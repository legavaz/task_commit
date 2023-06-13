
&AtServer
Procedure OnCreateAtServer(Cancel, Standard)
	
	Var ItemsList, CommonFilterInfo, UserName, FilterByUser, ByUser;
	Var FormDataSettings, Value, AboutFile, TempJournal, BinData;
	Var ConnectionString;
	
	ConnectionString = InfoBaseConnectionString();
	If Find(ConnectionString, "File=") <> 0 Then
		IsFileDB = True;
	Else
		IsFileDB = False;
	EndIf;
	ItemsList = Items.VisibleEventsNumber.ChoiceList;
	ItemsList.Clear();
	ItemsList.Add(  200, NStr("ru = '200 событий'; sys= 'View200Events'", "ru"));
	ItemsList.Add(  500, NStr("ru = '500 событий'; sys= 'View500Events'", "ru"));
	ItemsList.Add( 1000, NStr("ru = '1000 событий'; sys= 'View1000Events'", "ru"));
	ItemsList.Add(10000, NStr("ru = '10000 событий'; sys= 'View10000Events'", "ru"));
	If Not AccessRight("EventLog", Metadata) Then
		Cancel = True;
		Return;
	EndIf;
	Items.ViewActiveUserList.Enabled = AccessRight("ActiveUsers", Metadata);
	MetaPath = FormAttributeToValue("Object").Metadata().FullName();
		
	// prepare common info structure for stored and future used
	CommonFilterInfo = New Structure;
	CommonFilterInfo.Insert("FilterData", New Structure);
	CommonFilterInfo.Insert("FilterDataPresentation", "");
	CommonFilterInfo.Insert("SessionDataFilterPresentation", "");
	CommonFilterInfo.Insert("JournalFileName", ""); // имя файла для отображения
	CommonFilterInfo.Insert("JournalDataFileName", ""); // имя временного файла с реальными данными
	CommonFilterInfo.Insert("MetaPath", MetaPath);
	
	If Parameters.User <> Undefined Then
		UserName = Parameters.User;
		FilterByUser = New ValueList;
		ByUser = FilterByUser.Add(UserName);
		If IsBlankString(UserName) Then
			ByUser.Presentation = "";
		Else
			ByUser.Presentation = UserName;
		EndIf;
		CommonFilterInfo.FilterData.Insert("User", FilterByUser);
	EndIf;
	
	If Not IsBlankString(Parameters.JournalFile) Then
		// выполняется просмотр журнала из файла - надо достать этот
		// файл из временного хранилища и потом не забыть удалить его
		CommonFilterInfo.JournalFileName = Parameters.JournalFile;
		If IsTempStorageURL(Parameters.JournalAddress) Then
			// получим расширение файла, это надо для корректной работы
			AboutFile = New File(Parameters.JournalFile);
			TempJournal = GetTempFileName(AboutFile.Extension);
			// файл приехал на сервер во временном хранилище
			BinData = GetFromTempStorage(Parameters.JournalAddress);
			BinData.Write(TempJournal);
			CommonFilterInfo.JournalDataFileName = TempJournal;
		Else
			// файл смотрится в локальной базе, ничего не ездит через временное хранилище
			CommonFilterInfo.JournalDataFileName = Parameters.JournalFile;
		EndIf;
		Title = NStr("ru='Файл журнала:';SYS='Processing.JournalFileTitle'", "ru") + " " + CommonFilterInfo.JournalFileName;
	EndIf;
	
	VisibleEventsNumber = 200;
	If Metadata.ScriptVariant = Metadata.ObjectProperties.ScriptVariant.English Then
		FormDataSettings = SystemSettingsStorage.Load(ThisForm.FormName + "/CurrentData");
	Else
		FormDataSettings = SystemSettingsStorage.Load(ThisForm.FormName + "/ТекущиеДанные");
	EndIf;
	
	If TypeOf(FormDataSettings) = Type("Map") Then
		Value = FormDataSettings.Get("VisibleEventsNumber");
		If Value <> Undefined Then
			VisibleEventsNumber = Value;
		EndIf;
	EndIf;
	// store common info
	CommonFilterInfoAddr = PutToTempStorage(CommonFilterInfo, UUID);
	IsRefreshNeed = True;
	
