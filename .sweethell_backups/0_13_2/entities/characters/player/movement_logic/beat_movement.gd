extends GridMovement

@export var window_time: float = 0.25
var can_move_now: bool = false

func _ready() -> void:
	var engine = get_tree().root.find_child("RhythmEngine", true, false)
	if engine:
		engine.beat.connect(_on_beat)

func _on_beat(_index: int) -> void:
	can_move_now = true
	get_tree().create_timer(window_time).timeout.connect(func(): can_move_now = false)

func attempt_move(direction: Vector2) -> void:
	if can_move_now:
		super.attempt_move(direction)
	else:
		_fail_feedback()

func _fail_feedback() -> void:
	sprite.modulate = Color.RED
	shake_sprite()
	get_tree().create_timer(0.15).timeout.connect(func(): sprite.modulate = Color.WHITE)
	
