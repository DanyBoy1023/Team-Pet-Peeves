extends Node2D

@onready var cat_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var left_top: Marker2D = $"left top"
@onready var left_bottom: Marker2D = $"left bottom"
@onready var right_top: Marker2D = $"right top"
@onready var right_bottom: Marker2D = $"right bottom"


func spawn_new_cat_sprite():
	var new_cat_sprite : AnimatedSprite2D = cat_sprite.duplicate()
	add_child(new_cat_sprite)
	var start_position: Vector2
	var end_position: Vector2
	if randf() >= .5:
		# right
		start_position = get_random_right_point()
		end_position = get_random_left_point()
	else:
		# left
		start_position = get_random_left_point()
		end_position = get_random_right_point()
	
	new_cat_sprite.global_position = start_position
	
	# randomize sprite frame
	var random_frame = randi_range(0, new_cat_sprite.sprite_frames.get_frame_count("random cat") - 1)
	new_cat_sprite.frame = random_frame
	new_cat_sprite.z_index = randi_range(-1, 1)
	
	var tween: Tween = create_tween()
	var duration = randf_range(10, 15)
	tween.tween_property(new_cat_sprite, "global_position", end_position, duration)
	tween.tween_callback(new_cat_sprite.queue_free)

func get_random_right_point() -> Vector2:
	var pos = right_top.global_position
	pos.y = randf_range(right_top.global_position.y, right_bottom.global_position.y)
	return pos

func get_random_left_point() -> Vector2:
	var pos = left_top.global_position
	pos.y = randf_range(left_top.global_position.y, left_bottom.global_position.y)
	return pos


func _on_timer_timeout() -> void:
	for i in randi_range(1,3):
		spawn_new_cat_sprite()
