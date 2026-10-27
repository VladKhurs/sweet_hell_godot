extends Area2D
class_name SweetTutorialHint

## Reusable, non-blocking hint: place scene in a level and set unique Hint ID.
@export var hint_id: String = ""
@export_enum("move", "jump", "interact", "attack", "transform", "grid", "beat") var hint_kind: String = "move"
@export_range(2.0, 12.0, 0.5) var display_seconds: float = 5.0
@export_multiline var custom_text_ru: String = ""
@export_multiline var custom_text_en: String = ""

const POPUP := preload("res://widgets/hud/tutorial_popup.tscn")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if hint_id.strip_edges().is_empty():
		push_warning("TutorialHint: Hint ID is empty: " + str(get_path()))
		return
	if GameState.get_world_state("tutorial", hint_id) == true:
		return
	if not get_tree().get_nodes_in_group("sweet_tutorial_popups").is_empty():
		return
	var level := get_tree().current_scene
	if level == null:
		return
	var popup := POPUP.instantiate()
	level.add_child(popup)
	popup.show_hint(hint_kind, display_seconds, custom_text_ru, custom_text_en)
	# World state is already included in the existing JSON saves. New game resets it.
	GameState.set_world_state("tutorial", hint_id, true)
