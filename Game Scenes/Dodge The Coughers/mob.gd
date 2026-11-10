extends RigidBody2D


func _ready():
	# Pick one of the sick pedestrian types (cough, sneeze, hack).
	var types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	var type = types.pick_random()
	$AnimatedSprite2D.animation = type
	# Randomize the pace and starting frame so groups don't cough in unison.
	$AnimatedSprite2D.speed_scale = randf_range(0.8, 1.3)
	$AnimatedSprite2D.frame = randi() % $AnimatedSprite2D.sprite_frames.get_frame_count(type)
	$AnimatedSprite2D.play()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
