; WeActCLI - Console Text and Image Display Utility for WeAct Display FS
; Main program file for displaying text and images on WeAct Display via serial port

XIncludeFile "WeActDisplay.pbi"

OpenConsole()

; =============================================
; GLOBAL VARIABLE DECLARATIONS
; =============================================

; Control flag for verbose output mode (shows detailed information)
Global verbose.i = #False

; COM port for WeAct Display connection (default: COM3)
; Stores the serial port name like "COM3"
Global comPort.s = "COM3"

; Text color constant in BRG565 format (default: white = #WEACT_WHITE = $FFFF)
Global textColor.i = #WEACT_WHITE

; Text content to be displayed on the screen
; Can come from command line, file, or stdin
Global displayText.s = ""

; Path to image file to display
Global imageFile.s = ""

; Maximum width for text wrapping in pixels (default: 150px)
; Used to wrap long text lines to fit display width
Global wrapWidth.i = 150

; Spacing between text lines in pixels (default: 2px)
; Adds vertical space between lines of wrapped text
Global lineSpacing.i = 2

; Font name for text rendering (default: Arial)
Global fontName.s = "Arial"

; Font size in points (default: 8pt)
; Size of the font for text rendering
Global fontSize.i = 8

; Scrolling speed in pixels per second (default: 30.0 px/s)
; Controls how fast text moves in scroll mode
Global scrollSpeed.f = 30.0

; Flag indicating whether scrolling mode is enabled
; #True = text scrolls, #False = static text
Global scrollMode.i = #False

; Scrolling direction (up/down), uses constants from WeActDisplay.pbi
; #SCROLL_UP = scroll upward, #SCROLL_DOWN = scroll downward
Global scrollDirection.i = #SCROLL_UP

; Flag for horizontal text centering
; #True = center text, #False = left-align text
Global centerText.i = #False

; Flag for screen clearing only mode (no text display)
; #True = only clear screen, #False = normal operation
Global clearScreenOnly.i = #False

; Path to text file for loading content
Global textFile.s = ""

; Maximum number of lines to load from text file
; Prevents loading huge files that won't fit on display
Global maxFileLines.i = 1000

; Image display mode: 0=fit to screen, 1=original size, 2=centered with size
Global imageMode.i = 0

; Custom image dimensions for mode 2 (centered with specific size)
; -1 means use original image dimensions
Global imageWidth.i = -1
Global imageHeight.i = -1

; Image quality setting for display
; 0=fast, 1=normal, 2=high, 3=bw fast, 4=bw high
Global imageQuality.i = 1

; =============================================
; UTILITY FUNCTIONS
; =============================================

; Loads text content from a specified file with UTF-8 encoding support
; FilePath: Full path to the text file
; MaxLines: Maximum number of lines to load (prevents memory issues)
; Returns: String containing file content or empty string on error
Procedure.s LoadTextFromFile(FilePath.s, MaxLines.i = 1000)
  Protected result.s = ""      ; Final text content to return
  Protected lineCount.i = 0    ; Counter for loaded lines
  Protected file.i            ; File handle
  
  ; Check if file exists and is not empty
  ; FileSize() returns file size in bytes, <=0 means file doesn't exist or is empty
  If FileSize(FilePath) <= 0
    PrintN("Error: File '" + FilePath + "' not found or empty")
    ProcedureReturn ""         ; Return empty string on error
  EndIf
  
  ; Open file with UTF-8 encoding for proper Unicode support
  file = ReadFile(#PB_Any, FilePath)
  If Not file                 ; Check if file opened successfully
    PrintN("Error: Cannot open file '" + FilePath + "'")
    ProcedureReturn ""         ; Return empty string on error
  EndIf
  
  ; Read file line by line until EOF or MaxLines reached
  While Not Eof(file) And lineCount < MaxLines
    Protected line.s = ReadString(file, #PB_UTF8)  ; Read line with UTF-8 encoding
    
    ; Concatenate lines with CRLF (carriage return + line feed) separation
    ; This preserves original line breaks in the text
    If result <> ""
      result + #CRLF$ + line    ; Add newline before next line
    Else
      result = line             ; First line, no newline needed
    EndIf
    lineCount + 1              ; Increment line counter
  Wend
  
  CloseFile(file)              ; Close file when done
  
  ProcedureReturn result       ; Return the loaded text
EndProcedure

; Display image from file using WeAct display functions
; ImagePath: Full path to image file
; Mode: Display mode (0=fit to screen, 1=original size, 2=centered with size)
; ImgWidth: Custom width for mode 2
; ImgHeight: Custom height for mode 2
; Returns: #True if successful, #False if failed
Procedure DisplayImageFromFile(ImagePath.s, Mode.i = 0, ImgWidth.i = -1, ImgHeight.i = -1)
  Protected result.i = #False  ; Operation result flag
  
  ; Load test image first to validate it can be loaded
  Protected testImage = LoadImage(#PB_Any, ImagePath)
  If testImage
    FreeImage(testImage)       ; Free test image after validation
  EndIf
  
  ; Use appropriate display function based on mode parameter
  Select Mode
    Case 0  ; Mode 0: Fit to screen (maintain aspect ratio, fill screen)
      ; WeAct_LoadImageFullScreen scales image to fill screen while keeping aspect ratio
      result = WeAct_LoadImageFullScreen(ImagePath)
      
    Case 1  ; Mode 1: Original size at position (0,0)
      ; WeAct_LoadImageToBuffer displays image at original size at top-left corner
      ; ImgWidth and ImgHeight are ignored in this mode (use original dimensions)
      result = WeAct_LoadImageToBuffer(0, 0, ImagePath, ImgWidth, ImgHeight)
      
    Case 2  ; Mode 2: Centered with specified size
      ; WeAct_LoadImageCentered displays image centered on screen with optional custom size
      result = WeAct_LoadImageCentered(ImagePath, ImgWidth, ImgHeight)
  EndSelect
  
  ; If image loaded successfully, update display and show for 3 seconds
  If result
    If WeAct_UpdateDisplay()
      Delay(3000)               ; Show image for 3 seconds
      ProcedureReturn #True
    EndIf
  Else
    PrintN("Error: Failed to load image - " + WeAct_GetLastError())
  EndIf
  
  ProcedureReturn #False       ; Return failure
EndProcedure

; Reads data from standard input (stdin) with proper encoding handling
; This allows piping text into the program: echo "text" | WeActCLI /p:3
; Returns: String containing stdin data or empty string if no data
Procedure.s ReadFromStdin()
  Protected result.s = ""      ; Result string
  
  ; Windows-specific stdin handling
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected consoleCP.i = GetConsoleCP_()      ; Get console codepage
    Protected isRedirected.i = #False           ; Flag for pipe/file redirection
    
    ; Check if stdin is redirected (pipe or file) or console input
    Protected hStdin = GetStdHandle_(#STD_INPUT_HANDLE)
    Protected fileType = GetFileType_(hStdin)
    
    If fileType <> #FILE_TYPE_CHAR
      isRedirected = #True     ; stdin is redirected (pipe or file)
    EndIf
    
    ; Determine encoding to use
    ; For redirected input (pipes/files), use UTF-8 by default
    ; For console input, use console's codepage
    Protected useCodepage.i = consoleCP
    If isRedirected
      useCodepage = #CP_UTF8   ; Default to UTF-8 for redirected input
    EndIf
    
    ; Allocate buffer for reading stdin data
    Protected bufferSize = 65536    ; 64KB buffer
    Protected *buffer = AllocateMemory(bufferSize)
    
    If *buffer
      Protected bytesRead.l         ; Bytes read in current read operation
      Protected totalBytesRead = 0  ; Total bytes read from stdin
      
      ; Read all available data from stdin
      While #True
        Protected bytesAvailable.l   ; Bytes available to read
        
        ; Check how many bytes are available to read
        If PeekNamedPipe_(hStdin, #Null, 0, #Null, @bytesAvailable, #Null)
          If bytesAvailable > 0
            ; Read available data
            If ReadFile_(hStdin, *buffer + totalBytesRead, bytesAvailable, @bytesRead, #Null)
              totalBytesRead + bytesRead  ; Add to total
              
              ; Stop if buffer is almost full
              If totalBytesRead >= bufferSize - 1024
                Break
              EndIf
            Else
              Break  ; Read failed, exit loop
            EndIf
          Else
            Break    ; No more data available, exit loop
          EndIf
        Else
          ; Failed to check available data, try direct read
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
        
        ; Clean up string: remove null characters and trailing line breaks
        result = ReplaceString(result, Chr(0), "")
        result = RTrim(result, #CR$ + #LF$)
      EndIf
      
      FreeMemory(*buffer)      ; Free the buffer
    EndIf
    
  CompilerElse
    ; Linux/Mac stdin handling (simpler, always UTF-8)
    Protected stdinFile.i = ReadFile(#PB_Any, "")  ; Open stdin as file
    If stdinFile
      Protected fileSize.i = Lof(stdinFile)        ; Get size of stdin data
      If fileSize > 0
        Protected *fileBuffer = AllocateMemory(fileSize)
        If *fileBuffer
          ReadData(stdinFile, *fileBuffer, fileSize)  ; Read all data
          result = PeekS(*fileBuffer, fileSize, #PB_UTF8)  ; Convert to UTF-8 string
          FreeMemory(*fileBuffer)
        EndIf
      EndIf
      CloseFile(stdinFile)
    EndIf
  CompilerEndIf
  
  ProcedureReturn result       ; Return the stdin data
EndProcedure

; Simple inline-if function for strings
; Condition: Boolean condition to check
; TrueValue: String to return if condition is true
; FalseValue: String to return if condition is false
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
; Used when /CLS parameter is specified without other content
; Returns: #True if successful, #False if failed
Procedure ClearDisplayOnly()
  ; Initialize display connection
  If WeAct_Init(comPort)
    ; Clear buffer to black and update display
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateDisplay()
    
    Delay(500)                   ; Wait half second to ensure display update
    WeAct_Cleanup()              ; Close display connection
    
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
; FontName: Name of font to check
; Returns: #True if font is likely available, #False otherwise
Procedure.i IsFontAvailable(FontName.s)
  ; List of common Windows fonts that are usually available
  Protected commonFonts.s = "Arial,Tahoma,Verdana,Courier New,Courier,Times New Roman," +
                            "Segoe UI,Calibri,Microsoft Sans Serif,Consolas," +
                            "Comic Sans MS,Impact,Lucida Console"
  
  Protected i.i
  For i = 1 To CountString(commonFonts, ",") + 1
    ; Case-insensitive comparison
    If LCase(StringField(commonFonts, i, ",")) = LCase(FontName)
      ProcedureReturn #True     ; Font found in common list
    EndIf
  Next
  
  ; Special case: "Courier" is often available even if not in list
  If LCase(FontName) = "courier"
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False        ; Font not found
EndProcedure

; Checks if a single word fits within specified maximum width using current font
; Word: Single word to check
; FontSize: Font size in points
; FontName: Name of font
; MaxWidth: Maximum allowed width in pixels
; Returns: #True if word fits, #False if too wide
Procedure.i CheckWordFits(Word.s, FontSize.i, FontName.s, MaxWidth.i)
  ; Get actual pixel width of the word with specified font
  Protected wordWidth.i = WeAct_GetTextWidth(Word, FontSize, FontName)
  ; Check if width is less than or equal to maximum allowed
  ProcedureReturn Bool(wordWidth <= MaxWidth)
EndProcedure

; Automatically reduces font size to ensure all words fit within maximum width
; Text: Full text containing multiple words
; *FontSize: Pointer to font size variable (will be modified if needed)
; FontName: Name of font
; MaxWidth: Maximum allowed width in pixels
; Returns: #True if text can fit (possibly with reduced font size), #False if impossible
Procedure.i AdjustFontSizeForWords(Text.s, *FontSize.Integer, FontName.s, MaxWidth.i)
  Protected originalSize.i = *FontSize\i   ; Store original font size
  Protected currentSize.i = originalSize   ; Current size being tested
  Protected minSize.i = 6                  ; Minimum font size to try
  
  ; Clean text: replace tabs with spaces and remove null characters
  Text = ReplaceString(Text, Chr(9), " ")   ; Tab to space
  Text = ReplaceString(Text, Chr(0), "")    ; Remove null chars
  
  ; Split text into individual words
  Protected wordCount.i = CountString(Text, " ") + 1
  Protected i.i
  
  ; Try progressively smaller font sizes until all words fit
  For currentSize = originalSize To minSize Step -1
    Protected allWordsFit.i = #True  ; Assume all words fit at this size
    
    ; Check each word at current font size
    For i = 1 To wordCount
      Protected word.s = StringField(Text, i, " ")
      ; Skip empty words (multiple spaces)
      If word <> ""
        If Not CheckWordFits(word, currentSize, FontName, MaxWidth)
          allWordsFit = #False  ; This word doesn't fit
          Break                 ; No need to check other words
        EndIf
      EndIf
    Next
    
    ; If all words fit at this font size, use it
    If allWordsFit
      *FontSize\i = currentSize  ; Update font size
      ProcedureReturn #True      ; Success
    EndIf
  Next
  
  ; No font size (down to 6pt) allows all words to fit
  ProcedureReturn #False
EndProcedure

; =============================================
; COMMAND-LINE PARSING FUNCTIONS
; =============================================

; Determines if a string represents a command-line parameter
; Parameters start with / or - followed by a letter
; Text: String to check
; Returns: #True if string is a parameter, #False otherwise
Procedure.i IsParameter(Text.s)
  If Left(Text, 1) = "/" Or Left(Text, 1) = "-"
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Parse image size string like "64x64" or "100x50"
; SizeString: String containing width and height separated by 'x'
; *Width: Pointer to width variable to store result
; *Height: Pointer to height variable to store result
; Returns: #True if parsing successful, #False if invalid format
Procedure ParseImageSize(SizeString.s, *Width.Integer, *Height.Integer)
  ; Find the 'x' separator
  Protected xPos.i = FindString(SizeString, "x")
  If xPos > 0
    ; Extract width (left part) and height (right part)
    *Width\i = Val(Left(SizeString, xPos - 1))   ; Convert left part to integer
    *Height\i = Val(Mid(SizeString, xPos + 1))   ; Convert right part to integer
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False  ; No 'x' found, invalid format
EndProcedure

; =============================================
; COMMAND LINE PARSER
; =============================================
; Main command-line parsing function
; Reads and processes all command-line parameters
; Sets global variables based on parameters
; Returns: #True if parsing successful, #False if error
Procedure ParseCommandLine()
  Protected paramCount = CountProgramParameters()  ; Get number of command-line arguments
  
  ; If no parameters and no stdin data, show help and exit
  If paramCount = 0
    Protected stdinTest.s = ReadFromStdin()  ; Check for stdin data
    If stdinTest = ""
      ShowHelp()            ; No input, show help
      ProcedureReturn #False
    Else
      ; We have stdin data, use it as display text
      displayText = stdinTest
    EndIf
  EndIf
  
  ; Store all parameters in an array for easier processing
  Dim params.s(paramCount - 1)
  Protected i.i
  For i = 0 To paramCount - 1
    params(i) = ProgramParameter(i)  ; Get each parameter
  Next
  
  ; Process parameters in order
  i = 0
  While i < paramCount
    Protected param.s = params(i)  ; Current parameter
    
    If IsParameter(param)  ; Check if this is a parameter (starts with / or -)
      Select LCase(param)  ; Convert to lowercase for case-insensitive comparison
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
          ; COM port parameter: /p:X or -p:X
          If Left(param, 3) = "/p:" Or Left(param, 3) = "-p:"
            comPort = "COM" + Mid(param, 4)  ; Extract port number
            
          ; Color parameter: /c:YYY or -c:YYY
          ElseIf Left(param, 3) = "/c:" Or Left(param, 3) = "-c:"
            Protected colorName.s = LCase(Mid(param, 4))  ; Extract color name
            
            ; Map color names to BRG565 color constants
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
            
          ; Font parameter: /f:"Font Name":Size or -f:"Font Name":Size
          ElseIf Left(param, 3) = "/f:" Or Left(param, 3) = "-f:"
            Protected fontParam.s = Mid(param, 4)  ; Extract font parameter
            
            ; Handle quoted font names (e.g., "Times New Roman":12)
            If Left(fontParam, 1) = Chr(34)  ; Check for opening quote
              Protected quoteEndPos.i = FindString(fontParam, Chr(34), 2)  ; Find closing quote
              If quoteEndPos > 0
                fontName = Mid(fontParam, 2, quoteEndPos - 2)  ; Extract font name inside quotes
                
                ; Find colon after closing quote for font size
                Protected sizeStartPos.i = FindString(fontParam, ":", quoteEndPos)
                If sizeStartPos > 0
                  fontSize = Val(Mid(fontParam, sizeStartPos + 1))  ; Extract and convert font size
                Else
                  fontSize = 8  ; Default font size
                EndIf
              Else
                PrintN("Error: Missing closing quote in font name")
                ProcedureReturn #False
              EndIf
            Else
              ; Unquoted font name (e.g., Arial:10)
              Protected colonPos.i = FindString(fontParam, ":")  ; Find colon separator
              If colonPos > 0
                fontName = Left(fontParam, colonPos - 1)      ; Font name before colon
                fontSize = Val(Mid(fontParam, colonPos + 1))  ; Font size after colon
              Else
                fontName = fontParam  ; No size specified, just font name
                fontSize = 8          ; Default size
              EndIf
            EndIf
            
            ; Validate font size range (6-32 points)
            If fontSize < 6 Or fontSize > 32
              If fontSize < 6 : fontSize = 6 : EndIf    ; Clamp to minimum
              If fontSize > 32 : fontSize = 32 : EndIf  ; Clamp to maximum
            EndIf
            
            ; Check if font is available, fall back to Arial if not
            If Not IsFontAvailable(fontName)
              fontName = "Arial"
            EndIf
            
          ; Scroll parameter: /s:Speed[:u|d] or -s:Speed[:u|d]
          ElseIf Left(param, 3) = "/s:" Or Left(param, 3) = "-s:"
            scrollMode = #True
            Protected scrollParam.s = Mid(param, 4)  ; Extract scroll parameter
            
            Protected dirPos.i = FindString(scrollParam, ":")  ; Find direction separator
            If dirPos > 0
              ; Has direction specified (e.g., 25.5:u)
              scrollSpeed = ValF(Left(scrollParam, dirPos - 1))  ; Extract speed
              Protected direction.s = LCase(Mid(scrollParam, dirPos + 1))  ; Extract direction
              
              Select direction
                Case "u", "up":
                  scrollDirection = #SCROLL_UP
                Case "d", "down":
                  scrollDirection = #SCROLL_DOWN
                Default:
                  scrollDirection = #SCROLL_UP  ; Default to up
              EndSelect
            Else
              ; No direction specified (e.g., 25.5)
              scrollSpeed = ValF(scrollParam)   ; Just speed
              scrollDirection = #SCROLL_UP      ; Default direction
            EndIf
            
            ; Validate scroll speed range (0.1-100 pixels/second)
            If scrollSpeed <= 0 Or scrollSpeed > 100
              If scrollSpeed <= 0 : scrollSpeed = 10.0 : EndIf
              If scrollSpeed > 100 : scrollSpeed = 100.0 : EndIf
            EndIf
            
          ; File parameter: /file:"path" or -file:"path"
          ElseIf Left(param, 6) = "/file:" Or Left(param, 6) = "-file:"
            textFile = Mid(param, 7)  ; Extract file path
            
            ; Remove quotes if present
            If Left(textFile, 1) = Chr(34)
              textFile = Mid(textFile, 2)
            EndIf
            If Right(textFile, 1) = Chr(34)
              textFile = Left(textFile, Len(textFile) - 1)
            EndIf
            
          ; Image parameter: /image:"path"[:mode[:WxH]] or -image:"path"[:mode[:WxH]]
          ElseIf Left(param, 7) = "/image:" Or Left(param, 7) = "-image:"
            Protected imageParam.s = Mid(param, 8)  ; Extract image parameter
            
            ; Extract image path (may be in quotes)
            Protected imagePath.s
            If Left(imageParam, 1) = Chr(34)  ; Check for opening quote
              Protected imageQuoteEndPos.i = FindString(imageParam, Chr(34), 2)  ; Find closing quote
              If imageQuoteEndPos > 0
                imagePath = Mid(imageParam, 2, imageQuoteEndPos - 2)  ; Extract path inside quotes
                imageParam = Mid(imageParam, imageQuoteEndPos + 1)    ; Remaining parameter
              Else
                PrintN("Error: Missing closing quote in image path")
                ProcedureReturn #False
              EndIf
            Else
              ; Unquoted path: find first colon for mode separator
              Protected firstColon.i = FindString(imageParam, ":")
              If firstColon > 0
                imagePath = Left(imageParam, firstColon - 1)  ; Path before colon
                imageParam = Mid(imageParam, firstColon + 1)  ; Mode/size after colon
              Else
                imagePath = imageParam  ; No mode/size, just path
                imageParam = ""
              EndIf
            EndIf
            
            imageFile = imagePath  ; Store image file path
            
            ; Parse mode if present (after first colon)
            If imageParam <> ""
              Protected modeColon.i = FindString(imageParam, ":")  ; Find size separator
              If modeColon > 0
                imageMode = Val(Left(imageParam, modeColon - 1))  ; Extract mode number
                imageParam = Mid(imageParam, modeColon + 1)       ; Size parameter
                
                ; Parse size if present (e.g., 64x64)
                If imageParam <> ""
                  ParseImageSize(imageParam, @imageWidth, @imageHeight)
                EndIf
              Else
                imageMode = Val(imageParam)  ; Just mode, no size
              EndIf
            EndIf
            
          ; Quality parameter: /quality:value or -quality:value
          ElseIf Left(param, 8) = "/quality:" Or Left(param, 8) = "-quality:"
            Protected qualityParam.s = Mid(param, 9)  ; Extract quality parameter
            
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
            
          Else
            PrintN("Error: Unknown parameter '" + param + "'")
            ShowHelp()
            ProcedureReturn #False
          EndIf
      EndSelect
      
    Else
      ; This is not a parameter, it's text content to display
      displayText = param
      
      ; Handle quoted text (e.g., "Hello World")
      If Left(displayText, 1) = Chr(34)
        Protected quotePos.i = FindString(displayText, Chr(34), 2)  ; Find closing quote
        If quotePos > 0
          displayText = Mid(displayText, 2, quotePos - 2)  ; Extract text inside quotes
          
          ; Skip any remaining parameters that are part of this quoted text
          i + 1
          While i < paramCount And params(i) <> Chr(34)
            i + 1
          Wend
        EndIf
      Else
        ; Unquoted text: concatenate with following parameters until next parameter
        i + 1
        While i < paramCount
          displayText + " " + params(i)  ; Add space and next parameter
          i + 1
        Wend
        Break  ; Exit loop, processed all parameters
      EndIf
    EndIf
    
    i + 1  ; Move to next parameter
  Wend
  
  ; =============================================
  ; INPUT SOURCE VALIDATION
  ; =============================================
  
  ; 1. COM port is always required
  If comPort = "COM"  ; Means only "COM" without number was specified
    PrintN("Error: COM port not specified")
    PrintN("Use /p:X to specify COM port (e.g., /p:3 for COM3)")
    ProcedureReturn #False
  EndIf
  
  ; 2. Check for multiple content sources (image, file, text)
  Protected contentSources.i = 0
  If textFile <> "" : contentSources + 1 : EndIf
  If imageFile <> "" : contentSources + 1 : EndIf
  If displayText <> "" : contentSources + 1 : EndIf
  
  ; 3. Process content sources in priority order
  If imageFile <> ""
    ; Image has highest priority
    ; Clear other content sources when image is specified
    displayText = ""
    textFile = ""
    
  ElseIf textFile <> ""
    ; File parameter has second priority
    ; Load text from file
    displayText = LoadTextFromFile(textFile, maxFileLines)
    If displayText = ""  ; Failed to load file
      ProcedureReturn #False
    EndIf
    
  ElseIf displayText = "" And Not clearScreenOnly
    ; No text specified, check stdin
    Protected stdinText.s = ReadFromStdin()
    
    If stdinText <> ""
      ; Found data in stdin
      displayText = stdinText
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
  
  ProcedureReturn #True  ; Command line parsing successful
EndProcedure

; =============================================
; TEXT PROCESSING FUNCTIONS
; =============================================

; Wraps text to multiple lines based on maximum pixel width
; Text: Text string to wrap
; FontSize: Font size in points
; FontName: Name of font
; MaxWidth: Maximum width in pixels for each line
; *LineCount: Optional pointer to receive number of lines
; Returns: Text with CRLF line breaks at wrap points
Procedure.s WrapTextToLines(Text.s, FontSize.i, FontName.s, MaxWidth.i, *LineCount.Integer = 0)
  Protected lines.s = ""           ; Result text with line breaks
  Protected currentLine.s = ""     ; Current line being built
  Protected word.s = ""            ; Current word being built
  Protected lineCount.i = 0        ; Number of lines created
  Protected i.i
  
  ; Clean text: replace tabs with spaces, remove null characters
  Text = ReplaceString(Text, Chr(9), " ")   ; Tab to space
  Text = ReplaceString(Text, Chr(0), "")    ; Remove null chars
  
  ; Process text character by character
  For i = 1 To Len(Text)
    Protected char.s = Mid(Text, i, 1)  ; Get current character
    
    ; Check for word boundaries: space or line break characters
    If char = " " Or char = Chr(10) Or char = Chr(13)
      If word <> ""  ; We have a complete word
        If currentLine = ""
          ; First word on line
          currentLine = word
        Else
          ; Test if adding this word exceeds max width
          Protected testLine.s = currentLine + " " + word
          Protected testWidth.i = WeAct_GetTextWidth(testLine, FontSize, FontName)
          
          If testWidth <= MaxWidth
            ; Word fits, add to current line
            currentLine = testLine
          Else
            ; Word doesn't fit, start new line
            If lines <> ""
              lines + #CRLF$  ; Add line break
            EndIf
            lines + currentLine  ; Add completed line
            lineCount + 1        ; Increment line count
            currentLine = word   ; Start new line with current word
          EndIf
        EndIf
        word = ""  ; Reset word for next word
      EndIf
      
      ; Handle explicit line breaks (CR or LF)
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
      word + char  ; Add character to current word
    EndIf
  Next
  
  ; Process final word (text ended without space)
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
  
  ; Add final line if not empty
  If currentLine <> ""
    If lines <> ""
      lines + #CRLF$
    EndIf
    lines + currentLine
    lineCount + 1
  EndIf
  
  ; Return line count if pointer provided
  If *LineCount
    *LineCount\i = lineCount
  EndIf
  
  ProcedureReturn lines
EndProcedure

; Calculates X position for text based on centering setting
; Text: Text string to position
; FontSize: Font size in points
; FontName: Name of font
; ScreenWidth: Width of display in pixels
; Returns: X coordinate for text (centered or left-aligned)
Procedure.i GetTextPositionX(Text.s, FontSize.i, FontName.s, ScreenWidth.i)
  Protected textWidth.i = WeAct_GetTextWidth(Text, FontSize, FontName)
  
  If centerText
    ; Center text horizontally
    Protected centeredX.i = (ScreenWidth - textWidth) / 2
    If centeredX < 0 : centeredX = 0 : EndIf  ; Clamp to 0 if negative
    
    ProcedureReturn centeredX
  Else
    ; Left-align with 5 pixel margin
    ProcedureReturn 5
  EndIf
EndProcedure

; =============================================
; DISPLAY RENDERING FUNCTIONS
; =============================================

; Displays text with smooth vertical scrolling animation
; Text: Text string to scroll
; Color: Text color in BRG565 format
; FontName: Name of font
; FontSize: Font size in points
; Speed: Scroll speed in pixels per second
; Direction: Scroll direction (#SCROLL_UP or #SCROLL_DOWN)
; Returns: #True if successful, #False if failed
Procedure DisplayTextWithScrolling(Text.s, Color.i, FontName.s, FontSize.i, Speed.f, Direction.i)
  Protected screenWidth.i = WeAct_GetDisplayWidth()   ; Get display width
  Protected screenHeight.i = WeAct_GetDisplayHeight() ; Get display height
  
  ; Calculate maximum width for text wrapping
  Protected maxWidth.i
  If centerText
    maxWidth = screenWidth - 20  ; Center mode: use almost full width
  Else
    maxWidth = wrapWidth         ; Left-align: use configured wrap width
  EndIf
  
  ; Adjust font size if needed to fit words within maxWidth
  Protected adjustedFontSize.i = FontSize
  If Not AdjustFontSizeForWords(Text, @adjustedFontSize, FontName, maxWidth)
    PrintN("Error: Could not fit text with current font settings")
    ProcedureReturn #False
  EndIf
  
  If adjustedFontSize <> FontSize
    FontSize = adjustedFontSize  ; Use adjusted font size
  EndIf
  
  ; Wrap text into multiple lines
  Protected lineCount.i
  Protected wrappedText.s = WrapTextToLines(Text, FontSize, FontName, maxWidth, @lineCount)
  
  If wrappedText = ""
    PrintN("Error: Could not wrap text")
    ProcedureReturn #False
  EndIf
  
  ; Calculate text dimensions
  Protected lineHeight.i = FontSize + lineSpacing  ; Height of each line
  Protected totalTextHeight.i = lineCount * lineHeight  ; Total height of all lines
  
  ; Store each line's text and X position
  Dim linePositionsX.i(lineCount)  ; X position for each line
  Dim lineTexts.s(lineCount)       ; Text for each line
  Protected j.i
  For j = 1 To lineCount
    Protected lineText.s = StringField(wrappedText, j, #CRLF$)  ; Extract line
    lineTexts(j - 1) = lineText
    linePositionsX(j - 1) = GetTextPositionX(lineText, FontSize, FontName, screenWidth)
  Next
  
  ; Calculate animation parameters
  Protected frameDelay.i = 33  ; Delay between frames in milliseconds (~30 FPS)
  ; Pixels to move per frame: speed * (frameDelay/1000)
  Protected pixelsPerFrame.f = Speed * (frameDelay / 1000.0)
  
  ; Set initial scroll position based on direction
  Protected currentY.f  ; Current Y position (floating for smooth movement)
  Protected startY.f    ; Starting Y position
  Protected endY.f      ; Ending Y position
  
  If Direction = #SCROLL_UP
    ; Start at bottom, scroll up until text disappears at top
    currentY = screenHeight     ; Start below screen
    startY = screenHeight       ; Starting position
    endY = -totalTextHeight     ; End when text completely above screen
  Else
    ; Start at top, scroll down until text disappears at bottom
    currentY = -totalTextHeight ; Start above screen
    startY = -totalTextHeight   ; Starting position
    endY = screenHeight         ; End when text completely below screen
  EndIf
  
  ; Accumulator for fractional pixels (for smooth scrolling)
  Protected accumulatedPixels.f = 0
  Protected keepScrolling.i = #True  ; Continue scrolling flag
  
  ; Main scroll animation loop
  While keepScrolling
    ; Add pixels for this frame
    accumulatedPixels + pixelsPerFrame
    
    ; Move integer pixels when accumulated enough
    If accumulatedPixels >= 1.0
      Protected pixelsToMove.i = Int(accumulatedPixels)  ; Whole pixels to move
      If Direction = #SCROLL_UP
        currentY - pixelsToMove  ; Move up
      Else
        currentY + pixelsToMove  ; Move down
      EndIf
      accumulatedPixels - pixelsToMove  ; Remove moved pixels from accumulator
    EndIf
    
    ; Clear screen for new frame
    WeAct_ClearBuffer(#WEACT_BLACK)
    
    ; Draw each line at current scroll position
    Protected anyVisible.i = #False  ; Flag if any line is visible
    For j = 0 To lineCount - 1
      Protected lineY.i = j * lineHeight  ; Line's position within text block
      Protected screenY.i = lineY + Int(currentY)  ; Line's position on screen
      
      ; Only draw if line is (partially) visible on screen
      If screenY >= -lineHeight And screenY < screenHeight
        anyVisible = #True
        WeAct_DrawTextSystemFont(linePositionsX(j), screenY, lineTexts(j), Color, FontSize, FontName)
      EndIf
    Next
    
    ; Update display with new frame
    WeAct_UpdateDisplay()
    
    ; Check if scrolling should stop (text completely scrolled off)
    If Direction = #SCROLL_UP
      If currentY <= endY
        keepScrolling = #False  ; Text completely above screen
      EndIf
    Else
      If currentY >= endY
        keepScrolling = #False  ; Text completely below screen
      EndIf
    EndIf
    
    ; Safety check: stop if no lines visible for too long
    Static noVisibleCounter.i = 0
    If Not anyVisible
      noVisibleCounter + 1
      If noVisibleCounter > 15  ; About 0.5 second with no visible lines
        keepScrolling = #False
      EndIf
    Else
      noVisibleCounter = 0  ; Reset counter when lines are visible
    EndIf
    
    ; Wait for next frame
    Delay(frameDelay)
  Wend
  
  ; Clear screen after scrolling completes
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_UpdateDisplay()
  
  noVisibleCounter = 0  ; Reset static counter for next use
  
  Delay(300)  ; Brief pause after scrolling
  
  ProcedureReturn #True
EndProcedure

; Displays static (non-scrolling) text on the screen
; Text: Text string to display
; Color: Text color in BRG565 format
; FontName: Name of font
; FontSize: Font size in points
; Returns: #True if successful, #False if failed
Procedure DisplayStaticText(Text.s, Color.i, FontName.s, FontSize.i)
  Protected screenWidth.i = WeAct_GetDisplayWidth()   ; Get display width
  Protected screenHeight.i = WeAct_GetDisplayHeight() ; Get display height
  
  ; Calculate maximum width for text wrapping
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
    FontSize = adjustedFontSize  ; Use adjusted font size
  EndIf
  
  ; Wrap text into lines
  Protected lineCount.i
  Protected wrappedText.s = WrapTextToLines(Text, FontSize, FontName, maxWidth, @lineCount)
  
  If wrappedText = ""
    PrintN("Error: Could not wrap text")
    ProcedureReturn #False
  EndIf
  
  ; Clear screen
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Calculate vertical positioning (center text vertically)
  Protected lineHeight.i = FontSize + lineSpacing  ; Height of each line
  Protected totalHeight.i = lineCount * lineHeight  ; Total height of all lines
  Protected startY.i = (screenHeight - totalHeight) / 2  ; Center vertically
  If startY < 5 : startY = 5 : EndIf  ; Minimum 5 pixel margin
  
  ; Draw each line
  Protected i.i
  For i = 1 To lineCount
    Protected line.s = StringField(wrappedText, i, #CRLF$)  ; Extract line
    Protected lineX.i = GetTextPositionX(line, FontSize, FontName, screenWidth)  ; Get X position
    
    WeAct_DrawTextSystemFont(lineX, startY, line, Color, FontSize, FontName)  ; Draw line
    startY + lineHeight  ; Move to next line position
  Next
  
  ; Update display and show text for 2 seconds
  WeAct_UpdateDisplay()
  Delay(2000)
  
  ProcedureReturn #True
EndProcedure

; =============================================
; MAIN DISPLAY CONTROL FUNCTION
; =============================================
; Main function that coordinates display operations
; Calls appropriate display functions based on parameters
; Returns: #True if successful, #False if failed
Procedure DisplayContent()
  ; Initialize display connection
  If WeAct_Init(comPort)
    
    If clearScreenOnly
      ; Clear screen only mode
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_UpdateDisplay()
      Delay(500)
    ElseIf imageFile <> ""
      ; Image display mode
      DisplayImageFromFile(imageFile, imageMode, imageWidth, imageHeight)
    ElseIf scrollMode
      ; Scrolling text mode
      DisplayTextWithScrolling(displayText, textColor, fontName, fontSize, scrollSpeed, scrollDirection)
    Else
      ; Static text mode
      DisplayStaticText(displayText, textColor, fontName, fontSize)
    EndIf
    
    ; Clean up display connection
    WeAct_Cleanup()
    
    ProcedureReturn #True
    
  Else
    ; Failed to initialize display
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

; Parse command line and execute appropriate action
If ParseCommandLine()
  If clearScreenOnly And displayText = "" And imageFile = ""
    ; Only clear screen, no content to display
    ClearDisplayOnly()
  Else
    ; Display content (text or image)
    DisplayContent()
  EndIf
  
  End 0  ; Exit with success code
Else
  End 1  ; Exit with error code
EndIf

; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; Folding = ----
; EnableXP
; Executable = WeactCLI.exe
