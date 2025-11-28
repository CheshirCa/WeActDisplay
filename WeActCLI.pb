; =============================================
; WeActCLI - Console Text Display Utility
; Usage: WeActCLI /p:X [/v][/c:YYY] "text"
; =============================================

XIncludeFile "d:\WeActDisplay.pbi"

OpenConsole()

; { Глобальные переменные }
Global verbose.i = #False  ; ← ИЗМЕНЕНО: по умолчанию тихий режим
Global comPort.s = "COM3"
Global textColor.i = #WEACT_YELLOW
Global displayText.s = ""

; { Функция вывода справки }
Procedure ShowHelp()
  PrintN("WeActCLI - Console Text Display Utility for WeAct Display FS")
  PrintN("")
  PrintN("Usage: WeActCLI /p:X [/v][/c:YYY] " + Chr(34) + "text" + Chr(34))
  PrintN("")
  PrintN("Parameters:")
  PrintN("  /p:X       - COM port number (required)")
  PrintN("               Example: /p:3 for COM3")
  PrintN("")
  PrintN("  /c:YYY     - Text color (optional, default: yellow)")
  PrintN("               Available colors:")
  PrintN("                 red, green, blue, white, black")
  PrintN("                 yellow, cyan, magenta")
  PrintN("               Example: /c:red")
  PrintN("")
  PrintN("  /v         - Verbose mode (optional, default: off)")
  PrintN("               Use /v to enable informational messages")
  PrintN("")
  PrintN("  text       - Text to display (required, in quotes)")
  PrintN("")
  PrintN("Examples:")
  PrintN("  WeActCLI /p:3 " + Chr(34) + "Hello World!" + Chr(34) )
  PrintN("  WeActCLI /p:5 /c:green " + Chr(34) + "Status: OK" + Chr(34) )
  PrintN("  WeActCLI /p:3 /v /c:red " + Chr(34) + "ALERT: Error detected!" + Chr(34) )
  PrintN("")
EndProcedure

; { Функция разбора параметров командной строки }
Procedure ParseCommandLine()
  Protected paramCount = CountProgramParameters()
  
  If paramCount = 0
    ShowHelp()
    ProcedureReturn #False
  EndIf
  
  For i = 0 To paramCount - 1
    Protected param.s = ProgramParameter(i)
    
    If Left(param, 1) = "/" Or Left(param, 1) = "-"
      ; Обрабатываем ключи
      Select LCase(Left(param, 3))
        Case "/p:", "-p:"
          comPort = "COM" + Mid(param, 4)
          
        Case "/c:", "-c:"
          Protected colorName.s = LCase(Mid(param, 4))
          Select colorName
            Case "red":     textColor = #WEACT_RED
            Case "green":   textColor = #WEACT_GREEN
            Case "blue":    textColor = #WEACT_BLUE
            Case "white":   textColor = #WEACT_WHITE
            Case "black":   textColor = #WEACT_BLACK
            Case "yellow":  textColor = #WEACT_YELLOW
            Case "cyan":    textColor = #WEACT_CYAN
            Case "magenta": textColor = #WEACT_MAGENTA
            Default:
              PrintN("Error: Unknown color '" + colorName + "'")
              PrintN("Use one of: red, green, blue, white, black, yellow, cyan, magenta")
              ProcedureReturn #False
          EndSelect
          
        Case "/v", "-v"
          verbose = #True  ; ← ИЗМЕНЕНО: включаем verbose при указании ключа
          
        Case "/h", "-h", "/?", "-?"
          ShowHelp()
          ProcedureReturn #False
          
        Default:
          PrintN("Error: Unknown parameter '" + param + "'")
          ShowHelp()
          ProcedureReturn #False
      EndSelect
    Else
      ; Это текст для отображения
      If displayText = ""
        displayText = param
      Else
        displayText + " " + param
      EndIf
    EndIf
  Next
  
  ; Проверяем обязательные параметры
  If comPort = "COM"
    PrintN("Error: COM port not specified")
    PrintN("Use /p:X to specify COM port (e.g., /p:3 for COM3)")
    ProcedureReturn #False
  EndIf
  
  If displayText = ""
    PrintN("Error: No text specified")
    PrintN("Please provide text to display in quotes")
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

; { Функция отображения текста на дисплее }
Procedure DisplayText()
  If verbose
    PrintN("Initializing WeAct Display FS...")
    PrintN("Port: " + comPort)
  EndIf
  
  ; Инициализируем дисплей
  If WeAct_Init(comPort)
    If verbose
      PrintN("Display initialized successfully")
      PrintN("Displaying text: " + Chr(34) + displayText  + Chr(34))
    EndIf
    
    ; Очищаем экран и выводим текст
    WeAct_ClearBuffer(#WEACT_BLACK)
    
    ; Автоматически подбираем размер шрифта в зависимости от длины текста
    Protected textLength = Len(displayText)
    Protected fontSize.i
    
    If textLength <= 10
      fontSize = 16  ; Large для короткого текста
      WeAct_DrawTextLarge(5, 30, displayText, textColor)
    ElseIf textLength <= 20
      fontSize = 12  ; Medium для среднего текста
      WeAct_DrawTextMedium(5, 30, displayText, textColor)
    Else
      fontSize = 8   ; Small для длинного текста
      
      ; Для очень длинного текста используем перенос
      If textLength > 25
        WeAct_DrawWrappedTextAutoSize(5, 5, 150, 70, displayText, textColor)
      Else
        WeAct_DrawTextSmall(5, 30, displayText, textColor)
      EndIf
    EndIf
    
    ; Обновляем дисплей
    If WeAct_UpdateDisplay()
      If verbose
        PrintN("Text displayed successfully")
        PrintN("Font size: " + Str(fontSize))
        
        ; Показываем информацию о цвете
        Protected colorName.s
        Select textColor
          Case #WEACT_RED:     colorName = "red"
          Case #WEACT_GREEN:   colorName = "green" 
          Case #WEACT_BLUE:    colorName = "blue"
          Case #WEACT_WHITE:   colorName = "white"
          Case #WEACT_BLACK:   colorName = "black"
          Case #WEACT_YELLOW:  colorName = "yellow"
          Case #WEACT_CYAN:    colorName = "cyan"
          Case #WEACT_MAGENTA: colorName = "magenta"
        EndSelect
        PrintN("Text color: " + colorName)
      EndIf
      
      ; Ждем немного перед завершением
      Delay(100)
      WeAct_Cleanup()
      
      If verbose
        PrintN("Display connection closed")
      EndIf
      
      ProcedureReturn #True
    Else
      PrintN("Error: Failed to update display")
      WeAct_Cleanup()
      ProcedureReturn #False
    EndIf
    
  Else
    PrintN("Error: Failed to initialize display on " + comPort)
    PrintN("Please check:")
    PrintN("  1. COM port number")
    PrintN("  2. Display connection")
    PrintN("  3. Driver installation")
    ProcedureReturn #False
  EndIf
EndProcedure

; =============================================
; { ОСНОВНАЯ ПРОГРАММА }
; =============================================

; Проверяем версию PureBasic
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  PrintN("Error: This program requires Windows")
  End 1
CompilerEndIf

; Разбираем командную строку
If ParseCommandLine()
  ; Выводим текст на дисплей
  If DisplayText()
    If verbose
      PrintN("Operation completed successfully")
    EndIf
    End 0
  Else
    End 1
  EndIf
Else
  End 1
EndIf
; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 128
; FirstLine = 123
; Folding = -
; EnableXP

; Executable = WeActCLI.exe
