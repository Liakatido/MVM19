extends Node

var game
var flash_ui

const DEFAULT_STRENGTH = 10
const max_shake_per_frame = 10
var shake_queue = []
var camera : Camera2D


func _process(_delta):
	var i = 0
	while i != max_shake_per_frame and len(shake_queue) != 0:
		i += 1
		_shake(shake_queue.pop_front())

func shake(strength : int = DEFAULT_STRENGTH):
	shake_queue.append(strength)

func _shake(strength : int = DEFAULT_STRENGTH):
	var tween = camera.create_tween()
	
	var x_dir = randf() * 2 - 1
	var y_dir = randf() * 2 - 1
	
	var camera_origin = Vector2.ZERO
	var camera_shake = camera_origin + Vector2(x_dir, y_dir) * strength
	var inv_camera_shake = camera_origin - Vector2(x_dir, y_dir) * (strength/2)
	
	tween.tween_property(camera, "position", camera_origin, 0.1).from(camera_shake)
	tween.tween_property(camera, "position", camera_origin, 0.05).from(inv_camera_shake)

func spawn_audio(sound, db, pitch=1.0):
	game.spawn_audio(sound, db, pitch)

func play_song(song):
	game.play_song(song)

func flash_screen():
	flash_ui.flash_screen()

func frame_freeze(time_scale, duration):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0
