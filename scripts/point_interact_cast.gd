class_name PointInteractCast;
extends RayCast3D;

#@export var converter: PointToUVConverter;
@export var object: PaintableObject
#@export var draw_viewport: DrawViewport;
#@export var mesh: PaintableMesh;

@export var draw_strength: float = 100;
@export var draw_size_multiplier: float = 1;

var pressing: bool = true;
var viewport_size: int = 512;

#func _ready():
	#if draw_viewport:
		#viewport_size = draw_viewport.get_texture().get_size().x;

func _process(delta):
	if pressing and is_colliding():
		object = get_collider();
		var uv_coords = object.converter.get_uv_coords(get_collision_point(), get_collision_normal());
		object.draw_viewport.brush.scale = object.draw_viewport.base_brush_size * draw_size_multiplier
		if uv_coords:
			object.draw_viewport.move_brush(uv_coords * object.viewport_size, delta * draw_strength);
			set_paint_tex(object.draw_viewport.get_texture());

	#pressing = is_pressing;
	
func set_paint_tex(tex: Texture):
	object.mesh.set_paint_tex(tex);
