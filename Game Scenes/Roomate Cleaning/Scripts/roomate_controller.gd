class_name RoomateController
extends Node2D

@onready var dish_stack: DishStack = %"Dish Stack"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var next_dish_spawn_amount := 0

func start_animation(speed_scale: float, amount: int = 1):
	if animation_player.is_playing(): return
	
	next_dish_spawn_amount = amount
	animation_player.speed_scale = speed_scale
	animation_player.play("add new dish")

func roomate_add_new_dish():
	for i in next_dish_spawn_amount:
		dish_stack.add_new_dish_to_stack()


func _on_timer_timeout() -> void:
	timer.wait_time = randf_range(max(dish_stack.get_children().size(), 4), 8)
	start_animation(1)


func _on_dish_clean_controller_all_dishes_clean() -> void:
	timer.stop()
	animation_player.pause()
