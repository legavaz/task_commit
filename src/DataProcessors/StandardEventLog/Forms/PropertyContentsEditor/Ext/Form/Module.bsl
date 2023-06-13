
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	LoadedFile = ?(Parameters.JournalFile = Undefined, "", Parameters.JournalFile);
	
EndProcedure

&AtServer
Function GetEventLogFilterValuesOnServer(columns)
	
	Var Processing, FilterParametersStucture, Item;
	
	Processing = FormAttributeToValue("Object");
	FilterParametersStucture = GetEventLogFilterValues(columns, LoadedFile);
	For Each Item In FilterParametersStucture Do
		FilterParametersStucture.Delete(Item.Key);
		FilterParametersStucture.Insert(Processing.TermRu2En(Item.Key), Item.Value);
	EndDo;
	
	Return FilterParametersStucture;
	
EndFunction

&AtServer
Procedure SortEditList()
	
	Var TreeObject, TreeItem, NewItem, TreeItem2, NewItem2;
	
	TreeObject = New ValueTree;
	TreeObject.Columns.Add("Mark");
	TreeObject.Columns.Add("Value");
	TreeObject.Columns.Add("Presentation");
	TreeObject.Columns.Add("ForSorting", New TypeDescription("Number", New NumberQualifiers(5, 0, AllowedSign.Any)));
	
	For Each TreeItem in List.GetItems() Do
		NewItem = TreeObject.Rows.Add();
		FillPropertyValues(NewItem, TreeItem);
		For Each TreeItem2 in TreeItem.GetItems() Do
			NewItem2 = NewItem.Rows.Add();
			FillPropertyValues(NewItem2, TreeItem2);
		EndDo;
	EndDo;
	
	TreeObject.Rows.Sort("ForSorting Asc, Presentation Asc", True, New CompareValues);
	List.GetItems().Clear();
	
	For Each TreeItem in TreeObject.Rows Do
		NewItem = List.GetItems().Add();
		FillPropertyValues(NewItem, TreeItem);
		For Each TreeItem2 in TreeItem.Rows Do
			NewItem2 = NewItem.GetItems().Add();
			FillPropertyValues(NewItem2, TreeItem2);
		EndDo;
	EndDo;
	
EndProcedure

&AtServer
Procedure ConvertUserNames()
	
	Var Processing, Item;
	
	Processing = FormAttributeToValue("Object");
	
	For Each Item In List.GetItems() Do
		
		Item.Presentation = Processing.GetDBUserName(New UUID(Item.Presentation), Item.Value, True);
		
	EndDo;
	
EndProcedure

&AtClientAtServerNoContext
Function IsTransaction(CheckedString)
	
	If StrOccurrenceCount(CheckedString, "Transaction") <> 0 OR StrOccurrenceCount(CheckedString, "Транзакция") <> 0 Then
		
		Return True;
		
	Else
		
		Return False;
		
	EndIf;
	
EndFunction

// Function parses the sting by the dot as delimeter
&AtClientAtServerNoContext
Function ParseStringByDots(Val Presentation)
	
	Var Fragments, i;
	
	Fragments = New Array;
	Presentation = StrReplace(Presentation, ".", Chars.LF);
	For i=1 To StrLineCount(Presentation) Do
		
		Fragments.Add(TrimAll(StrGetLine(Presentation, i)));
		
	EndDo;
	
	Return Fragments;
	
EndFunction

/////////////////////////////////////////////////////////////////////////////////////////
// procedures exported

