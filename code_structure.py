import os

def create_combined_file():
    ignored_extensions = ['.png', '.svg', '.webp', '.jpg', '.txt', '.ico', '.docx', '.pdf', '.sql', '.log', '.tscn', '.mp3', '.import', '.godot', '.cfg', '.uid', '.editorconfig', '.gitattributes', '.py', '.keystore', '.dialogue']
    ignored_directories = ['addons', '.git', 'node_modules', '.qodo', 'frontend', 'logs', '.godot', '.']
    ignored_files = ['package-lock.json', '.gitignore', '.browserslistrc', 'code.txt', 'create_result.py', 'copy_names.py', 'dialogue_manager.gd']
    output_filename = 'code.txt'

    with open(output_filename, 'w', encoding='utf-8') as result_file:
        for root, dirs, files in os.walk('.', topdown=True):
            dirs[:] = [d for d in dirs if d not in ignored_directories]

            for filename in files:
                if (filename == os.path.basename(__file__) or 
                    filename == output_filename or 
                    filename in ignored_files):
                    continue
                
                _, extension = os.path.splitext(filename)
                if extension.lower() in ignored_extensions:
                    continue

                file_path = os.path.join(root, filename)
                
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as current_file:
                        content = current_file.read()
                        
                        result_file.write(f'>>!>FILEPATH: {file_path}\n')
                        result_file.write(content)
                        result_file.write('\n<!<ENDOFFILE!<<\n')
                except Exception as e:
                    print(f"Не удалось прочитать файл {file_path}: {e}")

    print(f"Все файлы были успешно записаны в {output_filename}")

if __name__ == '__main__':
    create_combined_file()
