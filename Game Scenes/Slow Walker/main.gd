extends Node3D
# Slow Walkers. Walk the length of a crowded street before your patience runs out.
#
# Patience drains while a walker blocks your way and drops when you bump into one.
# It refills slowly when the path ahead is clear.
#
# The street is split into lanes. Walkers spawn in formations that block one or more lanes:
# a single walker, a side by side pair, a stack that follows one behind another, a row across
# several lanes, or a loose crowd. A formation is only spawned if at least one lane stays open.

const PATIENCE_MAX := 100.0
const STUCK_RANGE := 3.2          # a walker this close ahead of you counts as in the way
const STUCK_HALF_WIDTH := 0.85    # and this close to your line of travel
const STUCK_DRAIN := 9.0          # patience per second at point blank range
const PATIENCE_REGEN := 3.5
const BUMP_PENALTY := 12.0

const LANE_COUNT := 5
const LANE_WIDTH := Street.WIDTH / LANE_COUNT
const STACK_GAP := 1.5            # meters between walkers in a stack
const PAIR_SPACING := 0.8         # meters between walkers side by side
const BAND_MARGIN := 6.0          # how far around a new formation to look for lanes already in use

const SPAWN_MIN_AHEAD := 40.0
const SPAWN_MAX_AHEAD := 75.0
const MAX_WALKERS := 60
const SPAWN_INTERVAL_START := 0.9
const SPAWN_INTERVAL_END := 0.55
const START_CROWD := 8

# lanes: how many lanes wide. depth: walkers one behind another. abreast: walkers side by side.
const FORMATIONS := [
	{"id": "single", "weight": 3, "motion": "away", "lanes": Vector2i(1, 1), "depth": Vector2i(1, 1), "abreast": 1},
	{"id": "pair", "weight": 2, "motion": "away", "lanes": Vector2i(1, 1), "depth": Vector2i(1, 1), "abreast": 2},
	{"id": "stack", "weight": 3, "motion": "away", "lanes": Vector2i(1, 1), "depth": Vector2i(3, 5), "abreast": 1},
	{"id": "row", "weight": 2, "motion": "away", "lanes": Vector2i(2, 3), "depth": Vector2i(1, 1), "abreast": 1},
	{"id": "crowd", "weight": 2, "motion": "away", "lanes": Vector2i(2, 2), "depth": Vector2i(2, 3), "abreast": 1},
	{"id": "oncoming", "weight": 3, "motion": "toward", "lanes": Vector2i(1, 1), "depth": Vector2i(1, 2), "abreast": 1},
	{"id": "crossing", "weight": 2, "motion": "cross", "lanes": Vector2i(1, 1), "depth": Vector2i(1, 2), "abreast": 1},
]

const RESTART_DELAY := 0.8
const SAVE_PATH := "user://slow_walkers.cfg"

enum State { TITLE, PLAYING, WON, LOST }

@export var walker_scene: PackedScene

var state := State.TITLE
var elapsed := 0.0
var patience := PATIENCE_MAX
var best_time := 0.0
var bumps := 0

var _state_age := 0.0
var _stuck := 0.0

@onready var player: Player = $Player
@onready var hud: Hud = $HUD


func _ready() -> void:
	var music := $Music.stream as AudioStreamOggVorbis
	if music != null:
		music.loop = true
	player.bumped.connect(_on_player_bumped)
	best_time = _load_best()
	_show_title()


func _show_title() -> void:
	state = State.TITLE
	_state_age = 0.0
	player.reset($StartPosition.global_position)
	hud.show_title(best_time)
	hud.update_status(PATIENCE_MAX, Player.MAX_STAMINA, Street.LEVEL_LENGTH, 0.0, false)


