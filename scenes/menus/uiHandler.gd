extends CanvasLayer

@onready var healthBar = get_node("%uiHealthBar")
@onready var spitBar = get_node("%uiSpit")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	healthBar.max_value = Data.max_health
	healthBar.value = Data.health
	if Data.spit_enabled:
		spitBar.show()
	else:
		spitBar.hide()
