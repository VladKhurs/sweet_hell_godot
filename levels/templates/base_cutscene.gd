extends Node2D
class_name BaseCutscene

@export_file("*.tscn") var next_level_path: String = ""
const PLAYER_SCENE = preload("res://entities/characters/player/player.tscn")

var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().root.find_child("Player", true, false)
	if not player:
		player = PLAYER_SCENE.instantiate()
		add_child(player)

	var spawn = get_node_or_null("SpawnPoint")
	if spawn:
		player.global_position = spawn.global_position

	player.set_controls_enabled(false)
	_run()

func _run() -> void:
	pass

func finish() -> void:
	if not next_level_path.is_empty():
		Game.load_level(next_level_path)
	elif player:
		player.set_controls_enabled(true)
