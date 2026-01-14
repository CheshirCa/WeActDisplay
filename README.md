# WeAct Display FS Library for PureBasic v5.0

![WeAct 0.96" Display](https://raw.githubusercontent.com/CheshirCa/WeActDisplay/refs/heads/main/USB_Display.jpg)

Библиотека для работы с дисплеем WeAct Display FS 0.96-inch (160x80) через последовательный порт.  
Library for working with WeAct Display FS 0.96-inch (160x80) via serial port.

**GitHub:** https://github.com/CheshirCa/WeActDisplay

## ⚠️ Важное замечание / Important Note

**Русский:**  
Дисплей WeAct FS использует формат **RGB565** (Red-Green-Blue). Все функции библиотеки работают с этим форматом. Предопределенные цвета (`#WEACT_RED`, `#WEACT_GREEN`, и т.д.) заданы в правильном формате.

**English:**  
WeAct FS display uses **RGB565** format (Red-Green-Blue). All library functions work with this format. Predefined colors (`#WEACT_RED`, `#WEACT_GREEN`, etc.) are set in the correct format.

## 📋 Полный список функций / Complete Function List

### 🔧 Инициализация и завершение / Initialization and Cleanup

#### WeAct_Init(PortName.s = "COM3")
**Русский:** Инициализирует дисплей на указанном COM-порту. Автоматически устанавливает ландшафтную ориентацию и максимальную яркость.

**English:** Initializes the display on the specified COM port. Automatically sets landscape orientation and maximum brightness.

```purebasic
; Пример использования / Usage example
If WeAct_Init("COM3")
  Debug "Дисплей инициализирован / Display initialized"
Else
  Debug "Ошибка: " + WeAct_GetLastError()
EndIf
```

#### WeAct_Close()
**Русский:** Закрывает соединение с дисплеем и освобождает ресурсы.

**English:** Closes the connection to the display and releases resources.

```purebasic
WeAct_Close()
```

#### WeAct_Cleanup()
**Русский:** Полная очистка всех ресурсов библиотеки, включая кэш шрифтов и буферы.

**English:** Complete cleanup of all library resources including font cache and buffers.

```purebasic
WeAct_Cleanup()
```

#### WeAct_InitImageDecoders()
**Русский:** Инициализирует декодеры изображений (JPEG, PNG, TIFF, TGA). Вызывается автоматически в WeAct_Init().

**English:** Initializes image decoders (JPEG, PNG, TIFF, TGA). Called automatically in WeAct_Init().

```purebasic
WeAct_InitImageDecoders()  ; Обычно не требуется вызывать вручную / Usually not needed to call manually
```

### 🎨 Работа с цветами / Color Operations

#### RGBToRGB565_Fixed(r, g, b)
**Русский:** Конвертирует RGB значения (0-255) в формат RGB565 с правильным распределением битов.

**English:** Converts RGB values (0-255) to RGB565 format with correct bit distribution.

```purebasic
; Конвертация цвета / Color conversion
color = RGBToRGB565_Fixed(255, 0, 0)      ; Красный / Red
color = RGBToRGB565_Fixed(0, 255, 0)      ; Зеленый / Green
color = RGBToRGB565_Fixed(128, 64, 200)   ; Пользовательский цвет / Custom color
```

#### RGBToRGB565(r, g, b) (макрос / macro)
**Русский:** Макрос для обратной совместимости, вызывает RGBToRGB565_Fixed().

**English:** Macro for backward compatibility, calls RGBToRGB565_Fixed().

```purebasic
; То же самое что RGBToRGB565_Fixed() / Same as RGBToRGB565_Fixed()
color = RGBToRGB565(255, 128, 64)
```

### 📊 Буферизация / Buffering

#### WeAct_SwapBuffers()
**Русский:** Переключает фронтальный и задний буферы (двойная буферизация).

**English:** Swaps front and back buffers (double buffering).

```purebasic
WeAct_SwapBuffers()  ; Используется внутри WeAct_UpdateDisplay() / Used inside WeAct_UpdateDisplay()
```

#### WeAct_ClearBuffer(Color = #WEACT_BLACK)
**Русский:** Очищает задний буфер указанным цветом.

**English:** Clears the back buffer with the specified color.

```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)     ; Черный фон / Black background
WeAct_ClearBuffer(#WEACT_WHITE)     ; Белый фон / White background
WeAct_ClearBuffer(RGBToRGB565(128, 128, 128))  ; Серый фон / Gray background
```

#### WeAct_DrawPixelBuffer(x, y, Color)
**Русский:** Рисует пиксель в указанных координатах заднего буфера.

**English:** Draws a pixel at specified coordinates in the back buffer.

```purebasic
WeAct_DrawPixelBuffer(50, 40, #WEACT_RED)
WeAct_DrawPixelBuffer(60, 40, RGBToRGB565(255, 128, 0))
```

#### WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, Filled = #True)
**Русский:** Рисует прямоугольник или заполненный прямоугольник.

**English:** Draws a rectangle or filled rectangle.

```purebasic
; Заполненный прямоугольник / Filled rectangle
WeAct_DrawRectangleBuffer(10, 10, 50, 30, #WEACT_RED, #True)

; Контур прямоугольника / Rectangle outline
WeAct_DrawRectangleBuffer(70, 10, 50, 30, #WEACT_GREEN, #False)
```

#### WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
**Русский:** Рисует линию между двумя точками (алгоритм Брезенхэма).

**English:** Draws a line between two points (Bresenham's algorithm).

```purebasic
WeAct_DrawLineBuffer(10, 10, 150, 70, #WEACT_WHITE)
WeAct_DrawLineBuffer(150, 10, 10, 70, #WEACT_BLUE)
```

#### WeAct_DrawCircleBuffer(cx, cy, radius, Color, Filled = #False)
**Русский:** Рисует окружность или заполненную окружность.

**English:** Draws a circle or filled circle.

```purebasic
; Контур окружности / Circle outline
WeAct_DrawCircleBuffer(80, 40, 20, #WEACT_YELLOW, #False)

; Заполненная окружность / Filled circle
WeAct_DrawCircleBuffer(120, 40, 15, #WEACT_CYAN, #True)
```

### 🖥️ Вывод на дисплей / Display Output

#### WeAct_FlushBuffer()
**Русский:** Отправляет содержимое заднего буфера на физический дисплей.

**English:** Sends back buffer content to the physical display.

```purebasic
If WeAct_FlushBuffer()
  Debug "Буфер отправлен / Buffer sent"
EndIf
```

#### WeAct_UpdateDisplay()
**Русский:** Отправляет буфер на дисплей и переключает буферы. Основная функция для обновления экрана.

**English:** Sends buffer to display and swaps buffers. Main function for screen updates.

```purebasic
WeAct_ClearBuffer(#WEACT_BLACK)
WeAct_DrawTextMedium(10, 10, "Hello", #WEACT_WHITE)
WeAct_UpdateDisplay()  ; Показывает на экране / Shows on screen
```

### 📝 Работа с текстом / Text Operations

#### GetCachedFont(FontName.s, FontSize.i)
**Русский:** Возвращает шрифт из кэша или загружает его. Внутренняя функция для оптимизации.

**English:** Returns font from cache or loads it. Internal function for optimization.

```purebasic
; Обычно вызывается внутри других функций / Usually called inside other functions
fontID = GetCachedFont("Arial", 12)
```

#### WeAct_GetTextWidth(Text.s, FontSize.i, FontName.s = "Arial")
**Русский:** Возвращает ширину текста в пикселях для точного позиционирования.

**English:** Returns text width in pixels for precise positioning.

```purebasic
width = WeAct_GetTextWidth("Hello World", 12, "Arial")
Debug "Ширина текста: " + Str(width) + "px"
```

#### WeAct_GetTextHeight(Text.s, FontSize.i, FontName.s = "Arial")
**Русский:** Возвращает высоту текста в пикселях.

**English:** Returns text height in pixels.

```purebasic
height = WeAct_GetTextHeight("Hello", 12, "Arial")
Debug "Высота текста: " + Str(height) + "px"
```

#### WeAct_DrawTextSystemFont(x, y, Text.s, Color, FontSize.i = 12, FontName.s = "Arial")
**Русский:** Рисует текст с указанным шрифтом и размером. Поддерживает кириллицу.

**English:** Draws text with specified font and size. Supports Cyrillic.

```purebasic
WeAct_DrawTextSystemFont(10, 10, "Привет мир!", #WEACT_WHITE, 12, "Arial")
WeAct_DrawTextSystemFont(10, 30, "Hello World", #WEACT_GREEN, 14, "Tahoma")
```

#### WeAct_DrawTextSmall(x, y, Text.s, Color)
**Русский:** Рисует мелкий текст (8px Arial).

**English:** Draws small text (8px Arial).

```purebasic
WeAct_DrawTextSmall(10, 10, "Мелкий текст", #WEACT_WHITE)
```

#### WeAct_DrawTextMedium(x, y, Text.s, Color)
**Русский:** Рисует средний текст (12px Arial).

**English:** Draws medium text (12px Arial).

```purebasic
WeAct_DrawTextMedium(10, 30, "Средний текст", #WEACT_GREEN)
```

#### WeAct_DrawTextLarge(x, y, Text.s, Color)
**Русский:** Рисует крупный текст (16px Arial).

**English:** Draws large text (16px Arial).

```purebasic
WeAct_DrawTextLarge(10, 50, "Крупный текст", #WEACT_BLUE)
```

#### WeAct_DrawWrappedText(x, y, Width, Height, Text.s, Color, FontSize.i = 12, FontName.s = "Arial", AutoSize = #False)
**Русский:** Рисует текст с автоматическим переносом слов в указанной области.

**English:** Draws text with automatic word wrapping in specified area.

```purebasic
text$ = "Это длинный текст который будет автоматически перенесен на несколько строк в пределах указанной области."
WeAct_DrawWrappedText(10, 10, 140, 60, text$, #WEACT_WHITE, 10, "Arial", #False)
```

#### WeAct_DrawWrappedTextAutoSize(x, y, Width, Height, Text.s, Color, FontName.s = "Arial")
**Русский:** Рисует текст с авто-подбором размера шрифта чтобы поместиться в область.

**English:** Draws text with auto-adjusting font size to fit area.

```purebasic
text$ = "Автоматический подбор размера шрифта"
WeAct_DrawWrappedTextAutoSize(10, 10, 140, 60, text$, #WEACT_GREEN, "Arial")
```

#### WeAct_DrawWrappedTextFixed(x, y, Width, Height, Text.s, Color, FontSize.i = 12, FontName.s = "Arial")
**Русский:** Рисует текст с фиксированным размером шрифта и переносом.

**English:** Draws text with fixed font size and wrapping.

```purebasic
WeAct_DrawWrappedTextFixed(10, 10, 140, 60, "Текст с переносом", #WEACT_WHITE, 10, "Arial")
```

### 🔄 Скроллинг текста / Text Scrolling

#### WeAct_StartScrollText(Text.s, FontSize.i = 12, Direction.i = #SCROLL_LEFT, Speed.f = 20.0, Color.i = #WEACT_WHITE, FontName.s = "Arial")
**Русский:** Запускает плавный скроллинг текста с указанными параметрами.

**English:** Starts smooth text scrolling with specified parameters.

```purebasic
WeAct_StartScrollText("Бегущая строка", 12, #SCROLL_LEFT, 30.0, #WEACT_WHITE, "Arial")
WeAct_StartScrollText("Вертикальный скроллинг", 10, #SCROLL_UP, 15.5, #WEACT_CYAN, "Tahoma")
```

#### WeAct_StopScrollText()
**Русский:** Останавливает скроллинг текста.

**English:** Stops text scrolling.

```purebasic
WeAct_StopScrollText()
```

#### WeAct_UpdateScrollText()
**Русский:** Обновляет позицию скроллируемого текста на основе прошедшего времени.

**English:** Updates scrolling text position based on elapsed time.

```purebasic
; В игровом цикле / In game loop
WeAct_UpdateScrollText()
```

#### WeAct_DrawScrollText()
**Русский:** Рисует скроллируемый текст в текущей позиции.

**English:** Draws scrolling text at current position.

```purebasic
WeAct_DrawScrollText()
```

#### WeAct_ScrollTextLeft(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
**Русский:** Запускает скроллинг текста влево.

**English:** Starts left text scrolling.

```purebasic
WeAct_ScrollTextLeft("Скролл влево", 25.0, 12, #WEACT_WHITE)
```

#### WeAct_ScrollTextRight(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
**Русский:** Запускает скроллинг текста вправо.

**English:** Starts right text scrolling.

```purebasic
WeAct_ScrollTextRight("Скролл вправо", 25.0, 12, #WEACT_GREEN)
```

#### WeAct_ScrollTextUp(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
**Русский:** Запускает скроллинг текста вверх.

**English:** Starts up text scrolling.

```purebasic
WeAct_ScrollTextUp("Вертикальный скролл", 15.0, 10, #WEACT_CYAN)
```

#### WeAct_ScrollTextDown(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
**Русский:** Запускает скроллинг текста вниз.

**English:** Starts down text scrolling.

```purebasic
WeAct_ScrollTextDown("Скролл вниз", 15.0, 10, #WEACT_YELLOW)
```

### 🖼️ Работа с изображениями / Image Operations

#### WeAct_GetSupportedImageFormats()
**Русский:** Возвращает список поддерживаемых форматов изображений.

**English:** Returns list of supported image formats.

```purebasic
formats$ = WeAct_GetSupportedImageFormats()
Debug "Поддерживаемые форматы: " + formats$  ; "BMP, JPEG, PNG, TIFF, TGA"
```

#### WeAct_LoadImageToBuffer(x, y, FileName.s, Width.i = -1, Height.i = -1)
**Русский:** Загружает изображение с возможностью масштабирования.

**English:** Loads image with scaling capability.

```purebasic
; Оригинальный размер / Original size
WeAct_LoadImageToBuffer(10, 10, "image.bmp", -1, -1)

; Масштабирование / Scaling
WeAct_LoadImageToBuffer(20, 20, "image.jpg", 80, 40)

; Пропорциональное масштабирование / Proportional scaling
WeAct_LoadImageToBuffer(0, 0, "photo.png", 100, -1)  ; Авто-высота / Auto-height
```

#### WeAct_LoadImageFullScreen(FileName.s)
**Русский:** Загружает изображение на весь экран с сохранением пропорций.

**English:** Loads image to full screen with aspect ratio preserved.

```purebasic
WeAct_LoadImageFullScreen("background.jpg")
```

#### WeAct_LoadImageCentered(FileName.s, Width.i = -1, Height.i = -1)
**Русский:** Загружает изображение по центру экрана с возможным масштабированием.

**English:** Loads image centered on screen with optional scaling.

```purebasic
WeAct_LoadImageCentered("logo.png")                    ; Оригинальный размер / Original size
WeAct_LoadImageCentered("icon.jpg", 64, 64)           ; 64x64 по центру / 64x64 centered
WeAct_LoadImageCentered("banner.bmp", 120, -1)        ; Ширина 120px, авто-высота / Width 120px, auto-height
```

#### WeAct_LoadImageFast(x, y, FileName.s)
**Русский:** Быстрая загрузка изображения без масштабирования (только копирование пикселей).

**English:** Fast image loading without scaling (pixel copy only).

```purebasic
WeAct_LoadImageFast(10, 10, "sprite.bmp")  ; Изображение должно быть правильного размера / Image must be correct size
```

### ⚙️ Управление дисплеем / Display Control

#### WeAct_SetOrientation(Orientation)
**Русский:** Устанавливает ориентацию дисплея. Поддерживает режим автоповорота.

**English:** Sets display orientation. Supports auto-rotation mode.

```purebasic
WeAct_SetOrientation(#WEACT_LANDSCAPE)           ; 160x80
WeAct_SetOrientation(#WEACT_PORTRAIT)            ; 80x160
WeAct_SetOrientation(#WEACT_REVERSE_LANDSCAPE)   ; Перевернутый ландшафт / Reverse landscape
WeAct_SetOrientation(#WEACT_REVERSE_PORTRAIT)    ; Перевернутый портрет / Reverse portrait
WeAct_SetOrientation(#WEACT_ROTATE)              ; Автоповорот / Auto-rotation
```

#### WeAct_SetBrightness(Brightness, TimeMs = 500)
**Русский:** Устанавливает яркость дисплея с плавным переходом.

**English:** Sets display brightness with smooth transition.

```purebasic
WeAct_SetBrightness(255)       ; Максимальная яркость / Maximum brightness
WeAct_SetBrightness(128)       ; Половина яркости / Half brightness
WeAct_SetBrightness(0, 1000)   ; Плавное выключение / Smooth fade to off
WeAct_SetBrightness(255, 2000) ; Плавное включение / Smooth fade to max
```

#### WeAct_SystemReset()
**Русский:** Отправляет команду сброса на дисплей.

**English:** Sends reset command to display.

```purebasic
WeAct_SystemReset()  ; Перезагружает дисплей / Reboots the display
```

#### WeAct_FillScreen(Color)
**Русский:** Быстро заливает весь экран цветом через аппаратную команду.

**English:** Quickly fills entire screen with color via hardware command.

```purebasic
WeAct_FillScreen(#WEACT_RED)      ; Красный экран / Red screen
WeAct_FillScreen(#WEACT_BLACK)    ; Черный экран / Black screen
```

### 🔧 Вспомогательные функции / Utility Functions

#### WeAct_GetInfo()
**Русский:** Возвращает информацию о дисплее и подключении.

**English:** Returns display and connection information.

```purebasic
info$ = WeAct_GetInfo()
Debug info$  ; "WeAct Display FS 0.96-inch (COM3) 160x80"
```

#### WeAct_GetOrientation()
**Русский:** Возвращает текущую ориентацию дисплея.

**English:** Returns current display orientation.

```purebasic
orientation = WeAct_GetOrientation()
Select orientation
  Case #WEACT_LANDSCAPE
    Debug "Ландшафтная ориентация / Landscape orientation"
  Case #WEACT_PORTRAIT
    Debug "Портретная ориентация / Portrait orientation"
EndSelect
```

#### WeAct_GetBrightness()
**Русский:** Возвращает текущую яркость дисплея (0-255).

**English:** Returns current display brightness (0-255).

```purebasic
brightness = WeAct_GetBrightness()
Debug "Текущая яркость: " + Str(brightness) + " / 255"
```

#### WeAct_IsConnected()
**Русский:** Проверяет, подключен ли дисплей.

**English:** Checks if display is connected.

```purebasic
If WeAct_IsConnected()
  Debug "Дисплей подключен / Display connected"
Else
  Debug "Дисплей отключен / Display disconnected"
EndIf
```

#### WeAct_GetDisplayWidth()
**Русский:** Возвращает текущую ширину дисплея (зависит от ориентации).

**English:** Returns current display width (depends on orientation).

```purebasic
width = WeAct_GetDisplayWidth()
Debug "Ширина дисплея: " + Str(width) + "px"
```

#### WeAct_GetDisplayHeight()
**Русский:** Возвращает текущую высоту дисплея (зависит от ориентации).

**English:** Returns current display height (depends on orientation).

```purebasic
height = WeAct_GetDisplayHeight()
Debug "Высота дисплея: " + Str(height) + "px"
```

#### WeAct_GetLastError()
**Русский:** Возвращает текст последней ошибки.

**English:** Returns last error message.

```purebasic
If Not WeAct_Init("COM99")
  error$ = WeAct_GetLastError()
  Debug "Ошибка инициализации: " + error$
EndIf
```

#### WeAct_CleanupFonts()
**Русский:** Очищает кэш шрифтов. Вызывается автоматически в WeAct_Cleanup().

**English:** Clears font cache. Called automatically in WeAct_Cleanup().

```purebasic
WeAct_CleanupFonts()  ; Освобождает память занятую шрифтами / Frees memory occupied by fonts
```

### 🆕 Новые функции / New Functions

#### WeAct_DrawProgressBar(x, y, Width, Height, Progress.f, ForeColor = #WEACT_GREEN, BackColor = #WEACT_BLACK, BorderColor = #WEACT_WHITE)
**Русский:** Рисует прогресс-бар с указанным прогрессом (0.0-1.0).

**English:** Draws progress bar with specified progress (0.0-1.0).

```purebasic
; Прогресс 65% / 65% progress
WeAct_DrawProgressBar(10, 30, 140, 15, 0.65, #WEACT_GREEN, #WEACT_BLACK, #WEACT_WHITE)

; Простой прогресс-бар / Simple progress bar
WeAct_DrawProgressBar(10, 50, 120, 10, 0.3)  ; Использует цвета по умолчанию / Uses default colors
```

#### WeAct_DrawGraph(x, y, Width, Height, *Data.Float, DataCount, MinValue.f, MaxValue.f, Color = #WEACT_WHITE, BackColor = #WEACT_BLACK)
**Русский:** Рисует график из массива значений с автоматическим масштабированием.

**English:** Draws graph from value array with automatic scaling.

```purebasic
; Создаем данные синусоиды / Create sine wave data
Protected Dim data.f(49)
For i = 0 To 49
  data(i) = Sin(i * 3.14159 * 2.0 / 50) * 0.8
Next

; Рисуем график / Draw graph
WeAct_DrawGraph(5, 15, 150, 60, @data(), 50, -1.0, 1.0, #WEACT_CYAN, #WEACT_BLACK)
```

#### WeAct_ShowTextFile(FileName.s, FontSize = 10, Color = #WEACT_WHITE, ScrollSpeed.f = 30.0)
**Русский:** Загружает текстовый файл и запускает вертикальный скроллинг.

**English:** Loads text file and starts vertical scrolling.

```purebasic
If WeAct_ShowTextFile("readme.txt", 8, #WEACT_WHITE, 20.0)
  Debug "Файл загружен / File loaded"
Else
  Debug "Ошибка: " + WeAct_GetLastError()
EndIf
```

#### WeAct_ShowTime(x, y, Hour, Minute, Color = #WEACT_WHITE, FontSize = 16)
**Русский:** Отображает время в формате HH:MM.

**English:** Displays time in HH:MM format.

```purebasic
WeAct_ShowTime(10, 10, 14, 30, #WEACT_WHITE, 16)  ; 14:30
```

#### WeAct_ShowDate(x, y, Day, Month, Year, Color = #WEACT_WHITE, FontSize = 10)
**Русский:** Отображает дату в формате DD.MM.YYYY.

**English:** Displays date in DD.MM.YYYY format.

```purebasic
WeAct_ShowDate(10, 30, 15, 1, 2026, #WEACT_WHITE, 10)  ; 15.01.2026
```

#### WeAct_DrawSpinner(cx, cy, radius, angle.f, Color = #WEACT_WHITE)
**Русский:** Рисует анимированный индикатор загрузки (спиннер).

**English:** Draws animated loading indicator (spinner).

```purebasic
; Анимация спиннера / Spinner animation
For angle.f = 0.0 To 360.0 Step 10.0
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawSpinner(80, 50, 20, angle, #WEACT_CYAN)
  WeAct_UpdateDisplay()
  Delay(30)
Next
```

### 📝 Внутренние функции / Internal Functions

#### SendCommand(*Data, Length)
**Русский:** Отправляет команду на дисплей. Внутренняя функция.

**English:** Sends command to display. Internal function.

```purebasic
; Пример использования внутри библиотеки / Example usage inside library
Dim cmd.b(2)
cmd(0) = $02   ; Команда ориентации / Orientation command
cmd(1) = #WEACT_LANDSCAPE
cmd(2) = $0A   ; Терминатор / Terminator
SendCommand(@cmd(), 3)
```

## 🎯 Примеры использования / Usage Examples

### Полный пример программы / Complete Program Example

```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM3")
  ; Очищаем экран / Clear screen
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Рисуем текст / Draw text
  WeAct_DrawTextMedium(10, 10, "WeAct Display Test", #WEACT_WHITE)
  WeAct_DrawTextSmall(10, 30, "Графика и текст", #WEACT_GREEN)
  
  ; Рисуем графические примитивы / Draw graphics primitives
  WeAct_DrawRectangleBuffer(10, 50, 60, 20, #WEACT_RED, #True)
  WeAct_DrawRectangleBuffer(80, 50, 60, 20, #WEACT_BLUE, #False)
  WeAct_DrawCircleBuffer(40, 70, 15, #WEACT_YELLOW, #True)
  WeAct_DrawCircleBuffer(100, 70, 10, #WEACT_CYAN, #False)
  
  ; Прогресс-бар / Progress bar
  WeAct_DrawProgressBar(10, 90, 140, 10, 0.75, #WEACT_GREEN, #WEACT_BLACK, #WEACT_WHITE)
  
  ; Обновляем дисплей / Update display
  WeAct_UpdateDisplay()
  
  Delay(5000)
  WeAct_Cleanup()
EndIf
```

### Пример со скроллингом / Scrolling Example

```purebasic
XIncludeFile "WeActDisplay.pbi"

If WeAct_Init("COM3")
  ; Запускаем скроллинг / Start scrolling
  WeAct_StartScrollText("Пример бегущей строки с плавным скроллингом", 12, #SCROLL_LEFT, 40.0, #WEACT_WHITE)
  
  ; Анимация / Animation
  For i = 1 To 300  ; ~10 секунд / ~10 seconds
    WeAct_ClearBuffer(#WEACT_BLACK)
    
    ; Обновляем и рисуем скроллируемый текст / Update and draw scrolling text
    WeAct_UpdateScrollText()
    WeAct_DrawScrollText()
    
    ; Рисуем статичный текст / Draw static text
    WeAct_DrawTextSmall(10, 60, "Счетчик: " + Str(i), #WEACT_GREEN)
    
    WeAct_UpdateDisplay()
    Delay(33)  ; ~30 FPS
  Next
  
  WeAct_StopScrollText()
  WeAct_Close()
EndIf
```

## 🎨 Предопределенные цвета / Predefined Colors

```purebasic
; Все цвета в формате RGB565 / All colors in RGB565 format
#WEACT_RED     = $F800    ; 1111100000000000 - Красный / Red
#WEACT_GREEN   = $07E0    ; 0000011111100000 - Зеленый / Green
#WEACT_BLUE    = $001F    ; 0000000000011111 - Синий / Blue
#WEACT_WHITE   = $FFFF    ; 1111111111111111 - Белый / White
#WEACT_BLACK   = $0000    ; 0000000000000000 - Черный / Black
#WEACT_YELLOW  = $FFE0    ; 1111111111100000 - Желтый / Yellow
#WEACT_CYAN    = $07FF    ; 0000011111111111 - Голубой / Cyan
#WEACT_MAGENTA = $F81F    ; 1111100000011111 - Пурпурный / Magenta
```

## 📋 Константы ориентации / Orientation Constants

```purebasic
; Используйте с WeAct_SetOrientation() / Use with WeAct_SetOrientation()
#WEACT_PORTRAIT = 0           ; 80x160 пикселей / 80x160 pixels
#WEACT_REVERSE_PORTRAIT = 1   ; 80x160 перевернутый / 80x160 reversed
#WEACT_LANDSCAPE = 2          ; 160x80 (стандарт) / 160x80 (default)
#WEACT_REVERSE_LANDSCAPE = 3  ; 160x80 перевернутый / 160x80 reversed
#WEACT_ROTATE = 5             ; Автоповорот / Auto-rotation
```

## 📋 Константы скроллинга / Scrolling Constants

```purebasic
; Используйте с WeAct_StartScrollText() / Use with WeAct_StartScrollText()
#SCROLL_LEFT = 0    ; Слева направо / Left to right
#SCROLL_RIGHT = 1   ; Справа налево / Right to left
#SCROLL_UP = 2      ; Снизу вверх / Bottom to top
#SCROLL_DOWN = 3    ; Сверху вниз / Top to bottom
```

## 🛠️ Технические характеристики / Technical Specifications

**Русский:**
- Дисплей: WeAct Display FS 0.96-inch
- Разрешение: 160x80 пикселей
- Подключение: USB-Serial (CH340)
- Скорость: 115200 бод
- Формат цвета: RGB565 (16-bit)
- Поддержка изображений: BMP, JPEG, PNG, TIFF, TGA
- Двойная буферизация: 2×25600 байт
- Поддержка кириллицы: полная

**English:**
- Display: WeAct Display FS 0.96-inch
- Resolution: 160x80 pixels
- Connection: USB-Serial (CH340)
- Baud rate: 115200
- Color format: RGB565 (16-bit)
- Image support: BMP, JPEG, PNG, TIFF, TGA
- Double buffering: 2×25600 bytes
- Cyrillic support: full

---

**Версия / Version:** 5.1
**Совместимость / Compatibility:** PureBasic 6.20+, WeAct Display FS 0.96-inch (160x80)  
**GitHub:** https://github.com/CheshirCa/WeActDisplay
