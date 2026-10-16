; WeAct Display FPS Monitor for library 6.x.
; Shows the refresh frequency of a selected desktop on either supported panel.

XIncludeFile "..\WeActDisplay.pbi"

EnableExplicit
OpenConsole()

Global ComPort.s = "COM3"
Global Model.i = #WEACT_MODEL_096
Global Orientation.i = #WEACT_LANDSCAPE
Global MonitorIndex.i = 0
Global UpdateInterval.i = 1000
Global Verbose.i = #False
Global Frequency.i

Procedure ShowHelp()
  PrintN("WeAct FPS Monitor")
  PrintN("Usage: WeActFPS /p:21 [/model:096|350] [/orientation:portrait|landscape|reverse-portrait|reverse-landscape] [/m:0] [/i:1000] [/v]")
  PrintN("/p:N        COM port number (required)")
  PrintN("/model:...  Display model; default: 096")
  PrintN("/m:N        Desktop index; default: 0")
  PrintN("/i:N        Update interval in ms, 100..5000; default: 1000")
  PrintN("/v          Print values to the console")
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
  Protected i.i, Parameter.s, Value.s
  If CountProgramParameters() = 0
    ShowHelp()
    ProcedureReturn #False
  EndIf
  For i = 0 To CountProgramParameters() - 1
    Parameter = ProgramParameter(i)
    If Left(Parameter, 3) = "/p:" Or Left(Parameter, 3) = "-p:"
      ComPort = "COM" + Mid(Parameter, 4)
    ElseIf Left(Parameter, 7) = "/model:" Or Left(Parameter, 7) = "-model:"
      Value = LCase(Mid(Parameter, 8))
      If Value = "096"
        Model = #WEACT_MODEL_096
      ElseIf Value = "350"
        Model = #WEACT_MODEL_350
      Else
        PrintN("Error: model must be 096 or 350")
        ProcedureReturn #False
      EndIf
    ElseIf Left(Parameter, 13) = "/orientation:" Or Left(Parameter, 13) = "-orientation:"
      Orientation = ParseOrientation(Mid(Parameter, 14))
      If Orientation < 0
        PrintN("Error: unsupported orientation")
        ProcedureReturn #False
      EndIf
    ElseIf Left(Parameter, 3) = "/m:" Or Left(Parameter, 3) = "-m:"
      MonitorIndex = Val(Mid(Parameter, 4))
    ElseIf Left(Parameter, 3) = "/i:" Or Left(Parameter, 3) = "-i:"
      UpdateInterval = Val(Mid(Parameter, 4))
      If UpdateInterval < 100 : UpdateInterval = 100 : EndIf
      If UpdateInterval > 5000 : UpdateInterval = 5000 : EndIf
    ElseIf Parameter = "/v" Or Parameter = "-v"
      Verbose = #True
    ElseIf Parameter = "/?" Or Parameter = "-?" Or Parameter = "/h" Or Parameter = "-h"
      ShowHelp()
      End 0
    Else
      PrintN("Error: unknown parameter " + Parameter)
      ProcedureReturn #False
    EndIf
  Next
  ProcedureReturn #True
EndProcedure

Procedure DisplayFPS(Frequency.i)
  Protected width.i = WeAct_GetDisplayWidth()
  Protected height.i = WeAct_GetDisplayHeight()
  Protected text.s = Str(Frequency) + " Hz"
  Protected fontSize.i = 24
  Protected x.i = (width - WeAct_GetTextWidth(text, fontSize, "Arial")) / 2
  Protected y.i = (height - WeAct_GetTextHeight(text, fontSize, "Arial")) / 2
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextSystemFont(4, 4, "Monitor " + Str(MonitorIndex), #WEACT_WHITE, 10)
  WeAct_DrawTextSystemFont(x, y, text, #WEACT_GREEN, fontSize)
  ProcedureReturn WeAct_UpdateDisplay()
EndProcedure

If Not ParseArguments()
  End 1
EndIf

If Not WeAct_Init(ComPort, Model)
  PrintN("Error: " + WeAct_GetLastError())
  End 1
EndIf

If Not WeAct_SetOrientation(Orientation)
  PrintN("Error: " + WeAct_GetLastError())
  WeAct_Cleanup()
  End 1
EndIf

If ExamineDesktops() <= MonitorIndex Or MonitorIndex < 0
  PrintN("Error: monitor index is unavailable")
  WeAct_Cleanup()
  End 1
EndIf

While #True
  Frequency = DesktopFrequency(MonitorIndex)
  If Frequency <= 0 : Frequency = 60 : EndIf
  If Not DisplayFPS(Frequency)
    PrintN("Error: " + WeAct_GetLastError())
    Break
  EndIf
  If Verbose
    PrintN("Monitor " + Str(MonitorIndex) + ": " + Str(Frequency) + " Hz")
  EndIf
  Delay(UpdateInterval)
Wend

WeAct_Cleanup()
