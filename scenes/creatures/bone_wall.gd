extends Node2D

signal destroyed

const CrashSound = preload("res://assets/sounds/player/crash.ogg")

@onready var sprite : Sprite2D = $Mask/Sprite2D
@onready var damage1 : Sprite2D = $Mask/Damage1
@onready var damage2 : Sprite2D = $Mask/Damage2
@onready var damage3 : Sprite2D = $Mask/Damage3

@onready var bone_particles : CPUParticles2D = $BoneParticles
@onready var dust_particles : CPUParticles2D = $DustParticles

@onready var breakable_area = $BreakableTile

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.position.y += 64
	damage1.position.y += 64
	
	breakable_area.connect("broken", damaged)

var damage_counter : int = 0
func damaged(_x, _y):
	Utils.spawn_audio(CrashSound, -10)
	damage_counter += 1
	if damage_counter == 1:
		damage2.show()
		breakable_area.already_broken = false
	if damage_counter == 2:
		damage3.show()
		breakable_area.already_broken = false
	if damage_counter > 2:
		destroy()

func destroy():
	emit_signal("destroyed")
	queue_free()


func rise():
	var tween = create_tween()
	start_particles()
	tween.tween_property(sprite, "position", Vector2(0, 0), 0.5)
	tween.parallel().tween_property(damage1, "position", Vector2(0, 0), 0.5)
	tween.tween_callback(stop_particles)
	

func start_particles():
	bone_particles.restart()
	dust_particles.restart()
	bone_particles.emitting = true
	dust_particles.emitting = true

func stop_particles():
	bone_particles.emitting = false
	dust_particles.emitting = false
