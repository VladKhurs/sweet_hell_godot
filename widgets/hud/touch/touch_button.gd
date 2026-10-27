extends Button
class_name TouchButton

@export var action_name: StringName = &"ui_accept"

var touch_id: int = -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			touch_id = event.index
			_send_action(true)
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			_send_action(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED and touch_id != -1:
		touch_id = -1
		_send_action(false)

func _exit_tree() -> void:
	if touch_id != -1:
		touch_id = -1
		_send_action(false)

func _send_action(is_pressed: bool) -> void:
	if is_pressed:
		Input.action_press(action_name)
	else:
		Input.action_release(action_name)

	var ev := InputEventAction.new()
	ev.action = action_name
	ev.pressed = is_pressed
	Input.parse_input_event(ev)
