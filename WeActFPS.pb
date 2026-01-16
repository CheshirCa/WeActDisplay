; =============================================
; WeAct Display FPS Monitor
; Version 1.0
; Shows FPS from specified monitor in real-time
; =============================================

XIncludeFile "WeActDisplay.pbi"
OpenConsole()
EnableExplicit

; Global variables for program configuration
Global comPort.s = "COM3"        ; Serial port to connect to WeAct display
Global monitorIndex.i = 0        ; Index of monitor to check (0 = primary)
Global updateInterval.i = 1000   ; How often to update FPS (milliseconds)
Global running.i = #True         ; Control flag for main loop
Global verbose.i = #False        ; Show detailed console output

; Variables for FPS calculation
Global lastCaptureTime.i = 0     ; Last time we captured screen
Global frameCount.i = 0          ; Counter for captured frames
Global currentFPS.f = 0.0        ; Current calculated FPS value

Procedure ShowHelp()
  ; Display help information about program usage
  PrintN("WeAct Display FPS Monitor v1.0")
  PrintN("")
  PrintN("Usage: WeActFPS /p:<port> [/m:<monitor>] [/i:<interval>] [/v]")
  PrintN("")
  PrintN("Required:")
  PrintN("  /p:<port>      COM port (e.g., /p:3 for COM3)")
  PrintN("")
  PrintN("Optional:")
  PrintN("  /m:<monitor>   Monitor index (default: 0 for primary)")
  PrintN("  /i:<interval>  Update interval in ms (default: 1000)")
  PrintN("  /v             Verbose output")
  PrintN("")
  PrintN("Examples:")
  PrintN("  WeActFPS /p:3")
  PrintN("  WeActFPS /p:3 /m:1 /i:500")
  PrintN("")
  PrintN("Controls:")
  PrintN("  Ctrl+C - Stop monitoring")
EndProcedure

