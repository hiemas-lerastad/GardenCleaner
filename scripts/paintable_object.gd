class_name PaintableObject
extends StaticBody3D;

@export var mesh: PaintableMesh;
@export var draw_viewport: DrawViewport;
@export var converter: PointToUVConverter;

@export var brush_size: Vector2 = Vector2(0.5, 0.5);
@export var threshold: int = 95;

var viewport_size: int = 512;

func _ready() -> void:
	viewport_size = draw_viewport.get_texture().get_size().x;
	draw_viewport.base_brush_size = brush_size;
	draw_viewport.threshold = threshold;
	converter.set_mesh(mesh);
