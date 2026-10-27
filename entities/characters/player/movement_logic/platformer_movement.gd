extends Node

@onready var player: CharacterBody2D = get_parent().get_parent()

@export var speed: float = 120.0
@export var acceleration: float = 700.0
@export var friction: float =  1000.0

@export var penguin_speed: float = 320.0
@export var penguin_acceleration: float = 225.0
@export var penguin_friction: float = 200.0

@export var jump_velocity: float = -185.0
@export var penguin_jump_velocity: float = -130.0
@export var gravity: float = 700.0
@export var fall_multiplier: float = 1.5
@export var max_fall_speed: float = 380.0

@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export_range(0.1, 1.0, 0.05) var jump_release_multiplier: float = 0.65

var enabled: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func execute(delta: float) -> void:
	if not enabled: return

	var is_penguin: bool = player.is_penguin

	coyote_timer = coyote_time if player.is_on_floor() else maxf(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		player.velocity.y = penguin_jump_velocity if is_penguin else jump_velocity
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		player.feedback.on_jump()

	if Input.is_action_just_released("jump") and player.velocity.y < 0.0:
		player.velocity.y *= jump_release_multiplier

	if not player.is_on_floor():
		var current_gravity := gravity * fall_multiplier if player.velocity.y > 0.0 else gravity
		player.velocity.y = minf(player.velocity.y + current_gravity * delta, max_fall_speed)

	var max_speed := penguin_speed if is_penguin else speed
	var accel := penguin_acceleration if is_penguin else acceleration
	var slow_down := penguin_friction if is_penguin else friction

	var dir := Input.get_axis("ui_left", "ui_right")
	if dir != 0.0:
		player.velocity.x = move_toward(player.velocity.x, dir * max_speed, accel * delta)
		player.set_horizontal_facing(dir)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, slow_down * delta)

	var was_on_floor := player.is_on_floor()
	var falling_speed := player.velocity.y
	player.move_and_slide()
	if not was_on_floor and player.is_on_floor() and falling_speed > 90.0:
		player.feedback.on_land()
