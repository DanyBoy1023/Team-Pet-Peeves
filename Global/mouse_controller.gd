extends Node

# Preload your cursor textures
const MOUSE_HOVER = preload("uid://b3ld42pciemmy")
const MOUSE_NORMAL = preload("uid://bs6gykxath7x8")

func _ready() -> void:
	# Set the initial cursor with a top-left hotspot
	Input.set_custom_mouse_cursor(MOUSE_NORMAL, Input.CURSOR_ARROW, Vector2(0, 0))
	
	await get_tree().process_frame
	connect_buttons_in_scene()

func connect_buttons_in_scene():
	await get_tree().process_frame
	await get_tree().process_frame
	for node in get_all_nodes(get_tree().current_scene):
		if node is BaseButton:
			var button: BaseButton = node
			button.mouse_entered.connect(_on_interactable_mouse_entered)
			button.mouse_exited.connect(_on_interactable_mouse_exited)

func get_all_nodes(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	nodes.append(node)
	for child in node.get_children():
		nodes.append_array(get_all_nodes(child))
	return nodes


func _on_interactable_mouse_entered() -> void:
	# Change cursor and set a custom hotspot (e.g., 16x16 for a 32x32 centered icon)
	Input.set_custom_mouse_cursor(MOUSE_HOVER, Input.CURSOR_ARROW, Vector2(2, 0))

func _on_interactable_mouse_exited() -> void:
	# Revert back to your default custom cursor
	Input.set_custom_mouse_cursor(MOUSE_NORMAL, Input.CURSOR_ARROW, Vector2(0, 0))
