extends Node

@onready var main_menu = $MainMenu

var current_level : Level
var last_gate : String

func _ready():
	# connect ui signals
	main_menu.connect("start_pressed", start_game)
	main_menu.connect("exit_pressed", exit_game)

func switch_to_level(level, gate, clean_previous : bool = true):
	# fade
	
	# clean previous level
	if clean_previous:
		current_level.disable()
		
	# setup new level
	current_level = load(level).instantiate()
	current_level.spawn_gate = gate
	current_level.connect("switch_to_level", switch_to_level)
	last_gate = gate
	call_deferred("add_child", current_level)

func start_game():
	main_menu.hide()
	# hard coded level
	# TODO: get gate and level spawn from some save data
	switch_to_level("res://scenes/levels/cave/caveSelfLair.tscn", "safeCave", false)

func exit_game():
	get_tree().quit()
