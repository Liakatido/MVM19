extends Node2D

const Spit = preload("res://scenes/creatures/enemyspit.tscn")
const SpitSound = preload ("res://assets/sounds/player/spitter.ogg")

enum State {
	IDLE,
	SHOOT,
	AWAY
}

const GRAVITY = 280.0
const JUMP = 80.0
const JUMP_HORIZONTAL = 60.0
const JUMP_COOLDOWN = 1.5 # seconds
const SHOOT_COOLDOWN = 2.0 # seconds
const SHOOT_DISTANCE = 130

var state = State.IDLE
var x_speed : float = 0
var shoot_ticker : float
var can_shoot : bool = true
var shooting : bool = false
var jump_ticker : float
var can_jump : bool = true
var body : CharacterBody2D
var sprite : Sprite2D
var animations : AnimationPlayer
var orientation : Vector2 = Vector2.RIGHT

func _ready():
	body = get_parent()
	sprite = get_parent().get_node("Sprite2D")
	animations = get_parent().get_node("MovementAnimations")
	animations.play("idle")

func _physics_process(delta):
	# handle shoot cooldown
	if not can_shoot:
		shoot_ticker += delta
		if shoot_ticker >= SHOOT_COOLDOWN:
			shoot_ticker = 0
			can_shoot = true
	
	var player_is_close = distance_to_player() <= SHOOT_DISTANCE
	if player_is_close and not can_shoot:
		state = State.AWAY
	if player_is_close and can_shoot and body.is_on_floor():
		state = State.SHOOT
	if not player_is_close:
		state = State.IDLE
	
	# wait until finished shooting to keep processing
	if shooting:
		return
	
	match state:
		State.IDLE:
			idle(delta)
		State.SHOOT:
			shoot(delta)
		State.AWAY:
			away(delta)
	
	# set sprite orientation
	sprite.flip_h = orientation == Vector2.LEFT

func direction_to_player() -> Vector2:
	return body.global_position.direction_to(Data.player_position)

func distance_to_player() -> float:
	return body.global_position.distance_to(Data.player_position)

func stop_shooting():
	shooting = false

func away(delta):
	# change x direction when touching a wall
	if body.is_on_wall():
			orientation = orientation*-1
	
	# jump cooldown
	if not can_jump:
		jump_ticker += delta
		if jump_ticker >= JUMP_COOLDOWN:
			jump_ticker = 0
			can_jump = true
	
	if body.is_on_floor():
		animations.play("idle")
		x_speed = 0
	
	# jump whenever on floor, and on cooldown
	if body.is_on_floor() and can_jump:
		animations.play("jump")
		can_jump = false
		body.velocity.y -= JUMP
		x_speed = JUMP_HORIZONTAL
		# on jump, set orientation away from player
		var direction_to_player = direction_to_player()
		orientation.x = sign(direction_to_player.x)*-1
	
	# apply gravity
	body.velocity.y += GRAVITY*delta
	body.velocity.x = orientation.x*x_speed
	
	body.move_and_slide()

func shoot(delta):
	if body.is_on_floor():
		Utils.spawn_audio(SpitSound, -12)
		shooting = true
		animations.play("shoot")
		can_shoot = false
		var direction_to_player = direction_to_player()
		orientation.x = sign(direction_to_player().x)
	
		var spit = Spit.instantiate()
		spit.DAMAGE = 10
		spit.set_orientation(Vector2(sign(direction_to_player.x), 0))
		spit.global_position = self.global_position + Vector2(orientation.x*5, -10)
		body.get_parent().add_child(spit)
		
		# stop moving for some time while shooting
		get_tree().create_timer(0.6).connect("timeout", stop_shooting)
	

func idle(delta):
	# change x direction when touching a wall
	if body.is_on_wall():
			orientation = orientation*-1
	
	# jump cooldown
	if not can_jump:
		jump_ticker += delta
		if jump_ticker >= JUMP_COOLDOWN:
			jump_ticker = 0
			can_jump = true
	
	if body.is_on_floor():
		animations.play("idle")
		x_speed = 0
	
	# jump whenever on floor, and on cooldown
	if body.is_on_floor() and can_jump:
		animations.play("jump")
		can_jump = false
		body.velocity.y -= JUMP
		x_speed = JUMP_HORIZONTAL
	
	# apply gravity
	body.velocity.y += GRAVITY*delta
	body.velocity.x = orientation.x*x_speed
	
	body.move_and_slide()
