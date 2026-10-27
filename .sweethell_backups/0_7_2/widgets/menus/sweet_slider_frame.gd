extends PanelContainer
class_name SweetSliderFrame

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var cfg := SweetUI.CONFIG
    add_theme_stylebox_override("panel", SweetUI.make_box(cfg.background, cfg.border, -1, -1, 6, 5))
    var slider := get_child(0) as HSlider
    if slider == null:
        return
    slider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    slider.custom_minimum_size.y = 18
    slider.add_theme_stylebox_override("slider", SweetUI.make_box(cfg.slider_track, cfg.border, cfg.corner_pixels, 1, 0, 0))
    slider.add_theme_stylebox_override("grabber_area", SweetUI.make_box(cfg.slider_fill, cfg.border, cfg.corner_pixels, 1, 0, 0))
    slider.add_theme_stylebox_override("grabber_area_highlight", SweetUI.make_box(cfg.hover, cfg.border, cfg.corner_pixels, 1, 0, 0))
    slider.add_theme_icon_override("grabber", _knob(cfg.slider_handle, cfg.border))
    slider.add_theme_icon_override("grabber_highlight", _knob(cfg.hover, cfg.border))
    slider.add_theme_icon_override("grabber_disabled", _knob(cfg.disabled, cfg.border))

func _knob(fill: Color, outline: Color) -> Texture2D:
    var img := Image.create(11, 15, false, Image.FORMAT_RGBA8)
    img.fill(Color.TRANSPARENT)
    for y in range(15):
        for x in range(11):
            if (x < 2 or x > 8) and (y < 2 or y > 12):
                continue
            var edge := x == 0 or x == 10 or y == 0 or y == 14
            edge = edge or ((x <= 2 or x >= 8) and (y <= 2 or y >= 12))
            img.set_pixel(x, y, outline if edge else fill)
    return ImageTexture.create_from_image(img)
