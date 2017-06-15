class CriticalPointGame extends GameInfo
    dependsOn(CPTeamInfo);

	`define GAMEINFO(dummy)
	`include(CriticalPoint\CPIStats.uci);
	`undefine(GAMEINFO)

enum ESpectateView // Global enum. Re-used in the GRI.
{
    SpectateView_All,
    SpectateView_TeamOnly,
    SpectateView_None
}; 

var     bool blnFinalRoundHUDMsgPlayed;
var     int ServerPlayerID;
var     CPTeamInfo  Teams[3];
var     CPTeamInfo  Spec;
var array<string> Swat, Merc, Hostages;
var int MercIndexId,SwatIndexId,HostageIndexId;
var config ESpectateView Spectating;

var NavigationPoint LastPlayerStartSpot;    // last place current player looking for start spot started from
var NavigationPoint LastStartSpot;          // last place any player started from

var config int RoundDurationInMinutes, // How long a round lasts (in minutes) before forcing an EndRound check.
    RoundStartDelay, // How long to wait (in seconds) before players can move upon starting a new round
    RoundEndDelay, // How long to wait (in seconds) before a round is restarted after it ends.
    GameRestartWait, // How to wait (in seconds) before the game is restarted (travel to new map)
    MinimumPlayers, // Minimum players required to start a match (stays in Warmup until this requirement is met)
    GameStartDelay, // Delay to start a match.
    MaxWaitOnTraveling, // Max time in seconds to wait for traveling players during warmup.
    FriendlyFirePercentage, // Percentage of damage done to teammate
    NadeFriendlyFirePercentage,
    MaxTeamKills;

var int CurrentRound;

var config bool bPlayersBalanceTeams; // Balance teams
var bool bPlayersBalanceTeamsCommandExecute; // Balance teams due to admin command

var config bool bAllowGhostCam;
var config bool bForceTeams;

var config bool bFFenabled;
var config bool bNadeFFenabled;

var config bool bAllowBehindView;

var float EndTime, StartTime;
var int WarmupDelay;
var bool bWarmupRound;
var bool bPrepopulateConfigSettings, bLoadConfigSettingsWhenPawnFound, bLoadConfigSettingsWhenNoPawnFound;

//var       globalconfig
var int     MinEscapeCount;
//var       globalconfig
var float   EscapePct;

// For calibrating cash drops
var config bool bDropMoneyOnSuicide;
var config bool bTeamOnlyMoneyDropIfSuicide;
var config int BaseMoneyDropAmount;
var config int MinCarryAmount;
var config int DropAmountTier1Min;
var config int DropAmountTier1Max;
var config int DropAmountTier2Max;
var config float DropAmountTier1Multiplier;
var config float DropAmountTier2Multiplier;
var config float DropAmountTier3Multiplier;
var config int KillAmount;
var config int TeamKillAmount;
var config int HostageRescueAmount;
var config int HostageTeamRescueAmount;
var config int HostageKillAmount;


/** Default inventory added via AddDefaultInventory() */
struct SDefaultTeamInventory
{
    var class<Inventory> Team[2];
};

struct LoserTracker
{
    var int LosingTeam;
    var int RoundsLost;
};

var bool blnWinningStreak;
var LoserTracker LT;

var array<SDefaultTeamInventory> DefaultInventory;

/** Map Cycle */
var globalconfig array<string> MapCycle;     // map (name) list used for the mapcycle
var globalconfig int MapCycleIndex;          // index of current map in the cycle

var bool bAdminSetNextMap;
var string strAdminMapSelected;

var localized array<string> tipString;

var CPGeoLocation SrvGeoLocation; // Geo location of the server

/** Array of active bot names. */
struct ActiveBotInfo
{
    /** name of character */
    var string BotName;
    /** whether the bot is currently in the game */
    var bool bInUse;
};
var globalconfig array<ActiveBotInfo> ActiveBots;

/** number of desired player on current map , */
var int DesiredPlayerCount;

/** Difficulty of game */
var int AdjustedDifficulty;

var globalconfig int PendingLoginTimeout;

var actor EndGameFocus;
var bool bSoaking;
var bool bPlayerBecameActive;

var bool bAutoNumBots;
//temporary it will be deleted
var int PlayerKills, PlayerDeaths;

/* Reverb Volume Hack */
var CPReverbVolumeHackHelper reverbHackHelper;

/* Player Info */
struct SPlayerInfo
{
    var CPPlayerController PC;
    var int UID;
    var vector LocationHistory[5];
    var int NextLocHistSlot;
    var bool bWarmedUp;
    var int ReCheckTime;
    var bool CampingStatus;
    var Vector CampingLocRandomOffset;
};

var array<SPlayerInfo> PlayerInfos;
var int PlayerInfoUIDCounter;

var bool bLastMerc, bLastSwat;

var bool bBombGiven;  //make sure the bomb is given to someone before we stop trying to give the bomb.
var CPHostageRescueZone foundHostageZone;
//var CPIValidate CV;
var int TopTeamIndex;

/** Gameplay statistics logging */
var config string GameplayEventsWriterClassName;
var transient GameplayEventsWriterBase GameplayEventsWriter;
var config bool bLogGameplayEvents;

var config bool bEnableGamePlayerPoll;

	// Hook-in for debugging and polling
	`include(GameAnalyticsProfile.uci);
	`if(`bRunGamePlayerPoll)
		`include(CPGamePlayerPoll.uci);
	`endif
	

	
/*
 *  Message broadcasting functions (handled by the BroadCastHandler)
 *  The main Broadcast function that broadcasts all announcements to the world
*/
event Broadcast( Actor Sender, coerce string Msg, optional name Type)
{
    local CPPlayerController PC;
    local PlayerReplicationInfo PRI;

    // This code gets the PlayerReplicationInfo of the sender. We'll use it to get the sender's name with PRI.PlayerName
    if ( Pawn(Sender) != None )
        PRI = Pawn(Sender).PlayerReplicationInfo;
    else if ( Controller(Sender) != None )
        PRI = Controller(Sender).PlayerReplicationInfo;

    // This line executes a "Say"
    // Removing this line completely will entirely remove the old, default chat system
   // BroadcastHandler.Broadcast(Sender,Msg,Type);

    // This is where we broadcast the received message to all players (PlayerControllers)
    if (WorldInfo != None)
    {
        foreach WorldInfo.AllControllers(class'CPPlayerController',PC)
        {
            PC.ReceiveBroadcast(PRI.PlayerName, Msg, Type, TopTeamIndex);
        }
    }
}


/*
*/
reliable client function SupplyTeamIndex(int TeamIndex)
{
    TopTeamIndex = TeamIndex;
}


/*
 *  Message broadcasting functions (handled by the BroadCastHandler)
 *  The main Broadcast function that broadcasts all team announcements to the world
*/
event BroadcastTeam( Controller Sender, coerce string Msg, optional name Type)
{
    local CPPlayerController PC;
    local PlayerReplicationInfo PRI;

    // This code gets the PlayerReplicationInfo of the sender. We'll use it to get the sender's name with PRI.PlayerName
    if ( Sender != None )
        PRI = Sender.PlayerReplicationInfo;
    else if ( Sender != None )
        PRI = Sender.PlayerReplicationInfo;

    // This line executes a "TeamSay"
    // Removing this line completely will entirely remove the old, default chat system
   // BroadcastHandler.BroadcastTeam(Sender,Msg,Type);

    // This is where we broadcast the received message to all players (PlayerControllers)
    if (WorldInfo != None)
    {
        foreach WorldInfo.AllControllers(class'CPPlayerController',PC)
        {
            PC.ReceiveBroadcast(PRI.PlayerName, Msg, Type, TopTeamIndex);
        }
    }
}


/*
*/
function PostBeginPlay()
{
    Super.PostBeginPlay();

    EscapePct = Clamp( EscapePct, 1, 100 );
    MinEscapeCount = Clamp( MinEscapeCount, 1, 16 );
    GameDifficulty = 2;
}

function EndLogging(string Reason)
{
   if (GameplayEventsWriter != None)
   {
      GameplayEventsWriter.EndLogging();
   }

   Super.EndLogging(Reason);
}

