extends Node
class_name PlayerFeedback

## Optional sounds: replace individual .wav resources through the Inspector.
@export_category("Sound Effects")
@export var jump_sound: AudioStream
@export var land_sound: AudioStream
@export var attack_sound: AudioStream
@export var hit_sound: AudioStream
@export var hurt_sound: AudioStream
@export var transform_sound: AudioStream

@export_category("Visual Feedback")
@export_range(0.0, 3.0, 1.0) var camera_shake_pixels: float = 1.0


@onready var _player: CharacterBody2D = get_parent()
@onready var _camera: Camera2D = $"../Camera2D"
@onready var _move_audio: AudioStreamPlayer = $MoveAudio
@onready var _action_audio: AudioStreamPlayer = $ActionAudio
@onready var _impact_audio: AudioStreamPlayer = $ImpactAudio

var _shake_tween: Tween

func on_jump() -> void:
	_play(_move_audio, jump_sound)

func on_land() -> void:
	_play(_move_audio, land_sound)

func on_attack() -> void:
	_play(_action_audio, attack_sound)

func on_hit(at: Vector2) -> void:
	_play(_impact_audio, hit_sound)
	_shake()

func on_hurt() -> void:
	_play(_impact_audio, hurt_sound)
	_shake()

func on_transform() -> void:
	_play(_action_audio, transform_sound)

func _play(player: AudioStreamPlayer, stream: AudioStream) -> void:
	if stream == null:
		return
	player.stream = stream
	player.play()

func _shake() -> void:
	if camera_shake_pixels <= 0.0:
		return

	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()

	_camera.offset.x = camera_shake_pixels

	_shake_tween = create_tween()
	_shake_tween.tween_property(_camera, "offset:x", -camera_shake_pixels, 0.06)
	_shake_tween.tween_property(_camera, "offset:x", camera_shake_pixels, 0.06)
	_shake_tween.tween_property(_camera, "offset:x", 0.0, 0.06)
