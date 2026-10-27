@tool
extends Button
class_name SweetButton

const UI_CONFIG: SweetUIConfig = preload("res://assets/themes/sweet_ui_config.tres")

## Пиксельная кнопка Sweet Hell. Размеры и цвета настраиваются в Inspector.

@export_group("Pixel appearance")
@export var use_global_palette: bool = true
@export var normal_color: Color = Color("ef75ac"):
	set(value):
		normal_color = value
		_refresh_style()
@export var hover_color: Color = Color("ff9dcb"):
	set(value):
		hover_color = value
		_refresh_style()
@export var pressed_color: Color = Color("c84d91"):
	set(value):
		pressed_color = value
		_refresh_style()
@export var disabled_color: Color = Color("77516f"):
	set(value):
		disabled_color = value
		_refresh_style()
@export var outline_color: Color = Color("542747"):
	set(value):
		outline_color = value
		_refresh_style()
@export var highlight_color: Color = Color("ffdec6"):
	set(value):
		highlight_color = value
		_refresh_style()
@export var shadow_color: Color = Color("8b3665"):
	set(value):
		shadow_color = value
		_refresh_style()
@export_range(1, 8, 1) var outline_pixels: int = 2:
	set(value):
		outline_pixels = value
		_refresh_style()
@export_range(0, 8, 1) var shadow_pixels: int = 3:
	set(value):
		shadow_pixels = value
		_refresh_style()
@export_range(0, 24, 1) var horizontal_padding: int = 12:
	set(value):
		horizontal_padding = value
		_refresh_style()
@export_range(0, 16, 1) var vertical_padding: int = 5:
	set(value):
		vertical_padding = value
		_refresh_style()
@export var font_asset: Font:
	set(value):
		font_asset = value
		_refresh_style()
@export_range(6, 48, 1) var text_size: int = 8:
	set(value):
		text_size = value
		_refresh_style()
@export var text_color: Color = Color("fff2de"):
	set(value):
		text_color = value
		_refresh_style()

@export_group("Animation")
@export_range(1.0, 1.4, 0.01) var hover_scale: float = 1.06
@export_range(0.75, 1.0, 0.01) var press_scale: float = 0.96
@export_range(0.0, 0.5, 0.01) var transition_seconds: float = 0.10

@export_group("Sound")
@export var hover_sound: AudioStream
@export var pressed_sound: AudioStream
@export_range(-60.0, 12.0, 0.5) var sound_volume_db: float = -8.0

var _scale_tween: Tween
var _audio: AudioStreamPlayer

func _ready() -> void:
	_refresh_style()
	pivot_offset = size / 2.0
	resized.connect(_update_pivot)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	if not Engine.is_editor_hint():
		_audio = AudioStreamPlayer.new()
		_audio.name = "ButtonSound"
		_audio.volume_db = sound_volume_db
		add_child(_audio)

func _refresh_style() -> void:
	if not is_inside_tree():
		return
	add_theme_stylebox_override("normal", _make_box(UI_CONFIG.button if use_global_palette else normal_color))
	add_theme_stylebox_override("hover", _make_box(UI_CONFIG.hover if use_global_palette else hover_color))
	add_theme_stylebox_override("pressed", _make_box(UI_CONFIG.pressed if use_global_palette else pressed_color))
	add_theme_stylebox_override("hover_pressed", _make_box(UI_CONFIG.pressed if use_global_palette else pressed_color))
	add_theme_stylebox_override("disabled", _make_box(UI_CONFIG.disabled if use_global_palette else disabled_color))
	var empty_focus := StyleBoxEmpty.new()
	add_theme_stylebox_override("focus", empty_focus)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		add_theme_color_override(state, UI_CONFIG.text if use_global_palette else text_color)
	add_theme_color_override("font_disabled_color", text_color.darkened(0.4))
	add_theme_color_override("font_outline_color", highlight_color)
	add_theme_constant_override("outline_size", 1)
	add_theme_font_size_override("font_size", text_size)
	if font_asset:
		add_theme_font_override("font", font_asset)
	else:
		remove_theme_font_override("font")  # наследует глобальную пиксельную тему

func _make_box(fill_color: Color) -> StyleBoxTexture:
	var c := UI_CONFIG
	return SweetPixelStyle.box(fill_color, c.border if use_global_palette else outline_color, c.corner_pixels if use_global_palette else 0, c.border_pixels if use_global_palette else outline_pixels, c.padding_horizontal if use_global_palette else horizontal_padding, c.padding_vertical if use_global_palette else vertical_padding)

func _update_pivot() -> void:
	pivot_offset = size / 2.0

func _animate_scale(target: float) -> void:
	if _scale_tween and _scale_tween.is_valid():
		_scale_tween.kill()
	if transition_seconds <= 0.0:
		scale = Vector2.ONE * target
		return
	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", Vector2.ONE * target, transition_seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _play_sound(sound: AudioStream) -> void:
	if _audio and sound:
		_audio.stream = sound
		_audio.volume_db = sound_volume_db
		_audio.play()

func _on_mouse_entered() -> void:
	if disabled or Engine.is_editor_hint():
		return
	_animate_scale(hover_scale)
	_play_sound(hover_sound)

func _on_mouse_exited() -> void:
	if Engine.is_editor_hint():
		return
	_animate_scale(1.0)

func _on_button_down() -> void:
	if not Engine.is_editor_hint():
		_animate_scale(press_scale)

func _on_button_up() -> void:
	if not Engine.is_editor_hint():
		_animate_scale(hover_scale if get_global_rect().has_point(get_global_mouse_position()) else 1.0)

func _on_pressed() -> void:
	if not Engine.is_editor_hint():
		_play_sound(pressed_sound)

func _on_focus_entered() -> void:
	if not Engine.is_editor_hint() and not disabled:
		_animate_scale(hover_scale)

func _on_focus_exited() -> void:
	if not Engine.is_editor_hint():
		_animate_scale(1.0)
