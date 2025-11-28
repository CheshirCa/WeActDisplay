# WeActCLI - Консольная утилита для дисплея WeAct Display FS

WeActCLI - простая консольная утилита для вывода текста на дисплей WeAct Display FS 0.96-inch через последовательный порт.

# WeActCLI - Console Utility for WeAct Display FS

WeActCLI - simple console utility for displaying text on WeAct Display FS 0.96-inch via serial port.

## 🌟 Возможности / Features

**Русский:**
- ✅ Вывод текста на дисплей WeAct Display FS
- ✅ Автоматический подбор размера шрифта
- ✅ Поддержка цветного текста
- ✅ Автоматический перенос длинного текста
- ✅ Тихий режим для скриптового использования
- ✅ Подробный режим для отладки
- ✅ Проверка ошибок с понятными сообщениями

**English:**
- ✅ Text display on WeAct Display FS
- ✅ Automatic font size selection
- ✅ Colored text support
- ✅ Automatic text wrapping for long content
- ✅ Silent mode for scripting
- ✅ Verbose mode for debugging
- ✅ Error checking with clear messages

## 🔧 Установка / Installation

**Русский:**
1. Скомпилируйте программу:
   ```bash
   pbcompiler /CONSOLE WeActCLI.pb
   ```
2. Убедитесь, что файл `WeActDisplay.pbi` находится в той же папке
3. Подключите дисплей WeAct к COM-порту

**English:**
1. Compile the program:
   ```bash
   pbcompiler /CONSOLE WeActCLI.pb
   ```
2. Ensure `WeActDisplay.pbi` is in the same folder
3. Connect WeAct display to COM port

## 📝 Синтаксис / Syntax

**Русский:**
```cmd
WeActCLI /p:X [/v][/c:YYY] "текст"
```

**English:**
```cmd
WeActCLI /p:X [/v][/c:YYY] "text"
```

## ⚙️ Параметры / Parameters

### `/p:X` - COM порт (обязательный) / COM Port (required)

**Русский:** Указывает номер COM-порта для подключения дисплея.

**English:** Specifies COM port number for display connection.

```cmd
WeActCLI /p:3 "Hello"      ; COM3
WeActCLI /p:5 "Hello"      ; COM5
```

### `/c:YYY` - Цвет текста (опционально) / Text Color (optional)

**Русский:** Задает цвет текста. Доступные цвета:
- `red` - красный
- `green` - зеленый  
- `blue` - синий
- `white` - белый
- `black` - черный
- `yellow` - желтый (по умолчанию)
- `cyan` - голубой
- `magenta` - пурпурный

**English:** Sets text color. Available colors:
- `red` - red
- `green` - green
- `blue` - blue
- `white` - white
- `black` - black
- `yellow` - yellow (default)
- `cyan` - cyan
- `magenta` - magenta

```cmd
WeActCLI /p:3 /c:red "Alert!"
WeActCLI /p:3 /c:green "Status: OK"
```

### `/v` - Подробный режим (опционально) / Verbose Mode (optional)

**Русский:** Включает вывод информационных сообщений. По умолчанию отключен.

**English:** Enables informational messages output. Disabled by default.

```cmd
WeActCLI /p:3 /v "Debug info"
```

### "текст" - Текст для отображения (обязательный) / Text to Display (required)

**Русский:** Текст, который будет отображен на дисплее. Должен быть в кавычках.

**English:** Text to be displayed on the screen. Must be in quotes.

```cmd
WeActCLI /p:3 "Hello World!"
```

## 🎯 Примеры использования / Usage Examples

### Базовые примеры / Basic Examples

**Русский:**
```cmd
:: Простой вывод
WeActCLI /p:3 "Hello World!"

:: Вывод с красным цветом
WeActCLI /p:3 /c:red "ВНИМАНИЕ: Ошибка!"

:: Вывод с зеленым цветом
WeActCLI /p:5 /c:green "Статус: Система работает"

:: Подробный режим для отладки
WeActCLI /p:3 /v "Тестовое сообщение"
```

**English:**
```cmd
:: Simple display
WeActCLI /p:3 "Hello World!"

:: Display with red color
WeActCLI /p:3 /c:red "ALERT: Error detected!"

:: Display with green color  
WeActCLI /p:5 /c:green "Status: System OK"

:: Verbose mode for debugging
WeActCLI /p:3 /v "Test message"
```

