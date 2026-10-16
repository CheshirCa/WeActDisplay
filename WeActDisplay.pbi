; Copyright (C) CheshirCa 2026   https://t.me/cheshircanest
; Modified 2026-10-14 for two display models; GPL-3.0, see LICENSE.
; WeAct Display FS Library for PureBasic 6.0.0
; Supports WeAct Display FS 0.96-inch and 3.5-inch via serial port
; GitHub: https://github.com/CheshirCa/WeActDisplay
; Compatibility: PureBasic 6.20+
; FastLZ stream encoding is based on the documented FastLZ format.
; FastLZ Copyright (C) 2005-2020 Ariya Hidayat; MIT License.

; Display physical dimensions
#WEACT_DISPLAY_WIDTH = 160
#WEACT_DISPLAY_HEIGHT = 80
#WEACT_BAUDRATE = 115200
#WEACT_BAUDRATE_350 = 1152000
#WEACT_MODEL_096 = 0
#WEACT_MODEL_350 = 1
#WEACT_BYTES_PER_PIXEL = 2
; Maximum buffer size for double buffering (160*80*2 bytes = 25600)
#WEACT_MAX_BUFFER_SIZE = 25600

; Display orientation modes (as defined in the device protocol)
Enumeration
  #WEACT_PORTRAIT = 0             ; Portrait mode (80x160)
  #WEACT_REVERSE_PORTRAIT = 1     ; Portrait mode rotated 180 degrees
  #WEACT_LANDSCAPE = 2            ; Landscape mode (160x80) - default
  #WEACT_REVERSE_LANDSCAPE = 3    ; Landscape mode rotated 180 degrees
  #WEACT_ROTATE = 5               ; Deprecated reserved value; unsupported by both models
EndEnumeration

; Text scrolling directions
Enumeration
  #SCROLL_LEFT = 0
  #SCROLL_RIGHT
  #SCROLL_UP
  #SCROLL_DOWN
EndEnumeration

; Predefined colors in RGB565 format
; Both displays use RGB565 in little-endian byte order
; Each color is 16-bit: 5 bits red, 6 bits green, 5 bits blue
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
  Model.i                   ; Explicit display model
  PhysicalWidth.i
  PhysicalHeight.i
  BytesPerPixel.i
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
  SensorPeriod.i
  SensorPosition.i
  SensorLastTime.q
  Temperature.f
  Humidity.f
  SensorValid.i
  SensorPacket.a[6]
  FastLZEnabled.i
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
  Color.i                   ; Text color in RGB565 format
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
Declare WeAct_Close()

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
; Note: Despite the name, this actually converts to RGB565, not RGB565
; Kept as an alias for source compatibility
Macro RGBToRGB565(r, g, b)
  RGBToRGB565_Fixed(r, g, b)
EndMacro

Procedure.i WeAct_WriteAll(*Data, Length)
  ; A serial write may accept only part of a block. Never restart the image stream.
  Protected sent.i, block.i, count.i, deadline.q
  If Not WeActDisplay\IsConnected Or *Data = 0 Or Length < 1
    WeActDisplay\LastError = "Serial port is not connected or data is empty"
    ProcedureReturn #False
  EndIf
  While sent < Length
    block = Length - sent
    If block > 4096 : block = 4096 : EndIf
    deadline = ElapsedMilliseconds() + 5000
    Repeat
      count = WriteSerialPortData(WeActDisplay\SerialPort, *Data + sent, block)
      If count > 0
        sent + count
        Break
      EndIf
      If ElapsedMilliseconds() >= deadline
        WeActDisplay\LastError = "Serial write timed out after " + Str(sent) + " of " + Str(Length) + " bytes (error " + Str(SerialPortError(WeActDisplay\SerialPort)) + ")"
        CloseSerialPort(WeActDisplay\SerialPort)
        WeActDisplay\IsConnected = #False
        ProcedureReturn #False
      EndIf
      Delay(1)
    ForEver
  Wend
  ProcedureReturn #True
EndProcedure

