
Function TransactionStatusValueByName(Name) Export
	
	Var EnumStruc;
	
	EnumStruc = New Structure;
	EnumStruc.Insert("Committed", EventLogEntryTransactionStatus.Committed);
	EnumStruc.Insert("Зафиксирована", EventLogEntryTransactionStatus.Committed);
	EnumStruc.Insert("Unfinished", EventLogEntryTransactionStatus.Unfinished);
	EnumStruc.Insert("НеЗавершена", EventLogEntryTransactionStatus.Unfinished);
	EnumStruc.Insert("NotApplicable", EventLogEntryTransactionStatus.NotApplicable);
	EnumStruc.Insert("НетТранзакции", EventLogEntryTransactionStatus.NotApplicable);
	EnumStruc.Insert("RolledBack", EventLogEntryTransactionStatus.RolledBack);
	EnumStruc.Insert("Отменена", EventLogEntryTransactionStatus.RolledBack);
	
	If IsBlankString(Name) Then
		
		Return EventLogEntryTransactionStatus.NotApplicable;
		
	Else
		
		Return EnumStruc[Name];
		
	EndIf;
	
EndFunction

Function EventLogLevelValueByName(Name) Export
	
	Var EnumStruc;
	
	EnumStruc = New Structure;
	EnumStruc.Insert("Information", EventLogLevel.Information);
	EnumStruc.Insert("Информация", EventLogLevel.Information);
	EnumStruc.Insert("Error", EventLogLevel.Error);
	EnumStruc.Insert("Ошибка", EventLogLevel.Error);
	EnumStruc.Insert("Warning", EventLogLevel.Warning);
	EnumStruc.Insert("Предупреждение", EventLogLevel.Warning);
	EnumStruc.Insert("Note", EventLogLevel.Note);
	EnumStruc.Insert("Примечание", EventLogLevel.Note);
	
	Return EnumStruc[Name];
	
EndFunction

Function TermRu2En(Term) Export 
	
	Var Terms, NewTerm;
	
	Terms = New Structure;
	Terms.Insert("ДатаНачала", "StartDate");
	Terms.Insert("ДатаОкончания", "EndDate");
	Terms.Insert("Пользователь", "User");
	Terms.Insert("Компьютер", "Computer");
	Terms.Insert("ИмяПриложения", "ApplicationName");
	Terms.Insert("Событие", "Event");
	Terms.Insert("Метаданные", "Metadata");
	Terms.Insert("РабочийСервер", "ServerName");
	Terms.Insert("ОсновнойIPПорт", "Port");
	Terms.Insert("ВспомогательныйIPПорт", "SyncPort");
	Terms.Insert("Уровень", "Level");
	Terms.Insert("Дата", "Date");
	Terms.Insert("Комментарий", "Comment");
	Terms.Insert("Данные", "Data");
	Terms.Insert("ПредставлениеДанных", "DataPresentation");
	Terms.Insert("ИмяПользователя", "UserName");
	Terms.Insert("ПредставлениеПриложения", "ApplicationPresentation");
	Terms.Insert("ПредставлениеСобытия", "EventPresentation");
	Terms.Insert("ПредставлениеМетаданных", "MetadataPresentation");
	Terms.Insert("СтатусТранзакции", "TransactionStatus");
	Terms.Insert("Транзакция", "TransactionID");
	Terms.Insert("Сеанс", "Session");
	Terms.Insert("Соединение", "Connection");
	Terms.Insert("РазделениеДанныхСеанса", "SessionDataSeparation");
	Terms.Insert("ПредставлениеРазделенияДанныхСеанса", "SessionDataSeparationPresentation");
	Terms.Insert("РазделениеДанныхСеансаЗначения", "SessionDataSeparationValues");
	
	Terms.Insert("ОбъектДоступа", "AccessObject");
	Terms.Insert("Право", "Right");
	Terms.Insert("Объект", "Object");
	Terms.Insert("Действие", "Action");
	Terms.Insert("Объекты", "Objects");
	//Terms.Insert("Данные", "Data");
	Terms.Insert("ПользовательОС", "OSUser");
	Terms.Insert("ТекущийПользовательОС", "CurrentOSUser");
	Terms.Insert("Имя", "Name");
	Terms.Insert("АутентификацияОС", "OSAuthentication");
	Terms.Insert("АутентификацияСтандартная", "StandardAuthentication");
	Terms.Insert("ЗапрещеноИзменятьПароль", "CannotChangePassword");
	Terms.Insert("ОсновнойИнтерфейс", "DefaultInterface");
	Terms.Insert("ПарольИзменен", "PasswordChanged");
	Terms.Insert("ПарольУстановлен", "PasswordIsSet");
	Terms.Insert("ПоказыватьВСпискеВыбора", "ShowInList");
	Terms.Insert("ПолноеИмя", "FullName");
	Terms.Insert("РежимЗапуска", "RunMode");
	Terms.Insert("Роли", "Roles");
	Terms.Insert("Язык", "Language");
	Terms.Insert("Ссылка", "Reference");
	Terms.Insert("ИмяПредопределенныхДанных", "PredefinedDataName");
	Terms.Insert("СтароеИмяПредопределенныхДанных", "OldPredefinedDataName");
	Terms.Insert("НовоеИмяПредопределенныхДанных", "NewPredefinedDataName");
	Terms.Insert("РазделениеДанных", "DataSeparation");
	Terms.Insert("ВидИзменения", "ChangeType");
    Terms.Insert("АутентификацияOpenID", "OpenIDAuthentication");
    Terms.Insert("ЗащитаОтОпасныхДействий", "UnsafeOperationProtection");
	Terms.Insert("Уровни", "Levels");
	Terms.Insert("ПериодРазделения", "SplitPeriod");
	Terms.Insert("ФорматЖурналаРегистрации", "EventLogStructure");
	Terms.Insert("ИмяСобытия", "EventName");
	Terms.Insert("СобытиеРегистрируется", "EventIsLogged");
	Terms.Insert("Дата", "Date");
	Terms.Insert("ВремяОжиданияБлокировки", "LockWaitTime");
	Terms.Insert("МинимальнаяДлинаПароля", "MinPswdLength");
	Terms.Insert("ПроверкаСложностиПаролей", "RequiredPswdStrength");
	Terms.Insert("ВремяЗасыпанияПассивногоСеанса", "PassiveSessionHibernateTime");
	Terms.Insert("ВремяЗавершенияСпящегоСеанса", "HibernateSessionTerminateTime");
		
	If Terms.Property(Term) Then
		NewTerm = Terms[Term];
	Else
		NewTerm = Term;
	EndIf;
	return NewTerm;
	
