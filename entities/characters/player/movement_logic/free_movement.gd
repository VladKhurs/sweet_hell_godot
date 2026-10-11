extends Node

@onready var player = get_parent().get_parent() # Ссылка на CharacterBody2D
@export var speed: float = 110.0
var enabled: bool = false

func execute(_delta):
	if not enabled: return
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	player.velocity = direction * speed
	player.move_and_slide()
