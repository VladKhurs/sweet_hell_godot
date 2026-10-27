@tool
extends Node
class_name LevelMusic
## Attach as a child of a level or main menu and assign a track in Inspector.
@export var track: AudioStream
@export_range(0.0, 5.0, 0.05) var fade_seconds: float = 0.55
@export var stop_if_empty: bool = true
@export var yield_to_rhythm_mode: bool = true

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    if yield_to_rhythm_mode and GameState.current_mode == "beat":
        MusicManager.stop_music(fade_seconds)
    elif track != null:
        MusicManager.play_music(track, fade_seconds)
    elif stop_if_empty:
        MusicManager.stop_music(fade_seconds)
