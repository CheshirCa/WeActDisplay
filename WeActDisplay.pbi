; WeAct Display FS Library for PureBasic
; Supports WeAct Display FS 0.96-inch (160x80) via serial port
; GitHub: https://github.com/CheshirCa/WeActDisplay
; Compatibility: PureBasic 6.20+

; Display physical dimensions
#WEACT_DISPLAY_WIDTH = 160
#WEACT_DISPLAY_HEIGHT = 80
#WEACT_BAUDRATE = 115200
; Maximum buffer size for double buffering (160*80*2 bytes = 25600)
#WEACT_MAX_BUFFER_SIZE = 25600

; Display orientation modes (as defined in the device protocol)
Enumeration
  #WEACT_PORTRAIT = 0             ; Portrait mode (80x160)
  #WEACT_REVERSE_PORTRAIT = 1     ; Portrait mode rotated 180 degrees
  #WEACT_LANDSCAPE = 2            ; Landscape mode (160x80) - default
  #WEACT_REVERSE_LANDSCAPE = 3    ; Landscape mode rotated 180 degrees
  #WEACT_ROTATE = 5               ; Auto-rotation mode (hardware feature)
EndEnumeration

; Text scrolling directions
Enumeration
  #SCROLL_LEFT = 0
  #SCROLL_RIGHT
  #SCROLL_UP
  #SCROLL_DOWN
EndEnumeration

; Predefined colors in BRG565 format
; Note: The display uses BRG565 (Blue-Red-Green) instead of RGB565
; Each color is 16-bit: 5 bits for blue, 6 bits for red, 5 bits for green
#WEACT_RED    = $F800    ; Binary: 11111 00000 00000
#WEACT_GREEN  = $07E0    ; Binary: 00000 111111 00000  
#WEACT_BLUE   = $001F    ; Binary: 00000 00000 11111
#WEACT_WHITE  = $FFFF    ; Binary: 11111 11111 11111
#WEACT_BLACK  = $0000    ; Binary: 00000 00000 00000
#WEACT_YELLOW = $FFE0    ; Binary: 11111 11111 00000
#WEACT_CYAN   = $07FF    ; Binary: 00000 11111 11111
#WEACT_MAGENTA = $F81F   ; Binary: 11111 00000 11111

Structure WeActDisplay
  SerialPort.i              ; Handle for the serial port connection
  PortName.s                ; Name of the serial port (e.g., "COM3")
  IsConnected.i             ; Flag: 1 if connected, 0 if not
  CurrentOrientation.i      ; Current display orientation mode
  CurrentBrightness.i       ; Brightness level (0-255, where 255 is max)
  DisplayWidth.i            ; Current display width (depends on orientation)
  DisplayHeight.i           ; Current display height (depends on orientation)
  BufferSize.i              ; Size of frame buffer in bytes
  *FrameBuffer              ; Pointer to the front buffer (displayed content)
  *BackBuffer               ; Pointer to the back buffer (drawing canvas for double buffering)
  LastError.s               ; Last error message for debugging
EndStructure

; Font cache structure to improve performance by reusing loaded fonts
Structure FontCache
  FontID.i                  ; PureBasic font handle
  Size.i                    ; Font size in pixels
  Name.s                    ; Font name
EndStructure

