extends Control
class_name MoveJoystick

@export var max_radius: float = 40.0
@export var deadzone: float = 0.15
@export var default_offset: Vector2 = Vector2(110.0, 110.0)

@export var base_color: Color = Color(1, 1, 1, 0.2)
@export var border_color: Color = Color(1, 1, 1, 0.5)
@export var knob_color: Color = Color(1, 1, 1, 0.6)

var touch_id: int = -1
var base_pos: Vector2
var knob_offset: Vector2 = Vector2.ZERO
var is_touched: bool = false
var _original_radius: float
var _original_offset: Vector2

func _ready() -> void:
	_original_radius = max_radius
	_original_offset = default_offset
	mouse_filter = Control.MOUSE_FILTER_STOP
	base_pos = _get_default_pos()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_notification_paused()
	elif what == NOTIFICATION_RESIZED and not is_touched:
		base_pos = _get_default_pos()
		queue_redraw()

func _get_default_pos() -> Vector2:
	return Vector2(default_offset.x, size.y - default_offset.y)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			touch_id = event.index
			is_touched = true
			base_pos = event.position
			knob_offset = Vector2.ZERO
		elif not event.pressed and event.index == touch_id:
			_reset_joystick()
		queue_redraw()
	elif event is InputEventScreenDrag and event.index == touch_id:
		knob_offset = (event.position - base_pos).limit_length(max_radius)
		_apply_input(knob_offset / max_radius)
		queue_redraw()

func _draw() -> void:
	var center := base_pos if is_touched else _get_default_pos()
	draw_circle(center, max_radius, base_color)
	draw_arc(center, max_radius, 0, TAU, 32, border_color, 2.0)
	draw_circle(center + knob_offset, max_radius * 0.4, knob_color)

func _apply_input(vec: Vector2) -> void:
	var strength := clampf((vec.length() - deadzone) / (0.85 - deadzone), 0.0, 0.85) if vec.length() > deadzone else 0.0
	var norm := vec.normalized() * strength
	_set_axis("ui_left", "ui_right", norm.x)
	_set_axis("ui_up", "ui_down", norm.y)

func _set_axis(neg: StringName, pos: StringName, val: float) -> void:
	if val > 0.05:
		Input.action_press(pos, val)
		Input.action_release(neg)
	elif val < -0.05:
		Input.action_press(neg, -val)
		Input.action_release(pos)
	else:
		Input.action_release(neg)
		Input.action_release(pos)

func _reset_joystick() -> void:
	touch_id = -1
	is_touched = false
	knob_offset = Vector2.ZERO
	base_pos = _get_default_pos()
	for action in [&"ui_left", &"ui_right", &"ui_up", &"ui_down"]:
		Input.action_release(action)
	queue_redraw()

func set_control_scale(value: float) -> void:
	max_radius = _original_radius * value
	default_offset = _original_offset * value
	if is_touched:
		_reset_joystick()
	base_pos = _get_default_pos()
	queue_redraw()


func _exit_tree() -> void:
	if is_touched:
		_reset_joystick()


func _notification_paused() -> void:
	if is_touched:
		_reset_joystick()
