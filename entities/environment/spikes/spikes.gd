extends Area2D

var player_inside: Node2D = null

func _ready() -> void:
	body_entered.connect(func(b):
		if b.name == "Player":
			player_inside = b
			_try_damage()
	)
	body_exited.connect(func(b):
		if b == player_inside:
			player_inside = null
	)
	Game.invulnerability_ended.connect(_try_damage)

func _try_damage() -> void:
	if is_instance_valid(player_inside) and Game.take_damage(1):
		var dir := (player_inside.global_position - global_position).normalized()
		player_inside.knockback(dir)
		
