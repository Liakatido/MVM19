extends MarginContainer

signal continue_selected
signal exit_selected



func _on_yes_button_pressed():
	emit_signal("continue_selected")


func _on_no_button_pressed():
	emit_signal("exit_selected")
