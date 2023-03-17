extends Node2D

const Rock = preload("res://scenes/creatures/rock.tscn")
const RockSound = preload("res://assets/sounds/player/rocks.ogg")

const ROCK_INTERVAL = 0.3
var rock_ticker : float
var spawn_rocks : bool = false
var point_1 : Vector2
var point_2 : Vector2

func _ready():
	var markers = get_children()
	point_1 = markers[0].global_position
	point_2 = markers[1].global_position

var sound_ticker : float
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not spawn_rocks:
		return
	rock_ticker += delta
	if rock_ticker >= ROCK_INTERVAL:
		spawn_rock()
		rock_ticker = 0
	
	sound_ticker += delta
	if sound_ticker >= 0.5:
		sound_ticker = 0
		Utils.spawn_audio(RockSound, -8)

func spawn_rock():
	var x = randf_range(point_1.x, point_2.x)
	var y = point_1.y
	
	var rock = Rock.instantiate()
	add_child(rock)
	rock.global_position = Vector2(x, y)
	rock.start_falling()
	rock.show()

func stop():
	spawn_rocks = false
