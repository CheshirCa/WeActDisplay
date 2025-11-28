# WeAct Display FS Library for PureBasic

![WeAct 0.96" Display](https://raw.githubusercontent.com/CheshirCa/WeActDisplay/refs/heads/main/USB_Display.jpg)

Полная библиотека для работы с дисплеем WeAct Display FS 0.96-inch (160x80) через последовательный порт.

Complete library for working with WeAct Display FS 0.96-inch (160x80) via serial port.

## 📋 Содержание / Table of Contents
- [Особенности / Features](#особенности--features)
- [Установка / Installation](#установка--installation)
- [Инициализация / Initialization](#инициализация--initialization)
- [Базовые функции / Basic Functions](#базовые-функции--basic-functions)
- [Работа с текстом / Text Operations](#работа-с-текстом--text-operations)
- [Графические функции / Graphics Functions](#графические-функции--graphics-functions)
- [Скроллинг текста / Text Scrolling](#скроллинг-текста--text-scrolling)
- [Работа с изображениями / Image Operations](#работа-с-изображениями--image-operations)
- [Управление дисплеем / Display Control](#управление-дисплеем--display-control)
- [Вспомогательные функции / Utility Functions](#вспомогательные-функции--utility-functions)
- [Примеры / Examples](#примеры--examples)

## 🌟 Особенности / Features

- ✅ Поддержка дисплея WeAct Display FS 0.96-inch (160x80)
- ✅ Правильная работа с цветами BRG565
- ✅ Читаемый текст с поддержкой сглаживания
- ✅ Двойная буферизация для плавной анимации
- ✅ Поддержка различных ориентаций экрана
- ✅ Загрузка изображений (BMP, JPEG, PNG, TIFF, TGA)
- ✅ Плавный скроллинг текста
- ✅ Управление яркостью
- ✅ Кэширование шрифтов для производительности

- ✅ Support for WeAct Display FS 0.96-inch (160x80)
- ✅ Correct BRG565 color handling
- ✅ Readable text with anti-aliasing support
- ✅ Double buffering for smooth animation
- ✅ Multiple screen orientation support
- ✅ Image loading (BMP, JPEG, PNG, TIFF, TGA)
- ✅ Smooth text scrolling
- ✅ Brightness control
- ✅ Font caching for performance

## 🔧 Установка / Installation

**Русский:**
1. Скопируйте файл `WeActDisplay.pbi` в ваш проект
2. Подключите библиотеку с помощью `XIncludeFile "WeActDisplay.pbi"`
3. Подключите дисплей к COM-порту (по умолчанию COM3)

**English:**
1. Copy `WeActDisplay.pbi` to your project
2. Include the library with `XIncludeFile "WeActDisplay.pbi"`
3. Connect the display to COM port (default COM3)

## 🚀 Инициализация / Initialization

### WeAct_Init()
**Русский:** Инициализирует дисплей и подготавливает библиотеку к работе.
```purebasic
; Подключение к COM3 (по умолчанию)
If WeAct_Init()
  Debug "Дисплей инициализирован"
Else
  Debug "Ошибка инициализации"
EndIf

; Подключение к определенному порту
If WeAct_Init("COM5")
  Debug "Успешное подключение к COM5"
EndIf
```

**English:** Initializes the display and prepares the library for operation.
```purebasic
; Connect to COM3 (default)
If WeAct_Init()
  Debug "Display initialized"
Else
  Debug "Initialization error"
EndIf

; Connect to specific port
If WeAct_Init("COM5")
  Debug "Successfully connected to COM5"
EndIf
```

### WeAct_Close()
**Русский:** Закрывает соединение с дисплеем и освобождает ресурсы.
```purebasic
WeAct_Close()
```

**English:** Closes the display connection and releases resources.
```purebasic
WeAct_Close()
```

### WeAct_Cleanup()
**Русский:** Полная очистка всех ресурсов библиотеки.
```purebasic
WeAct_Cleanup()
```

**English:** Complete cleanup of all library resources.
```purebasic
WeAct_Cleanup()
```

## 🎨 Базовые функции / Basic Functions

### WeAct_ClearBuffer()
**Русский:** Очищает буфер указанным цветом.
```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)    ; Очистить черным
WeAct_ClearBuffer(#WEACT_WHITE)    ; Очистить белым
WeAct_ClearBuffer(#WEACT_RED)      ; Очистить красным
```

**English:** Clears the buffer with specified color.
```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)    ; Clear with black
WeAct_ClearBuffer(#WEACT_WHITE)    ; Clear with white
WeAct_ClearBuffer(#WEACT_RED)      ; Clear with red
```

### WeAct_UpdateDisplay()
**Русский:** Обновляет дисплей, отображая содержимое буфера.
```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)
WeAct_DrawTextMedium(10, 10, "Hello World", #WEACT_WHITE)
WeAct_UpdateDisplay()  ; Отображаем на дисплее
```

**English:** Updates the display with buffer contents.
```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)
WeAct_DrawTextMedium(10, 10, "Hello World", #WEACT_WHITE)
WeAct_UpdateDisplay()  ; Display on screen
```

### RGBToRGB565()
**Русский:** Преобразует RGB цвет в формат BRG565.
```purebasic
color = RGBToRGB565(255, 0, 0)     ; Красный
color = RGBToRGB565(0, 255, 0)     ; Зеленый
color = RGBToRGB565(0, 0, 255)     ; Синий
```

**English:** Converts RGB color to BRG565 format.
```purebasic
color = RGBToRGB565(255, 0, 0)     ; Red
color = RGBToRGB565(0, 255, 0)     ; Green
color = RGBToRGB565(0, 0, 255)     ; Blue
```

## 📝 Работа с текстом / Text Operations

### WeAct_DrawTextSmall(), WeAct_DrawTextMedium(), WeAct_DrawTextLarge()
**Русский:** Рисует текст разных размеров.
```purebasic
WeAct_DrawTextSmall(10, 5, "Small text", #WEACT_WHITE)
WeAct_DrawTextMedium(10, 20, "Medium text", #WEACT_GREEN)
WeAct_DrawTextLarge(10, 40, "Large text", #WEACT_BLUE)
```

**English:** Draws text in different sizes.
```purebasic
WeAct_DrawTextSmall(10, 5, "Small text", #WEACT_WHITE)
WeAct_DrawTextMedium(10, 20, "Medium text", #WEACT_GREEN)
WeAct_DrawTextLarge(10, 40, "Large text", #WEACT_BLUE)
```

### WeAct_DrawTextSystemFont()
**Русский:** Рисует текст с указанным размером и шрифтом.
```purebasic
WeAct_DrawTextSystemFont(10, 10, "Custom font", #WEACT_RED, 14, "Arial")
WeAct_DrawTextSystemFont(10, 30, "Another font", #WEACT_YELLOW, 10, "Tahoma")
```

**English:** Draws text with specified size and font.
```purebasic
WeAct_DrawTextSystemFont(10, 10, "Custom font", #WEACT_RED, 14, "Arial")
WeAct_DrawTextSystemFont(10, 30, "Another font", #WEACT_YELLOW, 10, "Tahoma")
```

### WeAct_DrawWrappedTextFixed()
**Русский:** Рисует текст с переносом по словам.
```purebasic
text = "This is a very long text that will be automatically wrapped to fit the specified width"
WeAct_DrawWrappedTextFixed(5, 5, 150, 40, text, #WEACT_WHITE, 10)
```

**English:** Draws text with word wrapping.
```purebasic
text = "This is a very long text that will be automatically wrapped to fit the specified width"
WeAct_DrawWrappedTextFixed(5, 5, 150, 40, text, #WEACT_WHITE, 10)
```

### WeAct_DrawWrappedTextAutoSize()
**Русский:** Рисует текст с автоматическим подбором размера шрифта.
```purebasic
text = "Long text that will auto-size to fit"
WeAct_DrawWrappedTextAutoSize(5, 5, 150, 40, text, #WEACT_WHITE)
```

**English:** Draws text with automatic font size adjustment.
```purebasic
text = "Long text that will auto-size to fit"
WeAct_DrawWrappedTextAutoSize(5, 5, 150, 40, text, #WEACT_WHITE)
```

### WeAct_GetTextWidth(), WeAct_GetTextHeight()
**Русский:** Возвращает ширину и высоту текста.
```purebasic
width = WeAct_GetTextWidth("Hello", 12, "Arial")
height = WeAct_GetTextHeight("Hello", 12, "Arial")
Debug "Text size: " + Str(width) + "x" + Str(height)
```

**English:** Returns text width and height.
```purebasic
width = WeAct_GetTextWidth("Hello", 12, "Arial")
height = WeAct_GetTextHeight("Hello", 12, "Arial")
Debug "Text size: " + Str(width) + "x" + Str(height)
```

## 🎨 Графические функции / Graphics Functions

### WeAct_DrawPixelBuffer()
**Русский:** Рисует пиксель в указанных координатах.
```purebasic
WeAct_DrawPixelBuffer(50, 40, #WEACT_RED)     ; Красный пиксель
WeAct_DrawPixelBuffer(51, 40, #WEACT_GREEN)   ; Зеленый пиксель
WeAct_DrawPixelBuffer(52, 40, #WEACT_BLUE)    ; Синий пиксель
```

**English:** Draws a pixel at specified coordinates.
```purebasic
WeAct_DrawPixelBuffer(50, 40, #WEACT_RED)     ; Red pixel
WeAct_DrawPixelBuffer(51, 40, #WEACT_GREEN)   ; Green pixel
WeAct_DrawPixelBuffer(52, 40, #WEACT_BLUE)    ; Blue pixel
```

### WeAct_DrawLineBuffer()
**Русский:** Рисует линию между двумя точками.
```purebasic
WeAct_DrawLineBuffer(10, 10, 150, 70, #WEACT_WHITE)   ; Белая линия
WeAct_DrawLineBuffer(150, 10, 10, 70, #WEACT_YELLOW)  ; Желтая линия
```

**English:** Draws a line between two points.
```purebasic
WeAct_DrawLineBuffer(10, 10, 150, 70, #WEACT_WHITE)   ; White line
WeAct_DrawLineBuffer(150, 10, 10, 70, #WEACT_YELLOW)  ; Yellow line
```

### WeAct_DrawRectangleBuffer()
**Русский:** Рисует прямоугольник (заполненный или контур).
```purebasic
; Заполненный прямоугольник
WeAct_DrawRectangleBuffer(10, 10, 50, 30, #WEACT_RED, #True)

; Контур прямоугольника
WeAct_DrawRectangleBuffer(70, 10, 50, 30, #WEACT_GREEN, #False)
```

**English:** Draws a rectangle (filled or outline).
```purebasic
; Filled rectangle
WeAct_DrawRectangleBuffer(10, 10, 50, 30, #WEACT_RED, #True)

; Outline rectangle
WeAct_DrawRectangleBuffer(70, 10, 50, 30, #WEACT_GREEN, #False)
```

## 🔄 Скроллинг текста / Text Scrolling

### WeAct_StartScrollText()
**Русский:** Запускает скроллинг текста.
```purebasic
WeAct_StartScrollText("Scrolling text demo", 12, #SCROLL_LEFT, 15, #WEACT_WHITE)
```

**English:** Starts text scrolling.
```purebasic
WeAct_StartScrollText("Scrolling text demo", 12, #SCROLL_LEFT, 15, #WEACT_WHITE)
```

### WeAct_ScrollTextLeft(), WeAct_ScrollTextRight(), WeAct_ScrollTextUp(), WeAct_ScrollTextDown()
**Русский:** Быстрый запуск скроллинга в разных направлениях.
```purebasic
WeAct_ScrollTextLeft("Left scroll", 20)
WeAct_ScrollTextRight("Right scroll", 15)
WeAct_ScrollTextUp("Up scroll", 10)
WeAct_ScrollTextDown("Down scroll", 10)
```

**English:** Quick start for scrolling in different directions.
```purebasic
WeAct_ScrollTextLeft("Left scroll", 20)
WeAct_ScrollTextRight("Right scroll", 15)
WeAct_ScrollTextUp("Up scroll", 10)
WeAct_ScrollTextDown("Down scroll", 10)
```

### WeAct_UpdateScrollText(), WeAct_DrawScrollText()
**Русский:** Обновление и отрисовка скроллируемого текста (для использования в циклах).
```purebasic
WeAct_StartScrollText("Animation demo", 12, #SCROLL_LEFT, 30, #WEACT_CYAN)

For i = 1 To 100
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateScrollText()
  WeAct_DrawScrollText()
  WeAct_UpdateDisplay()
  Delay(50)
Next

WeAct_StopScrollText()
```

**English:** Update and draw scrolling text (for use in loops).
```purebasic
WeAct_StartScrollText("Animation demo", 12, #SCROLL_LEFT, 30, #WEACT_CYAN)

For i = 1 To 100
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateScrollText()
  WeAct_DrawScrollText()
  WeAct_UpdateDisplay()
  Delay(50)
Next

WeAct_StopScrollText()
```

### WeAct_StopScrollText()
**Русский:** Останавливает скроллинг текста.
```purebasic
WeAct_StopScrollText()
```

**English:** Stops text scrolling.
```purebasic
WeAct_StopScrollText()
```

## 🖼️ Работа с изображениями / Image Operations

### WeAct_LoadImageToBuffer()
**Русский:** Загружает и отображает изображение с указанными координатами и размером.
```purebasic
; Загрузить с оригинальным размером
WeAct_LoadImageToBuffer(10, 10, "image.bmp")

; Загрузить с указанным размером
WeAct_LoadImageToBuffer(20, 20, "image.jpg", 80, 40)
```

**English:** Loads and displays image with specified coordinates and size.
```purebasic
; Load with original size
WeAct_LoadImageToBuffer(10, 10, "image.bmp")

; Load with specified size
WeAct_LoadImageToBuffer(20, 20, "image.jpg", 80, 40)
```

### WeAct_LoadImageFullScreen()
**Русский:** Загружает изображение на весь экран с сохранением пропорций.
```purebasic
WeAct_LoadImageFullScreen("background.jpg")
```

**English:** Loads image to full screen with aspect ratio preserved.
```purebasic
WeAct_LoadImageFullScreen("background.jpg")
```

### WeAct_LoadImageCentered()
**Русский:** Загружает изображение по центру экрана.
```purebasic
; Центрировать с оригинальным размером
WeAct_LoadImageCentered("logo.png")

; Центрировать с указанным размером
WeAct_LoadImageCentered("logo.png", 100, 50)
```

**English:** Loads image centered on screen.
```purebasic
; Center with original size
WeAct_LoadImageCentered("logo.png")

; Center with specified size
WeAct_LoadImageCentered("logo.png", 100, 50)
```

### WeAct_GetSupportedImageFormats()
**Русский:** Возвращает список поддерживаемых форматов изображений.
```purebasic
formats$ = WeAct_GetSupportedImageFormats()
Debug "Поддерживаемые форматы: " + formats$
```

**English:** Returns list of supported image formats.
```purebasic
formats$ = WeAct_GetSupportedImageFormats()
Debug "Supported formats: " + formats$
```

## ⚙️ Управление дисплеем / Display Control

### WeAct_SetOrientation()
**Русский:** Устанавливает ориентацию дисплея.
```purebasic
WeAct_SetOrientation(#WEACT_LANDSCAPE)           ; Альбомная (160x80)
WeAct_SetOrientation(#WEACT_PORTRAIT)           ; Портретная (80x160)
WeAct_SetOrientation(#WEACT_REVERSE_LANDSCAPE)  ; Реверс альбомная
WeAct_SetOrientation(#WEACT_REVERSE_PORTRAIT)   ; Реверс портретная
```

**English:** Sets display orientation.
```purebasic
WeAct_SetOrientation(#WEACT_LANDSCAPE)           ; Landscape (160x80)
WeAct_SetOrientation(#WEACT_PORTRAIT)           ; Portrait (80x160)
WeAct_SetOrientation(#WEACT_REVERSE_LANDSCAPE)  ; Reverse landscape
WeAct_SetOrientation(#WEACT_REVERSE_PORTRAIT)   ; Reverse portrait
```

### WeAct_SetBrightness()
**Русский:** Устанавливает яркость дисплея.
```purebasic
WeAct_SetBrightness(255)      ; Максимальная яркость
WeAct_SetBrightness(128)      ; Средняя яркость
WeAct_SetBrightness(0)        ; Минимальная яркость
WeAct_SetBrightness(200, 1000) ; Плавное изменение за 1 секунду
```

**English:** Sets display brightness.
```purebasic
WeAct_SetBrightness(255)      ; Maximum brightness
WeAct_SetBrightness(128)      ; Medium brightness
WeAct_SetBrightness(0)        ; Minimum brightness
WeAct_SetBrightness(200, 1000) ; Smooth transition over 1 second
```

### WeAct_SystemReset()
**Русский:** Выполняет сброс дисплея.
```purebasic
WeAct_SystemReset()
```

**English:** Performs display reset.
```purebasic
WeAct_SystemReset()
```

## 🔧 Вспомогательные функции / Utility Functions

### WeAct_IsConnected()
**Русский:** Проверяет подключен ли дисплей.
```purebasic
If WeAct_IsConnected()
  Debug "Дисплей подключен"
Else
  Debug "Дисплей не подключен"
EndIf
```

**English:** Checks if display is connected.
```purebasic
If WeAct_IsConnected()
  Debug "Display connected"
Else
  Debug "Display not connected"
EndIf
```

### WeAct_GetInfo()
**Русский:** Возвращает информацию о подключенном дисплее.
```purebasic
info$ = WeAct_GetInfo()
Debug info$
```

**English:** Returns information about connected display.
```purebasic
info$ = WeAct_GetInfo()
Debug info$
```

### WeAct_GetDisplayWidth(), WeAct_GetDisplayHeight()
**Русский:** Возвращает текущие размеры дисплея.
```purebasic
width = WeAct_GetDisplayWidth()
height = WeAct_GetDisplayHeight()
Debug "Display size: " + Str(width) + "x" + Str(height)
```

**English:** Returns current display dimensions.
```purebasic
width = WeAct_GetDisplayWidth()
height = WeAct_GetDisplayHeight()
Debug "Display size: " + Str(width) + "x" + Str(height)
```

### WeAct_GetOrientation(), WeAct_GetBrightness()
**Русский:** Возвращает текущую ориентацию и яркость.
```purebasic
orientation = WeAct_GetOrientation()
brightness = WeAct_GetBrightness()
Debug "Orientation: " + Str(orientation) + ", Brightness: " + Str(brightness)
```

**English:** Returns current orientation and brightness.
```purebasic
orientation = WeAct_GetOrientation()
brightness = WeAct_GetBrightness()
Debug "Orientation: " + Str(orientation) + ", Brightness: " + Str(brightness)
```

## 🎯 Примеры / Examples

### Простой пример / Simple Example
```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM3")
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 10, "Hello World!", #WEACT_WHITE)
  WeAct_DrawTextSmall(10, 30, "WeAct Display FS", #WEACT_GREEN)
  WeAct_DrawRectangleBuffer(10, 50, 140, 20, #WEACT_BLUE, #True)
  WeAct_UpdateDisplay()
  
  Delay(3000)
  WeAct_Cleanup()
EndIf
```

### Анимация скроллинга / Scrolling Animation
```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM3")
  WeAct_StartScrollText("Welcome to WeAct Display FS Library!", 14, #SCROLL_LEFT, 20, #WEACT_CYAN)
  
  For i = 1 To 200
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateScrollText()
    WeAct_DrawScrollText()
    WeAct_UpdateDisplay()
    Delay(50)
  Next
  
  WeAct_StopScrollText()
  WeAct_Cleanup()
EndIf
```

### Графический демо / Graphics Demo
```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM3")
  ; Рисуем сетку
  For x = 0 To 159 Step 20
    WeAct_DrawLineBuffer(x, 0, x, 79, #WEACT_WHITE)
  Next
  For y = 0 To 79 Step 10
    WeAct_DrawLineBuffer(0, y, 159, y, #WEACT_WHITE)
  Next
  
  ; Рисуем цветные прямоугольники
  WeAct_DrawRectangleBuffer(10, 10, 30, 20, #WEACT_RED, #True)
  WeAct_DrawRectangleBuffer(50, 10, 30, 20, #WEACT_GREEN, #False)
  WeAct_DrawRectangleBuffer(90, 10, 30, 20, #WEACT_BLUE, #True)
  WeAct_DrawRectangleBuffer(130, 10, 20, 20, #WEACT_YELLOW, #True)
  
  ; Рисуем диагональные линии
  WeAct_DrawLineBuffer(10, 40, 150, 70, #WEACT_CYAN)
  WeAct_DrawLineBuffer(150, 40, 10, 70, #WEACT_MAGENTA)
  
  WeAct_UpdateDisplay()
  Delay(5000)
  WeAct_Cleanup()
EndIf
```

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