EndFunction

Function TermEn2Ru(Term) Export 
	
	Var Terms, NewTerm;
	
	Terms = New Structure;
	Terms.Insert("StartDate", "ДатаНачала");
	Terms.Insert("EndDate", "ДатаОкончания");
	Terms.Insert("User", "Пользователь");
	Terms.Insert("Computer", "Компьютер");
	Terms.Insert("ApplicationName", "ИмяПриложения");
	Terms.Insert("Event", "Событие");
	Terms.Insert("Metadata", "Метаданные");
	Terms.Insert("ServerName", "РабочийСервер");
	Terms.Insert("Port", "ОсновнойIPПорт");
	Terms.Insert("SyncPort", "ВспомогательныйIPПорт");
	Terms.Insert("Level", "Уровень");
	Terms.Insert("Date", "Дата");
	Terms.Insert("Comment", "Комментарий");
	Terms.Insert("Data", "Данные");
	Terms.Insert("DataPresentation", "ПредставлениеДанных");
	Terms.Insert("UserName", "ИмяПользователя");
	Terms.Insert("ApplicationPresentation", "ПредставлениеПриложения");
	Terms.Insert("EventPresentation", "ПредставлениеСобытия");
	Terms.Insert("MetadataPresentation", "ПредставлениеМетаданных");
	Terms.Insert("TransactionStatus", "СтатусТранзакции");
	Terms.Insert("TransactionID", "Транзакция");
	Terms.Insert("Session", "Сеанс");
	Terms.Insert("Connection", "Соединение");
	Terms.Insert("SessionDataSeparation", "РазделениеДанныхСеанса");
	Terms.Insert("SessionDataSeparationPresentation", "ПредставлениеРазделенияДанныхСеанса");
	Terms.Insert("SessionDataSeparationValues", "РазделениеДанныхСеансаЗначения");
	
	Terms.Insert("AccessObject", "ОбъектДоступа");
	Terms.Insert("Right", "Право");
	Terms.Insert("Object", "Объект");
	Terms.Insert("Action", "Действие");
	Terms.Insert("Objects", "Объекты");
	//Terms.Insert("Data", "Данные");
	Terms.Insert("OSUser", "ПользовательОС");
	Terms.Insert("CurrentOSUser", "ТекущийПользовательОС");
	Terms.Insert("Name", "Имя");
	Terms.Insert("OSAuthentication", "АутентификацияОС");
	Terms.Insert("StandardAuthentication", "АутентификацияСтандартная");
	Terms.Insert("CannotChangePassword", "ЗапрещеноИзменятьПароль");
	Terms.Insert("DefaultInterface", "ОсновнойИнтерфейс");
	Terms.Insert("PasswordChanged", "ПарольИзменен");
	Terms.Insert("PasswordIsSet", "ПарольУстановлен");
	Terms.Insert("ShowInList", "ПоказыватьВСпискеВыбора");
	Terms.Insert("FullName", "ПолноеИмя");
	Terms.Insert("RunMode", "РежимЗапуска");
	Terms.Insert("Roles", "Роли");
	Terms.Insert("Language", "Язык");
	Terms.Insert("Reference", "Ссылка");
	Terms.Insert("PredefinedDataName", "ИмяПредопределенныхДанных");
	Terms.Insert("OldPredefinedDataName", "СтароеИмяПредопределенныхДанных");
	Terms.Insert("NewPredefinedDataName", "НовоеИмяПредопределенныхДанных");
	Terms.Insert("DataSeparation", "РазделениеДанных");
	Terms.Insert("ChangeType", "ВидИзменения");
    Terms.Insert("OpenIDAuthentication", "АутентификацияOpenID");
    Terms.Insert("UnsafeOperationProtection", "ЗащитаОтОпасныхДействий");
	Terms.Insert("Levels", "Уровни");
	Terms.Insert("SplitPeriod", "ПериодРазделения");
	Terms.Insert("EventLogStructure", "ФорматЖурналаРегистрации");
	Terms.Insert("EventName", "ИмяСобытия");
	Terms.Insert("EventIsLogged", "СобытиеРегистрируется");
	Terms.Insert("Date", "Дата");
	Terms.Insert("LockWaitTime", "ВремяОжиданияБлокировки");
	Terms.Insert("MinPswdLength", "МинимальнаяДлинаПароля");
	Terms.Insert("RequiredPswdStrength", "ПроверкаСложностиПаролей");
	Terms.Insert("PassiveSessionHibernateTime", "ВремяЗасыпанияПассивногоСеанса");
	Terms.Insert("HibernateSessionTerminateTime", "ВремяЗавершенияСпящегоСеанса");

	If Terms.Property(Term) Then
		NewTerm = Terms[Term];
	Else
		NewTerm = Term;
	EndIf;
	return NewTerm;
	
