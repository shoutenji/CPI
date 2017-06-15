class CPI_FrontEnd_PrivateGame extends CPIFrontEnd_Screen
    config(UI);

var GFxClikWidget PlayButton, BackButton,MapList, scrollbar;
var GFxClikWidget FriendlyFire_OptStepper, GrenadeFriendlyFire_OptStepper, FriendlyFireScale_NumStepper, ForceTeams_OptStepper, BehindViewMode_OptStepper, SpectatorMode_OptStepper;
var GFxClikWidget RoundDuration_NumStepper, NumberOfBots_NumStepper, MapDuration_NumStepper, PreRoundTime_NumStepper;

var GFxObject AdminPassword_TextInput, GamePassword_TextInput;

var GFxObject WindowTitle, MapTitle, ObjectiveLabel, NumberOfBots_Label, FriendlyFire_Label, GrenadeFriendlyFire_Label, MapDuration_Label, ForceTeams_Label, FriendlyFireScale_Label, BehindViewMode_Label;
var GFxObject PreRoundTime_Label, SpectatorMode_Label, GamePassword_Label, AdminPassword_Label, MaxPlayersLabel, RoundDuration_Label, ObjectiveDescriptionLabel;

var localized string strWindowTitle, strWindowTitleLan, strObjectiveLabel, strNumberOfBots_Label, strFriendlyFire_Label, strGrenadeFriendlyFire_Label, strMapDuration_Label, strForceTeams_Label, strFriendlyFireScale_Label, strBehindViewMode_Label;
var localized string strPreRoundTime_Label, strSpectatorMode_Label, strGamePassword_Label, strAdminPassword_Label, strMaxPlayersLabel, strRoundDuration_Label;
var localized string strOnValue, strOffValue, strSpectatorAll, strSpectatorTeamOnly, strSpectatorNone;
var localized string strPlayButton, strBackButton;
var string strSelectedMap;
var bool blnPrivateServer;

var GFxObject PGImageLoader;

function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
	super.OnTopMostView(bPlayOpenAnimation);
	SetupDefaultValues();
}

function SetupDefaultValues()
{
	MapList.SetFloat("selectedIndex",0); 

	if(blnPrivateServer)
	{
		WindowTitle.SetString("text",strWindowTitleLan);
		PlayButton.SetString("label","<CREATE GAME>");

		if(GamePassword_Label != none)
			GamePassword_Label.SetVisible(true);
		
		if(AdminPassword_Label != none)	
			AdminPassword_Label.SetVisible(true);

		AdminPassword_TextInput.SetVisible(true);
		GamePassword_TextInput.SetVisible(true);
	}
	else
	{
		WindowTitle.SetString("text",strWindowTitle);

		if(GamePassword_Label != none)
			GamePassword_Label.SetVisible(false);
		if(AdminPassword_Label != none)			
			AdminPassword_Label.SetVisible(false);

		AdminPassword_TextInput.SetVisible(false);
		GamePassword_TextInput.SetVisible(false);
	}
	RoundDuration_NumStepper.SetInt("maximum", 5);
	RoundDuration_NumStepper.SetInt("value",CPGameReplicationInfo(GetPC().WorldInfo.GRI).RoundDurationInMinutes);

	MapDuration_NumStepper.SetInt("maximum", 999);
	MapDuration_NumStepper.SetInt("value",CPGameReplicationInfo(GetPC().WorldInfo.GRI).TimeLimit);

	PreRoundTime_NumStepper.SetInt("maximum", 5);
	PreRoundTime_NumStepper.SetInt("value",CPGameReplicationInfo(GetPC().WorldInfo.GRI).RoundStartDelay);

	NumberOfBots_NumStepper.SetInt("maximum", 16);
	NumberOfBots_NumStepper.SetInt("value",CPGameReplicationInfo(GetPC().WorldInfo.GRI).MinimumPlayers);

	FriendlyFire_OptStepper.SetString("value",String(CPGameReplicationInfo(GetPC().WorldInfo.GRI).bIsFFenabled));
	GrenadeFriendlyFire_OptStepper.SetString("value",String(CPGameReplicationInfo(GetPC().WorldInfo.GRI).bNadeFFenabled));
	ForceTeams_OptStepper.SetString("value",String(CPGameReplicationInfo(GetPC().WorldInfo.GRI).bTeamsAreForced));
	BehindViewMode_OptStepper.SetString("value",String(CPGameReplicationInfo(GetPC().WorldInfo.GRI).bAllowBehindView));

	switch(CPGameReplicationInfo(GetPC().WorldInfo.GRI).Spectating)
	{
	case SpectateView_All:
		SpectatorMode_OptStepper.SetFloat("selectedIndex",0);
		//SpectatorMode_OptStepper.SetString("value",strSpectatorAll);
		break;
	case SpectateView_TeamOnly:
		SpectatorMode_OptStepper.SetFloat("selectedIndex",1);
		//SpectatorMode_OptStepper.SetString("value",strSpectatorTeamOnly);
		break;
	case SpectateView_None:
		SpectatorMode_OptStepper.SetFloat("selectedIndex",2);
		//SpectatorMode_OptStepper.SetString("value",strSpectatorNone);
		break;
	default:
		break;
	}	

	FriendlyFireScale_NumStepper.SetFloat("maximum", 100.0f);
	FriendlyFireScale_NumStepper.SetFloat("value",CPGameReplicationInfo(GetPC().WorldInfo.GRI).FFPercentage);
}

