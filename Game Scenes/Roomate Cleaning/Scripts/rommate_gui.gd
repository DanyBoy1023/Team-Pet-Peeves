extends CanvasLayer

@onready var clean_dishes_counter: Label = %"Clean Dishes Counter"
@onready var dish_clean_controller: DishController = %"Dish Clean Controller"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	clean_dishes_counter.text = str(dish_clean_controller.clean_dish_count)