EndFunction

Function GetColumnPresentation(ColumnName) Export 
	
	Var Names, NewTerm;
	
	Names = New Structure;
	Names.Insert("User", NStr("ru='Пользователь'; sys='EventLog.Column.Presentation.User'", "ru"));
	Names.Insert("Computer", NStr("ru='Компьютер'; sys='EventLog.Column.Presentation.Computer'", "ru"));
	Names.Insert("ApplicationName", NStr("ru='Приложения'; sys='EventLog.Column.Presentation.ApplicationName'", "ru"));
	Names.Insert("Event", NStr("ru='События'; sys='EventLog.Column.Presentation.Event'", "ru"));
	Names.Insert("Metadata", NStr("ru='Метаданные'; sys='EventLog.Column.Presentation.Metadata'", "ru"));
	Names.Insert("ServerName", NStr("ru='Рабочий сервер'; sys='EventLog.Column.Presentation.ServerName'", "ru"));
	Names.Insert("Port", NStr("ru='Основной IP порт'; sys='EventLog.Column.Presentation.Port'", "ru"));
	Names.Insert("SyncPort", NStr("ru='Вспомогательный IP порт'; sys='EventLog.Column.Presentation.SyncPort'", "ru"));
	Names.Insert("Level", NStr("ru='Важность'; sys='EventLog.Column.Presentation.Level'", "ru"));
	Names.Insert("Comment", NStr("ru='Комментарий'; sys='EventLog.Column.Presentation.Comment'", "ru"));
	Names.Insert("Data", NStr("ru='Данные'; sys='EventLog.Column.Presentation.Data'", "ru"));
	Names.Insert("DataPresentation", NStr("ru='Представление'; sys='EventLog.Column.Presentation.DataPresentation'", "ru"));
	Names.Insert("TransactionStatus", NStr("ru='Статус транзакции'; sys='EventLog.Column.Presentation.TransactionStatus'", "ru"));
	Names.Insert("TransactionID", NStr("ru='Транзакция'; sys='EventLog.Column.Presentation.TransactionID'", "ru"));
	Names.Insert("Session", NStr("ru='Сеанс'; sys='EventLog.Column.Presentation.Session'", "ru"));
	Names.Insert("SessionDataSeparation", NStr("ru='Разделение данных сеанса'; sys='EventLog.Column.Presentation.SessionDataSeparation'", "ru"));
	
	If Names.Property(ColumnName) Then
		Presentation = Names[ColumnName];
	Else
		Presentation = "";
	EndIf;
	return Presentation;
	
EndFunction

