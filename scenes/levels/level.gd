extends Node2D

class_name Level

signal switch_to_level(level, gate)

const Player = preload("res://scenes/player/player.tscn")
const BreakableTile = preload("res://scenes/levels/breakable_tile.tscn")
const BreakAudio = preload("res://assets/sounds/player/crash.ogg")

@onready var tilemap = $TileMap
@onready var gates = $Gates

@export var spawn_gate : String
@export var song : String = "normal"

var camera : Camera2D
var setup_complete : bool = false

var available_gates : Dictionary # [GateID]: Gate

const CAMERA_OFFSET = -64
const SCREEN_HEIGHT = 240

func _ready():
	setup()

func setup():
	setup_gates()
		
	# spawn player
	var player = Player.instantiate()
	call_deferred("add_child", player)
	player.global_position = available_gates[spawn_gate].get_spawn_pos()
	
	# setup camera
	setup_camera(player.get_node("Camera2D"))
	
	# setup level specific stuff
	setup_breakable_tiles()
	
	Utils.play_song(song)
	
	setup_complete = true

func setup_gates():
	# setup gates
	for gate in gates.get_children():
		available_gates[gate.gate_id] = gate
		gate.connect("player_entered_gate", signal_switch_level)

func setup_breakable_tiles():
	var tilemap_layer = 0
	for cell in tilemap.get_used_cells(tilemap_layer):
		var tile_data = tilemap.get_cell_tile_data(tilemap_layer, cell)
		var breakable = tile_data.get_custom_data("breakable")
		
		if not breakable:
			continue
		
		# setup tile breaking on charge
		var cell_global_pos = tilemap.to_global(tilemap.map_to_local(cell))
		var breakable_tile = BreakableTile.instantiate()
		add_child(breakable_tile)
		breakable_tile.global_position = cell_global_pos
		
		breakable_tile.x = cell.x
		breakable_tile.y = cell.y
		breakable_tile.connect("broken", break_tile)

func break_tile(x, y):
	Utils.spawn_audio(BreakAudio, -24)
	var tilemap_layer = 0
	tilemap.erase_cell(tilemap_layer, Vector2(x, y))

func _process(_delta):
	if not setup_complete:
		return
	
	# handle camera offset so it doesn't go above the ceiling
	var distance_over_ceiling = -(camera.global_position.y - CAMERA_OFFSET - SCREEN_HEIGHT) + 16
	if distance_over_ceiling  > 0:
		camera.offset = Vector2(0, CAMERA_OFFSET + clamp(distance_over_ceiling, 0, -CAMERA_OFFSET))
	else:
		camera.offset = Vector2(0, CAMERA_OFFSET)
	

func setup_camera(player_camera : Camera2D):
	var level_x = tilemap.get_used_rect().size.x * 16
	var level_y = tilemap.get_used_rect().size.y * 16
	
	player_camera.limit_bottom = level_y + SCREEN_HEIGHT
	player_camera.limit_top = 0
	player_camera.limit_left = 0
	player_camera.limit_right = level_x
	
	camera = player_camera

func signal_switch_level(level, gate):
	emit_signal("switch_to_level", level, gate)

func disable():
	hide()
	call_deferred("queue_free")
