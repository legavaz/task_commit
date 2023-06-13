
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	Var CommonFilterInfo, Processing, CurrentFilterData, FilterParametersList, FilterKeyEn;
	Var Param, ReadKey, NewParameter, CurrentFilterValues, LogValues, StructItem, LogValuesMap;
	Var CurrentFilterValuePresentation;
	
	CommonFilterInfoAddr = Parameters.CommonFilterInfoAddr;
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	MetaPath = CommonFilterInfo.MetaPath;
	LoadedFile = CommonFilterInfo.JournalDataFileName;
	
	Processing = FormAttributeToValue("Object");
	SessionDataList.Clear();
	
	// получим структуру со значениями отбора, если она есть
	CurrentFilterData = Undefined; // structure
	CommonFilterInfo.FilterData.Property("SessionDataSeparation", CurrentFilterData);
	
	FilterParametersStucture = GetEventLogFilterValues("SessionDataSeparation", LoadedFile);
	For Each FilterParametersList In FilterParametersStucture Do
		
		FilterKeyEn = Processing.TermRu2En(FilterParametersList.Key);
		If Upper(FilterKeyEn) = "SESSIONDATASEPARATION" Then
			
			For Each Param In FilterParametersList.Value Do
				
				ReadKey = "SESSIONDATASEPARATIONVALUES";
				// создадим строку ТЗ про общий реквизит
				NewParameter = SessionDataList.Add();
				NewParameter.Use = False;
				NewParameter.ParameterName = Param.Key;
				NewParameter.ParameterPresentation = Param.Value;
				NewParameter.ValueListPresentation = "";
				
				// теперь сформируем представление отбора (если задан) и заполним список значений отбора
				If CurrentFilterData <> Undefined Then
					
					// проверим, есть в структуре отбора текущий общий реквизит и если есть - обработаем его
					CurrentFilterValues = Undefined; // array or item
					If CurrentFilterData.Property(Param.Key, CurrentFilterValues) Then
						
						LogValues = GetEventLogFilterValues(FilterKeyEn + "." + Param.Key, LoadedFile); // structure -> name-map-(key-map)
						For Each StructItem In LogValues Do

							LogValues.Delete(StructItem.Key);
							LogValues.Insert(Upper(Processing.TermRu2En(StructItem.Key)), StructItem.Value);
							
						EndDo;
						
						// а если в легенде ничего нет - тогда и искать не будем ничего
						LogValuesMap = Undefined;
						If LogValues.Property(ReadKey) Then
							
							LogValuesMap = LogValues[ReadKey].Get(Param.Key);
							if LogValuesMap <> Undefined AND LogValuesMap.Count() <> 0 Then
								
								If TypeOf(CurrentFilterValues) = Type("Array") Then
									
									// в фильтре - несколько значений
									For Each CurrentFilterValue In CurrentFilterValues Do
										
										CurrentFilterValuePresentation = NormalizePresentation(CurrentFilterValue, LogValuesMap.Get(CurrentFilterValue));
										NewParameter.ParameterValue.Add(CurrentFilterValue, CurrentFilterValuePresentation);
										
									EndDo;
									
								Else
									
									// в фильтре - одиночное значение
									CurrentFilterValuePresentation = NormalizePresentation(CurrentFilterValues, LogValuesMap.Get(CurrentFilterValues));
									NewParameter.ParameterValue.Add(CurrentFilterValues, CurrentFilterValuePresentation);
									
								EndIf;
								
								NewParameter.Use = ?(NewParameter.ParameterValue.Count(), True, False);
								NewParameter.ValueListPresentation = GetItemPresentation(NewParameter.ParameterValue);
								
							EndIf;
							
						EndIf;
						
					EndIf;
					
				EndIf;
				
			EndDo;
			
		EndIf;
		
	EndDo;
	
EndProcedure

&AtClientAtServerNoContext
Function NormalizePresentation(Val Value, Val Presentation)
	
	If Value = "UnsettingAttribute" Then
		
		// special value for filter unsetting common attribute
		Presentation = NStr("ru = '<Не задано>';sys = 'EventLog.PropertyEditor2.UnsettingAttribute'", "ru");
		
	ElsIf Presentation = Undefined Then
		
		// для такого значения отбора нет представления - неожиданное явление!
		Presentation = "<?> " + String(Value);
		
	EndIf;
	
	Return Presentation;
	
EndFunction

