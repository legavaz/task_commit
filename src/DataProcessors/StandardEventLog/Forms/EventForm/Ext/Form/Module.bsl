
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	EventFormSetting(Parameters.ViewEvent);
	
EndProcedure

&AtServer
Procedure EventFormSetting(EventStructure)
	
	Var CurrentID, EventsCount, Processing, EventNames;
	Var ExtraData, i, ArraySize, Structure, TrueEvent;
	Var Item, DataLine, LowKey;
	
	MetaDataList.Clear();
	SessionDataList.Clear();
	SpecialData.Clear();
	AccessData.Clear();
	CurrentID = EventStructure.CurrentID;
	EventsCount = EventStructure.EventsCount;
	//Items.PreviousEvent.Enabled = ?(CurrentID-1 <= 0, False, True);
	//Items.NextEvent.Enabled = ?(CurrentID+1 >= EventsCount, False, True);
	Processing = FormAttributeToValue("Object");
	DateTime = EventStructure.DateTime;
	User = EventStructure.User;
	Application = EventStructure.Application;
	Computer = EventStructure.Computer;
	Event = EventStructure.EventPresentation;
	Comment = EventStructure.Comment;
	Metadata = EventStructure.Metadata;
	Data = EventStructure.Data;
	DataPresentation = EventStructure.DataPresentation;
	TransactionID = EventStructure.TransactionID;
	TransactionCompleteStatus = EventStructure.TransactionCompleteStatus;
	Session = EventStructure.Session;
	ServerName = EventStructure.ServerName;
	Port = EventStructure.Port;
	SyncPort = EventStructure.SyncPort;
	TempStorageAddr = EventStructure.TempStorageAddr;
	
	EventNames = Processing.GetSpecialEventsName();
	Items.DataViewPages.PagesRepresentation = FormPagesRepresentation.None;
	If Not EventStructure.IsSessionData Then
		Items.SessionDataSeparation.Visible = False;
	EndIf;
	If IsBlankString(TempStorageAddr) Then
		Items.DataViewPages.CurrentPage = Items.Simple;
		Items.Metadata.OpenButton = False;
		MetaDataList.Add(EventStructure.Metadata);
		SessionDataSeparation = "";
		SessionDataList.Clear();
	Else
		ExtraData = GetFromTempStorage(TempStorageAddr);
		If ExtraData.Property("SessionDataSeparationPresentation") Then
			// prepare session data oreview
			ArraySize = ExtraData.SessionDataSeparationPresentation.Count();
			For i=0 To ArraySize-1 Do
				SessionDataList.Add(ExtraData.SessionDataSeparationPresentation[i]);
			EndDo;
			SessionDataSeparation = Processing.ConvertArrayToString(ExtraData.SessionDataSeparationPresentation);
		EndIf;
		If ExtraData = Undefined OR TypeOf(ExtraData) <> Type("Structure") Then
			Items.DataViewPages.CurrentPage = Items.Simple;
			Return;
		EndIf;
		If NOT ExtraData.Property("Data") Then
			Items.DataViewPages.CurrentPage = Items.Simple;
			Return;
		EndIf;
		Structure = ExtraData.Data;
		TrueEvent = EventStructure.Event;
		If ExtraData.Property("Metadata") Then
			// здесь будет список метаданных (даже если из 1 элемента)
			ArraySize = ExtraData.Metadata.Count();
			For i=0 To ArraySize-1 Do
				If IsBlankString(ExtraData.Metadata[i]) Then
					Continue;
				EndIf;
				MetaDataList.Add(ExtraData.Metadata[i], ExtraData.MetadataPresentation[i]);
			EndDo;
			Metadata = Processing.ConvertArrayToString(ExtraData.MetadataPresentation);
		EndIf;
		If MetaDataList.Count() <= 1 Then
			Items.Metadata.OpenButton = False;
			Items.MetadataUser.OpenButton = False;
			Items.MetadataAccess.OpenButton = False;
			Items.MetadataAccessDenied.OpenButton = False;
		EndIf;
		// user operations, auth operations, configuration extension
		If TrueEvent = EventNames[0] OR TrueEvent = EventNames[1] OR
			TrueEvent = EventNames[4] OR
			TrueEvent = EventNames[5] OR TrueEvent = EventNames[6] OR
			TrueEvent = EventNames[16] OR
			TrueEvent = EventNames[17] OR TrueEvent = EventNames[18] OR
			TrueEvent = EventNames[7] OR TrueEvent = EventNames[8] OR
			TrueEvent = EventNames[9] OR TrueEvent = EventNames[25] Then
			For Each Item In Structure Do
				DataLine = SpecialData.Add();
				DataLine.ItemName = Processing.GetKeyPresentation(Item.Key);
				If TypeOf(Item.Value) = Type("Array") Then
					If TrueEvent = EventNames[4] OR TrueEvent = EventNames[5] OR TrueEvent = EventNames[6] Then
						DataLine.ItemValue = Processing.GetRolePresentation(Item.Value);
					Else
						DataLine.ItemValue = Processing.ConvertArrayToString(Item.Value);
					EndIf;
				Else
					LowKey = Lower(Item.Key);
					If LowKey = "defaultinterface" Then
						DataLine.ItemValue = Processing.GetPresentationFromFullName("Interfaces", Item.Value);
					ElsIf LowKey = "language" Then
						DataLine.ItemValue = Processing.GetPresentationFromFullName("Languages", Item.Value);
					ElsIf LowKey = "runmode" Then
						DataLine.ItemValue = String(ClientRunMode[Item.Value]);
					Else
						DataLine.ItemValue = String(Item.Value);
					EndIf;
				EndIf;
			EndDo;
			SpecialData.Sort("ItemName ASC");
			Items.DataViewPages.CurrentPage = Items.Auth_User;
		ElsIf TrueEvent = EventNames[10] OR TrueEvent = EventNames[12] OR
			  TrueEvent = EventNames[13] OR TrueEvent = EventNames[14] OR
			  TrueEvent = EventNames[15] // Some predefined data
			  OR 
			  TrueEvent = EventNames[19] OR TrueEvent = EventNames[20] OR
			  TrueEvent = EventNames[21] OR TrueEvent = EventNames[22] OR
			  TrueEvent = EventNames[23] OR TrueEvent = EventNames[24] Then
			For Each Item In Structure Do
				DataLine = SpecialData.Add();
				DataLine.ItemName = Processing.GetKeyPresentation(Item.Key);
				DataLine.ItemValue = String(Item.Value);
			EndDo;
			SpecialData.Sort("ItemName ASC");
			Items.DataViewPages.CurrentPage = Items.AccessDenied;
		// Access ans some predefined data
		ElsIf TrueEvent = EventNames[11] Then
			CreateDataGrid(Items.AccessData1, ?(Structure.Property("Data") AND Structure.Data <> Undefined, Structure.Data, Undefined), True);
			Items.DataViewPages.CurrentPage = Items.Access;
		ElsIf TrueEvent = EventNames[2] OR TrueEvent = EventNames[3] Then
			// applied event mode
			DataLine = SpecialData.Add();
			If ExtraData.Data.Property("Right") Then
				DataLine.ItemName = Processing.GetKeyPresentation("Right");
				DataLine.ItemValue = RightPresentation(ExtraData.Data.Right);
				If ExtraData.Data.Property("AccessObject") Then
					DataLine = SpecialData.Add();
					DataLine.ItemName = Processing.GetKeyPresentation("AccessObject");
					DataLine.ItemValue = Processing.GetAccessControlObjectPresentation(ExtraData.Data.AccessObject);
				EndIf;
				If ExtraData.Data.Property("Action") Then
					DataLine = SpecialData.Add();
					DataLine.ItemName = Processing.GetKeyPresentation("Action");
					DataLine.ItemValue = Processing.GetActionPresentation(ExtraData.Data.Action);
				EndIf;
				Items.AccessData2.Visible = False;
			Else 
				DataLine.ItemName = Processing.GetKeyPresentation("Action");
				DataLine.ItemValue = Processing.GetActionPresentation(ExtraData.Data.Action);
				CreateDataGrid(Items.AccessData2, ?(Structure.Property("Data") AND Structure.Data <> Undefined, Structure.Data, Undefined));
				Items.AccessData2.Visible = True;
			EndIf;
			Items.DataViewPages.CurrentPage = Items.AccessDenied;
		EndIf;
	EndIf;

