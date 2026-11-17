extends Node2D
# Draws the street tile repeatedly and scrolls it downward,
# so the player looks like they are walking up the street.

@export var texture: Texture2D
@export var view_width := 480.0 # The tile is stretched to this width.

# Scroll speed in pixels per second. Main sets this.
var speed := 0.0
var offset := 0.0


func _tile_height() -> float:
	return texture.get_height() * view_width / texture.get_width()


func _process(delta):
	if speed > 0.0 and texture != null:
		offset = fposmod(offset + speed * delta, _tile_height())
		queue_redraw()


func _draw():
	if texture == null:
		return
	var h = _tile_height()
	var o = floorf(offset)
	# The tile is taller than the screen, so two copies always cover it.
	# Each copy is 1 px taller than needed so no seam shows between them.
	for i in range(-1, 1):
		draw_texture_rect(texture, Rect2(0, o + i * h, view_width, h + 1.0), false)
