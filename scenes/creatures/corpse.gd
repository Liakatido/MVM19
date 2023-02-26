extends CharacterBody2D

@onready var hitbox = $Hitbox
@onready var particles = $CPUParticles2D
@onready var sprite = $Sprite2D

@export var kind : Kind

var disabled : bool = false

enum Kind {
	NORMAL,
	CHARGE,
	SPIT,
	TAIL,
	MAX_HEALTH,
	MAX_AMMO,
}

const GRAVITY = 500

func _ready():
	hitbox.connect("got_hit", get_eaten)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

func get_eaten(_damage):
	if disabled:
		return
	
	match kind:
		Kind.NORMAL:
			# heal, refill some ammo
			pass
	
	destroy()

func destroy():
	sprite.hide()
	particles.restart()
	particles.emitting = true
	var destroy_timer = get_tree().create_timer(1)
	destroy_timer.connect("timeout", queue_free)

