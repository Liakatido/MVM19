extends Node2D

class_name Level

signal switch_to_level(level, gate)

const Player = preload("res://scenes/player/player.tscn")

@onready var tilemap = $TileMap
@onready var gates = $Gates

@export var spawn_gate : String

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
	
	setup_complete = true

func setup_gates():
	# setup gates
	for gate in gates.get_children():
		available_gates[gate.gate_id] = gate
		gate.connect("player_entered_gate", signal_switch_level)

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
