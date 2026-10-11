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
	