Procedure.i SendCommand(*Data, Length)
  ProcedureReturn WeAct_WriteAll(*Data, Length)
EndProcedure

; { INITIALIZATION AND CLEANUP }

Procedure WeAct_InitImageDecoders()
  ; Initialize PureBasic's built-in image decoders for various formats
  UseJPEGImageDecoder()
  UsePNGImageDecoder()
  UseTIFFImageDecoder()
  UseTGAImageDecoder()
EndProcedure

Procedure.i WeAct_InitInternal(PortName.s, Model.i, PreserveScreen.i)
  Protected baud.i, orientation.i
  WeAct_Close()
  If Model <> #WEACT_MODEL_096 And Model <> #WEACT_MODEL_350
    WeActDisplay\LastError = "Invalid display model"
    ProcedureReturn #False
  EndIf
  WeActDisplay\Model = Model
  WeActDisplay\BytesPerPixel = #WEACT_BYTES_PER_PIXEL
  If Model = #WEACT_MODEL_350
    WeActDisplay\PhysicalWidth = 320
    WeActDisplay\PhysicalHeight = 480
    baud = #WEACT_BAUDRATE_350
    orientation = #WEACT_PORTRAIT
  Else
    WeActDisplay\PhysicalWidth = 80
    WeActDisplay\PhysicalHeight = 160
    baud = #WEACT_BAUDRATE
    orientation = #WEACT_LANDSCAPE
  EndIf
  WeActDisplay\BufferSize = WeActDisplay\PhysicalWidth * WeActDisplay\PhysicalHeight * WeActDisplay\BytesPerPixel
  WeActDisplay\CurrentOrientation = orientation
  If orientation = #WEACT_LANDSCAPE
    WeActDisplay\DisplayWidth = WeActDisplay\PhysicalHeight
    WeActDisplay\DisplayHeight = WeActDisplay\PhysicalWidth
  Else
    WeActDisplay\DisplayWidth = WeActDisplay\PhysicalWidth
    WeActDisplay\DisplayHeight = WeActDisplay\PhysicalHeight
  EndIf
  WeActDisplay\FrameBuffer = AllocateMemory(WeActDisplay\BufferSize)
  WeActDisplay\BackBuffer = AllocateMemory(WeActDisplay\BufferSize)
  If Not WeActDisplay\FrameBuffer Or Not WeActDisplay\BackBuffer
    WeAct_Close()
    WeActDisplay\LastError = "Failed to allocate memory buffers"
    ProcedureReturn #False
  EndIf
  FillMemory(WeActDisplay\FrameBuffer, WeActDisplay\BufferSize, 0)
  FillMemory(WeActDisplay\BackBuffer, WeActDisplay\BufferSize, 0)
  WeActDisplay\SerialPort = OpenSerialPort(#PB_Any, PortName, baud,
                                          #PB_SerialPort_NoParity, 8, 1,
                                          #PB_SerialPort_NoHandshake, 2048, 8192)
  If Not WeActDisplay\SerialPort
    WeAct_Close()
    WeActDisplay\LastError = "Failed to open serial port " + PortName
    ProcedureReturn #False
  EndIf
  WeActDisplay\IsConnected = #True
  WeActDisplay\PortName = PortName
  WeActDisplay\CurrentBrightness = 255
  WeActDisplay\SensorPeriod = 0
  WeActDisplay\SensorPosition = 0
  WeActDisplay\SensorValid = #False
  SerialPortTimeouts(WeActDisplay\SerialPort, 100, 100, 0, 1000, 1)
  WeAct_InitImageDecoders()
  If Not PreserveScreen
    If Not WeAct_SetOrientation(orientation)
      Protected errorText.s = WeActDisplay\LastError
      WeAct_Close()
      WeActDisplay\LastError = errorText
      ProcedureReturn #False
    EndIf
  EndIf
  WeActDisplay\LastError = ""
  ProcedureReturn #True
EndProcedure

Procedure.i WeAct_Init(PortName.s = "COM3", Model.i = #WEACT_MODEL_096)
  ProcedureReturn WeAct_InitInternal(PortName, Model, #False)
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
  Protected color_l = Color & $FF     ; RGB565 little endian, as in DrawPixelBuffer()
  Protected color_h = (Color >> 8) & $FF
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
  ; Color: RGB565 color value
  ; Filled: #True for filled rectangle, #False for outline only
  Protected xx.i, yy.i, startX.i, startY.i, endX.i, endY.i
  Protected rawEndX.q, rawEndY.q
  If Width <= 0 Or Height <= 0 : ProcedureReturn : EndIf
  rawEndX = x
  rawEndX + Width - 1
  rawEndY = y
  rawEndY + Height - 1
  If rawEndX < 0 Or rawEndY < 0 Or x >= WeActDisplay\DisplayWidth Or y >= WeActDisplay\DisplayHeight
    ProcedureReturn
  EndIf
  startX = x : If startX < 0 : startX = 0 : EndIf
  startY = y : If startY < 0 : startY = 0 : EndIf
  endX = rawEndX : If rawEndX >= WeActDisplay\DisplayWidth : endX = WeActDisplay\DisplayWidth - 1 : EndIf
  endY = rawEndY : If rawEndY >= WeActDisplay\DisplayHeight : endY = WeActDisplay\DisplayHeight - 1 : EndIf
  
  If Filled
    ; Draw filled rectangle
    For yy = startY To endY
      For xx = startX To endX
        WeAct_DrawPixelBuffer(xx, yy, Color)
      Next
    Next
  Else
    ; Draw rectangle outline
    ; Top and bottom edges
    For xx = startX To endX
      WeAct_DrawPixelBuffer(xx, y, Color)
      WeAct_DrawPixelBuffer(xx, y + Height - 1, Color)
    Next
    ; Left and right edges
    For yy = startY To endY
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
  ; Color: RGB565 color value
  ; Filled: #True for filled circle, #False for outline
  Protected x, y, d
  If radius < 0 Or radius > WeActDisplay\DisplayWidth + WeActDisplay\DisplayHeight
    ProcedureReturn
  EndIf
  
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

Procedure.i WeAct_MakeRectCommand(x.i, y.i, Width.i, Height.i, *Command)
  ; Useful for both transport and reproducible packet tests.
  If *Command = 0 Or x < 0 Or y < 0 Or Width <= 0 Or Height <= 0 Or x >= WeActDisplay\DisplayWidth Or y >= WeActDisplay\DisplayHeight
    ProcedureReturn #False
  EndIf
  If Width > WeActDisplay\DisplayWidth - x Or Height > WeActDisplay\DisplayHeight - y
    ProcedureReturn #False
  EndIf
  PokeA(*Command, $05)
  PokeA(*Command + 1, x & $FF)
  PokeA(*Command + 2, (x >> 8) & $FF)
  PokeA(*Command + 3, y & $FF)
  PokeA(*Command + 4, (y >> 8) & $FF)
  PokeA(*Command + 5, (x + Width - 1) & $FF)
  PokeA(*Command + 6, ((x + Width - 1) >> 8) & $FF)
  PokeA(*Command + 7, (y + Height - 1) & $FF)
  PokeA(*Command + 8, ((y + Height - 1) >> 8) & $FF)
  PokeA(*Command + 9, $0A)
  ProcedureReturn #True
EndProcedure

; { FASTLZ TRANSPORT }
; The 3.5-inch firmware accepts independent FastLZ level-1 blocks.  The encoder
; uses only the documented byte stream: literal runs and 8 KiB back references.
#WEACT_FASTLZ_HASH_SIZE = 8192
#WEACT_FASTLZ_MAX_MATCH = 264

Procedure.i WeAct_FastLZCompress(*Input, InputLength.i, *Output, OutputCapacity.i)
  Protected Dim Hash.i(#WEACT_FASTLZ_HASH_SIZE - 1)
  Protected i.i, anchor.i, outputPosition.i, hashIndex.i, reference.i
  Protected matchLength.i, distance.i, literalLength.i, copyLength.i, extraLength.i

  If *Input = 0 Or *Output = 0 Or InputLength < 1
    ProcedureReturn 0
  EndIf
  For i = 0 To #WEACT_FASTLZ_HASH_SIZE - 1
    Hash(i) = -1
  Next

  i = 0
  anchor = 0
  While i <= InputLength - 3
    hashIndex = ((PeekA(*Input + i) & $FF) * 251 + (PeekA(*Input + i + 1) & $FF) * 17 + (PeekA(*Input + i + 2) & $FF)) & (#WEACT_FASTLZ_HASH_SIZE - 1)
    reference = Hash(hashIndex)
    Hash(hashIndex) = i

    matchLength = 0
    distance = i - reference
    If reference >= 0 And distance <= 8192 And PeekA(*Input + reference) = PeekA(*Input + i) And PeekA(*Input + reference + 1) = PeekA(*Input + i + 1) And PeekA(*Input + reference + 2) = PeekA(*Input + i + 2)
      matchLength = 3
      While matchLength < #WEACT_FASTLZ_MAX_MATCH And i + matchLength < InputLength And PeekA(*Input + reference + matchLength) = PeekA(*Input + i + matchLength)
        matchLength + 1
      Wend
    EndIf

    If matchLength = 0
      i + 1
      Continue
    EndIf

    literalLength = i - anchor
    While literalLength > 0
      copyLength = literalLength
      If copyLength > 32 : copyLength = 32 : EndIf
      If outputPosition + copyLength + 1 > OutputCapacity : ProcedureReturn 0 : EndIf
      PokeA(*Output + outputPosition, copyLength - 1)
      outputPosition + 1
      CopyMemory(*Input + anchor, *Output + outputPosition, copyLength)
      outputPosition + copyLength
      anchor + copyLength
      literalLength - copyLength
    Wend

    extraLength = matchLength - 2
    If extraLength < 7
      If outputPosition + 2 > OutputCapacity : ProcedureReturn 0 : EndIf
      PokeA(*Output + outputPosition, (extraLength << 5) | ((distance - 1) >> 8))
      PokeA(*Output + outputPosition + 1, (distance - 1) & $FF)
      outputPosition + 2
    Else
      If outputPosition + 3 > OutputCapacity : ProcedureReturn 0 : EndIf
      PokeA(*Output + outputPosition, (7 << 5) | ((distance - 1) >> 8))
      PokeA(*Output + outputPosition + 1, extraLength - 7)
      PokeA(*Output + outputPosition + 2, (distance - 1) & $FF)
      outputPosition + 3
    EndIf

    For hashIndex = i + 1 To i + matchLength - 1
      If hashIndex <= InputLength - 3
        Hash(((PeekA(*Input + hashIndex) & $FF) * 251 + (PeekA(*Input + hashIndex + 1) & $FF) * 17 + (PeekA(*Input + hashIndex + 2) & $FF)) & (#WEACT_FASTLZ_HASH_SIZE - 1)) = hashIndex
      EndIf
    Next
    i + matchLength
    anchor = i
  Wend

  literalLength = InputLength - anchor
  While literalLength > 0
    copyLength = literalLength
    If copyLength > 32 : copyLength = 32 : EndIf
    If outputPosition + copyLength + 1 > OutputCapacity : ProcedureReturn 0 : EndIf
    PokeA(*Output + outputPosition, copyLength - 1)
    outputPosition + 1
    CopyMemory(*Input + anchor, *Output + outputPosition, copyLength)
    outputPosition + copyLength
    anchor + copyLength
    literalLength - copyLength
  Wend
  ProcedureReturn outputPosition
EndProcedure

Procedure.i WeAct_FastLZDecompress(*Input, InputLength.i, *Output, OutputCapacity.i)
  Protected inputPosition.i, outputPosition.i, control.i, copyLength.i, offset.i, reference.i, i.i
  If *Input = 0 Or *Output = 0 Or InputLength < 1
    ProcedureReturn 0
  EndIf
  control = PeekA(*Input) & $1F
  inputPosition = 1
  While #True
    If control >= 32
      copyLength = (control >> 5) - 1
      offset = (control & $1F) << 8
      If copyLength = 6
        If inputPosition >= InputLength : ProcedureReturn 0 : EndIf
        copyLength + (PeekA(*Input + inputPosition) & $FF)
        inputPosition + 1
      EndIf
      If inputPosition >= InputLength : ProcedureReturn 0 : EndIf
      offset + (PeekA(*Input + inputPosition) & $FF)
      inputPosition + 1
      copyLength + 3
      reference = outputPosition - offset - 1
      If reference < 0 Or outputPosition + copyLength > OutputCapacity : ProcedureReturn 0 : EndIf
      For i = 0 To copyLength - 1
        PokeA(*Output + outputPosition + i, PeekA(*Output + reference + i))
      Next
      outputPosition + copyLength
    Else
      copyLength = control + 1
      If inputPosition + copyLength > InputLength Or outputPosition + copyLength > OutputCapacity : ProcedureReturn 0 : EndIf
      CopyMemory(*Input + inputPosition, *Output + outputPosition, copyLength)
      inputPosition + copyLength
      outputPosition + copyLength
    EndIf
    If inputPosition >= InputLength : Break : EndIf
    control = PeekA(*Input + inputPosition) & $FF
    inputPosition + 1
  Wend
  ProcedureReturn outputPosition
EndProcedure

Procedure.i WeAct_SetFastLZEnabled(Enabled.i)
  If WeActDisplay\Model <> #WEACT_MODEL_350
    WeActDisplay\LastError = "FastLZ is supported only by the 3.5-inch display"
    ProcedureReturn #False
  EndIf
  WeActDisplay\FastLZEnabled = Bool(Enabled)
  WeActDisplay\LastError = ""
  ProcedureReturn #True
EndProcedure

Procedure.i WeAct_FlushRectFastLZ(x.i, y.i, Width.i, Height.i)
  Protected row.i, rowBytes.i, offset.i, outputCapacity.i, compressedLength.i
  Protected *Compressed, Dim Command.a(9), Dim BlockHeader.a(3)
  If Not WeActDisplay\IsConnected Or Not WeActDisplay\BackBuffer
    WeActDisplay\LastError = "Display not initialized"
    ProcedureReturn #False
  EndIf
  If Not WeAct_MakeRectCommand(x, y, Width, Height, @Command())
    WeActDisplay\LastError = "Invalid rectangle or rectangle exceeds display bounds"
    ProcedureReturn #False
  EndIf
  PokeA(@Command(), $15)
  If Not SendCommand(@Command(), 10) : ProcedureReturn #False : EndIf

  rowBytes = Width * WeActDisplay\BytesPerPixel
  outputCapacity = rowBytes + (rowBytes / 32) + 16
  *Compressed = AllocateMemory(outputCapacity)
  If *Compressed = 0
    WeActDisplay\LastError = "Failed to allocate FastLZ buffer"
    ProcedureReturn #False
  EndIf
  For row = y To y + Height - 1
    offset = (row * WeActDisplay\DisplayWidth + x) * WeActDisplay\BytesPerPixel
    compressedLength = WeAct_FastLZCompress(WeActDisplay\BackBuffer + offset, rowBytes, *Compressed, outputCapacity)
    If compressedLength = 0 Or compressedLength > $FFFF
      FreeMemory(*Compressed)
      WeActDisplay\LastError = "FastLZ compression failed"
      ProcedureReturn #False
    EndIf
    PokeA(@BlockHeader(), rowBytes & $FF)
    PokeA(@BlockHeader() + 1, (rowBytes >> 8) & $FF)
    PokeA(@BlockHeader() + 2, compressedLength & $FF)
    PokeA(@BlockHeader() + 3, (compressedLength >> 8) & $FF)
    If Not WeAct_WriteAll(@BlockHeader(), 4) Or Not WeAct_WriteAll(*Compressed, compressedLength)
      FreeMemory(*Compressed)
      ProcedureReturn #False
    EndIf
  Next
  FreeMemory(*Compressed)
  ProcedureReturn #True
EndProcedure

Procedure.i WeAct_FlushRect(x.i, y.i, Width.i, Height.i)
  ; Public dimensions are width/height; the wire format uses inclusive end points.
  Protected row.i, rowBytes.i, offset.i
  Dim Command.a(9)
  If WeActDisplay\FastLZEnabled
    ProcedureReturn WeAct_FlushRectFastLZ(x, y, Width, Height)
  EndIf
  If Not WeActDisplay\IsConnected Or Not WeActDisplay\BackBuffer
    WeActDisplay\LastError = "Display not initialized"
    ProcedureReturn #False
  EndIf
  If Not WeAct_MakeRectCommand(x, y, Width, Height, @Command())
    WeActDisplay\LastError = "Invalid rectangle or rectangle exceeds display bounds"
    ProcedureReturn #False
  EndIf
  If Not SendCommand(@Command(), 10) : ProcedureReturn #False : EndIf
  rowBytes = Width * WeActDisplay\BytesPerPixel
  If Width = WeActDisplay\DisplayWidth
    offset = y * rowBytes
    ProcedureReturn WeAct_WriteAll(WeActDisplay\BackBuffer + offset, rowBytes * Height)
  EndIf
  For row = y To y + Height - 1
    offset = (row * WeActDisplay\DisplayWidth + x) * WeActDisplay\BytesPerPixel
    If Not WeAct_WriteAll(WeActDisplay\BackBuffer + offset, rowBytes)
      ProcedureReturn #False
    EndIf
  Next
  ProcedureReturn #True
EndProcedure

Procedure.i WeAct_FlushBuffer()
  ProcedureReturn WeAct_FlushRect(0, 0, WeActDisplay\DisplayWidth, WeActDisplay\DisplayHeight)
EndProcedure

Procedure.i WeAct_FlushChangedBuffer()
  ; Compare frames without copying either one; send one bounding rectangle.
  Protected x.i, y.i, offset.i, minX.i, minY.i, maxX.i, maxY.i
  If Not WeActDisplay\FrameBuffer Or Not WeActDisplay\BackBuffer
    ProcedureReturn #False
  EndIf
  minX = WeActDisplay\DisplayWidth : minY = WeActDisplay\DisplayHeight
  maxX = -1 : maxY = -1
  For y = 0 To WeActDisplay\DisplayHeight - 1
    For x = 0 To WeActDisplay\DisplayWidth - 1
      offset = (y * WeActDisplay\DisplayWidth + x) * WeActDisplay\BytesPerPixel
      If PeekW(WeActDisplay\FrameBuffer + offset) <> PeekW(WeActDisplay\BackBuffer + offset)
        If x < minX : minX = x : EndIf
        If x > maxX : maxX = x : EndIf
        If y < minY : minY = y : EndIf
        If y > maxY : maxY = y : EndIf
      EndIf
    Next
  Next
  If maxX = -1 : ProcedureReturn #True : EndIf
  ProcedureReturn WeAct_FlushRect(minX, minY, maxX - minX + 1, maxY - minY + 1)
EndProcedure

Procedure.i WeAct_UpdateChangedDisplay()
  If WeAct_FlushChangedBuffer()
    WeAct_SwapBuffers()
    ProcedureReturn #True
  EndIf
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
  ; Only documented fixed orientations are safe to send to either display model.
  If Orientation < 0 Or Orientation > 3
    WeActDisplay\LastError = "Unsupported orientation. Use fixed values 0-3"
    ProcedureReturn #False
  EndIf
  
  ; Determine new dimensions based on orientation
  Protected newWidth, newHeight
  
  Select Orientation
    Case #WEACT_PORTRAIT, #WEACT_REVERSE_PORTRAIT
      newWidth = WeActDisplay\PhysicalWidth
      newHeight = WeActDisplay\PhysicalHeight
      
    Case #WEACT_LANDSCAPE, #WEACT_REVERSE_LANDSCAPE
      newWidth = WeActDisplay\PhysicalHeight
      newHeight = WeActDisplay\PhysicalWidth
      
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
    
    ; Update display dimensions
    WeActDisplay\DisplayWidth = newWidth
    WeActDisplay\DisplayHeight = newHeight
    WeActDisplay\BufferSize = newWidth * newHeight * WeActDisplay\BytesPerPixel
    
    ; Clear buffers after orientation change
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      FillMemory(WeActDisplay\FrameBuffer, WeActDisplay\BufferSize, 0)
      FillMemory(WeActDisplay\BackBuffer, WeActDisplay\BufferSize, 0)
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
  ; The 3.5-inch reference protocol does not document a reset command.
  If WeActDisplay\Model = #WEACT_MODEL_350
    WeActDisplay\LastError = "System reset is not supported by the documented 3.5-inch protocol"
    ProcedureReturn #False
  EndIf
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
    ; Keep the software buffers consistent with the hardware fill.
    WeAct_ClearBuffer(Color)
    If WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer
      CopyMemory(WeActDisplay\BackBuffer, WeActDisplay\FrameBuffer, WeActDisplay\BufferSize)
    EndIf
    ProcedureReturn #True
  EndIf
  
  WeActDisplay\LastError = "Failed to fill screen"
  ProcedureReturn #False
EndProcedure

; { HELPER FUNCTIONS }

Procedure.s WeAct_GetInfo()
  ; Get display information as formatted string
  If WeActDisplay\IsConnected
    Protected modelName.s = "0.96-inch"
    If WeActDisplay\Model = #WEACT_MODEL_350 : modelName = "3.5-inch" : EndIf
    ProcedureReturn "WeAct Display FS " + modelName + " (" + WeActDisplay\PortName + ") " +
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

Procedure.i WeAct_SetSensorPeriod(PeriodMs.i)
  ; 3.5-inch firmware: 0 disables reports, otherwise 500..65535 ms.
  Dim Command.a(3)
  If WeActDisplay\Model <> #WEACT_MODEL_350
    WeActDisplay\LastError = "Sensors are not supported by the 0.96-inch display"
    ProcedureReturn #False
  EndIf
  If PeriodMs <> 0 And (PeriodMs < 500 Or PeriodMs > 65535)
    WeActDisplay\LastError = "Sensor period must be 0 or 500..65535 ms"
    ProcedureReturn #False
  EndIf
  Command(0) = $06
  Command(1) = PeriodMs & $FF
  Command(2) = (PeriodMs >> 8) & $FF
  Command(3) = $0A
  If Not SendCommand(@Command(), 4) : ProcedureReturn #False : EndIf
  WeActDisplay\SensorPeriod = PeriodMs
  If PeriodMs = 0 : WeActDisplay\SensorValid = #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.s WeAct_GetFirmwareVersion(TimeoutMs.i = 1000)
  ; The 3.5-inch firmware returns a 19-byte reply to C2 0A.
  Protected started.q, received.i, discard.a, character.a, i.i
  Protected version.s = ""
  Dim Command.a(1)

  If WeActDisplay\Model <> #WEACT_MODEL_350
    WeActDisplay\LastError = "Firmware version query is supported only by the 3.5-inch display"
    ProcedureReturn ""
  EndIf
  If Not WeActDisplay\IsConnected
    WeActDisplay\LastError = "Display not connected"
    ProcedureReturn ""
  EndIf
  If TimeoutMs < 1 : TimeoutMs = 1000 : EndIf
  If TimeoutMs > 5000 : TimeoutMs = 5000 : EndIf

  ; A previous sensor report must not be mistaken for a version response.
  While AvailableSerialPortInput(WeActDisplay\SerialPort) > 0
    If ReadSerialPortData(WeActDisplay\SerialPort, @discard, 1) <> 1 : Break : EndIf
  Wend

  Command(0) = $C2
  Command(1) = $0A
  If Not SendCommand(@Command(), 2)
    ProcedureReturn ""
  EndIf

  Dim Response.a(18)
  started = ElapsedMilliseconds()
  While received < 19 And ElapsedMilliseconds() - started < TimeoutMs
    If AvailableSerialPortInput(WeActDisplay\SerialPort) > 0
      If ReadSerialPortData(WeActDisplay\SerialPort, @Response(received), 1) = 1
        received + 1
      EndIf
    Else
      Delay(5)
    EndIf
  Wend

  If received <> 19
    WeActDisplay\LastError = "Timed out waiting for the firmware version"
    ProcedureReturn ""
  EndIf

  For i = 1 To 8
    character = Response(i)
    If character >= 32 And character <= 126
      version + Chr(character)
    EndIf
  Next
  version = Trim(version)
  If version = ""
    WeActDisplay\LastError = "Firmware version response is invalid"
    ProcedureReturn ""
  EndIf

  WeActDisplay\LastError = ""
  ProcedureReturn version
EndProcedure

Procedure.i WeAct_PollSensor()
  ; Nonblocking parser for the documented 86 LL HH LL HH 0A packet.
  Protected value.a, count.i, temperature.i, humidity.i
  If WeActDisplay\Model <> #WEACT_MODEL_350 Or Not WeActDisplay\IsConnected
    ProcedureReturn #False
  EndIf
  count = AvailableSerialPortInput(WeActDisplay\SerialPort)
  While count > 0
    If ReadSerialPortData(WeActDisplay\SerialPort, @value, 1) <> 1 : Break : EndIf
    If WeActDisplay\SensorPosition = 0
      If value = $86
        WeActDisplay\SensorPacket[0] = value
        WeActDisplay\SensorPosition = 1
      EndIf
    Else
      WeActDisplay\SensorPacket[WeActDisplay\SensorPosition] = value
      WeActDisplay\SensorPosition + 1
      If WeActDisplay\SensorPosition = 6
        WeActDisplay\SensorPosition = 0
        If WeActDisplay\SensorPacket[5] = $0A
          temperature = WeActDisplay\SensorPacket[1] & $FF | ((WeActDisplay\SensorPacket[2] & $FF) << 8)
          humidity = WeActDisplay\SensorPacket[3] & $FF | ((WeActDisplay\SensorPacket[4] & $FF) << 8)
          If humidity >= 0 And humidity <= 10000
            WeActDisplay\Temperature = temperature / 100.0
            WeActDisplay\Humidity = humidity / 100.0
            WeActDisplay\SensorLastTime = ElapsedMilliseconds()
            WeActDisplay\SensorValid = #True
          EndIf
        EndIf
      EndIf
    EndIf
    count - 1
  Wend
  ProcedureReturn WeActDisplay\SensorValid
EndProcedure

Procedure.i WeAct_GetSensorValues(*Temperature.Float, *Humidity.Float, MaxAgeMs.i = 5000)
  If WeActDisplay\Model <> #WEACT_MODEL_350 Or Not WeActDisplay\IsConnected
    WeActDisplay\LastError = "Sensors unavailable"
    ProcedureReturn #False
  EndIf
  WeAct_PollSensor()
  If Not WeActDisplay\SensorValid Or ElapsedMilliseconds() - WeActDisplay\SensorLastTime > MaxAgeMs
    WeActDisplay\LastError = "No recent sensor report"
    ProcedureReturn #False
  EndIf
  If *Temperature : *Temperature\f = WeActDisplay\Temperature : EndIf
  If *Humidity : *Humidity\f = WeActDisplay\Humidity : EndIf
  ProcedureReturn #True
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

Procedure.i WeAct_InitNoClear(PortName.s = "COM3", Model.i = #WEACT_MODEL_096)
  ; Preserve the physical screen. Fresh software buffers start black because
  ; the device has no documented readback command.
  ProcedureReturn WeAct_InitInternal(PortName, Model, #True)
EndProcedure

; { CLEANUP }

Procedure WeAct_Cleanup()
  ; Complete cleanup of all resources
  WeAct_CleanupFonts()
  WeAct_Close()
EndProcedure

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 237
; FirstLine = 228
; Folding = ----------
; EnableXP

