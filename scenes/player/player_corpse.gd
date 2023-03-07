extends CharacterBody2D


const GRAVITY = 400

var death_signal_sent : bool = false


func _physics_process(delta):
	if velocity == Vector2.ZERO and not death_signal_sent:
		death_signal_sent = true
		show_death_screen()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	velocity.x += -velocity.x/10
	velocity.x = move_toward(velocity.x, 0, delta*10)

	move_and_slide()

func show_death_screen():
	var pos = get_global_transform_with_canvas().get_origin() + Vector2(0, -16)
	var is_left = scale.x == -1
	Utils.game.show_death_screen(pos, is_left)