EndProcedure

&AtServer
Function GetEventLogFilterValuesEnglishKeys(columns, inputFileName = Undefined)
	
	Var Processing, FiterParametersStucture, StructItem;
	
	Processing = FormAttributeToValue("Object");
	FiterParametersStucture = GetEventLogFilterValues(columns, inputFileName);
	For Each StructItem In FiterParametersStucture Do
		FiterParametersStucture.Delete(StructItem.Key);
		FiterParametersStucture.Insert(Processing.TermRu2En(StructItem.Key), StructItem.Value);
	EndDo;
	Return FiterParametersStucture;
	
EndFunction

&AtServer
Procedure SetFilterItems(CommonFilterInfoAddr, FilterItemsStructure)
	
	Var Processing;
	
	Processing = FormAttributeToValue("Object");
	Processing.SetFilterItems(CommonFilterInfoAddr, FilterItemsStructure);
	
EndProcedure

&AtServer
Function GetFilterItems(CommonFilterInfoAddr, FilterNamesArray)
	
	Var Processing;
	
	Processing = FormAttributeToValue("Object");
	Return Processing.GetFilterItems(CommonFilterInfoAddr, FilterNamesArray);
	
EndFunction

&AtClient
Procedure OnOpen(Cancel)
	
	IsRefreshNeed = False;
	RefreshList();
	AttachIdleHandler("IdleHandler", 0.1, True);
	
EndProcedure

&AtClient
Procedure IdleHandler()
	
	If IsRefreshNeed Then
		RefreshList();
		IsRefreshNeed = False;
	EndIf;
	AttachIdleHandler("IdleHandler", 0.1, True);
	
EndProcedure

&AtClient
Procedure OnClose()
	
	If Not IsBlankString(JournalFileName) Then
		OnCloseAtServer(JournalDataFileName);
	EndIf;
	
EndProcedure

&AtServerNoContext
Procedure OnCloseAtServer(FileName)
	
	// удалим временный файл с журналом, он нам больше не нужен
	// мусор после себя оставлять плохо
	DeleteFiles(FileName);
	
EndProcedure

&AtClient
Procedure ShowCurrentEventInSeparateWindow()
	
	Var CurData, DialogName, ViewEvent;
	
	CurData = Items.Journal.CurrentData;
	If CurData = Undefined Then
		Return;
	EndIf;
	DialogName = GetFormName("EventForm");
	If DialogName = Undefined Then
		Return;
	EndIf;
	ViewEvent = GetEventByID(CurData.EventID);
	OpenForm(DialogName, New Structure("ViewEvent", ViewEvent), ThisForm, "" + CurData.Date + CurData.Event);
	
EndProcedure

&AtClient
Function GetEventByID(EventID) Export
	
	Var Results, ViewEvent;
	
	Results = Journal.FindRows(New Structure("EventID", EventID));
	If Results.Count() = 0 Then
		Return Undefined;
	EndIf;
	Items.Journal.CurrentRow = Results[0].GetID();
	
	ViewEvent = New Structure;
	ViewEvent.Insert("DateTime", Results[0].Date);
	ViewEvent.Insert("User", Results[0].UserName);
	ViewEvent.Insert("Application", Results[0].ApplicationPresentation);
	ViewEvent.Insert("Computer", Results[0].Computer);
	ViewEvent.Insert("Event", Results[0].Event);
	ViewEvent.Insert("EventPresentation", Results[0].EventPresentation);
	ViewEvent.Insert("Comment", Results[0].Comment);
	ViewEvent.Insert("Metadata", Results[0].MetadataPresentation);
	ViewEvent.Insert("Data", Results[0].Data);
	ViewEvent.Insert("DataPresentation", Results[0].DataPresentation);
	ViewEvent.Insert("TransactionID", Results[0].TransactionID);
	ViewEvent.Insert("TransactionCompleteStatus", Results[0].TransactionStatus);
	ViewEvent.Insert("Session", Format(Results[0].Session, "NG=0"));
	ViewEvent.Insert("ServerName", Results[0].ServerName);
	ViewEvent.Insert("Port", Format(Results[0].Port, "NG=0"));
	ViewEvent.Insert("SyncPort", Format(Results[0].SyncPort, "NG=0"));
	ViewEvent.Insert("TempStorageAddr", Results[0].TempStorageAddr);
	ViewEvent.Insert("CurrentID", EventID);
	ViewEvent.Insert("EventsCount", Journal.Count());
	ViewEvent.Insert("IsSessionData", IsSessionData);
	
	Return ViewEvent;
	
