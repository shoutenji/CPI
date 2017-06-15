class CPConsole extends Console within CPGameViewportClient config(Input);

/** The key which opens the console. */
var globalconfig name ConsoleKey;

/** The key which opens the typing bar. */
var globalconfig name TypeKey;
var globalconfig string GameVersion;

var bool blnShowVersionText;
var string LastOutputText;

var bool blnToggleConsole;
var string ServerIP; //stored for use in password box prompt
var bool blnConsoleShowing;

function SetTypeKey(name value)
{
	if(ConsoleKey == value)
	{
		ConsoleKey = '';
	}

	TypeKey = value;
	SaveConfig();

}

function SetConsoleKey(name value)
{
	if(TypeKey == value)
	{
		TypeKey = '';
	}

	ConsoleKey = value;
	SaveConfig();
}

/**
 * Executes a console command.
 * @param Command - The command to execute.
 */
function ConsoleCommand(string Command)
{		
	//local SteamProfileInfo SPI;
	local array<string> CommandArray;

	local CPPlayerReplicationInfo CPPRI;
	local CPGameReplicationInfo CPGRI;

	local int FirstQMark;

	if(CAPS(Left(Command,4)) == "OPEN")
	{ 
		FirstQMark = InStr(ServerIP,"?");

		if(FirstQMark != -1)
		{
			`Log("Server IP is" @ Mid(Command,5,FirstQMark - 5));
			ServerIP = Mid(Command,5,FirstQMark - 5);
		}
		else
		{
			CommandArray = SplitString(Command,"?",true);
			ServerIP = Split(CommandArray[0]," ",false);
			`Log("Server IP is" @ ServerIP);		
		}


		//if(InStr(Command,"hash") == -1)
		//{
		//	SPI = new(self) class'SteamProfileInfo';
		//	class'Engine'.static.BasicLoadObject(SPI, "steam_api.bin", false, 1);
		//	Command $= "?" $ "hash=" $ SPI.hash;
		//}

		strLastConsoleCommand = Command;

		if(GamePlayers[0].Actor.myHUD == none) //fixes a crash when unloading player and joining a server
		{
			super.ConsoleCommand(Command);
			return;
		}

		if(Len(GetMapName()) != 0) //main menu if its nothing
		{
			if(CPHUD(GamePlayers[0].Actor.myHUD).CPI_FrontEnd == none)
			{   
				CPHUD(GamePlayers[0].Actor.myHUD).ShowMenu();
			}
		}
		//the code below is to bypass storing this command with passwords
		StripPasswordFromHistory(Command);

		OutputText(">>>" @ Command @ "<<<");

		if(ConsoleTargetPlayer != None)
		{
			// If there is a console target player, execute the command in the player's context.
			ConsoleTargetPlayer.Actor.ConsoleCommand(Command);
		}
		else if(GamePlayers.Length > 0 && GamePlayers[0].Actor != None)
		{
			// If there are any players, execute the command in the first players context.
			GamePlayers[0].Actor.ConsoleCommand(Command);
		}
		else
		{
			// Otherwise, execute the command in the context of the viewport.
			Outer.ConsoleCommand(Command);
		}
		return;

	}
	else if(CAPS(Command) == "RECONNECT")
	{
		if(ConsoleTargetPlayer != None)
		{
			if (ConsoleTargetPlayer.Actor.PlayerReplicationInfo != None)
			{
				CPPRI = CPPlayerReplicationInfo(ConsoleTargetPlayer.Actor.PlayerReplicationInfo);
			}
			if (ConsoleTargetPlayer.Actor.WorldInfo.GRI != None)
			{
				CPGRI = CPGameReplicationInfo(ConsoleTargetPlayer.Actor.WorldInfo.GRI) ;
			}
		}
		else if(GamePlayers.Length > 0 && GamePlayers[0].Actor != None)
		{
			if(GamePlayers[0].Actor.PlayerReplicationInfo != None)
			{
				CPPRI = CPPlayerReplicationInfo(GamePlayers[0].Actor.PlayerReplicationInfo);
			}
			if(GamePlayers[0].Actor.WorldInfo.GRI!=None)
			{
				CPGRI = CPGameReplicationInfo(GamePlayers[0].Actor.WorldInfo.GRI);
			}
		}
		
		if(CPGRI!= None && CPPRI != None && !CPGRI.bDamageTaken) //Never died
		{
			CPPRI.bConditionalReturn = true;
		}
	}

		// Store the command in the console history.
	if ((HistoryTop == 0) ? !(History[MaxHistory - 1] ~= Command) : !(History[HistoryTop - 1] ~= Command))
	{
		// ensure uniqueness
		PurgeCommandFromHistory(Command);

		History[HistoryTop] = Command;
		HistoryTop = (HistoryTop+1) % MaxHistory;

		if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
			HistoryBot = (HistoryBot+1) % MaxHistory;
	}
	HistoryCur = HistoryTop;

	// Save the command history to the INI.
	SaveConfig();

	// Display say and teamsay a little different than other commands. Also
	// remove the extra space that is thrown into the log.....
    if(CAPS(Left(Command,3)) == "SAY" || CAPS(Left(Command,7)) == "TEAMSAY")
	{
		//Requested to remove these messages from consol since they will show up
		// as normal say and teamsay messages anyhow.
		//OutputText(">>>" @ Command);
	}
	else
	{
		OutputText(">>>" @ Command @ "<<<");
	}

	if(ConsoleTargetPlayer != None)
	{
		// If there is a console target player, execute the command in the player's context.
		ConsoleTargetPlayer.Actor.ConsoleCommand(Command);
	}
	else if(GamePlayers.Length > 0 && GamePlayers[0].Actor != None)
	{
		// If there are any players, execute the command in the first players context.
		GamePlayers[0].Actor.ConsoleCommand(Command);
	}
	else
	{
		// Otherwise, execute the command in the context of the viewport.
		Outer.ConsoleCommand(Command);
	}
}