function PopulateMapInfo()
{
	local string MaxPlayers,MapObjecitve;
	local string mapImage;
	MapTitle.SetString("text",strSelectedMap);
	MaxPlayers = Localize("MapInfo","MaxPlayers",strSelectedMap);
	MapObjecitve = Localize("MapInfo","MapObjective",strSelectedMap);

	MaxPlayersLabel.SetString("text", MaxPlayers @ strMaxPlayersLabel);
	ObjectiveDescriptionLabel.SetString("text", MapObjecitve);

	mapImage = Localize("MapInfo","MapPrivateGameScreenImage",strSelectedMap);

	if(Left(mapImage,5) == "?INT?")
	{
		`Log("default mapImage needed");
		PGImageLoader.SetString("source", "img://" $ "CPI_FrontEnd.CPI_Custom_Level_1196x293");
	}
	else
	{
		`Log("mapImage =" @ mapImage);
		PGImageLoader.SetString("source", "img://" $mapImage); 
	}
}

function StartPrivateServer()
{
	//if(MenuManager.SPI.playername != "")
	//{
		//GetPC().ConsoleCommand("open"@strSelectedMap$BuildSelectedOptionsParamList()$"?game=criticalpoint.criticalpointgame" $ "?ServerName=" $ MenuManager.SPI.playername $ "'s CPI Server" $ "?listen?steamsockets");	
		GetPC().ConsoleCommand("open"@strSelectedMap$BuildSelectedOptionsParamList()$"?game=criticalpoint.criticalpointgame" $ "?ServerName=" $ GetPC().PlayerReplicationInfo.PlayerName $ "'s CPI Server" $ "?listen?steamsockets");	
	//}
	//else
	//{
	//	`Log("server not started - you are not logged in.");
	//}
}

function OpenMap()
{
	CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ConsoleCommand("open"@strSelectedMap$BuildSelectedOptionsParamList());
}

function string BuildSelectedOptionsParamList()
{
	local string options;

	options $= "?" $ "RoundDurationInMinutes=" $ RoundDuration_NumStepper.GetInt("value");
	options $= "?" $ "TimeLimit=" $ MapDuration_NumStepper.GetInt("value");
	options $= "?" $ "RoundStartDelay=" $ PreRoundTime_NumStepper.GetInt("value");
	options $= "?" $ "NumBots=" $ NumberOfBots_NumStepper.GetInt("value");
	options $= "?" $ "FFPercentage=" $ FriendlyFireScale_NumStepper.GetInt("value");
	options $= "?" $ "bIsFFenabled=" $ FriendlyFire_OptStepper.GetString("value");
	options $= "?" $ "bNadeFFenabled=" $ GrenadeFriendlyFire_OptStepper.GetString("value");
	options $= "?" $ "bTeamsAreForced=" $ ForceTeams_OptStepper.GetString("value");
	options $= "?" $ "bBehindViewAllowed=" $ BehindViewMode_OptStepper.GetString("value");

	`Log(SpectatorMode_OptStepper.GetString("selectedIndex"));
	switch(SpectatorMode_OptStepper.GetString("selectedIndex"))
	{
	case "0":
		`Log("Selected ALL");
		options $= "?" $ "SpectatorMode=ALL";
		break;
	case "1":
		`Log("Selected TEAM");
		options $= "?" $ "SpectatorMode=TEAM";
		break;
	case "2":
		`Log("Selected NONE");
		options $= "?" $ "SpectatorMode=NONE";
		break;
	}

	
	options $= "?" $ "GamePassword=" $ GamePassword_TextInput.GetString("text");
	options $= "?" $ "AdminPassword=" $ AdminPassword_TextInput.GetString("text");

	//class'Engine'.static.BasicLoadObject(MenuManager.SPI, "steam_api.bin", false, 1);

	//options $= "?" $ "hash=" $ MenuManager.SPI.hash;

	return options;
}
function Select_BackButton(GFxClikWidget.EventData ev)
{
	MoveBackImpl();
}

