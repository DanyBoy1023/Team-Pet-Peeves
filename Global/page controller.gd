extends Node

# holds the player has opened
var page_list: Array[PackedScene] = [preload("uid://cu4gtqtor86l7")]
var current_page_index = 0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back page"):
		go_back_a_page()
	if Input.is_action_just_pressed("forward page"):
		go_forward_a_page()

func go_to_page(page_scene: PackedScene):
	page_list = page_list.slice(0, current_page_index+1)
	page_list.append(page_scene)
	current_page_index += 1
	get_tree().change_scene_to_packed(page_scene)

func go_forward_a_page():
	var new_page_index = min(current_page_index + 1, page_list.size()-1)
	if new_page_index != current_page_index:
		current_page_index = new_page_index
		open_page_by_index(current_page_index)

func go_back_a_page():
	var new_page_index = max(current_page_index - 1, 0)
	if new_page_index != current_page_index:
		current_page_index = new_page_index
		open_page_by_index(current_page_index)

func open_page_by_index(index: int):
	var page_scene = page_list[index]
	get_tree().change_scene_to_packed(page_scene)
