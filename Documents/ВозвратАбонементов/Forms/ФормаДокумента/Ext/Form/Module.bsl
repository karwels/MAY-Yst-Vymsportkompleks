﻿&НаСервере
Процедура КлиентПриИзмененииНаСервере()
    Клиент = Объект.Клиент;
    
    // Очищаем предыдущие данные
    Объект.ДатаПокупки = Неопределено;
    Объект.Возврат.Очистить();
    
    Если Клиент = Неопределено Тогда
        Возврат;
    КонецЕсли;
    
    // Ищем последнюю продажу абонемента
    ДокПродажи = Документы.ПродажаАбонементов.НайтиПоРеквизиту("Клиент", Клиент);
    Если ДокПродажи = Неопределено Тогда
        Сообщить("Не найдены продажи для выбранного клиента");
        Возврат;
    КонецЕсли;
    
    // Заполняем дату покупки
    Объект.ДатаПокупки = ДокПродажи.Дата;
    
    // Ищем абонемент клиента
    Абонемент = Документы.Абонемент.НайтиПоРеквизиту("Клиент", Клиент);
    Если Абонемент = Неопределено Тогда
        Сообщить("Не найден абонемент для выбранного клиента");
        Возврат;
    КонецЕсли;
    
    // Создаем новую строку возврата
    НоваяСтрока = Объект.Возврат.Добавить();
    НоваяСтрока.Абонемент = Абонемент;
    НоваяСтрока.ТипАбонемента = Клиент.ТипАбонемента;
    НоваяСтрока.СтоимостьАбонемента = РаботаСДокументами.ЦенаАбонементов(ДокПродажи.Дата, НоваяСтрока.ТипАбонемента);
    
    // Рассчитываем срок использования
    РассчитатьСрокИспользования(НоваяСтрока);
    
    // Рассчитываем сумму к возврату
    РассчитатьСуммуКВозврату(НоваяСтрока);
КонецПроцедуры

&НаСервере
Процедура РассчитатьСрокИспользования(СтрокаТЧ)
    Если СтрокаТЧ.Абонемент = Неопределено ИЛИ Объект.ДатаПокупки = Неопределено Тогда
        СтрокаТЧ.СрокИспользования = 0;
        Возврат;
    КонецЕсли;
    
    ДатаПродажи = Объект.ДатаПокупки;
    ДатаВозврата = Объект.Дата;
    
    РазницаВМесяцах = (Год(ДатаВозврата) - Год(ДатаПродажи)) * 12 + 
                     (Месяц(ДатаВозврата) - Месяц(ДатаПродажи));
    
    Если День(ДатаВозврата) < День(ДатаПродажи) Тогда
        РазницаВМесяцах = РазницаВМесяцах - 1;
    КонецЕсли;
    
    СтрокаТЧ.СрокИспользования = Макс(РазницаВМесяцах, 0);
КонецПроцедуры

&НаСервере
Процедура РассчитатьСуммуКВозврату(СтрокаТЧ)
	
    Если Не ЗначениеЗаполнено(СтрокаТЧ.ТипАбонемента) ИЛИ 
       Не ЗначениеЗаполнено(СтрокаТЧ.СтоимостьАбонемента) ИЛИ 
       Не ЗначениеЗаполнено(СтрокаТЧ.СрокИспользования) Тогда
        СтрокаТЧ.СуммаКВозврату = 0;
        Возврат;
    КонецЕсли;
    
    // Получаем ссылки на типы абонементов для сравнения
    Lux = Справочники.ТипАбонемента.НайтиПоНаименованию("Lux");
    Premium = Справочники.ТипАбонемента.НайтиПоНаименованию("Premium");
    Standart = Справочники.ТипАбонемента.НайтиПоНаименованию("Standart");
    
    // Расчет в зависимости от типа абонемента
    Если СтрокаТЧ.ТипАбонемента = Lux Тогда
        // Для Lux: (Стоимость/12) * СрокИспользования
        СтрокаТЧ.СуммаКВозврату = Окр(СтрокаТЧ.СтоимостьАбонемента - (СтрокаТЧ.СтоимостьАбонемента / 12 * СтрокаТЧ.СрокИспользования), 2);
        
    ИначеЕсли СтрокаТЧ.ТипАбонемента = Premium Тогда
        // Для Premium: (Стоимость/9) * СрокИспользования
        СтрокаТЧ.СуммаКВозврату = Окр(СтрокаТЧ.СтоимостьАбонемента -(СтрокаТЧ.СтоимостьАбонемента / 9 * СтрокаТЧ.СрокИспользования), 2);
        
    ИначеЕсли СтрокаТЧ.ТипАбонемента = Standart Тогда
        // Для Standart: (Стоимость/6) * СрокИспользования
        СтрокаТЧ.СуммаКВозврату = Окр(СтрокаТЧ.СтоимостьАбонемента - (СтрокаТЧ.СтоимостьАбонемента / 6 * СтрокаТЧ.СрокИспользования), 2);
        
    Иначе
        // Для других типов - фиксированный процент (50%)
        СтрокаТЧ.СуммаКВозврату = 0;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КлиентПриИзменении(Элемент)
    КлиентПриИзмененииНаСервере();
    Элементы.Возврат.Обновить();
КонецПроцедуры


