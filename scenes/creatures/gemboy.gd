extends Node2D

const Gem = preload("res://scenes/creatures/gem.tscn")
const ShootSound = preload("res://assets/sounds/player/gem.ogg")

@onready var raycast = $RayCast2D

enum State {
	IDLE,
	AWAY,
	SHOOT
}

const SPEED = 100.0
const GRAVITY = 200.0
const ATTACK_RANGE = 140
const AWAY_DURATION = 1
const SHOOT_DURATION = 0.5
const SHOOT_COOLDOWN = 3
var shoot_ticker : float
var away_ticker : float

const DIR_1 = Vector2(1, -0.6)
const DIR_2 = Vector2(1, -0.4)
const DIR_3 = Vector2(1, -0.1)

const SPD_1 = 100.0
const SPD_2 = 90.0
const SPD_3 = 80.0

var state = State.IDLE
var body : CharacterBody2D
var animations : AnimationPlayer
var sprite : Sprite2D
var orientation : Vector2 = Vector2.RIGHT

func _ready():
	body = get_parent()
	animations = body.get_node("MovementAnimations")
	sprite = body.get_node("Sprite2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not body.is_on_floor():
		body.velocity.y += GRAVITY*delta
	
	match state:
		State.IDLE:
			idle(delta)
		State.AWAY:
			away(delta)
		State.SHOOT:
			shoot(delta)
	
	body.move_and_slide()
	# set sprite orientation
	sprite.flip_h = orientation == Vector2.LEFT
	raycast.target_position.x = 12*orientation.x

func direction_to_player() -> Vector2:
	return body.global_position.direction_to(Data.player_position)

func distance_to_player() -> float:
	return body.global_position.distance_to(Data.player_position)

func idle(delta):
	shoot_ticker += delta
	if distance_to_player() <= ATTACK_RANGE and shoot_ticker >= SHOOT_COOLDOWN:
		shoot_ticker = 0
		state = State.SHOOT
		animations.play("attack")
		orientation.x = sign(direction_to_player().x)
		return

func away(delta):
	away_ticker += delta
	if away_ticker >= AWAY_DURATION:
		away_ticker = 0
		state = State.IDLE
		animations.play("idle")
		body.velocity.x = 0
		return
	
	if raycast.is_colliding() and body.is_on_floor():
		body.velocity.y = -100
	
	orientation = Vector2(-sign(direction_to_player().x), 0)
	body.velocity.x = orientation.x*SPEED

func shoot(delta):
	if shoot_ticker == 0:
		Utils.spawn_audio(ShootSound, -13)
		var gem1 = Gem.instantiate()
		var gem2 = Gem.instantiate()
		var gem3 = Gem.instantiate()
		body.get_parent().add_child(gem1)
		body.get_parent().add_child(gem2)
		body.get_parent().add_child(gem3)
		gem1.global_position = global_position + Vector2(8, 0)
		gem2.global_position = global_position + Vector2(0, 0)
		gem3.global_position = global_position + Vector2(-8, 0)
	
		gem1.shoot(DIR_1*Vector2(orientation.x,2.8), SPD_1, 5)
		gem2.shoot(DIR_2*Vector2(orientation.x,3), SPD_2, 4)
		gem3.shoot(DIR_3*Vector2(orientation.x,3.2), SPD_3, 2)
	shoot_ticker += delta
	if shoot_ticker >= SHOOT_DURATION:
		animations.play("walk")
		state = State.AWAY
