
&AtServer
Procedure MakeFilterData()
	
	Var CommonFilterInfo, FilterData, TempData, LevelsList, Item;
	
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	FilterData = CommonFilterInfo.FilterData;
	
	FilterData.Clear();
	// Dates
	If StartDate <> '00010101000000' Then 
		FilterData.Insert("StartDate", StartDate);
	EndIf;
	If EndDate <> '00010101000000' Then
		FilterData.Insert("EndDate", EndDate);
	EndIf;
	// User
	If Users.Count() > 0 Then 
		FilterData.Insert("User", Users);
	EndIf;
	// Event
	If Events.Count() > 0 Then 
		FilterData.Insert("Event", Events);
	EndIf;
	// Computer
	If Computers.Count() > 0 Then 
		FilterData.Insert("Computer", Computers);
	EndIf;
	// ApplicationName
	If Applications.Count() > 0 Then 
		FilterData.Insert("ApplicationName", Applications);
	EndIf;
	// Comment
	If Not IsBlankString(Comment) Then 
		FilterData.Insert("Comment", Comment);
	EndIf;
	// Metadata
	If Metadata.Count() > 0 Then 
		FilterData.Insert("Metadata", Metadata);
	EndIf;
	// Data 
	If (Data <> Undefined) And (Not Data.IsEmpty()) Then
		FilterData.Insert("Data", Data);
	EndIf;
	// DataPresentation
	If Not IsBlankString(DataPresentation) Then 
		FilterData.Insert("DataPresentation", DataPresentation);
	EndIf;
	// TransactionID
	If Not IsBlankString(Transaction) Then 
		FilterData.Insert("TransactionID", Transaction);
	EndIf;
	// ServerName
	If Servers.Count() > 0 Then 
		FilterData.Insert("ServerName", Servers);
	EndIf;
	// Session
	If Not IsBlankString(Sessions) Then 
		FilterData.Insert("Session", Sessions);
	EndIf;
	// Port
	If MainIPPorts.Count() > 0 Then 
		FilterData.Insert("Port", MainIPPorts);
	EndIf;
	// SyncPort
	If AdditionalIPPorts.Count() > 0 Then 
		FilterData.Insert("SyncPort", AdditionalIPPorts);
	EndIf;
	// SessionDataSeparation
	If SessionDataSeparation.Count() > 0 Then
		TempData = New Structure;
		For Each Item In SessionDataSeparation Do
		
			TempData.Insert(Item.Key, Item.Value);
		
		EndDo;
		FilterData.Insert("SessionDataSeparation", TempData);
	EndIf;
	// Level
	LevelsList = New ValueList;
	For Each Item In Levels Do
		If Item.Check Then 
			LevelsList.Add(Item.Value, Item.Presentation);
		EndIf;
	EndDo;
	If LevelsList.Count() > 0 And LevelsList.Count() <> Levels.Count() Then
		FilterData.Insert("Level", LevelsList);
	EndIf;
	// TransactionStatus
	StatusList = New ValueList;
	For Each Item In TransactionStatus Do
		If Item.Check Then 
			StatusList.Add(Item.Value, Item.Presentation);
		EndIf;
	EndDo;
	If StatusList.Count() > 0 And StatusList.Count() <> TransactionStatus.Count() Then
		FilterData.Insert("TransactionStatus", StatusList);
	EndIf;
	
	// Запишем новые данные отбора по "боевому" адресу во временное хранилище
	PutToTempStorage(CommonFilterInfo, CommonFilterInfoAddrBackup);
	
