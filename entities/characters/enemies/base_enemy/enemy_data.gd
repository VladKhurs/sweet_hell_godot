extends Resource
class_name EnemyData


@export_category("Enemy")
@export var enemy_id: StringName
@export var enemy_name: String = ""
@export var sprite: Texture2D

@export_category("Stats")
@export_range(0.0, 500.0, 1.0) var speed: float = 30.0
@export_range(1, 1000, 1) var max_health: int = 3
@export_range(0, 1000, 1) var damage: int = 1

@export_category("Loot")
@export var loot: Array[PackedScene] = []
