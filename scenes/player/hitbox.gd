extends Area2D

signal got_hit(damage)

func hit(damage):
	emit_signal("got_hit", damage)
