class_name Walker
extends CharacterBody3D
# One pedestrian: an upright paper cut-out that walks slowly along the street.
#
# motion "away":   walks the same way as the player, slowly. The classic slow walker.
# motion "toward": walks toward the player and steps around slow walkers in its way.
# motion "left" / "right": crosses the street sideways.
#
# Main spawns walkers in formations (stacks, pairs, rows, crowds). Group members share one pace
# and do not drift sideways, so the group holds its shape and keeps its lanes blocked.
#
# Sprite frames come from art/<name>.png. Every frame of a character shares one canvas that sits
# on the bottom edge, so one pixel size keeps all of them at the right height.

const PIXEL_SIZE := 1.75 / 340.0   # meters per texture pixel; adult sprites are about 340 px tall
const SHADOW_SIZE := 0.9
const FOLLOW_GAP := 1.6            # closer than this behind a walker in the same lane, match its pace
const FOLLOW_WIDTH := 0.7          # and within this sideways distance counts as the same lane

const KINDS := [
	{"id": "e1", "motion": "toward", "weight": 3, "speed": Vector2(0.7, 1.2),
	 "walk": ["e1_walk_1", "e1_walk_2"]},
	{"id": "e2_toward", "motion": "toward", "weight": 2, "speed": Vector2(0.6, 1.1),
	 "walk": ["e2_toward"]},
	{"id": "e3", "motion": "toward", "weight": 2, "speed": Vector2(0.6, 1.1),
	 "walk": ["e3_walk"]},
	{"id": "e4", "motion": "toward", "weight": 2, "speed": Vector2(0.9, 1.4),
	 "walk": ["e4_walk"]},
	{"id": "e2_away", "motion": "away", "weight": 4, "speed": Vector2(0.4, 0.8),
	 "walk": ["e2_away"]},
	{"id": "up", "motion": "away", "weight": 3, "speed": Vector2(0.45, 0.9),
	 "walk": ["player_up_1", "player_up_2"]},
	{"id": "left", "motion": "left", "weight": 1, "speed": Vector2(0.6, 1.0),
	 "walk": ["player_left_1", "player_left_2"]},
	{"id": "right", "motion": "right", "weight": 1, "speed": Vector2(0.6, 1.0),
	 "walk": ["player_right_1", "player_right_2"]},
]

static var _tex_cache := {}
static var _shadow_tex: Texture2D

# Set by Main before the walker enters the tree.
var kind: Dictionary = {}
var speed := -1.0               # meters per second; random from the kind when negative
var drift := 0.12               # sideways wander in m/s. Main sets 0 for group members.

var current_speed := 0.0

var _dir := Vector3(0.0, 0.0, -1.0)
var _age := 0.0
var _phase := randf() * TAU
var _step := 0.0
var _fade := 0.0
var _stagger := 0.0
var _frame_name := ""

@onready var _sprite: Sprite3D = $Sprite3D


# Weighted random kind. Pass a motion ("away", "toward", "left", "right") to limit the pool.
static func random_kind(motion: String = "") -> Dictionary:
	var pool: Array = []
	var total := 0
	for k in KINDS:
		if motion == "" or k.motion == motion:
			pool.append(k)
			total += k.weight
	var roll := randi() % total
	for k in pool:
		roll -= k.weight
		if roll < 0:
			return k
	return pool[0]


static func get_tex(frame: String) -> Texture2D:
	if not _tex_cache.has(frame):
		_tex_cache[frame] = load("res://Game Scenes/Slow Walker/art/%s.png" % frame)
	return _tex_cache[frame]


func _ready() -> void:
	if kind.is_empty():
		kind = random_kind()
	if speed < 0.0:
		speed = randf_range(kind.speed.x, kind.speed.y)
	match kind.motion:
		"away":
			_dir = Vector3(0.0, 0.0, -1.0)
		"toward":
			_dir = Vector3(0.0, 0.0, 1.0)
		"left":
			_dir = Vector3(-1.0, 0.0, 0.0)
		"right":
			_dir = Vector3(1.0, 0.0, 0.0)

	_sprite.pixel_size = PIXEL_SIZE
	_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_sprite.shaded = false
	_set_frame(kind.walk[0])
	_sprite.modulate.a = 0.0
	_add_shadow()


