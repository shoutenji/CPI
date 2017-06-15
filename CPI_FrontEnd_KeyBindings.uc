class CPI_FrontEnd_KeyBindings extends CPIFrontEnd_Screen 
    config(UI);

var GFxClikWidget KeyBindBackBtn, DefaultButton, KeyBindAcceptBtn;
var GFxObject KeyBindTitle, InstructionsTxt, Keybind1, Keybind2, keybindSubtitle;

var GFxClikWidget KeyScrollBar;

//bind key box area
var GFxClikWidget BindKeyCancelButton, BindKeyAcceptButton;
var GFxObject BindKeyTxt, KeyBindInstructionsTxt, FunctionNameTxt, KeyBindInputBox, BindKeyBox, BindDialogOKBtn;

//KeybindMenuList
var GFxClikWidget KeybindMenuList, KeyBindList;

//keybind listbar
var GFxClikWidget btn1, btn2;
var GFxObject lbl1;

var int btn1index, btn2index;
var bool blnCaptureNextKey;
var bool blnKeybindAreaVisible;

struct KeybindSection
{
	var	string		strFriendlyName, strKey1, strKey2, GBA_KeyName;
};
var		array<KeybindSection>		Misc, Weapons, Communication, Menus, Mouse, Interactions, Movement;
var		array<KeybindSection>	    SelectedKeybindSection;
var     int KeybindDataProviderSelectedIndex;

var localized string strMovement,strInteraction,strMouse,strMenus,strCommunication,strWeapons,strMisc;
var localized string strMenuLabel, strFriendlyName, KeyBindOne, KeyBindTwo;
var localized string strBindKeyCancelButton, strBindKeyAcceptButton, strInstructionsTxt, strFunctionNameTxt, strKeyBindInstructionsTxt;
var localized string strBindKeyTxt, strDuplicateKeyFunctionTxt, strDuplicateKeyInstructionsTxt, strDuplicateKeyTxt;
var localized string strYes, strNo, strDefaultButton, strKeyBindAcceptBtn, strKeyBindBackBtn;

//bindkey globals
var name oldBindName, newBindName;
var string newBindCommand, oldBindCommand;
var bool blnSecondaryBind;

function BuildMovementList()
{
	Movement = PopulateList(class'CPUIDataProvider_Movement_KeyBinding', Movement);
}

function BuildInteractionList()
{
	Mouse = PopulateList(class'CPUIDataProvider_Mouse_KeyBinding', Mouse);
}

function BuildMouseList()
{
	Interactions = PopulateList(class'CPUIDataProvider_Interaction_KeyBinding', Interactions);
}

function BuildMenusList()
{
	Menus = PopulateList(class'CPUIDataProvider_Menus_KeyBinding', Menus);
}

function BuildCommunicationList()
{
	Communication = PopulateList(class'CPUIDataProvider_Communication_KeyBinding', Communication);
}

function BuildWeaponsList()
{
	Weapons = PopulateList(class'CPUIDataProvider_Weapons_KeyBinding', Weapons);
}

function BuildMiscList()
{
	Misc = PopulateList(class'CPUIDataProvider_Misc_KeyBinding', Misc);
}

