extends Area2D
class_name SweetCheckpoint

## ID must be unique inside the level; set it on each instance in Inspector.
@export var checkpoint_id: String = ""
@export var idle_color: Color = Color("f667af")
@export var active_color: Color = Color("ffd5ad")

@onready var _flag: Polygon2D = $Visual/Flag

func _ready() -> void:
    GameState.checkpoint_changed.connect(_on_checkpoint_changed)
    _refresh_visual.call_deferred()

func interact(_interactor: Node) -> void:
    if checkpoint_id.strip_edges().is_empty():
        push_warning("SweetCheckpoint: set a unique checkpoint_id in Inspector: " + str(get_path()))
        return
    var level: Node = get_tree().current_scene
    if level == null or level.scene_file_path.is_empty():
        push_warning("SweetCheckpoint: cannot determine the current level")
        return
    GameState.activate_checkpoint(level.scene_file_path, checkpoint_id)

func _on_checkpoint_changed(_level_path: String, _id: String) -> void:
    _refresh_visual()

func _refresh_visual() -> void:
    var is_active: bool = (
        not checkpoint_id.is_empty()
        and GameState.checkpoint_level_path == GameState.current_level_path
        and GameState.current_checkpoint_id == checkpoint_id
    )
    _flag.color = active_color if is_active else idle_color
