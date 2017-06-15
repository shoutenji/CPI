class CPI_FrontEnd_MultiplayerMenu extends CPIFrontEnd_Screen 
    config(UI);

var GFxClikWidget MultiplayerTitle;
var GFxClikWidget MPJoinGameBtn, MPRefreshBtn,MPBacBtn,Header1,Header2,Header3,Header4, ServerHeader1, ServerHeader2, FriendsDataHeader1, FriendsDataHeader2, FriendsDataHeader3, FriendsDataHeader4, FriendsDataHeader5;

var GFxClikWidget MPDatalist,MPServerDetailsList,MPFriendsDetailsList;

var OnlineSubsystem OnlineSub;
var OnlineGameInterface GameInterface;
var CPIGameSettings currentGameSettings;

var CPIOnlineSearchSettings SearchSetting;
var array<OnlineGameSearchResult> searchResults;

var bool bSearching; //used so we dont cancel if we are already searching... might not have finished the search?
var bool blnConsoleShowing;

var GFxObject MPImageLoader;
var bool blnImageFound;
var string strSelectedMapName;

function Tick()
{
	if(!CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).blnConsoleShowing)
		return;

	if(blnConsoleShowing != CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).blnConsoleShowing)
	{
		blnConsoleShowing = true;
		`Log("shutdown!");
		//shut it all down.
		setRefreshTimer(0);
		ClearOnlineGamesDelegate();
		//OnlineSub = none;
		//GameInterface = none;

	}
	else
	{
		setRefreshTimer(5);
	}
}

function RefreshTimer()
{
	`Log("Tick ");
	PopulateServerPlayerInfo(Int(MPDatalist.GetFloat("selectedIndex")));
}

function DisableSubComponents(bool bDisableComponents)
{
	if( !bDisableComponents)
		SetVisible(true);
	else
		SetVisible(false);

	InitOnlineSubSystem();

	if(!bDisableComponents)
	{
		SearchOnlineGames();
		setRefreshTimer(5);
	}
	else
	{
		setRefreshTimer(0);
	}

	super.DisableSubComponents(bDisableComponents);
}

function setRefreshTimer(float refreshvalue)
{
		GetPC().SetTimer(refreshvalue,false,nameof(RefreshTimer),self);
}

function Select_JoinGameButton(GFxClikWidget.EventData ev)
{
	local GFxObject TempObj;

	CancelSearchOnlineGames();
	TempObj = MPDatalist.GetObject("dataProvider",class'GFxClikWidget');
	JoinGame(TempObj.GetElementObject(Int(MPDatalist.GetFloat("selectedIndex"))).GetString("field5"));
}

function JoinGame(string steamip)
{
	local LocalPlayer LP;

	ClearOnlineGamesDelegate();

	`Log("JoinGame - selected steam server uid " @ steamip);
	LP=GetLP();
	if ((LP!=none ) && (LP.ViewportClient.ViewportConsole!=none))
	{
		//CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ConsoleCommand("open steam." $ steamip $ "?" $ "hash=" $ MenuManager.SPI.hash);
		CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ConsoleCommand("open steam." $ steamip);
	}
}

function ClearOnlineGamesDelegate()
{
	GameInterface.ClearFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
}
function Select_RefreshButton(GFxClikWidget.EventData ev)
{
	`Log("Select_RefreshButton");
	SearchOnlineGames();
}

function Select_BackButton(GFxClikWidget.EventData ev)
{
	CancelSearchOnlineGames();
	MoveBackImpl();
}

function Select_MPDatalist_Selected(GFxClikWidget.EventData ev)
{
	`Log("Select_MPDatalist_Selected - index " @ Int(ev.target.GetFloat("selectedIndex")));
	PopulateServerPlayerInfo(Int(ev.target.GetFloat("selectedIndex")));
	PopulateServerRules(Int(ev.target.GetFloat("selectedIndex")));

	SetMapImage(Int(ev.target.GetFloat("selectedIndex")));
}

function SetMapImage(int index)
{
	local string mapImage;

	if(MPDataList == none)
		return;

	strSelectedMapName = "CP-" $ MPDatalist.GetObject("dataProvider").GetElementObject(index).GetString("field3");

	`Log("selected map name is " @strSelectedMapName);

	if(strSelectedMapName == "CP-")
	{
		MPImageLoader.SetVisible(false);
	}
	else
	{
		MPImageLoader.SetVisible(true);
	}

	mapImage = Localize("MapInfo","MapMultiplayerScreenImage",strSelectedMapName);


	if(Left(mapImage,5) == "?INT?")
	{
		`Log("default mapImage needed");
		MPImageLoader.SetString("source", "img://" $ "CPI_FrontEnd.CPI_Custom_Level_333x196");
	}
	else
	{
		`Log("mapImage =" @ mapImage);
		MPImageLoader.SetString("source", "img://" $mapImage);
	}
}