EndProcedure

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Events processing
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	Var Processing, CommonFilterInfo, FilterData, PropertyValue, Item;
	
	Processing = FormAttributeToValue("Object");
	CommonFilterInfoAddrBackup = Parameters.CommonFilterInfoAddr;
	CommonFilterInfo = GetFromTempStorage(Parameters.CommonFilterInfoAddr);
	
	// Сделаем рабочую копию отбора и работать будем с этой копией
	// Если в отборе нажали ОК - рабочую копию сделаем основной
	CommonFilterInfoAddr = PutToTempStorage(Processing.CopyOf(CommonFilterInfo), UUID);
	
	// Инициализируем форму
	MetaPath = CommonFilterInfo.MetaPath;
	LoadedFile = CommonFilterInfo.JournalDataFileName;
	
	If Not Parameters.IsSessionData Then
		Items.SessionDataSeparation.Visible = False;
	EndIf;
	
	Levels.Add("Error", String(EventLogLevel.Error));
	Levels.Add("Warning", String(EventLogLevel.Warning));
	Levels.Add("Information", String(EventLogLevel.Information));
	Levels.Add("Note", String(EventLogLevel.Note));
	
	TransactionStatus.Add("NotApplicable", String(EventLogEntryTransactionStatus.NotApplicable));
	TransactionStatus.Add("Committed", String(EventLogEntryTransactionStatus.Committed));
	TransactionStatus.Add("Unfinished", String(EventLogEntryTransactionStatus.Unfinished));
	TransactionStatus.Add("RolledBack", String(EventLogEntryTransactionStatus.RolledBack));
	
	FilterData = CommonFilterInfo.FilterData;
	SessionDataSeparationPresentation = CommonFilterInfo.SessionDataFilterPresentation;
	
	PropertyValue = Undefined;
	// StartDate
	If FilterData.Property("StartDate", PropertyValue) Then
		StartDate = PropertyValue;
	EndIf;
	// EndDate
	If FilterData.Property("EndDate", PropertyValue) Then
		EndDate = PropertyValue;
	EndIf;
	// User
	If FilterData.Property("User", PropertyValue) Then
		Users = PropertyValue;
	EndIf;
	// Event
	If FilterData.Property("Event", PropertyValue) Then
		Events = PropertyValue;
	EndIf;
	// Computer
	If FilterData.Property("Computer", PropertyValue) Then
		Computers = PropertyValue;
	EndIf;
	// ApplicationName
	If FilterData.Property("ApplicationName", PropertyValue) Then
		Applications = PropertyValue;
	EndIf;
	// Comment
	If FilterData.Property("Comment", PropertyValue) Then
		Comment = PropertyValue;
	EndIf;
	// Metadata
	If FilterData.Property("Metadata", PropertyValue) Then
		Metadata = PropertyValue;
	EndIf;
	// Data/Data 
	If FilterData.Property("Data", PropertyValue) Then
		Data = PropertyValue;
	EndIf;
	// DataPresentation
	If FilterData.Property("DataPresentation", PropertyValue) Then
		DataPresentation = PropertyValue;
	EndIf;
	// TransactionID
	If FilterData.Property("TransactionID", PropertyValue) Then
		Transaction = PropertyValue;
	EndIf;
	// ServerName
	If FilterData.Property("ServerName", PropertyValue) Then
		Servers = PropertyValue;
	EndIf;
	// Session
	If FilterData.Property("Session", PropertyValue) Then
		Sessions = PropertyValue;
		// convert ValueList to string
		SessionsString = "";
		For Each Item in Sessions Do
			SessionsString = SessionsString + " " + Format(Item.Value, "NG=0");
		EndDo;
		SessionsString = StrReplace(TrimAll(SessionsString), " ", ",");
	EndIf;
	// Port
	If FilterData.Property("Port", PropertyValue) Then
		MainIPPorts = PropertyValue;
	EndIf;
	// SyncPort
	If FilterData.Property("SyncPort", PropertyValue) Then
		AdditionalIPPorts = PropertyValue;
	EndIf;
	// SessionDataSeparation
	If FilterData.Property("SessionDataSeparation", PropertyValue) Then
		SessionDataSeparation = New FixedStructure(PropertyValue);
	Else
		SessionDataSeparation = New FixedStructure(New Structure);
	EndIf;
	// Level
	If FilterData.Property("Level", PropertyValue) Then
		For Each Item In Levels Do
			If PropertyValue.FindByValue(Item.Value) <> Undefined Then
				Item.Check = True;
			EndIf;
		EndDo;
	Else
		Levels.FillChecks(True);
	EndIf;
	// TransactionStatus
	If FilterData.Property("TransactionStatus", PropertyValue) Then
		For Each Item In TransactionStatus Do
			If PropertyValue.FindByValue(Item.Value) <> Undefined Then
				Item.Check = True;
			EndIf;
		EndDo;
	Else
		TransactionStatus.FillChecks(True);
	EndIf;
	
EndProcedure

&AtServer
Procedure ReSetSessionDataFilter()
	
	Var CommonFilterInfo;
	
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	SessionDataSeparation = New FixedStructure(CommonFilterInfo.FilterData.SessionDataSeparation);
	SessionDataSeparationPresentation = CommonFilterInfo.SessionDataFilterPresentation;
	
EndProcedure

&AtServer
Procedure SessionDataViewClearingAtServer()
	
	Var SessionData, CommonFilterInfo;
	
	SessionData = New FixedStructure(New Structure);
	SessionDataPresentation = "";
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	CommonFilterInfo.FilterData.Delete("SessionData");
	CommonFilterInfo.SessionDataFilterPresentation = SessionDataPresentation;
	PutToTempStorage(CommonFilterInfo, CommonFilterInfoAddr);
	
EndProcedure

