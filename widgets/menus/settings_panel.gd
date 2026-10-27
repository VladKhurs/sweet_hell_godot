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
var _main_page: VBoxContainer
var _touch_page: VBoxContainer
var _touch_entry: Button
var _touch_title: Label
var _touch_size_label: Label
var _touch_opacity_label: Label
var _touch_back: Button

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
 _main_page = content
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
 _touch_entry = _button(content, "", _open_touch_page)
 _touch_entry.visible = TouchPlatform.is_enabled()
 _back = _button(content, "", _close)

 _touch_page = VBoxContainer.new()
 _touch_page.custom_minimum_size.x = 220
 _touch_page.add_theme_constant_override("separation", 7)
 center.add_child(_touch_page)
 _touch_title = _label(_touch_page)
 _touch_size_label = _label(_touch_page)
 _touch_slider(_touch_page, 70.0, 130.0, SettingsManager.touch_scale * 100.0, func(v: float): SettingsManager.set_touch_scale(v / 100.0))
 _touch_opacity_label = _label(_touch_page)
 _touch_slider(_touch_page, 35.0, 100.0, SettingsManager.touch_opacity * 100.0, func(v: float): SettingsManager.set_touch_opacity(v / 100.0))
 _touch_back = _button(_touch_page, "", _close_touch_page)
 _touch_page.hide()
 SettingsManager.touch_settings_changed.connect(_refresh_touch_labels)
 SettingsManager.language_changed.connect(_refresh)
 _refresh()
 _back.grab_focus()

func _touch_slider(parent: Node, low: float, high: float, current: float, callback: Callable) -> void:
 var slider := HSlider.new()
 slider.min_value = low
 slider.max_value = high
 slider.step = 5.0
 slider.value = current
 slider.value_changed.connect(callback)
 slider.set_script(preload("res://widgets/menus/sweet_volume_slider.gd"))
 parent.add_child(slider)

func _open_touch_page() -> void:
 _main_page.hide()
 _touch_page.show()
 _touch_back.grab_focus()

func _close_touch_page() -> void:
 _touch_page.hide()
 _main_page.show()
 _touch_entry.grab_focus()

func _refresh_touch_labels() -> void:
 _touch_title.text = SettingsManager.tr_key("touch_controls")
 _touch_size_label.text = "%s: %d%%" % [SettingsManager.tr_key("touch_size"), roundi(SettingsManager.touch_scale * 100.0)]
 _touch_opacity_label.text = "%s: %d%%" % [SettingsManager.tr_key("touch_opacity"), roundi(SettingsManager.touch_opacity * 100.0)]

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
 _touch_entry.text = SettingsManager.tr_key("touch_controls")
 _touch_back.text = SettingsManager.tr_key("back")
 _refresh_touch_labels()

func _close() -> void:
 closed.emit()
 queue_free()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel"):
  if _touch_page.visible:
   _close_touch_page()
  else:
   _close()
  get_viewport().set_input_as_handled()