function AddInactivePRI(PlayerReplicationInfo PRI, PlayerController PC)
{
    `log("Adding Inactive PRI");
    super.AddInactivePRI(PRI, PC);
}

static function bool UseLowGore(WorldInfo WI)
{
    return (Default.GoreLevel > 0) && (WI.NetMode != NM_DedicatedServer);
}

function float SpawnWait(AIController B)
{
    if ( B.PlayerReplicationInfo.bOutOfLives )
        return 999;
    if ( WorldInfo.NetMode == NM_Standalone )
    {
        if ( WantFastSpawnFor(B) )
            return 0;

        return (FMax(2,NumBots-4) * FRand());
    }
    return 0.5;
}
function bool WantFastSpawnFor(AIController B)
{
    return ( NumBots < 4 );
}

function PreBeginPlay()
{
    local UDKTeamPlayerStart P;
    local bool  blnHostageZoneFound;
    local int intHostagesToSpawn;
    ServerPlayerID = 0;
    Super.PreBeginPlay();
    //`Log("CriticalPointGame::PreBeginPlay :: Reset bAdminSetNextMap");
    bAdminSetNextMap = false;
    Spawn(class'webserver');  // Spawn the webserver class


    CreateTeam(0);
    CreateTeam(1);
    CreateTeam(2); //hostages

    foreach AllActors(class'CPHostageRescueZone', foundHostageZone)
    {
        `Log("Found a hostage rescue zone");
        blnHostageZoneFound= true;
        break; //only supporting one zone!
    }

    if(blnHostageZoneFound)
    {
        foreach WorldInfo.AllNavigationPoints(class'UDKTeamPlayerStart', P)
        {
            if(P.TeamNumber == 2)
                intHostagesToSpawn++;
        }

        foundHostageZone.NumToWin = intHostagesToSpawn;

        if(intHostagesToSpawn != 0)
            ServerAddHostages(intHostagesToSpawn);
    }
}

function ServerAddHostages(int numberToAdd)
{
    local CPHostage P;
    local CPGameReplicationInfo TAGRI;
    local int i, intNumberOfHostages;

    TAGRI = CPGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(TAGRI.PRIArray[i].Team.TeamIndex == 2)
            intNumberOfHostages++;
    }

    for (i = intNumberOfHostages ; i < numberToAdd ; i++)
    {
        if (i > 4 )
            break;

        P = Spawn(class'CPHostage');
        if(P != none)
        {
            P.PlayerReplicationInfo.Team = TAGRI.Teams[2];
            P.PlayerReplicationInfo.Team.TeamIndex = 2;
            P.PlayerReplicationInfo.PlayerName = CriticalPointGame(WorldInfo.Game).Hostages[i];
            P.PlayerReplicationInfo.bBot = true;
            CPPlayerReplicationInfo(P.PlayerReplicationInfo).ClanTag = "ImAHostage";
            RestartPlayer(P);
        }
    }
}


// ~Drakk : added this to handle mapcycle reset upon startup
event InitGame(string Options,out string ErrorMessage)
{
    local int i;

    SrvGeoLocation = Spawn(class'CPGeoLocation'); // Spawn our geo location class

    reverbHackHelper=new class'CPReverbVolumeHackHelper';
    reverbHackHelper.Init(WorldInfo);

    super.InitGame(Options,ErrorMessage);

    //BroadcastHandler = spawn(BroadcastHandlerClass);

    if (WorldInfo.TimeSeconds==0.0)     // reset map cycle if we're just starting up
    {
        MapCycleIndex=INDEX_NONE;
        SaveConfig();
    }

    // make sure no bots got saved in the .ini as in use
    for (i = 0; i < ActiveBots.length; i++)
    {
        ActiveBots[i].bInUse = false;
    }
    Super.InitGame(Options, ErrorMessage);

    SetGameSpeed(GameSpeed);
    MaxLives = Max(0,GetIntOption( Options, "MaxLives", MaxLives ));
    RoundDurationInMinutes = Max(0,GetIntOption( Options, "RoundDurationInMinutes", RoundDurationInMinutes ));
    RoundStartDelay = Max(0,GetIntOption( Options, "RoundStartDelay", RoundStartDelay ));
    NumBots = Max(0,GetIntOption( Options, "NumBots", NumBots ));

    // Boolean Configuration settings are wiped out if no option is defined in the command line...
    if(HasOption( Options, "bIsFFenabled")){
        bFFenabled = Bool(ParseOption( Options, "bIsFFenabled"));
    }
    if(HasOption(Options, "bNadeFFenabled")){
        bNadeFFenabled = Bool(ParseOption( Options, "bNadeFFenabled"));
    }
    if(HasOption(Options, "bTeamsAreForced")){
        bForceTeams = Bool(ParseOption( Options, "bTeamsAreForced"));
    }

    if(HasOption(Options, "bAllowBehindView")){
        bAllowBehindView = Bool(ParseOption( Options, "bAllowBehindView"));
    }

    FriendlyFirePercentage = FMax(0,GetIntOption( Options, "FFPercentage", FriendlyFirePercentage ));
    NadeFriendlyFirePercentage = FMax(0,GetIntOption( Options, "NadeFFPercentage", NadeFriendlyFirePercentage ));

    switch(ParseOption( Options, "SpectatorMode"))
    {
        case "ALL":
            Spectating = SpectateView_All;
            break;
        case "TEAM":
            Spectating = SpectateView_TeamOnly;
            break;
        case "NONE":
            Spectating = SpectateView_None;
            break;
        default:
            Spectating = SpectateView_TeamOnly;
    }

    //if( DefaultMaxLives > 0 )
    //{
    //  TimeLimit = 0;
    //}

    bAutoNumBots = (WorldInfo.NetMode == NM_Standalone);
    DesiredPlayerCount = bAutoNumBots ? LevelRecommendedPlayers() : Clamp(GetIntOption( Options, "NumPlay", 1 ),1,32);

    //bShouldWaitForNetPlayers = false;//bWaitForNetPlayers && (WorldInfo.NetMode != NM_StandAlone);

    // Quick start the match if passed in as option or automated testing
//  bQuickStart = bQuickStart || IsAutomatedPerfTesting();
    GameDifficulty = 4;
    AdjustedDifficulty = GameDifficulty;

    if (WorldInfo.Game.AccessControl != none)
    {
        //lets clean out any vote bans!.
        CPAccessControl(WorldInfo.Game.AccessControl ).CleanUpVotes();
    }
	
	OutPutConfigVars();
}

function CreateTeam(int TeamIndex)
{
    Teams[TeamIndex] = spawn(class'CriticalPoint.CPTeamInfo');
    Teams[TeamIndex].Initialize(TeamIndex);
    GameReplicationInfo.SetTeam(TeamIndex,Teams[TeamIndex]);
}

function InitGameReplicationInfo()
{
    local CPGameReplicationInfo CPGRI;

    super.InitGameReplicationInfo();

    CPGRI = CPGameReplicationInfo(GameReplicationInfo);

    // Rogue. This function is called after every round. Do not reset
    // remaining time if match is in progress.
    if(!GameReplicationInfo.bMatchHasBegun)
    {
        GameReplicationInfo.RemainingTime = TimeLimit * 60;
        if (WorldInfo.NetMode!=NM_Client)
            CPGRI.EndMapTime = WorldInfo.TimeSeconds + (TimeLimit * 60);
    }
    GameReplicationInfo.TimeLimit = TimeLimit;
    CPGRI.MaxPlayers = MaxPlayers;
    CPGRI.RoundDurationInMinutes = RoundDurationInMinutes;
    CPGRI.RoundStartDelay = RoundStartDelay;
    CPGRI.RoundEndDelay = RoundEndDelay;
    CPGRI.GameRestartWait = GameRestartWait;
    CPGRI.MinimumPlayers = MinimumPlayers;
    CPGRI.GameStartDelay = GameStartDelay;
    CPGRI.MaxWaitOnTraveling = MaxWaitOnTraveling;
    CPGRI.FFPercentage = FriendlyFirePercentage;
    CPGRI.NadeFFPercentage = NadeFriendlyFirePercentage;
    CPGRI.bIsFFenabled = bFFenabled;
    CPGRI.bNadeFFenabled = bNadeFFenabled;
    CPGRI.MaxTeamKills = MaxTeamKills;

    CPGRI.bTeamsAreForced = bForceTeams;

    CPGRI.Spectating = Spectating;

    `Log("CriticalPointGame::InitGameReplicationInfo Current Spectating setting ="@CPGRI.Spectating);

    //CPGameReplicationInfo(GameReplicationInfo).Spectating = Spectating;
}

function RestartPlayer(Controller NewPlayer)
{
    local NavigationPoint startSpot;
    local int TeamNum,Idx;
    local array<SequenceObject> Events;
    local SeqEvent_PlayerSpawned SpawnedEvent;
    local CPGameReplicationInfo TAGRI;
    local bool bCreatedNewPawn;
    local bool bEscapedRepossess;
    local CPPlayerController tapc;

    if (NewPlayer==none || NewPlayer.PlayerReplicationInfo==none || NewPlayer.PlayerReplicationInfo.Team==none)
        return;

    if (NewPlayer.PlayerReplicationInfo.bOutOfLives)
    {
        //`Log("ERROR: trying to restart player ["$NewPlayer.PlayerReplicationInfo.PlayerName$"] who is out of lives");
        if (!NewPlayer.IsInState('Spectating'))
            NewPlayer.GoToState('Spectating');
        return;
    }

    TAGRI=CPGameReplicationInfo(GameReplicationInfo);
    //`Log("RoundInProgress:"@RoundIsInProgress()@",bRoundIsOver:"@TAGRI.bRoundIsOver@", bRoundHasBegun:"@TAGRI.bRoundHasBegun@", bDamageTaken:"@TAGRI.bDamageTaken);

    if (!
         (
           (
             (RoundIsInProgress() || TAGRI.IsRoundPreparation() || IsInState('RoundPreparation')) &&
              !TAGRI.IsRoundRestarting() &&
              NewPlayer.PlayerReplicationInfo.Team!=none &&
              !TAGRI.bDamageTaken
           )
           ||
           IsInState('WaitingForPlayers')
         )
       )
    {
        return;
    }

    if (bRestartLevel && WorldInfo.NetMode!=NM_DedicatedServer && WorldInfo.NetMode!=NM_ListenServer)
    {
        `warn("bRestartLevel && !server, abort from RestartPlayer"@WorldInfo.NetMode);
        return;
    }

    TeamNum = ((NewPlayer.PlayerReplicationInfo==none) || (NewPlayer.PlayerReplicationInfo.Team==none)) ? 255 : NewPlayer.PlayerReplicationInfo.Team.TeamIndex;
    startSpot = FindPlayerStart(NewPlayer,TeamNum);

    if (startSpot == none)
    {
        if (NewPlayer.StartSpot!=none)
        {
            StartSpot=NewPlayer.StartSpot;
            `warn("Player start not found, using last start spot");
        }
        else
        {
            //`warn("Player start not found, failed to restart player");
            return;
        }
    }

    bCreatedNewPawn=false;
    bEscapedRepossess=false;

    tapc = CPPlayerController(NewPlayer);
    if (tapc != None && CPPlayerReplicationInfo(tapc.PlayerReplicationInfo).bHasEscaped)
    {
        //Auth(tapc);

        if (tapc.EscapedPawn==none)
            `warn("unable to repossess escaped pawn for "$NewPlayer$", the pawn reference is empty");
        else
        {
            NewPlayer.Pawn = tapc.EscapedPawn;
            tapc.EscapedPawn = none;
            CPPlayerReplicationInfo(tapc.PlayerReplicationInfo).bHasEscaped = false;
            bEscapedRepossess = true;
        }
    }
   // else
      //  `warn("unnable to reposess escaped pawn because of unknown controller ["$NewPlayer$"]");

    if (NewPlayer.Pawn == none)
    {
        NewPlayer.Pawn = SpawnDefaultPawnFor(NewPlayer,StartSpot);
        bCreatedNewPawn = true;
    }

    if (NewPlayer.Pawn == none)
    {
        `log("failed to spawn player at "$StartSpot);
        NewPlayer.GotoState('Dead');
        if (PlayerController(NewPlayer) != none)
            PlayerController(NewPlayer).ClientGotoState('Dead','Begin');
    }
    else
    {
        if (tapc != none && tapc.PlayerReplicationInfo != none)
        {
            CPPlayerReplicationInfo(tapc.PlayerReplicationInfo).bDiffusedBomb = false;
            CPPlayerReplicationInfo(tapc.PlayerReplicationInfo).bPlantedBomb = false;
        }

        NewPlayer.Pawn.SetAnchor(startSpot);
        if (PlayerController(NewPlayer)!=none)
        {
            PlayerController(NewPlayer).TimeMargin=-0.1;
            startSpot.AnchoredPawn=none;
        }
        if (bEscapedRepossess)
        {
            NewPlayer.Pawn.SetCollision(NewPlayer.Pawn.default.bCollideActors,
                                        NewPlayer.Pawn.default.bBlockActors,
                                        NewPlayer.Pawn.default.bIgnoreEncroachers);
            NewPlayer.Pawn.SetHidden(false);
        }
        if (!bCreatedNewPawn)
        {
            NewPlayer.Pawn.SetLocation(startSpot.Location);
            NewPlayer.Pawn.SetRotation(startSpot.Rotation);
            NewPlayer.Pawn.Health=NewPlayer.Pawn.default.Health;
            NewPlayer.Pawn.bForceNetUpdate=true;
        }
        NewPlayer.Pawn.LastStartSpot=PlayerStart(startSpot);
        NewPlayer.Pawn.LastStartTime=WorldInfo.TimeSeconds;
        if (bCreatedNewPawn || bEscapedRepossess)
            NewPlayer.Possess(NewPlayer.Pawn,false);
        NewPlayer.ClientSetRotation(NewPlayer.Pawn.Rotation,true);
        if (CPPlayerController(NewPlayer)!=none)
            RestartCamperInfoFor(CPPlayerController(NewPlayer));
        if (!WorldInfo.bNoDefaultInventoryForPlayer && bCreatedNewPawn)
            AddDefaultInventory(NewPlayer.Pawn);
        SetPlayerDefaults(NewPlayer.Pawn);
        CPPawn(NewPlayer.Pawn).PostBigTeleport();            // ~Drakk : needed to because of the force update components call in it

        if(NewPlayer.PlayerReplicationInfo.bBot)
        {
            //CPBot(NewPlayer).StartBotBrain();
        }

        if (WorldInfo.GetGameSequence()!=none)
        {
            WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_PlayerSpawned',TRUE,Events);
            for (Idx=0;Idx<Events.Length;Idx++)
            {
                SpawnedEvent = SeqEvent_PlayerSpawned(Events[Idx]);
                if (SpawnedEvent!=none &&
                    SpawnedEvent.CheckActivate(NewPlayer,NewPlayer))
                {
                    SpawnedEvent.SpawnPoint=startSpot;
                    SpawnedEvent.PopulateLinkedVariableValues();
                }
            }
        }
    }
}

function class<Pawn> GetDefaultPlayerClass(Controller C)
{
    if (CPHostage(C) != None)
        return class'CPHostagePawn';
    else
        return DefaultPawnClass;
}

/**
* Returns the default pawn for a given controller. Since this occurs every time a pawn is spawned for a player (or should), we check here if we need to
* update the pc/pawn's character class (aka model).
*/
function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
    local CPPlayerController cppc;

    cppc = CPPlayerController(NewPlayer);

    //`log(">>>>>> SpawnDefaultPawnFor : " $ NewPlayer @ cppc @ CPPlayerReplicationInfo(cppc.PlayerReplicationInfo).PendingCharClass);
    if (cppc != None && CPPlayerReplicationInfo(cppc.PlayerReplicationInfo).PendingCharClass != None)
    {
        cppc.SetCharacterClass(CPPlayerReplicationInfo(cppc.PlayerReplicationInfo).PendingCharClass);
    }

    return super.SpawnDefaultPawnFor(NewPlayer, StartSpot);
}


/** FindPlayerStart()
* Return the 'best' player start for this player to start from.  PlayerStarts are rated by RatePlayerStart().
* @param Player is the controller for whom we are choosing a playerstart
* @param InTeam specifies the Player's team (if the player hasn't joined a team yet)
* @param IncomingName specifies the tag of a teleporter to use as the Playerstart
* @return NavigationPoint chosen as player start (usually a PlayerStart)
 */
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
    local NavigationPoint Best;

    // Save LastPlayerStartSpot for use in RatePlayerStart()
    if ( (Player != None) && (Player.StartSpot != None) )
    {
        LastPlayerStartSpot = Player.StartSpot;
    }

    Best = Super.FindPlayerStart(Player, InTeam, incomingName );

    // Save LastStartSpot for use in RatePlayerStart()
    if ( Best != None )
    {
        LastStartSpot = Best;
    }
    else
        return LastPlayerStartSpot;

    return Best;
}

/** RatePlayerStart()
* Return a score representing how desireable a playerstart is.
* @param P is the playerstart being rated
* @param Team is the team of the player choosing the playerstart
* @param Player is the controller choosing the playerstart
* @return playerstart score
*/
function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
    local float Score;
    local Controller OtherPlayer;

    // Primary starts are more desireable
    Score = P.bPrimaryStart ? 30 : 20;

    if ( (P == LastStartSpot) || (P == LastPlayerStartSpot) )
    {
        // avoid re-using starts
        Score -= 15.0;
    }

    if (Player != None)
    {
        ForEach WorldInfo.AllControllers(class'Controller', OtherPlayer)
        {
            if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
            {
                // check if playerstart overlaps this pawn
                if ( (Abs(P.Location.Z - OtherPlayer.Pawn.Location.Z) < P.CylinderComponent.CollisionHeight + OtherPlayer.Pawn.CylinderComponent.CollisionHeight)
                    && (VSize2D(P.Location - OtherPlayer.Pawn.Location) < P.CylinderComponent.CollisionRadius + OtherPlayer.Pawn.CylinderComponent.CollisionRadius) )
                {
                    // overlapping - would telefrag
                    return -10;
                }
            }
        }
    }

    // never use playerstarts not belonging to this team
    if ( UDKTeamPlayerStart(P) == None )
    {
        `warn(P$" is not a team playerstart!");
        return -9;
    }
    if ( Team != UDKTeamPlayerStart(P).TeamNumber )
        return -9;

    return FMax(Score, 0.2);
}

/** ChangeTeam()
* verify whether controller Other is allowed to change team, and if so change his team by calling SetTeam().
* @param Other:  the controller which wants to change teams
* @param num:  the teamindex of the desired team.
* @param bNewTeam:  if true, broadcast team change notification
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
    local CPTeamInfo NewTeam;

    //`Log("ChangeTeam:"@num);
    // don't add spectators to teams

     //@Wail - 12/09/13 - Ensure that when players switch to spectating / spectator team, their pawn is cleaned up
    if (Num == 255 && PlayerController(Other).Pawn != None)
       PlayerController(Other).CleanupPawn();


    //@Wail - 12/06/13 - Error checking
    //`log("Is Controller.PRI.bOnlySpectator true? " @ Other.PlayerReplicationInfo.bOnlySpectator);

    if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
    {
        Other.PlayerReplicationInfo.Team = None;
        //TOP-Proto Support spectators here.
        Other.GoToState('Spectating');

        return true;
    }

    NewTeam = (num < 2) ? Teams[PickTeam(num,Other)] : None;



    // check if already on this team
    if (Other.PlayerReplicationInfo.Team == NewTeam && Other.PlayerReplicationInfo.Team != none)
    {
        return false;
    }

    // set the new team for Other
    SetTeam(Other, NewTeam, bNewTeam);
	//set the model and skin when using the changeteam functionality.
	if(Other != none && Num != 255)
	{
		SetPlayerModelBasedOnTeam(Other.GetTeamNum(), Other);
	}

    //`Log("SetTeam:"@NewTeam);
    return true;
}

/** SetTeam()
* Change Other's team to NewTeam.
* @param Other:  the controller which wants to change teams
* @param NewTeam:  the desired team.
* @param bNewTeam:  if true, broadcast team change notification
*/
function SetTeam(Controller Other, CPTeamInfo NewTeam, bool bNewTeam)
{
    local Actor A;

    if ( Other.PlayerReplicationInfo == None )
    {
        return;
    }
    if (Other.PlayerReplicationInfo.Team != None || !ShouldSpawnAtStartSpot(Other))
    {
        // clear the StartSpot, which was a valid start for his old team
        Other.StartSpot = None;
    }

    // remove the controller from his old team
    if ( Other.PlayerReplicationInfo.Team != None )
    {
        Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
        Other.PlayerReplicationInfo.Team = none;
    }

    if ( NewTeam==None || (NewTeam!= none && NewTeam.AddToTeam(Other)) )
    {
        if ( (NewTeam!=None) && ((WorldInfo.NetMode != NM_Standalone) || (PlayerController(Other) == None) || (PlayerController(Other).Player != None)) )
            BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );
    }

    if ( (PlayerController(Other) != None) && (LocalPlayer(PlayerController(Other).Player) != None) )
    {
        // if local player, notify level actors
        ForEach AllActors(class'Actor', A)
        {
            A.NotifyLocalPlayerTeamReceived();
        }
    }
}

/** JoinTeamBalanced()
* Works out which team has the least players on and sets that as the team to join
*/
function byte JoinTeamBalanced()
{
    //`Log("Entering JoinTeamBalanced()");
    if (Teams[0].Size > Teams[1].Size)
    {
        return 1;
    }
    else if (Teams[0].Size == Teams[1].Size)
    {
        if (Teams[0].Score > Teams[1].Score)
        {
            return 1;
        }
        else if(Teams[0].Score == Teams[1].Score)
        {
            return Rand(2);
        }
    }

    return 0;
}

function byte PickTeam(byte num, Controller C)
{
    /// TODO: Implement team balancing.

    //local CPTeamInfo SmallTeam, BigTeam, NewTeam;

    //if (num < 2)
    //{
    //  NewTeam = Teams[num];

    //  if (bPlayersBalanceTeams)
    //  {
    //      SmallTeam = Teams[0];
    //      BigTeam = Teams[1];

    //      if ( SmallTeam.Size > BigTeam.Size )
    //      {
    //          SmallTeam = Teams[1];
    //          BigTeam = Teams[0];
    //      }

    //      NewTeam = SmallTeam;
    //  }

    //  return NewTeam.TeamIndex;
    //}

    return num;
}

function ScoreKill(Controller Killer, Controller Other)
{
    // Score awared in Active Round state and in no other.
    `warn("Can't score kill, no round currently active.");
}

function int LevelRecommendedPlayers()
{
    local CPMapInfo MapInfo;

    MapInfo = CPMapInfo(WorldInfo.GetMapInfo());
    return (MapInfo != None) ? Min(12, (MapInfo.RecommendedPlayersMax + MapInfo.RecommendedPlayersMin) / 2) : 1;
}

// `k = Owner's PlayerName (Killer)
// `o = Other's PlayerName (Victim)
static function string ParseKillMessage( string KillerName, string VictimName, string DeathMessage )
{
    return Repl(Repl(DeathMessage,"\`k",KillerName),"\`o",VictimName);
}


function EndRound(PlayerReplicationInfo Winner, string Reason)
{
    `warn("Can't endround, no round currently active.");
}

/** CanSpectate()
* Decides whether Viewer is allowed to spectate ViewTarget.
* Config:Spectating dictates who can be spectated.
* @param Viewer:  The spectating playercontroller
* @param ViewTarget:  ReplicationInfo of the desired target.
*/
function bool CanSpectate(PlayerController Viewer, PlayerReplicationInfo ViewTarget)
{
    if ( !ViewTarget.bIsSpectator && (ViewTarget.Team != none))
    {
        if ( Controller(ViewTarget.Owner).IsA('CPHostage') )
        {
            return False;
        }
        switch ( Spectating )
        {
            case SpectateView_All:
                return true;
            case SpectateView_TeamOnly:
                // Spectators can view anyone. Dead players can only view thier own team..
                if( (Viewer.PlayerReplicationInfo != none) &&
                     (
                       (Viewer.PlayerReplicationInfo.Team == None) ||
                       (Viewer.PlayerReplicationInfo.bOnlySpectator) ||
                       (Viewer.PlayerReplicationInfo.Team.TeamIndex == ViewTarget.Team.TeamIndex)
                     )
                  )
                    return true;
                return false;
            case SpectateView_None:
                // In game players can still spectate their own team....
                // SpectateView_None means that the server does not allow spectators into server....
                if( (Viewer.PlayerReplicationInfo != none) &&
                     (
                       (Viewer.PlayerReplicationInfo.Team != None) &&
                       (Viewer.PlayerReplicationInfo.Team.TeamIndex == ViewTarget.Team.TeamIndex)
                     )
                  )
                    return true;
                return false;
        }
    }

    return false;
}

function bool MatchIsInProgress()
{
    return false;
}

function bool RoundIsInProgress()
{
    return false;
}

function AnnounceBombTossed()
{
    HUDMessage(30);
}

function AnnounceBombBeingDefused()
{
    HUDMessage(34);
}

function AnnounceObjectiveBeingHacked()
{
    HUDMessage(35);
}

function AnnounceObjectiveBeingHackedBySpecialForces()
{
    HUDMessage(38);
}

function AnnounceObjectiveBeingHackedByMercenaries()
{
    HUDMessage(39);
}

function AnnounceBombPlanted()
{
    HUDMessage(31);
}

auto state PendingMatch
{
    // (UTGame) Override these 4 functions so that if we are in a warmup round, they get ignored.

    function CheckLives();
    function bool CheckMaxLives(PlayerReplicationInfo Scorer, bool leftTeam);
    function bool CheckScore(PlayerReplicationInfo Scorer);
    function ScoreKill(Controller Killer, Controller Other);

    function bool CheckStartMatch()
    {
        local int requiredPlayersPerTeam, numPlayersNotSpectating;

        numPlayersNotSpectating = Teams[0].Size + Teams[1].Size;

        //nobody has joined the game just yet
        if(numPlayersNotSpectating == 0)
        {
            //HUDMessage(0);
            return false;
        }

        // Start match if we're running a Standalone (singleplayer) game or if we have [MinimumPlayers] in either of the teams.
        if (WorldInfo.NetMode == NM_Standalone || numPlayersNotSpectating >= MinimumPlayers)
        {
            // Wait for players still loading the map.
            if (NumTravellingPlayers == 0 || WorldInfo.TimeSeconds > StartTime + MaxWaitOnTraveling)
            {
                requiredPlayersPerTeam = MinimumPlayers / 2;

                // Check team balance before starting the match, stay in warmup until teams have been divided equally.
                if (!bPlayersBalanceTeams || Teams[0].Size >= requiredPlayersPerTeam && Teams[1].Size >= requiredPlayersPerTeam)
                {
                    StartMatch();
                }
                return true;
            }
        }
        return false;
    }

    function BeginState(Name PreviousStateName)
    {

        StartTime = WorldInfo.TimeSeconds;
        //`Log("Entering PendingMatch");
        bWaitingToStartMatch = true;
    }

    function Timer()
    {
        //`Log("PendingMatch:: StartTime + WarmupDelay "$ StartTime + WarmupDelay);
        //`Log("PendingMatch:: WorldInfo.TimeSeconds "$ WorldInfo.TimeSeconds);
        local StringHolder oWarmupDelay;

        Global.Timer();

        oWarmupDelay = new(self) class'StringHolder';
        oWarmupDelay.str = string(int(StartTime + WarmupDelay - WorldInfo.TimeSeconds));

        if(int(StartTime + WarmupDelay - WorldInfo.TimeSeconds) >= 0)
            HUDMessage(5, oWarmupDelay);

        if (WorldInfo.TimeSeconds > StartTime + WarmupDelay)
        {
            if (!CheckStartMatch() && !IsInState('WaitingForPlayers'))
                GotoState('WaitingForPlayers');
        }
    }

    function EndState(Name NextStateName)
    {
        super.EndState(NextStateName);
        //`Log("Leaving PendingMatch");
    }
}

