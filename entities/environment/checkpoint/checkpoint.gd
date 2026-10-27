extends Area2D
class_name SweetCheckpoint

## ID must be unique inside the level; set it on each instance in Inspector.
@export var checkpoint_id: String = ""
@export var idle_color: Color = Color("f667af")
@export var active_color: Color = Color("ffd5ad")
@export_group("Save Dialogue")
@export_file("*.dialogue") var save_dialogue_file: String = ""
@export var dialogue_title: String = "start"

const SAVE_NOTICE := preload("res://widgets/menus/save_notice.tscn")
var _saving: bool = false

@onready var _flag: Polygon2D = $Visual/Flag

func _ready() -> void:
    GameState.checkpoint_changed.connect(_on_checkpoint_changed)
    _refresh_visual.call_deferred()

func interact(interactor: Node) -> void:
    if _saving:
        return
    if checkpoint_id.strip_edges().is_empty():
        push_warning("SweetCheckpoint: set a unique checkpoint_id in Inspector: " + str(get_path()))
        return
    var level: Node = get_tree().current_scene
    if level == null or level.scene_file_path.is_empty():
        push_warning("SweetCheckpoint: cannot determine the current level")
        return
    _saving = true
    if not save_dialogue_file.is_empty():
        var source_dialogue := ResourceLoader.load(save_dialogue_file) as DialogueResource
        if source_dialogue == null:
            push_warning("SweetCheckpoint: cannot load dialogue: " + save_dialogue_file)
            _saving = false
            return
        var resource := DialogueLocale.resolve(source_dialogue)
        if interactor.has_method("set_controls_enabled"):
            interactor.set_controls_enabled(false)
        DialogueManager.show_dialogue_balloon(resource, dialogue_title)
        var ended_resource: DialogueResource = await DialogueManager.dialogue_ended
        if is_instance_valid(interactor) and interactor.has_method("set_controls_enabled"):
            interactor.set_controls_enabled(true)
        if ended_resource != resource:
            push_warning("SweetCheckpoint: unexpected dialogue ended before saving")
            _saving = false
            return
        if not is_inside_tree():
            return

    GameState.activate_checkpoint(level.scene_file_path, checkpoint_id)
    Game.current_health = Game.max_health
    Game.health_changed.emit(Game.current_health)
    if SaveManager.save_at_checkpoint():
        for old_notice in get_tree().get_nodes_in_group("sweet_save_notices"):
            old_notice.queue_free()
        var notice := SAVE_NOTICE.instantiate()
        level.add_child(notice)
        notice.call("show_playtime", SaveManager.format_playtime())
    else:
        push_warning("SweetCheckpoint: progress could not be saved")
    _saving = false

func _on_checkpoint_changed(_level_path: String, _id: String) -> void:
    _refresh_visual()

func _refresh_visual() -> void:
    var is_active: bool = (
        not checkpoint_id.is_empty()
        and GameState.checkpoint_level_path == GameState.current_level_path
        and GameState.current_checkpoint_id == checkpoint_id
    )
    _flag.color = active_color if is_active else idle_color
