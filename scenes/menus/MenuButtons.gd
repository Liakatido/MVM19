extends MarginContainer

@onready var v_contaner = $Buttons

# TODO: This whole script is incomplete
# finish later to have a default button menu that also works completely with keyboard

var buttons : Array
var current_selected : int = -1 # index of the selected button in buttons, -1 == there isn't any selected/pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	for b in v_contaner.get_children():
		buttons.append(buttons)

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		select_next_button()
	if event.is_action_pressed("ui_up"):
		select_previous_button()
	if event.is_action_pressed("ui_accept"):
		press_button()

func select_next_button():
	current_selected += 1
	if current_selected >= len(buttons):
		current_selected = 0
	
	

func select_previous_button():
	pass

func press_button():
	pass
