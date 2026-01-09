; =============================================
; WeAct Display FS Test Suite - Professional Edition v4.0
; FIXED: All issues resolved
; 
; Fixed Issues:
; - COM port selection from available ports
; - Window size and status bar visibility
; - Individual test execution
; - Non-blocking tests with timer
; - Proper error handling (stops on connection failure)
; - UI doesn't freeze during tests
; 
; GitHub: https://github.com/CheshirCa/WeActDisplay
; =============================================

XIncludeFile "WeActDisplay.pbi"

; { Window and Gadget IDs }
Enumeration
  #WINDOW_MAIN
  #MENU_MAIN
  #TIMER_TEST
  
  ; Gadgets
  #EDITOR_LOG
  #BTN_INIT
  #BTN_RUN_ALL
  #BTN_STOP
  #BTN_CLEAR_DISPLAY
  #COMBO_COM_PORT
  #BTN_REFRESH_PORTS
  #PROGRESS_TEST
  #CONTAINER_STATUS
  #TEXT_STATUS
  #PANEL_TESTS
  
  ; Test buttons
  #BTN_TEST_BASIC
  #BTN_TEST_TEXT
  #BTN_TEST_GRAPHICS
  #BTN_TEST_SCROLL
  #BTN_TEST_IMAGE
  #BTN_TEST_ORIENTATION
  #BTN_TEST_BRIGHTNESS
  #BTN_TEST_NEW
  
  ; Menu items
  #MENU_FILE_EXIT
  #MENU_LANG_EN
  #MENU_LANG_RU
  #MENU_HELP_ABOUT
  #MENU_HELP_GITHUB
EndEnumeration

; { Language System }
Structure LanguageStrings
  AppTitle.s
  MenuFile.s
  MenuExit.s
  MenuLanguage.s
  MenuHelp.s
  MenuAbout.s
  MenuGitHub.s
  
  GroupConnection.s
  LabelComPort.s
  BtnRefreshPorts.s
  BtnInitialize.s
  
  GroupTests.s
  BtnRunAll.s
  BtnStop.s
  BtnClearDisplay.s
  TabIndividual.s
  
  GroupLog.s
  
  StatusReady.s
  StatusRunning.s
  StatusCompleted.s
  StatusError.s
  StatusConnected.s
  StatusDisconnected.s
  
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
  
  MsgNoDisplay.s
  MsgTestStopped.s
  MsgAllCompleted.s
  
  AboutTitle.s
  AboutText.s
EndStructure

Global Lang.LanguageStrings
Global CurrentLanguage.s = "EN"
Global TestRunning.i = #False
Global TestResults.s = ""
Global ComPort.s = "COM3"
Global CurrentTestIndex.i = 0
Global TestCount.i = 10
Global TestQueue.i = 0  ; 0 = all tests, 1-9 = specific test

; =============================================
; { Language Initialization }
; =============================================

Procedure InitLanguageEN()
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

