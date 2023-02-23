extends CharacterBody2D

const Attack = preload("res://scenes/player/attack.tscn")
const DashTextureRight = preload("res://assets/particles/dash.png")
const DashTextureLeft = preload("res://assets/particles/dash_inverse.png")

@onready var sprite = $Sprite2D
@onready var animations = $AnimationPlayer
@onready var walk_audio = $WalkAudio
@onready var jump_audio = $JumpAudio
@onready var attack_audio = $AttackAudio
@onready var dash_audio = $DashAudio
@onready var dash_particles = $DashParticles
@onready var attack_marker = $AttackMarker

const SPEED = 85.0
const JUMP_VELOCITY = -190.0
const GRAVITY = 520

const LEFT = -1
const RIGHT = 1

var orientation : Vector2 = Vector2.RIGHT
var disabled : bool = false

# attack data
const ATTACK_COOLDOWN : float = 0.4

var attack_marker_x : float
var can_attack : bool = true
var attack_ticker : float

# dash data
const DASH_SPEED = 400
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.2

var dashing : bool = false
var can_dash : bool = false
var dash_ticker : float


func _ready():
	attack_marker_x = attack_marker.position.x

func _unhandled_input(event):
	if event.is_action_pressed("attack") and can_attack and not dashing:
		attack_audio.play()
		can_attack = false
		var attack = Attack.instantiate()
		add_child(attack)
		attack.global_position = attack_marker.global_position
		attack.do_attack(orientation)
		animations.play("attack")
	if event.is_action_pressed("dash") and can_dash:
		dash_audio.play()
		can_dash = false
		animations.play("dash")
		dashing = true
		dash_particles.emitting = true
	

func _process(delta):
	# handle attack cooldown
	if not can_attack:
		attack_ticker += delta
		if attack_ticker > ATTACK_COOLDOWN:
			attack_ticker = 0
			can_attack = true
	
	if dashing:
		dash_ticker += delta
		if dash_ticker > DASH_DURATION:
			dashing = false
			dash_particles.emitting = false
	
	if not can_dash and not dashing:
		dash_ticker += delta
		if dash_ticker > DASH_COOLDOWN:
			dash_ticker = 0
			can_dash = true

func _physics_process(delta):
	if disabled:
		return
	
	# handle dash
	if dashing:
		velocity = orientation * DASH_SPEED
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_audio.play()
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	# set orientation
	if direction == LEFT:
		orientation = Vector2.LEFT
		sprite.flip_h = true
		attack_marker.position.x = -attack_marker_x
		dash_particles.texture = DashTextureLeft
	if direction == RIGHT:
		sprite.flip_h = false
		attack_marker.position.x = attack_marker_x
		orientation = Vector2.RIGHT
		dash_particles.texture = DashTextureRight
	
	# handle horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# handle animations
	var attacking = animations.current_animation == "attack" and animations.is_playing()
	if direction != 0 and is_on_floor() and not attacking:
		animations.play("run")
	if direction == 0 and is_on_floor() and not attacking:
		animations.play("idle")
	if not is_on_floor() and not attacking:
		animations.play("jump")
