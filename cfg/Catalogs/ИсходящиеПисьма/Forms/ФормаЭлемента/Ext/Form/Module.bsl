﻿&НаСервереБезКонтекста
Функция ПолучитьКонтактноеЛицоПоКонтрагенту(Контрагент)
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Контрагенты.КонтактноеЛицо
	|ИЗ
	|	Справочник.Контрагенты КАК Контрагенты
	|ГДЕ
	|	Контрагенты.Ссылка = &Контрагент";
	Запрос.Параметры.Вставить("Контрагент", Контрагент);
	Выборка = Запрос.Выполнить().Выбрать();
	КонтактноеЛицо = "";
	Если Выборка.Следующий() Тогда
		КонтактноеЛицо = Выборка.КонтактноеЛицо;
	КонецЕсли;
	Возврат КонтактноеЛицо;
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьАдресЭлектроннойПочты(Контрагент)
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Контрагенты.ЭлектроннаяПочта
	|ИЗ
	|	Справочник.Контрагенты КАК Контрагенты
	|ГДЕ
	|	Контрагенты.Ссылка = &Контрагент";
	Запрос.Параметры.Вставить("Контрагент", Контрагент);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ЭлектроннаяПочта;
	Иначе
		Возврат "";
	КонецЕсли;
КонецФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Ключ.Пустая() Тогда
		Заголовок = "Исходящее письмо (Создание)";
		Объект.Дата = ТекущаяДата();
		ПоШаблону = Параметры.Свойство("ПоШаблону");
		ВходящееПисьмо = Параметры.ВходящееПисьмо;
		Если ПоШаблону = Истина Тогда
			Элементы.ЗаполнитьПоШаблону.Видимость = Истина;
			РаботаСПочтой.ЗаполнитьПисьмоПоШаблону(Объект, Содержимое);
		ИначеЕсли Не ВходящееПисьмо.Пустая() Тогда
			РаботаСПочтой.ЗаполнитьОтветНаПисьмо(ВходящееПисьмо, Объект, Содержимое);
		КонецЕсли;
		Адресаты = Параметры.Адресаты;
		Если Адресаты <> Неопределено Тогда
			Запрос = Новый Запрос;
			Запрос.Текст = 
			"ВЫБРАТЬ
			|	Контрагенты.ЭлектроннаяПочта
			|ИЗ
			|	Справочник.Контрагенты КАК Контрагенты
			|ГДЕ
			|	Контрагенты.Ссылка В(&Адресаты)
			|	И Контрагенты.ЭлектроннаяПочта <> """"";
			Запрос.УстановитьПараметр("Адресаты", Адресаты);
			Получатели = Запрос.Выполнить().Выгрузить();
			Объект.Получатели.Загрузить(Получатели);
		КонецЕсли;
	ИначеЕсли Объект.Получатели.Количество() = 0 И НЕ ПустаяСтрока(Объект.Получатель) Тогда
		МассивАдресов = СтрРазделить(Объект.Получатель, ";");
		Для каждого ЭлектроннаяПочта из МассивАдресов Цикл
			ЭлектроннаяПочта = СокрЛП(ЭлектроннаяПочта);
			Получатель = Объект.Получатели.Добавить();
			Получатель.ЭлектроннаяПочта = ЭлектроннаяПочта;
		КонецЦикла;
	КонецЕсли;
	
	Элементы.Получатели.РасширенноеРедактированиеМножественныхЗначений = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Содержимое = ТекущийОбъект.Содержимое.Получить();
	Заголовок = ТекущийОбъект.Наименование + " (Исходящее письмо)";
	Если  РаботаСПочтой.ПисьмоОтправлено(ТекущийОбъект.Ссылка) Тогда
		Заголовок = Заголовок + " - Отправлено";
	КонецЕсли;
	
	РаботаСПочтойВызовСервера.ПроверитьАдресаПолучателей(Объект.Получатели);
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	ТекущийОбъект.Содержимое = Новый ХранилищеЗначения(Содержимое, Новый СжатиеДанных());
	ТекущийОбъект.Текст = Содержимое.ПолучитьТекст();
КонецПроцедуры

&НаСервере
Функция ОтправитьПисьмо(Ошибка)
	Если Не Записать() Тогда
		Ошибка = "ОшибкаЗаписи";
		Возврат Ложь;
	КонецЕсли;
	Если Не РаботаСПочтой.ОтправитьПисьмо(Объект.Ссылка) Тогда
		Ошибка = "ОшибкаОтправки";
		Возврат Ложь;
	КонецЕсли;
	Заголовок = Заголовок + " - Отправлено";
	Возврат Истина;
КонецФункции

&НаКлиенте
Асинх Функция ОтправитьПисьмоКлиент()
	Ошибка = "";
	Если Не ОтправитьПисьмо(Ошибка) Тогда
		Если Ошибка = "ОшибкаОтправки" Тогда
			Кнопки = Новый СписокЗначений;
			Кнопки.Добавить(1, НСтр("ru = 'Настроить почту'"));
			Кнопки.Добавить(2, НСтр("ru = 'Закрыть'"));
			РезультатВопросаОНастройке = Ждать ВопросАсинх(НСтр("ru = 'Не указаны настройки интернет почты!'"),
				Кнопки,
				,
				1);
			Если РезультатВопросаОНастройке = 1 Тогда
				ОткрытьФорму("ОбщаяФорма.НастройкаПочты");
			КонецЕсли;
		КонецЕсли;
		Возврат Ложь;
	КонецЕсли;
	НавигационнаяСсылка = ПолучитьНавигационнуюСсылку(Объект.Ссылка);
	ПоказатьОповещениеПользователя("Письмо отправлено", НавигационнаяСсылка, Объект.Наименование);
	ОповеститьОбИзменении(Объект.Ссылка);
	Возврат Истина;
КонецФункции

&НаКлиенте
Процедура ОтправитьПисьмоКлиентВопросЗавершение(Результат, Параметры) Экспорт
	Если Результат = 1 Тогда
		ОткрытьФорму("ОбщаяФорма.НастройкаПочты");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Отправить(Команда)
	ОтправитьПисьмоКлиент();
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьИЗакрыть(Команда)
	АсинхОтправитьИЗакрыть();
КонецПроцедуры

&НаКлиенте
Асинх Процедура АсинхОтправитьИЗакрыть()
	Если Не Ждать ОтправитьПисьмоКлиент() Тогда
		Возврат;
	КонецЕсли;
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ВставитьСтрокуВТекущуюПозицию(Поле, Документ, Строка)
	Перем Начало, Конец;
	
	Поле.ПолучитьГраницыВыделения(Начало, Конец);
	Позиция = Документ.ПолучитьПозициюПоЗакладке(Начало);
	Документ.Удалить(Начало, Конец);
	Начало = Документ.ПолучитьЗакладкуПоПозиции(Позиция);
	Документ.Вставить(Начало, Строка);
	Позиция = Позиция + СтрДлина(Строка);
	Закладка = Документ.ПолучитьЗакладкуПоПозиции(Позиция);
	Поле.УстановитьГраницыВыделения(Закладка, Закладка);
КонецПроцедуры

&НаКлиенте
Процедура ВставитьКонтактноеЛицо(Команда)
	Если Объект.Контрагент.Пустая() Тогда
		Сообщить("Выберите контрагента");
	Иначе
		КонтактноеЛицо = ПолучитьКонтактноеЛицоПоКонтрагенту(Объект.Контрагент);
		ВставитьСтрокуВТекущуюПозицию(Элементы.Содержимое, Содержимое, КонтактноеЛицо + " ");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	Заголовок = ТекущийОбъект.Наименование + " (Исходящее письмо)";
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	
	ЭлектроннаяПочта = ПолучитьАдресЭлектроннойПочты(Объект.Контрагент);
	
	Если НЕ ПустаяСтрока(ЭлектроннаяПочта) Тогда
		ОтборСтрок = Новый Структура("ЭлектроннаяПочта", ЭлектроннаяПочта);
		Если Объект.Получатели.НайтиСтроки(ОтборСтрок).Количество() = 0 Тогда
			Стр = Объект.Получатели.Добавить();
			Стр.ЭлектроннаяПочта = ЭлектроннаяПочта;
			ПроверитьЭлектроннуюПочту();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыделитьВажное(Команда)
	Перем Начало, Конец;
	
	ВсеВажное = Истина;
	Элементы.Содержимое.ПолучитьГраницыВыделения(Начало, Конец);
	Если Начало = Конец Тогда
		Возврат;
	КонецЕсли;
	
	НаборТекстовыхЭлементов = Новый Массив();
	Для Каждого ТекстовыйЭлемент Из Содержимое.СформироватьЭлементы(Начало, Конец) Цикл
		Если Тип(ТекстовыйЭлемент) = Тип("ТекстФорматированногоДокумента") Тогда
			НаборТекстовыхЭлементов.Добавить(ТекстовыйЭлемент);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ТекстовыйЭлемент Из НаборТекстовыхЭлементов Цикл
		Если ТекстовыйЭлемент.Шрифт.Жирный <> Истина И
			ТекстовыйЭлемент.ЦветТекста <> Новый Цвет(255, 0, 0) Тогда
			ВсеВажное = Ложь;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ТекстовыйЭлемент Из НаборТекстовыхЭлементов Цикл
		ТекстовыйЭлемент.Шрифт = Новый Шрифт(ТекстовыйЭлемент.Шрифт, , , Не ВсеВажное);
		ТекстовыйЭлемент.ЦветТекста = Новый Цвет(?(ВсеВажное, 0, 255), 0, 0);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПоШаблону(Команда)
	Если Объект.Контрагент.Пустая() Тогда
		Сообщить("Выберите контрагента");
	Иначе
		НайтиИЗаменить("[Контрагент]", Объект.Контрагент);
		НайтиИЗаменить("[КонтактноеЛицо]", ПолучитьКонтактноеЛицоПоКонтрагенту(Объект.Контрагент));
	КонецЕсли;
	НайтиИЗаменить("[ДатаПисьма]", Объект.Дата);
КонецПроцедуры

&НаКлиенте
Процедура НайтиИЗаменить(СтрокаДляПоиска, СтрокаДляЗамены)
	Перем ВставленныйТекст, ШрифтОформления, ЦветТекстаОформления, ЦветФонаОформления, НавигационнаяСсылкаОформления;
	
	РезультатПоиска = Содержимое.НайтиТекст(СтрокаДляПоиска);
	Пока ((РезультатПоиска <> Неопределено) И (РезультатПоиска.ЗакладкаНачала <> Неопределено) И (РезультатПоиска.ЗакладкаКонца <> Неопределено)) Цикл
		ПозицияНачалаСледующегоЦиклаПоиска = Содержимое.ПолучитьПозициюПоЗакладке(РезультатПоиска.ЗакладкаНачала) + СтрДлина(СтрокаДляЗамены);
		МассивЭлементовДляОформления = Содержимое.ПолучитьЭлементы(РезультатПоиска.ЗакладкаНачала, РезультатПоиска.ЗакладкаКонца);
		Для Каждого ЭлементДляОформления Из МассивЭлементовДляОформления Цикл
			Если Тип(ЭлементДляОформления) = Тип("ТекстФорматированногоДокумента") Тогда
				ШрифтОформления = ЭлементДляОформления.Шрифт;
				ЦветТекстаОформления = ЭлементДляОформления.ЦветТекста;
				ЦветФонаОформления = ЭлементДляОформления.ЦветФона;
				НавигационнаяСсылкаОформления = ЭлементДляОформления.НавигационнаяССылка;
				Прервать;
			КонецЕсли;
		КонецЦикла;	
		Содержимое.Удалить(РезультатПоиска.ЗакладкаНачала, РезультатПоиска.ЗакладкаКонца);
		ВставленныйТекст = Содержимое.Вставить(РезультатПоиска.ЗакладкаНачала, СтрокаДляЗамены);
		Если ВставленныйТекст <> Неопределено И ШрифтОформления <> Неопределено Тогда
			ВставленныйТекст.Шрифт = ШрифтОформления;
		КонецЕсли;
		Если ВставленныйТекст <> Неопределено И ЦветТекстаОформления <> Неопределено Тогда
			ВставленныйТекст.ЦветТекста = ЦветТекстаОформления;
		КонецЕсли;
		Если ВставленныйТекст <> Неопределено И ЦветФонаОформления <> Неопределено Тогда
			ВставленныйТекст.ЦветФона = ЦветФонаОформления;
		КонецЕсли;
		Если ВставленныйТекст <> Неопределено И НавигационнаяСсылкаОформления <> Неопределено Тогда
			ВставленныйТекст.НавигационнаяССылка = НавигационнаяСсылкаОформления;
		КонецЕсли;
		
		РезультатПоиска = Содержимое.НайтиТекст(СтрокаДляПоиска, Содержимое.ПолучитьЗакладкуПоПозиции(ПозицияНачалаСледующегоЦиклаПоиска));
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если Модифицированность Тогда
		Отказ = Истина;
		Если НЕ ЗавершениеРаботы Тогда
			СтандартнаяОбработка = Ложь;
			ДействияПриМодифицирпрванностиПисьмаПриПродолженииРаботы();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ДействияПриМодифицирпрванностиПисьмаПриПродолженииРаботы()
	Текст = НСтр("ru='Письмо было изменено. Сохранить изменения?'", "ru");
	Режим = РежимДиалогаВопрос.ДаНетОтмена;
	РезультатВопросаОСохраненииИзменений = Ждать ВопросАсинх(Текст, Режим, 0);
	Если РезультатВопросаОСохраненииИзменений = КодВозвратаДиалога.Да Тогда
		Записать();
		Модифицированность = Ложь;
		Закрыть();
	ИначеЕсли РезультатВопросаОСохраненииИзменений = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьЭлектроннуюПочту()
	
	МассивДляПроверки = Новый Массив;
	Для каждого Получатель из Объект.Получатели Цикл
		ПроверяемыйЭлемент = Новый Структура("ЭлектроннаяПочта, СодержитОшибку");
		ЗаполнитьЗначенияСвойств(ПроверяемыйЭлемент, Получатель);
		МассивДляПроверки.Добавить(ПроверяемыйЭлемент);
	КонецЦикла;
	РаботаСПочтойВызовСервера.ПроверитьАдресаПолучателей(МассивДляПроверки);
	Для Индекс = 0 По МассивДляПроверки.ВГраница() Цикл
		Объект.Получатели[Индекс].СодержитОшибку = МассивДляПроверки[Индекс].СодержитОшибку;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучательПриИзменении(Элемент)

	ПроверитьЭлектроннуюПочту();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПроверитьДобавляемыеАдреса(ДобавляемыеАдреса)
	
	Для каждого ЭлектроннаяПочта из ДобавляемыеАдреса Цикл
		РаботаСПочтойВызовСервера.ПроверитьЭлектронныйАдрес(ЭлектроннаяПочта);
	КонецЦикла;
	
КонецПроцедуры	
	
&НаКлиенте
Процедура ПолучателиДобавлениеМножественныхЗначений(Элемент, Значения, СтандартнаяОбработка)

	ДобавляемыеАдреса = Новый Массив;
	Для каждого ВведенноеЗначение из Значения Цикл
		МассивАдресов = СтрРазделить(ВведенноеЗначение, ";");
		Для каждого ЭлектроннаяПочта из МассивАдресов Цикл
			ЭлектроннаяПочта = СокрЛП(ЭлектроннаяПочта);
			Если НЕ ПустаяСтрока(ЭлектроннаяПочта) Тогда
				ДобавляемыеАдреса.Добавить(ЭлектроннаяПочта);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	ПроверитьДобавляемыеАдреса(ДобавляемыеАдреса);
	Значения = ДобавляемыеАдреса;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучателиОткрытиеМножественногоЗначения(Элемент, Идентификатор, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Стр = Объект.Получатели.НайтиПоИдентификатору(Идентификатор);
	Если Стр <> Неопределено Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПослеРедактированияЭлектроннойПочты", ЭтотОбъект, Стр);
		ПоказатьВводСтроки(ОписаниеОповещения, Стр.ЭлектроннаяПочта, "Адрес электронной почты");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеРедактированияЭлектроннойПочты(ЭлектроннаяПочта, ДополнительныеПараметры) Экспорт
	
	Если ЭлектроннаяПочта <> Неопределено Тогда
		ЭлектроннаяПочта = СокрЛП(ЭлектроннаяПочта);
		РаботаСПочтойВызовСервера.ПроверитьЭлектронныйАдрес(ЭлектроннаяПочта);
		ДополнительныеПараметры.ЭлектроннаяПочта = ЭлектроннаяПочта;
		ПроверитьЭлектроннуюПочту();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучателиАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = РаботаСПочтойВызовСервера.ПолучитьАдресаЭлектроннойПочты(Текст);
КонецПроцедуры
