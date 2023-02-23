extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var hitbox = $Hitbox
@onready var particles = $CPUParticles2D

const SPEED : float = 200
const UP_SPEED : float = 100
const GRAVITY : float = 220

var disabled = false
var shooting_direction = Vector2(1, -0.5)

func _ready():
	velocity.y = shooting_direction.y * UP_SPEED
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.15).from(Vector2.ZERO)

func _physics_process(delta):
	# stop moving after being disabled
	if disabled:
		return
	velocity.y += GRAVITY * delta
	velocity.x = shooting_direction.x * SPEED
	move_and_slide()

func set_orientation(orientation : Vector2):
	if orientation == Vector2.LEFT:
		shooting_direction.x = -1
	

# hitted environment
func _on_hitbox_body_entered(body):
	if disabled:
		return
	if body.is_in_group("player") or body.is_in_group("spit"):
		return
	disabled = true
	hitbox.set_deferred("monitoring", false)
	particles.emitting = false
	sprite.hide() # play hit animation
	# set so bullet is queued free when particles dissipate
	var q_free_timer = get_tree().create_timer(1.5)
	q_free_timer.connect("timeout", queue_free)
