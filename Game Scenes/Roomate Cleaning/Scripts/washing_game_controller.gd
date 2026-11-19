extends Node2D

@onready var music: AudioStreamPlayer = $Music

func _on_dish_clean_controller_all_dishes_clean() -> void:
	music.stop()