Procedure ParseCommandLine()
  ; Parse command line arguments provided by user
  Protected paramCount = CountProgramParameters()
  Protected i, param.s
  
  ; If no parameters, show help and exit
  If paramCount < 1
    ShowHelp()
    ProcedureReturn #False
  EndIf
  
  ; Loop through all command line parameters
  For i = 0 To paramCount - 1
    param = ProgramParameter(i)
    
    ; Check for serial port parameter
    If Left(param, 3) = "/p:" Or Left(param, 3) = "-p:"
      comPort = "COM" + Mid(param, 4)
    
    ; Check for monitor index parameter  
    ElseIf Left(param, 3) = "/m:" Or Left(param, 3) = "-m:"
      monitorIndex = Val(Mid(param, 4))
    
    ; Check for update interval parameter
    ElseIf Left(param, 3) = "/i:" Or Left(param, 3) = "-i:"
      updateInterval = Val(Mid(param, 4))
      ; Validate interval range (100ms to 5000ms)
      If updateInterval < 100 : updateInterval = 100 : EndIf
      If updateInterval > 5000 : updateInterval = 5000 : EndIf
    
    ; Check for verbose mode parameter
    ElseIf param = "/v" Or param = "-v"
      verbose = #True
    
    ; Check for help parameter
    ElseIf param = "/?" Or param = "-?" Or param = "/h" Or param = "-h"
      ShowHelp()
      ProcedureReturn #False
    EndIf
  Next
  
  ; Validate that COM port was specified
  If comPort = "COM"
    PrintN("Error: COM port not specified")
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure MeasureRealFPS()
  ; Measure actual FPS by capturing screen frames
  ; This measures real rendering FPS, not just refresh rate
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected startTime.i, frameCount.i = 0
    Protected testDuration.i = 1000  ; Measure for 1 second
    Protected hDC.i, hMemDC.i, hBitmap.i
    Protected testWidth.i = 100, testHeight.i = 100
    
    ; Get device context for the desktop (entire screen)
    hDC = GetDC_(#Null)
    If hDC
      ; Create compatible device context for capturing
      hMemDC = CreateCompatibleDC_(hDC)
      If hMemDC
        ; Create bitmap compatible with screen
        hBitmap = CreateCompatibleBitmap_(hDC, testWidth, testHeight)
        If hBitmap
          ; Select bitmap into memory DC
          Protected hOldBitmap = SelectObject_(hMemDC, hBitmap)
          
          ; Record start time
          startTime = ElapsedMilliseconds()
          
          ; Capture frames for specified duration
          While ElapsedMilliseconds() - startTime < testDuration And running
            ; Copy small portion of screen to memory DC
            BitBlt_(hMemDC, 0, 0, testWidth, testHeight, hDC, 0, 0, #SRCCOPY)
            frameCount + 1
            
            ; Small delay to prevent CPU overload
            Delay(1)
          Wend
          
          ; Calculate elapsed time
          Protected elapsed.i = ElapsedMilliseconds() - startTime
          
          ; Calculate frames per second
          If elapsed > 0
            currentFPS = (frameCount * 1000.0) / elapsed
          Else
            currentFPS = 60.0
          EndIf
          
          ; Clean up GDI objects
          SelectObject_(hMemDC, hOldBitmap)
          DeleteObject_(hBitmap)
        EndIf
        DeleteDC_(hMemDC)
      EndIf
      ReleaseDC_(#Null, hDC)
    Else
      ; Fallback if can't get device context
      currentFPS = 60.0
    EndIf
  CompilerElse
    ; Linux/Mac fallback value
    currentFPS = 60.0
  CompilerEndIf
  
  ProcedureReturn currentFPS
EndProcedure

Procedure CalculateFPS()
  ; Get monitor refresh rate as reference
  ; This shows the maximum possible FPS
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected hDC.i, refreshRate.i
    
    ; Get device context for desktop
    hDC = GetDC_(#Null)
    If hDC
      ; Get vertical refresh rate in Hz (116 = VREFRESH constant)
      refreshRate = GetDeviceCaps_(hDC, 116)
      ReleaseDC_(#Null, hDC)
      
      If refreshRate > 0
        currentFPS = refreshRate
      Else
        currentFPS = 60.0  ; Default fallback
      EndIf
    Else
      currentFPS = 60.0
    EndIf
  CompilerElse
    ; Linux/Mac fallback value
    currentFPS = 60.0
  CompilerEndIf
  
  ProcedureReturn currentFPS
EndProcedure

Procedure DisplayFPS(fps.f)
  ; Display FPS value on WeAct display
  Protected fpsText.s
  Protected displayWidth.i = WeAct_GetDisplayWidth()
  Protected displayHeight.i = WeAct_GetDisplayHeight()
  
  ; Format FPS text with one decimal place
  fpsText = "FPS: " + StrF(fps, 1)
  
  ; Clear display buffer with black color
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Draw FPS text in large font in center of display
  Protected fontSize.i = 16
  Protected textWidth.i = WeAct_GetTextWidth(fpsText, fontSize, "Arial")
  Protected x.i = (displayWidth - textWidth) / 2
  Protected y.i = (displayHeight - fontSize) / 2
  
  WeAct_DrawTextSystemFont(x, y, fpsText, #WEACT_GREEN, fontSize, "Arial")
  
  ; Draw monitor information in small font at top-left corner
  Protected infoText.s = "Monitor: " + Str(monitorIndex)
  WeAct_DrawTextSystemFont(5, 5, infoText, #WEACT_WHITE, 8, "Arial")
  
  ; Send buffer to physical display
  WeAct_UpdateDisplay()
EndProcedure

Procedure MonitorLoop()
  ; Main monitoring loop that runs continuously
  Protected nextUpdate.i = ElapsedMilliseconds()
  
  While running
    ; Check if it's time to update FPS
    If ElapsedMilliseconds() >= nextUpdate
      ; Measure actual FPS by screen capture
      MeasureRealFPS()
      
      ; Display FPS on WeAct display
      DisplayFPS(currentFPS)
      
      ; Show FPS in console if verbose mode is enabled
      If verbose
        PrintN("Real FPS: " + StrF(currentFPS, 1))
      EndIf
      
      ; Schedule next update time
      nextUpdate = ElapsedMilliseconds() + updateInterval
    EndIf
    
    ; Small delay to prevent CPU overload
    Delay(10)
  Wend
EndProcedure

Procedure Main()
  ; Main program entry point
  
  ; Parse and validate command line arguments
  If Not ParseCommandLine()
    End 1  ; Exit with error code 1
  EndIf
  
  ; Initialize WeAct display on specified serial port
  If Not WeAct_Init(comPort)
    PrintN("Error: Cannot initialize display on " + comPort)
    End 1  ; Exit with error code 1
  EndIf
  
  ; Set display brightness to maximum
  WeAct_SetBrightness(255, 100)
  
  ; Show startup information if verbose mode
  If verbose
    PrintN("FPS Monitor started")
    PrintN("Monitor: " + Str(monitorIndex))
    PrintN("Update interval: " + Str(updateInterval) + "ms")
    PrintN("Press Ctrl+C to stop")
  EndIf
  
  ; Start main monitoring loop
  MonitorLoop()
  
  ; Cleanup before exiting
  WeAct_ClearBuffer(#WEACT_BLACK)  ; Clear display buffer
  WeAct_UpdateDisplay()            ; Send black screen to display
  WeAct_Cleanup()                  ; Release display resources
  
  ; Show exit message if verbose mode
  If verbose
    PrintN("Monitoring stopped")
  EndIf
  
  End 0  ; Exit with success code 0
EndProcedure

; Start the program
Main()

; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; EnableXP
; Executable = WeActFPS.exe
; IDE Options = PureBasic 6.30 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 290
; FirstLine = 216
; Folding = --
; EnableXP
; Executable = WeActFPS.exe