shader_type spatial;
render_mode cull_disabled;

uniform vec3 top_color: source_color;
uniform vec3 bottom_color: source_color;
uniform vec3 base_color: source_color;

uniform vec2 mesh_coords;
uniform sampler2D paint_texture;
uniform vec2 size;
uniform bool initialised = false;

varying vec3 world_position;
varying vec3 local_position;
varying vec2 paint_uv;
varying vec3 paint_value;
varying float paint_luminance;

uniform float max_visible_distance: hint_range(0.0, 200.0, 1.0) = 100.0;
uniform vec3 player_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_position = world_position - vec3(mesh_coords.x, 0.0, mesh_coords.y);
	paint_uv = (local_position.xz - (size / vec2(2.0))) / size;
	paint_uv = clamp(paint_uv, -0.99, -0.01);
}

void fragment() {
	float blend_distance = 10.0;

	paint_value = texture(paint_texture, paint_uv).rgb;
	if (length(player_position - world_position) > max_visible_distance - blend_distance) {
		float distance_value = (clamp(length(player_position - world_position), max_visible_distance - blend_distance, max_visible_distance) - (max_visible_distance - blend_distance)) / blend_distance;
		vec3 currentColor;
		
		currentColor = mix(top_color, bottom_color, paint_value);

		ALBEDO = mix(base_color, currentColor, distance_value);
	} else {
		ALBEDO = base_color;
	}
}