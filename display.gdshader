shader_type spatial;
render_mode unshaded;
uniform int digit : hint_range(-1, 9) = 0; // -1 = blank (for leading zeros)
uniform vec3 display_color : source_color = vec3(1.0, 0.15, 0.05);
uniform float glow_strength : hint_range(0.0, 5.0) = 1.5;
uniform float off_brightness : hint_range(0.0, 0.3) = 0.06;
const int SEGMENT_MASKS[10] = int[10](
    0x3F, 0x06, 0x5B, 0x4F, 0x66,
    0x6D, 0x7D, 0x07, 0x7F, 0x6F
);
bool has_segment(int mask, int bit_index){
    return (mask & (1 << bit_index)) != 0;
}
float segment_a(vec2 uv){ return step(0.35, uv.x) * step(uv.x, 0.65) * step(0.85, uv.y); }
float segment_g(vec2 uv){ return step(0.35, uv.x) * step(uv.x, 0.65) * step(0.45, uv.y) * step(uv.y, 0.55); }
float segment_d(vec2 uv){ return step(0.35, uv.x) * step(uv.x, 0.65) * step(uv.y, 0.15); }
float segment_f(vec2 uv){ return step(0.15, uv.y) * step(uv.y, 0.85) * step(0.1, uv.x) * step(uv.x, 0.3) * step(0.5, uv.y); }
float segment_b(vec2 uv){ return step(0.15, uv.y) * step(uv.y, 0.85) * step(0.7, uv.x) * step(uv.x, 0.9) * step(0.5, uv.y); }
float segment_e(vec2 uv){ return step(0.15, uv.y) * step(uv.y, 0.85) * step(0.1, uv.x) * step(uv.x, 0.3) * step(uv.y, 0.5); }
float segment_c(vec2 uv){ return step(0.15, uv.y) * step(uv.y, 0.85) * step(0.7, uv.x) * step(uv.x, 0.9) * step(uv.y, 0.5); }
void fragment(){
    vec2 uv = UV;
    float lit = 0.0;
    if (digit >= 0 && digit <= 9){
        int mask = SEGMENT_MASKS[digit];
        if (has_segment(mask, 0)) lit = max(lit, segment_a(uv));
        if (has_segment(mask, 1)) lit = max(lit, segment_b(uv));
        if (has_segment(mask, 2)) lit = max(lit, segment_c(uv));
        if (has_segment(mask, 3)) lit = max(lit, segment_d(uv));
        if (has_segment(mask, 4)) lit = max(lit, segment_e(uv));
        if (has_segment(mask, 5)) lit = max(lit, segment_f(uv));
        if (has_segment(mask, 6)) lit = max(lit, segment_g(uv));
    }
    vec3 col = display_color * mix(off_brightness, 1.0, lit);
    ALBEDO = col;
    EMISSION = col * lit * glow_strength;
}