EndFunction

&AtClient
Procedure SetDateInterval()
	
	Var Dialog, ParamNames, Params, StartDate, EndDate, Callback;
	
	Dialog = New StandardPeriodEditDialog;
	ParamNames = New Array;
	ParamNames.Add("StartDate");
	ParamNames.Add("EndDate");
	Params = GetFilterItems(CommonFilterInfoAddr, ParamNames);

	StartDate = ?(TypeOf(Params.StartDate) = Type("Date"), Params.StartDate, '00010101000000');
	EndDate = ?(TypeOf(Params.EndDate) = Type("Date"), Params.EndDate, '00010101000000');
	If DateInterval.StartDate <> StartDate Then
		DateInterval.StartDate = StartDate;
	EndIf;
	If DateInterval.EndDate <> EndDate Then
		DateInterval.EndDate = EndDate;
	EndIf;
	Dialog.Period = DateInterval;
	
	ExtraParameters = New Structure;
	ExtraParameters.Insert("Dialog", Dialog);
	ExtraParameters.Insert("Params", Params);
	Callback = New NotifyDescription("SetDateIntervalCallback", ThisForm, ExtraParameters);
	Dialog.Show(Callback);
	
EndProcedure

&AtClient
Procedure SetDateIntervalCallback(Result, ExtraParameters) Export
	
	Var Dialog, Params;
	
	Dialog = ExtraParameters.Dialog;
	Params = ExtraParameters.Params;
	If Result <> Undefined Then
		DateInterval = Dialog.Period;
		If DateInterval.StartDate = '00010101000000' Then
			Params.StartDate = "Delete";
		Else
			Params.StartDate = DateInterval.StartDate;
		EndIf;
		If DateInterval.EndDate = '00010101000000' Then
			Params.EndDate = "Delete";
		Else
			Params.EndDate = DateInterval.EndDate;
		EndIf;
		SetFilterItems(CommonFilterInfoAddr, Params);
		RefreshList();
	EndIf;
	
EndProcedure

&AtClient
Procedure SetFilter()
	
	Var DialogName, FormParameter, FilterForm, Callback;
	
	DialogName = GetFormName("EventsJournalFilter");
	If DialogName = Undefined Then
		Return;
	EndIf;
	
	FormParameter = New Structure;
	FormParameter.Insert("CommonFilterInfoAddr", CommonFilterInfoAddr);
	FormParameter.Insert("IsSessionData", IsSessionData);
	FilterForm   = GetForm(DialogName, FormParameter);
	Callback = New NotifyDescription("SetFilterCallback", ThisForm);
	FilterForm.OnCloseNotifyDescription = Callback;
	FilterForm.Open();
	
EndProcedure

&AtClient
Procedure SetFilterCallback(Result, ExtraParameters) Export
	
	If Result = DialogReturnCode.OK Then
		RefreshList();
	EndIf;
	
EndProcedure

&AtClient
Procedure ClearFilter()
	
	SetFilterItems(CommonFilterInfoAddr, New Structure);
	RefreshList();
	
EndProcedure

&AtClient
Procedure ActiveUsersList()
	
	Var ActiveUsersFormName;
	
	ActiveUsersFormName = GetActiveUsersFormName();
	If Not ActiveUsersFormName = Undefined Then
		OpenForm(ActiveUsersFormName);
	EndIf;
	
EndProcedure

&AtClient
Procedure RefreshList() Export
	
	Status(NStr("ru='Выполняется обновление журнала регистрации...';SYS='MFModule.EventLogJournalRefreshInProgress'", "ru"));
	FillJournalList();
	Status(NStr("ru='Завершено обновление журнала регистрации';SYS='MFModule.EventLogJournalRefreshComplete'", "ru"));
	
	If Journal.Count() Then
		Items.Journal.CurrentRow = Journal[Journal.Count() - 1].GetId();
	EndIf;
	
