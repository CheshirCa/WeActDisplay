XIncludeFile "WeActDisplay.pbi"

; { Window and Gadget IDs - unique identifiers for UI elements }
Enumeration
  #WINDOW_MAIN          ; Main application window
  #MENU_MAIN            ; Main menu bar
  #TIMER_TEST           ; Timer for running tests without freezing UI
  
  ; UI Controls
  #EDITOR_LOG           ; Text log display area
  #BTN_INIT             ; Button to initialize display connection
  #BTN_RUN_ALL          ; Button to run all tests sequentially
  #BTN_STOP             ; Button to stop running tests
  #BTN_CLEAR_DISPLAY    ; Button to clear display screen
  #COMBO_COM_PORT       ; Dropdown list for selecting COM port
  #BTN_REFRESH_PORTS    ; Button to refresh available COM ports
  #PROGRESS_TEST        ; Progress bar showing test completion
  #CONTAINER_STATUS     ; Container for status bar at bottom
  #TEXT_STATUS          ; Text label showing current status
  #PANEL_TESTS          ; Panel containing test buttons
  
  ; Individual Test Buttons - each triggers a specific test
  #BTN_TEST_BASIC
  #BTN_TEST_TEXT
  #BTN_TEST_GRAPHICS
  #BTN_TEST_SCROLL
  #BTN_TEST_IMAGE
  #BTN_TEST_ORIENTATION
  #BTN_TEST_BRIGHTNESS
  #BTN_TEST_NEW
  
  ; Menu Items - application menu commands
  #MENU_FILE_EXIT
  #MENU_LANG_EN
  #MENU_LANG_RU
  #MENU_HELP_ABOUT
  #MENU_HELP_GITHUB
EndEnumeration

; { Language System Structure - stores all UI text for different languages }
Structure LanguageStrings
  ; Application title and menu texts
  AppTitle.s
  MenuFile.s
  MenuExit.s
  MenuLanguage.s
  MenuHelp.s
  MenuAbout.s
  MenuGitHub.s
  
  ; Connection group texts
  GroupConnection.s
  LabelComPort.s
  BtnRefreshPorts.s
  BtnInitialize.s
  
  ; Test control group texts
  GroupTests.s
  BtnRunAll.s
  BtnStop.s
  BtnClearDisplay.s
  TabIndividual.s
  
  ; Log group text
  GroupLog.s
  
  ; Status bar messages
  StatusReady.s
  StatusRunning.s
  StatusCompleted.s
  StatusError.s
  StatusConnected.s
  StatusDisconnected.s
  
  ; Test names for log
  TestInit.s
  TestBasic.s
  TestText.s
  TestGraphics.s
  TestScroll.s
  TestImage.s
  TestOrientation.s
  TestBrightness.s
  TestNewFeatures.s
  TestSystemInfo.s
  
  ; Error and info messages
  MsgNoDisplay.s
  MsgTestStopped.s
  MsgAllCompleted.s
  
  ; About dialog texts
  AboutTitle.s
  AboutText.s
EndStructure

; { Global Variables - application state }
Global Lang.LanguageStrings        ; Current language strings
Global CurrentLanguage.s = "EN"    ; Active language code
Global TestRunning.i = #False      ; Flag: tests are currently running
Global TestResults.s = ""          ; Accumulated test results text
Global ComPort.s = "COM3"          ; Default COM port
Global CurrentTestIndex.i = 0      ; Index of current test being executed
Global TestCount.i = 10            ; Total number of tests available
Global TestQueue.i = 0             ; Test execution mode: 0=all tests, 1-9=specific test


; { Прототипы процедур для правильного порядка компиляции }
Declare UpdateStatusBar(Message.s)
Declare UpdateUILanguage()
Declare SetLanguage(Language.s)
Declare LogMessage(Message.s, Level.s = "INFO")

; =============================================
; { Language Initialization Procedures }
; =============================================

Procedure InitLanguageEN()
  ; English language initialization
  Lang\AppTitle = "WeAct Display Test Suite Professional v4.0"
  Lang\MenuFile = "File"
  Lang\MenuExit = "Exit"
  Lang\MenuLanguage = "Language"
  Lang\MenuHelp = "Help"
  Lang\MenuAbout = "About"
  Lang\MenuGitHub = "Open GitHub Project"
  
  Lang\GroupConnection = "Connection Settings"
  Lang\LabelComPort = "COM Port:"
  Lang\BtnRefreshPorts = "Refresh"
  Lang\BtnInitialize = "Initialize Display"
  
  Lang\GroupTests = "Test Control"
  Lang\BtnRunAll = "Run All Tests"
  Lang\BtnStop = "Stop Tests"
  Lang\BtnClearDisplay = "Clear Display"
  Lang\TabIndividual = "Individual Tests"
  
  Lang\GroupLog = "Test Log"
  
  Lang\StatusReady = "Ready"
  Lang\StatusRunning = "Running tests..."
  Lang\StatusCompleted = "Tests completed"
  Lang\StatusError = "Error - Display not connected"
  Lang\StatusConnected = "Connected"
  Lang\StatusDisconnected = "Disconnected"
  
  Lang\TestInit = "Initialization"
  Lang\TestBasic = "Basic Functions"
  Lang\TestText = "Text Rendering"
  Lang\TestGraphics = "Graphics"
  Lang\TestScroll = "Smooth Scrolling"
  Lang\TestImage = "Image Loading"
  Lang\TestOrientation = "Orientation"
  Lang\TestBrightness = "Brightness"
  Lang\TestNewFeatures = "New Features"
  Lang\TestSystemInfo = "System Info"
  
  Lang\MsgNoDisplay = "ERROR: Display not connected! Cannot run tests."
  Lang\MsgTestStopped = "Tests stopped by user"
  Lang\MsgAllCompleted = "All tests completed successfully!"
  
  Lang\AboutTitle = "About WeAct Display Test Suite"
  Lang\AboutText = "WeAct Display FS Library v4.0" + #CRLF$ + #CRLF$ +
                   "Professional test suite for WeAct 0.96" + Chr(34) + " USB display" + #CRLF$ + #CRLF$ +
                   "Features:" + #CRLF$ +
                   "• Fixed smooth scrolling" + #CRLF$ +
                   "• ROTATE mode support" + #CRLF$ +
                   "• Progress bars and graphs" + #CRLF$ +
                   "• Full Cyrillic support" + #CRLF$ + #CRLF$ +
                   "GitHub: https://github.com/CheshirCa/WeActDisplay"