&AtClient
Procedure OKCommand(Command)

	MakeFilterData();
	Close(DialogReturnCode.OK);
	
EndProcedure

&AtClient
Procedure EventLevel_SetAll()
	
	Levels.FillChecks(True);
	
EndProcedure

&AtClient
Procedure EventLevel_ClearAll()
	
	Levels.FillChecks(False);
	
EndProcedure

&AtClient
Procedure TransactionStatus_SetAll()
	
	TransactionStatus.FillChecks(True);
	
EndProcedure

&AtClient
Procedure TransactionStatus_ClearAll()
	
	TransactionStatus.FillChecks(False);
	
EndProcedure

&AtClient
Procedure SelectPeriod(Command)
	
	Var Dialog, Callback, ExtraParameters;
	
	Dialog = New StandardPeriodEditDialog;
	Dialog.Period.StartDate = StartDate;
	Dialog.Period.EndDate = EndDate;
	ExtraParameters = New Structure;
	ExtraParameters.Insert("Dialog", Dialog);
	Callback = New NotifyDescription("SelectPeriodCallback", ThisForm, ExtraParameters);
	Dialog.Show(Callback);
	
EndProcedure

&AtClient
Procedure SelectPeriodCallback(Result, ExtraParameters) Export
	
	Var Dialog;
	
	Dialog = ExtraParameters.Dialog;
	If Result <> Undefined Then
		StartDate = Dialog.Period.StartDate;
		EndDate = Dialog.Period.EndDate;
	EndIf;
	
EndProcedure

&AtClient
Procedure StartDateChoiceProcessing(Item, SelectedValue, StandardProcessing)
	
	StandardProcessing = False;
	StartDate = BegOfDay(SelectedValue);
	
EndProcedure

&AtClient
Procedure EndDateChoiceProcessing(Item, SelectedValue, StandardProcessing)
	
	StandardProcessing = False;
	EndDate = EndOfDay(SelectedValue);
	
EndProcedure

&AtClient
Procedure OnMadeChoice(Item, ChoiceData, StandardProcessing)
	
	Var ListToEdit, ParametersToEdit, EditorFormName, Params, EditorForm, Callback;
	
	StandardProcessing = False;
	
	If Item = Items.Users Then
		ListToEdit = Users;
		ListToEdit.SortByPresentation();
		ParametersToEdit = "User";
	ElsIf Item = Items.Events Then
		ListToEdit = Events;
		ParametersToEdit = "Event";
	ElsIf Item = Items.Computers Then
		ListToEdit = Computers;
		ListToEdit.SortByPresentation();
		ParametersToEdit = "Computer";
	ElsIf Item = Items.Applications Then
		ListToEdit = Applications;
		ListToEdit.SortByPresentation();
		ParametersToEdit = "ApplicationName";
	ElsIf Item = Items.Metadata Then
		ListToEdit = Metadata;
		ParametersToEdit = "Metadata";
	ElsIf Item = Items.Servers Then
		ListToEdit = Servers;
		ListToEdit.SortByPresentation();
		ParametersToEdit = "ServerName";
	ElsIf Item = Items.MainIPPorts Then
		ListToEdit = MainIPPorts;
		ParametersToEdit = "Port";
	ElsIf Item = Items.AdditionalIPPorts Then
		ListToEdit = AdditionalIPPorts;
		ParametersToEdit = "SyncPort";
	Else
		StandardProcessing = True;
		Return;
	EndIf;
	
	// Open property editor
	EditorFormName = MetaPath+".Form.PropertyContentsEditor";
	If EditorFormName = Undefined Then 
		Return;
	EndIf;
	
	Params = New Structure;
	Params.Insert("JournalFile", LoadedFile);
	EditorForm = GetForm(EditorFormName, Params);
	EditorForm.SetEditorParameters(ListToEdit, ParametersToEdit);
	ExtraParameters = New Structure;
	ExtraParameters.Insert("EditorForm", EditorForm);
	ExtraParameters.Insert("Item", Item);
	Callback = New NotifyDescription("OnMadeChoiceCallback", ThisForm, ExtraParameters);
	EditorForm.OnCloseNotifyDescription = Callback;
	EditorForm.Open();

EndProcedure

