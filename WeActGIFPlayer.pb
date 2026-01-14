; =============================================
; WeAct Display GIF Player for Windows
; Version 1.2
; =============================================

IncludeFile "WeActDisplay.pbi"  ; Include the WeAct display library
OpenConsole()
EnableExplicit

; Global variable for verbose output mode (show detailed messages)
Global verbose.i = #False

; Enable GIF image decoder to handle GIF files
UseGIFImageDecoder()

; Structure to store information about each GIF frame
Structure GIF_Frame
  Image.i      ; Handle to the frame image
  Delay.i      ; Delay for this frame in milliseconds
  Width.i      ; Width of the frame in pixels
  Height.i     ; Height of the frame in pixels
EndStructure

; Global variables
Global NewList Frames.GIF_Frame()  ; List to store all GIF frames
Global SpeedFactor.f = 1.0         ; Speed multiplier (0.1-5.0)
Global TotalFrames.i = 0           ; Total number of frames loaded
Global CurrentFrame.i = 0          ; Currently displayed frame index
Global Running.i = #True           ; Flag to control main loop
Global DisplayWidth.i              ; Width of the display
Global DisplayHeight.i             ; Height of the display
Global LoopMode.i = #False         ; Flag for loop mode (repeat animation)
Global LoopsCompleted.i = 0        ; Counter for completed loops

; =============================================
; { HELPER FUNCTIONS }
; =============================================

Procedure GetScreenSize(*Width.Integer, *Height.Integer)
  ; Get display dimensions from the library
  Protected width.i, height.i
  
  width = WeAct_GetDisplayWidth()    ; Get current display width
  height = WeAct_GetDisplayHeight()  ; Get current display height
  
  If width = 0 Or height = 0
    ; Use default dimensions if library returns invalid values
    width = #WEACT_DISPLAY_WIDTH
    height = #WEACT_DISPLAY_HEIGHT
  EndIf
  
  ; Store results in output parameters
  *Width\i = width
  *Height\i = height
EndProcedure

Procedure.f Clamp(value.f, min.f, max.f)
  ; Limit a value to a specified range
  If value < min
    ProcedureReturn min
  ElseIf value > max
    ProcedureReturn max
  Else
    ProcedureReturn value
  EndIf
EndProcedure

