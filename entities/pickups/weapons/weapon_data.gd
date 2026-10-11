extends Resource
class_name WeaponData


@export_category("Weapon")
@export var weapon_id: StringName
@export var weapon_name: String = ""
@export var sprite: Texture2D

@export_category("Combat")
@export_range(0, 100000, 1) var damage: int = 1
@export_range(0.0, 1000.0, 1.0) var attack_range: float = 16.0
@export_range(0.0, 60.0, 0.05) var attack_cooldown: float = 1.0
