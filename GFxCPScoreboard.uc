class GFxCPScoreboard extends GFxMoviePlayer;

var GFxObject RootMC;
var GFxObject ScoreboardMC, OverlayMC, BlueTeamMC, RedTeamMC, SpectatorMC;

var GFxObject BlueHeaderMC, BlueScoreTF, BlueTitleTF;
var GFxObject RedHeaderMC, RedScoreTF, RedTitleTF;

var byte RedTeamIndex, BlueTeamIndex;
var GFxObject PlayerRow;
var CONST ASColorTransform GREEN, YELLOW, WHITE;

var bool bPlayerRowTween;

var array<CPPlayerReplicationInfo> RedPRIs, BluePRIs, SpectatorPRIs;

var bool blnColorRow;

var Float TimerCount;
var Float LastTimerCount;

//for localisation
//lblSWATPlayerName, lblSWATScoreName, lblSWATKillDeathsName, lblSWATPingName
//lblMERCPlayerName, lblMERCScoreName, lblMERCKillDeathsName, lblMERCPingName

//gfxGradientBG TODO make this one on one off in the menus.
struct ScoreboardState
{
    var int     RemainingTime;
    var int     RedScore;
    var int     BlueScore;
    var array<CPPlayerReplicationInfo> RedPlayers;
    var array<CPPlayerReplicationInfo> BluePlayers;
	var array<CPPlayerReplicationInfo> SpectatorPlayers;
};

var ScoreboardState PreviousState;

struct ScoreRow
{
    var GFxObject MovieClip;
	var GFxObject NameTF;
    var GFxObject ScoreTF;
	var GFxObject KillsDeathsTF;
	var GFxObject PingTF;
	var GFxObject LocationTF;
	var GFxObject TimeInGameTF;
	var GFxObject PlayersIdTF;
	var GFxObject PacketLossTF;
	var GFxObject gfxGradientBG;
	var GFxObject gfxGradientBGSWAT;
	var GFxObject gfxGradientBGMERC;
	var GFxObject gfxGradientBGDEAD;
	var GFxObject EscapeIcon;
	var GFxObject DeadIcon;
	var GFxObject SpectateIcon;

	//var GFxObject gfxGradientBGSPECTATORS;
};

var array<ScoreRow> BlueItems, RedItems, SpectatorItems;

var transient array<CPPlayerReplicationInfo> PRIList;

var transient int NameCnt;

var bool bInitialized;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);
	//SetViewScaleMode(SM_ExactFit);
	if (!bInitialized)
	{
		ConfigScoreboard();
	}

	Draw();
    return true;
}

function PlayOpenAnimation()
{
    OverlayMC.GotoAndPlay("open");
}

function PlayCloseAnimation()
{
    OverlayMC.GotoAndPlay("close");
}

/*
 * Cache references to Scoreboard's MovieClips for later use.
 */
function ConfigScoreboard()
{
	RootMC = GetVariableObject("_root");
	ScoreboardMC = RootMC.GetObject("scoreboard");
	OverlayMC = ScoreboardMC.GetObject("overlay");
	BlueTeamMC = ScoreboardMC.GetObject("blue_team");
	RedTeamMC = ScoreboardMC.GetObject("red_team");
	//SpectatorMC = ScoreboardMC.GetObject("spectator");

	SetupBlueTeam();
	SetupRedTeam();
	SetupSpectators();

	bInitialized = true;
}

/*
 * Cache references to MovieClips used for the Blue Team.
 */
