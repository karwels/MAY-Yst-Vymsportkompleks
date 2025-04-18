﻿&НаСервере
Процедура КлиентПриИзмененииНаСервере()
	Объект.Опции.Очистить();	
    Клиент = Объект.Клиент;  
    Если Клиент <> Неопределено Тогда          
        Абонементы = Документы.Абонемент.НайтиПоРеквизиту("Клиент", Клиент); 
		Если Не Абонементы.Пустая() Тогда  
			Абонемент = Абонементы;
            Для Каждого Строка Из Абонемент.Опции Цикл
                НоваяСтрока = Объект.Опции.Добавить();
                НоваяСтрока.Услуги = Строка.Услуги; 
            КонецЦикла;
        Иначе
            Сообщение = Новый СообщениеПользователю();
            Сообщение.Текст ="Абонементы не найдены для данного клиента.";			
            Сообщение.Сообщить();
        КонецЕсли;    
    Иначе
        Сообщение = Новый СообщениеПользователю();		
        Сообщение.Текст ="Клиент не выбран.";
        Сообщение.Сообщить();		
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КлиентПриИзменении(Элемент)
	КлиентПриИзмененииНаСервере();
КонецПроцедуры