function array<KeybindSection> PopulateList(class<CPUIDataProvider_Base_KeyBinding> theBindClass, array<KeybindSection> theKeyBindSection)
{
	local array<UDKUIResourceDataProvider> ProviderList;  
	local array<KeyBind> TAKeys;
	local int index, keyindex;

	class'UDKUIDataStore_MenuItems'.static.GetAllResourceDataProviders(theBindClass,ProviderList);
	TAKeys= class'CPPlayerInput'.default.Bindings;

	theKeyBindSection.Remove(0, theKeyBindSection.Length); //clear the list down completely to stop duplication.
	theKeyBindSection.Insert(0, ProviderList.Length);	//prepopulate the array so when we insert items they are inserted in the right order using menuorder.

	for(index = 0 ; index < ProviderList.Length ; index++)
	{
		for(keyindex = 0 ; keyindex < TAKeys.Length ; keyindex++)
		{			
			if(TAKeys[keyindex].Command == CPUIDataProvider_Base_KeyBinding(ProviderList[index]).Command)
			{
				theKeyBindSection[CPUIDataProvider_Base_KeyBinding(ProviderList[index]).MenuOrder].strFriendlyName = CPUIDataProvider_Base_KeyBinding(ProviderList[index]).FriendlyName;
				theKeyBindSection[CPUIDataProvider_Base_KeyBinding(ProviderList[index]).MenuOrder].GBA_KeyName = CPUIDataProvider_Base_KeyBinding(ProviderList[index]).Command;

				if(Len(theKeyBindSection[CPUIDataProvider_Base_KeyBinding(ProviderList[index]).MenuOrder].strKey1) == 0)
				{
					if(string(TAKeys[keyindex].Name) != "None")
					{
						theKeyBindSection[CPUIDataProvider_Base_KeyBinding(ProviderList[index]).MenuOrder].strKey1 = string(TAKeys[keyindex].Name);
					}

				}
				else if(Len(theKeyBindSection[CPUIDataProvider_Base_KeyBinding(ProviderList[index]).MenuOrder].strKey2) == 0) //basically if we have any more keybinds past the second in the ini file - ignore them.
				{
					if(string(TAKeys[keyindex].Name) != "None")
					{
						theKeyBindSection[CPUIDataProvider_Base_KeyBinding(ProviderList[index]).MenuOrder].strKey2 = string(TAKeys[keyindex].Name);
					}
				}
			}
		}
	}
	return theKeyBindSection;
}

function PopulateKeyBindList(array<KeybindSection> Section)
{
	local GFxObject DataProvider;
	local GFxObject TempObj;

	local int index;

	DataProvider=CreateArray();   

	for (index = 0 ; index < Section.Length ; index++ )
	{
		TempObj=CreateObject("Object");

		TempObj.SetString("lbl1", Section[index].strFriendlyName);      
		TempObj.SetString("btn1",Section[index].strKey1);
		TempObj.SetString("btn2",Section[index].strKey2);
		//`Log("Setting " $ Section[index].strFriendlyName $ " btn1 " $ Section[index].strKey1 $ " btn2 " $ Section[index].strKey2);
		DataProvider.SetElementObject(index, TempObj);
	}

	KeyBindList.SetObject("dataProvider",DataProvider); 
}

function PopulateKeybindMenuList()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;

    DataProvider=CreateArray();     

	TempObj=CreateObject("Object");
    TempObj.SetString("label", strMovement);                           
    DataProvider.SetElementObject(0, TempObj);

	TempObj=CreateObject("Object");
    TempObj.SetString("label", strInteraction);                           
    DataProvider.SetElementObject(1, TempObj);

	TempObj=CreateObject("Object");
    TempObj.SetString("label", strMouse);                           
    DataProvider.SetElementObject(2, TempObj);

	TempObj=CreateObject("Object");
    TempObj.SetString("label", strMenus);                           
    DataProvider.SetElementObject(3, TempObj);

	TempObj=CreateObject("Object");
    TempObj.SetString("label", strCommunication);                           
    DataProvider.SetElementObject(4, TempObj);

	TempObj=CreateObject("Object");
    TempObj.SetString("label", strWeapons);                           
    DataProvider.SetElementObject(5, TempObj);

	TempObj=CreateObject("Object");
    TempObj.SetString("label", strMisc);                           
    DataProvider.SetElementObject(6, TempObj);

	KeybindMenuList.SetObject("dataProvider",DataProvider); 
}

function int GetKeyBindMenuList()
{
	return KeybindMenuList.GetFloat("selectedIndex");
}

function Select_KeybindMenuList_Change(GFxClikWidget.EventData ev)
{
	UpdateKeybindDataProviders(Int(ev.target.GetFloat("selectedIndex")));
}

