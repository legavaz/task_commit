
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	Var Item, Data;
	
	UseParameter = Upper(Parameters.UseParameter);
	LoadedFile = ?(Parameters.JournalFile = Undefined, "", Parameters.JournalFile);
	KeyValue = Parameters.KeyValue;
	DoSearchAtServer(UseParameter, KeyValue);
	DialogTitle = "";
	If UseParameter = "USER" Then
		
		DialogTitle = NStr("ru='пользователи';sys='StandardEventLog.PropertyEditor2.UserTitle'", "ru");
		
	ElsIf UseParameter = "COMPUTER" Then
		
		DialogTitle = NStr("ru='компьютеры';sys='StandardEventLog.PropertyEditor2.ComputerTitle'", "ru");
		
	ElsIf UseParameter = "SESSIONDATASEPARATION" Then
		
		DialogTitle = NStr("ru='общий реквизит';sys='StandardEventLog.PropertyEditor2.SessionDataTitle'", "ru") + " """ + Parameters.UseParameterPresentation + """";
		
	EndIf;
		                       
	For Each Item In Parameters.SelectList Do
		
		Data = Filter.Add();
		Data.Value = Item.Value;
		Data.Presentation = Item.Presentation;
		
	EndDo;
	Filter.SortByPresentation(SortDirection.Asc);
	Title = Title + " (" + DialogTitle + ")";
	
EndProcedure

&AtServer
Procedure DoSearchAtServer(Val Key, SecondKey = "")
	
	Var Processing, Params, Item, Data, ItemData;
	Var ValueItem, ValueItemData;
	
	Processing = FormAttributeToValue("Object");
	Params = GetEventLogFilterValues(Processing.TermRu2En(Key) + ?(IsBlankString(SecondKey), "", "." + SecondKey), LoadedFile);
	
	For Each Item In Params Do

		Params.Delete(Item.Key);
		Params.Insert(Upper(Processing.TermRu2En(Item.Key)), Item.Value);
		
	EndDo;
	
	PossibleList.Clear();
	Data = Undefined;
	Key = Upper(Key);
	Key = ?(Key = "SESSIONDATASEPARATION" AND NOT IsBlankString(SecondKey), "SESSIONDATASEPARATIONVALUES", Key);
	If Not Params.Property(Key, Data) Then // ???
		
		Return;
		
	EndIf;
	If Key = "COMPUTER" AND TypeOf(Data) = Type("Array") Then
		
		For Each Item In Data Do
		
			ItemData = PossibleList.Add();
			ItemData.Value = Item;
			ItemData.Presentation = String(Item);
		
		EndDo;
		
	ElsIf Key = "USER" AND TypeOf(Data) = Type("Map") Then
		
		For Each Item In Data Do
		
			ItemData = PossibleList.Add();
			ItemData.Value = Item;
			ItemData.Presentation = Processing.GetDBUserName(New UUID(Item.Key), Item.Value, True);
			
		EndDo;
		
	ElsIf Key = "SESSIONDATASEPARATIONVALUES" AND TypeOf(Data) = Type("Map") Then
		
		ItemData = PossibleList.Add();
		ItemData.Value = "UnsettingAttribute";
		ItemData.Presentation = NStr("ru = '<Не задано>';sys = 'EventLog.PropertyEditor2.UnsettingAttribute'", "ru");
		For Each ValueItem In Data Do
			
			If ValueItem.Key = SecondKey Then
				
				For Each ValueDataItem In ValueItem.Value Do
					
					ItemData = PossibleList.Add();
					ItemData.Value = ValueDataItem.Key;
					ItemData.Presentation = ValueDataItem.Value;
					
				EndDo;
				
			EndIf;
			
		EndDo;
				
	EndIf;
	PossibleList.SortByPresentation(SortDirection.Asc);
	
EndProcedure

&AtClient
Function GetListEdited() Export
	
	Var ListToEdit, Item;
	
	ListToEdit = New ValueList;
	For Each Item In Filter Do
	
		ListToEdit.Add(Item.Value, Item.Presentation);
	
	EndDo;
	
	Return ListToEdit;
	
EndFunction

&AtClient
Procedure AddToFilter(Command)
	
	Var Index, Item, Result, Data;
	
	For Each Index In Items.PossibleList.SelectedRows Do
	
		Item = PossibleList.FindById(Index);
		Result = Filter.FindByValue(Item.Value);
		If Result = Undefined Then
			
			Data = Filter.Add();
			Data.Value = Item.Value;
			Data.Presentation = Item.Presentation;
			
		EndIf;
	
	EndDo;
	Filter.SortByPresentation(SortDirection.Asc);
	ThisForm.CurrentItem = Items.PossibleList;
	
EndProcedure

&AtClient
Procedure AddToFilterAll(Command)

	Var Item, Result, Data;
	
	For Each Item In PossibleList Do
	
		//Result = Filter.FindRows(New Structure("Value", Item.Value));
		Result = Filter.FindByValue(Item.Value);
		If Result = Undefined Then
			
			Data = Filter.Add();
			Data.Value = Item.Value;
			Data.Presentation = Item.Presentation;
			
		EndIf;
	
	EndDo;
	Filter.SortByPresentation(SortDirection.Asc);
	Items.Filter.CurrentRow = Filter[0].GetID();
	ThisForm.CurrentItem = Items.Filter;
	
EndProcedure

&AtClient
Procedure RemoveFromFilter(Command)
	
	Var Index;
	
	For Each Index In Items.Filter.SelectedRows Do
	
		Filter.Delete(Filter.FindByID(Index));
	
	EndDo;
	ThisForm.CurrentItem = Items.Filter;
	
EndProcedure

&AtClient
Procedure RemoveFromFilterAll(Command)
	
	Filter.Clear();
	ThisForm.CurrentItem = Items.PossibleList;
	
EndProcedure

&AtClient
Procedure PossibleListSelection(Item, SelectedRow, Field, StandardProcessing)
	
	StandardProcessing = False;
	AddToFilter(Commands.AddToFilter);
	
EndProcedure

&AtClient
Procedure PossibleListDragStart(Item, DragParameters, StandardProcessing)
	
	Var Data, INdex;
	
	DragParameters.Action = DragAction.Copy;
	DragParameters.AllowedActions = DragAllowedActions.Copy;
	Data = New ValueList;
	For Each Index In Items.PossibleList.SelectedRows Do
	
		Item = PossibleList.FindById(Index);
		Data.Add(Item.Value, Item.Presentation);
	
	EndDo;
	DragParameters.Value = Data;
	
EndProcedure

&AtClient
Procedure PossibleListDragCheck(Item, DragParameters, StandardProcessing, Row, Field)
	
	If TypeOf(DragParameters.Value) <> Type("Array") Then
		
		DragParameters.Action = DragAction.Cancel;
		DragParameters.AllowedActions = DragAllowedActions.DontProcess;
		StandardProcessing = False;
		
	Else
		
		StandardProcessing = False;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure PossibleListDrag(Item, DragParameters, StandardProcessing, Row, Field)
	
	Var Result;
	
	StandardProcessing = False;
	For Each ValueItem In DragParameters.Value Do
	
		Result = Filter.FindByValue(ValueItem);
		If Result <> Undefined Then
			
			Filter.Delete(Result);
			
		EndIf;
	
	EndDo;
	Filter.SortByPresentation(SortDirection.Asc);
	ThisForm.CurrentItem = Items.PossibleList;
	
EndProcedure

&AtClient
Procedure FilterSelection(Item, SelectedRow, Field, StandardProcessing)
	
	StandardProcessing = False;
	RemoveFromFilter(Commands.RemoveFromFilter);
	
EndProcedure

&AtClient
Procedure FilterDragStart(Item, DragParameters, StandardProcessing)

	Var Index, Data;
	
	DragParameters.Action = DragAction.Move;
	DragParameters.AllowedActions = DragAllowedActions.Move;
	Data = New Array;
	For Each Index In Items.Filter.SelectedRows Do
	
		Item = Filter.FindById(Index);
		Data.Add(Item.Value);
	
	EndDo;
	DragParameters.Value = Data;
	
EndProcedure

&AtClient
Procedure FilterDragCheck(Item, DragParameters, StandardProcessing, Row, Field)
	
	If TypeOf(DragParameters.Value) <> Type("ValueList") Then
		
		DragParameters.Action = DragAction.Cancel;
		DragParameters.AllowedActions = DragAllowedActions.DontProcess;
		StandardProcessing = False;
		
	Else
		
		StandardProcessing = False;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure FilterDrag(Item, DragParameters, StandardProcessing, Row, Field)
	
	Var ValueItem;
	
	StandardProcessing = False;
	For Each ValueItem In DragParameters.Value Do
	
		Result = Filter.FindByValue(ValueItem.Value);
		If Result = Undefined Then
			
			Data = Filter.Add();
			Data.Value = ValueItem.Value;
			Data.Presentation = ValueItem.Presentation;
			
		EndIf;
	
	EndDo;
	Filter.SortByPresentation(SortDirection.Asc);
	Items.Filter.CurrentRow = Filter[0].GetID();
	ThisForm.CurrentItem = Items.Filter;
	
EndProcedure
