extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).

# Keep the whole sprite on screen (the sprite is about 80x174 px, centered on the node).
const MARGIN := Vector2(45.0, 88.0)
const HIT_ANIMATIONS := ["hit_disgust", "hit_hands", "hit_fall", "hit_fallaway"]

var screen_size # Size of the game window.
var active := false # True while a round is running.
var celebrating := false


func _ready():
	screen_size = get_viewport_rect().size


# Standing pose before a round starts.
func show_idle(pos):
	position = pos
	active = false
	celebrating = false
	$AnimatedSprite2D.play("idle")
	show()


func _process(delta):
	if not active:
		return

	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	position += velocity * delta
	position = position.clamp(MARGIN, screen_size - MARGIN)

	if celebrating:
		return

	# The street always scrolls, so the player is always walking.
	# Standing still plays "up" (walking away from the camera).
	var anim = "up"
	if velocity.x < 0:
		anim = "left"
	elif velocity.x > 0:
		anim = "right"
	elif velocity.y > 0:
		anim = "down"
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)


func start(pos):
	position = pos
	active = true
	celebrating = false
	$AnimatedSprite2D.play("up")
	show()
	$CollisionShape2D.disabled = false


# Short victory pose at score milestones. Movement keeps working.
func celebrate():
	if not active or celebrating:
		return
	celebrating = true
	$AnimatedSprite2D.play("victory")
	await get_tree().create_timer(0.8).timeout
	celebrating = false


func _on_body_entered(_body):
	if not active:
		return
	active = false
	celebrating = false
	# The player stays on screen and reacts to getting coughed on.
	$AnimatedSprite2D.play(HIT_ANIMATIONS.pick_random())
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
