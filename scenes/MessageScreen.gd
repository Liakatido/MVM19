extends CanvasLayer

var active : bool = false
var can_be_closed : bool = false

func _unhandled_input(event):
	if any_key_presed(event) and active and can_be_closed:
		get_node("PanelContainer").hide()
		get_parent().resume()
		active = false

func any_key_presed(event) -> bool:
	return event.is_action_pressed("down") or event.is_action_pressed("left") or event.is_action_pressed("right") or event.is_action_pressed("attack") or event.is_action_pressed("jump") or event.is_action_pressed("dash") or event.is_action_pressed("interact") 

func show_message(message):
	can_be_closed = false
	get_node("PanelContainer/Label").text = message
	get_parent().pause()
	active = true
	get_node("PanelContainer").show()
	var tween = create_tween()
	tween.tween_property(get_node("PanelContainer"), "scale", Vector2(1, 1), 0.25).from(Vector2.ZERO)
	tween.tween_callback(allow_to_close)

func allow_to_close():
	can_be_closed = true
