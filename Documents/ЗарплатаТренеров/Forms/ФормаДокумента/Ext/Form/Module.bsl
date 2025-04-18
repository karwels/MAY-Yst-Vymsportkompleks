﻿&НаКлиенте
Процедура Загрузить(Команда)
    Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
    Диалог.Заголовок = "Выберите файл для загрузки";
    Диалог.Фильтр = "Текстовые файлы (*.txt)|*.txt|CSV файлы (*.csv)|*.csv|Файлы Excel (*.xls)|*.xls|Файлы Excel (*.xlsx)|*.xlsx";
    
    Если Диалог.Выбрать() Тогда
        ВыбранныйФайл = Диалог.ПолноеИмяФайла;
        
        Попытка
            Расширение = НРег(Прав(ВыбранныйФайл, 4));
            
            Если Расширение = ".txt" Тогда
                Данные = ЗагрузитьИзTXT(ВыбранныйФайл);
            ИначеЕсли Расширение = ".csv" Тогда
                Данные = ЗагрузитьИзCSV(ВыбранныйФайл);
            ИначеЕсли Расширение = ".xls" Или Расширение = "xlsx" Тогда
                Данные = ЗагрузитьИзExcel(ВыбранныйФайл);
            Иначе
                Сообщить("Неподдерживаемый формат файла.");
                Возврат;
            КонецЕсли;
            
            ОбработатьДанныеНаСервере(Данные);
        Исключение
            Сообщить("Ошибка: " + ОписаниеОшибки());
        КонецПопытки;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ЗагрузитьИзTXT(Путь)
    ЧтениеТекста = Новый ЧтениеТекста(Путь);
    Данные = ЧтениеТекста.Прочитать();
    ЧтениеТекста.Закрыть();
    Возврат Данные;
КонецФункции

&НаКлиенте
Функция ЗагрузитьИзCSV(Путь)
    ЧтениеТекста = Новый ЧтениеТекста(Путь);
    Данные = ЧтениеТекста.Прочитать();
    ЧтениеТекста.Закрыть();
    Возврат Данные;
КонецФункции

&НаКлиенте
Функция ЗагрузитьИзExcel(Путь)
    Данные = "";
    
    Попытка
        Excel = Новый COMОбъект("Excel.Application");
        Excel.Visible = Ложь;
        Книга = Excel.Workbooks.Open(Путь);
        Лист = Книга.Sheets(1);
        
        КоличествоСтрок = Лист.UsedRange.Rows.Count;
        КоличествоКолонок = Лист.UsedRange.Columns.Count;
        
        Для Строка = 1 По КоличествоСтрок Цикл
            СтрокаДанных = "";
            Для Колонка = 1 По КоличествоКолонок Цикл
                ЗначениеЯчейки = Лист.Cells(Строка, Колонка).Text;
                СтрокаДанных = СтрокаДанных + ?(СтрокаДанных = "", "", ";") + СокрЛП(ЗначениеЯчейки);
            КонецЦикла;
            Данные = Данные + ?(Данные = "", "", Символы.ПС) + СтрокаДанных;
        КонецЦикла;
        
        Книга.Close(Ложь);
        Excel.Quit();
    Исключение
        Сообщить("Ошибка при чтении Excel-файла: " + ОписаниеОшибки());
    КонецПопытки;
    
    Возврат Данные;
КонецФункции

