# WeAct Display FS Test Suite

## English

### Overview
Professional test application for WeAct 0.96" USB display (160x80 pixels). The program allows you to thoroughly test all display functions through a convenient graphical interface.

### Features
- **Complete Function Testing**: 10 different tests covering all display capabilities
- **Bilingual Interface**: English and Russian language support
- **Non-blocking Execution**: Tests run without freezing the interface
- **Automatic COM Port Detection**: Scans and lists available serial ports
- **Test Logging**: Detailed log with timestamps and results
- **Individual Test Execution**: Run specific tests or all at once
- **Progress Tracking**: Visual progress indicator during test execution

### Supported Tests
1. **Initialization** - Connection and basic information
2. **Basic Functions** - Pixels, lines, rectangles, circles
3. **Text Rendering** - Different font sizes with Cyrillic support
4. **Graphics** - Grids, colored borders, coordinate system
5. **Smooth Scrolling** - Animated text scrolling
6. **Image Loading** - BMP image display with scaling
7. **Orientation** - Portrait, landscape, and rotation modes
8. **Brightness** - Brightness control with smooth transitions
9. **New Features** - Progress bars and graphs
10. **System Information** - Display parameters and status

### Requirements
- WeAct 0.96" USB Display FS
- PureBasic 6.20 or higher
- Windows OS (tested on Windows 10/11)

### Installation
1. Download `WeAct_Test.pb` and `WeActDisplay.pbi` files
2. Open `WeAct_Test.pb` in PureBasic IDE
3. Connect your WeAct display via USB
4. Compile and run the program

### Usage
1. **Select COM Port**: Click "Refresh" to detect available ports, select your display's port
2. **Initialize**: Click "Initialize Display" to establish connection
3. **Run Tests**:
   - "Run All Tests" - Execute all 10 tests sequentially
   - Individual buttons - Run specific tests only
4. **Monitor Progress**: Watch the progress bar and log messages
5. **View Results**: Check the log for detailed test results

### Controls
- **Refresh Ports** - Rescan COM ports
- **Initialize Display** - Connect to selected port
- **Run All Tests** - Execute complete test suite
- **Stop Tests** - Abort current test execution
- **Clear Display** - Reset display to black screen
- **Individual Test Buttons** - Run specific functionality tests

### Troubleshooting
- **No COM ports detected**: Ensure display is connected and drivers are installed
- **Connection failed**: Check if another program is using the COM port
- **Tests fail**: Verify display is properly connected and powered

### File Structure
- `WeAct_Test.pb` - Main application with GUI
- `WeActDisplay.pbi` - Display communication library
- `test_pattern.bmp` - Test image (generated automatically if missing)
- `test_results_*.txt` - Automatic test result logs

---

## Русский

### Обзор
Профессиональное тестовое приложение для USB-дисплея WeAct 0.96" (160x80 пикселей). Программа позволяет тщательно протестировать все функции дисплея через удобный графический интерфейс.

### Возможности
- **Полное тестирование функций**: 10 различных тестов, охватывающих все возможности дисплея
- **Двуязычный интерфейс**: Поддержка английского и русского языков
- **Неблокирующее выполнение**: Тесты выполняются без зависания интерфейса
- **Автоматическое обнаружение COM-портов**: Сканирование и список доступных портов
- **Ведение журнала тестов**: Подробный лог с временными метками и результатами
- **Индивидуальное выполнение тестов**: Запуск отдельных тестов или всех сразу
- **Отслеживание прогресса**: Визуальный индикатор выполнения тестов

### Поддерживаемые тесты
1. **Инициализация** - Подключение и основная информация
2. **Базовые функции** - Пиксели, линии, прямоугольники, круги
3. **Вывод текста** - Разные размеры шрифтов с поддержкой кириллицы
4. **Графика** - Сетки, цветные границы, система координат
5. **Плавный скроллинг** - Анимированная прокрутка текста
6. **Загрузка изображений** - Отображение BMP-изображений с масштабированием
7. **Ориентация** - Портретный, ландшафтный и поворотный режимы
8. **Яркость** - Управление яркостью с плавными переходами
9. **Новые функции** - Прогресс-бары и графики
10. **Системная информация** - Параметры и статус дисплея

### Требования
- Дисплей WeAct 0.96" USB Display FS
- PureBasic 6.20 или выше
- ОС Windows (тестировалось на Windows 10/11)

### Установка
1. Скачайте файлы `WeAct_Test.pb` и `WeActDisplay.pbi`
2. Откройте `WeAct_Test.pb` в среде PureBasic IDE
3. Подключите дисплей WeAct через USB
4. Скомпилируйте и запустите программу

### Использование
1. **Выберите COM-порт**: Нажмите "Обновить" для обнаружения портов, выберите порт дисплея
2. **Инициализация**: Нажмите "Инициализация дисплея" для установки соединения
3. **Запуск тестов**:
   - "Запустить все" - Выполнить все 10 тестов последовательно
   - Отдельные кнопки - Запустить только конкретные тесты
4. **Отслеживание прогресса**: Следите за прогресс-баром и сообщениями в логе
5. **Просмотр результатов**: Проверьте лог для детальных результатов тестов

### Управление
- **Обновить порты** - Повторное сканирование COM-портов
- **Инициализация дисплея** - Подключение к выбранному порту
- **Запустить все** - Выполнить полный набор тестов
- **Остановить** - Прервать выполнение текущих тестов
- **Очистить дисплей** - Сбросить дисплей к черному экрану
- **Кнопки отдельных тестов** - Запуск тестов конкретных функций

### Решение проблем
- **Не обнаружены COM-порты**: Убедитесь, что дисплей подключен и драйверы установлены
- **Ошибка подключения**: Проверьте, не использует ли другой программой COM-порт
- **Тесты завершаются ошибкой**: Убедитесь в правильном подключении и питании дисплея

### Структура файлов
- `WeAct_Test.pb` - Основное приложение с графическим интерфейсом
- `WeActDisplay.pbi` - Библиотека для работы с дисплеем
- `test_pattern.bmp` - Тестовое изображение (создается автоматически при отсутствии)
- `test_results_*.txt` - Автоматические журналы результатов тестов
