extends Node
class_name WalkCutscene

@export var walk_distance: float = 120.0
@export var walk_time: float = 2.5
@export var lumi: Node2D
@export var wall: Node2D

func _ready() -> void:
	await get_tree().process_frame
	var choice := GameState.story_point
	if choice.is_empty():
		return

	GameState.set_story_point("")
	_run_cutscene(choice)

func _run_cutscene(choice: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().root.find_child("Player", true, false)
	if not player:
		return

	if not lumi: lumi = get_tree().root.find_child("Lumi", true, false)
	if not wall: wall = get_tree().root.find_child("Wall", true, false)

	player.set_controls_enabled(false)
	player.set_process(false)

	if wall:
		_set_wall_active(false)

	if choice == "walk-together":
		player.anim.flip_h = true
		player.anim.play("walk")
		if lumi and lumi.has_method("play_walk"): lumi.play_walk(true)

		var tween := create_tween().set_parallel(true)
		tween.tween_property(player, "global_position:x", player.global_position.x - walk_distance, walk_time)
		if lumi:
			tween.tween_property(lumi, "global_position:x", lumi.global_position.x - walk_distance, walk_time)
		await tween.finished

		player.anim.play("idle")
		if lumi and lumi.has_method("play_idle"): lumi.play_idle(true)
	else:
		if lumi and lumi.has_method("play_walk"): lumi.play_walk(true)
		if lumi:
			var tween := create_tween()
			tween.tween_property(lumi, "global_position:x", lumi.global_position.x - walk_distance - 50.0, walk_time)
			await tween.finished
			if lumi.has_method("play_idle"): lumi.play_idle(true)
		if wall:
			_set_wall_active(true)

	player.set_process(true)
	player.set_controls_enabled(true)

func _set_wall_active(active: bool) -> void:
	wall.visible = active
	var col = wall.get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", not active)
		
