# WeAct Display FS Library for PureBasic

## Описание библиотеки

Библиотека для работы с дисплеем WeAct Display FS 0.96-inch через последовательный порт. Поддерживает двойную буферизацию, системные шрифты и загрузку изображений.

## Основные функции

### Инициализация и управление

**WeAct_Init(PortName.s)**
Инициализирует дисплей и подключается к указанному COM-порту.
Возвращает #True при успешной инициализации.
```
If WeAct_Init("COM8")
  Debug "Дисплей инициализирован"
EndIf
```

**WeAct_Close()**
Закрывает соединение с дисплеем и освобождает ресурсы.
```
WeAct_Close()
```

**WeAct_IsConnected()**
Проверяет подключение к дисплею.
Возвращает #True если дисплей подключен.
```
If WeAct_IsConnected()
  Debug "Дисплей подключен"
EndIf
```

### Управление дисплеем

**WeAct_SetOrientation(Orientation)**
Устанавливает ориентацию дисплея.
Допустимые значения: #WEACT_PORTRAIT, #WEACT_LANDSCAPE, #WEACT_REVERSE_PORTRAIT, #WEACT_REVERSE_LANDSCAPE, #WEACT_ROTATE
```
WeAct_SetOrientation(#WEACT_LANDSCAPE)
```

**WeAct_SetBrightness(Brightness, TimeMs)**
Устанавливает яркость дисплея (0-255) с плавным изменением за указанное время в миллисекундах.
```
WeAct_SetBrightness(200, 1000) ; Яркость 200, изменение за 1 секунду
```

**WeAct_SystemReset()**
Выполняет системный сброс дисплея.
```
WeAct_SystemReset()
```

### Работа с буфером

**WeAct_ClearBuffer(Color)**
Очищает back buffer указанным цветом.
```
WeAct_ClearBuffer(#WEACT_BLACK) ; Очистить черным цветом
WeAct_ClearBuffer(#WEACT_WHITE) ; Очистить белым цветом
```

**WeAct_UpdateDisplay()**
Выводит содержимое back buffer на дисплей и переключает буферы.
```
WeAct_UpdateDisplay()
```

### Графические примитивы

**WeAct_DrawPixelBuffer(x, y, Color)**
Рисует пиксель в back buffer.
```
WeAct_DrawPixelBuffer(10, 10, #WEACT_RED)
```

**WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)**
Рисует линию в back buffer.
```
WeAct_DrawLineBuffer(0, 0, 50, 50, #WEACT_GREEN)
```

**WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, Filled)**
Рисует прямоугольник в back buffer.
Filled = #True для залитого, #False для контура.
```
; Залитый прямоугольник
WeAct_DrawRectangleBuffer(10, 10, 50, 30, #WEACT_BLUE, #True)

; Контур прямоугольника  
WeAct_DrawRectangleBuffer(70, 10, 50, 30, #WEACT_YELLOW, #False)
```

### Работа с текстом

**WeAct_DrawTextSystemFont(x, y, Text, Color, FontSize, FontName)**
Рисует текст системным шрифтом в back buffer.
```
WeAct_DrawTextSystemFont(10, 10, "Hello World", #WEACT_WHITE, 12, "Arial")
```

**WeAct_DrawTextSmall(x, y, Text, Color)**
Рисует текст мелким шрифтом (8px).
```
WeAct_DrawTextSmall(10, 10, "Small text", #WEACT_WHITE)
```

**WeAct_DrawTextMedium(x, y, Text, Color)**
Рисует текст средним шрифтом (12px).
```
WeAct_DrawTextMedium(10, 25, "Medium text", #WEACT_GREEN)
```

**WeAct_DrawTextLarge(x, y, Text, Color)**
Рисует текст крупным шрифтом (16px).
```
WeAct_DrawTextLarge(10, 45, "Large text", #WEACT_RED)
```

### Работа с изображениями

**WeAct_LoadImageToBuffer(x, y, FileName, Width, Height)**
Загружает изображение из файла в back buffer с возможностью ресайза.
```
; Оригинальный размер
WeAct_LoadImageToBuffer(0, 0, "image.jpg")

; Ресайз до указанных размеров
WeAct_LoadImageToBuffer(10, 10, "image.jpg", 100, 50)
```

**WeAct_LoadImageFullScreen(FileName)**
Загружает изображение на весь экран с сохранением пропорций.
```
WeAct_LoadImageFullScreen("photo.jpg")
```

**WeAct_LoadImageCentered(FileName, Width, Height)**
Загружает изображение по центру экрана.
```
; Центрированное изображение с оригинальным размером
WeAct_LoadImageCentered("logo.png")

; Центрированное изображение 100x60
WeAct_LoadImageCentered("logo.png", 100, 60)
```

### Вспомогательные функции

**WeAct_GetInfo()**
Возвращает информацию о подключенном дисплее.
```
Debug WeAct_GetInfo()
```

**WeAct_GetOrientation()**
Возвращает текущую ориентацию дисплея.
```
orientation = WeAct_GetOrientation()
```

**WeAct_GetBrightness()**
Возвращает текущую яркость дисплея.
```
brightness = WeAct_GetBrightness()
```

## Пример программы

```
; Подключаем библиотеку
IncludeFile "WeActDisplay.pbi"

; Инициализируем дисплей
If WeAct_Init("COM8")
  
  ; Очищаем буфер черным цветом
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Рисуем текст разными размерами
  WeAct_DrawTextSmall(10, 10, "Small text", #WEACT_WHITE)
  WeAct_DrawTextMedium(10, 25, "Medium text", #WEACT_GREEN) 
  WeAct_DrawTextLarge(10, 45, "Large text", #WEACT_RED)
  
  ; Рисуем графические примитивы
  WeAct_DrawRectangleBuffer(100, 10, 50, 30, #WEACT_BLUE, #True)
  WeAct_DrawLineBuffer(100, 50, 150, 70, #WEACT_YELLOW)
  
  ; Выводим на дисплей
  WeAct_UpdateDisplay()
  
  ; Ждем 3 секунды
  Delay(3000)
  
  ; Очищаем и загружаем изображение
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_LoadImageFullScreen("background.jpg")
  WeAct_UpdateDisplay()
  
  ; Закрываем соединение
  WeAct_Close()
  
Else
  Debug "Ошибка инициализации дисплея"
EndIf
```

## Поддерживаемые форматы изображений

Библиотека поддерживает загрузку изображений в форматах: BMP, JPEG, PNG, TIFF, TGA, GIF.

## Цвета

Доступные предопределенные цвета в формате RGB565:
- #WEACT_RED
- #WEACT_GREEN  
- #WEACT_BLUE
- #WEACT_WHITE
- #WEACT_BLACK
- #WEACT_YELLOW
- #WEACT_CYAN
- #WEACT_MAGENTA

Также можно создавать свои цвета с помощью функции RGBToRGB565(r, g, b).

## Важные замечания

1. Все функции рисования работают с back buffer. Для вывода на дисплей необходимо вызвать WeAct_UpdateDisplay().
2. Библиотека использует двойную буферизацию для плавного вывода.
3. При завершении программы автоматически вызывается очистка ресурсов.
4. Для работы с изображениями необходимо наличие файлов изображений в поддерживаемых форматах.
