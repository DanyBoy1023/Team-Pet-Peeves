class_name Dish
extends Node2D

signal soap_cleaned(percent: float)
signal all_clean(dish: Dish)

var total_soap = 40
var cleaned_soap = 0

@onready var nav_region: NavigationRegion2D = $NavigationRegion2D
@export var soap_bubble: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

func spawn_bubbles():
	for i in total_soap:
		var new_soap_bubble = soap_bubble.instantiate()
		new_soap_bubble.cleaned.connect(cleaned)
		add_child(new_soap_bubble)
		var rand_pos = get_random_nav_point()
		new_soap_bubble.global_position = rand_pos

func get_random_nav_point() -> Vector2:
	var region_rid: RID = nav_region.get_region_rid()
	# Set the third parameter to true for uniform distribution across triangles
	return NavigationServer2D.region_get_random_point(region_rid, 1, true)
	#return NavigationServer2D.map_get_random_point(nav_region.get_navigation_map(), 1, true)

@onready var grime_sprite_material: ShaderMaterial = $"grime sprite".material

func cleaned():
	cleaned_soap += 1
	var cleaned_percent = cleaned_soap/float(total_soap)
	soap_cleaned.emit(cleaned_percent)
	grime_sprite_material.set_shader_parameter("alpha", 1-cleaned_percent)
	if cleaned_soap >= total_soap:
		all_clean.emit(self)
