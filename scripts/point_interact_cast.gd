class_name PointInteractCast;
extends ShapeCast3D;

@export var object: PaintableObject;

@export var draw_strength: float = 100;
@export var draw_size_multiplier: float = 1;

var pressing: bool = false;
var viewport_size: int = 512;
	
func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 3 == 0:
		handle_paint(delta);

func handle_paint(delta) -> void:
	if pressing and is_colliding() and enabled:
		var index: int = Engine.get_physics_frames() % 2;

		if get_collision_count() - 1 < index:
			return;

		object = get_collider(index);

		var uv_coords = object.converter.get_uv_coords(get_collision_point(index), get_collision_normal(index));
		object.draw_viewport.brush.scale = object.draw_viewport.base_brush_size * draw_size_multiplier;

		if uv_coords:
			object.draw_viewport.move_brush(uv_coords * object.viewport_size, delta * draw_strength);
			
			set_paint_tex(object.draw_viewport.get_texture(), object);

func set_paint_tex(tex: Texture, object: PaintableObject)  -> void:
	object.mesh.set_paint_tex(tex);


		#var faces: Array = object.converter.get_faces_to_update(get_collision_point(), get_collision_normal());
		# USE TO MASK FOR EACH FACE AND DRAW CIRCLE OFFSET

		# FOR SHADER MIGHT NEED TO CHANGE DRAWING METHOD, CHANGE DRAWING TO CANVAS ITEM (TEXTURE RECT?) WITHIN VIEWPORT, DRAW ON THAT, APPLY SHADER TO THAT, AND GET OUTPUT FROM VIEWPORT

		#if uv_coords:
			#object.draw_viewport.move_brush(uv_coords * object.viewport_size, delta * draw_strength);
			#set_paint_tex(object.draw_viewport.get_texture());

		#for face in faces:
			##get face coords - check
			#var uvs: Array = object.converter.get_face_uvs(face.idx)
			##print(uvs)
			#var min_x: float = min(uvs[0].x, uvs[1].x, uvs[2].x);
			#var min_y: float = min(uvs[0].y, uvs[1].y, uvs[2].y);
			#var max_x: float = max(uvs[0].x, uvs[1].x, uvs[2].x);
			#var max_y: float = max(uvs[0].y, uvs[1].y, uvs[2].y);
			#
			#var containing_rect = Rect2()
			#containing_rect.position = Vector2(min_x, max_x);

			#get rect min size to fit face
			
			#generate mask the shape of face
			#blit_rect_mask(src: Image, mask: Image, src_rect: Rect2i, dst: Vector2i)
			#maybe need to convert to images, can I use only images and not textures? pass image into shader?


#func _on_area_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#objects.append(body);
#
#
#func _on_area_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#objects.erase(body);
