; =============================================
; WeAct Display FS Library for PureBasic
; Version 4.0 - Professional Edition
; 
; Supports WeAct Display FS 0.96-inch (160x80) via serial port
; 
; Features:
; - Fixed smooth scrolling (fractional pixel accumulation)
; - ROTATE mode support (auto-rotation)
; - New graphics functions (circles, progress bars, graphs)
; - Improved error handling with GetLastError()
; - Full Cyrillic support
; - Double buffering for smooth animation
; 
; GitHub: https://github.com/CheshirCa/WeActDisplay
; Protocol: v1.1
; Compatibility: PureBasic 6.20+
; =============================================

; { Device Constants }
#WEACT_DISPLAY_WIDTH = 160
#WEACT_DISPLAY_HEIGHT = 80
#WEACT_BAUDRATE = 115200
#WEACT_MAX_BUFFER_SIZE = 25600  ; 160*80*2 bytes (same for all orientations)

; { Orientation Constants - According to Protocol v1.1 }
Enumeration
  #WEACT_PORTRAIT = 0
  #WEACT_REVERSE_PORTRAIT = 1
  #WEACT_LANDSCAPE = 2
  #WEACT_REVERSE_LANDSCAPE = 3
  #WEACT_ROTATE = 5              ; Auto-rotation mode (NEW in v4.0!)
EndEnumeration

; { Scrolling Direction Constants }
Enumeration
  #SCROLL_LEFT = 0
  #SCROLL_RIGHT
  #SCROLL_UP
  #SCROLL_DOWN
EndEnumeration

; { Predefined Colors for BRG565 Format }
; Note: Display uses BRG565 (Blue-Red-Green) not RGB565
#WEACT_RED    = $07C0    ; BRG: 00000 11111 000000
#WEACT_GREEN  = $001F    ; BRG: 00000 00000 011111
#WEACT_BLUE   = $F800    ; BRG: 11111 00000 000000
#WEACT_WHITE  = $FFFF    ; BRG: 11111 11111 111111
#WEACT_BLACK  = $0000    ; BRG: 00000 00000 000000
#WEACT_YELLOW = $07FF    ; BRG: 00000 11111 111111
#WEACT_CYAN   = $F81F    ; BRG: 11111 00000 111111
#WEACT_MAGENTA = $FFE0   ; BRG: 11111 11111 000000

; { Data Structures }

; Main display structure
Structure WeActDisplay
  SerialPort.i              ; Serial port handle
  PortName.s                ; Port name (e.g., "COM3")
  IsConnected.i             ; Connection status flag
  CurrentOrientation.i      ; Current orientation mode
  CurrentBrightness.i       ; Current brightness level (0-255)
  DisplayWidth.i            ; Current display width (changes with orientation)
  DisplayHeight.i           ; Current display height (changes with orientation)
  BufferSize.i              ; Current buffer size in bytes
  *FrameBuffer              ; Pointer to frame buffer
  *BackBuffer               ; Pointer to back buffer (for double buffering)
  LastError.s               ; Last error message (for diagnostics)
EndStructure

; Font cache structure for performance optimization
Structure FontCache
  FontID.i                  ; Font handle
  Size.i                    ; Font size in pixels
  Name.s                    ; Font name
EndStructure

; Scrolling text structure
; FIXED in v4.0: Added fractional pixel accumulation for smooth scrolling
Structure ScrollText
  Text.s                    ; Text to scroll
  FontSize.i                ; Font size in pixels
  Direction.i               ; Scroll direction (LEFT, RIGHT, UP, DOWN)
  Speed.f                   ; FIXED: Speed in pixels per second (now float for precision)
  Position.f                ; FIXED: Current position (now float for smooth movement)
  Color.i                   ; Text color in BRG565 format
  FontName.s                ; Font name
  Active.i                  ; Is scrolling active?
  LastUpdate.i              ; Last update timestamp (milliseconds)
  AccumulatedPixels.f       ; NEW: Accumulated fractional pixels (prevents jerking)
