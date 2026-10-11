extends CharacterBody2D
class_name BaseEnemy

enum State { PATROL, CHASE }

@export_category("Enemy")
@export var enemy_id: StringName
@export var enemy_name: String = ""
@export var enemy_sprite: Texture2D

@export_category("Stats")
@export var speed: float = 30.0
@export var max_health: int = 3
@export var damage: int = 1
@export var gravity: float = 600.0

@export_category("Chase")
@export var chase_stop_distance: float = 8.0

@export_category("Loot")
@export var loot: Array[PackedScene] = []

@export_category("Knockback")
@export var knockback_force: float = 90.0
@export var knockback_upward_force: float = 40.0
@export var knockback_time: float = 0.15

@onready var sprite: Sprite2D = $Sprite2D
@onready var floor_check: ShapeCast2D = $FloorCheck
@onready var detection_area: Area2D = $DetectionArea
@onready var damage_area: Area2D = $DamageArea

var player_in_damage_area: Node2D = null
var current_health: int
var state: State = State.PATROL
var move_direction: float = 1.0
var target: Node2D = null
var is_dead: bool = false
var is_knocked_back: bool = false

func _ready() -> void:
	current_health = max_health
	sprite.texture = enemy_sprite
	detection_area.body_entered.connect(func(b): if b.is_in_group("player"): target = b; state = State.CHASE)
	detection_area.body_exited.connect(func(b): if b == target: target = null; state = State.PATROL)
	damage_area.body_entered.connect(_on_damage_body_entered)
	damage_area.body_exited.connect(func(b): if b == player_in_damage_area: player_in_damage_area = null)
	Game.invulnerability_ended.connect(_try_damage_player)

func _physics_process(delta: float) -> void:
	if GameState.current_mode != &"platformer":
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_knocked_back:
		move_and_slide()
		return

	match state:
		State.PATROL:
			if not _has_floor_ahead(move_direction) or is_on_wall():
				_set_direction(-move_direction)
			velocity.x = move_direction * speed

		State.CHASE:
			if not is_instance_valid(target):
				state = State.PATROL
			else:
				var dx := target.global_position.x - global_position.x
				if absf(dx) <= chase_stop_distance:
					velocity.x = 0.0
				else:
					var dir := signf(dx)
					_set_direction(dir)
					velocity.x = (dir * speed) if _has_floor_ahead(dir) else 0.0

	move_and_slide()

func _has_floor_ahead(dir: float) -> bool:
	floor_check.position.x = absf(floor_check.position.x) * dir
	floor_check.force_shapecast_update()
	return floor_check.is_colliding()

func _set_direction(dir: float) -> void:
	if is_zero_approx(dir): return
	move_direction = dir
	sprite.flip_h = dir < 0.0

func take_damage(amount: int) -> void:
	if is_dead or amount <= 0: return
	current_health = maxi(current_health - amount, 0)
	if current_health <= 0:
		die()

func die() -> void:
	if is_dead: return
	is_dead = true
	for loot_scene in loot:
		if loot_scene:
			var item = loot_scene.instantiate()
			get_parent().add_child(item)
			if item is Node2D:
				item.global_position = global_position
	queue_free()

func _on_damage_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_damage_area = body
		_try_damage_player()

func _try_damage_player() -> void:
	if not is_instance_valid(player_in_damage_area): return
	if Game.take_damage(damage):
		var dir := signf(player_in_damage_area.global_position.x - global_position.x)
		player_in_damage_area.knockback(Vector2(dir, -0.25).normalized())

func knockback(direction: Vector2) -> void:
	if is_dead: return
	is_knocked_back = true
	velocity = Vector2(direction.x * knockback_force, -knockback_upward_force)
	get_tree().create_timer(knockback_time).timeout.connect(func(): is_knocked_back = false)
	
