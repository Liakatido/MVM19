extends Node

class_name GlobalData

signal max_health_changed
signal health_changed
signal max_ammo_changed
signal ammo_changed
signal player_died

var max_health : int = 100 : set = _set_max_health
var health : int = 100 : set = _set_health
var ammo : int = 4 : set = _set_ammo
var max_ammo : int = 4 : set = _set_max_ammo
var ammo_ticker : float
var ammo_cooldown : float = 10

var player_position : Vector2

var tail_enabled : bool
var dash_enabled : bool
var spit_enabled : bool

var flags : Dictionary

var last_save : SaveState

func _process(delta):
	if ammo < max_ammo:
		ammo_ticker += delta
		if ammo_ticker >= ammo_cooldown:
			ammo_ticker = 0
			ammo = ammo + 1

func set_stats_from_last_save():
	max_health = last_save.max_health
	health = last_save.health
	max_ammo = last_save.max_ammo
	ammo = last_save.ammo
	
	tail_enabled = last_save.tail_enabled
	dash_enabled = last_save.dash_enabled
	spit_enabled = last_save.spit_enabled
	
	flags = last_save.flags.duplicate()

func save(level : String, gate : String):
	var new_save = SaveState.new()
	new_save.health = health
	new_save.max_health = max_health
	new_save.ammo = ammo
	new_save.max_ammo = max_ammo
	new_save.gate = gate
	new_save.level = level
	
	new_save.dash_enabled = dash_enabled
	new_save.spit_enabled = spit_enabled
	new_save.tail_enabled = tail_enabled
	
	new_save.flags = flags.duplicate()
	
	last_save = new_save

func _set_max_health(value):
	max_health = value
	health = max_health
	emit_signal("max_health_changed")
	emit_signal("health_changed")

func _set_health(value):
	health = value
	if health > max_health:
		health = max_health
	if health <= 0:
		emit_signal("player_died")
	emit_signal("health_changed")

func _set_max_ammo(value):
	max_ammo = value
	ammo = value
	emit_signal("max_ammo_changed")
	emit_signal("ammo_changed")

func _set_ammo(value):
	ammo = value
	if ammo > max_ammo:
		ammo = max_ammo
	emit_signal("ammo_changed")

class SaveState:
	# player stats
	var max_health : int
	var health : int
	var ammo : int
	var max_ammo : int
	
	# where to spawn
	var level : String
	var gate : String
	
	# abilities flags
	var dash_enabled : bool
	var spit_enabled : bool
	var tail_enabled : bool
	
	# enemy flags
	var flags : Dictionary
