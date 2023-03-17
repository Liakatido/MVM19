extends CanvasLayer

var paused : bool = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if not paused:
			get_node("Panel").show()
			paused = true
			get_parent().pause()
		else:
			get_node("Panel").hide()
			paused = false
			get_parent().resume()
