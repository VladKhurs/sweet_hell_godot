extends Node
## Persistent background music, including crossfades between scenes.
const FADE_SECONDS := 0.55
var _players: Array[AudioStreamPlayer] = []
var _active: int = 0
var _transition: Tween

func _ready() -> void:
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.name = "MusicChannel%d" % i
		player.bus = &"Master"
		add_child(player)
		_players.append(player)

func play_music(track: AudioStream, fade: float = FADE_SECONDS) -> void:
	if _transition and _transition.is_valid():
		_transition.kill()
	var current := _players[_active]
	if track != null and current.stream == track and current.playing:
		return
	var other := _players[1 - _active]
	other.stop()
	other.stream = track
	if track == null:
		_fade_to_silence(current, fade)
		return
	other.volume_db = -60.0 if fade > 0 else 0.0
	other.play()
	_transition = create_tween().set_parallel(true)
	_transition.tween_property(current, "volume_db", -60.0, maxf(fade, 0.0))
	_transition.tween_property(other, "volume_db", 0.0, maxf(fade, 0.0))
	_transition.chain().tween_callback(current.stop)
	_active = 1 - _active

func stop_music(fade: float = FADE_SECONDS) -> void:
	play_music(null, fade)

func _fade_to_silence(current: AudioStreamPlayer, fade: float) -> void:
	if not current.playing:
		return
	_transition = create_tween()
	_transition.tween_property(current, "volume_db", -60.0, maxf(fade, 0.0))
	_transition.tween_callback(current.stop)