&AtClient
Procedure SetEditorParameters(ListToEdit, ParametersInUse) Export
	
	Var FilterParametersStructure, FilterValues, ListItems, Item, ItIsTree;
	
	// store on future use
	UseParameter = ParametersInUse;
	If Not IsBlankString(UseParameter) Then
		FilterParametersStructure = GetEventLogFilterValuesOnServer(UseParameter);
		FilterValues = FilterParametersStructure[UseParameter];
	EndIf;
	
	If TypeOf(FilterValues) = Type("Array") Then
		ListItems = List.GetItems();
		For Each Item In FilterValues Do
			NewItem = ListItems.Add();
			NewItem.Mark = False;
			NewItem.Value = Item;
			If UseParameter = "Сеанс" Or UseParameter = "Session" Or
				UseParameter = "ОсновнойIPПорт" Or UseParameter = "Port" Or
				UseParameter = "ВспомогательныйIPПорт" Or UseParameter = "SyncPort" Then 
				NewItem.Presentation = Format(Item, "NG=0");
			Else
				NewItem.Presentation = Item;
			EndIf;
		EndDo;
	ElsIf TypeOf(FilterValues) = Type("Map") Then
		If UseParameter = "Событие" Or UseParameter = "Event" Or
				UseParameter = "Метаданные" Or UseParameter = "Metadata" Then 
			 
			For Each Item In FilterValues Do
				NewItem = GetTreeNode(Item.Value, Item.Key);
				NewItem.Mark = False;
				If IsBlankString(NewItem.Value) Then
					NewItem.Value = Item.Key;
				Else
					NewItem.Value = NewItem.Value + Chars.LF + Item.Key;
				Endif;
			EndDo;
		Else
			ListItems = List.GetItems();
			For Each Item In FilterValues Do
				NewItem = ListItems.Add();
				NewItem.Mark = False;
				NewItem.Value = Item.Key;
				If (UseParameter = "Пользователь" Or UseParameter = "User") Then
					NewItem.Value = Item.Value;
					NewItem.Presentation = Item.Key;
				Else
					NewItem.Presentation = Item.Value;
				EndIf;
			EndDo;
			If (UseParameter = "Пользователь" Or UseParameter = "User") Then
				ConvertUserNames();
			EndIf;
		EndIf;
	EndIf;
	// mark tree nodes, if exists in ListToEdit
	MarkExistsItems(List.GetItems(), ListToEdit);
	// check items to have subitems, if not, switch to list mode
	ItIsTree = False;
	For Each Item In List.GetItems() Do
		If Item.GetItems().Count() > 0 Then 
			ItIsTree = True;
			Break;
		EndIf;
	EndDo;
	If Not ItIsTree Then
		Items.List.Representation = TableRepresentation.List;
	EndIf;
EndProcedure

&AtClient
Procedure GetListEdited(ListToEdit) Export
	
	Var HasUnmarked, Result;
	
	ListToEdit.Clear();
	HasUnmarked = False;
	Result = GetSubtreeList(ListToEdit, List.GetItems());
	
	if UseParameter = "Событие" OR UseParameter = "Event" Then
		If Result.ItemsMarked = 0 OR (Result.ItemsAll - Result.ItemsMarked = Result.TransactionAll) Then
			ListToEdit.Clear(); // all marked, so nothing to filter
		EndIf;
	Else
		If Result.ItemsAll = Result.ItemsMarked OR Result.ItemsMarked = 0 Then
			ListToEdit.Clear(); // all marked, so nothing to filter
		EndIf;
	EndIf;
	
EndProcedure

&AtClient
Function GetSubtreeList(ListToEdit, TreeNodes, Result = Undefined)
	
	Var Item;
	
	If Result = Undefined Then
		Result = New Structure("ItemsAll, ItemsMarked, TransactionAll, TransactionMarked", 0, 0, 0, 0);
	EndIf;
	For Each Item In TreeNodes Do
		If Item.GetItems().Count() <> 0 Then
			If IsTransaction(Item.Presentation) Then
				Result.TransactionAll = Result.TransactionAll + Item.GetItems().Count();
			EndIf;
			GetSubtreeList(ListToEdit, Item.GetItems(), Result);
		Else
			Result.ItemsAll = Result.ItemsAll + 1;
			If Item.Mark Then
				NewListItem = ListToEdit.Add();
				NewListItem.Value = Item.Value;
				NewListItem.Presentation = CalcPresentation(Item);
				Result.ItemsMarked = Result.ItemsMarked + 1;
				If IsTransaction(Item.Value) Then
					Result.TransactionMarked = Result.TransactionMarked + 1;
				EndIf;
			EndIf;
		EndIf;
	EndDo;
	Return Result;
	