function SetupBlueTeam()
{
    local byte i;
    local GFxObject Item_GMC;
    local ScoreRow sr;

    for (i = 0; i < 12; i++)
    {
        BlueItems[i] = sr;
        BlueItems[i].MovieClip = BlueTeamMC.GetObject("item"$(i+1));
        BlueItems[i].MovieClip.SetFloat("_z", 200);

        Item_GMC = BlueItems[i].MovieClip.GetObject("item_g");
        BlueItems[i].KillsDeathsTF          = Item_GMC.GetObject("deaths");
        BlueItems[i].ScoreTF                = Item_GMC.GetObject("score");
        BlueItems[i].NameTF                 = Item_GMC.GetObject("name");
		BlueItems[i].PingTF                 = Item_GMC.GetObject("ping");
		BlueItems[i].LocationTF             = Item_GMC.GetObject("location");
		BlueItems[i].TimeInGameTF           = Item_GMC.GetObject("timeingame");
		BlueItems[i].PlayersIdTF            = Item_GMC.GetObject("playersid");
		BlueItems[i].PacketLossTF           = Item_GMC.GetObject("packetloss");
		BlueItems[i].EscapeIcon             = Item_GMC.GetObject("escapeMan");
		BlueItems[i].DeadIcon               = Item_GMC.GetObject("deathIcon");
		BlueItems[i].SpectateIcon           = Item_GMC.GetObject("spectateIcon");
		BlueItems[i].gfxGradientBG          = Item_GMC.GetObject("gfxGradientBG");
		BlueItems[i].gfxGradientBGSWAT      = Item_GMC.GetObject("gfxGradientBGSWAT");
		BlueItems[i].gfxGradientBGMERC      = Item_GMC.GetObject("gfxGradientBGMERC");
		BlueItems[i].gfxGradientBGDEAD		= Item_GMC.GetObject("gfxGradientBGDead");
    }

    BlueHeaderMC = BlueTeamMC.GetObject("header");
    BlueScoreTF = BlueHeaderMC.GetObject("score").GetObject("textField");
}

/*
 * Cache references to MovieClips used for the Red Team.
 */
function SetupRedTeam()
{
    local byte i;
    local GFxObject Item_GMC;
    local ScoreRow sr;

    for (i = 0; i < 12; i++)
    {
        RedItems[i] = sr;
        RedItems[i].MovieClip = RedTeamMC.GetObject("item"$(i+1));
        RedItems[i].MovieClip.SetFloat("_z", 200);

        Item_GMC = RedItems[i].MovieClip.GetObject("item_g");
        RedItems[i].KillsDeathsTF           = Item_GMC.GetObject("deaths");
        RedItems[i].ScoreTF				    = Item_GMC.GetObject("score");
        RedItems[i].NameTF                  = Item_GMC.GetObject("name");
		RedItems[i].PingTF                  = Item_GMC.GetObject("ping");
		RedItems[i].LocationTF              = Item_GMC.GetObject("location");
		RedItems[i].TimeInGameTF            = Item_GMC.GetObject("timeingame");
		RedItems[i].PlayersIdTF             = Item_GMC.GetObject("playersid");
		RedItems[i].PacketLossTF            = Item_GMC.GetObject("packetloss");
		RedItems[i].EscapeIcon              = Item_GMC.GetObject("escapeMan");
		RedItems[i].DeadIcon                = Item_GMC.GetObject("deathIcon");
		RedItems[i].SpectateIcon            = Item_GMC.GetObject("spectateIcon");
		RedItems[i].gfxGradientBG           = Item_GMC.GetObject("gfxGradientBG");
		RedItems[i].gfxGradientBGSWAT       = Item_GMC.GetObject("gfxGradientBGSWAT");
		RedItems[i].gfxGradientBGMERC       = Item_GMC.GetObject("gfxGradientBGMERC");
		RedItems[i].gfxGradientBGDEAD		= Item_GMC.GetObject("gfxGradientBGDead");
    }

    RedHeaderMC = RedTeamMC.GetObject("header");
    RedScoreTF = RedHeaderMC.GetObject("score").GetObject("textField");
}

/*
 * Cache references to MovieClips used for the Spectating Team.
 */
