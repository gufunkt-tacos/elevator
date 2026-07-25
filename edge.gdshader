shader_type spatial;
render_mode unshaded;

// --- Edge detection uniforms ---
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float threshold = 0.1;
uniform float blend = 0.2;
uniform bool enable_depth_pass = true;
uniform float threshold_depth = 0.05;
uniform float blend_depth = 0.3;
uniform float distance_fade_length = 50.0;
uniform float distance_fade_blend = 20.0;

// --- Soft / glowy / pixelated look ---
uniform bool enable_pixelate = true;
uniform float pixel_factor : hint_range(1.0, 8.0) = 3.0;

uniform bool enable_posterize = true;
uniform float color_levels : hint_range(3.0, 24.0) = 10.0;
uniform float color_softness : hint_range(0.0, 1.0) = 0.45;

uniform float glow_strength : hint_range(0.0, 2.0) = 0.9;
uniform float glow_threshold : hint_range(0.0, 1.0) = 0.4;
uniform float glow_spread : hint_range(0.5, 6.0) = 2.5;

uniform vec3 tint_color = vec3(1.0, 0.97, 0.94);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.15;
uniform float saturation : hint_range(0.0, 2.0) = 0.85;

// --- Edge detection helpers ---
float getGrayScale(sampler2D sampler, vec2 coods){
	vec4 color = texture(sampler, coods);
	return (color.r + color.g + color.b) / 3.0;
}