EndFunction

/////////////////////////////////////////////////////////////////////////////////////////
// Additional procedures

&AtClient
Function GetTreeNode(Presentation, Value)
	
	Var PresentationStrings, RealDataStrings;
	Var TreeNodes, TreeNode, NodeName, NodeValue;
	Var ParentPathPresentation, ParentDataPath, i, Item;
	
	PresentationStrings = ParseStringByDots(Presentation);
	RealDataStrings = ParseStringByDots(Value);
	If PresentationStrings.Count() = 1 Then
		TreeNodes = List.GetItems();
		NodeName = PresentationStrings[0];
		NodeValue = RealDataStrings[0];
	Else
		// get path to parent node
		ParentPathPresentation = "";
		ParentDataPath = "";
		For i = 0 To PresentationStrings.Count() - 2 Do
			If Not IsBlankString(ParentPathPresentation) Then
				ParentPathPresentation = ParentPathPresentation + ".";
				ParentDataPath = ParentDataPath + ".";
			EndIf;
			ParentPathPresentation = ParentPathPresentation + PresentationStrings[i];
			ParentDataPath = ParentDataPath + RealDataStrings[i];
		EndDo;
		TreeNodes = GetTreeNode(ParentPathPresentation, ParentDataPath).GetItems();
		NodeName = PresentationStrings[PresentationStrings.Count() - 1];
	EndIf;
	
	For Each Item In TreeNodes Do
		If Item.Presentation = NodeName Then
			Return Item;
		EndIf;
	EndDo;
	
	// Not finded, let`s create
	TreeNode = TreeNodes.Add();
	TreeNode.Presentation = NodeName;
	TreeNode.Value = NodeValue;
	TreeNode.Mark = False;
	// Основные системные события по данным: 200
	//	_$Data$_.New
	//	_$Data$_.Update
	//	_$Data$_.Delete
	// Прочие события (включая нижеперечисленные): 400
	//	_$Data$_.TotalsPeriodUpdate
	//	_$Data$_.TotalsMaxPeriodUpdate
	//	_$Data$_.TotalsMinPeriodUpdate
	//	_$Data$_.SetStandardODataInterfaceContent
	//	_$Data$_.Unpost
	//	_$Data$_.Post
	// Системные события по предопределенным данным: 600
	//	_$Data$_.NewPredefinedData
	//	_$Data$_.UpdatePredefinedData
	//	_$Data$_.PredefinedDataInitialization
	//	_$Data$_.DeletePredefinedData
	//	_$Data$_.SetPredefinedDataInitialization
	// Все остальное: 400
	// common data events
	
	// Основным событиям по данным устанавливаем повышенный приоритет сортировки = 200;
	// системным событиям по предопределенным данным - пониженный приоритет сортировки: 600;
	// всем остальным событиям устанавливаем нормальный приоритет сортировки = 400.
	
	If Value = "_$Data$_.New" OR Value = "_$Data$_.Update" OR Value = "_$Data$_.Delete" Then
		TreeNode.ForSorting = 200;
	// predefined data events
	ElsIf Value = "_$Data$_.NewPredefinedData" OR Value = "_$Data$_.UpdatePredefinedData" OR Value = "_$Data$_.DeletePredefinedData"
		OR Value = "_$Data$_.PredefinedDataInitialization" OR Value = "_$Data$_.SetPredefinedDataInitialization" Then
		TreeNode.ForSorting = 600;
	// other data events
	Else
		TreeNode.ForSorting = 400;
	EndIf;
	
	Return TreeNode;
	
EndFunction

