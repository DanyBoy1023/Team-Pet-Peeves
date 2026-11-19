class_name Page
extends Node

enum page {
	random_game,
	main,
	dodge,
	dishes,
	slow_walker,
	cat
}

const DODGE_THE_COUGHERS_WINDOW = preload("uid://chbhtvwo00ivv")
const INFINITE_DISHES_WINDOW = preload("uid://b07q35mcq4h7a")
const MAIN_PAGE = preload("uid://cu4gtqtor86l7")

func get_page_scene(page_enum: page):
	match page_enum:
		page.random_game:
			var game_scenes: Array = [DODGE_THE_COUGHERS_WINDOW, INFINITE_DISHES_WINDOW]
			return game_scenes.get(randi_range(0, game_scenes.size()-1))
		page.main:
			return MAIN_PAGE
		page.dodge:
			return DODGE_THE_COUGHERS_WINDOW
		page.dishes:
			return INFINITE_DISHES_WINDOW
		page.slow_walker:
			pass
		page.cat:
			pass
