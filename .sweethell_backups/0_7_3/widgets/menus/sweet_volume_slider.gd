extends HSlider
## Pixel-styled volume control. Colors and geometry: sweet_ui_config.tres.

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    custom_minimum_size.y = 18.0
    size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var cfg := SweetUI.CONFIG
    add_theme_stylebox_override("slider", _bar(cfg.slider_track))
    add_theme_stylebox_override("grabber_area", _bar(cfg.slider_fill))
    add_theme_stylebox_override("grabber_area_highlight", _bar(cfg.hover))
    add_theme_icon_override("grabber", _handle(cfg.slider_handle))
    add_theme_icon_override("grabber_highlight", _handle(cfg.hover))
    add_theme_icon_override("grabber_disabled", _handle(cfg.disabled))


func _bar(fill: Color) -> StyleBoxTexture:
    var cfg := SweetUI.CONFIG
    return SweetPixelStyle.box(fill, cfg.border, cfg.slider_corner_pixels, cfg.slider_border_pixels, 0, 0)


func _handle(fill: Color) -> ImageTexture:
    var cfg := SweetUI.CONFIG
    var width := cfg.slider_handle_width
    var height := cfg.slider_handle_height
    var radius := cfg.slider_corner_pixels
    var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
    img.fill(Color.TRANSPARENT)
    for y in range(height):
        for x in range(width):
            if not _inside(x, y, width, height, radius):
                continue
            var border := not _inside(x - 1, y, width, height, radius)
            border = border or not _inside(x + 1, y, width, height, radius)
            border = border or not _inside(x, y - 1, width, height, radius)
            border = border or not _inside(x, y + 1, width, height, radius)
            img.set_pixel(x, y, cfg.border if border else fill)
    return ImageTexture.create_from_image(img)


func _inside(x: int, y: int, width: int, height: int, radius: int) -> bool:
    if x < 0 or y < 0 or x >= width or y >= height:
        return false
    var dx := mini(x, width - 1 - x)
    var dy := mini(y, height - 1 - y)
    return dx + dy >= radius - 1 if dx < radius and dy < radius else true
