extends Node2D

enum State {
	AMBUSH,
	DOWN,
	WAIT,
	UP
}

const SPEED = 250.0
const WAIT_DURATION = 2.5 # seconds
const ATTACK_COOLDOWN = 2 # seconds

var rays : Array[RayCast2D]
var body : CharacterBody2D
var animations : AnimationPlayer
var line : Line2D
var state : State = State.AMBUSH
var origin_pos : Vector2
var wait_ticker : float
var cooldown_ticker : float
var line_node_moved : bool = false


func _ready():
	origin_pos = self.global_position
	for ray in get_children():
		rays.append(ray)
	
	body = get_parent()
	animations = body.get_node("MovementAnimations")
	line = body.get_node("Line2D")
	
	# set line initial points
	line.add_point(self.global_position)
	line.add_point(self.global_position)

func move_line_to(pos : Vector2):
	# workaround to move line to body parent, can't do in _ready because it runs before body's _ready
	if not line_node_moved:
		body.remove_child(line)
		body.get_parent().add_child(line)
		line.global_position = Vector2.ZERO
		line.z_index = -1
		line_node_moved = true
		connect("tree_exited", line.queue_free)
	line.points[1] = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		State.AMBUSH:
			ambush(delta)
		State.DOWN:
			down(delta)
		State.UP:
			up(delta)
		State.WAIT:
			wait(delta)
	
	move_line_to(global_position)

func ambush(delta):
	var can_attack = cooldown_ticker >= ATTACK_COOLDOWN
	if not can_attack:
		cooldown_ticker += delta
		return
	
	for ray in rays:
		if ray.is_colliding():
			animations.play("idle")
			state = State.DOWN
			cooldown_ticker = 0

func down(_delta):
	if body.is_on_floor():
		state = State.WAIT
		return
	body.velocity.y = SPEED
	body.move_and_slide()

func wait(delta):
	wait_ticker += delta
	if wait_ticker >= WAIT_DURATION:
		wait_ticker = 0
		state = State.UP

func up(_delta):
	# if near origin, move to it and stop moving
	if body.global_position.distance_to(origin_pos) < 4:
		body.global_position = origin_pos
		state = State.AMBUSH
		animations.play("hide")
		return
	
	body.velocity.y = -SPEED
	body.move_and_slide()
