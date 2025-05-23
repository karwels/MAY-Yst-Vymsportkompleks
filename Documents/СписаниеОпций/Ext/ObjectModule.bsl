﻿Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
 	Префикс = Обмен.ПолучитьПрефиксНомера();
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	Если Режим = РежимПроведенияДокумента.Оперативный Тогда 	
        Запрос4 = Новый Запрос;     
		МенеджерВТ = Новый МенеджерВременныхТаблиц;
		Запрос4.МенеджерВременныхТаблиц = МенеджерВТ;
        Запрос4.Текст = 
        "ВЫБРАТЬ
            |УчетЗанятийОбороты.Тренер КАК Тренер,
            |УчетЗанятийОбороты.ВремяНачала КАК ВремяНачала,
            |УчетЗанятийОбороты.ВремяОкончания КАК ВремяОкончания
        	|	ИЗ
            |РегистрНакопления.УчетЗанятий.Обороты КАК УчетЗанятийОбороты
        	|	ГДЕ
            |УчетЗанятийОбороты.Тренер = &Тренер
            |И (
            |    (УчетЗанятийОбороты.ВремяНачала < &ВремяОкончания И УчетЗанятийОбороты.ВремяОкончания > &ВремяНачала)
            |    ИЛИ
            |    (УчетЗанятийОбороты.ВремяНачала = &ВремяНачала И УчетЗанятийОбороты.ВремяОкончания = &ВремяОкончания))";  

        Запрос4.УстановитьПараметр("Тренер", Тренер);
        Запрос4.УстановитьПараметр("ВремяНачала", ВремяНачала); 
        Запрос4.УстановитьПараметр("ВремяОкончания", ВремяОкончания);  
        
        РезультатЗапроса = Запрос4.Выполнить();
        ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
        
        Если ВыборкаДетальныеЗаписи.Следующий() Тогда    
            Сообщение = Новый СообщениеПользователю();
            Сообщение.Текст = "Вы не можете записаться на " + Строка(ВыборкаДетальныеЗаписи.ВремяНачала) + " к тренеру " + Строка(ВыборкаДетальныеЗаписи.Тренер) + ", так как это время занято";
            Сообщение.Сообщить();    
            Отказ = Истина;
        КонецЕсли; 
    КонецЕсли;
	// регистр УчетЗанятий 
	Движения.УчетЗанятий.Записывать = Истина;
	Для Каждого ТекСтрокаОпции Из Опции Цикл
		Движение = Движения.УчетЗанятий.Добавить();
		Движение.Период = Дата;
		Движение.ВремяНачала = ВремяНачала;
		Движение.ВремяОкончания = ВремяОкончания;
		Движение.Клиент = Клиент;
		Движение.Тренер = Тренер;
		Движение.Услуги = ТекСтрокаОпции.Услуги;
		Движение.Количество = ТекСтрокаОпции.Количество;
	КонецЦикла;

	// регистр УчетОпций Расход
	Движения.УчетОпций.Записывать = Истина;
	Для Каждого ТекСтрокаОпции Из Опции Цикл
		Движение = Движения.УчетОпций.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.Услуги = ТекСтрокаОпции.Услуги;
		Движение.Количество = ТекСтрокаОпции.Количество;
	КонецЦикла;
	
	Движения.Записать();
	
	Если Режим = РежимПроведенияДокумента.Оперативный Тогда
		Запрос3 = Новый Запрос;  
		МенеджерВТ = Новый МенеджерВременныхТаблиц;
		Запрос3.МенеджерВременныхТаблиц = МенеджерВТ;
		Запрос3.Текст = "ВЫБРАТЬ
		                |	УчетОпцийОстатки.Клиент КАК Клиент,
		                |	УчетОпцийОстатки.Услуги КАК Услуги,
		                |	УчетОпцийОстатки.КоличествоОстаток КАК КоличествоОстаток
		                |ИЗ
		                |	РегистрНакопления.УчетОпций.Остатки КАК УчетОпцийОстатки
		                |ГДЕ
		                |	УчетОпцийОстатки.КоличествоОстаток < 0"; 
	РезультатЗапроса = Запрос3.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = "Вы не можете использовать заданное количество опций, так как по Вашему абонементу не хватает " + Строка(- ВыборкаДетальныеЗаписи
	.КоличествоОстаток) + " применений услуги """
	+ ВыборкаДетальныеЗаписи.Услуги + """";
	Сообщение.Сообщить();
	Отказ = Истина;
КонецЦикла; 
    КонецЕсли;
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
