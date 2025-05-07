shader_type spatial;
render_mode cull_disabled;

uniform vec2 mesh_coords;
uniform sampler2D paint_texture;
uniform vec2 size = vec2(6.0, 6.0);
uniform bool initialised = false;

varying vec3 world_position;
varying vec3 local_position;
varying vec2 paint_uv;
varying vec4 paint_value;
varying float paint_luminance;
varying float height;

void vertex()
{
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_position = world_position - vec3(mesh_coords.x, 0.0, mesh_coords.y);
	paint_uv = (local_position.xz - (size / vec2(2.0))) / size;
	paint_value = texture(paint_texture, paint_uv);
	paint_luminance = (0.2126 * paint_value.r + 0.7152 * paint_value.g + 0.0722 * paint_value.b);

	if (!initialised) {
		paint_luminance = 0.0;
	}
	
	if (paint_uv.x > 0.5) {
		height = 1.0;
		VERTEX.y = 10.0;
	} else {
		height = VERTEX.y * (clamp(paint_luminance, 0.0, 0.7));	
	}
}

void fragment()
{
	//ALBEDO = paint_value.rgb;
	//ALBEDO = vec3(paint_luminance);

	//if (!initialised) {
	if (height > 0.07) {
		ALPHA = 0.0;
	}
	ALBEDO = vec3(0.5, 1.0, 0.0);
	//}
}