EndProcedure

&AtClient
Procedure OnChangeVisibleEventsNumber(Item)
	
	RefreshList();
	
EndProcedure

&AtClient
Procedure OnChoiceJournal(Item, SelectedRow, Field, Standard)
	
	Var CurData;
	
	CurData = Items.Journal.CurrentData;
	If CurData = Undefined Then
		Return;
	EndIf;
	
	If Field.Name = "Data" Or Field.Name = "DataPresentation" Then
		If CurData.Data <> Undefined Then
			if TypeOf(CurData.Data) <> Type("PredefinedDataUpdate") Then
				If TypeOf(CurData.Data) <> Type("String") AND TypeOf(CurData.Data) <> Type("Date") AND (Not CurData.Data.IsEmpty()) Then
					ShowValue(, CurData.Data);
					Return;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If Field.Name = "Date" Then
		SetDateInterval();
		Return;
	EndIf;
	ShowCurrentEventInSeparateWindow();
	
EndProcedure

///////////////////////////////////////////////////////////////////////////////////////////////
// Common procedures

&AtClient
Функция GetFormName(FormName) Export
	
	Var ForReturn;
	
	ForReturn = MetaPath + ".Form";
	If Not IsBlankString(FormName) Then
		ForReturn = ForReturn + "." + FormName;
	EndIf;
	Return ForReturn;
	
КонецФункции

&AtServer
Функция GetActiveUsersFormName()
	
	Var ForReturn, ActiveUsers, ProcName;
	
	ForReturn = Undefined;
	If AccessRight("ActiveUsers", Metadata) Then
		ActiveUsers = Undefined;
		ProcName = Undefined;
		Try
			ActiveUsers = New("ExternalDataProcessorObject.StandardActiveUsers");
			ProcName = ActiveUsers.Metadata().Name;
		Except
			Try
				ProcName = ExternalDataProcessors.Connect("v8res://mngbase/StandardActiveUsers.epf", , False);
				ActiveUsers = New("ExternalDataProcessorObject." + ProcName);
			Except
				Message(ErrorDescription());
			EndTry;
		EndTry;
		If ActiveUsers <> Undefined Then
			ForReturn = "ExternalDataProcessor." + ProcName + ".Form";
		EndIf;
	EndIf;
	Return ForReturn;
	
КонецФункции

&AtServer
Procedure UpdateColumnNames(EventsTable)
	
	Var Processing, Column;
	
	Processing = FormAttributeToValue("Object");
	For Each Column In EventsTable.Columns Do
		Column.Name = Processing.TermRu2En(Column.Name);
	EndDo;
	
EndProcedure

