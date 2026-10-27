@tool
extends Resource
class_name SweetUIConfig

@export_group("Palette")
@export var background: Color = Color("422b48")
@export var panel: Color = Color("6b315f")
@export var button: Color = Color("f667af")
@export var hover: Color = Color("ff9dcb")
@export var pressed: Color = Color("b56caf")
@export var disabled: Color = Color("74536e")
@export var border: Color = Color("ffd5ad")
@export var text: Color = Color("fff2de")
@export var muted_text: Color = Color("ffd5ad")
@export var shadow: Color = Color("422b48")

@export_group("Volume Slider")
@export var slider_track: Color = Color("422b48")
@export var slider_fill: Color = Color("f667af")
@export var slider_handle: Color = Color("f667af")

@export_group("Pixel Geometry")
@export_range(0, 8, 1) var corner_pixels: int = 3
@export_range(1, 6, 1) var border_pixels: int = 2
@export_range(0, 12, 1) var padding_horizontal: int = 7
@export_range(0, 10, 1) var padding_vertical: int = 4
@export_range(0, 10, 1) var spacing: int = 3
@export_range(6, 24, 1) var font_size: int = 8
