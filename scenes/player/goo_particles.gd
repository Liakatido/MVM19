extends CPUParticles2D

func _ready():
	restart()
	emitting = true


func _on_timer_timeout():
	queue_free()
