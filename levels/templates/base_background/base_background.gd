extends Node2D

@export var bg_far: Texture2D

@onready var far_layer: Parallax2D = $FarLayer
@onready var far_sprite: Sprite2D = $FarLayer/Sprite2D

func _ready() -> void:
	z_index = -100
	_apply_texture(far_layer, far_sprite, bg_far)

func _apply_texture(layer: Parallax2D, sprite: Sprite2D, tex: Texture2D) -> void:
	if tex:
		sprite.texture = tex
		sprite.scale = Vector2(1.7, 1.7)
		layer.repeat_size = tex.get_size() * 1.7
		layer.visible = true
	else:
		layer.visible = false