Function GetSpecialEventsName() Export
	
	Var SpecialEvents;
	
	SpecialEvents = New Array;
	SpecialEvents.Add("_$Session$_.Authentication"); 		// 0 - успешная аутентификация
	SpecialEvents.Add("_$Session$_.AuthenticationError");	// 1 - ошибка аутентификации
	SpecialEvents.Add("_$Access$_.Access");					// 2 - доступ к данным
	SpecialEvents.Add("_$Access$_.AccessDenied");			// 3 - ошибка доступа к данным
	SpecialEvents.Add("_$User$_.New");						// 4 - Пользователи.Добавление
	SpecialEvents.Add("_$User$_.Update");					// 5 - Пользователи.Изменение
	SpecialEvents.Add("_$User$_.Delete");					// 6 - Пользователи.Удаление
	SpecialEvents.Add("_$Session$_.ConfigExtensionApplyError");// 7 - ошибка применения расширения
	SpecialEvents.Add("_$InfoBase$_.ConfigExtensionUpdate");// 8 - изменение расширения конфигурации
	SpecialEvents.Add("_$InfoBase$_.DBConfigExtensionUpdate");// 9 - изменение расширения конфигурации БД
	SpecialEvents.Add("_$Data$_.SetPredefinedDataInitialization");// 10 - установка инициализации предопределенных данных
	SpecialEvents.Add("_$Data$_.PredefinedDataInitialization");// 11 - инициализация предопределенных данных
	SpecialEvents.Add("_$Data$_.NewPredefinedData");// 12 - добавление предопределенных данных
	SpecialEvents.Add("_$Data$_.UpdatePredefinedData");// 13 - изменение предопределенных данных
	SpecialEvents.Add("_$Data$_.DeletePredefinedData");// 14 - удаление преодопределенных данных
	SpecialEvents.Add("_$InfoBase$_.PredefinedDataUpdate");// 15 - обновление предопределенных данных
	//SpecialEvents.Add("_$InfoBase$_.SetPredefinedDataUpdate");// 15 - установка обновления предопределенных данных
	SpecialEvents.Add("_$User$_.NewError");// 16 - Пользователи. Ошибка добавления
	SpecialEvents.Add("_$User$_.UpdateError");// 17 - Пользователи. Ошибка изменения
	SpecialEvents.Add("_$User$_.DeleteError");// 18 - Пользователи. Ошибка удаления
	SpecialEvents.Add("_$InfoBase$_.EventLogReduce");// 19 - Информационная база. Сокращение журнала регистрации
	SpecialEvents.Add("_$InfoBase$_.EventLogReduceError");// 20 - Информационная база. Ошибка сокращения журнала регистрации
	SpecialEvents.Add("_$InfoBase$_.EventLogSettingsUpdate");// 21 - Информационная база. Изменение параметров журнала регистрации
	SpecialEvents.Add("_$InfoBase$_.EventLogSettingsUpdateError");// 22 - Информационная база. Ошибка изменения параметров журнала регистрации
	SpecialEvents.Add("_$InfoBase$_.InfoBaseAdmParamsUpdate");// 23 - Информационная база. Изменение параметров информационной базы
	SpecialEvents.Add("_$InfoBase$_.InfoBaseAdmParamsUpdateError");// 24 - Информационная база. Ошибка изменения параметров информационной базы
	SpecialEvents.Add("_$InfoBase$_.DBConfigExtensionUpdateError");// 25 - Информационная база. Ошибка изменения расширения конфигурации базы данных
	
	Return SpecialEvents;
	
EndFunction

Function GetSpecialEventPresentation(Event, ExtraData) Export
	
	Var SpecialEvents, EventData, MultiDot, Result;
	
	SpecialEvents = GetSpecialEventsName();
	// "ExtraData" not specified
	If ExtraData = Undefined Then
		Return "";
	EndIf;
	
	// property "Data" not specified in "ExtraData" structure
	If Not ExtraData.Property("Data") Then
		Return "";
	EndIf;
	
	// normal processing
	EventData = ExtraData.Data;
	MultiDot = ", ...";
	Result = "";
	If Event = SpecialEvents[0] OR Event = SpecialEvents[1] Then // auth
		If EventData.Property("Name") Then
			Result = GetKeyPresentation("Name") + ": " + EventData.Name;
		Else
			Result = GetKeyPresentation("OSUser") + ": " + EventData.OSUser;
		EndIf;
		If EventData.Count() <> 1 Then
			Result = Result + MultiDot;
		EndIf;
	ElsIf Event = SpecialEvents[2] OR Event = SpecialEvents[3] Then // access, access denied
		Result = "";
		If EventData.Property("AccessObject") Then
			Result = GetKeyPresentation("AccessObject") + ": " + GetAccessControlObjectPresentation(EventData.AccessObject);
		ElsIf EventData.Property("Right") Then
			Result = GetKeyPresentation("Right") + ": " + RightPresentation(EventData.Right);		
		ElsIf EventData.Property("Action") Then
			Result = GetKeyPresentation("Action") + ": " + GetActionPresentation(EventData.Action) + MultiDot;
		EndIf;
		If EventData.Count() <> 1 Then
			Result = Result + MultiDot;
		EndIf;
	ElsIf Event = SpecialEvents[10] OR Event = SpecialEvents[11] OR
		  Event = SpecialEvents[12] OR Event = SpecialEvents[13] OR
		  Event = SpecialEvents[14] OR Event = SpecialEvents[15] // predefined data
		  OR
		  Event = SpecialEvents[19] OR Event = SpecialEvents[20] OR
		  Event = SpecialEvents[21] OR Event = SpecialEvents[22] OR
		  Event = SpecialEvents[23] OR Event = SpecialEvents[24] Then
		Result = "...";
	ElsIf Event = SpecialEvents[4] OR Event = SpecialEvents[5] OR Event = SpecialEvents[6] Then // action with users
		Result = GetKeyPresentation("Name") + ": " + EventData.Name;
		If EventData.Count() <> 1 Then
			Result = Result + MultiDot;
		EndIf;
	ElsIf Event = SpecialEvents[7] OR Event = SpecialEvents[8] OR Event = SpecialEvents[9] Then // action with configuration extension
		Result = GetKeyPresentation("Name") + ": " + EventData.Name + MultiDot;
	EndIf;
	Return Result;
	
EndFunction