state WaitingForPlayers extends PendingMatch
{
    //fixes the double spawn bug
    function RestartPlayer(Controller NewPlayer);
    function bool CheckMaxLives(PlayerReplicationInfo Scorer, bool leftTeam);
    function BeginState(Name PreviousStateName)
    {
		local class<GameplayEventsWriter> GameplayEventsWriterClass;
        //local PlayerController P;
        `Log("Entering WaitingForPlayers");

		//Optionally setup the gameplay event logger
		if (bLogGameplayEvents && GameplayEventsWriterClassName != "")
		{
			GameplayEventsWriterClass = class<GameplayEventsWriter>(FindObject(GameplayEventsWriterClassName, class'Class'));
			if ( GameplayEventsWriterClass != None )
			{
				//dont record events from the main menu...
				`Log("mapurl" @ WorldInfo.Game.GetURLMap());
				if (WorldInfo.Game != none && WorldInfo.Game.GetURLMap() != "CPFrontEndMap")
				{
					`log("Recording game events with"@GameplayEventsWriterClass);
					GameplayEventsWriter = new(self) GameplayEventsWriterClass; 
					//Optionally begin logging here
					GameplayEventsWriter.StartLogging(0.5f);
				}
			}
			else
			{
				`log("Unable to record game events with"@GameplayEventsWriterClassName);
			}
		}
		else
		{
			`log("Gameplay events will not be recorded.");
		}
        bWarmupRound = true;

        CPGameReplicationInfo(GameReplicationInfo).bCanPlayersMove = true;

        if(bForceTeams == true)
            CPGameReplicationInfo(GameReplicationInfo).bTeamsAreForced = true;
        else
            CPGameReplicationInfo(GameReplicationInfo).bTeamsAreForced = false;
    }

    function EndState(Name PreviousStateName)
    {
        bWarmupRound = false;
        CPGameReplicationInfo(GameReplicationInfo).bCanPlayersMove = false;
    }
}

function StartMatch()
{
    if ( CheckForSentinelRun() )
    {
        return;
    }

    GotoState('MatchInProgress');

    GameReplicationInfo.RemainingMinute = GameReplicationInfo.RemainingTime;
    Super.StartMatch();

    `log("START MATCH");
    SendServerLogMessageToClient("START MATCH");
    `Log("Spectating ruleset:"@Spectating);
}

/** ExecuteSwapTeams()
* Swaps everyone to opposing team.
* 
*/
function ExecuteSwapTeams()
{
    local CPPlayerController PC;

    if ((WorldInfo.NetMode != NM_Standalone))
    {
        //iterate through all of the controllers
        foreach WorldInfo.AllControllers(class'CPPlayerController', PC)
        {
			// Swap players if they are on a team currently
            if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
            {
				// Swap teams for each player.
                if ( PC.PlayerReplicationInfo.Team.TeamIndex == MercIndexId )
                {
					PC.ServerChangeTeam(SwatIndexId);
                }
                else if ( PC.PlayerReplicationInfo.Team.TeamIndex == SwatIndexId )
                {
					PC.ServerChangeTeam(MercIndexId);					
                }
				SetPlayerModelBasedOnTeam(PC.GetTeamNum(), PC);
            }
        }
    }
}

/** AdminBalanceTeams()
* Balances the current teams.
* Balances teams based on teams scores and current team sizes.
*/
function AdminBalanceTeams()
{
    local CPPlayerController PC;
    local int RedCount, BlueCount, MoveCount, i, j;
    local array<CPPlayerController> RedPlayers, BluePlayers;
    local int redTeamScore, blueTeamScore;
	local CPPlayerController TempPC;

    RedCount = 0;
    BlueCount = 0;
    if ((WorldInfo.NetMode != NM_Standalone) && (CPGameReplicationInfo(GameReplicationInfo).bDamageTaken == false))
    {
        //Count the number of players on each team.
        foreach WorldInfo.AllControllers(class'CPPlayerController', PC)
        {
            if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
            {
                if ( PC.PlayerReplicationInfo.Team.TeamIndex == MercIndexId )
                {
					RedPlayers[RedCount] = PC;
                    RedCount++;
                    redTeamScore = PC.PlayerReplicationInfo.Team.Score;
                }
                else if ( PC.PlayerReplicationInfo.Team.TeamIndex == SwatIndexId )
                {
					BluePlayers[BlueCount] = PC;
                    BlueCount++;
                    blueTeamScore = PC.PlayerReplicationInfo.Team.Score;
                }
            }
        }

		// Sort players by ID. Highest ID first since they should switch first because they have entered
		// the game the latest supposedly....
        for(j=1; j< RedPlayers.Length;j++)
        {
			TempPC = RedPlayers[j];
            for(i = j-1; (i >= 0) && (RedPlayers[i].PlayerReplicationInfo.PlayerID < TempPC.PlayerReplicationInfo.PlayerID); i--)
            {
				RedPlayers[i+1] = RedPlayers[i];
            }
			RedPlayers[i+1] = TempPC;
        }

		// Sort players by ID. Highest ID first since they should switch first because they have entered
		// the game the latest supposedly....
        for(j=1; j< BluePlayers.Length;j++)
        {
			TempPC = BluePlayers[j];
            for(i = j-1; (i >= 0) && (BluePlayers[i].PlayerReplicationInfo.PlayerID < TempPC.PlayerReplicationInfo.PlayerID); i--)
            {
				BluePlayers[i+1] = BluePlayers[i];
            }
			BluePlayers[i+1] = TempPC;
        }
		
        // Verify if one team has more players than the other team. Also don't bother with
        // a game that consists of only 1 player.
        if ( Abs(RedCount - BlueCount) > 0 && ((RedCount > 1) || (BlueCount > 1)))
        {
            // Check if Mercs have more players than SF.
            if ( RedCount > BlueCount )
            {
                // Determine number of players to move to blue team.
                MoveCount = (RedCount - BlueCount)/2;

                // If we have an odd number for teams then put more players
                // on the losing team if the score is great enough.
                if(((Abs(RedCount-BlueCount) % 2) != 0) && (redTeamScore > blueTeamScore))
                {
                    // Only switch odd player to the SF team if the score
                    // difference is greater four wins of greater.
                    if(redTeamScore >= (blueTeamScore+4))
                    {
                        MoveCount++;
                    }
                }

                // Move players. Maybe move players based on players scores as well?? Not sure
                // might cause frustration for players if they keep moving.....
                for ( i=0; i<MoveCount; i++ )
                {
					RedPlayers[i].ServerChangeTeam(1);
					SetPlayerModelBasedOnTeam(RedPlayers[i].GetTeamNum(), RedPlayers[i]);
                }
            }
            else
            {
                MoveCount = (BlueCount - RedCount)/2;

                // If we have an odd number for teams then put more players
                // on the losing team.
                if(((Abs(RedCount-BlueCount) % 2) != 0) && (blueTeamScore > redTeamScore))
                {
                    if(blueTeamScore >= (redTeamScore+4))
                    {
                        MoveCount++;
                    }
                }

                // Move players. Maybe move players based on players scores as well?? Not sure
                // might cause frustration for players if they keep moving.....
                for ( i=0; i<MoveCount; i++ )
                {
					BluePlayers[i].ServerChangeTeam(0);
                    SetPlayerModelBasedOnTeam(BluePlayers[i].GetTeamNum(), BluePlayers[i]);
                }
            }
        }
		bPlayersBalanceTeamsCommandExecute = false;
    }
    else if((WorldInfo.NetMode != NM_Standalone) && (CPGameReplicationInfo(GameReplicationInfo).bDamageTaken == true))
    {
        //broadcast message "Admin has set teams to balance at the end of the round."
        bPlayersBalanceTeamsCommandExecute = true;
    }
}

state MatchInProgress
{
    function bool MatchIsInProgress()
    {
        return true;
    }

    function StartRound()
    {
        local CPGameReplicationInfo GRI;
		local CPPlayerController CPC;
		local array<PlayerReplicationInfo> CPPRIs;
        local CPTeamInfo TTeamInfo;
        local int i;

        // Do we have time to start a new round?
        //`log( "GameReplicationInfo.RemainingTime:" @ GameReplicationInfo.RemainingTime );
        GRI = CPGameReplicationInfo(GameReplicationInfo);

        if ( GameReplicationInfo.RemainingTime > 0 )
        {
            foreach DynamicActors(class'CPPlayerController', CPC)
			{
				if(CPC.PlayerReplicationInfo != None)
					CPPRIs.AddItem(CPC.PlayerReplicationInfo);
			}
			`if(`bPollRoundStartEvent)
				if(bEnableGamePlayerPoll)
					PollRoundStartEvent(CPPRIs, CurrentRound);
			`endif
			ResetLevel();

            // Rogue. Balance teams if balancing is enabled.
            if(bPlayersBalanceTeams || bPlayersBalanceTeamsCommandExecute)
            {
                bPlayersBalanceTeamsCommandExecute = false;
                AdminBalanceTeams();
            }

            if ( GRI != none && GRI.EscapeZone != none )
            {
                GRI.EscapeZone.TeamSize = 0;
                GRI.EscapeZone.NumToWin = 0;
                GRI.EscapeZone.NumEscaped = 0;

                for ( i = 0; i < GRI.Teams.Length; i++ )
                {
                    TTeamInfo = CPTeamInfo(GRI.Teams[i]);
                    if (TTeamInfo != None && TTeamInfo.TeamIndex==TTI_Mercenaries)
                    {
                        GRI.EscapeZone.TeamSize = TTeamInfo.Size;
                        GRI.EscapeZone.NumToWin = int( float( TTeamInfo.Size ) / EscapePct + 0.5f );
                        if ( GRI.EscapeZone.NumToWin < MinEscapeCount )
                            GRI.EscapeZone.NumToWin = MinEscapeCount;

                        //`log( "CriticalPointGame::MIP::StartRound:"@GRI.EscapeZone.TeamSize@"-"@GRI.EscapeZone.NumToWin );
                    }
                }
            }

            if ( !IsInState( 'RoundInProgress' ) )
            {
                PushState( 'RoundInProgress' );
            }
        }
        else
        {
            if ( GRI != none && GRI.EscapeZone != none )
            {
                GRI.EscapeZone.TeamSize = 0;
                GRI.EscapeZone.NumToWin = 0;
                GRI.EscapeZone.NumEscaped = 0;
            }

            EndGame( none, "TimeLimit" );
        }
    }

    function Timer()
    {
        Global.Timer();

        /*if ( bOverTime )
        {
            EndGame(None,"TimeLimit");
        }
        else if ( TimeLimit > 0 )
        {
            GameReplicationInfo.bStopCountDown = false;
            if ( GameReplicationInfo.RemainingTime <= 0 )
            {
                EndGame(None,"TimeLimit");
            }
        }
        else if ( (MaxLives > 0) && (NumPlayers + NumBots != 1) )
        {
            CheckMaxLives(none);
        }*/
        //`Log("Match is in progress, RemainingTime:"@GameReplicationInfo.RemainingTime);
    }

    function BeginState(Name PreviousStateName)
    {
        local PlayerReplicationInfo PRI;

        `Log("Entering MatchInProgress");
        foreach DynamicActors(class'PlayerReplicationInfo', PRI)
        {
            PRI.StartTime = 0;
        }

        // Rogue. Moved the starting of the main clock to happen when the first buytime
        // ends.
        //GameReplicationInfo.bStopCountDown = false;
        //GameReplicationInfo.ElapsedTime = 0;
        bWaitingToStartMatch = false;

        StartRound();
    }

    function ContinuedState()
    {
        local CPPawn P;
        foreach WorldInfo.AllActors(class'CPPawn',P)
        {
            if(P.PlayerReplicationInfo == None || P.Health == 0)
            {
                P.Destroy();
            }
        }

        `Log("ContinuedState:MatchInProgress");
        if(NumPlayers > 0) 
        {
        	StartRound();
        }
    }
}

