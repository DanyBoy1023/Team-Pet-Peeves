extends Node

# holds the player has opened
var page_list: Array[String] = ["uid://cu4gtqtor86l7"]
var current_page_index = 0
var new_page_index = 0

var next_page: String
var load_new = false

var loading_bar_anim_player: AnimationPlayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back page"):
		go_back_a_page()
	if Input.is_action_just_pressed("forward page"):
		go_forward_a_page()

func open_new_page(page_scene: String):
	next_page = page_scene
	load_new = true
	load_bar()

func load_new_page():
	page_list = page_list.slice(0, current_page_index+1)
	page_list.append(next_page)
	current_page_index += 1
	get_tree().change_scene_to_file(next_page)
	Mouse.connect_buttons_in_scene()

func go_forward_a_page():
	load_new = false
	new_page_index = min(current_page_index + 1, page_list.size()-1)
	open_page_by_index(new_page_index)

func go_back_a_page():
	load_new = false
	new_page_index = max(current_page_index - 1, 0)
	open_page_by_index(new_page_index)

func reload_current_page():
	load_new = false
	var page_scene = page_list[current_page_index]
	next_page = page_scene
	load_bar()

func load_bar():
	connect_animation_player()
	loading_bar_anim_player.stop()
	
	var animations := Array(loading_bar_anim_player.get_animation_list())
	animations.remove_at(animations.find("RESET"))
	animations.shuffle()
	loading_bar_anim_player.play(animations[0])
	

func open_page_by_index(index: int):
	if index != current_page_index:
		var page_scene = page_list[index]
		next_page = page_scene
		load_bar()

func connect_animation_player():
	loading_bar_anim_player = get_loading_bar_anim_player()
	if not loading_bar_anim_player.animation_finished.is_connected(change_to_scene):
		loading_bar_anim_player.animation_finished.connect(change_to_scene)

func get_loading_bar_anim_player() -> AnimationPlayer:
	return get_tree().get_first_node_in_group("Loading Bar Animation")

func change_to_scene(_animation_name):
	# actcually switch to new scene
	if load_new:
		load_new_page()
	else:
		if new_page_index != current_page_index:
			current_page_index = new_page_index
		get_tree().change_scene_to_file(next_page)
		Mouse.connect_buttons_in_scene()
