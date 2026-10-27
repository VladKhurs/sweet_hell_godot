extends CharacterBody2D

@onready var movements: Node = $Movements
@onready var camera: Camera2D = $Camera2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var penguin_shape: CollisionShape2D = $PenguinShape
@onready var hud: CanvasLayer = get_tree().root.find_child("HUD", true, false)
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_sprite: Sprite2D = $WeaponPivot/WeaponSprite
@onready var human_sprite_offset: Vector2 = anim.offset
@onready var human_sprite_position: Vector2 = anim.position
@onready var penguin_shape_rest_rotation: float = penguin_shape.rotation

@export var penguin_sprite_offset: Vector2 = Vector2.ZERO
@export var penguin_turn_speed: float = 16.0
@export var attack_visual_time: float = 0.12
@export var attack_recoil_x: float = 100.0
@export var attack_recoil_y: float = -40.0

var is_penguin: bool = false
var penguin_rotating: bool = false
var current_movement: Node = null
var controls_enabled: bool = true
var last_attack_time: float = -INF
var facing_direction: float = 1.0
var weapon_tween: Tween

func _ready() -> void:
	Inventory.changed.connect(_update_attack_area)
	Game.player_damaged.connect(_on_damaged)
	change_movement_mode(GameState.current_mode)
	if GameState.is_penguin:
		set_penguin(true, true)
	_update_attack_area()

func _physics_process(delta: float) -> void:
	if controls_enabled and current_movement:
		current_movement.execute(delta)
	_update_penguin_rotation(delta)

func _process(_delta: float) -> void:
	_update_animations()
	if hud:
		hud.set_interaction_visible(has_interactable_nearby())

func _input(event: InputEvent) -> void:
	if not controls_enabled: return
	if event.is_action_pressed("ui_interact"):
		check_interaction()
	elif event.is_action_pressed("ui_attack"):
		attack()
	elif event.is_action_pressed("transform"):
		set_penguin(not is_penguin)

func set_controls_enabled(value: bool) -> void:
	controls_enabled = value
	if not controls_enabled:
		velocity = Vector2.ZERO
		if current_movement and current_movement.has_method("stop_movement"):
			current_movement.stop_movement()

func change_movement_mode(mode_name: String) -> void:
	for child in movements.get_children():
		child.enabled = false

	var target = movements.get_node_or_null(mode_name)
	if target:
		current_movement = target
		current_movement.enabled = true
		GameState.set_mode(mode_name)
		velocity = Vector2.ZERO
		if (mode_name == "grid" or mode_name == "beat") and current_movement.has_method("snap_to_grid_center"):
			current_movement.snap_to_grid_center()

	if is_penguin and not can_be_penguin():
		set_penguin(false, true)

	var target_offset := -10.0 if mode_name == "platformer" else 0.0
	create_tween().tween_property(camera, "offset:y", target_offset, 0.3).set_ease(Tween.EASE_OUT)

func can_be_penguin() -> bool:
	return GameState.current_mode == &"free" or GameState.current_mode == &"platformer"

func set_penguin(value: bool, force: bool = false) -> void:
	if value == is_penguin: return
	if value and not can_be_penguin(): return

	var new_shape := penguin_shape if value else body_shape
	if not force and not _has_room(new_shape): return

	is_penguin = value
	GameState.is_penguin = value
	body_shape.set_deferred("disabled", value)
	penguin_shape.set_deferred("disabled", not value)
	anim.offset = penguin_sprite_offset if value else human_sprite_offset

func _has_room(shape_node: CollisionShape2D) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform.translated(Vector2(0.0, -0.5))
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func _update_penguin_rotation(delta: float) -> void:
	var active := is_penguin and current_movement != null and current_movement.name == "free"

	if not active:
		if penguin_rotating:
			penguin_rotating = false
			anim.rotation = 0.0
			penguin_shape.rotation = penguin_shape_rest_rotation
			anim.position = human_sprite_position
			anim.offset = penguin_sprite_offset if is_penguin else human_sprite_offset
		return

	penguin_rotating = true
	if velocity.length() > 10.0:
		anim.rotation = rotate_toward(anim.rotation, velocity.angle(), penguin_turn_speed * delta)
	penguin_shape.rotation = anim.rotation + penguin_shape_rest_rotation
	anim.position = penguin_shape.position
	anim.offset = penguin_sprite_offset - (penguin_shape.position - human_sprite_position) / anim.scale

