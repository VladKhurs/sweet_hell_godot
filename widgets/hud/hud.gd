extends CanvasLayer

@onready var hearts_container: HBoxContainer = $HBoxContainer
@onready var dialogue_box: Control = $DialogueBox
@onready var dialogue_label: Label = $DialogueBox/DialogueLabel
@onready var interaction_label: Control = $InteractionLabel
@onready var touch_controls: Control = $TouchControls
@onready var toggle_button: Button = $ToggleTouchButton
@onready var action_buttons: Control = $TouchControls/ActionButtons
@onready var joystick: MoveJoystick = $TouchControls/MoveJoystick
@onready var pause_button: Button = $TouchControls/PauseButton

func _ready() -> void:
	Game.health_changed.connect(update_hearts)
	update_hearts(Game.current_health)
	# Always visible in Web exports, even in desktop browsers.
	# Hidden in native desktop exports, even with a touch screen connected.
	touch_controls.visible = TouchPlatform.is_enabled()
	touch_controls.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	toggle_button.hide()
	if touch_controls.visible:
		SettingsManager.touch_settings_changed.connect(_apply_touch_settings)
		SettingsManager.language_changed.connect(_update_touch_labels)
		_apply_touch_settings()
		_update_touch_labels()

func update_hearts(health: int) -> void:
	var hearts := hearts_container.get_children()
	for i in hearts.size():
		hearts[i].visible = i < health

func show_message(text: String) -> void:
	dialogue_label.text = text
	dialogue_box.show()
	await get_tree().create_timer(3.0).timeout
	dialogue_box.hide()

func set_interaction_visible(value: bool) -> void:
	interaction_label.visible = value
	

func _apply_touch_settings() -> void:
	var scale_value := SettingsManager.touch_scale
	touch_controls.modulate.a = SettingsManager.touch_opacity
	action_buttons.pivot_offset = action_buttons.size
	action_buttons.scale = Vector2.ONE * scale_value
	pause_button.pivot_offset = Vector2.ZERO
	pause_button.scale = Vector2.ONE * scale_value
	joystick.set_control_scale(scale_value)


func _update_touch_labels() -> void:
	$TouchControls/ActionButtons/AttackButton.text = SettingsManager.tr_key("touch_attack")
	$TouchControls/ActionButtons/JumpButton.text = SettingsManager.tr_key("touch_jump")
