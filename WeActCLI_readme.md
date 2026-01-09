# WeActCLI - Console Text Display Utility for WeAct FS Display

# (русская версия ниже)

A command-line utility for displaying text on WeAct FS displays via COM port with support for multiple display modes.

## Features

- **Multiple Text Input Sources**:
  - Direct command-line input
  - File loading (with UTF-8 support)
  - Pipe redirection from other programs
  - File redirection (`< file.txt`)
- **Various Display Modes**:
  - Static text with line wrapping
  - Smooth text scrolling (up/down)
  - Screen clearing
- **Customizable Appearance**:
  - Font selection and sizing
  - Text color selection
  - Horizontal text centering
  - Automatic font size adjustment for text fitting
- **Encoding Support**:
  - Automatic input encoding detection
  - UTF-8, Windows-1251, CP866 and other encoding support
  - Conversion to UTF-8 for correct Russian text display

## Requirements

- Windows (tested on Windows 10/11)
- WeAct FS display with USB connection (virtual COM port)
- CH340/CH341 USB-UART adapter drivers (if required)

## Installation

1. Download `WeActCLI.exe` from the Releases section
2. Place the file in a convenient directory (e.g., `C:\Tools\`)
3. (Optional) Add the directory to your PATH environment variable

## Usage

### Basic Syntax

```bash
WeActCLI /p:X [/v][/c:YYY] [/f:"Font Name":Size] [/s:Speed[:u|d]] [/center] [/CLS] [/file:"path\name.txt"] ["text"]
```

### Main Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `/p:X` | **Required** - COM port number | `/p:3` for COM3 |
| `/v` | Verbose output mode | `/v` |
| `/c:YYY` | Text color | `/c:red`, `/c:green` |
| `/f:"Font":Size` | Font and size | `/f:Arial:10` |
| `/s:Speed[:u|d]` | Scroll mode and speed | `/s:30`, `/s:25.5:d` |
| `/center` | Horizontal text centering | `/center` |
| `/CLS` | Clear screen only (no text output) | `/CLS` |
| `/file:"path"` | Load text from file | `/file:log.txt` |

### Supported Colors

- `red`
- `green`
- `blue`
- `white` - default
- `black`
- `yellow`
- `cyan`
- `magenta`

## Usage Examples

### 1. Simple Text Display
```bash
WeActCLI /p:3 "Hello, World!"
```

### 2. Display Russian Text
```bash
WeActCLI /p:3 "Привет, мир!"
```

### 3. Colored Text
```bash
WeActCLI /p:3 /c:green "System loaded successfully"
```

### 4. Change Font and Size
```bash
WeActCLI /p:3 /f:"Courier New":12 "Monospaced font"
```

### 5. Horizontal Centering
```bash
WeActCLI /p:3 /center "Centered text"
```

### 6. Text Scrolling
```bash
# Scroll up at 30 pixels/second
WeActCLI /p:3 /s:30 "Long text for scrolling..."

# Scroll down at 25.5 pixels/second
WeActCLI /p:3 /s:25.5:d "Text scrolling down"
```

### 7. Load Text from File
```bash
WeActCLI /p:3 /file:log.txt
```

### 8. Clear Screen
```bash
WeActCLI /p:3 /CLS
```

### 9. Using Input Redirection

From command line:
```bash
echo "Text from echo command" | WeActCLI /p:3
```

From file:
```bash
WeActCLI /p:3 < log.txt
```

From PowerShell:
```powershell
Get-Date | WeActCLI /p:3
```

### 10. Verbose Mode (Debugging)
```bash
WeActCLI /p:3 /v /c:yellow /center "Debug text"
```

### 11. Complex Example
```bash
WeActCLI /p:4 /v /c:cyan /f:Arial:10 /s:40 /center "Important system message for users"
```

## Operating Modes

### Static Text (Default)
Text is displayed on screen with line wrapping and remains static. If text doesn't fit, font size is automatically reduced.

### Scroll Mode (`/s`)
Text smoothly scrolls across the screen in specified direction:
- `u` or unspecified - up (default)
- `d` - down

Speed is specified in pixels per second (recommended: 10-50).

### Clear Screen Mode (`/CLS`)
Simply clears the display screen. Useful for resetting display state.

### File Mode (`/file`)
Loads text from specified file. UTF-8 encoding is supported. Limit: 1000 lines.

## Encoding Support

### For Correct Russian Text Display:

**In PowerShell:**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

**In CMD:**
```cmd
chcp 65001
```

**Recommended approach:** Use UTF-8 encoded text files with the `/file` parameter.

## Automatic Font Adjustment

The program automatically checks if the longest words in the text fit within screen width. If words don't fit:
1. Font size is gradually reduced (down to minimum 6pt)
2. If words still don't fit at 6pt - error is displayed
3. In such cases, using scroll mode (`/s`) is recommended

## Diagnostics and Debugging

### Verbose Mode (`/v`)
Enables detailed output:
- Command-line parameters
- Display information
- Text processing details
- Line and character statistics
- Encoding information

### COM Port Verification
If connection issues occur:
1. Check COM port number in Device Manager
2. Ensure drivers are installed
3. Verify cable connection

### Return Codes
- `0` - successful execution
- `1` - execution error

## Limitations

- Maximum text length: limited by available memory
- Maximum lines from file: 1000
- Font size: 6-32pt (recommended)
- Scroll speed: 0.1-100 pixels/second
- Windows only

## Common Use Cases

### 1. Log Monitoring
```bash
# Display last log lines
tail -n 20 app.log | WeActCLI /p:3
```

### 2. System Status Display
```bash
# In PowerShell script
$status = "CPU: " + (Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage) + "%"
WeActCLI /p:3 /c:green $status
```

### 3. Information Display
```bash
# News ticker
WeActCLI /p:3 /s:25 /center "Important announcement: Maintenance tomorrow from 10:00 to 12:00"
```

### 4. Embedded Systems Debugging
```bash
# Display debug information from another system's COM port
some_debug_tool | WeActCLI /p:3
```

## Support

If issues occur:
1. Enable `/v` mode for detailed output
2. Verify COM port number is correct
3. Check encoding support

---

# WeActCLI - Консольная утилита для отображения текста на дисплее WeAct FS

Утилита командной строки для вывода текста на дисплей WeAct FS через COM-порт с поддержкой различных режимов отображения.

## Возможности

- **Множественные источники ввода текста**:
  - Прямой ввод через командную строку
  - Загрузка из файла (с поддержкой UTF-8)
  - Перенаправление ввода (pipe) из других программ
  - Перенаправление из файлов (`< file.txt`)
- **Различные режимы отображения**:
  - Статический текст с переносом строк
  - Плавная прокрутка текста (вверх/вниз)
  - Очистка экрана
- **Настройка внешнего вида**:
  - Выбор шрифта и размера
  - Выбор цвета текста
  - Горизонтальное центрирование
  - Автоматическая корректировка размера шрифта для вписывания текста
- **Поддержка кодировок**:
  - Автоматическое определение кодировки ввода
  - Поддержка UTF-8, Windows-1251, CP866 и других
  - Конвертация в UTF-8 для корректного отображения русского текста

## Требования

- Windows (тестировалось на Windows 10/11)
- Дисплей WeAct FS с подключением по USB (виртуальный COM-порт)
- Драйверы CH340/CH341 для USB-UART адаптера (если требуется)

## Установка

1. Скачайте `WeActCLI.exe` из раздела Releases
2. Поместите файл в удобную директорию (например, `C:\Tools\`)
3. (Опционально) Добавьте путь в переменную окружения PATH

## Использование

### Базовый синтаксис

```bash
WeActCLI /p:X [/v][/c:YYY] [/f:"Font Name":Size] [/s:Speed[:u|d]] [/center] [/CLS] [/file:"path\name.txt"] ["text"]
```

### Основные параметры

| Параметр | Описание | Пример |
|----------|----------|---------|
| `/p:X` | **Обязательный** - номер COM-порта | `/p:3` для COM3 |
| `/v` | Режим подробного вывода (verbose) | `/v` |
| `/c:YYY` | Цвет текста | `/c:red`, `/c:green` |
| `/f:"Font":Size` | Шрифт и размер | `/f:Arial:10` |
| `/s:Speed[:u|d]` | Режим прокрутки и скорость | `/s:30`, `/s:25.5:d` |
| `/center` | Горизонтальное центрирование | `/center` |
| `/CLS` | Очистить экран (без вывода текста) | `/CLS` |
| `/file:"path"` | Загрузить текст из файла | `/file:log.txt` |

### Поддерживаемые цвета

- `red` (красный)
- `green` (зеленый)
- `blue` (синий)
- `white` (белый) - по умолчанию
- `black` (черный)
- `yellow` (желтый)
- `cyan` (голубой)
- `magenta` (пурпурный)

## Примеры использования

### 1. Простой вывод текста
```bash
WeActCLI /p:3 "Hello, World!"
```

### 2. Вывод текста на русском языке
```bash
WeActCLI /p:3 "Привет, мир!"
```

### 3. Цветной текст
```bash
WeActCLI /p:3 /c:green "Система загружена успешно"
```

### 4. Изменение шрифта и размера
```bash
WeActCLI /p:3 /f:"Courier New":12 "Моноширинный шрифт"
```

### 5. Горизонтальное центрирование
```bash
WeActCLI /p:3 /center "Текст по центру"
```

### 6. Прокрутка текста
```bash
# Прокрутка вверх со скоростью 30 пикселей/сек
WeActCLI /p:3 /s:30 "Длинный текст для прокрутки..."

# Прокрутка вниз со скоростью 25.5 пикселей/сек
WeActCLI /p:3 /s:25.5:d "Текст прокручивается вниз"
```

### 7. Загрузка текста из файла
```bash
WeActCLI /p:3 /file:log.txt
```

### 8. Очистка экрана
```bash
WeActCLI /p:3 /CLS
```

### 9. Использование с перенаправлением ввода

Из командной строки:
```bash
echo "Текст из команды echo" | WeActCLI /p:3
```

Из файла:
```bash
WeActCLI /p:3 < log.txt
```

Из PowerShell:
```powershell
Get-Date | WeActCLI /p:3
```

### 10. Подробный режим (отладка)
```bash
WeActCLI /p:3 /v /c:yellow /center "Текст для отладки"
```

### 11. Комплексный пример
```bash
WeActCLI /p:4 /v /c:cyan /f:Arial:10 /s:40 /center "Важное сообщение для пользователей системы"
```

## Режимы работы

### Статический текст (по умолчанию)
Текст отображается на экране с переносом строк и остается неподвижным. Если текст не помещается, автоматически уменьшается размер шрифта.

### Режим прокрутки (`/s`)
Текст плавно прокручивается по экрану в указанном направлении:
- `u` или без указания - вверх (по умолчанию)
- `d` - вниз

Скорость указывается в пикселях в секунду (рекомендуется 10-50).

### Режим очистки (`/CLS`)
Просто очищает экран дисплея. Полезно для сброса состояния.

### Режим файла (`/file`)
Загружает текст из указанного файла. Поддерживается UTF-8 кодировка. Ограничение: 1000 строк.

## Работа с кодировками

### Для корректного отображения русского текста:

**В PowerShell:**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

**В CMD:**
```cmd
chcp 65001
```

**Рекомендуемый способ:** Используйте текстовые файлы в кодировке UTF-8 с параметром `/file`.

## Автоматическая корректировка шрифта

Программа автоматически проверяет, помещаются ли самые длинные слова в тексте в ширину экрана. Если слова не помещаются:
1. Постепенно уменьшается размер шрифта (до минимального 6pt)
2. Если даже при 6pt слова не помещаются - выводится ошибка
3. В таком случае рекомендуется использовать режим прокрутки (`/s`)

## Диагностика и отладка

### Подробный режим (`/v`)
Включает вывод подробной информации:
- Параметры командной строки
- Информация о дисплее
- Детали обработки текста
- Статистика по строкам и символам
- Информация о кодировке

### Проверка COM-порта
Если возникают проблемы с подключением:
1. Проверьте номер COM-порта в Диспетчере устройств
2. Убедитесь, что драйверы установлены
3. Проверьте подключение кабеля

### Коды возврата
- `0` - успешное выполнение
- `1` - ошибка выполнения

## Ограничения

- Максимальная длина текста: ограничена доступной памятью
- Максимальное количество строк из файла: 1000
- Размер шрифта: 6-32pt (рекомендуется)
- Скорость прокрутки: 0.1-100 пикселей/сек
- Поддерживается только Windows

## Типичные сценарии использования

### 1. Мониторинг логов
```bash
# Вывод последних строк лога
tail -n 20 app.log | WeActCLI /p:3
```

### 2. Отображение статуса системы
```bash
# В скрипте PowerShell
$status = "CPU: " + (Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage) + "%"
WeActCLI /p:3 /c:green $status
```

### 3. Информационное табло
```bash
# Бегущая строка с новостями
WeActCLI /p:3 /s:25 /center "Важное объявление: Завтра профилактические работы с 10:00 до 12:00"
```

### 4. Отладка embedded-систем
```bash
# Вывод отладочной информации с COM-порта другой системы
some_debug_tool | WeActCLI /p:3
```

## Поддержка

При возникновении проблем:
1. Включите режим `/v` для подробного вывода
2. Проверьте правильность номера COM-порта
3. Убедитесь в поддержке используемой кодировки
