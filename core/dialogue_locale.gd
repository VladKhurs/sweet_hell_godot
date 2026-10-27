extends RefCounted
class_name DialogueLocale

const SOURCE_DIR := "res://assets/dialogues/"
const RU_DIR := "res://assets/dialogues_ru/"
const EN_DIR := "res://assets/dialogues_en/"

# All scene references remain valid; only the played resource is swapped.
static func resolve(source: DialogueResource) -> DialogueResource:
    if source == null:
        return null
    var path: String = source.resource_path
    var relative: String = ""
    for prefix in [SOURCE_DIR, RU_DIR, EN_DIR]:
        if path.begins_with(prefix):
            relative = path.trim_prefix(prefix)
            break
    if relative.is_empty():
        return source
    var locale: String = SettingsManager.language
    var selected: String = (EN_DIR if locale == "en" else RU_DIR) + relative
    if not ResourceLoader.exists(selected):
        push_warning("Missing dialogue: %s; using Russian" % selected)
        selected = RU_DIR + relative
    if not ResourceLoader.exists(selected):
        return source
    var result := load(selected) as DialogueResource
    return result if result != null else source
