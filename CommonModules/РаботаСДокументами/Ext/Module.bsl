﻿Функция ЦенаАбонементов(АктуальнаяДата, ЭлементТипАбонемента) Экспорт 
Отбор = Новый Структура("ТипыАбонементов", ЭлементТипАбонемента);
ЗначенияРесурсов = РегистрыСведений.ЦеныНаАбонементы.ПолучитьПоследнее(АктуальнаяДата, Отбор);
Возврат ЗначенияРесурсов.Цена;
КонецФункции