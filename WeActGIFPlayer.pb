; =============================================
; WeAct Display GIF Player for Windows
; Version 1.2
; =============================================


IncludeFile "WeActDisplay.pbi"  ; Подключаем вашу библиотеку
OpenConsole()
EnableExplicit

Global verbose.i = #False

UseGIFImageDecoder()  ; Включаем декодер GIF

; Структура для кадров GIF
Structure GIF_Frame
  Image.i
  Delay.i      ; Задержка в миллисекундах
  Width.i
  Height.i
EndStructure

; Глобальные переменные
Global NewList Frames.GIF_Frame()
Global SpeedFactor.f = 1.0
Global TotalFrames.i = 0
Global CurrentFrame.i = 0
Global Running.i = #True
Global DisplayWidth.i, DisplayHeight.i
Global LoopMode.i = #False      ; Флаг зацикливания
Global LoopsCompleted.i = 0     ; Счетчик завершенных циклов

; =============================================
; { ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ }
; =============================================

Procedure GetScreenSize(*Width.Integer, *Height.Integer)
  Protected width.i, height.i
  
  ; Получаем размеры дисплея через библиотеку
  width = WeAct_GetDisplayWidth()
  height = WeAct_GetDisplayHeight()
  
  If width = 0 Or height = 0
    width = #WEACT_DISPLAY_WIDTH
    height = #WEACT_DISPLAY_HEIGHT
  EndIf
  
  *Width\i = width
  *Height\i = height
EndProcedure

Procedure.f Clamp(value.f, min.f, max.f)
  If value < min
    ProcedureReturn min
  ElseIf value > max
    ProcedureReturn max
  Else
    ProcedureReturn value
  EndIf
EndProcedure

