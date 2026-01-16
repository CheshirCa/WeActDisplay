; =============================================
; WeAct Display Video Player for Windows
; Version 1.0
; Uses ffmpeg to extract and display video frames
; =============================================

XIncludeFile "WeActDisplay.pbi"
OpenConsole()
EnableExplicit

; Global variables
Global verbose.i = #False
Global loopMode.i = #False
Global scaleMode.i = 0  ; 0=fit, 1=width, 2=height
Global videoFile.s = ""
Global comPort.s = "COM3"
Global running.i = #True
Global tempDir.s = ""

; Video playback variables
Global displayWidth.i = 160
Global displayHeight.i = 80
Global frameCount.i = 0
Global currentFrame.i = 0
Global fps.f = 30.0  ; Will be updated based on user input or default

UseJPEGImageDecoder()
UsePNGImageDecoder()

; =============================================
; Shows help information for command line usage
; =============================================
Procedure ShowHelp()
  PrintN("WeAct Display Video Player v1.0")
  PrintN("")
  PrintN("Usage: WeActVideoPlayer /p:<port> <video_file> [/loop] [/w|/h] [/f:<fps>]")
  PrintN("")
  PrintN("Required:")
  PrintN("  /p:<port>       COM port (e.g., /p:3 for COM3)")
  PrintN("  <video_file>    Path to video file (.mp4, .avi, .wmv)")
  PrintN("")
  PrintN("Optional:")
  PrintN("  /loop           Loop playback continuously")
  PrintN("  /w              Scale to fit width")
  PrintN("  /h              Scale to fit height")
  PrintN("  /f:<fps>        Set playback frames per second (default: 10)")
  PrintN("")
  PrintN("Requirements:")
  PrintN("  ffmpeg.exe must be in PATH or same directory")
  PrintN("")
  PrintN("Examples:")
  PrintN("  WeActVideoPlayer /p:3 video.mp4")
  PrintN("  WeActVideoPlayer /p:3 /loop /w /f:15 video.mp4")
  PrintN("")
  PrintN("Controls:")
  PrintN("  Ctrl+C - Stop playback")
EndProcedure

; =============================================
; Parses command line arguments and validates inputs
; Returns: #True if successful, #False if invalid
; =============================================
Procedure ParseCommandLine()
  Protected paramCount = CountProgramParameters()
  Protected i, param.s, paramValue.s
  
  If paramCount < 2
    ShowHelp()
    ProcedureReturn #False
  EndIf
  
  For i = 0 To paramCount - 1
    param = ProgramParameter(i)
    
    ; Check for COM port parameter
    If Left(param, 3) = "/p:" Or Left(param, 3) = "-p:"
      comPort = "COM" + Mid(param, 4)
      
    ; Check for loop mode
    ElseIf param = "/loop" Or param = "-loop"
      loopMode = #True
      
    ; Check for width scaling
    ElseIf param = "/w" Or param = "-w"
      scaleMode = 1
      
    ; Check for height scaling
    ElseIf param = "/h" Or param = "-h"
      scaleMode = 2
      
    ; Check for FPS parameter
    ElseIf Left(param, 3) = "/f:" Or Left(param, 3) = "-f:"
      paramValue = Mid(param, 4)
      fps = ValF(paramValue)
      If fps <= 0
        PrintN("Warning: Invalid FPS value, using default (10)")
        fps = 10.0
      EndIf
      
    ; Check for verbose mode
    ElseIf param = "/v" Or param = "-v"
      verbose = #True
      
    ; Check for help request
    ElseIf param = "/?" Or param = "-?"
      ShowHelp()
      ProcedureReturn #False
      
    ; Treat as video file path
    Else
      If videoFile = ""
        ; Remove surrounding quotes if present
        videoFile = param
        If Left(videoFile, 1) = Chr(34)
          videoFile = Mid(videoFile, 2)
        EndIf
        If Right(videoFile, 1) = Chr(34)
          videoFile = Left(videoFile, Len(videoFile) - 1)
        EndIf
      EndIf
    EndIf
  Next
  
  ; Validate required parameters
  If comPort = "COM"
    PrintN("Error: COM port not specified")
    ProcedureReturn #False
  EndIf
  
  If videoFile = ""
    PrintN("Error: Video file not specified")
    ProcedureReturn #False
  EndIf
  
  If FileSize(videoFile) <= 0
    PrintN("Error: Video file not found: " + videoFile)
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

