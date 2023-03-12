extends CharacterBody2D

const GooLeft = preload("res://scenes/player/goo_left.tscn")
const GooRight = preload("res://scenes/player/goo_right.tscn")
const GooUp = preload("res://scenes/player/goo_up.tscn")
const GooDown = preload("res://scenes/player/goo_down.tscn")

@onready var sprite = $Sprite2D
@onready var hitbox = $Hitbox
@onready var particles = $CPUParticles2D

@export var DAMAGE = 5

const SPEED : float = 200
const UP_SPEED : float = 100
const GRAVITY : float = 220

var speed : float
var disabled = false
var shooting_direction = Vector2(1, -0.5)

func _ready():
	speed = SPEED
	velocity.y = shooting_direction.y * UP_SPEED
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.15).from(Vector2.ZERO)

func _physics_process(delta):
	# stop moving after being disabled
	if disabled:
		return
	velocity.y += GRAVITY * delta
	velocity.x = shooting_direction.x * speed
	move_and_slide()

func set_orientation(orientation : Vector2):
	if orientation == Vector2.LEFT:
		shooting_direction.x = -1

func get_goo_scene(direction : Vector2) -> PackedScene:
	match direction:
		Vector2.DOWN:
			return GooDown
		Vector2.LEFT:
			return GooLeft
		Vector2.RIGHT:
			return GooRight
		Vector2.UP:
			return GooUp
	return GooRight

func spawn_goo_from_tilemap(map: TileMap):
	var pos_inside_tilemap = map.to_local(global_position)
	var standing_tile = map.local_to_map(pos_inside_tilemap)
	var surrounding_tiles = map.get_surrounding_cells(standing_tile)
	var global_pos_of_surrounding_tiles : Array = []
	
	for tile_i in surrounding_tiles:
		var tile_id = map.get_cell_source_id(0, tile_i)
		# empty tile on tilemap
		if tile_id < 0:
			continue
		var pos = map.to_global(map.map_to_local(tile_i))
		global_pos_of_surrounding_tiles.append(pos)
	
	var closest_tile : Vector2 = Vector2(99999999999999, 99999999999999) # really big vector so its always the furthestst away
	for tile in global_pos_of_surrounding_tiles:
		var distance = global_position.distance_to(tile)
		if distance < global_position.distance_to(closest_tile):
			closest_tile = tile
	
	var from_tile_to_here : Vector2 = closest_tile.direction_to(global_position)
	var is_horizontal : bool = abs(from_tile_to_here.x) > abs(from_tile_to_here.y)
	
	var goo_pos : Vector2
	var goo_direction : Vector2
	if is_horizontal:
		const tile_x_size = 16
		goo_pos = Vector2(closest_tile.x+tile_x_size*sign(from_tile_to_here.x), global_position.y)
		goo_direction = Vector2.RIGHT * sign(from_tile_to_here.x)
	else:
		const tile_y_size = 16
		goo_pos = Vector2(global_position.x, closest_tile.y+tile_y_size*sign(from_tile_to_here.y))
		goo_direction = Vector2.DOWN * sign(from_tile_to_here.y)
	
	# spawn goo
	var goo = get_goo_scene(goo_direction).instantiate()
	get_parent().call_deferred("add_child", goo)
	goo.global_position = goo_pos

func destroy():
	disabled = true
	hitbox.set_deferred("monitoring", false)
	particles.emitting = false
	sprite.hide() # play hit animation
	
	# set so bullet is queued free when particles dissipate
	var q_free_timer = get_tree().create_timer(1.5)
	q_free_timer.connect("timeout", queue_free)

func _on_hitbox_body_entered(body):
	# this is so it doesn't trigger more than once
	if disabled:
		return
	
	# dont collide with player or itself
	if body.is_in_group("player") or body.is_in_group("spit"):
		return
	
	if body is TileMap:
		spawn_goo_from_tilemap(body)
	
	destroy()

func _on_hitbox_area_entered(area):
	if area.has_method("hit"):
		area.hit(DAMAGE)
		destroy()
