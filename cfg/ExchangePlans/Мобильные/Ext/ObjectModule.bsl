﻿
Процедура ПриОтправкеДанныхПодчиненному(ЭлементДанных, ОтправкаЭлемента, СозданиеНачальногоОбраза)
	
	Если НЕ ОбменМобильныеПереопределяемый.НуженПереносДанных(ЭлементДанных, ЭтотОбъект) Тогда
		// Получаем значение с возможным удалением данных
		ОтправкаЭлемента = ОтправкаЭлементаДанных.Удалить;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередСозданиемНачальногоОбраза(ТолькоЗарегистрированные, ПотокОбменаДанными)
    ОбменМобильныеПереопределяемый.СформироватьЗаказанныеОтчеты(ЭтотОбъект);      
КонецПроцедуры

Процедура ПередНачаломОтправкиДанныхПодчиненному(ПотокОбменаДанными)
    ОбменМобильныеПереопределяемый.СформироватьЗаказанныеОтчеты(ЭтотОбъект);      
КонецПроцедуры

