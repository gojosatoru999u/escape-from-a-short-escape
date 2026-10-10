shader_type canvas_item;

uniform float flash_strength = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 flash_color = vec4(1.0, 0.0, 0.0, 1.0); // red

    COLOR = mix(tex_color, flash_color, flash_strength) * tex_color.a;
}
