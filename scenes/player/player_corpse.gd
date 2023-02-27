extends CharacterBody2D


const GRAVITY = 400


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	
	velocity.x = move_toward(velocity.x, 0, delta*2)

	move_and_slide()
