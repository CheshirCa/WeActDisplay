# WeAct Display FS Library for PureBasic v4.0

![WeAct 0.96" Display](https://raw.githubusercontent.com/CheshirCa/WeActDisplay/refs/heads/main/USB_Display.jpg)

Улучшенная библиотека для работы с дисплеем WeAct Display FS 0.96-inch (160x80) через последовательный порт.

**GitHub:** https://github.com/CheshirCa/WeActDisplay

Enhanced library for working with WeAct Display FS 0.96-inch (160x80) via serial port.

## 🆕 Что нового в версии 4.0

**Русский:**
- ✅ **ИСПРАВЛЕНО:** Плавный скроллинг без рывков (накопление дробных пикселей)
- ✅ **ИСПРАВЛЕНО:** Корректная работа с ориентацией экрана согласно протоколу v1.1
- ✅ **НОВОЕ:** Поддержка режима `ROTATE` (автоповорот)
- ✅ **НОВОЕ:** Команда `FillScreen` для быстрой заливки цветом (протокол FULL)
- ✅ **НОВОЕ:** Рисование окружностей (контур и заполненные)
- ✅ **НОВОЕ:** Прогресс-бар с настройкой цветов
- ✅ **НОВОЕ:** Отображение графиков
- ✅ **НОВОЕ:** Индикатор загрузки (спиннер)
- ✅ **НОВОЕ:** Функции отображения времени и даты
- ✅ **УЛУЧШЕНО:** Обработка ошибок с функцией `GetLastError()`
- ✅ **УЛУЧШЕНО:** Динамические размеры буферов для разных ориентаций

**English:**
- ✅ **FIXED:** Smooth scrolling without jerking (fractional pixel accumulation)
- ✅ **FIXED:** Correct orientation handling according to protocol v1.1
- ✅ **NEW:** Support for `ROTATE` mode (auto-rotation)
- ✅ **NEW:** `FillScreen` command for fast color fill (FULL protocol)
- ✅ **NEW:** Circle drawing (outline and filled)
- ✅ **NEW:** Progress bar with color customization
- ✅ **NEW:** Graph display
- ✅ **NEW:** Loading spinner
- ✅ **NEW:** Time and date display functions
- ✅ **IMPROVED:** Error handling with `GetLastError()` function
- ✅ **IMPROVED:** Dynamic buffer sizes for different orientations

## 🌟 Основные возможности / Core Features

**Русский:**
- ✅ Поддержка дисплея WeAct Display FS 0.96-inch (160x80)
- ✅ Правильная работа с цветами BRG565
- ✅ Читаемый текст с поддержкой сглаживания
- ✅ Полная поддержка кириллицы
- ✅ Двойная буферизация для плавной анимации
- ✅ Все ориентации экрана (включая автоповорот)
- ✅ Загрузка изображений (BMP, JPEG, PNG, TIFF, TGA)
- ✅ Плавный скроллинг текста во всех направлениях
- ✅ Управление яркостью с плавными переходами
- ✅ Кэширование шрифтов для производительности
- ✅ Расширенные графические примитивы

**English:**
- ✅ Support for WeAct Display FS 0.96-inch (160x80)
- ✅ Correct BRG565 color handling
- ✅ Readable text with anti-aliasing support
- ✅ Full Cyrillic support
- ✅ Double buffering for smooth animation
- ✅ All screen orientations (including auto-rotation)
- ✅ Image loading (BMP, JPEG, PNG, TIFF, TGA)
- ✅ Smooth text scrolling in all directions
- ✅ Brightness control with smooth transitions
- ✅ Font caching for performance
- ✅ Extended graphics primitives

## 📋 Содержание / Table of Contents

- [Установка](#-установка--installation)
- [Инициализация](#-инициализация--initialization)
- [Базовые функции](#-базовые-функции--basic-functions)
- [Работа с текстом](#-работа-с-текстом--text-operations)
- [Графические функции](#-графические-функции--graphics-functions)
- [Скроллинг](#-скроллинг-текста--text-scrolling)
- [Изображения](#-работа-с-изображениями--image-operations)
- [Управление дисплеем](#-управление-дисплеем--display-control)
- [Новые функции v4.0](#-новые-функции-v40--new-functions-v40)
- [Вспомогательные функции](#-вспомогательные-функции--utility-functions)
- [Примеры](#-примеры--examples)
- [Исправление ошибок](#-исправленные-проблемы--fixed-issues)

## 🔧 Установка / Installation

**Русский:**
1. Скопируйте файл `WeActDisplay.pbi` в ваш проект
2. Подключите библиотеку: `XIncludeFile "WeActDisplay.pbi"`
3. Подключите дисплей к COM-порту (по умолчанию COM3)

**English:**
1. Copy `WeActDisplay.pbi` to your project
2. Include the library: `XIncludeFile "WeActDisplay.pbi"`
3. Connect the display to COM port (default COM3)

## 🚀 Инициализация / Initialization

### WeAct_Init(PortName.s = "COM3")
**Русский:** Инициализирует дисплей. Теперь с улучшенной обработкой ошибок.

**English:** Initializes the display. Now with improved error handling.

```purebasic
; Подключение к COM3 (по умолчанию)
If WeAct_Init()
  Debug "Дисплей инициализирован"
Else
  Debug "Ошибка: " + WeAct_GetLastError()
EndIf

; Подключение к определенному порту
If WeAct_Init("COM5")
  Debug "Успешное подключение к COM5"
EndIf
```

### WeAct_Close()
**Русский:** Закрывает соединение с дисплеем и освобождает ресурсы.

**English:** Closes the display connection and releases resources.

### WeAct_Cleanup()
**Русский:** Полная очистка всех ресурсов библиотеки.

**English:** Complete cleanup of all library resources.

```purebasic
WeAct_Cleanup()
```

## 🎨 Базовые функции / Basic Functions

### WeAct_ClearBuffer(Color = #WEACT_BLACK)
**Русский:** Очищает буфер указанным цветом. Теперь работает корректно для любой ориентации.

**English:** Clears the buffer with specified color. Now works correctly for any orientation.

```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)
WeAct_ClearBuffer(#WEACT_WHITE)
WeAct_ClearBuffer(RGBToRGB565(128, 128, 128))  ; Серый
```

### WeAct_UpdateDisplay()
**Русский:** Обновляет дисплей, отображая содержимое буфера.

**English:** Updates the display with buffer contents.

```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)
WeAct_DrawTextMedium(10, 10, "Hello World", #WEACT_WHITE)
WeAct_UpdateDisplay()
```

### RGBToRGB565(r, g, b)
**Русский:** Преобразует RGB цвет (0-255) в формат BRG565.

**English:** Converts RGB color (0-255) to BRG565 format.

```purebasic
color = RGBToRGB565(255, 0, 0)     ; Красный / Red
color = RGBToRGB565(0, 255, 0)     ; Зеленый / Green
color = RGBToRGB565(128, 64, 200)  ; Пользовательский / Custom
```

## 📝 Работа с текстом / Text Operations

### WeAct_DrawTextSmall/Medium/Large(x, y, Text.s, Color)
**Русский:** Рисует текст разных размеров. Полная поддержка кириллицы.

**English:** Draws text in different sizes. Full Cyrillic support.

```purebasic
WeAct_DrawTextSmall(10, 5, "Маленький текст", #WEACT_WHITE)
WeAct_DrawTextMedium(10, 20, "Средний текст", #WEACT_GREEN)
WeAct_DrawTextLarge(10, 40, "Большой", #WEACT_BLUE)
```

### WeAct_DrawTextSystemFont(x, y, Text.s, Color, FontSize, FontName.s)
**Русский:** Рисует текст с указанным шрифтом и размером.

**English:** Draws text with specified font and size.

```purebasic
WeAct_DrawTextSystemFont(10, 10, "Custom", #WEACT_RED, 14, "Arial")
WeAct_DrawTextSystemFont(10, 30, "Tahoma", #WEACT_YELLOW, 10, "Tahoma")
```

### WeAct_DrawWrappedTextFixed/AutoSize()
**Русский:** Рисует текст с переносом по словам.

**English:** Draws text with word wrapping.

```purebasic
; Фиксированный размер шрифта
WeAct_DrawWrappedTextFixed(5, 5, 150, 40, 
  "Длинный текст с автоматическим переносом строк", 
  #WEACT_WHITE, 10)

; Автоматический подбор размера
WeAct_DrawWrappedTextAutoSize(5, 5, 150, 40, 
  "Текст подберет оптимальный размер", 
  #WEACT_WHITE)
```

### WeAct_GetTextWidth/Height(Text.s, FontSize, FontName.s)
**Русский:** Возвращает размеры текста.

**English:** Returns text dimensions.

```purebasic
width = WeAct_GetTextWidth("Hello", 12, "Arial")
height = WeAct_GetTextHeight("Hello", 12, "Arial")
```

## 🎨 Графические функции / Graphics Functions

### WeAct_DrawPixelBuffer(x, y, Color)
**Русский:** Рисует пиксель.

**English:** Draws a pixel.

```purebasic
WeAct_DrawPixelBuffer(50, 40, #WEACT_RED)
```

### WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
**Русский:** Рисует линию (алгоритм Брезенхэма).

**English:** Draws a line (Bresenham's algorithm).

```purebasic
WeAct_DrawLineBuffer(10, 10, 150, 70, #WEACT_WHITE)
```

### WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, Filled)
**Русский:** Рисует прямоугольник.

**English:** Draws a rectangle.

```purebasic
; Заполненный / Filled
WeAct_DrawRectangleBuffer(10, 10, 50, 30, #WEACT_RED, #True)

; Контур / Outline
WeAct_DrawRectangleBuffer(70, 10, 50, 30, #WEACT_GREEN, #False)
```

### WeAct_DrawCircleBuffer(cx, cy, radius, Color, Filled) 🆕
**Русский:** Рисует окружность (алгоритм Брезенхэма).

**English:** Draws a circle (Bresenham's algorithm).

```purebasic
; Контур окружности / Circle outline
WeAct_DrawCircleBuffer(80, 40, 20, #WEACT_YELLOW, #False)

; Заполненная окружность / Filled circle
WeAct_DrawCircleBuffer(120, 40, 15, #WEACT_CYAN, #True)
```

## 🔄 Скроллинг текста / Text Scrolling

### ⚠️ ИСПРАВЛЕНО: Плавный скроллинг

**Русский:** В версии 4.0 полностью переработан механизм скроллинга. Теперь движение плавное без рывков на любой скорости благодаря накоплению дробных пикселей.

**English:** Version 4.0 completely reworked the scrolling mechanism. Now movement is smooth without jerking at any speed thanks to fractional pixel accumulation.

### WeAct_StartScrollText(Text.s, FontSize, Direction, Speed.f, Color, FontName.s)
**Русский:** Запускает скроллинг текста. **Speed** теперь в пикселях/секунду (float).

**English:** Starts text scrolling. **Speed** now in pixels/second (float).

```purebasic
; Горизонтальный скроллинг / Horizontal scrolling
WeAct_StartScrollText("Плавный скроллинг!", 12, #SCROLL_LEFT, 30.0, #WEACT_WHITE)

; Медленный вертикальный / Slow vertical
WeAct_StartScrollText("Вертикально", 12, #SCROLL_UP, 15.5, #WEACT_CYAN)
```

### WeAct_UpdateScrollText() / WeAct_DrawScrollText()
**Русский:** Обновление и отрисовка скроллируемого текста в цикле анимации.

**English:** Update and draw scrolling text in animation loop.

```purebasic
WeAct_StartScrollText("Smooth animation", 14, #SCROLL_LEFT, 40.0, #WEACT_GREEN)

For i = 1 To 200
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateScrollText()    ; Обновляем позицию
  WeAct_DrawScrollText()      ; Рисуем текст
  WeAct_UpdateDisplay()
  Delay(30)
Next

WeAct_StopScrollText()
```

### WeAct_ScrollTextLeft/Right/Up/Down()
**Русский:** Быстрый запуск скроллинга.

**English:** Quick start for scrolling.

```purebasic
WeAct_ScrollTextLeft("Left scroll", 25.0, 12, #WEACT_WHITE)
WeAct_ScrollTextRight("Right scroll", 20.0, 12, #WEACT_CYAN)
WeAct_ScrollTextUp("Up scroll", 15.0, 10, #WEACT_YELLOW)
WeAct_ScrollTextDown("Down scroll", 18.5, 10, #WEACT_MAGENTA)
```

## 🖼️ Работа с изображениями / Image Operations

### WeAct_LoadImageToBuffer(x, y, FileName.s, Width, Height)
**Русский:** Загружает изображение в указанную позицию с масштабированием.

**English:** Loads image to specified position with scaling.

```purebasic
; Оригинальный размер / Original size
WeAct_LoadImageToBuffer(10, 10, "image.bmp", -1, -1)

; С масштабированием / With scaling
WeAct_LoadImageToBuffer(20, 20, "image.jpg", 80, 40)
```

### WeAct_LoadImageFullScreen(FileName.s)
**Русский:** Загружает изображение на весь экран с сохранением пропорций.

**English:** Loads image to full screen with aspect ratio preserved.

```purebasic
WeAct_LoadImageFullScreen("background.jpg")
```

### WeAct_LoadImageCentered(FileName.s, Width, Height)
**Русский:** Загружает изображение по центру экрана.

**English:** Loads image centered on screen.

```purebasic
WeAct_LoadImageCentered("logo.png", 100, 50)
```

### WeAct_GetSupportedImageFormats()
**Русский:** Возвращает список поддерживаемых форматов.

**English:** Returns list of supported image formats.

```purebasic
formats$ = WeAct_GetSupportedImageFormats()
; Вернет: "BMP, JPEG, PNG, TIFF, TGA"
```

## ⚙️ Управление дисплеем / Display Control

### ⚠️ ИСПРАВЛЕНО: WeAct_SetOrientation(Orientation)

**Русский:** Устанавливает ориентацию дисплея согласно протоколу v1.1. Теперь поддерживает **режим ROTATE (5)** для автоматического поворота.

**English:** Sets display orientation according to protocol v1.1. Now supports **ROTATE mode (5)** for automatic rotation.

```purebasic
; Стандартные режимы / Standard modes
WeAct_SetOrientation(#WEACT_LANDSCAPE)           ; 160x80
WeAct_SetOrientation(#WEACT_PORTRAIT)            ; 80x160
WeAct_SetOrientation(#WEACT_REVERSE_LANDSCAPE)   ; 160x80 (перевернутый)
WeAct_SetOrientation(#WEACT_REVERSE_PORTRAIT)    ; 80x160 (перевернутый)

; Новый режим! / New mode!
WeAct_SetOrientation(#WEACT_ROTATE)              ; Автоповорот (5)
```

**⚠️ Важно:** После смены ориентации между PORTRAIT и LANDSCAPE изменяются размеры дисплея. Используйте `WeAct_GetDisplayWidth()` и `WeAct_GetDisplayHeight()` для получения актуальных размеров.

### WeAct_SetBrightness(Brightness, TimeMs = 500)
**Русский:** Устанавливает яркость (0-255) с плавным переходом.

**English:** Sets brightness (0-255) with smooth transition.

```purebasic
WeAct_SetBrightness(255)        ; Максимальная / Maximum
WeAct_SetBrightness(128)        ; Средняя / Medium
WeAct_SetBrightness(200, 2000)  ; Плавно за 2 секунды / Smooth over 2 sec
```

### WeAct_SystemReset()
**Русский:** Выполняет сброс дисплея (команда 0x40).

**English:** Performs display reset (command 0x40).

```purebasic
WeAct_SystemReset()
```

### WeAct_FillScreen(Color) 🆕
**Русский:** Быстрая заливка всего экрана цветом через команду FULL (0x04). Работает быстрее чем рисование через буфер.

**English:** Fast fill entire screen with color via FULL command (0x04). Faster than buffer-based drawing.

```purebasic
WeAct_FillScreen(#WEACT_RED)      ; Быстрая заливка красным
WeAct_FillScreen(#WEACT_BLUE)     ; Быстрая заливка синим
WeAct_FillScreen(RGBToRGB565(64, 64, 64))  ; Темно-серый
```

## 🆕 Новые функции v4.0 / New Functions v4.0

### WeAct_DrawProgressBar(x, y, Width, Height, Progress.f, ForeColor, BackColor, BorderColor)
**Русский:** Рисует прогресс-бар с настраиваемыми цветами.

**English:** Draws a progress bar with customizable colors.

```purebasic
; Progress от 0.0 до 1.0
WeAct_DrawProgressBar(10, 30, 140, 15, 0.65, 
  #WEACT_GREEN,     ; Цвет заполнения
  #WEACT_BLACK,     ; Цвет фона
  #WEACT_WHITE)     ; Цвет рамки

; Анимация прогресса / Progress animation
For progress.f = 0.0 To 1.0 Step 0.05
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawProgressBar(10, 30, 140, 15, progress)
  WeAct_UpdateDisplay()
  Delay(100)
Next
```

### WeAct_DrawGraph(x, y, Width, Height, *Data.Float, DataCount, MinValue.f, MaxValue.f, Color, BackColor)
**Русский:** Рисует график с автоматическим масштабированием.

**English:** Draws a graph with automatic scaling.

```purebasic
; Создаем данные (синусоида) / Create data (sine wave)
Protected Dim data.f(49)
For i = 0 To 49
  data(i) = Sin(i * 3.14159 * 2.0 / 50) * 0.8
Next

; Рисуем график / Draw graph
WeAct_DrawGraph(5, 15, 150, 60, @data(), 50, -1.0, 1.0, 
  #WEACT_CYAN, #WEACT_BLACK)
```

### WeAct_DrawSpinner(cx, cy, radius, angle.f, Color)
**Русский:** Рисует анимированный индикатор загрузки.

**English:** Draws an animated loading spinner.

```purebasic
; Анимация спиннера / Spinner animation
For angle.f = 0.0 To 360.0 Step 10.0
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextSmall(50, 30, "Загрузка...", #WEACT_WHITE)
  WeAct_DrawSpinner(80, 50, 20, angle, #WEACT_CYAN)
  WeAct_UpdateDisplay()
  Delay(30)
Next
```

### WeAct_ShowTime(x, y, Hour, Minute, Color, FontSize)
**Русский:** Отображает время в формате HH:MM.

**English:** Displays time in HH:MM format.

```purebasic
WeAct_ShowTime(30, 20, 14, 35, #WEACT_WHITE, 20)
; Отобразит: 14:35
```

### WeAct_ShowDate(x, y, Day, Month, Year, Color, FontSize)
**Русский:** Отображает дату в формате DD.MM.YYYY.

**English:** Displays date in DD.MM.YYYY format.

```purebasic
WeAct_ShowDate(30, 50, 10, 1, 2025, #WEACT_CYAN, 10)
; Отобразит: 10.01.2025
```

### WeAct_ShowTextFile(FileName.s, FontSize, Color, ScrollSpeed.f)
**Русский:** Загружает и отображает текстовый файл с автоматическим скроллингом.

**English:** Loads and displays text file with automatic scrolling.

```purebasic
WeAct_ShowTextFile("readme.txt", 8, #WEACT_WHITE, 25.0)
```

## 🔧 Вспомогательные функции / Utility Functions

### WeAct_IsConnected()
**Русский:** Проверяет подключен ли дисплей.

**English:** Checks if display is connected.

```purebasic
If WeAct_IsConnected()
  Debug "Connected"
EndIf
```

### WeAct_GetInfo()
**Русский:** Возвращает информацию о дисплее.

**English:** Returns display information.

```purebasic
info$ = WeAct_GetInfo()
; "WeAct Display FS 0.96-inch (COM3) 160x80"
```

### WeAct_GetDisplayWidth() / WeAct_GetDisplayHeight()
**Русский:** Возвращает текущие размеры дисплея (меняются при смене ориентации).

**English:** Returns current display dimensions (changes with orientation).

```purebasic
width = WeAct_GetDisplayWidth()
height = WeAct_GetDisplayHeight()
```

### WeAct_GetOrientation() / WeAct_GetBrightness()
**Русский:** Возвращает текущую ориентацию и яркость.

**English:** Returns current orientation and brightness.

```purebasic
orientation = WeAct_GetOrientation()
brightness = WeAct_GetBrightness()
```

### WeAct_GetLastError() 🆕
**Русский:** Возвращает текст последней ошибки.

**English:** Returns last error message.

```purebasic
If Not WeAct_Init("COM99")
  Debug "Ошибка: " + WeAct_GetLastError()
  ; "Failed to open serial port COM99"
EndIf
```

## 🎯 Примеры / Examples

### Простой пример / Simple Example
```purebasic
XIncludeFile "WeActDisplay_v4.pbi"

If WeAct_Init("COM3")
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 10, "Hello World!", #WEACT_WHITE)
  WeAct_DrawTextSmall(10, 30, "Привет мир!", #WEACT_GREEN)
  WeAct_DrawCircleBuffer(120, 50, 20, #WEACT_BLUE, #False)
  WeAct_UpdateDisplay()
  
  Delay(3000)
  WeAct_Cleanup()
EndIf
```

### Анимация скроллинга (исправлено) / Scrolling Animation (fixed)
```purebasic
XIncludeFile "WeActDisplay_v4.pbi"

If WeAct_Init("COM3")
  ; Плавный скроллинг на любой скорости!
  WeAct_StartScrollText("Плавное движение без рывков! ✨", 
                         12, #SCROLL_LEFT, 35.5, #WEACT_CYAN)
  
  For i = 1 To 300
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateScrollText()
    WeAct_DrawScrollText()
    WeAct_UpdateDisplay()
    Delay(30)
  Next
  
  WeAct_StopScrollText()
  WeAct_Cleanup()
EndIf
```

### Графический демо / Graphics Demo
```purebasic
XIncludeFile "WeActDisplay_v4.pbi"

If WeAct_Init("COM3")
  ; Геометрические фигуры
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  WeAct_DrawRectangleBuffer(10, 10, 40, 25, #WEACT_RED, #True)
  WeAct_DrawCircleBuffer(80, 22, 18, #WEACT_GREEN, #False)
  WeAct_DrawCircleBuffer(130, 22, 15, #WEACT_BLUE, #True)
  
  WeAct_DrawLineBuffer(10, 50, 150, 50, #WEACT_YELLOW)
  WeAct_DrawLineBuffer(10, 60, 150, 70, #WEACT_CYAN)
  
  WeAct_UpdateDisplay()
  Delay(3000)
  
  ; Быстрая заливка через команду FULL
  WeAct_FillScreen(#WEACT_MAGENTA)
  Delay(1000)
  WeAct_FillScreen(#WEACT_BLACK)
  
  WeAct_Cleanup()
EndIf
```

### Прогресс-бар и графики / Progress Bar and Graphs
```purebasic
XIncludeFile "WeActDisplay_v4.pbi"

If WeAct_Init("COM3")
  ; Анимированный прогресс-бар
  For progress.f = 0.0 To 1.0 Step 0.02
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_DrawTextSmall(10, 5, "Загрузка данных...", #WEACT_WHITE)
    WeAct_DrawProgressBar(10, 20, 140, 12, progress, 
                          #WEACT_GREEN, #WEACT_BLACK, #WEACT_WHITE)
    WeAct_DrawTextSmall(10, 38, Str(Int(progress * 100)) + "%", #WEACT_CYAN)
    WeAct_UpdateDisplay()
    Delay(50)
  Next
  
  Delay(1000)
  
  ; График
  Protected Dim data.f(39)
  For i = 0 To 39
    data(i) = Sin(i * 0.3) * Cos(i * 0.1)
  Next
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextSmall(5, 2, "Данные датчика", #WEACT_WHITE)
  WeAct_DrawGraph(5, 15, 150, 60, @data(), 40, -1.2, 1.2, 
                  #WEACT_YELLOW, #WEACT_BLACK)
  WeAct_UpdateDisplay()
  
  Delay(3000)
  WeAct_Cleanup()
EndIf
```

### Тест всех ориентаций / All Orientations Test
```purebasic
XIncludeFile "WeActDisplay_v4.pbi"

If WeAct_Init("COM3")
  Protected orientations.i(4) = {0, 1, 2, 3, 5}
  Protected names.s(4) = {"Portrait", "Rev Portrait", 
                          "Landscape", "Rev Landscape", "Rotate"}
  
  For i = 0 To 4
    If WeAct_SetOrientation(orientations(i))
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_DrawTextMedium(5, 5, names(i), #WEACT_WHITE)
      WeAct_DrawTextSmall(5, 25, "Size: " + 
        Str(WeAct_GetDisplayWidth()) + "x" + 
        Str(WeAct_GetDisplayHeight()), #WEACT_GREEN)
      
      ; Рамка для визуального контроля
      WeAct_DrawRectangleBuffer(0, 0, 
        WeAct_GetDisplayWidth(), 
        WeAct_GetDisplayHeight(), 
        #WEACT_YELLOW, #False)
      
      WeAct_UpdateDisplay()
      Delay(2000)
    EndIf
  Next
  
  WeAct_Cleanup()
EndIf
```

## 🔧 Исправленные проблемы / Fixed Issues

### 1. Скроллинг (Scrolling)

**Проблема / Problem:**
- Рывки при медленной скорости скроллинга
- Неравномерное движение
- Jerking at slow scrolling speeds
- Uneven movement

**Решение / Solution:**
```purebasic
; БЫЛО (v3.2):
Protected pixelsToMove.f = ScrollText\Speed * (deltaTime / 1000.0)
If pixelsToMove < 1.0
  ProcedureReturn  ; Дробные пиксели терялись!
EndIf

; СТАЛО (v4.0):
Protected pixelsToMove.f = ScrollText\Speed * (deltaTime / 1000.0)
ScrollText\AccumulatedPixels + pixelsToMove
Protected intPixelsToMove.i = Int(ScrollText\AccumulatedPixels)
If intPixelsToMove >= 1
  ScrollText\AccumulatedPixels - intPixelsToMove
  ; Перемещаем на целое количество пикселей
EndIf
```

**Результат / Result:**
- ✅ Плавное движение на любой скорости
- ✅ Накопление дробных пикселей
- ✅ Speed теперь float (точные значения)
- ✅ Smooth movement at any speed
- ✅ Fractional pixel accumulation
- ✅ Speed is now float (precise values)

### 2. Ориентация (Orientation)

**Проблема / Problem:**
- Отсутствие режима ROTATE (5) из протокола
- Не обновлялись размеры при смене ориентации
- Missing ROTATE mode (5) from protocol
- Dimensions not updated on orientation change

**Решение / Solution:**
```purebasic
; Добавлена константа:
#WEACT_ROTATE = 5

; Улучшена функция WeAct_SetOrientation:
Select Orientation
  Case #WEACT_PORTRAIT, #WEACT_REVERSE_PORTRAIT
    newWidth = 80 : newHeight = 160
  Case #WEACT_LANDSCAPE, #WEACT_REVERSE_LANDSCAPE
    newWidth = 160 : newHeight = 80
  Case #WEACT_ROTATE
    ; Автоповорот - размеры сохраняются
    newWidth = WeActDisplay\DisplayWidth
    newHeight = WeActDisplay\DisplayHeight
EndSelect

WeActDisplay\DisplayWidth = newWidth
WeActDisplay\DisplayHeight = newHeight
```

**Результат / Result:**
- ✅ Полная поддержка всех режимов протокола v1.1
- ✅ Корректное обновление размеров
- ✅ Режим автоповорота работает
- ✅ Full support for all protocol v1.1 modes
- ✅ Correct dimension updates
- ✅ Auto-rotation mode works

### 3. Обработка ошибок (Error Handling)

**Проблема / Problem:**
- Нет информации об ошибках
- Сложно диагностировать проблемы
- No error information
- Hard to diagnose issues

**Решение / Solution:**
```purebasic
; Добавлено поле LastError в структуру:
Structure WeActDisplay
  ; ...
  LastError.s
EndStructure

; Функция получения ошибки:
Procedure.s WeAct_GetLastError()
  ProcedureReturn WeActDisplay\LastError
EndProcedure

; Использование:
If Not WeAct_Init("COM99")
  Debug WeAct_GetLastError()
EndIf
```

**Результат / Result:**
- ✅ Информативные сообщения об ошибках
- ✅ Упрощенная отладка
- ✅ Informative error messages
- ✅ Simplified debugging

## 🎨 Предопределенные цвета / Predefined Colors

```purebasic
#WEACT_RED     = $07C0    ; Красный / Red
#WEACT_GREEN   = $001F    ; Зеленый / Green
#WEACT_BLUE    = $F800    ; Синий / Blue
#WEACT_WHITE   = $FFFF    ; Белый / White
#WEACT_BLACK   = $0000    ; Черный / Black
#WEACT_YELLOW  = $07FF    ; Желтый / Yellow
#WEACT_CYAN    = $F81F    ; Голубой / Cyan
#WEACT_MAGENTA = $FFE0    ; Пурпурный / Magenta
```

## 📊 Производительность / Performance

**Русский:**
- Кэширование шрифтов для быстрого рендеринга
- Двойная буферизация предотвращает мерцание
- Команда FULL для быстрой заливки
- Оптимизированный алгоритм скроллинга

**English:**
- Font caching for fast rendering
- Double buffering prevents flickering
- FULL command for fast filling
- Optimized scrolling algorithm

## 🐛 Отладка / Debugging

**Русский:**
Используйте `WeAct_GetLastError()` для диагностики:

**English:**
Use `WeAct_GetLastError()` for diagnostics:

```purebasic
If Not WeAct_Init("COM3")
  Debug "Init error: " + WeAct_GetLastError()
EndIf

If Not WeAct_SetOrientation(#WEACT_PORTRAIT)
  Debug "Orientation error: " + WeAct_GetLastError()
EndIf

If Not WeAct_LoadImageToBuffer(0, 0, "test.jpg", 80, 80)
  Debug "Image error: " + WeAct_GetLastError()
EndIf
```

## 📝 Лицензия / License

**Русский:** Открытый исходный код. Свободно используйте в своих проектах.

**English:** Open source. Free to use in your projects.

## 📞 Поддержка / Support

**Русский:**
- Проверьте номер COM-порта в Диспетчере устройств
- Убедитесь, что дисплей правильно подключен
- Используйте `WeAct_GetLastError()` для диагностики
- Запустите тестовую программу `WeAct_Test.pb`

**English:**
- Check COM port number in Device Manager
- Ensure display is properly connected
- Use `WeAct_GetLastError()` for diagnostics
- Run test program `WeAct_Test.pb`

---

**Version:** 4.0  
**Date:** January 2025  
**Compatibility:** PureBasic 6.20+, WeAct Display FS 0.96-inch (160x80)  
**Protocol:** v1.1
