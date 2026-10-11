extends Area2D

@export_file("*.tscn") var target_level_path: String
@export var control_lock_delay: float = 0.05
var changing_level: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if changing_level or body.name != "Player" or target_level_path.is_empty():
		return

	changing_level = true
	set_deferred("monitoring", false)
	Game.load_level(target_level_path)

	await get_tree().create_timer(control_lock_delay).timeout
	if is_instance_valid(body) and body.has_method("set_controls_enabled"):
		body.set_controls_enabled(false)
		
