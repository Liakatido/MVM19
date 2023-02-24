extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Hitbox").connect("got_hit", destroy)


func destroy(_damage):
	queue_free()
