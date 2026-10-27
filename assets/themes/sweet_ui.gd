extends Node

const CONFIG: SweetUIConfig = preload("res://assets/themes/sweet_ui_config.tres")
const PIXEL_FONT: FontFile = preload("res://assets/fonts/PressStart2P-Regular.ttf")
var ui_theme: Theme

func _ready() -> void:
	ui_theme = Theme.new()
	ui_theme.default_font = PIXEL_FONT
	ui_theme.default_font_size = CONFIG.font_size
	var types := ["Button", "Panel", "PanelContainer", "LineEdit", "TextEdit", "PopupPanel"]
	for type in types:
		if type == "Button":
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
				var color: Color = CONFIG.button
				match state:
					"hover": color = CONFIG.hover
					"pressed", "hover_pressed": color = CONFIG.pressed
					"disabled": color = CONFIG.disabled
					"focus": color = CONFIG.hover
				ui_theme.set_stylebox(state, type, make_box(color))
			for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
				ui_theme.set_color(color_name, type, CONFIG.text)
			ui_theme.set_color("font_disabled_color", type, CONFIG.muted_text)
		else:
			ui_theme.set_stylebox("panel" if type in ["Panel", "PanelContainer", "PopupPanel"] else "normal", type, make_box(CONFIG.panel))
	for type in ["Label", "RichTextLabel"]:
		ui_theme.set_color("font_color" if type == "Label" else "default_color", type, CONFIG.text)
	ui_theme.set_constant("separation", "VBoxContainer", CONFIG.spacing)
	ui_theme.set_constant("separation", "HBoxContainer", CONFIG.spacing)
	get_tree().root.theme = ui_theme

func make_box(fill: Color, edge: Color = Color.TRANSPARENT, radius: int = -1, thickness: int = -1, pad_x: int = -1, pad_y: int = -1) -> StyleBoxTexture:
	return SweetPixelStyle.box(fill, CONFIG.border if edge == Color.TRANSPARENT else edge, CONFIG.corner_pixels if radius < 0 else radius, CONFIG.border_pixels if thickness < 0 else thickness, CONFIG.padding_horizontal if pad_x < 0 else pad_x, CONFIG.padding_vertical if pad_y < 0 else pad_y)
