; =============================================
; ПОЛНЫЙ ТЕСТ БИБЛИОТЕКИ WeAct DISPLAY 
; Стабильная версия со всеми функциями
; =============================================

XIncludeFile "WeActDisplay.pbi"

; =============================================
; НАСТРОЙКИ
; =============================================
#COM_PORT = "COM8"
#TEST_IMAGE = "test_image.jpg"

; =============================================
; ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
; =============================================
Global DisplayConnected.i = #False
Global AutoTestRunning.i = #False
Global TestPhase.i = 0

; =============================================
; СТАБИЛЬНЫЕ ТЕСТОВЫЕ ФУНКЦИИ
; =============================================

Procedure WeAct_SafeWait(ms.i)
  Protected startTime = ElapsedMilliseconds()
  While ElapsedMilliseconds() - startTime < ms
    Delay(1)
    If WindowEvent() = #PB_Event_CloseWindow
      ProcedureReturn #False
    EndIf
  Wend
  ProcedureReturn #True
EndProcedure

Procedure TestClearScreen()
  If DisplayConnected
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateDisplay()
  EndIf
EndProcedure

Procedure TestBasicGraphics()
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 2, "1. Базовая графика", #WEACT_YELLOW)
  
  ; Пиксели
  WeAct_DrawTextSmall(10, 20, "Пиксели:", #WEACT_WHITE)
  Protected i
  For i = 0 To 9
    WeAct_DrawPixelBuffer(70 + i*2, 20, #WEACT_RED)
    WeAct_DrawPixelBuffer(70 + i*2, 22, #WEACT_GREEN) 
    WeAct_DrawPixelBuffer(70 + i*2, 24, #WEACT_BLUE)
  Next
  
  ; Линии
  WeAct_DrawTextSmall(10, 30, "Линии:", #WEACT_WHITE)
  WeAct_DrawLineBuffer(60, 30, 150, 30, #WEACT_RED)
  WeAct_DrawLineBuffer(60, 35, 150, 40, #WEACT_GREEN)
  WeAct_DrawLineBuffer(60, 45, 150, 35, #WEACT_BLUE)
  
  ; Прямоугольники
  WeAct_DrawTextSmall(10, 50, "Прямоуг.:", #WEACT_WHITE)
  WeAct_DrawRectangleBuffer(80, 50, 30, 15, #WEACT_CYAN, #True)
  WeAct_DrawRectangleBuffer(115, 50, 30, 15, #WEACT_MAGENTA, #False)
  
  WeAct_UpdateDisplay()
EndProcedure

Procedure TestTextRendering()
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 2, "2. Рендеринг текста", #WEACT_YELLOW)
  
  WeAct_DrawTextSmall(10, 20, "Маленький шрифт (8pt)", #WEACT_GREEN)
  WeAct_DrawTextMedium(10, 35, "Средний шрифт (12pt)", #WEACT_CYAN) 
  WeAct_DrawTextLarge(10, 55, "Большой шрифт (16pt)", #WEACT_MAGENTA)
  
  WeAct_UpdateDisplay()
EndProcedure

Procedure TestWrappedText()
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 2, "3. Перенос текста", #WEACT_YELLOW)
  
  WeAct_DrawWrappedTextAutoSize(10, 15, 140, 30, "Это демонстрация работы функции переноса текста. Длинные предложения автоматически разбиваются на несколько строк.", #WEACT_WHITE, "Arial")
  
  WeAct_DrawTextSmall(10, 50, "Фикс. размер:", #WEACT_GREEN)
  WeAct_DrawWrappedTextFixed(10, 60, 140, 15, "Короткий текст", #WEACT_CYAN, 10, "Arial")
  
  WeAct_UpdateDisplay()
EndProcedure

Procedure TestColorPalette()
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 2, "4. Цветовая палитра", #WEACT_YELLOW)
  
  WeAct_DrawRectangleBuffer(10, 20, 140, 8, #WEACT_RED, #True)
  WeAct_DrawRectangleBuffer(10, 30, 140, 8, #WEACT_GREEN, #True)
  WeAct_DrawRectangleBuffer(10, 40, 140, 8, #WEACT_BLUE, #True)
  WeAct_DrawRectangleBuffer(10, 50, 140, 8, #WEACT_CYAN, #True)
  WeAct_DrawRectangleBuffer(10, 60, 140, 8, #WEACT_MAGENTA, #True)
  WeAct_DrawRectangleBuffer(10, 70, 140, 8, #WEACT_YELLOW, #True)
  
  WeAct_UpdateDisplay()
EndProcedure

Procedure TestImageLoading()
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 2, "5. Загрузка изображений", #WEACT_YELLOW)
  
  If FileSize(#TEST_IMAGE) > 0
    WeAct_DrawTextSmall(10, 20, "Загрузка...", #WEACT_GREEN)
    WeAct_UpdateDisplay()
    
    If WeAct_LoadImageCentered(#TEST_IMAGE, 120, 50)
      WeAct_DrawTextSmall(10, 72, "Успешно!", #WEACT_CYAN)
    Else
      WeAct_DrawTextSmall(10, 72, "Ошибка загрузки", #WEACT_RED)
    EndIf
  Else
    WeAct_DrawTextSmall(10, 20, "Файл не найден:", #WEACT_RED)
    WeAct_DrawTextSmall(10, 35, #TEST_IMAGE, #WEACT_RED)
    WeAct_DrawTextSmall(10, 50, "Создайте тестовый файл", #WEACT_YELLOW)
  EndIf
  
  WeAct_UpdateDisplay()
EndProcedure

Procedure TestOrientation()
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  Protected currentOrientation = WeAct_GetOrientation()
  Protected newOrientation = (currentOrientation + 1) % 4
  
  WeAct_SetOrientation(newOrientation)
  WeAct_SafeWait(300)
  
  WeAct_ClearBuffer(#WEACT_BLACK)
   ; Используем актуальные размеры
  Protected width = WeAct_GetDisplayWidth()
  Protected height = WeAct_GetDisplayHeight()
  
  ; Центрируем текст относительно новых размеров
  Protected textWidth = WeAct_GetTextWidth("Ориентация", 12, "Arial")
  Protected x = (width - textWidth) / 2
  WeAct_DrawTextMedium(10, 2, "6. Ориентация", #WEACT_YELLOW)
  
  Select newOrientation
    Case #WEACT_PORTRAIT
      WeAct_DrawTextSmall(10, 20, "Портретная", #WEACT_GREEN)
      WeAct_DrawTextLarge(70, 40, "↑", #WEACT_CYAN)
    Case #WEACT_REVERSE_PORTRAIT
      WeAct_DrawTextSmall(10, 20, "Обратная портрет.", #WEACT_GREEN)
      WeAct_DrawTextLarge(70, 40, "↓", #WEACT_CYAN)
    Case #WEACT_LANDSCAPE
      WeAct_DrawTextSmall(10, 20, "Альбомная", #WEACT_GREEN)
      WeAct_DrawTextLarge(70, 40, "→", #WEACT_CYAN)
    Case #WEACT_REVERSE_LANDSCAPE
      WeAct_DrawTextSmall(10, 20, "Обратная альбом.", #WEACT_GREEN)
      WeAct_DrawTextLarge(70, 40, "←", #WEACT_CYAN)
  EndSelect
  
  WeAct_DrawTextSmall(10, 65, "Ориент.: " + Str(newOrientation), #WEACT_WHITE)
  WeAct_UpdateDisplay()
EndProcedure

Procedure TestBrightness()
  Static brightnessLevel = 150
  
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  WeAct_SetBrightness(brightnessLevel, 200)
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  Protected w = WeAct_GetDisplayWidth()
  Protected h = WeAct_GetDisplayHeight()
  
  WeAct_DrawTextMedium(10, 5, "7. Управление яркостью", #WEACT_YELLOW)
  
  Protected barWidth = w - 20
  Protected barHeight = 10
  Protected barX = 10
  Protected barY = h / 2 - 5
  
  WeAct_DrawRectangleBuffer(barX, barY, barWidth, barHeight, #WEACT_WHITE, #False)
  WeAct_DrawRectangleBuffer(barX, barY, brightnessLevel * barWidth / 255, barHeight, #WEACT_CYAN, #True)
  
  WeAct_DrawTextSmall(barX, barY + barHeight + 5, "Яркость: " + Str(brightnessLevel), #WEACT_GREEN)
  WeAct_UpdateDisplay()
  
  brightnessLevel + 50
  If brightnessLevel > 255 : brightnessLevel = 50 : EndIf
EndProcedure

Procedure TestAnimation()
  Static frame = 0
  frame + 1
  
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(10, 2, "8. Анимация", #WEACT_YELLOW)
  
  Protected centerX = WeAct_GetDisplayWidth() / 2
  Protected centerY = WeAct_GetDisplayHeight() / 2
  Protected radius = 15
  Protected angle1 = frame * 0.2
  Protected angle2 = frame * 0.2 + 2.0
  Protected angle3 = frame * 0.2 + 4.0
  
  Protected x1 = centerX + radius * Cos(angle1)
  Protected y1 = centerY + radius * Sin(angle1)
  Protected x2 = centerX + radius * Cos(angle2)
  Protected y2 = centerY + radius * Sin(angle2)
  Protected x3 = centerX + radius * Cos(angle3)
  Protected y3 = centerY + radius * Sin(angle3)
  
  WeAct_DrawLineBuffer(x1, y1, x2, y2, #WEACT_RED)
  WeAct_DrawLineBuffer(x2, y2, x3, y3, #WEACT_GREEN)
  WeAct_DrawLineBuffer(x3, y3, x1, y1, #WEACT_BLUE)
  
  WeAct_DrawTextSmall(10, 65, "Кадр: " + Str(frame), #WEACT_WHITE)
  WeAct_UpdateDisplay()
EndProcedure

Procedure TestScrollText()
  If Not DisplayConnected : ProcedureReturn : EndIf
  
  Static direction = 0
  WeAct_StopScrollText()
  
  Select direction
    Case 0
      WeAct_ScrollTextLeft("← Скроллируемый текст влево", 25, 12, #WEACT_GREEN)
    Case 1
      WeAct_ScrollTextRight("Скроллируемый текст вправо →", 25, 12, #WEACT_CYAN)
    Case 2
      WeAct_ScrollTextUp("Скроллируемый текст вверх", 15, 14, #WEACT_MAGENTA)
    Case 3
      WeAct_ScrollTextDown("Скроллируемый текст вниз", 15, 14, #WEACT_YELLOW)
  EndSelect
  
  Protected startTime = ElapsedMilliseconds()
  While ElapsedMilliseconds() - startTime < 2500
    WeAct_ClearBuffer(#WEACT_BLACK)
    WeAct_UpdateScrollText()
    WeAct_DrawScrollText()
    
    ; Информация о направлении
    Select direction
      Case 0: WeAct_DrawTextSmall(10, 2, "← СКРОЛЛ ВЛЕВО", #WEACT_CYAN)
      Case 1: WeAct_DrawTextSmall(10, 2, "→ СКРОЛЛ ВПРАВО", #WEACT_GREEN)
      Case 2: WeAct_DrawTextSmall(10, 2, "↑ СКРОЛЛ ВВЕРХ", #WEACT_YELLOW)
      Case 3: WeAct_DrawTextSmall(10, 2, "↓ СКРОЛЛ ВНИЗ", #WEACT_RED)
    EndSelect
    
    WeAct_UpdateDisplay()
    Delay(30)
  Wend
  
  WeAct_StopScrollText()
  direction = (direction + 1) % 4
EndProcedure

; =============================================
; ГЛАВНАЯ ПРОГРАММА
; =============================================

OpenWindow(0, 100, 100, 450, 500, "WeAct Display - Полный тест", #PB_Window_SystemMenu)

TextGadget(0, 20, 20, 410, 30, "Полный тест библиотеки WeAct Display", #PB_Text_Center)
TextGadget(1, 20, 50, 410, 20, "Подключение к " + #COM_PORT + "...", #PB_Text_Center)

; Инициализация дисплея
If WeAct_Init(#COM_PORT)
  DisplayConnected = #True
  SetGadgetText(1, "✓ Подключено к " + #COM_PORT + " | 160x80")
  
  ; Начальное сообщение
  WeAct_ClearBuffer(#WEACT_BLACK)
  WeAct_DrawTextMedium(40, 30, "ГОТОВ", #WEACT_GREEN)
  WeAct_UpdateDisplay()
Else
  SetGadgetText(1, "✗ Ошибка подключения к " + #COM_PORT)
  DisplayConnected = #False
EndIf

; Интерфейс
ButtonGadget(2, 50, 80, 350, 30, "🧹 Очистить экран")
DisableGadget(2, 1 - DisplayConnected)

TextGadget(3, 20, 120, 410, 20, "Основные функции:", #PB_Text_Center)

ButtonGadget(4, 50, 150, 170, 30, "📊 Графика")
DisableGadget(4, 1 - DisplayConnected)
ButtonGadget(5, 230, 150, 170, 30, "📝 Текст")
DisableGadget(5, 1 - DisplayConnected)

ButtonGadget(6, 50, 190, 170, 30, "🌀 Перенос текста")
DisableGadget(6, 1 - DisplayConnected)
ButtonGadget(7, 230, 190, 170, 30, "🎨 Цвета")
DisableGadget(7, 1 - DisplayConnected)

ButtonGadget(8, 50, 230, 170, 30, "🖼️ Изображения")
DisableGadget(8, 1 - DisplayConnected)
ButtonGadget(9, 230, 230, 170, 30, "🔄 Ориентация")
DisableGadget(9, 1 - DisplayConnected)

TextGadget(10, 20, 270, 410, 20, "Дополнительные функции:", #PB_Text_Center)

ButtonGadget(11, 50, 300, 170, 30, "💡 Яркость")
DisableGadget(11, 1 - DisplayConnected)
ButtonGadget(12, 230, 300, 170, 30, "🎬 Анимация")
DisableGadget(12, 1 - DisplayConnected)

ButtonGadget(13, 50, 340, 170, 30, "🌀 Скроллинг")
DisableGadget(13, 1 - DisplayConnected)
ButtonGadget(14, 230, 340, 170, 30, "⚡ Производит.")
DisableGadget(14, 1 - DisplayConnected)

ButtonGadget(15, 50, 390, 350, 30, "▶ АВТОТЕСТ (9 функций)")
DisableGadget(15, 1 - DisplayConnected)

ButtonGadget(16, 50, 430, 350, 30, "❌ Выход")

; Таймер для автотеста
AddWindowTimer(0, 1, 2000)

Repeat
  Event = WaitWindowEvent()
  
  Select Event
    Case #PB_Event_Timer
      If EventTimer() = 1 And AutoTestRunning And DisplayConnected
        Select TestPhase
          Case 0: TestBasicGraphics()
          Case 1: TestTextRendering()
          Case 2: TestWrappedText()
          Case 3: TestColorPalette()
          Case 4: TestImageLoading()
          Case 5: TestOrientation()
          Case 6: TestBrightness()
          Case 7: TestAnimation()
          Case 8: TestScrollText()
          Case 9:
            RemoveWindowTimer(0, 1)
            AutoTestRunning = #False
            TestPhase = 0
            TestClearScreen()
            WeAct_DrawTextMedium(30, 30, "ТЕСТ ЗАВЕРШЕН", #WEACT_GREEN)
            WeAct_UpdateDisplay()
            MessageRequester("Авто-тест", "Все 9 функций протестированы успешно!")
        EndSelect
        If AutoTestRunning : TestPhase + 1 : EndIf
      EndIf
      
    Case #PB_Event_Gadget
      Select EventGadget()
        Case 2: TestClearScreen()
        Case 4: TestBasicGraphics()
        Case 5: TestTextRendering()
        Case 6: TestWrappedText()
        Case 7: TestColorPalette()
        Case 8: TestImageLoading()
        Case 9: TestOrientation()
        Case 11: TestBrightness()
        Case 12: TestAnimation()
        Case 13: TestScrollText()
        Case 14: ; Производительность
          If DisplayConnected
            startTime = ElapsedMilliseconds()
            For i = 0 To 49
              WeAct_DrawRectangleBuffer(Random(150), Random(70), 6, 3, RGBToRGB565(Random(255), Random(255), Random(255)), #True)
            Next
            endTime = ElapsedMilliseconds()
            WeAct_ClearBuffer(#WEACT_BLACK)
            WeAct_DrawTextMedium(10, 2, "Производительность", #WEACT_YELLOW)
            WeAct_DrawTextSmall(10, 25, "50 прямоугольников:", #WEACT_WHITE)
            WeAct_DrawTextSmall(10, 40, Str(endTime - startTime) + " мс", #WEACT_GREEN)
            WeAct_UpdateDisplay()
          EndIf
        Case 15: ; Автотест
          If Not AutoTestRunning
            AutoTestRunning = #True
            TestPhase = 0
          EndIf
        Case 16: Break
      EndSelect
      
    Case #PB_Event_CloseWindow
      Break
  EndSelect
ForEver

If DisplayConnected
  WeAct_Cleanup()
EndIf

CloseWindow(0)
; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 154
; FirstLine = 138
; Folding = --

; EnableXP