&AtServer
Procedure FillJournalList()
	
	Var Processing, CommonFilterInfo, FilterData, Item, Filter;
	Var NewFilter, NewArray, ArrayItem, DataStructure, Events, FilterParameters;
	Var FilterByEventValue, ValueTable_Events, SpecailEvents;
	Var Counter, ValueTableRow, Delta, StoredData;
	
	Processing = FormAttributeToValue("Object");
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	FilterData = Processing.CopyOf(CommonFilterInfo.FilterData);

	// clear temporary storage
	For Each Item In Journal Do
		If Not IsBlankString(Item.TempStorageAddr) Then
			DeleteFromTempStorage(Item.TempStorageAddr);
		EndIf;
	EndDo;
	
	// upload selected events into table
	Filter = New Structure;
	For Each FilterItem In FilterData Do
		If Upper(FilterItem.Key) = "SESSIONDATASEPARATION" Then
			NewFilter = New Structure;
			For Each Item In FilterItem.Value Do
				NewArray = New Array;
				For Each ArrayItem In Item.Value Do
					DataStructure = New Structure("Use, Value", False, Undefined);
					If ArrayItem = "UnsettingAttribute" Then
						DataStructure.Use = False;
						DataStructure.Value = Undefined;
					Else
						DataStructure.Use = True;
						DataStructure.Value = ArrayItem;
					EndIf;
					NewArray.Add(DataStructure);
				EndDo;
				NewFilter.Insert(Item.Key, NewArray);
			EndDo;
			Filter.Insert(FilterItem.Key, NewFilter);
		Else 
			Filter.Insert(FilterItem.Key, FilterItem.Value);
		EndIf;
	EndDo;
	ConvertFilter(Filter);
	
	if Not Filter.Property("Event") Then
		// add all events except Transaction event
		Events = New Array;
		FiterParameters = GetEventLogFilterValuesEnglishKeys("Event");
		For Each FilterByEventValue In FiterParameters.Event Do
			If StrOccurrenceCount(FilterByEventValue.Value, "Transaction.") = 0 AND StrOccurrenceCount(FilterByEventValue.Value, "Транзакция.") = 0 Then
				Events.Add(FilterByEventValue.Key);
			EndIf;
		EndDo;
		Filter.Insert("Event", Events);
	EndIf;
	
	ValueTable_Events = New ValueTable;
	UnloadEventLog(ValueTable_Events, Filter, , CommonFilterInfo.JournalDataFileName, VisibleEventsNumber);
	UpdateColumnNames(ValueTable_Events);
	ValueTable_Events.Columns.Add("PictureNumber", New TypeDescription("Number"));
	ValueTable_Events.Columns.Add("Grayed", New TypeDescription("Boolean"));
	ValueTable_Events.Columns.Add("TempStorageAddr", New TypeDescription("String"));
	ValueTable_Events.Columns.Add("EventID", New TypeDescription("Number"));
	
	// detect session data present fo future use
	IsSessionData = ?(ValueTable_Events.Columns.Find("SessionDataSeparation") = Undefined, False, True);
	If Not IsSessionData Then
		Items.SessionDataSeparation.Visible = False;
	EndIf;
	
	SpecailEvents = Processing.GetSpecialEventsName();
	Counter = 0;
	For Each ValueTableRow In ValueTable_Events Do
		Delta = ?(ValueTableRow.TransactionStatus = EventLogEntryTransactionStatus.Unfinished OR ValueTableRow.TransactionStatus = EventLogEntryTransactionStatus.RolledBack, 4, 0);
		ValueTableRow.EventID = Counter;
		Counter = Counter + 1;
		ValueTableRow.Grayed = ?(Delta = 0, False, True);
		ValueTableRow.PictureNumber = 5 + Delta;
		If ValueTableRow.Level = EventLogLevel.Information Then
			ValueTableRow.PictureNumber = 2 + Delta;
		ElsIf ValueTableRow.Level = EventLogLevel.Warning Then
			ValueTableRow.PictureNumber = 3 + Delta;
		ElsIf ValueTableRow.Level = EventLogLevel.Error Then
			ValueTableRow.PictureNumber = 4 + Delta;
		EndIf;
		
		ValueTableRow.UserName = Processing.GetDBUserName(ValueTableRow.User, ValueTableRow.UserName);
		ValueTableRow.TransactionStatus = ?(ValueTableRow.TransactionStatus = EventLogEntryTransactionStatus.NotApplicable, "", String(ValueTableRow.TransactionStatus));
		ValueTableRow.TempStorageAddr = "";
		
		// special processing some events
		StoredData = New Structure; // extra data for event viewer
		If IsSessionData Then
			If ValueTableRow.SessionDataSeparation.Count() <> 0 Then
				StoredData.Insert("SessionDataSeparationPresentation", Processing.CopyOf(ValueTableRow.SessionDataSeparationPresentation));
				StoredData.Insert("SessionDataSeparation", Processing.CopyOf(ValueTableRow.SessionDataSeparation));
				ValueTableRow.SessionDataSeparation = Processing.ConvertArrayToString(ValueTableRow.SessionDataSeparationPresentation);
			Else
				ValueTableRow.SessionDataSeparation = "";
			EndIf;
		EndIf;
		
		If SpecailEvents.Find(ValueTableRow.Event) <> Undefined Then
			// для системных событий будем детально разбираться со структурами данных
			// в том числе заниматься переименованием ключей и прочими действиями
			If TypeOf(ValueTableRow.Metadata) = Type("Array") Then
				// store for future usage
				StoredData.Insert("Metadata", Processing.CopyOf(ValueTableRow.Metadata));
				StoredData.Insert("MetadataPresentation", Processing.CopyOf(ValueTableRow.MetadataPresentation));
				// generate metadata presentation
				If ValueTableRow.Event = SpecailEvents[3] AND ValueTableRow.MetadataPresentation.Count() = 0 Then
					ValueTableRow.MetadataPresentation = "";//"<Configuration>";
				Else
					ValueTableRow.MetadataPresentation = Processing.ConvertArrayToString(ValueTableRow.MetadataPresentation);
				EndIf; 
			EndIf;
			If TypeOf(ValueTableRow.Data) = Type("Structure") Then
				// convert special data to english structure key
				EventData = Processing.ConvertStructureKeyToEn(ValueTableRow.Data);
				// store for future usage
				StoredData.Insert("Data", Processing.CopyOf(EventData, True));
			EndIf;
			// generate presentation for special events
			ValueTableRow.Data = Processing.GetSpecialEventPresentation(ValueTableRow.Event, StoredData);
		Else
			If IsBlankString(ValueTableRow.DataPresentation) Then
				ValueTableRow.DataPresentation = String(ValueTableRow.Data);
			EndIf;
		EndIf;
		If StoredData.Count() <> 0 Then
			// put special stored data to temporary storage
			ValueTableRow.TempStorageAddr = PutToTempStorage(StoredData, UUID);
		EndIf;
	EndDo;
	
	Journal.Load(ValueTable_Events);
	CreateFilterPresentation();
	
