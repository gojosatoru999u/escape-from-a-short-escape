shader_type canvas_item;

uniform vec4 color: source_color;
uniform float multiplier = 1.0;
uniform float softness = 2.0;

void fragment() {
	float value = distance(UV, vec2(0.5));
	COLOR = vec4(color.r, 0.0, 0.0, smoothstep(multiplier, softness, value));
}
