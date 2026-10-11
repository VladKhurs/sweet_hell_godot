extends StaticBody2D

@export var flag_name: String = ""


func _ready() -> void:
	GameState.world_state_changed.connect(_update_state)
	_update_state()


func _update_state(_obj = "", _key = "", _value = null) -> void:
	var is_active: bool = GameState.get_world_state(flag_name, "active") == true
	visible = is_active
	$CollisionShape2D.set_deferred("disabled", not is_active)
