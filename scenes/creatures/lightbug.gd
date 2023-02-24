extends CharacterBody2D
var moveTo = Vector2()
var idleTicker = 120
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if idleTicker < 120:
		idleTicker += 1
	else:
		moveTo.x = rng.randf_range(-1, 1) * 10
		moveTo.y = rng.randf_range(-1, 1) * 10
		velocity = moveTo
		idleTicker = 0
	move_and_slide()
