extends Node2D

const Gem = preload("res://scenes/creatures/gem.tscn")
const Bonewall = preload("res://scenes/creatures/bone_wall.tscn")
const Bonewave = preload("res://scenes/creatures/bone_wave.tscn")
const JumpSound = preload("res://assets/sounds/player/jump.ogg")
const BoneSound = preload("res://assets/sounds/player/bones.ogg")
const ShootSound = preload("res://assets/sounds/player/gem.ogg")

enum State {
	IDLE,
	SHOOT,
	DIG,
	JUMP,
	RUN
}

var body : CharacterBody2D
var animations : AnimationPlayer
var sprite : Sprite2D
var raycast : RayCast2D

var orientation = Vector2.RIGHT
var state = State.IDLE
var next_state = State.RUN

# Called when the node enters the scene tree for the first time.
func _ready():
	body = get_parent()
	animations = body.get_node("MovementAnimations")
	sprite = body.get_node("Sprite2D")
	raycast = get_node("RayCast2D")

func flip(new_orientation : Vector2):
	if new_orientation == orientation:
		return
	orientation = new_orientation
	sprite.flip_h = orientation == Vector2.LEFT
	raycast.target_position *= -1

const GRAVITY = 200
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not body.is_on_floor():
		body.velocity.y += GRAVITY*delta
	else:
		body.velocity.y = 0
	
	match state:
		State.IDLE:
			idle(delta)
		State.SHOOT:
			shoot(delta)
		State.RUN:
			run(delta)
		State.DIG:
			dig(delta)
		State.JUMP:
			jump(delta)
	
	body.move_and_slide()

func is_colliding_player() -> bool:
	return raycast.get_collider().has_method("is_in_group") and raycast.get_collider().is_in_group("player")

func direction_to_player() -> Vector2:
	return Vector2(sign(body.global_position.direction_to(Data.player_position).x), 0)

func switch_to_state(next):
	state = next
	match state:
		State.IDLE:
			animations.play("idle")
		State.SHOOT:
			animations.play("shoot")
			flip(direction_to_player())
		State.RUN:
			last_pos = global_position
			animations.play("run")
			flip(direction_to_player())
		State.JUMP:
			Utils.spawn_audio(JumpSound, -10, 0.7)
			animations.play("jump")
			body.velocity.y = -JUMP
		State.DIG:
			animations.play("dig")
			flip(direction_to_player())

const IDLE_INTERVAL = 3.0
var idle_ticker: float
func idle(delta):
	idle_ticker += delta
	if idle_ticker >= IDLE_INTERVAL:
		idle_ticker = 0
		# just roll if going from idle to run
		if next_state == State.RUN:
			should_jump = roll_should_jump()
		switch_to_state(next_state)

const SHOOT_INTERVAL = 6.0
const GEM_INTERVAl = 0.3
var gem_ticker : float
var shoot_ticker : float
func shoot(delta):
	shoot_ticker += delta
	gem_ticker += delta
	
	if gem_ticker >= GEM_INTERVAl:
		gem_ticker = 0
		# shoot gem
		Utils.spawn_audio(ShootSound, -16)
		var gem = Gem.instantiate()
		body.get_parent().add_child(gem)
		gem.global_position = global_position + Vector2(0, -12)
	
		var gem_velocity = Vector2(randf_range(10, 65)*direction_to_player().x, randf_range(200, 250)*-1)
		gem.shoot_v2(gem_velocity, 4)
	
	if shoot_ticker >= SHOOT_INTERVAL and not continue_shooting:
		shoot_ticker = 0
		gem_ticker = 0
		next_state = State.RUN
		switch_to_state(State.IDLE)

const SPEED = 100.0
const JUMP = 230.0
const JUMP_DISTANCE = 50.0
var last_pos : Vector2
var jump_distance_ticker : float
var should_jump : bool = false
func run(delta):
	body.velocity.x = SPEED*orientation.x
	
	if should_jump:
		jump_distance_ticker += abs(last_pos.x - global_position.x)
		if jump_distance_ticker >= JUMP_DISTANCE:
			should_jump = false
			jump_distance_ticker = 0
			switch_to_state(State.JUMP)
			return
	
	last_pos = global_position
	if raycast.is_colliding() and not is_colliding_player():
		next_state = roll_shoot_or_dig()
		body.velocity.x = 0
		switch_to_state(State.IDLE)

const JUMP_GEM_INTERVAL = 0.2
var jump_gem_ticker : float
func jump(delta):
	if body.is_on_floor():
		switch_to_state(State.RUN)
		return
	
	jump_gem_ticker += delta
	if jump_gem_ticker >= JUMP_GEM_INTERVAL:
		jump_gem_ticker = 0
		# shoot gem
		Utils.spawn_audio(ShootSound, -16)
		var gem = Gem.instantiate()
		body.get_parent().add_child(gem)
		gem.global_position = global_position + Vector2(0, 0)
	
		var gem_velocity = Vector2(randf_range(-50, 50), randf_range(10, 20))
		gem.shoot_v2(gem_velocity, 3)

const DIG_INTERVAL = 3.0
var dig_ticker : float
var continue_shooting : bool = false
func dig(delta):
	# dig for n seconds
	dig_ticker += delta
	if dig_ticker >= DIG_INTERVAL:
		dig_ticker = 0
		# spawn bone wall and wave
		var spawn_pos = global_position + raycast.target_position
		
		var bone_wall = Bonewall.instantiate()
		bone_wall.global_position = spawn_pos
		body.get_parent().add_child(bone_wall)
		Utils.spawn_audio(BoneSound, -3)
		bone_wall.rise()
		
		var bone_wave = Bonewave.instantiate()
		bone_wave.global_position = spawn_pos
		body.get_parent().add_child(bone_wave)
		bone_wave.direction = direction_to_player()
		bone_wave.start(direction_to_player())
		
		# connect stop shooting to bone wall destroy
		bone_wall.connect("destroyed", stop_shooting)
		
		# set to idle with next state shoot
		switch_to_state(State.IDLE)
		next_state = State.SHOOT
		continue_shooting = true

func stop_shooting():
	continue_shooting = false

func roll_should_jump() -> bool:
	var roll = randf_range(0, 1)
	return roll < 0.5

func roll_shoot_or_dig() -> State:
	var roll = randf_range(0, 1)
	if roll < 0.5:
		return State.SHOOT
	else:
		return State.DIG
