extends CharacterBody2D


@onready var damage_area = $DamageArea
@onready var sprite = $Sprite2D
var moving : bool = false
var gravity : float

func _ready():
	damage_area.connect("hitted", destroy)

func _physics_process(delta):
	sprite.rotation = velocity.normalized().angle()
	if moving:
		velocity.y += gravity
		move_and_slide()
		
		if is_on_floor() or is_on_wall():
			destroy()

func shoot(direction : Vector2, speed : float, g : float):
	velocity = speed*direction
	gravity = g
	moving = true

func destroy():
	queue_free()