function UpdateKeybindDataProviders(int index)
{
	BuildMovementList();
	BuildInteractionList();
	BuildMouseList();
	BuildMenusList();
	BuildCommunicationList();
	BuildWeaponsList();
	BuildMiscList();

	SelectedKeybindSection.Remove(0,SelectedKeybindSection.Length);
	switch(index)
	{
		case (0):
			//`Log("Movement");
			PopulateKeyBindList(Movement);
			SelectedKeybindSection.Insert(0, Movement.Length);
			SelectedKeybindSection = Movement;
		break;	
		case (1):
			//`Log("Interaction");
			PopulateKeyBindList(Interactions);
			SelectedKeybindSection.Insert(0, Interactions.Length);
			SelectedKeybindSection = Interactions;
		break;	
		case (2):
			//`Log("Mouse");
			PopulateKeyBindList(Mouse);
			SelectedKeybindSection.Insert(0, Mouse.Length);
			SelectedKeybindSection = Mouse;
		break;	
		case (3):
			//`Log("Menus");
			PopulateKeyBindList(Menus);
			SelectedKeybindSection.Insert(0, Menus.Length);
			SelectedKeybindSection = Menus;
		break;	
		case (4):
			//`Log("Communication");
			PopulateKeyBindList(Communication);
			SelectedKeybindSection.Insert(0, Communication.Length);
			SelectedKeybindSection = Communication;
		break;	
		case (5):
			//`Log("Weapons");
			PopulateKeyBindList(Weapons);
			SelectedKeybindSection.Insert(0, Weapons.Length);
			SelectedKeybindSection = Weapons;
		break;	
		case (6):
			//`Log("Misc");
			PopulateKeyBindList(Misc);
			SelectedKeybindSection.Insert(0, Misc.Length);
			SelectedKeybindSection = Misc;
		break;	
		default:
			//`Log("Unknown!");
			PopulateKeyBindList(Movement);
			SelectedKeybindSection.Insert(0, Movement.Length);
			SelectedKeybindSection = Movement;
		break;
	}

	if(SelectedKeybindSection.Length < 8)
	{
		if(KeyScrollBar != none)
			KeyScrollBar.SetVisible(false);
	}
	else
	{
		if(KeyScrollBar != none)
			KeyScrollBar.SetVisible(true);
	}

	KeybindDataProviderSelectedIndex = index;
}

function Select_KeyBindBackBtn(GFxClikWidget.EventData ev)
{
	MoveBackImpl();
}

function Select_KeyBindAcceptBtn(GFxClikWidget.EventData ev)
{
	MoveBackImpl();
}

