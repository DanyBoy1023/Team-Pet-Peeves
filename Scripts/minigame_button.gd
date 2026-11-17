extends BaseButton

@export var minigame_page: PackedScene

func _ready() -> void:
	pressed.connect(go_to_page)

func go_to_page():
	PageController.open_new_page(minigame_page)
