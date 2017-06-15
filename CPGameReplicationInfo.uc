class CPGameReplicationInfo extends GameReplicationInfo
    dependsOn(CriticalPointGame);

var() globalconfig string MessageOfTheDay;
var() globalconfig string AdminName;
var() globalconfig string AdminEmail;
var globalconfig bool bShowKillersHealthInMessage;
var bool bAnnouncementsDisabled;
var array<MaterialInterface> WeaponOverlays;
var databinding int RemainingRoundTime;
var databinding int ElapsedRoundTime;
var databinding int RoundTimeBuffer;
var databinding int EndMapTime;
var databinding int EndRoundTime;
var bool bRoundHasBegun;
var bool bRoundIsOver;
var bool bDamageTaken;
var bool bWarmup;
var bool bCanPlayersMove;
var bool bTeamsAreForced;
var bool bIsFFenabled;
var bool bNadeFFenabled;
var bool bBombPlanted;
var bool bBombBeingDiffused; //used only for the hud display.
var config bool bAllowBehindView; //TODO:Code this in so when using behindview in console it allows you to go into behindview if set to true.
var int MaxTeamKills;
var() globalconfig bool bAllowHitIndicators;
var databinding float RemainingBombDetonatonTime, RemainingBombDiffuseTime;

var float BombPlantStartTime, BombDiffuseStartTime;
var float FFPercentage;
var float NadeFFPercentage;
var CPEscapeZone EscapeZone;
var CPHostageRescueZone HostageRescueZone;

/** ~WillyG: moved from CriticalPointGame BEGIN */
var CriticalPointGame.ESpectateView Spectating;

var int RoundDurationInMinutes, RoundStartDelay, RoundEndDelay,
    GameRestartWait, MinimumPlayers, GameStartDelay, MaxWaitOnTraveling;

var int MaxPlayers;

/** Moved from CriticalPointGame END */

replication
{
    // ~Rogue: All values put here are replicated everytime they change, but not upon initial replication
    if (!bNetInitial && Role==ROLE_Authority)
        ElapsedRoundTime,RoundTimeBuffer, bBombPlanted, bBombBeingDiffused;

    // ~Rogue: All values put here will be updated to every client everytime the values change on the server.
    if((bNetDirty || bNetInitial) && (Role==ROLE_Authority))
        Spectating, MinimumPlayers, MaxPlayers, RoundDurationInMinutes,
        bRoundHasBegun, bRoundIsOver, bDamageTaken, RoundStartDelay,
        RoundEndDelay, GameRestartWait, GameStartDelay, bTeamsAreForced,
        MaxWaitOnTraveling, bWarmup, bCanPlayersMove, RemainingRoundTime,
        RemainingBombDetonatonTime, RemainingBombDiffuseTime, FFPercentage, bIsFFenabled, NadeFFPercentage, bNadeFFenabled, MaxTeamKills,
        bAllowBehindView;
    if (bNetDirty)
        bAnnouncementsDisabled, bAllowHitIndicators;
}

simulated function ResetDiffuseTimer() //required when people press diffuse constantly.
{
    BombDiffuseStartTime = 0;
}

simulated event Timer()
{

    // Do not count down the Round time until we have left the
    // buytime.
    if (bMatchHasBegun && !IsRoundPreparation())
    {
        // Wait until players can move before we start the round countdown as well.
        if (RemainingRoundTime>0 && bRoundHasBegun && bCanPlayersMove)
        {
            // If the Main clock has not started counting down then
            // start it here once the first buytime has completed.
            if(bStopCountDown == true)
            {
                bStopCountDown = false;
                ElapsedTime = 0;
            }
            //Rogue. Have server use WorldInfo to keep track of time. The client will just
            //use the "Timer" to simulate time.
            if ( WorldInfo.NetMode != NM_Client )
            {
                RemainingRoundTime = EndRoundTime - WorldInfo.TimeSeconds;
            }
            else
            {
                RemainingRoundTime--;
            }
        }
    }

    ////bomb timer logic
    if(bBombPlanted && Role == ROLE_AUTHORITY)
    {
        if(BombPlantStartTime == 0)
            BombPlantStartTime = WorldInfo.TimeSeconds + default.RemainingBombDetonatonTime;

        RemainingBombDetonatonTime = BombPlantStartTime - WorldInfo.TimeSeconds;
        //`log("RemainingBombDetonatonTime " $ RemainingBombDetonatonTime);
    }
    else
    {
        BombPlantStartTime = 0;
    }

    if(bBombBeingDiffused && Role == ROLE_AUTHORITY)
    {
        if(BombDiffuseStartTime == 0)
            BombDiffuseStartTime = WorldInfo.TimeSeconds + default.RemainingBombDiffuseTime;

        RemainingBombDiffuseTime = BombDiffuseStartTime - WorldInfo.TimeSeconds;
        //`log("RemainingBombDiffuseTime " $ RemainingBombDiffuseTime);
    }
    else
    {
        BombDiffuseStartTime = 0;
    }

    if ( (WorldInfo.Game == None) || WorldInfo.Game.MatchIsInProgress() )
    {
        ElapsedTime++;
    }
    if ( WorldInfo.NetMode == NM_Client )
    {
        // sync remaining time with server once a minute
        if ( RemainingMinute != 0 )
        {
            RemainingTime = RemainingMinute;
            RemainingMinute = 0;
        }
    }
    if ( (RemainingTime > 0) && !bStopCountDown )
    {
        // Have the server use WorldInfo to keep track of time correctly.
        // The client will use simulated time to count down but will resync to the server every
        // minute.
        if ( WorldInfo.NetMode != NM_Client )
        {
            RemainingTime = EndMapTime - WorldInfo.TimeSeconds;
            if ( RemainingTime % 2 == 0 )
            {
                RemainingMinute = RemainingTime;
            }
        }
        else
        {
            RemainingTime--;
        }
    }

    SetTimer(WorldInfo.TimeDilation, true);
}

simulated function bool IsRoundPreparation()
{
    if (bRoundHasBegun && !bRoundIsOver && RoundTimeBuffer>0)
        return true;
    return false;
}

simulated function bool IsRoundRestarting()
{
    if (bRoundHasBegun && bRoundIsOver && RoundTimeBuffer>0)
        return true;
    return false;
}

//@Wail - This function is intended for use as a way of quickly determining whether the round in progress has had any 'key' events
//e.g. has any damage occurred, any hostages been rescued, bombs been planted, that would prevent a new player from immediately joining the game
simulated function bool RoundIsActive ()
{
   // Reset Damage taken on an endround.
   return (bDamageTaken || (EscapeZone != None && EscapeZone.NumEscaped > 0) || bBombPlanted || 
			(HostageRescueZone != None && HostageRescueZone.NumEscaped > 0) );
}


DefaultProperties
{
    RemainingBombDetonatonTime=55   //timer is set to this...
    RemainingBombDiffuseTime=8      //Amount of time it takes to diffuse the bomb
}