EndProcedure

Procedure InitLanguageRU()
  ; Russian language initialization
  Lang\AppTitle = "WeAct Display - Профессиональное тестирование v4.0"
  Lang\MenuFile = "Файл"
  Lang\MenuExit = "Выход"
  Lang\MenuLanguage = "Язык"
  Lang\MenuHelp = "Справка"
  Lang\MenuAbout = "О программе"
  Lang\MenuGitHub = "Открыть GitHub"
  
  Lang\GroupConnection = "Настройки подключения"
  Lang\LabelComPort = "COM порт:"
  Lang\BtnRefreshPorts = "Обновить"
  Lang\BtnInitialize = "Инициализация"
  
  Lang\GroupTests = "Управление тестами"
  Lang\BtnRunAll = "Запустить все"
  Lang\BtnStop = "Остановить"
  Lang\BtnClearDisplay = "Очистить дисплей"
  Lang\TabIndividual = "Отдельные тесты"
  
  Lang\GroupLog = "Журнал тестирования"
  
  Lang\StatusReady = "Готов"
  Lang\StatusRunning = "Выполняются тесты..."
  Lang\StatusCompleted = "Тесты завершены"
  Lang\StatusError = "Ошибка - Дисплей не подключен"
  Lang\StatusConnected = "Подключен"
  Lang\StatusDisconnected = "Отключен"
  
  Lang\TestInit = "Инициализация"
  Lang\TestBasic = "Базовые функции"
  Lang\TestText = "Вывод текста"
  Lang\TestGraphics = "Графика"
  Lang\TestScroll = "Плавный скроллинг"
  Lang\TestImage = "Загрузка изображений"
  Lang\TestOrientation = "Ориентация"
  Lang\TestBrightness = "Яркость"
  Lang\TestNewFeatures = "Новые функции"
  Lang\TestSystemInfo = "Системная информация"
  
  Lang\MsgNoDisplay = "ОШИБКА: Дисплей не подключен! Тесты невозможны."
  Lang\MsgTestStopped = "Тесты остановлены пользователем"
  Lang\MsgAllCompleted = "Все тесты успешно завершены!"
  
  Lang\AboutTitle = "О программе"
  Lang\AboutText = "Библиотека WeAct Display FS v4.0" + #CRLF$ + #CRLF$ +
                   "Профессиональное тестирование USB дисплея 0.96" + Chr(34)  + #CRLF$ + #CRLF$ +
                   "Возможности:" + #CRLF$ +
                   "• Исправлен плавный скроллинг" + #CRLF$ +
                   "• Поддержка режима ROTATE" + #CRLF$ +
                   "• Прогресс-бары и графики" + #CRLF$ +
                   "• Полная поддержка кириллицы" + #CRLF$ + #CRLF$ +
                   "GitHub: https://github.com/CheshirCa/WeActDisplay"
EndProcedure

