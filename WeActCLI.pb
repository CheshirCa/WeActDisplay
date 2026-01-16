; WeActCLI - Console Text and Image Display Utility for WeAct Display FS
; Main program file for displaying text and images on WeAct Display via serial port

XIncludeFile "WeActDisplay.pbi"

OpenConsole()

; =============================================
; GLOBAL VARIABLES
; =============================================

; Flag for detailed output mode
Global verbose.i = #False

; Serial port for display connection (default: COM3)
Global comPort.s = "COM3"

; Text color in BRG565 format (default: white)
Global textColor.i = #WEACT_WHITE

; Text to display (from command line, file, or stdin)
Global displayText.s = ""

; Path to image file
Global imageFile.s = ""

; Maximum pixel width for text wrapping
Global wrapWidth.i = 150

; Vertical space between text lines in pixels
Global lineSpacing.i = 2

; Font name for rendering
Global fontName.s = "Arial"

; Font size in points
Global fontSize.i = 8

; Scrolling speed in pixels per second
Global scrollSpeed.f = 30.0

; Enable/disable scrolling mode
Global scrollMode.i = #False

; Scrolling direction (#SCROLL_UP or #SCROLL_DOWN)
Global scrollDirection.i = #SCROLL_UP

; Flag for horizontal text centering
Global centerText.i = #False

; Flag for screen clear only (no content display)
Global clearScreenOnly.i = #False

; Path to text file for loading content
Global textFile.s = ""

; Maximum lines to load from file (prevents memory issues)
Global maxFileLines.i = 1000

; Image display mode: 0=fit screen, 1=original size, 2=centered
Global imageMode.i = 0

; Custom image dimensions for mode 2 (-1 = use original size)
Global imageWidth.i = -1
Global imageHeight.i = -1

; Image quality: 0=fast, 1=normal, 2=high, 3=bw fast, 4=bw high
Global imageQuality.i = 1

; Text position coordinates (-1 = auto-position)
Global textX.i = -1
Global textY.i = -1

; Clear screen before drawing? False when using /x: or /y: (overlay mode)
Global clearScreen.i = #True

; =============================================
; UTILITY FUNCTIONS
; =============================================

; Loads text from a file with UTF-8 encoding support
; FilePath: Full path to text file
; MaxLines: Maximum lines to load (avoids memory issues)
; Returns: String with file content or empty string on error
Procedure.s LoadTextFromFile(FilePath.s, MaxLines.i = 1000)
  Protected result.s = ""      ; Text content to return
  Protected lineCount.i = 0    ; Number of lines loaded
  Protected file.i            ; File handle
  
  ; Check if file exists and is not empty
  If FileSize(FilePath) <= 0
    PrintN("Error: File '" + FilePath + "' not found or empty")
    ProcedureReturn ""
  EndIf
  
  ; Open file with UTF-8 encoding
  file = ReadFile(#PB_Any, FilePath)
  If Not file                 ; File open failed
    PrintN("Error: Cannot open file '" + FilePath + "'")
    ProcedureReturn ""
  EndIf
  
  ; Read lines until end of file or max lines reached
  While Not Eof(file) And lineCount < MaxLines
    Protected line.s = ReadString(file, #PB_UTF8)  ; Read UTF-8 line
    
    ; Add line break before each line except the first
    If result <> ""
      result + #CRLF$ + line
    Else
      result = line
    EndIf
    lineCount + 1
  Wend
  
  CloseFile(file)              ; Close file
  
  ProcedureReturn result
EndProcedure

; Displays image from file using WeAct display functions
; ImagePath: Full path to image file
; Mode: Display mode (0=fit screen, 1=original size, 2=centered)
; ImgWidth: Custom width for mode 2
; ImgHeight: Custom height for mode 2
; Returns: #True if successful, #False if failed
Procedure DisplayImageFromFile(ImagePath.s, Mode.i = 0, ImgWidth.i = -1, ImgHeight.i = -1)
  Protected result.i = #False  ; Success flag
  
  ; Test if image can be loaded
  Protected testImage = LoadImage(#PB_Any, ImagePath)
  If testImage
    FreeImage(testImage)       ; Free test image
  EndIf
  
  ; Select display function based on mode
  Select Mode
    Case 0  ; Fit to screen (keep aspect ratio)
      result = WeAct_LoadImageFullScreen(ImagePath)
      
    Case 1  ; Original size at top-left corner
      result = WeAct_LoadImageToBuffer(0, 0, ImagePath, ImgWidth, ImgHeight)
      
    Case 2  ; Centered with optional custom size
      result = WeAct_LoadImageCentered(ImagePath, ImgWidth, ImgHeight)
  EndSelect
  
  ; Update display if image loaded successfully
  If result
    If WeAct_UpdateDisplay()
      ProcedureReturn #True
    EndIf
  Else
    PrintN("Error: Failed to load image - " + WeAct_GetLastError())
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Reads data from standard input (stdin)
; Allows piping text into program: echo "text" | WeActCLI /p:3
; Returns: String with stdin data or empty string if none
Procedure.s ReadFromStdin()
  Protected result.s = ""      ; Result string
  
  ; Windows-specific stdin handling
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected consoleCP.i = GetConsoleCP_()      ; Console codepage
    Protected isRedirected.i = #False           ; Pipe/file redirection flag
    
    ; Check if stdin is redirected (pipe or file)
    Protected hStdin = GetStdHandle_(#STD_INPUT_HANDLE)
    Protected fileType = GetFileType_(hStdin)
    
    If fileType <> #FILE_TYPE_CHAR
      isRedirected = #True     ; stdin is redirected
    EndIf
    
    ; Determine encoding (UTF-8 for redirected, console CP otherwise)
    Protected useCodepage.i = consoleCP
    If isRedirected
      useCodepage = #CP_UTF8
    EndIf
    
    ; Allocate buffer for reading
    Protected bufferSize = 65536    ; 64KB
    Protected *buffer = AllocateMemory(bufferSize)
    
    If *buffer
      Protected bytesRead.l         ; Bytes read in current operation
      Protected totalBytesRead = 0  ; Total bytes read
      
      ; Read all available data from stdin
      While #True
        Protected bytesAvailable.l   ; Available bytes
        
        ; Check how many bytes are available
        If PeekNamedPipe_(hStdin, #Null, 0, #Null, @bytesAvailable, #Null)
          If bytesAvailable > 0
            ; Read available data
            If ReadFile_(hStdin, *buffer + totalBytesRead, bytesAvailable, @bytesRead, #Null)
              totalBytesRead + bytesRead
              
              ; Stop if buffer is almost full
              If totalBytesRead >= bufferSize - 1024
                Break
              EndIf
            Else
              Break  ; Read failed
            EndIf
          Else
            Break    ; No more data
          EndIf
        Else
          ; Failed to check availability, try direct read
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
      
      ; Convert bytes to string based on encoding
      If totalBytesRead > 0
        ; UTF-8 encoding
        If useCodepage = 65001 Or useCodepage = #CP_UTF8
          result = PeekS(*buffer, totalBytesRead, #PB_UTF8)
        ; Windows-1251 (Cyrillic)
        ElseIf useCodepage = 1251
          result = PeekS(*buffer, totalBytesRead, #PB_Ascii)
        ; CP866 (DOS Cyrillic)
        ElseIf useCodepage = 866
          result = PeekS(*buffer, totalBytesRead, #PB_Ascii)
        ; Other encodings
        Else
          ; Try UTF-8 first, fall back to ANSI if invalid
          Protected testResult.s = PeekS(*buffer, totalBytesRead, #PB_UTF8)
          Protected isValidUTF8.i = #True
          
          ; Check for invalid UTF-8 characters (codes 128-159)
          Protected k.i
          For k = 1 To Len(testResult)
            Protected charCode.i = Asc(Mid(testResult, k, 1))
            If charCode >= 128 And charCode <= 159
              isValidUTF8 = #False
              Break
            EndIf
          Next
          
          If isValidUTF8 And testResult <> ""
            result = testResult           ; Valid UTF-8
          Else
            ; Fall back to ANSI (Windows-1252)
            result = PeekS(*buffer, totalBytesRead, #PB_Ascii)
          EndIf
        EndIf
        
        ; Clean up: remove null chars and trailing line breaks
        result = ReplaceString(result, Chr(0), "")
        result = RTrim(result, #CR$ + #LF$)
      EndIf
      
      FreeMemory(*buffer)      ; Free buffer
    EndIf
    
  CompilerElse
    ; Linux/Mac stdin handling (always UTF-8)
    Protected stdinFile.i = ReadFile(#PB_Any, "")  ; Open stdin as file
    If stdinFile
      Protected fileSize.i = Lof(stdinFile)        ; Get data size
      If fileSize > 0
        Protected *fileBuffer = AllocateMemory(fileSize)
        If *fileBuffer
          ReadData(stdinFile, *fileBuffer, fileSize)  ; Read all data
          result = PeekS(*fileBuffer, fileSize, #PB_UTF8)  ; Convert to UTF-8
          FreeMemory(*fileBuffer)
        EndIf
      EndIf
      CloseFile(stdinFile)
    EndIf
  CompilerEndIf
  
  ProcedureReturn result
EndProcedure

; Inline-if function for strings
; Condition: Boolean condition
; TrueValue: Return if condition true
; FalseValue: Return if condition false
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

; Displays comprehensive help information
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
  PrintN("  7. Multi-line text:   WeActCLI /p:3 "+ Chr(34) + "Line 1\\nLine 2\\nLine 3" + Chr(34))
  PrintN("")
  PrintN("SYNTAX: WeActCLI /p:X [/v][/c:YYY] [/f:" + Chr(34) + "Font Name" + Chr(34) + ":Size] [/s:Speed[:u|d]] [/center] [/x:X] [/y:Y] [/CLS] [/file:" + Chr(34) + "path\name.txt" + Chr(34) + "] [/image:" + Chr(34) + "path\image.jpg" + Chr(34) + "[:mode[:WxH]]] [" + Chr(34) + "text" + Chr(34) + "]")
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
  PrintN("  /x:X       - X coordinate for text position (optional)")
  PrintN("               When specified, text is placed at exact position")
  PrintN("               without clearing screen (overlay mode)")
  PrintN("               Example: /x:10 /y:20")
  PrintN("")
  PrintN("  /y:Y       - Y coordinate for text position (optional)")
  PrintN("               Used together with /x: for precise positioning")
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
  PrintN("               Use \n for line breaks in text")
  PrintN("               Example: WeActCLI /p:3 " + Chr(34) + "Line 1\\nLine 2" + Chr(34))
  PrintN("")
  PrintN("ENCODING NOTES:")
  PrintN("  - For Russian text, use UTF-8 encoding")
  PrintN("  - In PowerShell: [Console]::OutputEncoding = [System.Text.Encoding]::UTF8")
  PrintN("  - In CMD: chcp 65001")
  PrintN("  - Or use text files with UTF-8 encoding")
  PrintN("  - Use \\n for line breaks: " + Chr(34) + "Line1\\nLine2" + Chr(34))
  PrintN("")
  PrintN("IMAGE FORMATS:")
  PrintN("  Supported: " + WeAct_GetSupportedImageFormats())
  PrintN("")
EndProcedure

; =============================================
; DISPLAY CONTROL FUNCTIONS
; =============================================

; Clears the display screen (no text)
; Used with /CLS parameter
; Returns: #True if successful, #False if failed
Procedure ClearDisplayOnly()
  ; Initialize display connection
  If WeAct_Init(comPort)
    ; Clear to black and update
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateDisplay()
    
    Delay(100)                   ; Wait for display update
    WeAct_Cleanup()              ; Close connection
    
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

; Checks if a font is likely available on Windows
; FontName: Font name to check
; Returns: #True if available, #False otherwise
Procedure.i IsFontAvailable(FontName.s)
  ; List of common Windows fonts
  Protected commonFonts.s = "Arial,Tahoma,Verdana,Courier New,Courier,Times New Roman," +
                            "Segoe UI,Calibri,Microsoft Sans Serif,Consolas," +
                            "Comic Sans MS,Impact,Lucida Console"
  
  Protected i.i
  For i = 1 To CountString(commonFonts, ",") + 1
    ; Case-insensitive comparison
    If LCase(StringField(commonFonts, i, ",")) = LCase(FontName)
      ProcedureReturn #True     ; Found in common list
    EndIf
  Next
  
  ; Special case for "Courier"
  If LCase(FontName) = "courier"
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Checks if a word fits within specified maximum width
; Word: Single word to check
; FontSize: Font size in points
; FontName: Font name
; MaxWidth: Maximum allowed width in pixels
; Returns: #True if word fits, #False if too wide
Procedure.i CheckWordFits(Word.s, FontSize.i, FontName.s, MaxWidth.i)
  ; Get pixel width of word with current font
  Protected wordWidth.i = WeAct_GetTextWidth(Word, FontSize, FontName)
  ; Check against maximum
  ProcedureReturn Bool(wordWidth <= MaxWidth)
EndProcedure

; Reduces font size to ensure all words fit within maximum width
; Text: Full text to check
; *FontSize: Pointer to font size variable (will be modified)
; FontName: Font name
; MaxWidth: Maximum allowed width
; Returns: #True if text can fit, #False if impossible
Procedure.i AdjustFontSizeForWords(Text.s, *FontSize.Integer, FontName.s, MaxWidth.i)
  Protected originalSize.i = *FontSize\i   ; Original font size
  Protected currentSize.i = originalSize   ; Current test size
  Protected minSize.i = 6                  ; Minimum font size
  
  ; Clean text
  Text = ReplaceString(Text, Chr(9), " ")   ; Tab to space
  Text = ReplaceString(Text, Chr(0), "")    ; Remove nulls
  
  ; Count words
  Protected wordCount.i = CountString(Text, " ") + 1
  Protected i.i
  
  ; Try progressively smaller sizes
  For currentSize = originalSize To minSize Step -1
    Protected allWordsFit.i = #True  ; Assume all fit at this size
    
    ; Check each word
    For i = 1 To wordCount
      Protected word.s = StringField(Text, i, " ")
      If word <> ""                  ; Skip empty words
        If Not CheckWordFits(word, currentSize, FontName, MaxWidth)
          allWordsFit = #False       ; Word doesn't fit
          Break
        EndIf
      EndIf
    Next
    
    ; If all words fit, use this size
    If allWordsFit
      *FontSize\i = currentSize
      ProcedureReturn #True
    EndIf
  Next
  
  ; No size works (down to 6pt)
  ProcedureReturn #False
EndProcedure

; =============================================
; COMMAND-LINE PARSING FUNCTIONS
; =============================================

; Checks if string is a command-line parameter
; Parameters start with / or - followed by a letter
; Text: String to check
; Returns: #True if parameter, #False otherwise
Procedure.i IsParameter(Text.s)
  If Left(Text, 1) = "/" Or Left(Text, 1) = "-"
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Parses image size string like "64x64"
; SizeString: String with width and height
; *Width: Pointer to store width
; *Height: Pointer to store height
; Returns: #True if successful, #False if invalid
Procedure ParseImageSize(SizeString.s, *Width.Integer, *Height.Integer)
  ; Find the 'x' separator
  Protected xPos.i = FindString(SizeString, "x")
  If xPos > 0
    ; Extract width and height
    *Width\i = Val(Left(SizeString, xPos - 1))
    *Height\i = Val(Mid(SizeString, xPos + 1))
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

; =============================================
; COMMAND LINE PARSER
; =============================================
; Main command-line parsing function
; Processes all parameters and sets global variables
; Returns: #True if successful, #False if error
Procedure ParseCommandLine()
  Protected paramCount = CountProgramParameters()  ; Number of arguments
  
  ; If no parameters and no stdin, show help
  If paramCount = 0
    Protected stdinTest.s = ReadFromStdin()       ; Check stdin
    If stdinTest = ""
      ShowHelp()            ; No input, show help
      ProcedureReturn #False
    Else
      ; Use stdin data as display text
      displayText = stdinTest
    EndIf
  EndIf
  
  ; Store parameters in array
  Dim params.s(paramCount - 1)
  Protected i.i
  For i = 0 To paramCount - 1
    params(i) = ProgramParameter(i)
  Next
  
  ; Process parameters in order
  i = 0
  While i < paramCount
    Protected param.s = params(i)  ; Current parameter
    
    If IsParameter(param)          ; Parameter starts with / or -
      Select LCase(param)          ; Case-insensitive
        Case "/center", "-center"
          centerText = #True
          
        Case "/cls", "-cls"
          clearScreenOnly = #True
          
        Case "/v", "-v"
          verbose = #True
          
        Case "/?", "-?", "/h", "-h"
          ShowHelp()
          ProcedureReturn #False
          
        Default:
          ; COM port: /p:X or -p:X
          If Left(param, 3) = "/p:" Or Left(param, 3) = "-p:"
            comPort = "COM" + Mid(param, 4)  ; Extract port number
            
          ; Color: /c:YYY or -c:YYY
          ElseIf Left(param, 3) = "/c:" Or Left(param, 3) = "-c:"
            Protected colorName.s = LCase(Mid(param, 4))  ; Color name
            
            ; Map names to BRG565 color constants
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
            
          ; Font: /f:"Font Name":Size or -f:"Font Name":Size
          ElseIf Left(param, 3) = "/f:" Or Left(param, 3) = "-f:"
            Protected fontParam.s = Mid(param, 4)
            
            ; Handle quoted font names
            If Left(fontParam, 1) = Chr(34)
              Protected quoteEndPos.i = FindString(fontParam, Chr(34), 2)
              If quoteEndPos > 0
                fontName = Mid(fontParam, 2, quoteEndPos - 2)
                
                ; Find font size after closing quote
                Protected sizeStartPos.i = FindString(fontParam, ":", quoteEndPos)
                If sizeStartPos > 0
                  fontSize = Val(Mid(fontParam, sizeStartPos + 1))
                Else
                  fontSize = 8  ; Default
                EndIf
              Else
                PrintN("Error: Missing closing quote in font name")
                ProcedureReturn #False
              EndIf
            Else
              ; Unquoted font name
              Protected colonPos.i = FindString(fontParam, ":")
              If colonPos > 0
                fontName = Left(fontParam, colonPos - 1)
                fontSize = Val(Mid(fontParam, colonPos + 1))
              Else
                fontName = fontParam
                fontSize = 8
              EndIf
            EndIf
            
            ; Validate font size (6-32 points)
            If fontSize < 6 Or fontSize > 32
              If fontSize < 6 : fontSize = 6 : EndIf
              If fontSize > 32 : fontSize = 32 : EndIf
            EndIf
            
            ; Check font availability, fall back to Arial
            If Not IsFontAvailable(fontName)
              fontName = "Arial"
            EndIf
            
          ; Scroll: /s:Speed[:u|d] or -s:Speed[:u|d]
          ElseIf Left(param, 3) = "/s:" Or Left(param, 3) = "-s:"
            scrollMode = #True
            Protected scrollParam.s = Mid(param, 4)
            
            Protected dirPos.i = FindString(scrollParam, ":")
            If dirPos > 0
              ; Has direction (e.g., 25.5:u)
              scrollSpeed = ValF(Left(scrollParam, dirPos - 1))
              Protected direction.s = LCase(Mid(scrollParam, dirPos + 1))
              
              Select direction
                Case "u", "up":
                  scrollDirection = #SCROLL_UP
                Case "d", "down":
                  scrollDirection = #SCROLL_DOWN
                Default:
                  scrollDirection = #SCROLL_UP
              EndSelect
            Else
              ; No direction (e.g., 25.5)
              scrollSpeed = ValF(scrollParam)
              scrollDirection = #SCROLL_UP
            EndIf
            
            ; Validate scroll speed (0.1-100 px/s)
            If scrollSpeed <= 0 Or scrollSpeed > 100
              If scrollSpeed <= 0 : scrollSpeed = 10.0 : EndIf
              If scrollSpeed > 100 : scrollSpeed = 100.0 : EndIf
            EndIf
            
          ; File: /file:"path" or -file:"path"
          ElseIf Left(param, 6) = "/file:" Or Left(param, 6) = "-file:"
            textFile = Mid(param, 7)
            
            ; Remove quotes if present
            If Left(textFile, 1) = Chr(34)
              textFile = Mid(textFile, 2)
            EndIf
            If Right(textFile, 1) = Chr(34)
              textFile = Left(textFile, Len(textFile) - 1)
            EndIf
            
          ; Image: /image:"path"[:mode[:WxH]] or -image:"path"[:mode[:WxH]]
          ElseIf Left(param, 7) = "/image:" Or Left(param, 7) = "-image:"
            Protected imageParam.s = Mid(param, 8)
            
            ; Extract image path
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
              ; Unquoted path
              Protected firstColon.i = FindString(imageParam, ":")
              If firstColon > 0
                imagePath = Left(imageParam, firstColon - 1)
                imageParam = Mid(imageParam, firstColon + 1)
              Else
                imagePath = imageParam
                imageParam = ""
              EndIf
            EndIf
            
            imageFile = imagePath  ; Store path
            
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
                imageMode = Val(imageParam)  ; Just mode
              EndIf
            EndIf
            
          ; Quality: /quality:value or -quality:value
          ElseIf Left(param, 9) = "/quality:" Or Left(param, 9) = "-quality:"
            Protected qualityParam.s = Mid(param, 10)
            
            ; Map quality names to numeric values
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
            
          ; X coordinate: /x:value or -x:value
          ElseIf Left(param, 3) = "/x:" Or Left(param, 3) = "-x:"
            textX = Val(Mid(param, 4))
            clearScreen = #False  ; Overlay mode
            
          ; Y coordinate: /y:value or -y:value
          ElseIf Left(param, 3) = "/y:" Or Left(param, 3) = "-y:"
            textY = Val(Mid(param, 4))
            clearScreen = #False  ; Overlay mode
            
          Else
            PrintN("Error: Unknown parameter '" + param + "'")
            ShowHelp()
            ProcedureReturn #False
          EndIf
      EndSelect
      
    Else
      ; Not a parameter, it's text content
      displayText = param
      
      ; Handle quoted text
      If Left(displayText, 1) = Chr(34)
        Protected quotePos.i = FindString(displayText, Chr(34), 2)
        If quotePos > 0
          displayText = Mid(displayText, 2, quotePos - 2)
          
          ; Skip remaining part of quoted text
          i + 1
          While i < paramCount And params(i) <> Chr(34)
            i + 1
          Wend
        EndIf
      Else
        ; Unquoted text: concatenate until next parameter
        i + 1
        While i < paramCount
          displayText + " " + params(i)
          i + 1
        Wend
        Break  ; Exit loop
      EndIf
    EndIf
    
    i + 1  ; Next parameter
  Wend
  
  ; =============================================
  ; INPUT SOURCE VALIDATION
  ; =============================================
  
  ; 1. COM port is required
  If comPort = "COM"  ; No number specified
    PrintN("Error: COM port not specified")
    PrintN("Use /p:X to specify COM port (e.g., /p:3 for COM3)")
    ProcedureReturn #False
  EndIf
  
  ; 2. Count content sources
  Protected contentSources.i = 0
  If textFile <> "" : contentSources + 1 : EndIf
  If imageFile <> "" : contentSources + 1 : EndIf
  If displayText <> "" : contentSources + 1 : EndIf
  
  ; 3. Process sources in priority order
  If imageFile <> ""
    ; Image has highest priority
    displayText = ""
    textFile = ""
    
  ElseIf textFile <> ""
    ; File parameter second
    displayText = LoadTextFromFile(textFile, maxFileLines)
    If displayText = ""  ; Failed to load
      ProcedureReturn #False
    EndIf
    
  ElseIf displayText = "" And Not clearScreenOnly
    ; No text, check stdin
    Protected stdinText.s = ReadFromStdin()
    
    If stdinText <> ""
      displayText = stdinText
    Else
      ; No input source
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
  
  ; Process newline escape sequences
  If displayText <> ""
    displayText = ReplaceString(displayText, "\n", #CRLF$)
  EndIf
  
  ProcedureReturn #True  ; Parsing successful
EndProcedure

; =============================================
; TEXT PROCESSING FUNCTIONS
; =============================================

; Wraps text to multiple lines based on pixel width
; Text: Text to wrap
; FontSize: Font size in points
; FontName: Font name
; MaxWidth: Maximum width in pixels
; *LineCount: Optional pointer for line count
; Returns: Text with CRLF line breaks
Procedure.s WrapTextToLines(Text.s, FontSize.i, FontName.s, MaxWidth.i, *LineCount.Integer = 0)
  Protected lines.s = ""
  Protected currentLine.s = ""
  Protected word.s = ""
  Protected lineCount.i = 0
  Protected i.i
  Protected afterNewline.i = #False
  
  Text = ReplaceString(Text, Chr(9), " ")
  Text = ReplaceString(Text, Chr(0), "")
  
  For i = 1 To Len(Text)
    Protected char.s = Mid(Text, i, 1)
    
    If char = Chr(10) Or char = Chr(13)  ; Line break
      If word <> ""
        If currentLine = ""
          currentLine = word
        Else
          currentLine + " " + word
        EndIf
        word = ""
      EndIf
      
      If currentLine <> ""
        If lines <> ""
          lines + #CRLF$
        EndIf
        lines + currentLine
        lineCount + 1
        currentLine = ""
      EndIf
      
      afterNewline = #True
      
    ElseIf char = " "  ; Space
      If afterNewline
        currentLine + char
      Else
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
      EndIf
    Else  ; Regular character
      word + char
      afterNewline = #False
    EndIf
  Next
  
  ; Handle last word
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
  EndIf
  
  ; Add last line if not empty
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

; Calculates X position for text based on centering
; Text: Text string
; FontSize: Font size in points
; FontName: Font name
; ScreenWidth: Display width in pixels
; Returns: X coordinate for text
Procedure.i GetTextPositionX(Text.s, FontSize.i, FontName.s, ScreenWidth.i)
  Protected textWidth.i = WeAct_GetTextWidth(Text, FontSize, FontName)
  
  ; Use specified X if provided
  If textX >= 0
    ProcedureReturn textX
  EndIf
  
  If centerText
    ; Center horizontally
    Protected centeredX.i = (ScreenWidth - textWidth) / 2
    If centeredX < 0 : centeredX = 0 : EndIf  ; Clamp to 0
    
    ProcedureReturn centeredX
  Else
    ; Left-align with 5 pixel margin
    ProcedureReturn 5
  EndIf
EndProcedure

; =============================================
; DISPLAY RENDERING FUNCTIONS
; =============================================

; Displays text with smooth vertical scrolling
; Text: Text to scroll
; Color: Text color in BRG565
; FontName: Font name
; FontSize: Font size in points
; Speed: Scroll speed in px/s
; Direction: #SCROLL_UP or #SCROLL_DOWN
; Returns: #True if successful, #False if failed
Procedure DisplayTextWithScrolling(Text.s, Color.i, FontName.s, FontSize.i, Speed.f, Direction.i)
  Protected screenWidth.i = WeAct_GetDisplayWidth()
  Protected screenHeight.i = WeAct_GetDisplayHeight()
  
  ; Calculate max width for wrapping
  Protected maxWidth.i
  If centerText
    maxWidth = screenWidth - 20  ; Center mode
  Else
    maxWidth = wrapWidth         ; Left-align mode
  EndIf
  
  ; Adjust font size if needed
  Protected adjustedFontSize.i = FontSize
  If Not AdjustFontSizeForWords(Text, @adjustedFontSize, FontName, maxWidth)
    PrintN("Error: Could not fit text with current font settings")
    ProcedureReturn #False
  EndIf
  
  If adjustedFontSize <> FontSize
    FontSize = adjustedFontSize
  EndIf
  
  ; Wrap text into lines
  Protected lineCount.i
  Protected wrappedText.s = WrapTextToLines(Text, FontSize, FontName, maxWidth, @lineCount)
  
  If wrappedText = ""
    PrintN("Error: Could not wrap text")
    ProcedureReturn #False
  EndIf
  
  ; Calculate text dimensions
  Protected lineHeight.i = FontSize + lineSpacing
  Protected totalTextHeight.i = lineCount * lineHeight
  
  ; Store each line's text and X position
  Dim linePositionsX.i(lineCount)
  Dim lineTexts.s(lineCount)
  Protected j.i
  For j = 1 To lineCount
    Protected lineText.s = StringField(wrappedText, j, #CRLF$)
    lineTexts(j - 1) = lineText
    linePositionsX(j - 1) = GetTextPositionX(lineText, FontSize, FontName, screenWidth)
  Next
  
  ; Animation parameters
  Protected frameDelay.i = 33  ; ~30 FPS
  Protected pixelsPerFrame.f = Speed * (frameDelay / 1000.0)  ; Pixels per frame
  
  ; Set initial scroll position
  Protected currentY.f
  Protected startY.f
  Protected endY.f
  
  If Direction = #SCROLL_UP
    ; Start at bottom, scroll up
    currentY = screenHeight
    startY = screenHeight
    endY = -totalTextHeight  ; End when text completely above screen
  Else
    ; Start at top, scroll down
    currentY = -totalTextHeight
    startY = -totalTextHeight
    endY = screenHeight      ; End when text completely below screen
  EndIf
  
  ; Fractional pixel accumulator for smooth scrolling
  Protected accumulatedPixels.f = 0
  Protected keepScrolling.i = #True
  
  ; Main scroll loop
  While keepScrolling
    ; Add pixels for this frame
    accumulatedPixels + pixelsPerFrame
    
    ; Move integer pixels when accumulated enough
    If accumulatedPixels >= 1.0
      Protected pixelsToMove.i = Int(accumulatedPixels)
      If Direction = #SCROLL_UP
        currentY - pixelsToMove  ; Move up
      Else
        currentY + pixelsToMove  ; Move down
      EndIf
      accumulatedPixels - pixelsToMove
    EndIf
    
    ; Clear screen for new frame
    WeAct_ClearBuffer(#WEACT_BLACK)
    
    ; Draw each line at current scroll position
    Protected anyVisible.i = #False
    For j = 0 To lineCount - 1
      Protected lineY.i = j * lineHeight
      Protected screenY.i = lineY + Int(currentY)
      
      ; Draw only if line is (partially) visible
      If screenY >= -lineHeight And screenY < screenHeight
        anyVisible = #True
        WeAct_DrawTextSystemFont(linePositionsX(j), screenY, lineTexts(j), Color, FontSize, FontName)
      EndIf
    Next
    
    ; Update display
    WeAct_UpdateDisplay()
    
    ; Check if scrolling should stop
    If Direction = #SCROLL_UP
      If currentY <= endY
        keepScrolling = #False  ; Text completely above screen
      EndIf
    Else
      If currentY >= endY
        keepScrolling = #False  ; Text completely below screen
      EndIf
    EndIf
    
    ; Safety: stop if no lines visible for too long
    Static noVisibleCounter.i = 0
    If Not anyVisible
      noVisibleCounter + 1
      If noVisibleCounter > 15  ; ~0.5 second
        keepScrolling = #False
      EndIf
    Else
      noVisibleCounter = 0
    EndIf
    
    ; Wait for next frame
    Delay(frameDelay)
  Wend
  
  ; Clear screen after scrolling
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateDisplay()
  
  noVisibleCounter = 0  ; Reset static counter
  
  Delay(300)  ; Pause after scrolling
  
  ProcedureReturn #True
EndProcedure

; Displays static (non-scrolling) text
; Text: Text to display
; Color: Text color in BRG565
; FontName: Font name
; FontSize: Font size in points
; Returns: #True if successful, #False if failed
Procedure DisplayStaticText(Text.s, Color.i, FontName.s, FontSize.i)
  Protected screenWidth.i = WeAct_GetDisplayWidth()
  Protected screenHeight.i = WeAct_GetDisplayHeight()
  
  ; Calculate max width for wrapping
  Protected maxWidth.i
  If centerText
    maxWidth = screenWidth - 20  ; Center mode
  Else
    maxWidth = wrapWidth         ; Left-align mode
  EndIf
  
  ; Adjust font size if needed
  Protected adjustedFontSize.i = FontSize
  If Not AdjustFontSizeForWords(Text, @adjustedFontSize, FontName, maxWidth)
    PrintN("Error: Could not fit text with current font settings")
    ProcedureReturn #False
  EndIf
  
  If adjustedFontSize <> FontSize
    FontSize = adjustedFontSize
  EndIf
  
  ; Wrap text into lines
  Protected lineCount.i
  Protected wrappedText.s = WrapTextToLines(Text, FontSize, FontName, maxWidth, @lineCount)
  
  If wrappedText = ""
    PrintN("Error: Could not wrap text")
    ProcedureReturn #False
  EndIf
  
  ; Clear screen only if not in overlay mode
  If clearScreen
    WeAct_ClearBuffer(#WEACT_BLACK)
  EndIf
  
  ; Calculate vertical positioning
  Protected lineHeight.i = FontSize + lineSpacing
  Protected totalHeight.i = lineCount * lineHeight
  Protected startY.i
  
  ; Use specified Y or center vertically
  If textY >= 0
    startY = textY
  Else
    startY = (screenHeight - totalHeight) / 2  ; Center
    If startY < 5 : startY = 5 : EndIf  ; Minimum margin
  EndIf
  
  ; Draw each line
  Protected i.i
  For i = 1 To lineCount
    Protected line.s = StringField(wrappedText, i, #CRLF$)
    Protected lineX.i = GetTextPositionX(line, FontSize, FontName, screenWidth)
    
    WeAct_DrawTextSystemFont(lineX, startY, line, Color, FontSize, FontName)
    startY + lineHeight  ; Next line position
  Next
  
  ; Update display
  WeAct_UpdateDisplay()
  
  ProcedureReturn #True
EndProcedure

; =============================================
; MAIN DISPLAY CONTROL FUNCTION
; =============================================
; Coordinates display operations based on parameters
; Returns: #True if successful, #False if failed
Procedure DisplayContent()
  ; Initialize display connection
  Protected initResult.i
  
  If clearScreen = #False
    ; Overlay mode - don't clear screen on init
    initResult = WeAct_InitNoClear(comPort)
  Else
    ; Normal mode - standard init
    initResult = WeAct_Init(comPort)
  EndIf
  
  If initResult
    If clearScreenOnly
      ; Clear screen only
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_UpdateDisplay()
      Delay(100)
    ElseIf imageFile <> ""
      ; Image display
      DisplayImageFromFile(imageFile, imageMode, imageWidth, imageHeight)
    ElseIf scrollMode
      ; Scrolling text
      DisplayTextWithScrolling(displayText, textColor, fontName, fontSize, scrollSpeed, scrollDirection)
    Else
      ; Static text
      DisplayStaticText(displayText, textColor, fontName, fontSize)
    EndIf
    
    ; Clean up
    WeAct_Cleanup()
    
    ProcedureReturn #True
    
  Else
    ; Initialization failed
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

; Check operating system (Windows required)
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  PrintN("Error: This program requires Windows")
  End 1
CompilerEndIf

; Parse command line and execute
If ParseCommandLine()
  If clearScreenOnly And displayText = "" And imageFile = ""
    ; Only clear screen
    ClearDisplayOnly()
  Else
    ; Display content
    DisplayContent()
  EndIf
  
  End 0  ; Success exit
Else
  End 1  ; Error exit
EndIf
; IDE Options = PureBasic 6.30 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 1298
; FirstLine = 1225
; Folding = ----
; EnableXP
; Executable = WeactCLI.exe
