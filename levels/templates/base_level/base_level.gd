extends Node2D

@export_enum("free", "grid", "beat", "platformer") var level_mode: String = "free"

const PLAYER_SCENE = preload("res://entities/characters/player/player.tscn")

func _ready():
	GameState.set_location(scene_file_path)	
	setup_level()

func _enter_tree() -> void:
	GameState.set_mode(level_mode)

func setup_level():
	var player = get_tree().root.find_child("Player", true, false)
	
	if not player:
		player = PLAYER_SCENE.instantiate()
		add_child(player)
	
	var spawn_point = get_node_or_null("SpawnPoint")
	if spawn_point:
		player.global_position = spawn_point.global_position

	var respawn_id: String = GameState.take_checkpoint_respawn(scene_file_path)
	if not respawn_id.is_empty():
		var checkpoint := _find_checkpoint(respawn_id)
		if checkpoint != null:
			var marker := checkpoint.get_node_or_null("SpawnMarker") as Marker2D
			if marker:
				player.global_position = marker.global_position
		else:
			push_warning("Checkpoint not found: " + respawn_id)
	
	if player.has_method("change_movement_mode"):
		player.change_movement_mode(level_mode)
		
	if player.has_method("set_controls_enabled"):
		player.set_controls_enabled(true)
		
	if level_mode == "beat":
		$RhythmEngine.play_music()

func _find_checkpoint(checkpoint_id: String) -> Area2D:
	for node in get_tree().get_nodes_in_group("sweet_checkpoints"):
		if is_ancestor_of(node) and node.get("checkpoint_id") == checkpoint_id:
			return node as Area2D
	return null
