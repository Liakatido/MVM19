extends Area2D

@export var damage : int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for area in get_overlapping_areas():
		area.hit(damage)
