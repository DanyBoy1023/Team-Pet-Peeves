extends RigidBody2D

# Emitted when this pedestrian coughs, so Main can play the sound.
signal coughed

# walk:    looping animation
# special: optional one-shot animation that plays now and then ("" for none)
# away:    true if the person walks the same way as the player, so they move
#          slower than the street scrolls instead of faster
# radius, height: collision capsule in pixels
const TYPES := [
	{"walk": "e1_walk", "special": "e1_cough", "weight": 3, "away": false, "radius": 20.0, "height": 120.0},
	{"walk": "e2_toward", "special": "", "weight": 2, "away": false, "radius": 20.0, "height": 120.0},
	{"walk": "e2_away", "special": "", "weight": 1, "away": true, "radius": 20.0, "height": 120.0},
	{"walk": "e3_walk", "special": "", "weight": 2, "away": false, "radius": 20.0, "height": 120.0},
	{"walk": "e4_walk", "special": "e4_barf", "weight": 2, "away": false, "radius": 18.0, "height": 100.0},
]

var kind: Dictionary
var sway_time := randf() * TAU


func _ready():
	kind = _pick_type()
	$AnimatedSprite2D.speed_scale = randf_range(0.85, 1.2)
	$AnimatedSprite2D.play(kind.walk)

	# Each mob gets its own shape, because the scene's shape resource is shared.
	var shape := CapsuleShape2D.new()
	shape.radius = kind.radius
	shape.height = kind.height
	$CollisionShape2D.shape = shape

	if kind.special != "":
		$SpecialTimer.start(randf_range(0.8, 2.2))


# Called by Main right after the mob is added to the scene.
func launch(scroll_speed: float):
	var vy: float
	if kind.away:
		vy = maxf(scroll_speed * 0.4, scroll_speed - randf_range(110.0, 170.0))
	else:
		vy = scroll_speed + randf_range(40.0, 140.0)
	linear_velocity = Vector2(randf_range(-50.0, 50.0), vy)


func _process(delta):
	# Paper cut-out wobble: tilt and bob in step with the walk.
	sway_time += delta * 7.0 * $AnimatedSprite2D.speed_scale
	$AnimatedSprite2D.rotation = sin(sway_time) * 0.07
	$AnimatedSprite2D.position.y = -absf(sin(sway_time)) * 4.0


func _pick_type() -> Dictionary:
	var total := 0
	for t in TYPES:
		total += t.weight
	var roll := randi() % total
	for t in TYPES:
		roll -= t.weight
		if roll < 0:
			return t
	return TYPES[0]


func _on_special_timer_timeout():
	$AnimatedSprite2D.play(kind.special)
	if kind.special == "e1_cough":
		coughed.emit()


func _on_animated_sprite_2d_animation_finished():
	# Only the one-shot animations finish; go back to walking and wait for the next one.
	if $AnimatedSprite2D.animation == kind.special:
		$AnimatedSprite2D.play(kind.walk)
		$SpecialTimer.start(randf_range(1.5, 3.0))


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
