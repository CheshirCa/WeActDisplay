# WeAct Display Video Player

[English](#english) | [Русский](#russian)

---

<a name="english"></a>
# English Version

## 📌 Overview

WeAct Video Player is a Windows console application that allows you to play video files on WeAct-series displays (160x80 pixels) via serial connection. The application uses FFmpeg to extract frames from video files and displays them in real-time on compatible displays.

## ✨ Features

- **Video Playback**: Play MP4, AVI, WMV, and other FFmpeg-supported formats
- **Scalable Display**: Three scaling modes: fit to screen, fit to width, fit to height
- **Customizable FPS**: Control playback speed with frames-per-second parameter
- **Loop Playback**: Continuous looping of video content
- **Serial Communication**: Connect via standard COM ports (USB-Serial adapters supported)
- **Efficient Processing**: On-the-fly frame extraction and display

## 🛠️ Hardware Requirements

1. **WeAct Display Module** (160x80 pixels, ST7735-based)
2. **USB to Serial Adapter** (FTDI, CH340, or CP2102)
3. **Connection Cables**
4. **Windows PC**

## 📦 Software Requirements

1. **PureBasic 6.21+** (for compilation)
2. **FFmpeg** (must be in PATH or same directory)
3. **WeActDisplay.pbi** (display driver library)

## 🚀 Installation

### Step 1: Install FFmpeg
1. Download FFmpeg from [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)
2. Extract to a directory
3. Add FFmpeg to your system PATH:
   - Press Win + X, select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Add FFmpeg's `bin` directory to PATH

### Step 2: Hardware Connection
1. Connect WeAct display to your PC using USB-Serial adapter:
   ```
   Display VCC → 5V/3.3V (check display requirements)
   Display GND → GND
   Display SDA → TX
   Display SCL → RX
   ```
2. Note the COM port number in Device Manager

### Step 3: Get the Software
1. Download `WeActVideoPlayer.exe` from Releases
2. Or compile from source using PureBasic 6.21+

## 📖 Usage

### Basic Command
```cmd
WeActVideoPlayer.exe /p:3 video.mp4
```

### Full Syntax
```cmd
WeActVideoPlayer.exe /p:<port> <video_file> [/loop] [/w|/h] [/f:<fps>] [/v]
```

### Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `/p:<port>` | **Required.** COM port number | `/p:3` for COM3 |
| `<video_file>` | **Required.** Path to video file | `C:\videos\demo.mp4` |
| `/loop` | Optional. Loop video continuously | `/loop` |
| `/w` | Optional. Scale to fit width | `/w` |
| `/h` | Optional. Scale to fit height | `/h` |
| `/f:<fps>` | Optional. Playback frames per second (default: 10) | `/f:15` |
| `/v` | Optional. Verbose mode (shows progress) | `/v` |

### Scaling Modes

1. **Default (no parameter)**: Fit entire video within display, maintain aspect ratio
2. **`/w`**: Fit to width, crop height if necessary
3. **`/h`**: Fit to height, crop width if necessary

## 📝 Examples

### Example 1: Basic Playback
```cmd
WeActVideoPlayer.exe /p:4 C:\Users\Video\animation.mp4
```

### Example 2: Looped Playback with Custom FPS
```cmd
WeActVideoPlayer.exe /p:3 /loop /f:12 presentation.wmv
```

### Example 3: Width-Fit Scaling with Verbose Output
```cmd
WeActVideoPlayer.exe /p:5 /w /v /f:8 tutorial.avi
```

### Example 4: Height-Fit Scaling
```cmd
WeActVideoPlayer.exe /p:2 /h demo.mp4
```

## 🔧 Technical Details

### How It Works
1. **Frame Extraction**: FFmpeg extracts frames from video at specified FPS
2. **Image Processing**: Frames are scaled and converted to RGB565 format
3. **Serial Transmission**: Processed frames sent via serial port to display
4. **Timing Control**: Precise frame timing maintains smooth playback

### Frame Processing Pipeline
```
Video File → FFmpeg → JPEG Frames → Scaling → RGB565 Conversion → Serial Transmission → Display
```

### Supported Video Formats
Any format supported by FFmpeg:
- MP4, AVI, MKV, MOV, WMV, FLV
- H.264, H.265, MPEG-4, VP9
- Check FFmpeg documentation for complete list

### Display Specifications
- **Resolution**: 160x80 pixels
- **Color Depth**: RGB565 (16-bit)
- **Interface**: SPI via Serial
- **Controller**: ST7735 or compatible

## 🐛 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| "Cannot initialize display" | Check COM port number and cable connections |
| "FFmpeg not found" | Ensure FFmpeg is in PATH or same directory |
| "No frames extracted" | Check video file path and format support |
| "Display shows artifacts" | Verify power supply and ground connections |
| "Playback too slow/fast" | Adjust FPS with `/f:` parameter |

### Debug Steps
1. Enable verbose mode: Add `/v` parameter
2. Check Device Manager for correct COM port
3. Test with simple video files first
4. Ensure adequate power supply to display

## 📊 Performance Tips

1. **Optimal FPS**: 8-15 FPS for smooth playback
2. **Video Preparation**: Pre-scale videos to 160x80 for best performance
3. **File Location**: Use local drives (not network shares)
4. **Background Processes**: Close unnecessary applications during playback

## 📁 Project Structure

```
WeActVideoPlayer/
├── WeActVideoPlayer.pb    # Main source code
├── WeActDisplay.pbi      # Display driver library
├── WeActVideoPlayer.exe  # Compiled executable
├── README.md            # This file
└── Examples/            # Sample videos and scripts
```

## 📄 License

MIT License - see LICENSE file for details

---

<a name="russian"></a>
# Русская Версия

## 📌 Обзор

WeAct Video Player - это консольное приложение для Windows, которое позволяет воспроизводить видеофайлы на дисплеях серии WeAct (160x80 пикселей) через последовательное соединение. Приложение использует FFmpeg для извлечения кадров из видеофайлов и отображает их в реальном времени на совместимых дисплеях.

## ✨ Возможности

- **Воспроизведение видео**: MP4, AVI, WMV и другие форматы, поддерживаемые FFmpeg
- **Масштабирование**: Три режима: вписать в экран, по ширине, по высоте
- **Настраиваемый FPS**: Контроль скорости воспроизведения
- **Циклическое воспроизведение**: Непрерывное повторение видео
- **Последовательное соединение**: Подключение через COM-порты
- **Эффективная обработка**: Извлечение и отображение кадров на лету

## 🛠️ Требования к оборудованию

1. **Модуль дисплея WeAct** (160x80 пикселей, на базе ST7735)
2. **USB-Serial адаптер** (FTDI, CH340 или CP2102)
3. **Соединительные кабели**
4. **Компьютер с Windows**

## 📦 Требования к программному обеспечению

1. **PureBasic 6.21+** (для компиляции)
2. **FFmpeg** (должен быть в PATH или в той же директории)
3. **WeActDisplay.pbi** (библиотека драйвера дисплея)

## 🚀 Установка

### Шаг 1: Установка FFmpeg
1. Скачайте FFmpeg с [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)
2. Распакуйте в папку
3. Добавьте FFmpeg в системный PATH:
   - Нажмите Win + X, выберите "Система"
   - Нажмите "Дополнительные параметры системы"
   - Нажмите "Переменные среды"
   - Добавьте папку `bin` FFmpeg в PATH

### Шаг 2: Подключение оборудования
1. Подключите дисплей WeAct к компьютеру:
   ```
   Дисплей VCC → 5V/3.3V (проверьте требования дисплея)
   Дисплей GND → GND
   Дисплей SDA → TX
   Дисплей SCL → RX
   ```
2. Запомните номер COM-порта в Диспетчере устройств

### Шаг 3: Получение программы
1. Скачайте `WeActVideoPlayer.exe` из раздела Releases
2. Или скомпилируйте из исходников с помощью PureBasic 6.21+

## 📖 Использование

### Базовая команда
```cmd
WeActVideoPlayer.exe /p:3 video.mp4
```

### Полный синтаксис
```cmd
WeActVideoPlayer.exe /p:<порт> <видеофайл> [/loop] [/w|/h] [/f:<кадры/сек>] [/v]
```

### Параметры

| Параметр | Описание | Пример |
|----------|----------|---------|
| `/p:<порт>` | **Обязательный.** Номер COM-порта | `/p:3` для COM3 |
| `<видеофайл>` | **Обязательный.** Путь к видеофайлу | `C:\видео\демо.mp4` |
| `/loop` | Опционально. Циклическое воспроизведение | `/loop` |
| `/w` | Опционально. Масштабирование по ширине | `/w` |
| `/h` | Опционально. Масштабирование по высоте | `/h` |
| `/f:<кадры/сек>` | Опционально. Кадров в секунду (по умолчанию: 10) | `/f:15` |
| `/v` | Опционально. Подробный вывод (прогресс) | `/v` |

### Режимы масштабирования

1. **По умолчанию (без параметра)**: Вписать видео в экран, сохранить пропорции
2. **`/w`**: По ширине, обрезать высоту при необходимости
3. **`/h`**: По высоте, обрезать ширину при необходимости

## 📝 Примеры

### Пример 1: Базовое воспроизведение
```cmd
WeActVideoPlayer.exe /p:4 C:\Users\Видео\анимация.mp4
```

### Пример 2: Циклическое воспроизведение с кастомным FPS
```cmd
WeActVideoPlayer.exe /p:3 /loop /f:12 презентация.wmv
```

### Пример 3: Масштабирование по ширине с подробным выводом
```cmd
WeActVideoPlayer.exe /p:5 /w /v /f:8 обучение.avi
```

### Пример 4: Масштабирование по высоте
```cmd
WeActVideoPlayer.exe /p:2 /h демо.mp4
```

## 🔧 Технические детали

### Как это работает
1. **Извлечение кадров**: FFmpeg извлекает кадры с указанным FPS
2. **Обработка изображений**: Кадры масштабируются и конвертируются в RGB565
3. **Передача по Serial**: Обработанные кадры отправляются на дисплей
4. **Контроль времени**: Точная синхронизация для плавного воспроизведения

### Конвейер обработки
```
Видеофайл → FFmpeg → JPEG кадры → Масштабирование → Конвертация RGB565 → Serial передача → Дисплей
```

### Поддерживаемые форматы видео
Любые форматы, поддерживаемые FFmpeg:
- MP4, AVI, MKV, MOV, WMV, FLV
- H.264, H.265, MPEG-4, VP9
- Полный список смотрите в документации FFmpeg

### Характеристики дисплея
- **Разрешение**: 160x80 пикселей
- **Глубина цвета**: RGB565 (16 бит)
- **Интерфейс**: SPI через Serial
- **Контроллер**: ST7735 или совместимый

## 🐛 Устранение неполадок

### Распространенные проблемы

| Проблема | Решение |
|----------|---------|
| "Cannot initialize display" | Проверьте номер COM-порта и подключение кабелей |
| "FFmpeg not found" | Убедитесь, что FFmpeg в PATH или в той же папке |
| "No frames extracted" | Проверьте путь к видео и поддержку формата |
| "Дисплей показывает артефакты" | Проверьте питание и заземление |
| "Воспроизведение слишком медленное/быстрое" | Настройте FPS параметром `/f:` |

### Шаги отладки
1. Включите подробный режим: добавьте параметр `/v`
2. Проверьте правильность COM-порта в Диспетчере устройств
3. Сначала протестируйте с простыми видеофайлами
4. Убедитесь в достаточном питании дисплея

## 📊 Советы по производительности

1. **Оптимальный FPS**: 8-15 кадров/сек для плавного воспроизведения
2. **Подготовка видео**: Предварительно масштабируйте видео до 160x80
3. **Расположение файлов**: Используйте локальные диски (не сетевые)
4. **Фоновые процессы**: Закройте ненужные приложения во время воспроизведения

## 📁 Структура проекта

```
WeActVideoPlayer/
├── WeActVideoPlayer.pb    # Исходный код
├── WeActDisplay.pbi      # Библиотека драйвера дисплея
├── WeActVideoPlayer.exe  # Скомпилированный файл
├── README.md            # Этот файл
└── Examples/            # Примеры видео и скриптов
```

## 📄 Лицензия

MIT License - подробности в файле LICENSE