Procedure SetLanguage(Language.s)
  CurrentLanguage = Language
  If Language = "RU"
    InitLanguageRU()
  Else
    InitLanguageEN()
  EndIf
  If IsWindow(#WINDOW_MAIN)
    SetWindowTitle(#WINDOW_MAIN, Lang\AppTitle)
  EndIf
EndProcedure

; =============================================
; { COM Port Detection }
; =============================================

Procedure.s GetAvailableComPorts()
  Protected portList.s = ""
  Protected i
  
  ; Scan COM1 to COM20
  For i = 1 To 20
    Protected portName.s = "COM" + Str(i)
    Protected testPort = OpenSerialPort(#PB_Any, portName, 9600, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 512, 512)
    If testPort
      CloseSerialPort(testPort)
      If portList <> ""
        portList + ","
      EndIf
      portList + portName
    EndIf
  Next
  
  ProcedureReturn portList
EndProcedure

Procedure RefreshComPorts()
  If IsGadget(#COMBO_COM_PORT)
    ClearGadgetItems(#COMBO_COM_PORT)
    
    Protected ports.s = GetAvailableComPorts()
    If ports = ""
      AddGadgetItem(#COMBO_COM_PORT, -1, "No ports found")
      DisableGadget(#BTN_INIT, #True)
    Else
      Protected count = CountString(ports, ",") + 1
      Protected i
      For i = 1 To count
        AddGadgetItem(#COMBO_COM_PORT, -1, StringField(ports, i, ","))
      Next
      SetGadgetState(#COMBO_COM_PORT, 0)
      DisableGadget(#BTN_INIT, #False)
    EndIf
  EndIf
EndProcedure

; =============================================
; { Logging Functions }
; =============================================

Procedure LogMessage(Message.s, Level.s = "INFO")
  Protected Timestamp.s = FormatDate("%hh:%ii:%ss", Date())
  Protected Prefix.s
  
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
  
  If IsGadget(#EDITOR_LOG)
    AddGadgetItem(#EDITOR_LOG, -1, LogLine)
    SetGadgetState(#EDITOR_LOG, CountGadgetItems(#EDITOR_LOG) - 1)
  EndIf
  
  Debug LogLine
  TestResults + LogLine + #CRLF$
EndProcedure

Procedure ClearLog()
  If IsGadget(#EDITOR_LOG)
    ClearGadgetItems(#EDITOR_LOG)
  EndIf
  TestResults = ""
EndProcedure

Procedure UpdateProgress(Current, Total)
  If IsGadget(#PROGRESS_TEST)
    SetGadgetState(#PROGRESS_TEST, (Current * 100) / Total)
  EndIf
EndProcedure

Procedure UpdateStatusBar(Message.s)
  If IsGadget(#TEXT_STATUS)
    SetGadgetText(#TEXT_STATUS, "  " + Message)
  EndIf
EndProcedure

; =============================================
; { Test Functions - With Proper Error Checking }
; =============================================

Procedure TestInitialization()
  LogMessage("=== " + Lang\TestInit + " ===", "TEST")
  
  If WeAct_Init(ComPort)
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
  LogMessage("=== " + Lang\TestBasic + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  LogMessage("✓ Buffer cleared", "SUCCESS")
  
  Protected i
  For i = 0 To 5
    WeAct_DrawPixelBuffer(5 + i * 5, 5, #WEACT_RED + i * 100)
  Next
  LogMessage("✓ Pixels drawn", "SUCCESS")
  
  WeAct_DrawLineBuffer(5, 15, 60, 15, #WEACT_WHITE)
  WeAct_DrawLineBuffer(5, 20, 60, 30, #WEACT_YELLOW)
  LogMessage("✓ Lines drawn", "SUCCESS")
  
  WeAct_DrawRectangleBuffer(70, 10, 20, 15, #WEACT_RED, #True)
  WeAct_DrawRectangleBuffer(95, 10, 20, 15, #WEACT_GREEN, #False)
  LogMessage("✓ Rectangles drawn", "SUCCESS")
  
  WeAct_DrawCircleBuffer(80, 50, 15, #WEACT_MAGENTA, #False)
  WeAct_DrawCircleBuffer(120, 50, 10, #WEACT_CYAN, #True)
  LogMessage("✓ Circles drawn", "SUCCESS")
  
  WindowEvent()  ; Keep UI responsive
  
  If WeAct_UpdateDisplay()
    LogMessage("✓ Display updated", "SUCCESS")
    WindowEvent()  ; Keep UI responsive
    Delay(2000)
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestTextFunctions()
  LogMessage("=== " + Lang\TestText + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextSmall(5, 5, "Small 8pt", #WEACT_WHITE)
  WeAct_DrawTextMedium(5, 18, "Medium 12pt", #WEACT_GREEN)
  WeAct_DrawTextLarge(5, 35, "Large", #WEACT_BLUE)
  WeAct_DrawTextSmall(5, 55, "Кириллица", #WEACT_YELLOW)
  LogMessage("✓ Font rendering tested", "SUCCESS")
  
  WindowEvent()  ; Keep UI responsive
  
  If WeAct_UpdateDisplay()
    WindowEvent()  ; Keep UI responsive
    Delay(2000)
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestGraphics()
  LogMessage("=== " + Lang\TestGraphics + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  Protected width = WeActDisplay\DisplayWidth
  Protected height = WeActDisplay\DisplayHeight
  
  ; 1. Основная сетка - БЕЛЫЕ тонкие линии
  Protected y
  For y = 0 To height - 1 Step 10
    WeAct_DrawLineBuffer(0, y, width - 1, y, #WEACT_WHITE)
  Next
  
  Protected x
  For x = 0 To width - 1 Step 20
    WeAct_DrawLineBuffer(x, 0, x, height - 1, #WEACT_WHITE)
  Next
  
  ; 2. Цветные границы - ТОЛСТЫЕ (3 пикселя) и ЯРКИЕ
  ; Верхняя граница - ЯРКИЙ СИНИЙ
  Protected brightBlue = RGBToRGB565(80, 80, 255)
  For y = 0 To 2
    For x = 0 To width - 1
      WeAct_DrawPixelBuffer(x, y, brightBlue)
    Next
  Next
  
  ; Нижняя граница - ЯРКИЙ ЗЕЛЕНЫЙ
  Protected brightGreen = RGBToRGB565(80, 255, 80)
  For y = height - 3 To height - 1
    For x = 0 To width - 1
      WeAct_DrawPixelBuffer(x, y, brightGreen)
    Next
  Next
  
  ; Левая граница - ЯРКИЙ ЖЕЛТЫЙ
  Protected brightYellow = RGBToRGB565(255, 255, 80)
  For x = 0 To 2
    For y = 0 To height - 1
      WeAct_DrawPixelBuffer(x, y, brightYellow)
    Next
  Next
  
  ; Правая граница - ЯРКИЙ КРАСНЫЙ
  Protected brightRed = RGBToRGB565(255, 80, 80)
  For x = width - 3 To width - 1
    For y = 0 To height - 1
      WeAct_DrawPixelBuffer(x, y, brightRed)
    Next
  Next
  
  ; 3. Информационный текст с контрастным фоном
  ; Размеры дисплея в центре
  Protected info.s = Str(width) + " × " + Str(height)
  Protected textWidth = WeAct_GetTextWidth(info, 12, "Arial")
  Protected textX = (width - textWidth) / 2
  Protected textY = (height - 12) / 2
  
  ; Белый фон для текста
  WeAct_DrawRectangleBuffer(textX - 6, textY - 4, textWidth + 12, 20, #WEACT_WHITE, #True)
  WeAct_DrawTextMedium(textX, textY, info, #WEACT_BLACK)
  
  ; 4. Подписи границ (маленькие, в углах)
  ; "TOP" в левом верхнем углу
  WeAct_DrawRectangleBuffer(8, 8, 28, 12, brightBlue, #True)
  WeAct_DrawTextSmall(10, 10, "TOP", #WEACT_BLACK)
  
  ; "BOTTOM" в правом нижнем углу
  WeAct_DrawRectangleBuffer(width - 48, height - 20, 42, 12, brightGreen, #True)
  WeAct_DrawTextSmall(width - 46, height - 18, "BOTTOM", #WEACT_BLACK)
  
  ; "LEFT" в левом нижнем углу
  WeAct_DrawRectangleBuffer(8, height - 20, 30, 12, brightYellow, #True)
  WeAct_DrawTextSmall(10, height - 18, "LEFT", #WEACT_BLACK)
  
  ; "RIGHT" в правом верхнем углу
  WeAct_DrawRectangleBuffer(width - 38, 8, 32, 12, brightRed, #True)
  WeAct_DrawTextSmall(width - 36, 10, "RIGHT", #WEACT_BLACK)
  
  LogMessage("✓ Grid with bright borders displayed", "SUCCESS")
  LogMessage("Grid: White lines every 10/20 pixels", "INFO")
  LogMessage("Borders: Blue=Top, Yellow=Left, Red=Right, Green=Bottom", "INFO")
  LogMessage("All elements should be clearly visible", "INFO")
  
  WindowEvent()
  
  If WeAct_UpdateDisplay()
    WindowEvent()
    Delay(3000)
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure TestScrollText()
  LogMessage("=== " + Lang\TestScroll + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_StartScrollText("→ Smooth scrolling!", 12, #SCROLL_LEFT, 30.0, #WEACT_WHITE)
  LogMessage("✓ Scrolling started", "SUCCESS")
  
  Protected i
  For i = 1 To 60
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateScrollText()
    WeAct_DrawScrollText()
    If Not WeAct_UpdateDisplay()
      LogMessage("✗ Display update failed", "ERROR")
      WeAct_StopScrollText()
      ProcedureReturn #False
    EndIf
    Delay(30)
    If i % 10 = 0 : WindowEvent() : EndIf
  Next
  
  WeAct_StopScrollText()
  LogMessage("✓ Scrolling completed", "SUCCESS")
  ProcedureReturn #True
EndProcedure

Procedure TestImageLoading()
  LogMessage("=== " + Lang\TestImage + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  Protected testImage.s = "test_pattern.bmp"
  If FileSize(testImage) <= 0
    Protected img = CreateImage(#PB_Any, 100, 50)
    If StartDrawing(ImageOutput(img))
      Box(0, 0, 100, 50, RGB(255, 0, 0))
      Box(10, 10, 80, 30, RGB(0, 255, 0))
      DrawText(20, 18, "TEST", RGB(255, 255, 255))
      StopDrawing()
      SaveImage(img, testImage, #PB_ImagePlugin_BMP)
      FreeImage(img)
    EndIf
  EndIf
  
  If WeAct_LoadImageCentered(testImage, 80, 40)
    LogMessage("✓ Image loaded", "SUCCESS")
    WindowEvent()  ; Keep UI responsive
    If WeAct_UpdateDisplay()
      WindowEvent()  ; Keep UI responsive
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
  LogMessage("=== " + Lang\TestOrientation + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  Protected originalOrientation = WeAct_GetOrientation()
  Protected orientations.s
  
  If CurrentLanguage = "RU"
    orientations = "Портрет,Ландшафт,Автоповорот"
  Else
    orientations = "Portrait,Landscape,Auto-rotate"
  EndIf
  
  Dim orientationValues.i(2)
  orientationValues(0) = 0  ; Portrait
  orientationValues(1) = 2  ; Landscape
  orientationValues(2) = 5  ; Rotate
  
  Protected i, success = #True
  For i = 0 To 2
    Protected orientation = orientationValues(i)
    
    If WeAct_SetOrientation(orientation)
      Delay(200)
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_DrawTextMedium(5, 5, "Orient: " + Str(orientation), #WEACT_WHITE)
      WeAct_DrawRectangleBuffer(0, 0, WeActDisplay\DisplayWidth, WeActDisplay\DisplayHeight, #WEACT_YELLOW, #False)
      
      If WeAct_UpdateDisplay()
        LogMessage("✓ " + StringField(orientations, i + 1, ",") + " - OK", "SUCCESS")
        Delay(1000)
      Else
        LogMessage("✗ Display update failed", "ERROR")
        success = #False
        Break
      EndIf
    Else
      LogMessage("✗ Failed to set orientation: " + WeAct_GetLastError(), "ERROR")
      success = #False
      Break
    EndIf
    WindowEvent()
  Next
  
  WeAct_SetOrientation(originalOrientation)
  ProcedureReturn success
EndProcedure

Procedure TestBrightness()
  LogMessage("=== " + Lang\TestBrightness + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 10, "Brightness", #WEACT_WHITE)
  WeAct_DrawRectangleBuffer(10, 40, 140, 20, #WEACT_WHITE, #True)
  WindowEvent()  ; Keep UI responsive
  WeAct_UpdateDisplay()
  
  Protected brightnessLevels = 4
  Protected brightness, i, success = #True
  
  For i = 0 To brightnessLevels
    brightness = i * 60
    If brightness > 255 : brightness = 255 : EndIf
    
    If WeAct_SetBrightness(brightness, 200)
      LogMessage("✓ Brightness: " + Str(brightness), "SUCCESS")
      WindowEvent()  ; Keep UI responsive
      Delay(500)
    Else
      LogMessage("✗ Failed to set brightness", "ERROR")
      success = #False
    EndIf
  Next
  
  WeAct_SetBrightness(255, 200)
  ProcedureReturn success
EndProcedure

Procedure TestNewFeatures()
  LogMessage("=== " + Lang\TestNewFeatures + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  ; Progress bar
  WeAct_ClearBuffer(#WEACT_BLACK)
  Protected i, progress.f
  For i = 0 To 10
    progress = i / 10.0
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_DrawTextSmall(10, 5, "Loading...", #WEACT_WHITE)
    WeAct_DrawProgressBar(10, 20, 140, 15, progress, #WEACT_GREEN, #WEACT_BLACK, #WEACT_WHITE)
    WindowEvent()  ; Keep UI responsive
    If Not WeAct_UpdateDisplay()
      LogMessage("✗ Display update failed", "ERROR")
      ProcedureReturn #False
    EndIf
    Delay(100)
  Next
  LogMessage("✓ Progress bar OK", "SUCCESS")
  
  WindowEvent()  ; Keep UI responsive
  Delay(500)
  
  ; Graph
  WeAct_ClearBuffer(#WEACT_BLACK)
  Protected dataCount = 50
  Dim graphData.f(dataCount - 1)
  For i = 0 To dataCount - 1
    graphData(i) = Sin(i * 3.14159 * 2.0 / dataCount) * 0.8
  Next
  
  WeAct_DrawTextSmall(5, 2, "Sine wave", #WEACT_WHITE)
  WeAct_DrawGraph(5, 15, 150, 60, @graphData(), dataCount, -1.0, 1.0, #WEACT_CYAN, #WEACT_BLACK)
  
  WindowEvent()  ; Keep UI responsive
  
  If WeAct_UpdateDisplay()
    LogMessage("✓ Graph rendering OK", "SUCCESS")
    WindowEvent()  ; Keep UI responsive
    Delay(2000)
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestSystemInfo()
  LogMessage("=== " + Lang\TestSystemInfo + " ===", "TEST")
  
  If Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    ProcedureReturn #False
  EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  Protected infoY = 5
  WeAct_DrawTextSmall(5, infoY, "System Info:", #WEACT_WHITE) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "W: " + Str(WeAct_GetDisplayWidth()), #WEACT_GREEN) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "H: " + Str(WeAct_GetDisplayHeight()), #WEACT_BLUE) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "Orient: " + Str(WeAct_GetOrientation()), #WEACT_YELLOW)
  
  WindowEvent()  ; Keep UI responsive
  
  If WeAct_UpdateDisplay()
    LogMessage("✓ System info displayed", "SUCCESS")
    WindowEvent()  ; Keep UI responsive
    Delay(2000)
    ProcedureReturn #True
  Else
    LogMessage("✗ Display update failed", "ERROR")
    ProcedureReturn #False
  EndIf
EndProcedure

; =============================================
; { Test Execution with Timer }
; =============================================

Procedure RunSingleTest(TestIndex)
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
  If Not TestRunning
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
    ProcedureReturn
  EndIf
  
  ; Check if display is connected (except for test 0 which IS the connection test)
  If CurrentTestIndex > 0 And Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    TestRunning = #False
    UpdateStatusBar(Lang\StatusError)
    DisableGadget(#BTN_RUN_ALL, #False)
    DisableGadget(#BTN_INIT, #False)
    DisableGadget(#BTN_STOP, #True)
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
    ProcedureReturn
  EndIf
  
  ; Run current test
  Protected success = RunSingleTest(CurrentTestIndex)
  
  If Not success And CurrentTestIndex = 0
    ; Initialization failed - stop all tests
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    TestRunning = #False
    UpdateStatusBar(Lang\StatusError)
    DisableGadget(#BTN_RUN_ALL, #False)
    DisableGadget(#BTN_INIT, #False)
    DisableGadget(#BTN_STOP, #True)
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
    ProcedureReturn
  EndIf
  
  UpdateProgress(CurrentTestIndex + 1, TestCount)
  CurrentTestIndex + 1
  
  ; Check if more tests to run
  If CurrentTestIndex >= TestCount Or (TestQueue > 0 And CurrentTestIndex > TestQueue)
    TestRunning = #False
    LogMessage("", "INFO")
    LogMessage(Lang\MsgAllCompleted, "SUCCESS")
    UpdateStatusBar(Lang\StatusCompleted)
    
    ; Save results
    Protected resultsFile.s = "test_results_" + FormatDate("%yyyy%mm%dd_%hh%ii%ss", Date()) + ".txt"
    If CreateFile(0, resultsFile)
      WriteString(0, TestResults)
      CloseFile(0)
      LogMessage("✓ Results saved: " + resultsFile, "INFO")
    EndIf
    
    DisableGadget(#BTN_RUN_ALL, #False)
    DisableGadget(#BTN_INIT, #False)
    DisableGadget(#BTN_STOP, #True)
    RemoveWindowTimer(#WINDOW_MAIN, #TIMER_TEST)
  EndIf
EndProcedure

Procedure StartTests(StartIndex = 0)
  If StartIndex > 0 And Not WeAct_IsConnected()
    LogMessage(Lang\MsgNoDisplay, "ERROR")
    UpdateStatusBar(Lang\StatusError)
    MessageRequester("Error", Lang\MsgNoDisplay, #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf
  
  TestRunning = #True
  CurrentTestIndex = StartIndex
  TestQueue = StartIndex  ; 0 = all tests, >0 = single test
  
  If StartIndex = 0
    TestResults = "=== TEST RESULTS v4.0 ===" + #CRLF$ +
                  "Date: " + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Date()) + #CRLF$ + #CRLF$
  EndIf
  
  UpdateStatusBar(Lang\StatusRunning)
  DisableGadget(#BTN_RUN_ALL, #True)
  DisableGadget(#BTN_INIT, #True)
  DisableGadget(#BTN_STOP, #False)
  
  ; Use timer for non-blocking execution
  AddWindowTimer(#WINDOW_MAIN, #TIMER_TEST, 100)
EndProcedure

; =============================================
; { UI Creation }
; =============================================

Procedure CreateMainWindow()
  ; Increased window size: 800x545 (was 520, status bar was cut)
  Protected flags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget
  
  If OpenWindow(#WINDOW_MAIN, 0, 0, 800, 545, Lang\AppTitle, flags)
    
    ; Create menu
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
    
    ; Connection group
    FrameGadget(#PB_Any, 10, 10, 380, 70, Lang\GroupConnection)
    TextGadget(#PB_Any, 20, 32, 70, 20, Lang\LabelComPort)
    ComboBoxGadget(#COMBO_COM_PORT, 95, 30, 120, 24)
    ButtonGadget(#BTN_REFRESH_PORTS, 220, 30, 70, 24, Lang\BtnRefreshPorts)
    ButtonGadget(#BTN_INIT, 20, 55, 350, 20, Lang\BtnInitialize)
    
    ; Test control group
    FrameGadget(#PB_Any, 400, 10, 390, 70, Lang\GroupTests)
    ButtonGadget(#BTN_RUN_ALL, 410, 30, 110, 24, Lang\BtnRunAll)
    ButtonGadget(#BTN_STOP, 530, 30, 80, 24, Lang\BtnStop)
    ButtonGadget(#BTN_CLEAR_DISPLAY, 620, 30, 160, 24, Lang\BtnClearDisplay)
    ProgressBarGadget(#PROGRESS_TEST, 410, 55, 370, 20, 0, 100)
    
    ; Individual tests panel
    FrameGadget(#PB_Any, 10, 90, 780, 60, Lang\TabIndividual)
    ButtonGadget(#BTN_TEST_BASIC, 20, 110, 90, 24, "1. Basic")
    ButtonGadget(#BTN_TEST_TEXT, 115, 110, 90, 24, "2. Text")
    ButtonGadget(#BTN_TEST_GRAPHICS, 210, 110, 90, 24, "3. Graphics")
    ButtonGadget(#BTN_TEST_SCROLL, 305, 110, 90, 24, "4. Scroll")
    ButtonGadget(#BTN_TEST_IMAGE, 400, 110, 90, 24, "5. Image")
    ButtonGadget(#BTN_TEST_ORIENTATION, 495, 110, 90, 24, "6. Orient")
    ButtonGadget(#BTN_TEST_BRIGHTNESS, 590, 110, 90, 24, "7. Bright")
    ButtonGadget(#BTN_TEST_NEW, 685, 110, 95, 24, "8. New")
    
    ; Log group - moved up by 5 pixels, increased height to 330
    FrameGadget(#PB_Any, 10, 160, 780, 340, Lang\GroupLog)
    EditorGadget(#EDITOR_LOG, 20, 180, 760, 310, #PB_Editor_ReadOnly)
    
    ; Status bar with container - moved to new position
    ContainerGadget(#CONTAINER_STATUS, 0, 510, 800, 35, #PB_Container_Flat)
    TextGadget(#TEXT_STATUS, 2, 7, 796, 22, "  " + Lang\StatusReady, #PB_Text_Border)
    CloseGadgetList()
    
    ; Initial state
    DisableGadget(#BTN_STOP, #True)
    RefreshComPorts()
    
    LogMessage("WeAct Display Test Suite v4.0 Professional", "INFO")
    LogMessage("Select COM port and click Initialize", "INFO")
    LogMessage("", "INFO")
    
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; =============================================
; { Event Handling }
; =============================================

Procedure HandleEvents()
  Protected Event = WindowEvent()
  
  Select Event
    Case #PB_Event_Timer
      If EventTimer() = #TIMER_TEST
        OnTestTimer()
      EndIf
      
    Case #PB_Event_CloseWindow
      If TestRunning
        Protected result = MessageRequester("Confirm Exit", "Tests running. Exit?", #PB_MessageRequester_YesNo)
        If result = #PB_MessageRequester_Yes
          TestRunning = #False
          WeAct_Cleanup()
          End
        EndIf
      Else
        WeAct_Cleanup()
        End
      EndIf
      
    Case #PB_Event_Menu
      Select EventMenu()
        Case #MENU_FILE_EXIT
          PostEvent(#PB_Event_CloseWindow, #WINDOW_MAIN, 0)
        Case #MENU_LANG_EN
          SetLanguage("EN")
        Case #MENU_LANG_RU
          SetLanguage("RU")
        Case #MENU_HELP_ABOUT
          MessageRequester(Lang\AboutTitle, Lang\AboutText, #PB_MessageRequester_Info)
        Case #MENU_HELP_GITHUB
          RunProgram("https://github.com/CheshirCa/WeActDisplay", "", "")
      EndSelect
      
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #BTN_REFRESH_PORTS
          RefreshComPorts()
          LogMessage("COM ports refreshed", "INFO")
          
        Case #COMBO_COM_PORT
          ComPort = GetGadgetText(#COMBO_COM_PORT)
          LogMessage("Selected: " + ComPort, "INFO")
          
        Case #BTN_INIT
          ComPort = GetGadgetText(#COMBO_COM_PORT)
          If TestInitialization()
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
          ClearLog()
          StartTests(0)
          
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
          
        Case #BTN_TEST_BASIC
          StartTests(1)
        Case #BTN_TEST_TEXT
          StartTests(2)
        Case #BTN_TEST_GRAPHICS
          StartTests(3)
        Case #BTN_TEST_SCROLL
          StartTests(4)
        Case #BTN_TEST_IMAGE
          StartTests(5)
        Case #BTN_TEST_ORIENTATION
          StartTests(6)
        Case #BTN_TEST_BRIGHTNESS
          StartTests(7)
        Case #BTN_TEST_NEW
          StartTests(8)
      EndSelect
  EndSelect
EndProcedure

; =============================================
; { Main Program }
; =============================================

SetLanguage("EN")

If CreateMainWindow()
  Repeat
    HandleEvents()
    Delay(10)
  ForEver
Else
  MessageRequester("Error", "Failed to create window", #PB_MessageRequester_Error)
EndIf

WeAct_Cleanup()

; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 524
; FirstLine = 474
; Folding = -----
; EnableXP