// (UTGame) check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer, bool leftTeam)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local int numberOfPlayers;
    local int numberOfLiveSfPlayers;
    local int numberOfDeadSfPlayers;
    //local int numberOfEscapedSfPlayers;
    local int numberOfLiveTerrPlayers;
    local int numberOfDeadTerrPlayers;
    //local int numberOfEscapedTerrPlayers;
    local int numberOfTerr;
    local int numberOfSf;
    `Log("Entering CheckMaxLives");

    if ( MaxLives > 0 )
    {
        // Check if scorer is dead... suicide and killing self :O
        if ( (Scorer != none)
            && !Scorer.bOutOfLives
            && !Scorer.bOnlySpectator
            && !Scorer.bIsSpectator
            && !(CPPlayerReplicationInfo(Scorer).bHasEscaped)
            && (Scorer.Team != None)
            && (Scorer.Team.TeamIndex != HostageIndexId) )
        {
            Living = Scorer;
        }
        else
        {
            Living = none;
        }

        numberOfPlayers = 0;
        numberOfLiveSfPlayers = 0;
        numberOfDeadSfPlayers = 0;
        numberOfLiveTerrPlayers = 0;
        numberOfDeadTerrPlayers = 0;
        numberOfTerr = 0;
        numberOfSf = 0;
        foreach WorldInfo.AllControllers(class'Controller', C)
        {
            // This counts all live players and checks for two live
            // players on opposite teams.
            if ( (C.PlayerReplicationInfo != None)
               && C.bIsPlayer
               && !C.PlayerReplicationInfo.bOutOfLives
               && !C.PlayerReplicationInfo.bOnlySpectator
               && !C.PlayerReplicationInfo.bIsSpectator
               && !CPPlayerReplicationInfo(C.PlayerReplicationInfo).bHasEscaped
               && (C.PlayerReplicationInfo.Team != None)
               && (C.PlayerReplicationInfo.Team.TeamIndex != HostageIndexId) )
            {
                if(C.PlayerReplicationInfo.Team.TeamIndex == SwatIndexId)
                {
                    numberOfLiveSfPlayers++;
                }
                else if(C.PlayerReplicationInfo.Team.TeamIndex == MercIndexId)
                {
                    numberOfLiveTerrPlayers++;
                }
                numberOfPlayers++;
                // Get a living player if the scorer is dead. This is so we
                // can use the first living player to compare to the second living player if
                // there is one.
                if ( Living == None )
                {
                    Living = C.PlayerReplicationInfo;
                }
                // If we can already see a live player on both teams then don't end round.
                else if ( (C.PlayerReplicationInfo != Living) &&
                          (C.PlayerReplicationInfo.Team != Living.Team) )
                {
                    `Log("In CheckMaxLives seems we have one of each team alive still");
                    return false;
                }
            }
            // Count all dead players
            else if( (C.PlayerReplicationInfo != None)
                && C.bIsPlayer
                && !C.PlayerReplicationInfo.bOnlySpectator
                //&& (C.PlayerReplicationInfo.bIsSpectator || C.PlayerReplicationInfo.bOutOfLives)
                && (C.PlayerReplicationInfo.Team != None)
                && (C.PlayerReplicationInfo.Team.TeamIndex != HostageIndexId) )
            {
                if(C.PlayerReplicationInfo.Team.TeamIndex == SwatIndexId)
                {
                    numberOfDeadSfPlayers++;
                    //if(CPPlayerReplicationInfo(C.PlayerReplicationInfo).bHasEscaped)
                    //  numberOfEscapedSfPlayers++;
                }
                else if(C.PlayerReplicationInfo.Team.TeamIndex == MercIndexId)
                {
                    numberOfDeadTerrPlayers++;
                    //if(CPPlayerReplicationInfo(C.PlayerReplicationInfo).bHasEscaped)
                    //  numberOfEscapedTerrPlayers++;

                }
                numberOfPlayers++;
            }
        }
        numberOfTerr = numberOfLiveTerrPlayers + numberOfDeadTerrPlayers;
        numberOfSf = numberOfLiveSfPlayers + numberOfDeadSfPlayers;
        // -Before ending the round make sure that no live players are left except
        // for maybe the last scorer.
        // -Also make sure that all players are not on the same team. Round won't end if
        // everyone is on the same team until every player is dead.
        // If all players are on the same team then do not end round unless someone was
        // changing teams causing himself to die.
        if (numberOfLiveSfPlayers == 0 || numberOfLiveTerrPlayers == 0)
        {
            if ((numberOfPlayers == numberOfSf) && (numberOfLiveSfPlayers > 0) && (leftTeam == false))
            {
                `Log("CheckMaxLives seems all on same team. numberOfSf ="$numberOfSf@"numberOfLiveSf ="$numberofLiveSfPlayers);
                return false;
            }
            else if ((numberOfPlayers == numberOfTerr) && (numberOfLiveTerrPlayers > 0) && (leftTeam == false))
            {
                `Log("CheckMaxLives seems all on same team. numberOfTerr ="$numberOfTerr@"numberOfLiveTerr ="$numberofLiveTerrPlayers);
                return false;
            }
            else
            {
                `Log("CheckMaxLives.... game should end here");
                if ( Living != None )
                    EndRound(Living,"OppositionTerminated");
                // If there are no living and only one player in server then the last
                 // player standing must have suicided.
                else if( Living == None && numberOfPlayers < 2)
                    EndRound(Scorer,"LASTPLAYERSUICIDELOSS");
                // Cover the case of both players dying at same time??
                else
                    EndRound(Scorer,"LASTPLAYERSUICIDELOSS");

                return true;
            }
        }
    }
    return false;
}

state RoundInProgress extends MatchInProgress
{
    function ResetRound(CPGameReplicationInfo TAGRI)
    {
        local Controller P;
        local Actor A;

        bBombGiven = false;
        bLastSwat = false;
        bLastMerc = false;
        TAGRI.RemainingRoundTime = RoundDurationInMinutes * 60;
        TAGRI.EndRoundTime = WorldInfo.TimeSeconds + RoundDurationInMinutes * 60;
        TAGRI.bBombPlanted = false; //resetting the bomb as round is reset.
        TAGRI.bBombBeingDiffused = false;
        TAGRI.RemainingBombDetonatonTime = TAGRI.default.RemainingBombDetonatonTime; //resetting the bomb as round is reset.
        TAGRI.RemainingBombDiffuseTime = TAGRI.default.RemainingBombDiffuseTime; //resetting the bomb as round is reset.
        // Reset Damage taken.
        TAGRI.bDamageTaken = false;

        foreach WorldInfo.AllActors(class'Actor' , A)
        {
            if(A.IsA('CPDroppedBomb'))
            {
                CPDroppedBomb(A).GotoState( 'Pickup' );
            }
            else if(A.IsA('CPBreakingGlassActor'))
                A.Reset();
            else if(A.IsA('DroppedMoneyItem'))
                A.Destroy();
        }

        foreach WorldInfo.AllControllers(class'Controller', P)
        {
			if(!CPPlayerReplicationInfo(P.PlayerReplicationInfo).bOnlySpectator)
			{
				P.PlayerReplicationInfo.NumLives = 0;
				P.PlayerReplicationInfo.bOutOfLives = false;

				if (CPPlayerReplicationInfo(P.PlayerReplicationInfo) != none)
					CPPlayerReplicationInfo(P.PlayerReplicationInfo).bHasEscaped = false;

				if (CPPlayerController(P) != none) //would be for bots
				{
					if ( CPPawn( P.Pawn ) != none )
						CPPawn( P.Pawn ).bIsUsingObjective = false;
					CPPlayerController(P).ClientResetEffectsAndDecals();
					CPPlayerController(P).ResetScopeSettings();
				}
				
				//fix here to make sure the players skin is correct when the new round restarts - this is for when you swap teams.
				if ( CPPawn( P.Pawn ) != none )
				{
					if(CPPawn( P.Pawn ).Controller != none)
					{
						SetPlayerModelBasedOnTeam(CPPawn( P.Pawn ).Controller.GetTeamNum(), P);
					}
				}

				if (CPPlayerController(P) != none && CPPlayerController(P).Pawn != none && CPPlayerController(P).Pawn.Weapon != none)
				{
					CPWeapon(CPPlayerController(P).Pawn.Weapon).Reset();

				}
				RestartPlayer(P);
			}
        }

		// Set Spectator view to appropriate player. Either current player that he was
		// spectating or to next available player.
		foreach WorldInfo.AllControllers(class'Controller', P)
        {
			if(CPPlayerReplicationInfo(P.PlayerReplicationInfo).bOnlySpectator)
			{
				if(CPPlayerController(P).ViewTarget == none)
			    {
					CPPlayerController(P).ServerViewNextPlayer();
			    }
				else
				{
					CPPlayerController(P).ViewPlayerID(CPPawn(CPPlayerController(P).ViewTarget).PlayerReplicationInfo.PlayerID);

					// If we couldn't view the player request then move to next available player.
					if(CPPlayerController(P).ViewTarget == none)
					{
						CPPlayerController(P).ServerViewNextPlayer();
					}
				}
			}
        }

        UpdateAdvertisementForPlayerInfo();
        AdvertiseGameSettings();
    }

    function bool CheckEndRound(PlayerReplicationInfo PRI)
    {
        return CheckMaxLives(PRI, false);
    }

    function EndRound(PlayerReplicationInfo Winner, string Reason)
    {
        local TeamInfo TI;
        local stringholder strReason;
        local CPGameReplicationInfo TAGRI;

        TAGRI = CPGameReplicationInfo(GameReplicationInfo);

        strReason = new(self) class'StringHolder';
		if(Winner != None && Winner.Team != None)
			WinningTeamIndex = Winner.Team.TeamIndex;
		else
			WinningTeamIndex = -1;

        // Reset Damage taken on an endround.
        if(TAGRI != none)
        {
            TAGRI.bDamageTaken = false;

            if (TAGRI.EscapeZone != none )
            {
                TAGRI.EscapeZone.TeamSize = 0;
                TAGRI.EscapeZone.NumToWin = 0;
                TAGRI.EscapeZone.NumEscaped = 0;
            }
        }

        if (Reason == "Mercenaries have escaped!")
        {
            AwardMoney(1500,0, Reason); //money for winners
            TrackLooserMoneyBonus(1);
            //AwardScoreEvenIfDead(500.0/10.0,0); //for winning the round
            //AwardScoreEvenIfDead(200.0/10.0,1); //for loosing the round
            AwardScoreIfAlive(250.0/10.0,0); //anyone that was alive give them a bonus 250 points
        }

        if (Reason == "Hostages have escaped!")
        {
            Teams[TTI_SpecialForces].Score += 1;
            //todo check these amounts and scores.
            AwardMoney(1500,1, Reason); //money for winners
            TrackLooserMoneyBonus(0);
            //AwardScoreEvenIfDead(500.0/10.0,1); //for winning the round
            //AwardScoreEvenIfDead(200.0/10.0,0); //for loosing the round
            AwardScoreIfAlive(250.0/10.0,1); //anyone that was alive give them a bonus 250 points
            PushState('RoundRestarting');
            return;
        }

        if (Reason == "OppositionTerminated")
        {
            //AwardScoreEvenIfDead(500.0/10.0,Winner.Team.TeamIndex); //for winning the round

            AwardMoney(1500,Winner.Team.TeamIndex, Reason); //money for winners

            if(Winner.Team.TeamIndex == 0)
            {
                TrackLooserMoneyBonus(1);
                //AwardScoreEvenIfDead(200.0/10.0,1); //for loosing the round
            }
            else
            {
                TrackLooserMoneyBonus(0);
                //AwardScoreEvenIfDead(200.0/10.0,0); //for loosing the round
            }
        }

        if (Reason == "Special Forces have hacked the objective!")
        {
            AwardMoney(1500,1, Reason); //money for winners
            TrackLooserMoneyBonus(0);

            Teams[Winner.Team.TeamIndex].Score += 1;
            //AwardScoreEvenIfDead(500.0/10.0,1); //for winning the round
            //AwardScoreEvenIfDead(200.0/10.0,0); //for loosing the round
            AwardScoreIfAlive(150.0/10.0,1); //anyone that was alive give them a bonus 150 points
            //Award for the hacker
            Winner.Score += 250.0/10.0;
            CPPlayerReplicationInfo(Winner).ModifyMoney(300);
            AwardMoneyIfAlive(100,1, Reason);
            PushState('RoundRestarting');
            return;
        }

        if (Reason == "BombDetonated")
        {
            AwardMoney(1500,0, Reason); //money for winners
            AwardDetonationScore(25.0,0); // add to score of planting player
            TrackLooserMoneyBonus(1); //money for loosers
            HUDMessage(32); //mercs win
            //add point to mercs
            Teams[TTI_Mercenaries].Score += 1;
            //AwardScoreEvenIfDead(500.0/10.0,0); //for winning the round
            //AwardScoreEvenIfDead(200.0/10.0,1); //for loosing the round
            PushState('RoundRestarting');
            return;
        }

        //before we end round lets check to see if the bomb has been planted... if it has it MUST either detonate or be diffused unless all SWAT die.
        if (AreAnySwatAlive() && TAGRI.bBombPlanted && (Reason != "BombDiffused"))
        {
            `Log("AreAnySwatAlive() " @ AreAnySwatAlive());
            `Log("TAGRI.bBombPlanted " @ TAGRI.bBombPlanted);
            `Log("Reason " @ Reason);
            SendServerLogMessageToClient("Reason " @ Reason);
            return;
        }

        if(Reason == "BombDiffused")
        {
            AwardMoney(1500,1, Reason); //money for winners
            AwardDeffusingScore(25.0,1); // Add to score of deffusing player
            TrackLooserMoneyBonus(0);

            HUDMessage(33); //swat win
            //add point to swat
            Teams[1].Score += 1;
            //AwardScoreEvenIfDead(500.0/10.0,1); //for winning the round
            //AwardScoreEvenIfDead(200.0/10.0,0); //for loosing the round
            PushState('RoundRestarting');
            return;
        }

        if (Reason == "ADMINENDROUND")
        {
            `if(`bPollObectiveEvent)
				if(bEnableGamePlayerPoll)
					PollObjectiveEvent(WorldInfo.TimeSeconds, GetObjectiveByEnum(Reason));
			`endif
			PushState('RoundRestarting');
            return;
        }

        if (Winner == none)
        {
            // TODO Determine winner if one wasn't specified (like if the time runs out + one of the places I want to make objectives hook).
        }

        if ((Winner != none) && (Reason != "LASTPLAYERSUICIDELOSS"))
        {
            Winner.Team.Score = Winner.Team.Score += 1;
            Winner.Team.bForceNetUpdate = true;
            `Log("EndRound:\""@Reason$"\", winning team:"@Winner.Team.GetHumanReadableName());
            //HUDMessage("EndRound:\""@Reason$"\", winning team:"@Winner.Team.GetHumanReadableName());
            strReason.str = Reason;
            //HUDMessage(6,strReason, Winner);
            if(Winner.Team.TeamIndex == 0)
            {
                HUDMessage(36,strReason, Winner);
            }
            else
            {
                HUDMessage(37,strReason, Winner);
            }
        }
        // Update score for a loss caused by a suicide
        else if ((Winner != none) && (Reason == "LASTPLAYERSUICIDELOSS"))
        {
                `if(`bPollObectiveEvent)
					if(bEnableGamePlayerPoll)
						PollObjectiveEvent(WorldInfo.TimeSeconds, GetObjectiveByEnum(Reason));
				`endif
				// Find the other team opposite of the suicide player
                foreach DynamicActors(class'TeamInfo', TI)
                {
                    if (TI != none)
                    {
                        if(Winner.Team.TeamIndex != TI.TeamIndex)
                        {
                            TI.Score = TI.Score += 1;
                            //AwardScoreEvenIfDead(500.0/10.0,1); //for winning the round
                            //AwardScoreEvenIfDead(200.0/10.0,0); //for loosing the round
                            TI.bForceNetUpdate = true;
                            `Log("EndRound:\""@Reason$"\", winning team:"@TI.GetHumanReadableName());
                            //HUDMessage("EndRound:\""@Reason$"\", losing team:"@Winner.Team.GetHumanReadableName());

                            if(Winner.Team.TeamIndex == 0)
                            {
                                //HUDMessage(37,strReason, Winner);
                                HUDMessage(23,strReason, Winner);
                            }
                            else
                            {
                                //HUDMessage(36,strReason, Winner);
                                HUDMessage(24,strReason, Winner);
                            }
                            break;
                        }
                    }
                }

        }
        else
        {
            //TODO - check to see if a hostage died - whichever team killed the hostage looses.

            //this money is if the game is a draw.
            AwardMoney(1250,1, "Draw"); //money
            AwardMoney(1250,0, "Draw"); //money

            //AwardScoreEvenIfDead(350.0/10.0,1); //for winning the round
            //AwardScoreEvenIfDead(350.0/10.0,0); //for loosing the round
            //`warn("EndRound didn't find a winner.");
            HUDMessage(20);
        }

        PushState('RoundRestarting');
    }

    // This is called whenever damage occurs, so we can use it for the crosshair damage indicator.
    function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
    {
        local CPPlayerController CPPC;

        CPPC = CPPlayerController(instigatedBy);
        if (Damage > 0 && CPPC != None && injured.Controller != instigatedBy)
        {
           CPPC.NotifyEnemyHit();
        }
    }

    function ScoreKill(Controller Killer, Controller Other)
    {
        local PlayerReplicationInfo OtherPRI, KillerPRI;
        //local CPGameReplicationInfo GRI;

        // Deduct a life from the killed player.
        if (Other != None && Other.PlayerReplicationInfo != None)
        {
            OtherPRI = Other.PlayerReplicationInfo;
            OtherPRI.NumLives++;
            if ( (MaxLives > 0) && (OtherPRI.NumLives >=MaxLives) )
                OtherPRI.bOutOfLives = true;
        }

        // Give kill to appropriate player
        if( (Killer == Other) || (Killer == None) )
        {
            if ( (Other!=None) && (Other.PlayerReplicationInfo != None) )
            {
//              Other.PlayerReplicationInfo.Score -= 1;
                Other.PlayerReplicationInfo.bForceNetUpdate = TRUE;
                // Suicides should remove kills even if they are jumping from walls IMO.....
                //CPPlayerReplicationInfo(Other.PlayerReplicationInfo).CPKills--;
            }
        }
        else if ( Killer.PlayerReplicationInfo != None )
        {
            if(Other != none && (Other.PlayerReplicationInfo.Team.TeamIndex == 2))
            {
                //dont give or remove kills for killing hostages but still update the PRI
                Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;
            }
            else if( Other != none && (Other.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team) )
            {
//              Killer.PlayerReplicationInfo.Score -= 1;
                Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;
                CPPlayerReplicationInfo(Killer.PlayerReplicationInfo).CPKills--;

                //Add Team Kill Notes
                CPPlayerReplicationInfo(Killer.PlayerReplicationInfo).TeamKills++;
            }
            else
            {
//              Killer.PlayerReplicationInfo.Score += 1;
                Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;
                CPPlayerReplicationInfo(Killer.PlayerReplicationInfo).CPKills++;
            }
        }

        ModifyScoreKill(Killer, Other);

    // adjust bot skills to match player - only for DM, not team games
    //GRI = CPGameReplicationInfo(GameReplicationInfo);
    //if ( GRI.bStoryMode && !bTeamGame && (killer.IsA('PlayerController') || Other.IsA('PlayerController')) )
 //   {
    //  if ( killer.IsA('AIController') )
    //      AdjustSkill(AIController(killer), PlayerController(Other), false);
    //  if ( Other.IsA('AIController') )
    //      AdjustSkill(AIController(Other), PlayerController(Killer), true);
 //   }
        // Be sure to check if this kill means that one of the teams have been wiped out.
        if (Killer != None && Killer.PlayerReplicationInfo != None)
        {
            KillerPRI = Killer.PlayerReplicationInfo;
            CheckEndRound(KillerPRI);
        }
        else if (OtherPRI != none)
        {
            CheckEndRound(OtherPRI);
        }
        else
        {
            CheckEndRound(none);
        }
    }

    function bool RoundIsInProgress()
    {
        return true;
    }

    function PushedState()
    {
        local CPGameReplicationInfo TAGRI;
        TAGRI = CPGameReplicationInfo(GameReplicationInfo);

        `Log("Entering RoundInProgress");
        ResetPlayerInfos();

        TAGRI.bRoundIsOver = false;
        TAGRI.bRoundHasBegun = true;
        TAGRI.bCanPlayersMove = false;

        ResetRound(TAGRI);

        //`Log("Team 1 ("$TAGRI.Teams[0].GetHumanReadableName()$") score:"@int(TAGRI.Teams[0].Score)@", Team 2 ("$TAGRI.Teams[1].GetHumanReadableName()$") score:"@int(TAGRI.Teams[1].Score));
        SendServerLogMessageToClient("Team 1 ("$TAGRI.Teams[0].GetHumanReadableName()$") score:"@int(TAGRI.Teams[0].Score)@", Team 2 ("$TAGRI.Teams[1].GetHumanReadableName()$") score:"@int(TAGRI.Teams[1].Score));

        PushState('RoundPreparation');
    }
    function PoppedState()
    {
        `Log("Leaving RoundInProgress");
        ResetPlayerInfos();
    }

    function Timer()
    {
        local CPGameReplicationInfo TAGRI;

        TAGRI = CPGameReplicationInfo(GameReplicationInfo);

        Global.Timer();
        UpdateAdvertisementForPlayerInfo();
        GiveOnePlayerABomb();
        //`Log("Round is in progress, RemainingRoundTime:"@TAGRI.RemainingRoundTime@", RemainingTime:"@TAGRI.RemainingTime@",MatchIsInProgress():"@MatchIsInProgress());

        if( TAGRI.RemainingBombDiffuseTime <= 0.0 )
        {
            TAGRI.bBombPlanted = false; //stop the detonation timer now the bombs been diffused
            EndRound(none, "BombDiffused");
        }

        if( TAGRI.RemainingBombDetonatonTime <= 0.0 )
        {
            EndRound( none, "BombDetonated" );
        }

        if(TAGRI.RemainingTime == 0 && TAGRI.RemainingRoundTime > TAGRI.RemainingTime)
        {
            if(!blnFinalRoundHUDMsgPlayed)
            {
                HUDMessage(1); //this is the final round message and announcement
                blnFinalRoundHUDMsgPlayed = true;
            }
        }

        if(TAGRI.RemainingRoundTime == 30)
        {
            HUDMessage(15); //30 seconds of ROUND TIME remaining
        }

        if(TAGRI.RemainingRoundTime == 120)
        {
            HUDMessage(16); //2 minutes of ROUND TIME remaining
        }

        if (TAGRI.RemainingRoundTime == 0)
        {
            if(TAGRI.RemainingTime == 0)
            {
                GotoState('MatchOver');
            }
            else
            {
                EndRound(none, "RoundEnded");
            }
        }

        UpdatePlayerInfos();
        UpdateEscapeAmmounts();
        CountValidPlayers();
    }
    function ContinuedState()
    {
        local CPGameReplicationInfo TAGRI;
        TAGRI = CPGameReplicationInfo(GameReplicationInfo);

        if (TAGRI.bRoundHasBegun && !TAGRI.bRoundIsOver)
        {
            // RoundHasBegun is TRUE and RoundIsOver is FALSE when coming back from RoundPreparation, allow players to move now.
            TAGRI.bCanPlayersMove = true;
        }
        else if (TAGRI.bRoundHasBegun && TAGRI.bRoundIsOver)
        {
            // RoundHasBegun and RoundIsOver is TRUE when coming back from RoundRestarting, Pop RoundInProgress, going back to MatchInProgress.
            TAGRI.bRoundHasBegun = false;
            TAGRI.bRoundIsOver = false;
            PopState();
        }
    }
}

	function SetPlayerModelBasedOnTeam(byte team, Controller C)
	{
		//1. what team are you on?
		//2. are you male or female?

		if(C == none)
		{
			`Log("SetPlayerModelBasedOnTeam Controller is none!");
			return;
		}

		if(CPPlayerReplicationInfo(C.PlayerReplicationInfo) == none)
		{
			`Log("SetPlayerModelBasedOnTeam PlayerReplicationInfo is none!");
			return;
		}

		`Log("SetPlayerModelBasedOnTeam Team = " @ team);
		if(team == TTI_Mercenaries)
		{			
			if(CPPlayerReplicationInfo(C.PlayerReplicationInfo).bIsFemale)
			{
				`Log("SetPlayerModelBasedOnTeam Team = TTI_Mercenaries FEMALE");
				CPPlayerReplicationInfo(C.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_MERC_FemaleOne';
			}
			else
			{
				`Log("SetPlayerModelBasedOnTeam Team = TTI_Mercenaries MALE");
				CPPlayerReplicationInfo(C.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_MERC_MaleOne';
			}
		}
		else if(team == TTI_SpecialForces)
		{
			if(CPPlayerReplicationInfo(C.PlayerReplicationInfo).bIsFemale)
			{
				`Log("SetPlayerModelBasedOnTeam Team = TTI_SpecialForces FEMALE");
				CPPlayerReplicationInfo(C.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_SWAT_FemaleOne';
			}
			else
			{
				`Log("SetPlayerModelBasedOnTeam Team = TTI_SpecialForces MALE");
				CPPlayerReplicationInfo(C.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_SWAT_MaleOne';
			}
		}
		else if(team == 225 || team == TTI_Hostages || team == -1)
		{
			//TTI_Hostages
			`Log("SetPlayerModelBasedOnTeam Team = TTI_Hostages");
			CPPlayerReplicationInfo(C.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_HOST_MaleOne';
		}
		else
		{
			
			`Log("Unknown Team for byte " @ team);
		}
	}

/*
 *  Count how many players are in the server
*/
reliable server function int ServerPlayerCount()
{
    local CPPlayerController PC;
    local int PlayerCount;

    PlayerCount = 0;

    // Count the number of players
    foreach WorldInfo.AllControllers(class'CPPlayerController', PC)
    {
        if(PC != none)
        {
            if(PC.PlayerReplicationInfo != None)
            {
                PlayerCount++;
                if(PlayerCount > -1)
                {
                    return PlayerCount;
                }
            }
        }
    }

    return 0;
}



function UpdateEscapeAmmounts()
{
    local CPGameReplicationInfo GRI;
    local CPTeamInfo TTeamInfo;
    local int i;
    GRI = CPGameReplicationInfo(GameReplicationInfo);

    if ( GRI != none && GRI.EscapeZone != none && !GRI.bDamageTaken)
    {
        for ( i = 0; i < GRI.Teams.Length; i++ )
        {
            TTeamInfo = CPTeamInfo( GRI.Teams[i] );

            if (TTeamInfo != None && TTeamInfo.TeamIndex == TTI_Mercenaries)
            {
                GRI.EscapeZone.TeamSize = TTeamInfo.Size;
                GRI.EscapeZone.NumToWin = int( float( TTeamInfo.Size ) / EscapePct + 0.5f );
                if ( GRI.EscapeZone.NumToWin < MinEscapeCount )
                    GRI.EscapeZone.NumToWin = MinEscapeCount;

                //`log( "CriticalPointGame::MIP::StartRound:"@GRI.EscapeZone.TeamSize@"-"@GRI.EscapeZone.NumToWin );
            }
        }
    }
}

