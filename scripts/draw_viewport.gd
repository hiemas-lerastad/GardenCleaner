class_name DrawViewport
extends SubViewport

signal progress_above_threshold()

@export var brush: Sprite2D
@export var calculation_viewport: CalculationViewport
@export var black_backgound: ColorRect;

@export var compare_texture: SubViewport;

var base_brush_size: Vector2 = Vector2(1, 1);
var threshold: int = 95;
var completed: bool = false;

func _ready() -> void:
	refresh()
	move_brush(Vector2.LEFT * 1000, 0, true)

func move_brush(position: Vector2, brush_amount: float, first: bool = false):
	if not completed:
		render_target_update_mode = SubViewport.UPDATE_ONCE
		brush.self_modulate.a = brush_amount
		brush.position = position
		if !first:
			black_backgound.visible = false
			var texture_difference: Dictionary = get_texture().get_image().compute_image_metrics(compare_texture.get_texture().get_image(), true)
			var percent: int = ceil((texture_difference.mean/255) * 400)

			if percent >= threshold and not completed:
				set_complete()

func set_complete():
	completed = true;
	black_backgound.color = Color.WHITE;
	black_backgound.visible = true;
	render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	render_target_update_mode = SubViewport.UPDATE_ONCE

func refresh():
	black_backgound.visible = true;
	render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	render_target_update_mode = SubViewport.UPDATE_ONCE
