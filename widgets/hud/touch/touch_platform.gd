extends RefCounted
class_name TouchPlatform

## Show on Web (including desktop browsers) and mobile exports only.
static func is_enabled() -> bool:
    return OS.get_name() in ["Web", "Android", "iOS"]