function SetupSpectators()
{
	local byte i;
	local int randCount;
    local GFxObject Item_GMC;
    local ScoreRow sr;
	local int otherSide;

	randCount = 0;
	otherSide = 0;

    for (i = 0; i < 4; i++)
    {
        SpectatorItems[i] = sr;
		// Rogue FIXME.. Remove this when section for specators is created in HUD.
		// This just randomly gets a location on the bottom of the scoreboard for
		// spectators
		if(randCount == 0)
		{
			SpectatorItems[i].MovieClip = RedTeamMC.GetObject("item"$(12-otherSide));
		}
		else
		{
			SpectatorItems[i].MovieClip = BlueTeamMC.GetObject("item"$(12-otherSide));
			otherSide++;
		}
		// Use this when the spectator section of the hud is created. 
		//SpectatorItems[i].MovieClip = SpectatorMC.GetObject("item"$(i+1));
		
		// Get Objects for each section of the HUD for spectators.
		// These will change based on how the Spectator part of the HUD is
		// setup.
		SpectatorItems[i].MovieClip.SetFloat("_z", 200);
		Item_GMC = SpectatorItems[i].MovieClip.GetObject("item_g");
		SpectatorItems[i].KillsDeathsTF           = Item_GMC.GetObject("deaths");
		SpectatorItems[i].ScoreTF				  = Item_GMC.GetObject("score");
		SpectatorItems[i].NameTF                  = Item_GMC.GetObject("name");
		SpectatorItems[i].PingTF                  = Item_GMC.GetObject("ping");
		SpectatorItems[i].LocationTF              = Item_GMC.GetObject("location");
		SpectatorItems[i].TimeInGameTF            = Item_GMC.GetObject("timeingame");
		SpectatorItems[i].PlayersIdTF             = Item_GMC.GetObject("playersid");
		SpectatorItems[i].PacketLossTF            = Item_GMC.GetObject("packetloss");
		SpectatorItems[i].EscapeIcon              = Item_GMC.GetObject("escapeMan");
		SpectatorItems[i].DeadIcon                = Item_GMC.GetObject("deathIcon");
		SpectatorItems[i].SpectateIcon            = Item_GMC.GetObject("spectateIcon");
		SpectatorItems[i].gfxGradientBG           = Item_GMC.GetObject("gfxGradientBG");
		SpectatorItems[i].gfxGradientBGSWAT       = Item_GMC.GetObject("gfxGradientBGSWAT");
		SpectatorItems[i].gfxGradientBGMERC       = Item_GMC.GetObject("gfxGradientBGMERC");
		SpectatorItems[i].gfxGradientBGDEAD		  = Item_GMC.GetObject("gfxGradientBGDead");
		//SpectatorItems[i].gfxGradientBGSPECTATORS = Item_GMC.GetObject("gfxGradientBGSPECTATORS");
		randCount++;
		if(randCount > 1)
		{
			randCount = 0;
		}
    }
}
/*
 * Clears a ScoreRow struct
 */
function ClearScoreRowStruct(out ScoreRow scrt)
{
	scrt.MovieClip=none;
	scrt.NameTF=none;
	scrt.ScoreTF=none;
	scrt.KillsDeathsTF=none;
	scrt.PingTF=none;
	scrt.LocationTF=none;
	scrt.TimeInGameTF=none;
	scrt.PlayersIdTF=none;
	scrt.PacketLossTF=none;
	scrt.gfxGradientBG=none;
	scrt.gfxGradientBGSWAT=none;
	scrt.gfxGradientBGMERC=none;
	scrt.gfxGradientBGDEAD=none;
	scrt.EscapeIcon=none;
	scrt.DeadIcon=none;
	scrt.SpectateIcon=none;
}


/*
 * Initial setup of Scoreboard.
 */
