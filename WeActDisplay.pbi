; =============================================
; WeAct Display FS Library for PureBasic
; Version 3.2 - Stable Release (Fixed Colors & Text)
; Supports WeAct Display FS 0.96-inch
; =============================================

; { Константы устройства }
#WEACT_DISPLAY_WIDTH = 160
#WEACT_DISPLAY_HEIGHT = 80
#WEACT_BAUDRATE = 115200
#WEACT_BUFFER_SIZE = #WEACT_DISPLAY_WIDTH * #WEACT_DISPLAY_HEIGHT * 2

; { Константы ориентации }
Enumeration
  #WEACT_PORTRAIT = 0
  #WEACT_REVERSE_PORTRAIT = 1
  #WEACT_LANDSCAPE = 2
  #WEACT_REVERSE_LANDSCAPE = 3
EndEnumeration

; { Константы скроллинга }
Enumeration
  #SCROLL_LEFT = 0
  #SCROLL_RIGHT
  #SCROLL_UP
  #SCROLL_DOWN
EndEnumeration

; { Предопределенные цвета для BRG565 }
#WEACT_RED    = $07C0    ; BRG: 00000 11111 000000 (синий=0, красный=31, зеленый=0)
#WEACT_GREEN  = $001F    ; BRG: 00000 00000 011111 (синий=0, красный=0, зеленый=31)
#WEACT_BLUE   = $F800    ; BRG: 11111 00000 000000 (синий=31, красный=0, зеленый=0)
#WEACT_WHITE  = $FFFF    ; BRG: 11111 11111 111111
#WEACT_BLACK  = $0000    ; BRG: 00000 00000 000000
#WEACT_YELLOW = $07FF    ; BRG: 00000 11111 111111 (синий=0, красный=31, зеленый=63)
#WEACT_CYAN   = $F81F    ; BRG: 11111 00000 111111 (синий=31, красный=0, зеленый=63)
#WEACT_MAGENTA = $FFE0   ; BRG: 11111 11111 000000 (синий=0, красный=31, зеленый=63)

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

Structure ScrollText
  Text.s
  FontSize.i
  Direction.i
  Speed.i
  Position.i
  Color.i
  FontName.s
  Active.i
  LastUpdate.i
EndStructure

; { Глобальные переменные }
Global WeActDisplay.WeActDisplay
Global NewMap FontCache.FontCache()
Global ScrollText.ScrollText
Global WeAct_DisplayWidth.i = #WEACT_DISPLAY_WIDTH
Global WeAct_DisplayHeight.i = #WEACT_DISPLAY_HEIGHT
Global WeAct_BufferSize.i = #WEACT_BUFFER_SIZE

Declare WeAct_SetOrientation(Orientation)

; =============================================
; { БАЗОВЫЕ ФУНКЦИИ }
; =============================================

Procedure.i RGBToRGB565(r, g, b)
  ; Нормализуем значения
  r = r & $FF
  g = g & $FF  
  b = b & $FF
  
  ; Преобразуем в BRG565 (Синий, Красный, Зеленый)
  Protected r5 = (r >> 3) & $1F    ; 5 бит красного
  Protected g6 = (g >> 2) & $3F    ; 6 бит зеленого  
  Protected b5 = (b >> 3) & $1F    ; 5 бит синего
  
  ; Формируем цвет в порядке: BBBBBRRRRRGGGGGG
  Protected brg565 = (b5 << 11) | (r5 << 6) | g6
  
  ProcedureReturn brg565
EndProcedure

Procedure SendCommand(*Data, Length)
  If WeActDisplay\IsConnected
    Result = WriteSerialPortData(WeActDisplay\SerialPort, *Data, Length)
    Delay(5)
    ProcedureReturn Result
  EndIf
  ProcedureReturn #False
EndProcedure

; =============================================
; { ИНИЦИАЛИЗАЦИЯ И ЗАВЕРШЕНИЕ }
; =============================================

