extends BasePickup
class_name CurrencyPickup


@export_category("Currency")
@export var currency_id: String = ""
@export_range(1, 100000, 1) var amount: int = 1


func collect(_interactor: Node) -> bool:
	if currency_id.is_empty():
		push_warning("%s: currency_id не указан" % name)
		return false

	Inventory.add_currency(currency_id, amount)

	return true
