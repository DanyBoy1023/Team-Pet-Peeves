extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).hide()
	pressed.connect(on_pressed)
	focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

func on_pressed():
	var child : Control = get_child(0)
	child.visible = !child.visible
