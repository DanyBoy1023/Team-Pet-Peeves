extends BaseButton

@export_file_path("*.tscn") var minigame_page: String

func _ready() -> void:
	pressed.connect(go_to_page)

func go_to_page():
	var anim_player: AnimationPlayer = get_tree().get_first_node_in_group("Loading Bar Animation")
	if anim_player.is_playing(): return
	anim_player.play("Fast Loading")
	await anim_player.animation_finished
	get_tree().change_scene_to_file(minigame_page)
