# WeActCLI - Console Utility for WeAct FS Display

[Русская версия](#weactcli---консольная-утилита-для-дисплея-weact-fs)

A command-line utility for displaying text and images on WeAct FS displays via COM port. Supports multiple display modes, text scrolling, image display, and advanced encoding handling.

## Features

### 📝 Text Display
- **Multiple input sources**: direct text, files, stdin redirection
- **Smart text wrapping**: automatic line breaks at pixel level
- **Font management**: custom fonts and sizes with automatic adjustment
- **Text colors**: 8 predefined colors
- **Centering**: horizontal text alignment

### 🖼️ Image Display (New!)
- **Multiple display modes**: fit to screen, original size, centered with custom size
- **Format support**: JPEG, PNG, BMP, and other formats supported by PureBasic
- **Size control**: specify exact dimensions for centered display

### 🔄 Scrolling Modes
- **Smooth scrolling**: configurable speed (pixels/second)
- **Dual direction**: scroll up or down
- **Continuous display**: handles long text seamlessly

### 🌐 Encoding Support
- **Automatic detection**: detects console and file encodings
- **UTF-8 support**: native UTF-8 handling
- **Legacy encodings**: Windows-1251, CP866, and others
- **Smart conversion**: automatic conversion to UTF-8 for display

### 🛠️ Utility Functions
- **Screen clearing**: standalone screen reset
- **Verbose mode**: detailed operation logging
- **Error handling**: comprehensive error messages and diagnostics

## Requirements

- **Windows** (tested on Windows 10/11)
- **WeAct FS display** with USB connection (virtual COM port)
- **CH340/CH341 drivers** for USB-UART adapter (if required)
- **PureBasic runtime** (included in executable)

## Installation

1. Download the latest `WeActCLI.exe` from [Releases](https://github.com/yourusername/WeActCLI/releases)
2. Place it in any directory (e.g., `C:\Tools\`)
3. Optional: Add the directory to your system PATH for global access

## Quick Start

```bash
# Display simple text
WeActCLI /p:3 "Hello World!"

# Show an image
WeActCLI /p:3 /image:photo.jpg

# Scroll text
WeActCLI /p:3 /s:30 "Long text for scrolling..."

# Clear screen
WeActCLI /p:3 /CLS
```

## Complete Syntax

```
WeActCLI /p:X [/v][/c:YYY] [/f:"Font:Size"] [/s:Speed[:u|d]] [/center] [/CLS]
           [/file:"path.txt"] [/image:"path.jpg"[:mode[:WxH]]] [/quality:level]
           "text"
```

## Parameters Reference

### Required
| Parameter | Description | Example |
|-----------|-------------|---------|
| `/p:X` | COM port number (REQUIRED) | `/p:3` for COM3 |

### Text Display
| Parameter | Description | Example |
|-----------|-------------|---------|
| `"text"` | Text to display (use quotes for spaces) | `"Hello World"` |
| `/c:YYY` | Text color | `/c:red`, `/c:green` |
| `/f:"Font:Size"` | Font name and size | `/f:Arial:10` |
| `/center` | Center text horizontally | `/center` |
| `/s:Speed[:u|d]` | Scroll speed and direction | `/s:30`, `/s:25.5:d` |

### File Operations
| Parameter | Description | Example |
|-----------|-------------|---------|
| `/file:"path"` | Load text from file | `/file:log.txt` |
| `/image:"path"` | Display image file | `/image:photo.jpg` |

### Image Parameters (New!)
| Parameter | Description | Example |
|-----------|-------------|---------|
| `:mode` | Image display mode (0-2) | `/image:pic.jpg:1` |
| `:WxH` | Custom size for mode 2 | `/image:icon.png:2:64x64` |
| `/quality:level` | Image rendering quality | `/quality:high` |

### System
| Parameter | Description | Example |
|-----------|-------------|---------|
| `/CLS` | Clear screen only | `/CLS` |
| `/v` | Verbose output mode | `/v` |
| `/?`, `/h` | Show help | `/?` |

## Image Display Modes

### Mode 0: Fit to Screen (Default)
```bash
WeActCLI /p:3 /image:photo.jpg
```
Images are scaled to fit the display while maintaining aspect ratio.

### Mode 1: Original Size at (0,0)
```bash
WeActCLI /p:3 /image:icon.png:1
```
Displays image at its original resolution starting from top-left corner.

### Mode 2: Centered with Custom Size
```bash
WeActCLI /p:3 /image:logo.png:2:100x50
```
Centers image on screen with specified dimensions.

## Color Options

Available colors: `red`, `green`, `blue`, `white` (default), `black`, `yellow`, `cyan`, `magenta`

## Usage Examples

### Basic Text Operations
```bash
# Simple text display
WeActCLI /p:3 "System Ready"

# Colored text with custom font
WeActCLI /p:4 /c:green /f:"Courier New":12 "OK: All tests passed"

# Centered warning message
WeActCLI /p:3 /center /c:yellow "WARNING: High temperature detected"
```

### Scrolling Text
```bash
# Scroll up at 30px/sec
WeActCLI /p:3 /s:30 "Important news: System maintenance scheduled for tomorrow..."

# Scroll down at 25.5px/sec
WeActCLI /p:3 /s:25.5:d "Log entries: User login, File upload, Database update..."
```

### File Operations
```bash
# Display text file
WeActCLI /p:3 /file:status.txt

# Display log file with scrolling
WeActCLI /p:3 /file:app.log /s:20

# Clear screen
WeActCLI /p:3 /CLS
```

### Image Display
```bash
# Display image full screen
WeActCLI /p:3 /image:wallpaper.jpg

# Display icon at original size
WeActCLI /p:3 /image:icon.png:1

# Display centered logo (64x64 pixels)
WeActCLI /p:3 /image:logo.png:2:64x64

# High quality image rendering
WeActCLI /p:3 /image:photo.jpg /quality:high
```

### Input Redirection
```bash
# Pipe from command
echo "Current time: %time%" | WeActCLI /p:3

# Redirect from file
WeActCLI /p:3 < data.txt

# PowerShell pipeline
Get-Process | Select-Object -First 5 Name,CPU | WeActCLI /p:3
```

### Advanced Examples
```bash
# Complex configuration
WeActCLI /p:4 /v /c:cyan /f:"Arial Bold":10 /s:40 /center /file:announcement.txt

# Image then text sequence
WeActCLI /p:3 /image:splash.jpg && WeActCLI /p:3 "Welcome to System v2.0"

# Diagnostic mode
WeActCLI /p:3 /v /c:yellow "Testing display connection..."
```

## Image Quality Settings

| Quality Level | Description | Use Case |
|--------------|-------------|----------|
| `fast` (0) | Fast rendering, lower quality | Simple icons, quick updates |
| `normal` (1) | Balanced quality/speed | Default setting |
| `high` (2) | Best quality, slower | Photographs, detailed images |
| `bwfast` (3) | Fast black and white | Text-based images |
| `bwhigh` (4) | High quality black and white | Detailed monochrome images |

## Encoding Support

### For Russian/Cyrillic Text:

**PowerShell:**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

**CMD:**
```cmd
chcp 65001
```

**Recommended approach:**
```bash
# Use UTF-8 encoded files
WeActCLI /p:3 /file:russian_text_utf8.txt

# Or ensure UTF-8 output from commands
echo "Привет мир" | WeActCLI /p:3
```

## Supported Image Formats

The utility supports all image formats handled by PureBasic's `LoadImage()` function, typically including:
- JPEG (.jpg, .jpeg)
- PNG (.png)
- BMP (.bmp)
- TIFF (.tif, .tiff)
- And more depending on PureBasic configuration

Check supported formats:
```bash
# The utility will show supported formats in verbose mode
WeActCLI /p:3 /v /image:test.jpg
```

## Error Handling

Common issues and solutions:

1. **"Failed to initialize display"**
   - Check COM port number in Device Manager
   - Verify USB cable connection
   - Ensure drivers are installed (CH340/CH341)

2. **"File not found"**
   - Use full paths or check current directory
   - Enclose paths with spaces in quotes: `"C:\My Files\image.jpg"`

3. **Text encoding issues**
   - Use UTF-8 encoded files
   - Set console encoding to UTF-8
   - Use the `/file` parameter for reliable encoding

4. **Image display problems**
   - Verify image format is supported
   - Check file path and permissions
   - Try different quality settings

## Return Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (invalid parameters, display error, file error) |

## Building from Source

Requires PureBasic 6.21 or later:

```bash
pbcompiler WeActCLI.pb /CONSOLE /EXE "WeActCLI.exe"
```

## License

[Specify your license here]

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/WeActCLI/issues)
- **Documentation**: See examples above and code comments

---

# WeActCLI - Консольная утилита для дисплея WeAct FS

Утилита командной строки для вывода текста и изображений на дисплей WeAct FS через COM-порт. Поддерживает различные режимы отображения, прокрутку текста, вывод изображений и расширенную работу с кодировками.

## Возможности

### 📝 Вывод текста
- **Несколько источников ввода**: прямой текст, файлы, перенаправление stdin
- **Умный перенос строк**: автоматический разрыв на уровне пикселей
- **Управление шрифтами**: пользовательские шрифты и размеры с автонастройкой
- **Цвета текста**: 8 предустановленных цветов
- **Центрирование**: горизонтальное выравнивание текста

### 🖼️ Вывод изображений (Новое!)
- **Несколько режимов отображения**: подгонка под экран, оригинальный размер, центрирование с заданным размером
- **Поддержка форматов**: JPEG, PNG, BMP и другие форматы, поддерживаемые PureBasic
- **Контроль размера**: задание точных размеров для центрированного отображения

### 🔄 Режимы прокрутки
- **Плавная прокрутка**: настраиваемая скорость (пикселей/секунду)
- **Два направления**: прокрутка вверх или вниз
- **Непрерывное отображение**: плавная работа с длинным текстом

### 🌐 Поддержка кодировок
- **Автоматическое определение**: определение кодировок консоли и файлов
- **Поддержка UTF-8**: нативная работа с UTF-8
- **Устаревшие кодировки**: Windows-1251, CP866 и другие
- **Умная конвертация**: автоматическое преобразование в UTF-8 для отображения

### 🛠️ Сервисные функции
- **Очистка экрана**: самостоятельный сброс экрана
- **Подробный режим**: детальное логирование операций
- **Обработка ошибок**: подробные сообщения об ошибках и диагностика

## Требования

- **Windows** (тестировалось на Windows 10/11)
- **Дисплей WeAct FS** с USB-подключением (виртуальный COM-порт)
- **Драйверы CH340/CH341** для USB-UART адаптера (если требуется)
- **Среда выполнения PureBasic** (включена в исполняемый файл)

## Установка

1. Скачайте последнюю версию `WeActCLI.exe` из [Releases](https://github.com/yourusername/WeActCLI/releases)
2. Поместите файл в любую директорию (например, `C:\Tools\`)
3. Опционально: добавьте директорию в системный PATH для глобального доступа

## Быстрый старт

```bash
# Вывести простой текст
WeActCLI /p:3 "Привет мир!"

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

## Справочник параметров

### Обязательные
| Параметр | Описание | Пример |
|----------|----------|---------|
| `/p:X` | Номер COM-порта (ОБЯЗАТЕЛЬНО) | `/p:3` для COM3 |

### Вывод текста
| Параметр | Описание | Пример |
|----------|----------|---------|
| `"текст"` | Текст для отображения (используйте кавычки для пробелов) | `"Привет мир"` |
| `/c:YYY` | Цвет текста | `/c:red`, `/c:green` |
| `/f:"Шрифт:Размер"` | Имя шрифта и размер | `/f:Arial:10` |
| `/center` | Центрировать текст по горизонтали | `/center` |
| `/s:Скорость[:u|d]` | Скорость и направление прокрутки | `/s:30`, `/s:25.5:d` |

### Работа с файлами
| Параметр | Описание | Пример |
|----------|----------|---------|
| `/file:"путь"` | Загрузить текст из файла | `/file:log.txt` |
| `/image:"путь"` | Отобразить файл изображения | `/image:photo.jpg` |

### Параметры изображений (Новое!)
| Параметр | Описание | Пример |
|----------|----------|---------|
| `:режим` | Режим отображения изображения (0-2) | `/image:pic.jpg:1` |
| `:ШxВ` | Пользовательский размер для режима 2 | `/image:icon.png:2:64x64` |
| `/quality:уровень` | Качество рендеринга изображения | `/quality:high` |

### Системные
| Параметр | Описание | Пример |
|----------|----------|---------|
| `/CLS` | Только очистка экрана | `/CLS` |
| `/v` | Подробный режим вывода | `/v` |
| `/?`, `/h` | Показать справку | `/?` |

## Режимы отображения изображений

### Режим 0: Подгонка под экран (По умолчанию)
```bash
WeActCLI /p:3 /image:photo.jpg
```
Изображение масштабируется под размер дисплея с сохранением пропорций.

### Режим 1: Оригинальный размер в (0,0)
```bash
WeActCLI /p:3 /image:icon.png:1
```
Отображает изображение в оригинальном разрешении, начиная с левого верхнего угла.

### Режим 2: Центрирование с заданным размером
```bash
WeActCLI /p:3 /image:logo.png:2:100x50
```
Центрирует изображение на экране с указанными размерами.

## Доступные цвета

Доступные цвета: `red` (красный), `green` (зеленый), `blue` (синий), `white` (белый, по умолчанию), `black` (черный), `yellow` (желтый), `cyan` (голубой), `magenta` (пурпурный)

## Примеры использования

### Базовые операции с текстом
```bash
# Простой вывод текста
WeActCLI /p:3 "Система готова"

# Цветной текст с пользовательским шрифтом
WeActCLI /p:4 /c:green /f:"Courier New":12 "OK: Все тесты пройдены"

# Центрированное предупреждение
WeActCLI /p:3 /center /c:yellow "ПРЕДУПРЕЖДЕНИЕ: Обнаружена высокая температура"
```

### Прокрутка текста
```bash
# Прокрутка вверх со скоростью 30px/сек
WeActCLI /p:3 /s:30 "Важные новости: Техническое обслуживание запланировано на завтра..."

# Прокрутка вниз со скоростью 25.5px/сек
WeActCLI /p:3 /s:25.5:d "Записи лога: Вход пользователя, Загрузка файла, Обновление базы данных..."
```

### Работа с файлами
```bash
# Вывести текстовый файл
WeActCLI /p:3 /file:status.txt

# Вывести лог-файл с прокруткой
WeActCLI /p:3 /file:app.log /s:20

# Очистить экран
WeActCLI /p:3 /CLS
```

### Отображение изображений
```bash
# Показать изображение на весь экран
WeActCLI /p:3 /image:wallpaper.jpg

# Показать иконку в оригинальном размере
WeActCLI /p:3 /image:icon.png:1

# Показать центрированный логотип (64x64 пикселя)
WeActCLI /p:3 /image:logo.png:2:64x64

# Высококачественный рендеринг изображения
WeActCLI /p:3 /image:photo.jpg /quality:high
```

### Перенаправление ввода
```bash
# Пайп из команды
echo "Текущее время: %time%" | WeActCLI /p:3

# Перенаправление из файла
WeActCLI /p:3 < data.txt

# Пайплайн PowerShell
Get-Process | Select-Object -First 5 Name,CPU | WeActCLI /p:3
```

### Продвинутые примеры
```bash
# Комплексная конфигурация
WeActCLI /p:4 /v /c:cyan /f:"Arial Bold":10 /s:40 /center /file:announcement.txt

# Последовательность: изображение, затем текст
WeActCLI /p:3 /image:splash.jpg && WeActCLI /p:3 "Добро пожаловать в Систему v2.0"

# Диагностический режим
WeActCLI /p:3 /v /c:yellow "Тестирование подключения дисплея..."
```

## Настройки качества изображений

| Уровень качества | Описание | Пример использования |
|-----------------|----------|----------------------|
| `fast` (0) | Быстрый рендеринг, низкое качество | Простые иконки, быстрые обновления |
| `normal` (1) | Сбалансированное качество/скорость | Настройка по умолчанию |
| `high` (2) | Лучшее качество, медленнее | Фотографии, детализированные изображения |
| `bwfast` (3) | Быстрое черно-белое | Текстовые изображения |
| `bwhigh` (4) | Высококачественное черно-белое | Детализированные монохромные изображения |

## Поддержка кодировок

### Для русского/кириллического текста:

**PowerShell:**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

**CMD:**
```cmd
chcp 65001
```

**Рекомендуемый способ:**
```bash
# Используйте файлы в кодировке UTF-8
WeActCLI /p:3 /file:russian_text_utf8.txt

# Или обеспечьте вывод в UTF-8 из команд
echo "Привет мир" | WeActCLI /p:3
```

## Поддерживаемые форматы изображений

Утилита поддерживает все форматы изображений, обрабатываемые функцией `LoadImage()` в PureBasic, обычно включая:
- JPEG (.jpg, .jpeg)
- PNG (.png)
- BMP (.bmp)
- TIFF (.tif, .tiff)
- И другие в зависимости от конфигурации PureBasic

Проверка поддерживаемых форматов:
```bash
# Утилита покажет поддерживаемые форматы в подробном режиме
WeActCLI /p:3 /v /image:test.jpg
```

## Обработка ошибок

Частые проблемы и решения:

1. **"Не удалось инициализировать дисплей"**
   - Проверьте номер COM-порта в Диспетчере устройств
   - Проверьте подключение USB-кабеля
   - Убедитесь, что драйверы установлены (CH340/CH341)

2. **"Файл не найден"**
   - Используйте полные пути или проверьте текущую директорию
   - Заключайте пути с пробелами в кавычки: `"C:\Мои Файлы\image.jpg"`

3. **Проблемы с кодировкой текста**
   - Используйте файлы в кодировке UTF-8
   - Установите кодировку консоли в UTF-8
   - Используйте параметр `/file` для надежной работы с кодировками

4. **Проблемы с отображением изображений**
   - Проверьте, что формат изображения поддерживается
   - Проверьте путь к файлу и права доступа
   - Попробуйте разные настройки качества

## Коды возврата

| Код | Значение |
|-----|----------|
| 0 | Успех |
| 1 | Ошибка (неверные параметры, ошибка дисплея, ошибка файла) |

## Сборка из исходного кода

Требуется PureBasic 6.21 или новее:

```bash
pbcompiler WeActCLI.pb /CONSOLE /EXE "WeActCLI.exe"
```

## Лицензия

[Укажите вашу лицензию здесь]

## Участие в разработке

1. Форкните репозиторий
2. Создайте ветку для новой функции
3. Зафиксируйте изменения
4. Отправьте в ветку
5. Создайте Pull Request

## Поддержка

- **Проблемы**: [GitHub Issues](https://github.com/yourusername/WeActCLI/issues)
- **Документация**: Смотрите примеры выше и комментарии в коде
