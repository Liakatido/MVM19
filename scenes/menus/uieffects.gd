extends Control

@onready var flash_texture = $FlashTexture

const TRANSPARENT = Color(1, 1, 1, 0)
const WHITE = Color(0.9, 0.9, 0.9, 1)

const FLASH_DURATION = 1.0 # seconds

func _ready():
	Utils.flash_ui = self

func flash_screen():
	var tween = create_tween()
	tween.tween_property(flash_texture, "modulate", TRANSPARENT, FLASH_DURATION).from(WHITE)
