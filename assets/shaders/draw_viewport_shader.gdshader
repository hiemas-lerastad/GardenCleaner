shader_type canvas_item;

uniform sampler2D tex;
uniform vec2 point_a;
uniform vec2 point_b;
uniform vec2 point_c;

void fragment() {
	float alpha = ((point_b.y - point_c.y)*(UV.x - point_c.x) + (point_c.x - point_b.x)*(UV.y - point_c.y)) /
	        ((point_b.y - point_c.y)*(point_a.x - point_c.x) + (point_c.x - point_b.x)*(point_a.y - point_c.y));
	float beta = ((point_c.y - point_a.y)*(UV.x - point_c.x) + (point_a.x - point_c.x)*(UV.y - point_c.y)) /
	       ((point_b.y - point_c.y)*(point_a.x - point_c.x) + (point_c.x - point_b.x)*(point_a.y - point_c.y));
	float gamma = 1.0f - alpha - beta;

	if (alpha > 0.0 && beta > 0.0 && gamma > 0.0) {
		vec4 test_texture = texture(tex, UV);
		COLOR = test_texture;
		//COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}