&НаСервере
Функция мПривестиКДате(Представление, ТипРеквизита, Примечание = "")
    Результат = ТипРеквизита.ПривестиЗначение(Представление);
    Если Результат = '00010101' Тогда
        МассивЧастей = ПолучитьЧастиПредставленияДаты(Представление);
        Если ТипРеквизита.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.Время Тогда
            Попытка
                Если МассивЧастей.Количество() = 5 Тогда
                    День = МассивЧастей[0];
                    Месяц = МассивЧастей[1];
                    Год = МассивЧастей[2];
                    Час = МассивЧастей[3];
                    Минута = МассивЧастей[4];
                    Результат = Дата(Год, Месяц, День, Час, Минута, 0);
                ИначеЕсли МассивЧастей.Количество() = 3 Тогда
                    День = МассивЧастей[0];
                    Месяц = МассивЧастей[1];
                    Год = МассивЧастей[2];
                    Результат = Дата(Год, Месяц, День);
                КонецЕсли;
            Исключение
                Примечание = "Неправильный формат даты";
            КонецПопытки;
        ИначеЕсли МассивЧастей.Количество() = 3 или МассивЧастей.Количество() = 5 Тогда
            Если МассивЧастей[0] >= 1000 Тогда
                Временно = МассивЧастей[0];
                МассивЧастей[0] = МассивЧастей[2];
                МассивЧастей[2] = Временно;
            КонецЕсли;
            Если МассивЧастей[2] < 100 Тогда
                МассивЧастей[2] = МассивЧастей[2] + ?(МассивЧастей[2] < 30, 2000, 1900);
            КонецЕсли;
            Попытка
                Если МассивЧастей.Количество() = 3 или ТипРеквизита.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.Дата Тогда
                    Результат = Дата(МассивЧастей[2], МассивЧастей[1], МассивЧастей[0]);
                Иначе
                    Результат = Дата(МассивЧастей[2], МассивЧастей[1], МассивЧастей[0], МассивЧастей[3], МассивЧастей[4], 0);
                КонецЕсли;
            Исключение
                Примечание = "Неправильный формат даты";
            КонецПопытки;
        КонецЕсли;
    КонецЕсли;
    Возврат Результат;
КонецФункции

&НаСервере
Функция ПолучитьЧастиПредставленияДаты(ЗНАЧ Представление)
    МассивЧастей = Новый Массив;
    НачалоЦифры = 0;
    Для к = 1 По СтрДлина(Представление) Цикл
        Символ = Сред(Представление, к, 1);
        ЭтоЦифра = Символ >= "0" и Символ <= "9";
        Если ЭтоЦифра Тогда
            Если НачалоЦифры = 0 Тогда
                НачалоЦифры = к;
            КонецЕсли;
        Иначе
            Если Не НачалоЦифры = 0 Тогда
                МассивЧастей.Добавить(Число(Сред(Представление, НачалоЦифры, к - НачалоЦифры)));
            КонецЕсли;
            НачалоЦифры = 0;
        КонецЕсли;
    КонецЦикла;
    Если Не НачалоЦифры = 0 Тогда
        МассивЧастей.Добавить(Число(Сред(Представление, НачалоЦифры)));
    КонецЕсли;
    Возврат МассивЧастей;
КонецФункции

