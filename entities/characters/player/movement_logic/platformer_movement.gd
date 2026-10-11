extends Node

@onready var player: CharacterBody2D = get_parent().get_parent()

@export var speed: float = 120.0
@export var acceleration: float = 1000.0
@export var friction: float = 1200.0

@export var jump_velocity: float = -215.0
@export var gravity: float = 600.0
@export var fall_gravity_multiplier: float = 1.1
@export var max_fall_speed: float = 360.0

@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10
@export var jump_cut: float = 0.38

var enabled: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func execute(delta: float) -> void:
	if not enabled: return

	coyote_timer = coyote_time if player.is_on_floor() else maxf(coyote_timer - delta, 0.0)
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		player.velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
	elif Input.is_action_just_released("ui_accept") and player.velocity.y < 0.0:
		player.velocity.y *= jump_cut

	if not player.is_on_floor():
		var cur_gravity := gravity * (fall_gravity_multiplier if player.velocity.y > 0.0 else 1.0)
		player.velocity.y = minf(player.velocity.y + cur_gravity * delta, max_fall_speed)

	var dir := Input.get_axis("ui_left", "ui_right")
	if dir != 0.0:
		player.velocity.x = move_toward(player.velocity.x, dir * speed, acceleration * delta)
		player.set_horizontal_facing(dir)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, friction * delta)

	player.move_and_slide()
	