; Text scrolling structure with smooth scrolling support
Structure ScrollText
  Text.s                    ; Text string to scroll
  FontSize.i                ; Font size in pixels
  Direction.i               ; Scroll direction (#SCROLL_LEFT, #SCROLL_RIGHT, etc.)
  Speed.f                   ; Scroll speed in pixels per second (floating point for precision)
  Position.f                ; Current text position (floating point for smooth movement)
  Color.i                   ; Text color in BRG565 format
  FontName.s                ; Name of the font to use
  Active.i                  ; Flag: 1 if scrolling is active, 0 if not
  LastUpdate.i              ; Timestamp of last update (in milliseconds)
  AccumulatedPixels.f       ; Accumulated fractional pixels for smooth scrolling
EndStructure

; Global variables for display state, font cache, and scrolling text
Global WeActDisplay.WeActDisplay
Global NewMap FontCache.FontCache()
Global ScrollText.ScrollText

Declare WeAct_SetOrientation(Orientation)

; { BASE FUNCTIONS }

Procedure.i RGBToRGB565_Fixed(r, g, b)
  ; Normalize input values to 8-bit range (0-255)
  r = r & $FF
  g = g & $FF  
  b = b & $FF
  
  ; Convert 8-bit values to 5-6-5 bit format for RGB565:
  ; - Right shift by 3 to reduce 8 bits to 5 bits (for red and blue)
  ; - Right shift by 2 to reduce 8 bits to 6 bits (for green - more bits for better color accuracy)
  Protected r5 = (r >> 3) & $1F    ; 5-bit red component
  Protected g6 = (g >> 2) & $3F    ; 6-bit green component
  Protected b5 = (b >> 3) & $1F    ; 5-bit blue component
  
  ; Pack bits into 16-bit RGB565 format:
  ; Bits 15-11: Red (5 bits), Bits 10-5: Green (6 bits), Bits 4-0: Blue (5 bits)
  Protected rgb565 = (r5 << 11) | (g6 << 5) | b5
  
  ProcedureReturn rgb565
EndProcedure

; Macro to provide backward compatibility with old function name
; Note: Despite the name, this actually converts to RGB565, not BRG565
; The display hardware expects BRG565 but stores it in RGB565 format
Macro RGBToRGB565(r, g, b)
  RGBToRGB565_Fixed(r, g, b)
EndMacro

Procedure SendCommand(*Data, Length)
  ; Send raw command data to the display over serial connection
  If WeActDisplay\IsConnected
    Protected Result = WriteSerialPortData(WeActDisplay\SerialPort, *Data, Length)
    Delay(5)  ; Small delay to ensure command is processed
    ProcedureReturn Result
  EndIf
  ProcedureReturn #False
EndProcedure

; { INITIALIZATION AND CLEANUP }

Procedure WeAct_InitImageDecoders()
  ; Initialize PureBasic's built-in image decoders for various formats
  UseJPEGImageDecoder()
  UsePNGImageDecoder()
  UseTIFFImageDecoder()
  UseTGAImageDecoder()
EndProcedure

Procedure WeAct_Init(PortName.s = "COM3")
  ; Initialize connection to the WeAct display
  ; PortName: Serial port name (e.g., "COM3" on Windows, "/dev/ttyUSB0" on Linux)
  
  ; Open serial port with specified parameters:
  ; - Baud rate: 115200 (standard for WeAct display)
  ; - No parity, 8 data bits, 1 stop bit, no hardware handshake
  ; - Input/output buffer size: 2048 bytes each
  WeActDisplay\SerialPort = OpenSerialPort(#PB_Any, PortName, #WEACT_BAUDRATE, 
                                          #PB_SerialPort_NoParity, 8, 1, 
                                          #PB_SerialPort_NoHandshake, 2048, 2048)
  
  If WeActDisplay\SerialPort
    ; Store connection parameters
    WeActDisplay\PortName = PortName
    WeActDisplay\IsConnected = #True
    WeActDisplay\CurrentOrientation = #WEACT_LANDSCAPE
    WeActDisplay\CurrentBrightness = 255
    WeActDisplay\DisplayWidth = #WEACT_DISPLAY_WIDTH
    WeActDisplay\DisplayHeight = #WEACT_DISPLAY_HEIGHT
    WeActDisplay\BufferSize = #WEACT_MAX_BUFFER_SIZE
    
    ; Allocate memory for double buffering
    ; Front buffer: currently displayed frame
    ; Back buffer: frame being prepared for next display update
    WeActDisplay\FrameBuffer = AllocateMemory(#WEACT_MAX_BUFFER_SIZE)
    WeActDisplay\BackBuffer = AllocateMemory(#WEACT_MAX_BUFFER_SIZE)
    
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      ; Clear both buffers to black
      FillMemory(WeActDisplay\FrameBuffer, #WEACT_MAX_BUFFER_SIZE, 0)
      FillMemory(WeActDisplay\BackBuffer, #WEACT_MAX_BUFFER_SIZE, 0)
      
      ; Initialize image decoders and set default orientation
      WeAct_InitImageDecoders()
      WeAct_SetOrientation(#WEACT_LANDSCAPE)
      Delay(500)  ; Wait for display to initialize
      
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
  ; Close connection to display and free allocated resources
  If WeActDisplay\IsConnected
    CloseSerialPort(WeActDisplay\SerialPort)
    WeActDisplay\IsConnected = #False
  EndIf
  
  ; Safely free allocated memory buffers
  If WeActDisplay\FrameBuffer
    FreeMemory(WeActDisplay\FrameBuffer)
    WeActDisplay\FrameBuffer = 0
  EndIf
  If WeActDisplay\BackBuffer
    FreeMemory(WeActDisplay\BackBuffer)
    WeActDisplay\BackBuffer = 0
  EndIf
EndProcedure

; { BUFFER MANAGEMENT FUNCTIONS }

Procedure WeAct_SwapBuffers()
  ; Swap front and back buffers for double buffering
  ; This prevents screen tearing by only displaying complete frames
  Protected *temp = WeActDisplay\FrameBuffer
  WeActDisplay\FrameBuffer = WeActDisplay\BackBuffer
  WeActDisplay\BackBuffer = *temp
EndProcedure

Procedure WeAct_ClearBuffer(Color = #WEACT_BLACK)
  ; Clear the back buffer with specified color
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  
  Protected i
  Protected *ptr = WeActDisplay\BackBuffer
  ; Split 16-bit color into two 8-bit parts for faster filling
  Protected color_l = Color >> 8      ; High byte of color
  Protected color_h = Color & $FF     ; Low byte of color
  Protected pixelCount = WeActDisplay\DisplayWidth * WeActDisplay\DisplayHeight
  
  ; Fill buffer with color (each pixel = 2 bytes)
  For i = 0 To pixelCount - 1
    PokeA(*ptr + i * 2, color_l)      ; Write high byte
    PokeA(*ptr + i * 2 + 1, color_h)  ; Write low byte
  Next
EndProcedure

Procedure WeAct_DrawPixelBuffer(x, y, Color)
  ; Draw a single pixel to the back buffer at specified coordinates
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  ; Check if coordinates are within display bounds
  If x < 0 Or x >= WeActDisplay\DisplayWidth Or y < 0 Or y >= WeActDisplay\DisplayHeight
    ProcedureReturn
  EndIf
  
  ; Calculate memory offset: (y * width + x) * 2 bytes per pixel
  Protected offset = (y * WeActDisplay\DisplayWidth + x) * 2
  Protected *ptr = WeActDisplay\BackBuffer + offset
  
  ; Store color in little-endian format (low byte first)
  PokeA(*ptr, Color & $FF)      ; Low byte (green/blue part)
  PokeA(*ptr + 1, Color >> 8)   ; High byte (red part)
EndProcedure

Procedure WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, Filled = #True)
  ; Draw rectangle to back buffer
  ; x, y: Top-left corner coordinates
  ; Width, Height: Rectangle dimensions
  ; Color: BRG565 color value
  ; Filled: #True for filled rectangle, #False for outline only
  Protected xx, yy
  
  If Filled
    ; Draw filled rectangle
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
    ; Draw rectangle outline
    ; Top and bottom edges
    For xx = x To x + Width - 1
      WeAct_DrawPixelBuffer(xx, y, Color)
      WeAct_DrawPixelBuffer(xx, y + Height - 1, Color)
    Next
    ; Left and right edges
    For yy = y To y + Height - 1
      WeAct_DrawPixelBuffer(x, yy, Color)
      WeAct_DrawPixelBuffer(x + Width - 1, yy, Color)
    Next
  EndIf
EndProcedure

Procedure WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
  ; Draw line using Bresenham's line algorithm
  ; This algorithm only uses integer arithmetic for efficiency
  Protected dx = Abs(x2 - x1)  ; Horizontal distance
  Protected dy = Abs(y2 - y1)  ; Vertical distance
  Protected sx = 1 : If x1 > x2 : sx = -1 : EndIf  ; X direction step
  Protected sy = 1 : If y1 > y2 : sy = -1 : EndIf  ; Y direction step
  Protected err = dx - dy      ; Error accumulator
  
  While #True
    WeAct_DrawPixelBuffer(x1, y1, Color)  ; Draw current pixel
    
    If x1 = x2 And y1 = y2 : Break : EndIf  ; Stop when endpoint reached
    
    Protected e2 = err * 2  ; Double the error
    
    ; Adjust X coordinate if error indicates we should move horizontally
    If e2 > -dy
      err - dy
      x1 + sx
    EndIf
    
    ; Adjust Y coordinate if error indicates we should move vertically
    If e2 < dx
      err + dx
      y1 + sy
    EndIf
  Wend
EndProcedure

Procedure WeAct_DrawCircleBuffer(cx, cy, radius, Color, Filled = #False)
  ; Draw circle with center at (cx, cy) and given radius
  ; cx, cy: Center coordinates
  ; radius: Circle radius in pixels
  ; Color: BRG565 color value
  ; Filled: #True for filled circle, #False for outline
  Protected x, y, d
  
  If Filled
    ; Draw filled circle (simple but slower method)
    For y = -radius To radius
      For x = -radius To radius
        ; Check if point (x,y) is inside circle using distance formula
        If x * x + y * y <= radius * radius
          WeAct_DrawPixelBuffer(cx + x, cy + y, Color)
        EndIf
      Next
    Next
  Else
    ; Draw circle outline using Bresenham's circle algorithm
    x = 0
    y = radius
    d = 3 - 2 * radius  ; Initial decision parameter
    
    While x <= y
      ; Draw all 8 symmetric points of the circle
      WeAct_DrawPixelBuffer(cx + x, cy + y, Color)
      WeAct_DrawPixelBuffer(cx - x, cy + y, Color)
      WeAct_DrawPixelBuffer(cx + x, cy - y, Color)
      WeAct_DrawPixelBuffer(cx - x, cy - y, Color)
      WeAct_DrawPixelBuffer(cx + y, cy + x, Color)
      WeAct_DrawPixelBuffer(cx - y, cy + x, Color)
      WeAct_DrawPixelBuffer(cx + y, cy - x, Color)
      WeAct_DrawPixelBuffer(cx - y, cy - x, Color)
      
      ; Update decision parameter and coordinates
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

; { DISPLAY OUTPUT FUNCTIONS }

Procedure WeAct_FlushBuffer()
  ; Send back buffer contents to the physical display
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn #False : EndIf
  If Not WeActDisplay\IsConnected : ProcedureReturn #False : EndIf
  
  ; Command format for sending image data to display:
  ; Byte 0: Command ID (0x05 = draw image)
  ; Bytes 1-4: Starting coordinates (x1, y1) as 16-bit values
  ; Bytes 5-8: Ending coordinates (x2, y2) as 16-bit values
  ; Byte 9: Terminator (0x0A)
  Dim Command.b(10)
  Command(0) = $05  ; Draw command
  
  ; Starting coordinates (0, 0)
  Command(1) = 0
  Command(2) = 0
  Command(3) = 0
  Command(4) = 0
  
  ; Calculate ending coordinates (width-1, height-1)
  Protected x_end = WeActDisplay\DisplayWidth - 1
  Command(5) = x_end & $FF        ; X low byte
  Command(6) = (x_end >> 8) & $FF ; X high byte
  
  Protected y_end = WeActDisplay\DisplayHeight - 1
  Command(7) = y_end & $FF        ; Y low byte
  Command(8) = (y_end >> 8) & $FF ; Y high byte
  
  Command(9) = $0A  ; Command terminator
  
  ; Send command header
  If WriteSerialPortData(WeActDisplay\SerialPort, @Command(), 10)
    Delay(10)  ; Small delay before sending pixel data
    
    ; Calculate total bytes to send: width * height * 2 bytes per pixel
    Protected bytesToSend = WeActDisplay\DisplayWidth * WeActDisplay\DisplayHeight * 2
    
    ; Send the actual pixel data from back buffer
    If WriteSerialPortData(WeActDisplay\SerialPort, WeActDisplay\BackBuffer, bytesToSend)
      Delay(10)  ; Small delay after sending data
      ProcedureReturn #True
    EndIf
  EndIf
  
  WeActDisplay\LastError = "Failed to flush buffer to display"
  ProcedureReturn #False
EndProcedure

Procedure WeAct_UpdateDisplay()
  ; Update display with back buffer contents and swap buffers
  If WeAct_FlushBuffer()
    WeAct_SwapBuffers()  ; Now back buffer becomes front buffer
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; { TEXT RENDERING FUNCTIONS }

Procedure.i GetCachedFont(FontName.s, FontSize.i)
  ; Get font from cache or load it if not cached
  ; Font caching improves performance by avoiding repeated font loading
  Protected key.s = FontName + "_" + Str(FontSize)
  
  If FindMapElement(FontCache(), key)
    ; Font found in cache, return its ID
    ProcedureReturn FontCache()\FontID
  Else
    ; Font not in cache, load it
    Protected fontID = LoadFont(#PB_Any, FontName, FontSize)
    If fontID
      ; Add to cache for future use
      AddMapElement(FontCache(), key)
      FontCache()\FontID = fontID
      FontCache()\Size = FontSize
      FontCache()\Name = FontName
      ProcedureReturn fontID
    EndIf
  EndIf
  
  ProcedureReturn #PB_Default  ; Return default if font loading failed
EndProcedure

Procedure.i WeAct_GetTextWidth(Text.s, FontSize.i, FontName.s = "Arial")
  ; Calculate width of text string in pixels
  Protected fontID, width.i = 0
  Protected tempImage
  
  ; Get or load font
  fontID = GetCachedFont(FontName, FontSize)
  If fontID = #PB_Default
    fontID = LoadFont(#PB_Any, FontName, FontSize)
    If Not fontID
      ProcedureReturn 0
    EndIf
  EndIf
  
  ; Create temporary image for text measurement
  tempImage = CreateImage(#PB_Any, 1, 1, 24)
  If tempImage And StartDrawing(ImageOutput(tempImage))
    DrawingFont(FontID(fontID))  ; Select font for drawing
    width = TextWidth(Text)      ; PureBasic function to get text width
    StopDrawing()
    FreeImage(tempImage)
  EndIf
  
  ProcedureReturn width
EndProcedure

Procedure.i WeAct_GetTextHeight(Text.s, FontSize.i, FontName.s = "Arial")
  ; Calculate height of text string in pixels
  Protected fontID, height.i = 0
  Protected tempImage
  
  ; Get or load font
  fontID = GetCachedFont(FontName, FontSize)
  If fontID = #PB_Default
    fontID = LoadFont(#PB_Any, FontName, FontSize)
    If Not fontID
      ProcedureReturn 0
    EndIf
  EndIf
  
  ; Create temporary image for text measurement
  tempImage = CreateImage(#PB_Any, 1, 1, 24)
  If tempImage And StartDrawing(ImageOutput(tempImage))
    DrawingFont(FontID(fontID))   ; Select font for drawing
    height = TextHeight(Text)     ; PureBasic function to get text height
    StopDrawing()
    FreeImage(tempImage)
  EndIf
  
  ProcedureReturn height
EndProcedure

Procedure WeAct_DrawTextSystemFont(x, y, Text.s, Color, FontSize.i = 12, FontName.s = "Arial")
  ; Draw text using system fonts with anti-aliasing
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  If Text = "" : ProcedureReturn : EndIf
  
  ; Load the specified font
  Protected fontID = LoadFont(#PB_Any, FontName, FontSize)
  If Not fontID
    ProcedureReturn
  EndIf
  
  ; Measure text dimensions
  Protected textWidth = 0, textHeight = 0
  Protected measureImage = CreateImage(#PB_Any, 1, 1)
  
  If measureImage And StartDrawing(ImageOutput(measureImage))
    DrawingFont(FontID(fontID))
    textWidth = TextWidth(Text)
    textHeight = TextHeight(Text)
    StopDrawing()
    FreeImage(measureImage)
  EndIf
  
  If textWidth <= 0 Or textHeight <= 0
    FreeFont(fontID)
    ProcedureReturn
  EndIf
  
  ; Create temporary image for text rendering (24-bit RGB format)
  ; Add 4 pixels padding for anti-aliasing edges
  Protected renderImage = CreateImage(#PB_Any, textWidth + 4, textHeight + 4, 24, RGB(0, 0, 0))
  If renderImage
    ; Render text to temporary image
    If StartDrawing(ImageOutput(renderImage))
      DrawingFont(FontID(fontID))
      DrawingMode(#PB_2DDrawing_Transparent)  ; Draw text without background
      ; Draw white text on black background (we'll use brightness as alpha)
      DrawText(2, 2, Text, RGB(255, 255, 255))
      StopDrawing()
      
      ; Copy rendered text to display buffer
      If StartDrawing(ImageOutput(renderImage))
        Protected srcX, srcY, pixelColor, brightness
        
        ; Scan each pixel of rendered text
        For srcY = 0 To textHeight + 3
          For srcX = 0 To textWidth + 3
            pixelColor = Point(srcX, srcY)  ; Get pixel color
            brightness = Red(pixelColor)    ; In grayscale, R=G=B
            
            ; If pixel is not black (text pixel), draw it on display
            If brightness > 30  ; Threshold to filter out anti-aliasing artifacts
              WeAct_DrawPixelBuffer(x + srcX - 2, y + srcY - 2, Color)
            EndIf
          Next
        Next
        
        StopDrawing()
      EndIf
      
      FreeImage(renderImage)
    EndIf
  EndIf
  
  FreeFont(fontID)
EndProcedure

; Convenience functions for common text sizes
Procedure WeAct_DrawTextSmall(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 8, "Arial")
EndProcedure

Procedure WeAct_DrawTextMedium(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 12, "Arial")
EndProcedure

Procedure WeAct_DrawTextLarge(x, y, Text.s, Color)
  WeAct_DrawTextSystemFont(x, y, Text, Color, 16, "Arial")
EndProcedure

; { TEXT WRAPPING FUNCTIONS }

Procedure WeAct_DrawWrappedText(x, y, Width, Height, Text.s, Color, FontSize.i = 12, FontName.s = "Arial", AutoSize = #False)
  ; Draw text with automatic line wrapping within specified rectangle
  ; x, y: Top-left corner of text area
  ; Width, Height: Dimensions of text area
  ; Text: Text string to draw
  ; AutoSize: If #True, automatically reduces font size to fit text in area
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn : EndIf
  
  Protected fontID, tempImage, currentFontSize
  Protected Dim lines.s(0)   ; Array to store individual text lines
  Protected lineCount, i, currentY
  Protected maxLines, lineHeight
  Protected fitted = #False  ; Flag indicating text fits in area
  
  currentFontSize = FontSize
  
  If AutoSize
    ; Auto-size mode: reduce font size until text fits
    While currentFontSize >= 6 And Not fitted
      ; Get or load font with current size
      fontID = GetCachedFont(FontName, currentFontSize)
      If fontID = #PB_Default
        fontID = LoadFont(#PB_Any, FontName, currentFontSize)
        If Not fontID
          ProcedureReturn
        EndIf
      EndIf
      
      ; Create temporary image for text layout
      tempImage = CreateImage(#PB_Any, Width, Height, 24)
      If tempImage
        If StartDrawing(ImageOutput(tempImage))
          DrawingFont(FontID(fontID))
          ReDim lines.s(0)  ; Reset lines array
          lineCount = 0
          
          ; Normalize line endings and split into words
          Protected words.s = ReplaceString(Text, Chr(13) + Chr(10), " ")
          words = ReplaceString(words, Chr(13), " ")
          words = ReplaceString(words, Chr(10), " ")
          Protected wordCount = CountString(words, " ") + 1
          Protected currentLine.s = ""
          Protected testLine.s
          Protected textWidth
          
          ; Word wrapping algorithm
          For i = 1 To wordCount
            ; Test if adding next word exceeds width
            testLine = currentLine
            If testLine <> ""
              testLine + " "
            EndIf
            testLine + StringField(words, i, " ")
            textWidth = TextWidth(testLine)
            
            If textWidth <= Width
              ; Word fits, add to current line
              currentLine = testLine
            Else
              ; Word doesn't fit, start new line
              If currentLine <> ""
                ReDim lines.s(lineCount + 1)
                lines(lineCount) = currentLine
                lineCount + 1
              EndIf
              currentLine = StringField(words, i, " ")
            EndIf
          Next i
          
          ; Add last line if not empty
          If currentLine <> ""
            ReDim lines.s(lineCount + 1)
            lines(lineCount) = currentLine
            lineCount + 1
          EndIf
          
          ; Check if all lines fit in height
          lineHeight = TextHeight("A")
          maxLines = Height / lineHeight
          
          If lineCount <= maxLines
            fitted = #True  ; Text fits with current font size
          Else
            currentFontSize - 1  ; Try smaller font
          EndIf
          StopDrawing()
        EndIf
        FreeImage(tempImage)
      EndIf
      
      ; If still not fitted and font is at minimum size, force fit
      If Not fitted And currentFontSize < 6
        currentFontSize = 6
        fitted = #True
      EndIf
    Wend
  Else
    ; Fixed font size mode
    fontID = GetCachedFont(FontName, currentFontSize)
    If fontID = #PB_Default
      fontID = LoadFont(#PB_Any, FontName, currentFontSize)
      If Not fontID
        ProcedureReturn
      EndIf
    EndIf
    
    ; Create temporary image for text layout
    tempImage = CreateImage(#PB_Any, Width, Height, 24)
    If tempImage
      If StartDrawing(ImageOutput(tempImage))
        DrawingFont(FontID(fontID))
        ReDim lines.s(0)
        lineCount = 0
        
        ; Normalize line endings and split into words
        words.s = ReplaceString(Text, Chr(13) + Chr(10), " ")
        words = ReplaceString(words, Chr(13), " ")
        words = ReplaceString(words, Chr(10), " ")
        wordCount = CountString(words, " ") + 1
        currentLine.s = ""
        
        ; Word wrapping algorithm (same as above)
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
        
        ; Add last line
        If currentLine <> ""
          ReDim lines.s(lineCount + 1)
          lines(lineCount) = currentLine
          lineCount + 1
        EndIf
        
        ; Limit lines to fit available height
        lineHeight = TextHeight("A")
        maxLines = Height / lineHeight
        
        If lineCount > maxLines
          lineCount = maxLines  ; Truncate text if doesn't fit
        EndIf
        StopDrawing()
      EndIf
      FreeImage(tempImage)
    EndIf
  EndIf
  
  ; Render wrapped text to display
  tempImage = CreateImage(#PB_Any, Width, Height, 24)
  If tempImage
    If StartDrawing(ImageOutput(tempImage))
      ; Clear background
      Box(0, 0, Width, Height, RGB(0, 0, 0))
      DrawingFont(FontID(fontID))
      DrawingMode(#PB_2DDrawing_Transparent)
      Protected textColor = RGB(255, 255, 255)  ; Render as white for brightness detection
      currentY = 0
      
      ; Draw each line
      For i = 0 To lineCount - 1
        If lines(i) <> ""
          DrawText(0, currentY, lines(i), textColor)
          currentY + lineHeight
        EndIf
      Next i
      StopDrawing()
      
      ; Copy rendered text to display buffer
      If StartDrawing(ImageOutput(tempImage))
        Protected sourceX, sourceY, pixelColor, brightness
        
        For sourceY = 0 To Height - 1
          For sourceX = 0 To Width - 1
            pixelColor = Point(sourceX, sourceY)
            brightness = Red(pixelColor)  ; Check pixel brightness
            
            ; Draw pixels that are part of text (not background)
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

; Convenience functions for wrapped text
Procedure WeAct_DrawWrappedTextAutoSize(x, y, Width, Height, Text.s, Color, FontName.s = "Arial")
  WeAct_DrawWrappedText(x, y, Width, Height, Text, Color, 12, FontName, #True)
EndProcedure

Procedure WeAct_DrawWrappedTextFixed(x, y, Width, Height, Text.s, Color, FontSize.i = 12, FontName.s = "Arial")
  WeAct_DrawWrappedText(x, y, Width, Height, Text, Color, FontSize, FontName, #False)
EndProcedure

; { TEXT SCROLLING FUNCTIONS }

Procedure WeAct_StartScrollText(Text.s, FontSize.i = 12, Direction.i = #SCROLL_LEFT, Speed.f = 20.0, Color.i = #WEACT_WHITE, FontName.s = "Arial")
  ; Initialize text scrolling parameters
  ScrollText\Text = Text
  ScrollText\FontSize = FontSize
  ScrollText\Direction = Direction
  ScrollText\Speed = Speed
  ScrollText\Color = Color
  ScrollText\FontName = FontName
  ScrollText\Active = #True
  ScrollText\LastUpdate = ElapsedMilliseconds()
  ScrollText\AccumulatedPixels = 0.0  ; For smooth fractional pixel movement
  
  ; Set initial position based on scroll direction
  Select Direction
    Case #SCROLL_LEFT
      ; Start from right edge of display
      ScrollText\Position = WeActDisplay\DisplayWidth
    Case #SCROLL_RIGHT
      ; Start from left edge (text width off-screen)
      ScrollText\Position = -WeAct_GetTextWidth(Text, FontSize, FontName)
    Case #SCROLL_UP
      ; Start from bottom edge
      ScrollText\Position = WeActDisplay\DisplayHeight
    Case #SCROLL_DOWN
      ; Start from top edge (text height off-screen)
      ScrollText\Position = -WeAct_GetTextHeight(Text, FontSize, FontName)
  EndSelect
EndProcedure

Procedure WeAct_StopScrollText()
  ; Stop active text scrolling
  ScrollText\Active = #False
EndProcedure

Procedure WeAct_UpdateScrollText()
  ; Update scroll text position based on elapsed time
  ; This implements smooth scrolling with fractional pixel accumulation
  If Not ScrollText\Active
    ProcedureReturn
  EndIf
  
  ; Calculate time since last update
  Protected currentTime = ElapsedMilliseconds()
  Protected deltaTime = currentTime - ScrollText\LastUpdate
  
  If deltaTime <= 0
    ProcedureReturn
  EndIf
  
  ; Calculate how many pixels to move based on speed and time
  ; Speed is in pixels per second, deltaTime is in milliseconds
  Protected pixelsToMove.f = ScrollText\Speed * (deltaTime / 1000.0)
  
  ; Accumulate fractional pixels to prevent jerky movement
  ScrollText\AccumulatedPixels + pixelsToMove
  
  ; Only move whole pixels (integer movement)
  Protected intPixelsToMove.i = Int(ScrollText\AccumulatedPixels)
  
  If intPixelsToMove >= 1
    ; Subtract moved pixels from accumulator
    ScrollText\AccumulatedPixels - intPixelsToMove
    
    ; Update position based on direction
    Select ScrollText\Direction
      Case #SCROLL_LEFT
        ScrollText\Position - intPixelsToMove
        ; Reset to right edge when text scrolls completely off left edge
        If ScrollText\Position < -WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
          ScrollText\Position = WeActDisplay\DisplayWidth
        EndIf
        
      Case #SCROLL_RIGHT
        ScrollText\Position + intPixelsToMove
        ; Reset to left edge when text scrolls completely off right edge
        If ScrollText\Position > WeActDisplay\DisplayWidth
          ScrollText\Position = -WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
        EndIf
        
      Case #SCROLL_UP
        ScrollText\Position - intPixelsToMove
        ; Reset to bottom edge when text scrolls completely off top edge
        If ScrollText\Position < -WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
          ScrollText\Position = WeActDisplay\DisplayHeight
        EndIf
        
      Case #SCROLL_DOWN
        ScrollText\Position + intPixelsToMove
        ; Reset to top edge when text scrolls completely off bottom edge
        If ScrollText\Position > WeActDisplay\DisplayHeight
          ScrollText\Position = -WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)
        EndIf
    EndSelect
  EndIf
  
  ; Update timestamp for next calculation
  ScrollText\LastUpdate = currentTime
EndProcedure

Procedure WeAct_DrawScrollText()
  ; Draw the currently scrolling text at its current position
  If Not ScrollText\Active
    ProcedureReturn
  EndIf
  
  Protected x, y
  
  ; Calculate text position based on direction
  Select ScrollText\Direction
    Case #SCROLL_LEFT, #SCROLL_RIGHT
      ; Horizontal scrolling: x position changes, y is centered
      x = ScrollText\Position
      y = (WeActDisplay\DisplayHeight - WeAct_GetTextHeight(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)) / 2
    Case #SCROLL_UP, #SCROLL_DOWN
      ; Vertical scrolling: y position changes, x is centered
      x = (WeActDisplay\DisplayWidth - WeAct_GetTextWidth(ScrollText\Text, ScrollText\FontSize, ScrollText\FontName)) / 2
      y = ScrollText\Position
  EndSelect
  
  ; Draw text at calculated position
  WeAct_DrawTextSystemFont(x, y, ScrollText\Text, ScrollText\Color, ScrollText\FontSize, ScrollText\FontName)
EndProcedure

; Convenience functions for starting scroll in specific directions
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

; { IMAGE LOADING FUNCTIONS }

Procedure.s WeAct_GetSupportedImageFormats()
  ; Return list of supported image formats
  ProcedureReturn "BMP, JPEG, PNG, TIFF, TGA"
EndProcedure

Procedure WeAct_LoadImageToBuffer(x, y, FileName.s, Width.i = -1, Height.i = -1)
  ; Load and display image from file
  ; x, y: Top-left corner position for image
  ; FileName: Path to image file
  ; Width, Height: Target dimensions (-1 means use original size or proportional scaling)
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn #False : EndIf
  
  Protected originalImage, originalWidth, originalHeight
  Protected targetWidth, targetHeight
  Protected scaleX.f, scaleY.f
  
  ; Check if file exists
  If FileSize(FileName) <= 0
    WeActDisplay\LastError = "Image file not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Load original image
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    WeActDisplay\LastError = "Failed to load image: " + FileName
    ProcedureReturn #False
  EndIf
  
  originalWidth = ImageWidth(originalImage)
  originalHeight = ImageHeight(originalImage)
  
  ; Calculate target dimensions based on parameters
  If Width = -1 And Height = -1
    ; Use original dimensions
    targetWidth = originalWidth
    targetHeight = originalHeight
  ElseIf Width = -1
    ; Scale proportionally based on height
    targetHeight = Height
    scaleY = targetHeight / originalHeight
    targetWidth = originalWidth * scaleY
  ElseIf Height = -1
    ; Scale proportionally based on width
    targetWidth = Width
    scaleX = targetWidth / originalWidth
    targetHeight = originalHeight * scaleX
  Else
    ; Use specified dimensions
    targetWidth = Width
    targetHeight = Height
  EndIf
  
  ; Convert to integers
  targetWidth = Int(targetWidth)
  targetHeight = Int(targetHeight)
  
  ; Limit to display dimensions
  If targetWidth > WeActDisplay\DisplayWidth
    targetWidth = WeActDisplay\DisplayWidth
  EndIf
  If targetHeight > WeActDisplay\DisplayHeight
    targetHeight = WeActDisplay\DisplayHeight
  EndIf
  
  ; Adjust coordinates to keep image on screen
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
  
  ; Create temporary image for scaling
  Protected tempImage = CreateImage(#PB_Any, targetWidth, targetHeight, 24)
  If Not tempImage
    FreeImage(originalImage)
    WeActDisplay\LastError = "Failed to create resized image"
    ProcedureReturn #False
  EndIf
  
  ; Scale image to target dimensions
  If StartDrawing(ImageOutput(tempImage))
    ; Clear background
    Box(0, 0, targetWidth, targetHeight, RGB(0, 0, 0))
    ; Draw scaled image
    DrawImage(ImageID(originalImage), 0, 0, targetWidth, targetHeight)
    StopDrawing()
  EndIf
  
  ; Copy pixels to display buffer
  If StartDrawing(ImageOutput(tempImage))
    Protected destX.i, destY.i, pixelColor, r.i, g.i, b.i
    
    ; Scan each pixel of scaled image
    For destY = 0 To targetHeight - 1
      For destX = 0 To targetWidth - 1
        pixelColor = Point(destX, destY)  ; Get pixel color
        r = Red(pixelColor)               ; Extract red component (0-255)
        g = Green(pixelColor)             ; Extract green component (0-255)
        b = Blue(pixelColor)              ; Extract blue component (0-255)
        ; Convert to RGB565 and draw to buffer
        WeAct_DrawPixelBuffer(x + destX, y + destY, RGBToRGB565(r, g, b))
      Next
    Next
    
    StopDrawing()
  EndIf
  
  ; Clean up
  FreeImage(tempImage)
  FreeImage(originalImage)
  ProcedureReturn #True
EndProcedure

Procedure WeAct_LoadImageFullScreen(FileName.s)
  ; Load image and scale to fill screen while maintaining aspect ratio
  Protected originalImage, targetWidth, targetHeight
  Protected scale.f, x, y
  
  ; Check if file exists
  If FileSize(FileName) <= 0
    WeActDisplay\LastError = "Image file not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Load image
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    WeActDisplay\LastError = "Failed to load image: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Calculate scale factor to fill screen while maintaining aspect ratio
  ; Find the smaller of the two scale factors (width and height)
  scale = WeActDisplay\DisplayWidth / ImageWidth(originalImage)
  If (WeActDisplay\DisplayHeight / ImageHeight(originalImage)) < scale
    scale = WeActDisplay\DisplayHeight / ImageHeight(originalImage)
  EndIf
  
  ; Calculate target dimensions
  targetWidth = ImageWidth(originalImage) * scale
  targetHeight = ImageHeight(originalImage) * scale
  
  ; Center image on screen
  x = (WeActDisplay\DisplayWidth - targetWidth) / 2
  y = (WeActDisplay\DisplayHeight - targetHeight) / 2
  
  FreeImage(originalImage)
  
  ; Use main image loading function
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

Procedure WeAct_LoadImageCentered(FileName.s, Width.i = -1, Height.i = -1)
  ; Load image and center it on screen
  Protected originalImage, targetWidth, targetHeight
  Protected x, y
  
  ; Check if file exists
  If FileSize(FileName) <= 0
    WeActDisplay\LastError = "Image file not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Load image
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    WeActDisplay\LastError = "Failed to load image: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Calculate target dimensions
  If Width = -1 And Height = -1
    targetWidth = ImageWidth(originalImage)
    targetHeight = ImageHeight(originalImage)
  ElseIf Width = -1
    ; Scale proportionally based on height
    targetHeight = Height
    targetWidth = ImageWidth(originalImage) * (targetHeight / ImageHeight(originalImage))
  ElseIf Height = -1
    ; Scale proportionally based on width
    targetWidth = Width
    targetHeight = ImageHeight(originalImage) * (targetWidth / ImageWidth(originalImage))
  Else
    targetWidth = Width
    targetHeight = Height
  EndIf
  
  ; Limit to display dimensions
  If targetWidth > WeActDisplay\DisplayWidth
    targetWidth = WeActDisplay\DisplayWidth
  EndIf
  If targetHeight > WeActDisplay\DisplayHeight
    targetHeight = WeActDisplay\DisplayHeight
  EndIf
  
  ; Center image
  x = (WeActDisplay\DisplayWidth - targetWidth) / 2
  y = (WeActDisplay\DisplayHeight - targetHeight) / 2
  
  FreeImage(originalImage)
  
  ; Use main image loading function
  ProcedureReturn WeAct_LoadImageToBuffer(x, y, FileName, targetWidth, targetHeight)
EndProcedure

Procedure WeAct_LoadImageFast(x, y, FileName.s)
  ; Fast image loading without scaling (better performance)
  If WeActDisplay\BackBuffer = 0 : ProcedureReturn #False : EndIf
  
  Protected originalImage, originalWidth, originalHeight
  Protected srcX, srcY, pixelColor, r, g, b
  
  ; Check if file exists
  If FileSize(FileName) <= 0
    WeActDisplay\LastError = "Image file not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Load image
  originalImage = LoadImage(#PB_Any, FileName)
  If Not originalImage
    WeActDisplay\LastError = "Failed to load image: " + FileName
    ProcedureReturn #False
  EndIf
  
  originalWidth = ImageWidth(originalImage)
  originalHeight = ImageHeight(originalImage)
  
  ; Limit to available space on display
  If x + originalWidth > WeActDisplay\DisplayWidth
    originalWidth = WeActDisplay\DisplayWidth - x
  EndIf
  If y + originalHeight > WeActDisplay\DisplayHeight
    originalHeight = WeActDisplay\DisplayHeight - y
  EndIf
  
  If originalWidth <= 0 Or originalHeight <= 0
    FreeImage(originalImage)
    ProcedureReturn #False
  EndIf
  
  ; Fast pixel-by-pixel copy without scaling
  If StartDrawing(ImageOutput(originalImage))
    For srcY = 0 To originalHeight - 1
      For srcX = 0 To originalWidth - 1
        pixelColor = Point(srcX, srcY)  ; Get pixel color
        r = Red(pixelColor)             ; Extract red component
        g = Green(pixelColor)           ; Extract green component
        b = Blue(pixelColor)            ; Extract blue component
        ; Convert and draw pixel
        WeAct_DrawPixelBuffer(x + srcX, y + srcY, RGBToRGB565(r, g, b))
      Next
    Next
    StopDrawing()
  EndIf
  
  FreeImage(originalImage)
  ProcedureReturn #True
EndProcedure

; { DISPLAY CONTROL FUNCTIONS }

Procedure WeAct_SetOrientation(Orientation)
  ; Set display orientation mode
  ; Valid values: 0-3 for fixed orientations, 5 for auto-rotation
  If Orientation < 0 Or (Orientation > 3 And Orientation <> 5)
    WeActDisplay\LastError = "Invalid orientation value. Use 0-3 or 5 for ROTATE"
    ProcedureReturn #False
  EndIf
  
  ; Determine new dimensions based on orientation
  Protected newWidth, newHeight
  
  Select Orientation
    Case #WEACT_PORTRAIT, #WEACT_REVERSE_PORTRAIT
      ; Portrait mode: 80x160
      newWidth = 80
      newHeight = 160
      
    Case #WEACT_LANDSCAPE, #WEACT_REVERSE_LANDSCAPE
      ; Landscape mode: 160x80 (default)
      newWidth = 160
      newHeight = 80
      
    Case #WEACT_ROTATE
      ; Auto-rotation: keep current dimensions
      newWidth = WeActDisplay\DisplayWidth
      newHeight = WeActDisplay\DisplayHeight
  EndSelect
  
  ; Send orientation command to display
  ; Command format: 0x02 [orientation] 0x0A
  Dim Command.b(2)
  Command(0) = $02          ; Orientation command
  Command(1) = Orientation  ; Orientation value
  Command(2) = $0A          ; Terminator
  
  If SendCommand(@Command(), 3)
    ; Update local state
    WeActDisplay\CurrentOrientation = Orientation
    Delay(100)  ; Wait for display to process command
    
    ; Update display dimensions
    WeActDisplay\DisplayWidth = newWidth
    WeActDisplay\DisplayHeight = newHeight
    WeActDisplay\BufferSize = newWidth * newHeight * 2
    
    ; Clear buffers after orientation change
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
  ; Set display brightness with optional fade time
  ; Brightness: 0-255 (0 = off, 255 = max)
  ; TimeMs: Fade time in milliseconds (0-5000)
  If Brightness < 0 : Brightness = 0 : EndIf
  If Brightness > 255 : Brightness = 255 : EndIf
  If TimeMs < 0 : TimeMs = 0 : EndIf
  If TimeMs > 5000 : TimeMs = 5000 : EndIf
  
  ; Command format: 0x03 [brightness] [time_low] [time_high] 0x0A
  Dim Command.b(4)
  Command(0) = $03                ; Brightness command
  Command(1) = Brightness         ; Brightness level
  Command(2) = TimeMs & $FF       ; Fade time low byte
  Command(3) = TimeMs >> 8        ; Fade time high byte
  Command(4) = $0A                ; Terminator
  
  If SendCommand(@Command(), 5)
    WeActDisplay\CurrentBrightness = Brightness
    ProcedureReturn #True
  EndIf
  
  WeActDisplay\LastError = "Failed to set brightness"
  ProcedureReturn #False
EndProcedure

Procedure WeAct_SystemReset()
  ; Send system reset command to display
  Dim Command.b(1)
  Command(0) = $40  ; Reset command
  Command(1) = $0A  ; Terminator
  
  If SendCommand(@Command(), 2)
    Delay(1000)  ; Wait for reset to complete
    ProcedureReturn #True
  EndIf
  
  WeActDisplay\LastError = "Failed to reset system"
  ProcedureReturn #False
EndProcedure

Procedure WeAct_FillScreen(Color)
  ; Fill entire screen with solid color using hardware command
  ; This is faster than drawing pixel-by-pixel
  If Not WeActDisplay\IsConnected
    WeActDisplay\LastError = "Display not connected"
    ProcedureReturn #False
  EndIf
  
  ; Command format: 0x04 [x1_low] [x1_high] [y1_low] [y1_high] 
  ;                 [x2_low] [x2_high] [y2_low] [y2_high]
  ;                 [color_low] [color_high] 0x0A
  Dim Command.b(11)
  Command(0) = $04  ; Fill screen command
  
  ; Starting coordinates (0, 0)
  Command(1) = 0
  Command(2) = 0
  Command(3) = 0
  Command(4) = 0
  
  ; Ending coordinates (width-1, height-1)
  Protected x_end = WeActDisplay\DisplayWidth - 1
  Command(5) = x_end & $FF        ; X end low byte
  Command(6) = (x_end >> 8) & $FF ; X end high byte
  
  Protected y_end = WeActDisplay\DisplayHeight - 1
  Command(7) = y_end & $FF        ; Y end low byte
  Command(8) = (y_end >> 8) & $FF ; Y end high byte
  
  ; Color in RGB565 format
  Command(9) = Color & $FF        ; Color low byte
  Command(10) = (Color >> 8) & $FF ; Color high byte
  
  Command(11) = $0A  ; Terminator
  
  If SendCommand(@Command(), 12)
    Delay(50)  ; Wait for command to complete
    ProcedureReturn #True
  EndIf
  
  WeActDisplay\LastError = "Failed to fill screen"
  ProcedureReturn #False
EndProcedure

; { HELPER FUNCTIONS }

Procedure.s WeAct_GetInfo()
  ; Get display information as formatted string
  If WeActDisplay\IsConnected
    ProcedureReturn "WeAct Display FS 0.96-inch (" + WeActDisplay\PortName + ") " + 
                    Str(WeActDisplay\DisplayWidth) + "x" + Str(WeActDisplay\DisplayHeight)
  EndIf
  ProcedureReturn "Not connected"
EndProcedure

Procedure.i WeAct_GetOrientation()
  ; Get current orientation mode
  ProcedureReturn WeActDisplay\CurrentOrientation
EndProcedure

Procedure.i WeAct_GetBrightness()
  ; Get current brightness level
  ProcedureReturn WeActDisplay\CurrentBrightness
EndProcedure

Procedure.i WeAct_IsConnected()
  ; Check if display is connected
  ProcedureReturn WeActDisplay\IsConnected
EndProcedure

Procedure.i WeAct_GetDisplayWidth()
  ; Get current display width (depends on orientation)
  ProcedureReturn WeActDisplay\DisplayWidth
EndProcedure

Procedure.i WeAct_GetDisplayHeight()
  ; Get current display height (depends on orientation)
  ProcedureReturn WeActDisplay\DisplayHeight
EndProcedure

Procedure.s WeAct_GetLastError()
  ; Get last error message
  ProcedureReturn WeActDisplay\LastError
EndProcedure

Procedure WeAct_CleanupFonts()
  ; Free all cached fonts
  ForEach FontCache()
    If FontCache()\FontID
      FreeFont(FontCache()\FontID)
    EndIf
  Next
  ClearMap(FontCache())
EndProcedure

; { NEW FUNCTIONS }

Procedure WeAct_DrawProgressBar(x, y, Width, Height, Progress.f, ForeColor = #WEACT_GREEN, BackColor = #WEACT_BLACK, BorderColor = #WEACT_WHITE)
  ; Draw progress bar
  ; x, y: Top-left corner
  ; Width, Height: Progress bar dimensions
  ; Progress: Value from 0.0 to 1.0
  ; ForeColor: Color of filled portion
  ; BackColor: Color of background
  ; BorderColor: Color of border
  If Progress < 0.0 : Progress = 0.0 : EndIf
  If Progress > 1.0 : Progress = 1.0 : EndIf
  
  ; Draw background
  WeAct_DrawRectangleBuffer(x, y, Width, Height, BackColor, #True)
  
  ; Draw filled portion
  Protected fillWidth = Int(Width * Progress)
  If fillWidth > 0
    WeAct_DrawRectangleBuffer(x, y, fillWidth, Height, ForeColor, #True)
  EndIf
  
  ; Draw border
  WeAct_DrawRectangleBuffer(x, y, Width, Height, BorderColor, #False)
EndProcedure

Procedure WeAct_DrawGraph(x, y, Width, Height, *Data.Float, DataCount, MinValue.f, MaxValue.f, Color = #WEACT_WHITE, BackColor = #WEACT_BLACK)
  ; Draw line graph from array of float values
  ; x, y: Top-left corner of graph area
  ; Width, Height: Graph dimensions
  ; *Data: Pointer to array of float values
  ; DataCount: Number of data points
  ; MinValue, MaxValue: Y-axis range for scaling
  ; Color: Graph line color
  ; BackColor: Background color
  If DataCount < 2 Or Not *Data
    ProcedureReturn
  EndIf
  
  ; Clear graph area
  WeAct_DrawRectangleBuffer(x, y, Width, Height, BackColor, #True)
  
  ; Draw border
  WeAct_DrawRectangleBuffer(x, y, Width, Height, Color, #False)
  
  ; Calculate value range for scaling
  Protected range.f = MaxValue - MinValue
  If range = 0.0 : range = 1.0 : EndIf  ; Avoid division by zero
  
  Protected i, x1, y1, x2, y2
  Protected stepX.f = Width / (DataCount - 1)  ; Horizontal spacing between points
  
  ; Draw lines connecting data points
  For i = 0 To DataCount - 2
    ; Get two consecutive data points
    Protected value1.f = PeekF(*Data + i * SizeOf(Float))
    Protected value2.f = PeekF(*Data + (i + 1) * SizeOf(Float))
    
    ; Scale coordinates to fit graph area
    x1 = x + Int(i * stepX)
    y1 = y + Height - Int((value1 - MinValue) / range * Height)
    
    x2 = x + Int((i + 1) * stepX)
    y2 = y + Height - Int((value2 - MinValue) / range * Height)
    
    ; Draw line segment
    WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
  Next
EndProcedure

Procedure WeAct_ShowTextFile(FileName.s, FontSize = 10, Color = #WEACT_WHITE, ScrollSpeed.f = 30.0)
  ; Display text file with vertical scrolling
  If FileSize(FileName) <= 0
    WeActDisplay\LastError = "File not found: " + FileName
    ProcedureReturn #False
  EndIf
  
  ; Read entire file
  Protected file = ReadFile(#PB_Any, FileName)
  If Not file
    WeActDisplay\LastError = "Failed to open file: " + FileName
    ProcedureReturn #False
  EndIf
  
  Protected content.s = ReadString(file, #PB_File_IgnoreEOL)
  CloseFile(file)
  
  ; Start vertical scrolling
  WeAct_StartScrollText(content, FontSize, #SCROLL_UP, ScrollSpeed, Color)
  
  ProcedureReturn #True
EndProcedure

Procedure WeAct_ShowTime(x, y, Hour, Minute, Color = #WEACT_WHITE, FontSize = 16)
  ; Display time in HH:MM format
  Protected timeText.s = RSet(Str(Hour), 2, "0") + ":" + RSet(Str(Minute), 2, "0")
  WeAct_DrawTextSystemFont(x, y, timeText, Color, FontSize, "Arial")
EndProcedure

Procedure WeAct_ShowDate(x, y, Day, Month, Year, Color = #WEACT_WHITE, FontSize = 10)
  ; Display date in DD.MM.YYYY format
  Protected dateText.s = RSet(Str(Day), 2, "0") + "." + RSet(Str(Month), 2, "0") + "." + Str(Year)
  WeAct_DrawTextSystemFont(x, y, dateText, Color, FontSize, "Arial")
EndProcedure

Procedure WeAct_DrawSpinner(cx, cy, radius, angle.f, Color = #WEACT_WHITE)
  ; Draw animated loading spinner
  ; cx, cy: Center coordinates
  ; radius: Spinner radius
  ; angle: Current rotation angle in degrees
  ; Color: Spinner color
  Protected segments = 8           ; Number of spinner segments
  Protected i, x1, y1, x2, y2
  Protected angleStep.f = 360.0 / segments  ; Angle between segments
  
  For i = 0 To segments - 1
    Protected currentAngle.f = angle + i * angleStep
    ; Calculate alpha (opacity) for fade effect
    Protected alpha.f = 1.0 - (i / segments)
    
    ; Only draw segments with sufficient opacity
    If alpha > 0.3
      ; Calculate segment endpoints
      x1 = cx + Cos(Radian(currentAngle)) * radius * 0.5  ; Inner point
      y1 = cy + Sin(Radian(currentAngle)) * radius * 0.5
      x2 = cx + Cos(Radian(currentAngle)) * radius        ; Outer point
      y2 = cy + Sin(Radian(currentAngle)) * radius
      
      ; Draw segment
      WeAct_DrawLineBuffer(x1, y1, x2, y2, Color)
    EndIf
  Next
EndProcedure


; { OVERLAY MODE INIT }

Procedure WeAct_InitNoClear(PortName.s = "COM3")
  ; Initialize connection to WeAct display WITHOUT clearing screen
  ; Use this for overlay mode to preserve existing screen content
  ; PortName: Serial port name (e.g., "COM3")
  
  ; Open serial port
  WeActDisplay\SerialPort = OpenSerialPort(#PB_Any, PortName, #WEACT_BAUDRATE, 
                                          #PB_SerialPort_NoParity, 8, 1, 
                                          #PB_SerialPort_NoHandshake, 2048, 2048)
  
  If WeActDisplay\SerialPort
    ; Store connection parameters
    WeActDisplay\PortName = PortName
    WeActDisplay\IsConnected = #True
    WeActDisplay\CurrentOrientation = #WEACT_LANDSCAPE
    WeActDisplay\CurrentBrightness = 255
    WeActDisplay\DisplayWidth = #WEACT_DISPLAY_WIDTH
    WeActDisplay\DisplayHeight = #WEACT_DISPLAY_HEIGHT
    WeActDisplay\BufferSize = #WEACT_MAX_BUFFER_SIZE
    
    ; Allocate memory for double buffering if not already allocated
    If Not WeActDisplay\FrameBuffer
      WeActDisplay\FrameBuffer = AllocateMemory(#WEACT_MAX_BUFFER_SIZE)
    EndIf
    If Not WeActDisplay\BackBuffer
      WeActDisplay\BackBuffer = AllocateMemory(#WEACT_MAX_BUFFER_SIZE)
    EndIf
    
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      ; DON'T clear buffers - preserve content for overlay
      ; DON'T call WeAct_SetOrientation - avoid screen refresh
      
      ; Initialize image decoders
      WeAct_InitImageDecoders()
      
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

; { CLEANUP }

Procedure WeAct_Cleanup()
  ; Complete cleanup of all resources
  WeAct_CleanupFonts()
  WeAct_Close()
EndProcedure

; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 237
; FirstLine = 228
; Folding = ----------
; EnableXP
