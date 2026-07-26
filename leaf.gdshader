shader_type spatial;
render_mode cull_disabled;

uniform float strength = 0.3;
uniform float speed = 2.0;

void vertex() {
	float wave = sin(TIME * speed + VERTEX.y * 8.0);

	// Keep Y unchanged
	float bend = max(VERTEX.y, 0.0);

	// Only move sideways
	VERTEX.x += wave * strength * bend;
	VERTEX.z += cos(TIME * speed * 0.7) * strength * bend;
}

void fragment() {
	ALBEDO = vec3(0.1, 0.8, 0.2);
}