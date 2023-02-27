extends Control

@onready var corpse_sprite = get_node("%Corpse")
@onready var obscure_texture = get_node("%ObscureTexture")
@onready var death_menu = get_node("%DeathMenu")

var corpse_left : bool = false
var corpse_position : Vector2

var death_menu_offset : Vector2
const DEATH_MENU_STARTING_COLOR = Color8(255, 255, 255, 0)
const DEATH_MENU_FINAL_COLOR = Color8(255, 255, 255, 255)
const DEATH_MENU_ANIMATION_DURATION = 3 # seconds

const OBSCURE_STARTING_COLOR = Color8(25, 25, 25, 0)
const OBSCURE_FINAL_COLOR = Color8(25, 25, 25, 180)
const OBSCURE_ANIMATION_DURATION = 2 # seconds

func _ready():
	death_menu_offset = Vector2(-death_menu.size.x/2, -death_menu.size.y)

func show_death_screen():
	show()
	# setup corpse on player corpse position
	corpse_sprite.position = corpse_position
	corpse_sprite.flip_h = corpse_left
	corpse_sprite.show()
	
	# obscure screen
	obscure_texture.show()
	var tween = create_tween()
	tween.tween_property(obscure_texture, "modulate", OBSCURE_FINAL_COLOR, OBSCURE_ANIMATION_DURATION).from(OBSCURE_STARTING_COLOR)
	
	# death menu
	var final_pos = corpse_position + death_menu_offset
	var initial_pos = final_pos + Vector2(0, 20)

	tween.tween_callback(death_menu.show)
	tween.parallel().tween_property(death_menu, "position", final_pos, DEATH_MENU_ANIMATION_DURATION).from(initial_pos)
	tween.parallel().tween_property(death_menu, "modulate", DEATH_MENU_FINAL_COLOR, DEATH_MENU_ANIMATION_DURATION).from(DEATH_MENU_STARTING_COLOR)

func hide_death_screen():
	hide()
	obscure_texture.hide()
	corpse_sprite.hide()
	death_menu.hide()
