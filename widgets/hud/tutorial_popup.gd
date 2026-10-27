extends CanvasLayer

var _kind: String = "move"
var _custom_ru: String = ""
var _custom_en: String = ""

@onready var _panel: PanelContainer = $Layout/Panel
@onready var _label: Label = $Layout/Panel/Margin/Message

func _ready() -> void:
	_panel.add_theme_stylebox_override("panel", SweetPixelStyle.box(
		SweetUI.CONFIG.panel, SweetUI.CONFIG.border,
		SweetUI.CONFIG.corner_pixels, SweetUI.CONFIG.border_pixels, 5, 4
	))
	SettingsManager.language_changed.connect(_refresh)
	_refresh()

func show_hint(kind: String, duration: float, custom_ru: String, custom_en: String) -> void:
	_kind = kind
	_custom_ru = custom_ru
	_custom_en = custom_en
	_refresh()
	await get_tree().create_timer(duration, false).timeout
	if is_inside_tree():
		queue_free()

func _refresh() -> void:
	if not is_node_ready():
		return
	var custom_text := _custom_ru if SettingsManager.language == "ru" else _custom_en
	if not custom_text.is_empty():
		_label.text = custom_text
		return
	var device := "touch" if TouchPlatform.is_enabled() else "pc"
	_label.text = SettingsManager.tr_key("tutorial_%s_%s" % [_kind, device])
