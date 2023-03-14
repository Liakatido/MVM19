extends Node2D

@onready var bone_particles : CPUParticles2D = $BoneParticles
@onready var dust_particles : CPUParticles2D = $DustParticles
@onready var sprite = $Sprite2D

const SPEED = 100

var direction : Vector2 = Vector2.RIGHT
var can_move : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().create_timer(10).connect("timeout", queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if can_move:
		global_position += direction*SPEED*delta

func start(direction : Vector2):
	if direction == Vector2.LEFT:
		sprite.flip_h = true
		bone_particles.position.x *= -1
		dust_particles.position.x *= -1
		bone_particles.direction.x *= -1
		dust_particles.direction.x *= -1
	can_move = true
