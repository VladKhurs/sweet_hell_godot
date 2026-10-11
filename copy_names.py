#!/usr/bin/env python3
"""
Рекурсивно собирает имена всех файлов и папок в текущей директории,
игнорируя указанные папки (по умолчанию node_modules, .git, __pycache__ и т.д.).
Результат сохраняется в файл file_structure.txt.
"""

import os
import sys
import argparse
from pathlib import Path

# Стандартные папки, которые игнорируются, если не указано иное
DEFAULT_IGNORE_DIRS = ['node_modules', '.git', '__pycache__', '.idea', '.vscode', 'dev', 'public', '.godot', 'assets']

def main():
    parser = argparse.ArgumentParser(description='Собрать имена всех файлов и папок, игнорируя указанные папки.')
    parser.add_argument('-i', '--ignore', nargs='+', default=[],
                        help='Список имён папок для игнорирования (по умолчанию: {})'.format(', '.join(DEFAULT_IGNORE_DIRS)))
    args = parser.parse_args()

    # Объединяем стандартные и пользовательские папки для игнорирования
    ignore_dirs = set(DEFAULT_IGNORE_DIRS) | set(args.ignore)

    root_dir = Path.cwd()
    output_file = root_dir / "file_structure.txt"

    all_items = []

    for dirpath, dirnames, filenames in os.walk(root_dir):
        current_path = Path(dirpath)

        # Удаляем из dirnames те, которые нужно игнорировать
        # (чтобы os.walk не заходил в них)
        for d in list(dirnames):
            if d in ignore_dirs:
                dirnames.remove(d)

        # Относительный путь текущей директории
        try:
            rel_dir = current_path.relative_to(root_dir)
        except ValueError:
            rel_dir = current_path.name

        # Добавляем саму директорию (кроме корневой)
        if rel_dir != Path('.'):
            all_items.append(str(rel_dir))

        # Добавляем файлы внутри директории
        for file in filenames:
            # Игнорируем сам создаваемый файл file_structure.txt в корневой папке
            if current_path == root_dir and file == "file_structure.txt":
                continue
            file_rel = current_path / file
            all_items.append(str(file_rel.relative_to(root_dir)))

    # Запись результата в файл
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            for item in sorted(all_items):
                f.write(item + '\n')
        print(f"Список успешно записан в file_structure.txt")
    except IOError as e:
        print(f"Ошибка записи в файл: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
