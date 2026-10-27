extends Control

func _ready() -> void:
	# The Dialogue Manager example balloon carries its own theme.
	# Override it with the same skin as the rest of Sweet Hell.
	theme = SweetUI.ui_theme
