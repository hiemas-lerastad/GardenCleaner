class_name PaintableObject
extends StaticBody3D;

@export var mesh: PaintableMesh;
@export var draw_viewport: DrawViewport;
@export var output_viewport: SubViewport;
@export var converter: PointToUVConverter;
@export var mesh_material: ShaderMaterial;

@export var brush_size: Vector2 = Vector2(0.5, 0.5);
@export var threshold: int = 95;
@export var size: Vector2 = Vector2(10.0, 10.0);

var viewport_size: int = 512;

func _ready() -> void:
	viewport_size = draw_viewport.get_texture().get_size().x;
	draw_viewport.base_brush_size = brush_size;
	draw_viewport.threshold = threshold;
	converter.set_mesh(mesh);

	mesh.shader_material = mesh_material.duplicate();
	print(mesh.shader_material)
	mesh.size = Vector2(10, 10);
	
	mesh.initialise();
