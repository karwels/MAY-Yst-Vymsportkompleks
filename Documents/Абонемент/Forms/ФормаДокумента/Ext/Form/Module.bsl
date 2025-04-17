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
            
            ОбработатьДанныеНаСервере(Данные); // Вызов серверной процедуры
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
        // Создаем COM-объект для работы с Excel
        Excel = Новый COMОбъект("Excel.Application");
        Excel.Visible = Ложь; // Скрываем окно Excel
        Книга = Excel.Workbooks.Open(Путь);
        Лист = Книга.Sheets(1); // Выбираем первый лист
        
        // Читаем данные из листа
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
        
        // Закрываем книгу и Excel
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
                    // Обработка формата ДД.ММ.ГГГГ ЧЧ:ММ
                    День = МассивЧастей[0];
                    Месяц = МассивЧастей[1];
                    Год = МассивЧастей[2];
                    Час = МассивЧастей[3];
                    Минута = МассивЧастей[4];
                    Результат = Дата(Год, Месяц, День, Час, Минута, 0);
                ИначеЕсли МассивЧастей.Количество() = 3 Тогда
                    // Обработка формата ДД.ММ.ГГГГ
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
                МассивЧастей[2] = МассивЧастей[2] + ?(МассивЧастей[2] < 30, 2000,1900);
            КонецЕсли;
            Попытка
                Если МассивЧастей.Количество() = 3 или ТипРеквизита.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.Дата Тогда
                    Результат = Дата(МассивЧастей[2],МассивЧастей[1],МассивЧастей[0]);
                Иначе
                    Результат = Дата(МассивЧастей[2],МассивЧастей[1],МассивЧастей[0],МассивЧастей[3],МассивЧастей[4],0);
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
        Символ = Сред(Представление, к ,1);
        ЭтоЦифра = Символ >= "0" и Символ <= "9";
        Если ЭтоЦифра Тогда
            Если НачалоЦифры = 0 Тогда
                НачалоЦифры = к;
            КонецЕсли;
        Иначе
            Если Не НачалоЦифры = 0 Тогда
                МассивЧастей.Добавить(Число(Сред(Представление,НачалоЦифры, к - НачалоЦифры)));
            КонецЕсли;
            НачалоЦифры = 0;
        КонецЕсли;
    КонецЦикла;
    Если Не НачалоЦифры = 0 Тогда
        МассивЧастей.Добавить(Число(Сред(Представление,НачалоЦифры)));
    КонецЕсли;
    Возврат МассивЧастей;
КонецФункции

