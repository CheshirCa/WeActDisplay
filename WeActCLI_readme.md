# WeActCLI - Console Text and Image Display Utility for WeAct Display FS

[English](#english) | [Русский](#русский)

---

## English

WeActCLI is a powerful command-line utility for displaying text and images on WeAct Display FS via serial port (COM port). It supports multiple input sources, text formatting, scrolling, and image display modes.

### Features

- **Multiple Input Sources**:
  - Direct command-line text input
  - Text file loading with UTF-8 support
  - Image file display (multiple formats)
  - Pipe/redirect input from other programs
  - Standard input (stdin) support

- **Text Display Options**:
  - Static text display with word wrapping
  - Smooth vertical scrolling (up/down)
  - Customizable font, size, and color
  - Horizontal text centering
  - Precise text positioning (X/Y coordinates)
  - Overlay mode (display text without clearing screen)

- **Image Display Options**:
  - Fit to screen (maintain aspect ratio)
  - Original size display
  - Centered display with custom size
  - Multiple image quality settings

- **Advanced Features**:
  - Automatic font size adjustment to fit long words
  - Text line spacing control
  - Screen clearing option
  - Verbose mode for debugging
  - Comprehensive help system
  - Windows console encoding support (UTF-8, Windows-1251, CP866)

### Supported Image Formats
The utility supports all formats provided by the underlying WeAct display library, typically including:
- JPEG/JPG
- PNG
- BMP
- GIF

### Installation

1. **Prerequisites**:
   - Windows operating system
   - WeAct Display FS hardware
   - USB-to-serial drivers installed (if needed)
   - PureBasic compiler (for building from source)

2. **Binary Installation**:
   Download the pre-compiled `WeActCLI.exe` from the releases page.

3. **Building from Source**:
   ```bash
   # Requires PureBasic 6.30 or later
   pbcompiler WeActCLI.pb /CONSOLE /EXE WeActCLI.exe
   ```

### Command Line Syntax

```bash
WeActCLI /p:X [/v][/c:YYY] [/f:"Font Name":Size] [/s:Speed[:u|d]] [/center] [/x:X] [/y:Y] [/CLS] [/file:"path\name.txt"] [/image:"path\image.jpg"[:mode[:WxH]]] ["text"]
```

### Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `/p:X` | **Required** COM port number | `/p:3` for COM3 |
| `/c:YYY` | Text color | `/c:red`, `/c:blue`, `/c:white` |
| `/f:"Font":Size` | Font name and size | `/f:Arial:10`, `/f:"Times New Roman":12` |
| `/s:Speed[:u\|d]` | Scroll speed and direction | `/s:25.5`, `/s:40:d` |
| `/center` | Center text horizontally | |
| `/x:X` | X coordinate for text (overlay mode) | `/x:10` |
| `/y:Y` | Y coordinate for text (overlay mode) | `/y:20` |
| `/CLS` | Clear screen only | |
| `/file:"path"` | Load text from file | `/file:log.txt` |
| `/image:"path"[:mode[:WxH]]` | Display image | `/image:photo.jpg:0`, `/image:logo.png:2:64x64` |
| `/v` | Verbose mode | |
| `text` | Text to display (use quotes for spaces) | `"Hello World"` |

### Color Options
- `red`, `green`, `blue`, `white`, `black`, `yellow`, `cyan`, `magenta`

### Image Modes
- `0` - Fit to screen (default)
- `1` - Original size at position (0,0)
- `2` - Centered with optional custom size

### Usage Examples

1. **Display simple text**:
   ```bash
   WeActCLI /p:3 "Hello World"
   ```

2. **Display text with custom font and color**:
   ```bash
   WeActCLI /p:3 /c:red /f:Arial:12 "Warning: System Alert"
   ```

3. **Display scrolling text**:
   ```bash
   WeActCLI /p:3 /s:25.5 "This text will scroll upwards"
   ```

4. **Display text from file**:
   ```bash
   WeActCLI /p:3 /file:log.txt
   ```

5. **Display image**:
   ```bash
   WeActCLI /p:3 /image:photo.jpg
   ```

6. **Display centered image with custom size**:
   ```bash
   WeActCLI /p:3 /image:logo.png:2:128x64
   ```

7. **Pipe text from another program**:
   ```bash
   echo "Current time: %time%" | WeActCLI /p:3
   ```

8. **Clear screen only**:
   ```bash
   WeActCLI /p:3 /CLS
   ```

9. **Display text at specific position (overlay)**:
   ```bash
   WeActCLI /p:3 /x:50 /y:100 "Status: OK"
   ```

10. **Multi-line text with line breaks**:
    ```bash
    WeActCLI /p:3 "Line 1\nLine 2\nLine 3"
    ```

### Encoding Support

For proper text display, especially with non-English characters:

#### PowerShell:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
WeActCLI /p:3 "Русский текст"
```

#### Command Prompt (CMD):
```cmd
chcp 65001
WeActCLI /p:3 "Русский текст"
```

#### Text Files:
Use UTF-8 encoded text files for best results.

### Error Handling

Common error messages and solutions:

1. **"Error: Failed to initialize display on COMx"**:
   - Check COM port number
   - Verify display is connected and powered
   - Ensure correct drivers are installed

2. **"Error: File not found or empty"**:
   - Verify file path is correct
   - Check file permissions

3. **"Error: No content specified"**:
   - Provide text, file, or image parameter
   - Or use `/CLS` to clear screen

### Technical Details

- **Text Rendering**: Uses Windows system fonts via GDI
- **Image Processing**: Uses PureBasic's image library with optional scaling

### License

This project is provided as-is. Refer to the WeAct display library for specific licensing details.

### Support

For issues and questions:
- Check the troubleshooting section above
- Review the help (`WeActCLI /?`)
- Contact hardware manufacturer for WeAct Display FS support

---

## Русский

WeActCLI - мощная консольная утилита для отображения текста и изображений на дисплее WeAct Display FS через последовательный порт (COM-порт). Поддерживает несколько источников ввода, форматирование текста, прокрутку и режимы отображения изображений.

### Возможности

- **Несколько источников ввода**:
  - Прямой ввод текста из командной строки
  - Загрузка текста из файлов с поддержкой UTF-8
  - Отображение файлов изображений (несколько форматов)
  - Ввод через конвейер (pipe) из других программ
  - Поддержка стандартного ввода (stdin)

- **Параметры отображения текста**:
  - Статическое отображение текста с переносом слов
  - Плавная вертикальная прокрутка (вверх/вниз)
  - Настраиваемый шрифт, размер и цвет
  - Горизонтальное выравнивание по центру
  - Точное позиционирование текста (координаты X/Y)
  - Режим наложения (отображение без очистки экрана)

- **Параметры отображения изображений**:
  - Подгонка под экран (с сохранением пропорций)
  - Отображение в исходном размере
  - Отображение по центру с произвольным размером
  - Несколько настроек качества изображения

- **Расширенные возможности**:
  - Автоматическая регулировка размера шрифта для длинных слов
  - Управление межстрочным интервалом
  - Опция очистки экрана
  - Подробный режим для отладки
  - Полноценная система помощи
  - Поддержка кодировок Windows-консоли (UTF-8, Windows-1251, CP866)

### Поддерживаемые форматы изображений
Утилита поддерживает все форматы, предоставляемые базовой библиотекой дисплея WeAct, обычно включая:
- JPEG/JPG
- PNG
- BMP
- GIF

### Установка

1. **Предварительные требования**:
   - Операционная система Windows
   - Оборудование WeAct Display FS
   - Установленные драйверы USB-to-serial (при необходимости)
   - Компилятор PureBasic (для сборки из исходного кода)

2. **Установка бинарного файла**:
   Скачайте предварительно скомпилированный `WeActCLI.exe` со страницы релизов.

3. **Сборка из исходного кода**:
   ```bash
   # Требуется PureBasic 6.30 или новее
   pbcompiler WeActCLI.pb /CONSOLE /EXE WeActCLI.exe
   ```

### Синтаксис командной строки

```bash
WeActCLI /p:X [/v][/c:YYY] [/f:"Имя шрифта":Размер] [/s:Скорость[:u|d]] [/center] [/x:X] [/y:Y] [/CLS] [/file:"путь\имя.txt"] [/image:"путь\изображение.jpg"[:режим[:ШxВ]]] ["текст"]
```

### Параметры

| Параметр | Описание | Пример |
|-----------|-------------|---------|
| `/p:X` | **Обязательный** Номер COM-порта | `/p:3` для COM3 |
| `/c:YYY` | Цвет текста | `/c:red`, `/c:blue`, `/c:white` |
| `/f:"Шрифт":Размер` | Имя шрифта и размер | `/f:Arial:10`, `/f:"Times New Roman":12` |
| `/s:Скорость[:u\|d]` | Скорость и направление прокрутки | `/s:25.5`, `/s:40:d` |
| `/center` | Выравнивание текста по центру | |
| `/x:X` | Координата X для текста (режим наложения) | `/x:10` |
| `/y:Y` | Координата Y для текста (режим наложения) | `/y:20` |
| `/CLS` | Только очистка экрана | |
| `/file:"путь"` | Загрузка текста из файла | `/file:log.txt` |
| `/image:"путь"[:режим[:ШxВ]]` | Отображение изображения | `/image:photo.jpg:0`, `/image:logo.png:2:64x64` |
| `/v` | Подробный режим | |
| `текст` | Текст для отображения (используйте кавычки для пробелов) | `"Привет Мир"` |

### Доступные цвета
- `red` (красный), `green` (зеленый), `blue` (синий), `white` (белый), `black` (черный), `yellow` (желтый), `cyan` (голубой), `magenta` (пурпурный)

### Режимы изображений
- `0` - Подгонка под экран (по умолчанию)
- `1` - Оригинальный размер в позиции (0,0)
- `2` - По центру с произвольным размером

### Примеры использования

1. **Отображение простого текста**:
   ```bash
   WeActCLI /p:3 "Привет Мир"
   ```

2. **Отображение текста с произвольным шрифтом и цветом**:
   ```bash
   WeActCLI /p:3 /c:red /f:Arial:12 "Внимание: Системная тревога"
   ```

3. **Отображение прокручиваемого текста**:
   ```bash
   WeActCLI /p:3 /s:25.5 "Этот текст будет прокручиваться вверх"
   ```

4. **Отображение текста из файла**:
   ```bash
   WeActCLI /p:3 /file:log.txt
   ```

5. **Отображение изображения**:
   ```bash
   WeActCLI /p:3 /image:photo.jpg
   ```

6. **Отображение изображения по центру с произвольным размером**:
   ```bash
   WeActCLI /p:3 /image:logo.png:2:128x64
   ```

7. **Передача текста из другой программы**:
   ```bash
   echo "Текущее время: %time%" | WeActCLI /p:3
   ```

8. **Только очистка экрана**:
   ```bash
   WeActCLI /p:3 /CLS
   ```

9. **Отображение текста в определенной позиции (наложение)**:
   ```bash
   WeActCLI /p:3 /x:50 /y:100 "Статус: OK"
   ```

10. **Многострочный текст с разрывами строк**:
    ```bash
    WeActCLI /p:3 "Строка 1\nСтрока 2\nСтрока 3"
    ```

### Поддержка кодировок

Для правильного отображения текста, особенно с неанглийскими символами:

#### PowerShell:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
WeActCLI /p:3 "Русский текст"
```

#### Командная строка (CMD):
```cmd
chcp 65001
WeActCLI /p:3 "Русский текст"
```

#### Текстовые файлы:
Используйте текстовые файлы в кодировке UTF-8 для лучших результатов.

### Обработка ошибок

Частые сообщения об ошибках и их решения:

1. **"Error: Failed to initialize display on COMx"**:
   - Проверьте номер COM-порта
   - Убедитесь, что дисплей подключен и включен
   - Убедитесь, что установлены правильные драйверы

2. **"Error: File not found or empty"**:
   - Проверьте правильность пути к файлу
   - Проверьте права доступа к файлу

3. **"Error: No content specified"**:
   - Укажите текст, файл или параметр изображения
   - Или используйте `/CLS` для очистки экрана

### Технические детали

- **Отрисовка текста**: Использует системные шрифты Windows через GDI
- **Обработка изображений**: Использует библиотеку изображений PureBasic с опциональным масштабированием

### Лицензия

Проект предоставляется "как есть". Обратитесь к библиотеке дисплея WeAct для получения информации о лицензировании.

### Поддержка

При возникновении проблем и вопросов:
- Проверьте раздел устранения неполадок выше
- Ознакомьтесь со справкой (`WeActCLI /?`)
- Обратитесь к производителю оборудования для получения поддержки WeAct Display FS
