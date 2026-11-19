class_name DishStack
extends Node2D

const PLATE = preload("uid://djbbkjqs8g075")
const CUP = preload("uid://bn2psvco6mcfn")
const PAN = preload("uid://cwb8s3qsoxea")
const SPATULA = preload("uid://c2efyuvp7por0")

var dish_scenes : Array[PackedScene] = [PLATE, CUP, PAN, SPATULA]

@export var dish_stack_gap: float = 20
@export var initial_stack_size: int = 6
@export_custom(PROPERTY_HINT_LINK, "") var dish_scale := Vector2.ONE

func _ready() -> void:
	for i in initial_stack_size:
		add_new_dish_to_stack()


func add_new_dish_to_stack():
	spawn_dish()
	var i = 0
	for child: Dish in get_children():
		child.global_position = global_position
		child.global_scale = dish_scale
		child.global_position.y -= i * dish_stack_gap
		i += 1

func spawn_dish():
	var new_dish: Dish = dish_scenes.get(randi_range(0, dish_scenes.size()-1)).instantiate()
	add_child(new_dish)

func get_top_dish() -> Dish:
	if get_children().size() == 0:
		return null
	
	return get_child(get_children().size()-1)

func is_empty() -> bool:
	if get_children().size() == 0:
		return true
	return false