func new_game() -> void:
	for w in $Walkers.get_children():
		$Walkers.remove_child(w)
		w.queue_free()
	elapsed = 0.0
	patience = PATIENCE_MAX
	bumps = 0
	_stuck = 0.0
	player.reset($StartPosition.global_position)
	player.active = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.hide_message()
	$Music.play()
	for i in START_CROWD:
		_spawn_formation(randf_range(8.0, 50.0))
	$SpawnTimer.wait_time = SPAWN_INTERVAL_START
	$SpawnTimer.start()
	state = State.PLAYING
	_state_age = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and state != State.TITLE \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	_state_age += delta
	if state != State.PLAYING:
		var wait := 0.0 if state == State.TITLE else RESTART_DELAY
		if _state_age > wait and Input.is_action_just_pressed("start"):
			new_game()
		return
	var remaining := maxf(0.0, Street.LEVEL_LENGTH + player.global_position.z)
	hud.update_status(patience, player.stamina, remaining, elapsed, _stuck > 0.15)


func _physics_process(delta: float) -> void:
	if state != State.PLAYING:
		return
	elapsed += delta

	_stuck = _stuck_factor()
	if _stuck > 0.0:
		patience -= STUCK_DRAIN * _stuck * delta
	else:
		patience = minf(PATIENCE_MAX, patience + PATIENCE_REGEN * delta)

	if patience <= 0.0:
		_lose()
	elif -player.global_position.z >= Street.LEVEL_LENGTH:
		_win()


# 0 when the way ahead is clear. Up to 1 with a walker right in front of you.
func _stuck_factor() -> float:
	var fwd := -player.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var right := fwd.cross(Vector3.UP)
	var best := 0.0
	for node in $Walkers.get_children():
		var w := node as Walker
		if w == null:
			continue
		var rel := w.global_position - player.global_position
		rel.y = 0.0
		var d := rel.dot(fwd)
		if d < 0.3 or d > STUCK_RANGE:
			continue
		if absf(rel.dot(right)) > STUCK_HALF_WIDTH:
			continue
		best = maxf(best, 1.0 - d / STUCK_RANGE)
	return best


func _on_spawn_timer_timeout() -> void:
	if state != State.PLAYING:
		return
	var progress := clampf(-player.global_position.z / Street.LEVEL_LENGTH, 0.0, 1.0)
	$SpawnTimer.wait_time = lerpf(SPAWN_INTERVAL_START, SPAWN_INTERVAL_END, progress)
	_spawn_formation(randf_range(SPAWN_MIN_AHEAD, SPAWN_MAX_AHEAD))


# ---------- lanes and formations ----------

func _lane_x(lane: int) -> float:
	return -Street.HALF_WIDTH + LANE_WIDTH * (lane + 0.5)


func _lane_of(x: float) -> int:
	return clampi(int(floor((x + Street.HALF_WIDTH) / LANE_WIDTH)), 0, LANE_COUNT - 1)


func _pick_formation() -> Dictionary:
	var total := 0
	for f in FORMATIONS:
		total += f.weight
	var roll := randi() % total
	for f in FORMATIONS:
		roll -= f.weight
		if roll < 0:
			return f
	return FORMATIONS[0]


# Lanes that have a lane-bound walker (not a crosser) between these two z values.
func _lanes_in_use(z_from: float, z_to: float) -> Array:
	var used := []
	for node in $Walkers.get_children():
		var w := node as Walker
		if w == null or w.kind.motion == "left" or w.kind.motion == "right":
			continue
		if w.position.z < z_from or w.position.z > z_to:
			continue
		var lane := _lane_of(w.position.x)
		if not used.has(lane):
			used.append(lane)
	return used


# Spawns one formation about this far ahead of the player.
func _spawn_formation(ahead: float) -> void:
	if $Walkers.get_child_count() >= MAX_WALKERS:
		return
	var f := _pick_formation()
	if f.motion == "cross":
		_spawn_crossers(ahead, randi_range(f.depth.x, f.depth.y))
		return

	var z := maxf(player.global_position.z - ahead, -Street.LEVEL_LENGTH - 15.0)
	var n_lanes := randi_range(f.lanes.x, f.lanes.y)
	var depth := randi_range(f.depth.x, f.depth.y)
	var used := _lanes_in_use(z - depth * STACK_GAP - BAND_MARGIN, z + BAND_MARGIN)
	for attempt in 6:
		var first := randi_range(0, LANE_COUNT - n_lanes)
		var lanes: Array[int] = []
		for i in n_lanes:
			lanes.append(first + i)
		# Always leave at least one lane open in this stretch of street.
		var blocked := used.duplicate()
		for lane in lanes:
			if not blocked.has(lane):
				blocked.append(lane)
		if blocked.size() >= LANE_COUNT:
			continue
		var slots := _make_slots(f.id, lanes, depth, f.abreast, z)
		if _fits(slots):
			_spawn_group(slots, f.motion)
			return


