class CPI_FrontEnd_Welcome extends CPIFrontEnd_Screen 
    config(UI);

var GFxClikWidget SwatTeamButton, MercTeamButton, WSRandomButton, WSSpectatorButton, WSDisconnectButton;
var GFxObject WSTitle, MissionTypeLabel, MapNameLabel, WSMaxPlayers, WSLevelDesignerLabel, WSContributorsLabel, WSMissionBriefTitle, WSMissionBrief, WSChooseLabel,SwatPlayerCount,MercPlayerCount;
var GFxObject WSSeverName, WSServerNameResult, WSServerLocation, WSServerLocationResult, WSServerAdmin, WSServerAdminResult, WSServerDetails, WSServerScrollingList;

var localized string Title, MissionBriefing, SelectYourTeam, ServerName, ServerLocation, ServerAdmin, ServerDetails;
var localized string MercTeamButtonText, SwatTeamButtonText, RandomButtonText,SpectatorButtonText,DisconnectButtonText;
var string strServerName, strAdminEmail, strAdminName, strMOTD, strServerLocation, strRoundDurationInMinutes, strTimeLimit, strRoundStartDelay, strNumberOfBots, strFFPercentage, strFFEnabled, strGrenadeFF, strForcedTeams, strBehindViewEnabled, strSpectatorMode, strPasswordedServer;
var localized string LevelDesignerText,MinMaxPlayersText,ContributorsText;

var GFxObject WSImageLoader;
var bool blnImageFound;