; =============================================
; Checks if ffmpeg is available in system PATH
; Returns: #True if found, #False if not found
; =============================================
Procedure CheckFFmpeg()
  Protected result.i
  
  ; Execute ffmpeg -version command to test availability
  result = RunProgram("ffmpeg", "-version", "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If result
    CloseProgram(result)
    ProcedureReturn #True
  EndIf
  
  PrintN("Error: ffmpeg.exe not found")
  PrintN("Please install ffmpeg and add it to PATH")
  PrintN("Download from: https://ffmpeg.org/download.html")
  ProcedureReturn #False
EndProcedure

; =============================================
; Extracts frames from video using ffmpeg
; Creates temporary directory and saves frames as JPEG
; Returns: #True if successful, #False if failed
; =============================================
Procedure ExtractFrames()
  ; Create unique temporary directory using timestamp
  tempDir = GetTemporaryDirectory() + "weact_video_" + Str(ElapsedMilliseconds()) + "\"
  CreateDirectory(tempDir)
  
  If verbose
    PrintN("Extracting frames to: " + tempDir)
    PrintN("This may take a while...")
  EndIf
  
  ; Build ffmpeg command:
  ; -i : input file
  ; -vf : video filter with scaling to display dimensions
  ; -r : frame extraction rate (uses user-specified FPS)
  ; Output: numbered JPEG files in temporary directory
  Protected cmd.s = "-i " + Chr(34) + videoFile + Chr(34) + " "
  cmd + "-vf " + Chr(34) + "scale=" + Str(displayWidth) + ":" + Str(displayHeight) + ":force_original_aspect_ratio=decrease" + Chr(34) + " "
  cmd + "-r " + StrF(fps) + " "  ; Use user-specified FPS
  cmd + Chr(34) + tempDir + "frame_%04d.jpg" + Chr(34)
  
  ; Execute ffmpeg to extract frames
  Protected program = RunProgram("ffmpeg", cmd, "", #PB_Program_Open | #PB_Program_Wait | #PB_Program_Hide)
  
  If Not program
    PrintN("Error: Failed to extract frames")
    ProcedureReturn #False
  EndIf
  
  ; Wait for ffmpeg to complete extraction
  While ProgramRunning(program)
    Delay(100)
  Wend
  
  CloseProgram(program)
  
  ; Count how many frames were extracted
  Protected dirID = ExamineDirectory(#PB_Any, tempDir, "*.jpg")
  If dirID
    While NextDirectoryEntry(dirID)
      If DirectoryEntryType(dirID) = #PB_DirectoryEntry_File
        frameCount + 1
      EndIf
    Wend
    FinishDirectory(dirID)
  EndIf
  
  ; Validate extraction results
  If frameCount = 0
    PrintN("Error: No frames extracted")
    ProcedureReturn #False
  EndIf
  
  If verbose
    PrintN("Extracted " + Str(frameCount) + " frames")
  EndIf
  
  ; Keep original fps value (user-specified or default)
  ; No longer resetting to 10.0
  
  ProcedureReturn #True
EndProcedure

; =============================================
; Displays a single video frame on the display
; Parameters: frameNum - frame number to display
; Returns: #True if successful, #False if failed
; =============================================
Procedure DisplayVideoFrame(frameNum.i)
  ; Construct full path to frame file
  Protected framePath.s = tempDir + "frame_" + RSet(Str(frameNum), 4, "0") + ".jpg"
  
  ; Check if frame file exists
  If FileSize(framePath) <= 0
    ProcedureReturn #False
  EndIf
  
  ; Load the JPEG frame into memory
  Protected frameImage = LoadImage(#PB_Any, framePath)
  If Not frameImage
    ProcedureReturn #False
  EndIf
  
  ; Variables for scaling calculations
  Protected targetWidth.i, targetHeight.i
  Protected x.i, y.i
  Protected scaleX.f, scaleY.f, scale.f
  Protected imgWidth.i, imgHeight.i
  
  ; Get original frame dimensions
  imgWidth = ImageWidth(frameImage)
  imgHeight = ImageHeight(frameImage)
  
  ; Calculate scaling based on selected mode
  Select scaleMode
    Case 0  ; Fit entire frame within display (maintain aspect ratio)
      scaleX = displayWidth / imgWidth
      scaleY = displayHeight / imgHeight
      scale = scaleX
      If scaleY < scale
        scale = scaleY
      EndIf
      targetWidth = imgWidth * scale
      targetHeight = imgHeight * scale
      
    Case 1  ; Fit to width, crop height if needed
      scale = displayWidth / imgWidth
      targetWidth = displayWidth
      targetHeight = imgHeight * scale
      If targetHeight > displayHeight
        targetHeight = displayHeight
      EndIf
      
    Case 2  ; Fit to height, crop width if needed
      scale = displayHeight / imgHeight
      targetHeight = displayHeight
      targetWidth = imgWidth * scale
      If targetWidth > displayWidth
        targetWidth = displayWidth
      EndIf
  EndSelect
  
  ; Center the scaled image on display
  x = (displayWidth - targetWidth) / 2
  y = (displayHeight - targetHeight) / 2
  
  ; Clear display buffer to black
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Create temporary image for scaling operations
  Protected tempImage = CreateImage(#PB_Any, targetWidth, targetHeight)
  If tempImage
    ; Draw original frame scaled to target dimensions
    If StartDrawing(ImageOutput(tempImage))
      DrawImage(ImageID(frameImage), 0, 0, targetWidth, targetHeight)
      StopDrawing()
    EndIf
    
    ; Process each pixel of the scaled image
    If StartDrawing(ImageOutput(tempImage))
      Protected sx, sy, pixelColor, r, g, b
      
      ; Iterate through all pixels in the scaled image
      For sy = 0 To targetHeight - 1
        For sx = 0 To targetWidth - 1
          ; Get pixel color at current position
          pixelColor = Point(sx, sy)
          r = Red(pixelColor)
          g = Green(pixelColor)
          b = Blue(pixelColor)
          ; Convert RGB to RGB565 and draw to buffer
          WeAct_DrawPixelBuffer(x + sx, y + sy, RGBToRGB565(r, g, b))
        Next
      Next
      StopDrawing()
    EndIf
    
    ; Clean up temporary image
    FreeImage(tempImage)
  EndIf
  
  ; Clean up original frame image
  FreeImage(frameImage)
  
  ; Send updated buffer to display
  ProcedureReturn WeAct_UpdateDisplay()
EndProcedure

; =============================================
; Main video playback loop
; Controls frame timing and looping behavior
; =============================================
Procedure PlayVideo()
  ; Calculate delay between frames based on FPS
  Protected frameDelay.i = Int(1000.0 / fps)  ; Delay in milliseconds
  Protected lastFrameTime.i
  
  Repeat
    ; Start from first frame
    currentFrame = 1
    
    ; Play all frames in sequence
    While currentFrame <= frameCount And running
      ; Record start time of frame display
      lastFrameTime = ElapsedMilliseconds()
      
      ; Display current frame
      DisplayVideoFrame(currentFrame)
      
      ; Calculate time elapsed for this frame
      Protected elapsedTime.i = ElapsedMilliseconds() - lastFrameTime
      
      ; Calculate remaining time to maintain FPS
      Protected remainingTime.i = frameDelay - elapsedTime
      
      ; Apply delay only if we're ahead of schedule
      If remainingTime > 0
        Delay(remainingTime)
      EndIf
      
      ; Move to next frame
      currentFrame + 1
    Wend
    
    ; Exit if not in loop mode
    If Not loopMode
      running = #False
    EndIf
    
  Until Not running
  
  ProcedureReturn #True
EndProcedure

; =============================================
; Cleans up temporary files and directories
; Removes extracted frames after playback
; =============================================
Procedure Cleanup()
  If tempDir <> ""
    If verbose
      PrintN("Cleaning up temporary files...")
    EndIf
    
    ; Delete all JPEG frame files
    Protected dirID = ExamineDirectory(#PB_Any, tempDir, "*.jpg")
    If dirID
      While NextDirectoryEntry(dirID)
        If DirectoryEntryType(dirID) = #PB_DirectoryEntry_File
          DeleteFile(tempDir + DirectoryEntryName(dirID))
        EndIf
      Wend
      FinishDirectory(dirID)
    EndIf
    
    ; Remove temporary directory
    ; Windows-specific command for silent removal
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      RunProgram("cmd", "/c rmdir /q " + Chr(34) + tempDir + Chr(34), "", #PB_Program_Wait | #PB_Program_Hide)
    CompilerElse
      RunProgram("rmdir", tempDir, "", #PB_Program_Wait | #PB_Program_Hide)
    CompilerEndIf
  EndIf
EndProcedure

; =============================================
; Main program entry point
; Coordinates all program operations
; =============================================
Procedure Main()
  ; Parse and validate command line arguments
  If Not ParseCommandLine()
    End 1
  EndIf
  
  ; Check for ffmpeg availability
  If Not CheckFFmpeg()
    End 1
  EndIf
  
  ; Initialize display connection
  If Not WeAct_Init(comPort)
    PrintN("Error: Cannot initialize display on " + comPort)
    End 1
  EndIf
  
  ; Get display dimensions from hardware
  displayWidth = WeAct_GetDisplayWidth()
  displayHeight = WeAct_GetDisplayHeight()
  
  If verbose
    PrintN("Display: " + Str(displayWidth) + "x" + Str(displayHeight))
    PrintN("Playback FPS: " + StrF(fps))
  EndIf
  
  ; Set display brightness to maximum
  WeAct_SetBrightness(255, 100)
  
  ; Extract frames from video file
  If Not ExtractFrames()
    WeAct_Cleanup()
    End 1
  EndIf
  
  If verbose
    PrintN("Starting playback...")
  EndIf
  
  ; Start video playback
  PlayVideo()
  
  ; Cleanup sequence
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateDisplay()
  WeAct_Cleanup()
  Cleanup()
  
  If verbose
    PrintN("Playback finished")
  EndIf
  
  ; Exit successfully
  End 0
EndProcedure

; Start the program
Main()

; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; EnableXP
; Executable = WeActVideoPlayer.exe
; IDE Options = PureBasic 6.30 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 477
; FirstLine = 403
; Folding = --
; EnableXP
; Executable = WeActVideoPlayer.exe