function bool AreAnySwatAlive()
{
    local int sfPlayers;
    local CPPlayerReplicationInfo PRI;
    local int i;
    local CPGameReplicationInfo TAGRI;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    sfPlayers = 0;

    if ( TAGRI == None )
    {
        return false;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        PRI = CPPlayerReplicationInfo(TAGRI.PRIArray[i]);
        if ( PRI == none || (!PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
        (PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None))) )
        {
        }
        else
        {
            if (PRI.Team != None && PRI.Team.TeamIndex == TTI_SpecialForces && !PRI.bOnlySpectator)
            {
                if (!PRI.bIsSpectator && !PRI.bOutOfLives)
                {
                    sfPlayers++;
                }
            }
        }
    }

    if (sfPlayers == 0)
        return false;

    return true;
}

//fix for crash when these are included in the state code
function CountValidPlayers()
{
    local int liveSfPlayers;
    local int liveTerrPlayers;
    local int deadTerrPlayers;
    local int deadSfPlayers;
    local CPPlayerReplicationInfo PRI;
    local CPPlayerReplicationInfo LastLiveSf;
    local CPPlayerReplicationInfo LastLiveTerr;
    local int i;
    local CPGameReplicationInfo TAGRI;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    liveSfPlayers = 0;
    liveTerrPlayers = 0;
    deadTerrPlayers = 0;
    deadSfPlayers = 0;

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        PRI = CPPlayerReplicationInfo(TAGRI.PRIArray[i]);
        if ( PRI == none || (!PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
            (PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None))) )
        {
        }
        else
        {
            if (PRI.Team != None && PRI.Team.TeamIndex == TTI_SpecialForces && !PRI.bOnlySpectator)
            {
                if (!PRI.bIsSpectator && !PRI.bHasEscaped && PRI.NumLives > 0)
                {
                    liveSfPlayers++;
                    LastLiveSf = PRI;
                }
                else
                {
                    deadSfPlayers++;
                }
            }
            else if(PRI.Team != None && PRI.Team.TeamIndex == TTI_Mercenaries && !PRI.bOnlySpectator)
            {
                if (!PRI.bIsSpectator && !PRI.bHasEscaped && PRI.NumLives > 0)
                {
                    liveTerrPlayers++;
                    LastLiveTerr = PRI;
                }
                else
                {
                    deadTerrPlayers++;
                }
            }
        }
    }

    if ((liveSfPlayers == 1) && (deadSfPlayers > 0))
    {
        if(liveTerrPlayers != 0)
        {
            if(!bLastSwat)
            {
                bLastSwat = true;
                //disabled as its firing when it shouldnt. needs fixing
                //rogue FIX ME please
                PlayLastAliveAnnouncement(LastLiveSf);
            }
        }
    }
    else if ((liveTerrPlayers == 1) && (deadTerrPlayers > 0))
    {
        if (liveSfPlayers != 0)
        {
            if(!bLastMerc)
            {
                bLastMerc = true;
                //disabled as its firing when it shouldnt. needs fixing
                PlayLastAliveAnnouncement(LastLiveTerr);
            }
        }
    }
}

function PlayLastAliveAnnouncement(PlayerReplicationInfo PRI1)
{
    `Log("PlayLastAliveAnnouncement PLAYING!");
    HUDPersonalizedMessage(19, PRI1);
}

simulated function AnnounceRoundRestartToPlayers()
{
    SendServerLogMessageToClient("Entering RoundPreparation (Round #" $ CurrentRound $ ")");
}

simulated function SendServerLogMessageToClient(string Message)
{
    local CPPlayerController P;

    foreach WorldInfo.AllControllers(class'CPPlayerController', P)
    {
        P.LogServerMessage(Message);
    }
}

state RoundPreparation extends MatchInProgress
{
    function bool CheckMaxLives(PlayerReplicationInfo Scorer, bool leftTeam);

    function PushedState()
    {
        CPGameReplicationInfo(GameReplicationInfo).RoundTimeBuffer = RoundStartDelay;

        `Log("Entering RoundPreparation (Round #" $ CurrentRound $ ")");

        if(WorldInfo.NetMode!=NM_Standalone)
            AnnounceRoundRestartToPlayers();

        CurrentRound++;
    }

    function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
    {
        local CPGameReplicationInfo CPGRI;

        Damage = 0;
        Momentum = vect(0,0,0);

        CPGRI = CPGameReplicationInfo(GameReplicationInfo);

        // Reset Damage taken on an endround.
        if (CPGRI != none)
        {
            CPGRI.bDamageTaken = false;

            if (CPGRI.EscapeZone != none)
            {
                CPGRI.EscapeZone.TeamSize = 0;
                CPGRI.EscapeZone.NumToWin = 0;
                CPGRI.EscapeZone.NumEscaped = 0;
            }
        }
    }

    simulated function Timer()
    {
        local CPGameReplicationInfo TAGRI;
        TAGRI = CPGameReplicationInfo(GameReplicationInfo);

        GiveOnePlayerABomb();
        Global.Timer();

        //`Log("Round Preparation, RoundTimeBuffer:"@TAGRI.RoundTimeBuffer);

        if (TAGRI.RoundTimeBuffer > 0)
        {
            if( TAGRI.RoundTimeBuffer == RoundStartDelay)
            {
                //`Log("RoundPreparation::Timer PREPARING TO START");
                HUDMessage(2); //preparing to start
            }
            else
            {
                if( TAGRI.RoundTimeBuffer < RoundStartDelay - 1)
                {
                    //`Log("RoundPreparation::Timer COUNTDOWN BEEPS");
                    HUDMessage(3, TAGRI);
                }
            }

            TAGRI.RoundTimeBuffer--;
        }
        else
        {
            //`Log("RoundPreparation::Timer GO GO GO");
            HUDMessage(4); //go go go
            PopState();
        }
    }
}

state RoundRestarting extends MatchInProgress
{
    
    simulated function PushedState()
    {
        blnFinalRoundHUDMsgPlayed = false;      //reset this so final round message can be played again if someone adds more time etc
        CPGameReplicationInfo(GameReplicationInfo).RoundTimeBuffer = RoundEndDelay;
    }
    function PoppedState()
    {
		`if(`bRunGamePlayerPoll)
			OutputPlayerEventPoll(CurrentRound-1, WinningTeamIndex);
		`endif
		`Log("Leaving RoundRestarting");
    }

    function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
    {
        local CPGameReplicationInfo CPGRI;

        Damage = 0;
        Momentum = vect(0,0,0);

        CPGRI = CPGameReplicationInfo(GameReplicationInfo);

        // Reset Damage taken on an endround.
        if (CPGRI != none)
        {
            CPGRI.bDamageTaken = false;

            if (CPGRI.EscapeZone != none)
            {
                CPGRI.EscapeZone.TeamSize = 0;
                CPGRI.EscapeZone.NumToWin = 0;
                CPGRI.EscapeZone.NumEscaped = 0;
            }
        }
    }

    function Timer()
    {
        local CPGameReplicationInfo TAGRI;
        TAGRI = CPGameReplicationInfo(GameReplicationInfo);

        Global.Timer();

        `Log("Round Restarting in " $ TAGRI.RoundTimeBuffer $ "..");

        TAGRI.bRoundIsOver = true;
        if (TAGRI.RoundTimeBuffer > 0)
        {
            TAGRI.RoundTimeBuffer--;
        }
        else
        {
            // Rogue. Balance teams if balancing is enabled.
            if(bPlayersBalanceTeams || bPlayersBalanceTeamsCommandExecute)
            {
                bPlayersBalanceTeamsCommandExecute = false;
                AdminBalanceTeams();
            }
            PopState();
        }
    }
}

function Killed(Controller Killer,Controller KilledPlayer,Pawn KilledPawn,class<DamageType> damageType )
{
	`RecordKillEvent(NORMAL, Killer, DamageType, KilledPlayer);
    if (Killer == none)
    {
        super.Killed(Killer,KilledPlayer,KilledPawn,damageType);
        return;
    }
    //@Wail - In some unusual circumstances we may kill a pawn that does not have a controller, failsafe check
    if (KilledPlayer == None)
    {
       //Super.Killed(Killer,KilledPlayer,KilledPawn,damageType);
       return;
    }

    if (Killer == KilledPlayer) //if you killed yourself
        Killer.PlayerReplicationInfo.Score -= 20;
    else if (CPHostage(KilledPlayer) != none) //hostage was killed
    {
        Killer.PlayerReplicationInfo.Score -= 20;
		CPPlayerReplicationInfo(Killer.PlayerReplicationInfo).ModifyMoney(HostageKillAmount);
    }
    else if (Killer.PlayerReplicationInfo.Team.TeamIndex == KilledPlayer.PlayerReplicationInfo.Team.TeamIndex) //was a team kill!!
    {
        Killer.PlayerReplicationInfo.Score -= 20;
		CPPlayerReplicationInfo(Killer.PlayerReplicationInfo).ModifyMoney(TeamKillAmount);
    }
    else
    {
        Killer.PlayerReplicationInfo.Score += 10;
		CPPlayerReplicationInfo(Killer.PlayerReplicationInfo).ModifyMoney(KillAmount);
    }

    if (CPPlayerController(KilledPlayer) != none)
        ResetCamperInfoFor(CPPlayerController(KilledPlayer));

    super.Killed(Killer,KilledPlayer,KilledPawn,damageType);
    AdvertiseGameSettings();
}