EndProcedure

&AtServer
Procedure CreateDataGrid(FormItem, DataTable, ConvertNames = False)
	
	Var Columns, Column, DeleteProps, MyProps, NewData, Item, Name;
	
	Processing = FormAttributeToValue("Object");
	Columns = GetAttributes("AccessData");
	DeleteProps = New Array;
	For Each Column In Columns Do
		DeleteProps.Add(Column.Path + "." + Column.Name);
	EndDo;
	
	If DataTable <> Undefined Then
		// add needed columns to ValueTable and delete older columns
		MyProps = New Array;
		For Each Column In DataTable.Columns Do
			If ConvertNames Then
				Name = Processing.TermRu2En(Column.Name);
			Else
				Name = Column.Name;
			EndIf;
			MyProps.Add(New FormAttribute(Column.Name, New TypeDescription("String"), "AccessData", Processing.GetKeyPresentation(Name), False));
		EndDo;
		ChangeAttributes(MyProps, DeleteProps);
		// add form items
		For Each Column In DataTable.Columns Do
			Item = Items.Add("AccessData"+Column.Name, Type("FormField"), FormItem);
			Item.DataPath = "AccessData."+Column.Name;
			If ConvertNames Then
				Name = Processing.TermRu2En(Column.Name);
			Else
				Name = Column.Name;
			EndIf;
			Item.Title = Processing.GetKeyPresentation(Name);
		EndDo;
		// convert data from event data to form data
		For Each DataLine In DataTable Do
			NewData = AccessData.Add();
			For Each Column In DataTable.Columns Do
				NewData[Column.Name] = DataLine[Column.Name];
			EndDo;
		EndDo;
	Else
		MyProps = New Array;
		// add needed columns to ValueTable and delete older columns
		MyProps.Add(New FormAttribute("Empty", New TypeDescription("String"), "AccessData", " ", False));
		ChangeAttributes(MyProps, DeleteProps);
		// add form items
		Item = Items.Add("AccessDataEmpty", Type("FormField"), FormItem);
		Item.DataPath = "AccessData.Empty";
		Item.Title = "";
	EndIf;
	
EndProcedure

&AtClient
Procedure MetadataListOpen(Item, StandardProcessing)
	
	StandardProcessing = False;
	ShowValue(, MetaDataList);
	
EndProcedure

&AtClient
Procedure SessionDataOpen(Item, StandardProcessing)
	
	StandardProcessing = False;
	ShowValue(, SessionDataList);
	
EndProcedure

&AtClient
Procedure NextEvent(Command)
	
	Var EventStructure;
	
	EventStructure = ThisForm.FormOwner.GetEventByID(CurrentID+1);
	EventFormSetting(EventStructure);
	
EndProcedure

&AtClient
Procedure PreviousEvent(Command)
	
	Var EventStructure;
	
	EventStructure = ThisForm.FormOwner.GetEventByID(CurrentID-1);
	EventFormSetting(EventStructure);
	
EndProcedure