### Примеры для скриптов / Scripting Examples

**Русский:**
```cmd
:: Вывод статуса системы (тихий режим)
WeActCLI /p:3 "Сервер запущен"

:: Вывод температуры
WeActCLI /p:3 /c:cyan "Температура: 23.5°C"

:: Вывод предупреждения
WeActCLI /p:3 /c:yellow "Предупреждение: Высокая нагрузка"
```

**English:**
```cmd
:: System status display (silent mode)
WeActCLI /p:3 "Server running"

:: Temperature display
WeActCLI /p:3 /c:cyan "Temperature: 23.5°C"

:: Warning display
WeActCLI /p:3 /c:yellow "Warning: High load"
```

### Длинный текст / Long Text

**Русский:**
```cmd
:: Автоматический перенос длинного текста
WeActCLI /p:3 "Это очень длинный текст который будет автоматически перенесен для удобства чтения на маленьком дисплее"
```

**English:**
```cmd
:: Automatic wrapping for long text
WeActCLI /p:3 "This is a very long text that will be automatically wrapped to fit the small display for better readability"
```

### Справка / Help

**Русский:**
```cmd
:: Показать справку
WeActCLI /?
WeActCLI /h
```

**English:**
```cmd
:: Show help
WeActCLI /?
WeActCLI /h
```

## 📊 Коды возврата / Return Codes

**Русский:**
- `0` - Успешное выполнение
- `1` - Ошибка (неверные параметры, проблемы с подключением)

**English:**
- `0` - Success
- `1` - Error (invalid parameters, connection issues)

**Пример использования в скриптах / Example in scripts:**
```cmd
WeActCLI /p:3 "Script started"
IF %ERRORLEVEL% NEQ 0 (
    ECHO Error displaying text
    EXIT /B 1
)
```

## 🔄 Автоматические функции / Automatic Features

### Автоподбор размера шрифта / Automatic Font Size Selection

**Русский:** Программа автоматически выбирает оптимальный размер шрифта:
- **1-10 символов:** Крупный шрифт (16pt)
- **11-20 символов:** Средний шрифт (12pt)  
- **21+ символов:** Мелкий шрифт (8pt)
- **25+ символов:** Автоматический перенос текста

**English:** Program automatically selects optimal font size:
- **1-10 characters:** Large font (16pt)
- **11-20 characters:** Medium font (12pt)
- **21+ characters:** Small font (8pt) 
- **25+ characters:** Automatic text wrapping

### Примеры автоматического подбора / Automatic Selection Examples

```cmd
WeActCLI /p:3 "Hi"           ; Large font (16pt)
WeActCLI /p:3 "Hello World"  ; Medium font (12pt)  
WeActCLI /p:3 "This is a longer text example"  ; Small font (8pt)
WeActCLI /p:3 "This is a very long text that demonstrates automatic wrapping feature"  ; Wrapped text
```

## 🐛 Отладка / Debugging

**Русский:** При возникновении проблем используйте ключ `/v` для получения подробной информации:

```cmd
WeActCLI /p:3 /v "Тестовое сообщение"
```

**Вывод:**
```
Initializing WeAct Display FS...
Port: COM3
Display initialized successfully
Displaying text: "Тестовое сообщение"
Text displayed successfully
Font size: 12
Text color: yellow
Display connection closed
Operation completed successfully
```

**English:** Use `/v` key for detailed information when troubleshooting:

```cmd
WeActCLI /p:3 /v "Test message"
```

**Output:**
```
Initializing WeAct Display FS...
Port: COM3
Display initialized successfully
Displaying text: "Test message"
Text displayed successfully
Font size: 12
Text color: yellow
Display connection closed
Operation completed successfully
```

## 💡 Советы / Tips

**Русский:**
- Используйте двойные кавычки для текста с пробелами
- Для скриптового использования не указывайте `/v`
- Проверьте номер COM-порта в Диспетчере устройств
- Убедитесь, что дисплей правильно подключен

**English:**
- Use double quotes for text with spaces
- Omit `/v` for scripting use
- Check COM port number in Device Manager
- Ensure display is properly connected

