extends Node

@export_file("*.tscn") var next_level_path: String = ""
@export var walk_distance: float = 120.0
@export var walk_time: float = 3.5

@onready var lumi: Node2D = get_parent().get_node_or_null("Lumi")
var player: CharacterBody2D

func _ready() -> void:
	await get_tree().process_frame

	player = get_tree().root.find_child("Player", true, false)
	if not player:
		return

	# Ждем, пока игрок упадет на пол
	while not player.is_on_floor():
		await get_tree().physics_frame

	player.set_controls_enabled(false)
	_run()

func _run() -> void:
	# Анимации ходьбы
	player.anim.flip_h = true
	player.anim.play("walk")
	if lumi and lumi.has_method("play_walk"):
		lumi.play_walk(true)

	# Идут параллельно с одинаковой скоростью
	var tween := create_tween().set_parallel(true)
	tween.tween_property(player, "global_position:x", player.global_position.x - walk_distance, walk_time)
	if lumi:
		tween.tween_property(lumi, "global_position:x", lumi.global_position.x - walk_distance, walk_time)
	await tween.finished

	# Остановка
	player.anim.play("idle")
	if lumi and lumi.has_method("play_idle"):
		lumi.play_idle(true)

	finish()

func finish() -> void:
	if not next_level_path.is_empty():
		Game.load_level(next_level_path)
	elif player:
		player.set_controls_enabled(true)
