extends Area2D

var hovering = false
var grabbed = false
var reaching = false

@export var grabbed_threshold := 10
@export var cleaning_strength = 4

var prev_global_position: Vector2


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		reaching = true
	if Input.is_action_just_released("grab"):
		reaching = false
		grabbed = false
	
	if grabbed or reaching:
		var mouse_pos = get_global_mouse_position()
		if reaching:
			global_position = lerp(global_position, mouse_pos, .05)
			var dir := global_position.distance_to(mouse_pos)
			if dir <= grabbed_threshold:
				grabbed = true
				reaching = false
		if grabbed:
			global_position = lerp(global_position, mouse_pos, .5)
		
		
		for area in get_overlapping_areas():
			if area is Soap:
				var soap : Soap = area
				var speed = global_position.distance_to(prev_global_position)
				soap.dirt -= delta * cleaning_strength * speed
	else:
		position = lerp(position, Vector2.ZERO, .2)
	
	prev_global_position = global_position

func is_hovered() -> bool:
	var target_position := get_global_mouse_position()
	# 1. Get the direct 2D world physics space state
	var space_state := get_world_2d().direct_space_state
	
	# 2. Configure the point query parameters
	var query := PhysicsPointQueryParameters2D.new()
	query.position = target_position
	
	# Optional configurations:
	# query.collision_mask = 1       # Query specific collision layers
	query.collide_with_areas = true # Include Area2D nodes (default is false)
	# query.collide_with_bodies = true # Include Physics bodies (default is true)
	
	# 3. Fetch all intersections (returns an array of Dictionaries, up to 32 by default)
	var results := space_state.intersect_point(query)
	
	for result in results:
		var object: CollisionObject2D = result.collider
		if object == self:
			return true
	
	return false

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false


func _on_dish_clean_controller_all_dishes_clean() -> void:
	queue_free()
