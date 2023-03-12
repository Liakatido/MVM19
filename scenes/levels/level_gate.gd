@tool
extends Area2D

signal player_entered_gate(to_level, to_gate)

@export var gate_id : String
@export var active : bool = true
@export var to_level : String
@export var to_gate : String

@onready var spawn_pos = $Marker2D

func get_spawn_pos() -> Vector2:
	return spawn_pos.global_position

func _on_area_entered(area):
	if active && area.is_in_group("player") :
		emit_signal("player_entered_gate", to_level, to_gate)
