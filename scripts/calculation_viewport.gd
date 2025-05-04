class_name CalculationViewport
extends SubViewport

@export var nextCalculationVP: CalculationViewport
@export var sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_texture(tex: Texture) -> float:
	render_target_update_mode = SubViewport.UPDATE_ONCE
	sprite.texture = tex
	if nextCalculationVP:
		return nextCalculationVP.set_texture(get_texture())
	else:
		var data = get_texture().get_image().get_data()
		var sum = 0
		for point in data:
			sum += point
		var avg = sum / data.size()
		var progress = float(avg) / 256
		return progress
