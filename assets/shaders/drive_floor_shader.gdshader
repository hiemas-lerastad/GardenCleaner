shader_type spatial;
render_mode cull_disabled;

uniform sampler2D clean_texture;
uniform sampler2D dirt_texture;

uniform vec2 mesh_coords;
uniform sampler2D paint_texture;
uniform vec2 size;
uniform bool initialised = false;

varying vec3 world_position;
varying vec3 local_position;
varying vec2 paint_uv;
varying vec3 paint_value;
varying float paint_luminance;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_position = world_position - vec3(mesh_coords.x, 0.0, mesh_coords.y);
	paint_uv = (local_position.xz - (size / vec2(2.0))) / size;
	paint_uv = clamp(paint_uv, -0.99, -0.01);
}

void fragment() {
	paint_value = texture(paint_texture, paint_uv).rgb;
	vec3 clean_value = texture(clean_texture, paint_uv).rgb;
	vec3 dirt_value = texture(dirt_texture, paint_uv).rgb;
	
	vec3 color = mix(clean_value, dirt_value, paint_value);
	ALBEDO = color;
}