extends Node2D
class_name BaseCutscene

@export_file("*.tscn") var next_level_path: String = ""


func _ready() -> void:
	_run()


func _run() -> void:
	pass


func finish() -> void:
	if not next_level_path.is_empty():
		Game.load_level(next_level_path)
	else:
		# Остаемся на этом же уровне — просто отдаем игроку управление:
		var player = get_tree().root.find_child("Player", true, false)
		if player and player.has_method("set_controls_enabled"):
			player.set_controls_enabled(true)
