class_name PointInteractCast;
extends RayCast3D;

@export var object: PaintableObject

@export var draw_strength: float = 100;
@export var draw_size_multiplier: float = 1;

@export var collision_area: Area3D;

var pressing: bool = true;
var viewport_size: int = 512;

func _process(delta):
	if pressing and is_colliding():
		object = get_collider();
		var uv_coords = object.converter.get_uv_coords(get_collision_point(), get_collision_normal());
		
		var faces: Array = object.converter.get_faces_to_update(get_collision_point(), get_collision_normal());
		# USE TO MASK FOR EACH FACE AND DRAW CIRCLE OFFSET
		
		# FOR SHADER MIGHT NEED TO CHANGE DRAWING METHOD, CHANGE DRAWING TO CANVAS ITEM (TEXTURE RECT?) WITHIN VIEWPORT, DRAW ON THAT, APPLY SHADER TO THAT, AND GET OUTPUT FROM VIEWPORT
		
		object.draw_viewport.brush.scale = object.draw_viewport.base_brush_size * draw_size_multiplier
		#if uv_coords:
			#object.draw_viewport.move_brush(uv_coords * object.viewport_size, delta * draw_strength);
			#set_paint_tex(object.draw_viewport.get_texture());
			
		for face in faces:
			#get face coords - check
			var uvs: Array = object.converter.get_face_uvs(face.idx)
			print(uvs)
			var min_x: float = min(uvs[0].x, uvs[1].x, uvs[2].x);
			var min_y: float = min(uvs[0].y, uvs[1].y, uvs[2].y);
			var max_x: float = max(uvs[0].x, uvs[1].x, uvs[2].x);
			var max_y: float = max(uvs[0].y, uvs[1].y, uvs[2].y);
			
			var containing_rect = Rect2()
			containing_rect.position = Vector2(min_x, max_x);

			#get rect min size to fit face
			
			#generate mask the shape of face
			#blit_rect_mask(src: Image, mask: Image, src_rect: Rect2i, dst: Vector2i)
			#maybe need to convert to images, can I use only images and not textures? pass image into shader?
		
		if uv_coords:
			#if face == faces[0]:
			#object.draw_viewport.snapshot = object.output_viewport.get_texture().duplicate();
			object.draw_viewport.move_brush(uv_coords * object.viewport_size, delta * draw_strength);
			
			set_paint_tex(object.draw_viewport.get_texture());

func set_paint_tex(tex: Texture):
	object.mesh.set_paint_tex(tex);
