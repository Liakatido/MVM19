extends Node2D

const Cry = preload("res://assets/sounds/player/charger.ogg")

enum State {
	IDLE,
	CHARGE,
}

const IDLE_DAMAGE = 20
const CHARGE_DAMAGE = 40

const CHARGE_SPEED = 100
const CHARGE_COOLDOWN = 2
const WALL_GRACE_TIME = 0.4
const ATTACK_RANGE = 200

var body : CharacterBody2D
var animations : AnimationPlayer
var damage_area : Area2D
var sprite : Sprite2D
var rays : Array[RayCast2D]

var state : State = State.IDLE
var charge_ticker : float
var grace_ticker : float

var orientation : Vector2 = Vector2.RIGHT


func _ready():
	body = get_parent()
	animations = body.get_node("MovementAnimations")
	damage_area = body.get_node("DamageArea")
	sprite = body.get_node("Sprite2D")
	
	for ray in get_children():
		rays.append(ray)


func _physics_process(delta):
	match state:
		State.IDLE:
			idle(delta)
		State.CHARGE:
			charge(delta)
	
	# set sprite orientation
	sprite.flip_h = orientation == Vector2.LEFT

func direction_to_player() -> Vector2:
	return body.global_position.direction_to(Data.player_position)

func distance_to_player() -> float:
	return body.global_position.distance_to(Data.player_position)

func idle(delta):
	charge_ticker += delta
	if charge_ticker >= CHARGE_COOLDOWN and distance_to_player() < ATTACK_RANGE:
		charge_ticker = 0
		state = State.CHARGE
		orientation = Vector2(sign(direction_to_player().x), 0)
		animations.play("charge")
		damage_area.damage = CHARGE_DAMAGE
		Utils.spawn_audio(Cry, -10)
		grace_ticker = 0

func charge(delta):
	grace_ticker += delta
	
	# stop charging if about to drop
	for ray in rays:
		if not ray.is_colliding():
			state = State.IDLE
			damage_area.damage = IDLE_DAMAGE
			animations.play("idle")
			return
	
	# stop charging if hitting wall
	# grace time is to start moving even if touching a wall at the start
	if body.is_on_wall() and grace_ticker > WALL_GRACE_TIME:
		state = State.IDLE
		damage_area.damage = IDLE_DAMAGE
		animations.play("idle")
		return
	
	# do charge
	body.velocity = orientation*CHARGE_SPEED
	body.move_and_slide()
