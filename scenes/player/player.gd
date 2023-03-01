extends CharacterBody2D

const Attack = preload("res://scenes/player/attack.tscn")
const Spit = preload("res://scenes/player/spit.tscn")
const Bite = preload("res://scenes/player/bite.tscn")
const DashTextureRight = preload("res://assets/particles/dash.png")
const DashTextureLeft = preload("res://assets/particles/dash_inverse.png")
const Corpse = preload("res://scenes/player/player_corpse.tscn")
const HurtSound = preload("res://assets/sounds/player/hurt.ogg")

@onready var sprite = $Sprite2D
@onready var animations = $AnimationPlayer
@onready var camera = $Camera2D
@onready var invincible_animation = $InvincibleAnimation
@onready var walk_audio = $WalkAudio
@onready var jump_audio = $JumpAudio
@onready var attack_audio = $AttackAudio
@onready var spit_audio = $SpitAudio
@onready var dash_audio = $DashAudio
@onready var dash_particles = $DashParticles
@onready var attack_marker = $AttackMarker
@onready var dust_particles = $DustParticles
@onready var dash_hitbox = $ChargeHitbox
@onready var crash_hitbox = $CrashHitbox
@onready var hitbox = $Hitbox

const SPEED = 85.0
const JUMP_VELOCITY = -190.0
var GRAVITY = 520

const LEFT = -1
const RIGHT = 1

var orientation : Vector2 = Vector2.RIGHT
var disabled : bool = false
var was_on_floor : bool = true

var stunned : bool = false
const STUN_DURATION = 0.4 # seconds
var stun_ticker : float
var stun_velocity : Vector2

# invicibility data
var invincible : bool = false
var invincible_ticker : float
const INVINCIBILITY_PERIOD = 1.5

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
var dash_hitbox_pos : Vector2
var crash_hitbox_pos : Vector2

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
	
	# setup dash data
	dash_hitbox_pos = dash_hitbox.position
	crash_hitbox_pos = crash_hitbox.position
	
	# connect signals
	hitbox.connect("got_hit", get_hit)
	Data.connect("player_died", destroy)

func _unhandled_input(event):
	if disabled:
		return
	
	if event.is_action_pressed("attack") and can_attack and not dashing and not crouching:
		GRAVITY = 380 #lowering the impact of gravity so air attacks a bit more reliable
		attack_audio.play()
		can_attack = false
		var attack = Attack.instantiate()
		add_child(attack)
		attack.global_position = attack_marker.global_position
		attack.do_attack(orientation)
		animations.play("attack")
	
	if event.is_action_pressed("attack") and crouching:
		var bite = Bite.instantiate()
		add_child(bite)
		bite.global_position = global_position + Vector2(4, 0)*orientation + Vector2(0, -6)
		bite.bite()
	
	if event.is_action_pressed("dash") and can_dash and Data.dash_enabled:
		enable_crash_hitbox()
		dash_audio.play()
		can_dash = false
		animations.play("dash")
		dashing = true
		dash_particles.emitting = true
	
	if event.is_action_pressed("spit") and can_spit and not dashing and Data.spit_enabled:
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
	if invincible:
		invincible_ticker += delta
		if invincible_ticker > INVINCIBILITY_PERIOD:
			invincible_ticker = 0
			end_invincibility()
	
	# handle stunned duration
	if stunned:
		stun_ticker += delta
		if stun_ticker >= STUN_DURATION:
			stunned = false
			stun_ticker = 0
	
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
			disable_crash_hitbox()
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
	
	# will move in the stun velocity/direction until its finished
	if stunned:
		# set stun velocity only once
		if stun_velocity != Vector2.ZERO:
			velocity = stun_velocity
			stun_velocity = Vector2.ZERO
		velocity.y += GRAVITY * delta # gravity should still apply
		move_and_slide()
		return
	
	# handle dash
	if dashing:
		break_entities()
		crash_against_wall()
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
		dash_hitbox.position = dash_hitbox_pos * Vector2(-1, 1)
		crash_hitbox.position = crash_hitbox_pos * Vector2(-1, 1)
	if direction == RIGHT:
		sprite.flip_h = false
		attack_marker.position.x = attack_marker_x
		orientation = Vector2.RIGHT
		dash_particles.texture = DashTextureRight
		dash_hitbox.position = dash_hitbox_pos
		crash_hitbox.position = crash_hitbox_pos
	
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

func get_hit(damage):
	if not invincible:
		# todo: some knockback?
		# play audio outside of player node, so when it dies, the sound doesn't cut
		Utils.spawn_audio(HurtSound, -13)
		Data.health -= damage
		start_invincibilty()

func start_invincibilty():
	invincible = true
	invincible_animation.play("invincible")

func end_invincibility():
	invincible = false
	invincible_animation.play("RESET")

func destroy():
	disabled = true
	# spawn corpse
	var corpse = Corpse.instantiate()
	corpse.global_position = global_position
	corpse.velocity = velocity
	if orientation == Vector2.LEFT:
		corpse.scale = Vector2(-1, 1)
	get_parent().add_child(corpse)
	
	# set camera to follow corpse
	remove_child(camera)
	corpse.add_child(camera)
	
	# destroy player node
	hide()
	call_deferred("queue_free")

# handle cleaning after animations finish, when needed
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"shoot":
			spitting = false


func _on_animation_player_animation_started(anim_name):
	if anim_name != "down" and crouching:
		reset_after_crouch()

func disable_crash_hitbox():
	crash_hitbox.monitorable = false
	crash_hitbox.monitoring = false

func enable_crash_hitbox():
	crash_hitbox.monitorable = true
	crash_hitbox.monitoring = true

func get_stunned():
	dashing = false
	dash_particles.emitting = false
	
	invincible = true
	stunned = true
	var x_speed = 40
	var y_speed = 100
	stun_velocity = Vector2(-orientation.x*x_speed, -y_speed)

# break object returns a bool that indicates if player should be stunned after
# breaking something (e.g on some enemies breakable parts)
func break_entities():
	var entities = dash_hitbox.get_overlapping_areas()
	for entity in entities:
		if entity.has_method("break_object"):
			disable_crash_hitbox()
			var should_stun = entity.break_object()
			if should_stun:
				get_stunned()

func crash_against_wall():
	var bodies = crash_hitbox.get_overlapping_bodies()
	# there is always 1 body inside (player)
	if bodies.any(func(x) -> bool: return x is TileMap):
		disable_crash_hitbox()
		get_stunned()
