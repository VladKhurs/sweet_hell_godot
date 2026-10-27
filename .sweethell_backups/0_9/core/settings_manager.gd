extends Node
signal language_changed

const PATH := "user://settings.cfg"
const TEXT := {
 "ru": {"play":"ИГРАТЬ", "settings":"НАСТРОЙКИ", "exit":"ВЫЙТИ", "exit_question":"Выйти из игры?", "yes":"ДА", "no":"НЕТ", "back":"НАЗАД", "volume":"ГРОМКОСТЬ", "language":"ЯЗЫК", "russian":"РУССКИЙ", "english":"ENGLISH", "pause":"ПАУЗА", "resume":"ВЕРНУТЬСЯ К ИГРЕ", "exit_menu":"ВЫЙТИ В ГЛАВНОЕ МЕНЮ", "lose_progress":"НЕСОХРАНЁННЫЙ ПРОГРЕСС\nБУДЕТ ПОТЕРЯН. ВЫЙТИ?", "confirm_exit":"ДА, ВЫЙТИ", "cancel":"ОТМЕНА"},
 "en": {"play":"PLAY", "settings":"SETTINGS", "exit":"EXIT", "exit_question":"Exit the game?", "yes":"YES", "no":"NO", "back":"BACK", "volume":"VOLUME", "language":"LANGUAGE", "russian":"РУССКИЙ", "english":"ENGLISH", "pause":"PAUSE", "resume":"RESUME GAME", "exit_menu":"EXIT TO MAIN MENU", "lose_progress":"UNSAVED PROGRESS\nWILL BE LOST. EXIT?", "confirm_exit":"YES, EXIT", "cancel":"CANCEL"}
}
var language: String = "ru"
var volume: float = 1.0

func _ready() -> void:
 var cfg := ConfigFile.new()
 if cfg.load(PATH) == OK:
  language = str(cfg.get_value("general", "language", "ru"))
  volume = clampf(float(cfg.get_value("audio", "volume", 1.0)), 0.0, 1.0)
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

func _apply_volume() -> void:
 var bus := AudioServer.get_bus_index("Master")
 if bus >= 0:
  AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.0001)))
  AudioServer.set_bus_mute(bus, is_zero_approx(volume))

func _save() -> void:
 var cfg := ConfigFile.new()
 cfg.set_value("general", "language", language)
 cfg.set_value("audio", "volume", volume)
 var result := cfg.save(PATH)
 if result != OK: push_warning("Settings save failed: %s" % result)
