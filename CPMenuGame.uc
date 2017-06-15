class CPMenuGame extends CriticalPointGame;

function bool NeedPlayers()
{
	return false;
}

function StartMatch()
{
}

event InitGame( string Options, out string ErrorMessage )
{
}

auto State PendingMatch
{
	function RestartPlayer(Controller aPlayer)
	{
	}

	function Timer()
    {
    }

    function BeginState(Name PreviousStateName)
    {
		bWaitingToStartMatch=true;
    }

	function EndState(Name NextStateName)
	{
	}
}

function float RatePlayerStart(PlayerStart P,byte Team,Controller Player)
{
	return -9;
}

function PlayerController SpawnPlayerController(vector SpawnLocation,rotator SpawnRotation)
{
local PlayerController pc;
	
	pc=Spawn(PlayerControllerClass,,,SpawnLocation,SpawnRotation);
	if (pc.IsA('CPPlayerController'))
		CPPlayerController(pc).bIsInMenuGame=true;
	return pc;
}

defaultproperties
{
    //Fixed duplicate hud showing in menugame mode.
    HUDType=none

}
