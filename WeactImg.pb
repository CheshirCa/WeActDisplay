; =============================================
; WeActCLI - Console Text and Image Display Utility
; Usage: WeActCLI /p:X [/v][/c:YYY] [/f:Font:Size] [/s:Speed[:u|d]] [/center] [/CLS] [/file:"path\name.txt"] [/image:"path\image.jpg"] "text"
; =============================================

XIncludeFile "WeActDisplay.pbi"

OpenConsole()

; =============================================
; GLOBAL VARIABLE DECLARATIONS
; =============================================

; Control flag for verbose output mode
Global verbose.i = #False

; COM port for WeAct Display connection (default: COM3)
Global comPort.s = "COM3"

; Text color constant (default: white)
Global textColor.i = #WEACT_WHITE

; Text content to be displayed on the screen
Global displayText.s = ""

; Image file to display
Global imageFile.s = ""

; Maximum width for text wrapping in pixels (default: 150px)
Global wrapWidth.i = 150

; Spacing between text lines in pixels (default: 2px)
Global lineSpacing.i = 2

; Font name for text rendering (default: Arial)
Global fontName.s = "Arial"

; Font size in points (default: 8pt)
Global fontSize.i = 8

; Scrolling speed in pixels per second (default: 30.0 px/s)
Global scrollSpeed.f = 30.0

; Flag indicating whether scrolling mode is enabled
Global scrollMode.i = #False

; Scrolling direction (up/down), uses constants from WeActDisplay.pbi
Global scrollDirection.i = #SCROLL_UP

; Flag for horizontal text centering
Global centerText.i = #False

; Flag for screen clearing only mode (no text display)
Global clearScreenOnly.i = #False

; Path to text file for loading content
Global textFile.s = ""

; Maximum number of lines to load from text file
Global maxFileLines.i = 1000

; Image display mode: 0=fit to screen, 1=original size, 2=centered with size
Global imageMode.i = 0
Global imageWidth.i = -1
Global imageHeight.i = -1

; =============================================
; UTILITY FUNCTIONS
; =============================================

