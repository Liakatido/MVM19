extends Node2D

@onready var sides = %Sides
@onready var down = %Down

enum State {
	IDLE,
	FLEE
}

const SPEED = 20.0
const GRAVITY = 400.0
const FLEE_SPEED = 40.0
const JUMP = 200.0

var down_raycasts : Array[RayCast2D]
var sides_raycasts : Array[RayCast2D]

var body : CharacterBody2D
var orientation : Vector2 = Vector2.RIGHT

var state : State = State.IDLE

func _ready():
	body = get_parent()
	for ray in down.get_children():
		down_raycasts.append(ray)
	for ray in sides.get_children():
		sides_raycasts.append(ray)
	body.get_node("MovementAnimations").play("idle")
	body.connect("got_hit", switch_to_flee)

func _physics_process(delta):
	# apply gravity
	if not body.is_on_floor():
		body.velocity.y += GRAVITY * delta
	if body.is_on_ceiling():
		body.velocity.y = 0
	
	# same behavior as spikebug
	if state == State.IDLE:
		# check if should change orientation
		if is_about_to_fall() or is_about_to_hit_wall():
			orientation *= -1
	
		# move body
		body.velocity.x = orientation.x*SPEED
		body.move_and_slide()
	else:
		# jump whenever on floor
		if body.is_on_floor():
			body.velocity.y = -JUMP
		
		# change x direction when hitting a wall
		if body.is_on_wall():
			orientation = orientation*-1
		
		body.velocity.x = orientation.x*FLEE_SPEED
		body.move_and_slide()
	
	body.get_node("Sprite2D").flip_h = orientation == Vector2.RIGHT

func switch_to_flee():
	state = State.FLEE

func is_about_to_fall() -> bool:
	for ray in down_raycasts:
		if not ray.is_colliding():
			return true
	return false

func is_about_to_hit_wall() -> bool:
	for ray in sides_raycasts:
		if ray.is_colliding() and not ray.get_collider().name == "Player":
			return true
	return false