function Select_DefaultButton(GFxClikWidget.EventData ev)
{
	`Log("Select_DefaultButton");
}

function Select_DuplicateKeyNoButton(GFxClikWidget.EventData ev)
{
	UpdateKeybindDataProviders(KeybindDataProviderSelectedIndex);
	ToggleDuplicateKeyArea(false);
	EnableControls();
}

function Select_DuplicateKeyYesButton(GFxClikWidget.EventData ev)
{
	CPPlayerInput(GetPC().PlayerInput).CPISetBind(oldBindName,newBindName,newBindCommand,oldBindCommand,blnSecondaryBind);		
	UpdateKeybindDataProviders(KeybindDataProviderSelectedIndex);
	ToggleDuplicateKeyArea(false);
	EnableControls();
}

function ToggleDuplicateKeyArea(bool blnShow)
{	
	DisableControls();
	BindKeyTxt.SetString("text",strDuplicateKeyTxt);
	KeyBindInstructionsTxt.SetString("text",strDuplicateKeyInstructionsTxt);
	BindKeyCancelButton.SetString("label",strNo);
	BindKeyAcceptButton.SetString("label",strYes);

	blnKeybindAreaVisible = blnShow;
	BindKeyTxt.SetVisible(blnShow);
 	KeyBindInstructionsTxt.SetVisible(blnShow);
	BindKeyCancelButton.SetVisible(blnShow);
 	BindKeyAcceptButton.SetVisible(blnShow);
	BindKeyBox.SetVisible(blnShow);
	FunctionNameTxt.SetVisible(blnShow);
}

function ToggleBindKeyArea(bool blnShow)
{	
	if(blnShow)
	{
		DisableControls();
	}
	else
	{
		EnableControls();
	}

	BindKeyTxt.SetString("text",strBindKeyTxt);
	KeyBindInstructionsTxt.SetString("text",strKeyBindInstructionsTxt);
	BindKeyCancelButton.SetVisible(false);
 	BindKeyAcceptButton.SetVisible(false);

	blnKeybindAreaVisible = blnShow;
	BindKeyTxt.SetVisible(blnShow);
 	KeyBindInstructionsTxt.SetVisible(blnShow);
 	FunctionNameTxt.SetVisible(blnShow);
 	BindKeyBox.SetVisible(blnShow);
}

function Select_btn1(GFxClikWidget.EventData ev)
{
	blnSecondaryBind = false;

	if (SelectedKeybindSection.Length > int(ev.target.GetString("tag")))
	{
		oldBindName = name(SelectedKeybindSection[int(ev.target.GetString("tag"))].strKey1);
		newBindCommand =  SelectedKeybindSection[int(ev.target.GetString("tag"))].GBA_KeyName;
		FunctionNameTxt.SetString("text",GBAToFriendlyName(newBindCommand));
		ToggleBindKeyArea(true);
		blnCaptureNextKey=true;
	}
}

function Select_btn2(GFxClikWidget.EventData ev)
{
	blnSecondaryBind = true;

	if (SelectedKeybindSection.Length > int(ev.target.GetString("tag")))
	{
		oldBindName = name(SelectedKeybindSection[int(ev.target.GetString("tag"))].strKey2);
		newBindCommand =  SelectedKeybindSection[int(ev.target.GetString("tag"))].GBA_KeyName;
		FunctionNameTxt.SetString("text",GBAToFriendlyName(newBindCommand));
		ToggleBindKeyArea(true);
		blnCaptureNextKey=true;
	}
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled=false;

	switch(WidgetName)
	{
		case ('KeyBindBackBtn'):
			KeyBindBackBtn=GFxClikWidget(Widget);
			KeyBindBackBtn.SetString("label",strKeyBindBackBtn);
			KeyBindBackBtn.AddEventListener('CLIK_press',Select_KeyBindBackBtn);
			bWasHandled=true; 
		break;	
		case ('KeyBindAcceptBtn'):
			KeyBindAcceptBtn=GFxClikWidget(Widget);
			KeyBindAcceptBtn.SetString("label",strKeyBindAcceptBtn);
			KeyBindAcceptBtn.AddEventListener('CLIK_press',Select_KeyBindAcceptBtn);
			bWasHandled=true; 
		break;	
		case ('DefaultButton'):
			DefaultButton=GFxClikWidget(Widget);
			DefaultButton.SetString("label",strDefaultButton);
			DefaultButton.AddEventListener('CLIK_press',Select_DefaultButton);
			DefaultButton.SetVisible(false); //todo code this in.
			bWasHandled=true; 
		break;	
		case ('KeyBindTitle'):
			KeyBindTitle=Widget;
			KeyBindTitle.SetString("text",strMenuLabel);
			bWasHandled=true; 
		break;
		case ('BindKeyCancelButton'):
			BindKeyCancelButton=GFxClikWidget(Widget);
			BindKeyCancelButton.SetVisible(false);
			BindKeyCancelButton.AddEventListener('CLIK_press',Select_DuplicateKeyNoButton);
			bWasHandled=true; 
		break;	
		case ('BindKeyAcceptButton'):
			BindKeyAcceptButton=GFxClikWidget(Widget);
			BindKeyAcceptButton.SetVisible(false);
			BindKeyAcceptButton.AddEventListener('CLIK_press',Select_DuplicateKeyYesButton);
			bWasHandled=true; 
		break;	
		case ('BindDialogOKBtn'):////
			BindDialogOKBtn=GFxClikWidget(Widget);//// is this needed?
			BindDialogOKBtn.SetVisible(false);////
			bWasHandled=true; ////
		break;			
		case ('BindKeyTxt'):
			BindKeyTxt=Widget;
			BindKeyTxt.SetString("text",strBindKeyTxt);
			BindKeyTxt.SetVisible(false);
			bWasHandled=true; 
		break;
		case ('KeyBindInstructionsTxt'):
			KeyBindInstructionsTxt=Widget;
			KeyBindInstructionsTxt.SetString("text",strKeyBindInstructionsTxt);
			KeyBindInstructionsTxt.SetVisible(false);
			bWasHandled=true; 
		break;
		case ('FunctionNameTxt'):
			FunctionNameTxt=Widget;
			FunctionNameTxt.SetString("text",strFunctionNameTxt);
			FunctionNameTxt.SetVisible(false);
			bWasHandled=true; 
		break;
		case ('KeyBindInputBox'):
			KeyBindInputBox=Widget;
			KeyBindInputBox.SetVisible(false);
			bWasHandled=true; 
		break;	
		case ('BindKeyBox'):
			BindKeyBox=Widget;
			BindKeyBox.SetVisible(false);
			bWasHandled=true; 
		break;	

		case ('InstructionsTxt'):
			InstructionsTxt=Widget;
			InstructionsTxt.SetString("text",strInstructionsTxt); //something to possibly add later on
			InstructionsTxt.SetVisible(false);
			bWasHandled=true; 
		break;
		case ('Keybind1'):
			Keybind1=Widget;
			Keybind1.SetString("text",KeyBindOne);
			bWasHandled=true; 
		break;
		case ('Keybind2'):
			Keybind2=Widget;
			Keybind2.SetString("text",KeyBindTwo);
			bWasHandled=true; 
		break;
		case ('keybindSubtitle'):
			keybindSubtitle=Widget;
			keybindSubtitle.SetString("text",strFriendlyName);
			bWasHandled=true; 
		break;
		case ('KeybindMenuList'):
			KeybindMenuList=GFxClikWidget(Widget);
			PopulateKeybindMenuList();
			KeybindMenuList.SetFloat("selectedIndex",0);
			KeybindMenuList.AddEventListener('CLIK_change',Select_KeybindMenuList_Change);
			bWasHandled=true; 
		break;	
		case ('KeyBindList'):
			KeyBindList=GFxClikWidget(Widget);
			UpdateKeybindDataProviders(0);
			bWasHandled=true; 
		break;	
		
		case('Track'):
			//these are handled as part of the scrollbar
			bWasHandled=true; 
		break;
		case('downArrow'):
			//these are handled as part of the scrollbar
			bWasHandled=true; 
		break;
		case('upArrow'):
			//these are handled as part of the scrollbar
			bWasHandled=true; 
		break;
		case('Thumb'):
			//these are handled as part of the scrollbar
			bWasHandled=true; 
		break;
		case('KeyScrollBar'):
			KeyScrollBar=GFxClikWidget(Widget);
			KeyScrollBar.SetVisible(false);
			bWasHandled=true; 
			bWasHandled=true; 
		break;
		case('renderer0'):
			//these are handled as part of the KeybindList
			bWasHandled=true; 
		break;
		case('renderer1'):
			//these are handled as part of the KeybindList
			bWasHandled=true; 
		break;
		case('renderer2'):
			//these are handled as part of the KeybindList
			bWasHandled=true; 
		break;
		case('renderer3'):
			//these are handled as part of the KeybindList
			bWasHandled=true; 
		break;
		case('renderer4'):
			//these are handled as part of the KeybindList
			bWasHandled=true; 
		break;
		case('renderer5'):
			//these are handled as part of the KeybindList
			bWasHandled=true; 
		break;
		case('renderer6'):
			//these are handled as part of the KeybindList
			bWasHandled=true; 
		break;
		case('btn1'):
			btn1=GFxClikWidget(Widget);
			btn1.SetString("tag",string(btn1index));
			btn1index++;
			btn1.AddEventListener('CLIK_press',Select_btn1);
			bWasHandled=true; 
		break;
		case('btn2'):
			btn2=GFxClikWidget(Widget);
			btn2.SetString("tag",string(btn2index));
			btn2index++;
			btn2.AddEventListener('CLIK_press',Select_btn2);
			bWasHandled=true; 
		break;

		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
		`log( "CPI_FrontEnd_KeyBindings::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);

	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

function string GBAToFriendlyName(string strGBA)
{
	local int i;

	//HORRIBLE HACK - SORRY GUYS!
	for (i=0;i<Misc.Length;i++) 
	{
		if(Misc[i].GBA_KeyName == strGBA)
		{
			return Misc[i].strFriendlyName;
		}
	}

	for (i=0;i<Weapons.Length;i++) 
	{
		if(Weapons[i].GBA_KeyName == strGBA)
		{
			return Weapons[i].strFriendlyName;
		}
	}

	for (i=0;i<Communication.Length;i++) 
	{
		if(Communication[i].GBA_KeyName == strGBA)
		{
			return Communication[i].strFriendlyName;
		}
	}

	for (i=0;i<Menus.Length;i++) 
	{
		if(Menus[i].GBA_KeyName == strGBA)
		{
			return Menus[i].strFriendlyName;
		}
	}

	for (i=0;i<Mouse.Length;i++) 
	{
		if(Mouse[i].GBA_KeyName == strGBA)
		{
			return Mouse[i].strFriendlyName;
		}
	}

	for (i=0;i<Interactions.Length;i++) 
	{
		if(Interactions[i].GBA_KeyName == strGBA)
		{
			return Interactions[i].strFriendlyName;
		}
	}

	for (i=0;i<Movement.Length;i++) 
	{
		if(Movement[i].GBA_KeyName == strGBA)
		{
			return Movement[i].strFriendlyName;
		}
	}

	return "GBA NAME ERROR!";
}

function bool OnFilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if(blnCaptureNextKey && InputEvent == EInputEvent.IE_Pressed)
	{
		blnCaptureNextKey = false;
		newBindName = ButtonName;
		//`Log("ControllerId"@ControllerId@"newBindName"@newBindName@"InputEvent"@InputEvent);
		oldBindCommand = GetPC().PlayerInput.GetBind(newBindName);
		//`Log("The old key is " $ oldBindName);
		//`Log("The new key is " $ newBindName);
		//`Log("The GBA_KeyName for the new key is " $ newBindCommand);		
		//`Log("The GBA_KeyName for the old key is " $ oldBindCommand);


		if(oldBindCommand == newBindCommand)
		{
			CPPlayerInput(GetPC().PlayerInput).CPISetBind(oldBindName,newBindName,newBindCommand,oldBindCommand,blnSecondaryBind);		
			UpdateKeybindDataProviders(KeybindDataProviderSelectedIndex);
			ToggleBindKeyArea(false);

			//update console keys if they have changed.
			if(newBindCommand == "GBA_TypeKey")
			{
				//update console key
				CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).SetTypeKey(newBindName);
			}
			else if(newBindCommand == "GBA_ConsoleKey")
			{
				//update console key
				CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).SetConsoleKey(newBindName);
			}
		}
		else if(oldBindCommand == "")
		{
			CPPlayerInput(GetPC().PlayerInput).CPISetBind(oldBindName,newBindName,newBindCommand,oldBindCommand,blnSecondaryBind);		
			UpdateKeybindDataProviders(KeybindDataProviderSelectedIndex);
			ToggleBindKeyArea(false);

			//update console keys if they have changed.
			if(newBindCommand == "GBA_TypeKey")
			{
				//update console key
				CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).SetTypeKey(newBindName);
			}
			else if(newBindCommand == "GBA_ConsoleKey")
			{
				//update console key
				CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).SetConsoleKey(newBindName);
			}
		}
		else
		{
			if(ButtonName != 'Escape')
			{
				FunctionNameTxt.SetString("text",GBAToFriendlyName(oldBindCommand));
				ToggleBindKeyArea(false);
				ToggleDuplicateKeyArea(true);

				//update console keys if they have changed.
				if(newBindCommand == "GBA_TypeKey")
				{
					//update console key
					CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).SetTypeKey(newBindName);
				}
				else if(newBindCommand == "GBA_ConsoleKey")
				{
					//update console key
					CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).SetConsoleKey(newBindName);
				}
			}
		}
		return true;
	}
	return false;
}

