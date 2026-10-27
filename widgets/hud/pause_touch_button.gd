extends Button
## Add this lightweight button under HUD/TouchControls for touch devices.
func _ready() -> void:
	if not TouchPlatform.is_enabled():
		hide()
		return
	text = "II"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pressed.connect(PauseManager.open_pause)
