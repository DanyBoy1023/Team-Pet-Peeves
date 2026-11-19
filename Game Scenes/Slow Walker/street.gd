class_name Street
extends Node3D
# Builds the street in code: floor, side walls, collision, finish gate, distance signs.
# The street runs along -Z. The player starts at z = 0 and the finish line is at z = -LEVEL_LENGTH.

const WIDTH := 8.0
const HALF_WIDTH := 4.0
const LEVEL_LENGTH := 300.0
const START_PAD := 8.0   # street behind the start line
const END_PAD := 24.0    # street past the finish line
const WALL_HEIGHT := 10.0
const SIGN_EVERY := 50.0


func _ready():
	var total := LEVEL_LENGTH + START_PAD + END_PAD
	var center_z := -(LEVEL_LENGTH + END_PAD - START_PAD) / 2.0
	var front_z := -(LEVEL_LENGTH + END_PAD)

	_build_floor(total, center_z)
	_build_walls(total, center_z, front_z)
	_build_colliders(total, center_z, front_z)
	_build_finish()
	_build_signs()


func _unshaded(tex: Texture2D) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_texture = tex
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return m


func _flat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = color
	return m


func _build_floor(total: float, center_z: float) -> void:
	var tex := load("res://Game Scenes/Slow Walker/art/street.jpg") as Texture2D
	var mat := _unshaded(tex)
	# One texture tile covers the street width. Repeat it along the length.
	var tile_len := WIDTH * float(tex.get_height()) / float(tex.get_width())
	mat.uv1_scale = Vector3(1.0, total / tile_len, 1.0)
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(WIDTH, total)
	mesh.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0.0, 0.0, center_z)
	add_child(mi)


func _build_walls(total: float, center_z: float, front_z: float) -> void:
	var tex := load("res://Game Scenes/Slow Walker/art/facade.png") as Texture2D
	var aspect := float(tex.get_width()) / float(tex.get_height())
	var side_mat := _unshaded(tex)
	side_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	side_mat.uv1_scale = Vector3(total / (WALL_HEIGHT * aspect), 1.0, 1.0)
	var right_mat := side_mat.duplicate() as StandardMaterial3D
	right_mat.albedo_color = Color(0.85, 0.9, 0.95)
	right_mat.uv1_offset = Vector3(0.37, 0.0, 0.0)
	var end_mat := side_mat.duplicate() as StandardMaterial3D
	end_mat.uv1_scale = Vector3(WIDTH / (WALL_HEIGHT * aspect), 1.0, 1.0)

	_quad(Vector2(total, WALL_HEIGHT), Vector3(-HALF_WIDTH, WALL_HEIGHT / 2.0, center_z), 90.0, side_mat)
	_quad(Vector2(total, WALL_HEIGHT), Vector3(HALF_WIDTH, WALL_HEIGHT / 2.0, center_z), -90.0, right_mat)
	_quad(Vector2(WIDTH, WALL_HEIGHT), Vector3(0.0, WALL_HEIGHT / 2.0, START_PAD), 180.0, end_mat)
	_quad(Vector2(WIDTH, WALL_HEIGHT), Vector3(0.0, WALL_HEIGHT / 2.0, front_z), 0.0, end_mat)


func _quad(size: Vector2, pos: Vector3, yaw_deg: float, mat: Material) -> void:
	var mesh := QuadMesh.new()
	mesh.size = size
	mesh.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = Vector3(0.0, yaw_deg, 0.0)
	add_child(mi)


func _build_colliders(total: float, center_z: float, front_z: float) -> void:
	_box(Vector3(WIDTH + 2.0, 1.0, total + 2.0), Vector3(0.0, -0.5, center_z))                     # floor
	_box(Vector3(1.0, 6.0, total + 2.0), Vector3(-HALF_WIDTH - 0.5, 3.0, center_z))                # left
	_box(Vector3(1.0, 6.0, total + 2.0), Vector3(HALF_WIDTH + 0.5, 3.0, center_z))                 # right
	_box(Vector3(WIDTH + 2.0, 6.0, 1.0), Vector3(0.0, 3.0, START_PAD + 0.5))                       # back
	_box(Vector3(WIDTH + 2.0, 6.0, 1.0), Vector3(0.0, 3.0, front_z - 0.5))                         # front


func _box(size: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	body.position = pos
	add_child(body)


func _build_finish() -> void:
	var z := -LEVEL_LENGTH

	# Checkered strip on the ground.
	var img := Image.create(16, 2, false, Image.FORMAT_RGB8)
	for x in 16:
		for y in 2:
			img.set_pixel(x, y, Color.WHITE if (x + y) % 2 == 0 else Color(0.08, 0.08, 0.08))
	var checker := _unshaded(ImageTexture.create_from_image(img))
	checker.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	var strip := PlaneMesh.new()
	strip.size = Vector2(WIDTH, 1.6)
	strip.material = checker
	var strip_mi := MeshInstance3D.new()
	strip_mi.mesh = strip
	strip_mi.position = Vector3(0.0, 0.02, z)
	add_child(strip_mi)

	# Gate: two posts and a crossbar.
	var red := _flat(Color(0.9, 0.25, 0.2))
	for sx in [-1.0, 1.0]:
		_block(Vector3(0.5, 5.0, 0.5), Vector3(sx * (HALF_WIDTH - 0.4), 2.5, z), red)
	_block(Vector3(WIDTH - 0.3, 1.2, 0.5), Vector3(0.0, 5.0, z), red)

	var label := Label3D.new()
	label.text = "FINISH"
	label.font_size = 160
	label.pixel_size = 0.012
	label.outline_size = 24
	label.modulate = Color(1, 1, 1)
	label.position = Vector3(0.0, 5.0, z + 0.3)
	add_child(label)


func _block(size: Vector3, pos: Vector3, mat: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)


func _build_signs() -> void:
	var d := SIGN_EVERY
	while d < LEVEL_LENGTH:
		var label := Label3D.new()
		label.text = "%d m" % int(d)
		label.font_size = 120
		label.pixel_size = 0.01
		label.outline_size = 20
		label.position = Vector3(-HALF_WIDTH + 0.05, 3.0, -d)
		label.rotation_degrees = Vector3(0.0, 90.0, 0.0)
		add_child(label)
		d += SIGN_EVERY
