shader_type canvas_item;

uniform vec2 tile_scale = vec2(2.0, 2.0);

void fragment() {
	COLOR = texture(TEXTURE, UV * tile_scale);
}
