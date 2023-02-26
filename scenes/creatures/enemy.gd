extends CharacterBody2D

@onready var hitbox = $Hitbox
@onready var animations = $BasicAnimations

@export var health = 30

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 100.0

func _ready():
	hitbox.connect("got_hit", get_hit)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

func get_hit(damage):
	animations.play("hit")
	health -= damage
	if health <= 0:
		get_destroyed()

func get_destroyed():
	queue_free()
