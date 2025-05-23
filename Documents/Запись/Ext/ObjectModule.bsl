﻿
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

    // Движения для регистра ОказаниеУслуг 
    Движения.ОказаниеУслуг.Записывать = Истина;
    Для Каждого ТекСтрокаЗанятие Из Занятие Цикл
        Движение = Движения.ОказаниеУслуг.Добавить(); 
		Движение.ДатаЗанятия = ВремяНачала; 
        Движение.Период = Дата;
        Движение.Клиент = Клиент;
        Движение.Тренер = Тренер;
        Движение.Услуги = ТекСтрокаЗанятие.Услуги;
        Движение.Количество = ТекСтрокаЗанятие.Количество;
        Движение.Цена = ТекСтрокаЗанятие.Цена;
        Движение.Сумма = ТекСтрокаЗанятие.Сумма;
    КонецЦикла;

    // Движения для регистра УчетЗанятий 
    Движения.УчетЗанятий.Записывать = Истина;
    Для Каждого ТекСтрокаЗанятие Из Занятие Цикл
        Движение = Движения.УчетЗанятий.Добавить();
        Движение.Период = Дата;
        Движение.ВремяНачала = ВремяНачала;
        Движение.ВремяОкончания = ВремяОкончания;
        Движение.Клиент = Клиент;
        Движение.Тренер = Тренер;
        Движение.Услуги = ТекСтрокаЗанятие.Услуги;
        Движение.Количество = ТекСтрокаЗанятие.Количество;
    КонецЦикла;

    Движения.Записать();
КонецПроцедуры