function EndGame( PlayerReplicationInfo Winner, string Reason )
{
    super.EndGame(Winner, Reason);
    GotoState('MatchOver');
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
    if (Killer == None)
    {
        BroadcastLocalized(self, class'CPMsg_HUDMessageCanvas', 10, none, Other.PlayerReplicationInfo, damageType);
        // Log kill death messages.
        `Log(class'CPMsg_HUDMessageCanvas'.static.GetString(10, false, none, Other.PlayerReplicationInfo, damageType));
    }
    else if (Killer == Other)
    {
        BroadcastLocalized(self, class'CPMsg_HUDMessageCanvas', 10, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
        // Log kill death messages.
        `Log(class'CPMsg_HUDMessageCanvas'.static.GetString(10, false, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType));
    }
    else
    {
        BroadcastLocalized(self, class'CPMsg_Death', 11, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
        // Log kill death messages.
        `Log(class'CPMsg_Death'.static.GetString(11, false, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType));
    }
}


/** map cycle functions */
/** @return the index of the current map in the mapclye list */
function int GetCurrentMapCycleIndex()
{
    return MapCycle.Find(string(WorldInfo.GetPackageName()));
}

/** @return name of the map that is about to be loaded */
function string GetNextMap()
{
    if (MapCycle.length==0)
    {
        `warn("unable to get next map, no mapcycle defined");
        return "";
    }
    if (MapCycleIndex==INDEX_NONE)
    {
        //`Log("MapCycle Reset!");
        MapCycleIndex = GetCurrentMapCycleIndex();
        if (MapCycleIndex == INDEX_NONE)
        {
            MapCycleIndex=MapCycle.length;
            `warn("Failed to find "$string(WorldInfo.GetPackageName())$" in mapcycle, next map will be the first one from the mapcycle list");
        }
    }
    MapCycleIndex=(MapCycleIndex+1<MapCycle.length) ? (MapCycleIndex+1) : 0;
    SaveConfig();


    if (bAdminSetNextMap)
    {
        //`Log("ADMIN SET NEXT MAP to " $ strAdminMapSelected);
        return strAdminMapSelected;
    }
    else
    {
        //`Log("Next map is "$MapCycle[MapCycleIndex]);
        return MapCycle[MapCycleIndex];
    }
}
/** map cycle functions */

state MatchOver
{
    function RestartPlayer(Controller aPlayer) {}
    function ScoreKill(Controller Killer, Controller Other) {}

    function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
    {
        Damage = 0;
        Momentum = vect(0,0,0);
    }

    function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
    {
        // (UTGame) we don't want newly joining players to get stuck as a spectator for the next match,
        // mark them as out of the game and pretend we succeeded
        Other.PlayerReplicationInfo.bOutOfLives = true;
        return true;
    }



    event PostLogin(PlayerController NewPlayer)
    {
        Global.PostLogin(NewPlayer);

        NewPlayer.GameHasEnded();
    }

    event Timer()
    {
        Global.Timer();

        if ( !bGameRestarted && (WorldInfo.TimeSeconds > EndTime + GameRestartWait) )
        {
            RestartGame();
        }
    }

    function bool NeedPlayers()
    {
        return false;
    }

    function BeginState(Name PreviousStateName)
    {
        local Pawn P;

        EndTime = WorldInfo.TimeSeconds;

        GameReplicationInfo.bStopCountDown = true;
        GameReplicationInfo.EndGame();
        foreach WorldInfo.AllPawns(class'Pawn', P)
        {
            P.TurnOff();
            P.SetHidden(true);
        }
    }

    function ResetLevel()
    {
        RestartGame();
    }
}

/** SetGameType(string MapName, string Options, string Portal)
* Overriden so we load into the menus if we load our menu map
*/
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    //`Log("Loading into map " $ MapName);
    if (Left(MapName, 13) ~= "TAFrontEndMap" )
    {
        //This is important to set correctly, because it actually defines the keybinds and the configuration set used!!
        return class'CPMenuGame';
    }

    return Default.Class;
}

/** HUDMessage(string text)
* Sends a message to all players whenever called. Check this for online games
*/
function HUDMessage(int MessageNumber, optional Object OptionalObject, optional PlayerReplicationInfo PRI1)
{
    local PlayerController P;

    foreach WorldInfo.AllControllers(class'PlayerController', P)
    {
        P.ReceiveLocalizedMessage( class'CPMsg_HUDMessageTopCenter', MessageNumber,PRI1,, OptionalObject);
    }
}

/** HUDMessage(string text)
* Sends a message to all players whenever called. Check this for online games
*/
function HUDPersonalizedMessage(int MessageNumber, PlayerReplicationInfo PRI1, optional Object OptionalObject)
{
    local Pawn P;

    foreach WorldInfo.AllPawns(class'Pawn', P)
    {
        if(P.PlayerReplicationInfo == PRI1)
        {
            if(PlayerController(P.Controller) != none)
                PlayerController(P.Controller).ReceiveLocalizedMessage( class'CPMsg_HUDMessageTopCenter', MessageNumber,PRI1,, OptionalObject);
        }
    }
}

/**  AddDefaultInventory( pawn PlayerPawn )
* Cut down version of the UT add default inventory.
* Everyone in TA starts with a pistol and a melee weapon so it makes sense to add this code back in
*/
function AddDefaultInventory(pawn PlayerPawn)
{
    local int i;

    if (PlayerPawn.PlayerReplicationInfo == none)
    {
        //`warn("unable to add default inventory to "$PlayerPawn$" there is no PlayerReplicationInfo!");
        return;
    }
    if (PlayerPawn.PlayerReplicationInfo.Team == none)
    {
        //`warn("unable to add default inventory to "$PlayerPawn$" there is no Team!");
        return;
    }
    if (PlayerPawn.PlayerReplicationInfo.Team.TeamIndex == TTI_Hostages)
        return; //hostage dont give them inventory.

    if (PlayerPawn.PlayerReplicationInfo.Team == Teams[0])
    {
        for (i=0;i<DefaultInventory.Length;i++)
            if (DefaultInventory[i].Team[0]!=none)
                if (PlayerPawn.FindInventoryType(DefaultInventory[i].Team[0])==none)
                    PlayerPawn.CreateInventory(DefaultInventory[i].Team[0],true);
    }
    else if (PlayerPawn.PlayerReplicationInfo.Team == Teams[1])
    {
        for (i=0;i<DefaultInventory.Length;i++)
            if (DefaultInventory[i].Team[1]!=none)
                if (PlayerPawn.FindInventoryType(DefaultInventory[i].Team[1])==none)
                    PlayerPawn.CreateInventory(DefaultInventory[i].Team[1],true);
    }
    else
    {
        //`warn("unable to add default inventory to "$PlayerPawn$" invalid team specified "$PlayerPawn.PlayerReplicationInfo.Team.TeamIndex);
        return;
    }

    PlayerPawn.AddDefaultInventory();
}

function GiveOnePlayerABomb()
{
    local PlayerController PC;
    Local Inventory Inv;
    local CPBombZone BZ;
    local int intPlayerCount;
    local int intSelectedPlayer, intCurrentPlayer;

    //if a bombzone exists in the level...
    foreach WorldInfo.AllActors(class'CPBombZone', BZ)
    {
        break; //only need to find one.
    }

    if (BZ == None) // No BombZone found
        return;

    if (bBombGiven)
        return;

    foreach WorldInfo.AllControllers(class'PlayerController', PC)
    {
        if (PC.PlayerReplicationInfo.Team == Teams[0]) //if we are merc...
        {
            //add up the players...
            intPlayerCount++;
        }

        //remove the bomb from everyone.
        if (PC.Pawn != none)
        {
            Inv = PC.Pawn.FindInventoryType(class'CPWeap_Bomb');
            if (Inv != none)
            {
                PC.Pawn.InvManager.RemoveFromInventory(Inv);
            }
        }
    }

    intSelectedPlayer = Rand(intPlayerCount);

    foreach WorldInfo.AllControllers(class'PlayerController', PC)
    {
        if (PC.PlayerReplicationInfo.Team == Teams[0]) //if we are merc...
        {
            if (IntCurrentPlayer == intSelectedPlayer)
            {
                if (PC.Pawn != none)
                {
                    if (PC.Pawn.FindInventoryType(class'CPWeap_Bomb') == none)
                    {
                        bBombGiven = true; //needed just in case bomb is not given at the start of the round.
                        PC.Pawn.CreateInventory(class'CPWeap_Bomb',true);
                    }
                    break;
                }
            }
            intCurrentPlayer++;
        }
    }

}

function reliable server ResetAndRestartLevel()
{
	// Set to to false since some of the resets act differently
	// based on this value.
	GameReplicationInfo.bMatchHasBegun = false;
	
	// Reset everything
	// Reset the players PRI values
	ResetPlayerReplicationInfo();

	// Reset info about players
	ResetPlayerInfos();

	// Reset level and controllers.
	ResetLevel();
    super.ResetLevel();   	

	// Reset everything else
	ResetGameLevel();

	// Use endround to restart the level once everything has been reset.
    EndRound( none, "ADMINENDROUND" );

	CurrentRound = 1;
}

function ResetPlayerReplicationInfo()
{
    local CPPlayerController tapc;

    foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
    {
        if (tapc==none || tapc.PlayerReplicationInfo==none)
            continue;

        if (!tapc.PlayerReplicationinfo.bIsSpectator &&
            !tapc.PlayerReplicationinfo.bOnlySpectator)
        {
            CPPlayerReplicationInfo(tapc.PlayerReplicationinfo).Money = 1000;
			CPPlayerReplicationInfo(tapc.PlayerReplicationinfo).CPKills = 0;
			CPPlayerReplicationInfo(tapc.PlayerReplicationinfo).TeamKills = 0;
			CPPlayerReplicationInfo(tapc.PlayerReplicationinfo).bHasEscaped = false;
			CPPlayerReplicationInfo(tapc.PlayerReplicationinfo).bPlantedBomb = false;
			CPPlayerReplicationInfo(tapc.PlayerReplicationinfo).bDiffusedBomb = false;
        }
    }

}

function ResetGameLevel()
{
    local Controller P;
    local Actor A;
	local CPGameReplicationInfo TAGRI;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

	if(TAGRI == none)
		return;

    bBombGiven = false;
    bLastSwat = false;
    bLastMerc = false;
	TAGRI.bRoundIsOver = false;
    TAGRI.bRoundHasBegun = true;
	TAGRI.bMatchHasBegun = true;
    TAGRI.bCanPlayersMove = false;
	TAGRI.Teams[MercIndexId].Score = 0;
	TAGRI.Teams[SwatIndexId].Score = 0;
    TAGRI.RemainingRoundTime = RoundDurationInMinutes * 60;
    TAGRI.EndRoundTime = WorldInfo.TimeSeconds + RoundDurationInMinutes * 60;
    TAGRI.bBombPlanted = false; //resetting the bomb as round is reset.
    TAGRI.bBombBeingDiffused = false;
    TAGRI.RemainingBombDetonatonTime = TAGRI.default.RemainingBombDetonatonTime; //resetting the bomb as round is reset.
    TAGRI.RemainingBombDiffuseTime = TAGRI.default.RemainingBombDiffuseTime; //resetting the bomb as round is reset.
    // Reset Damage taken.
    TAGRI.bDamageTaken = false;

    foreach WorldInfo.AllActors(class'Actor' , A)
    {
        if(A.IsA('CPDroppedBomb'))
        {
            CPDroppedBomb(A).GotoState( 'Pickup' );
        }
        else if(A.IsA('CPBreakingGlassActor'))
            A.Reset();
        else if(A.IsA('DroppedMoneyItem'))
            A.Destroy();
    }

    foreach WorldInfo.AllControllers(class'Controller', P)
    {
        P.PlayerReplicationInfo.NumLives = 0;
        P.PlayerReplicationInfo.bOutOfLives = false;

        if (CPPlayerReplicationInfo(P.PlayerReplicationInfo) != none)
            CPPlayerReplicationInfo(P.PlayerReplicationInfo).bHasEscaped = false;

        if (CPPlayerController(P) != none) //would be for bots
        {
            if ( CPPawn( P.Pawn ) != none )
                CPPawn( P.Pawn ).bIsUsingObjective = false;
            CPPlayerController(P).ClientResetEffectsAndDecals();
        }
			
        //fix here to make sure the players skin is correct when the new round restarts - this is for when you swap teams.
        if ( CPPawn( P.Pawn ) != none )
        {
			if(CPPawn( P.Pawn ).Controller != none)
			{
				SetPlayerModelBasedOnTeam(CPPawn( P.Pawn ).Controller.GetTeamNum(), P);
		    }
        }

        if (CPPlayerController(P) != none && CPPlayerController(P).Pawn != none && CPPlayerController(P).Pawn.Weapon != none)
        {
            CPWeapon(CPPlayerController(P).Pawn.Weapon).Reset();

        }

        RestartPlayer(P);
    }

    UpdateAdvertisementForPlayerInfo();
    AdvertiseGameSettings();
}

function reliable server AdminSetNextMap(string strMapName)
{
    //`Log("AdminSetNextMap::ServerSetNextMap SETTING NEXT MAP TO " $ strMapName);
    strAdminMapSelected = strMapName;
    bAdminSetNextMap = true;
    //`Log("next map to be loaded is now " @ GetNextMap());
}

//final function ValidatePlayer(CPPlayerController PC)
//{
//  if (CV == none)
//  {
//      CV = Spawn(class'CPIValidate');
//  }

//  if (WorldInfo.Game != none && WorldInfo.Game.GetURLMap() != "CPFrontEndMap")
//  {
//      `Log("ValidatePlayer called for " @ PC.PlayerReplicationInfo.PlayerName @ "on map"@WorldInfo.Game.GetURLMap());
//      CV.Validate(string(PC.PlayerReplicationInfo.UniqueId.Uid.A) $ string(PC.PlayerReplicationInfo.UniqueId.Uid.B),CPPlayerReplicationInfo(PC.PlayerReplicationInfo).hash, PC);
//  }
//}

//final function Auth(CPPlayerController PC)
//{
//  if (WorldInfo.Game.GetURLMap() == "CPFrontEndMap")
//      return;

//  if (PC == none)
//      return;

//  `Log("Auth called for " @ PC.PlayerReplicationInfo.PlayerName @ "on map"@WorldInfo.Game.GetURLMap(),,'CPIGame');

//  `Log("AUTH: CPPlayerReplicationInfo(PC.PlayerReplicationInfo).blnAuthed is set to"@CPPlayerReplicationInfo(PC.PlayerReplicationInfo).blnAuthed,,'CPIGame');
//  `Log("AUTH: CPPlayerReplicationInfo(PC.PlayerReplicationInfo).Hash is set to"@CPPlayerReplicationInfo(PC.PlayerReplicationInfo).hash,,'CPIGame');
//  if (!CPPlayerReplicationInfo(PC.PlayerReplicationInfo).blnAuthed)
//  {
//      `Log("AUTH: Server says you are not authed - attempting try number " @ CPPlayerReplicationInfo(PC.PlayerReplicationInfo).intLoginTrys,,'CPIGame');
//      if (CPPlayerReplicationInfo(PC.PlayerReplicationInfo).intLoginTrys < 3)
//      {
//          `Log("AUTH: ShowLoginDialog Called",,'CPIGame');
//          PC.ShowLoginDialog();
//          CPPlayerReplicationInfo(PC.PlayerReplicationInfo).intLoginTrys++;
//      }
//      else
//      {
//          `Log("AUTH: AUTH FAILED FOR"@ PC.PlayerReplicationInfo.PlayerName,,'CPIGame');
//          make sure noone else is connected with the same info
//          if(AccessControl != none)
//          {
//              `Log("AUTH: Failed to authenticate - Ejected from server",,'CPIGame');
//              ForceKickPlayer(PC,"Failed to authenticate - Ejected from server");
//          }
//          else
//          {
//              `Log("AUTH: Console Command Quit initiated",,'CPIGame');
//              ConsoleCommand("Quit",true);
//          }
//      }
//  }
//  else
//  {
//      show welcome??
//      PC.ShowWelcomeDialog();
//  }
//}

// ~Drakk : original commented block below, if not needed please remove this
// left out for testing purposes.
//if (ROLE < ROLE_Authority)
//{
//  class'Engine'.static.StopMovie(true);
//}
event PlayerController Login(string Portal, string Options,const UniqueNetID UniqueID,out string ErrorMessage)
{
    local NavigationPoint StartSpot;
    local CPPlayerController NewPlayer;
    local string InCharacter, InAdminPass;/*,InPassword*/
    local byte InTeam;
    local bool bSpectator,bAdmin,bPerfTesting;
    local rotator SpawnRotation;
    local UniqueNetId ZeroId;

    bAdmin=false;
    if (bUsingArbitration && bHasArbitratedHandshakeBegun)
    {
        ErrorMessage=PathName(WorldInfo.Game.GameMessageClass)$".ArbitrationMessage";
        return none;
    }
    if (BaseMutator!=none)
        BaseMutator.ModifyLogin(Portal,Options);

    bPerfTesting=(ParseOption(Options,"AutomatedPerfTesting")~="1");
    bSpectator=bPerfTesting || (ParseOption(Options,"SpectatorOnly")~="1");
    InTeam=GetIntOption(Options,"Team",255);
    //InPassword=ParseOption(Options,"Password");
    InAdminPass = ParseOption(Options,"AdminPassword");

    if (AccessControl!=none)
        bAdmin=AccessControl.ParseAdminOptions(Options);

    if (!bAdmin && AtCapacity(bSpectator))
    {
        ErrorMessage=PathName(WorldInfo.Game.GameMessageClass)$".MaxedOutMessage";
        return none;
    }

    if (bAdmin && AtCapacity(false))
        bSpectator=true;

    InTeam=PickTeam(InTeam,none);
    StartSpot=FindPlayerStart(none,InTeam,Portal);

    if (StartSpot==none)
    {
        ErrorMessage=PathName(WorldInfo.Game.GameMessageClass) $ ".FailedPlaceMessage";
        return none;
    }
    SpawnRotation.Yaw=StartSpot.Rotation.Yaw;
    NewPlayer=CPPlayerController(SpawnPlayerController(StartSpot.Location,SpawnRotation)); //TOP-Proto this might affect spectators or hostages.
    if( NewPlayer==none)
    {
        `log("Couldn't spawn player controller of class "$PlayerControllerClass);
        ErrorMessage=PathName(WorldInfo.Game.GameMessageClass)$".FailedSpawnMessage";
        return none;
    }
    NewPlayer.StartSpot=StartSpot;
    NewPlayer.PlayerReplicationInfo.SetUniqueId(UniqueId);

//  CPPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo).hash = ParseOption(Options,"hash");
//  ValidatePlayer(NewPlayer);

    if ((WorldInfo.Game.AccessControl!=none) && (WorldInfo.Game.AccessControl.IsIDBanned(UniqueId)))
    {
        `Log("player ["$NewPlayer.GetPlayerNetworkAddress()$"] who's trying to connect is banned, rejecting...");
        ErrorMessage="Engine.AccessControl.SessionBanned";
        return none;
    }

    if ((CPAccessControl(WorldInfo.Game.AccessControl)!=none) && (CPAccessControl(WorldInfo.Game.AccessControl).IsIDMapBanned(UniqueId)))
    {
        `Log("player ["$NewPlayer.GetPlayerNetworkAddress()$"] who's trying to connect is map banned, rejecting...");
        ErrorMessage="You have been banned for the duration of the map.";
        return none;
    }

    if (OnlineSub!=none &&
        OnlineSub.GameInterface!=none &&
        UniqueId!=ZeroId)
    {
        WorldInfo.Game.OnlineSub.GameInterface.RegisterPlayer(PlayerReplicationInfoClass.default.SessionName,UniqueId,HasOption(Options, "bIsFromInvite"));
    }
    RecalculateSkillRating();
    InCharacter=ParseOption(Options,"Character");
    NewPlayer.SetCharacter(InCharacter);

    if (bSpectator || NewPlayer.PlayerReplicationInfo.bOnlySpectator || !ChangeTeam(newPlayer,InTeam,false))
    {
        NewPlayer.GotoState('Spectating');
        NewPlayer.PlayerReplicationInfo.bOnlySpectator=true;
        NewPlayer.PlayerReplicationInfo.bIsSpectator=true;
        NewPlayer.PlayerReplicationInfo.bOutOfLives=true;
        return NewPlayer;
    }

    //TOP-Proto - only attempt to adminlogin if the password is set otherwise it will set off the warning system
    if(Len(InAdminPass) > 0)
    {
        if (AccessControl!=none)
            AccessControl.AdminLogin(NewPlayer,InAdminPass);
    }

    if (bDelayedStart)
    {
        NewPlayer.GotoState('PlayerWaiting');
        return NewPlayer;
    }
    return newPlayer;
}

function int GetCPPlayerID()
{
    ServerPlayerID ++;
    return ServerPlayerID;
}

event PostLogin(PlayerController NewPlayer)
{
    local string Address,StatGuid;
    local int pos, i;
    local Sequence GameSeq;
    local array<SequenceObject> AllInterpActions;
    local bool bPlayerInfoAdded;
    local SPlayerInfo newPlayerInfo;

    if (NewPlayer.PlayerReplicationInfo.bOnlySpectator)
        NumSpectators++;
    else if (WorldInfo.IsInSeamlessTravel() || NewPlayer.HasClientLoadedCurrentWorld())
        NumPlayers++;
    else
        NumTravellingPlayers++;

    UpdateGameSettingsCounts();
    Address=NewPlayer.GetPlayerNetworkAddress();
    pos=InStr(Address,":");
    NewPlayer.PlayerReplicationInfo.SavedNetworkAddress=(pos > 0) ? left(Address,pos) : Address;

    if (CPPlayerController(NewPlayer)!=none && !CPPlayerController(NewPlayer).bIsInMenuGame)
    {
        bPlayerInfoAdded=false;
        for (i=0;i<PlayerInfos.Length;i++)
        {
            if (PlayerInfos[i].PC==CPPlayerController(NewPlayer))
                bPlayerInfoAdded=true;
        }
        if (!bPlayerInfoAdded)
        {
            newPlayerInfo.PC=CPPlayerController(NewPlayer);
            newPlayerInfo.UID=PlayerInfoUIDCounter;
            PlayerInfoUIDCounter++;
            PlayerInfos.AddItem(newPlayerInfo);
        }
    }

    if (!bDelayedStart)
    {
        bRestartLevel=false;
        if (bWaitingToStartMatch)
            StartMatch();
        else
            RestartPlayer(newPlayer);
        bRestartLevel=Default.bRestartLevel;
    }
    if (NewPlayer.Pawn!=none)
        NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);
    NewPlayer.ClientCapBandwidth(NewPlayer.Player.CurrentNetSpeed);
    UpdateNetSpeeds();
    GenericPlayerInitialization(NewPlayer);

    if (GameReplicationInfo.bMatchHasBegun && OnlineSub!=none && OnlineSub.StatsInterface!=none)
    {
        StatGuid=OnlineSub.StatsInterface.GetHostStatGuid();
        if (StatGuid!="")
            NewPlayer.ClientRegisterHostStatGuid(StatGuid);
    }

    if (bRequiresPushToTalk)
        NewPlayer.ClientStopNetworkedVoice();
    else
        NewPlayer.ClientStartNetworkedVoice();

    if (NewPlayer.PlayerReplicationInfo.bOnlySpectator)
        NewPlayer.ClientGotoState('Spectating');

    GameSeq=WorldInfo.GetGameSequence();
    if (GameSeq!=none)
    {
        GameSeq.FindSeqObjectsByClass(class'SeqAct_Interp',true,AllInterpActions);
        for (i=0;i<AllInterpActions.Length;i++)
            SeqAct_Interp(AllInterpActions[i]).AddPlayerToDirectorTracks(NewPlayer);
    }
}

function GenericPlayerInitialization(Controller C)
{
local CPPlayerController PC;

    super.GenericPlayerInitialization(C);
    PC=CPPlayerController(C);
    if (PC!=none)
    {
        if (!PC.bIsInMenuGame)
        {
            CPPlayerReplicationInfo(PC.PlayerReplicationInfo).bPendingLogin=true;
            PC.SetTimer(PendingLoginTimeout,false,'PendingLoginTimedout');
            PC.ClientPendingLoginNotify();
        }
        else
            PendingLoginCompletedFor(PC);
    }
}

function PendingLoginCompletedFor(PlayerController PC)
{
    if (!CPPlayerController(PC).bIsInMenuGame)
    {
        PC.ClearTimer('PendingLoginTimedout');
        CPPlayerReplicationInfo(PC.PlayerReplicationInfo).bPendingLogin=false;
    }

    if (PC.PlayerReplicationInfo.bAdmin)
        AccessControl.AdminEntered(PC);

    ChangeName(PC,PC.PlayerReplicationInfo.PlayerName,true);
    FindInactivePRI(PC);

    CPPlayerController(PC).PendingLoginCompleted();

    if (WorldInfo.NetMode!=NM_Standalone && pc.IsA('CPPlayerController'))
        PlayerStatusToLog(CPPlayerController(pc),"login");
}

/* Try to change a player's name.
*/
function ChangeName( Controller Other, coerce string S, bool bNameChange )
{
    local PlayerController P;
    local bool blnDupicateName;

    blnDupicateName = false;
    foreach WorldInfo.AllControllers(class'PlayerController', P)
    {
        if(P.PlayerReplicationInfo.PlayerName==S && CPPlayerReplicationInfo(P.PlayerReplicationInfo).CPPlayerID != CPPlayerReplicationInfo(Other.PlayerReplicationInfo).CPPlayerID)
        {
            blnDupicateName = true;
            break;
        }
    }

    if(blnDupicateName)
    {
        S = S $ 1;
    }

    if( S == "" )
    {
        return;
    }


    if(Other.PlayerReplicationInfo.PlayerName!=S)
        `log(Other.PlayerReplicationInfo.PlayerName $ " changed name to " $ S);

    Other.PlayerReplicationInfo.SetPlayerName(S);
}

function bool FindInactivePRI(PlayerController PC)
{
    local string NewNetworkAddress;
    local int i;
    local CPPlayerReplicationInfo CurrentPRI;
    local bool bIsConsole;

    if (PC.PlayerReplicationInfo.bOnlySpectator || CPPlayerReplicationInfo(PC.PlayerReplicationInfo) == none)
        return false;

    bIsConsole = WorldInfo.IsConsoleBuild();
    NewNetworkAddress = PC.PlayerReplicationInfo.SavedNetworkAddress;

    for (i = 0; i < InactivePRIArray.Length; i++)
    {
        CurrentPRI = CPPlayerReplicationInfo(InactivePRIArray[i]);
        if (CurrentPRI == none || CurrentPRI.bDeleteMe)
        {
            InactivePRIArray.Remove(i,1);
            i--;
        }
        // Check to see if the current UniqueID is the same as the saved UniqueID, OR the current IP is the same as the saved IP
        else if ((bIsConsole && CurrentPRI.UniqueId == PC.PlayerReplicationInfo.UniqueId) || (!bIsConsole && (CurrentPRI.SavedNetworkAddress ~= NewNetworkAddress)))
        {
            OverridePRI(PC,CurrentPRI);
            InactivePRIArray.Remove(i,1);
            CurrentPRI.Destroy();

            //since we override we need to check a few things here
            `Log("Was this player Voted out?? - if they were kick them out again if required");
            `Log("Was this player temp banned for teamkills?? - if they were kick them out again if required");
            return true;
        }
    }

    CPPlayerReplicationInfo(PC.PlayerReplicationInfo).CPPlayerID=GetCPPlayerID();
    CPPlayerReplicationInfo(PC.PlayerReplicationInfo).PlayerID=CPPlayerReplicationInfo(PC.PlayerReplicationInfo).CPPlayerID; //original was native and made no sense!!
    return false;
}

/* Player Infos */
function UpdatePlayerInfos()
{
    local int i,j;
    local Box HistoryBox;
    local float MaxDim;
    local CPPlayerController tapc;
    local Vector tmpVect;

    i = 0;
    while (i < PlayerInfos.Length)
    {
        if (PlayerInfos[i].PC == none || PlayerInfos[i].PC.PlayerReplicationInfo == none)
            PlayerInfos.Remove(i,1);

        else if (!PlayerInfos[i].PC.PlayerReplicationinfo.bOnlySpectator)
        {
            if (PlayerInfos[i].PC.PlayerReplicationinfo.bIsSpectator ||
                PlayerInfos[i].PC.Pawn == none ||
                PlayerInfos[i].PC.IsDead())
            {
                if (PlayerInfos[i].CampingStatus)
                {
                    PlayerInfos[i].ReCheckTime = 0;
                    PlayerInfos[i].CampingStatus = false;
                    PlayerInfos[i].PC.SetClientCampingStatus(false);

                    foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
                    {
                        if (tapc == none || tapc.PlayerReplicationInfo == none)
                            continue;

                        if (!tapc.PlayerReplicationinfo.bIsSpectator &&
                             !tapc.PlayerReplicationinfo.bOnlySpectator &&
                             !tapc.IsDead() &&
                             tapc.Pawn!=none &&
                             tapc!=PlayerInfos[i].PC)
                        {
                            tapc.ClientRemoveCamperPosition(PlayerInfos[i].UID);
                        }
                    }
                }
                i++;
                continue;
            }

            PlayerInfos[i].LocationHistory[PlayerInfos[i].NextLocHistSlot] = PlayerInfos[i].PC.Pawn.Location;
            PlayerInfos[i].NextLocHistSlot++;

            if (PlayerInfos[i].NextLocHistSlot==5)
            {
                PlayerInfos[i].NextLocHistSlot=0;
                PlayerInfos[i].bWarmedUp=true;
            }

            if(PlayerInfos[i].bWarmedUp)
            {
                HistoryBox.Min.X=PlayerInfos[i].LocationHistory[0].X;
                HistoryBox.Min.Y=PlayerInfos[i].LocationHistory[0].Y;
                HistoryBox.Min.Z=PlayerInfos[i].LocationHistory[0].Z;
                HistoryBox.Max.X=PlayerInfos[i].LocationHistory[0].X;
                HistoryBox.Max.Y=PlayerInfos[i].LocationHistory[0].Y;
                HistoryBox.Max.Z=PlayerInfos[i].LocationHistory[0].Z;

                for (j=1;j<5;j++)
                {
                    HistoryBox.Min.X=FMin(HistoryBox.Min.X,PlayerInfos[i].LocationHistory[j].X);
                    HistoryBox.Min.Y=FMin(HistoryBox.Min.Y,PlayerInfos[i].LocationHistory[j].Y);
                    HistoryBox.Min.Z=FMin(HistoryBox.Min.Z,PlayerInfos[i].LocationHistory[j].Z);
                    HistoryBox.Max.X=FMax(HistoryBox.Max.X,PlayerInfos[i].LocationHistory[j].X);
                    HistoryBox.Max.Y=FMax(HistoryBox.Max.Y,PlayerInfos[i].LocationHistory[j].Y);
                    HistoryBox.Max.Z=FMax(HistoryBox.Max.Z,PlayerInfos[i].LocationHistory[j].Z);
                }

                MaxDim=FMax(FMax(HistoryBox.Max.X-HistoryBox.Min.X,HistoryBox.Max.Y-HistoryBox.Min.Y),HistoryBox.Max.Z-HistoryBox.Min.Z);
                if (PlayerInfos[i].ReCheckTime<=0 && MaxDim<=300 && !PlayerInfos[i].CampingStatus)
                {
                    PlayerInfos[i].ReCheckTime=1;
                    PlayerInfos[i].CampingStatus=true;
                    PlayerInfos[i].CampingLocRandomOffset.X=FRand()*10.0-5.0;
                    PlayerInfos[i].CampingLocRandomOffset.Y=FRand()*10.0-5.0;
                    PlayerInfos[i].CampingLocRandomOffset.Z=FRand()*5.0-2.5;
                    PlayerInfos[i].PC.SetClientCampingStatus(true);
                    foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
                    {
                        if (tapc.PlayerReplicationInfo == none)
                            continue;

                        if (!tapc.PlayerReplicationinfo.bIsSpectator &&
                             !tapc.PlayerReplicationinfo.bOnlySpectator &&
                             !tapc.IsDead() &&
                             tapc.Pawn != none &&
                             tapc!=PlayerInfos[i].PC &&
                             !tapc.Pawn.IsSameTeam(PlayerInfos[i].PC.Pawn))
                        {
                            tmpVect=PlayerInfos[i].PC.Pawn.Location+PlayerInfos[i].CampingLocRandomOffset;
                            tapc.ClientAddCamperPosition(PlayerInfos[i].UID,tmpVect.X,tmpVect.Y,tmpVect.Z);
                        }
                    }
                }
                else if (PlayerInfos[i].ReCheckTime<=0 && MaxDim>=300 && PlayerInfos[i].CampingStatus)
                {
                    PlayerInfos[i].ReCheckTime = 4;
                    PlayerInfos[i].CampingStatus = false;
                    PlayerInfos[i].PC.SetClientCampingStatus(false);

                    foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
                    {
                        if (tapc.PlayerReplicationInfo == none)
                            continue;

                        if (!tapc.PlayerReplicationinfo.bIsSpectator &&
                             !tapc.PlayerReplicationinfo.bOnlySpectator &&
                             !tapc.IsDead() &&
                             tapc.Pawn != none &&
                             tapc != PlayerInfos[i].PC &&
                             !tapc.Pawn.IsSameTeam(PlayerInfos[i].PC.Pawn))
                        {
                            tapc.ClientRemoveCamperPosition(PlayerInfos[i].UID);
                        }
                    }
                }
                else if (PlayerInfos[i].ReCheckTime>0)
                {
                    if (PlayerInfos[i].CampingStatus && MaxDim>50)
                    {
                        foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
                        {
                            if (tapc.PlayerReplicationInfo == none)
                                continue;

                            if (!tapc.PlayerReplicationinfo.bIsSpectator &&
                                 !tapc.PlayerReplicationinfo.bOnlySpectator &&
                                 !tapc.IsDead() &&
                                 tapc.Pawn != none &&
                                 tapc != PlayerInfos[i].PC &&
                                 !tapc.Pawn.IsSameTeam(PlayerInfos[i].PC.Pawn) &&
                                 VSize(PlayerInfos[i].PC.Pawn.Location - tapc.Pawn.Location) < 1200.0)
                            {
                                tmpVect = PlayerInfos[i].PC.Pawn.Location + PlayerInfos[i].CampingLocRandomOffset;
                                tapc.ClientUpdateCamperPosition(PlayerInfos[i].UID,tmpVect.X,tmpVect.Y,tmpVect.Z);
                            }
                        }
                    }

                    if (MaxDim > 300 && !PlayerInfos[i].CampingStatus)
                        PlayerInfos[i].ReCheckTime = 4;
                    else if (MaxDim < 300 && PlayerInfos[i].CampingStatus)
                        PlayerInfos[i].ReCheckTime = 1;
                    else
                        PlayerInfos[i].ReCheckTime--;
                }
            }
            i++;
        }
        else
            i++;
    }
}

function ResetPlayerInfos()
{
    local int i,l;
    local CPPlayerController tapc;

    for (i=0;i<PlayerInfos.Length;i++)
    {
        if (PlayerInfos[i].PC==none)
        {
            PlayerInfos.Remove(i,1);
            i--;
            //if(i<0)
            continue;
        }
        for (l=0;l<5;l++)
            PlayerInfos[i].LocationHistory[l]=vect(0.0,0.0,0.0);
        PlayerInfos[i].NextLocHistSlot=0;
        PlayerInfos[i].bWarmedUp=false;
        PlayerInfos[i].ReCheckTime=0;
        PlayerInfos[i].CampingStatus=false;
        PlayerInfos[i].PC.SetClientCampingStatus(false);

        foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
        {
            if (tapc==none || tapc.PlayerReplicationInfo==none)
                continue;

            if (!tapc.PlayerReplicationinfo.bIsSpectator &&
                !tapc.PlayerReplicationinfo.bOnlySpectator &&
                !tapc.IsDead() &&
                tapc.Pawn!=none &&
                tapc!=PlayerInfos[i].PC)
            {
                tapc.ClientRemoveCamperPosition(PlayerInfos[i].UID);
            }
        }
    }
}

function ResetCamperInfoFor(CPPlayerController tapcIn)
{
local int i;
local CPPlayerController tapc;

    for (i=0;i<PlayerInfos.Length;i++)
    {
        if (PlayerInfos[i].PC==tapcIn)
        {
            if (PlayerInfos[i].CampingStatus)
            {
                PlayerInfos[i].ReCheckTime=0;
                PlayerInfos[i].CampingStatus=false;
                PlayerInfos[i].PC.SetClientCampingStatus(false);

                foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
                {
                    if (tapc==none || tapc.PlayerReplicationInfo==none)
                        continue;

                    if (!tapc.PlayerReplicationinfo.bIsSpectator &&
                         !tapc.PlayerReplicationinfo.bOnlySpectator &&
                         !tapc.IsDead() &&
                         tapc.Pawn!=none &&
                         tapc!=PlayerInfos[i].PC)
                    {
                        tapc.ClientRemoveCamperPosition(PlayerInfos[i].UID);
                    }
                }
            }
            break;
        }
    }
}

function RestartCamperInfoFor(CPPlayerController tapcIn)
{
    local int i;
    local Vector tmpVect;

    ResetCamperInfoFor(tapcIn);
    if (!tapcIn.PlayerReplicationinfo.bIsSpectator &&
        !tapcIn.PlayerReplicationinfo.bOnlySpectator &&
        tapcIn.Pawn != none)
    {
        for (i=0;i<PlayerInfos.Length;i++)
        {
            if (!PlayerInfos[i].CampingStatus || tapcIn==PlayerInfos[i].PC || tapcIn.Pawn.IsSameTeam(PlayerInfos[i].PC.Pawn))
                continue;

            if (PlayerInfos[i].PC.Pawn != none)
            {
                tmpVect=PlayerInfos[i].PC.Pawn.Location+PlayerInfos[i].CampingLocRandomOffset;
                tapcIn.ClientAddCamperPosition(PlayerInfos[i].UID,tmpVect.X,tmpVect.Y,tmpVect.Z);
            }
        }
    }
}
/* Player Infos */

function bool ShouldReset(Actor ActorToReset)
{
    local CPPawn CPP;
    local CPPlayerController CPPC;

    CPP = CPPawn(ActorToReset);
    if (CPP != None)
    {
        if (CPP.Controller!=none)
            return !ShouldRestart(CPP.Controller);

        foreach WorldInfo.AllControllers(class'CPPlayerController', CPPC)
        {
            if (!CPPlayerReplicationInfo(CPPC.PlayerReplicationInfo).bHasEscaped)
                continue;
            if (ActorToReset == CPPC.EscapedPawn)
                return false;
        }
    }
    return true;
}

function bool ShouldRestart(Actor ActorToRestart)
{
    local CPPlayerController tap;

    tap = CPPlayerController(ActorToRestart);
    if (tap != None)
    {
        if (tap != none &&
            tap.bIsPlayer &&
            tap.PlayerReplicationInfo != none &&
            !tap.PlayerReplicationInfo.bIsSpectator &&
            !tap.PlayerReplicationInfo.bWaitingPlayer &&
            !tap.PlayerReplicationInfo.bOutOfLives &&
            tap.PlayerReplicationInfo.Team != none &&
            ((tap.Pawn !=none && tap.Pawn.Health>0) || (CPPlayerReplicationInfo(tap.PlayerReplicationInfo).bHasEscaped && tap.EscapedPawn != none)))
        {
            return true;
        }
    }
    return false;
}

function ResetLevel()
{
    local CPPlayerController CPPC;
    local CPWeaponScoped ScopedWeapon;
    local Controller C;
    local Actor A;
    local Sequence GameSeq;
    local array<SequenceObject> AllSeqEvents;
    local array<int> ActivateIndices;
    local int i;

    //`Log("Reset Level " @ self);

    // Reset all actors (except controllers, the GameInfo, and any other actors specified by ShouldReset())
    // Rogue- Also do not reset the PlayerReplicationInfo since this clears scores. Only reset specific player information
    // for each PlayerReplication Info
    // Rogue- On a offline mode it seems that Resetting the controllers also puts them into
    // spectator and playerwaiting states. Because of this the ShouldReset function will return
    // false since the conditions looked for look for the player to be a spectator or
    // a waiting player. If we reset everything before resetting the Controller then the state should
    // be good for the ShouldReset function to work properly.
    foreach AllActors(class'Actor', A)
    {
        if (A != self && Controller(A) == None && ShouldReset(A))
        {
            if (CPPawn(A) != None && CPPawn(A).IsInState('Dying'))
            {
               A.Reset();
               `log("ResetLevel: Destroying Dead CPPawn.");
            }

            if (CPPlayerReplicationInfo(A) != None)
                CPPlayerReplicationInfo(A).ResetPlayer();
            else
                A.Reset();
        }
    }

    // Rogue- The Client Reset function is causing the controllers to go into a playerwaiting and
    // spectator state before the round begins for Offline server. Only reset the client for the
    // same reasons we reset everything else.
    foreach WorldInfo.AllControllers(class'Controller',C)
    {
        CPPC = CPPlayerController( C );
        if ( CPPC != none && CPPC.Pawn != none )
        {
            ScopedWeapon = CPWeaponScoped( CPPC.Pawn.Weapon );
            if ( ScopedWeapon != none )
                ScopedWeapon.ClientUnZoom();
        }

        if (ShouldRestart(C))
        {
            if (CPPlayerController(C) != None)
			{
                CPPlayerController(C).Restart(false);
			}
            else
            {
                `warn("unable to restart controller type "$C.class$". resetting instead");
				if (CPPlayerController(C)!=none)
				{
                    CPPlayerController(C).ClientReset();
                }
				C.Reset();
            }
        }
        else
        {
            if (PlayerController(C)!=none)
			{
                CPPlayerController(C).ClientReset();
			}
            C.Reset();
        }
    }



    Reset();
    GameSeq=WorldInfo.GetGameSequence();
    if (GameSeq!=none)
    {
        //GameSeq.Reset(); //TOP-Proto fix for kismet that stops working when level resets from any kismet run from levelloaded.
        GameSeq.FindSeqObjectsByClass(class'SeqEvent_LevelLoaded',true,AllSeqEvents);
        ActivateIndices[0]=2;
        for (i=0;i<AllSeqEvents.Length;i++)
            SeqEvent_LevelLoaded(AllSeqEvents[i]).CheckActivate(WorldInfo,none,false,ActivateIndices);
    }
}

/* login info */
function Logout(Controller Exiting)
{
    super.Logout(Exiting);
    if (WorldInfo.NetMode!=NM_Standalone && Exiting.IsA('CPPlayerController'))
        PlayerStatusToLog(CPPlayerController(Exiting),"logout");

    if (WorldInfo != none && CPGameReplicationInfo(WorldInfo.GRI) != none && CPGameReplicationInfo(WorldInfo.GRI).bDamageTaken)
        CheckMaxLives(none, true);

    AdvertiseGameSettings();
    
	if(NumPlayers == 0) 
	{
		GotoState('WaitingForPlayers');
	}    
}

singular function PlayerStatusToLog(CPPlayerController infoPC,string typeTag)
{
    local string logTimeStamp;
    local CPPlayerReplicationInfo taPRI;

    if (infoPC==none || infoPC.PlayerReplicationInfo==none || typeTag=="")
        return;
    taPRI=CPPlayerReplicationInfo(infoPC.PlayerReplicationInfo);
    if (taPRI==none)
        return;
    logTimeStamp="[ "$TimeStamp()$" ]";
    if (typeTag=="login")
    {
        `if(`bRunGamePlayerPoll)
			if(bEnableGamePlayerPoll)
				`log("CPIPLAYERLOGIN");
		`endif
		`log("+++++ LOGIN "$logTimeStamp$" +++++",true,'PlayerLog');
        `log("+++ Name: '"$taPRI.PlayerName$"'",true,'PlayerLog');
        `log("+++ ClanTag: '"$taPRI.ClanTag$"'",true,'PlayerLog');
        `log("+++ Player ID: "$taPRI.CPPlayerID,true,'PlayerLog');
        `log("+++ Player UID: "$taPRI.UniqueId.Uid.A$taPRI.UniqueId.Uid.B,true,'PlayerLog');
        `log("+++ Network Address: "$infoPC.GetPlayerNetworkAddress(),true,'PlayerLog');
        `log("+++++ LOGIN "$logTimeStamp$" +++++",true,'PlayerLog');
    }
    else if (typeTag=="logout")
    {
        `if(`bRunGamePlayerPoll)
			if(bEnableGamePlayerPoll)
				`log("CPIPLAYERLOGOUT");
		`endif
		`log("****** LOGOUT "$logTimeStamp$" ******",true,'PlayerLog');
        `log("*** Name: '"$taPRI.PlayerName$"'",true,'PlayerLog');
        `log("*** ClanTag: '"$taPRI.ClanTag$"'",true,'PlayerLog');
        `log("*** Player ID: "$taPRI.CPPlayerID,true,'PlayerLog');
		if(taPRI.Team != None)
			`log("*** Team: "$taPRI.Team.TeamIndex,true,'PlayerLog');
        `log("*** Player UID: "$taPRI.UniqueId.Uid.A$taPRI.UniqueId.Uid.B,true,'PlayerLog');
        `log("*** Network Address: "$infoPC.GetPlayerNetworkAddress(),true,'PlayerLog');
        `log("****** LOGOUT "$logTimeStamp$" ******",true,'PlayerLog');
    }
    else
        `log("unable to generate log, unknown type tag '"$typeTag$"'",true,'PlayerLog');
}

/* reverb volume hack play sound function */
function PlaySoundWithReverbVolumeHack(Actor playActor,SoundCue Sound,optional bool bAlsoRepToSource,optional bool bOnlyRepToNonRelevantRecvrs)
{
    if (reverbHackHelper==none)
    {
        `warn("Reverb volume hack function called but no helper object exists");
        return;
    }
    reverbHackHelper.PlaySoundWithReverbVolumeHack(playActor,Sound,bAlsoRepToSource,bOnlyRepToNonRelevantRecvrs);
}


function TrackLooserMoneyBonus(int Looser)
{
    if (LT.LosingTeam == Looser)
    {
        LT.RoundsLost++;
    }
    else
    {
        LT.LosingTeam = Looser;
        LT.RoundsLost = 1;
    }

    `Log("Losing Team is " $ LT.LosingTeam $ " And they have lost " $ LT.RoundsLost $ " Rounds ");

    switch(LT.RoundsLost)
    {
    case 1:
        `Log("Awarding 1000 for losing");
        SendServerLogMessageToClient("Awarding 1000 for losing");
        AwardMoney(1000,Looser, "Awarding 1000 for losing");
        break;
    case 2:
        `Log("Awarding 2000 for losing");
        SendServerLogMessageToClient("Awarding 2000 for losing");
        AwardMoney(2000,Looser, "Awarding 2000 for losing");
        break;
    case 3:
        `Log("Awarding 2250 for losing");
        SendServerLogMessageToClient("Awarding 2250 for losing");
        AwardMoney(2250,Looser,"Awarding 2250 for losing");
        break;
    case 4:
        `Log("Awarding 2500 for losing");
        SendServerLogMessageToClient("Awarding 2500 for losing");
        AwardMoney(2500,Looser, "Awarding 2500 for losing");
        break;
    case 5:
        `Log("Awarding 2750 for losing");
        SendServerLogMessageToClient("Awarding 2750 for losing");
        AwardMoney(2750,Looser, "Awarding 2750 for losing");
        break;
    default:
        `Log("Awarding 3000 for losing");
        SendServerLogMessageToClient("Awarding 3000 for losing");
        AwardMoney(3000,Looser, "Awarding 3000 for losing");
        break;
    }
}

function AwardScoreIfAlive(int AwardedScore, int AwardedTeam)
{
    local CPGameReplicationInfo TAGRI;
    local int i;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(TAGRI.PRIArray[i].Team != none)
        {
            if(!TAGRI.PRIArray[i].bOutOfLives && TAGRI.PRIArray[i].Team.TeamIndex == AwardedTeam )
            {
                TAGRI.PRIArray[i].Score += AwardedScore;

                AdvertiseGameSettings();
            }
        }
    }
}

function AwardScoreEvenIfDead(int AwardedScore, int AwardedTeam)
{
    local CPGameReplicationInfo TAGRI;
    local int i;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(TAGRI.PRIArray[i].Team != none)
        {
            if(TAGRI.PRIArray[i].Team.TeamIndex == AwardedTeam )
            {
                TAGRI.PRIArray[i].Score += AwardedScore;

                AdvertiseGameSettings();
            }
        }
    }
}

function AwardMoney(int AwardedMoney, int AwardedTeam, optional string Reason)
{
    local CPGameReplicationInfo TAGRI;
    local int i;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
		
		//If player is new (hence spectating) dont give them money
		if(TAGRI.PRIArray[i].bIsSpectator && CPPlayerReplicationInfo(TAGRI.PRIArray[i]).bIsNewPlayer)
			continue;
		
		if (TAGRI.PRIArray[i].Team != none && TAGRI.PRIArray[i].Team.TeamIndex == AwardedTeam )
        {
			`if(`bPollObectiveEvent)
				if(bEnableGamePlayerPoll)
					PollObjectiveEvent(WorldInfo.TimeSeconds, GetObjectiveByEnum(Reason), AwardedMoney, TAGRI.PRIArray[i]);
			`endif
			CPPlayerReplicationInfo(TAGRI.PRIArray[i]).ModifyMoney(AwardedMoney);
        }
    }
}

function AwardDetonationScore(int AwardedScore, int AwardedTeam)
{
    local CPGameReplicationInfo TAGRI;
    local int i;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(TAGRI.PRIArray[i].bIsSpectator)
            continue;

        if(TAGRI.PRIArray[i].Team != none && TAGRI.PRIArray[i].Team.TeamIndex == AwardedTeam  && CPPlayerReplicationInfo(TAGRI.PRIArray[i]).bPlantedBomb)
        {
            TAGRI.PRIArray[i].Score += AwardedScore;

            AdvertiseGameSettings();
        }
    }
}

function AwardDeffusingScore(int AwardedScore, int AwardedTeam)
{
    local CPGameReplicationInfo TAGRI;
    local int i;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(CPPlayerReplicationInfo(TAGRI.PRIArray[i]).bIsSpectator)
            continue;

        if(TAGRI.PRIArray[i].Team != none && TAGRI.PRIArray[i].Team.TeamIndex == AwardedTeam  && CPPlayerReplicationInfo(TAGRI.PRIArray[i]).bDiffusedBomb)
        {
            CPPlayerReplicationInfo(TAGRI.PRIArray[i]).Score += AwardedScore;

            AdvertiseGameSettings();
        }
    }
}

function AwardMoneyIfAlive(int AwardedMoney, int AwardedTeam, optional string Reason)
{
    local CPGameReplicationInfo TAGRI;
    local int i;

    TAGRI = CPGameReplicationInfo(GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(CPPlayerReplicationInfo(TAGRI.PRIArray[i]).bIsSpectator)
            continue;

        if(TAGRI.PRIArray[i].bOutOfLives && TAGRI.PRIArray[i].Team != none && TAGRI.PRIArray[i].Team.TeamIndex == AwardedTeam )
        {
            `if(`bPollObectiveEvent)
				if(bEnableGamePlayerPoll)
					PollObjectiveEvent(WorldInfo.TimeSeconds, GetObjectiveByEnum(Reason), AwardedMoney, TAGRI.PRIArray[i]);
			`endif
            CPPlayerReplicationInfo(TAGRI.PRIArray[i]).ModifyMoney(AwardedMoney);
        }
    }
}

/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel(string URL, optional bool bAbsolute)
{
    local PlayerController LocalPlayer;
    local bool bSeamless;
    local string NextMap;
    local Guid NextMapGuid;
    local int OptionStart;

    bLevelChange = true;
    EndLogging("mapchange");

    // force an old style load screen if the server has been up for a long time so that TimeSeconds doesn't overflow and break everything
    bSeamless = (bUseSeamlessTravel && WorldInfo.TimeSeconds < 172800.0f); // 172800 seconds == 48 hours

    if (InStr(Caps(URL), "?RESTART") != INDEX_NONE)
    {
        NextMap = string(WorldInfo.GetPackageName());
    }
    else
    {
        OptionStart = InStr(URL, "?");
        if (OptionStart == INDEX_NONE)
        {
            NextMap = URL;
        }
        else
        {
            NextMap = Left(URL, OptionStart);
        }
    }
    NextMapGuid = GetPackageGuid(name(NextMap));

    if(NextMapGuid.A == 0 && NextMapGuid.B == 0 && NextMapGuid.C == 0 && NextMapGuid.D == 0)
    {
        if(URL == "CP-Frostbite") //if we fail to find CP-Frostbite fail and load the main menu.
        {
            `log("ProcessServerTravel: map"@URL@"Does not exist. Aborting server travel and returning to the main menu.");
            ProcessServerTravel("CPFrontEndMap", true);
            return;
        }
        else // if we fail to find URL, fail and load CP-StGeorge
        {
            `log("ProcessServerTravel: map"@URL@"Does not exist. Aborting server travel and loading CP-StGeorge.");
            ProcessServerTravel("CP-Frostbite", true);
            return;
        }
    }
    // Notify clients we're switching level and give them time to receive.
    LocalPlayer = ProcessClientTravel(URL, NextMapGuid, bSeamless, bAbsolute);

    `log("ProcessServerTravel:"@URL);
    WorldInfo.NextURL = URL;
    if (WorldInfo.NetMode == NM_ListenServer && LocalPlayer != None)
    {
        WorldInfo.NextURL $= "?Team="$LocalPlayer.GetDefaultURL("Team")
                            $"?Name="$LocalPlayer.GetDefaultURL("Name")
                            $"?Class="$LocalPlayer.GetDefaultURL("Class")
                            $"?Character="$LocalPlayer.GetDefaultURL("Character");
    }


    // Notify access control, to cleanup online subsystem references
    if (AccessControl != none)
    {
        AccessControl.NotifyServerTravel(bSeamless);
    }

    // Trigger cleanup of online delegates
    ClearOnlineDelegates();

    if (bSeamless)
    {
        WorldInfo.SeamlessTravel(WorldInfo.NextURL, bAbsolute);
        WorldInfo.NextURL = "";
    }
    // Switch immediately if not networking.
    else if (WorldInfo.NetMode != NM_DedicatedServer && WorldInfo.NetMode != NM_ListenServer)
    {
        WorldInfo.NextSwitchCountdown = 0.0;
    }
}


//THIS UPDATES EVERY TICK BUT IT DOES NOT ADVERTISE EVERY TICK SO PLEASE USE THIS FOR ANY UPDATES TO PLAYER INFO.
function UpdateAdvertisementForPlayerInfo()
{
    local PlayerController P;
    local OnlineGameSettings GameSettings;
    local int index;

    // If we're playing in editor then return out of the function
    if (WorldInfo.IsPlayInPreview() || WorldInfo.IsPlayInEditor())
    {
        return;
    }

    if (OnlineGameSettingsClass != None)
    {
        GameSettings = OnlineSub.GameInterface.GetGameSettings(WorldInfo.Game.PlayerReplicationInfoClass.default.SessionName);

        if(GameSettings == none)
            return;

        index = 0;

        foreach WorldInfo.AllControllers(class'PlayerController', P)
        {
            if(P != none && P.PlayerReplicationInfo != none && P.PlayerReplicationInfo.Team != none)
            {

                CPIGameSettings(GameSettings).setServerPlayerInfo("{" $ P.PlayerReplicationInfo.PlayerName $ "|" $ int(P.PlayerReplicationInfo.Score * 10) $ "|" $ CPPlayerReplicationInfo(P.PlayerReplicationInfo).CPKills $ "/" $ P.PlayerReplicationInfo.Deaths $ "|" $ P.PlayerReplicationInfo.Ping $ "|" $ P.PlayerReplicationInfo.Team.TeamIndex $ "}",index);
            }
            index++;
        }

        GameSettings.UpdateFromURL(ServerOptions, self);
    }
}

function AdvertiseGameSettings()
{
    local OnlineGameSettings GameSettings;

    if (GameInterface != None)
    {
        GameSettings = GameInterface.GetGameSettings(PlayerReplicationInfoClass.default.SessionName);
    }

    if (GameSettings != None && GameInterface != None)
    {
        GameInterface.UpdateOnlineGame(PlayerReplicationInfoClass.default.SessionName,GameSettings);
    }
}

// Untested
function PurgePoll(PlayerController APlayerController)
{
	`if(`bRunGamePlayerPoll)
		if(PlayerEventPoll.Length==0)
			CPPlayerController(APlayerController).ClientNotifyPollPurged(False, "Poll empty");
		else
		{
			OutputPlayerEventPoll(CurrentRound, WinningTeamIndex);
			CPPlayerController(APlayerController).ClientNotifyPollPurged(True);
		}
	`else
		CPPlayerController(APlayerController).ClientNotifyPollPurged(False, "Poll is disabled. See \'GameAnalyticsProfile.uc\' to enable");
	`endif
	
}

DefaultProperties
{
    bRestartLevel=false
    bTeamGame=true
    WarmupDelay=0
    MinEscapeCount=2
    EscapePct=50.000000
    Swat[0]="Proto"
    Swat[1]="Arny"
    Swat[2]="Thor"
    Swat[3]="Zippo"
    Swat[4]="Serg"
    Swat[5]="Hamid"
    Swat[6]="Proto"
    Swat[7]="PAldred"

    Merc[0]="Evil Proto"
    Merc[1]="Evil Jean"
    Merc[2]="Evil John"
    Merc[3]="Evil Ssswing"
    Merc[4]="Evil PAldred"
    Merc[5]="Evil JasonMatthews"
    Merc[6]="Evil Molez"
    Merc[7]="Evil Arny"

    Hostages[0]="Hostage 1"
    Hostages[1]="Hostage 2"
    Hostages[2]="Hostage 3"
    Hostages[3]="Hostage 4"
    Hostages[4]="Hostage 5"
    Hostages[5]="Hostage 6"
    Hostages[6]="Hostage 7"
    Hostages[7]="Hostage 8"


    //Pointed the hud to the CPHUD Class
    HUDType=class'CriticalPoint.CPHUD'

    PlayerControllerClass=class'CPPlayerController'
    //ConsolePlayerControllerClass=class'UTGame.UTConsolePlayerController'
    DefaultPawnClass=class'CPPawn'
    PlayerReplicationInfoClass=class'CPPlayerReplicationInfo'
    GameReplicationInfoClass=class'CPGameReplicationInfo'
    OnlineGameSettingsClass=class'CPIGameSettings'

    BroadcastHandlerClass=class'Engine.BroadcastHandler'

    DefaultInventory(1)=(Team[0]=class'CPWeap_Hatchet',Team[1]=class'CPWeap_KaBar')
    DefaultInventory(0)=(Team[0]=class'CPWeap_Glock',Team[1]=class'CPWeap_SpringfieldXD45')

    AccessControlClass=class'CriticalPoint.CPAccessControl'
    DeathMessageClass=class'CPMsg_Death'

    PlayerInfoUIDCounter=1258

    MercIndexId = 0
    SwatIndexId = 1
    HostageIndexId = 2
    CurrentRound=1
}
