class_name Soap
extends Area2D

signal cleaned()

var starting_dirt: float = 10
var dirt: float = starting_dirt:
	set(value):
		dirt = value
		if dirt <= 3:
			cleaned.emit()
			queue_free()
		var alpha = dirt/starting_dirt
		modulate.a = alpha
