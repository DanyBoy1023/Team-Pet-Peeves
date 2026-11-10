extends Node2D
# Draws the sidewalk tile repeatedly and scrolls it downward,
# so the player looks like they are walking up the street.

@export var texture: Texture2D

# Scroll speed in pixels per second. Main sets this.
var speed := 0.0
var offset := 0.0


func _process(delta):
	if speed > 0.0 and texture != null:
		offset = fposmod(offset + speed * delta, float(texture.get_height()))
		queue_redraw()


func _draw():
	if texture == null:
		return
	var h = texture.get_height()
	var o = floorf(offset)
	for i in range(-1, 3):
		draw_texture(texture, Vector2(0, o + i * h))
