shader_type spatial;
render_mode cull_disabled, diffuse_toon, specular_schlick_ggx, depth_prepass_alpha;
// Nice Shader by @_Malido ^^

uniform vec3 top_color: source_color;
uniform vec3 bottom_color: source_color;
uniform float ambient_occlusion_factor: hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float specular_strength: hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float player_displacement_strength: hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float player_displacement_size: hint_range(0.0, 2.0, 0.01) = 1.0;

uniform vec3 wind_direction; // Use a negative y component to give it an extra touch (For displacement effect and noise scroll direction)
uniform float wind_strength: hint_range(0.0, 1.0, 0.01) = 0.3;
uniform sampler2D wind_noise; // Periln FBM Noise looks Best
uniform float wind_noise_size: hint_range(0.0, 1.0, 0.001) = 0.05; // high values dont work well
uniform float wind_noise_speed: hint_range(0.0, 1.0, 0.001) = 0.1;

uniform vec2 mesh_coords;
uniform sampler2D paint_texture;
uniform vec2 size;
uniform bool initialised = false;

varying vec3 world_position;
varying vec3 local_position;
varying vec2 paint_uv;
varying vec4 paint_value;
varying float paint_luminance;
varying float height;

// Instance the Player Position through a GDScript in the _physics_process
instance uniform vec3 player_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_position = world_position - vec3(mesh_coords.x, 0.0, mesh_coords.y);
	paint_uv = (local_position.xz - (size / vec2(2.0))) / size;
	paint_uv = clamp(paint_uv, -0.99, -0.01);
	paint_value = texture(paint_texture, paint_uv);
	paint_luminance = (0.2126 * paint_value.r + 0.7152 * paint_value.g + 0.0722 * paint_value.b);

	if (!initialised) {
		paint_luminance = 0.0;
	}

	height = VERTEX.y * (clamp(paint_luminance, 0.0, 0.7));
	
	//height = 0.14;
	
	if (paint_uv.x > 1.0) {
		height = 1.0;
	}

	vec3 wind_texture = texture(wind_noise, world_position.xz * wind_noise_size + normalize(-wind_direction.xz) * (TIME + UV.y / 2.5) * wind_noise_speed).rgb;
	vec3 wind_vector = (vec4(wind_texture * normalize(wind_direction) * wind_strength, 0.0) * MODEL_MATRIX).xyz;

	float player_height = smoothstep(1.0, 0.0, length(player_position.y - world_position.y + 0.3));
	vec3 push_direction = vec3(world_position - player_position) * vec3(1 , -0.3 ,1);
	float player_position_factor = smoothstep(player_displacement_size, 0.0, length(push_direction));

	vec3 player_push_vector = (vec4(normalize(push_direction), 0.0) * MODEL_MATRIX).xyz;

	// Apply Player Position displacement
	//VERTEX += player_push_vector * (1.0 - UV.y) * player_position_factor * player_displacement_strength * player_height;
	// Apply Wind displacement linearly
	VERTEX += wind_vector * (1.0 - UV.y) * (1.0 - player_position_factor * 0.7);

	// A new normal correction, which aligns the normals of the mesh facing upwards no matter the original direction.
	NORMAL = vec3(0.0, 1.0, 0.0);
}

void fragment() {
	vec3 color = mix(bottom_color, top_color, 1.0 - UV.y);

	// Add fake ambient occlusion by darkening the base of the mesh
	float ao_fallof = pow(UV.y, 5.0);
	vec3 ao_color = bottom_color * (1.0 - ambient_occlusion_factor);

	ALBEDO = mix(color, ao_color, ao_fallof);
	ROUGHNESS = 0.4;

	// Increase the Specular with Grass Height
	SPECULAR *= (1.0 - UV.y) * specular_strength;

	// Just removing some funny shading
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}

	if (height > 0.13) {
		ALPHA = 0.0;
	}
}