function StripPasswordFromHistory(string Command)
{
	local string strRemovePass;
	// Store the command in the console history.
	if ((HistoryTop == 0) ? !(History[MaxHistory - 1] ~= Command) : !(History[HistoryTop - 1] ~= Command))
	{
		// ensure uniqueness

		//strip password from command

		strRemovePass = Split(Command,"?",false);
		
		Command = Repl(Command,strRemovePass,"");
		PurgeCommandFromHistory(Command);

		History[HistoryTop] = Command;
		HistoryTop = (HistoryTop+1) % MaxHistory;

		if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
			HistoryBot = (HistoryBot+1) % MaxHistory;
	}
	HistoryCur = HistoryTop;

	// Save the command history to the INI.
	SaveConfig();
}

function bool InputKey(int ControllerId,name Key,EInputEvent Event,float AmountDepressed=1.f,bool bGamepad=false)
{
	local WorldInfo WorldInfo;
	local CPPlayerController PC;

	// If we are currently chatting, disable the ability to open console
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if(WorldInfo != none)
	{
		foreach WorldInfo.LocalPlayerControllers(class'CPPlayerController', PC)
		{
			if(PC != none)
			{
				if(PC.CPHUD != none)
				{
					if(PC.CPHUD.HudMovie != none)
					{
						if(PC.CPHUD.HudMovie.bChatting)
						{
							return false;
						}
					}
				}
			}
		}
	}
	
	if (ConsoleTargetPlayer!=none && ConsoleTargetPlayer.Actor.WorldInfo.IsInSeamlessTravel())
		return false;
	if (Event==IE_Pressed)
	{
		if(blnToggleConsole)
		{
			bCaptureKeyInput=false;
			if (Key==class'CPConsole'.default.ConsoleKey)
			{
				blnConsoleShowing = true;
				GotoState('Open');
				bCaptureKeyInput=true;
			}
			else if (Key==class'CPConsole'.default.TypeKey)
			{
				blnConsoleShowing = true;
				GotoState('Typing');
				bCaptureKeyInput=true;
			}
		}
	}
	return bCaptureKeyInput;
}

state Open
{
	function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
	{
		if( Key == 'Escape' && Event == IE_Released )
		{
			blnConsoleShowing = false;
		}

		if( Key==class'CPConsole'.default.ConsoleKey && Event == IE_Pressed )
		{
			GotoState('');
			bCaptureKeyInput = true;
			blnConsoleShowing = false;
			return true;
		}
		else if(Key == 'Tab' && Event == IE_Pressed)
		{
			if (AutoCompleteIndices.Length > 0 && !bAutoCompleteLocked)
			{
				TypedStr = AutoCompleteList[AutoCompleteIndices[0]].Command;
				SetCursorPos(Len(TypedStr));
				bAutoCompleteLocked = TRUE;
			}
			else
			{
				GotoState('');
				bCaptureKeyInput = true;
			}
			return true;
		}
		return super.InputKey(ControllerId,Key,Event,AmountDepressed,bGamepad);
	}

	event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		if(blnShowVersionText)
		{
			blnShowVersionText = false;
			OutputText("========================");
			OutputText("Critical Point:Incursion");
			OutputText("BETA");
			OutputText("Version "$GameVersion);
			OutputText("========================");
		}
	}
}

state Typing
{
	function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
	{
		if( Key == 'Escape' && Event == IE_Released )
		{
			blnConsoleShowing = false;
			GotoState( '' );
			return true;
		}
		else if ( Key==class'CPConsole'.default.ConsoleKey && Event == IE_Pressed )
		{
			GotoState('Open');
			bCaptureKeyInput = true;
			blnConsoleShowing = false;
			return true;
		}
		else if(Key == 'Tab' && Event == IE_Pressed) 
		{
			if (AutoCompleteIndices.Length > 0 && !bAutoCompleteLocked)
			{
				TypedStr = AutoCompleteList[AutoCompleteIndices[AutoCompleteIndex]].Command;
				SetCursorPos(Len(TypedStr));
				bAutoCompleteLocked = TRUE;
			}
			else
			{
				GotoState('');
				bCaptureKeyInput = true;
			}
			return true;
		}
		return Super.InputKey( ControllerId, Key, Event, AmountDepressed, bGamepad);
	}
}

event OutputText(coerce string Text)
{
	if(Text != LastOutputText)
	{
		LastOutputText = Text;
		Super.OutputText(Text);
	}
}

DefaultProperties
{
	LastOutputText = "NaN"
	blnShowVersionText=true
	blnToggleConsole=true
	blnConsoleShowing = false
}