EndProcedure

&AtServer
Procedure ConvertFilter(Filter)
	
	Var FilterItem;
	
	For Each FilterItem In Filter Do
		If TypeOf(FilterItem.Value) = Type("ValueList") Then
			ConvertFilterItem(Filter, FilterItem);
		EndIf;
	EndDo;
	
EndProcedure

&AtServer
Procedure ConvertFilterItem(Filter, FilterItem)
	
	Var Processing, NewValue, ValueFromList, LineCount, i, DBUser;
	
	SetPrivilegedMode(True);
	// if this procedure is called, the filter item is kindof value list item,
	// but fliter can contain array only. let`s convert it to array.
	Processing = FormAttributeToValue("Object");
	NewValue = New Array;
	
	For Each ValueFromList In FilterItem.Value Do
		If FilterItem.Key = "Level" Then
			// Event levels are presented by string, we need to convert them to sys enum
			NewValue.Add(Processing.EventLogLevelValueByName(ValueFromList.Value));
		ElsIf FilterItem.Key = "TransactionStatus" Then
			// TransactionID status is presented by string, we need to convert it to sys enum
			NewValue.Add(Processing.TransactionStatusValueByName(ValueFromList.Value));
		ElsIf FilterItem.Key = "Event" Or FilterItem.Key = "Metadata" Then 
			LineCount = StrLineCount(ValueFromList.Value);
			For i = 1 To LineCount Do
				NewValue.Add(StrGetLine(ValueFromList.Value, i));
			EndDo;
		ElsIf FilterItem.Key = "User" And TypeOf(ValueFromList.Value) = Type("KeyAndValue") Then
			// If User is presented by UUID, we need to convert it to InfoBaseUser
			DBUser = InfoBaseUsers.FindByUUID(ValueFromList.Value.Key);
			If DBUser <> Undefined Then
				NewValue.Add(DBUser);
			Else
				NewValue.Add(ValueFromList.Value.Value);
			EndIf;
		Else
			NewValue.Add(ValueFromList.Value);
		EndIf;
	EndDo;
	Filter.Insert(FilterItem.Key, NewValue);
	SetPrivilegedMode(False);
	
EndProcedure
	
