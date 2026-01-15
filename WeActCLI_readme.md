# WeActCLI - Display Utility for WeAct FS Display

[Русская версия](#weactcli---утилита-для-дисплея-weact-fs)

A console utility for displaying text and images on WeAct FS displays via serial port. Supports text scrolling, image display, and various input methods.

## Features

- **Text display** with automatic wrapping and font management
- **Image display** with multiple scaling modes
- **Text scrolling** with adjustable speed and direction
- **Multiple input sources**: command line, files, stdin
- **Encoding support** including UTF-8, Windows-1251, CP866
- **Screen clearing** functionality

## Requirements

- **Windows** (Windows 10/11 recommended)
- **WeAct FS display** connected via USB (virtual COM port)
- **CH340/CH341 drivers** if required for USB-UART adapter

## Installation

1. Download `WeActCLI.exe` from the releases section
2. Place in any directory (e.g., `C:\Tools\`)
3. Optional: Add to system PATH for command-line access

## Quick Start

```bash
# Display text
WeActCLI /p:3 "Hello World"

# Show image
WeActCLI /p:3 /image:photo.jpg

# Scroll text
WeActCLI /p:3 /s:30 "Long scrolling text..."

# Clear screen
WeActCLI /p:3 /CLS
```

## Complete Syntax

```
WeActCLI /p:X [/v][/c:YYY] [/f:"Font:Size"] [/s:Speed[:u|d]] [/center] [/CLS]
           [/file:"path.txt"] [/image:"path.jpg"[:mode[:WxH]]] [/quality:level]
           "text"
```

## Parameters

### Required
| Parameter | Description | Example |
|-----------|-------------|---------|
| `/p:X` | COM port number | `/p:3` for COM3 |

### Text Display
| Parameter | Description | Example |
|-----------|-------------|---------|
| `"text"` | Text to display (quotes for spaces) | `"Sample text"` |
| `/c:YYY` | Text color | `/c:green` |
| `/f:"Font:Size"` | Font name and size | `/f:Arial:10` |
| `/center` | Center text horizontally | `/center` |
| `/s:Speed[:u|d]` | Scroll speed and direction | `/s:30`, `/s:25.5:d` |

### File Operations
| Parameter | Description | Example |
|-----------|-------------|---------|
| `/file:"path"` | Load text from file | `/file:log.txt` |
| `/image:"path"` | Display image file | `/image:photo.jpg` |

### Image Parameters
| Parameter | Description | Example |
|-----------|-------------|---------|
| `:mode` | Image mode: 0=fit, 1=original, 2=centered | `/image:pic.jpg:1` |
| `:WxH` | Custom size for mode 2 | `/image:icon.png:2:64x64` |
| `/quality:level` | Image quality: fast/normal/high/bwfast/bwhigh | `/quality:high` |

### System
| Parameter | Description | Example |
|-----------|-------------|---------|
| `/CLS` | Clear screen | `/CLS` |
| `/v` | Verbose output | `/v` |
| `/?`, `/h` | Show help | `/?` |

## Color Options

Available colors: `red`, `green`, `blue`, `white` (default), `black`, `yellow`, `cyan`, `magenta`

## Usage Examples

### Basic Text Display
```bash
# Simple text
WeActCLI /p:3 "System Ready"

# Colored text with custom font
WeActCLI /p:4 /c:green /f:"Courier New":12 "OK: Tests passed"

# Centered warning
WeActCLI /p:3 /center /c:yellow "WARNING: High temperature"
```

### Scrolling Text
```bash
# Scroll up at 30px/sec
WeActCLI /p:3 /s:30 "News: Maintenance scheduled for tomorrow..."

# Scroll down at 25.5px/sec
WeActCLI /p:3 /s:25.5:d "Log: User login, File upload, DB update..."
```

### File Operations
```bash
# Display text file
WeActCLI /p:3 /file:status.txt

# Display log with scrolling
WeActCLI /p:3 /file:app.log /s:20

# Clear screen
WeActCLI /p:3 /CLS
```

### Image Display
```bash
# Full screen image
WeActCLI /p:3 /image:wallpaper.jpg

# Original size
WeActCLI /p:3 /image:icon.png:1

# Centered with custom size
WeActCLI /p:3 /image:logo.png:2:64x64

# High quality
WeActCLI /p:3 /image:photo.jpg /quality:high
```

### Input Redirection
```bash
# Pipe from command
echo "Time: %time%" | WeActCLI /p:3

# Redirect from file
WeActCLI /p:3 < data.txt

# PowerShell
Get-Process | Select-Object -First 5 Name,CPU | WeActCLI /p:3
```

## Image Display Modes

**Mode 0: Fit to Screen** (default)
- Scales image to fit display while maintaining aspect ratio
```bash
WeActCLI /p:3 /image:photo.jpg
```

**Mode 1: Original Size**
- Displays at original resolution from top-left corner
```bash
WeActCLI /p:3 /image:icon.png:1
```

**Mode 2: Centered with Custom Size**
- Centers image with specified dimensions
```bash
WeActCLI /p:3 /image:logo.png:2:100x50
```

## Image Quality Settings

| Level | Description | Use Case |
|-------|-------------|----------|
| `fast` | Fast rendering, lower quality | Simple icons |
| `normal` | Balanced quality/speed | Default |
| `high` | Best quality, slower | Photographs |
| `bwfast` | Fast black and white | Text images |
| `bwhigh` | High quality black and white | Monochrome images |

## Encoding Support

For Russian/Cyrillic text:

**PowerShell:**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

**CMD:**
```cmd
chcp 65001
```

**Recommended:**
```bash
WeActCLI /p:3 /file:utf8_text.txt
```

## Supported Image Formats

Formats supported by PureBasic's `LoadImage()`:
- JPEG (.jpg, .jpeg)
- PNG (.png)
- BMP (.bmp)
- TIFF (.tif, .tiff)

## Error Handling

Common issues:

1. **"Failed to initialize display"**
   - Check COM port number in Device Manager
   - Verify USB connection
   - Ensure drivers are installed

2. **"File not found"**
   - Use full paths
   - Enclose paths with spaces in quotes

3. **Text encoding issues**
   - Use UTF-8 encoded files
   - Set console encoding to UTF-8

## Return Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error |

## Building from Source

Requires PureBasic 6.21+:

```bash
pbcompiler WeActCLI.pb /CONSOLE /EXE "WeActCLI.exe"
```

---

# WeActCLI - Утилита для дисплея WeAct FS

Консольная утилита для вывода текста и изображений на дисплей WeAct FS через COM-порт. Поддерживает прокрутку текста, отображение изображений и различные источники ввода.

## Возможности

- **Вывод текста** с автоматическим переносом и управлением шрифтами
- **Отображение изображений** с несколькими режимами масштабирования
- **Прокрутка текста** с настраиваемой скоростью и направлением
- **Несколько источников ввода**: командная строка, файлы, stdin
- **Поддержка кодировок** включая UTF-8, Windows-1251, CP866
- **Функция очистки экрана**

## Требования

- **Windows** (рекомендуется Windows 10/11)
- **Дисплей WeAct FS** подключенный по USB (виртуальный COM-порт)
- **Драйверы CH340/CH341** если требуется для USB-UART адаптера

## Установка

1. Скачайте `WeActCLI.exe` из раздела релизов
2. Поместите в любую директорию (например, `C:\Tools\`)
3. Опционально: добавьте в системный PATH для доступа из командной строки

## Быстрый старт

```bash
# Вывести текст
WeActCLI /p:3 "Привет мир"

# Показать изображение
WeActCLI /p:3 /image:photo.jpg

# Прокрутить текст
WeActCLI /p:3 /s:30 "Длинный текст для прокрутки..."

# Очистить экран
WeActCLI /p:3 /CLS
```

## Полный синтаксис

```
WeActCLI /p:X [/v][/c:YYY] [/f:"Шрифт:Размер"] [/s:Скорость[:u|d]] [/center] [/CLS]
           [/file:"путь.txt"] [/image:"путь.jpg"[:режим[:ШxВ]]] [/quality:уровень]
           "текст"
```

## Параметры

### Обязательные
| Параметр | Описание | Пример |
|----------|----------|---------|
| `/p:X` | Номер COM-порта | `/p:3` для COM3 |

### Вывод текста
| Параметр | Описание | Пример |
|----------|----------|---------|
| `"текст"` | Текст для отображения (кавычки для пробелов) | `"Пример текста"` |
| `/c:YYY` | Цвет текста | `/c:green` |
| `/f:"Шрифт:Размер"` | Имя шрифта и размер | `/f:Arial:10` |
| `/center` | Центрировать текст по горизонтали | `/center` |
| `/s:Скорость[:u|d]` | Скорость и направление прокрутки | `/s:30`, `/s:25.5:d` |

### Работа с файлами
| Параметр | Описание | Пример |
|----------|----------|---------|
| `/file:"путь"` | Загрузить текст из файла | `/file:log.txt` |
| `/image:"путь"` | Отобразить файл изображения | `/image:photo.jpg` |

### Параметры изображений
| Параметр | Описание | Пример |
|----------|----------|---------|
| `:режим` | Режим изображения: 0=подгонка, 1=оригинал, 2=центрирование | `/image:pic.jpg:1` |
| `:ШxВ` | Пользовательский размер для режима 2 | `/image:icon.png:2:64x64` |
| `/quality:уровень` | Качество: fast/normal/high/bwfast/bwhigh | `/quality:high` |

### Системные
| Параметр | Описание | Пример |
|----------|----------|---------|
| `/CLS` | Очистить экран | `/CLS` |
| `/v` | Подробный вывод | `/v` |
| `/?`, `/h` | Показать справку | `/?` |

## Доступные цвета

Доступные цвета: `red` (красный), `green` (зеленый), `blue` (синий), `white` (белый, по умолчанию), `black` (черный), `yellow` (желтый), `cyan` (голубой), `magenta` (пурпурный)

## Примеры использования

### Базовый вывод текста
```bash
# Простой текст
WeActCLI /p:3 "Система готова"

# Цветной текст с пользовательским шрифтом
WeActCLI /p:4 /c:green /f:"Courier New":12 "OK: Тесты пройдены"

# Центрированное предупреждение
WeActCLI /p:3 /center /c:yellow "ПРЕДУПРЕЖДЕНИЕ: Высокая температура"
```

### Прокрутка текста
```bash
# Прокрутка вверх 30px/сек
WeActCLI /p:3 /s:30 "Новости: Техобслуживание запланировано на завтра..."

# Прокрутка вниз 25.5px/сек
WeActCLI /p:3 /s:25.5:d "Лог: Вход пользователя, Загрузка файла, Обновление БД..."
```

### Работа с файлами
```bash
# Вывести текстовый файл
WeActCLI /p:3 /file:status.txt

# Вывести лог с прокруткой
WeActCLI /p:3 /file:app.log /s:20

# Очистить экран
WeActCLI /p:3 /CLS
```

### Отображение изображений
```bash
# Изображение на весь экран
WeActCLI /p:3 /image:wallpaper.jpg

# Оригинальный размер
WeActCLI /p:3 /image:icon.png:1

# Центрирование с заданным размером
WeActCLI /p:3 /image:logo.png:2:64x64

# Высокое качество
WeActCLI /p:3 /image:photo.jpg /quality:high
```

### Перенаправление ввода
```bash
# Пайп из команды
echo "Время: %time%" | WeActCLI /p:3

# Перенаправление из файла
WeActCLI /p:3 < data.txt

# PowerShell
Get-Process | Select-Object -First 5 Name,CPU | WeActCLI /p:3
```

## Режимы отображения изображений

**Режим 0: Подгонка под экран** (по умолчанию)
- Масштабирует изображение под размер дисплея с сохранением пропорций
```bash
WeActCLI /p:3 /image:photo.jpg
```

**Режим 1: Оригинальный размер**
- Отображает в оригинальном разрешении из левого верхнего угла
```bash
WeActCLI /p:3 /image:icon.png:1
```

**Режим 2: Центрирование с заданным размером**
- Центрирует изображение с указанными размерами
```bash
WeActCLI /p:3 /image:logo.png:2:100x50
```

## Настройки качества изображений

| Уровень | Описание | Пример использования |
|---------|----------|----------------------|
| `fast` | Быстрый рендеринг, низкое качество | Простые иконки |
| `normal` | Сбалансированное качество/скорость | По умолчанию |
| `high` | Лучшее качество, медленнее | Фотографии |
| `bwfast` | Быстрое черно-белое | Текстовые изображения |
| `bwhigh` | Высококачественное черно-белое | Монохромные изображения |

## Поддержка кодировок

Для русского/кириллического текста:

**PowerShell:**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

**CMD:**
```cmd
chcp 65001
```

**Рекомендуется:**
```bash
WeActCLI /p:3 /file:utf8_text.txt
```

## Поддерживаемые форматы изображений

Форматы, поддерживаемые функцией `LoadImage()` в PureBasic:
- JPEG (.jpg, .jpeg)
- PNG (.png)
- BMP (.bmp)
- TIFF (.tif, .tiff)

## Обработка ошибок

Частые проблемы:

1. **"Не удалось инициализировать дисплей"**
   - Проверьте номер COM-порта в Диспетчере устройств
   - Проверьте USB-подключение
   - Убедитесь, что драйверы установлены

2. **"Файл не найден"**
   - Используйте полные пути
   - Заключайте пути с пробелами в кавычки

3. **Проблемы с кодировкой текста**
   - Используйте файлы в кодировке UTF-8
   - Установите кодировку консоли в UTF-8

## Коды возврата

| Код | Значение |
|-----|----------|
| 0 | Успех |
| 1 | Ошибка |

## Сборка из исходного кода

Требуется PureBasic 6.21+:

```bash
pbcompiler WeActCLI.pb /CONSOLE /EXE "WeActCLI.exe"
```
