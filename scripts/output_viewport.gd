class_name OutputViewport;
extends SubViewport;

@export var canvas: CanvasItem;
@export var canvas_material: ShaderMaterial;

var current_material: ShaderMaterial;

func _ready():
	current_material = canvas_material.duplicate();
	canvas.material = current_material;
	pass;
	
func set_snapshot(tex: Texture):
	canvas.texture = tex;

func set_tex(tex: Texture):
	current_material.set_shader_parameter("tex", tex);
	pass;

func set_region(point_a: Vector2, point_b: Vector2, point_c: Vector2):
	current_material.set_shader_parameter("point_a", point_a);
	current_material.set_shader_parameter("point_b", point_b);
	current_material.set_shader_parameter("point_c", point_c);
	pass;
