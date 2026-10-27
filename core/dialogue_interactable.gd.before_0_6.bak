extends StaticBody2D
class_name DialogueInteractable


@export_category("Dialogue")
@export var dialogue_resource: DialogueResource
@export var dialogue_title: String = "start"


var _dialogue_active := false


func interact(interactor: Node):
	if _dialogue_active:
		return

	if dialogue_resource == null:
		push_warning("%s: dialogue_resource не назначен" % name)
		return

	_dialogue_active = true

	if interactor.has_method("set_controls_enabled"):
		interactor.set_controls_enabled(false)

	DialogueManager.show_dialogue_balloon(
		dialogue_resource,
		dialogue_title
	)

	await DialogueManager.dialogue_ended

	if is_instance_valid(interactor) and interactor.has_method("set_controls_enabled"):
		interactor.set_controls_enabled(true)

	_dialogue_active = false