float get_linear_depth(sampler2D sampler, vec2 coords, mat4 ipm){
	float depth = texture(sampler, coords).r;
	vec3 ndc = vec3(coords, depth) * 2.0 - 1.0;
	vec4 view = ipm * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

vec3 to_hsv(vec3 c){
	float cmax = max(c.r, max(c.g, c.b));
	float cmin = min(c.r, min(c.g, c.b));
	float d = cmax - cmin;
	float h = 0.0;
	if (d > 1e-5) {
		if      (cmax == c.r) h = mod((c.g - c.b) / d, 6.0);
		else if (cmax == c.g) h = (c.b - c.r) / d + 2.0;
		else                  h = (c.r - c.g) / d + 4.0;
		h /= 6.0;
		if (h < 0.0) h += 1.0;
	}
	float s = cmax <= 1e-5 ? 0.0 : d / cmax;
	return vec3(h, s, cmax);
}

vec3 to_rgb(vec3 hsv){
	float h = hsv.x * 6.0;
	float s = hsv.y;
	float v = hsv.z;
	int i = int(floor(h));
	float f = h - float(i);
	float p = v * (1.0 - s);
	float q = v * (1.0 - s * f);
	float t = v * (1.0 - s * (1.0 - f));
	if(i == 0) return vec3(v, t, p);
	if(i == 1) return vec3(q, v, p);
	if(i == 2) return vec3(p, v, t);
	if(i == 3) return vec3(p, q, v);
	if(i == 4) return vec3(t, p, v);
	return vec3(v, p, q);
}

float reduce_color_soft(float raw, float levels, float softness){
	float scaled = raw * levels;
	float snapped = floor(scaled + 0.5) / levels;
	return mix(snapped, raw, softness);
}

void fragment(){
	vec2 px = 1.0 / VIEWPORT_SIZE;
	vec2 delta = vec2(0.0, 0.003);
	vec2 texCoords = SCREEN_UV;

	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

	// --- Edge detection (color pass) ---
	float c1y = getGrayScale(SCREEN_TEXTURE, texCoords.xy - delta / 2.0);
	float c2y = getGrayScale(SCREEN_TEXTURE, texCoords.xy + delta / 2.0);
	float c1x = getGrayScale(SCREEN_TEXTURE, texCoords.xy - delta.yx / 2.0);
	float c2x = getGrayScale(SCREEN_TEXTURE, texCoords.xy + delta.yx / 2.0);
	float dcdx = (c2x - c1x) / (delta.y * 10.0);
	float dcdy = (c2y - c1y) / (delta.y * 10.0);
	float edge = length(vec2(dcdx, dcdy)) / 10.0;
	edge = 1.0 - edge;
	edge = smoothstep(threshold, threshold + blend, edge);
	float final_edge = edge;

	// --- Edge detection (depth pass) ---
	if (enable_depth_pass){
		c1y = get_linear_depth(DEPTH_TEXTURE, texCoords.xy - delta / 2.0, INV_PROJECTION_MATRIX);
		c2y = get_linear_depth(DEPTH_TEXTURE, texCoords.xy + delta / 2.0, INV_PROJECTION_MATRIX);
		c1x = get_linear_depth(DEPTH_TEXTURE, texCoords.xy - delta.yx / 2.0, INV_PROJECTION_MATRIX);
		c2x = get_linear_depth(DEPTH_TEXTURE, texCoords.xy + delta.yx / 2.0, INV_PROJECTION_MATRIX);
		dcdx = (c2x - c1x) / (delta.y * 10.0);
		dcdy = (c2y - c1y) / (delta.y * 10.0);
		float depth_edge = length(vec2(dcdx, dcdy)) / 10.0;
		depth_edge = 1.0 - depth_edge;
		depth_edge = smoothstep(threshold_depth, threshold_depth + blend_depth, depth_edge);
		final_edge *= depth_edge;
	}

	float linear_depth = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
	float df = 1.0 - smoothstep(distance_fade_length, distance_fade_length + distance_fade_blend, linear_depth);
	final_edge = (1.0 - final_edge) * df;
	final_edge = 1.0 - final_edge;

	vec3 result = mix(edge_color.rgb, screen_color.rgb, final_edge);

	// --- Soft pixelation ---
	vec2 uv = SCREEN_UV;
	if (enable_pixelate){
		vec2 step_uv = px * pixel_factor;
		uv = floor(uv / step_uv) * step_uv + step_uv * 0.5;
		result = texture(SCREEN_TEXTURE, uv).rgb;
		// blend the pixelated sample gently back with the un-pixelated result
		// so blocks feel soft-edged rather than hard-cut
		vec3 soft_blend = mix(result, mix(edge_color.rgb, screen_color.rgb, final_edge), 0.35);
		result = soft_blend;
	}

	// --- Gentle glow: bloom bright areas outward using a few soft offset samples ---
	vec3 glow = vec3(0.0);
	if (glow_strength > 0.0){
		vec2 glow_px = px * glow_spread;
		vec3 s1 = texture(SCREEN_TEXTURE, uv + vec2( glow_px.x, 0.0)).rgb;
		vec3 s2 = texture(SCREEN_TEXTURE, uv + vec2(-glow_px.x, 0.0)).rgb;
		vec3 s3 = texture(SCREEN_TEXTURE, uv + vec2(0.0,  glow_px.y)).rgb;
		vec3 s4 = texture(SCREEN_TEXTURE, uv + vec2(0.0, -glow_px.y)).rgb;
		vec3 avg = (s1 + s2 + s3 + s4) * 0.25;

		float luma = dot(avg, vec3(0.2126, 0.7152, 0.0722));
		float mask = smoothstep(glow_threshold, 1.0, luma);
		glow = avg * mask * glow_strength;
	}

	vec3 col = result + glow;

	// --- Soft color quantization (gentle, not harsh banding) ---
	if (enable_posterize){
		col.r = reduce_color_soft(col.r, color_levels, color_softness);
		col.g = reduce_color_soft(col.g, color_levels, color_softness);
		col.b = reduce_color_soft(col.b, color_levels, color_softness);
	}

	// --- Warm/soft tint + gentle desaturation for a pastel feel ---
	col = mix(col, col * tint_color, tint_strength);
	vec3 hsv = to_hsv(clamp(col, 0.0, 1.0));
	hsv.y *= saturation;
	col = to_rgb(hsv);

	ALBEDO = clamp(col, 0.0, 1.0);
}