function Draw()
{
    local CPGameReplicationInfo GRI;
    local byte i;
    local byte redPlayers, bluePlayers, spectatorPlayers;
	local array<CPPlayerReplicationInfo> BlankPRI;

	PRIList.Length = 0;
    redPlayers = 0;
    bluePlayers = 0;
	spectatorPlayers = 0;

	//TOP-Proto Fix for Scoreboard shows player on both teams 
	//When swapping sides the Cached PRI's were never cleared and would leave a ghost entry in the scoreboard. This should fix it.

	BlankPRI.Length=0;
	RedPRIs=BlankPRI;
	BluePRIs=BlankPRI;
	SpectatorPRIs=BlankPRI;

    if (GetPC() != none)
	{
        GRI = CPGameReplicationInfo(GetPC().WorldInfo.GRI);
	}

	if ( GRI == None )
	{
		return;
	}

    GetPRIList(GRI);

	// Setup lists of Red/Blue players -only has 12 slots.
	// FIXME Spectator has 4 slots? Probably really only 2 but TDB....
    for (i = 0; i < PRIList.length; i++)
	{
        if ((PRIList[i].Team == None) || PRIList[i].bOnlySpectator)
        {
			if(spectatorPlayers < 4)
        {
				SpectatorPRIs[spectatorPlayers] = PRIList[i];
				spectatorPlayers++;
			}
        }	
        else if((PRIList[i].Team.TeamIndex == RedTeamIndex) && (redPlayers < 12))
			{
				RedPRIs[redPlayers] = PRIList[i];
				redPlayers++;
			}
		else if ( (PRIList[i].Team.TeamIndex == BlueTeamIndex) && (bluePlayers < 12) )
		{
			BluePRIs[bluePlayers] = PRIList[i];
			bluePlayers++;
		}
		
    }

    UpdateHeaders(GRI);
    //UpdatePreviousState(GRI);

	// Sort arrays by score.
	if(RedPRIs.Length != 0)
	{
		InsertSortIArray(RedPRIs, 0, RedPRIs.Length-1);
	}

	if(BluePRIs.Length != 0)
	{
		InsertSortIArray(BluePRIs, 0, BluePRIs.Length-1);
	}
}

function Tick(Float DeltaTime)
{
    local CPGameReplicationInfo GRI;
	GRI = CPGameReplicationInfo(GetPC().WorldInfo.GRI);
	
	// Rogue- Only update Scoreboard aboute every second instead of constantly
    // Appears the Scoreboard hud cannot take being updated constantly for some reason...
	if( ((TimerCount-=DeltaTime) <= 0.0) || 
		((GetPC().WorldInfo.TimeSeconds - LastTimerCount) > 1.0)
	  )
	{
		if( GRI!=None )
		{
			Update(GRI);
		}
		TimerCount = 0.4;
		LastTimerCount = GetPC().WorldInfo.TimeSeconds;
	}
}

function Update(CPGameReplicationInfo GRI)
{

	UpdateTeam(RedPRIs, RedItems);
	if(RedPRIs.Length != 0)
	{
		InsertSortIArray(RedPRIs, 0, RedPRIs.Length-1);
	}

	// If it's not a team game, only RedTeam is used.		
	UpdateTeam(BluePRIs, BlueItems);
	if(BluePRIs.Length != 0)
	{

		InsertSortIArray(BluePRIs, 0, BluePRIs.Length-1);
	}

	// Add specators
	UpdateSpecatorDisplay(SpectatorPRIs, SpectatorItems);

	//UpdatePreviousState(GRI);
	UpdateHeaders(GRI);
}

function HideEmptyRows(array<ScoreRow> TeamRows, int IntEmptyRowStartNumber)
{
	local int i;
    local ScoreRow thisRow;

	ClearScoreRowStruct(thisRow);
    for (i = IntEmptyRowStartNumber; i < TeamRows.Length; i++)
    {
		thisRow = TeamRows[i];
		thisRow.MovieClip.SetBool("_visible",false);
    }
}

/*
 * Update the rows for a team.
 * Handles the deaths, scores, and name fields of a row. Also manages which
 * row belongs to this player. Could be optimized by avoid unnecessary SetText() calls
 * by comparing the current state with previous state for each player.
 */
