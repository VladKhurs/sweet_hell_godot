@tool
extends RefCounted
class_name SweetPixelStyle

# A 9-sliced image with stepped, *not antialiased*, corners.
static func box(fill: Color, edge: Color, radius: int, thickness: int, pad_x: int, pad_y: int) -> StyleBoxTexture:
	var r: int = maxi(radius, 0)
	var b: int = maxi(thickness, 1)
	var margin: int = r + b + 2
	var side: int = margin * 2 + 1
	var img := Image.create(side, side, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	for y in range(side):
		for x in range(side):
			if not _inside(x, y, side, r):
				continue
			var inner: bool = x >= b and y >= b and x < side - b and y < side - b and _inside(x - b, y - b, side - 2 * b, maxi(r - b, 0))
			img.set_pixel(x, y, fill if inner else edge)
	var style := StyleBoxTexture.new()
	style.texture = ImageTexture.create_from_image(img)
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	style.content_margin_left = pad_x
	style.content_margin_right = pad_x
	style.content_margin_top = pad_y
	style.content_margin_bottom = pad_y
	return style

static func _inside(x: int, y: int, size: int, radius: int) -> bool:
	if radius == 0:
		return true
	var dx: int = mini(x, size - 1 - x)
	var dy: int = mini(y, size - 1 - y)
	# Deliberate integer staircase instead of smooth circular corners.
	if dx < radius and dy < radius:
		return dx + dy >= radius - 1
	return true
