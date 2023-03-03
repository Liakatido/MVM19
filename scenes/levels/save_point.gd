extends Area2D

const SaveSound = preload("res://assets/sounds/player/save.ogg")

@onready var ui = $HBoxContainer

func _unhandled_input(event):
	if event.is_action_pressed("interact") and has_overlapping_areas():
		var level = get_parent().to_level
		var gate = get_parent().gate_id
		
		# heal player
		Data.health = Data.max_health
		
		# sound
		Utils.spawn_audio(SaveSound, -10)
		
		Utils.flash_screen()
		
		Data.save(level, gate)

func _process(_delta):
	if has_overlapping_areas():
		ui.show()
	else:
		ui.hide()