function UpdateTeam(array<CPPlayerReplicationInfo> TeamPRIs, array<ScoreRow> TeamRows)
{
    local ScoreRow thisRow;
    local int i;
	local CPPlayerReplicationInfo CurrentPRI;

	//hide rows with no players on them yet.
	HideEmptyRows(TeamRows, TeamPRIs.length);

	//reset for the pri array
	blnColorRow = true;

	ClearScoreRowStruct(thisRow);
    for (i = (TeamPRIs.length - 1); i >= 0; i--)
    {
		// Check to see that an update the row is necessary.
		CurrentPRI = TeamPRIs[i]; // The PRI we're looking at.

		thisRow = TeamRows[(TeamPRIs.length-1) - i];

		//Color every other row in a PRI to make it look pretty.
		if(blnColorRow)
		{
			thisRow.gfxGradientBG.SetBool("_visible",false);
			blnColorRow = false;
		}
		else
		{
			thisRow.gfxGradientBG.SetBool("_visible",true);
			blnColorRow = true;
		}

		thisRow.gfxGradientBGDEAD.SetBool("_visible", false);
		thisRow.gfxGradientBGSWAT.SetBool("_visible",false);
		thisRow.gfxGradientBGMERC.SetBool("_visible",false);

		if(CurrentPRI == none)
		{
			thisRow.MovieClip.SetBool("_visible",false);
			continue;
		}

		thisRow.MovieClip.SetBool("_visible",true);
		thisRow.KillsDeathsTF.SetText(string(CurrentPRI.CPKills) $ "/" $ string(CurrentPRI.Deaths));
		thisRow.ScoreTF.SetText(string(int(CurrentPRI.Score)*10));
		thisRow.PingTF.SetText(string(int(CurrentPRI.Ping)));
		//thisRow.LocationTF.SetText(CurrentPRI.GetLocationName()); //TOP-Proto TODO: Fix this 
		thisRow.LocationTF.SetText("");
		thisRow.TimeInGameTF.SetText("T:"   $ GetTimeOnline(CurrentPRI));
		thisRow.PlayersIdTF.SetText("ID:"   $ string(CurrentPRI.CPPlayerID));
		thisRow.PacketLossTF.SetText("PL:"  $ string(CurrentPRI.StatPKLTotal));
		
		thisRow.EscapeIcon.SetVisible(CurrentPRI.bHasEscaped);
		thisRow.SpectateIcon.SetVisible(false); //spectators go into the dedicated spectator listings.

		// Display the dead icon when dead
		if(thisRow.DeadIcon != none)
		{
			if(CurrentPRI.bOutOfLives || (CurrentPRI.bIsSpectator && !CurrentPRI.bOnlySpectator))
				thisRow.DeadIcon.SetVisible(true);
			else
                thisRow.DeadIcon.SetVisible(false);
		}

		// Shade this player's name when dead
		if(thisRow.gfxGradientBGDEAD != none)
		{
			thisRow.gfxGradientBGDEAD.SetBool("_visible", CurrentPRI.bOutOfLives);
		}

		//`Log("CurrentPRI.ClanTag @ CurrentPRI.PlayerName @ thisRow.DeadIcon =" @CurrentPRI.ClanTag @ CurrentPRI.PlayerName @ thisRow.DeadIcon);
		if(CurrentPRI.bAdmin)
			thisRow.NameTF.SetColorTransform( YELLOW );
		else
			thisRow.NameTF.SetColorTransform( WHITE );

		thisRow.NameTF.SetString("htmlText", left(CurrentPRI.ClanTag,6) /* limit clantag to 6 chars even though we do the checks when setting it */ @ left(CurrentPRI.PlayerName,15));

		if (CurrentPRI.IsLocalPlayerPRI())
		{
			if((PRIList[i].Team.TeamIndex == RedTeamIndex) )
			{
				thisRow.gfxGradientBGSWAT.SetBool("_visible",false);
				thisRow.gfxGradientBGMERC.SetBool("_visible",true);
			}
			else
			{
				thisRow.gfxGradientBGSWAT.SetBool("_visible",true);
				thisRow.gfxGradientBGMERC.SetBool("_visible",false);
			}
			thisRow.gfxGradientBG.SetBool("_visible",false);
		}
   }
}

/*
 * Update the Spectator Rows.
 * Handles the Player name andPlayerId of the spectator. 
 * Could be optimized by avoid unnecessary SetText() calls
 * by comparing the current state with previous state for each spectator.
 */
