# WeAct Display FPS Monitor

A real-time FPS monitoring tool that displays frame rate information on a WeAct display connected via serial port.

## 🌟 Features
- Real-time FPS monitoring from specified display
- Multiple calculation methods (refresh rate and screen capture)
- Customizable update intervals
- Verbose console output option
- Clean shutdown with display clearing
- Cross-platform support (Windows primary, fallbacks for Linux/Mac)

## 📋 Requirements
- WeAct display hardware connected via serial port
- PureBasic 6.21 or later (for compilation)
- Windows OS for full functionality (Linux/Mac have limited features)

## 🔧 Installation

### Pre-compiled Binary
Download `WeActFPS.exe` from the Releases section and run it from command line.

### Compile from Source
1. Install PureBasic 6.21+
2. Copy `WeActDisplay.pbi` to the project directory
3. Open `WeActFPS.pb` in PureBasic IDE
4. Compile with: Executable Format = Console

## 🚀 Usage

### Basic Command
```bash
WeActFPS.exe /p:3
```
This connects to COM3 with default settings.

### Complete Syntax
```bash
WeActFPS.exe /p:<port> [/m:<monitor>] [/i:<interval>] [/v]
```

### Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| `/p:<port>` | **Required.** COM port number (e.g., `/p:3` for COM3) | - |
| `/m:<monitor>` | Monitor index (0 = primary) | 0 |
| `/i:<interval>` | Update interval in milliseconds (100-5000) | 1000 |
| `/v` | Verbose mode - shows detailed console output | Off |
| `/?` or `/h` | Show help information | - |

### Examples
```bash
# Connect to COM5, primary monitor, 1-second updates
WeActFPS.exe /p:5

# Connect to COM3, secondary monitor, updates every 500ms
WeActFPS.exe /p:3 /m:1 /i:500

# Enable verbose output
WeActFPS.exe /p:4 /v

# Show help
WeActFPS.exe /?
```

## 📊 FPS Calculation Methods

### Method 1: Refresh Rate (Default)
- Reads monitor's vertical refresh rate from system
- Shows maximum possible FPS for that display
- Fast and CPU-efficient

### Method 2: Screen Capture (Experimental)
- Actively captures screen frames to measure real rendering FPS
- More accurate for actual performance measurement
- Higher CPU usage
- Currently Windows-only

## 🎨 Display Output
The WeAct display shows:
- **Large green text**: Current FPS value (e.g., "FPS: 60.0")
- **Small white text**: Monitor index (top-left corner)
- **Black background**: Minimizes OLED burn-in

## ⚙️ Configuration

### Global Variables (in source code)
```purebasic
Global comPort.s = "COM3"        ; Default serial port
Global monitorIndex.i = 0        ; Default monitor (0 = primary)
Global updateInterval.i = 1000   ; Update every 1000ms
Global verbose.i = #False        ; Console output disabled
```

### Valid Ranges
- **COM Port**: 1-255 (e.g., COM1-COM255)
- **Monitor Index**: 0-9 (system dependent)
- **Update Interval**: 100-5000 milliseconds

## 🔄 Program Flow
1. Parse command line arguments
2. Initialize serial connection to WeAct display
3. Set display to maximum brightness
4. Enter main monitoring loop:
   - Calculate FPS using selected method
   - Update WeAct display with new FPS value
   - Optionally output to console (verbose mode)
   - Wait for next update interval
5. On exit (Ctrl+C):
   - Clear display buffer to black
   - Send final update to display
   - Release serial resources

## 🛠️ Building from Source

### Dependencies
- `WeActDisplay.pbi` - Display driver library
- PureBasic Windows SDK

### Compilation Notes
- Target: Console application
- Enable XP compatibility
- No Unicode requirement
- Link necessary Windows libraries

### IDE Settings
```
ExecutableFormat = Console
EnableXP = Yes
Executable = WeActFPS.exe
```

## ⚠️ Limitations
- Screen capture method only works on Windows
- Linux/Mac versions use fallback 60 FPS value
- Requires exclusive access to serial port
- May conflict with other serial port applications
- OLED displays may experience burn-in with static content

## 🆘 Troubleshooting

### "Cannot initialize display"
- Check COM port number
- Verify WeAct display is connected and powered
- Ensure no other application is using the serial port
- Try different COM port

### Inaccurate FPS readings
- For refresh rate: Update graphics drivers
- For screen capture: Run as administrator
- Try different monitor index values
- Increase update interval for more stable readings

### High CPU Usage
- Increase update interval (e.g., `/i:2000`)
- Use refresh rate method instead of screen capture
- Close other applications

## 📝 License
This project is provided as-is for educational and personal use. Commercial use may require additional permissions.

---

# WeAct Display FPS Monitor (Русская версия)

Инструмент для мониторинга FPS в реальном времени с выводом информации на дисплей WeAct через последовательный порт.

## 🌟 Возможности
- Мониторинг FPS в реальном времени с указанного дисплея
- Несколько методов расчета (частота обновления и захват экрана)
- Настраиваемые интервалы обновления
- Опция подробного вывода в консоль
- Чистое завершение работы с очисткой дисплея
- Кроссплатформенная поддержка (Windows основная, fallback для Linux/Mac)