&AtClient
Procedure OnMadeChoiceCallback(Result, ExtraParameters) Export
	
	Var ListToEdit, Item;
	
	If Result = DialogReturnCode.OK Then
		EditorForm = ExtraParameters.EditorForm;
		Item = ExtraParameters.Item;
		ListToEdit = New ValueList;
		EditorForm.GetListEdited(ListToEdit);
		If Item = Items.Users Then
			Users = ListToEdit;
		ElsIf Item = Items.Events Then
			Events = ListToEdit;
		ElsIf Item = Items.Computers Then
			Computers = ListToEdit;
		ElsIf Item = Items.Applications Then
			Applications = ListToEdit;
		ElsIf Item = Items.Metadata Then
			Metadata = ListToEdit;
		ElsIf Item = Items.Servers Then
			Servers = ListToEdit;
		ElsIf Item = Items.MainIPPorts Then
			MainIPPorts = ListToEdit;
		ElsIf Item = Items.AdditionalIPPorts Then
			AdditionalIPPorts = ListToEdit;
		EndIf;
	EndIf;
	
EndProcedure

&AtClient
Procedure OnMadeChoice2(Item, ChoiceData, StandardProcessing)
	
	Var ListToEdit, ParametersToEdit, EditorFormName, Params, EditorForm, Callback;
	
	StandardProcessing = False;
	If Item = Items.Users Then
		ListToEdit = Users;
		ListToEdit.SortByPresentation();
		ParametersToEdit = "User";
	ElsIf Item = Items.Computers Then
		ListToEdit = Computers;
		ListToEdit.SortByPresentation();
		ParametersToEdit = "Computer";
	Else
		StandardProcessing = True;
		Return;
	EndIf;
	
	// Open property editor
	EditorFormName = MetaPath+".Form.PropertyContentsEditor2";
	If EditorFormName = Undefined Then 
		Return;
	EndIf;
	Params = New Structure;
	Params.Insert("JournalFile", LoadedFile);
	Params.Insert("UseParameter", ParametersToEdit);
	Params.Insert("SelectList", ListToEdit);
	EditorForm = GetForm(EditorFormName, Params);
	ExtraParameters = New Structure;
	ExtraParameters.Insert("EditorForm", EditorForm);
	ExtraParameters.Insert("Item", Item);
	Callback = New NotifyDescription("OnMadeChoice2Callback", ThisForm, ExtraParameters);
	EditorForm.OnCloseNotifyDescription = Callback;
	EditorForm.Open();
	
EndProcedure

&AtClient
Procedure OnMadeChoice2Callback(Result, ExtraParameters) Export
	
	Var ListToEdit, Item;
	
	If Result = DialogReturnCode.OK Then
		EditorForm = ExtraParameters.EditorForm;
		Item = ExtraParameters.Item;
		ListToEdit = EditorForm.GetListEdited();
		If Item = Items.Users Then
			Users = ListToEdit;
		ElsIf Item = Items.Computers Then
			Computers = ListToEdit;
		EndIf;
	EndIf;
	
EndProcedure

&AtClient
Procedure OnMadeChoice3(Item, ChoiceData, StandardProcessing)
	
	Var EditorFormName, Params, EditorForm;
	
	StandardProcessing = False;
	// Open property editor
	EditorFormName = MetaPath+".Form.PropertyContentsEditor3";
	If EditorFormName = Undefined Then 
		Return;
	EndIf;
	
	Params = New Structure;
	Params.Insert("CommonFilterInfoAddr", CommonFilterInfoAddr);
	EditorForm = GetForm(EditorFormName, Params);
	Callback = New NotifyDescription("OnMadeChoice3Callback", ThisForm);
	EditorForm.OnCloseNotifyDescription = Callback;
	EditorForm.Open();
	
EndProcedure

&AtClient
Procedure OnMadeChoice3Callback(Result, ExtraParameters) Export
	
	If Result = DialogReturnCode.OK Then
		ReSetSessionDataFilter();
	EndIf;
	
EndProcedure

&AtClient
Procedure SessionsOnChange(Item)
	
	Var Maybe, Source, i, Char, StrNumber, SessionsItem;
	
	Maybe = "0123456789,";
	Source = "";
	For i=1 To StrLen(SessionsString) Do
		Char = Mid(SessionsString, i, 1);
		Source = Source + ?(StrOccurrenceCount(Maybe, Char) = 0, "", Char);
	EndDo;
	Sessions.Clear();
	Source = StrReplace(Source, ",", Chars.LF);
	For i=1 To StrLineCount(Source) Do
		StrNumber = StrGetLine(Source, i);
		If IsBlankString(StrNumber) Then
			Continue;
		EndIf;
		Sessions.Add(Number(StrNumber));
	EndDo;
	SessionsString = "";
	For Each SessionsItem in Sessions Do
		SessionsString = SessionsString + " " + Format(SessionsItem.Value, "NG=0");
	EndDo;
	SessionsString = StrReplace(TrimAll(SessionsString), " ", ",");

EndProcedure

&AtClient
Procedure SessionDataViewClearing(Item, StandardProcessing)
	
	StandardProcessing = False;
	SessionDataViewClearingAtServer();
	
EndProcedure

