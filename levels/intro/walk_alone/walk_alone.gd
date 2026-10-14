extends Node

@export_file("*.tscn") var next_level_path: String = ""
@export var walk_distance: float = 120.0
@export var walk_time: float = 2.5

@onready var lumi: Node2D = get_parent().get_node_or_null("Lumi")
var player: CharacterBody2D

func _ready() -> void:
	await get_tree().process_frame

	player = get_tree().root.find_child("Player", true, false)
	if not player:
		return

	# Ждем, пока гравитация опустит игрока на пол
	while not player.is_on_floor():
		await get_tree().physics_frame

	# Теперь глушим управление и запускаем катсцену
	player.set_controls_enabled(false)
	_run()

func _run() -> void:
	if lumi:
		if lumi.has_method("play_walk"): lumi.play_walk(true)
		var tween_lumi := create_tween()
		tween_lumi.tween_property(lumi, "global_position:x", lumi.global_position.x - walk_distance - 60.0, walk_time * 1)
		await tween_lumi.finished
		lumi.visible = false

	finish()

func finish() -> void:
	if not next_level_path.is_empty():
		Game.load_level(next_level_path)
	elif player:
		player.set_controls_enabled(true)
