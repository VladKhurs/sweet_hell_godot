#!/usr/bin/env python3
"""Checks that RU/EN Dialogue Manager scripts retain the same control flow.

Does not read/compare translated prose or modify dialogue files.
Run: python3 tools/check_dialogues.py [PROJECT_DIR]
"""
from pathlib import Path
import re
import sys


def structure(path: Path):
    result = []
    for number, raw in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
        value = raw.strip()
        if not value or value.startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" \t"))
        # Titles, conditions, jumps and executable statements must match verbatim.
        if (value.startswith(("~ ", "if ", "elif ", "else:", "=> ", "do ", "$>", "$ "))
                or value in {"else", "=> END"}):
            result.append((number, f"{indent}:{value}"))
        # Players' choices may differ linguistically, but number/order/level must match.
        elif value.startswith("- "):
            result.append((number, f"{indent}:CHOICE"))
        # Keep markup tags that influence visuals/logic, e.g. [#bg=...].
        for tag in re.findall(r"\[#[^\]]+\]", value):
            result.append((number, f"{indent}:TAG {tag}"))
    return result


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]).resolve()
    ru_root, en_root = (root / "assets" / d for d in ("dialogues_ru", "dialogues_en"))
    if not ru_root.is_dir() or not en_root.is_dir():
        print("ОШИБКА: папки assets/dialogues_ru и assets/dialogues_en должны существовать")
        return 1
    ru = {str(p.relative_to(ru_root)): p for p in ru_root.rglob("*.dialogue")}
    en = {str(p.relative_to(en_root)): p for p in en_root.rglob("*.dialogue")}
    bad = False
    for missing in sorted(ru.keys() - en.keys()):
        print("ОШИБКА: отсутствует английский диалог:", missing)
        bad = True
    for missing in sorted(en.keys() - ru.keys()):
        print("ОШИБКА: отсутствует русский диалог:", missing)
        bad = True
    for rel in sorted(ru.keys() & en.keys()):
        left, right = structure(ru[rel]), structure(en[rel])
        for i in range(max(len(left), len(right))):
            a = left[i] if i < len(left) else None
            b = right[i] if i < len(right) else None
            if a is None or b is None or a[1] != b[1]:
                print(f"ОШИБКА {rel}, управляющий элемент {i+1}:")
                print("  RU:", f"строка {a[0]}: {a[1]}" if a else "элемент отсутствует")
                print("  EN:", f"строка {b[0]}: {b[1]}" if b else "элемент отсутствует")
                bad = True
                break  # Do not print every shifted element for one file.
    if not bad:
        print(f"OK: проверены {len(ru)} пар RU/EN. Ветвления, переходы и команды совпадают.")
    return int(bad)


if __name__ == "__main__":
    raise SystemExit(main())