/*
 * Convert the server property from a simple 0 or 1 to a No or Yes value
*/
function string ConvertServerSettings(string Setting)
{
	switch(Setting)
	{
		case "0":
			return "No";
			break;
		case "1":
			return "Yes";
			break;

		default:
			break;
	}
	return "No";
}


/*
*/
function PopulateServerRules(int selectedindex)
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local CPIGameSettings gs;

	if(SearchSetting == none)
		return;

	if(SearchSetting.Results.Length == 0)
		return;

	if(SearchSetting.Results.Length < selectedindex + 1)
		return;

	gs = CPIGameSettings(SearchSetting.Results[selectedindex].GameSettings);

	if(gs == none)
		return;

	DataProvider=CreateArray();  

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Round Time Duration");  
	TempObj.SetString("field2", gs.getRoundDurationInMinutes() $ " Minutes");
	DataProvider.SetElementObject(0, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "TimeLimit");  
	TempObj.SetString("field2", gs.getTimeLimit() $ " Minutes");
	DataProvider.SetElementObject(1, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Round start delay");  
	TempObj.SetString("field2", gs.getRoundStartDelayTime() $ " Seconds");
	DataProvider.SetElementObject(2, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Number of bots");  
	TempObj.SetString("field2", gs.getNumberOfBots());
	DataProvider.SetElementObject(3, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Friendly Fire %");  
	TempObj.SetString("field2", gs.getFFPercentage() $ "%");
	DataProvider.SetElementObject(4, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Friendly Fire Enabled");  
	TempObj.SetString("field2", ConvertServerSettings(gs.getFFEnabled()));
	DataProvider.SetElementObject(5, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Grenade Friendly Fire Enabled");  
	TempObj.SetString("field2", ConvertServerSettings(gs.getNadeFFEnabled()));
	DataProvider.SetElementObject(6, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Forced Teams");  
	TempObj.SetString("field2", ConvertServerSettings(gs.getAreTeamsForced()));
	DataProvider.SetElementObject(7, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Behind View Enabled");  
	TempObj.SetString("field2", ConvertServerSettings(gs.getIsBehindViewAllowed()));
	DataProvider.SetElementObject(8, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Spectator Mode");  
	TempObj.SetString("field2", ConvertServerSettings(gs.getSpectatorMode()));
	DataProvider.SetElementObject(9, TempObj);

	TempObj=CreateObject("Object");
	TempObj.SetString("field1", "Game Passworded");  
	TempObj.SetString("field2", ConvertServerSettings(gs.getIsGamePassworded()));
	DataProvider.SetElementObject(10, TempObj);

	MPServerDetailsList.SetObject("dataProvider",DataProvider); 
}

function PopulateServerPlayerInfo(int selectedindex)
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local CPIGameSettings gs;
	local int PeopleOnServer;
	local int index;
	local string PlayerInfo;
	local array<string> PlayerRowInfo;

	if(SearchSetting == none)
		return;

	if(SearchSetting.Results.Length == 0)
		return;

	if(SearchSetting.Results.Length < selectedindex + 1)
		return;

	gs = CPIGameSettings(SearchSetting.Results[selectedindex].GameSettings);

	if(gs == none)
		return;

	PeopleOnServer = (gs.NumPublicConnections + gs.NumPrivateConnections) - (gs.NumOpenPublicConnections + gs.NumOpenPrivateConnections);

	//`Log("There are " @ PeopleOnServer @ "people on the server");
	DataProvider=CreateArray();  

	if(DataProvider == none)
		return;

	for(index = 0 ; index < PeopleOnServer ; index++)
	{
		PlayerInfo = gs.getServerPlayerInfo(index);
		
		PlayerInfo = Mid(PlayerInfo,1,Len(PlayerInfo) - 2);

		ParseStringIntoArray(PlayerInfo,PlayerRowInfo,"|",false);

		if(PlayerRowInfo.Length == 0)
			return;

		TempObj=CreateObject("Object");

		if(TempObj == none)
			return;

		TempObj.SetString("field1", PlayerRowInfo[0]);  
		TempObj.SetString("field2", PlayerRowInfo[1]);
		TempObj.SetString("field3", PlayerRowInfo[2]);
		TempObj.SetString("field4", PlayerRowInfo[3]);

		if(PlayerRowInfo[4] == "0")
			TempObj.SetString("field5", "MERC");
		else
			TempObj.SetString("field5", "SWAT");

		DataProvider.SetElementObject(index, TempObj);
	}

	for(index = PeopleOnServer ; index < 8 ; index++)
	{
		TempObj=CreateObject("Object");

		if(TempObj == none)
			return;

		TempObj.SetString("field1", "");  
		TempObj.SetString("field2", "");
		TempObj.SetString("field3", "");
		TempObj.SetString("field4", "");
		TempObj.SetString("field5", "");
		DataProvider.SetElementObject(index, TempObj);
	}
    MPFriendsDetailsList.SetObject("dataProvider",DataProvider); 
}

function PopulateServerList()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local int index;

	DataProvider=CreateArray(); 

	for(index = 0 ; index < 8 ; index++)
	{
		TempObj=CreateObject("Object");
		TempObj.SetString("field1", "");  
		TempObj.SetString("field2", "");
		TempObj.SetString("field3", "");
		TempObj.SetString("field4", "");
		DataProvider.SetElementObject(index, TempObj);
	}

    MPDatalist.SetObject("dataProvider",DataProvider); 

    PopulateServerPlayerInfo(0);
	PopulateServerRules(0);
}

function PopulateFriendsList()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local int index;

	DataProvider=CreateArray(); 

	for(index = 0 ; index < 8 ; index++)
	{
		TempObj=CreateObject("Object");
		TempObj.SetString("field1", "");  
		TempObj.SetString("field2", "");
		TempObj.SetString("field3", "");
		TempObj.SetString("field4", "");
		TempObj.SetString("field5", "");
		DataProvider.SetElementObject(index, TempObj);
	}

    MPFriendsDetailsList.SetObject("dataProvider",DataProvider); 
}

function PopulateServerInfoList()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local int index;

	DataProvider=CreateArray(); 

	for(index = 0 ; index < 8 ; index++)
	{
		TempObj=CreateObject("Object");
		TempObj.SetString("field1", "");  
		TempObj.SetString("field2", "");
		TempObj.SetString("field3", "");
		TempObj.SetString("field4", "");
		DataProvider.SetElementObject(index, TempObj);
	}

    MPServerDetailsList.SetObject("dataProvider",DataProvider); 
}
event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled=false;

	switch(WidgetName)
	{
		case ('MultiplayerTitle'):
			MultiplayerTitle=GFxClikWidget(Widget);
			if(MultiplayerTitle != none)
			{
				MultiplayerTitle.SetString("text", "Multiplayer");
			}
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
		case('_scrollBar'):
			//these are handled as part of the scrollbar
			bWasHandled=true; 
		break;
		case ('MPJoinGameBtn'):
			MPJoinGameBtn=GFxClikWidget(Widget);
			if(MPJoinGameBtn != none)
			{
				MPJoinGameBtn.SetString("label","Join Game");
				MPJoinGameBtn.AddEventListener('CLIK_press',Select_JoinGameButton);
			}
			bWasHandled=true; 
		break;
		case ('MPRefreshBtn'):
			MPRefreshBtn=GFxClikWidget(Widget);
			if(MPRefreshBtn != none)
			{
				MPRefreshBtn.SetString("label","Refresh");
				MPRefreshBtn.AddEventListener('CLIK_press', Select_RefreshButton);
			}
			bWasHandled=true; 
		break;
		case ('MPBacBtn'):
			MPBacBtn=GFxClikWidget(Widget);
			if(MPBacBtn != none)
			{
				MPBacBtn.SetString("label","Back");
				MPBacBtn.AddEventListener('CLIK_press',Select_BackButton);
			}
			bWasHandled=true; 
		break;
		case ('Header1'):
			Header1=GFxClikWidget(Widget);
			Header1.SetString("label","SERVER NAME");
			bWasHandled=true; 
		break;	
		case ('Header2'):
			Header2=GFxClikWidget(Widget);
			Header2.SetString("label","PING");
			bWasHandled=true; 
		break;
		case ('Header3'):
			Header3=GFxClikWidget(Widget);
			Header3.SetString("label","MAP NAME");
			bWasHandled=true; 
		break;
		case ('Header4'):
			Header4=GFxClikWidget(Widget);
			Header4.SetString("label","PLAYERS");
			bWasHandled=true; 
		break;
		case ('ServerHeader1'):
			ServerHeader1=GFxClikWidget(Widget);
			ServerHeader1.SetString("label","PROPERTY");
			bWasHandled=true; 
		break;	
		case ('ServerHeader2'):
			ServerHeader2=GFxClikWidget(Widget);
			ServerHeader2.SetString("label","VALUE");
			bWasHandled=true; 
		break;
		case ('FriendsDataHeader1'):
			FriendsDataHeader1=GFxClikWidget(Widget);
			FriendsDataHeader1.SetString("label","PLAYER NAME");
			bWasHandled=true; 
		break;
		case ('FriendsDataHeader2'):
			FriendsDataHeader2=GFxClikWidget(Widget);
			FriendsDataHeader2.SetString("label","SCORE");
			bWasHandled=true; 
		break;
		case ('FriendsDataHeader3'):
			FriendsDataHeader3=GFxClikWidget(Widget);
			FriendsDataHeader3.SetString("label","K/D");
			bWasHandled=true; 
		break;
		case ('FriendsDataHeader4'):
			FriendsDataHeader4=GFxClikWidget(Widget);
			FriendsDataHeader4.SetString("label","PING");
			bWasHandled=true; 
		break;
		case ('FriendsDataHeader5'):
			FriendsDataHeader5=GFxClikWidget(Widget);
			FriendsDataHeader5.SetString("label","TEAM");
			bWasHandled=true; 
		break;
		case ('MPDatalist'):
			MPDatalist=GFxClikWidget(Widget);
			PopulateServerList();
			MPDatalist.AddEventListener('CLIK_change',Select_MPDatalist_Selected);
			bWasHandled=true; 
		break;
		case ('MPServerDetailsList'):
			MPServerDetailsList=GFxClikWidget(Widget);
			PopulateServerInfoList();
			//MPDatalist.AddEventListener('CLIK_change',Select_MPServerDetailsList_Selected);
			bWasHandled=true; 
		break;
		case ('MPFriendsDetailsList'):
			MPFriendsDetailsList=GFxClikWidget(Widget);
			PopulateFriendsList();
			//MPDatalist.AddEventListener('CLIK_change',Select_MPFriendsDetailsList_Selected);
			bWasHandled=true; 
		break;
		case ('MPMapImage'):
			MPImageLoader=Widget;
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
		//`log( "CPI_FrontEnd_MultiplayerMenu::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}
	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}


/**
 * Initializes the variables for the OnlineSubSystem
 */
function InitOnlineSubSystem() {
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	if (OnlineSub == None) {
		`Log("CreateOnlineGame - No OnlineSubSystem found.");
		return;
	}

	GameInterface = OnlineSub.GameInterface;

	if (GameInterface == None) {
		`Log("CreateOnlineGame - No GameInterface found.");
	}
}

///**
// * Creates the OnlineGame with the Settings we want
// */
//function CreateOnlineGame() {
//	// Create the desired GameSettings
//	currentGameSettings = new class'CPIGameSettings';
//	currentGameSettings.bShouldAdvertise = true;
//	currentGameSettings.NumPublicConnections = 32;
//	currentGameSettings.NumPrivateConnections = 32;
//	currentGameSettings.NumOpenPrivateConnections = 32;
//	currentGameSettings.NumOpenPublicConnections = 32;
//	currentGameSettings.bIsLanMatch = false;
//	currentGameSettings.setServerName("My Test Server on Steam");

//	// Create the online game
//	// First, set the delegate thats called when the game was created (cause this is async)
//	GameInterface.AddCreateOnlineGameCompleteDelegate(OnGameCreated);

//	// Try to create the game. If it fails, clear the delegate
//	// Note: the playerControllerId == 0 is the default and noone seems to know what it actually does...
//	if (GameInterface.CreateOnlineGame(class'UIInteraction'.static.GetPlayerControllerId(0), 'Game', currentGameSettings) == FALSE ) {
//		GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
//		`Log("CreateOnlineGame - Failed to create online game.");
//	}
//}

///**
// * Delegate that gets called when the OnlineGame has been created.
// * Actually sends the player to the game
// */
//function OnGameCreated(name SessionName, bool bWasSuccessful) {
//	local string TravelURL;
//	local Engine Eng;
//	local PlayerController PC;

//	// Clear the delegate we set.
//	GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);

//	if (bWasSuccessful) {
//		Eng = class'Engine'.static.GetEngine();
//		PC = Eng.GamePlayers[0].Actor;

//		// Creation was successful, so send the player on the host to the level
//		// Build the URL
//		currentGameSettings.BuildURL(TravelURL);

//		TravelURL = "open " 
//			$ "CP-StGeorge"
//			$ "?game=criticalpoint.criticalpointgame"
//			$ TravelURL $ "?listen?steamsockets";
//		// Do the server travel.
//		PC.ConsoleCommand(TravelURL);
//	} else {
//		`Log("OnGameCreated: Creation of OnlineGame failed!");
//	}
//}

/**
 * Searches for Online games.
 */
function SearchOnlineGames() 
{
	if(bSearching)
		return;

	bSearching = true;
	SearchSetting = new class'CPIOnlineSearchSettings';
	SearchSetting.bIsLanQuery = false;
	SearchSetting.MaxSearchResults = 50;
	CancelSearchOnlineGames();
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
	GameInterface.FindOnlineGames(class'UIInteraction'.static.GetPlayerControllerId(0), SearchSetting);
}

function CancelSearchOnlineGames()
{
	// Cancel the Search first...cause there may be a former search still in progress
	GameInterface.CancelFindOnlineGames();
	GameInterface.ClearFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
	bSearching = false;
}

/**
 * Delegate that gets called when the ServerSearch is finished
 */
function OnServerQueryComplete(bool bWasSuccessful) {
	local int i;
	local CPIGameSettings gs;

	local GFxObject DataProvider;
	local GFxObject TempObj;

	DataProvider=CreateArray(); 

	if(DataProvider == none)
		return;

	searchResults = SearchSetting.Results;

	if(searchResults.Length == 0)
		return;

	if (bWasSuccessful) 
	{
		for (i = 0; i < SearchSetting.Results.Length; i++) 
		{
			gs = CPIGameSettings(SearchSetting.Results[i].GameSettings);

			TempObj=CreateObject("Object");

			if(TempObj == none)
				return;

			TempObj.SetString("field1", repl(gs.getServerName(),"\"","",false));  
			TempObj.SetString("field2", string(gs.PingInMs));
			TempObj.SetString("field3", gs.getMapName());
			TempObj.SetString("field4", string((gs.NumPublicConnections + gs.NumPrivateConnections) - (gs.NumOpenPublicConnections + gs.NumOpenPrivateConnections)) $ "/" $ string(gs.NumPublicConnections + gs.NumPrivateConnections));
			TempObj.SetString("field5", gs.SteamServerId);

			DataProvider.SetElementObject(i, TempObj);
		}

		for(i = SearchSetting.Results.Length ; i < 8 ; i++)
		{
			TempObj=CreateObject("Object");

			if(TempObj == none)
				return;

			TempObj.SetString("field1", "");  
			TempObj.SetString("field2", "");
			TempObj.SetString("field3", "");
			TempObj.SetString("field4", "");
			TempObj.SetString("field5", "");
			DataProvider.SetElementObject(i, TempObj);
		}

		MPDatalist.SetObject("dataProvider",DataProvider); 
		PopulateServerPlayerInfo(0); //poulate the first servers player info
		PopulateServerRules(0); //poulate the first servers rules info
		SetMapImage(0);
	} 
	else 
	{
		`Log("No Results!!!!!");
	}

	GameInterface.ClearFindOnlineGamesCompleteDelegate(OnServerQueryComplete);
	bSearching = false;
	
}

function OnEscapeKeyPress()
{
	CancelSearchOnlineGames();
	super.OnEscapeKeyPress();
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="MPJoinGameBtn",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="MPRefreshBtn",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="MPBacBtn",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="Header1",WidgetClass=class'GFxClikWidget'))			
	SubWidgetBindings.Add((WidgetName="Header2",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="Header3",WidgetClass=class'GFxClikWidget'))		
	SubWidgetBindings.Add((WidgetName="Header4",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="ServerHeader1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="ServerHeader2",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FriendsDataHeader1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="FriendsDataHeader2",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FriendsDataHeader3",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FriendsDataHeader4",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FriendsDataHeader5",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="MPDatalist",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MPServerDetailsList",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MPFriendsDetailsList",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="MultiplayerTitle",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MPMapImage",WidgetClass=class'GFxObject'))	
	blnConsoleShowing = false
}
