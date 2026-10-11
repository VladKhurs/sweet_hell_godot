extends BasePickup
class_name WeaponPickup


@export_category("Weapon")
@export var weapon_data: WeaponData


func _ready() -> void:
	super()

	if is_queued_for_deletion():
		return

	if weapon_data == null:
		return

	var sprite := get_node_or_null("Sprite2D") as Sprite2D

	if sprite:
		sprite.texture = weapon_data.sprite


func collect(_interactor: Node) -> bool:
	if weapon_data == null:
		push_warning("%s: weapon_data не назначен" % name)
		return false

	if Inventory.has_weapon(weapon_data.weapon_id):
		return false
	
	return Inventory.add_weapon(weapon_data)
