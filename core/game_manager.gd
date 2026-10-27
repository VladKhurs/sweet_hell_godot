extends Node

signal health_changed(new_health: int)
signal player_damaged
signal invulnerability_ended

var max_health: int = 3
var current_health: int = 3
var invulnerability_time: float = 1.0
var is_invulnerable: bool = false
var fade_layer: ColorRect

func _ready() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	fade_layer = ColorRect.new()
	fade_layer.color = Color(0, 0, 0, 0)
	fade_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fade_layer)

func take_damage(amount: int) -> bool:
	if is_invulnerable or current_health <= 0:
		return false

	is_invulnerable = true
	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health)
	player_damaged.emit()

	if current_health <= 0:
		restart_game.call_deferred()
	else:
		get_tree().create_timer(invulnerability_time).timeout.connect(func():
			is_invulnerable = false
			invulnerability_ended.emit()
		)
	return true

func restart_game() -> void:
	if SaveManager.restore_game():
		return
	current_health = max_health
	is_invulnerable = false
	if GameState.request_checkpoint_respawn():
		if get_tree().change_scene_to_file(GameState.checkpoint_level_path) == OK:
			return
		GameState.resume_at_checkpoint = false
	get_tree().reload_current_scene()

func _fade(target_alpha: float, duration: float = 0.3) -> Signal:
	var tween := create_tween()
	tween.tween_property(fade_layer, "color:a", target_alpha, duration)
	return tween.finished

func load_level(path: String) -> void:
	await _fade(1.0)
	if get_tree().change_scene_to_file(path) != OK:
		push_error("Не удалось загрузить уровень: " + path)
		is_invulnerable = false
		_fade(0.0)
		return
	await get_tree().process_frame
	is_invulnerable = false
	await _fade(0.0)
