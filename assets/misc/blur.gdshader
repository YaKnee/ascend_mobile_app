shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5) = 0.8;
uniform float darken: hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 colour = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	colour.rgb *= (1.0 - darken);
	COLOR = colour;
}
