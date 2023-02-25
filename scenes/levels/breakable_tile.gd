extends Area2D

signal broken(x, y)

var x : int
var y : int

var already_broken : bool = false

func break_object():
	# so it isn't setup to be broken more than once
	if not already_broken:
		already_broken = true
		emit_signal("broken", x, y)