## 📋 Требования
- Аппаратный дисплей WeAct, подключенный через последовательный порт
- PureBasic 6.21 или новее (для компиляции)
- ОС Windows для полной функциональности (Linux/Mac имеют ограничения)

## 🔧 Установка

### Готовый исполняемый файл
Скачайте `WeActFPS.exe` из раздела Releases и запустите из командной строки.

### Компиляция из исходного кода
1. Установите PureBasic 6.21+
2. Скопируйте `WeActDisplay.pbi` в директорию проекта
3. Откройте `WeActFPS.pb` в PureBasic IDE
4. Скомпилируйте с настройками: Executable Format = Console

## 🚀 Использование

### Базовая команда
```bash
WeActFPS.exe /p:3
```
Подключится к COM3 с настройками по умолчанию.

### Полный синтаксис
```bash
WeActFPS.exe /p:<port> [/m:<monitor>] [/i:<interval>] [/v]
```

### Параметры
| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `/p:<port>` | **Обязательный.** Номер COM порта (например, `/p:3` для COM3) | - |
| `/m:<monitor>` | Индекс монитора (0 = основной) | 0 |
| `/i:<interval>` | Интервал обновления в миллисекундах (100-5000) | 1000 |
| `/v` | Подробный режим - показывает детальный вывод в консоль | Выключен |
| `/?` или `/h` | Показать справку | - |

### Примеры
```bash
# Подключиться к COM5, основной монитор, обновление каждую секунду
WeActFPS.exe /p:5

# Подключиться к COM3, второй монитор, обновление каждые 500мс
WeActFPS.exe /p:3 /m:1 /i:500

# Включить подробный вывод
WeActFPS.exe /p:4 /v

# Показать справку
WeActFPS.exe /?
```

## 📊 Методы расчета FPS

### Метод 1: Частота обновления (По умолчанию)
- Читает вертикальную частоту обновления монитора из системы
- Показывает максимально возможный FPS для этого дисплея
- Быстрый и экономичный по CPU

### Метод 2: Захват экрана (Экспериментальный)
- Активно захватывает кадры экрана для измерения реального FPS
- Более точен для измерения фактической производительности
- Выше использование CPU
- В настоящее время только для Windows

## 🎨 Вывод на дисплей
Дисплей WeAct показывает:
- **Крупный зеленый текст**: Текущее значение FPS (например, "FPS: 60.0")
- **Мелкий белый текст**: Индекс монитора (левый верхний угол)
- **Черный фон**: Минимизирует выгорание OLED

## ⚙️ Конфигурация

### Глобальные переменные (в исходном коде)
```purebasic
Global comPort.s = "COM3"        ; Порт по умолчанию
Global monitorIndex.i = 0        ; Монитор по умолчанию (0 = основной)
Global updateInterval.i = 1000   ; Обновление каждые 1000мс
Global verbose.i = #False        ; Вывод в консоль отключен
```

### Допустимые диапазоны
- **COM порт**: 1-255 (например, COM1-COM255)
- **Индекс монитора**: 0-9 (зависит от системы)
- **Интервал обновления**: 100-5000 миллисекунд

## 🔄 Работа программы
1. Парсинг аргументов командной строки
2. Инициализация последовательного соединения с дисплеем WeAct
3. Установка максимальной яркости дисплея
4. Вход в основной цикл мониторинга:
   - Расчет FPS выбранным методом
   - Обновление дисплея WeAct новым значением FPS
   - Опциональный вывод в консоль (подробный режим)
   - Ожидание следующего интервала обновления
5. При выходе (Ctrl+C):
   - Очистка буфера дисплея черным цветом
   - Отправка финального обновления на дисплей
   - Освобождение ресурсов последовательного порта

## 🛠️ Сборка из исходного кода

### Зависимости
- `WeActDisplay.pbi` - Библиотека драйвера дисплея
- PureBasic Windows SDK

### Примечания по компиляции
- Цель: Консольное приложение
- Включить совместимость с XP
- Без требований к Unicode
- Связывание необходимых библиотек Windows

### Настройки IDE
```
ExecutableFormat = Console
EnableXP = Yes
Executable = WeActFPS.exe
```

## ⚠️ Ограничения
- Метод захвата экрана работает только на Windows
- Версии для Linux/Mac используют fallback значение 60 FPS
- Требуется эксклюзивный доступ к последовательному порту
- Возможны конфликты с другими приложениями, использующими COM порт
- OLED дисплеи могут подвергаться выгоранию при статическом контенте

## 🆘 Устранение неполадок

### "Cannot initialize display"
- Проверьте номер COM порта
- Убедитесь, что дисплей WeAct подключен и включен
- Убедитесь, что другие приложения не используют последовательный порт
- Попробуйте другой COM порт

### Неточные показания FPS
- Для частоты обновления: Обновите драйверы видеокарты
- Для захвата экрана: Запустите от имени администратора
- Попробуйте другие значения индекса монитора
- Увеличьте интервал обновления для более стабильных показаний

### Высокая загрузка CPU
- Увеличьте интервал обновления (например, `/i:2000`)
- Используйте метод частоты обновления вместо захвата экрана
- Закройте другие приложения

## 📝 Лицензия
Проект предоставляется "как есть" для образовательного и личного использования. Коммерческое использование может требовать дополнительных разрешений.