# Freezes the walker for a moment, for example after the player bumps into it.
func stagger(seconds: float) -> void:
	_stagger = seconds


func _add_shadow() -> void:
	if _shadow_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(0, 0, 0, 0.5))
		g.set_color(1, Color(0, 0, 0, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.5)
		gt.fill_to = Vector2(1.0, 0.5)
		gt.width = 64
		gt.height = 64
		_shadow_tex = gt
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_texture = _shadow_tex
	var mesh := QuadMesh.new()
	mesh.size = Vector2(SHADOW_SIZE, SHADOW_SIZE)
	mesh.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	mi.position = Vector3(0.0, 0.03, 0.0)
	add_child(mi)


func _set_frame(frame: String) -> void:
	if frame == _frame_name:
		return
	_frame_name = frame
	var tex := get_tex(frame)
	_sprite.texture = tex
	if tex != null:
		# Feet on the floor: the sprite is centered, so lift it by half its height.
		_sprite.position.y = tex.get_height() * PIXEL_SIZE / 2.0


func _process(delta: float) -> void:
	_age += delta
	_fade = minf(1.0, _fade + delta * 1.8)
	_sprite.modulate.a = _fade

	# Walk cycle: frames swap in step with how fast the walker moves.
	_step += delta * (0.5 + current_speed * 1.4)
	var frames: Array = kind.walk
	_set_frame(frames[int(_step * 2.0) % frames.size()])
	# Small bob so single-frame walkers still read as walking.
	_sprite.position.y = get_tex(_frame_name).get_height() * PIXEL_SIZE / 2.0 \
			+ absf(sin(_step * PI)) * 0.035 * clampf(current_speed, 0.0, 1.2)


func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player != null and _should_despawn(player.global_position):
		queue_free()
		return

	_stagger = maxf(0.0, _stagger - delta)
	var target := speed
	if _stagger > 0.0:
		target = 0.0
	var lane_walker: bool = kind.motion == "away" or kind.motion == "toward"
	if lane_walker:
		target = minf(target, _neighbor_limit())
	current_speed = move_toward(current_speed, target, 2.5 * delta)

	var vel := _dir * current_speed
	if lane_walker:
		vel.x = sin(_age * 0.6 + _phase) * drift
		if kind.motion == "toward":
			vel.x += _sidestep()
	velocity = vel
	move_and_slide()

	if lane_walker:
		global_position.x = clampf(global_position.x, -Street.HALF_WIDTH + 0.5, Street.HALF_WIDTH - 0.5)


# Do not walk through the walker in front. Match its pace when it is close ahead in the same lane.
func _neighbor_limit() -> float:
	var limit := 99.0
	for node in get_tree().get_nodes_in_group("walkers"):
		var other := node as Walker
		if other == null or other == self or other.kind.motion != kind.motion:
			continue
		var rel := other.global_position - global_position
		var ahead := rel.dot(_dir)
		if ahead > 0.0 and ahead < FOLLOW_GAP and absf(rel.x) < FOLLOW_WIDTH:
			limit = minf(limit, other.current_speed)
	return limit


# Oncoming walkers step sideways around slow walkers heading the other way.
func _sidestep() -> float:
	for node in get_tree().get_nodes_in_group("walkers"):
		var other := node as Walker
		if other == null or other.kind.motion != "away":
			continue
		var rel := other.global_position - global_position
		if rel.z > 0.0 and rel.z < 2.5 and absf(rel.x) < 0.8:
			return 1.0 if rel.x <= 0.0 else -1.0
	return 0.0


func _should_despawn(player_pos: Vector3) -> bool:
	var p := global_position
	if p.z > player_pos.z + 12.0:
		return true
	if p.z < -Street.LEVEL_LENGTH - 40.0:
		return true
	if kind.motion == "left" and p.x < -Street.HALF_WIDTH - 0.3:
		return true
	if kind.motion == "right" and p.x > Street.HALF_WIDTH + 0.3:
		return true
	return false
