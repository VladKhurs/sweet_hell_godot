extends CharacterBody2D
class_name Lumi

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func play_walk(flip_left: bool = true) -> void:
	if anim:
		anim.flip_h = flip_left
		anim.play("walk")


func play_idle(flip_left: bool = true) -> void:
	if anim:
		anim.flip_h = flip_left
		anim.play("idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 600.0 * delta
		move_and_slide()