function DisableSubComponents(bool bDisableComponents)
{
	if( !bDisableComponents)
		SetVisible(true);
	else
		SetVisible(false);

	super.DisableSubComponents(bDisableComponents);
}
function Tick()
{	
	local CPSaveManager CPSaveManager;
	local string mapImage;

	if(!blnImageFound)
	{
		mapImage = Localize("MapInfo","MapWelcomeScreenImage",GetPC().WorldInfo.GetMapName(true));

		if(Left(mapImage,5) == "?INT?")
		{
			`Log("int file not found falling back to default custom level image");
			WSImageLoader.SetString("source", "img://" $ "CPI_FrontEnd.CPI_Custom_Level_975x206");
		}
		else
		{
			WSImageLoader.SetString("source", "img://" $mapImage);
		}
		blnImageFound = true;
	}

	CPSaveManager = new () class'CPSaveManager';
	// If our welcome screen is open...
	if(bMovieShowing)
	{
		if(CPSaveManager != none)
		{
			// If spectator only mode is active
			if(bool(CPSaveManager.GetItem("Spectator")))
			{
				CPPlayerController(GetPC()).ServerSuicide();
				CPPlayerController(GetPC()).PlayerReplicationInfo.bOnlySpectator = true;
				CPPlayerController(GetPC()).ServerSetBOnlySpectator(true);
				CPPlayerController(GetPC()).PlayerReplicationInfo.bOutOfLives = true;
				CPPlayerController(GetPC()).PlayerReplicationInfo.bWaitingPlayer = false;
				CPPlayerController(GetPC()).ChangeTeam("Spectator");

				MoveBackImpl();
				CPHud(GetPC().myHUD).CloseFrontend();
			}
		}
	}
	
	SetPlayerCounts();
}

function SetPlayerCounts()
{
	local CPPlayerReplicationInfo PRI;
	local int redTeam, blueTeam, i;

	if (CPGameReplicationInfo(GetPC().WorldInfo.GRI)!=none)
	{
		for (i=0;i<CPGameReplicationInfo(GetPC().WorldInfo.GRI).PRIArray.Length;i++)
		{
			PRI=CPPlayerReplicationInfo(CPGameReplicationInfo(GetPC().WorldInfo.GRI).PRIArray[i]);
			if (PRI!=none && IsValidPlayer(PRI) && PRI.Team!=none)
			{
				if (PRI.Team.TeamIndex==0)
					redTeam++;
				else if (PRI.Team.TeamIndex==1)
					blueTeam++;
			}
		}
	}

	if(SwatPlayerCount != none)
	{
		if(SwatPlayerCount.GetString("text") != ("Players:"$blueTeam))
		{
			SwatPlayerCount.SetString("text","Players:"$blueTeam);
		}
	}

	if(MercPlayerCount != none)
	{
		if(MercPlayerCount.GetString("text") != ("Players:"$redTeam))
		{
			MercPlayerCount.SetString("text","Players:"$redTeam);
		}
	}
}

function bool IsValidPlayer(CPPlayerReplicationInfo PRI)
{
	if (!PRI.bIsInactive &&
		PRI.WorldInfo.NetMode!=NM_Client &&
		(PRI.Owner==none ||
		(PlayerController(PRI.Owner)!=none &&
		PlayerController(PRI.Owner).Player==none)))
	{
		return false;
	}
	return true;
}

function OnViewLoaded()
{
	CPPlayerController(GetPC()).WelcomeScreenGetServerInfo();
}

function Select_SwatTeamButton(GFxClikWidget.EventData ev)
{
    if(CPHud(GetPC().myHUD).TAGRI != none && CPHud(GetPC().myHUD).TAGRI.bTeamsAreForced)
	{  
		// Don't allow button selection if bForceTeams is on		
	}
	else
	{
		MoveBackImpl();
		CPHud(GetPC().myHUD).intTeamSelected = 1;
		CPHud(GetPC().myHUD).ShowCharacterSelectMenu(1);
	}
}

function Select_MercTeamButton(GFxClikWidget.EventData ev)
{
    if(CPHud(GetPC().myHUD).TAGRI != none && CPHud(GetPC().myHUD).TAGRI.bTeamsAreForced)
	{  
		// Don't allow button selection if bForceTeams is on		
	}
	else
	{
		MoveBackImpl();
		CPHud(GetPC().myHUD).intTeamSelected = 0;
		CPHud(GetPC().myHUD).ShowCharacterSelectMenu(0);
	}
}

function Select_WSRandomButton(GFxClikWidget.EventData ev)
{
	local int randTeam;
	MoveBackImpl();
	randTeam=CPHud(GetPC().myHUD).JoinTeamBalanced();
	CPHud(GetPC().myHUD).intTeamSelected=randTeam;
	CPHud(GetPC().myHUD).ShowCharacterSelectMenu(randTeam);
}

function Select_WSSpectatorButton(GFxClikWidget.EventData ev)
{
	CPPlayerController(GetPC()).ServerSuicide();
	CPPlayerController(GetPC()).PlayerReplicationInfo.bOnlySpectator = true;
	CPPlayerController(GetPC()).ServerSetBOnlySpectator(true);
	CPPlayerController(GetPC()).PlayerReplicationInfo.bOutOfLives = true;
	CPPlayerController(GetPC()).PlayerReplicationInfo.bWaitingPlayer = false;
	CPPlayerController(GetPC()).ChangeTeam("Spectator");

	MoveBackImpl();
	CPHud(GetPC().myHUD).CloseFrontend();
}

function Select_WSDisconnectButton(GFxClikWidget.EventData ev)
{
	MoveBackImpl();
	GetPC().ConsoleCommand("Disconnect");
}

function OnEscapeKeyPress()
{
	if(!CPHud(GetPC().myHUD).blnPlayerWelcomed)
	{
		MoveBackImpl();
		CPHud(GetPC().myHUD).CloseFrontend();
	}
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;
	
	bWasHandled=false;

	switch(WidgetName)
	{
		case ('WSTitle'):
			WSTitle=Widget;
			WSTitle.SetString("text",Title);
			bWasHandled=true; 
		break;	
		case ('MissionTypeLabel'):
			MissionTypeLabel=Widget;
			MissionTypeLabel.SetString("text","MissionTypeLabel");
			bWasHandled=true; 
		break;	
		case ('MapNameLabel'):
			MapNameLabel=Widget;
			MapNameLabel.SetString("text",GetPC().GetURLMap());
			bWasHandled=true; 
		break;	
		case ('WSMaxPlayers'):
			WSMaxPlayers=Widget;
			WSMaxPlayers.SetString("text",MinMaxPlayersText@Localize("MapInfo","MaxPlayers",GetPC().GetURLMap()));
			bWasHandled=true; 
		break;	
		case ('WSLevelDesignerLabel'):
			WSLevelDesignerLabel=Widget;
			WSLevelDesignerLabel.SetString("text",LevelDesignerText@Localize("MapInfo","LevelDesigner",GetPC().GetURLMap()));
			bWasHandled=true; 
		break;	
		case ('WSContributorsLabel'):
			WSContributorsLabel=Widget;
			WSContributorsLabel.SetString("text",ContributorsText@Localize("MapInfo","Contributors",GetPC().GetURLMap()));
			bWasHandled=true; 
		break;	
		case ('WSMissionBriefTitle'):
			WSMissionBriefTitle=Widget;
			WSMissionBriefTitle.SetString("text",MissionBriefing);
			bWasHandled=true; 
		break;	
		case ('WSMissionBrief'):
			WSMissionBrief=Widget;
			WSMissionBrief.SetString("text",Localize("MapInfo","MapObjective",GetPC().GetURLMap()));
			bWasHandled=true; 
		break;	
		case ('WSChooseLabel'):
			WSChooseLabel=Widget;
			WSChooseLabel.SetString("text",SelectYourTeam);
			bWasHandled=true; 
		break;	

		case ('WSSeverName'):
			WSSeverName=Widget;
			WSSeverName.SetString("text",ServerName);
			bWasHandled=true; 
		break;	
		case ('WSServerNameResult'):
			WSServerNameResult=Widget;
			WSServerNameResult.SetString("text",strServerName);
			bWasHandled=true; 
		break;	
		case ('WSServerLocation'):
			WSServerLocation=Widget;
			WSServerLocation.SetString("text",ServerLocation);
			bWasHandled=true; 
		break;	
		case ('WSServerLocationResult'):
			WSServerLocationResult=Widget;
			WSServerLocationResult.SetString("text",strServerLocation);
			bWasHandled=true; 
		break;	
		case ('WSServerAdmin'):
			WSServerAdmin=Widget;
			WSServerAdmin.SetString("text",ServerAdmin);
			bWasHandled=true; 
		break;	
		case ('WSServerAdminResult'):
			WSServerAdminResult=Widget;
			WSServerAdminResult.SetString("text",strAdminName);
			bWasHandled=true; 
		break;	
		case ('SwatPlayerCount'):
			SwatPlayerCount=Widget;
			SwatPlayerCount.SetString("text","SwatPlayerCount");
			bWasHandled=true; 
		break;	
		case ('MercPlayerCount'):
			MercPlayerCount=Widget;
			MercPlayerCount.SetString("text","MercPlayerCount");
			bWasHandled=true; 
		break;	
		case ('WSServerDetails'):
			WSServerDetails=Widget;
			WSServerDetails.SetString("text",ServerDetails);
			bWasHandled=true; 
		break;	
		case ('ServerScrollingList1'):
			WSServerScrollingList=Widget;
			PopulateServerRules();
			bWasHandled=true; 
		break;
		case ('MercTeamButton'):
			MercTeamButton=GFxClikWidget(Widget);
			MercTeamButton.SetString("label",MercTeamButtonText);
			MercTeamButton.AddEventListener('CLIK_press',Select_MercTeamButton);
			bWasHandled=true;
			
			//if(CPPC != None && CPPC.GetTeamNum() == TTI_Mercenaries && CPPC.Pawn != None)
			//	MercTeamButton.SetBool("enabled", false);
		break;	
		case ('SwatTeamButton'):
			SwatTeamButton=GFxClikWidget(Widget);
			SwatTeamButton.SetString("label",SwatTeamButtonText);
			SwatTeamButton.AddEventListener('CLIK_press',Select_SwatTeamButton);
			bWasHandled=true; 
			
			//if(CPPC != None && CPPC.GetTeamNum() == TTI_SpecialForces && CPPC.Pawn != None)
			//	SwatTeamButton.SetBool("enabled", false);
		break;	
		case ('WSRandomButton'):
			WSRandomButton=GFxClikWidget(Widget);
			WSRandomButton.SetString("label",RandomButtonText);
			WSRandomButton.AddEventListener('CLIK_press',Select_WSRandomButton);
			bWasHandled=true; 
		break;	
		case ('WSSpectatorButton'):
			WSSpectatorButton=GFxClikWidget(Widget);
			WSSpectatorButton.SetString("label",SpectatorButtonText);
			WSSpectatorButton.AddEventListener('CLIK_press',Select_WSSpectatorButton);
			bWasHandled=true; 
		break;	
		case ('WSDisconnectButton'):
			WSDisconnectButton=GFxClikWidget(Widget);
			WSDisconnectButton.SetString("label",DisconnectButtonText);
			WSDisconnectButton.AddEventListener('CLIK_press',Select_WSDisconnectButton);
			bWasHandled=true; 
		break;		
		case ('WSMapImage'):
			WSImageLoader=Widget;
			bWasHandled=true; 
			break;
		case('renderer0'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('renderer1'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('renderer2'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('renderer3'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('renderer4'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('renderer5'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('Track'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('downArrow'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('upArrow'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('Thumb'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		case('WSScroller'):
			//these are handled as part of the WelcomeList
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
		`log( "CPI_FrontEnd_Welcome::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}

	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

function PopulateWelcomeScreenServerInfo(string sServerName,string AdminEmail,string AdminName,string MOTD,string sServerLocation, string RoundDurationInMinutes, string TimeLimit, string RoundStartDelay, string NumberOfBots, string FFPercentage, string FFEnabled, string GrenadeFF, string ForcedTeams, string BehindViewEnabled, string SpectatorMode, string PasswordedServer)
{
	//`Log("Matt do we need admin email on this menu? its" @ AdminEmail @ "by the way ;)");
	//`Log("Matt do we need MOTD on this menu? its" @ MOTD @ "by the way ;)");
	strServerName=sServerName;
	strAdminEmail=AdminEmail;
	strAdminName=AdminName;
	strMOTD=MOTD;
	strServerLocation=sServerLocation;	
	strRoundDurationInMinutes = RoundDurationInMinutes;
	strTimeLimit = TimeLimit;
	strRoundStartDelay = RoundStartDelay;
	strNumberOfBots = NumberOfBots;
	strFFPercentage = FFPercentage;
	strFFEnabled = FFEnabled;
	strGrenadeFF = GrenadeFF;
	strForcedTeams = ForcedTeams;
	strBehindViewEnabled = BehindViewEnabled;

    switch(SpectatorMode)
    {
        case "SpectateView_All":
            strSpectatorMode = "All";
            break;
        case "SpectateView_TeamOnly":
			strSpectatorMode = "Team Only";
            break;
        case "SpectateView_None":
			strSpectatorMode = "None";
            break;
        default:
    }

	strPasswordedServer = PasswordedServer;

	PopulateServerRules();

	if(WSServerNameResult != none)
		WSServerNameResult.SetString("text",strServerName);
	
	if(WSServerLocationResult != none)
		WSServerLocationResult.SetString("text",strServerLocation);
	
	if(WSServerAdminResult != none)
		WSServerAdminResult.SetString("text",strAdminName);
		

}

function PopulateServerRules()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;

	DataProvider=CreateArray();  

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Round Time Duration");  
	TempObj.SetString("lbl2", strRoundDurationInMinutes $ " Minutes");
	DataProvider.SetElementObject(0, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "TimeLimit");  
	TempObj.SetString("lbl2", strTimeLimit $ " Minutes");
	DataProvider.SetElementObject(1, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Round start delay");  
	TempObj.SetString("lbl2", strRoundStartDelay $ " Seconds");
	DataProvider.SetElementObject(2, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Number of bots");  
	TempObj.SetString("lbl2", strNumberOfBots);
	DataProvider.SetElementObject(3, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Friendly Fire %");  
	TempObj.SetString("lbl2", strFFPercentage $ "%");
	DataProvider.SetElementObject(4, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Friendly Fire Enabled");  
	TempObj.SetString("lbl2", strFFEnabled);
	DataProvider.SetElementObject(5, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Grenade Friendly Fire Enabled");  
	TempObj.SetString("lbl2", strGrenadeFF);
	DataProvider.SetElementObject(6, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Forced Teams");  
	TempObj.SetString("lbl2", strForcedTeams);
	DataProvider.SetElementObject(7, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Behind View Enabled");  
	TempObj.SetString("lbl2", strBehindViewEnabled);
	DataProvider.SetElementObject(8, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Spectator Mode");  
	TempObj.SetString("lbl2", strSpectatorMode);
	DataProvider.SetElementObject(9, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("lbl1", "Game Passworded");  
	TempObj.SetString("lbl2", strPasswordedServer);
	DataProvider.SetElementObject(10, TempObj);

	if(WSServerScrollingList != none)
		WSServerScrollingList.SetObject("dataProvider",DataProvider); 
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="SwatTeamButton",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="MercTeamButton",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="WSRandomButton",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="WSSpectatorButton",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="WSDisconnectButton",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="WSServerNameResult",WidgetClass=class'GFxObject'))		
	SubWidgetBindings.Add((WidgetName="WSServerScrollingList",WidgetClass=class'GFxObject'))	
	SubWidgetBindings.Add((WidgetName="WSMapImage",WidgetClass=class'GFxObject'))		
}