&AtClientAtServerNoContext
Function GetItemPresentation(FilterList)
	
	Var ValueListPresentation, Item;
	
	ValueListPresentation = "";
	For Each Item In FilterList Do
		
		ValueListPresentation = ValueListPresentation + Item.Presentation + "; ";
		
	EndDo;
	
	Return Left(ValueListPresentation, StrLen(ValueListPresentation)-2);
	
EndFunction

&AtServer
Procedure MakeFilterDataAtServer()
	
	Var Processing, SessionData, Presentation, SessionDataItem;
	Var ValueArray, PresentationArray, ValueItem;
	
	Processing = FormAttributeToValue("Object");
	CommonFilterInfo = GetFromTempStorage(CommonFilterInfoAddr);
	SessionData = New Structure;
	Presentation = "";
	
	For Each SessionDataItem In SessionDataList Do
		
		// This parameter not use
		If Not SessionDataItem.Use Then
			
			Continue;
			
		EndIf;
		
		Presentation = Presentation + SessionDataItem.ParameterPresentation + ": ";
		
		ValueArray = New Array;
		PresentationArray = New Array;
		For Each ValueItem In SessionDataItem.ParameterValue Do
		
			ValueArray.Add(ValueItem.Value);
			PresentationArray.Add(ValueItem.Presentation);
		
		EndDo;
		
		SessionData.Insert(SessionDataItem.ParameterName, ValueArray);
		Presentation = Presentation + Processing.ConvertArrayToString(PresentationArray) + "; ";
	
	EndDo;
	CommonFilterInfo.FilterData.Insert("SessionDataSeparation", SessionData);
	CommonFilterInfo.SessionDataFilterPresentation = Left(Presentation, StrLen(Presentation)-2);
	
	PutToTempStorage(CommonFilterInfo, CommonFilterInfoAddr);
	
EndProcedure

&AtClient
Procedure MakeChoice(CurrentData)
	
	Var EditorFormName, Params, EditorForm;
	
	EditorFormName = MetaPath+".Form.PropertyContentsEditor2";
	If EditorFormName = Undefined Then 
		Return;
	EndIf;
	
	Params = New Structure;
	Params.Insert("JournalFile", LoadedFile);
	Params.Insert("UseParameter", "SessionDataSeparation");
	Params.Insert("UseParameterPresentation", CurrentData.ParameterPresentation);
	Params.Insert("KeyValue", CurrentData.ParameterName);
	Params.Insert("SelectList", CurrentData.ParameterValue);
	EditorForm = GetForm(EditorFormName, Params);
	ExtraParameters = New Structure;
	ExtraParameters.Insert("EditorForm", EditorForm);
	ExtraParameters.Insert("CurrentData", CurrentData);
	Callback = New NotifyDescription("MakeChoiceCallback", ThisForm, ExtraParameters);
	EditorForm.OnCloseNotifyDescription = Callback;
	EditorForm.Open();
	
EndProcedure

&AtClient
Procedure MakeChoiceCallback(Result, ExtraParameters) Export
	
	CurrentData = ExtraParameters.CurrentData;
	EditorForm = ExtraParameters.EditorForm;
	If Result = DialogReturnCode.OK Then
		CurrentData.ParameterValue = EditorForm.GetListEdited();
	EndIf;
	CurrentData.ValueListPresentation = GetItemPresentation(CurrentData.ParameterValue);
	CurrentData.Use = ?(CurrentData.ParameterValue.Count() = 0, False, True);
	
EndProcedure

/////////////////////////////////////////////////////////////////////////////////////////
// Commands and events

&AtClient
Procedure SessionDataListValueListPresentationStartChoice(Item, ChoiceData, StandardProcessing)
	
	StandardProcessing = False;
	MakeChoice(Items.SessionDataList.CurrentData);
	
EndProcedure

&AtClient
Procedure SessionDataListUseOnChange(Item)

	Var CurrentData;
	
	CurrentData = Items.SessionDataList.CurrentData;
	If CurrentData.Use Then
		MakeChoice(CurrentData);
	EndIf;
	
EndProcedure

&AtClient
Procedure OKCommand(Command)
	
	MakeFilterDataAtServer();
	Close(DialogReturnCode.OK);
	
EndProcedure

&AtClient
Procedure TurnAllOFF(Command)
	
	Var DataItem;
	
	For Each DataItem In SessionDataList Do
		DataItem.Use = False;
	EndDo;
	
EndProcedure

&AtClient
Procedure TurnAllON(Command)
	
	Var DataItem;
	
	For Each DataItem In SessionDataList Do
		DataItem.Use = True;
	EndDo;
	
EndProcedure