Procedure WeAct_InitImageDecoders()
  UseJPEGImageDecoder()
  UsePNGImageDecoder()
  UseTIFFImageDecoder()
  UseTGAImageDecoder()
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
    
    ; Выделяем буферы фиксированного размера 160x80
    WeActDisplay\FrameBuffer = AllocateMemory(#WEACT_BUFFER_SIZE)
    WeActDisplay\BackBuffer = AllocateMemory(#WEACT_BUFFER_SIZE)
    
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      FillMemory(WeActDisplay\FrameBuffer, #WEACT_BUFFER_SIZE, 0)
      FillMemory(WeActDisplay\BackBuffer, #WEACT_BUFFER_SIZE, 0)
      
      WeAct_InitImageDecoders()
      WeAct_SetOrientation(#WEACT_LANDSCAPE)
      Delay(500)
      
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
    WeActDisplay\IsConnected = #False
  EndIf
  
  ; Безопасное освобождение памяти
  If WeActDisplay\FrameBuffer
    FreeMemory(WeActDisplay\FrameBuffer)
    WeActDisplay\FrameBuffer = 0
  EndIf
  If WeActDisplay\BackBuffer
    FreeMemory(WeActDisplay\BackBuffer)
    WeActDisplay\BackBuffer = 0
  EndIf
EndProcedure

; =============================================
; { ФУНКЦИИ БУФЕРИЗАЦИИ }
; =============================================

Procedure WeAct_SwapBuffers()
  Protected *temp = WeActDisplay\FrameBuffer
  WeActDisplay\FrameBuffer = WeActDisplay\BackBuffer
  WeActDisplay\BackBuffer = *temp
EndProcedure

Procedure WeAct_ClearBuffer(Color = #WEACT_BLACK)
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  
  Protected i
  Protected *ptr = WeActDisplay\BackBuffer
  ; Исправляем порядок байт
  Protected color_l = Color >> 8     ; Старший байт
  Protected color_h = Color & $FF    ; Младший байт
  
  For i = 0 To (WeAct_DisplayWidth * WeAct_DisplayHeight) - 1
    PokeA(*ptr + i * 2, color_l)
    PokeA(*ptr + i * 2 + 1, color_h)
  Next
EndProcedure

Procedure WeAct_DrawPixelBuffer(x, y, Color)
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  If x < 0 Or x >= WeAct_DisplayWidth Or y < 0 Or y >= WeAct_DisplayHeight
    ProcedureReturn
  EndIf
  
  Protected offset = (y * WeAct_DisplayWidth + x) * 2
  Protected *ptr = WeActDisplay\BackBuffer + offset
  ; Исправляем порядок байт
  PokeA(*ptr, Color >> 8)      ; Старший байт
  PokeA(*ptr + 1, Color & $FF) ; Младший байт
EndProcedure

Procedure WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, Filled = #True)
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
; { ВЫВОД НА ДИСПЛЕЙ }
; =============================================

Procedure WeAct_FlushBuffer()
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn #False : EndIf
  If Not WeActDisplay\IsConnected : ProcedureReturn #False : EndIf
  
  Dim Command.b(10)
  Command(0) = $05
  
  Command(1) = 0
  Command(2) = 0
  Command(3) = 0
  Command(4) = 0
  
  Protected x_end = WeAct_DisplayWidth - 1
  Command(5) = x_end & $FF
  Command(6) = (x_end >> 8) & $FF
  
  Protected y_end = WeAct_DisplayHeight - 1
  Command(7) = y_end & $FF
  Command(8) = (y_end >> 8) & $FF
  
  Command(9) = $0A
  
  If WriteSerialPortData(WeActDisplay\SerialPort, @Command(), 10)
    Delay(10)
    If WriteSerialPortData(WeActDisplay\SerialPort, WeActDisplay\BackBuffer, WeAct_BufferSize)
      Delay(10)
      ProcedureReturn #True
    EndIf
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure WeAct_UpdateDisplay()
  If WeAct_FlushBuffer()
    WeAct_SwapBuffers()
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; =============================================
; { РЕНДЕРИНГ ТЕКСТА }
; =============================================

Procedure.i GetCachedFont(FontName.s, FontSize.i)
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

Procedure.i WeAct_GetTextWidth(Text.s, FontSize.i, FontName.s = "Arial")
  Protected fontID, width.i = 0
  Protected tempImage
  
  fontID = GetCachedFont(FontName, FontSize)
  If fontID = #PB_Default
    fontID = LoadFont(#PB_Any, FontName, FontSize)
    If Not fontID
      ProcedureReturn 0
    EndIf
  EndIf
  
  tempImage = CreateImage(#PB_Any, 1, 1, 24)
  If tempImage And StartDrawing(ImageOutput(tempImage))
    DrawingFont(FontID(fontID))
    width = TextWidth(Text)
    StopDrawing()
    FreeImage(tempImage)
  EndIf
  
  ProcedureReturn width
EndProcedure

Procedure.i WeAct_GetTextHeight(Text.s, FontSize.i, FontName.s = "Arial")
  Protected fontID, height.i = 0
  Protected tempImage
  
  fontID = GetCachedFont(FontName, FontSize)
  If fontID = #PB_Default
    fontID = LoadFont(#PB_Any, FontName, FontSize)
    If Not fontID
      ProcedureReturn 0
    EndIf
  EndIf
  
  tempImage = CreateImage(#PB_Any, 1, 1, 24)
  If tempImage And StartDrawing(ImageOutput(tempImage))
    DrawingFont(FontID(fontID))
    height = TextHeight(Text)
    StopDrawing()
    FreeImage(tempImage)
  EndIf
  
  ProcedureReturn height
EndProcedure

Procedure WeAct_DrawTextSystemFont(x, y, Text.s, Color, FontSize.i = 12, FontName.s = "Arial")
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  If Text = "" : ProcedureReturn : EndIf
  
  Protected fontID, tempImage
  
  fontID = GetCachedFont(FontName, FontSize)
  If fontID = #PB_Default
    fontID = LoadFont(#PB_Any, FontName, FontSize)
    If Not fontID
      ProcedureReturn
    EndIf
  EndIf
  
  ; Создаем временное изображение для рендеринга текста
  tempImage = CreateImage(#PB_Any, #WEACT_DISPLAY_WIDTH, #WEACT_DISPLAY_HEIGHT, 24, #Black)
  If tempImage
    If StartDrawing(ImageOutput(tempImage))
      DrawingFont(FontID(fontID))
      DrawingMode(#PB_2DDrawing_Transparent)
      ; Рисуем текст БЕЛЫМ цветом на черном фоне
      DrawText(x, y, Text, RGB(255, 255, 255))
      StopDrawing()
      
      ; Копируем белые пиксели текста на дисплей
      If StartDrawing(ImageOutput(tempImage))
        Protected sourceX, sourceY, pixelColor, brightness
        
        For sourceY = 0 To #WEACT_DISPLAY_HEIGHT - 1
          For sourceX = 0 To #WEACT_DISPLAY_WIDTH - 1
            pixelColor = Point(sourceX, sourceY)
            brightness = Red(pixelColor) ; Для серого R=G=B
            
            ; Захватываем все пиксели текста (включая сглаженные)
            If brightness > 30 ; Оптимальный порог для читаемости
              WeAct_DrawPixelBuffer(sourceX, sourceY, Color)
            EndIf
          Next
        Next
        StopDrawing()
      EndIf
      FreeImage(tempImage)
    EndIf
  EndIf
EndProcedure

Procedure WeAct_DrawTextSmall(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 8, "Arial")
EndProcedure

Procedure WeAct_DrawTextMedium(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 12, "Arial")
EndProcedure

Procedure WeAct_DrawTextLarge(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 16, "Arial")
EndProcedure

; =============================================
; { ПЕРЕНОС ТЕКСТА }
; =============================================

Procedure WeAct_DrawWrappedText(x, y, Width, Height, Text.s, Color, FontSize.i = 12, FontName.s = "Arial", AutoSize = #False)
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  
  Protected fontID, tempImage, currentFontSize
  Protected Dim lines.s(0)
  Protected lineCount, i, currentY
  Protected maxLines, lineHeight
  Protected fitted = #False
  
  currentFontSize = FontSize
  
  If AutoSize
    While currentFontSize >= 6 And Not fitted
      fontID = GetCachedFont(FontName, currentFontSize)
      If fontID = #PB_Default
        fontID = LoadFont(#PB_Any, FontName, currentFontSize)
        If Not fontID
          ProcedureReturn
        EndIf
      EndIf
      
      tempImage = CreateImage(#PB_Any, Width, Height, 24)
      If tempImage
        If StartDrawing(ImageOutput(tempImage))
          DrawingFont(FontID(fontID))
          ReDim lines.s(0)
          lineCount = 0
          Protected words.s = ReplaceString(Text, Chr(13) + Chr(10), " ")
          words = ReplaceString(words, Chr(13), " ")
          words = ReplaceString(words, Chr(10), " ")
          Protected wordCount = CountString(words, " ") + 1
          Protected currentLine.s = ""
          Protected testLine.s
          Protected textWidth
          
          For i = 1 To wordCount
            testLine = currentLine
            If testLine <> ""
              testLine + " "
            EndIf
            testLine + StringField(words, i, " ")
            textWidth = TextWidth(testLine)
            If textWidth <= Width
              currentLine = testLine
            Else
              If currentLine <> ""
                ReDim lines.s(lineCount + 1)
                lines(lineCount) = currentLine
                lineCount + 1
              EndIf
              currentLine = StringField(words, i, " ")
            EndIf
          Next i
          
          If currentLine <> ""
            ReDim lines.s(lineCount + 1)
            lines(lineCount) = currentLine
            lineCount + 1
          EndIf
          
          lineHeight = TextHeight("A")
          maxLines = Height / lineHeight
          
          If lineCount <= maxLines
            fitted = #True
          Else
            currentFontSize - 1
          EndIf
          StopDrawing()
        EndIf
        FreeImage(tempImage)
      EndIf
      
      If Not fitted And currentFontSize < 6
        currentFontSize = 6
        fitted = #True
      EndIf
    Wend
  Else
    fontID = GetCachedFont(FontName, currentFontSize)
    If fontID = #PB_Default
      fontID = LoadFont(#PB_Any, FontName, currentFontSize)
      If Not fontID
        ProcedureReturn
      EndIf
    EndIf
    
    tempImage = CreateImage(#PB_Any, Width, Height, 24)
    If tempImage
      If StartDrawing(ImageOutput(tempImage))
        DrawingFont(FontID(fontID))
        ReDim lines.s(0)
        lineCount = 0
        words.s = ReplaceString(Text, Chr(13) + Chr(10), " ")
        words = ReplaceString(words, Chr(13), " ")
        words = ReplaceString(words, Chr(10), " ")
        wordCount = CountString(words, " ") + 1
        currentLine.s = ""
        
        For i = 1 To wordCount
          testLine = currentLine
          If testLine <> ""
            testLine + " "
          EndIf
          testLine + StringField(words, i, " ")
          textWidth = TextWidth(testLine)
          If textWidth <= Width
            currentLine = testLine
          Else
            If currentLine <> ""
              ReDim lines.s(lineCount + 1)
              lines(lineCount) = currentLine
              lineCount + 1
            EndIf
            currentLine = StringField(words, i, " ")
          EndIf
        Next i
        
        If currentLine <> ""
          ReDim lines.s(lineCount + 1)
          lines(lineCount) = currentLine
          lineCount + 1
        EndIf
        
        lineHeight = TextHeight("A")
        maxLines = Height / lineHeight
        
        If lineCount > maxLines
          lineCount = maxLines
        EndIf
        StopDrawing()
      EndIf
      FreeImage(tempImage)
    EndIf
  EndIf
  
  tempImage = CreateImage(#PB_Any, Width, Height, 24)
  If tempImage
    If StartDrawing(ImageOutput(tempImage))
      Box(0, 0, Width, Height, RGB(0, 0, 0))
      DrawingFont(FontID(fontID))
      DrawingMode(#PB_2DDrawing_Transparent)
      Protected textColor = RGB(Red(Color), Green(Color), Blue(Color))
      currentY = 0
      For i = 0 To lineCount - 1
        If lines(i) <> ""
          DrawText(0, currentY, lines(i), textColor)
          currentY + lineHeight
        EndIf
      Next i
      StopDrawing()
      
      If StartDrawing(ImageOutput(tempImage))
        Protected sourceX, sourceY, pixelColor, r, g, b
        
        For sourceY = 0 To Height - 1
          For sourceX = 0 To Width - 1
            pixelColor = Point(sourceX, sourceY)
            If pixelColor <> 0
              r = Red(pixelColor)
              g = Green(pixelColor)
              b = Blue(pixelColor)
              WeAct_DrawPixelBuffer(x + sourceX, y + sourceY, RGBToRGB565(r, g, b))
            EndIf
          Next
        Next
        StopDrawing()
      EndIf
      FreeImage(tempImage)
    EndIf
  EndIf
EndProcedure

Procedure WeAct_DrawWrappedTextAutoSize(x, y, Width, Height, Text.s, Color, FontName.s = "Arial")
  WeAct_DrawWrappedText(x, y, Width, Height, Text, Color, 12, FontName, #True)
EndProcedure

Procedure WeAct_DrawWrappedTextFixed(x, y, Width, Height, Text.s, Color, FontSize.i = 12, FontName.s = "Arial")
  WeAct_DrawWrappedText(x, y, Width, Height, Text, Color, FontSize, FontName, #False)
EndProcedure

; =============================================
; { СКРОЛЛИНГ ТЕКСТА }
; =============================================

Procedure WeAct_StartScrollText(Text.s, FontSize.i = 12, Direction.i = #SCROLL_LEFT, Speed.i = 20, Color.i = #WEACT_WHITE, FontName.s = "Arial")
  ScrollText\Text = Text
  ScrollText\FontSize = FontSize
  ScrollText\Direction = Direction
  ScrollText\Speed = Speed
  ScrollText\Color = Color
  ScrollText\FontName = FontName
  ScrollText\Active = #True
  ScrollText\LastUpdate = ElapsedMilliseconds()
  
  Select Direction
    Case #SCROLL_LEFT
      ScrollText\Position = #WEACT_DISPLAY_WIDTH
    Case #SCROLL_RIGHT
      ScrollText\Position = -WeAct_GetTextWidth(Text, FontSize, FontName)
    Case #SCROLL_UP
      ScrollText\Position = #WEACT_DISPLAY_HEIGHT
    Case #SCROLL_DOWN
      ScrollText\Position = -WeAct_GetTextHeight(Text, FontSize, FontName)
  EndSelect
EndProcedure

Procedure WeAct_StopScrollText()
  ScrollText\Active = #False
EndProcedure

Procedure WeAct_UpdateScrollText()
  If Not ScrollText\Active
    ProcedureReturn
  EndIf
  
  Protected currentTime = ElapsedMilliseconds()
  Protected deltaTime = currentTime - ScrollText\LastUpdate
  Protected pixelsToMove.f
  
  If deltaTime <= 0
    ProcedureReturn
  EndIf
  
  pixelsToMove = ScrollText\Speed * (deltaTime / 1000.0)
  
  If pixelsToMove < 1.0
    ProcedureReturn
  EndIf
  
  Select ScrollText\Direction
    Case #SCROLL_LEFT
      ScrollText\Position - pixelsToMove
      If ScrollText\Position < -WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
        ScrollText\Position = #WEACT_DISPLAY_WIDTH
      EndIf
    Case #SCROLL_RIGHT
      ScrollText\Position + pixelsToMove
      If ScrollText\Position > #WEACT_DISPLAY_WIDTH
        ScrollText\Position = -WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
      EndIf
    Case #SCROLL_UP
      ScrollText\Position - pixelsToMove
      If ScrollText\Position < -WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
        ScrollText\Position = #WEACT_DISPLAY_HEIGHT
      EndIf
    Case #SCROLL_DOWN
      ScrollText\Position + pixelsToMove
      If ScrollText\Position > #WEACT_DISPLAY_HEIGHT
        ScrollText\Position = -WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
      EndIf
  EndSelect
  
  ScrollText\LastUpdate = currentTime
EndProcedure

Procedure WeAct_DrawScrollText()
  If Not ScrollText\Active
    ProcedureReturn
  EndIf
  
  Protected x, y
  
  Select ScrollText\Direction
    Case #SCROLL_LEFT, #SCROLL_RIGHT
      x = ScrollText\Position
      y = (#WEACT_DISPLAY_HEIGHT - WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)) / 2
    Case #SCROLL_UP, #SCROLL_DOWN
      x = (#WEACT_DISPLAY_WIDTH - WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)) / 2
      y = ScrollText\Position
  EndSelect
  
  WeAct_DrawTextSystemFont(x, y, ScrollText\Text, ScrollText\Color, ScrollText\FontSize, ScrollText\FontName)
EndProcedure

Procedure WeAct_ScrollTextLeft(Text.s, Speed.i = 20, FontSize.i = 12, Color.i = #WEACT_WHITE)
  WeAct_StartScrollText(Text, FontSize, #SCROLL_LEFT, Speed, Color)
EndProcedure

Procedure WeAct_ScrollTextRight(Text.s, Speed.i = 20, FontSize.i = 12, Color.i = #WEACT_WHITE)
  WeAct_StartScrollText(Text, FontSize, #SCROLL_RIGHT, Speed, Color)
EndProcedure

Procedure WeAct_ScrollTextUp(Text.s, Speed.i = 20, FontSize.i = 12, Color.i = #WEACT_WHITE)
  WeAct_StartScrollText(Text, FontSize, #SCROLL_UP, Speed, Color)
EndProcedure

Procedure WeAct_ScrollTextDown(Text.s, Speed.i = 20, FontSize.i = 12, Color.i = #WEACT_WHITE)
  WeAct_StartScrollText(Text, FontSize, #SCROLL_DOWN, Speed, Color)
EndProcedure

; =============================================
; { ЗАГРУЗКА ИЗОБРАЖЕНИЙ }
; =============================================

Procedure.s WeAct_GetSupportedImageFormats()
  ProcedureReturn "BMP, JPEG, PNG, TIFF, TGA"
EndProcedure

Procedure WeAct_LoadImageToBuffer(x, y, FileName.s, Width.i = -1, Height.i = -1)
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn #False : EndIf
  
  Protected originalImage, resizedImage
  Protected originalWidth, originalHeight
  Protected targetWidth, targetHeight
  Protected destX, destY, pixelColor, r, g, b
  
  If FileSize(FileName) <= 0
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    ProcedureReturn #False
  EndIf
  
  originalWidth = ImageWidth(originalImage)
  originalHeight = ImageHeight(originalImage)
  
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
  
  targetWidth = Int(targetWidth)
  targetHeight = Int(targetHeight)
  
  If targetWidth > #WEACT_DISPLAY_WIDTH
    targetWidth = #WEACT_DISPLAY_WIDTH
  EndIf
  If targetHeight > #WEACT_DISPLAY_HEIGHT
    targetHeight = #WEACT_DISPLAY_HEIGHT
  EndIf
  
  If x < 0 : x = 0 : EndIf
  If y < 0 : y = 0 : EndIf
  If x + targetWidth > #WEACT_DISPLAY_WIDTH
    x = #WEACT_DISPLAY_WIDTH - targetWidth
  EndIf
  If y + targetHeight > #WEACT_DISPLAY_HEIGHT
    y = #WEACT_DISPLAY_HEIGHT - targetHeight
  EndIf
  
  If targetWidth <= 0 Or targetHeight <= 0
    FreeImage(originalImage)
    ProcedureReturn #False
  EndIf
  
  resizedImage = CreateImage(#PB_Any, targetWidth, targetHeight)
  If Not resizedImage
    FreeImage(originalImage)
    ProcedureReturn #False
  EndIf
  
  If StartDrawing(ImageOutput(resizedImage))
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, targetWidth, targetHeight, RGB(0, 0, 0))
    DrawImage(ImageID(originalImage), 0, 0, targetWidth, targetHeight)
    StopDrawing()
  EndIf
  
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
  
  FreeImage(resizedImage)
  FreeImage(originalImage)
  ProcedureReturn #True
EndProcedure

Procedure WeAct_LoadImageFullScreen(FileName.s)
  Protected originalImage, targetWidth, targetHeight
  Protected scale.f, x, y
  
  If FileSize(FileName) <= 0
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    ProcedureReturn #False
  EndIf
  
  scale = #WEACT_DISPLAY_WIDTH / ImageWidth(originalImage)
  If (#WEACT_DISPLAY_HEIGHT / ImageHeight(originalImage)) < scale
    scale = #WEACT_DISPLAY_HEIGHT / ImageHeight(originalImage)
  EndIf
  
  targetWidth = ImageWidth(originalImage) * scale
  targetHeight = ImageHeight(originalImage) * scale
  
  x = (#WEACT_DISPLAY_WIDTH - targetWidth) / 2
  y = (#WEACT_DISPLAY_HEIGHT - targetHeight) / 2
  
  FreeImage(originalImage)
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

Procedure WeAct_LoadImageCentered(FileName.s, Width.i = -1, Height.i = -1)
  Protected originalImage, targetWidth, targetHeight
  Protected x, y
  
  If FileSize(FileName) <= 0
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
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
  
  x = (#WEACT_DISPLAY_WIDTH - targetWidth) / 2
  y = (#WEACT_DISPLAY_HEIGHT - targetHeight) / 2
  
  FreeImage(originalImage)
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

; =============================================
; { УПРАВЛЕНИЕ ДИСПЛЕЕМ }
; =============================================

Procedure WeAct_SetOrientation(Orientation)
  If Orientation >= 0 And Orientation <= 3
    ; Определяем новые размеры для ориентации
    Protected newWidth, newHeight
    
    Select Orientation
      Case #WEACT_PORTRAIT, #WEACT_REVERSE_PORTRAIT
        newWidth = 80   ; Портретные режимы: 80x160
        newHeight = 160
      Case #WEACT_LANDSCAPE, #WEACT_REVERSE_LANDSCAPE
        newWidth = 160  ; Альбомные режимы: 160x80  
        newHeight = 80
    EndSelect
    
    ; Отправляем команду смены ориентации на дисплей
    Dim Command.b(2)
    Command(0) = $02
    Command(1) = Orientation
    Command(2) = $0A
    
    If SendCommand(@Command(), 3)
      WeActDisplay\CurrentOrientation = Orientation
      Delay(100)
      
      ; Обновляем глобальные размеры
      WeAct_DisplayWidth = newWidth
      WeAct_DisplayHeight = newHeight
      WeAct_BufferSize = newWidth * newHeight * 2
      
      ; Пересоздаем буферы с новыми размерами
      If WeActDisplay\FrameBuffer
        FreeMemory(WeActDisplay\FrameBuffer)
      EndIf
      If WeActDisplay\BackBuffer
        FreeMemory(WeActDisplay\BackBuffer)
      EndIf
      
      WeActDisplay\FrameBuffer = AllocateMemory(WeAct_BufferSize)
      WeActDisplay\BackBuffer = AllocateMemory(WeAct_BufferSize)
      
      If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
        FillMemory(WeActDisplay\FrameBuffer, WeAct_BufferSize, 0)
        FillMemory(WeActDisplay\BackBuffer, WeAct_BufferSize, 0)
        ProcedureReturn #True
      Else
        WeActDisplay\IsConnected = #False
        ProcedureReturn #False
      EndIf
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

Procedure.i WeAct_GetDisplayWidth()
  ProcedureReturn WeAct_DisplayWidth
EndProcedure

Procedure.i WeAct_GetDisplayHeight()
  ProcedureReturn WeAct_DisplayHeight
EndProcedure

Procedure WeAct_CleanupFonts()
  ForEach FontCache()
    If FontCache()\FontID
      FreeFont(FontCache()\FontID)
    EndIf
  Next
  ClearMap(FontCache())
EndProcedure

; =============================================
; { ДЕСТРУКТОР }
; =============================================

Procedure WeAct_Cleanup()
  WeAct_CleanupFonts()
  WeAct_Close()
EndProcedure
