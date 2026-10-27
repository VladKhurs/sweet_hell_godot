extends CanvasLayer

@onready var hearts_container: HBoxContainer = $HBoxContainer
@onready var dialogue_box: Control = $DialogueBox
@onready var dialogue_label: Label = $DialogueBox/DialogueLabel
@onready var interaction_label: Control = $InteractionLabel
@onready var touch_controls: Control = $TouchControls
@onready var toggle_button: Button = $ToggleTouchButton

func _ready() -> void:
	Game.health_changed.connect(update_hearts)
	update_hearts(Game.current_health)
	if toggle_button:
		toggle_button.pressed.connect(func(): touch_controls.visible = not touch_controls.visible)
	if touch_controls:
		touch_controls.visible = true

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
	
