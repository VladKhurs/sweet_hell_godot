extends Node

signal changed

var currencies: Dictionary = {}
var weapons: Dictionary = {}
var equipped_weapon_id: StringName = &""

func add_currency(currency_id: String, amount: int) -> void:
	if amount <= 0: return
	currencies[currency_id] = get_currency(currency_id) + amount
	changed.emit()

func get_currency(currency_id: String) -> int:
	return currencies.get(currency_id, 0)

func spend_currency(currency_id: String, amount: int) -> bool:
	if amount <= 0 or get_currency(currency_id) < amount:
		return false
	currencies[currency_id] -= amount
	changed.emit()
	return true

func add_weapon(weapon: WeaponData) -> bool:
	if not weapon or weapon.weapon_id.is_empty() or weapons.has(weapon.weapon_id):
		return false
	weapons[weapon.weapon_id] = weapon
	if equipped_weapon_id.is_empty():
		equipped_weapon_id = weapon.weapon_id
	changed.emit()
	return true

func equip_weapon(weapon_id: StringName) -> bool:
	if not weapons.has(weapon_id):
		return false
	equipped_weapon_id = weapon_id
	changed.emit()
	return true

func get_equipped_weapon() -> WeaponData:
	return weapons.get(equipped_weapon_id)

func has_weapon(weapon_id: StringName) -> bool:
	return weapons.has(weapon_id)

func get_weapon(weapon_id: StringName) -> WeaponData:
	return weapons.get(weapon_id)

func clear() -> void:
	currencies.clear()
	weapons.clear()
	equipped_weapon_id = &""
	changed.emit()

func print_inventory() -> void:
	print("=== INVENTORY ===", "\nCurrencies: ", currencies, "\nWeapons: ", weapons.keys())

## Only IDs and resource paths are saved, never WeaponData objects.
func to_save_data() -> Dictionary:
	var saved_weapons: Array[Dictionary] = []
	for item in weapons.values():
		var weapon: WeaponData = item as WeaponData
		if weapon == null:
			return {}
		if weapon.resource_path.is_empty() or not weapon.resource_path.begins_with("res://"):
			push_error("Inventory: weapon %s must be a saved .tres resource" % weapon.weapon_id)
			return {}
		saved_weapons.append({"id": str(weapon.weapon_id), "path": weapon.resource_path})
	return {
		"currencies": currencies.duplicate(true),
		"weapons": saved_weapons,
		"equipped": str(equipped_weapon_id),
	}

func load_save_data(data: Dictionary) -> bool:
	if not data.get("currencies") is Dictionary or not data.get("weapons") is Array:
		return false
	var next_currencies: Dictionary = {}
	for id in data["currencies"]:
		var amount: Variant = data["currencies"][id]
		if not (id is String or id is StringName) or not (amount is int or amount is float):
			return false
		if amount < 0 or amount != floor(amount):
			return false
		next_currencies[str(id)] = int(amount)

	var next_weapons: Dictionary = {}
	for entry in data["weapons"]:
		if not (entry is Dictionary) or not (entry.get("id") is String) or not (entry.get("path") is String):
			return false
		var path: String = entry["path"]
		if not path.begins_with("res://entities/pickups/weapons/") or not path.ends_with(".tres"):
			return false
		var weapon := ResourceLoader.load(path) as WeaponData
		if weapon == null or str(weapon.weapon_id) != entry["id"] or next_weapons.has(weapon.weapon_id):
			return false
		next_weapons[weapon.weapon_id] = weapon

	var selected: StringName = StringName(str(data.get("equipped", "")))
	if not selected.is_empty() and not next_weapons.has(selected):
		return false
	currencies = next_currencies
	weapons = next_weapons
	equipped_weapon_id = selected
	changed.emit()
	return true
	
