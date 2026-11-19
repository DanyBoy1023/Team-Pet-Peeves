extends BaseButton

enum page_enum {
	random,
	home,
	dishes,
	dodge,
	slow_walk,
	cat
}
@export_file_path("*tscn") var page: String

func _ready() -> void:
	pressed.connect(go_to_page)

func go_to_page():
	PageController.open_new_page(page)
	#var page_scene: PackedScene
	#match page:
		#page_enum.random:
			#var game_scenes: Array = [PageInfo.DODGE_THE_COUGHERS_WINDOW, PageInfo.INFINITE_DISHES_WINDOW]
			#page_scene = game_scenes.get(randi_range(0, game_scenes.size()-1))
		#page_enum.home:
			#page_scene = PageInfo.MAIN_PAGE
		#page_enum.dodge:
			#page_scene = PageInfo.DODGE_THE_COUGHERS_WINDOW
		#page_enum.dishes:
			#page_scene = PageInfo.INFINITE_DISHES_WINDOW
		#page_enum.slow_walk:
			#page_scene = null
		#page_enum.cat:
			#page_scene = null
	