&AtClient
Procedure MarkExistsItems(TreeNodes, ListToEdit)
	
	Var TreeNode, ListItem, PresentationCalculated;
	
	If ListToEdit.Count() = 0 Then
		// Empty list means "Default values" - all mark, except Transaction events 
		SetMarks(True);
		If UseParameter = "Событие" OR UseParameter = "Event" Then
			For Each TreeNode in TreeNodes Do
				If IsTransaction(TreeNode.Presentation) Then
					MarkTreeNode(TreeNode.GetID(), False);
				EndIf;
			EndDo;
		EndIf;
		Return;
	EndIf;
	For Each TreeNode In TreeNodes Do
		If TreeNode.GetItems().Count() <> 0 Then 
			MarkExistsItems(TreeNode.GetItems(), ListToEdit);
		Else
			PresentationCalculated = CalcPresentation(TreeNode);
			For Each ListItem In ListToEdit Do
				If PresentationCalculated = ListItem.Presentation Then
					MarkTreeNode(TreeNode.GetID(), True);
					Break;
				EndIf;
			EndDo;
		EndIf;
	EndDo;
	
EndProcedure

&AtClient
Procedure MarkTreeNode(TreeNodeID, Mark, CheckParentState = True)
	
	Var TreeNode, Subitem;
	
	TreeNode = List.FindByID(TreeNodeID);
	TreeNode.Mark = Mark;
	For Each Subitem In TreeNode.GetItems() Do
		MarkTreeNode(Subitem.GetID(), Mark, False);
	EndDo;

	If CheckParentState Then
		CheckNodeMarkState(TreeNode.GetParent());
	EndIf;
	
EndProcedure

&AtClient
Procedure CheckNodeMarkState(Node)
	
	Var Subnodes, TrueExists, FalseExists;
	
	If Node = Undefined Then
		Return;
	EndIf;
	
	Subnodes = Node.GetItems();
	If Subnodes.Count() = 0 Then
		Return;
	EndIf;
	
	TrueExists = False;
	FalseExists = False;
	For Each Subnode In Subnodes Do
		If Subnode.Mark Then
			TrueExists = True;
			If FalseExists Then
				Break;
			EndIf;
		Else
			FalseExists = True;
			If TrueExists Then
				Break;
			EndIf;
		EndIf;
	EndDo;
	
	If TrueExists Then
		If FalseExists Then
			If Node.Mark Then
				Node.Mark = False;
				CheckNodeMarkState(Node.GetParent());
			EndIf;
		Else
			If Not Node.Mark Then
				Node.Mark = True;
				CheckNodeMarkState(Node.GetParent());
			EndIf;
		EndIf;
	Else
		If Node.Mark Then
			Node.Mark = False;
			CheckNodeMarkState(Node.GetParent());
		EndIf;
	EndIf;
	
EndProcedure

&AtClient
Function CalcPresentation(TreeNode)
	
	If TreeNode = Undefined Then
		Return "";
	EndIf;
	If TreeNode.GetParent() = Undefined Then
		Return TreeNode.Presentation;
	EndIf;
	Return CalcPresentation(TreeNode.GetParent()) + ". " + TreeNode.Presentation;
	
EndFunction

&AtClient
Procedure SetMarks(Value)
	
	Var TreeNode;
	
	For Each TreeNode In List.GetItems() Do
		
		MarkTreeNode(TreeNode.GetID(), Value, False);
		
	EndDo;
	
EndProcedure

/////////////////////////////////////////////////////////////////////////////////////////
// Commands and events
&AtClient
Procedure SetAllFlags()
	
	SetMarks(True);
	
EndProcedure

&AtClient
Procedure ClearAllFlags()
	
	SetMarks(False);
	
EndProcedure

&AtClient
Procedure OnChangedMark(Item)
	
	MarkTreeNode(Items.List.CurrentData.GetID(), Items.List.CurrentData.Mark);
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	SortEditList();
	
EndProcedure