Function GetRolePresentation(RoleArray) Export
	
	Var Presentation, Role, Name, RolePresent;
	
	Presentation = "";
	For Each Role In RoleArray Do
	
		Name = GetNameFromFullName(Role);
		RolePresent = GetPresentationFromFullName("Roles", Role);
		If IsBlankString(RolePresent) Then
			
			RolePresent = String(Name) + " <" + NStr("ru = 'Удалена'; SYS = 'Processing.RoleRemoved'", "ru") + ">";
			
		EndIf;
		Presentation = Presentation + ?(IsBlankString(Presentation), "", ", ") + RolePresent;
	
	EndDo;
	
	Return Presentation;
	
EndFunction

Function GetKeyPresentation(Key) Export
	
	Var Terms, Presentation;
	
	Terms = New Structure;
	Terms.Insert("AccessObject", NStr("ru = 'Объект доступа'; sys = 'EventLog.Key.AccessObject'", "ru"));
	Terms.Insert("Right", NStr("ru = 'Право'; sys = 'EventLog.Key.Right'", "ru"));
	Terms.Insert("Object", NStr("ru = 'Объект'; sys = 'EventLog.Key.Object'", "ru"));
	Terms.Insert("Action", NStr("ru = 'Действие'; sys = 'EventLog.Key.Action'", "ru"));
	Terms.Insert("Objects", NStr("ru = 'Объекты'; sys = 'EventLog.Key.Objects'", "ru"));
	Terms.Insert("Data", NStr("ru = 'Данные'; sys = 'EventLog.Key.Data'", "ru"));
	Terms.Insert("User", NStr("ru = 'Пользователь'; sys = 'EventLog.Key.User'", "ru"));
	Terms.Insert("OSUser", NStr("ru = 'Пользователь ОС'; sys = 'EventLog.Key.OSUser'", "ru"));
	Terms.Insert("CurrentOSUser", NStr("ru = 'Текущий пользователь ОС'; sys = 'EventLog.Key.CurrentOSUser'", "ru"));
	Terms.Insert("OSAuthentication", NStr("ru = 'Аутентификация ОС'; sys = 'EventLog.Key.OSAuthentication'", "ru"));
	Terms.Insert("Name", NStr("ru = 'Имя'; sys = 'EventLog.Key.Name'", "ru"));
	Terms.Insert("StandardAuthentication", NStr("ru = 'Аутентификация 1С:Предприятия'; sys = 'EventLog.Key.StandardAuthentication'", "ru"));
	Terms.Insert("CannotChangePassword", NStr("ru = 'Запрещено изменять пароль'; sys = 'EventLog.Key.CannotChangePassword'", "ru"));
	Terms.Insert("DefaultInterface", NStr("ru = 'Основной интерфейс'; sys = 'EventLog.Key.DefaultInterface'", "ru"));
	Terms.Insert("PasswordChanged", NStr("ru = 'Пароль изменен'; sys = 'EventLog.Key.PasswordChanged'", "ru"));
	Terms.Insert("PasswordIsSet", NStr("ru = 'Пароль установлен'; sys = 'EventLog.Key.PasswordIsSet'", "ru"));
	Terms.Insert("ShowInList", NStr("ru = 'Показывать в списке выбора'; sys = 'EventLog.Key.ShowInList'", "ru"));
	Terms.Insert("FullName", NStr("ru = 'Полное имя'; sys = 'EventLog.Key.FullName'", "ru"));
	Terms.Insert("RunMode", NStr("ru = 'Режим запуска'; sys = 'EventLog.Key.RunMode'", "ru"));
	Terms.Insert("Roles", NStr("ru = 'Роли'; sys = 'EventLog.Key.Roles'", "ru"));
	Terms.Insert("Language", NStr("ru = 'Язык'; sys = 'EventLog.Key.Language'", "ru"));
	Terms.Insert("Version", NStr("ru = 'Версия'; sys = 'EventLog.Key.Version'", "ru"));
	Terms.Insert("PredefinedDataName", NStr("ru = 'Имя предопределенных данных'; sys = 'EventLog.Key.PredefinedDataName'", "ru"));
	Terms.Insert("NewPredefinedDataName", NStr("ru = 'Новое имя предопределенных данных'; sys = 'EventLog.Key.NewPredefinedDataName'", "ru"));
	Terms.Insert("OldPredefinedDataName", NStr("ru = 'Старое имя предопределенных данных'; sys = 'EventLog.Key.OldPredefinedDataName'", "ru"));
	Terms.Insert("ChangeType", NStr("ru = 'Вид изменения'; sys = 'EventLog.Key.ChangeType'", "ru"));
	Terms.Insert("Value", NStr("ru = 'Значение'; sys = 'EventLog.Key.Value'", "ru"));
	Terms.Insert("DataSeparation", NStr("ru = 'Разделение данных'; sys = 'EventLog.Key.DataSeparation'", "ru"));
	Terms.Insert("Reference", NStr("ru = 'Ссылка'; sys = 'EventLog.Key.Reference'", "ru"));
	Terms.Insert("OpenIDAuthentication", NStr("ru = 'Аутентификация OpenID'; sys = 'EventLog.Key.OpenIDAuthentication'", "ru"));
	Terms.Insert("UnsafeOperationProtection", NStr("ru = 'Защита от опасных действий'; sys = 'EventLog.Key.InteractiveSecurity'", "ru"));
	Terms.Insert("Levels",  NStr("ru = 'Уровни событий журнала регистрации'; sys = 'EventLog.Key.Levels'", "ru"));
	Terms.Insert("SplitPeriod",  NStr("ru = 'Период разделения'; sys = 'EventLog.Key.SplitPeriod'", "ru"));
	Terms.Insert("EventLogStructure",  NStr("ru = 'Формат журнала регистрации'; sys = 'EventLog.Key.EventLogStructure'", "ru"));
	Terms.Insert("EventName",  NStr("ru = 'Имя события'; sys = 'EventLog.Key.EventName'", "ru"));
	Terms.Insert("EventIsLogged",  NStr("ru = 'Событие регистрируется'; sys = 'EventLog.Key.EventIsLogged'", "ru"));
	Terms.Insert("Date",  NStr("ru = 'Дата'; sys = 'EventLog.Key.Date'", "ru"));
	Terms.Insert("LockWaitTime",  NStr("ru = 'Время ожидания блокировки (в секундах)'; sys = 'EventLog.Key.LockWaitTime'", "ru"));
	Terms.Insert("MinPswdLength",  NStr("ru = 'Минимальная длина пароля'; sys = 'EventLog.Key.MinPswdLength'", "ru"));
	Terms.Insert("RequiredPswdStrength",  NStr("ru = 'Проверка сложности паролей'; sys = 'EventLog.Key.RequiredPswdStrength'", "ru"));
	Terms.Insert("PassiveSessionHibernateTime",  NStr("ru = 'Время засыпания пассивного сеанса (в секундах)'; sys = 'EventLog.Key.PassiveSessionHibernateTime'", "ru"));
	Terms.Insert("HibernateSessionTerminateTime",  NStr("ru = 'Время завершения спящего сеанса (в секундах)'; sys = 'EventLog.Key.HibernateSessionTerminateTime'", "ru"));
	
	If Terms.Property(Key) Then
		Presentation = Terms[Key];
	Else
		Presentation = Key;
	EndIf;
	Return Presentation;
	