&НаСервере
Процедура ОбработатьДанныеНаСервере(Данные)
    Строки = СтрРазделить(Данные, Символы.ПС);
    ПропуститьЗаголовок = Истина;
    
    Для Сч = 0 По Строки.Количество() - 1 Цикл
        Строка = Строки[Сч];
        
        Если ПропуститьЗаголовок Тогда
            ПропуститьЗаголовок = Ложь;
            Продолжить;
        КонецЕсли;
        
        Если Строка = "" ИЛИ СтрЗаменить(Строка, " ", "") = "" Тогда
            Продолжить;
        КонецЕсли;
        
        Колонки = СтрРазделить(Строка, ";");
        
        Если Колонки.Количество() = 8 Тогда
            Попытка
                Номер = СокрЛП(Колонки[0]);
                
                ДатаСтрока = СокрЛП(Колонки[1]);
                Дата = мПривестиКДате(ДатаСтрока, Новый ОписаниеТипов("Дата"));
                Если Дата = '00010101' Тогда
                    Сообщить("Ошибка: значение 'Дата' не является корректной датой в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                КонецПериодаСтрока = СокрЛП(Колонки[2]);
                КонецПериода = мПривестиКДате(КонецПериодаСтрока, Новый ОписаниеТипов("Дата"));
                Если КонецПериода = '00010101' Тогда
                    Сообщить("Ошибка: значение 'КонецПериода' не является корректной датой в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                ТренерСтрока = СокрЛП(Колонки[3]);
                Тренер = Справочники.Тренеры.НайтиПоНаименованию(ТренерСтрока);
                Если Тренер = Неопределено Тогда
                    Сообщить("Ошибка: тренер '" + ТренерСтрока + "' не найден в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                СтавкаСтрока = СокрЛП(Колонки[4]);
                Ставка = Число(СтавкаСтрока);
                Если Ставка = 0 Тогда
                    Сообщить("Ошибка: ставка '" + СтавкаСтрока + "' не является числом в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                КоличествоПроведенныхУслугСтрока = СокрЛП(Колонки[5]);
                КоличествоПроведенныхУслуг = Число(КоличествоПроведенныхУслугСтрока);
                Если КоличествоПроведенныхУслуг = 0 Тогда
                    Сообщить("Ошибка: количество проведенных услуг '" + КоличествоПроведенныхУслугСтрока + "' не является числом в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                СуммаЗаУслугиСтрока = СокрЛП(Колонки[6]);
                СуммаЗаУслуги = Число(СуммаЗаУслугиСтрока);
                Если СуммаЗаУслуги = 0 Тогда
                    Сообщить("Ошибка: сумма за услуги '" + СуммаЗаУслугиСтрока + "' не является числом в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                СуммаЗаработнойПлаты = Ставка * КоличествоПроведенныхУслуг + СуммаЗаУслуги;
                
                НовыйДокумент = Документы.ЗарплатаТренеров.СоздатьДокумент();
                НовыйДокумент.Номер = Номер;
                НовыйДокумент.Дата = Дата;
                НовыйДокумент.КонецПериода = КонецПериода;
                НовыйДокумент.Тренер = Тренер;
                
                НоваяСтрока = НовыйДокумент.Зарплата.Добавить();
                НоваяСтрока.Ставка = Ставка;
                НоваяСтрока.КоличествоПроведенныхУслуг = КоличествоПроведенныхУслуг;
                НоваяСтрока.СуммаЗаУслуги = СуммаЗаУслуги;
                НоваяСтрока.СуммаЗаработнойПлаты = СуммаЗаработнойПлаты;
                
                НовыйДокумент.Записать();
                Сообщить("Создан новый документ: " + Номер);
                
            Исключение
                Сообщить("Ошибка при обработке строки: " + Строка + ". Ошибка: " + ОписаниеОшибки());
                Продолжить;
            КонецПопытки;
        Иначе
            Сообщить("Ошибка формата: строка содержит " + Колонки.Количество() + " колонок вместо 8: " + Строка);
        КонецЕсли;
    КонецЦикла;
    
    Сообщить("Данные успешно загружены!");
КонецПроцедуры

&НаСервере
Процедура ТренерПриИзмененииНаСервере()
	Тренер = Объект.Тренер;
    
    Если Тренер = Неопределено Тогда
        Возврат;
    КонецЕсли;

    НачалоПериода = Объект.Дата;
    КонецПериода = Объект.КонецПериода;
	
	Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |	ОказаниеУслугОбороты.Тренер КАК Тренер,
                   |	СУММА(ОказаниеУслугОбороты.КоличествоОборот) КАК КоличествоПроведенныхУслуг,
                   |	СУММА(ОказаниеУслугОбороты.СуммаОборот) КАК СуммаЗаУслуги
                   |ИЗ
                   |	РегистрНакопления.ОказаниеУслуг.Обороты КАК ОказаниеУслугОбороты
                   |ГДЕ
                   |	ОказаниеУслугОбороты.Тренер = &Тренер
                   |	И ОказаниеУслугОбороты.ДатаЗанятия МЕЖДУ &НачалоПериода И &КонецПериода
                   |
                   |СГРУППИРОВАТЬ ПО
                   |	ОказаниеУслугОбороты.Тренер";   
	Запрос.УстановитьПараметр("Тренер", Тренер);
    Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);
    Запрос.УстановитьПараметр("КонецПериода", КонецПериода);
	
	Результат = Запрос.Выполнить();
    
    СуммаЗаУслуги = 0;
    КоличествоПроведенныхУслуг = 0;
	
    Выборка = Результат.Выбрать();
    
    Если Выборка.Следующий() Тогда
        СуммаЗаУслуги = Выборка.СуммаЗаУслуги;
		КоличествоПроведенныхУслуг = Выборка.КоличествоПроведенныхУслуг;
	КонецЕсли;
	
    ТренерЗапись = Справочники.Тренеры.НайтиПоНаименованию(Тренер);
    
    Если ТренерЗапись <> Неопределено Тогда
        Ставка = ТренерЗапись.Ставка;
    Иначе
        Ставка = 0; 
    КонецЕсли;

    СуммаЗаработнойПлаты = Ставка + (СуммаЗаУслуги * КоличествоПроведенныхУслуг) * 0.3; 
    
    НовыйЗапись = Объект.Зарплата.Добавить();
    НовыйЗапись.Ставка = Ставка;  
	НовыйЗапись.КоличествоПроведенныхУслуг = КоличествоПроведенныхУслуг;
    НовыйЗапись.СуммаЗаУслуги = СуммаЗаУслуги;
    НовыйЗапись.СуммаЗаработнойПлаты = СуммаЗаработнойПлаты;
	
КонецПроцедуры

&НаКлиенте
Процедура ТренерПриИзменении(Элемент)
	ТренерПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура Выгрузить(Команда)
    ТекстДляВыгрузки = СформироватьТекстДляВыгрузкиНаСервере();
    
    Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
    Диалог.Заголовок = "Сохранить файл";
    Диалог.Фильтр = "Текстовые файлы (*.txt)|*.txt|CSV файлы (*.csv)|*.csv|Excel файлы (*.xls)|*.xls|Word файлы (*.docx)|*.docx";
    
    ИмяФайлаПоУмолчанию = Объект.Номер + "_ЗарплатаТренеров_Выгрузка.txt";
    Диалог.ПолноеИмяФайла = ИмяФайлаПоУмолчанию;
    
    Если Диалог.Выбрать() Тогда
        ВыбранныйФайл = Диалог.ПолноеИмяФайла;
        Расширение = нРег(Прав(ВыбранныйФайл, 4));
        
        Попытка
            Если Расширение = ".txt" Тогда
                СохранитьВTXT(ВыбранныйФайл, ТекстДляВыгрузки);
            ИначеЕсли Расширение = ".csv" Тогда
                СохранитьВCSV(ВыбранныйФайл, ТекстДляВыгрузки);
            ИначеЕсли Расширение = ".xls" Тогда
                СохранитьВXLS(ВыбранныйФайл);
            ИначеЕсли Расширение = ".docx" Тогда
                СохранитьВDOCX(ВыбранныйФайл);
            КонецЕсли;
            
            Сообщить("Файл сохранен: " + ВыбранныйФайл);
        Исключение
            Сообщить("Ошибка: " + ОписаниеОшибки());
        КонецПопытки;
    КонецЕсли;
КонецПроцедуры

&НаСервере
Функция СформироватьТекстДляВыгрузкиНаСервере()
    // Заголовок документа
    ЗаголовокДокумента = 
        "Дата: " + Формат(Объект.Дата, "ДФ=dd.MM.yyyy HH:mm:ss") + "
    |" +
        "Конец периода: " + Формат(Объект.КонецПериода, "ДФ=dd.MM.yyyy") + "
    |" +
        "Тренер: " + Объект.Тренер + "
    |";
    
    // Заголовки табличной части
    ЗаголовкиТабличнойЧасти = "Ставка;КоличествоПроведенныхУслуг;СуммаПродаж;СуммаЗаработнойПлаты";
    Результат = ЗаголовокДокумента + ЗаголовкиТабличнойЧасти + "
    |";
    
    // Данные табличной части
    ТабличнаяЧасть = Объект.Зарплата;
    Если ТабличнаяЧасть.Количество() = 0 Тогда
        Возврат ЗаголовокДокумента + "
    |Нет данных в табличной части";
    КонецЕсли;
    
    Для Каждого Строка Из ТабличнаяЧасть Цикл
        Результат = Результат + 
            Формат(Строка.Ставка, "ЧДЦ=2") + ";" +
            Формат(Строка.КоличествоПроведенныхУслуг, "ЧГ=0") + ";" +
            Формат(Строка.СуммаЗаУслуги, "ЧДЦ=2") + ";" +
            Формат(Строка.СуммаЗаработнойПлаты, "ЧДЦ=2") + "
    |";
    КонецЦикла;
    
    Возврат Результат;
КонецФункции

&НаКлиенте
Процедура СохранитьВTXT(Путь, Данные)
    ЗаписьТекста = Новый ЗаписьТекста(Путь);
    ЗаписьТекста.ЗаписатьСтроку(Данные);
    ЗаписьТекста.Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВCSV(Путь, Данные)
    Данные = СтрЗаменить(Данные, "
    |", Символы.ПС);
    ЗаписьТекста = Новый ЗаписьТекста(Путь);
    ЗаписьТекста.ЗаписатьСтроку(Данные);
    ЗаписьТекста.Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВXLS(Путь)
    // Используем COM-объект Excel для создания XLS
    Excel = Новый COMОбъект("Excel.Application");
    Excel.Visible = Ложь;
    Книга = Excel.Workbooks.Add();
    Лист = Книга.Worksheets(1);
    
    // Заголовок документа
    Лист.Cells(1, 1).Value = "Дата: " + Формат(Объект.Дата, "ДФ=dd.MM.yyyy HH:mm:ss");
    Лист.Cells(2, 1).Value = "Конец периода: " + Формат(Объект.КонецПериода, "ДФ=dd.MM.yyyy");
    Лист.Cells(3, 1).Value = "Тренер: " + Объект.Тренер;
    
    // Заголовки таблицы
    Лист.Cells(5, 1).Value = "Ставка";
    Лист.Cells(5, 2).Value = "КоличествоПроведенныхУслуг";
    Лист.Cells(5, 3).Value = "СуммаЗаУслуги";
    Лист.Cells(5, 4).Value = "СуммаЗаработнойПлаты";
    
    // Данные таблицы
    Для i = 1 По Объект.Зарплата.Количество() Цикл
        Строка = Объект.Зарплата[i - 1];
        Лист.Cells(5 + i, 1).Value = Строка.Ставка;
        Лист.Cells(5 + i, 2).Value = Строка.КоличествоПроведенныхУслуг;
        Лист.Cells(5 + i, 3).Value = Строка.СуммаЗаУслуги;
        Лист.Cells(5 + i, 4).Value = Строка.СуммаЗаработнойПлаты;
    КонецЦикла;
    
    Книга.SaveAs(Путь);
    Книга.Close();
    Excel.Quit();
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВDOCX(Путь)
    // Используем COM-объект Word для создания DOCX
    Word = Новый COMОбъект("Word.Application");
    Word.Visible = Ложь;
    Документ = Word.Documents.Add();
    
    // Заголовок документа
    Документ.Content.Text = "Дата: " + Формат(Объект.Дата, "ДФ=dd.MM.yyyy HH:mm:ss") + Символы.ПС;
    Документ.Content.Text = Документ.Content.Text + "Конец периода: " + Формат(Объект.КонецПериода, "ДФ=dd.MM.yyyy") + Символы.ПС;
    Документ.Content.Text = Документ.Content.Text + "Тренер: " + Объект.Тренер + Символы.ПС;
    
    // Добавляем таблицу
    Таблица = Документ.Tables.Add(Документ.Content, Объект.Зарплата.Количество() + 1, 4);
    Таблица.Cell(1, 1).Range.Text = "Ставка";
    Таблица.Cell(1, 2).Range.Text = "КоличествоПроведенныхУслуг";
    Таблица.Cell(1, 3).Range.Text = "СуммаЗаУслуги";
    Таблица.Cell(1, 4).Range.Text = "СуммаЗаработнойПлаты";
    
    Для i = 1 По Объект.Зарплата.Количество() Цикл
        Строка = Объект.Зарплата[i - 1];
        Таблица.Cell(i + 1, 1).Range.Text = Формат(Строка.Ставка, "ЧДЦ=2");
        Таблица.Cell(i + 1, 2).Range.Text = Формат(Строка.КоличествоПроведенныхУслуг, "ЧГ=0");
        Таблица.Cell(i + 1, 3).Range.Text = Формат(Строка.СуммаЗаУслуги, "ЧДЦ=2");
        Таблица.Cell(i + 1, 4).Range.Text = Формат(Строка.СуммаЗаработнойПлаты, "ЧДЦ=2");
    КонецЦикла;
    
    Документ.SaveAs2(Путь);
    Документ.Close();
    Word.Quit();
КонецПроцедуры