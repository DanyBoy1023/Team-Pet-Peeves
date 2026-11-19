class_name DishController
extends Node2D

signal all_dishes_clean()

@onready var hold_position: Marker2D = $"../hold position"
@onready var end_position: Marker2D = $"../end position"

@onready var roomate_controller: RoomateController = %"Roomate Controller"

@onready var dish_stack: DishStack = %"Dish Stack"

var clean_dish_count = 0

var desparate_calls = 3

func on_dish_all_clean(dish: Dish) -> void:
	clean_dish_count += 1
	grab_dish()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(.2)
	tween.tween_property(dish, "global_position", end_position.global_position, .2)
	tween.tween_callback(dish.queue_free)

var spawned_roomate = false
func on_dish_soap_cleaned(percent: float):
	if percent >= .5 and not spawned_roomate and dish_stack.is_empty() and desparate_calls:
		spawned_roomate = true
		desparate_calls -= 1
		roomate_controller.start_animation(1.5, 2)
	if desparate_calls == 0 and percent >= .8 and dish_stack.is_empty():
		roomate_controller.start_animation(1)

func grab_dish():
	if dish_stack.is_empty():
		all_dishes_clean.emit()
		return
	
	var dish := dish_stack.get_top_dish()
	dish.reparent(self)
	
	spawned_roomate = false
	
	dish.all_clean.connect(on_dish_all_clean)
	dish.soap_cleaned.connect(on_dish_soap_cleaned)
	
	var tween_duration = .2
	
	var position_tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	position_tween.tween_interval(.25)
	position_tween.tween_callback(dish.spawn_bubbles)
	position_tween.tween_interval(.05)
	position_tween.tween_property(dish, "global_position", hold_position.global_position, tween_duration)
	
	var scale_tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_interval(.3)
	scale_tween.tween_property(dish, "global_scale", Vector2.ONE, tween_duration)
