# WeAct Display GIF Player

[English](#english) | [Русский](#русский)

---

## English

## WeAct Display GIF Player

A utility for displaying animated GIF files on WeAct USB displays (160x80 pixels). The program extracts frames from GIF files and sends them to the display via serial connection.

### Features

- Support for animated and static GIF files
- Adjustable playback speed (0.1x to 5.0x)
- Loop playback mode
- Automatic scaling with aspect ratio preservation
- Multiple COM port support
- Detailed debug output option

### Requirements

- Windows operating system
- WeAct USB Display (0.96-inch, 160x80)
- COM port connection (appears as COM3, COM4, etc.)

### Installation

1. Download the latest release or compile from source:
   ```bash
   pbcompiler WeActGIFPlayer.pb
   ```

2. Place `WeActDisplay.pbi` in the same directory as the executable

### Usage

```bash
WeActGIFPlayer.exe [/p:port] [/s:speed] [/l] [/v] <gif_file>
```

#### Parameters:
- `<gif_file>` - Path to GIF file (required)
- `/p:port` - COM port number (default: 3, e.g., COM3)
- `/s:speed` - Speed multiplier 0.1-5.0 (default: 1.0)
- `/l` - Loop playback continuously
- `/v` - Verbose output mode
- `/h` - Show help

### Examples

```bash
# Basic usage
WeActGIFPlayer.exe "animation.gif"

# Specify COM port and speed
WeActGIFPlayer.exe /p:4 /s:0.5 "animation.gif"

# Loop playback with verbose output
WeActGIFPlayer.exe /p:3 /s:2.0 /l /v "animation.gif"
```

### Speed Multipliers
- `0.1` - Very slow (10% of original speed)
- `0.5` - Slow (50% of original speed)
- `1.0` - Normal speed (default)
- `2.0` - Fast (2x faster)
- `5.0` - Very fast (5x faster)

### Controls
- Press `Ctrl+C` to stop playback and exit

### Technical Details

The program:
1. Loads GIF file and extracts all frames
2. Scales each frame to fit the 160x80 display while preserving aspect ratio
3. Converts colors to RGB565 format required by the display
4. Sends frames to the display via serial port with proper timing
5. Supports frame delays specified in the GIF file

### Building from Source

1. Install PureBasic 6.21 or later
2. Open `WeActGIFPlayer.pb` in PureBasic IDE
3. Ensure `WeActDisplay.pbi` is in the same directory
4. Compile as Console application

### Troubleshooting

1. **Display not responding**
   - Check COM port connection
   - Verify correct port number with Device Manager
   - Try different USB port

2. **GIF not playing**
   - Verify file exists and is readable
   - Try a different GIF file
   - Use `/v` flag for debug information

3. **Slow performance**
   - Reduce image resolution before loading
   - Use smaller GIF files
   - Adjust speed with `/s` parameter

---

## Русский

## WeAct Display GIF Player

Утилита для отображения анимированных GIF файлов на дисплеях WeAct (160x80 пикселей). Программа извлекает кадры из GIF файлов и отправляет их на дисплей через последовательный порт.

### Возможности

- Поддержка анимированных и статических GIF файлов
- Регулируемая скорость воспроизведения (0.1x до 5.0x)
- Режим зацикливания
- Автоматическое масштабирование с сохранением пропорций
- Поддержка нескольких COM портов
- Опция подробного вывода отладки

### Требования

- Операционная система Windows
- Дисплей WeAct (0.96 дюйма, 160x80)
- Подключение через COM порт (отображается как COM3, COM4 и т.д.)

### Установка

1. Скачайте последнюю версию или скомпилируйте из исходников:
   ```bash
   pbcompiler WeActGIFPlayer.pb
   ```

2. Поместите `WeActDisplay.pbi` в ту же директорию, что и исполняемый файл

### Использование

```bash
WeActGIFPlayer.exe [/p:порт] [/s:скорость] [/l] [/v] <файл_gif>
```

#### Параметры:
- `<файл_gif>` - Путь к GIF файлу (обязательный)
- `/p:порт` - Номер COM порта (по умолчанию: 3, например, COM3)
- `/s:скорость` - Множитель скорости 0.1-5.0 (по умолчанию: 1.0)
- `/l` - Зацикленное воспроизведение
- `/v` - Подробный режим вывода
- `/h` - Показать справку

### Примеры

```bash
# Базовое использование
WeActGIFPlayer.exe "анимация.gif"

# Указание COM порта и скорости
WeActGIFPlayer.exe /p:4 /s:0.5 "анимация.gif"

# Зацикленное воспроизведение с подробным выводом
WeActGIFPlayer.exe /p:3 /s:2.0 /l /v "анимация.gif"
```

### Множители скорости
- `0.1` - Очень медленно (10% от оригинальной скорости)
- `0.5` - Медленно (50% от оригинальной скорости)
- `1.0` - Нормальная скорость (по умолчанию)
- `2.0` - Быстро (в 2 раза быстрее)
- `5.0` - Очень быстро (в 5 раз быстрее)

### Управление
- Нажмите `Ctrl+C` для остановки воспроизведения и выхода

### Технические детали

Программа:
1. Загружает GIF файл и извлекает все кадры
2. Масштабирует каждый кадр под дисплей 160x80 с сохранением пропорций
3. Конвертирует цвета в формат RGB565, требуемый дисплеем
4. Отправляет кадры на дисплей через COM порт с правильными задержками
5. Поддерживает задержки между кадрами, указанные в GIF файле

### Сборка из исходников

1. Установите PureBasic 6.21 или новее
2. Откройте `WeActGIFPlayer.pb` в среде PureBasic
3. Убедитесь, что `WeActDisplay.pbi` находится в той же директории
4. Скомпилируйте как консольное приложение

### Решение проблем

1. **Дисплей не отвечает**
   - Проверьте подключение COM порта
   - Уточните номер порта в Диспетчере устройств
   - Попробуйте другой USB порт

2. **GIF не воспроизводится**
   - Убедитесь, что файл существует и доступен для чтения
   - Попробуйте другой GIF файл
   - Используйте флаг `/v` для отладочной информации

3. **Медленная работа**
   - Уменьшите разрешение изображения перед загрузкой
   - Используйте GIF файлы меньшего размера
   - Отрегулируйте скорость с помощью параметра `/s`
