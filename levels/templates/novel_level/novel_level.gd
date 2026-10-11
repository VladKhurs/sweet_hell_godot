extends Control
class_name NovelLevel

@export_category("Story & Progression")
@export var novel_id: String = ""
@export var dialogue_resource: DialogueResource
@export var dialogue_title: String = "start"
@export_file("*.tscn") var next_level_path: String = ""
@export var skip_if_already_read: bool = false

@export_category("Visuals")
@export_dir var images_folder: String = "res://assets/images/"
@export var default_background: Texture2D
@export var transition_duration: float = 0.4

@onready var bg_current: TextureRect = $BackgroundCurrent
@onready var bg_next: TextureRect = $BackgroundNext

var _fade_tween: Tween
var _current_bg_key: String = ""

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	if skip_if_already_read and not novel_id.is_empty() and GameState.get_world_state(novel_id, "completed") == true:
		_go_to_next_level()
		return

	if default_background:
		bg_current.texture = default_background

	if not dialogue_resource:
		push_error("[Novel] dialogue_resource не назначен!")
		return

	DialogueManager.got_dialogue.connect(_on_got_dialogue)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_title, [self])

func set_bg(image_name: String) -> void:
	if image_name.is_empty() or image_name == _current_bg_key: return
	var tex := _find_texture(image_name)
	if not tex:
		push_error("[Novel] Картинка '%s' не найдена!" % image_name)
		return

	_current_bg_key = image_name
	if transition_duration <= 0.0:
		bg_current.texture = tex
		return

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	bg_next.texture = tex
	bg_next.modulate.a = 0.0
	_fade_tween = create_tween()
	_fade_tween.tween_property(bg_next, "modulate:a", 1.0, transition_duration)
	_fade_tween.tween_callback(func():
		bg_current.texture = tex
		bg_next.modulate.a = 0.0
		bg_next.texture = null
	)

func _find_texture(file_name: String) -> Texture2D:
	var dirs: Array[String] = [images_folder, "res://assets/images/", "res://assets/"]
	if dialogue_resource:
		dirs.append(dialogue_resource.resource_path.get_base_dir())

	for d in dirs:
		var base_path: String = d.path_join(file_name)
		for ext: String in ["", ".png", ".webp", ".jpg"]:
			var full_path: String = base_path + ext
			if ResourceLoader.exists(full_path):
				return load(full_path) as Texture2D
	return null

func _on_got_dialogue(line: DialogueLine) -> void:
	if line.has_tag("bg"):
		set_bg(line.get_tag_value("bg"))

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource != dialogue_resource: return
	if not novel_id.is_empty():
		GameState.set_world_state(novel_id, "completed", true)
	_go_to_next_level()

func _go_to_next_level() -> void:
	if next_level_path.is_empty(): return
	if DialogueManager.got_dialogue.is_connected(_on_got_dialogue):
		DialogueManager.got_dialogue.disconnect(_on_got_dialogue)
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	Game.load_level(next_level_path)
	
