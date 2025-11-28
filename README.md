# WeAct Display FS Library for PureBasic

[English version below](#english-version)

## Русская версия

### Описание

Библиотека для работы с дисплеем WeAct Display FS 0.96-дюйма через последовательный порт. Поддерживает графику, текст, изображения, скроллинг и управление дисплеем.

### Основные возможности

- 📺 Графические примитивы (пиксели, линии, прямоугольники)
- 📝 Рендеринг текста с поддержкой шрифтов
- 🖼️ Загрузка изображений (BMP, JPEG, PNG, TIFF, TGA)
- 🔄 Скроллинг текста в 4 направлениях
- 🎛️ Управление ориентацией и яркостью
- 💾 Двойная буферизация для плавной анимации

### Установка

1. Подключите дисплей к COM-порту
2. Включите библиотеку в ваш проект:
```purebasic
XIncludeFile "WeActDisplay.pbi"
```

### Инициализация

```purebasic
; Инициализация дисплея
If WeAct_Init("COM8")
  Debug "Дисплей подключен"
Else
  Debug "Ошибка подключения"
EndIf

; Обязательная очистка при завершении
WeAct_Cleanup()
```

### Основные функции

#### Графические примитивы

```purebasic
; Очистка буфера
WeAct_ClearBuffer(#WEACT_BLACK)

; Рисование пикселя
WeAct_DrawPixelBuffer(10, 10, #WEACT_RED)

; Рисование линии
WeAct_DrawLineBuffer(0, 0, 50, 50, #WEACT_GREEN)

; Рисование прямоугольника
WeAct_DrawRectangleBuffer(20, 20, 40, 30, #WEACT_BLUE, #True)  ; Залитый
WeAct_DrawRectangleBuffer(70, 20, 40, 30, #WEACT_WHITE, #False) ; Контур

; Обновление дисплея
WeAct_UpdateDisplay()
```

#### Работа с текстом

```purebasic
; Простой текст
WeAct_DrawTextSmall(10, 10, "Маленький текст", #WEACT_WHITE)
WeAct_DrawTextMedium(10, 25, "Средний текст", #WEACT_CYAN)
WeAct_DrawTextLarge(10, 45, "Большой текст", #WEACT_YELLOW)

; Текст с произвольным шрифтом
WeAct_DrawTextSystemFont(10, 65, "Произвольный шрифт", #WEACT_GREEN, 14, "Arial")

; Перенос текста
WeAct_DrawWrappedTextAutoSize(10, 10, 140, 60, 
  "Это длинный текст, который автоматически переносится на несколько строк", 
  #WEACT_WHITE, "Arial")
```

#### Скроллинг текста

```purebasic
; Запуск скроллинга
WeAct_ScrollTextLeft("Текст скроллится влево", 20, 12, #WEACT_GREEN)

; В основном цикле
Repeat
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateScrollText()
  WeAct_DrawScrollText()
  WeAct_UpdateDisplay()
  Delay(30)
ForEver

; Остановка скроллинга
WeAct_StopScrollText()
```

#### Загрузка изображений

```purebasic
; Загрузка с автоматическим масштабированием
WeAct_LoadImageCentered("image.jpg", 100, 50)

; Загрузка на полный экран
WeAct_LoadImageFullScreen("background.jpg")

; Загрузка в указанную позицию
WeAct_LoadImageToBuffer(10, 10, "icon.png", 32, 32)
```

#### Управление дисплеем

```purebasic
; Смена ориентации
WeAct_SetOrientation(#WEACT_PORTRAIT)      ; Портретная
WeAct_SetOrientation(#WEACT_LANDSCAPE)     ; Альбомная

; Управление яркостью
WeAct_SetBrightness(150, 500)  ; Яркость 150, время изменения 500мс

; Системный сброс
WeAct_SystemReset()

; Получение информации
Debug WeAct_GetInfo()
Debug "Ширина: " + Str(WeAct_GetDisplayWidth())
Debug "Высота: " + Str(WeAct_GetDisplayHeight())
Debug "Яркость: " + Str(WeAct_GetBrightness())
```

#### Цвета RGB565

```purebasic
; Предопределенные цвета
#WEACT_RED    = $F800
#WEACT_GREEN  = $07E0  
#WEACT_BLUE   = $001F
#WEACT_WHITE  = $FFFF
#WEACT_BLACK  = $0000
#WEACT_YELLOW = $FFE0
#WEACT_CYAN   = $07FF
#WEACT_MAGENTA = $F81F

; Создание цвета из RGB
color = RGBToRGB565(255, 128, 0)  ; Оранжевый
```

### Полный пример

```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM8")
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Графика
  WeAct_DrawRectangleBuffer(10, 10, 140, 60, #WEACT_BLUE, #False)
  WeAct_DrawLineBuffer(10, 10, 150, 70, #WEACT_RED)
  
  ; Текст
  WeAct_DrawTextMedium(20, 25, "Hello World!", #WEACT_WHITE)
  WeAct_DrawTextSmall(20, 45, "WeAct Display", #WEACT_GREEN)
  
  WeAct_UpdateDisplay()
  
  Delay(3000)
  WeAct_Cleanup()
EndIf
```

---

<a name="english-version"></a>
## English Version

### Description

Library for working with WeAct Display FS 0.96-inch display via serial port. Supports graphics, text, images, scrolling and display control.

### Key Features

- 📺 Graphics primitives (pixels, lines, rectangles)
- 📝 Text rendering with font support
- 🖼️ Image loading (BMP, JPEG, PNG, TIFF, TGA)
- 🔄 Text scrolling in 4 directions
- 🎛️ Orientation and brightness control
- 💾 Double buffering for smooth animation

### Installation

1. Connect display to COM port
2. Include library in your project:
```purebasic
XIncludeFile "WeActDisplay.pbi"
```

### Initialization

```purebasic
; Display initialization
If WeAct_Init("COM8")
  Debug "Display connected"
Else
  Debug "Connection error"
EndIf

; Mandatory cleanup on exit
WeAct_Cleanup()
```

### Core Functions

#### Graphics Primitives

```purebasic
; Clear buffer
WeAct_ClearBuffer(#WEACT_BLACK)

; Draw pixel
WeAct_DrawPixelBuffer(10, 10, #WEACT_RED)

; Draw line
WeAct_DrawLineBuffer(0, 0, 50, 50, #WEACT_GREEN)

; Draw rectangle
WeAct_DrawRectangleBuffer(20, 20, 40, 30, #WEACT_BLUE, #True)  ; Filled
WeAct_DrawRectangleBuffer(70, 20, 40, 30, #WEACT_WHITE, #False) ; Outline

; Update display
WeAct_UpdateDisplay()
```

#### Text Rendering

```purebasic
; Simple text
WeAct_DrawTextSmall(10, 10, "Small text", #WEACT_WHITE)
WeAct_DrawTextMedium(10, 25, "Medium text", #WEACT_CYAN)
WeAct_DrawTextLarge(10, 45, "Large text", #WEACT_YELLOW)

; Text with custom font
WeAct_DrawTextSystemFont(10, 65, "Custom font", #WEACT_GREEN, 14, "Arial")

; Text wrapping
WeAct_DrawWrappedTextAutoSize(10, 10, 140, 60, 
  "This is a long text that automatically wraps to multiple lines", 
  #WEACT_WHITE, "Arial")
```

#### Text Scrolling

```purebasic
; Start scrolling
WeAct_ScrollTextLeft("Text scrolling left", 20, 12, #WEACT_GREEN)

; In main loop
Repeat
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateScrollText()
  WeAct_DrawScrollText()
  WeAct_UpdateDisplay()
  Delay(30)
ForEver

; Stop scrolling
WeAct_StopScrollText()
```

#### Image Loading

```purebasic
; Load with auto-scaling
WeAct_LoadImageCentered("image.jpg", 100, 50)

; Load full screen
WeAct_LoadImageFullScreen("background.jpg")

; Load to specific position
WeAct_LoadImageToBuffer(10, 10, "icon.png", 32, 32)
```

#### Display Control

```purebasic
; Change orientation
WeAct_SetOrientation(#WEACT_PORTRAIT)      ; Portrait
WeAct_SetOrientation(#WEACT_LANDSCAPE)     ; Landscape

; Brightness control
WeAct_SetBrightness(150, 500)  ; Brightness 150, transition time 500ms

; System reset
WeAct_SystemReset()

; Get information
Debug WeAct_GetInfo()
Debug "Width: " + Str(WeAct_GetDisplayWidth())
Debug "Height: " + Str(WeAct_GetDisplayHeight())
Debug "Brightness: " + Str(WeAct_GetBrightness())
```

#### RGB565 Colors

```purebasic
; Predefined colors
#WEACT_RED    = $F800
#WEACT_GREEN  = $07E0  
#WEACT_BLUE   = $001F
#WEACT_WHITE  = $FFFF
#WEACT_BLACK  = $0000
#WEACT_YELLOW = $FFE0
#WEACT_CYAN   = $07FF
#WEACT_MAGENTA = $F81F

; Create color from RGB
color = RGBToRGB565(255, 128, 0)  ; Orange
```

### Complete Example

```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM8")
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Graphics
  WeAct_DrawRectangleBuffer(10, 10, 140, 60, #WEACT_BLUE, #False)
  WeAct_DrawLineBuffer(10, 10, 150, 70, #WEACT_RED)
  
  ; Text
  WeAct_DrawTextMedium(20, 25, "Hello World!", #WEACT_WHITE)
  WeAct_DrawTextSmall(20, 45, "WeAct Display", #WEACT_GREEN)
  
  WeAct_UpdateDisplay()
  
  Delay(3000)
  WeAct_Cleanup()
EndIf
```

