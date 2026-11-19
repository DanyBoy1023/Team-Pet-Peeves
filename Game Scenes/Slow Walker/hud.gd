class_name Hud
extends CanvasLayer
# Heads-up display, built in code so there is no layout to keep in sync with the scene.

var _patience_bar: ProgressBar
var _stamina_bar: ProgressBar
var _distance_label: Label
var _time_label: Label
var _stuck_label: Label
var _title_label: Label
var _message_label: Label
var _flash: ColorRect
var _crosshair: ColorRect


static func format_time(t: float) -> String:
	var minutes := int(floor(t / 60.0))
	var secs := int(floor(t)) % 60
	var tenths := int(floor((t - floor(t)) * 10.0))
	return "%d:%02d.%d" % [minutes, secs, tenths]


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 0, 0, 0)
	root.add_child(_flash)

	_crosshair = ColorRect.new()
	_crosshair.color = Color(1, 1, 1, 0.7)
	_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_crosshair.offset_left = -3
	_crosshair.offset_right = 3
	_crosshair.offset_top = -3
	_crosshair.offset_bottom = 3
	root.add_child(_crosshair)

	root.add_child(_make_label("PATIENCE", 18, Vector2(24, 14), Vector2(300, 24)))
	_patience_bar = _make_bar(root, Color(0.95, 0.55, 0.15), Vector2(24, 40), Vector2(320, 22))
	root.add_child(_make_label("STAMINA", 14, Vector2(24, 70), Vector2(300, 20)))
	_stamina_bar = _make_bar(root, Color(0.3, 0.75, 0.9), Vector2(24, 92), Vector2(320, 10))

	_distance_label = _make_label("", 28, Vector2.ZERO, Vector2.ZERO)
	_right_aligned(_distance_label, 14)
	root.add_child(_distance_label)
	_time_label = _make_label("", 22, Vector2.ZERO, Vector2.ZERO)
	_right_aligned(_time_label, 54)
	root.add_child(_time_label)

	_stuck_label = _make_label("Slow walker ahead", 26, Vector2.ZERO, Vector2.ZERO)
	_stuck_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_stuck_label.offset_left = -300
	_stuck_label.offset_right = 300
	_stuck_label.offset_top = -130
	_stuck_label.offset_bottom = -90
	_stuck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stuck_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.3))
	_stuck_label.hide()
	root.add_child(_stuck_label)

	_title_label = _make_label("", 64, Vector2.ZERO, Vector2.ZERO)
	_centered(_title_label, -230, -130)
	root.add_child(_title_label)
	_message_label = _make_label("", 26, Vector2.ZERO, Vector2.ZERO)
	_centered(_message_label, -120, 120)
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_message_label)


func _make_label(text: String, size: int, pos: Vector2, dim: Vector2) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = dim
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 6)
	return l


func _make_bar(parent: Control, color: Color, pos: Vector2, dim: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.custom_minimum_size = dim
	bar.size = dim
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0, 0, 0, 0.55)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	parent.add_child(bar)
	return bar


func _right_aligned(l: Label, top: float) -> void:
	l.anchor_left = 1.0
	l.anchor_right = 1.0
	l.offset_left = -340
	l.offset_right = -24
	l.offset_top = top
	l.offset_bottom = top + 40
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func _centered(l: Label, top: float, bottom: float) -> void:
	l.anchor_left = 0.5
	l.anchor_right = 0.5
	l.anchor_top = 0.5
	l.anchor_bottom = 0.5
	l.offset_left = -520
	l.offset_right = 520
	l.offset_top = top
	l.offset_bottom = bottom
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func show_title(best_time: float) -> void:
	_title_label.text = "SLOW WALKERS"
	var best := ""
	if best_time > 0.0:
		best = "\nBest time %s" % format_time(best_time)
	_message_label.text = "Get to the finish line. Slow walkers block lanes. Find the open one.\n" \
			+ "WASD move. Mouse look. Shift sprint. Esc frees the mouse.\n" \
			+ "Press Space to start." + best
	_title_label.show()
	_message_label.show()
	_crosshair.hide()
	_stuck_label.hide()


func show_result(title: String, body: String) -> void:
	_title_label.text = title
	_message_label.text = body
	_title_label.show()
	_message_label.show()
	_stuck_label.hide()


func hide_message() -> void:
	_title_label.hide()
	_message_label.hide()
	_crosshair.show()


func update_status(patience: float, stamina: float, remaining: float, elapsed: float, stuck: bool) -> void:
	_patience_bar.value = patience
	_stamina_bar.value = stamina
	_distance_label.text = "%d m to go" % int(ceil(remaining))
	_time_label.text = format_time(elapsed)
	_stuck_label.visible = stuck
	# The patience bar shifts toward red as it empties.
	var fill := _patience_bar.get_theme_stylebox("fill") as StyleBoxFlat
	fill.bg_color = Color(0.95, 0.55, 0.15).lerp(Color(0.85, 0.12, 0.1), 1.0 - patience / 100.0)


func flash(color: Color) -> void:
	_flash.color = color
	var tween := create_tween()
	tween.tween_property(_flash, "color:a", 0.0, 0.45)
