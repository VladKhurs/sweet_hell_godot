extends CharacterBody2D

@onready var movements: Node = $Movements
@onready var camera: Camera2D = $Camera2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hud: CanvasLayer = get_tree().root.find_child("HUD", true, false)
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_sprite: Sprite2D = $WeaponPivot/WeaponSprite

@export var attack_visual_time: float = 0.12
@export var attack_recoil_force: float = 120.0
@export var attack_recoil_x: float = 100.0
@export var attack_recoil_y: float = -40.0

var current_movement: Node = null
var controls_enabled: bool = true
var last_attack_time: float = -INF
var facing_direction: float = 1.0
var weapon_tween: Tween

func _ready() -> void:
	Inventory.changed.connect(_update_attack_area)
	Game.player_damaged.connect(_on_damaged)
	change_movement_mode(GameState.current_mode)
	_update_attack_area()

func _physics_process(delta: float) -> void:
	if controls_enabled and current_movement:
		current_movement.execute(delta)

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

	var target_offset := -15.0 if mode_name == "platformer" else 0.0
	create_tween().tween_property(camera, "offset:y", target_offset, 0.3).set_ease(Tween.EASE_OUT)

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

func _update_animations() -> void:
	if current_movement and current_movement.name == "platformer" and not is_on_floor():
		anim.play("jump")
		return

	if velocity.length() > 10.0:
		# Если режим платформера — ходьба только влево/вправо
		if current_movement and current_movement.name == "platformer":
			anim.play("walk")
		else:
			# В свободном режиме определяем преобладающую ось движения:
			if absf(velocity.y) > absf(velocity.x):
				anim.flip_h = false
				if velocity.y > 0.0:
					anim.play("bottom")
				else:
					anim.play("top")
			else:
				set_horizontal_facing(velocity.x)
				anim.play("walk")
	else:
		anim.play("idle")

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

	if hit:
		velocity.x = -facing_direction * attack_recoil_force
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
	