Procedure UpdateUILanguage()
  ; Update all UI texts with current language strings
  
  ; Update window title
  SetWindowTitle(#WINDOW_MAIN, Lang\AppTitle)
  
  ; Update menu items (меню обновляется автоматически через SetLanguage)
  
  ; Update connection group
  If IsGadget(#COMBO_COM_PORT)
    ; Frame texts need recreation or we need to handle them differently
    ; For frames, we need to store their positions and recreate
  EndIf
  
  ; Update button texts
  SetGadgetText(#BTN_REFRESH_PORTS, Lang\BtnRefreshPorts)
  SetGadgetText(#BTN_INIT, Lang\BtnInitialize)
  SetGadgetText(#BTN_RUN_ALL, Lang\BtnRunAll)
  SetGadgetText(#BTN_STOP, Lang\BtnStop)
  SetGadgetText(#BTN_CLEAR_DISPLAY, Lang\BtnClearDisplay)
  
  ; Update test button texts (optional - they have fixed numbers)
  ; SetGadgetText(#BTN_TEST_BASIC, "1. " + Lang\TestBasic)
  ; SetGadgetText(#BTN_TEST_TEXT, "2. " + Lang\TestText)
  ; ... and so on for other test buttons
  
  ; Update status bar
  UpdateStatusBar(Lang\StatusReady)
  
  ; Log language change
  LogMessage("Language changed to " + CurrentLanguage, "INFO")
EndProcedure

Procedure SetLanguage(Language.s)
  ; Switch application language
  ; Language: "EN" or "RU" language code
  CurrentLanguage = Language
  If Language = "RU"
    InitLanguageRU()
  Else
    InitLanguageEN()
  EndIf
  If IsWindow(#WINDOW_MAIN)
    SetWindowTitle(#WINDOW_MAIN, Lang\AppTitle)
  EndIf
  UpdateUILanguage()
EndProcedure



; =============================================
; { COM Port Detection Procedures }
; =============================================

Procedure.s GetAvailableComPorts()
  ; Scan for available COM ports from COM1 to COM30
  Protected portList.s = ""  ; String to accumulate found ports
  Protected i
  
  For i = 1 To 30
    Protected portName.s = "COM" + Str(i)
    ; Try to open port to check if it exists and is available
    Protected testPort = OpenSerialPort(#PB_Any, portName, 9600, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 512, 512)
    If testPort
      CloseSerialPort(testPort)  ; Close test connection
      If portList <> ""
        portList + ","           ; Add comma separator between ports
      EndIf
      portList + portName        ; Add port name to list
    EndIf
  Next
  
  ProcedureReturn portList  ; Return comma-separated list of available ports
EndProcedure

Procedure RefreshComPorts()
  ; Refresh the COM port dropdown list with currently available ports
  If IsGadget(#COMBO_COM_PORT)
    ClearGadgetItems(#COMBO_COM_PORT)  ; Clear existing items
    
    Protected ports.s = GetAvailableComPorts()
    If ports = ""
      ; No ports found - show message and disable init button
      AddGadgetItem(#COMBO_COM_PORT, -1, "No ports found")
      DisableGadget(#BTN_INIT, #True)
    Else
      ; Found ports - add each to dropdown
      Protected count = CountString(ports, ",") + 1
      Protected i
      For i = 1 To count
        AddGadgetItem(#COMBO_COM_PORT, -1, StringField(ports, i, ","))
      Next
      SetGadgetState(#COMBO_COM_PORT, 0)  ; Select first port
      DisableGadget(#BTN_INIT, #False)    ; Enable init button
    EndIf
  EndIf
EndProcedure

; =============================================
; { Logging and Status Functions }
; =============================================

Procedure LogMessage(Message.s, Level.s = "INFO")
  ; Add message to log with timestamp and visual prefix
  ; Message: Text to log
  ; Level: Message type ("ERROR", "SUCCESS", "INFO", "TEST", "WARNING")
  Protected Timestamp.s = FormatDate("%hh:%ii:%ss", Date())  ; Current time HH:MM:SS
  Protected Prefix.s
  
  ; Select appropriate emoji prefix based on message level
  Select Level
    Case "ERROR"
      Prefix = "❌ "
    Case "SUCCESS"
      Prefix = "✅ "
    Case "INFO"
      Prefix = "ℹ️  "
    Case "TEST"
      Prefix = "🔧 "
    Case "WARNING"
      Prefix = "⚠️  "
    Default
      Prefix = "   "
  EndSelect
  
  Protected LogLine.s = "[" + Timestamp + "] " + Prefix + Message
  
  ; Add to log display
  If IsGadget(#EDITOR_LOG)
    AddGadgetItem(#EDITOR_LOG, -1, LogLine)
    SetGadgetState(#EDITOR_LOG, CountGadgetItems(#EDITOR_LOG) - 1)
  EndIf
  
  TestResults + LogLine + #CRLF$  ; Append to results string
EndProcedure

Procedure ClearLog()
  ; Clear the log display and results buffer
  If IsGadget(#EDITOR_LOG)
    ClearGadgetItems(#EDITOR_LOG)
  EndIf
  TestResults = ""
EndProcedure

Procedure UpdateProgress(Current, Total)
  ; Update progress bar with current completion percentage
  ; Current: Current step number (starting from 0 or 1)
  ; Total: Total number of steps
  If IsGadget(#PROGRESS_TEST)
    ; Formula: (Current / Total) * 100 = percentage
    SetGadgetState(#PROGRESS_TEST, (Current * 100) / Total)
  EndIf
EndProcedure

Procedure UpdateStatusBar(Message.s)
  ; Update the status bar text at bottom of window
  If IsGadget(#TEXT_STATUS)
    SetGadgetText(#TEXT_STATUS, "  " + Message)
  EndIf
EndProcedure

; =============================================
; { Test Functions - Each tests a specific display feature }
; =============================================

Procedure TestInitialization()
  ; Test 0: Initialize display connection
  LogMessage("=== " + Lang\TestInit + " ===", "TEST")
  
  If WeAct_Init(ComPort)  ; Try to initialize display
    LogMessage("✓ Connected: " + ComPort, "SUCCESS")
    LogMessage("  Display: " + WeAct_GetInfo(), "INFO")
    LogMessage("  Size: " + Str(WeAct_GetDisplayWidth()) + "x" + Str(WeAct_GetDisplayHeight()), "INFO")
    UpdateStatusBar(Lang\StatusConnected + " - " + ComPort)
    ProcedureReturn #True
  Else
    LogMessage("✗ Failed: " + WeAct_GetLastError(), "ERROR")
    UpdateStatusBar(Lang\StatusError)
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestBasicFunctions()
  ; Test 1: Basic drawing functions (pixels, lines, shapes)
  LogMessage("=== " + Lang\TestBasic + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  ; Clear display buffer to black
  WeAct_ClearBuffer(#WEACT_BLACK)
  LogMessage("✓ Buffer cleared", "SUCCESS")
  
  ; Draw pixels with different colors
  Protected i
  For i = 0 To 5
    ; Formula: #WEACT_RED + i * 100 creates color gradient
    WeAct_DrawPixelBuffer(5 + i * 5, 5, #WEACT_RED + i * 100)
  Next
  LogMessage("✓ Pixels drawn", "SUCCESS")
  
  ; Draw lines
  WeAct_DrawLineBuffer(5, 15, 60, 15, #WEACT_WHITE)    ; Horizontal line
  WeAct_DrawLineBuffer(5, 20, 60, 30, #WEACT_YELLOW)   ; Diagonal line
  LogMessage("✓ Lines drawn", "SUCCESS")
  
  ; Draw rectangles (filled and outline)
  WeAct_DrawRectangleBuffer(70, 10, 20, 15, #WEACT_RED, #True)    ; Filled red
  WeAct_DrawRectangleBuffer(95, 10, 20, 15, #WEACT_GREEN, #False) ; Outline green
  LogMessage("✓ Rectangles drawn", "SUCCESS")
  
  ; Draw circles (outline and filled)
  WeAct_DrawCircleBuffer(80, 50, 15, #WEACT_MAGENTA, #False)  ; Outline magenta
  WeAct_DrawCircleBuffer(120, 50, 10, #WEACT_CYAN, #True)     ; Filled cyan
  LogMessage("✓ Circles drawn", "SUCCESS")
  
  WindowEvent()  ; Keep UI responsive by processing pending events
  
  ; Update display with drawn content
  If WeAct_UpdateDisplay()
    LogMessage("✓ Display updated", "SUCCESS")
    WindowEvent()  ; Keep UI responsive
    Delay(2000)    ; Wait 2 seconds to see the result
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestTextFunctions()
  ; Test 2: Text rendering with different fonts and sizes
  LogMessage("=== " + Lang\TestText + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  ; Test different font sizes
  WeAct_DrawTextSmall(5, 5, "Small 8pt", #WEACT_WHITE)
  WeAct_DrawTextMedium(5, 18, "Medium 12pt", #WEACT_GREEN)
  WeAct_DrawTextLarge(5, 35, "Large", #WEACT_BLUE)
  WeAct_DrawTextSmall(5, 55, "Кириллица", #WEACT_YELLOW)  ; Test Cyrillic support
  LogMessage("✓ Font rendering tested", "SUCCESS")
  
  WindowEvent()
  
  If WeAct_UpdateDisplay()
    WindowEvent()
    Delay(2000)
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestGraphics()
  ; Test 3: Advanced graphics (grid, colored borders, text on background)
  LogMessage("=== " + Lang\TestGraphics + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  Protected width = WeActDisplay\DisplayWidth   ; Get display width from library structure
  Protected height = WeActDisplay\DisplayHeight ; Get display height from library structure
  
  ; 1. Create white grid pattern (thin lines every 10px vertically, 20px horizontally)
  Protected y
  For y = 0 To height - 1 Step 10  ; Loop from 0 to height, increment by 10
    WeAct_DrawLineBuffer(0, y, width - 1, y, #WEACT_WHITE)  ; Horizontal grid lines
  Next
  
  Protected x
  For x = 0 To width - 1 Step 20   ; Loop from 0 to width, increment by 20
    WeAct_DrawLineBuffer(x, 0, x, height - 1, #WEACT_WHITE) ; Vertical grid lines
  Next
  
  ; 2. Create thick colored borders (3 pixels thick, bright colors)
  ; Top border - Bright Blue (custom RGB value)
  Protected brightBlue = RGBToRGB565(80, 80, 255)  ; Convert RGB(80,80,255) to display format
  For y = 0 To 2  ; Draw 3-pixel thick border
    For x = 0 To width - 1
      WeAct_DrawPixelBuffer(x, y, brightBlue)
    Next
  Next
  
  ; Bottom border - Bright Green
  Protected brightGreen = RGBToRGB565(80, 255, 80)
  For y = height - 3 To height - 1  ; Last 3 rows
    For x = 0 To width - 1
      WeAct_DrawPixelBuffer(x, y, brightGreen)
    Next
  Next
  
  ; Left border - Bright Yellow
  Protected brightYellow = RGBToRGB565(255, 255, 80)
  For x = 0 To 2  ; First 3 columns
    For y = 0 To height - 1
      WeAct_DrawPixelBuffer(x, y, brightYellow)
    Next
  Next
  
  ; Right border - Bright Red
  Protected brightRed = RGBToRGB565(255, 80, 80)
  For x = width - 3 To width - 1  ; Last 3 columns
    For y = 0 To height - 1
      WeAct_DrawPixelBuffer(x, y, brightRed)
    Next
  Next
  
  ; 3. Display resolution info with contrasting background
  Protected info.s = Str(width) + " × " + Str(height)  ; Format: "160 × 80"
  Protected textWidth = WeAct_GetTextWidth(info, 12, "Arial")  ; Calculate text width in pixels
  Protected textX = (width - textWidth) / 2   ; Center horizontally: (total width - text width) / 2
  Protected textY = (height - 12) / 2        ; Center vertically: (total height - text height) / 2
  
  ; Draw white background rectangle behind text
  WeAct_DrawRectangleBuffer(textX - 6, textY - 4, textWidth + 12, 20, #WEACT_WHITE, #True)
  WeAct_DrawTextMedium(textX, textY, info, #WEACT_BLACK)  ; Draw black text on white background
  
  ; 4. Add border labels in corners with colored backgrounds
  ; "TOP" label in top-left corner on blue background
  WeAct_DrawRectangleBuffer(8, 8, 28, 12, brightBlue, #True)  ; Blue background
  WeAct_DrawTextSmall(10, 10, "TOP", #WEACT_BLACK)            ; Black text
  
  ; "BOTTOM" label in bottom-right corner on green background
  WeAct_DrawRectangleBuffer(width - 48, height - 20, 42, 12, brightGreen, #True)
  WeAct_DrawTextSmall(width - 46, height - 18, "BOTTOM", #WEACT_BLACK)
  
  ; "LEFT" label in bottom-left corner on yellow background
  WeAct_DrawRectangleBuffer(8, height - 20, 30, 12, brightYellow, #True)
  WeAct_DrawTextSmall(10, height - 18, "LEFT", #WEACT_BLACK)
  
  ; "RIGHT" label in top-right corner on red background
  WeAct_DrawRectangleBuffer(width - 38, 8, 32, 12, brightRed, #True)
  WeAct_DrawTextSmall(width - 36, 10, "RIGHT", #WEACT_BLACK)
  
  LogMessage("✓ Grid with bright borders displayed", "SUCCESS")
  LogMessage("Grid: White lines every 10/20 pixels", "INFO")
  LogMessage("Borders: Blue=Top, Yellow=Left, Red=Right, Green=Bottom", "INFO")
  LogMessage("All elements should be clearly visible", "INFO")
  
  WindowEvent()
  
  If WeAct_UpdateDisplay()
    WindowEvent()
    Delay(3000)  ; Wait 3 seconds to see complex graphics
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure TestScrollText()
  ; Test 4: Smooth text scrolling animation
  LogMessage("=== " + Lang\TestScroll + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  ; Start scrolling text with parameters:
  ; Text: "→ Smooth scrolling!"
  ; Font size: 12 pixels
  ; Direction: Left (text moves from right to left)
  ; Speed: 30 pixels per second
  ; Color: White
  WeAct_StartScrollText("→ Smooth scrolling!", 12, #SCROLL_LEFT, 30.0, #WEACT_WHITE)
  LogMessage("✓ Scrolling started", "SUCCESS")
  
  ; Animate scrolling for 60 frames (approximately 2 seconds at 30ms delay)
  Protected i
  For i = 1 To 60
    WeAct_ClearBuffer(#WEACT_BLACK)  ; Clear screen each frame
    WeAct_UpdateScrollText()         ; Calculate new text position
    WeAct_DrawScrollText()           ; Draw text at new position
    
    If Not WeAct_UpdateDisplay()     ; Update physical display
      LogMessage("✗ Display update failed", "ERROR")
      WeAct_StopScrollText()         ; Stop scrolling on error
      ProcedureReturn #False
    EndIf
    
    Delay(30)  ; 30ms delay = ~33 FPS animation
    
    ; Process UI events every 10 frames to keep UI responsive
    If i % 10 = 0 : WindowEvent() : EndIf
  Next
  
  WeAct_StopScrollText()  ; Stop scrolling animation
  LogMessage("✓ Scrolling completed", "SUCCESS")
  ProcedureReturn #True
EndProcedure

Procedure TestImageLoading()
  ; Test 5: Image loading and display
  LogMessage("=== " + Lang\TestImage + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  Protected testImage.s = "test_pattern.bmp"
  ; Check if test image exists, create it if not
  If FileSize(testImage) <= 0  ; FileSize returns -1 if file doesn't exist
    ; Create simple test pattern image programmatically
    Protected img = CreateImage(#PB_Any, 100, 50)  ; Create 100x50 pixel image
    If StartDrawing(ImageOutput(img))
      Box(0, 0, 100, 50, RGB(255, 0, 0))      ; Red background
      Box(10, 10, 80, 30, RGB(0, 255, 0))     ; Green rectangle
      DrawText(20, 18, "TEST", RGB(255, 255, 255))  ; White text
      StopDrawing()
      SaveImage(img, testImage, #PB_ImagePlugin_BMP)  ; Save as BMP file
      FreeImage(img)  ; Free memory
    EndIf
  EndIf
  
  ; Load and display image centered on screen
  If WeAct_LoadImageCentered(testImage, 80, 40)  ; Target size: 80x40 pixels
    LogMessage("✓ Image loaded", "SUCCESS")
    WindowEvent()
    If WeAct_UpdateDisplay()
      WindowEvent()
      Delay(2000)
      ProcedureReturn #True
    Else
      LogMessage("✗ Display update failed", "ERROR")
      ProcedureReturn #False
    EndIf
  Else
    LogMessage("✗ Image loading failed: " + WeAct_GetLastError(), "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestOrientation()
  ; Test 6: Test different display orientations (portrait, landscape, rotate)
  LogMessage("=== " + Lang\TestOrientation + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  Protected originalOrientation = WeAct_GetOrientation()  ; Save current orientation
  Protected orientations.s  ; Orientation names in current language
  
  ; Get orientation names based on current language
  If CurrentLanguage = "RU"
    orientations = "Портрет,Ландшафт,Автоповорот"
  Else
    orientations = "Portrait,Landscape,Auto-rotate"
  EndIf
  
  ; Orientation values corresponding to library constants
  Dim orientationValues.i(2)  ; Array with 3 elements
  orientationValues(0) = 0  ; Portrait mode
  orientationValues(1) = 2  ; Landscape mode
  orientationValues(2) = 5  ; Rotate mode
  
  Protected i, success = #True  ; success flag starts as True
  For i = 0 To 2  ; Test all 3 orientations
    Protected orientation = orientationValues(i)
    
    If WeAct_SetOrientation(orientation)  ; Change orientation
      Delay(200)  ; Wait for display to adjust
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_DrawTextMedium(5, 5, "Orient: " + Str(orientation), #WEACT_WHITE)
      ; Draw yellow border around display edges
      WeAct_DrawRectangleBuffer(0, 0, WeActDisplay\DisplayWidth, WeActDisplay\DisplayHeight, #WEACT_YELLOW, #False)
      
      If WeAct_UpdateDisplay()
        ; Get orientation name from comma-separated list: StringField(list, position, separator)
        LogMessage("✓ " + StringField(orientations, i + 1, ",") + " - OK", "SUCCESS")
        Delay(1000)  ; Wait 1 second to see each orientation
      Else
        LogMessage("✗ Display update failed", "ERROR")
        success = #False  ; Set flag to False on error
        Break  ; Exit loop early
      EndIf
    Else
      LogMessage("✗ Failed to set orientation: " + WeAct_GetLastError(), "ERROR")
      success = #False
      Break
    EndIf
    WindowEvent()  ; Keep UI responsive
  Next
  
  WeAct_SetOrientation(originalOrientation)  ; Restore original orientation
  ProcedureReturn success
EndProcedure

Procedure TestBrightness()
  ; Test 7: Test display brightness control
  LogMessage("=== " + Lang\TestBrightness + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 10, "Brightness", #WEACT_WHITE)
  WeAct_DrawRectangleBuffer(10, 40, 140, 20, #WEACT_WHITE, #True)  ; White progress bar background
  WindowEvent()
  WeAct_UpdateDisplay()
  
  Protected brightnessLevels = 4  ; Test 5 brightness levels (0-4)
  Protected brightness, i, success = #True
  
  ; Test brightness from 0% to 100% in steps
  For i = 0 To brightnessLevels
    brightness = i * 60  ; 0, 60, 120, 180, 240
    If brightness > 255 : brightness = 255 : EndIf  ; Clamp to max 255
    
    ; Set brightness with 200ms fade time
    If WeAct_SetBrightness(brightness, 200)
      LogMessage("✓ Brightness: " + Str(brightness), "SUCCESS")
      WindowEvent()
      Delay(500)  ; Wait 0.5 seconds at each brightness level
    Else
      LogMessage("✗ Failed to set brightness", "ERROR")
      success = #False
    EndIf
  Next
  
  WeAct_SetBrightness(255, 200)  ; Restore max brightness
  ProcedureReturn success
EndProcedure

Procedure TestNewFeatures()
  ; Test 8: Test new library features (progress bars, graphs)
  LogMessage("=== " + Lang\TestNewFeatures + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  ; 1. Progress bar animation (loading from 0% to 100%)
  WeAct_ClearBuffer(#WEACT_BLACK)
  Protected i, progress.f  ; progress is float (0.0 to 1.0)
  For i = 0 To 10
    progress = i / 10.0  ; Convert step to percentage: 0.0, 0.1, 0.2, ..., 1.0
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_DrawTextSmall(10, 5, "Loading...", #WEACT_WHITE)
    ; Draw progress bar: x=10, y=20, width=140, height=15
    WeAct_DrawProgressBar(10, 20, 140, 15, progress, #WEACT_GREEN, #WEACT_BLACK, #WEACT_WHITE)
    WindowEvent()
    If Not WeAct_UpdateDisplay()
      LogMessage("✗ Display update failed", "ERROR")
      ProcedureReturn #False
    EndIf
    Delay(100)  ; 100ms delay between steps = 1 second total animation
  Next
  LogMessage("✓ Progress bar OK", "SUCCESS")
  
  WindowEvent()
  Delay(500)  ; Pause between tests
  
  ; 2. Sine wave graph display
  WeAct_ClearBuffer(#WEACT_BLACK)
  Protected dataCount = 50  ; Number of data points for sine wave
  Dim graphData.f(dataCount - 1)  ; Array to store sine wave values
  
  ; Generate sine wave data: sin(2π * i/dataCount) * 0.8
  ; Creates one complete sine wave cycle
  For i = 0 To dataCount - 1
    ; Formula: sin(angle) * amplitude
    ; angle = i * 2π / dataCount (0 to 2π radians)
    ; amplitude = 0.8 (80% of graph height)
    graphData(i) = Sin(i * 3.14159 * 2.0 / dataCount) * 0.8
  Next
  
  WeAct_DrawTextSmall(5, 2, "Sine wave", #WEACT_WHITE)
  ; Draw graph: x=5, y=15, width=150, height=60
  ; Data range: -1.0 to 1.0 (sine wave range)
  WeAct_DrawGraph(5, 15, 150, 60, @graphData(), dataCount, -1.0, 1.0, #WEACT_CYAN, #WEACT_BLACK)
  
  WindowEvent()
  
  If WeAct_UpdateDisplay()
    LogMessage("✓ Graph rendering OK", "SUCCESS")
    WindowEvent()
    Delay(2000)  ; Wait 2 seconds to see graph
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestSystemInfo()
  ; Test 9: Display system information (resolution, orientation)
  LogMessage("=== " + Lang\TestSystemInfo + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  Protected infoY = 5  ; Starting Y position for first line
  
  ; Display multiple lines of system info with different colors
  WeAct_DrawTextSmall(5, infoY, "System Info:", #WEACT_WHITE) : infoY + 12  ; Move down 12 pixels
  WeAct_DrawTextSmall(5, infoY, "W: " + Str(WeAct_GetDisplayWidth()), #WEACT_GREEN) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "H: " + Str(WeAct_GetDisplayHeight()), #WEACT_BLUE) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "Orient: " + Str(WeAct_GetOrientation()), #WEACT_YELLOW)
  
  WindowEvent()
  
  If WeAct_UpdateDisplay()
    LogMessage("✓ System info displayed", "SUCCESS")
    WindowEvent()
    Delay(2000)
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

; =============================================
; { Test Execution with Timer - Non-blocking }
; =============================================

Procedure RunSingleTest(TestIndex)
  ; Execute a single test by index
  ; TestIndex: 0-9 corresponding to test functions
  Protected success = #False
  
  Select TestIndex
    Case 0
      success = TestInitialization()
    Case 1
      success = TestBasicFunctions()
    Case 2
      success = TestTextFunctions()
    Case 3
      success = TestGraphics()
    Case 4
      success = TestScrollText()
    Case 5
      success = TestImageLoading()
    Case 6
      success = TestOrientation()
    Case 7
      success = TestBrightness()
    Case 8
      success = TestNewFeatures()
    Case 9
      success = TestSystemInfo()
  EndSelect
  
  ProcedureReturn success
EndProcedure

Procedure OnTestTimer()
  ; Timer callback function - called periodically during test execution
  If Not TestRunning
    ; Tests stopped - remove timer
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
    ProcedureReturn
  EndIf
  
  ; Check if display is connected (except for test 0 which IS the connection test)
  ; TestIndex 0 = initialization test, which establishes connection
  If CurrentTestIndex > 0 And Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    TestRunning = #False
    UpdateStatusBar(Lang\StatusError)
    ; Re-enable UI buttons
    DisableGadget(#BTN_RUN_ALL, #False)
    DisableGadget(#BTN_INIT, #False)
    DisableGadget(#BTN_STOP, #True)
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
    ProcedureReturn
  EndIf
  
  ; Run current test
  Protected success = RunSingleTest(CurrentTestIndex)
  
  ; Handle initialization failure (test 0)
  If Not success And CurrentTestIndex = 0
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    TestRunning = #False
    UpdateStatusBar(Lang\StatusError)
    DisableGadget(#BTN_RUN_ALL, #False)
    DisableGadget(#BTN_INIT, #False)
    DisableGadget(#BTN_STOP, #True)
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
    ProcedureReturn
  EndIf
  
  ; Update progress bar: (current test + 1) / total tests
  UpdateProgress(CurrentTestIndex + 1, TestCount)
  CurrentTestIndex + 1  ; Move to next test
  
  ; Check if more tests to run
  ; TestQueue > 0 means running single test, not all tests
  If CurrentTestIndex >= TestCount Or (TestQueue > 0 And CurrentTestIndex > TestQueue)
    ; All tests completed
    TestRunning = #False
    LogMessage("", "INFO")
    LogMessage(Lang\MsgAllCompleted, "SUCCESS")
    UpdateStatusBar(Lang\StatusCompleted)
    
    ; Save results to timestamped text file
    ; FormatDate patterns: %yyyy=year, %mm=month, %dd=day, %hh=hour, %ii=minute, %ss=second
    Protected resultsFile.s = "test_results_" + FormatDate("%yyyy%mm%dd_%hh%ii%ss", Date()) + ".txt"
    If CreateFile(0, resultsFile)
      WriteString(0, TestResults)  ; Write accumulated results
      CloseFile(0)
      LogMessage("✓ Results saved: " + resultsFile, "INFO")
    EndIf
    
    ; Re-enable UI controls
    DisableGadget(#BTN_RUN_ALL, #False)
    DisableGadget(#BTN_INIT, #False)
    DisableGadget(#BTN_STOP, #True)
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
  EndIf
EndProcedure

Procedure StartTests(StartIndex = 0)
  ; Start test execution from specified index
  ; StartIndex: 0 = all tests, 1-9 = start from specific test
  
  ; Check display connection for tests other than initialization
  If StartIndex > 0 And Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    UpdateStatusBar(Lang\StatusError)
    MessageRequester("Error", Lang\MsgNoDisplay, #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf
  
  TestRunning = #True          ; Set global flag
  CurrentTestIndex = StartIndex ; Set starting point
  TestQueue = StartIndex       ; Store test mode (0=all, >0=single)
  
  ; Initialize results header for full test run
  If StartIndex = 0
    TestResults = "=== TEST RESULTS v4.0 ===" + #CRLF$ +
                  "Date: " + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Date()) + #CRLF$ + #CRLF$
  EndIf
  
  UpdateStatusBar(Lang\StatusRunning)
  ; Disable start buttons, enable stop button
  DisableGadget(#BTN_RUN_ALL, #True)
  DisableGadget(#BTN_INIT, #True)
  DisableGadget(#BTN_STOP, #False)
  
  ; Start timer for non-blocking execution (100ms interval)
  AddWindowTimer(#WINDOW_MAIN, #TIMER_TEST, 100)
EndProcedure

; =============================================
; { UI Creation - Build the application window }
; =============================================

Procedure CreateMainWindow()
  ; Create main application window with all UI controls
  Protected flags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget
  
  ; Window size: 800x545 (includes space for status bar)
  If OpenWindow(#WINDOW_MAIN, 0, 0, 800, 545, Lang\AppTitle, flags)
    
    ; Create menu bar
    If CreateMenu(#MENU_MAIN, WindowID(#WINDOW_MAIN))
      MenuTitle(Lang\MenuFile)
        MenuItem(#MENU_FILE_EXIT, Lang\MenuExit)
      MenuTitle(Lang\MenuLanguage)
        MenuItem(#MENU_LANG_EN, "English")
        MenuItem(#MENU_LANG_RU, "Русский")
      MenuTitle(Lang\MenuHelp)
        MenuItem(#MENU_HELP_ABOUT, Lang\MenuAbout)
        MenuItem(#MENU_HELP_GITHUB, Lang\MenuGitHub)
    EndIf
    
    ; Connection settings group (left side)
    FrameGadget(#PB_Any, 10, 10, 380, 70, Lang\GroupConnection)
    TextGadget(#PB_Any, 20, 32, 70, 20, Lang\LabelComPort)
    ComboBoxGadget(#COMBO_COM_PORT, 95, 30, 120, 24)          ; COM port dropdown
    ButtonGadget(#BTN_REFRESH_PORTS, 220, 30, 70, 24, Lang\BtnRefreshPorts)
    ButtonGadget(#BTN_INIT, 20, 55, 350, 20, Lang\BtnInitialize)
    
    ; Test control group (right side)
    FrameGadget(#PB_Any, 400, 10, 390, 70, Lang\GroupTests)
    ButtonGadget(#BTN_RUN_ALL, 410, 30, 110, 24, Lang\BtnRunAll)
    ButtonGadget(#BTN_STOP, 530, 30, 80, 24, Lang\BtnStop)
    ButtonGadget(#BTN_CLEAR_DISPLAY, 620, 30, 160, 24, Lang\BtnClearDisplay)
    ProgressBarGadget(#PROGRESS_TEST, 410, 55, 370, 20, 0, 100)  ; 0-100% range
    
    ; Individual test buttons panel
    FrameGadget(#PB_Any, 10, 90, 780, 60, Lang\TabIndividual)
    ButtonGadget(#BTN_TEST_BASIC, 20, 110, 90, 24, "1. Basic")
    ButtonGadget(#BTN_TEST_TEXT, 115, 110, 90, 24, "2. Text")
    ButtonGadget(#BTN_TEST_GRAPHICS, 210, 110, 90, 24, "3. Graphics")
    ButtonGadget(#BTN_TEST_SCROLL, 305, 110, 90, 24, "4. Scroll")
    ButtonGadget(#BTN_TEST_IMAGE, 400, 110, 90, 24, "5. Image")
    ButtonGadget(#BTN_TEST_ORIENTATION, 495, 110, 90, 24, "6. Orient")
    ButtonGadget(#BTN_TEST_BRIGHTNESS, 590, 110, 90, 24, "7. Bright")
    ButtonGadget(#BTN_TEST_NEW, 685, 110, 95, 24, "8. New")
    
    ; Log display area (takes most of window)
    FrameGadget(#PB_Any, 10, 160, 780, 340, Lang\GroupLog)
    EditorGadget(#EDITOR_LOG, 20, 180, 760, 310, #PB_Editor_ReadOnly)  ; Read-only log
    
    ; Status bar container at bottom
    ContainerGadget(#CONTAINER_STATUS, 0, 510, 800, 35, #PB_Container_Flat)
    TextGadget(#TEXT_STATUS, 2, 7, 796, 22, "  " + Lang\StatusReady, #PB_Text_Border)
    CloseGadgetList()
    
    ; Initial UI state
    DisableGadget(#BTN_STOP, #True)  ; Stop button disabled initially
    RefreshComPorts()                 ; Populate COM port list
    
    ; Initial log messages
    LogMessage("WeAct Display Test Suite v4.0 Professional", "INFO")
    LogMessage("Select COM port and click Initialize", "INFO")
    LogMessage("", "INFO")
    
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; =============================================
; { Event Handling - Process user interactions }
; =============================================

Procedure HandleEvents()
  ; Main event loop handler - processes all window events
  Protected Event = WindowEvent()
  
  Select Event
    Case #PB_Event_Timer
      ; Timer event - used for test execution
      If EventTimer() = #TIMER_TEST
        OnTestTimer()
      EndIf
      
    Case #PB_Event_CloseWindow
      ; Window close requested
      If TestRunning
        ; Tests are running - ask for confirmation
        Protected result = MessageRequester("Confirm Exit", "Tests running. Exit?", #PB_MessageRequester_YesNo)
        If result = #PB_MessageRequester_Yes
          TestRunning = #False
          WeAct_Cleanup()  ; Cleanup display connection
          End
        EndIf
      Else
        WeAct_Cleanup()
        End
      EndIf
      
    Case #PB_Event_Menu
      ; Menu item selected
      Select EventMenu()
        Case #MENU_FILE_EXIT
          PostEvent(#PB_Event_CloseWindow, #WINDOW_MAIN, 0)  ; Trigger close event
        Case #MENU_LANG_EN
          SetLanguage("EN")
        Case #MENU_LANG_RU
          SetLanguage("RU")
        Case #MENU_HELP_ABOUT
          MessageRequester(Lang\AboutTitle, Lang\AboutText, #PB_MessageRequester_Info)
        Case #MENU_HELP_GITHUB
          RunProgram("https://github.com/CheshirCa/WeActDisplay", "", "")  ; Open browser
      EndSelect
      
    Case #PB_Event_Gadget
      ; UI control (gadget) event
      Select EventGadget()
        Case #BTN_REFRESH_PORTS
          RefreshComPorts()
          LogMessage("COM ports refreshed", "INFO")
          
        Case #COMBO_COM_PORT
          ComPort = GetGadgetText(#COMBO_COM_PORT)  ; Get selected port
          LogMessage("Selected: " + ComPort, "INFO")
          
        Case #BTN_INIT
          ComPort = GetGadgetText(#COMBO_COM_PORT)
          If TestInitialization()
            ; Enable individual test buttons after successful initialization
            DisableGadget(#BTN_TEST_BASIC, #False)
            DisableGadget(#BTN_TEST_TEXT, #False)
            DisableGadget(#BTN_TEST_GRAPHICS, #False)
            DisableGadget(#BTN_TEST_SCROLL, #False)
            DisableGadget(#BTN_TEST_IMAGE, #False)
            DisableGadget(#BTN_TEST_ORIENTATION, #False)
            DisableGadget(#BTN_TEST_BRIGHTNESS, #False)
            DisableGadget(#BTN_TEST_NEW, #False)
          EndIf
          
        Case #BTN_RUN_ALL
          ClearLog()      ; Clear previous log
          StartTests(0)   ; Start all tests from beginning
          
        Case #BTN_STOP
          TestRunning = #False
          LogMessage(Lang\MsgTestStopped, "WARNING")
          UpdateStatusBar(Lang\StatusReady)
          
        Case #BTN_CLEAR_DISPLAY
          If WeAct_IsConnected()
            WeAct_ClearBuffer(#WEACT_BLACK)
            WeAct_UpdateDisplay()
            LogMessage("Display cleared", "INFO")
          EndIf
          
        ; Individual test buttons - each starts a specific test
        Case #BTN_TEST_BASIC
          StartTests(1)   ; Start from test 1 (Basic)
        Case #BTN_TEST_TEXT
          StartTests(2)   ; Start from test 2 (Text)
        Case #BTN_TEST_GRAPHICS
          StartTests(3)   ; Start from test 3 (Graphics)
        Case #BTN_TEST_SCROLL
          StartTests(4)   ; Start from test 4 (Scroll)
        Case #BTN_TEST_IMAGE
          StartTests(5)   ; Start from test 5 (Image)
        Case #BTN_TEST_ORIENTATION
          StartTests(6)   ; Start from test 6 (Orientation)
        Case #BTN_TEST_BRIGHTNESS
          StartTests(7)   ; Start from test 7 (Brightness)
        Case #BTN_TEST_NEW
          StartTests(8)   ; Start from test 8 (New Features)
      EndSelect
  EndSelect
EndProcedure

; =============================================
; { Main Program Entry Point }
; =============================================

SetLanguage("EN")  ; Set default language to English

If CreateMainWindow()
  ; Main event loop - runs until window is closed
  Repeat
    HandleEvents()  ; Process any pending events
    Delay(10)       ; Small delay to prevent CPU overuse (approx 100 FPS)
  ForEver
Else
  MessageRequester("Error", "Failed to create window", #PB_MessageRequester_Error)
EndIf

WeAct_Cleanup()  ; Cleanup resources on exit

; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 111
; FirstLine = 54
; Folding = -----
; EnableXP
; Executable = WeAct_Test.exe
