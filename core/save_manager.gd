extends Node
## One manual save slot. Only SweetCheckpoint calls save_at_checkpoint().
const VERSION := 1
const SAVE_PATH := "user://sweet_hell_save.json"
const BACKUP_PATH := "user://sweet_hell_save.bak"
const TEMP_PATH := "user://sweet_hell_save.tmp"
const MAIN_MENU := "res://widgets/menus/main_menu.tscn"
const RECENT_SAVE_SECONDS := 60.0

var playtime_seconds: float = 0.0
var _time_since_save: float = INF

func _process(delta: float) -> void:
	# Count gameplay time, not time in menus or on pause.
	var scene := get_tree().current_scene
	if scene != null and scene.scene_file_path != MAIN_MENU and not get_tree().paused:
		playtime_seconds += delta
		_time_since_save += delta

func reset_playtime() -> void:
	playtime_seconds = 0.0
	_time_since_save = INF

func has_recent_save() -> bool:
	return _time_since_save < RECENT_SAVE_SECONDS and has_save()

func format_playtime() -> String:
	var total := floori(playtime_seconds)
	return "%02d:%02d:%02d" % [int(total / 3600.0), int(total / 60.0) % 60, total % 60]

func has_save() -> bool:
	return not _read_saved_data().is_empty()

func save_at_checkpoint() -> bool:
	var level := GameState.checkpoint_level_path
	var checkpoint := GameState.current_checkpoint_id
	if not level.begins_with("res://levels/") or checkpoint.is_empty():
		push_warning("SaveManager: no active checkpoint")
		return false

	var inventory_data := Inventory.to_save_data()
	if inventory_data.is_empty():
		return false
	var data := {
		"version": VERSION,
		"playtime_seconds": playtime_seconds,
		"level": level,
		"checkpoint": checkpoint,
		"health": Game.current_health,
		"penguin": GameState.is_penguin,
		"characters": GameState.character_states.duplicate(true),
		"dialogues": GameState.dialogue_states.duplicate(true),
		"world": GameState.world_states.duplicate(true),
		"inventory": inventory_data,
	}
	if not _is_json_data(data):
		push_error("SaveManager: game state contains a non-JSON value")
		return false

	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot create temporary file: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(data, "\t") + "\n")
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("SaveManager: disk write failed: %s" % write_error)
		return false
	if _read_file(TEMP_PATH).is_empty():
		push_error("SaveManager: temporary save validation failed")
		return false

	# Never overwrite the last valid save before keeping a backup.
	if FileAccess.file_exists(SAVE_PATH) and not _read_file(SAVE_PATH).is_empty():
		var backup_error := DirAccess.copy_absolute(_abs(SAVE_PATH), _abs(BACKUP_PATH))
		if backup_error != OK:
			push_error("SaveManager: cannot back up save: %s" % backup_error)
			return false

	var error := DirAccess.rename_absolute(_abs(TEMP_PATH), _abs(SAVE_PATH))
	if error != OK:
		# Rename can refuse replacing an existing file on some operating systems.
		error = DirAccess.copy_absolute(_abs(TEMP_PATH), _abs(SAVE_PATH))
		if error == OK:
			DirAccess.remove_absolute(_abs(TEMP_PATH))
	if error != OK:
		push_error("SaveManager: write failed: %s" % error)
		return false
	_time_since_save = 0.0
	return true

func restore_game() -> bool:
	var data := _read_saved_data()
	if data.is_empty():
		return false
	# Validate inventory before changing game state.
	if not Inventory.load_save_data(data["inventory"]):
		push_error("SaveManager: could not restore inventory")
		return false

	# Keep time spent on failed attempts during this session.
	# Older saves without playtime_seconds remain compatible.
	playtime_seconds = maxf(playtime_seconds, maxf(float(data.get("playtime_seconds", 0.0)), 0.0))
	GameState.clear_all()
	GameState.character_states = data["characters"].duplicate(true)
	GameState.dialogue_states = data["dialogues"].duplicate(true)
	GameState.world_states = data["world"].duplicate(true)
	GameState.activate_checkpoint(data["level"], data["checkpoint"])
	GameState.current_level_path = data["level"]
	GameState.resume_at_checkpoint = true
	GameState.is_penguin = data["penguin"]
	Game.current_health = clampi(int(data["health"]), 1, Game.max_health)
	Game.health_changed.emit(Game.current_health)
	_time_since_save = 0.0
	Game.is_invulnerable = true
	Game.load_level(data["level"])
	return true

func delete_save() -> bool:
	for path in [TEMP_PATH, BACKUP_PATH, SAVE_PATH]:
		if FileAccess.file_exists(path):
			var error := DirAccess.remove_absolute(_abs(path))
			if error != OK:
				push_error("SaveManager: cannot remove %s: %s" % [path, error])
				return false
	return true

func _read_saved_data() -> Dictionary:
	var data := _read_file(SAVE_PATH)
	if not data.is_empty():
		return data
	return _read_file(BACKUP_PATH)

func _read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return {}
	var data: Dictionary = parsed
	if data.get("version") != VERSION:
		return {}
	if not (data.get("level", "") is String) or not (data.get("checkpoint", "") is String):
		return {}
	if not data["level"].begins_with("res://levels/") or data["checkpoint"].is_empty():
		return {}
	if not ResourceLoader.exists(data["level"], "PackedScene"):
		return {}
	if not (data.get("health") is float or data.get("health") is int):
		return {}
	if not (data.get("penguin") is bool):
		return {}
	for key in ["characters", "dialogues", "world", "inventory"]:
		if not (data.get(key) is Dictionary):
			return {}
	return data

func _is_json_data(value: Variant) -> bool:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME:
			return true
		TYPE_ARRAY:
			for entry in value:
				if not _is_json_data(entry):
					return false
			return true
		TYPE_DICTIONARY:
			for key in value:
				if not (key is String or key is StringName) or not _is_json_data(value[key]):
					return false
			return true
	return false

func _abs(path: String) -> String:
	return ProjectSettings.globalize_path(path)
