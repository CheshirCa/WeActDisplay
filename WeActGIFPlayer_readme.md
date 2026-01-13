# WeAct Display GIF Player

[English](#english) | [Русский](#русский)

---

## English

## WeAct Display GIF Player for Windows

A specialized GIF player designed to display animated GIFs on WeAct USB-connected displays. Written in PureBasic, this utility provides precise control over playback with hardware-accelerated display capabilities.

### Features

- **Hardware Acceleration**: Direct display buffer manipulation for optimal performance
- **Speed Control**: Adjust playback speed from 0.1x to 5.0x original
- **Loop Mode**: Option to play animations continuously
- **Scaling**: Automatic proportional scaling with centering
- **Multi-COM Support**: Connect to displays on different COM ports
- **Verbose Mode**: Detailed playback information and debugging
- **Signal Handling**: Clean shutdown with Ctrl+C support

### Requirements

- Windows OS
- PureBasic 6.21 or later (for compilation)
- WeAct USB Display connected via COM port
- WeActDisplay library (included in project)

### Installation

1. Download the latest release or compile from source:
   ```bash
   ; Requires PureBasic compiler
   pbcompiler WeActGIFPlayer.pb
   ```

2. Ensure the `WeActDisplay.pbi` library is in the same directory

3. Connect your WeAct display to a USB port (appears as COM port)

### Usage

```bash
WeActGIFPlayer.exe [/p:port] [/s:speed] [/l] [/v] <gif_path>
```

#### Required Parameters:
- `<gif_path>` - Path to animated GIF file

#### Optional Parameters:
- `/p:port` - COM port number (default: 3, e.g., COM3)
- `/s:speed` - Speed multiplier (0.1-5.0, default: 1.0)
- `/l` - Loop playback continuously
- `/v` - Verbose mode (detailed output)
- `/h` - Show help

### Examples

```bash
# Basic playback
WeActGIFPlayer.exe "C:\animations\demo.gif"

# Play at half speed on COM4
WeActGIFPlayer.exe /p:4 /s:0.5 "C:\animations\demo.gif"

# Loop at double speed with verbose output
WeActGIFPlayer.exe /p:3 /s:2.0 /l /v "C:\animations\demo.gif"
```

### Speed Reference
- `/s:0.1` - Very slow (10% of original)
- `/s:0.5` - Slow (50% of original)
- `/s:1.0` - Normal speed (default)
- `/s:2.0` - Fast (2x faster)
- `/s:5.0` - Very fast (5x faster)

### Controls
- `Ctrl+C` - Stop playback and exit

### Technical Details

The player:
- Extracts individual frames from GIF files
- Converts to RGB565 format for display compatibility
- Manages frame timing with millisecond precision
- Handles display buffer updates efficiently
- Supports both animated and static GIFs

### Building from Source

1. Install PureBasic 6.21+
2. Open `WeActGIFPlayer.pb` in PureBasic IDE
3. Ensure `WeActDisplay.pbi` is accessible
4. Compile as Console executable

### License

This project is provided for use with WeAct displays. See source code for details.

### Support

For issues:
1. Check COM port connection
2. Verify GIF file integrity
3. Ensure display is properly initialized
4. Use `/v` flag for debugging output

---

## Русский

## WeAct Display GIF Player для Windows

Специализированный плеер для отображения анимированных GIF на дисплеях WeAct с USB-подключением. Написан на PureBasic, предоставляет точный контроль над воспроизведением с аппаратным ускорением вывода.

### Возможности

- **Аппаратное ускорение**: Прямая работа с буфером дисплея для оптимальной производительности
- **Контроль скорости**: Изменение скорости воспроизведения от 0.1x до 5.0x
- **Режим зацикливания**: Опция непрерывного воспроизведения анимации
- **Масштабирование**: Автоматическое пропорциональное масштабирование с центрированием
- **Поддержка нескольких COM-портов**: Подключение к дисплеям на разных портах
- **Вербозный режим**: Подробная информация о воспроизведении и отладка
- **Обработка сигналов**: Корректное завершение по Ctrl+C

### Требования

- ОС Windows
- PureBasic 6.21 или новее (для компиляции)
- Дисплей WeAct подключенный через COM-порт
- Библиотека WeActDisplay (включена в проект)

### Установка

1. Скачайте последнюю версию или скомпилируйте из исходников:
   ```bash
   ; Требуется компилятор PureBasic
   pbcompiler WeActGIFPlayer.pb
   ```

2. Убедитесь, что библиотека `WeActDisplay.pbi` находится в той же директории

3. Подключите дисплей WeAct к USB-порту (определяется как COM-порт)

### Использование

```bash
WeActGIFPlayer.exe [/p:порт] [/s:скорость] [/l] [/v] <путь_к_gif>
```

#### Обязательные параметры:
- `<путь_к_gif>` - Путь к анимированному GIF файлу

#### Опциональные параметры:
- `/p:порт` - Номер COM-порта (по умолчанию: 3, например, COM3)
- `/s:скорость` - Множитель скорости (0.1-5.0, по умолчанию: 1.0)
- `/l` - Зацикленное воспроизведение
- `/v` - Вербозный режим (подробный вывод)
- `/h` - Показать справку

### Примеры

```bash
# Базовое воспроизведение
WeActGIFPlayer.exe "C:\анимации\демо.gif"

# Воспроизведение на половине скорости на COM4
WeActGIFPlayer.exe /p:4 /s:0.5 "C:\анимации\демо.gif"

# Зацикленное воспроизведение в 2 раза быстрее с подробным выводом
WeActGIFPlayer.exe /p:3 /s:2.0 /l /v "C:\анимации\демо.gif"
```

### Справка по скорости
- `/s:0.1` - Очень медленно (10% от оригинальной)
- `/s:0.5` - Медленно (50% от оригинальной)
- `/s:1.0` - Нормальная скорость (по умолчанию)
- `/s:2.0` - Быстро (в 2 раза быстрее)
- `/s:5.0` - Очень быстро (в 5 раз быстрее)

### Управление
- `Ctrl+C` - Остановить воспроизведение и выйти

### Технические детали

Плеер:
- Извлекает отдельные кадры из GIF файлов
- Конвертирует в формат RGB565 для совместимости с дисплеем
- Управляет временем кадров с миллисекундной точностью
- Эффективно обновляет буфер дисплея
- Поддерживает как анимированные, так и статические GIF

### Сборка из исходников

1. Установите PureBasic 6.21+
2. Откройте `WeActGIFPlayer.pb` в среде PureBasic
3. Убедитесь, что `WeActDisplay.pbi` доступен
4. Скомпилируйте как консольное приложение

### Лицензия

Проект предоставлен для использования с дисплеями WeAct. Подробности в исходном коде.

### Поддержка

При возникновении проблем:
1. Проверьте подключение COM-порта
2. Убедитесь в целостности GIF файла
3. Проверьте инициализацию дисплея
4. Используйте флаг `/v` для отладочного вывода