&AtServer
Procedure CreateFilterPresentation()
	
	Var Processing, CommonFilterInfo, PeriodStartDate, PeriodEndDate;
	Var FilterItem, LimitationName;
	
	Processing = FormAttributeToValue("Object");
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	Text = "";
	// Period
	PeriodStartDate = Undefined;
	CommonFilterInfo.FilterData.Property("StartDate", PeriodStartDate);
	PeriodStartDate = ?(PeriodStartDate = Undefined, '00010101000000', PeriodStartDate);
	PeriodEndDate = Undefined;
	CommonFilterInfo.FilterData.Property("EndDate", PeriodEndDate);
	PeriodEndDate = ?(PeriodEndDate = Undefined, '00010101000000', PeriodEndDate);
	If Not (PeriodStartDate = '00010101000000' And PeriodEndDate = '00010101000000') Then
		Text = NStr("ru='Интервал (';SYS='MFModule.IntervalStart'", "ru");
		Text = Text + Format(PeriodStartDate, "DLF=DT; DE='" + NStr("ru='без ограничений';SYS='Processing.WithoutSelection'", "ru") + "'") + " - ";
		Text = Text + Format(PeriodEndDate,   "DLF=DT; DE='" + NStr("ru='без ограничений';SYS='Processing.WithoutSelection'", "ru") + "'") + ")";
	EndIf;
	// other limitations signals by its name only without values
	For Each FilterItem In CommonFilterInfo.FilterData Do
		LimitationName = FilterItem.Key;
		If LimitationName = "StartDate" Or LimitationName = "EndDate" Then
			// Period already prepared
			Continue;
		EndIf;
		LimitationName = Processing.GetColumnPresentation(LimitationName);
		If Not IsBlankString(Text) Then 
			Text = Text + ", ";
		EndIf;
		Text = Text + LimitationName;
	EndDo;
	If Not CommonFilterInfo.FilterData.Property("SessionDataSeparation") Then
		CommonFilterInfo.SessionDataFilterPresentation = "";
	EndIf;
	If IsBlankString(Text) Then
		FilterPresentation = New FormattedString("");
	Else
		FilterPresentation = New FormattedString(New FormattedString(NStr("ru='Отключить:';SYS='Filter.ClearFilter'", "ru"), , , , "ClearFilter"), " ", Text);
	EndIf;
	CommonFilterInfo.FilterDataPresentation = FilterPresentation;
	PutToTempStorage(CommonFilterInfo, CommonFilterInfoAddr);
	
EndProcedure


&AtClient
Procedure FilterPresentationURLProcessing(Item, URL, StandardProcessing)
	
	if URL = "ClearFilter" Then
		ClearFilter();
	EndIf;
	StandardProcessing = False;
	
EndProcedure

&AtClient
Procedure ViewFromFile(Command)
	
	Var JournalFile, TempStorage, Dialog, Params, Callback;
	
	JournalFile = "";
	Callback = New NotifyDescription("ViewFromFileCallback", ThisForm);
	#If WebClient Then
		// open journal file from web-client
		TempStorage = "";
		BeginPutFile(Callback, TempStorage, GetClientAllFilesMask(), True, ThisForm.UUID);
	#Else
		Dialog = New FileDialog(FileDialogMode.Open);
		Dialog.Filter = NStr("ru = 'Журнал регистрации';sys = 'EventLog.MainForm.EventLog'", "ru")+ " (*.lgd, *.lgf)|*.lgd;*.lgf";
		Dialog.Multiselect = False;
		Dialog.CheckFileExist = True;
		Dialog.Title = NStr("ru='Выберите файл журнала регистрации';SYS='MFModule.SelectEventJournalFile'", "ru");
		If Dialog.Choose() = True Then
			
			JournalFile = Dialog.FullFileName;
			TempStorage = "";
			BeginPutFile(Callback, TempStorage, Dialog.FullFileName, False, ThisForm.UUID);
		EndIf;
	#EndIf
	
EndProcedure

&AtClient
Procedure ViewFromFileCallback(Result, FileAddr, ChooseFileName, ExtraParameters) Export
	
	If IsBlankString(ChooseFileName) Then
		Return;
	EndIf;
	
	If IsFileDB Then
		// удалим из временного хранилища, если работаем с файловым вариантом ИБ
		DeleteFromTempStorage(FileAddr);
	EndIf;
	// open new instance of this form
	Params = New Structure;
	Params.Insert("JournalFile", ChooseFileName);
	Params.Insert("JournalAddress", ?(IsFileDB, ChooseFileName, FileAddr));
	Params.Insert("PurposeUseKey", String(New UUID));
	OpenForm(MetaPath+".Form", Params);
	
EndProcedure
