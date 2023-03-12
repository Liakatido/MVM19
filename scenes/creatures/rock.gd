extends Sprite2D

var can_move : bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position.y += 100*delta
	if global_position.y > 1000:
		queue_free()

func start_falling():
	rotate(randf_range(0, 3))
	var scale_mod = randf_range(0.5, 0.8)
	scale = Vector2(scale_mod, scale_mod)
	can_move = true
