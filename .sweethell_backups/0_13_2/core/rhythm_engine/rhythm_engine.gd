extends CanvasLayer

signal beat(index)

@export_group("Settings")
@export var bpm: int = 120
@export var music_track: AudioStream
@export var flash_color: Color = Color(1, 1, 1, 0.2)

@onready var audio_player = $AudioStreamPlayer
@onready var flash_rect = $FlashOverlay

var time_begin: float = 0
var beat_duration: float = 0
var last_beat: int = 0

func _ready():
	beat_duration = 60.0 / bpm
	if music_track:
		audio_player.stream = music_track
	
	# Сами подписываемся на свой же сигнал для визуала
	beat.connect(_on_own_beat)

func play_music():
	time_begin = Time.get_ticks_usec()
	audio_player.play()

func _process(_delta):
	if audio_player.playing:
		var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
		var current_beat = int(floor(time / beat_duration))
		
		if current_beat > last_beat:
			last_beat = current_beat
			beat.emit(last_beat)

# Логика, которая раньше была в RhythmUI.gd
func _on_own_beat(_index):
	flash_rect.color = Color.WHITE
	var tween = create_tween()
	tween.tween_property(flash_rect, "color", flash_color, 0.2)
