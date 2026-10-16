; WeAct video player for library 6.x. ffmpeg extracts frames before playback.

XIncludeFile "..\WeActDisplay.pbi"

EnableExplicit
OpenConsole()
UseJPEGImageDecoder()

Global ComPort.s = "COM3"
Global Model.i = #WEACT_MODEL_096
Global Orientation.i = #WEACT_LANDSCAPE
Global VideoFile.s
Global FrameRate.f = 10.0
Global DurationSeconds.f = 0.0 ; 0 = full video; /t explicitly limits extraction
Global LoopPlayback.i = #False
Global ScaleMode.i = 0 ; 0 fit, 1 width, 2 height
Global FastLZMode.i = #False
Global ChangedUpdates.i = #False
Global TempDirectory.s
Global FrameCount.i

Procedure ShowHelp()
  PrintN("WeAct Video Player")
  PrintN("Usage: WeActVideoPlayer /p:21 [/model:096|350] [/orientation:portrait|landscape|reverse-portrait|reverse-landscape] [/f:10] [/t:seconds] [/loop] [/w|/h] [/fastlz] [/changed] file.mp4")
  PrintN("ffmpeg must be available on PATH.")
  PrintN("Without /t the full video is played. /t:seconds limits extraction to 1..600 seconds.")
  PrintN("/fastlz is available only for model 350. /changed updates only the changed area.")
EndProcedure

Procedure.i ParseOrientation(Value.s)
  Select LCase(Value)
    Case "portrait" : ProcedureReturn #WEACT_PORTRAIT
    Case "landscape" : ProcedureReturn #WEACT_LANDSCAPE
    Case "reverse-portrait" : ProcedureReturn #WEACT_REVERSE_PORTRAIT
    Case "reverse-landscape" : ProcedureReturn #WEACT_REVERSE_LANDSCAPE
  EndSelect
  ProcedureReturn -1
EndProcedure

Procedure.i ParseArguments()
  Protected i.i, parameter.s, value.s
  For i = 0 To CountProgramParameters() - 1
    parameter = ProgramParameter(i)
    If Left(parameter, 3) = "/p:" Or Left(parameter, 3) = "-p:"
      ComPort = "COM" + Mid(parameter, 4)
    ElseIf Left(parameter, 7) = "/model:" Or Left(parameter, 7) = "-model:"
      value = LCase(Mid(parameter, 8))
      If value = "096" : Model = #WEACT_MODEL_096 : ElseIf value = "350" : Model = #WEACT_MODEL_350 : Else : ProcedureReturn #False : EndIf
    ElseIf Left(parameter, 13) = "/orientation:" Or Left(parameter, 13) = "-orientation:"
      Orientation = ParseOrientation(Mid(parameter, 14))
      If Orientation < 0 : ProcedureReturn #False : EndIf
    ElseIf Left(parameter, 3) = "/f:" Or Left(parameter, 3) = "-f:"
      FrameRate = ValF(Mid(parameter, 4))
      If FrameRate < 1.0 : FrameRate = 1.0 : EndIf
      If FrameRate > 60.0 : FrameRate = 60.0 : EndIf
    ElseIf Left(parameter, 3) = "/t:" Or Left(parameter, 3) = "-t:"
      DurationSeconds = ValF(Mid(parameter, 4))
      If DurationSeconds < 1.0 : DurationSeconds = 1.0 : EndIf
      If DurationSeconds > 600.0 : DurationSeconds = 600.0 : EndIf
    ElseIf parameter = "/loop" Or parameter = "-loop"
      LoopPlayback = #True
    ElseIf parameter = "/w" Or parameter = "-w"
      ScaleMode = 1
    ElseIf parameter = "/h" Or parameter = "-h"
      ScaleMode = 2
    ElseIf parameter = "/fastlz" Or parameter = "-fastlz"
      FastLZMode = #True
    ElseIf parameter = "/changed" Or parameter = "-changed"
      ChangedUpdates = #True
    ElseIf Left(parameter, 1) = "/" Or Left(parameter, 1) = "-"
      ProcedureReturn #False
    Else
      VideoFile = parameter
    EndIf
  Next
  ProcedureReturn Bool(VideoFile <> "" And FileSize(VideoFile) > 0)
EndProcedure

