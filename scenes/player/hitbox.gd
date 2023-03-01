extends Area2D

signal got_hit(damage, direction)

func hit(damage, direction : Vector2 = Vector2.ZERO):
	emit_signal("got_hit", damage, direction)
