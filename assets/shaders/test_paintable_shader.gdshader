shader_type spatial;

uniform sampler2D paint_texture : hint_default_black;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 test_texture = texture(paint_texture, UV);
	ALBEDO = vec3(test_texture.x, test_texture.y, test_texture.z);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
