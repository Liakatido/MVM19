extends Area2D

func _unhandled_input(event):
	if event.is_action_pressed("interact") and has_overlapping_areas():
		var level = get_parent().to_level
		var gate = get_parent().gate_id
		
		# heal player
		Data.health = Data.max_health
		
		# sound
		
		Data.save(level, gate)
