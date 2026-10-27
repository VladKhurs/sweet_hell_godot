extends CanvasLayer

signal beat(index)

@export_group("Settings")
@export var bpm: int = 120
@export var music_track: AudioStream
@export var flash_color: Color = Color(1, 1, 1, 0.2)

@onready var audio_player = $AudioStreamPlayer
@onready var flash_rect = $FlashOverlay

var beat_duration: float = 0.0
var last_beat: int = 0

func _ready():
	beat_duration = 60.0 / bpm
	if music_track:
		audio_player.stream = music_track
	
	# Сами подписываемся на свой же сигнал для визуала
	beat.connect(_on_own_beat)

func play_music() -> void:
	last_beat = 0
	audio_player.stream_paused = false
	audio_player.play()

func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_PAUSED:
		audio_player.stream_paused = true
	elif what == NOTIFICATION_UNPAUSED:
		audio_player.stream_paused = false

func _process(_delta: float) -> void:
	if not audio_player.playing or audio_player.stream_paused:
		return
	# Follow actual audio playback, which stops with the pause and wraps on loops.
	var playback_time: float = maxf(
		audio_player.get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency(), 0.0
	)
	var current_beat: int = floori(playback_time / beat_duration)
	if current_beat < last_beat:
		last_beat = current_beat  # The music has looped or been seeked.
	elif current_beat > last_beat:
		last_beat = current_beat
		beat.emit(last_beat)

# Логика, которая раньше была в RhythmUI.gd
func _on_own_beat(_index):
	flash_rect.color = Color.WHITE
	var tween = create_tween()
	tween.tween_property(flash_rect, "color", flash_color, 0.2)