function UpdateSpecatorDisplay(array<CPPlayerReplicationInfo> TeamPRIs, array<ScoreRow> TeamRows)
{
    local ScoreRow thisRow;
    local int i;
	local CPPlayerReplicationInfo CurrentPRI;

	//hide rows with no players on them yet.
	HideEmptyRows(TeamRows, TeamPRIs.length);

	//reset for the pri array
	blnColorRow = true;

	ClearScoreRowStruct(thisRow);
    for (i = (TeamPRIs.length - 1); i >= 0; i--)
    {
		// Check to see that an update the row is necessary.
		CurrentPRI = TeamPRIs[i]; // The PRI we're looking at.

		thisRow = TeamRows[(TeamPRIs.length-1) - i];

		//Color every other row in a PRI to make it look pretty.
		if(blnColorRow)
		{
			thisRow.gfxGradientBG.SetBool("_visible",false);
			blnColorRow = false;
		}
		else
		{
			thisRow.gfxGradientBG.SetBool("_visible",true);
			blnColorRow = true;
		}
		
		thisRow.gfxGradientBGSWAT.SetBool("_visible",false);
		thisRow.gfxGradientBGMERC.SetBool("_visible",false);
		thisRow.MovieClip.SetBool("_visible",true);
		thisRow.KillsDeathsTF.SetText("");		
		thisRow.ScoreTF.SetText("");
		thisRow.PingTF.SetColorTransform( GREEN );
		thisRow.PingTF.SetText("Spec");
		thisRow.LocationTF.SetText("");
		thisRow.TimeInGameTF.SetText("");
		thisRow.PlayersIdTF.SetColorTransform( GREEN );
		thisRow.PlayersIdTF.SetText("ID:"   $ string(CurrentPRI.CPPlayerID));
		thisRow.PacketLossTF.SetText("");

		if(thisRow.SpectateIcon != none)
			thisRow.SpectateIcon.SetVisible(true);
		
		if(thisRow.DeadIcon != none)
			thisRow.DeadIcon.SetVisible(false);

		if(thisRow.EscapeIcon != none)
			thisRow.EscapeIcon.SetVisible(false);

		//if(thisRow.EscapeIcon != none)
		//	thisRow.EscapeIcon.SetVisible(CurrentPRI.bHasEscaped);

		//if(CurrentPRI.Team != none && CurrentPRI.bIsSpectator)
		//{
		//	if(thisRow.DeadIcon != none)
		//	{
		//		thisRow.DeadIcon.SetVisible(CurrentPRI.bOutOfLives);
		//	}
		//}
		//else
		//{
		//	if(thisRow.DeadIcon != none)
		//	{
		//		thisRow.DeadIcon.SetVisible(false);
		//	}
		//}

		//`Log("CurrentPRI.ClanTag @ CurrentPRI.PlayerName =" @CurrentPRI.ClanTag @ CurrentPRI.PlayerName);
		thisRow.NameTF.SetColorTransform( GREEN );
		thisRow.NameTF.SetString("htmlText", CurrentPRI.ClanTag @ CurrentPRI.PlayerName);

		if (CurrentPRI.IsLocalPlayerPRI())
		{
			if((PRIList[i].Team.TeamIndex == RedTeamIndex) )
			{
				thisRow.gfxGradientBGSWAT.SetBool("_visible",false);
				thisRow.gfxGradientBGMERC.SetBool("_visible",true);
			}
			else
			{
				thisRow.gfxGradientBGSWAT.SetBool("_visible",true);
				thisRow.gfxGradientBGMERC.SetBool("_visible",false);
			}
			thisRow.gfxGradientBG.SetBool("_visible",false);
		}
   }
}

/*
 * Store the current Game State. Data is used for checking if an update
 * to the view is necessary.
 */
function UpdatePreviousState(CPGameReplicationInfo GRI)
{
	PreviousState.RemainingTime = GRI.RemainingTime;
	PreviousState.RedScore = (GRI!=None && GRI.Teams.Length != 0) ? GRI.Teams[RedTeamIndex].Score : 0.f;
	PreviousState.BlueScore = (GRI!=None && GRI.Teams.Length != 0) ? GRI.Teams[BlueTeamIndex].Score : 0.f;
}

