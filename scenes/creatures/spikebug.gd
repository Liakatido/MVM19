extends Node2D

@onready var sides = %Sides
@onready var down = %Down

const SPEED = 30.0
const GRAVITY = 100.0

var down_raycasts : Array[RayCast2D]
var sides_raycasts : Array[RayCast2D]

var body : CharacterBody2D
var orientation : Vector2 = Vector2.RIGHT

func _ready():
	body = get_parent()
	for ray in down.get_children():
		down_raycasts.append(ray)
	for ray in sides.get_children():
		sides_raycasts.append(ray)

func _physics_process(delta):
	# apply gravity
	if not body.is_on_floor():
		body.velocity.y += GRAVITY * delta
	
	# check if should change orientation
	if is_about_to_fall() or is_about_to_hit_wall():
		orientation *= -1
	
	# move body
	body.velocity = orientation*SPEED
	body.move_and_slide()

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
