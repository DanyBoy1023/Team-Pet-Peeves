extends Button


@export var player_amount := 5

func _ready() -> void:
	for i in player_amount - 1:
		var new_player = get_child(0).duplicate()
		add_child(new_player)

func _on_pressed() -> void:
	if get_child_count() == 0: return
	
	for child in get_children():
		if child is AudioStreamPlayer:
			var player : AudioStreamPlayer = child
			if not player.playing:
				player.play()
				return
	
	get_child(0).play()
