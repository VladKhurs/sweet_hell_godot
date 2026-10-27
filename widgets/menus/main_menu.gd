extends Control
@export_file("*.tscn") var new_game_scene: String = "res://levels/0_forest/0_forest.tscn"
const SETTINGS := preload("res://widgets/menus/settings_panel.gd")
@onready var play_button: Button = $Menu/Play
@onready var settings_button: Button = $Menu/Settings
@onready var exit_button: Button = $Menu/Exit
@onready var confirm_panel: Control = $Confirm
var _settings_panel: Control
var _new_game_button: Button
var _confirm_new_game: bool = false
const SWEET_BUTTON := preload("res://widgets/buttons/sweet_button.gd")

func _ready() -> void:
 _new_game_button = SWEET_BUTTON.new() as Button
 _new_game_button.name = "NewGame"
 _new_game_button.custom_minimum_size = play_button.custom_minimum_size
 _new_game_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 $Menu.add_child(_new_game_button)
 $Menu.move_child(_new_game_button, 1)
 _new_game_button.pressed.connect(_ask_new_game)
 play_button.pressed.connect(_on_play)
 settings_button.pressed.connect(_open_settings)
 exit_button.pressed.connect(_ask_exit)
 $Confirm/Content/Buttons/Yes.pressed.connect(_confirm_action)
 $Confirm/Content/Buttons/No.pressed.connect(_dismiss_confirm)
 confirm_panel.hide()
 $Notice.hide()
 SettingsManager.language_changed.connect(_refresh)
 _refresh()
 play_button.grab_focus()

func _on_play() -> void:
 if SaveManager.has_save():
  if not SaveManager.restore_game():
   push_error("SaveManager: cannot continue this save")
  return
 _start_new_game()

func _ask_exit() -> void:
 _confirm_new_game = false
 confirm_panel.show()
 _refresh()

func _ask_new_game() -> void:
 _confirm_new_game = true
 confirm_panel.show()
 _refresh()

func _confirm_action() -> void:
 if not _confirm_new_game:
  get_tree().quit()
  return
 if not SaveManager.delete_save():
  push_error("Unable to delete old save; new game was not started")
  return
 _start_new_game()

func _dismiss_confirm() -> void:
 confirm_panel.hide()
 _confirm_new_game = false
 _refresh()

func _start_new_game() -> void:
 SaveManager.reset_playtime()
 GameState.clear_all()
 Inventory.clear()
 Game.current_health = Game.max_health
 Game.is_invulnerable = false
 Game.load_level(new_game_scene)

func _refresh() -> void:
 play_button.text = SettingsManager.tr_key("continue") if SaveManager.has_save() else SettingsManager.tr_key("play")
 _new_game_button.text = SettingsManager.tr_key("new_game")
 _new_game_button.visible = SaveManager.has_save()
 settings_button.text = SettingsManager.tr_key("settings")
 exit_button.text = SettingsManager.tr_key("exit")
 $Confirm/Content/Question.text = SettingsManager.tr_key("new_game_question") if _confirm_new_game else SettingsManager.tr_key("exit_question")
 $Confirm/Content/Buttons/Yes.text = SettingsManager.tr_key("yes")
 $Confirm/Content/Buttons/No.text = SettingsManager.tr_key("no")

func _open_settings() -> void:
 if is_instance_valid(_settings_panel): return
 _settings_panel = Control.new()
 _settings_panel.set_script(SETTINGS)
 add_child(_settings_panel)
 _settings_panel.closed.connect(func(): settings_button.grab_focus())

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel") and confirm_panel.visible:
  _dismiss_confirm()
  get_viewport().set_input_as_handled()
