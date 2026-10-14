extends Node

signal world_state_changed(object_id: String, key: String, value: Variant)

var current_level_path: String = ""
var current_checkpoint_id: String = ""
var current_mode: StringName = &"free"

var character_states: Dictionary = {}
var dialogue_states: Dictionary = {}
var world_states: Dictionary = {}

func set_mode(mode: StringName) -> void:
	current_mode = mode

func set_location(level_path: String, checkpoint_id: String = "") -> void:
	current_level_path = level_path
	current_checkpoint_id = checkpoint_id

func set_character_state(character_id: String, key: String, value: Variant) -> void:
	character_states.get_or_add(character_id, {})[key] = value

func get_character_state(character_id: String, key: String) -> Variant:
	return character_states.get(character_id, {}).get(key)

func set_dialogue_state(dialogue_id: String, key: String, value: Variant) -> void:
	dialogue_states.get_or_add(dialogue_id, {})[key] = value

func get_dialogue_state(dialogue_id: String, key: String) -> Variant:
	return dialogue_states.get(dialogue_id, {}).get(key)

func set_world_state(object_id: String, key: String, value: Variant) -> void:
	world_states.get_or_add(object_id, {})[key] = value
	world_state_changed.emit(object_id, key, value)

func get_world_state(object_id: String, key: String) -> Variant:
	return world_states.get(object_id, {}).get(key)

func clear_all() -> void:
	current_level_path = ""
	current_checkpoint_id = ""
	character_states.clear()
	dialogue_states.clear()
	world_states.clear()
	current_mode = &"free"
	
