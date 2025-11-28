; =============================================
; WeAct Display FS Library for PureBasic
; Version 2.0 - Optimized with Buffering
; Supports WeAct Display FS 0.96-inch
; =============================================

; { Константы устройства }
#WEACT_DISPLAY_WIDTH = 160
#WEACT_DISPLAY_HEIGHT = 80
#WEACT_BAUDRATE = 115200
#WEACT_BUFFER_SIZE = #WEACT_DISPLAY_WIDTH * #WEACT_DISPLAY_HEIGHT * 2 ; 25600 bytes

; { Константы ориентации }
Enumeration
  #WEACT_PORTRAIT = 0
  #WEACT_REVERSE_PORTRAIT = 1
  #WEACT_LANDSCAPE = 2
  #WEACT_REVERSE_LANDSCAPE = 3
  #WEACT_ROTATE = 5
EndEnumeration

; { Базовые цвета RGB565 }
#WEACT_RED   = $F800
#WEACT_GREEN = $07E0
#WEACT_BLUE  = $001F
#WEACT_WHITE = $FFFF
#WEACT_BLACK = $0000
#WEACT_YELLOW = $FFE0
#WEACT_CYAN   = $07FF
#WEACT_MAGENTA = $F81F

; { Структуры }
Structure WeActDisplay
  SerialPort.i
  PortName.s
  IsConnected.i
  CurrentOrientation.i
  CurrentBrightness.i
  *FrameBuffer
  *BackBuffer
EndStructure

Structure FontCache
  FontID.i
  Size.i
  Name.s
EndStructure

; { Глобальные переменные }
Global WeActDisplay.WeActDisplay
Global NewMap FontCache.FontCache()

; =============================================
; { БАЗОВЫЕ ФУНКЦИИ }
; =============================================

Procedure.i RGBToRGB565(r, g, b)
  Protected rgb565.i
  r = r & $FF
  g = g & $FF
  b = b & $FF
  rgb565 = (r >> 3) << 11
  rgb565 | (g >> 2) << 5
  rgb565 | (b >> 3)
  ProcedureReturn rgb565
EndProcedure

Procedure SendCommand(*Data, Length)
  If WeActDisplay\IsConnected
    Result = WriteSerialPortData(WeActDisplay\SerialPort, *Data, Length)
    Delay(2) ; Минимальная задержка
    ProcedureReturn Result
  EndIf
  ProcedureReturn #False
EndProcedure

; =============================================
; { ИНИЦИАЛИЗАЦИЯ И ЗАВЕРШЕНИЕ }
; =============================================

Procedure WeAct_InitImageDecoders()
  ; Инициализация декодеров для поддержки различных форматов изображений
  UseJPEGImageDecoder()
  UsePNGImageDecoder() 
  UseTIFFImageDecoder()
  UseTGAImageDecoder()
  UseGIFImageDecoder()
EndProcedure

