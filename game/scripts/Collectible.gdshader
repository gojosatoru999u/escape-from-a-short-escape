shader_type canvas_item;

uniform float line_thickness : hint_range(0, 10) = 1.0;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	float outline = 0.0;

	for (int i=0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline = min(outline, 1.0);

	vec4 color = texture(TEXTURE, UV);

	float flash = mod(floor(TIME * 2.0), 2.0);
	vec3 line_color = mix(vec3(1.0, 1.0, 0.0), vec3(1.0), flash);
	COLOR = mix(color, vec4(line_color, 1.0), outline - color.a);
}