EndStructure

; { Global Variables }
Global WeActDisplay.WeActDisplay
Global NewMap FontCache.FontCache()
Global ScrollText.ScrollText

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
    Protected Result = WriteSerialPortData(WeActDisplay\SerialPort, *Data, Length)
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
                                          #PB_SerialPort_NoHandshake, 2048, 2048)
  
  If WeActDisplay\SerialPort
    WeActDisplay\PortName = PortName
    WeActDisplay\IsConnected = #True
    WeActDisplay\CurrentOrientation = #WEACT_LANDSCAPE
    WeActDisplay\CurrentBrightness = 255
    WeActDisplay\DisplayWidth = #WEACT_DISPLAY_WIDTH
    WeActDisplay\DisplayHeight = #WEACT_DISPLAY_HEIGHT
    WeActDisplay\BufferSize = #WEACT_MAX_BUFFER_SIZE
    
    ; Выделяем буферы фиксированного размера
    WeActDisplay\FrameBuffer = AllocateMemory(#WEACT_MAX_BUFFER_SIZE)
    WeActDisplay\BackBuffer = AllocateMemory(#WEACT_MAX_BUFFER_SIZE)
    
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      FillMemory(WeActDisplay\FrameBuffer, #WEACT_MAX_BUFFER_SIZE, 0)
      FillMemory(WeActDisplay\BackBuffer, #WEACT_MAX_BUFFER_SIZE, 0)
      
      WeAct_InitImageDecoders()
      WeAct_SetOrientation(#WEACT_LANDSCAPE)
      Delay(500)
      
      WeActDisplay\LastError = ""
      ProcedureReturn #True
    Else
      WeActDisplay\IsConnected = #False
      WeActDisplay\LastError = "Failed to allocate memory buffers"
      ProcedureReturn #False
    EndIf
  Else
    WeActDisplay\IsConnected = #False
    WeActDisplay\LastError = "Failed to open serial port " + PortName
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
  Protected color_l = Color >> 8
  Protected color_h = Color & $FF
  Protected pixelCount = WeActDisplay\DisplayWidth * WeActDisplay\DisplayHeight
  
  For i = 0 To pixelCount - 1
    PokeA(*ptr + i * 2, color_l)
    PokeA(*ptr + i * 2 + 1, color_h)
  Next
EndProcedure

Procedure WeAct_DrawPixelBuffer(x, y, Color)
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  If x < 0 Or x >= WeActDisplay\DisplayWidth Or y < 0 Or y >= WeActDisplay\DisplayHeight
    ProcedureReturn
  EndIf
  
  Protected offset = (y * WeActDisplay\DisplayWidth + x) * 2
  Protected *ptr = WeActDisplay\BackBuffer + offset
  PokeA(*ptr, Color >> 8)
  PokeA(*ptr + 1, Color & $FF)
EndProcedure

Procedure WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, Filled = #True)
  Protected xx, yy
  
  If Filled
    For yy = y To y + Height - 1
      If yy >= 0 And yy < WeActDisplay\DisplayHeight
        For xx = x To x + Width - 1
          If xx >= 0 And xx < WeActDisplay\DisplayWidth
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

; НОВОЕ: Рисование окружности
Procedure WeAct_DrawCircleBuffer(cx, cy, radius, Color, Filled = #False)
  Protected x, y, d
  
  If Filled
    ; Заполненная окружность
    For y = -radius To radius
      For x = -radius To radius
        If x * x + y * y <= radius * radius
          WeAct_DrawPixelBuffer(cx + x, cy + y, Color)
        EndIf
      Next
    Next
  Else
    ; Контур окружности (алгоритм Брезенхэма)
    x = 0
    y = radius
    d = 3 - 2 * radius
    
    While x <= y
      WeAct_DrawPixelBuffer(cx + x, cy + y, Color)
      WeAct_DrawPixelBuffer(cx - x, cy + y, Color)
      WeAct_DrawPixelBuffer(cx + x, cy - y, Color)
      WeAct_DrawPixelBuffer(cx - x, cy - y, Color)
      WeAct_DrawPixelBuffer(cx + y, cy + x, Color)
      WeAct_DrawPixelBuffer(cx - y, cy + x, Color)
      WeAct_DrawPixelBuffer(cx + y, cy - x, Color)
      WeAct_DrawPixelBuffer(cx - y, cy - x, Color)
      
      If d < 0
        d = d + 4 * x + 6
      Else
        d = d + 4 * (x - y) + 10
        y - 1
      EndIf
      x + 1
    Wend
  EndIf
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
  
  Protected x_end = WeActDisplay\DisplayWidth - 1
  Command(5) = x_end & $FF
  Command(6) = (x_end >> 8) & $FF
  
  Protected y_end = WeActDisplay\DisplayHeight - 1
  Command(7) = y_end & $FF
  Command(8) = (y_end >> 8) & $FF
  
  Command(9) = $0A
  
  If WriteSerialPortData(WeActDisplay\SerialPort, @Command(), 10)
    Delay(10)
    Protected bytesToSend = WeActDisplay\DisplayWidth * WeActDisplay\DisplayHeight * 2
    If WriteSerialPortData(WeActDisplay\SerialPort, WeActDisplay\BackBuffer, bytesToSend)
      Delay(10)
      ProcedureReturn #True
    EndIf
  EndIf
  
  WeActDisplay\LastError = "Failed to flush buffer to display"
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
  Protected maxWidth = WeActDisplay\DisplayWidth
  Protected maxHeight = WeActDisplay\DisplayHeight
  
  tempImage = CreateImage(#PB_Any, maxWidth, maxHeight, 24, #Black)
  If tempImage
    If StartDrawing(ImageOutput(tempImage))
      DrawingFont(FontID(fontID))
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(x, y, Text, RGB(255, 255, 255))
      StopDrawing()
      
      ; Копируем пиксели текста на дисплей
      If StartDrawing(ImageOutput(tempImage))
        Protected sourceX, sourceY, pixelColor, brightness
        
        For sourceY = 0 To maxHeight - 1
          For sourceX = 0 To maxWidth - 1
            pixelColor = Point(sourceX, sourceY)
            brightness = Red(pixelColor)
            
            If brightness > 30
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
      Protected textColor = RGB(255, 255, 255)
      currentY = 0
      For i = 0 To lineCount - 1
        If lines(i) <> ""
          DrawText(0, currentY, lines(i), textColor)
          currentY + lineHeight
        EndIf
      Next i
      StopDrawing()
      
      If StartDrawing(ImageOutput(tempImage))
        Protected sourceX, sourceY, pixelColor, brightness
        
        For sourceY = 0 To Height - 1
          For sourceX = 0 To Width - 1
            pixelColor = Point(sourceX, sourceY)
            brightness = Red(pixelColor)
            If brightness > 30
              WeAct_DrawPixelBuffer(x + sourceX, y + sourceY, Color)
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
; { СКРОЛЛИНГ ТЕКСТА - ИСПРАВЛЕНО }
; =============================================

Procedure WeAct_StartScrollText(Text.s, FontSize.i = 12, Direction.i = #SCROLL_LEFT, Speed.f = 20.0, Color.i = #WEACT_WHITE, FontName.s = "Arial")
  ScrollText\Text = Text
  ScrollText\FontSize = FontSize
  ScrollText\Direction = Direction
  ScrollText\Speed = Speed
  ScrollText\Color = Color
  ScrollText\FontName = FontName
  ScrollText\Active = #True
  ScrollText\LastUpdate = ElapsedMilliseconds()
  ScrollText\AccumulatedPixels = 0.0
  
  Select Direction
    Case #SCROLL_LEFT
      ScrollText\Position = WeActDisplay\DisplayWidth
    Case #SCROLL_RIGHT
      ScrollText\Position = -WeAct_GetTextWidth(Text, FontSize, FontName)
    Case #SCROLL_UP
      ScrollText\Position = WeActDisplay\DisplayHeight
    Case #SCROLL_DOWN
      ScrollText\Position = -WeAct_GetTextHeight(Text, FontSize, FontName)
  EndSelect
EndProcedure

Procedure WeAct_StopScrollText()
  ScrollText\Active = #False
EndProcedure

; ИСПРАВЛЕНО: Улучшенный алгоритм скроллинга с накоплением дробных пикселей
Procedure WeAct_UpdateScrollText()
  If Not ScrollText\Active
    ProcedureReturn
  EndIf
  
  Protected currentTime = ElapsedMilliseconds()
  Protected deltaTime = currentTime - ScrollText\LastUpdate
  
  If deltaTime <= 0
    ProcedureReturn
  EndIf
  
  ; Вычисляем сколько пикселей переместить с учетом времени
  Protected pixelsToMove.f = ScrollText\Speed * (deltaTime / 1000.0)
  
  ; Накапливаем дробные пиксели
  ScrollText\AccumulatedPixels + pixelsToMove
  
  ; Перемещаем только целые пиксели
  Protected intPixelsToMove.i = Int(ScrollText\AccumulatedPixels)
  
  If intPixelsToMove >= 1
    ScrollText\AccumulatedPixels - intPixelsToMove
    
    Select ScrollText\Direction
      Case #SCROLL_LEFT
        ScrollText\Position - intPixelsToMove
        If ScrollText\Position < -WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
          ScrollText\Position = WeActDisplay\DisplayWidth
        EndIf
        
      Case #SCROLL_RIGHT
        ScrollText\Position + intPixelsToMove
        If ScrollText\Position > WeActDisplay\DisplayWidth
          ScrollText\Position = -WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
        EndIf
        
      Case #SCROLL_UP
        ScrollText\Position - intPixelsToMove
        If ScrollText\Position < -WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
          ScrollText\Position = WeActDisplay\DisplayHeight
        EndIf
        
      Case #SCROLL_DOWN
        ScrollText\Position + intPixelsToMove
        If ScrollText\Position > WeActDisplay\DisplayHeight
          ScrollText\Position = -WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
        EndIf
    EndSelect
  EndIf
  
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
      y = (WeActDisplay\DisplayHeight - WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)) / 2
    Case #SCROLL_UP, #SCROLL_DOWN
      x = (WeActDisplay\DisplayWidth - WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)) / 2
      y = ScrollText\Position
  EndSelect
  
  WeAct_DrawTextSystemFont(x, y, ScrollText\Text, ScrollText\Color, ScrollText\FontSize, ScrollText\FontName)
EndProcedure

Procedure WeAct_ScrollTextLeft(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
  WeAct_StartScrollText(Text, FontSize, #SCROLL_LEFT, Speed, Color)
EndProcedure

Procedure WeAct_ScrollTextRight(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
  WeAct_StartScrollText(Text, FontSize, #SCROLL_RIGHT, Speed, Color)
EndProcedure

Procedure WeAct_ScrollTextUp(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
  WeAct_StartScrollText(Text, FontSize, #SCROLL_UP, Speed, Color)
EndProcedure

Procedure WeAct_ScrollTextDown(Text.s, Speed.f = 20.0, FontSize.i = 12, Color.i = #WEACT_WHITE)
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
    WeActDisplay\LastError = "Image file not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    WeActDisplay\LastError = "Failed to load image: " + FileName
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
  
  If targetWidth > WeActDisplay\DisplayWidth
    targetWidth = WeActDisplay\DisplayWidth
  EndIf
  If targetHeight > WeActDisplay\DisplayHeight
    targetHeight = WeActDisplay\DisplayHeight
  EndIf
  
  If x < 0 : x = 0 : EndIf
  If y < 0 : y = 0 : EndIf
  If x + targetWidth > WeActDisplay\DisplayWidth
    x = WeActDisplay\DisplayWidth - targetWidth
  EndIf
  If y + targetHeight > WeActDisplay\DisplayHeight
    y = WeActDisplay\DisplayHeight - targetHeight
  EndIf
  
  If targetWidth <= 0 Or targetHeight <= 0
    FreeImage(originalImage)
    WeActDisplay\LastError = "Invalid image dimensions"
    ProcedureReturn #False
  EndIf
  
  resizedImage = CreateImage(#PB_Any, targetWidth, targetHeight)
  If Not resizedImage
    FreeImage(originalImage)
    WeActDisplay\LastError = "Failed to create resized image"
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
    WeActDisplay\LastError = "Image file not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    WeActDisplay\LastError = "Failed to load image: " + FileName
    ProcedureReturn #False
  EndIf
  
  scale = WeActDisplay\DisplayWidth / ImageWidth(originalImage)
  If (WeActDisplay\DisplayHeight / ImageHeight(originalImage)) < scale
    scale = WeActDisplay\DisplayHeight / ImageHeight(originalImage)
  EndIf
  
  targetWidth = ImageWidth(originalImage) * scale
  targetHeight = ImageHeight(originalImage) * scale
  
  x = (WeActDisplay\DisplayWidth - targetWidth) / 2
  y = (WeActDisplay\DisplayHeight - targetHeight) / 2
  
  FreeImage(originalImage)
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

Procedure WeAct_LoadImageCentered(FileName.s, Width.i = -1, Height.i = -1)
  Protected originalImage, targetWidth, targetHeight
  Protected x, y
  
  If FileSize(FileName) <= 0
    WeActDisplay\LastError = "Image file not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    WeActDisplay\LastError = "Failed to load image: " + FileName
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
  
  x = (WeActDisplay\DisplayWidth - targetWidth) / 2
  y = (WeActDisplay\DisplayHeight - targetHeight) / 2
  
  FreeImage(originalImage)
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

; =============================================
; { УПРАВЛЕНИЕ ДИСПЛЕЕМ - ИСПРАВЛЕНО }
; =============================================

; ИСПРАВЛЕНО: Корректная работа с ориентацией согласно протоколу
Procedure WeAct_SetOrientation(Orientation)
  If Orientation < 0 Or (Orientation > 3 And Orientation <> 5)
    WeActDisplay\LastError = "Invalid orientation value. Use 0-3 or 5 for ROTATE"
    ProcedureReturn #False
  EndIf
  
  ; Определяем новые размеры для ориентации
  Protected newWidth, newHeight
  
  Select Orientation
    Case #WEACT_PORTRAIT, #WEACT_REVERSE_PORTRAIT
      newWidth = 80
      newHeight = 160
      
    Case #WEACT_LANDSCAPE, #WEACT_REVERSE_LANDSCAPE
      newWidth = 160
      newHeight = 80
      
    Case #WEACT_ROTATE
      ; Автоповорот - размеры не меняются, используем текущие
      newWidth = WeActDisplay\DisplayWidth
      newHeight = WeActDisplay\DisplayHeight
  EndSelect
  
  ; Отправляем команду смены ориентации на дисплей
  Dim Command.b(2)
  Command(0) = $02
  Command(1) = Orientation
  Command(2) = $0A
  
  If SendCommand(@Command(), 3)
    WeActDisplay\CurrentOrientation = Orientation
    Delay(100)
    
    ; Обновляем размеры дисплея
    WeActDisplay\DisplayWidth = newWidth
    WeActDisplay\DisplayHeight = newHeight
    WeActDisplay\BufferSize = newWidth * newHeight * 2
    
    ; Очищаем буферы после смены ориентации
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      FillMemory(WeActDisplay\FrameBuffer, #WEACT_MAX_BUFFER_SIZE, 0)
      FillMemory(WeActDisplay\BackBuffer, #WEACT_MAX_BUFFER_SIZE, 0)
      ProcedureReturn #True
    Else
      WeActDisplay\LastError = "Buffer memory not allocated"
      ProcedureReturn #False
    EndIf
  Else
    WeActDisplay\LastError = "Failed to send orientation command"
    ProcedureReturn #False
  EndIf
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
  
  WeActDisplay\LastError = "Failed to set brightness"
  ProcedureReturn #False
EndProcedure

Procedure WeAct_SystemReset()
  Dim Command.b(1)
  Command(0) = $40
  Command(1) = $0A
  
  If SendCommand(@Command(), 2)
    Delay(1000)  ; Ждем завершения сброса
    ProcedureReturn #True
  EndIf
  
  WeActDisplay\LastError = "Failed to reset system"
  ProcedureReturn #False
EndProcedure

; НОВОЕ: Заполнение экрана сплошным цветом (команда FULL из протокола)
Procedure WeAct_FillScreen(Color)
  If Not WeActDisplay\IsConnected
    WeActDisplay\LastError = "Display not connected"
    ProcedureReturn #False
  EndIf
  
  Dim Command.b(11)
  Command(0) = $04  ; FULL команда
  
  ; Начальные координаты (0, 0)
  Command(1) = 0
  Command(2) = 0
  Command(3) = 0
  Command(4) = 0
  
  ; Конечные координаты (width-1, height-1)
  Protected x_end = WeActDisplay\DisplayWidth - 1
  Command(5) = x_end & $FF
  Command(6) = (x_end >> 8) & $FF
  
  Protected y_end = WeActDisplay\DisplayHeight - 1
  Command(7) = y_end & $FF
  Command(8) = (y_end >> 8) & $FF
  
  ; Цвет в формате RGB565
  Command(9) = Color & $FF
  Command(10) = (Color >> 8) & $FF
  
  Command(11) = $0A
  
  If SendCommand(@Command(), 12)
    Delay(50)
    ProcedureReturn #True
  EndIf
  
  WeActDisplay\LastError = "Failed to fill screen"
  ProcedureReturn #False
EndProcedure

; =============================================
; { ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ }
; =============================================

Procedure.s WeAct_GetInfo()
  If WeActDisplay\IsConnected
    ProcedureReturn "WeAct Display FS 0.96-inch (" + WeActDisplay\PortName + ") " + 
                    Str(WeActDisplay\DisplayWidth) + "x" + Str(WeActDisplay\DisplayHeight)
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
  ProcedureReturn WeActDisplay\DisplayWidth
EndProcedure

Procedure.i WeAct_GetDisplayHeight()
  ProcedureReturn WeActDisplay\DisplayHeight
EndProcedure

Procedure.s WeAct_GetLastError()
  ProcedureReturn WeActDisplay\LastError
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
; { НОВЫЕ ФУНКЦИИ }
; =============================================

; НОВОЕ: Рисование прогресс-бара
Procedure WeAct_DrawProgressBar(x, y, Width, Height, Progress.f, ForeColor = #WEACT_GREEN, BackColor = #WEACT_BLACK, BorderColor = #WEACT_WHITE)
  If Progress < 0.0 : Progress = 0.0 : EndIf
  If Progress > 1.0 : Progress = 1.0 : EndIf
  
  ; Рисуем фон
  WeAct_DrawRectangleBuffer(x, y, Width, Height, BackColor, #True)
  
  ; Рисуем заполненную часть
  Protected fillWidth = Int(Width * Progress)
  If fillWidth > 0
    WeAct_DrawRectangleBuffer(x, y, fillWidth, Height, ForeColor, #True)
  EndIf
  
  ; Рисуем рамку
  WeAct_DrawRectangleBuffer(x, y, Width, Height, BorderColor, #False)
EndProcedure

; НОВОЕ: Рисование графика
Procedure WeAct_DrawGraph(x, y, Width, Height, *Data.Float, DataCount, MinValue.f, MaxValue.f, Color = #WEACT_WHITE, BackColor = #WEACT_BLACK)
  If DataCount < 2 Or Not *Data
    ProcedureReturn
  EndIf
  
  ; Очищаем область графика
  WeAct_DrawRectangleBuffer(x, y, Width, Height, BackColor, #True)
  
  ; Рисуем рамку
  WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, #False)
  
  Protected range.f = MaxValue - MinValue
  If range = 0.0 : range = 1.0 : EndIf
  
  Protected i, x1, y1, x2, y2
  Protected stepX.f = Width / (DataCount - 1)
  
  For i = 0 To DataCount - 2
    ; Вычисляем координаты точек
    Protected value1.f = PeekF(*Data + i * SizeOf(Float))
    Protected value2.f = PeekF(*Data + (i + 1) * SizeOf(Float))
    
    x1 = x + Int(i * stepX)
    y1 = y + Height - Int((value1 - MinValue) / range * Height)
    
    x2 = x + Int((i + 1) * stepX)
    y2 = y + Height - Int((value2 - MinValue) / range * Height)
    
    ; Рисуем линию между точками
    WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
  Next
EndProcedure

; НОВОЕ: Вывод большого текста из файла с прокруткой
Procedure WeAct_ShowTextFile(FileName.s, FontSize = 10, Color = #WEACT_WHITE, ScrollSpeed.f = 30.0)
  If FileSize(FileName) <= 0
    WeActDisplay\LastError = "File not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  Protected file = ReadFile(#PB_Any, FileName)
  If Not file
    WeActDisplay\LastError = "Failed to open file: " + FileName
    ProcedureReturn #False
  EndIf
  
  Protected content.s = ReadString(file, #PB_File_IgnoreEOL)
  CloseFile(file)
  
  ; Запускаем вертикальный скроллинг
  WeAct_StartScrollText(content, FontSize, #SCROLL_UP, ScrollSpeed, Color)
  
  ProcedureReturn #True
EndProcedure

; НОВОЕ: Отображение времени в большом формате
Procedure WeAct_ShowTime(x, y, Hour, Minute, Color = #WEACT_WHITE, FontSize = 16)
  Protected timeText.s = RSet(Str(Hour), 2, "0") + ":" + RSet(Str(Minute), 2, "0")
  WeAct_DrawTextSystemFont(x, y, timeText, Color, FontSize, "Arial")
EndProcedure

; НОВОЕ: Отображение даты
Procedure WeAct_ShowDate(x, y, Day, Month, Year, Color = #WEACT_WHITE, FontSize = 10)
  Protected dateText.s = RSet(Str(Day), 2, "0") + "." + RSet(Str(Month), 2, "0") + "." + Str(Year)
  WeAct_DrawTextSystemFont(x, y, dateText, Color, FontSize, "Arial")
EndProcedure

; НОВОЕ: Индикатор загрузки (спиннер)
Procedure WeAct_DrawSpinner(cx, cy, radius, angle.f, Color = #WEACT_WHITE)
  ; Рисуем круговой индикатор загрузки
  Protected segments = 8
  Protected i, x1, y1, x2, y2
  Protected angleStep.f = 360.0 / segments
  
  For i = 0 To segments - 1
    Protected currentAngle.f = angle + i * angleStep
    Protected alpha.f = 1.0 - (i / segments)
    
    If alpha > 0.3
      x1 = cx + Cos(Radian(currentAngle)) * radius * 0.5
      y1 = cy + Sin(Radian(currentAngle)) * radius * 0.5
      x2 = cx + Cos(Radian(currentAngle)) * radius
      y2 = cy + Sin(Radian(currentAngle)) * radius
      
      WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
    EndIf
  Next
EndProcedure

; =============================================
; { ДЕСТРУКТОР }
; =============================================

Procedure WeAct_Cleanup()
  WeAct_CleanupFonts()
  WeAct_Close()
EndProcedure

; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 1172
; FirstLine = 1168
; Folding = ----------
; EnableXP
