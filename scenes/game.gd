extends Node

@onready var main_menu = $MainMenu

var current_level : Level
var last_gate : String

func _ready():
	# connect to global Utils
	Utils.game = self
	# connect ui signals
	main_menu.connect("start_pressed", start_game)
	main_menu.connect("exit_pressed", exit_game)
	
	# load last save
	load_game()

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

func load_game():
	# hardcoded save state
	# TODO: restore save state from file
	var save_state = GlobalData.SaveState.new()
	save_state.health = 100
	save_state.max_health = 100
	save_state.max_ammo = 4
	save_state.ammo = 4
	save_state.tail_enabled = true
	save_state.spit_enabled = true
	save_state.dash_enabled = true
	save_state.level = "res://scenes/levels/cave/caveSelfLair.tscn"
	save_state.gate = "safeCave"
	Data.last_save = save_state
	
	Data.set_stats_from_last_save()

func start_game():
	main_menu.hide()
	switch_to_level(Data.last_save.level, Data.last_save.gate, false)

func exit_game():
	get_tree().quit()

func spawn_audio(sound, db : float = 0):
	var audio_to_spawn = AudioStreamPlayer.new()
	add_child(audio_to_spawn)
	
	audio_to_spawn.stream = sound
	audio_to_spawn.volume_db = db
	audio_to_spawn.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_to_spawn.connect("finished", audio_to_spawn.queue_free)
	audio_to_spawn.play()