func check_interaction() -> void:
	var closest: Node2D = null
	var closest_dist := INF
	var items = interaction_area.get_overlapping_bodies() + interaction_area.get_overlapping_areas()

	for item in items:
		if item.has_method("interact"):
			var d := global_position.distance_squared_to(item.global_position)
			if d < closest_dist:
				closest = item
				closest_dist = d

	if closest:
		closest.interact(self)

func has_interactable_nearby() -> bool:
	for item in (interaction_area.get_overlapping_bodies() + interaction_area.get_overlapping_areas()):
		if item.has_method("interact"):
			return true
	return false

func knockback(direction: Vector2) -> void:
	velocity = direction * 150.0
	move_and_slide()

func set_horizontal_facing(dir: float) -> void:
	if is_zero_approx(dir): return
	facing_direction = signf(dir)
	anim.flip_h = facing_direction < 0.0
	_update_attack_area()

func _play(anim_name: String, fallback: String = "idle") -> void:
	var prefix := "penguin_" if is_penguin else ""
	if anim.sprite_frames.has_animation(prefix + anim_name):
		anim.play(prefix + anim_name)
	else:
		anim.play(prefix + fallback)

func _update_animations() -> void:
	if is_penguin and current_movement and current_movement.name == "free":
		anim.flip_h = false
		if velocity.length() > 10.0:
			_play("slide", "walk")
		else:
			_play("slide_idle", "idle")
		return

	if current_movement and current_movement.name == "platformer" and not is_on_floor():
		_play("jump", "walk")
		return

	if velocity.length() > 10.0:
		if current_movement and current_movement.name == "platformer":
			_play("walk")
		else:
			if absf(velocity.y) > absf(velocity.x):
				anim.flip_h = false
				if velocity.y > 0.0:
					_play("bottom", "walk")
				else:
					_play("top", "walk")
			else:
				set_horizontal_facing(velocity.x)
				_play("walk")
	else:
		_play("idle")

func _on_damaged() -> void:
	anim.modulate = Color.RED
	create_tween().tween_property(anim, "modulate", Color.WHITE, 0.2)

func _update_attack_area() -> void:
	var weapon := Inventory.get_equipped_weapon()
	if not weapon: return

	var shape := attack_shape.shape as CircleShape2D
	if shape:
		shape.radius = weapon.attack_range * 0.5
	attack_area.position.x = weapon.attack_range * 0.5 * facing_direction

func attack() -> void:
	if GameState.current_mode != &"platformer": return
	var weapon := Inventory.get_equipped_weapon()
	if not weapon: return

	var now := Time.get_ticks_msec() / 1000.0
	if now - last_attack_time < weapon.attack_cooldown: return
	last_attack_time = now

	_play_attack_visual(weapon)
	
	var hit: bool = false
	for body in attack_area.get_overlapping_bodies():
		if body == self:
			continue
		
		if body.has_method("take_damage"):
			body.take_damage(weapon.damage)
			if body.has_method("knockback"):
				body.knockback((body.global_position - global_position).normalized())
			hit = true
		elif body is StaticBody2D or body is TileMap or body is TileMapLayer:
			hit = true

	if hit:
		velocity.x = -facing_direction * attack_recoil_x
		velocity.y = attack_recoil_y
		move_and_slide()


func _play_attack_visual(weapon: WeaponData) -> void:
	if weapon_tween and weapon_tween.is_valid():
		weapon_tween.kill()

	weapon_sprite.texture = weapon.sprite
	weapon_sprite.visible = true
	weapon_pivot.scale.x = facing_direction
	weapon_pivot.rotation_degrees = -60.0 * facing_direction

	weapon_tween = create_tween()
	weapon_tween.tween_property(weapon_pivot, "rotation_degrees", 45.0 * facing_direction, attack_visual_time)
	weapon_tween.tween_callback(func():
		weapon_sprite.visible = false
		weapon_pivot.rotation_degrees = 0.0
	)
