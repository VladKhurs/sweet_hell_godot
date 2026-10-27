extends Control
signal closed

const BUTTON := preload("res://widgets/buttons/sweet_button.gd")
var _title: Label
var _volume_label: Label
var _language_label: Label
var _back: Button
var _slider: HSlider
var _ru: Button
var _en: Button

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 mouse_filter = Control.MOUSE_FILTER_STOP
 var dim := ColorRect.new()
 dim.color = Color(0.14, 0.07, 0.17, 0.94)
 dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(dim)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(center)
 var content := VBoxContainer.new()
 content.custom_minimum_size.x = 220
 content.add_theme_constant_override("separation", 7)
 center.add_child(content)
 _title = _label(content)
 _volume_label = _label(content)
 _slider = HSlider.new()
 _slider.min_value = 0
 _slider.max_value = 100
 _slider.step = 1
 _slider.value = SettingsManager.volume * 100.0
 _slider.value_changed.connect(func(v: float): SettingsManager.set_volume(v / 100.0))
 _slider.set_script(preload("res://widgets/menus/sweet_volume_slider.gd"))
 content.add_child(_slider)
 _language_label = _label(content)
 var languages := HBoxContainer.new()
 languages.add_theme_constant_override("separation", 5)
 content.add_child(languages)
 _ru = _button(languages, "", func(): SettingsManager.set_language("ru"))
 _en = _button(languages, "", func(): SettingsManager.set_language("en"))
 _back = _button(content, "", _close)
 SettingsManager.language_changed.connect(_refresh)
 _refresh()
 _back.grab_focus()

func _label(parent: Node) -> Label:
 var label := Label.new()
 label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 parent.add_child(label)
 return label

func _button(parent: Node, label: String, callback: Callable) -> Button:
 var button := BUTTON.new() as Button
 button.custom_minimum_size.y = 25
 button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 button.text = label
 parent.add_child(button)
 button.pressed.connect(callback)
 return button

func _refresh() -> void:
 _title.text = SettingsManager.tr_key("settings")
 _volume_label.text = SettingsManager.tr_key("volume")
 _language_label.text = SettingsManager.tr_key("language")
 _ru.text = SettingsManager.tr_key("russian")
 _en.text = SettingsManager.tr_key("english")
 _ru.disabled = SettingsManager.language == "ru"
 _en.disabled = SettingsManager.language == "en"
 _back.text = SettingsManager.tr_key("back")

func _close() -> void:
 closed.emit()
 queue_free()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel"):
  _close()
  get_viewport().set_input_as_handled()