&НаСервере
Процедура ОбработатьДанныеНаСервере(Данные)
    Строки = СтрРазделить(Данные, Символы.ПС);
    ПропуститьЗаголовок = Истина; // Флаг для пропуска заголовка
    
    Для Сч = 0 По Строки.Количество() - 1 Цикл
        Строка = Строки[Сч];
        
        // Пропускаем заголовок
        Если ПропуститьЗаголовок Тогда
            ПропуститьЗаголовок = Ложь;
            Продолжить;
        КонецЕсли;
        
        // Пропускаем пустые строки
        Если Строка = "" ИЛИ СтрЗаменить(Строка, " ", "") = "" Тогда
            Продолжить;
        КонецЕсли;
        
        // Разделяем строку на колонки
        Колонки = СтрРазделить(Строка, ";");
        
        // Проверяем, что строка содержит ровно 7 колонок (Номер, Дата, ДатаОкончанияИспользования, Клиент, ТипАбонемента, Услуга, Количество)
        Если Колонки.Количество() = 7 Тогда
            Попытка
                // Получаем номер абонемента
                Номер = СокрЛП(Колонки[0]);
                
                // Преобразуем дату начала использования
                ДатаСтрока = СокрЛП(Колонки[1]);
                Дата = мПривестиКДате(ДатаСтрока, Новый ОписаниеТипов("Дата"));
                Если Дата = '00010101' Тогда
                    Сообщить("Ошибка: значение 'Дата' не является корректной датой в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                // Преобразуем дату окончания использования
                ДатаОкончанияИспользованияСтрока = СокрЛП(Колонки[2]);
                ДатаОкончанияИспользования = мПривестиКДате(ДатаОкончанияИспользованияСтрока, Новый ОписаниеТипов("Дата"));
                Если ДатаОкончанияИспользования = '00010101' Тогда
                    Сообщить("Ошибка: значение 'ДатаОкончанияИспользования' не является корректной датой в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                // Получаем клиента
                КлиентСтрока = СокрЛП(Колонки[3]);
                Клиент = Справочники.Клиенты.НайтиПоНаименованию(КлиентСтрока);
                Если Клиент = Неопределено Тогда
                    Сообщить("Ошибка: клиент '" + КлиентСтрока + "' не найден в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                // Получаем тип абонемента
                ТипАбонементаСтрока = СокрЛП(Колонки[4]);
                ТипАбонемента = Справочники.ТипАбонемента.НайтиПоНаименованию(ТипАбонементаСтрока);
                Если ТипАбонемента = Неопределено Тогда
                    Сообщить("Ошибка: тип абонемента '" + ТипАбонементаСтрока + "' не найден в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                // Получаем услугу
                УслугиСтрока = СокрЛП(Колонки[5]);
                Услуги = Справочники.Услуги.НайтиПоНаименованию(УслугиСтрока);
                Если Услуги = Неопределено Тогда
                    Сообщить("Ошибка: услуга '" + УслугиСтрока + "' не найдена в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                // Получаем количество
                КоличествоСтрока = СокрЛП(Колонки[6]);
                Количество = Число(КоличествоСтрока);
                Если Количество = 0 Тогда
                    Сообщить("Ошибка: количество '" + КоличествоСтрока + "' не является числом в строке: " + Строка);
                    Продолжить;
                КонецЕсли;
                
                // Создаем новый документ "Абонемент"
                НовыйАбонемент = Документы.Абонемент.СоздатьДокумент();
                НовыйАбонемент.Номер = Номер;
                НовыйАбонемент.Дата = Дата;
                НовыйАбонемент.ДатаОкончанияИспользования = ДатаОкончанияИспользования;
                НовыйАбонемент.Клиент = Клиент; // Загружаем клиента в документ
                НовыйАбонемент.ТипАбонемента = ТипАбонемента; // Загружаем тип абонемента в документ
                
                // Добавляем строку в табличную часть "Опции"
                НоваяСтрока = НовыйАбонемент.Опции.Добавить();
                НоваяСтрока.Услуги = Услуги;
                НоваяСтрока.Количество = Количество;
                
                // Сохраняем документ
                НовыйАбонемент.Записать();
                Сообщить("Создан новый абонемент: " + Номер);
                
            Исключение
                Сообщить("Ошибка при обработке строки: " + Строка + ". Ошибка: " + ОписаниеОшибки());
                Продолжить;
            КонецПопытки;
        Иначе
            Сообщить("Ошибка формата: строка содержит " + Колонки.Количество() + " колонок вместо 7: " + Строка);
        КонецЕсли;
    КонецЦикла;
    
    Сообщить("Данные успешно загружены!");
КонецПроцедуры

&НаСервере
Процедура КлиентПриИзмененииНаСервере()  
	Если Объект.Клиент <> Неопределено Тогда
        ТипАбонемента = Объект.Клиент.ТипАбонемента;
        Если Не ТипАбонемента = Неопределено Тогда
           Объект.ТипАбонемента = ТипАбонемента;
        КонецЕсли;
	КонецЕсли;  
		
    Объект.Опции.Очистить();
    ТипАбонемента = Объект.ТипАбонемента;

    ЗаписьТипаАбонемента = Справочники.ТипАбонемента.НайтиПоНаименованию(ТипАбонемента);

    Если ЗаписьТипаАбонемента <> Неопределено Тогда
     
        Для Каждого Строка Из ЗаписьТипаАбонемента.Опции Цикл
            НоваяСтрока = Объект.Опции.Добавить();
            НоваяСтрока.Услуги = Строка.Услуги; 
            НоваяСтрока.Количество = Строка.Количество;
        КонецЦикла;
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура КлиентПриИзменении(Элемент)
	КлиентПриИзмененииНаСервере();
КонецПроцедуры


&НаСервере
Процедура ДатаПриИзмененииНаСервере()
	Если Объект.ТипАбонемента <> Неопределено Тогда 
        Если Объект.Дата <> Неопределено Тогда
            Выбор = Объект.ТипАбонемента; 
            Если Выбор = Справочники.ТипАбонемента.НайтиПоНаименованию("Standart") Тогда
                Объект.ДатаОкончанияИспользования = ДобавитьМесяц(Объект.Дата, 6); 
			ИначеЕсли Выбор = Справочники.ТипАбонемента.НайтиПоНаименованию("Premium") Тогда
                Объект.ДатаОкончанияИспользования = ДобавитьМесяц(Объект.Дата, 9); 
            ИначеЕсли Выбор = Справочники.ТипАбонемента.НайтиПоНаименованию("Lux") Тогда
                Объект.ДатаОкончанияИспользования = ДобавитьМесяц(Объект.Дата, 12); 
			КонецЕсли;
        КонецЕсли;    
    КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ДатаПриИзменении(Элемент)
	ДатаПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура Выгрузить(Команда)
    ТекстДляВыгрузки = СформироватьТекстДляВыгрузкиНаСервере();
    
    Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
    Диалог.Заголовок = "Сохранить файл";
    Диалог.Фильтр = "Текстовые файлы (*.txt)|*.txt|CSV файлы (*.csv)|*.csv|Excel файлы (*.xls)|*.xls|Word файлы (*.docx)|*.docx";
    
    ИмяФайлаПоУмолчанию = Объект.Номер + "_Абонемент_Выгрузка.txt";
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
	
	ЗаголовокДокумента = 
        "Номер: " + Объект.Номер + "
    |" +
        "Дата: " + Формат(Объект.Дата, "ДФ=dd.MM.yyyy HH:mm:ss") + "
    |" +
        "Клиент: " + Объект.Клиент + "
    |" +
        "ТипАбонемента: " + Объект.ТипАбонемента + "
    |" +
        "ДатаОкончанияИспользования: " + Формат(Объект.ДатаОкончанияИспользования, "ДФ=dd.MM.yyyy") + "
    |";
    
    ЗаголовкиТабличнойЧасти = "Услуги;Количество";
    Результат = ЗаголовокДокумента + ЗаголовкиТабличнойЧасти + "
    |";
    
    ТабличнаяЧасть = Объект.Опции;
    Если ТабличнаяЧасть.Количество() = 0 Тогда
        Возврат ЗаголовокДокумента + "
    |Нет данных в табличной части";
    КонецЕсли;
    
    Для Каждого Строка Из ТабличнаяЧасть Цикл
        Результат = Результат + 
            Строка(Строка.Услуги) + ";" +
            Формат(Строка.Количество, "ЧГ=0") + "
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
	
	Excel = Новый COMОбъект("Excel.Application");
    Excel.Visible = Ложь;
    Книга = Excel.Workbooks.Add();
    Лист = Книга.Worksheets(1);
    
    Лист.Cells(1, 1).Value = "Номер: " + Объект.Номер;
    Лист.Cells(2, 1).Value = "Дата: " + Формат(Объект.Дата, "ДФ=dd.MM.yyyy HH:mm:ss");
    Лист.Cells(3, 1).Value = "Клиент: " + Объект.Клиент;
    Лист.Cells(4, 1).Value = "ТипАбонемента: " + Объект.ТипАбонемента;
    Лист.Cells(5, 1).Value = "ДатаОкончанияИспользования: " + Формат(Объект.ДатаОкончанияИспользования, "ДФ=dd.MM.yyyy");
    
    Лист.Cells(7, 1).Value = "Услуги";
    Лист.Cells(7, 2).Value = "Количество";
    
    Для i = 1 По Объект.Опции.Количество() Цикл
        Строка = Объект.Опции[i - 1];
        Лист.Cells(7 + i, 1).Value = Строка.Услуги;
        Лист.Cells(7 + i, 2).Value = Строка.Количество;
    КонецЦикла;
    
    Книга.SaveAs(Путь);
    Книга.Close();
    Excel.Quit();
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВDOCX(Путь)

    Word = Новый COMОбъект("Word.Application");
    Word.Visible = Ложь;
    Документ = Word.Documents.Add();
    
    Документ.Content.Text = "Номер: " + Объект.Номер + Символы.ПС;
    Документ.Content.Text = Документ.Content.Text + "Дата: " + Формат(Объект.Дата, "ДФ=dd.MM.yyyy HH:mm:ss") + Символы.ПС;
    Документ.Content.Text = Документ.Content.Text + "Клиент: " + Объект.Клиент + Символы.ПС;
    Документ.Content.Text = Документ.Content.Text + "ТипАбонемента: " + Объект.ТипАбонемента + Символы.ПС;
    Документ.Content.Text = Документ.Content.Text + "ДатаОкончанияИспользования: " + Формат(Объект.ДатаОкончанияИспользования, "ДФ=dd.MM.yyyy") + Символы.ПС;
    
     Таблица = Документ.Tables.Add(Документ.Content, Объект.Опции.Количество() + 1, 2);
    Таблица.Cell(1, 1).Range.Text = "Услуги";
    Таблица.Cell(1, 2).Range.Text = "Количество";
    
    Для i = 1 По Объект.Опции.Количество() Цикл
        Строка = Объект.Опции[i - 1];
        Таблица.Cell(i + 1, 1).Range.Text = Строка.Услуги;
        Таблица.Cell(i + 1, 2).Range.Text = Строка.Количество;
    КонецЦикла;
    
    Документ.SaveAs2(Путь);
    Документ.Close();
    Word.Quit();
КонецПроцедуры

&НаСервере
Процедура ЗаморозитьНаСервере()
    
    // Получаем объект документа (не формы!)
    ДокументАбонемент = ЭтотОбъект.Объект;
    
    Если ДокументАбонемент.КоличествоЗаморозок >= 3 Тогда
        Сообщить("Лимит заморозок исчерпан (максимум 3)!");
        Возврат;
    КонецЕсли;
    
    Если ДокументАбонемент.ДатаОкончанияИспользования = Неопределено Тогда
        Сообщить("Не указана дата окончания!");
        Возврат;
    КонецЕсли;
    
    ДокументАбонемент.ДатаОкончанияИспользования = ДобавитьМесяц(ДокументАбонемент.ДатаОкончанияИспользования, 1);
    ДокументАбонемент.КоличествоЗаморозок = ДокументАбонемент.КоличествоЗаморозок + 1;
    ДатаРазморозки = ТекущаяДата();
    Объект.ДатаРазморозки = ДобавитьМесяц(ДатаРазморозки, 1);

    Попытка
        Сообщить("Успешно! Абонемент заморожен до: " + 
               Формат(ДокументАбонемент.ДатаРазморозки, "ДФ=dd.MM.yyyy") +
               ", заморозок использовано: " + ДокументАбонемент.КоличествоЗаморозок);
    Исключение
        Сообщить("Ошибка сохранения: " + ОписаниеОшибки());
	КонецПопытки;
КонецПроцедуры

&НаКлиенте
Процедура Заморозить(Команда)
	ЗаморозитьНаСервере();
КонецПроцедуры
