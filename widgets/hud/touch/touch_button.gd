extends Button
class_name TouchButton

@export var action_name: StringName = &"ui_attack"

var touch_id: int = -1


func _ready() -> void:
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			touch_id = event.index
			_send_action(true)
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			_send_action(false)


func _send_action(is_pressed: bool) -> void:
	var ev = InputEventAction.new()
	ev.action = action_name
	ev.pressed = is_pressed
	Input.parse_input_event(ev)
