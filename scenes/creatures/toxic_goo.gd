extends StaticBody2D

const Sound = preload("res://assets/sounds/player/spit.ogg")
const Particles = preload("res://scenes/player/goo_particles.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Hitbox").connect("got_hit", destroy)


func destroy(_damage, _direction):
	Utils.spawn_audio(Sound, -13)
	var particles = Particles.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	queue_free()