; Loads text content from a specified file with UTF-8 encoding support
Procedure.s LoadTextFromFile(FilePath.s, MaxLines.i = 1000)
  Protected result.s = ""
  Protected lineCount.i = 0
  Protected file.i
  
  ; Validate file existence and size
  If FileSize(FilePath) <= 0
    PrintN("Error: File '" + FilePath + "' not found or empty")
    ProcedureReturn ""
  EndIf
  
  ; Attempt to open file with UTF-8 encoding
  file = ReadFile(#PB_Any, FilePath)
  If Not file
    PrintN("Error: Cannot open file '" + FilePath + "'")
    ProcedureReturn ""
  EndIf
  
  ; Read file line by line up to MaxLines
  While Not Eof(file) And lineCount < MaxLines
    Protected line.s = ReadString(file, #PB_UTF8)
    
    ; Concatenate lines with newline separation
    If result <> ""
      result + #CRLF$ + line
    Else
      result = line
    EndIf
    lineCount + 1
  Wend
  
  CloseFile(file)
  
  ; Verbose mode logging for file loading details
  If verbose
    PrintN("Loaded " + Str(lineCount) + " lines from file: " + FilePath)
    PrintN("Total text length: " + Str(Len(result)) + " characters")
  EndIf
  
  ProcedureReturn result
EndProcedure



; Display image from file
Procedure DisplayImageFromFile(ImagePath.s, Mode.i = 0, ImgWidth.i = -1, ImgHeight.i = -1)
  Protected result.i = #False
  
  If verbose
    PrintN("Loading image: " + ImagePath)
    PrintN("Image mode: " + Str(Mode))
    If ImgWidth > 0 And ImgHeight > 0
      PrintN("Image size: " + Str(ImgWidth) + "x" + Str(ImgHeight))
    EndIf
  EndIf
  
  ; Загружаем изображение для получения информации о нем
  Protected testImage = LoadImage(#PB_Any, ImagePath)
  If testImage
    If verbose
      PrintN("Image loaded successfully")
      PrintN("Original size: " + Str(ImageWidth(testImage)) + "x" + Str(ImageHeight(testImage)))
      PrintN("Image depth: " + Str(ImageDepth(testImage)))
    EndIf
    FreeImage(testImage)
  EndIf
  
  Select Mode
    Case 0  ; Fit to screen (full screen with aspect ratio)
      If verbose : PrintN("Image mode: Fit to screen") : EndIf
      result = WeAct_LoadImageFullScreen(ImagePath)
      
    Case 1  ; Original size at (0,0)
      If verbose : PrintN("Image mode: Original size at (0,0)") : EndIf
      result = WeAct_LoadImageToBuffer(0, 0, ImagePath, ImgWidth, ImgHeight)
      
    Case 2  ; Centered with specified size
      If verbose : PrintN("Image mode: Centered") : EndIf
      result = WeAct_LoadImageCentered(ImagePath, ImgWidth, ImgHeight)
      
  EndSelect
  
  If result
    If verbose
      PrintN("WeAct_LoadImage... returned TRUE")
    EndIf
    If WeAct_UpdateDisplay()
      If verbose
        PrintN("WeAct_UpdateDisplay() successful")
      EndIf
      Delay(3000)  ; Show image for 3 seconds
      ProcedureReturn #True
    Else
      If verbose
        PrintN("WeAct_UpdateDisplay() FAILED: " + WeAct_GetLastError())
      EndIf
    EndIf
  Else
    PrintN("Error: Failed to load image - " + WeAct_GetLastError())
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Определяет кодировку консоли Windows
Procedure.i GetConsoleCodepage()
  Protected cp.i = GetConsoleCP_()
  
  If verbose
    PrintN("Console codepage: " + Str(cp))
    Select cp
      Case 65001
        PrintN("  Encoding: UTF-8")
      Case 1251
        PrintN("  Encoding: Windows-1251 (Cyrillic)")
      Case 1252
        PrintN("  Encoding: Windows-1252 (Latin)")
      Case 866
        PrintN("  Encoding: CP866 (DOS Cyrillic)")
      Case 437
        PrintN("  Encoding: CP437 (DOS English)")
      Default
        PrintN("  Encoding: Unknown")
    EndSelect
  EndIf
  
  ProcedureReturn cp
EndProcedure

; Конвертирует строку из заданной кодовой страницы в UTF-8
Procedure.s ConvertToUTF8(Text.s, SourceCodepage.i)
  If SourceCodepage = 65001 ; Уже UTF-8
    ProcedureReturn Text
  EndIf
  
  ; Конвертируем через API Windows
  Protected length.i = Len(Text)
  Protected *utf16 = AllocateMemory((length + 1) * 2) ; UTF-16 буфер
  Protected *utf8 = AllocateMemory((length + 1) * 4)  ; UTF-8 буфер
  
  If *utf16 And *utf8
    ; Конвертируем из исходной кодировки в UTF-16
    Protected charsConverted = MultiByteToWideChar_(SourceCodepage, 0, @Text, -1, *utf16, length * 2)
    
    If charsConverted > 0
      ; Конвертируем из UTF-16 в UTF-8
      Protected bytesConverted = WideCharToMultiByte_(#CP_UTF8, 0, *utf16, -1, *utf8, MemorySize(*utf8), #Null, #Null)
      
      If bytesConverted > 0
        Text = PeekS(*utf8, -1, #PB_UTF8)
      EndIf
    EndIf
  EndIf
  
  If *utf16 : FreeMemory(*utf16) : EndIf
  If *utf8 : FreeMemory(*utf8) : EndIf
  
  ProcedureReturn Text
EndProcedure

; Читает данные из stdin с учетом кодировки
Procedure.s ReadFromStdin()
  Protected result.s = ""
  
  If verbose
    PrintN("Reading from stdin...")
  EndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; Получаем кодовую страницу консоли
    Protected consoleCP.i = GetConsoleCP_()
    Protected isRedirected.i = #False
    
    ; Проверяем, перенаправлен ли stdin
    Protected hStdin = GetStdHandle_(#STD_INPUT_HANDLE)
    Protected fileType = GetFileType_(hStdin)
    
    If fileType <> #FILE_TYPE_CHAR
      isRedirected = #True
      If verbose
        PrintN("stdin is redirected (pipe or file)")
      EndIf
    Else
      If verbose
        PrintN("stdin is console input")
      EndIf
    EndIf
    
    ; Для pipe из PowerShell или cmd.exe данные могут приходить в OEM кодировке
    ; Для файлового перенаправления (< file.txt) - в ANSI кодировке
    Protected useCodepage.i = consoleCP
    
    If isRedirected
      ; При перенаправлении из PowerShell по умолчанию используется UTF-8
      ; Но в старых версиях может использоваться OEM кодировка
      useCodepage = #CP_UTF8 ; По умолчанию предполагаем UTF-8 для перенаправления
    EndIf
    
    ; Читаем все доступные данные из stdin
    Protected bufferSize = 65536
    Protected *buffer = AllocateMemory(bufferSize)
    
    If *buffer
      Protected bytesRead.l
      Protected totalBytesRead = 0
      
      ; Читаем данные
      While #True
        Protected bytesAvailable.l
        If PeekNamedPipe_(hStdin, #Null, 0, #Null, @bytesAvailable, #Null)
          If bytesAvailable > 0
            ; Читаем доступные данные
            If ReadFile_(hStdin, *buffer + totalBytesRead, bytesAvailable, @bytesRead, #Null)
              totalBytesRead + bytesRead
              
              ; Проверяем, не переполнен ли буфер
              If totalBytesRead >= bufferSize - 1024
                Break
              EndIf
            Else
              Break
            EndIf
          Else
            ; Больше данных нет
            Break
          EndIf
        Else
          ; Не удалось проверить доступность данных (может быть файл)
          ; Пробуем прочитать напрямую
          If ReadFile_(hStdin, *buffer + totalBytesRead, bufferSize - totalBytesRead, @bytesRead, #Null)
            If bytesRead > 0
              totalBytesRead + bytesRead
            Else
              Break
            EndIf
          Else
            Break
          EndIf
        EndIf
      Wend
      
      If totalBytesRead > 0
        ; Конвертируем байты в строку с учетом кодировки
        If useCodepage = 65001 Or useCodepage = #CP_UTF8
          ; UTF-8
          result = PeekS(*buffer, totalBytesRead, #PB_UTF8)
        ElseIf useCodepage = 1251
          ; Windows-1251 (Cyrillic)
          result = PeekS(*buffer, totalBytesRead, #PB_Ascii)
          result = ConvertToUTF8(result, 1251)
        ElseIf useCodepage = 866
          ; CP866 (DOS Cyrillic)
          result = PeekS(*buffer, totalBytesRead, #PB_Ascii)
          result = ConvertToUTF8(result, 866)
        Else
          ; Пробуем определить кодировку автоматически
          ; Сначала пробуем как UTF-8
          Protected testResult.s = PeekS(*buffer, totalBytesRead, #PB_UTF8)
          
          ; Проверяем, нет ли в UTF-8 строке недопустимых символов
          Protected isValidUTF8.i = #True
          Protected k.i
          For k = 1 To Len(testResult)
            Protected charCode.i = Asc(Mid(testResult, k, 1))
            If charCode >= 128 And charCode <= 159 ; Недопустимые символы в UTF-8
              isValidUTF8 = #False
              Break
            EndIf
          Next
          
          If isValidUTF8 And testResult <> ""
            result = testResult
          Else
            ; Пробуем как ANSI (Windows-1252)
            result = PeekS(*buffer, totalBytesRead, #PB_Ascii)
            result = ConvertToUTF8(result, 1252)
          EndIf
        EndIf
        
        ; Очищаем от управляющих символов
        result = ReplaceString(result, Chr(0), "")
        result = RTrim(result, #CR$ + #LF$)
        
        If verbose
          PrintN("Read " + Str(totalBytesRead) + " bytes from stdin")
          PrintN("Converted to " + Str(Len(result)) + " UTF-8 characters")
          If Len(result) > 0 And Len(result) < 100
            PrintN("First 100 chars: " + Left(result, 100))
          EndIf
        EndIf
      EndIf
      
      FreeMemory(*buffer)
    EndIf
    
  CompilerElse
    ; Для Linux/Mac используем стандартный подход
    Protected stdinFile.i = ReadFile(#PB_Any, "")
    If stdinFile
      Protected fileSize.i = Lof(stdinFile)
      If fileSize > 0
        Protected *fileBuffer = AllocateMemory(fileSize)
        If *fileBuffer
          ReadData(stdinFile, *fileBuffer, fileSize)
          result = PeekS(*fileBuffer, fileSize, #PB_UTF8)
          FreeMemory(*fileBuffer)
        EndIf
      EndIf
      CloseFile(stdinFile)
    EndIf
  CompilerEndIf
  
  ProcedureReturn result
EndProcedure

; Simple string utility function
Procedure.s IIf(Condition.i, TrueValue.s, FalseValue.s)
  If Condition
    ProcedureReturn TrueValue
  Else
    ProcedureReturn FalseValue
  EndIf
EndProcedure

; =============================================
; HELP SYSTEM
; =============================================

; Displays comprehensive help information with usage examples
Procedure ShowHelp()
  PrintN("WeActCLI - Console Text and Image Display Utility for WeAct Display FS")
  PrintN("")
  PrintN("USAGE MODES:")
  PrintN("  1. Command line text: WeActCLI /p:3 " + Chr(34) + "Hello World" + Chr(34))
  PrintN("  2. File input:        WeActCLI /p:3 /file:log.txt")
  PrintN("  3. Image display:     WeActCLI /p:3 /image:photo.jpg")
  PrintN("  4. Pipe redirection:  dir | WeActCLI /p:3")
  PrintN("  5. File redirection:  WeActCLI /p:3 < log.txt")
  PrintN("  6. Clear screen:      WeActCLI /p:3 /CLS")
  PrintN("")
  PrintN("SYNTAX: WeActCLI /p:X [/v][/c:YYY] [/f:" + Chr(34) + "Font Name" + Chr(34) + ":Size] [/s:Speed[:u|d]] [/center] [/CLS] [/file:" + Chr(34) + "path\name.txt" + Chr(34) + "] [/image:" + Chr(34) + "path\image.jpg" + Chr(34) + "[:mode[:WxH]]] [" + Chr(34) + "text" + Chr(34) + "]")
  PrintN("")
  PrintN("PARAMETERS:")
  PrintN("  /p:X       - COM port number (REQUIRED)")
  PrintN("               Example: /p:3 for COM3")
  PrintN("")
  PrintN("  /c:YYY     - Text color (optional, default: white)")
  PrintN("               Available colors: red, green, blue, white, black,")
  PrintN("               yellow, cyan, magenta")
  PrintN("")
  PrintN("  /f:" + Chr(34) + "Font Name" + Chr(34) + ":Size - Font name and size (optional)")
  PrintN("               Default: Arial:8")
  PrintN("               Example: /f:Arial:10")
  PrintN("               Example: /f:" + Chr(34) + "Times New Roman" + Chr(34) + ":12")
  PrintN("")
  PrintN("  /s:Speed[:u|d] - Scroll speed and direction (optional)")
  PrintN("               Speed: pixels/second (e.g., 25.5)")
  PrintN("               Direction: u=up (default), d=down")
  PrintN("               Example: /s:25.5        - up, 25.5 px/s")
  PrintN("               Example: /s:40:d        - down, 40 px/s")
  PrintN("")
  PrintN("  /center    - Center text horizontally (optional)")
  PrintN("")
  PrintN("  /CLS       - Clear screen only (optional)")
  PrintN("")
  PrintN("  /file:" + Chr(34) + "path" + Chr(34) + " - Load text from file (optional)")
  PrintN("               Example: /file:log.txt")
  PrintN("               Example: /file:" + Chr(34) + "C:\My Files\log.txt" + Chr(34))
  PrintN("")
  PrintN("  /image:" + Chr(34) + "path" + Chr(34) + "[:mode[:WxH]] - Display image (optional)")
  PrintN("               Modes: 0=fit to screen (default), 1=original size, 2=centered")
  PrintN("               Example: /image:photo.jpg")
  PrintN("               Example: /image:logo.png:1")
  PrintN("               Example: /image:icon.bmp:2:64x64")
  PrintN("               Example: /image:" + Chr(34) + "C:\My Images\photo.jpg" + Chr(34) + ":0")
  PrintN("")
  PrintN("  /v         - Verbose mode (optional)")
  PrintN("")
  PrintN("  text       - Text to display (optional, use quotes for spaces)")
  PrintN("")
  PrintN("ENCODING NOTES:")
  PrintN("  - For Russian text, use UTF-8 encoding")
  PrintN("  - In PowerShell: [Console]::OutputEncoding = [System.Text.Encoding]::UTF8")
  PrintN("  - In CMD: chcp 65001")
  PrintN("  - Or use text files with UTF-8 encoding")
  PrintN("")
  PrintN("IMAGE FORMATS:")
  PrintN("  Supported: " + WeAct_GetSupportedImageFormats())
  PrintN("")
EndProcedure

; =============================================
; DISPLAY CONTROL FUNCTIONS
; =============================================

; Clears the WeAct Display screen without showing any text
Procedure ClearDisplayOnly()
  If verbose
    PrintN("")
    PrintN("=== Clear screen operation ===")
    PrintN("Initializing WeAct Display FS...")
    PrintN("Port: " + comPort)
    PrintN("Mode: Clear screen only")
    PrintN("")
  EndIf
  
  If WeAct_Init(comPort)
    If verbose
      PrintN("Display initialized successfully")
      PrintN("Display size: " + Str(WeAct_GetDisplayWidth()) + "x" + Str(WeAct_GetDisplayHeight()))
      PrintN("Clearing screen...")
    EndIf
    
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateDisplay()
    
    If verbose
      PrintN("Screen cleared")
    EndIf
    
    Delay(500)
    WeAct_Cleanup()
    
    If verbose
      PrintN("Display connection closed")
      PrintN("")
      PrintN("=== Clear screen completed ===")
    EndIf
    
    ProcedureReturn #True
  Else
    PrintN("Error: Failed to initialize display on " + comPort)
    PrintN("Error details: " + WeAct_GetLastError())
    PrintN("Please check:")
    PrintN("  1. COM port number")
    PrintN("  2. Display connection")
    PrintN("  3. Driver installation")
    ProcedureReturn #False
  EndIf
EndProcedure

; =============================================
; FONT MANAGEMENT FUNCTIONS
; =============================================

; Checks if a specified font is likely available on the Windows system
Procedure.i IsFontAvailable(FontName.s)
  Protected commonFonts.s = "Arial,Tahoma,Verdana,Courier New,Courier,Times New Roman," +
                            "Segoe UI,Calibri,Microsoft Sans Serif,Consolas," +
                            "Comic Sans MS,Impact,Lucida Console"
  
  Protected i.i
  For i = 1 To CountString(commonFonts, ",") + 1
    If LCase(StringField(commonFonts, i, ",")) = LCase(FontName)
      ProcedureReturn #True
    EndIf
  Next
  
  If LCase(FontName) = "courier"
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Checks if a single word fits within specified maximum width using current font
Procedure.i CheckWordFits(Word.s, FontSize.i, FontName.s, MaxWidth.i)
  Protected wordWidth.i = WeAct_GetTextWidth(Word, FontSize, FontName)
  ProcedureReturn Bool(wordWidth <= MaxWidth)
EndProcedure

; Automatically reduces font size to ensure all words fit within maximum width
Procedure.i AdjustFontSizeForWords(Text.s, *FontSize.Integer, FontName.s, MaxWidth.i)
  Protected originalSize.i = *FontSize\i
  Protected currentSize.i = originalSize
  Protected minSize.i = 6
  
  ; Clean text: replace tabs with spaces and remove control characters
  Text = ReplaceString(Text, Chr(9), " ")
  Text = ReplaceString(Text, Chr(0), "")
  
  ; Split text into words
  Protected wordCount.i = CountString(Text, " ") + 1
  Protected i.i
  
  ; Check each word
  For currentSize = originalSize To minSize Step -1
    Protected allWordsFit.i = #True
    
    For i = 1 To wordCount
      Protected word.s = StringField(Text, i, " ")
      ; Skip empty words
      If word <> ""
        If Not CheckWordFits(word, currentSize, FontName, MaxWidth)
          allWordsFit = #False
          Break
        EndIf
      EndIf
    Next
    
    If allWordsFit
      *FontSize\i = currentSize
      
      If verbose And currentSize < originalSize
        PrintN("Warning: Font size reduced from " + Str(originalSize) + " to " + Str(currentSize))
        PrintN("         to ensure all words fit within screen width")
      EndIf
      
      ProcedureReturn #True
    EndIf
  Next
  
  ; If words don't fit even with minimal size
  If verbose
    PrintN("Error: Some words don't fit even with minimal font size (6pt)")
    PrintN("       Try enabling scroll mode with /s parameter")
  EndIf
  
  ProcedureReturn #False
EndProcedure

; =============================================
; COMMAND-LINE PARSING FUNCTIONS
; =============================================

; Determines if a string represents a command-line parameter
Procedure.i IsParameter(Text.s)
  If Left(Text, 1) = "/" Or Left(Text, 1) = "-"
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Parse image size string like "64x64" or "100x50"
Procedure ParseImageSize(SizeString.s, *Width.Integer, *Height.Integer)
  Protected xPos.i = FindString(SizeString, "x")
  If xPos > 0
    *Width\i = Val(Left(SizeString, xPos - 1))
    *Height\i = Val(Mid(SizeString, xPos + 1))
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; =============================================
; ПАРСЕР КОМАНДНОЙ СТРОКИ
; =============================================
Procedure ParseCommandLine()
  Protected paramCount = CountProgramParameters()
  
  ; If no parameters and no stdin, show help
  If paramCount = 0
    ; Check if there's data in stdin
    Protected stdinTest.s = ReadFromStdin()
    If stdinTest = ""
      ShowHelp()
      ProcedureReturn #False
    Else
      ; We have stdin data, process it
      displayText = stdinTest
    EndIf
  EndIf
  
  ; Store all parameters in array
  Dim params.s(paramCount - 1)
  Protected i.i
  For i = 0 To paramCount - 1
    params(i) = ProgramParameter(i)
  Next
  
  ; Process parameters in order
  i = 0
  While i < paramCount
    Protected param.s = params(i)
    
    If IsParameter(param)
      Select LCase(param)
        Case "/center", "-center"
          centerText = #True
          If verbose : PrintN("Parameter: centerText = ON") : EndIf
          
        Case "/cls", "-cls"
          clearScreenOnly = #True
          If verbose : PrintN("Parameter: clearScreenOnly = ON") : EndIf
          
        Case "/v", "-v"
          verbose = #True
          If verbose : PrintN("Parameter: verbose = ON") : EndIf
          
        Case "/?", "-?", "/h", "-h"
          ShowHelp()
          ProcedureReturn #False
          
        Default:
          If Left(param, 3) = "/p:" Or Left(param, 3) = "-p:"
            comPort = "COM" + Mid(param, 4)
            If verbose : PrintN("Parameter: COM port = " + comPort) : EndIf
            
          ElseIf Left(param, 3) = "/c:" Or Left(param, 3) = "-c:"
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
            If verbose : PrintN("Parameter: color = " + colorName) : EndIf
            
          ElseIf Left(param, 3) = "/f:" Or Left(param, 3) = "-f:"
            Protected fontParam.s = Mid(param, 4)
            
            If Left(fontParam, 1) = Chr(34)
              Protected quoteEndPos.i = FindString(fontParam, Chr(34), 2)
              If quoteEndPos > 0
                fontName = Mid(fontParam, 2, quoteEndPos - 2)
                
                Protected sizeStartPos.i = FindString(fontParam, ":", quoteEndPos)
                If sizeStartPos > 0
                  fontSize = Val(Mid(fontParam, sizeStartPos + 1))
                Else
                  fontSize = 8
                EndIf
              Else
                PrintN("Error: Missing closing quote in font name")
                ProcedureReturn #False
              EndIf
            Else
              Protected colonPos.i = FindString(fontParam, ":")
              If colonPos > 0
                fontName = Left(fontParam, colonPos - 1)
                fontSize = Val(Mid(fontParam, colonPos + 1))
              Else
                fontName = fontParam
                fontSize = 8
              EndIf
            EndIf
            
            If fontSize < 6 Or fontSize > 32
              PrintN("Warning: Font size " + Str(fontSize) + " is outside recommended range 6-32")
              If fontSize < 6 : fontSize = 6 : EndIf
              If fontSize > 32 : fontSize = 32 : EndIf
            EndIf
            
            If Not IsFontAvailable(fontName)
              PrintN("Warning: Font '" + fontName + "' may not be available on this system.")
              PrintN("Using default font 'Arial' instead.")
              fontName = "Arial"
            EndIf
            
            If verbose : PrintN("Parameter: font = " + fontName + ", size = " + Str(fontSize)) : EndIf
            
          ElseIf Left(param, 3) = "/s:" Or Left(param, 3) = "-s:"
            scrollMode = #True
            Protected scrollParam.s = Mid(param, 4)
            
            Protected dirPos.i = FindString(scrollParam, ":")
            If dirPos > 0
              scrollSpeed = ValF(Left(scrollParam, dirPos - 1))
              Protected direction.s = LCase(Mid(scrollParam, dirPos + 1))
              
              Select direction
                Case "u", "up":
                  scrollDirection = #SCROLL_UP
                Case "d", "down":
                  scrollDirection = #SCROLL_DOWN
                Default:
                  PrintN("Warning: Unknown direction '" + direction + "'. Using 'up'.")
                  scrollDirection = #SCROLL_UP
              EndSelect
            Else
              scrollSpeed = ValF(scrollParam)
              scrollDirection = #SCROLL_UP
            EndIf
            
            If scrollSpeed <= 0 Or scrollSpeed > 100
              PrintN("Warning: Scroll speed " + StrF(scrollSpeed, 1) + " is outside recommended range 0.1-100")
              If scrollSpeed <= 0 : scrollSpeed = 10.0 : EndIf
              If scrollSpeed > 100 : scrollSpeed = 100.0 : EndIf
            EndIf
            
            If verbose
              PrintN("Parameter: scroll mode = ON")
              PrintN("Parameter: scroll speed = " + StrF(scrollSpeed, 1))
              If scrollDirection = #SCROLL_UP
                PrintN("Parameter: scroll direction = UP")
              Else
                PrintN("Parameter: scroll direction = DOWN")
              EndIf
            EndIf
            
          ElseIf Left(param, 6) = "/file:" Or Left(param, 6) = "-file:"
            textFile = Mid(param, 7)
            
            If Left(textFile, 1) = Chr(34)
              textFile = Mid(textFile, 2)
            EndIf
            If Right(textFile, 1) = Chr(34)
              textFile = Left(textFile, Len(textFile) - 1)
            EndIf
            
            If verbose : PrintN("Parameter: text file = " + textFile) : EndIf
            
          ElseIf Left(param, 7) = "/image:" Or Left(param, 7) = "-image:"
            Protected imageParam.s = Mid(param, 8)
            
            ; Extract image path (may be in quotes)
            Protected imagePath.s
            If Left(imageParam, 1) = Chr(34)
              Protected imageQuoteEndPos.i = FindString(imageParam, Chr(34), 2)
              If imageQuoteEndPos > 0
                imagePath = Mid(imageParam, 2, imageQuoteEndPos - 2)
                imageParam = Mid(imageParam, imageQuoteEndPos + 1)
              Else
                PrintN("Error: Missing closing quote in image path")
                ProcedureReturn #False
              EndIf
            Else
              ; Find first colon after path (for mode)
              Protected firstColon.i = FindString(imageParam, ":")
              If firstColon > 0
                imagePath = Left(imageParam, firstColon - 1)
                imageParam = Mid(imageParam, firstColon + 1)
              Else
                imagePath = imageParam
                imageParam = ""
              EndIf
            EndIf
            
            imageFile = imagePath
            
            ; Parse mode if present
            If imageParam <> ""
              Protected modeColon.i = FindString(imageParam, ":")
              If modeColon > 0
                imageMode = Val(Left(imageParam, modeColon - 1))
                imageParam = Mid(imageParam, modeColon + 1)
                
                ; Parse size if present
                If imageParam <> ""
                  ParseImageSize(imageParam, @imageWidth, @imageHeight)
                EndIf
              Else
                imageMode = Val(imageParam)
              EndIf
            EndIf
            
            If verbose
              PrintN("Parameter: image file = " + imageFile)
              PrintN("Parameter: image mode = " + Str(imageMode))
              If imageWidth > 0 And imageHeight > 0
                PrintN("Parameter: image size = " + Str(imageWidth) + "x" + Str(imageHeight))
              EndIf
            EndIf
            
            ElseIf Left(param, 8) = "/quality:" Or Left(param, 8) = "-quality:"
  Protected qualityParam.s = Mid(param, 9)
  Select LCase(qualityParam)
    Case "fast", "0"
      imageQuality = 0
    Case "normal", "1"
      imageQuality = 1
    Case "high", "2"
      imageQuality = 2
    Case "bw", "bwfast"
      imageQuality = 3
    Case "bwhigh"
      imageQuality = 4
  EndSelect
            
          Else
            PrintN("Error: Unknown parameter '" + param + "'")
            ShowHelp()
            ProcedureReturn #False
          EndIf
      EndSelect
      
    Else
      ; This is text content (not a parameter)
      displayText = param
      
      If Left(displayText, 1) = Chr(34)
        Protected quotePos.i = FindString(displayText, Chr(34), 2)
        If quotePos > 0
          displayText = Mid(displayText, 2, quotePos - 2)
          i + 1
          While i < paramCount And params(i) <> Chr(34)
            i + 1
          Wend
        EndIf
      Else
        i + 1
        While i < paramCount
          displayText + " " + params(i)
          i + 1
        Wend
        Break
      EndIf
    EndIf
    
    i + 1
  Wend
  
  ; =============================================
  ; INPUT SOURCE VALIDATION
  ; =============================================
  
  ; 1. Check COM port (always required)
  If comPort = "COM"
    PrintN("Error: COM port not specified")
    PrintN("Use /p:X to specify COM port (e.g., /p:3 for COM3)")
    ProcedureReturn #False
  EndIf
  
  ; 2. Check for multiple content sources
  Protected contentSources.i = 0
  If textFile <> "" : contentSources + 1 : EndIf
  If imageFile <> "" : contentSources + 1 : EndIf
  If displayText <> "" : contentSources + 1 : EndIf
  
  If contentSources > 1 And Not clearScreenOnly
    PrintN("Warning: Multiple content sources specified:")
    If textFile <> "" : PrintN("  - Text file: " + textFile) : EndIf
    If imageFile <> "" : PrintN("  - Image file: " + imageFile) : EndIf
    If displayText <> "" : PrintN("  - Command line text") : EndIf
    PrintN("Only one content source can be processed at a time.")
    PrintN("Processing will use this priority order: Image > Text file > Command line text")
  EndIf
  
  ; 3. Process content sources in priority order
  If imageFile <> ""
    ; Image has highest priority
    If verbose
      If textFile <> "" : PrintN("Note: /image parameter overrides text file") : EndIf
      If displayText <> "" : PrintN("Note: /image parameter overrides command-line text") : EndIf
    EndIf
    
    ; No need to load displayText for images
    displayText = ""
    textFile = ""
    
  ElseIf textFile <> ""
    ; File parameter has second priority
    If displayText <> "" And verbose
      PrintN("Note: /file parameter overrides command-line text")
    EndIf
    
    displayText = LoadTextFromFile(textFile, maxFileLines)
    If displayText = ""
      ProcedureReturn #False
    EndIf
    
  ElseIf displayText = "" And Not clearScreenOnly
    ; No text specified, check stdin
    Protected stdinText.s = ReadFromStdin()
    
    If stdinText <> ""
      ; Found data in stdin
      displayText = stdinText
      If verbose
        PrintN("Input source: Standard input (stdin)")
      EndIf
    Else
      ; No input source found
      PrintN("Error: No content specified")
      PrintN("Please provide content via:")
      PrintN("  1. Command line: WeActCLI /p:3 " + Chr(34) + "text" + Chr(34))
      PrintN("  2. Image file: WeActCLI /p:3 /image:photo.jpg")
      PrintN("  3. Text file: WeActCLI /p:3 /file:log.txt")
      PrintN("  4. Pipe: echo " + Chr(34) + "text" + Chr(34) + " | WeActCLI /p:3")
      PrintN("  5. Or use /CLS to clear screen")
      ProcedureReturn #False
    EndIf
  EndIf
  
  ; All validations passed
  If verbose
    If imageFile <> ""
      PrintN("Input source: Image file: " + imageFile)
    ElseIf textFile <> ""
      PrintN("Input source: Text file: " + textFile)
    ElseIf displayText <> "" And stdinText <> ""
      PrintN("Input source: Standard input (stdin)")
    ElseIf displayText <> ""
      PrintN("Input source: Command line text")
    EndIf
  EndIf
  
  ProcedureReturn #True
EndProcedure

; =============================================
; TEXT PROCESSING FUNCTIONS
; =============================================

; Wraps text to multiple lines based on maximum pixel width
Procedure.s WrapTextToLines(Text.s, FontSize.i, FontName.s, MaxWidth.i, *LineCount.Integer = 0)
  Protected lines.s = ""
  Protected currentLine.s = ""
  Protected word.s = ""
  Protected lineCount.i = 0
  Protected i.i
  
  ; Clean text
  Text = ReplaceString(Text, Chr(9), " ")
  Text = ReplaceString(Text, Chr(0), "")
  
  For i = 1 To Len(Text)
    Protected char.s = Mid(Text, i, 1)
    
    If char = " " Or char = Chr(10) Or char = Chr(13)
      If word <> ""
        If currentLine = ""
          currentLine = word
        Else
          Protected testLine.s = currentLine + " " + word
          Protected testWidth.i = WeAct_GetTextWidth(testLine, FontSize, FontName)
          
          If testWidth <= MaxWidth
            currentLine = testLine
          Else
            If lines <> ""
              lines + #CRLF$
            EndIf
            lines + currentLine
            lineCount + 1
            currentLine = word
          EndIf
        EndIf
        word = ""
      EndIf
      
      ; Handle explicit line breaks
      If char = Chr(10) Or char = Chr(13)
        If currentLine <> ""
          If lines <> ""
            lines + #CRLF$
          EndIf
          lines + currentLine
          lineCount + 1
          currentLine = ""
        EndIf
      EndIf
    Else
      word + char
    EndIf
  Next
  
  ; Process final word
  If word <> ""
    If currentLine = ""
      currentLine = word
    Else
      Protected testLine2.s = currentLine + " " + word
      Protected testWidth2.i = WeAct_GetTextWidth(testLine2, FontSize, FontName)
      
      If testWidth2 <= MaxWidth
        currentLine = testLine2
      Else
        If lines <> ""
          lines + #CRLF$
        EndIf
        lines + currentLine
        lineCount + 1
        currentLine = word
      EndIf
    EndIf
  EndIf  ; <--- ЭТОТ EndIf БЫЛ ПРОПУЩЕН!
  
  ; Add final line
  If currentLine <> ""
    If lines <> ""
      lines + #CRLF$
    EndIf
    lines + currentLine
    lineCount + 1
  EndIf
  
  If *LineCount
    *LineCount\i = lineCount
  EndIf
  
  ProcedureReturn lines
EndProcedure

; Calculates X position for text based on centering setting
Procedure.i GetTextPositionX(Text.s, FontSize.i, FontName.s, ScreenWidth.i)
  Protected textWidth.i = WeAct_GetTextWidth(Text, FontSize, FontName)
  
  If centerText
    Protected centeredX.i = (ScreenWidth - textWidth) / 2
    If centeredX < 0 : centeredX = 0 : EndIf
    
    If verbose
      PrintN("Centering text: '" + Text + "'")
      PrintN("  Screen width: " + Str(ScreenWidth))
      PrintN("  Text width: " + Str(textWidth))
      PrintN("  Calculated X: " + Str(centeredX))
    EndIf
    
    ProcedureReturn centeredX
  Else
    ProcedureReturn 5
  EndIf
EndProcedure

; =============================================
; DISPLAY RENDERING FUNCTIONS
; =============================================

; Displays text with smooth vertical scrolling animation
Procedure DisplayTextWithScrolling(Text.s, Color.i, FontName.s, FontSize.i, Speed.f, Direction.i)
  If verbose
    PrintN("Starting scrolling mode")
    PrintN("Scroll speed: " + StrF(Speed, 1) + " pixels/second")
    If Direction = #SCROLL_UP
      PrintN("Scroll direction: UP")
    Else
      PrintN("Scroll direction: DOWN")
    EndIf
    If centerText
      PrintN("Text centering: ON")
    EndIf
  EndIf
  
  Protected screenWidth.i = WeAct_GetDisplayWidth()
  Protected screenHeight.i = WeAct_GetDisplayHeight()
  
  Protected maxWidth.i
  If centerText
    maxWidth = screenWidth - 20
  Else
    maxWidth = wrapWidth
  EndIf
  
  Protected adjustedFontSize.i = FontSize
  If Not AdjustFontSizeForWords(Text, @adjustedFontSize, FontName, maxWidth)
    PrintN("Error: Could not fit text with current font settings")
    ProcedureReturn #False
  EndIf
  
  If adjustedFontSize <> FontSize
    FontSize = adjustedFontSize
    If verbose
      PrintN("Adjusted font size to: " + Str(FontSize) + "pt")
    EndIf
  EndIf
  
  Protected lineCount.i
  Protected wrappedText.s = WrapTextToLines(Text, FontSize, FontName, maxWidth, @lineCount)
  
  If wrappedText = ""
    PrintN("Error: Could not wrap text")
    ProcedureReturn #False
  EndIf
  
  Protected lineHeight.i = FontSize + lineSpacing
  Protected totalTextHeight.i = lineCount * lineHeight
  
  If verbose
    PrintN("Text wrapped into " + Str(lineCount) + " lines")
    PrintN("Text height: " + Str(totalTextHeight) + " pixels")
    PrintN("Screen height: " + Str(screenHeight) + " pixels")
    PrintN("Screen width: " + Str(screenWidth) + " pixels")
    PrintN("Max width for wrapping: " + Str(maxWidth) + " pixels")
  EndIf
  
  Dim linePositionsX.i(lineCount)
  Dim lineTexts.s(lineCount)
  Protected j.i
  For j = 1 To lineCount
    Protected lineText.s = StringField(wrappedText, j, #CRLF$)
    lineTexts(j - 1) = lineText
    linePositionsX(j - 1) = GetTextPositionX(lineText, FontSize, FontName, screenWidth)
  Next
  
  Protected frameDelay.i = 33
  Protected pixelsPerFrame.f = Speed * (frameDelay / 1000.0)
  
  If verbose
    PrintN("Frame delay: " + Str(frameDelay) + "ms (" + Str(1000/frameDelay) + " FPS)")
    PrintN("Pixels per frame: " + StrF(pixelsPerFrame, 2))
  EndIf
  
  Protected currentY.f
  Protected startY.f
  Protected endY.f
  
  If Direction = #SCROLL_UP
    currentY = screenHeight
    startY = screenHeight
    endY = -totalTextHeight
  Else
    currentY = -totalTextHeight
    startY = -totalTextHeight
    endY = screenHeight
  EndIf
  
  Protected accumulatedPixels.f = 0
  Protected keepScrolling.i = #True
  
  While keepScrolling
    accumulatedPixels + pixelsPerFrame
    If accumulatedPixels >= 1.0
      Protected pixelsToMove.i = Int(accumulatedPixels)
      If Direction = #SCROLL_UP
        currentY - pixelsToMove
      Else
        currentY + pixelsToMove
      EndIf
      accumulatedPixels - pixelsToMove
    EndIf
    
    WeAct_ClearBuffer(#WEACT_BLACK)
    
    Protected anyVisible.i = #False
    For j = 0 To lineCount - 1
      Protected lineY.i = j * lineHeight
      Protected screenY.i
      
      screenY = lineY + Int(currentY)
      
      If screenY >= -lineHeight And screenY < screenHeight
        anyVisible = #True
        WeAct_DrawTextSystemFont(linePositionsX(j), screenY, lineTexts(j), Color, FontSize, FontName)
      EndIf
    Next
    
    WeAct_UpdateDisplay()
    
    If Direction = #SCROLL_UP
      If currentY <= endY
        keepScrolling = #False
      EndIf
    Else
      If currentY >= endY
        keepScrolling = #False
      EndIf
    EndIf
    
    Static noVisibleCounter.i = 0
    If Not anyVisible
      noVisibleCounter + 1
      If noVisibleCounter > 15
        keepScrolling = #False
      EndIf
    Else
      noVisibleCounter = 0
    EndIf
    
    Delay(frameDelay)
  Wend
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateDisplay()
  
  noVisibleCounter = 0
  
  If verbose
    PrintN("Scroll animation completed")
  EndIf
  
  Delay(300)
  
  ProcedureReturn #True
EndProcedure

; Displays static (non-scrolling) text on the screen
Procedure DisplayStaticText(Text.s, Color.i, FontName.s, FontSize.i)
  Protected screenWidth.i = WeAct_GetDisplayWidth()
  Protected screenHeight.i = WeAct_GetDisplayHeight()
  
  Protected maxWidth.i
  If centerText
    maxWidth = screenWidth - 20
  Else
    maxWidth = wrapWidth
  EndIf
  
  Protected adjustedFontSize.i = FontSize
  If Not AdjustFontSizeForWords(Text, @adjustedFontSize, FontName, maxWidth)
    PrintN("Error: Could not fit text with current font settings")
    ProcedureReturn #False
  EndIf
  
  If adjustedFontSize <> FontSize
    FontSize = adjustedFontSize
    If verbose
      PrintN("Adjusted font size to: " + Str(FontSize) + "pt")
    EndIf
  EndIf
  
  Protected lineCount.i
  Protected wrappedText.s = WrapTextToLines(Text, FontSize, FontName, maxWidth, @lineCount)
  
  If wrappedText = ""
    PrintN("Error: Could not wrap text")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  Protected lineHeight.i = FontSize + lineSpacing
  Protected totalHeight.i = lineCount * lineHeight
  Protected startY.i = (screenHeight - totalHeight) / 2
  If startY < 5 : startY = 5 : EndIf
  
  If verbose
    PrintN("Displaying " + Str(lineCount) + " lines")
    PrintN("Vertical position: Y = " + Str(startY))
    PrintN("Line height: " + Str(lineHeight) + " pixels")
  EndIf
  
  Protected i.i
  For i = 1 To lineCount
    Protected line.s = StringField(wrappedText, i, #CRLF$)
    Protected lineX.i = GetTextPositionX(line, FontSize, FontName, screenWidth)
    
    WeAct_DrawTextSystemFont(lineX, startY, line, Color, FontSize, FontName)
    startY + lineHeight
  Next
  
  WeAct_UpdateDisplay()
  Delay(2000)
  
  ProcedureReturn #True
EndProcedure

; =============================================
; MAIN DISPLAY CONTROL FUNCTION
; =============================================

Procedure DisplayContent()
  If verbose
    PrintN("")
    PrintN("=== Starting display operation ===")
    PrintN("Initializing WeAct Display FS...")
    PrintN("Port: " + comPort)
    If clearScreenOnly
      PrintN("Mode: Clear screen only")
    Else
      If imageFile <> ""
        PrintN("Source: Image file: " + imageFile)
        PrintN("Image mode: " + Str(imageMode))
        If imageWidth > 0 And imageHeight > 0
          PrintN("Image size: " + Str(imageWidth) + "x" + Str(imageHeight))
        EndIf
      ElseIf textFile <> ""
        PrintN("Source: Text file: " + textFile)
      Else
        PrintN("Source: Command line text")
      EndIf
      
      If displayText <> ""
        If Len(displayText) > 100
          PrintN("Text preview: " + Left(displayText, 100) + "...")
        Else
          PrintN("Text: " + displayText)
        EndIf
        PrintN("Text length: " + Str(Len(displayText)) + " characters")
      EndIf
      
      PrintN("Font: " + fontName + " (" + Str(fontSize) + "pt)")
      PrintN("Text color: " + Str(textColor))
      
      If scrollMode
        PrintN("Scroll mode: ON")
        PrintN("Scroll speed: " + StrF(scrollSpeed, 1) + " px/s")
        If scrollDirection = #SCROLL_UP
          PrintN("Scroll direction: UP")
        Else
          PrintN("Scroll direction: DOWN")
        EndIf
      Else
        PrintN("Scroll mode: OFF")
      EndIf
      
      PrintN("Text centering: " + IIf(centerText, "ON", "OFF"))
      PrintN("Clear screen only: " + IIf(clearScreenOnly, "ON", "OFF"))
    EndIf
    PrintN("")
  EndIf
  
  If WeAct_Init(comPort)
    If verbose
      Protected displayWidth.i = WeAct_GetDisplayWidth()
      Protected displayHeight.i = WeAct_GetDisplayHeight()
      PrintN("Display initialized successfully")
      PrintN("Display size: " + Str(displayWidth) + "x" + Str(displayHeight))
      PrintN("centerText global variable = " + Str(centerText))
    EndIf
    
    If clearScreenOnly
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_UpdateDisplay()
      Delay(500)
    ElseIf imageFile <> ""
      DisplayImageFromFile(imageFile, imageMode, imageWidth, imageHeight)
    ElseIf scrollMode
      DisplayTextWithScrolling(displayText, textColor, fontName, fontSize, scrollSpeed, scrollDirection)
    Else
      DisplayStaticText(displayText, textColor, fontName, fontSize)
    EndIf
    
    WeAct_Cleanup()
    
    If verbose
      PrintN("Display connection closed")
    EndIf
    
    ProcedureReturn #True
    
  Else
    PrintN("Error: Failed to initialize display on " + comPort)
    PrintN("Error details: " + WeAct_GetLastError())
    PrintN("Please check:")
    PrintN("  1. COM port number")
    PrintN("  2. Display connection")
    PrintN("  3. Driver installation")
    ProcedureReturn #False
  EndIf
EndProcedure

; =============================================
; MAIN PROGRAM ENTRY POINT
; =============================================

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  PrintN("Error: This program requires Windows")
  End 1
CompilerEndIf

If ParseCommandLine()
  If clearScreenOnly And displayText = "" And imageFile = ""
    ClearDisplayOnly()
  Else
    DisplayContent()
  EndIf
  
  If verbose
    PrintN("")
    PrintN("=== Operation completed successfully ===")
  EndIf
  
  End 0
Else
  End 1
EndIf

; =============================================
; COMPILER DIRECTIVES
; =============================================
; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 956
; FirstLine = 948
; Folding = ---
; EnableXP
; Executable = WeActCLI.exe
; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 114
; FirstLine = 78
; Folding = ----
; EnableXP
; Executable = WeactImg.exe