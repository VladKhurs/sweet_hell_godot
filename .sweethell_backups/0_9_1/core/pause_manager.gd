extends CanvasLayer
## Global pause UI; remains active while the level's SceneTree is paused.
const MAIN_MENU := "res://widgets/menus/main_menu.tscn"
const SWEET_BUTTON := preload("res://widgets/buttons/sweet_button.gd")
var _overlay: Control
var _actions: VBoxContainer
var _confirm: VBoxContainer
var _title: Label
var _warning: Label
var _resume_button: Button
var _exit_button: Button
var _yes_button: Button
var _cancel_button: Button

func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not InputMap.has_action("pause_game"):
		InputMap.add_action("pause_game")
		var key := InputEventKey.new()
		key.keycode = KEY_ESCAPE
		InputMap.action_add_event("pause_game", key)
	_build_ui()
	SettingsManager.language_changed.connect(_refresh)
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game") and not event.is_echo():
		if _overlay.visible:
			if _confirm.visible:
				_confirm.hide()
				_actions.show()
			else:
				resume()
		elif _in_level():
			open_pause()
		get_viewport().set_input_as_handled()

func _in_level() -> bool:
	var scene := get_tree().current_scene
	return scene != null and scene.scene_file_path != MAIN_MENU

func open_pause() -> void:
	if not _in_level() or _overlay.visible:
		return
	_overlay.show()
	_confirm.hide()
	_actions.show()
	get_tree().paused = true
	_actions.get_child(1).grab_focus()

func resume() -> void:
	get_tree().paused = false
	_overlay.hide()

func _go_to_menu() -> void:
	resume()
	Game.load_level(MAIN_MENU)

func _build_ui() -> void:
	_overlay = Control.new()
	_overlay.name = "PauseOverlay"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_overlay)
	_overlay.hide()

	var shade := ColorRect.new()
	shade.color = Color(0.12, 0.055, 0.13, 0.83)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(center)

	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	container.custom_minimum_size.x = 220
	center.add_child(container)

	_actions = VBoxContainer.new()
	_actions.add_theme_constant_override("separation", 8)
	container.add_child(_actions)
	var title := Label.new()
	title.text = "ПАУЗА"
	_title = title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_actions.add_child(title)
	_resume_button = _button(_actions, "ВЕРНУТЬСЯ К ИГРЕ", resume)
	_exit_button = _button(_actions, "ВЫЙТИ В ГЛАВНОЕ МЕНЮ", _ask_exit)

	_confirm = VBoxContainer.new()
	_confirm.add_theme_constant_override("separation", 8)
	container.add_child(_confirm)
	var warning := Label.new()
	warning.text = "НЕСОХРАНЁННЫЙ ПРОГРЕСС\nБУДЕТ ПОТЕРЯН. ВЫЙТИ?"
	_warning = warning
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm.add_child(warning)
	_yes_button = _button(_confirm, "ДА, ВЫЙТИ", _go_to_menu)
	_cancel_button = _button(_confirm, "ОТМЕНА", _cancel_exit)
	_confirm.hide()

func _button(parent: Node, label: String, callback: Callable) -> Button:
	var button := SWEET_BUTTON.new() as Button
	button.text = label
	button.custom_minimum_size = Vector2(220, 27)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(button)
	button.pressed.connect(callback)
	return button

func _ask_exit() -> void:
	_actions.hide()
	_confirm.show()
	_confirm.get_child(1).grab_focus()

func _cancel_exit() -> void:
	_confirm.hide()
	_actions.show()
	_actions.get_child(1).grab_focus()

func _refresh() -> void:
	_title.text = SettingsManager.tr_key("pause")
	_resume_button.text = SettingsManager.tr_key("resume")
	_exit_button.text = SettingsManager.tr_key("exit_menu")
	_warning.text = SettingsManager.tr_key("lose_progress")
	_yes_button.text = SettingsManager.tr_key("confirm_exit")
	_cancel_button.text = SettingsManager.tr_key("cancel")