function OnEscapeKeyPress()
{
	if(blnKeybindAreaVisible)
	{
		ToggleBindKeyArea(false);
	}
	else
	{
		super.OnEscapeKeyPress();
	}
}

function MoveBackImpl()
{
	super.MoveBackImpl();
	CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).blnToggleConsole = true;
}

function DisableControls()
{
	KeybindMenuList.SetBool("disabled",true);
	KeyBindList.SetBool("disabled",true);
	KeyBindBackBtn.SetBool("disabled",true);
	KeyBindAcceptBtn.SetBool("disabled",true);
}

function EnableControls()
{
	KeybindMenuList.SetBool("disabled",false);
	KeyBindList.SetBool("disabled",false);
	KeyBindBackBtn.SetBool("disabled",false);
	KeyBindAcceptBtn.SetBool("disabled",false);
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="DuplicateKeyNoButton",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="DuplicateKeyYesButton",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="KeyBindAcceptBtn",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="KeyBindBackBtn",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="DefaultButton",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="BindKeyCancelButton",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="BindKeyAcceptButton",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="BindDialogOKBtn",WidgetClass=class'GFxClikWidget'))	// do we need this?

	SubWidgetBindings.Add((WidgetName="KeybindMenuList",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="KeyBindList",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btn1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btn2",WidgetClass=class'GFxClikWidget'))		
	
	SubWidgetBindings.Add((WidgetName="KeyScrollBar",WidgetClass=class'GFxClikWidget'))	

	
	btn1index = 0
	btn2index = 0
	blnSecondaryBind = false;
}
