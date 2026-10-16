; Copyright (C) CheshirCa 2026   https://t.me/cheshircanest
; Created 2026-10-14; GPL-3.0, see LICENSE.
; Offline buffer/protocol checks and optional physical display smoke test.
XIncludeFile "..\WeActDisplay.pbi"
OpenConsole()

Global failures.i

Procedure Check(Result.i, Description.s)
  If Result
    PrintN("PASS " + Description)
  Else
    failures + 1
    PrintN("FAIL " + Description)
  EndIf
EndProcedure

Procedure TestFastLZ()
  Protected inputLength.i = 1024, outputCapacity.i = 1100, compressedLength.i, decompressedLength.i, i.i
  Protected *Input = AllocateMemory(inputLength)
  Protected *Compressed = AllocateMemory(outputCapacity)
  Protected *Decoded = AllocateMemory(inputLength)
  If Not *Input Or Not *Compressed Or Not *Decoded
    Check(#False, "FastLZ test memory")
    If *Input : FreeMemory(*Input) : EndIf
    If *Compressed : FreeMemory(*Compressed) : EndIf
    If *Decoded : FreeMemory(*Decoded) : EndIf
    ProcedureReturn
  EndIf
  For i = 0 To inputLength - 1
    PokeA(*Input + i, (i % 32) * 7)
  Next
  compressedLength = WeAct_FastLZCompress(*Input, inputLength, *Compressed, outputCapacity)
  decompressedLength = WeAct_FastLZDecompress(*Compressed, compressedLength, *Decoded, inputLength)
  Check(Bool(compressedLength > 0 And compressedLength < inputLength), "FastLZ compression")
  Check(Bool(decompressedLength = inputLength And CompareMemory(*Input, *Decoded, inputLength)), "FastLZ round trip")
  FreeMemory(*Input)
  FreeMemory(*Compressed)
  FreeMemory(*Decoded)
EndProcedure

Procedure OfflineModel(Model.i)
  Protected width.i, height.i, bytes.i, image.i, path.s
  Dim command.a(9)
  If Model = #WEACT_MODEL_350
    width = 320 : height = 480
  Else
    width = 160 : height = 80
  EndIf
  bytes = width * height * 2
  WeActDisplay\Model = Model
  WeActDisplay\DisplayWidth = width
  WeActDisplay\DisplayHeight = height
  WeActDisplay\BytesPerPixel = 2
  WeActDisplay\BufferSize = bytes
  WeActDisplay\FrameBuffer = AllocateMemory(bytes + 2)
  WeActDisplay\BackBuffer = AllocateMemory(bytes + 2)
  Check(Bool(WeActDisplay\FrameBuffer And WeActDisplay\BackBuffer), "allocate model " + Str(Model))
  If Not WeActDisplay\FrameBuffer Or Not WeActDisplay\BackBuffer
    WeAct_Close()
    ProcedureReturn
  EndIf
  PokeW(WeActDisplay\BackBuffer + bytes, $55AA)
  WeAct_ClearBuffer(#WEACT_RED)
  Check(Bool((PeekA(WeActDisplay\BackBuffer) & $FF) = $00 And (PeekA(WeActDisplay\BackBuffer + 1) & $FF) = $F8), "RGB565 little endian fill")
  WeAct_DrawPixelBuffer(0, 0, #WEACT_BLUE)
  WeAct_DrawPixelBuffer(width - 1, height - 1, #WEACT_WHITE)
  WeAct_DrawPixelBuffer(width, height, #WEACT_GREEN)
  Check(Bool((PeekW(WeActDisplay\BackBuffer) & $FFFF) = #WEACT_BLUE), "top left pixel")
  Check(Bool((PeekW(WeActDisplay\BackBuffer + bytes - 2) & $FFFF) = #WEACT_WHITE), "bottom right pixel")
  Check(Bool((PeekW(WeActDisplay\BackBuffer + bytes) & $FFFF) = $55AA), "buffer boundary")
  WeAct_DrawLineBuffer(0, 0, width - 1, 0, #WEACT_GREEN)
  WeAct_DrawLineBuffer(0, 0, 0, height - 1, #WEACT_GREEN)
  WeAct_DrawRectangleBuffer(width - 30, height - 30, 25, 20, #WEACT_YELLOW, #False)
  WeAct_DrawRectangleBuffer(-100, -100, 1000, 1000, #WEACT_GREEN, #False)
  WeAct_DrawCircleBuffer(width / 2, height / 2, 10, #WEACT_CYAN, #True)
  WeAct_DrawTextSystemFont(3, 3, "Hello Привет", #WEACT_WHITE, 12)
  WeAct_DrawTextSystemFont(3, 25, "Font 20", #WEACT_WHITE, 20)
  Check(Bool((PeekW(WeActDisplay\BackBuffer + bytes) & $FFFF) = $55AA), "drawing boundary")
  Check(WeAct_MakeRectCommand(0, 0, width, height, @command()), "full packet")
  Check(Bool(((command(5) & $FF) | ((command(6) & $FF) << 8)) = width - 1), "inclusive X end")
  Check(Bool(((command(7) & $FF) | ((command(8) & $FF) << 8)) = height - 1), "inclusive Y end")
  Check(WeAct_MakeRectCommand(width - 1, height - 1, 1, 1, @command()), "one pixel packet")
  Check(Bool(WeAct_MakeRectCommand(width - 1, height - 1, 2, 1, @command()) = 0), "reject overflow packet")
  image = CreateImage(#PB_Any, 8, 8, 24, RGB(255, 0, 0))
  If image
    path = GetTemporaryDirectory() + "weact_test_" + Str(Model) + "_" + Str(ElapsedMilliseconds()) + ".bmp"
    If SaveImage(image, path, #PB_ImagePlugin_BMP)
      Check(WeAct_LoadImageToBuffer(5, 5, path, 16, 16), "scaled BMP image")
      DeleteFile(path)
    Else
      Check(#False, "save BMP image")
    EndIf
    FreeImage(image)
  EndIf
  If Model = #WEACT_MODEL_096
    Check(Bool(WeAct_SetSensorPeriod(500) = 0), "sensor unsupported")
    Check(Bool(WeAct_SetFastLZEnabled(#True) = 0), "FastLZ unsupported")
  Else
    Check(WeAct_SetFastLZEnabled(#True), "FastLZ supported")
    WeAct_SetFastLZEnabled(#False)
  EndIf
  WeAct_Close()
  Check(Bool(WeActDisplay\FrameBuffer = 0 And WeActDisplay\BackBuffer = 0), "release buffers")
EndProcedure

Procedure.i TestHardwareImage(Model.i, Width.i, Height.i)
  Protected image.i, imageWidth.i, imageHeight.i, path.s, result.i

  imageWidth = Width / 2
  imageHeight = Height / 3
  If imageWidth < 32 : imageWidth = 32 : EndIf
  If imageHeight < 16 : imageHeight = 16 : EndIf

  image = CreateImage(#PB_Any, imageWidth, imageHeight, 24, RGB(0, 0, 0))
  If Not image
    ProcedureReturn #False
  EndIf

  If StartDrawing(ImageOutput(image))
    Box(0, 0, imageWidth, imageHeight, RGB(0, 0, 80))
    Box(2, 2, imageWidth - 4, imageHeight - 4, RGB(255, 180, 0))
    Circle(imageWidth / 2, imageHeight / 2, imageHeight / 4, RGB(0, 180, 255))
    StopDrawing()
  EndIf

  path = GetTemporaryDirectory() + "weact_hardware_" + Str(Model) + "_" + Str(ElapsedMilliseconds()) + ".bmp"
  If SaveImage(image, path, #PB_ImagePlugin_BMP)
    result = WeAct_LoadImageCentered(path, imageWidth, imageHeight)
    If result
      result = WeAct_UpdateDisplay()
    EndIf
    DeleteFile(path)
  EndIf
  FreeImage(image)
  ProcedureReturn result
EndProcedure

Procedure.i TestHardwareOrientation(Orientation.i, Label.s)
  Protected width.i, height.i, isLandscape.i
  
  If Not WeAct_SetOrientation(Orientation)
    ProcedureReturn #False
  EndIf
  
  width = WeAct_GetDisplayWidth()
  height = WeAct_GetDisplayHeight()
  isLandscape = Bool(Orientation = #WEACT_LANDSCAPE Or Orientation = #WEACT_REVERSE_LANDSCAPE)
  If isLandscape
    Check(Bool(width > height), Label + " geometry")
  Else
    Check(Bool(width < height), Label + " geometry")
  EndIf
  
  ; Four different corners make the selected rotation visible during the hardware test.
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawPixelBuffer(0, 0, #WEACT_RED)
  WeAct_DrawPixelBuffer(width - 1, 0, #WEACT_GREEN)
  WeAct_DrawPixelBuffer(0, height - 1, #WEACT_BLUE)
  WeAct_DrawPixelBuffer(width - 1, height - 1, #WEACT_WHITE)
  WeAct_DrawTextSystemFont(3, 3, Label, #WEACT_YELLOW, 10)
  
  ProcedureReturn WeAct_UpdateDisplay()
EndProcedure

Procedure HardwareModel(Port.s, Model.i)
  Protected width.i, height.i, i.i, t.f, h.f, fontHeight.i, version.s
  If Not WeAct_Init(Port, Model)
    Check(#False, "open " + Port + ": " + WeAct_GetLastError())
    ProcedureReturn
  EndIf
  Check(#True, "open " + Port)
  width = WeAct_GetDisplayWidth()
  height = WeAct_GetDisplayHeight()
  Check(WeAct_FillScreen(#WEACT_BLUE), "hardware fill")
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawPixelBuffer(0, 0, #WEACT_RED)
  WeAct_DrawPixelBuffer(width - 1, height - 1, #WEACT_GREEN)
  WeAct_DrawLineBuffer(0, 0, width - 1, height - 1, #WEACT_WHITE)
  WeAct_DrawRectangleBuffer(10, 10, 30, 20, #WEACT_YELLOW, #True)
  WeAct_DrawCircleBuffer(width / 2, height / 2, 10, #WEACT_CYAN, #True)
  WeAct_DrawTextSystemFont(3, 3, "Hello Привет", #WEACT_WHITE, 8)
  fontHeight = height - 22
  If fontHeight < 20 : fontHeight = 20 : EndIf
  WeAct_DrawTextSystemFont(3, fontHeight, "Large", #WEACT_WHITE, 16)
  Check(WeAct_UpdateDisplay(), "full frame")
  For i = 1 To 3
    WeAct_DrawPixelBuffer(i, i, #WEACT_MAGENTA)
    Check(WeAct_UpdateChangedDisplay(), "changed frame " + Str(i))
  Next
  Check(WeAct_SetBrightness(128, 100), "brightness")
  Check(TestHardwareOrientation(#WEACT_LANDSCAPE, "landscape"), "landscape frame")
  Check(TestHardwareOrientation(#WEACT_REVERSE_LANDSCAPE, "reverse landscape"), "reverse landscape frame")
  Check(TestHardwareOrientation(#WEACT_REVERSE_PORTRAIT, "reverse portrait"), "reverse portrait frame")
  Check(TestHardwareOrientation(#WEACT_PORTRAIT, "portrait"), "portrait frame")
  Check(Bool(WeAct_SetOrientation(#WEACT_ROTATE) = #False), "reject undocumented orientation 05")
  Check(Bool(WeAct_GetOrientation() = #WEACT_PORTRAIT), "keep portrait after rejected orientation 05")
  WeAct_ClearBuffer(#WEACT_BLACK)
  Check(WeAct_FlushRect(0, 0, 2, 2), "partial update")
  Check(TestHardwareImage(Model, WeAct_GetDisplayWidth(), WeAct_GetDisplayHeight()), "hardware BMP image")
  WeAct_StartScrollText("Scroll Прокрутка", 10, #SCROLL_LEFT, 80.0, #WEACT_WHITE)
  For i = 1 To 10
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateScrollText()
    WeAct_DrawScrollText()
    If Not WeAct_UpdateDisplay()
      Check(#False, "scroll frame " + Str(i))
      Break
    EndIf
  Next
  If i > 10
    Check(#True, "scroll frames")
  EndIf
  WeAct_StopScrollText()
  If Model = #WEACT_MODEL_350
    Check(WeAct_SetSensorPeriod(500), "enable sensor")
    Delay(1500)
    If WeAct_GetSensorValues(@t, @h)
      PrintN("Sensor: " + StrF(t, 2) + " C, " + StrF(h, 2) + " %")
    Else
      PrintN("Sensor: no response (" + WeAct_GetLastError() + ")")
    EndIf
    Check(WeAct_SetSensorPeriod(0), "disable sensor")
    version = WeAct_GetFirmwareVersion()
    Check(Bool(version <> ""), "firmware version")
    If version <> ""
      PrintN("Firmware: " + version)
    EndIf
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_DrawTextSystemFont(3, 3, "FastLZ Привет", #WEACT_WHITE, 16)
    Check(WeAct_SetFastLZEnabled(#True), "enable FastLZ")
    Check(WeAct_UpdateDisplay(), "FastLZ full frame")
    Check(WeAct_SetFastLZEnabled(#False), "disable FastLZ")
  EndIf
  Check(WeAct_SetBrightness(255, 100), "restore brightness")
  WeAct_Close()
  Check(Bool(WeAct_IsConnected() = 0), "close port")
EndProcedure

OfflineModel(#WEACT_MODEL_096)
OfflineModel(#WEACT_MODEL_350)
TestFastLZ()
Check(Bool(WeAct_Init("COM999", #WEACT_MODEL_350) = 0), "missing port error")
If CountProgramParameters() >= 2 And LCase(ProgramParameter(0)) = "/hardware"
  Select LCase(ProgramParameter(2))
    Case "096": HardwareModel(ProgramParameter(1), #WEACT_MODEL_096)
    Case "350": HardwareModel(ProgramParameter(1), #WEACT_MODEL_350)
    Default: Check(#False, "hardware model must be 096 or 350")
  EndSelect
EndIf
PrintN("Failures: " + Str(failures))
End Bool(failures > 0)
