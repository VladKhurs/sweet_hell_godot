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
	
	var spawn_point = $SpawnPoint
	if spawn_point:
		player.global_position = spawn_point.global_position
	
	if player.has_method("change_movement_mode"):
		player.change_movement_mode(level_mode)
		
	if player.has_method("set_controls_enabled"):
		player.set_controls_enabled(true)
		
	if level_mode == "beat":
		$RhythmEngine.play_music()
