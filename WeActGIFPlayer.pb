; WeAct animated GIF player for library 6.x.

XIncludeFile "..\WeActDisplay.pbi"

EnableExplicit
OpenConsole()
UseGIFImageDecoder()

Structure GIFFrame
  Image.i
  Delay.i
EndStructure

Global NewList Frames.GIFFrame()
Global ComPort.s = "COM3"
Global Model.i = #WEACT_MODEL_096
Global Orientation.i = #WEACT_LANDSCAPE
Global Speed.f = 1.0
Global LoopPlayback.i = #False
Global Verbose.i = #False
Global FastLZMode.i = #False
Global ChangedUpdates.i = #False
Global GifFile.s

Procedure ShowHelp()
  PrintN("WeAct GIF Player")
  PrintN("Usage: WeActGIFPlayer /p:21 [/model:096|350] [/orientation:portrait|landscape|reverse-portrait|reverse-landscape] [/s:1.0] [/l] [/fastlz] [/changed] [/v] file.gif")
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
    ElseIf Left(parameter, 3) = "/s:" Or Left(parameter, 3) = "-s:"
      Speed = ValF(Mid(parameter, 4))
      If Speed < 0.1 : Speed = 0.1 : EndIf
      If Speed > 5.0 : Speed = 5.0 : EndIf
    ElseIf parameter = "/l" Or parameter = "-l"
      LoopPlayback = #True
    ElseIf parameter = "/v" Or parameter = "-v"
      Verbose = #True
    ElseIf parameter = "/fastlz" Or parameter = "-fastlz"
      FastLZMode = #True
    ElseIf parameter = "/changed" Or parameter = "-changed"
      ChangedUpdates = #True
    ElseIf Left(parameter, 1) = "/" Or Left(parameter, 1) = "-"
      ProcedureReturn #False
    Else
      GifFile = parameter
    EndIf
  Next
  ProcedureReturn Bool(GifFile <> "" And FileSize(GifFile) > 0)
EndProcedure

Procedure.i LoadFrames()
  Protected source.i, frameCount.i, i.i, image.i, delay.i, width.i, height.i
  source = LoadImage(#PB_Any, GifFile)
  If Not source : ProcedureReturn #False : EndIf
  frameCount = ImageFrameCount(source)
  If frameCount < 1 : frameCount = 1 : EndIf
  For i = 0 To frameCount - 1
    SetImageFrame(source, i)
    width = ImageWidth(source)
    height = ImageHeight(source)
    image = CreateImage(#PB_Any, width, height, 24)
    If image
      If StartDrawing(ImageOutput(image))
        ; DrawImage resolves the selected GIF frame to a complete bitmap.
        DrawImage(ImageID(source), 0, 0, width, height)
        StopDrawing()
        delay = GetImageFrameDelay(source)
        If delay < 10 : delay = 100 : EndIf
        AddElement(Frames())
        Frames()\Image = image
        Frames()\Delay = delay
        If Verbose
          PrintN("GIF frame " + Str(i) + ": " + Str(width) + "x" + Str(height) + ", delay " + Str(delay) + " ms")
        EndIf
      Else
        FreeImage(image)
      EndIf
    EndIf
  Next
  FreeImage(source)
  ProcedureReturn Bool(ListSize(Frames()) > 0)
EndProcedure

Procedure.i ShowFrame(Image.i)
  Protected width.i = WeAct_GetDisplayWidth(), height.i = WeAct_GetDisplayHeight()
  Protected imageWidth.i = ImageWidth(Image), imageHeight.i = ImageHeight(Image)
  Protected scale.f, scaleX.f, scaleY.f, targetWidth.i, targetHeight.i, x.i, y.i, sourceX.i, sourceY.i, color.i
  Protected scaledImage.i
  scaleX = width / imageWidth
  scaleY = height / imageHeight
  scale = scaleX
  If scaleY < scale
    scale = scaleY
  EndIf
  targetWidth = Int(imageWidth * scale)
  targetHeight = Int(imageHeight * scale)
  x = (width - targetWidth) / 2
  y = (height - targetHeight) / 2
  If Verbose
    PrintN("Display " + Str(width) + "x" + Str(height) + ", frame " + Str(imageWidth) + "x" + Str(imageHeight) + ", target " + Str(targetWidth) + "x" + Str(targetHeight) + ", at " + Str(x) + "," + Str(y))
  EndIf
  WeAct_ClearBuffer(#WEACT_BLACK)
  scaledImage = CreateImage(#PB_Any, targetWidth, targetHeight, 24)
  If Not scaledImage : ProcedureReturn #False : EndIf
  If StartDrawing(ImageOutput(scaledImage))
    DrawImage(ImageID(Image), 0, 0, targetWidth, targetHeight)
    StopDrawing()
  Else
    FreeImage(scaledImage)
    ProcedureReturn #False
  EndIf
  If StartDrawing(ImageOutput(scaledImage))
    For sourceY = 0 To targetHeight - 1
      For sourceX = 0 To targetWidth - 1
        color = Point(sourceX, sourceY)
        WeAct_DrawPixelBuffer(x + sourceX, y + sourceY, RGBToRGB565(Red(color), Green(color), Blue(color)))
      Next
    Next
    StopDrawing()
  Else
    FreeImage(scaledImage)
    ProcedureReturn #False
  EndIf
  FreeImage(scaledImage)
  If ChangedUpdates
    ProcedureReturn WeAct_UpdateChangedDisplay()
  EndIf
  ProcedureReturn WeAct_UpdateDisplay()
EndProcedure

Procedure Cleanup()
  ForEach Frames()
    If Frames()\Image : FreeImage(Frames()\Image) : EndIf
  Next
  ClearList(Frames())
  WeAct_Cleanup()
EndProcedure

Procedure Main()
  Protected delay.i
  If Not ParseArguments() : ShowHelp() : ProcedureReturn : EndIf
  If FastLZMode And Model <> #WEACT_MODEL_350
    PrintN("Error: /fastlz requires /model:350") : ProcedureReturn
  EndIf
  If Not LoadFrames() : PrintN("Error: cannot load GIF") : ProcedureReturn : EndIf
  If Not WeAct_Init(ComPort, Model) Or Not WeAct_SetOrientation(Orientation)
    PrintN("Error: " + WeAct_GetLastError()) : Cleanup() : ProcedureReturn
  EndIf
  If FastLZMode And Not WeAct_SetFastLZEnabled(#True)
    PrintN("Error: " + WeAct_GetLastError()) : Cleanup() : ProcedureReturn
  EndIf
  Repeat
    ForEach Frames()
      If Not ShowFrame(Frames()\Image) : Cleanup() : ProcedureReturn : EndIf
      delay = Int(Frames()\Delay / Speed)
      If delay < 10 : delay = 10 : EndIf
      Delay(delay)
    Next
  Until Not LoopPlayback
  Cleanup()
EndProcedure

Main()
