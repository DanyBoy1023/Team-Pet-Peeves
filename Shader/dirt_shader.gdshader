shader_type canvas_item;

uniform sampler2D dirt_mask : hint_default_black;
uniform vec4 dirt_color : source_color = vec4(0.22, 0.15, 0.08, 1.0);
uniform float dirt_amount : hint_range(0.0, 1.0) = 0.5;
uniform float dirt_scale = 2.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 base_col = texture(TEXTURE, UV);
	float mask = texture(dirt_mask, UV * dirt_scale).r;
	float factor = smoothstep(1.0 - dirt_amount, 1.0, mask) * dirt_amount;

	vec3 mixed_rgb = mix(base_col.rgb, dirt_color.rgb, factor);
	COLOR = vec4(mixed_rgb, base_col.a);
	COLOR = vec4(COLOR.rgb, COLOR.a * alpha);
}
