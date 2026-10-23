extends Node

@onready var player = get_parent().get_parent()
@export var speed: float = 110.0
@export var penguin_speed: float = 320.0
@export var penguin_acceleration: float = 200.0
@export var penguin_friction: float = 180.0
var enabled: bool = false

func execute(delta):
	if not enabled: return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if player.is_penguin:
		var rate := penguin_acceleration if direction != Vector2.ZERO else penguin_friction
		player.velocity = player.velocity.move_toward(direction * penguin_speed, rate * delta)
	else:
		player.velocity = direction * speed

	player.move_and_slide()
