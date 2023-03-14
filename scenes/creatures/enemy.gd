extends CharacterBody2D

const HurtAudio = preload("res://assets/sounds/player/mobhurt.ogg")

signal got_hit
signal destroyed

@onready var hitbox = $Hitbox
@onready var animations = $BasicAnimations

@export var corpse_path : String
@export var health = 30
@export var knockback_resistance : float

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 100.0
const KNOCKBACK = 500.0

var knockback_trigger : Vector2

func _ready():
	hitbox.connect("got_hit", get_hit)

func _physics_process(_delta):
	if knockback_trigger != Vector2.ZERO:
		if velocity.x == 0:
			velocity += knockback_trigger
		else:
			velocity += knockback_trigger/3
		move_and_slide()
		knockback_trigger = Vector2.ZERO
	
func get_hit(damage, direction : Vector2 = Vector2.ZERO):
	emit_signal("got_hit")
	Utils.spawn_audio(HurtAudio, -15)
	
	if direction != Vector2.ZERO:
		knockback(direction)
	
	animations.play("hit")
	health -= damage
	if health <= 0:
		get_destroyed()

func knockback(direction : Vector2):
	knockback_trigger = (KNOCKBACK - knockback_resistance*KNOCKBACK/100)*direction

func get_destroyed():
	emit_signal("destroyed")
	var corpse = load(corpse_path).instantiate()
	get_parent().add_child(corpse)
	corpse.global_position = global_position
	queue_free()