Procedure.i CheckFFmpeg()
  Protected process.i = RunProgram("ffmpeg", "-version", "", #PB_Program_Open | #PB_Program_Wait | #PB_Program_Hide)
  If process : CloseProgram(process) : ProcedureReturn #True : EndIf
  PrintN("Error: ffmpeg was not found on PATH")
  ProcedureReturn #False
EndProcedure

Procedure.i CreateFrameDirectory()
  Protected attempt.i
  For attempt = 0 To 99
    TempDirectory = GetTemporaryDirectory() + "weact_video_" + Str(Date()) + "_" + Str(attempt) + "\\"
    If CreateDirectory(TempDirectory)
      ProcedureReturn #True
    EndIf
  Next
  TempDirectory = ""
  ProcedureReturn #False
EndProcedure

Procedure.i ExtractFrames()
  Protected width.i = WeAct_GetDisplayWidth(), height.i = WeAct_GetDisplayHeight()
  Protected command.s, process.i, directory.i
  If Not CreateFrameDirectory() : ProcedureReturn #False : EndIf
  command = "-i " + Chr(34) + VideoFile + Chr(34)
  If DurationSeconds > 0.0
    command = command + " -t " + StrF(DurationSeconds, 2)
  EndIf
  command = command + " -vf " + Chr(34) + "scale=" + Str(width) + ":" + Str(height) + ":force_original_aspect_ratio=decrease" + Chr(34) + " -r " + StrF(FrameRate, 2) + " " + Chr(34) + TempDirectory + "frame_%05d.jpg" + Chr(34)
  process = RunProgram("ffmpeg", command, "", #PB_Program_Open | #PB_Program_Wait | #PB_Program_Hide)
  If Not process : ProcedureReturn #False : EndIf
  CloseProgram(process)
  directory = ExamineDirectory(#PB_Any, TempDirectory, "*.jpg")
  If directory
    While NextDirectoryEntry(directory)
      If DirectoryEntryType(directory) = #PB_DirectoryEntry_File : FrameCount + 1 : EndIf
    Wend
    FinishDirectory(directory)
  EndIf
  ProcedureReturn Bool(FrameCount > 0)
EndProcedure

Procedure.i ShowFrame(Number.i)
  Protected image.i, result.i, path.s = TempDirectory + "frame_" + RSet(Str(Number), 5, "0") + ".jpg"
  image = LoadImage(#PB_Any, path)
  If Not image : ProcedureReturn #False : EndIf
  WeAct_ClearBuffer(#WEACT_BLACK)
  ; The extracted image already fits the active dimensions. This library routine keeps it centered.
  WeAct_LoadImageCentered(path)
  FreeImage(image)
  If ChangedUpdates
    result = WeAct_UpdateChangedDisplay()
  Else
    result = WeAct_UpdateDisplay()
  EndIf
  ProcedureReturn result
EndProcedure

Procedure Cleanup()
  If TempDirectory <> ""
    DeleteDirectory(TempDirectory, "*.*", #PB_FileSystem_Recursive)
  EndIf
  WeAct_Cleanup()
EndProcedure

Procedure Main()
  Protected number.i, frameDelay.i
  If Not ParseArguments() : ShowHelp() : ProcedureReturn : EndIf
  frameDelay = Int(1000.0 / FrameRate)
  If FastLZMode And Model <> #WEACT_MODEL_350
    PrintN("Error: /fastlz requires /model:350") : ProcedureReturn
  EndIf
  If Not CheckFFmpeg() : ProcedureReturn : EndIf
  If Not WeAct_Init(ComPort, Model) Or Not WeAct_SetOrientation(Orientation)
    PrintN("Error: " + WeAct_GetLastError()) : Cleanup() : ProcedureReturn
  EndIf
  If FastLZMode And Not WeAct_SetFastLZEnabled(#True)
    PrintN("Error: " + WeAct_GetLastError()) : Cleanup() : ProcedureReturn
  EndIf
  If Not ExtractFrames() : PrintN("Error: no frames extracted") : Cleanup() : ProcedureReturn : EndIf
  Repeat
    For number = 1 To FrameCount
      If Not ShowFrame(number) : PrintN("Error: failed to display frame") : Cleanup() : ProcedureReturn : EndIf
      Delay(frameDelay)
    Next
  Until Not LoopPlayback
  Cleanup()
EndProcedure

Main()
