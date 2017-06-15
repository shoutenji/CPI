//==============================================================================
// CPHackObjective
// $wotgreal_dt: 16.04.2014 16:17:23$ by Crusha
//
// A hackable objective with a visual representation as StaticMesh.
// You should look at it to activate it, while standing in a CPHackZone.
//
// Activates the ObjectiveCompleted SeqEvent in Kismet, with the hacking Pawn
// as instigator.
//==============================================================================
class CPHackObjective extends DynamicSMActor
    implements(CPObjectiveInterface) placeable;

var float HackDistance;
var() float HackTime; // How many seconds it takes to hack this objective.
var() int HackableTeamIndex; // TeamIndex of the faction that is supposed to hack this objective.
var() float AimEpsilon; // Determines how closely the player needs to look at the center of the objective to hack it. The closer to 1, the less forgiving.

var(HackingSound) AudioComponent HackingSound; // The sound that is played while this objective is being hacked. Played from coordinates of the objective.

var CPPawn PawnUsing;
var float Percent; // We probably need this for the HUD. If not, then we can get rid of the FClamp further below.
var repnotify bool bInUse; // Probably redundant with PawnUsing != None, but let's keep it for now.
var bool bActive;

var float LastAnnouncementTime;


replication
{
    if (bNetDirty)
        Percent, bActive, bInUse;
}

simulated event ReplicatedEvent(name VarName)
{
    super.ReplicatedEvent(VarName);

    if (VarName == 'bInUse')
    {
        if (bInUse)
        {
            PlayHackingEffects();
        }
        else
        {
            StopHackingEffects();
        }
    }
}


// This is defined in Actor.uc and there are already mechanics in place that make use of it.
//TODO: Make sure the custom Use() code in CPPlayerController doesn't actually break this functionality.
function bool UsedBy(Pawn User)
{
    local CPPawn CPP;

    CPP = CPPawn(User);

    if (!bActive || bInUse || CPP == none || !User.IsAliveAndWell()) // Let's hope that 'alive and well' means Health > 0...
	{
		return false;
	}

    if (User.GetTeamNum() != HackableTeamIndex || !FastTrace(Location, User.Location) || VSize(Location-User.Location) > HackDistance)
	{
		return false;
	}

    CPP.bIsUsingObjective = true;
    PawnUsing = CPP;
	HackingSound.Location = Location;
    bInUse = true;
    PlayHackingEffects();

    return super.UsedBy(User); // Passes the usage to the respective SeqEvent.
}

function StopHacking()
{
    if (PawnUsing != None)
    {
        PawnUsing.SetWeaponState(EWS_None);
        PawnUsing.bIsUsingObjective = false;
        PawnUsing.bNoWeaponFiring = false;
    }
    PawnUsing = none;
    bInUse = false;
    Percent = 0.0;
    StopHackingEffects();
}

simulated function PlayHackingEffects()
{
	 HackingSound.Play();
}

simulated function StopHackingEffects()
{
     HackingSound.Stop();
}

// We don't need to replicate this. Just let the server handle announcement checks exclusively.
function AnnounceObjectiveBeingHacked()
{
    local CPPlayerController CPPC;

    if (PawnUsing == None)
        return;

    CPPC = CPPlayerController(PawnUsing.Controller);

    if (CriticalPointGame(WorldInfo.Game) != None)
    {
        switch(CPPC.GetTeamNum())
        {
            case TTI_SpecialForces:
                CriticalPointGame(WorldInfo.Game).AnnounceObjectiveBeingHackedBySpecialForces();
            case TTI_Mercenaries:
                CriticalPointGame(WorldInfo.Game).AnnounceObjectiveBeingHackedByMercenaries();
            default:
                CriticalPointGame(WorldInfo.Game).AnnounceObjectiveBeingHacked();
        }
    }
}


simulated event Tick(float DeltaTime)
{
    local CriticalPointGame Game;
    local CPWeaponAttachment CPWA;
			
	if (Role == ROLE_Authority)
    {
        Game = CriticalPointGame(WorldInfo.Game);
        if (Game != none)
        {
            bActive = Game.MatchIsInProgress() && Game.RoundIsInProgress();
            //TODO: Performance optimization. Don't recalculate this on every Tick.
            // See if we can put this in a state and use MatchStarting(), etc to manage that state.
        }
    }

    if (!bInUse || !bActive || PawnUsing == None)
    {
		if(bInUse)
			StopHacking();	
        return;
    }

    if (!PawnUsing.bIsUseKeyDown || !PawnUsing.IsAliveAndWell() || !FastTrace(Location, PawnUsing.Location))
    {
        StopHacking();
        return;
    }

    if (Role == ROLE_Authority && WorldInfo.TimeSeconds - LastAnnouncementTime > 5)
    {
        AnnounceObjectiveBeingHacked();
        LastAnnouncementTime = WorldInfo.TimeSeconds;
    }

    PawnUsing.SetWeaponState(EWS_Hacking);


    Percent += 100 * DeltaTime / HackTime;
    Percent = FClamp(Percent, 0.0f, 100.0);
    if (Percent >= 100.0)
    {
        CPWA = PawnUsing.CurrentWeaponAttachment;

        if (CPWA != None)
			CPWA.HackSound.Stop();

        PawnUsing.bIsUseKeyDown = false;
        PawnUsing.SetWeaponState(EWS_None);

        TriggerEventClass(class'CPSeqEvent_ObjectiveCompleted', PawnUsing);

        if (Role == ROLE_Authority)
        {
            //TODO: Better handling of endgame. Allowing multiple objectives and correctly determining who hacked the objective.
            Game.HUDMessage(18);
            Game.EndRound(PawnUsing.Controller.PlayerReplicationInfo, "Special Forces have hacked the objective!");
        }

        StopHacking();
    }
	
}


defaultproperties
{
    Begin Object class=AudioComponent Name=HackSoundComponent
        SoundCue = SoundCue'CP_Weapon_Sounds.BombAndHackSounds.HackingLoop_Cue'
		bAlwaysPlay=True
		bReverb=True
		bAllowSpatialization=True
		bIsUISound=True
    End Object
    HackingSound=HackSoundComponent
	Components.Add(HackSoundComponent)

    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=10.0

    bCollideActors=true
    bProjTarget=true
    bNoDelete=true

    HackTime=15.0f
    AimEpsilon=0.98f
    HackableTeamIndex=TTI_SpecialForces
    HackDistance=60

    bInUse=false
    bActive=true

    SupportedEvents.Add(class'CPSeqEvent_ObjectiveCompleted')
}