class CPPlayerReplicationInfo extends PlayerReplicationInfo;

var repnotify class<CPFamilyInfo> CharClassInfo;
var class<CPFamilyInfo> CharClassInfoCached;
var class<CPFamilyInfo> PendingCharClass; // used to store the value of a pending character switch that will take effect next round
var class<CPVoice> VoiceClass;
var bool bIsFemale;
var bool bServerForcedRestart;
var string ClanTag;
var bool bRecievedPlayerName;
var bool bPendingLogin;
var int intLoginAttempts;
var	bool bHasEscaped;
var int Money;
var int MaxMoney;
var int CPKills;
var int CPHealth;
var int TeamKills;
var bool bPlantedBomb;
var bool bDiffusedBomb;
var int intLoginTrys;
var bool blnAuthed;
var bool bIsNewPlayer; //True until player enters walking state (ie the first time)
//var string hash;
var CPWeapon SpectatorWeapons[7];
var CPWeapon SpectatorOrderedWeapons[7];

var bool bConditionalReturn;
//GameReplicationInfo.bDamageTaken

/** Unique id number. */
var int					CPPlayerID;

var int StatPKLTotal;

/** List of votes recieved */
var array<int> VoteList;

replication
{
	if (bNetDirty && !bNetOwner)
		StatPKLTotal;

	if (bNetDirty)
		SpectatorOrderedWeapons, SpectatorWeapons, Money, CPPlayerID, ClanTag, bHasEscaped, CharClassInfo, bIsFemale ,CPKills, TeamKills, bDiffusedBomb, bPlantedBomb, CPHealth, bConditionalReturn, PendingCharClass;
}

simulated event ReplicatedEvent(name VarName)
{
    local CPPawn cpp;

	if (VarName=='Team')
	{
		foreach WorldInfo.AllPawns(class'CPPawn',cpp)
		{
			if (cpp.PlayerReplicationInfo == self || (cpp.DrivenVehicle != none && cpp.DrivenVehicle.PlayerReplicationInfo == self) )
				cpp.NotifyTeamChanged();
		}
	}
    else if (VarName=='CharClassInfo')
    {
        if (CharClassInfoCached != CharClassInfo)
        {
		    foreach WorldInfo.AllPawns(class'CPPawn',cpp)
		    {
			    if (cpp.PlayerReplicationInfo == self || (cpp.DrivenVehicle!=none && cpp.DrivenVehicle.PlayerReplicationInfo == self) )
			    	cpp.SetCharacterClassFromInfo(CharClassInfo);
		    }
		    CharClassInfoCached = CharClassInfo;
		    // reset PendingCharClass when we actually change CharClass
		    if (PendingCharClass != None)
		    {
                PendingCharClass = None;
            }
        }
    }
    Super.ReplicatedEvent(VarName);
}

simulated function ClientInitialize(Controller C)
{
local CPSaveManager TASave;

	TASave=new class'CPSaveManager';
	if (ClanTag!=TASave.GetItem("ClanTag"))
	{
		ClanTag=TASave.GetItem("ClanTag");
		CPPlayerController(C).ServerSetClanTag(ClanTag);
	}
}



function CopyProperties(PlayerReplicationInfo PRI)
{
	local CPPlayerReplicationInfo TAPRI;

	Super.CopyProperties(PRI);
	TAPRI=CPPlayerReplicationInfo(PRI);
	if (TAPRI==none)
		return;
    TAPRI.CharClassInfo=CharClassInfo;
	TAPRI.bIsFemale=bIsFemale;
	TAPRI.CPPlayerID = CPPlayerID;
	TAPRI.Money = Money;
	TAPRI.CPKills = CPKills;
}

function ResetPlayer()
{
	bReadyToPlay=false;
	NumLives=0;
	bOutOfLives=false;
	bForceNetUpdate=true;
}

function SeamlessTravelTo(PlayerReplicationInfo NewPRI)
{
local CPPlayerReplicationInfo TAPRI;

	Super.SeamlessTravelTo(NewPRI);
	TAPRI=CPPlayerReplicationInfo(NewPRI);
	if (TAPRI!=none)
	{
        TAPRI.CharClassInfo=CharClassInfo;
		TAPRI.VoiceClass=VoiceClass;
	}
}

function OverrideWith(PlayerReplicationInfo PRI)
{
	Super.OverrideWith(PRI);	

	bIsSpectator = PRI.bIsSpectator;
	bOnlySpectator = PRI.bOnlySpectator;
	bWaitingPlayer = PRI.bWaitingPlayer;
	bReadyToPlay = PRI.bReadyToPlay;
	CPPlayerID = CPPlayerReplicationInfo(PRI).CPPlayerID;
	PlayerID = CPPlayerReplicationInfo(PRI).CPPlayerID;
	bOutOfLives=PRI.bOutOfLives || bOutOfLives;
	Team=PRI.Team;
	Score=PRI.Score;
	Deaths=PRI.Deaths;
	TeamKills=CPPlayerReplicationInfo(PRI).TeamKills;
	Money = CPPlayerReplicationInfo(PRI).Money;
	CPKills = CPPlayerReplicationInfo(PRI).CPKills;
	
	TTSSpeaker=PRI.TTSSpeaker;

	`Log("DETECTED AN OLD PLAYER RELINKING THEM TO THEIR INACTIVE PRI");
	`Log("CPPlayerID " $ CPPlayerID);
	`Log("SavedNetworkAddress " $ SavedNetworkAddress);
	`Log("PlayerName " $ PlayerName);
}

function CheckPendingLoginStatus()
{
	if (CPPlayerController(Owner)==none)
		return;
	if (bRecievedPlayerName)
	{
		if (PlayerName=="")
			PlayerName=WorldInfo.Game.DefaultPlayerName;
		if (bPendingLogin && WorldInfo.Game.IsA('CriticalPointGame') && Owner!=none)
			CriticalPointGame(WorldInfo.Game).PendingLoginCompletedFor(PlayerController(Owner));	
	}
}

simulated function bool IsLocalPlayerPRI()
{
local PlayerController PC;
local LocalPlayer LP;

	PC=PlayerController(Owner);
	if (PC!=none)
	{
		LP=LocalPlayer(PC.Player);
		return (LP!=none);
	}
	return false;
}

//This function checks to make sure that player has enough money.
simulated function bool BuyCheck(int Cost, int MoneyBack)
{
	//`log("Money = " $ Money $ ", Cost = " $ Cost $ ", Money Back = " $ MoneyBack);
	
	if(Cost == 0 && MoneyBack > 0) //Case 1: Items are being sold back exclusively
	{
		return true;
	}
	else if(Money >= Cost-MoneyBack)
	{
		return true;
	}
	else return false;	
}

function ModifyMoney(int Modifier)
{
	Money += Modifier;
	
	if(Money > MaxMoney)
		Money = MaxMoney;
}

function SetMoney(int Modifier)
{
	Money = Modifier;
	
	if(Money > MaxMoney)
		Money = MaxMoney;
}

/**
 * Validates that the new name matches the profile if the player is logged in
 *
 * @return TRUE if the name doesn't match, FALSE otherwise
 *
 * Stubbed so we can change our in-game name to whatever we want.
 */
simulated function bool IsInvalidName();


/*
*/
DefaultProperties 
{
	bServerForcedRestart=false;
	VoiceClass=class'CPVoice'
	CharClassInfo=class'CriticalPoint.CP_SWAT_MaleOne'
	Money=1000
	MaxMoney=20000
	bIsNewPlayer=True
}