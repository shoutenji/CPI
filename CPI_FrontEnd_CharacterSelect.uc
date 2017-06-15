class CPI_FrontEnd_CharacterSelect extends CPIFrontEnd_Screen
    config(UI);

var GFxClikWidget JoinGame_Button, Random_Button, Back_Button, CharacterButton1, CharacterButton2, CharacterButton3, CharacterButton4;
var GFxObject SelectYourCharacter_Label, Character_Image;
var localized string SelectYourCharacter, JoinGame_ButtonText, Random_ButtonText, Back_ButtonText;
var localized string SWATMaleOneButtonText, SWATFemaleOneButtonText, MERCMaleOneButtonText, MERCFemaleOneButtonText;

var int CharacterSelected;


function InitChar()
{
	//bit of a hack so escape doesnt quit you out of the menus.
	MenuManager.ClearFocusIgnoreKeys();

	//set portrait
	if(CPHud(GetPC().myHUD).intTeamSelected == 1)
	{
		Character_Image.GotoAndStop("swatmale");
		CharacterButton1.SetString("label",SWATMaleOneButtonText);
		CharacterButton2.SetString("label",SWATFemaleOneButtonText);
	}
	else
	{
		Character_Image.GotoAndStop("mercmale");
		CharacterButton1.SetString("label",MERCMaleOneButtonText);
		CharacterButton2.SetString("label",MERCFemaleOneButtonText);
	}

	//highlight the skin of the selected character
	SetHighlightForSelectedCharacterButton();
}

