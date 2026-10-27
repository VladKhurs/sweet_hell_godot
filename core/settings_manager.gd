extends Node
signal language_changed
signal touch_settings_changed

const PATH := "user://settings.cfg"
const TEXT := {
 "ru": {"play":"ИГРАТЬ", "continue":"ПРОДОЛЖИТЬ", "new_game":"НОВАЯ ИГРА", "new_game_question":"НАЧАТЬ ЗАНОВО?\nСОХРАНЕНИЕ БУДЕТ\nУДАЛЕНО!", "settings":"НАСТРОЙКИ", "exit":"ВЫЙТИ", "exit_question":"Выйти из игры?", "yes":"ДА", "no":"НЕТ", "back":"НАЗАД", "volume":"ГРОМКОСТЬ", "language":"ЯЗЫК", "russian":"РУССКИЙ", "english":"ENGLISH", "pause":"ПАУЗА", "resume":"ВЕРНУТЬСЯ К ИГРЕ", "exit_menu":"ВЫЙТИ В ГЛАВНОЕ МЕНЮ", "lose_progress":"НЕСОХРАНЁННЫЙ ПРОГРЕСС\nБУДЕТ ПОТЕРЯН. ВЫЙТИ?", "confirm_exit":"ДА, ВЫЙТИ", "cancel":"ОТМЕНА", "exit_recent":"ВЫЙТИ В ГЛАВНОЕ МЕНЮ?", "save_complete":"ФАЙЛ СОХРАНЁН", "play_time":"ВРЕМЯ В ИГРЕ", "touch_controls":"СЕНСОРНОЕ УПРАВЛЕНИЕ", "touch_size":"РАЗМЕР", "touch_opacity":"ПРОЗРАЧНОСТЬ", "touch_attack":"АТК", "touch_jump":"ПРЖ","tutorial_move_pc":"ДВИЖЕНИЕ: A/D ИЛИ СТРЕЛКИ","tutorial_move_touch":"ДВИЖЕНИЕ: ЛЕВЫЙ ДЖОЙСТИК","tutorial_jump_pc":"ПРЫЖОК: ПРОБЕЛ ИЛИ W","tutorial_jump_touch":"ПРЫЖОК: КНОПКА ПРЖ","tutorial_interact_pc":"ДИАЛОГИ И ПРЕДМЕТЫ: E","tutorial_interact_touch":"ДИАЛОГИ И ПРЕДМЕТЫ: E","tutorial_attack_pc":"АТАКА СО СКОВОРОДОЙ: F","tutorial_attack_touch":"АТАКА: КНОПКА АТК","tutorial_transform_pc":"ПРЕВРАЩЕНИЕ В ПИНГВИНА: TAB","tutorial_transform_touch":"ПРЕВРАЩЕНИЕ В ПИНГВИНА: TAB","tutorial_grid_pc":"ПО КЛЕТКАМ: WASD ИЛИ СТРЕЛКИ","tutorial_grid_touch":"ПО КЛЕТКАМ: ДЖОЙСТИК","tutorial_beat_pc":"В РИТМ МУЗЫКЕ: WASD","tutorial_beat_touch":"В РИТМ МУЗЫКЕ: ДЖОЙСТИК"},
 "en": {"play":"PLAY", "continue":"CONTINUE", "new_game":"NEW GAME", "new_game_question":"START OVER?\nTHE OLD SAVE WILL\nBE DELETED!", "settings":"SETTINGS", "exit":"EXIT", "exit_question":"Exit the game?", "yes":"YES", "no":"NO", "back":"BACK", "volume":"VOLUME", "language":"LANGUAGE", "russian":"РУССКИЙ", "english":"ENGLISH", "pause":"PAUSE", "resume":"RESUME GAME", "exit_menu":"EXIT TO MAIN MENU", "lose_progress":"UNSAVED PROGRESS\nWILL BE LOST. EXIT?", "confirm_exit":"YES, EXIT", "cancel":"CANCEL", "exit_recent":"EXIT TO MAIN MENU?", "save_complete":"GAME SAVED", "play_time":"PLAY TIME", "touch_controls":"TOUCH CONTROLS", "touch_size":"SIZE", "touch_opacity":"OPACITY", "touch_attack":"ATK", "touch_jump":"JUMP","tutorial_move_pc":"MOVE: A/D OR ARROW KEYS","tutorial_move_touch":"MOVE: LEFT JOYSTICK","tutorial_jump_pc":"JUMP: SPACE OR W","tutorial_jump_touch":"JUMP: JUMP BUTTON","tutorial_interact_pc":"TALK AND PICK UP: E","tutorial_interact_touch":"TALK AND PICK UP: E BUTTON","tutorial_attack_pc":"ATTACK WITH PAN: F","tutorial_attack_touch":"ATTACK: ATK BUTTON","tutorial_transform_pc":"TURN INTO A PENGUIN: TAB","tutorial_transform_touch":"TURN INTO A PENGUIN: TAB BUTTON","tutorial_grid_pc":"GRID MOVE: WASD OR ARROWS","tutorial_grid_touch":"GRID MOVE: JOYSTICK","tutorial_beat_pc":"MOVE TO THE BEAT: WASD","tutorial_beat_touch":"MOVE TO THE BEAT: JOYSTICK"}
}
var language: String = "ru"
var volume: float = 1.0
var touch_scale: float = 1.0
var touch_opacity: float = 1.0

func _ready() -> void:
 var cfg := ConfigFile.new()
 if cfg.load(PATH) == OK:
  language = str(cfg.get_value("general", "language", "ru"))
  volume = clampf(float(cfg.get_value("audio", "volume", 1.0)), 0.0, 1.0)
  touch_scale = clampf(float(cfg.get_value("touch", "scale", 1.0)), 0.7, 1.3)
  touch_opacity = clampf(float(cfg.get_value("touch", "opacity", 1.0)), 0.35, 1.0)
 if not TEXT.has(language): language = "ru"
 _apply_volume()

func tr_key(key: String) -> String:
 return TEXT[language].get(key, key)

func set_language(value: String) -> void:
 if not TEXT.has(value) or value == language: return
 language = value
 _save()
 language_changed.emit()

func set_volume(value: float) -> void:
 volume = clampf(value, 0.0, 1.0)
 _apply_volume()
 _save()

func set_touch_scale(value: float) -> void:
 touch_scale = clampf(value, 0.7, 1.3)
 _save()
 touch_settings_changed.emit()

func set_touch_opacity(value: float) -> void:
 touch_opacity = clampf(value, 0.35, 1.0)
 _save()
 touch_settings_changed.emit()

func _apply_volume() -> void:
 var bus := AudioServer.get_bus_index("Master")
 if bus >= 0:
  AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.0001)))
  AudioServer.set_bus_mute(bus, is_zero_approx(volume))

func _save() -> void:
 var cfg := ConfigFile.new()
 cfg.set_value("general", "language", language)
 cfg.set_value("audio", "volume", volume)
 cfg.set_value("touch", "scale", touch_scale)
 cfg.set_value("touch", "opacity", touch_opacity)
 var result := cfg.save(PATH)
 if result != OK: push_warning("Settings save failed: %s" % result)
