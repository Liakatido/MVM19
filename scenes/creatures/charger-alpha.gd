extends Node2D

const ChargeSound = preload("res://assets/sounds/player/charger.ogg")
const CrashSound = preload("res://assets/sounds/player/chargecrash.ogg")
const WalkSound = preload("res://assets/sounds/player/chargestep.ogg")

enum State {
	IDLE,
	CHARGE,
	SLIDE,
	STUNNED
}

var state = State.IDLE

const IDLE_COOLDOWN = 1
var idle_ticker : float

const CHARGES_AMOUNT = 5
var charges : int

const STUNNED_COOLDOWN = 8.0
var stunned_ticker : float

const SPEED = 130
const SLIDE_DEACCELERATION = 100

const IDLE_DAMAGE = 20
const CHARGE_DAMAGE = 40

var body : CharacterBody2D
var animations : AnimationPlayer
var damage_area : Area2D
var sprite : Sprite2D
var particles : CPUParticles2D
var particles_pos : float
var raycast : RayCast2D
var raycast_pos : float
var rocks

var orientation : Vector2 = Vector2.RIGHT

func _ready():
	body = get_parent()
	animations = body.get_node("MovementAnimations")
	damage_area = body.get_node("DamageArea")
	sprite = body.get_node("Sprite2D")
	particles = body.get_node("CPUParticles2D")
	particles_pos = particles.position.x
	raycast = get_node("RayCast2D")
	raycast_pos = raycast.target_position.x
	rocks = body.get_node("RockLine")

func _physics_process(delta):
	match state:
		State.IDLE:
			idle(delta)
		State.CHARGE:
			charge(delta)
		State.STUNNED:
			stunned(delta)
		State.SLIDE:
			slide(delta)
	
	if rocks.spawn_rocks:
		process_rocks(delta)
	
	body.move_and_slide()

func flip():
	sprite.flip_h = orientation == Vector2.LEFT
	raycast.target_position.x = raycast_pos * orientation.x
	particles.position.x = particles_pos * orientation.x
	particles.direction.x = orientation.x*-1

func direction_to_player() -> Vector2:
	return body.global_position.direction_to(Data.player_position)

func idle(delta):
	setup_rock_line()
	idle_ticker += delta
	if idle_ticker >= IDLE_COOLDOWN:
		idle_ticker = 0
		state = State.CHARGE
		var previous_orientation = orientation
		orientation = Vector2(sign(direction_to_player().x), 0)
		if orientation != previous_orientation:
			flip()
		animations.play("run")

func is_colliding_player() -> bool:
	return raycast.get_collider().has_method("is_in_group") and raycast.get_collider().is_in_group("player")

var sound_ticker : float
func charge(delta):
	body.velocity.x = SPEED*orientation.x
	sound_ticker += delta
	if sound_ticker >= 0.35:
		Utils.spawn_audio(WalkSound, -5)
		sound_ticker = 0
	
	# approaching wall
	if raycast.is_colliding() and not is_colliding_player() and charges <= CHARGES_AMOUNT:
		charges += 1
		state = State.SLIDE
		animations.play("slide")
		particles.emitting = true
	
	if raycast.is_colliding() and not is_colliding_player() and charges > CHARGES_AMOUNT:
		if body.is_on_wall():
			# crash sound
			charges = 0
			Utils.spawn_audio(CrashSound, -10)
			animations.play("stunned")
			rocks.spawn_rocks = true
			get_tree().create_timer(STUNNED_COOLDOWN + 3).connect("timeout", stop_rocks)
			Utils.shake()
			body.velocity.x = 0
			state = State.STUNNED
			

func slide(delta):
	body.velocity.x = body.velocity.x - SLIDE_DEACCELERATION*orientation.x*delta
	
	# stop slide when standing still
	if (body.velocity.x <= 10 and not body.velocity.x < -10) or (body.velocity.x >= -10 and not body.velocity.x > 10):
		state = State.CHARGE
		Utils.spawn_audio(ChargeSound, -10, 0.7)
		animations.play("run")
		particles.emitting = false
		orientation = orientation*-1
		flip()
		

func stunned(delta):
	stunned_ticker += delta
	if stunned_ticker >= STUNNED_COOLDOWN:
		stunned_ticker = 0
		state = State.IDLE
		animations.play("idle")

var shake_ticker : float
const SHAKE_INTERVAL = 0.3
func process_rocks(delta):
	shake_ticker += delta
	if shake_ticker >= SHAKE_INTERVAL:
		Utils.shake(3)
		shake_ticker = 0

func stop_rocks():
	rocks.spawn_rocks = false

var rocks_done = false
func setup_rock_line():
	if not rocks_done:
		var global_pos = rocks.global_position
		body.remove_child(rocks)
		body.get_parent().add_child(rocks)
		rocks_done = true
		rocks.global_position = global_pos
		body.connect("destroyed", rocks.stop)
