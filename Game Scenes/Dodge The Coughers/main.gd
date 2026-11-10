extends Node

@export var mob_scene: PackedScene

const BASE_SCROLL_SPEED := 220.0
const MAX_SCROLL_SPEED := 520.0
const START_SPAWN_INTERVAL := 0.8
const MIN_SPAWN_INTERVAL := 0.3

var score := 0
var scroll_speed := 0.0


func _ready():
	# Slow scroll behind the title screen.
	$Background.speed = 60.0


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$Background.speed = 0.0
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	scroll_speed = BASE_SCROLL_SPEED
	$Background.speed = scroll_speed
	$MobTimer.wait_time = START_SPAWN_INTERVAL
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	# The longer you last, the faster the street moves and the more people spawn.
	scroll_speed = minf(BASE_SCROLL_SPEED + score * 4.0, MAX_SCROLL_SPEED)
	$Background.speed = scroll_speed
	$MobTimer.wait_time = maxf(START_SPAWN_INTERVAL - score * 0.012, MIN_SPAWN_INTERVAL)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()

	# Spawn just above the top edge at a random x position.
	mob.position = Vector2(randf_range(30.0, 450.0), -60.0)

	# Walk downward, a little faster than the street scrolls, with some sideways drift.
	var vx = randf_range(-60.0, 60.0)
	var vy = scroll_speed + randf_range(40.0, 140.0)
	mob.linear_velocity = Vector2(vx, vy)

	add_child(mob)

	if randf() < 0.4:
		$CoughSound.pitch_scale = randf_range(0.85, 1.2)
		$CoughSound.play()
