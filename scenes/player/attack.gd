extends Area2D

@onready var animations = $AnimationPlayer
@onready var sprite = $Sprite2D

func do_attack(orientation : Vector2):
	# animate
	animations.play("attack")
	
	# attack orientation
	if orientation == Vector2.LEFT:
		sprite.flip_h = true
	
	# damage enmies inside
	
	# setup destroying the object
	animations.connect("animation_finished", clear_object)

func clear_object(_animation):
	queue_free()
