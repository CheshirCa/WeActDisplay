# WeAct Display FS Library for PureBasic v5.0 - Professional Edition

![WeAct 0.96" Display](https://raw.githubusercontent.com/CheshirCa/WeActDisplay/refs/heads/main/USB_Display.jpg)

Улучшенная профессиональная библиотека для работы с дисплеем WeAct Display FS 0.96-inch (160x80) через последовательный порт.

**GitHub:** https://github.com/CheshirCa/WeActDisplay

Enhanced professional library for working with WeAct Display FS 0.96-inch (160x80) via serial port.

## ⚠️ ВАЖНОЕ ЗАМЕЧАНИЕ / IMPORTANT NOTE

**Русский:** 
Дисплей WeAct FS использует формат **BRG565** (Blue-Red-Green), а не стандартный RGB565. Все функции библиотеки автоматически преобразуют цвета в правильный формат. Предопределенные цвета (`#WEACT_RED`, `#WEACT_GREEN`, и т.д.) уже корректно настроены для BRG565.

**English:**
WeAct FS display uses **BRG565** format (Blue-Red-Green), not standard RGB565. All library functions automatically convert colors to the correct format. Predefined colors (`#WEACT_RED`, `#WEACT_GREEN`, etc.) are already correctly configured for BRG565.

## 🆕 Что нового в версии 5.0 - Professional Edition

**Русский:**
- ✅ **ПРОФЕССИОНАЛЬНОЕ ИЗДАНИЕ:** Полный рефакторинг кода с улучшенной архитектурой
- ✅ **ИСПРАВЛЕНО:** Корректное преобразование RGB в BRG565 с новой функцией `RGBToRGB565_Fixed()`
- ✅ **ИСПРАВЛЕНО:** Рендеринг текста теперь использует 24-bit изображения вместо 32-bit
- ✅ **ИСПРАВЛЕНО:** Полная обработка аппаратных ограничений дисплея при масштабировании изображений
- ✅ **НОВОЕ:** Функция `WeAct_LoadImageFast()` для максимальной производительности
- ✅ **НОВОЕ:** Подробные предупреждения о лимитах масштабирования в отладочном режиме
- ✅ **УЛУЧШЕНО:** Оптимизированное управление памятью и буферами
- ✅ **УЛУЧШЕНО:** Расширенная диагностика ошибок
- ✅ **СОХРАНЕНО:** Все функции и улучшения из версии 4.0

**English:**
- ✅ **PROFESSIONAL EDITION:** Complete code refactoring with improved architecture
- ✅ **FIXED:** Correct RGB to BRG565 conversion with new `RGBToRGB565_Fixed()` function
- ✅ **FIXED:** Text rendering now uses 24-bit images instead of 32-bit
- ✅ **FIXED:** Full handling of display hardware limitations when scaling images
- ✅ **NEW:** `WeAct_LoadImageFast()` function for maximum performance
- ✅ **NEW:** Detailed scaling limit warnings in debug mode
- ✅ **IMPROVED:** Optimized memory and buffer management
- ✅ **IMPROVED:** Extended error diagnostics
- ✅ **PRESERVED:** All functions and improvements from version 4.0

## 🌟 Основные возможности / Core Features

**Русский:**
- ✅ Поддержка дисплея WeAct Display FS 0.96-inch (160x80)
- ✅ Автоматическое преобразование цветов в формат BRG565
- ✅ Полная поддержка кириллицы и Unicode
- ✅ Двойная буферизация для плавной анимации без мерцания
- ✅ Все ориентации экрана + режим автоповорота (ROTATE)
- ✅ Загрузка изображений (BMP, JPEG, PNG, TIFF, TGA) с оптимизацией
- ✅ Плавный скроллинг текста с накоплением дробных пикселей
- ✅ Расширенные графические примитивы: линии, прямоугольники, окружности
- ✅ Прогресс-бары, графики, индикаторы загрузки
- ✅ Управление яркостью с плавными переходами
- ✅ Кэширование шрифтов для максимальной производительности
- ✅ Расширенная обработка ошибок с информативными сообщениями

**English:**
- ✅ Support for WeAct Display FS 0.96-inch (160x80)
- ✅ Automatic color conversion to BRG565 format
- ✅ Full Cyrillic and Unicode support
- ✅ Double buffering for smooth flicker-free animation
- ✅ All screen orientations + auto-rotation mode (ROTATE)
- ✅ Image loading (BMP, JPEG, PNG, TIFF, TGA) with optimization
- ✅ Smooth text scrolling with fractional pixel accumulation
- ✅ Extended graphics primitives: lines, rectangles, circles
- ✅ Progress bars, graphs, loading indicators
- ✅ Brightness control with smooth transitions
- ✅ Font caching for maximum performance
- ✅ Extended error handling with informative messages

## 📋 Содержание / Table of Contents

- [Важное замечание](#-важное-замечание--important-note)
- [Что нового](#-что-нового-в-версии-50---professional-edition)
- [Основные возможности](#-основные-возможности--core-features)
- [Установка](#-установка--installation)
- [Инициализация](#-инициализация--initialization)
- [Работа с цветами](#-работа-с-цветами--color-operations)
- [Базовые функции](#-базовые-функции--basic-functions)
- [Работа с текстом](#-работа-с-текстом--text-operations)
- [Графические функции](#-графические-функции--graphics-functions)
- [Скроллинг](#-скроллинг-текста--text-scrolling)
- [Изображения](#-работа-с-изображениями--image-operations)
- [Управление дисплеем](#-управление-дисплеем--display-control)
- [Новые функции v5.0](#-новые-функции-v50--new-functions-v50)
- [Вспомогательные функции](#-вспомогательные-функции--utility-functions)
- [Примеры](#-примеры--examples)
- [Исправление ошибок](#-исправленные-проблемы--fixed-issues)
- [Производительность](#-производительность--performance)
- [Отладка](#-отладка--debugging)
- [Лицензия](#-лицензия--license)
- [Поддержка](#-поддержка--support)

## 🔧 Установка / Installation

**Русский:**
1. Скопируйте файл `WeActDisplay.pbi` в ваш проект PureBasic
2. Подключите библиотеку: `XIncludeFile "WeActDisplay.pbi"`
3. Подключите дисплей к COM-порту (по умолчанию COM3)
4. Убедитесь, что установлен PureBasic 6.21 или новее

**English:**
1. Copy `WeActDisplay.pbi` to your PureBasic project
2. Include the library: `XIncludeFile "WeActDisplay.pbi"`
3. Connect the display to COM port (default COM3)
4. Ensure PureBasic 6.21 or newer is installed

## 🚀 Инициализация / Initialization

### WeAct_Init(PortName.s = "COM3")
**Русский:** Инициализирует дисплей с улучшенной обработкой ошибок и автоматической настройкой.

**English:** Initializes the display with improved error handling and automatic configuration.

```purebasic
; Подключение к COM3 (по умолчанию) / Connect to COM3 (default)
If WeAct_Init()
  Debug "Дисплей инициализирован / Display initialized"
Else
  Debug "Ошибка: " + WeAct_GetLastError()
EndIf

; Подключение к определенному порту / Connect to specific port
If WeAct_Init("COM5")
  Debug "Успешное подключение к COM5 / Successful connection to COM5"
EndIf
```

### WeAct_Close()
**Русский:** Закрывает соединение с дисплеем и освобождает ресурсы.

**English:** Closes the display connection and releases resources.

### WeAct_Cleanup()
**Русский:** Полная очистка всех ресурсов библиотеки, включая кэш шрифтов.

**English:** Complete cleanup of all library resources including font cache.

```purebasic
WeAct_Cleanup()
```

## 🎨 Работа с цветами / Color Operations

### Важно: Формат BRG565
Дисплей использует нестандартный формат BRG565. Библиотека предоставляет две функции для работы с цветами:

```purebasic
; 1. Исправленная функция (рекомендуется для точности)
color = RGBToRGB565_Fixed(255, 0, 0)  ; Красный / Red

; 2. Макрос для обратной совместимости
color = RGBToRGB565(255, 0, 0)        ; Автоматически вызывает исправленную функцию

; Преобразование собственных цветов
myColor = RGBToRGB565(128, 64, 200)   ; Пользовательский цвет / Custom color
```

### Предопределенные цвета / Predefined Colors
```purebasic
; ВАЖНО: Эти значения уже в формате BRG565!
#WEACT_RED     = $F800    ; Красный / Red
#WEACT_GREEN   = $07E0    ; Зеленый / Green  
#WEACT_BLUE    = $001F    ; Синий / Blue
#WEACT_WHITE   = $FFFF    ; Белый / White
#WEACT_BLACK   = $0000    ; Черный / Black
#WEACT_YELLOW  = $FFE0    ; Желтый / Yellow
#WEACT_CYAN    = $07FF    ; Голубой / Cyan
#WEACT_MAGENTA = $F81F    ; Пурпурный / Magenta
```

## 🎨 Базовые функции / Basic Functions

### WeAct_ClearBuffer(Color = #WEACT_BLACK)
**Русский:** Очищает буфер указанным цветом. Работает корректно для любой ориентации.

**English:** Clears the buffer with specified color. Works correctly for any orientation.

```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)
WeAct_ClearBuffer(#WEACT_WHITE)
WeAct_ClearBuffer(RGBToRGB565(128, 128, 128))  ; Серый / Gray
```

### WeAct_UpdateDisplay()
**Русский:** Обновляет дисплей, отображая содержимое буфера с двойной буферизацией.

**English:** Updates the display with buffer contents using double buffering.

```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)
WeAct_DrawTextMedium(10, 10, "Hello World", #WEACT_WHITE)
WeAct_UpdateDisplay()
```

## 📝 Работа с текстом / Text Operations

### WeAct_DrawTextSmall/Medium/Large(x, y, Text.s, Color)
**Русский:** Рисует текст предопределенных размеров. Полная поддержка кириллицы.

**English:** Draws text in predefined sizes. Full Cyrillic support.

```purebasic
WeAct_DrawTextSmall(10, 5, "Маленький текст", #WEACT_WHITE)
WeAct_DrawTextMedium(10, 20, "Средний текст", #WEACT_GREEN)
WeAct_DrawTextLarge(10, 40, "Большой", #WEACT_BLUE)
```

### WeAct_DrawTextSystemFont(x, y, Text.s, Color, FontSize, FontName.s)
**Русский:** Рисует текст с указанным шрифтом и размером. **Исправлено:** Теперь использует 24-bit рендеринг.

**English:** Draws text with specified font and size. **Fixed:** Now uses 24-bit rendering.

```purebasic
WeAct_DrawTextSystemFont(10, 10, "Custom", #WEACT_RED, 14, "Arial")
WeAct_DrawTextSystemFont(10, 30, "Tahoma", #WEACT_YELLOW, 10, "Tahoma")
```

### WeAct_GetTextWidth/Height(Text.s, FontSize, FontName.s)
**Русский:** Возвращает размеры текста для точного позиционирования.

**English:** Returns text dimensions for precise positioning.

```purebasic
width = WeAct_GetTextWidth("Hello", 12, "Arial")
height = WeAct_GetTextHeight("Hello", 12, "Arial")
```

## 🎨 Графические функции / Graphics Functions

### WeAct_DrawPixelBuffer(x, y, Color)
**Русский:** Рисует отдельный пиксель указанным цветом.

**English:** Draws a single pixel with specified color.

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
**Русский:** Рисует прямоугольник или заполненный прямоугольник.

**English:** Draws a rectangle or filled rectangle.

```purebasic
; Заполненный / Filled
WeAct_DrawRectangleBuffer(10, 10, 50, 30, #WEACT_RED, #True)

; Контур / Outline
WeAct_DrawRectangleBuffer(70, 10, 50, 30, #WEACT_GREEN, #False)
```

### WeAct_DrawCircleBuffer(cx, cy, radius, Color, Filled)
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

**Русский:** В версии 5.0 механизм скроллинга полностью оптимизирован. Движение плавное без рывков благодаря накоплению дробных пикселей.

**English:** Version 5.0 has fully optimized scrolling mechanism. Movement is smooth without jerking thanks to fractional pixel accumulation.

### WeAct_StartScrollText(Text.s, FontSize, Direction, Speed.f, Color, FontName.s)
**Русский:** Запускает скроллинг текста. **Speed** в пикселях/секунду (float).

**English:** Starts text scrolling. **Speed** in pixels/second (float).

```purebasic
; Горизонтальный скроллинг / Horizontal scrolling
WeAct_StartScrollText("Плавный скроллинг!", 12, #SCROLL_LEFT, 30.0, #WEACT_WHITE)

; Медленный вертикальный / Slow vertical
WeAct_StartScrollText("Вертикально", 12, #SCROLL_UP, 15.5, #WEACT_CYAN)
```

### Анимация скроллинга / Scrolling Animation
```purebasic
WeAct_StartScrollText("Smooth animation", 14, #SCROLL_LEFT, 40.0, #WEACT_GREEN)

For i = 1 To 200
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateScrollText()    ; Обновляем позицию / Update position
  WeAct_DrawScrollText()      ; Рисуем текст / Draw text
  WeAct_UpdateDisplay()
  Delay(30)
Next

WeAct_StopScrollText()
```

## 🖼️ Работа с изображениями / Image Operations

### WeAct_LoadImageToBuffer(x, y, FileName.s, Width, Height)
**Русский:** Загружает изображение с масштабированием. **Внимание:** Дисплей имеет аппаратные ограничения на масштабирование.

**English:** Loads image with scaling. **Note:** Display has hardware limitations for scaling.

```purebasic
; Оригинальный размер / Original size
WeAct_LoadImageToBuffer(10, 10, "image.bmp", -1, -1)

; С масштабированием / With scaling
WeAct_LoadImageToBuffer(20, 20, "image.jpg", 80, 40)
; В отладке появится предупреждение о лимитах масштабирования
```

### WeAct_LoadImageFast(x, y, FileName.s) 🆕
**Русский:** Быстрая загрузка изображения БЕЗ масштабирования. Максимальная производительность.

**English:** Fast image loading WITHOUT scaling. Maximum performance.

```purebasic
; Быстрая загрузка (изображение должно быть правильного размера)
WeAct_LoadImageFast(10, 10, "icon.bmp")
```

### WeAct_LoadImageFullScreen(FileName.s)
**Русский:** Загружает изображение на весь экран с сохранением пропорций.

**English:** Loads image to full screen with aspect ratio preserved.

```purebasic
WeAct_LoadImageFullScreen("background.jpg")
```

### WeAct_GetSupportedImageFormats()
**Русский:** Возвращает список поддерживаемых форматов.

**English:** Returns list of supported image formats.

```purebasic
formats$ = WeAct_GetSupportedImageFormats()
; Вернет / Returns: "BMP, JPEG, PNG, TIFF, TGA"
```

## ⚙️ Управление дисплеем / Display Control

### WeAct_SetOrientation(Orientation)
**Русский:** Устанавливает ориентацию дисплея согласно протоколу v1.1. Поддерживает **режим ROTATE (5)**.

**English:** Sets display orientation according to protocol v1.1. Supports **ROTATE mode (5)**.

```purebasic
; Стандартные режимы / Standard modes
WeAct_SetOrientation(#WEACT_LANDSCAPE)           ; 160x80
WeAct_SetOrientation(#WEACT_PORTRAIT)            ; 80x160
WeAct_SetOrientation(#WEACT_REVERSE_LANDSCAPE)   ; 160x80 (перевернутый)
WeAct_SetOrientation(#WEACT_REVERSE_PORTRAIT)    ; 80x160 (перевернутый)

; Автоповорот! / Auto-rotation!
WeAct_SetOrientation(#WEACT_ROTATE)              ; Режим 5 / Mode 5
```

**⚠️ Важно:** После смены ориентации изменяются размеры дисплея. Используйте `WeAct_GetDisplayWidth()` и `WeAct_GetDisplayHeight()` для актуальных размеров.

### WeAct_FillScreen(Color) 🆕
**Русский:** Быстрая заливка всего экрана цветом через команду FULL (0x04). Работает быстрее чем рисование через буфер.

**English:** Fast fill entire screen with color via FULL command (0x04). Faster than buffer-based drawing.

```purebasic
WeAct_FillScreen(#WEACT_RED)      ; Быстрая заливка красным / Fast red fill
WeAct_FillScreen(RGBToRGB565(64, 64, 64))  ; Темно-серый / Dark gray
```

## 🆕 Новые функции v5.0 / New Functions v5.0

### WeAct_DrawProgressBar(x, y, Width, Height, Progress.f, ForeColor, BackColor, BorderColor)
**Русский:** Рисует прогресс-бар с настраиваемыми цветами.

**English:** Draws a progress bar with customizable colors.

```purebasic
; Progress от 0.0 до 1.0
WeAct_DrawProgressBar(10, 30, 140, 15, 0.65, 
  #WEACT_GREEN,     ; Цвет заполнения / Fill color
  #WEACT_BLACK,     ; Цвет фона / Background color
  #WEACT_WHITE)     ; Цвет рамки / Border color
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
  WeAct_DrawSpinner(80, 50, 20, angle, #WEACT_CYAN)
  WeAct_UpdateDisplay()
  Delay(30)
Next
```

## 🔧 Вспомогательные функции / Utility Functions

### WeAct_GetLastError()
**Русский:** Возвращает текст последней ошибки для диагностики.

**English:** Returns last error message for diagnostics.

```purebasic
If Not WeAct_Init("COM99")
  Debug "Ошибка: " + WeAct_GetLastError()
  ; "Failed to open serial port COM99"
EndIf
```

### WeAct_GetInfo()
**Русский:** Возвращает информацию о дисплее и подключении.

**English:** Returns display and connection information.

```purebasic
info$ = WeAct_GetInfo()
; "WeAct Display FS 0.96-inch (COM3) 160x80"
```

### WeAct_GetDisplayWidth() / WeAct_GetDisplayHeight()
**Русский:** Возвращает текущие размеры дисплея.

**English:** Returns current display dimensions.

```purebasic
width = WeAct_GetDisplayWidth()
height = WeAct_GetDisplayHeight()
```

## 🎯 Примеры / Examples

### Простой пример / Simple Example
```purebasic
XIncludeFile "WeActDisplay.pbi"

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

### Тест быстрой загрузки изображений / Fast Image Loading Test
```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM3")
  ; Обычная загрузка с масштабированием
  WeAct_ClearBuffer(#WEACT_BLACK)
  If WeAct_LoadImageToBuffer(10, 10, "test.jpg", 100, 50)
    Debug "Изображение загружено с масштабированием"
  EndIf
  WeAct_UpdateDisplay()
  Delay(2000)
  
  ; Быстрая загрузка (без масштабирования)
  WeAct_ClearBuffer(#WEACT_BLACK)
  If WeAct_LoadImageFast(10, 10, "fast.bmp")
    Debug "Быстрая загрузка выполнена"
  EndIf
  WeAct_UpdateDisplay()
  Delay(2000)
  
  WeAct_Cleanup()
EndIf
```

### Тест цветов BRG565 / BRG565 Color Test
```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM3")
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Тестируем предопределенные цвета в формате BRG565
  WeAct_DrawTextMedium(10, 5, "BRG565 Color Test", #WEACT_WHITE)
  
  WeAct_DrawRectangleBuffer(10, 25, 40, 20, #WEACT_RED, #True)
  WeAct_DrawTextSmall(55, 30, "RED (BRG: $F800)", #WEACT_WHITE)
  
  WeAct_DrawRectangleBuffer(10, 50, 40, 20, #WEACT_GREEN, #True)
  WeAct_DrawTextSmall(55, 55, "GREEN (BRG: $07E0)", #WEACT_WHITE)
  
  WeAct_DrawRectangleBuffer(10, 75, 40, 20, #WEACT_BLUE, #True)
  WeAct_DrawTextSmall(55, 80, "BLUE (BRG: $001F)", #WEACT_WHITE)
  
  ; Тест преобразования RGB в BRG565
  Protected customColor = RGBToRGB565(255, 128, 0)  ; Оранжевый
  WeAct_DrawRectangleBuffer(10, 100, 40, 20, customColor, #True)
  WeAct_DrawTextSmall(55, 105, "Custom RGB(255,128,0)", #WEACT_WHITE)
  
  WeAct_UpdateDisplay()
  Delay(5000)
  WeAct_Cleanup()
EndIf
```

## 🔧 Исправленные проблемы / Fixed Issues

### 1. Преобразование цветов (Color Conversion)
**Проблема / Problem:** Неправильное преобразование RGB в BRG565 формате дисплея.
**Решение / Solution:** Новая функция `RGBToRGB565_Fixed()` с правильным преобразованием.

```purebasic
; Исправленный код / Fixed code:
Procedure.i RGBToRGB565_Fixed(r, g, b)
  r = r & $FF
  g = g & $FF  
  b = b & $FF
  
  Protected r5 = (r >> 3) & $1F    ; 5 бит красного / 5 red bits
  Protected g6 = (g >> 2) & $3F    ; 6 бит зеленого / 6 green bits
  Protected b5 = (b >> 3) & $1F    ; 5 бит синего / 5 blue bits
  
  ProcedureReturn (r5 << 11) | (g6 << 5) | b5
EndProcedure
```

### 2. Рендеринг текста (Text Rendering)
**Проблема / Problem:** Использование 32-bit формата для рендеринга текста.
**Решение / Solution:** Переход на 24-bit рендеринг для совместимости.

```purebasic
; Было / Was: (32-bit)
Protected renderImage = CreateImage(#PB_Any, textWidth + 4, textHeight + 4, 32)

; Стало / Now: (24-bit)
Protected renderImage = CreateImage(#PB_Any, textWidth + 4, textHeight + 4, 24, RGB(0, 0, 0))
```

### 3. Аппаратные ограничения масштабирования (Hardware Scaling Limitations)
**Проблема / Problem:** Дисплей имеет ограничения на произвольное масштабирование.
**Решение / Solution:** Добавлены предупреждения и новая функция для быстрой загрузки.

```purebasic
; При масштабировании выводится предупреждение:
Debug "ВНИМАНИЕ: Дисплей WeAct FS имеет аппаратные ограничения на масштабирование."
Debug "Рекомендуется загружать изображения в оригинальном размере..."

; Альтернатива: быстрая загрузка без масштабирования
WeAct_LoadImageFast(x, y, "image.bmp")
```

## 📊 Производительность / Performance

**Русский:**
- ✅ **Кэширование шрифтов:** Ускоренный рендеринг текста
- ✅ **Двойная буферизация:** Полное отсутствие мерцания
- ✅ **Быстрая заливка:** Команда FULL для мгновенной заливки экрана
- ✅ **Оптимизированный скроллинг:** Накопление дробных пикселей
- ✅ **Быстрая загрузка изображений:** Функция `LoadImageFast` для максимальной скорости
- ✅ **Эффективное управление памятью:** Фиксированные буферы для всех ориентаций

**English:**
- ✅ **Font caching:** Accelerated text rendering
- ✅ **Double buffering:** Complete elimination of flickering
- ✅ **Fast fill:** FULL command for instant screen filling
- ✅ **Optimized scrolling:** Fractional pixel accumulation
- ✅ **Fast image loading:** `LoadImageFast` function for maximum speed
- ✅ **Efficient memory management:** Fixed buffers for all orientations

## 🐛 Отладка / Debugging

**Русский:**
Используйте `WeAct_GetLastError()` для диагностики проблем:

**English:**
Use `WeAct_GetLastError()` for problem diagnostics:

```purebasic
If Not WeAct_Init("COM3")
  Debug "Init error: " + WeAct_GetLastError()
EndIf

If Not WeAct_LoadImageToBuffer(0, 0, "test.jpg", 80, 80)
  Debug "Image error: " + WeAct_GetLastError()
EndIf

; Включите отладку для предупреждений о масштабировании
; Enable debugging for scaling warnings
```

## 📝 Лицензия / License

**Русский:** Открытый исходный код. Свободно используйте в своих проектах. Профессиональное издание предоставляет улучшенную стабильность и производительность.

**English:** Open source. Free to use in your projects. Professional edition provides enhanced stability and performance.

## 📞 Поддержка / Support

**Русский:**
1. Проверьте номер COM-порта в Диспетчере устройств Windows
2. Убедитесь, что дисплей правильно подключен и питается
3. Используйте `WeAct_GetLastError()` для получения детальной информации об ошибках
4. Для изображений используйте `WeAct_LoadImageFast()` если не требуется масштабирование
5. Помните о формате BRG565 при работе с пользовательскими цветами

**English:**
1. Check COM port number in Windows Device Manager
2. Ensure display is properly connected and powered
3. Use `WeAct_GetLastError()` for detailed error information
4. For images, use `WeAct_LoadImageFast()` if scaling is not required
5. Remember BRG565 format when working with custom colors

---

**Version:** 5.0 - Professional Edition  
**Date:** January 2026  
**Compatibility:** PureBasic 6.21+, WeAct Display FS 0.96-inch (160x80)  
**Protocol:** v1.1  
**Color Format:** BRG565 (not RGB565)  
**GitHub:** https://github.com/CheshirCa/WeActDisplay
