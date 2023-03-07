extends Node2D

@onready var path = get_node("Path")

const SPEED = 20.0


var body : CharacterBody2D
var path_points : Array[Vector2]
var current_i : int
var i_ascending : bool = true

func _ready():
	path.hide()
	body = get_parent()
	body.get_node("MovementAnimations").play("idle")
	
	# calculate path points
	path_points = []
	for line_point in path.points:
		path_points.append(line_point + path.global_position)

func _physics_process(delta):
	if on_current_i():
		set_next_i()
	
	var direction = body.global_position.direction_to(path_points[current_i])
	
	body.get_node("Sprite2D").flip_h = direction.x > 0
	
	body.velocity = direction * SPEED
	body.move_and_slide()

func set_next_i():
	if i_ascending:
		var possible = current_i + 1
		if possible == len(path_points):
			i_ascending = false
			possible = current_i - 1
		current_i = possible
	else:
		var possible = current_i - 1
		if possible <= 0:
			i_ascending = true
			possible = current_i + 1

const DISTANCE_TO_CLOSE : float = 4.0
func on_current_i() -> bool:
	return global_position.distance_to(path_points[current_i]) <= DISTANCE_TO_CLOSE
