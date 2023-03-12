extends Node2D

const Spit = preload("res://scenes/creatures/enemyspit.tscn")
const SpitSound = preload ("res://assets/sounds/player/spitter.ogg")
const JumpSound = preload("res://assets/sounds/player/spitterjump.ogg")

enum State {
	IDLE,
	SHOOT,
	JUMP
}

const GRAVITY = 380.0
const JUMP = 200.0
const JUMPS = 12
const JUMP_HORIZONTAL = 100.0
const SHOOT_DISTANCE = 130
const SHOOT_INTERVAL = 0.5 # seconds
const SHOOT_AMOUNT = 10
const IDLE_COOLDOWN = 1.5

var state = State.IDLE
var next_state = State.JUMP
var x_speed : float = 0
var jumps_amount : int = 0
var shoot_ticker : float
var shots : int = 0
var jump_ticker : float
var idle_ticker : float

var body : CharacterBody2D
var sprite : Sprite2D
var animations : AnimationPlayer
var orientation : Vector2 = Vector2.RIGHT
var raycast : RayCast2D

func _ready():
	body = get_parent()
	sprite = get_parent().get_node("Sprite2D")
	raycast = get_node("RayCast2D")
	animations = get_parent().get_node("MovementAnimations")
	animations.play("idle")

func _physics_process(delta):	
	match state:
		State.IDLE:
			idle(delta)
		State.SHOOT:
			shoot(delta)
		State.JUMP:
			jump(delta)
	
	# set orientation
	
	# apply gravity
	body.velocity.y += GRAVITY*delta
	
	body.move_and_slide()

func direction_to_player() -> Vector2:
	return body.global_position.direction_to(Data.player_position)

func distance_to_player() -> float:
	return body.global_position.distance_to(Data.player_position)

var orientation_ticker : float
func jump(delta):
	# change x direction when touching a wall
	orientation_ticker += delta
	if raycast.is_colliding() and orientation_ticker > 0.5:
			orientation_ticker = 0
			orientation = orientation*-1
			flip(orientation)

	if body.is_on_floor():
		if jumps_amount > JUMPS:
			next_state = State.SHOOT
			state = State.IDLE
			body.velocity.x = 0
			jumps_amount = 0
			return
		Utils.spawn_audio(JumpSound, -10)
		Utils.shake(8)
		animations.play("jump")
		jumps_amount += 1
		body.velocity.y -= JUMP
		x_speed = JUMP_HORIZONTAL
		
	
	body.velocity.x = orientation.x*x_speed

func flip(orientation : Vector2):
	sprite.flip_h = orientation == Vector2.LEFT
	raycast.target_position.x *= -1
	body.get_node("Hitbox/CollisionShape2D").position.x *= -1
	body.get_node("DamageArea/CollisionShape2D").position.x *= -1

func shoot(delta):
	shoot_ticker += delta
	if shoot_ticker <= SHOOT_INTERVAL:
		return
	shoot_ticker = 0
	
	Utils.spawn_audio(SpitSound, -12)
	animations.play("shoot")
	var shoot_direction = sign((randf()*2)-1)
	

	var spit = Spit.instantiate()
	spit.DAMAGE = 10
	spit.set_orientation(Vector2(shoot_direction, 0))
	spit.set_spread(100, 0.6)
	spit.global_position = self.global_position + Vector2(orientation.x*5, -30)
	body.get_parent().add_child(spit)
	
	shots += 1
	if shots >= SHOOT_AMOUNT:
		next_state = State.JUMP
		shots = 0
		state = State.IDLE
		jump_ticker = 0
	

func idle(delta):
	animations.play("idle")
	idle_ticker += delta
	if idle_ticker >= IDLE_COOLDOWN:
		state = next_state
		idle_ticker = 0