function Select_PlayButton(GFxClikWidget.EventData ev)
{
	if(blnPrivateServer)
	{
		StartPrivateServer();
	}
	else
	{
		OpenMap();
	}
}

function Select_MapList_ChangeMap(GFxClikWidget.EventData ev)
{
	strSelectedMap = "CP-" $ ev.target.GetObject("dataProvider").GetElementObject(Int(ev.target.GetFloat("selectedIndex"))).GetString("label"); 
	PopulateMapInfo();
}

function PopulateMapsList()
{
	local int i,ListCounter;
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local array<UDKUIResourceDataProvider> ProviderList; 
	local array<CPUIDataProvider_MapInfo> LocalMapList;

    LocalMapList.Length=0;
	class'CPUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'CPUIDataProvider_MapInfo',ProviderList);
	for (i=0;i<ProviderList.length;i++)
		LocalMapList.AddItem(CPUIDataProvider_MapInfo(ProviderList[i]));
    if (LocalMapList.Length==0)
		return;
    ListCounter=0;
    DataProvider=CreateArray();              

    for (i=0;i<LocalMapList.Length;i++)
    {
		if(LEFT(LocalMapList[i].MapName,3)!="CP-")
			continue;
        if (!LocalMapList[i].ShouldBeFiltered())
        {
            TempObj=CreateObject("Object");
            TempObj.SetString("label", Repl(LocalMapList[i].MapName,"CP-","",false));                           
            DataProvider.SetElementObject(ListCounter++, TempObj);
        }
    }

	if(ListCounter >= 11)
	{
		MapList.SetInt("rowCount",11);
	}
	else
	{
		MapList.SetInt("rowCount",ListCounter);
	}

    MapList.SetObject("dataProvider",DataProvider); 
}

function Populate_FriendlyFire_OptStepper()
{
	FriendlyFire_OptStepper.SetObject("dataProvider",SetupOnOffSteppers());   
}

function Populate_GrenadeFriendlyFire_OptStepper()
{
	GrenadeFriendlyFire_OptStepper.SetObject("dataProvider",SetupOnOffSteppers());   
}

function Populate_ForceTeams_OptStepper()
{
	ForceTeams_OptStepper.SetObject("dataProvider",SetupOnOffSteppers());   
}

function Populate_BehindViewMode_OptStepper()
{
	BehindViewMode_OptStepper.SetObject("dataProvider",SetupOnOffSteppers());   
}

function GFxObject SetupOnOffSteppers()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
				
	DataProvider=CreateArray();

	TempObj=CreateObject("Object");  
	TempObj.SetString("label",strOnValue); 
	DataProvider.SetElementObject(1,TempObj);

	TempObj=CreateObject("Object");  
	TempObj.SetString("label",strOffValue); 
	DataProvider.SetElementObject(0,TempObj);

	return DataProvider;
}