function SetHighlightForSelectedCharacterButton()
{
	local class<CPFamilyInfo> theInfo;

	if(CPPawn(GetPC().Pawn) == none )
	{
		//we dont have a character so set it to the first button in the list
		CharacterButton1.SetBool("selected",true);
		CharacterButton1.setBool("focused",true);
		return;
	}
	else
	{
		if(CPPawn(GetPC().Pawn).CurrCharClassInfo != none)
		{
			`Log("CPPawn(GetPC().Pawn).CurrCharClassInfo != none");
			theInfo = CPPawn(GetPC().Pawn).CurrCharClassInfo;

			//@Evan your checks on theInfo will allow you to determine which button to select.
			if (CPHud(GetPC().myHUD).intTeamSelected == 0)
			{
            if (theInfo == class'CP_MERC_FemaleOne')
            {
               CharacterButton2.SetBool("selected",true);
               CharacterButton2.SetBool("focused",true);
            }
            else if (theInfo == class'CP_MERC_MaleOne')
            {
               CharacterButton1.SetBool("selected",true);
               CharacterButton1.SetBool("focused",true);
            }
         }
         else if (CPHud(GetPC().myHUD).intTeamSelected == 1)
         {
            if (theInfo == class'CP_SWAT_FemaleOne')
            {
               CharacterButton2.SetBool("selected",true);
               CharacterButton2.SetBool("focused",true);
            }
            else if (theInfo == class'CP_Swat_MaleOne')
            {
               CharacterButton1.SetBool("selected",true);
               CharacterButton1.SetBool("focused",true);
            }
         }
         else
         {
            CharacterButton1.SetBool("selected",false);
            CharacterButton1.SetBool("focused",false);
            CharacterButton2.SetBool("selected",false);
            CharacterButton2.SetBool("focused",false);
         }

		}

	}
}


function OnEscapeKeyPress()
{
	MoveBackImpl();
	CPHud(GetPC().myHUD).ShowWelcomeMenu();
}

function Select_JoinGame_Button(GFxClikWidget.EventData ev)
{
    local CPPlayerController cppc;

	MoveBackImpl();

    cppc = CPPlayerController(GetPC());

    if (cppc.PlayerReplicationInfo.bOnlySpectator)
    {
        // When players return to game from spectate... Fired from CPPlayerController
        cppc.BecomeActive();
    }

    if (CPHud(cppc.myHUD).intTeamSelected == 1)
    {
        cppc.ChangeTeam("SF");
        cppc.ChangeSwatModel(CharacterSelected);
    }
    else
    {
        cppc.ChangeTeam("Merc");
        cppc.ChangeMercModel(CharacterSelected);
    }
	CPHud(GetPC().myHUD).bCrosshairShow = true;
	CPHud(GetPC().myHUD).CloseFrontend();
}

function Select_Random_Button(GFxClikWidget.EventData ev)
{
	MoveBackImpl();

	CharacterSelected = Rand(2);
	
	Select_JoinGame_Button(ev);
}

function Select_Back_Button(GFxClikWidget.EventData ev)
{
	MoveBackImpl();
	CPHud(GetPC().myHUD).ShowWelcomeMenu();
}

function Select_CharacterButton1(GFxClikWidget.EventData ev)
{
	if(CPHud(GetPC().myHUD).intTeamSelected == 1)
	{
		Character_Image.GotoAndStop("swatmale");
		CharacterSelected = 0;
	}
	else
	{
		Character_Image.GotoAndStop("mercmale");
		CharacterSelected = 0;
	}
	SetHighlightForSelectedCharacterButton();
}

function Select_CharacterButton2(GFxClikWidget.EventData ev)
{
	if(CPHud(GetPC().myHUD).intTeamSelected == 1)
	{
		Character_Image.GotoAndStop("swatfemale");
		CharacterSelected = 1;
	}
	else
	{
		Character_Image.GotoAndStop("mercfemale");
		CharacterSelected = 1;
	}
	SetHighlightForSelectedCharacterButton();
}

function Select_CharacterButton3(GFxClikWidget.EventData ev)
{
	//unused.
}

function Select_CharacterButton4(GFxClikWidget.EventData ev)
{
	//unused.
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled=false;

	switch(WidgetName)
	{
		case ('Character_Image'):
			Character_Image=Widget;
			bWasHandled=true; 
		break;	
		case ('SelectYourCharacter_Label'):
			SelectYourCharacter_Label=Widget;
			SelectYourCharacter_Label.SetString("text",SelectYourCharacter);
			bWasHandled=true; 
		break;	
		case ('JoinGame_Button'):
			JoinGame_Button=GFxClikWidget(Widget);
			JoinGame_Button.SetString("label",JoinGame_ButtonText);
			JoinGame_Button.AddEventListener('CLIK_press',Select_JoinGame_Button);
			bWasHandled=true; 
		break;
		case ('Random_Button'):
			Random_Button=GFxClikWidget(Widget);
			Random_Button.SetString("label",Random_ButtonText);
			Random_Button.AddEventListener('CLIK_press',Select_Random_Button);
			bWasHandled=true;
		break;
		case ('Back_Button'):
			Back_Button=GFxClikWidget(Widget);
			Back_Button.SetString("label",Back_ButtonText);
			Back_Button.AddEventListener('CLIK_press',Select_Back_Button);
			bWasHandled=true;
		break;
		case ('CharacterButton1'):
			CharacterButton1=GFxClikWidget(Widget);
			CharacterButton1.SetString("label","CharacterButton1");
			CharacterButton1.AddEventListener('CLIK_press',Select_CharacterButton1);
			CharacterButton1.SetBool("selected",true);
			CharacterButton1.setBool("focused",true);
			bWasHandled=true; 
		break;
		case ('CharacterButton2'):
			CharacterButton2=GFxClikWidget(Widget);
			CharacterButton2.SetString("label","CharacterButton2");
			CharacterButton2.AddEventListener('CLIK_press',Select_CharacterButton2);
			bWasHandled=true; 
		break;
		case ('CharacterButton3'):
			CharacterButton3=GFxClikWidget(Widget);
			CharacterButton3.SetString("label","CharacterButton3");
			CharacterButton3.AddEventListener('CLIK_press',Select_CharacterButton3);
			CharacterButton3.SetVisible(false);
			bWasHandled=true; 
		break;
		case ('CharacterButton4'):
			CharacterButton4=GFxClikWidget(Widget);
			CharacterButton4.SetString("label","CharacterButton4");
			CharacterButton4.AddEventListener('CLIK_press',Select_CharacterButton4);
			CharacterButton4.SetVisible(false);
			bWasHandled=true;
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
		`log( "CPI_FrontEnd_CharacterSelect::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}
	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}


DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="JoinGame_Button",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="Random_Button",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="Back_Button",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="CharacterButton1",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="CharacterButton2",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="CharacterButton3",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="CharacterButton4",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="Character_Image",WidgetClass=class'GFxObject'))			
}
