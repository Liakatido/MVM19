extends CharacterBody2D

@onready var hitbox = $Hitbox
@onready var animations = $BasicAnimations

@export var corpse_path : String
@export var health = 30

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 100.0

func _ready():
	hitbox.connect("got_hit", get_hit)

func get_hit(damage):
	animations.play("hit")
	health -= damage
	if health <= 0:
		get_destroyed()

func get_destroyed():
	var corpse = load(corpse_path).instantiate()
	get_parent().add_child(corpse)
	corpse.global_position = global_position
	queue_free()