EndFunction

Function GetActionPresentation(Val Action) Export
	
	Var Presentation;
	
	Action = Lower(Action);
	Presentation = "<unknown>";
	If Action = "read" OR Action = "чтение" Then
		Presentation = NStr("ru = 'Чтение'; sys = 'EventLog.Action.Read'", "ru");
	ElsIf Action = "update" OR Action = "изменение" Then
		Presentation = NStr("ru = 'Изменение'; sys = 'EventLog.Action.Update'", "ru");
	ElsIf Action = "insert" OR Action = "добавление" Then
		Presentation = NStr("ru = 'Добавление'; sys = 'EventLog.Action.Insert'", "ru");
	ElsIf Action = "delete" OR Action = "удаление" Then
		Presentation = NStr("ru = 'Удаление'; sys = 'EventLog.Action.Delete'", "ru");
	ElsIf Action = "write" OR Action = "запись" Then
		Presentation = NStr("ru = 'Запись'; sys = 'EventLog.Action.Write'", "ru");
	EndIf;
	Return Presentation;
	
EndFunction

Function GetAccessControlObjectPresentation(Val Object) Export
	
	Var Presentation;
	
	Presentation = "<unknown>";
	If Object = "DBConfig" OR Object = "КонфигурациияБазыДанных" Then
		Presentation = NStr("ru = 'Конфигурация базы данных'; sys = 'EventLog.AccessControlObject.DatabaseConfiguration'", "ru");
	ElsIf Object = "InfoBaseUsers" OR Object = "ПользователиИнформационнойБазы" Then
		Presentation = NStr("ru = 'Пользователи информационной базы'; sys = 'EventLog.AccessControlObject.InfobaseUsers'", "ru");
	ElsIf Object = "ActiveUserList" OR Object = "СписокАктивныхПользователей" Then
		Presentation = NStr("ru = 'Список активных пользователей'; sys = 'EventLog.AccessControlObject.ActiveUsersList'", "ru");
	ElsIf Object = "InfoBase" OR Object = "ИнформационнаяБаза" Then
		Presentation = NStr("ru = 'Информационная база'; sys = 'EventLog.AccessControlObject.Infobase'", "ru");
	ElsIf Object = "EventLogRecords" OR Object = "ЗаписиЖурналаРегистрации" Then
		Presentation = NStr("ru = 'Записи журнала регистрации'; sys = 'EventLog.AccessControlObject.EventLogRecords'", "ru");
	ElsIf Object = "EventLogSettings" OR Object = "НастройкиЖурналаРегистрации" Then
		Presentation = NStr("ru = 'Настройки журнала регистрации'; sys = 'EventLog.AccessControlObject.EventLogSettings'", "ru");
	ElsIf Object = "InfoBaseAdmParams" OR Object = "ПараметрыИнформационнойБазы" Then
		Presentation = NStr("ru = 'Параметры информационной базы'; sys = 'EventLog.AccessControlObject.InfobaseSettings'", "ru");
	EndIf;
	Return Presentation;
	
