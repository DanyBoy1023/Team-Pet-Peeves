class_name Player
extends CharacterBody3D
# First-person walker. WASD or left stick to move, mouse or right stick to look, Shift to sprint.

signal bumped(walker)

const WALK_SPEED := 3.6
const SPRINT_SPEED := 6.0
const ACCEL := 18.0
const DECEL := 24.0
const GRAVITY := 20.0
const MOUSE_SENS := 0.0022
const STICK_LOOK := 2.6          # radians per second at full deflection
const HEAD_HEIGHT := 1.6
const MAX_STAMINA := 100.0
const SPRINT_DRAIN := 28.0
const STAMINA_REGEN := 16.0
const EXHAUST_RECOVER := 30.0    # stamina needed to sprint again after running dry
const BUMP_DISTANCE := 0.72      # player radius plus walker radius, with a little slack
const BUMP_COOLDOWN := 0.9
const KNOCKBACK := 3.2

var active := false
var stamina := MAX_STAMINA
var exhausted := false

var _move_vel := Vector2.ZERO
var _kick := Vector3.ZERO
var _cooldown := 0.0
var _bob := 0.0
var _shake := 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D


func reset(pos: Vector3) -> void:
	global_position = pos
	rotation = Vector3.ZERO
	head.rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	_move_vel = Vector2.ZERO
	_kick = Vector3.ZERO
	_cooldown = 0.0
	_shake = 0.0
	stamina = MAX_STAMINA
	exhausted = false
	active = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		head.rotation.x = clampf(head.rotation.x - event.relative.y * MOUSE_SENS, -1.3, 1.3)


func _physics_process(delta: float) -> void:
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look != Vector2.ZERO:
		rotate_y(-look.x * STICK_LOOK * delta)
		head.rotation.x = clampf(head.rotation.x - look.y * STICK_LOOK * delta, -1.3, 1.3)

	var input_dir := Vector2.ZERO
	if active:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	wish.y = 0.0
	if wish.length() > 1.0:
		wish = wish.normalized()

	# Sprint with a stamina pool. Running dry locks sprint until some stamina returns.
	var speed := WALK_SPEED
	var sprinting := active and Input.is_action_pressed("sprint") and not exhausted \
			and input_dir != Vector2.ZERO and stamina > 0.0
	if sprinting:
		speed = SPRINT_SPEED
		stamina = maxf(0.0, stamina - SPRINT_DRAIN * delta)
		if stamina <= 0.0:
			exhausted = true
	else:
		stamina = minf(MAX_STAMINA, stamina + STAMINA_REGEN * delta)
		if exhausted and stamina >= EXHAUST_RECOVER:
			exhausted = false

	var target := Vector2(wish.x, wish.z) * speed
	var rate := ACCEL if input_dir != Vector2.ZERO else DECEL
	_move_vel = _move_vel.move_toward(target, rate * delta)
	_kick = _kick.move_toward(Vector3.ZERO, 12.0 * delta)

	velocity.x = _move_vel.x + _kick.x
	velocity.z = _move_vel.y + _kick.z
	if is_on_floor():
		velocity.y = -0.5
	else:
		velocity.y -= GRAVITY * delta
	move_and_slide()

	_update_head(delta, _move_vel.length())

	_cooldown = maxf(0.0, _cooldown - delta)
	if active and _cooldown <= 0.0:
		_check_walkers()


func _update_head(delta: float, speed: float) -> void:
	_bob += delta * speed * 2.6
	var amount := clampf(speed / SPRINT_SPEED, 0.0, 1.0)
	head.position.y = HEAD_HEIGHT + sin(_bob) * 0.035 * amount
	_shake = maxf(0.0, _shake - delta * 2.5)
	camera.h_offset = randf_range(-1.0, 1.0) * _shake * 0.08
	camera.v_offset = randf_range(-1.0, 1.0) * _shake * 0.08


func _check_walkers() -> void:
	var p := Vector2(global_position.x, global_position.z)
	for node in get_tree().get_nodes_in_group("walkers"):
		var w := node as Walker
		if w == null:
			continue
		var wp := Vector2(w.global_position.x, w.global_position.z)
		if p.distance_to(wp) < BUMP_DISTANCE:
			var away := (p - wp).normalized()
			_kick = Vector3(away.x, 0.0, away.y) * KNOCKBACK
			_cooldown = BUMP_COOLDOWN
			_shake = 1.0
			bumped.emit(w)
			return