Procedure WeAct_Init(PortName.s = "COM3")
  WeActDisplay\SerialPort = OpenSerialPort(#PB_Any, PortName, #WEACT_BAUDRATE, 
                                          #PB_SerialPort_NoParity, 8, 1, 
                                          #PB_SerialPort_NoHandshake, 1024, 1024)
  
  If WeActDisplay\SerialPort
    WeActDisplay\PortName = PortName
    WeActDisplay\IsConnected = #True
    WeActDisplay\CurrentOrientation = #WEACT_LANDSCAPE
    WeActDisplay\CurrentBrightness = 255
    
    ; Выделяем буферы
    WeActDisplay\FrameBuffer = AllocateMemory(#WEACT_BUFFER_SIZE)
    WeActDisplay\BackBuffer = AllocateMemory(#WEACT_BUFFER_SIZE)
    
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      ; Очищаем буферы
      FillMemory(WeActDisplay\FrameBuffer, #WEACT_BUFFER_SIZE, 0)
      FillMemory(WeActDisplay\BackBuffer, #WEACT_BUFFER_SIZE, 0)
      
      ; Инициализируем декодеры изображений
      WeAct_InitImageDecoders()
      
      ProcedureReturn #True
    Else
      WeActDisplay\IsConnected = #False
      ProcedureReturn #False
    EndIf
  Else
    WeActDisplay\IsConnected = #False
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure WeAct_Close()
  If WeActDisplay\IsConnected
    CloseSerialPort(WeActDisplay\SerialPort)
    If WeActDisplay\FrameBuffer
      FreeMemory(WeActDisplay\FrameBuffer)
    EndIf
    If WeActDisplay\BackBuffer
      FreeMemory(WeActDisplay\BackBuffer)
    EndIf
    WeActDisplay\IsConnected = #False
  EndIf
EndProcedure

; =============================================
; { ФУНКЦИИ БУФЕРИЗАЦИИ }
; =============================================

Procedure WeAct_SwapBuffers()
  ; Быстрое переключение буферов
  Protected *temp = WeActDisplay\FrameBuffer
  WeActDisplay\FrameBuffer = WeActDisplay\BackBuffer
  WeActDisplay\BackBuffer = *temp
EndProcedure

Procedure WeAct_ClearBuffer(Color = #WEACT_BLACK)
  ; Очистка back buffer
  Protected i
  Protected *ptr = WeActDisplay\BackBuffer
  Protected color_l = Color & $FF
  Protected color_h = Color >> 8
  
  For i = 0 To (#WEACT_DISPLAY_WIDTH * #WEACT_DISPLAY_HEIGHT) - 1
    PokeA(*ptr + i * 2, color_l)
    PokeA(*ptr + i * 2 + 1, color_h)
  Next
EndProcedure

Procedure WeAct_DrawPixelBuffer(x, y, Color)
  ; Рисование пикселя в back buffer
  If x >= 0 And x < #WEACT_DISPLAY_WIDTH And y >= 0 And y < #WEACT_DISPLAY_HEIGHT
    Protected offset = (y * #WEACT_DISPLAY_WIDTH + x) * 2
    Protected *ptr = WeActDisplay\BackBuffer + offset
    PokeA(*ptr, Color & $FF)
    PokeA(*ptr + 1, Color >> 8)
  EndIf
EndProcedure

Procedure WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, Filled = #True)
  ; Рисование прямоугольника в back buffer
  Protected xx, yy
  
  If Filled
    For yy = y To y + Height - 1
      If yy >= 0 And yy < #WEACT_DISPLAY_HEIGHT
        For xx = x To x + Width - 1
          If xx >= 0 And xx < #WEACT_DISPLAY_WIDTH
            WeAct_DrawPixelBuffer(xx, yy, Color)
          EndIf
        Next
      EndIf
    Next
  Else
    ; Контур
    For xx = x To x + Width - 1
      WeAct_DrawPixelBuffer(xx, y, Color)
      WeAct_DrawPixelBuffer(xx, y + Height - 1, Color)
    Next
    For yy = y To y + Height - 1
      WeAct_DrawPixelBuffer(x, yy, Color)
      WeAct_DrawPixelBuffer(x + Width - 1, yy, Color)
    Next
  EndIf
EndProcedure

Procedure WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
  ; Алгоритм Брезенхэма для линии
  Protected dx = Abs(x2 - x1)
  Protected dy = Abs(y2 - y1)
  Protected sx = 1 : If x1 > x2 : sx = -1 : EndIf
  Protected sy = 1 : If y1 > y2 : sy = -1 : EndIf
  Protected err = dx - dy
  
  While #True
    WeAct_DrawPixelBuffer(x1, y1, Color)
    If x1 = x2 And y1 = y2 : Break : EndIf
    Protected e2 = err * 2
    If e2 > -dy
      err - dy
      x1 + sx
    EndIf
    If e2 < dx
      err + dx
      y1 + sy
    EndIf
  Wend
EndProcedure

; =============================================
; { БЫСТРЫЙ ВЫВОД НА ДИСПЛЕЙ }
; =============================================

Procedure WeAct_FlushBuffer()
  ; Быстрая отправка всего back buffer на дисплей
  Dim Command.b(9)
  Command(0) = $05        ; SET_BITMAP
  
  ; Вся область экрана
  Command(1) = 0          ; xs_l8
  Command(2) = 0          ; xs_h8
  Command(3) = 0          ; ys_l8
  Command(4) = 0          ; ys_h8
  Command(5) = #WEACT_DISPLAY_WIDTH - 1 & $FF    ; xe_l8
  Command(6) = #WEACT_DISPLAY_WIDTH - 1 >> 8     ; xe_h8
  Command(7) = #WEACT_DISPLAY_HEIGHT - 1 & $FF   ; ye_l8
  Command(8) = #WEACT_DISPLAY_HEIGHT - 1 >> 8    ; ye_h8
  Command(9) = $0A        ; Terminator
  
  If WeActDisplay\IsConnected
    WriteSerialPortData(WeActDisplay\SerialPort, @Command(), 10)
    WriteSerialPortData(WeActDisplay\SerialPort, WeActDisplay\BackBuffer, #WEACT_BUFFER_SIZE)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure WeAct_UpdateDisplay()
  ; Обновление дисплея и переключение буферов
  If WeAct_FlushBuffer()
    WeAct_SwapBuffers()
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; =============================================
; { РЕНДЕРИНГ СИСТЕМНЫМИ ШРИФТАМИ }
; =============================================

Procedure.i GetCachedFont(FontName.s, FontSize.i)
  ; Кэширование шрифтов для избежания повторной загрузки
  Protected key.s = FontName + "_" + Str(FontSize)
  
  If FindMapElement(FontCache(), key)
    ProcedureReturn FontCache()\FontID
  Else
    Protected fontID = LoadFont(#PB_Any, FontName, FontSize)
    If fontID
      AddMapElement(FontCache(), key)
      FontCache()\FontID = fontID
      FontCache()\Size = FontSize
      FontCache()\Name = FontName
      ProcedureReturn fontID
    EndIf
  EndIf
  
  ProcedureReturn #PB_Default
EndProcedure

Procedure WeAct_DrawTextSystemFont(x, y, Text.s, Color, FontSize.i = 12, FontName.s = "Arial")
  ; Рендеринг текста системным шрифтом в back buffer
  Protected fontID, tempImage
  
  ; Загружаем шрифт ДО начала рисования
  fontID = GetCachedFont(FontName, FontSize)
  If fontID = #PB_Default
    fontID = LoadFont(#PB_Any, FontName, FontSize)
    If Not fontID
      ProcedureReturn ; Не удалось загрузить шрифт
    EndIf
  EndIf
  
  ; Создаем временное изображение для рендеринга текста
  tempImage = CreateImage(#PB_Any, #WEACT_DISPLAY_WIDTH, #WEACT_DISPLAY_HEIGHT, 24)
  If tempImage
    If StartDrawing(ImageOutput(tempImage))
      ; Очищаем фон
      Box(0, 0, #WEACT_DISPLAY_WIDTH, #WEACT_DISPLAY_HEIGHT, RGB(0, 0, 0))
      
      ; Устанавливаем заранее загруженный шрифт
      DrawingFont(FontID(fontID))
      DrawingMode(#PB_2DDrawing_Transparent)
      
      ; Конвертируем RGB565 в RGB
      Protected textColor = RGB(Red(Color), Green(Color), Blue(Color))
      
      ; Рисуем текст
      DrawText(x, y, Text, textColor)
      
      StopDrawing()
      
      ; Копируем результат в back buffer
      If StartDrawing(ImageOutput(tempImage))
        Protected sourceX, sourceY, pixelColor, r, g, b
        
        For sourceY = 0 To #WEACT_DISPLAY_HEIGHT - 1
          For sourceX = 0 To #WEACT_DISPLAY_WIDTH - 1
            pixelColor = Point(sourceX, sourceY)
            If pixelColor <> 0 ; Если не черный (текст)
              r = Red(pixelColor)
              g = Green(pixelColor) 
              b = Blue(pixelColor)
              WeAct_DrawPixelBuffer(sourceX, sourceY, RGBToRGB565(r, g, b))
            EndIf
          Next
        Next
        
        StopDrawing()
      EndIf
      
      FreeImage(tempImage)
    EndIf
  EndIf
EndProcedure

; Упрощенные версии с предзагруженными шрифтами
Procedure WeAct_DrawTextSmall(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 8, "Arial")
EndProcedure

Procedure WeAct_DrawTextMedium(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 12, "Arial")
EndProcedure

Procedure WeAct_DrawTextLarge(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 16, "Arial")
EndProcedure

; Функция для очистки кэша шрифтов при завершении
Procedure WeAct_CleanupFonts()
  ForEach FontCache()
    If FontCache()\FontID
      FreeFont(FontCache()\FontID)
    EndIf
  Next
  ClearMap(FontCache())
EndProcedure

; =============================================
; { ЗАГРУЗКА И ВЫВОД ИЗОБРАЖЕНИЙ }
; =============================================

Procedure.s WeAct_GetSupportedImageFormats()
  ; Возвращает поддерживаемые форматы изображений
  ProcedureReturn "BMP, JPEG, PNG, TIFF, TGA, GIF"
EndProcedure

Procedure WeAct_LoadImageToBuffer(x, y, FileName.s, Width.i = -1, Height.i = -1)
  ; Загрузка изображения из файла в back buffer с ресайзингом
  Protected originalImage, resizedImage
  Protected originalWidth, originalHeight
  Protected targetWidth, targetHeight
  Protected destX, destY, pixelColor, r, g, b
  
  ; Проверяем существование файла
  If FileSize(FileName) <= 0
    Debug "File not found or empty: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Загружаем изображение (теперь поддерживаются все форматы)
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    Debug "Cannot load image: " + FileName
    Debug "Supported formats: " + WeAct_GetSupportedImageFormats()
    ProcedureReturn #False
  EndIf
  
  ; Получаем размеры исходного изображения
  originalWidth = ImageWidth(originalImage)
  originalHeight = ImageHeight(originalImage)
  
  ; Определяем целевые размеры
  If Width = -1 And Height = -1
    targetWidth = originalWidth
    targetHeight = originalHeight
  ElseIf Width = -1
    targetHeight = Height
    targetWidth = originalWidth * (targetHeight / originalHeight)
  ElseIf Height = -1
    targetWidth = Width
    targetHeight = originalHeight * (targetWidth / originalWidth)
  Else
    targetWidth = Width
    targetHeight = Height
  EndIf
  
  ; Округляем до целых
  targetWidth = Int(targetWidth)
  targetHeight = Int(targetHeight)
  
  ; Ограничиваем размеры экраном
  If targetWidth > #WEACT_DISPLAY_WIDTH
    targetWidth = #WEACT_DISPLAY_WIDTH
  EndIf
  If targetHeight > #WEACT_DISPLAY_HEIGHT
    targetHeight = #WEACT_DISPLAY_HEIGHT
  EndIf
  
  ; Проверяем позицию
  If x < 0 : x = 0 : EndIf
  If y < 0 : y = 0 : EndIf
  If x + targetWidth > #WEACT_DISPLAY_WIDTH
    x = #WEACT_DISPLAY_WIDTH - targetWidth
  EndIf
  If y + targetHeight > #WEACT_DISPLAY_HEIGHT
    y = #WEACT_DISPLAY_HEIGHT - targetHeight
  EndIf
  
  ; Если размеры нулевые - выходим
  If targetWidth <= 0 Or targetHeight <= 0
    Debug "Error: Target size is zero"
    FreeImage(originalImage)
    ProcedureReturn #False
  EndIf
  
  ; Создаем ресайзнутое изображение
  resizedImage = CreateImage(#PB_Any, targetWidth, targetHeight)
  If Not resizedImage
    Debug "Cannot create resized image"
    FreeImage(originalImage)
    ProcedureReturn #False
  EndIf
  
  ; Ресайзим изображение
  If StartDrawing(ImageOutput(resizedImage))
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, targetWidth, targetHeight, RGB(0, 0, 0)) ; Черный фон
    DrawImage(ImageID(originalImage), 0, 0, targetWidth, targetHeight)
    StopDrawing()
  EndIf
  
  ; Копируем в back buffer
  If StartDrawing(ImageOutput(resizedImage))
    For destY = 0 To targetHeight - 1
      For destX = 0 To targetWidth - 1
        pixelColor = Point(destX, destY)
        r = Red(pixelColor)
        g = Green(pixelColor)
        b = Blue(pixelColor)
        WeAct_DrawPixelBuffer(x + destX, y + destY, RGBToRGB565(r, g, b))
      Next
    Next
    StopDrawing()
  EndIf
  
  ; Освобождаем ресурсы
  FreeImage(resizedImage)
  FreeImage(originalImage)
  
  ProcedureReturn #True
EndProcedure

Procedure WeAct_LoadImageFullScreen(FileName.s)
  ; Загрузка изображения на весь экран с сохранением пропорций
  Protected originalImage, targetWidth, targetHeight
  Protected scale.f, x, y
  
  If FileSize(FileName) <= 0
    Debug "File not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    Debug "Cannot load image: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Вычисляем масштаб для вписывания в экран
  scale = #WEACT_DISPLAY_WIDTH / ImageWidth(originalImage)
  If (#WEACT_DISPLAY_HEIGHT / ImageHeight(originalImage)) < scale
    scale = #WEACT_DISPLAY_HEIGHT / ImageHeight(originalImage)
  EndIf
  
  targetWidth = ImageWidth(originalImage) * scale
  targetHeight = ImageHeight(originalImage) * scale
  
  ; Центрируем
  x = (#WEACT_DISPLAY_WIDTH - targetWidth) / 2
  y = (#WEACT_DISPLAY_HEIGHT - targetHeight) / 2
  
  FreeImage(originalImage)
  
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

Procedure WeAct_LoadImageCentered(FileName.s, Width.i = -1, Height.i = -1)
  ; Загрузка изображения по центру экрана
  Protected originalImage, targetWidth, targetHeight
  Protected x, y
  
  If FileSize(FileName) <= 0
    Debug "File not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    Debug "Cannot load image: " + FileName
    ProcedureReturn #False
  EndIf
  
  If Width = -1 And Height = -1
    targetWidth = ImageWidth(originalImage)
    targetHeight = ImageHeight(originalImage)
  ElseIf Width = -1
    targetHeight = Height
    targetWidth = ImageWidth(originalImage) * (targetHeight / ImageHeight(originalImage))
  ElseIf Height = -1
    targetWidth = Width
    targetHeight = ImageHeight(originalImage) * (targetWidth / ImageWidth(originalImage))
  Else
    targetWidth = Width
    targetHeight = Height
  EndIf
  
  ; Центрируем
  x = (#WEACT_DISPLAY_WIDTH - targetWidth) / 2
  y = (#WEACT_DISPLAY_HEIGHT - targetHeight) / 2
  
  FreeImage(originalImage)
  
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

; =============================================
; { ОСНОВНЫЕ КОМАНДЫ УПРАВЛЕНИЯ }
; =============================================

Procedure WeAct_SetOrientation(Orientation)
  If Orientation >= 0 And Orientation <= 5
    Dim Command.b(2)
    Command(0) = $02
    Command(1) = Orientation
    Command(2) = $0A
    If SendCommand(@Command(), 3)
      WeActDisplay\CurrentOrientation = Orientation
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure WeAct_SetBrightness(Brightness, TimeMs = 500)
  If Brightness < 0 : Brightness = 0 : EndIf
  If Brightness > 255 : Brightness = 255 : EndIf
  If TimeMs < 0 : TimeMs = 0 : EndIf
  If TimeMs > 5000 : TimeMs = 5000 : EndIf
  
  Dim Command.b(4)
  Command(0) = $03
  Command(1) = Brightness
  Command(2) = TimeMs & $FF
  Command(3) = TimeMs >> 8
  Command(4) = $0A
  
  If SendCommand(@Command(), 5)
    WeActDisplay\CurrentBrightness = Brightness
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure WeAct_SystemReset()
  Dim Command.b(1)
  Command(0) = $40
  Command(1) = $0A
  ProcedureReturn SendCommand(@Command(), 2)
EndProcedure

; =============================================
; { ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ }
; =============================================

Procedure.s WeAct_GetInfo()
  If WeActDisplay\IsConnected
    ProcedureReturn "WeAct Display FS 0.96-inch (" + WeActDisplay\PortName + ")"
  EndIf
  ProcedureReturn "Not connected"
EndProcedure

Procedure.i WeAct_GetOrientation()
  ProcedureReturn WeActDisplay\CurrentOrientation
EndProcedure

Procedure.i WeAct_GetBrightness()
  ProcedureReturn WeActDisplay\CurrentBrightness
EndProcedure

Procedure.i WeAct_IsConnected()
  ProcedureReturn WeActDisplay\IsConnected
EndProcedure

; =============================================
; { ДЕСТРУКТОР }
; =============================================

Procedure WeAct_Cleanup()
  WeAct_CleanupFonts()
  WeAct_Close()
EndProcedure

; Автоматическая очистка при завершении
If IsWindow(0) = 0
  OpenWindow(0, 0, 0, 1, 1, "")
EndIf
AddWindowTimer(0, 0, 1000)
BindEvent(#PB_Event_Timer, @WeAct_Cleanup())

; IDE Options = PureBasic 6.21 (Windows - x86)
; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 632
; FirstLine = 582
; Folding = ------
; EnableXP