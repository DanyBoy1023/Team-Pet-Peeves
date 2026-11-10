extends BaseButton

@export var minigame_page: PackedScene

func _ready() -> void:
	pressed.connect(go_to_page)

func go_to_page():
	var anim_player: AnimationPlayer = get_tree().get_first_node_in_group("Loading Bar Animation")
	if anim_player.is_playing(): return
	anim_player.play("Fast Loading")
	await anim_player.animation_finished
	PageController.go_to_page(minigame_page)
