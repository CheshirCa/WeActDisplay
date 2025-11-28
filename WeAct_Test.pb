; =============================================
; WeAct Display FS Library Test Suite
; Comprehensive test for all library functions
; =============================================

XIncludeFile "d:\WeActDisplay.pbi"

; { Константы теста }
Enumeration
  #WINDOW_MAIN
  #BTN_INIT
  #BTN_BASIC_TEST
  #BTN_TEXT_TEST
  #BTN_GRAPHICS_TEST
  #BTN_SCROLL_TEST
  #BTN_IMAGE_TEST
  #BTN_ORIENTATION_TEST
  #BTN_BRIGHTNESS_TEST
  #BTN_CLEAR
  #TXT_STATUS
  #STR_CURRENT_TEST
  #PROGRESS_TEST
  #BTN_NEXT_TEST
  #BTN_PREV_TEST
  #BTN_RUN_ALL_TESTS
EndEnumeration

; { Глобальные переменные }
Global currentTest.i = 0
Global testRunning.i = #False
Global testResults.s = ""

; =============================================
; { ФУНКЦИИ ТЕСТИРОВАНИЯ }
; =============================================

Procedure UpdateStatus(text.s)
  SetGadgetText(#TXT_STATUS, text)
  Debug text
  testResults + text + #CRLF$
EndProcedure

Procedure UpdateProgress(value, max)
  SetGadgetState(#PROGRESS_TEST, value * 100 / max)
EndProcedure

Procedure TestInitialization()
  UpdateStatus("=== ТЕСТ ИНИЦИАЛИЗАЦИИ ===")
  
  If WeAct_Init("COM8")
    UpdateStatus("✅ Дисплей инициализирован успешно")
    UpdateStatus("  Порт: " + WeAct_GetInfo())
    UpdateStatus("  Размер: " + Str(WeAct_GetDisplayWidth()) + "x" + Str(WeAct_GetDisplayHeight()))
    UpdateStatus("  Ориентация: " + Str(WeAct_GetOrientation()))
    UpdateStatus("  Яркость: " + Str(WeAct_GetBrightness()))
    ProcedureReturn #True
  Else
    UpdateStatus("❌ Ошибка инициализации дисплея!")
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure TestBasicFunctions()
  UpdateStatus("=== ТЕСТ БАЗОВЫХ ФУНКЦИЙ ===")
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  UpdateStatus("✅ Буфер очищен")
  
  ; Тест пикселей
  WeAct_DrawPixelBuffer(5, 5, #WEACT_RED)
  WeAct_DrawPixelBuffer(10, 5, #WEACT_GREEN)
  WeAct_DrawPixelBuffer(15, 5, #WEACT_BLUE)
  UpdateStatus("✅ Пиксели нарисованы")
  
  ; Тест линий
  WeAct_DrawLineBuffer(20, 10, 60, 10, #WEACT_WHITE)
  WeAct_DrawLineBuffer(20, 15, 60, 25, #WEACT_YELLOW)
  WeAct_DrawLineBuffer(20, 30, 60, 20, #WEACT_CYAN)
  UpdateStatus("✅ Линии нарисованы")
  
  ; Тест прямоугольников
  WeAct_DrawRectangleBuffer(70, 10, 20, 15, #WEACT_RED, #True)
  WeAct_DrawRectangleBuffer(95, 10, 20, 15, #WEACT_GREEN, #False)
  WeAct_DrawRectangleBuffer(120, 10, 20, 15, #WEACT_BLUE, #True)
  UpdateStatus("✅ Прямоугольники нарисованы")
  
  ; Тест обновления дисплея
  If WeAct_UpdateDisplay()
    UpdateStatus("✅ Дисплей обновлен успешно")
  Else
    UpdateStatus("❌ Ошибка обновления дисплея")
  EndIf
  
  Delay(1000)
EndProcedure

Procedure TestTextFunctions()
  UpdateStatus("=== ТЕСТ ТЕКСТОВЫХ ФУНКЦИЙ ===")
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Тест разных размеров шрифта
  WeAct_DrawTextSmall(5, 5, "Small 8pt", #WEACT_WHITE)
  WeAct_DrawTextMedium(5, 20, "Medium 12pt", #WEACT_GREEN)
  WeAct_DrawTextLarge(5, 40, "Large 16pt", #WEACT_BLUE)
  UpdateStatus("✅ Разные размеры шрифтов")
  
  ; Тест разных цветов текста
  WeAct_DrawTextSmall(80, 5, "Red", #WEACT_RED)
  WeAct_DrawTextSmall(80, 20, "Yellow", #WEACT_YELLOW)
  WeAct_DrawTextSmall(80, 35, "Cyan", #WEACT_CYAN)
  WeAct_DrawTextSmall(80, 50, "Magenta", #WEACT_MAGENTA)
  UpdateStatus("✅ Разные цвета текста")
  
  ; Тест переноса текста
  WeAct_DrawWrappedTextFixed(5, 60, 150, 20, "This is a long text that should wrap automatically", #WEACT_WHITE, 8)
  UpdateStatus("✅ Перенос текста")
  
  WeAct_UpdateDisplay()
  Delay(1000)
EndProcedure

Procedure TestGraphics()
  UpdateStatus("=== ТЕСТ ГРАФИКИ ===")
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Сетка из линий
  For i = 0 To 7
    WeAct_DrawLineBuffer(0, i * 10, 159, i * 10, #WEACT_WHITE)
    WeAct_DrawLineBuffer(i * 20, 0, i * 20, 79, #WEACT_WHITE)
  Next
  UpdateStatus("✅ Сетка нарисована")
  
  ; Геометрические фигуры
  WeAct_DrawRectangleBuffer(10, 10, 30, 20, #WEACT_RED, #True)
  WeAct_DrawRectangleBuffer(50, 10, 30, 20, #WEACT_GREEN, #False)
  WeAct_DrawRectangleBuffer(90, 10, 30, 20, #WEACT_BLUE, #True)
  
  WeAct_DrawLineBuffer(10, 40, 40, 70, #WEACT_YELLOW)
  WeAct_DrawLineBuffer(40, 40, 10, 70, #WEACT_CYAN)
  UpdateStatus("✅ Геометрические фигуры")
  
  WeAct_UpdateDisplay()
  Delay(1000)
EndProcedure

Procedure TestScrollText()
  UpdateStatus("=== ТЕСТ СКРОЛЛИНГА ТЕКСТА ===")
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Запускаем скроллинг в разных направлениях
  WeAct_StartScrollText("Scrolling Left Text", 12, #SCROLL_LEFT, 10, #WEACT_WHITE)
  UpdateStatus("✅ Скроллинг влево запущен")
  
  ; Показываем несколько кадров скроллинга
  For i = 1 To 5
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateScrollText()
    WeAct_DrawScrollText()
    WeAct_UpdateDisplay()
    Delay(200)
  Next
  
  WeAct_StopScrollText()
  UpdateStatus("✅ Скроллинг остановлен")
EndProcedure

Procedure TestImageLoading()
  UpdateStatus("=== ТЕСТ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ ===")
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Создаем тестовое изображение если его нет
  Protected testImage.s = "test_pattern.bmp"
  If FileSize(testImage) <= 0
    UpdateStatus("ℹ️ Тестовое изображение не найдено, создаем...")
    
    ; Создаем простое тестовое изображение
    Protected img = CreateImage(#PB_Any, 100, 50)
    If StartDrawing(ImageOutput(img))
      Box(0, 0, 100, 50, RGB(255, 0, 0))
      Box(20, 10, 60, 30, RGB(0, 255, 0))
      DrawText(25, 20, "TEST", RGB(255, 255, 255))
      StopDrawing()
      SaveImage(img, testImage, #PB_ImagePlugin_BMP)
      FreeImage(img)
      UpdateStatus("✅ Тестовое изображение создано")
    EndIf
  EndIf
  
  ; Пробуем загрузить изображение
  If WeAct_LoadImageCentered(testImage, 80, 40)
    UpdateStatus("✅ Изображение загружено успешно")
    WeAct_UpdateDisplay()
    Delay(1000)
  Else
    UpdateStatus("❌ Ошибка загрузки изображения")
  EndIf
EndProcedure

Procedure TestOrientation()
  UpdateStatus("=== ТЕСТ ОРИЕНТАЦИИ ===")
  
  Protected originalOrientation = WeAct_GetOrientation()
  
  ; Тестируем все ориентации
  Protected orientations.s = "Портрет, Реверс портрет, Ландшафт, Реверс ландшафт"
  Protected orientationsCount = 4
  
  For i = 0 To orientationsCount - 1
    UpdateStatus("Установка ориентации: " + StringField(orientations, i + 1, ","))
    
    If WeAct_SetOrientation(i)
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_DrawTextMedium(10, 10, "Orientation: " + Str(i), #WEACT_WHITE)
      WeAct_DrawTextSmall(10, 30, "W:" + Str(WeAct_GetDisplayWidth()), #WEACT_GREEN)
      WeAct_DrawTextSmall(10, 45, "H:" + Str(WeAct_GetDisplayHeight()), #WEACT_BLUE)
      WeAct_UpdateDisplay()
      UpdateStatus("✅ Ориентация " + Str(i) + " установлена")
      Delay(1000)
    Else
      UpdateStatus("❌ Ошибка установки ориентации " + Str(i))
    EndIf
  Next
  
  ; Возвращаем исходную ориентацию
  WeAct_SetOrientation(originalOrientation)
  UpdateStatus("✅ Возвращена исходная ориентация")
EndProcedure

Procedure TestBrightness()
  UpdateStatus("=== ТЕСТ ЯРКОСТИ ===")
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 10, "Brightness Test", #WEACT_WHITE)
  WeAct_UpdateDisplay()
  
  ; Тестируем разные уровни яркости
  Protected brightnessLevels.i = 5
  For i = 1 To brightnessLevels
    Protected brightness = i * 50
    If brightness > 255 : brightness = 255 : EndIf
    
    If WeAct_SetBrightness(brightness, 300)
      WeAct_ClearBuffer(#WEACT_BLACK)
      WeAct_DrawTextMedium(10, 10, "Brightness: " + Str(brightness), #WEACT_WHITE)
      WeAct_UpdateDisplay()
      UpdateStatus("✅ Яркость установлена: " + Str(brightness))
      Delay(500)
    Else
      UpdateStatus("❌ Ошибка установки яркости: " + Str(brightness))
    EndIf
  Next
  
  ; Возвращаем максимальную яркость
  WeAct_SetBrightness(255, 300)
  UpdateStatus("✅ Яркость возвращена к 255")
EndProcedure

Procedure TestSystemInfo()
  UpdateStatus("=== ТЕСТ СИСТЕМНОЙ ИНФОРМАЦИИ ===")
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  Protected infoY = 5
  WeAct_DrawTextSmall(5, infoY, "System Info:", #WEACT_WHITE) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "Connected: " + Str(WeAct_IsConnected()), #WEACT_GREEN) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "Width: " + Str(WeAct_GetDisplayWidth()), #WEACT_BLUE) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "Height: " + Str(WeAct_GetDisplayHeight()), #WEACT_CYAN) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "Orientation: " + Str(WeAct_GetOrientation()), #WEACT_YELLOW) : infoY + 12
  WeAct_DrawTextSmall(5, infoY, "Brightness: " + Str(WeAct_GetBrightness()), #WEACT_MAGENTA) : infoY + 12
  
  WeAct_UpdateDisplay()
  UpdateStatus("✅ Системная информация отображена")
  Delay(2000)
EndProcedure

; =============================================
; { УПРАВЛЕНИЕ ТЕСТАМИ }
; =============================================

Procedure RunTest(testNumber)
  SetGadgetState(#STR_CURRENT_TEST, testNumber)
  currentTest = testNumber
  
  Select testNumber
    Case 0
      SetGadgetText(#STR_CURRENT_TEST, "Инициализация")
      TestInitialization()
    Case 1
      SetGadgetText(#STR_CURRENT_TEST, "Базовые функции")
      TestBasicFunctions()
    Case 2
      SetGadgetText(#STR_CURRENT_TEST, "Текст")
      TestTextFunctions()
    Case 3
      SetGadgetText(#STR_CURRENT_TEST, "Графика")
      TestGraphics()
    Case 4
      SetGadgetText(#STR_CURRENT_TEST, "Скроллинг")
      TestScrollText()
    Case 5
      SetGadgetText(#STR_CURRENT_TEST, "Изображения")
      TestImageLoading()
    Case 6
      SetGadgetText(#STR_CURRENT_TEST, "Ориентация")
      TestOrientation()
    Case 7
      SetGadgetText(#STR_CURRENT_TEST, "Яркость")
      TestBrightness()
    Case 8
      SetGadgetText(#STR_CURRENT_TEST, "Системная информация")
      TestSystemInfo()
  EndSelect
  
  UpdateProgress(testNumber + 1, 9)
EndProcedure

Procedure RunAllTests()
  If Not WeAct_IsConnected()
    If Not TestInitialization()
      UpdateStatus("❌ Не удалось инициализировать дисплей!")
      ProcedureReturn
    EndIf
  EndIf
  
  testRunning = #True
  testResults = "=== РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ === " + #CRLF$
  
  DisableGadget(#BTN_RUN_ALL_TESTS, #True)
  DisableGadget(#BTN_NEXT_TEST, #True)
  DisableGadget(#BTN_PREV_TEST, #True)
  
  For i = 0 To 8
    RunTest(i)
    Delay(500) ; Пауза между тестами
  Next
  
  UpdateStatus("=== ВСЕ ТЕСТЫ ЗАВЕРШЕНЫ ===")
  
  ; Сохраняем результаты в файл
  Protected resultsFile.s = "test_results_" + FormatDate("%yyyy-%mm-%dd_%hh-%ii-%ss", Date()) + ".txt"
  If CreateFile(0, resultsFile)
    WriteString(0, testResults)
    CloseFile(0)
    UpdateStatus("✅ Результаты сохранены в: " + resultsFile)
  EndIf
  
  DisableGadget(#BTN_RUN_ALL_TESTS, #False)
  DisableGadget(#BTN_NEXT_TEST, #False)
  DisableGadget(#BTN_PREV_TEST, #False)
  testRunning = #False
EndProcedure

; =============================================
; { ОБРАБОТЧИКИ СОБЫТИЙ }
; =============================================

Procedure MainWindowEvents()
  Select Event()
    Case #PB_Event_CloseWindow
      WeAct_Cleanup()
      End
      
    Case #PB_Event_Gadget
      If testRunning : ProcedureReturn : EndIf
      
      Select EventGadget()
        Case #BTN_INIT
          TestInitialization()
          
        Case #BTN_BASIC_TEST
          RunTest(1)
          
        Case #BTN_TEXT_TEST
          RunTest(2)
          
        Case #BTN_GRAPHICS_TEST
          RunTest(3)
          
        Case #BTN_SCROLL_TEST
          RunTest(4)
          
        Case #BTN_IMAGE_TEST
          RunTest(5)
          
        Case #BTN_ORIENTATION_TEST
          RunTest(6)
          
        Case #BTN_BRIGHTNESS_TEST
          RunTest(7)
          
        Case #BTN_CLEAR
          If WeAct_IsConnected()
            WeAct_ClearBuffer(#WEACT_BLACK)
            WeAct_UpdateDisplay()
            UpdateStatus("Экран очищен")
          EndIf
          
        Case #BTN_NEXT_TEST
          If currentTest < 8
            RunTest(currentTest + 1)
          EndIf
          
        Case #BTN_PREV_TEST
          If currentTest > 0
            RunTest(currentTest - 1)
          EndIf
          
        Case #BTN_RUN_ALL_TESTS
          RunAllTests()
          
      EndSelect
  EndSelect
EndProcedure

; =============================================
; { ГЛАВНАЯ ПРОГРАММА }
; =============================================

If OpenWindow(#WINDOW_MAIN, 0, 0, 600, 700, "WeAct Display FS Test Suite", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  TextGadget(#PB_Any, 10, 10, 580, 20, "Комплексное тестирование библиотеки WeAct Display FS", #PB_Text_Center)
  
  ; Кнопки управления
  ButtonGadget(#BTN_INIT, 10, 40, 120, 30, "Инициализация")
  ButtonGadget(#BTN_BASIC_TEST, 140, 40, 120, 30, "Базовые функции")
  ButtonGadget(#BTN_TEXT_TEST, 270, 40, 120, 30, "Текст")
  ButtonGadget(#BTN_GRAPHICS_TEST, 400, 40, 120, 30, "Графика")
  
  ButtonGadget(#BTN_SCROLL_TEST, 10, 75, 120, 30, "Скроллинг")
  ButtonGadget(#BTN_IMAGE_TEST, 140, 75, 120, 30, "Изображения")
  ButtonGadget(#BTN_ORIENTATION_TEST, 270, 75, 120, 30, "Ориентация")
  ButtonGadget(#BTN_BRIGHTNESS_TEST, 400, 75, 120, 30, "Яркость")
  
  ButtonGadget(#BTN_CLEAR, 10, 110, 510, 30, "Очистить экран")
  
  ; Навигация по тестам
  TextGadget(#PB_Any, 10, 150, 100, 20, "Текущий тест:")
  StringGadget(#STR_CURRENT_TEST, 120, 150, 150, 20, "0", #PB_String_ReadOnly)
  ButtonGadget(#BTN_PREV_TEST, 280, 150, 80, 25, "← Назад")
  ButtonGadget(#BTN_NEXT_TEST, 370, 150, 80, 25, "Вперед →")
  ButtonGadget(#BTN_RUN_ALL_TESTS, 460, 150, 120, 25, "Запустить все тесты")
  
  ProgressBarGadget(#PROGRESS_TEST, 10, 180, 580, 20, 0, 100)
  
  ; Статус и логи
  TextGadget(#TXT_STATUS, 10, 210, 580, 480, "Готов к тестированию..." + #CRLF$ + #CRLF$ + 
                                              "Подключите WeAct Display FS к COM3 порту" + #CRLF$ +
                                              "и нажмите 'Инициализация' для начала тестирования.", #PB_Text_Border)
  
  ; Информация о тестах
  TextGadget(#PB_Any, 10, 695, 580, 20, 
             "Тесты: 0-Инициализация, 1-Базовые, 2-Текст, 3-Графика, 4-Скроллинг, 5-Изображения, 6-Ориентация, 7-Яркость, 8-Системная информация", 
             #PB_Text_Center)
  
  ; Начальное состояние кнопок
  DisableGadget(#BTN_NEXT_TEST, #True)
  DisableGadget(#BTN_PREV_TEST, #True)
  
  Repeat
    Event = WaitWindowEvent()
    MainWindowEvents()
  ForEver
EndIf

WeAct_Cleanup()