Procedure LoadAnimatedGIF(Filename.s)
  Protected gifImage.i, frameCount.i
  Protected i.i, frameImage.i
  Protected width.i, height.i, delay.i
  
  ; Проверяем существование файла
  If FileSize(Filename) <= 0
    If verbose
      PrintN("Ошибка: Файл не найден - " + Filename)
    EndIf
    ProcedureReturn #False
  EndIf
  
  ; Загружаем GIF
  gifImage = LoadImage(#PB_Any, Filename)
  If Not gifImage
    If verbose
      PrintN("Ошибка: Не удалось загрузить GIF файл")
    EndIf
    ProcedureReturn #False
  EndIf
  
  ; Получаем количество кадров
  frameCount = ImageFrameCount(gifImage)
  
  If frameCount <= 0
    ; Если это не анимированный GIF
    If verbose
      PrintN("Предупреждение: GIF не является анимацией, загружаем как статическое изображение")
    EndIf
    
    ; Добавляем как один кадр
    AddElement(Frames())
    Frames()\Image = gifImage
    Frames()\Delay = 100  ; Задержка по умолчанию 100ms
    Frames()\Width = ImageWidth(gifImage)
    Frames()\Height = ImageHeight(gifImage)
    
    TotalFrames = 1
    
    ; Не освобождаем изображение, так как оно используется
    ProcedureReturn #True
  EndIf
  
  If verbose
    PrintN("Найдено кадров: " + Str(frameCount))
  EndIf
  
  ; Извлекаем каждый кадр
  For i = 0 To frameCount - 1
    ; Устанавливаем текущий кадр
    SetImageFrame(gifImage, i)
    
    ; Получаем задержку кадра
    delay = GetImageFrameDelay(gifImage)
    If delay <= 0
      delay = 10  ; Минимальная задержка
    EndIf
    
    ; Создаем отдельное изображение для кадра
    width = ImageWidth(gifImage)
    height = ImageHeight(gifImage)
    
    frameImage = CreateImage(#PB_Any, width, height)
    If frameImage
      If StartDrawing(ImageOutput(frameImage))
        DrawImage(ImageID(gifImage), 0, 0, width, height)
        StopDrawing()
      EndIf
      
      ; Добавляем кадр в список
      AddElement(Frames())
      Frames()\Image = frameImage
      Frames()\Delay = delay
      Frames()\Width = width
      Frames()\Height = height
      
      TotalFrames + 1
    EndIf
  Next
  
  ; Освобождаем оригинальное изображение
  FreeImage(gifImage)
  
  If TotalFrames = 0
    If verbose
      PrintN("Ошибка: Не удалось загрузить ни одного кадра")
    EndIf
    ProcedureReturn #False
  EndIf
  
  If verbose
    PrintN("Успешно загружено: " + Str(TotalFrames) + " кадров")
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure DisplayFrame(FrameIndex.i)
  Protected *frame.GIF_Frame
  Protected targetWidth.i, targetHeight.i
  Protected x.i, y.i
  Protected scaleX.f, scaleY.f, scale.f
  
  If FrameIndex < 0 Or FrameIndex >= TotalFrames
    ProcedureReturn #False
  EndIf
  
  ; Получаем кадр
  SelectElement(Frames(), FrameIndex)
  *frame = @Frames()
  
  ; Рассчитываем размеры для отображения с сохранением пропорций
  scaleX = DisplayWidth / *frame\Width
  scaleY = DisplayHeight / *frame\Height
  scale = scaleX
  
  If scaleY < scale
    scale = scaleY
  EndIf
  
  targetWidth = *frame\Width * scale
  targetHeight = *frame\Height * scale
  
  ; Центрируем изображение
  x = (DisplayWidth - targetWidth) / 2
  y = (DisplayHeight - targetHeight) / 2
  
  ; Очищаем буфер
  WeAct_ClearBuffer(#WEACT_BLACK)
  
  ; Отображаем кадр
  Protected tempImage = CreateImage(#PB_Any, targetWidth, targetHeight)
  If tempImage
    If StartDrawing(ImageOutput(tempImage))
      DrawImage(ImageID(*frame\Image), 0, 0, targetWidth, targetHeight)
      StopDrawing()
    EndIf
    
    ; Копируем пиксели в буфер дисплея
    If StartDrawing(ImageOutput(tempImage))
      Protected sourceX, sourceY, pixelColor, r, g, b
      
      For sourceY = 0 To targetHeight - 1
        For sourceX = 0 To targetWidth - 1
          pixelColor = Point(sourceX, sourceY)
          r = Red(pixelColor)
          g = Green(pixelColor)
          b = Blue(pixelColor)
          WeAct_DrawPixelBuffer(x + sourceX, y + sourceY, RGBToRGB565(r, g, b))
        Next
      Next
      StopDrawing()
    EndIf
    
    FreeImage(tempImage)
  EndIf
  
  ; Обновляем дисплей
  If Not WeAct_UpdateDisplay()
    PrintN("Ошибка при обновлении дисплея: " + WeAct_GetLastError())
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure Cleanup()
  Protected i
  
  ; Освобождаем все кадры
  ForEach Frames()
    If Frames()\Image
      FreeImage(Frames()\Image)
    EndIf
  Next
  
  ClearList(Frames())
  
  ; Закрываем дисплей
  WeAct_Cleanup()
  
  If verbose
  PrintN("Очистка завершена")
    EndIf
EndProcedure

Procedure SignalHandler()
  PrintN("Получен сигнал прерывания...")
  Running = #False
EndProcedure

Procedure ShowHelp()
  PrintN("WeAct Display GIF Player v2.0")
  PrintN("")
  PrintN("Использование: " + GetFilePart(ProgramFilename()) + " [/p:port] [/s:speed] [/l] [/v] <путь_к_gif>")
  PrintN("")
  PrintN("Обязательные параметры:")
  PrintN("  <путь_к_gif>    Путь к анимированному GIF файлу")
  PrintN("")
  PrintN("Опциональные параметры:")
  PrintN("  /p:port         Номер COM порта дисплея (по умолчанию 3)")
  PrintN("  /s:speed        Множитель скорости (0.1-5.0, по умолчанию 1.0)")
  PrintN("  /l              Зациклить воспроизведение")
  PrintN("  /v              Вывод вербозных сообщений (verbose)")
  PrintN("  /h              Показать эту справку")
  PrintN("")
  PrintN("Примеры:")
  PrintN("  " + GetFilePart(ProgramFilename()) + " " + Chr(34) + "C:\anim.gif" + Chr(34))
  PrintN("  " + GetFilePart(ProgramFilename()) + " /p:4 /s:0.5 " + Chr(34) + "C:\anim.gif" + Chr(34))
  PrintN("  " + GetFilePart(ProgramFilename()) + " /p:3 /s:2.0 /l " + Chr(34) + "C:\anim.gif" + Chr(34))
  PrintN("  " + GetFilePart(ProgramFilename()) + " /p:3 /s:1.0 /l /v " + Chr(34) + "C:\anim.gif" + Chr(34))
  PrintN("")
  PrintN("Параметры скорости:")
  PrintN("  /s:0.1 - очень медленно (10% от оригинальной)")
  PrintN("  /s:0.5 - медленно (50% от оригинальной)")
  PrintN("  /s:1.0 - нормальная скорость (по умолчанию)")
  PrintN("  /s:2.0 - быстро (в 2 раза быстрее)")
  PrintN("  /s:5.0 - очень быстро (в 5 раз быстрее)")
  PrintN("")
  PrintN("Управление:")
  PrintN("  Ctrl+C - остановить воспроизведение и выйти")
EndProcedure

; =============================================
; { ОСНОВНАЯ ПРОГРАММА }
; =============================================


Procedure Main()
  Protected gifFile.s = "", port.s = "COM3"
  Protected startTime.i, elapsed.i, delay.i
  Protected frameTime.i, fps.i = 0, framesDisplayed.i = 0
  Protected i, param.s 
  
  ; Проверяем аргументы командной строки
  If CountProgramParameters() < 1
    ShowHelp()
    End 1
  EndIf
  
  ; Обрабатываем все параметры
  For i = 0 To CountProgramParameters() - 1
    param = ProgramParameter(i)
    
    ; Проверяем ключи параметров
    If Left(param, 3) = "/p:" Or Left(param, 3) = "-p:"
      port = "COM" + Mid(param, 4)
      
    ElseIf Left(param, 3) = "/s:" Or Left(param, 3) = "-s:"
      SpeedFactor = ValF(Mid(param, 4))
      SpeedFactor = Clamp(SpeedFactor, 0.1, 5.0)
      
    ElseIf param = "/l" Or param = "-l" Or param = "/loop" Or param = "-loop"
      LoopMode = #True
      
    ElseIf param = "/v" Or param = "-v" Or param = "/verbose" Or param = "-verbose"
      verbose = #True
      
    ElseIf param = "/h" Or param = "-h" Or param = "/help" Or param = "-help" Or param = "/?"
      ShowHelp()
      End 0
      
    Else
      ; Если это не ключ, то это должно быть имя файла
      If gifFile = ""
        gifFile = param
      Else
        If verbose
          PrintN("Ошибка: Неожиданный параметр - " + param)
        EndIf
        ShowHelp()
        End 1
      EndIf
    EndIf
  Next
  
  ; Проверяем, указан ли файл GIF
  If gifFile = ""
    If verbose
      PrintN("Ошибка: Не указан файл GIF")
    EndIf
    ShowHelp()
    End 1
  EndIf
  
  ; Проверяем существование файла
  If FileSize(gifFile) <= 0
    If verbose
      PrintN("Ошибка: Файл не найден - " + gifFile)
    EndIf
    End 1
  EndIf
  
  ; Выводим информацию о параметрах только в verbose режиме
  If verbose
    Protected modeName.s
    If LoopMode
      modeName = "ЗАЦИКЛЕНО"
    Else
      modeName = "ОДИН ПРОКАТ"
    EndIf
    
    PrintN("========================================")
    PrintN("WeAct Display GIF Player v2.0")
    PrintN("========================================")
    PrintN("Файл GIF: " + gifFile)
    PrintN("Скорость: " + StrF(SpeedFactor, 1) + "x")
    PrintN("COM порт: " + port)
    PrintN("Режим: " + modeName)
    PrintN("========================================")
  EndIf
  
  ; Регистрируем обработчик Ctrl+C
  OnErrorCall(@SignalHandler())
  
  ; Загружаем GIF
  If verbose
    PrintN("Загрузка GIF файла...")
  EndIf
  
  If Not LoadAnimatedGIF(gifFile)
    End 1
  EndIf
  
  ; Инициализируем дисплей
  If verbose
    PrintN("Инициализация дисплея на порту " + port + "...")
  EndIf
  
  If Not WeAct_Init(port)
    If verbose
      PrintN("Ошибка: Не удалось инициализировать дисплея: " + WeAct_GetLastError())
    EndIf
    Cleanup()
    End 1
  EndIf
  
  ; Получаем размеры дисплея
  GetScreenSize(@DisplayWidth, @DisplayHeight)
  
  If verbose
    PrintN("Размер дисплея: " + Str(DisplayWidth) + "x" + Str(DisplayHeight))
  EndIf
  
  ; Устанавливаем максимальную яркость
  WeAct_SetBrightness(255, 100)
  
  If verbose
    PrintN("")
    PrintN("Воспроизведение анимации...")
    PrintN("Нажмите Ctrl+C для выхода")
    PrintN("========================================")
  EndIf
  
  ; Основной цикл воспроизведения
  startTime = ElapsedMilliseconds()
  
  While Running
    ; Отображаем текущий кадр
    If Not DisplayFrame(CurrentFrame)
      If verbose
        PrintN("Ошибка при отображении кадра " + Str(CurrentFrame))
      EndIf
      Break
    EndIf
    
    ; Выводим информацию о кадре только в verbose режиме
    framesDisplayed + 1
    elapsed = ElapsedMilliseconds() - startTime
    
    If verbose And elapsed >= 1000
      fps = framesDisplayed
      SelectElement(Frames(), CurrentFrame)
      PrintN("Кадр: " + Str(CurrentFrame+1) + "/" + Str(TotalFrames) + " | FPS: " + Str(fps) + " | Цикл: " + Str(LoopsCompleted+1) + " | Задержка: " + Str(Frames()\Delay) + "ms")
      framesDisplayed = 0
      startTime = ElapsedMilliseconds()
    EndIf
    
    ; Получаем задержку для текущего кадра
    SelectElement(Frames(), CurrentFrame)
    delay = Frames()\Delay
    If delay = 0 : delay = 100 : EndIf
    
    ; Применяем множитель скорости
    delay = Int(delay / SpeedFactor)
    If delay < 10 : delay = 10 : EndIf
    
    ; Ждем перед следующим кадром
    frameTime = ElapsedMilliseconds()
    While ElapsedMilliseconds() - frameTime < delay And Running
      Delay(1)
    Wend
    
    ; Переходим к следующему кадру
    CurrentFrame + 1
    
    ; Проверяем, достигли ли конца анимации
    If CurrentFrame >= TotalFrames
      If LoopMode
        ; Зацикливаем анимацию
        CurrentFrame = 0
        LoopsCompleted + 1
        If verbose
          PrintN("──────── Начало нового цикла (" + Str(LoopsCompleted+1) + ") ────────")
        EndIf
      Else
        ; Останавливаем воспроизведение после одного прохода
        Running = #False
      EndIf
    EndIf
  Wend
  
  ; Завершение
  Cleanup()
  
  If verbose
    PrintN("Программа завершена")
  EndIf
  
  End 0
EndProcedure

; Точка входа
Main()
; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 15
; Folding = --
; EnableXP
; Executable = WeActGIFPlayer.exe
; IDE Options = PureBasic 6.21 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 254
; FirstLine = 216
; Folding = --
; EnableXP
; Executable = WeActGIFPlayer.exe