function Populate_SpectatorMode_OptStepper()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
				
	DataProvider=CreateArray();

	TempObj=CreateObject("Object");  
	TempObj.SetString("label",strSpectatorAll); 
	DataProvider.SetElementObject(0,TempObj);

	TempObj=CreateObject("Object");  
	TempObj.SetString("label",strSpectatorTeamOnly); 
	DataProvider.SetElementObject(1,TempObj);
	
	TempObj=CreateObject("Object");  
	TempObj.SetString("label",strSpectatorNone); 
	DataProvider.SetElementObject(2,TempObj);
	SpectatorMode_OptStepper.SetObject("dataProvider",DataProvider);   
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled=false;

	switch(WidgetName)
	{		
		case ('PlayButton'):
			PlayButton=GFxClikWidget(Widget);
			PlayButton.SetString("label",strPlayButton);
			PlayButton.AddEventListener('CLIK_press',Select_PlayButton);
			bWasHandled=true; 
		break;
		case ('BackButton'):
			BackButton=GFxClikWidget(Widget);
			BackButton.SetString("label",strBackButton);
			BackButton.AddEventListener('CLIK_press',Select_BackButton);
			bWasHandled=true; 
		break;
		case ('PrivateGameScroller'):
			scrollbar=GFxClikWidget(Widget);
			if(MapList.GetInt("rowCount") >= 11)
			{
				scrollbar.SetVisible(true);
			}
			else
			{
				scrollbar.SetVisible(false);
			}
			bWasHandled=true; 
		break;
		case ('MapList'):
			MapList=GFxClikWidget(Widget);
			PopulateMapsList();
			MapList.AddEventListener('CLIK_change',Select_MapList_ChangeMap);
			bWasHandled=true; 
		break;
		case ('AdminPassword_TextInput'):
			AdminPassword_TextInput=Widget;
			bWasHandled=true; 
		break;
		case ('GamePassword_TextInput'):
			GamePassword_TextInput=Widget;
			bWasHandled=true; 
		break;
		//NUM STEPPERS
		case ('RoundDuration_NumStepper'):
			RoundDuration_NumStepper=GFxClikWidget(Widget);
			bWasHandled=true; 
		break;
		case ('NumberOfBots_NumStepper'):
			NumberOfBots_NumStepper=GFxClikWidget(Widget);
			bWasHandled=true; 
		break;
		case ('MapDuration_NumStepper'):
			MapDuration_NumStepper=GFxClikWidget(Widget);
			bWasHandled=true; 
		break;
		case ('PreRoundTime_NumStepper'):
			PreRoundTime_NumStepper=GFxClikWidget(Widget);
			bWasHandled=true; 
		break;
		//OPTION STEPPERS
		case ('FriendlyFire_OptStepper'):
			FriendlyFire_OptStepper=GFxClikWidget(Widget);
			Populate_FriendlyFire_OptStepper();
			FriendlyFire_OptStepper.AddEventListener('CLIK_change',Boolean_OptStepper_Change);
			bWasHandled=true; 
		break;
		case ('GrenadeFriendlyFire_OptStepper'):
			GrenadeFriendlyFire_OptStepper=GFxClikWidget(Widget);
			Populate_GrenadeFriendlyFire_OptStepper();
			GrenadeFriendlyFire_OptStepper.AddEventListener('CLIK_change',Boolean_OptStepper_Change);
			bWasHandled=true; 
		break;
		case ('FriendlyFireScale_NumStepper'):
			FriendlyFireScale_NumStepper=GFxClikWidget(Widget);
			bWasHandled=true; 
		break;
		case ('ForceTeams_OptStepper'):
			ForceTeams_OptStepper=GFxClikWidget(Widget);
			Populate_ForceTeams_OptStepper();
			ForceTeams_OptStepper.AddEventListener('CLIK_change',Boolean_OptStepper_Change);
			bWasHandled=true; 
		break;
		case ('BehindViewMode_OptStepper'):
			BehindViewMode_OptStepper=GFxClikWidget(Widget);
			Populate_BehindViewMode_OptStepper();
			BehindViewMode_OptStepper.AddEventListener('CLIK_change',Boolean_OptStepper_Change);
			bWasHandled=true; 
		break;
		case ('SpectatorMode_OptStepper'):
			SpectatorMode_OptStepper=GFxClikWidget(Widget);
			Populate_SpectatorMode_OptStepper();
			bWasHandled=true; 
		break;
		case('nextBtn'):
			//these are handled as part of the respective steppers
			bWasHandled=true; 
		break;
		case('prevBtn'):
			//these are handled as part of the respective steppers
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
		//LABELS
		case ('WindowTitle'):
			WindowTitle=Widget;
			bWasHandled=true; 
		break;
		case ('MapTitle'):
			MapTitle=Widget;
			bWasHandled=true; 
		break;
		case ('ObjectiveLabel'):
			ObjectiveLabel=Widget;
			ObjectiveLabel.SetString("text", strObjectiveLabel);
			bWasHandled=true; 
		break;
		case ('NumberOfBots_Label'):
			NumberOfBots_Label=Widget;
			NumberOfBots_Label.SetString("text", strNumberOfBots_Label);
			bWasHandled=true; 
		break;
		case ('FriendlyFire_Label'):
			FriendlyFire_Label=Widget;
			FriendlyFire_Label.SetString("text", strFriendlyFire_Label);
			bWasHandled=true; 
		break;
		case ('GrenadeFriendlyFire_Label'):
			GrenadeFriendlyFire_Label=Widget;
			GrenadeFriendlyFire_Label.SetString("text", strGrenadeFriendlyFire_Label);
			bWasHandled=true; 
		break;
		case ('MapDuration_Label'):
			MapDuration_Label=Widget;
			MapDuration_Label.SetString("text", strMapDuration_Label);
			bWasHandled=true; 
		break;
		case ('ForceTeams_Label'):
			ForceTeams_Label=Widget;
			ForceTeams_Label.SetString("text", strForceTeams_Label);
			bWasHandled=true; 
		break;
		case ('FriendlyFireScale_Label'):
			FriendlyFireScale_Label=Widget;
			FriendlyFireScale_Label.SetString("text", strFriendlyFireScale_Label);
			bWasHandled=true; 
		break;
		case ('BehindViewMode_Label'):
			BehindViewMode_Label=Widget;
			BehindViewMode_Label.SetString("text", strBehindViewMode_Label);
			bWasHandled=true; 
		break;
		case ('PreRoundTime_Label'):
			PreRoundTime_Label=Widget;
			PreRoundTime_Label.SetString("text", strPreRoundTime_Label);
			bWasHandled=true; 
		break;
		case ('SpectatorMode_Label'):
			SpectatorMode_Label=Widget;
			SpectatorMode_Label.SetString("text", strSpectatorMode_Label);
			bWasHandled=true; 
		break;
		case ('GamePassword_Label'):
			GamePassword_Label=Widget;
			GamePassword_Label.SetString("text", strGamePassword_Label);
			bWasHandled=true; 
		break;
		case ('AdminPassword_Label'):
			AdminPassword_Label=Widget;
			AdminPassword_Label.SetString("text", strAdminPassword_Label);
			bWasHandled=true; 
		break;
		case ('MaxPlayersLabel'):
			MaxPlayersLabel=Widget;
			MaxPlayersLabel.SetString("text", strMaxPlayersLabel);
			bWasHandled=true; 
		break;
		case ('RoundDuration_Label'):
			RoundDuration_Label=Widget;
			RoundDuration_Label.SetString("text", strRoundDuration_Label);
			bWasHandled=true; 
		break;		
		case ('ObjectiveDescriptionLabel'):
			ObjectiveDescriptionLabel=Widget;
			bWasHandled=true; 
		break;		
		case ('PGMapImage'):
			PGImageLoader=Widget;
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
		`log( "CPI_FrontEnd_PrivateGame::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}

	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

function Boolean_OptStepper_Change(GFxClikWidget.EventData ev)
{
	SetControlTrueFalseValue(ev);
}

function SetControlTrueFalseValue(GFxClikWidget.EventData theControl)
{
	if(theControl.target.GetInt("selectedIndex") == 0)
	{
		theControl.target.SetString("value","False");
	}
	else
	{
		theControl.target.SetString("value","True");
	}
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="PlayButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BackButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PrivateGameScroller",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="MapList",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="RoundDuration_NumStepper",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="NumberOfBots_NumStepper",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MapDuration_NumStepper",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PreRoundTime_NumStepper",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="FriendlyFire_OptStepper",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="GrenadeFriendlyFire_OptStepper",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="FriendlyFireScale_NumStepper",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="ForceTeams_OptStepper",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="BehindViewMode_OptStepper",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="SpectatorMode_OptStepper",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="PGMapImage",WidgetClass=class'GFxObject'))	
	blnPrivateServer=false;
}
