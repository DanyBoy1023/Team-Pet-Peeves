extends Control

@export var ratio: float = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var screen_center = get_viewport_rect().size / 2
	
	var dif = screen_center - mouse_position
	
	offset_transform_position = dif * ratio