EndFunction

Function GetPresentationFromFullName(ClassName, FullName) Export
	
	Var Name, Object;
	
	Name = GetNameFromFullName(FullName);
	If IsBlankString(Name) Then
		Return "";
	EndIf;
	Object = Metadata[ClassName].Find(Name);
	If Object = Undefined Then
		Return "";
	Else
		Return Object.Presentation();
	EndIf;
	
EndFunction

Function GetDBUserName(UserUID, LogUserName, ForFilter = False) Export
	
	Var DBUserName, EmptyUUID, DBUser;
	
	DBUserName = "Unknown";
	
	SetPrivilegedMode(True);
	EmptyUUID = New UUID("00000000-0000-0000-0000-000000000000");
	DBUser = Undefined;
	
	If UserUID <> Undefined Then
		DBUser = InfoBaseUsers.FindByUUID(UserUID);
	EndIf;
	
	SetPrivilegedMode(False);
	If (UserUID = Undefined OR UserUID = EmptyUUID) AND IsBlankString(LogUserName) Then
		DBUserName = "<" + NStr("ru = 'Неопределен'; SYS = 'Processing.UserNotDefined'", "ru") + ">";
	ElsIf DBUser = Undefined AND Not IsBlankString(LogUserName) Then
		DBUserName = LogUserName + " <" + NStr("ru = 'не найден'; SYS = 'Processing.UserRemoved'", "ru") + ">";
	ElsIf  DBUser <> Undefined AND Not IsBlankString(LogUserName) Then
		DBUserName = LogUserName;
	ElsIf IsBlankString(LogUserName) Then
		If ForFilter Then
			DBUserName = "<" + NStr("ru = 'Пользователь не задан'; SYS = 'Processing.DefaultUser'", "ru") + ">";
		Else
			DBUserName = "";
		EndIf;
	Else
		If ForFilter Then
			DBUserName = "<" + NStr("ru = 'Неопределен'; SYS = 'Processing.UserNotDetected'", "ru") + "> " + String(UserUID);
		Else
			DBUserName = "<" + NStr("ru = 'Неопределен'; SYS = 'Processing.UserNotDefined'", "ru") + ">";
		EndIf;
	EndIf;
	Return DBUserName;
	
EndFunction

// This function return extreme rigth part of stirng
Function GetNameFromFullName(FullName, Delimiter = ".") Export
	
	Var WorkString;
	
	WorkString = StrReplace(FullName, Delimiter, Chars.LF);
	Return StrGetLine(WorkString, StrLineCount(WorkString));
	
EndFunction

Function ConvertArrayToString(PresentationArray, Delimiter = ",") Export
	
	Var Result, PresentationItem;
	
	Result = "";
	For Each PresentationItem In PresentationArray Do
		
		Result = Result + ?(IsBlankString(Result), "", Delimiter + " ") + PresentationItem;
		
	EndDo;
	
	Return Result;
	
EndFunction

Function ConvertStructureKeyToEn(DataStructure) Export
	
	Var Terms, NewStructure, Item, NewKey;
	
	//Terms = New Structure;
	//Terms.Insert("Право", "Right");
	//Terms.Insert("Объект", "Object");
	//Terms.Insert("Действие", "Action");
	//Terms.Insert("Объекты", "Objects");
	//Terms.Insert("Данные", "Data");
	//Terms.Insert("ПользовательОС", "OSUser");
	//Terms.Insert("ТекущийПользовательОС", "CurrentOSUser");
	//Terms.Insert("Имя", "Name");
	//Terms.Insert("АутентификацияОС", "OSAuthentication");
	//Terms.Insert("АутентификацияСтандартная", "StandardAuthentication");
	//Terms.Insert("ЗапрещеноИзменятьПароль", "CannotChangePassword");
	//Terms.Insert("ОсновнойИнтерфейс", "DefaultInterface");
	//Terms.Insert("ПарольИзменен", "PasswordChanged");
	//Terms.Insert("ПарольУстановлен", "PasswordIsSet");
	//Terms.Insert("ПоказыватьВСпискеВыбора", "ShowInList");
	//Terms.Insert("ПолноеИмя", "FullName");
	//Terms.Insert("РежимЗапуска", "RunMode");
	//Terms.Insert("Роли", "Roles");
	//Terms.Insert("Язык", "Language");
	//Terms.Insert("Ссылка", "Reference");
	//Terms.Insert("ИмяПредопределенныхДанных", "PredefinedDataName");
	//Terms.Insert("СтароеИмяПредопределенныхДанных", "OldPredefinedDataName");
	//Terms.Insert("НовоеИмяПредопределенныхДанных", "NewPredefinedDataName");
	//Terms.Insert("РазделениеДанных", "DataSeparation");
	
	NewStructure = New Structure;
	For Each Item In DataStructure Do
		//NewKey = Item.Key;
		//If Terms.Property(Item.Key) Then
		//	NewKey = Terms[Item.Key];
		//EndIf;
		NewKey = TermRu2En(Item.Key);
		NewStructure.Insert(NewKey, Item.Value);			
	EndDo;
	Return NewStructure;
	
