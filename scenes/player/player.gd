extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animations = $AnimationPlayer

const SPEED = 85.0
const JUMP_VELOCITY = -190.0
const GRAVITY = 520

const LEFT = -1
const RIGHT = 1

var disabled : bool = false


func _physics_process(delta):
	if disabled:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	# set sprite orientation
	if direction == LEFT:
		sprite.flip_h = true
	if direction == RIGHT:
		sprite.flip_h = false
	
	# handle horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# handle animations
	if direction != 0 and is_on_floor():
		animations.play("run")
	if direction == 0 and is_on_floor():
		animations.play("idle")
	if not is_on_floor():
		animations.play("jump")
