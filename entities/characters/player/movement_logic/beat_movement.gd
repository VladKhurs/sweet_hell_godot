extends GridMovement

@export var window_time: float = 0.25
var can_move_now: bool = false
var _beat_generation: int = 0

func _ready() -> void:
	var engine = get_tree().root.find_child("RhythmEngine", true, false)
	if engine:
		engine.beat.connect(_on_beat)

func _on_beat(_index: int) -> void:
	_beat_generation += 1
	var generation := _beat_generation
	can_move_now = true
	# Gameplay timer pauses with SceneTree; old timers cannot close a newer window.
	await get_tree().create_timer(window_time, false).timeout
	if generation == _beat_generation:
		can_move_now = false

func attempt_move(direction: Vector2) -> void:
	if can_move_now:
		super.attempt_move(direction)
	else:
		_fail_feedback()

func _fail_feedback() -> void:
	sprite.modulate = Color.RED
	shake_sprite()
	get_tree().create_timer(0.15, false).timeout.connect(func(): sprite.modulate = Color.WHITE)
	
