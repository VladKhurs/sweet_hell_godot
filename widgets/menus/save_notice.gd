extends CanvasLayer
## Pixel-styled notification shown after a checkpoint has been written to disk.

@onready var _panel: PanelContainer = $Overlay/Center/Panel
@onready var _title: Label = $Overlay/Center/Panel/Margin/Content/Header/Title
@onready var _time: Label = $Overlay/Center/Panel/Margin/Content/Time
@onready var _close: Button = $Overlay/Center/Panel/Margin/Content/Header/Close

var _playtime: String = "00:00:00"

func _ready() -> void:
	_panel.add_theme_stylebox_override("panel", SweetPixelStyle.box(
		SweetUI.CONFIG.panel, SweetUI.CONFIG.border,
		SweetUI.CONFIG.corner_pixels, SweetUI.CONFIG.border_pixels, 6, 6
	))
	_close.pressed.connect(queue_free)
	SettingsManager.language_changed.connect(_refresh)
	_refresh()
	_close.grab_focus()

func show_playtime(value: String) -> void:
	_playtime = value
	if is_node_ready():
		_refresh()

func _refresh() -> void:
	_title.text = SettingsManager.tr_key("save_complete")
	_time.text = "%s %s" % [SettingsManager.tr_key("play_time"), _playtime]
