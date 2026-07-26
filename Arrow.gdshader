shader_type spatial;
render_mode unshaded;

// 0 = up arrow, 1 = down arrow, 2 = minus (flat dash)
uniform int indicator_mode : hint_range(0, 2) = 0;
uniform bool arrow_active = true;
uniform vec3 display_color : source_color = vec3(1.0, 0.15, 0.05);
uniform float glow_strength : hint_range(0.0, 5.0) = 1.5;
uniform float off_brightness : hint_range(0.0, 0.3) = 0.06;

float triangle_sdf(vec2 uv, bool up){
	vec2 p = uv - vec2(0.5, 0.5);
	if (!up) p.y = -p.y;
	float d = max(abs(p.x) * 1.6 - (0.5 - p.y), -p.y - 0.35);
	return d;
}

float minus_sdf(vec2 uv){
	vec2 p = uv - vec2(0.5, 0.5);
	vec2 d = abs(p) - vec2(0.3, 0.08);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

void fragment(){
	float lit = 0.0;

	if (arrow_active){
		if (indicator_mode == 0){
			lit = step(triangle_sdf(UV, true), 0.0);
		} else if (indicator_mode == 1){
			lit = step(triangle_sdf(UV, false), 0.0);
		} else {
			lit = step(minus_sdf(UV), 0.0);
		}
	}

	vec3 col = display_color * mix(off_brightness, 1.0, lit);
	ALBEDO = col;
	EMISSION = col * lit * glow_strength;
}