﻿&НаКлиенте
Процедура СсылкаНаКартинкуНажатие(Элемент, СтандартнаяОбработка)
	Оповещение = Новый ОписаниеОповещения("СсылкаНаКартинкуНажатиеЗавершение", ЭтотОбъект);
	
	НачатьПомещениеФайла(Оповещение,,, Истина, УникальныйИдентификатор); 
	
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура СсылкаНаКартинкуНажатиеЗавершение(Результат, Адрес, ПомещаемыйФайл, ДополнительныеПараметры) Экспорт
	Если НЕ Результат Тогда 
		Возврат;
	КонецЕсли;
	
	СсылкаНаКартинку = Адрес;
	
	Модифицированность = Истина;
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если ЭтоАдресВременногоХранилища(СсылкаНаКартинку) Тогда
		ТекущийОбъект.ДанныеКартинки = Новый ХранилищеЗначения(ПолучитьИзВременногоХранилища(СсылкаНаКартинку));
	КонецЕсли;
	
	Если ПустаяСтрока(СсылкаНаКартинку) Тогда
		ТекущийОбъект.ДанныеКартинки = Неопределено; 
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СсылкаНаКартинку = ПолучитьНавигационнуюСсылку(Объект.Ссылка, "ДанныеКартинки");
КонецПроцедуры

&НаКлиенте
Процедура УдалитьИзображение(Команда)
	СсылкаНаКартинку = ""; 
	Модифицированность = Истина;
КонецПроцедуры