/*
 * Updates the following text fields:
 *      Red Team's Score
 *      Blue Team's Score
 *      Remaining Time
 */
function UpdateHeaders(CPGameReplicationInfo GRI)
{
	if (GRI!=None && GRI.Teams.Length != 0)
	{
		if (PreviousState.RedScore != GRI.Teams[RedTeamIndex].Score)
		{
			RedScoreTF.SetText(Min(GRI.Teams[RedTeamIndex].Score, 9999));
		}			
		if (PreviousState.BlueScore != GRI.Teams[BlueTeamIndex].Score)
		{
			BlueScoreTF.SetText(Min(GRI.Teams[BlueTeamIndex].Score, 9999));
		}
        UpdatePreviousState(GRI);
	}
}

/** Start UTScoreboard class **/

/** Scan the PRIArray and get any valid PRI's for display **/
function GetPRIList(CPGameReplicationInfo GRI)
{
	local int i,Idx;
	local CPPlayerReplicationInfo PRI;

	if (GRI != None)
	{
		for (i=0; i < GRI.PRIArray.Length; i++)
		{
			PRI = CPPlayerReplicationInfo(GRI.PRIArray[i]);
			if ( PRI != none && IsValidScoreboardPlayer(PRI) )
			{
				Idx = PRIList.Length;
				PRIList.Length = Idx + 1;
				PRIList[Idx] = PRI;
			}
		}
	}
}

function bool IsValidScoreboardPlayer( CPPlayerReplicationInfo PRI)
{
	//if ( !PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
	//	(PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None)) )
	//{
	//	return false;
	//}

	return true;
}

function string GetTimeOnline(CPPlayerReplicationInfo PRI)
{
	local int Mins;

	if(PRI != none)
	{
		Mins = (PRI.WorldInfo.GRI.ElapsedTime - PRI.StartTime) / 60;
	}

	return String(Mins);
}


static final function InsertSortIArray(out array<CPPlayerReplicationInfo> MyArray, int LowerBound, int UpperBound)
{
  local int InsertIndex, RemovedIndex;
  local int High, Closest;

  if ( LowerBound < UpperBound && MyArray[LowerBound+1] != none && MyArray[UpperBound] != none)
     for (RemovedIndex = LowerBound + 1; RemovedIndex <= UpperBound; ++RemovedIndex) {
      if ( MyArray[RemovedIndex-1].Score > MyArray[RemovedIndex].Score ) {
        // element is not in the correct place, find InsertIndex with BinarySearch
        InsertIndex = 0;
        High = RemovedIndex - 1;
        while (InsertIndex <= High) {
          Closest = (InsertIndex + High) / 2;
          if ( MyArray[Closest].Score == MyArray[RemovedIndex].Score ) {
            InsertIndex = Closest;
            break;
          }
          if ( MyArray[Closest].Score > MyArray[RemovedIndex].Score )
            High = Closest - 1;
          else if ( MyArray[Closest].Score < MyArray[RemovedIndex].Score )
            InsertIndex = Closest + 1;
        }
        if ( InsertIndex < RemovedIndex && MyArray[InsertIndex].Score < MyArray[RemovedIndex].Score )
          ++InsertIndex;
      }
      else
        InsertIndex = RemovedIndex;


      if ( RemovedIndex != InsertIndex ) {
        MyArray.Insert(InsertIndex, 1);
        MyArray[InsertIndex] = MyArray[RemovedIndex + 1];
        MyArray.Remove(RemovedIndex + 1, 1);
      }
    }
}

defaultproperties
{
    BlueTeamIndex = 1
    RedTeamIndex = 0
    bPlayerRowTween = false

    bDisplayWithHudOff=TRUE
	MovieInfo=SwfMovie'TA_Scoreboard.TAscoreboard'

	GREEN=(multiply=(R=0,G=128,B=0,A=0.9))
	YELLOW=(multiply=(R=255,G=255,B=0,A=0.9))
	WHITE=(multiply=(R=255,G=255,B=255,A=1.2)) 
}