EndFunction

Function ConvertStructureKeyToRu(DataStructure) Export
	
	Var Terms, NewStructure, Item, NewKey;
	
	//Terms = New Structure;
	//Terms.Insert("Right", "Право");
	//Terms.Insert("Object", "Объект");
	//Terms.Insert("Action", "Действие");
	//Terms.Insert("Objects", "Объекты");
	//Terms.Insert("Data", "Данные");
	//Terms.Insert("OSUser", "ПользовательОС");
	//Terms.Insert("CurrentOSUser", "ТекущийПользовательОС");
	//Terms.Insert("Name", "Имя");
	//Terms.Insert("OSAuthentication", "АутентификацияОС");
	//Terms.Insert("StandardAuthentication", "АутентификацияСтандартная");
	//Terms.Insert("CannotChangePassword", "ЗапрещеноИзменятьПароль");
	//Terms.Insert("DefaultInterface", "ОсновнойИнтерфейс");
	//Terms.Insert("PasswordChanged", "ПарольИзменен");
	//Terms.Insert("PasswordIsSet", "ПарольУстановлен");
	//Terms.Insert("ShowInList", "ПоказыватьВСпискеВыбора");
	//Terms.Insert("FullName", "ПолноеИмя");
	//Terms.Insert("RunMode", "РежимЗапуска");
	//Terms.Insert("Roles", "Роли");
	//Terms.Insert("Language", "Язык");
	//Terms.Insert("Reference", "Ссылка");
	//Terms.Insert("PredefinedDataName", "ИмяПредопределенныхДанных");
	//Terms.Insert("OldPredefinedDataName", "СтароеИмяПредопределенныхДанных");
	//Terms.Insert("NewPredefinedDataName", "НовоеИмяПредопределенныхДанных");
	//Terms.Insert("DataSeparation", "РазделениеДанных");

	NewStructure = New Structure;

	For Each Item In DataStructure Do
		//NewKey = Item.Key;
		//If Terms.Property(Item.Key) Then
		//	NewKey = Terms[Item.Key];
		//EndIf;
		NewKey = TermEn2Ru(Item.Key);
		NewStructure.Insert(NewKey, Item.Value);			
	EndDo;
	Return NewStructure;
	
EndFunction

Function CopyOf(Source, ConvertNames = False) Export
	
	Var SourceType, Result, Item;
	
	SourceType = TypeOf(Source);
	Result = Source;
	// make copy of source object
	If SourceType = Type("Array") Then
		Result = New Array;
		For Each Item In Source Do
			Result.Add(CopyOf(Item));
		EndDo;
	ElsIf SourceType = Type("Structure") Then
		If ConvertNames Then
			Result = ConvertStructureKeyToEn(Source);
		Else
			Result = New Structure;
			For Each Item In Source Do
				Result.Insert(Item.Key, CopyOf(Item.Value));
			EndDo;
		EndIf;
	ElsIf SourceType = Type("Map") Then
		Result = New Map;
		For Each Item In Source Do
			If ConvertNames Then
				Result.Insert(TermRu2En(Item.Key), CopyOf(Item.Value));
			Else
				Result.Insert(Item.Key, CopyOf(Item.Value));
			EndIf;
		EndDo;
	ElsIf SourceType = Type("ValueTable") Then
		Result = Source.Copy();
		If ConvertNames Then
			For Each Column In Result.Columns Do
				Column.Name = TermRu2En(Column.Name);
			EndDo;
		EndIf;
	ElsIf SourceType = Type("ValueList") Then
		Result = New ValueList;
		For Each Item In Source Do
			Result.Add(CopyOf(Item.Value), Item.Presentation, Item.Check, Item.Picture);
		EndDo;
	EndIf;
	
	Return Result;
EndFunction

// Set filter item value into common info structure
Procedure SetFilterItems(CommonFilterInfoAddr, FilterItemsStructure) Export
	
	Var CommonFilterInfo, FilterItem;
	
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	If FilterItemsStructure.Count() = 0 Then
		CommonFilterInfo.FilterData.Clear();
	Else
		For Each FilterItem In FilterItemsStructure Do
			If FilterItem.Value = "Delete" Then
				CommonFilterInfo.FilterData.Delete(FilterItem.Key);
			Else
				CommonFilterInfo.FilterData.Insert(FilterItem.Key, FilterItem.Value);
			EndIf;
		EndDo;
	EndIf;
	PutToTempStorage(CommonFilterInfoAddr);
	
EndProcedure

// Get filter item value from common info structure
Function GetFilterItems(CommonFilterInfoAddr, FilterNamesArray) Export
	
	Var CommonFilterInfo, ResultStructure, FilterItem, ItemValue;
	
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	ResultStructure = New Structure;
	For Each FilterName In FilterNamesArray Do
	
		ItemValue = Undefined;
		CommonFilterInfo.FilterData.Property(FilterName, ItemValue);
		ResultStructure.Insert(FilterName, ItemValue);
	
	EndDo;
	
	Return ResultStructure;
	
EndFunction
