extends Node
class_name GridMovement

@onready var player: CharacterBody2D = get_parent().get_parent()
@onready var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

@export var tile_size: int = 8
@export var move_speed: float = 0.15
@export var cell_center_offset: Vector2 = Vector2(4, 4)

var is_moving: bool = false
var enabled: bool = false
var move_tween: Tween

func execute(_delta: float) -> void:
	if not enabled or is_moving: return

	var dir := Vector2.ZERO
	if Input.is_action_just_pressed("ui_right"): dir = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_left"): dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_up"): dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"): dir = Vector2.DOWN

	if dir != Vector2.ZERO:
		if dir.x != 0:
			sprite.flip_h = dir.x < 0
		attempt_move(dir)

func snap_to_grid_center() -> void:
	var size := float(tile_size)
	player.global_position = Vector2(
		round((player.global_position.x - cell_center_offset.x) / size) * size + cell_center_offset.x,
		round((player.global_position.y - cell_center_offset.y) / size) * size + cell_center_offset.y
	)
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()

func attempt_move(dir: Vector2) -> void:
	if player.test_move(player.global_transform, dir * tile_size):
		shake_sprite()
		return

	is_moving = true
	move_tween = get_tree().create_tween()
	move_tween.tween_property(player, "global_position", player.global_position + dir * tile_size, move_speed)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	move_tween.parallel().tween_property(sprite, "scale", Vector2(0.5, 0.45), move_speed * 0.5)
	move_tween.chain().tween_property(sprite, "scale", Vector2(0.5, 0.5), move_speed * 0.5)
	move_tween.finished.connect(func(): is_moving = false)

func shake_sprite() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(sprite, "position:x", 5.0, 0.05)
	tween.tween_property(sprite, "position:x", -5.0, 0.05)
	tween.tween_property(sprite, "position:x", 0.0, 0.05)

func stop_movement() -> void:
	if move_tween and move_tween.is_valid():
		move_tween.kill()
	is_moving = false
	player.velocity = Vector2.ZERO
	
