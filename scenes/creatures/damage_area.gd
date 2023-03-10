extends Area2D

signal hitted

@export var damage : int
@export var one_time : bool = false

var damage_done : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for area in get_overlapping_areas():
		if not one_time:
			if area.has_method("hit"):
				area.hit(damage)
				emit_signal("hitted")
		if one_time and not damage_done:
			if area.has_method("hit"):
				area.hit(damage)
				damage_done = true
				emit_signal("hitted")
