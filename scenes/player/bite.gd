extends Area2D

@onready var animations = $AnimationPlayer

func bite():
	animations.play("bite")

func eat():
	for eatable in get_overlapping_areas():
		eatable.hit(0)

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
