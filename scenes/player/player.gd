extends CharacterBody2D

const Attack = preload("res://scenes/player/attack.tscn")
const Spit = preload("res://scenes/player/spit.tscn")
const DashTextureRight = preload("res://assets/particles/dash.png")
const DashTextureLeft = preload("res://assets/particles/dash_inverse.png")

@onready var sprite = $Sprite2D
@onready var animations = $AnimationPlayer
@onready var walk_audio = $WalkAudio
@onready var jump_audio = $JumpAudio
@onready var attack_audio = $AttackAudio
@onready var spit_audio = $SpitAudio
@onready var dash_audio = $DashAudio
@onready var dash_particles = $DashParticles
@onready var attack_marker = $AttackMarker
@onready var dust_particles = $DustParticles

const SPEED = 85.0
const JUMP_VELOCITY = -190.0
var GRAVITY = 520

const LEFT = -1
const RIGHT = 1

var orientation : Vector2 = Vector2.RIGHT
var disabled : bool = false
var was_on_floor : bool = true

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

# spit data
const SPIT_COOLDOWN = 2.0
var spit_ticker : float
var can_spit : bool = true
var spitting : bool = false

# crouch data
var crouching : bool = false
var original_sprite_pos : Vector2
var crouch_sprite_pos : Vector2


func _ready():
	attack_marker_x = attack_marker.position.x
	
	# setup crouch data
	original_sprite_pos = sprite.position
	crouch_sprite_pos = original_sprite_pos + Vector2(0, 1)

func _unhandled_input(event):
	if event.is_action_pressed("attack") and can_attack and not dashing:
		GRAVITY = 380 #lowering the impact of gravity so air attacks a bit more reliable
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
	
	if event.is_action_pressed("spit") and can_spit and not dashing:
		var spit = Spit.instantiate()
		spit.set_orientation(orientation)
		spit.global_position = self.global_position + Vector2(orientation.x*5, -10)
		get_parent().add_child(spit)
		can_spit = false
		# spit animation
		animations.play("shoot")
		spitting = true
		
		spit_audio.play()
	
	if event.is_action_pressed("down") and not dashing and not spitting:
		animations.play("down")
		crouching = true
		sprite.position = crouch_sprite_pos
	
	if event.is_action_released("down"):
		reset_after_crouch()
	

func _process(delta):
	# handle attack cooldown
	if not can_attack:
		attack_ticker += delta
		if attack_ticker > ATTACK_COOLDOWN:
			attack_ticker = 0
			GRAVITY = 520 #reseting gravity after air attacking.
			can_attack = true
	
	# handle dashing duration
	if dashing:
		dash_ticker += delta
		if dash_ticker > DASH_DURATION:
			dashing = false
			dash_particles.emitting = false
	
	# handle dash cooldown
	if not can_dash and not dashing:
		dash_ticker += delta
		if dash_ticker > DASH_COOLDOWN:
			dash_ticker = 0
			can_dash = true
	
	# handle spit cooldown
	if not can_spit:
		spit_ticker += delta
		if spit_ticker > SPIT_COOLDOWN:
			spit_ticker = 0
			can_spit = true

func _physics_process(delta):
	check_floor()
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
		dust_particles.restart()
		dust_particles.emitting = true
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
	if direction != 0 and is_on_floor() and not attacking and not spitting:
		animations.play("run")
	if direction == 0 and is_on_floor() and not attacking and not spitting and not crouching:
		reset_after_crouch() # sometimes crouch isn't cleaned properly, clean here just in case
		animations.play("idle")
	if not is_on_floor() and not attacking and not spitting:
		animations.play("jump")

# checks if player was touching floor on the previous frame
# and does what is needed depending the case
func check_floor():
	if is_on_floor() and not was_on_floor:
		dust_particles.restart()
		dust_particles.emitting = true
		was_on_floor = true
	
	if not is_on_floor() and was_on_floor:
		was_on_floor = false

func reset_after_crouch():
	sprite.scale = Vector2(1, 1)
	sprite.position = original_sprite_pos
	crouching = false

# handle cleaning after animations finish, when needed
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"shoot":
			spitting = false


func _on_animation_player_animation_started(anim_name):
	if anim_name != "down" and crouching:
		reset_after_crouch()
