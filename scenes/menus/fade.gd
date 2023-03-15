extends CanvasLayer

@onready var texture = $TextureRect

@export var fade_time : float

func start_fade(callbacks : Array[Callable]):
	var w : float = ProjectSettings.get("display/window/size/viewport_width")
	var h : float = ProjectSettings.get("display/window/size/viewport_height")
	var background_color : Color = ProjectSettings.get("rendering/environment/defaults/default_clear_color")
	texture.size = Vector2(3*w, h)
	texture.position = Vector2(-3*w, 0)
	texture.modulate = background_color
	texture.show()
	
	var tween = create_tween()
	tween.tween_property(texture, "position", Vector2(-1*w,0), fade_time)
	for cback in callbacks:
		tween.tween_callback(cback)

func end_fade():
	var w : float = ProjectSettings.get("display/window/size/viewport_width")

	var tween = create_tween()
	tween.tween_property(texture, "position", Vector2(w,0), fade_time)
	tween.tween_callback(texture.hide)