Procedure LoadAnimatedGIF(Filename.s)
  ; Load an animated GIF file and extract all frames
  Protected gifImage.i, frameCount.i
  Protected i.i, frameImage.i
  Protected width.i, height.i, delay.i
  
  ; Check if file exists
  If FileSize(Filename) <= 0
    ProcedureReturn #False
  EndIf
  
  ; Load the GIF image
  gifImage = LoadImage(#PB_Any, Filename)
  If Not gifImage
    ProcedureReturn #False
  EndIf
  
  ; Get total number of frames in the GIF
  frameCount = ImageFrameCount(gifImage)
  
  If frameCount <= 0
    ; Not an animated GIF - treat as single frame
    AddElement(Frames())
    Frames()\Image = gifImage        ; Use the loaded image directly
    Frames()\Delay = 100             ; Default delay of 100ms
    Frames()\Width = ImageWidth(gifImage)
    Frames()\Height = ImageHeight(gifImage)
    TotalFrames = 1
    ProcedureReturn #True
  EndIf
  
  ; Extract each frame from the animated GIF
  For i = 0 To frameCount - 1
    ; Set current frame index
    SetImageFrame(gifImage, i)
    
    ; Get frame delay in milliseconds
    delay = GetImageFrameDelay(gifImage)
    If delay <= 0
      delay = 10  ; Minimum delay to prevent instant display
    EndIf
    
    ; Get frame dimensions
    width = ImageWidth(gifImage)
    height = ImageHeight(gifImage)
    
    ; Create separate image for this frame
    frameImage = CreateImage(#PB_Any, width, height)
    If frameImage
      If StartDrawing(ImageOutput(frameImage))
        ; Copy the frame from GIF to our image
        DrawImage(ImageID(gifImage), 0, 0, width, height)
        StopDrawing()
      EndIf
      
      ; Add frame to the list
      AddElement(Frames())
      Frames()\Image = frameImage
      Frames()\Delay = delay
      Frames()\Width = width
      Frames()\Height = height
      TotalFrames + 1
    EndIf
  Next
  
  ; Free the original GIF image
  FreeImage(gifImage)
  
  If TotalFrames = 0
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure DisplayFrame(FrameIndex.i)
  ; Display a specific frame on the WeAct display
  Protected *frame.GIF_Frame
  Protected targetWidth.i, targetHeight.i
  Protected x.i, y.i
  Protected scaleX.f, scaleY.f, scale.f
  
  ; Validate frame index
  If FrameIndex < 0 Or FrameIndex >= TotalFrames
    ProcedureReturn #False
  EndIf
  
  ; Get pointer to the requested frame
  SelectElement(Frames(), FrameIndex)
  *frame = @Frames()
  
  ; Calculate scaling to fit display while maintaining aspect ratio
  ; scaleX: horizontal scaling factor
  ; scaleY: vertical scaling factor
  scaleX = DisplayWidth / *frame\Width
  scaleY = DisplayHeight / *frame\Height
  
  ; Use the smaller scaling factor to ensure entire image fits
  scale = scaleX
  If scaleY < scale
    scale = scaleY
  EndIf
  
  ; Calculate target dimensions
  targetWidth = *frame\Width * scale
  targetHeight = *frame\Height * scale
  
  ; Calculate position to center image on display
  x = (DisplayWidth - targetWidth) / 2
  y = (DisplayHeight - targetHeight) / 2
  
  ; Clear the back buffer (prepare for new frame)
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Create temporary image for scaling
  Protected tempImage = CreateImage(#PB_Any, targetWidth, targetHeight)
  If tempImage
    ; Draw scaled frame to temporary image
    If StartDrawing(ImageOutput(tempImage))
      DrawImage(ImageID(*frame\Image), 0, 0, targetWidth, targetHeight)
      StopDrawing()
    EndIf
    
    ; Copy pixels from temporary image to display buffer
    If StartDrawing(ImageOutput(tempImage))
      Protected sourceX, sourceY, pixelColor, r, g, b
      
      ; Loop through all pixels in the scaled image
      For sourceY = 0 To targetHeight - 1
        For sourceX = 0 To targetWidth - 1
          ; Get pixel color at current position
          pixelColor = Point(sourceX, sourceY)
          
          ; Extract RGB components
          r = Red(pixelColor)
          g = Green(pixelColor)
          b = Blue(pixelColor)
          
          ; Convert to RGB565 and draw to display buffer
          WeAct_DrawPixelBuffer(x + sourceX, y + sourceY, RGBToRGB565(r, g, b))
        Next
      Next
      StopDrawing()
    EndIf
    
    ; Free the temporary image
    FreeImage(tempImage)
  EndIf
  
  ; Send buffer to physical display
  If Not WeAct_UpdateDisplay()
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure Cleanup()
  ; Free all resources and close display connection
  Protected i
  
  ; Free all frame images
  ForEach Frames()
    If Frames()\Image
      FreeImage(Frames()\Image)
    EndIf
  Next
  
  ; Clear the frames list
  ClearList(Frames())
  
  ; Close display connection and free resources
  WeAct_Cleanup()
EndProcedure

Procedure SignalHandler()
  ; Handle interrupt signal (Ctrl+C)
  Running = #False
EndProcedure

Procedure ShowHelp()
  ; Display help information about program usage
  PrintN("WeAct Display GIF Player v2.0")
  PrintN("")
  PrintN("Usage: " + GetFilePart(ProgramFilename()) + " [/p:port] [/s:speed] [/l] [/v] <gif_file>")
  PrintN("")
  PrintN("Required parameters:")
  PrintN("  <gif_file>      Path to animated GIF file")
  PrintN("")
  PrintN("Optional parameters:")
  PrintN("  /p:port         COM port number (default: 3)")
  PrintN("  /s:speed        Speed multiplier (0.1-5.0, default: 1.0)")
  PrintN("  /l              Loop playback continuously")
  PrintN("  /v              Verbose output mode")
  PrintN("  /h              Show this help")
  PrintN("")
  PrintN("Examples:")
  PrintN("  " + GetFilePart(ProgramFilename()) + " " + Chr(34) + "C:\anim.gif" + Chr(34))
  PrintN("  " + GetFilePart(ProgramFilename()) + " /p:4 /s:0.5 " + Chr(34) + "C:\anim.gif" + Chr(34))
  PrintN("")
  PrintN("Speed parameters:")
  PrintN("  /s:0.1 - Very slow (10% of original)")
  PrintN("  /s:0.5 - Slow (50% of original)")
  PrintN("  /s:1.0 - Normal speed (default)")
  PrintN("  /s:2.0 - Fast (2x speed)")
  PrintN("  /s:5.0 - Very fast (5x speed)")
  PrintN("")
  PrintN("Controls:")
  PrintN("  Ctrl+C - Stop playback and exit")
EndProcedure

; =============================================
; { MAIN PROGRAM }
; =============================================

Procedure Main()
  Protected gifFile.s = "", port.s = "COM3"
  Protected startTime.i, elapsed.i, delay.i
  Protected frameTime.i, fps.i = 0, framesDisplayed.i = 0
  Protected i, param.s 
  
  ; Check command line arguments
  If CountProgramParameters() < 1
    ShowHelp()
    End 1
  EndIf
  
  ; Parse all command line arguments
  For i = 0 To CountProgramParameters() - 1
    param = ProgramParameter(i)
    
    ; Handle port parameter (/p:port)
    If Left(param, 3) = "/p:" Or Left(param, 3) = "-p:"
      port = "COM" + Mid(param, 4)
      
    ; Handle speed parameter (/s:speed)
    ElseIf Left(param, 3) = "/s:" Or Left(param, 3) = "-s:"
      SpeedFactor = ValF(Mid(param, 4))
      SpeedFactor = Clamp(SpeedFactor, 0.1, 5.0)
      
    ; Handle loop parameter (/l)
    ElseIf param = "/l" Or param = "-l" Or param = "/loop" Or param = "-loop"
      LoopMode = #True
      
    ; Handle verbose parameter (/v)
    ElseIf param = "/v" Or param = "-v" Or param = "/verbose" Or param = "-verbose"
      verbose = #True
      
    ; Handle help parameter (/h)
    ElseIf param = "/h" Or param = "-h" Or param = "/help" Or param = "-help" Or param = "/?"
      ShowHelp()
      End 0
      
    Else
      ; If not a parameter key, assume it's the GIF filename
      If gifFile = ""
        gifFile = param
      EndIf
    EndIf
  Next
  
  ; Check if GIF file was specified
  If gifFile = ""
    ShowHelp()
    End 1
  EndIf
  
  ; Check if GIF file exists
  If FileSize(gifFile) <= 0
    End 1
  EndIf
  
  ; Register Ctrl+C handler
  OnErrorCall(@SignalHandler())
  
  ; Load the GIF file
  If Not LoadAnimatedGIF(gifFile)
    End 1
  EndIf
  
  ; Initialize WeAct display
  If Not WeAct_Init(port)
    Cleanup()
    End 1
  EndIf
  
  ; Get display dimensions
  GetScreenSize(@DisplayWidth, @DisplayHeight)
  
  ; Set maximum brightness
  WeAct_SetBrightness(255, 100)
  
  ; Main playback loop
  startTime = ElapsedMilliseconds()
  
  While Running
    ; Display current frame
    If Not DisplayFrame(CurrentFrame)
      Break
    EndIf
    
    ; Update frame counter and calculate FPS
    framesDisplayed + 1
    elapsed = ElapsedMilliseconds() - startTime
    
    ; Get delay for current frame
    SelectElement(Frames(), CurrentFrame)
    delay = Frames()\Delay
    If delay = 0 : delay = 100 : EndIf
    
    ; Apply speed multiplier to delay
    delay = Int(delay / SpeedFactor)
    If delay < 10 : delay = 10 : EndIf
    
    ; Wait for the specified delay time
    frameTime = ElapsedMilliseconds()
    While ElapsedMilliseconds() - frameTime < delay And Running
      Delay(1)  ; Small delay to prevent CPU hogging
    Wend
    
    ; Move to next frame
    CurrentFrame + 1
    
    ; Check if we've reached the end of animation
    If CurrentFrame >= TotalFrames
      If LoopMode
        ; Loop back to beginning
        CurrentFrame = 0
        LoopsCompleted + 1
      Else
        ; Stop after one pass
        Running = #False
      EndIf
    EndIf
  Wend
  
  ; Cleanup and exit
  Cleanup()
  End 0
EndProcedure

; Program entry point
Main()
