extends Area2D
class_name BasePickup

@export_category("Pickup")
@export var pickup_id: String = ""
var _picked_up: bool = false

func _ready() -> void:
	if not pickup_id.is_empty() and GameState.get_world_state(pickup_id, "collected") == true:
		queue_free()

func interact(interactor: Node) -> void:
	if _picked_up or not collect(interactor):
		return

	_picked_up = true
	if not pickup_id.is_empty():
		GameState.set_world_state(pickup_id, "collected", true)

	Inventory.print_inventory()
	queue_free()

func collect(_interactor: Node) -> bool:
	return false
	