# World positions for each walker in the formation.
func _make_slots(id: String, lanes: Array[int], depth: int, abreast: int, z: float) -> Array[Vector3]:
	var slots: Array[Vector3] = []
	for lane in lanes:
		var cx := _lane_x(lane)
		for d in depth:
			for a in abreast:
				var x := cx + (a - (abreast - 1) * 0.5) * PAIR_SPACING
				var dz := d * STACK_GAP
				if id == "crowd":
					x += randf_range(-0.15, 0.15)
					dz += randf_range(-0.25, 0.25)
				elif id == "row":
					dz += randf_range(0.0, 0.6)
				slots.append(Vector3(x, 0.0, z - dz))
	return slots


func _spawn_crossers(ahead: float, count: int) -> void:
	var motion: String = ["left", "right"].pick_random()
	var edge := Street.HALF_WIDTH - 0.3
	var x := edge if motion == "left" else -edge
	var z := player.global_position.z - ahead * 0.5
	var slots: Array[Vector3] = []
	for i in count:
		slots.append(Vector3(x, 0.0, z - i * 0.9))
	if _fits(slots):
		_spawn_group(slots, motion)


# True when no existing walker is too close to any slot.
func _fits(slots: Array[Vector3]) -> bool:
	for node in $Walkers.get_children():
		var other := node as Walker
		if other == null:
			continue
		for p in slots:
			if Vector2(other.position.x - p.x, other.position.z - p.z).length() < 1.1:
				return false
	return true


# Spawns the whole group at one shared pace. Groups hold their shape, singles may drift.
func _spawn_group(slots: Array[Vector3], motion: String) -> void:
	if $Walkers.get_child_count() + slots.size() > MAX_WALKERS:
		return
	var pace := -1.0
	for p in slots:
		var k := Walker.random_kind(motion)
		if pace < 0.0:
			pace = randf_range(k.speed.x, k.speed.y)
		var w := walker_scene.instantiate() as Walker
		w.kind = k
		w.speed = pace
		if slots.size() > 1:
			w.drift = 0.0
		w.position = p
		$Walkers.add_child(w)


# ---------- events ----------

func _on_player_bumped(walker: Walker) -> void:
	bumps += 1
	patience -= BUMP_PENALTY
	$BumpSound.play()
	hud.flash(Color(1.0, 0.2, 0.1, 0.35))
	if is_instance_valid(walker):
		walker.stagger(0.7)


func _win() -> void:
	state = State.WON
	_state_age = 0.0
	player.active = false
	$SpawnTimer.stop()
	$Music.stop()
	$FinishSound.play()
	var line := "Time %s" % Hud.format_time(elapsed)
	if best_time <= 0.0 or elapsed < best_time:
		best_time = elapsed
		_save_best()
		line += "  (new best)"
	elif best_time > 0.0:
		line += "  (best %s)" % Hud.format_time(best_time)
	hud.show_result("YOU MADE IT", "%s\nBumps: %d\nPress Space to walk it again." % [line, bumps])


func _lose() -> void:
	state = State.LOST
	_state_age = 0.0
	player.active = false
	patience = 0.0
	$SpawnTimer.stop()
	$Music.stop()
	$GameOverSound.play()
	var dist := int(-player.global_position.z)
	hud.update_status(0.0, player.stamina, Street.LEVEL_LENGTH - dist, elapsed, false)
	hud.show_result("YOU SNAPPED", "You got %d m down the street.\nBumps: %d\nPress Space to try again." % [dist, bumps])


func _load_best() -> float:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		return float(cfg.get_value("scores", "best_time", 0.0))
	return 0.0


func _save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("scores", "best_time", best_time)
	cfg.save(SAVE_PATH)
