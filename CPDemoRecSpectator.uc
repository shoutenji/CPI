class CPDemoRecSpectator extends CPPlayerController;

var bool bFindPlayer;
var PlayerReplicationInfo MyRealViewTarget;
var config bool bLockRotationToViewTarget;
var config bool bAutoSwitchPlayers;
var config float AutoSwitchPlayerInterval;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (PlayerReplicationInfo!=none)
		PlayerReplicationInfo.bOutOfLives=true;
}

simulated event ReceivedPlayer()
{
	Super.ReceivedPlayer();
	if (Role==ROLE_Authority && WorldInfo.Game!=none)
		ClientSetHUD(WorldInfo.Game.HUDType);
}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.PlayerName="DemoRecSpectator";
	PlayerReplicationInfo.bIsSpectator=true;
	PlayerReplicationInfo.bOnlySpectator=true;
	PlayerReplicationInfo.bOutOfLives=true;
	PlayerReplicationInfo.bWaitingPlayer=false;
}

exec function Slomo(float NewTimeDilation)
{
	WorldInfo.DemoPlayTimeDilation=NewTimeDilation;
}

exec function ViewClass(class<actor> aClass,optional bool bQuiet,optional bool bCheat)
{
local actor other,first;
local bool bFound;

	first=none;
	ForEach AllActors(aClass,other)
	{
		if (bFound || (first==none))
		{
			first=other;
			if (bFound)
				break;
		}
		if (other==ViewTarget)
			bFound=true;
	}
	if (first!=none)
	{
		SetViewTarget(first);
		SetBehindView(ViewTarget!=self);
	}
	else
		SetViewTarget(self);
}

// Called during demo playback
exec function DemoViewNextPlayer()
{
local Pawn P,Pick;
local bool bFound;

	foreach WorldInfo.AllPawns(class'Pawn',P)
	{
		if (P.PlayerReplicationInfo!=none)
		{
			if (Pick==none)
				Pick=P;
			if (bFound)
			{
				Pick=P;
				break;
			}
			else
				bFound=(RealViewTarget==P.PlayerReplicationInfo || ViewTarget==P);
		}
	}
	SetViewTarget(Pick);
}

function SetViewTarget(Actor NewViewTarget,optional ViewTargetTransitionParams TransitionParams)
{
	Super.SetViewTarget(NewViewTarget, TransitionParams);
	if (NewViewTarget!=self)
		MyRealViewTarget=RealViewTarget;
}

unreliable server function ServerViewSelf(optional ViewTargetTransitionParams TransitionParams)
{
	Super.ServerViewSelf(TransitionParams);
	MyRealViewTarget=none;
}

reliable client function ClientSetRealViewTarget(PlayerReplicationInfo NewTarget)
{
	SetViewTarget(self);
	RealViewTarget=NewTarget;
	MyRealViewTarget=NewTarget;
	bFindPlayer=(NewTarget==none);
}

function bool SetPause(bool bPause,optional delegate<CanUnpause> CanUnpauseDelegate=CanUnpause)
{
	if (WorldInfo.NetMode==NM_Client)
	{
		WorldInfo.Pauser=(bPause) ? PlayerReplicationInfo : none;
		return true;
	}
	else
		return false;
}

exec function Pause()
{
	if (WorldInfo.NetMode==NM_Client)
		ServerPause();
}

auto state Spectating
{
	function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		if (bAutoSwitchPlayers)
			SetTimer( AutoSwitchPlayerInterval,true,'DemoViewNextPlayer');
	}

	exec function StartFire(optional byte FireModeNum)
	{
		SetBehindView(true);
		DemoViewNextPlayer();
	}

	/** used to start out the demo view on the local player - should be called when recording, not playback */
	function SendInitialViewTarget()
	{
		local PlayerController PC;

		foreach LocalPlayerControllers(class'PlayerController',PC)
		{
			if (!PC.PlayerReplicationInfo.bOnlySpectator)
			{
				ClientSetRealViewTarget(PC.PlayerReplicationInfo);
				return;
			}
		}
		// send None so demo playback knows it should just pick the first Pawn it can find
		ClientSetRealViewTarget(none);
	}

	simulated event GetPlayerViewPoint(out vector CameraLocation,out rotator CameraRotation)
	{
		Global.GetPlayerViewPoint(CameraLocation,CameraRotation);
	}

	exec function BehindView()
	{
		SetBehindView(!bBehindView);
	}

	event PlayerTick( float DeltaTime )
	{
		local Pawn P;

		Global.PlayerTick(DeltaTime);
		if (Role==ROLE_AutonomousProxy)
		{
			if (RealViewTarget==none && MyRealViewTarget!=none)
				RealViewTarget=MyRealViewTarget;
			if ((RealViewTarget==none || RealViewTarget==PlayerReplicationInfo) && bFindPlayer)
			{
				DemoViewNextPlayer();
				if (RealViewTarget!=none && RealViewTarget!=PlayerReplicationInfo)
					bFindPlayer=false;
			}
			else
			{
				if (RealViewTarget!=none && RealViewTarget!=PlayerReplicationInfo &&
					(Pawn(ViewTarget)==none || Pawn(ViewTarget).PlayerReplicationInfo!=RealViewTarget))
				{
					foreach WorldInfo.AllPawns(class'Pawn',P)
					{
						if (P.PlayerReplicationInfo==RealViewTarget)
						{
							SetViewTarget(P);
							break;
						}
					}
				}
			}
			if (Pawn(ViewTarget)!=none)
			{
				TargetViewRotation=ViewTarget.Rotation;
				TargetViewRotation.Pitch=Pawn(ViewTarget).RemoteViewPitch << 8;
			}
		}
	}
	
Begin:
	if (Role==ROLE_Authority)
	{
		// it takes two ticks to guarantee that all the relevant actors have been recorded into the demo
		// (necessary for the reference in ClientSetRealViewTarget()'s parameter to be valid during playback)
		Sleep(0.0);
		Sleep(0.0);
		SendInitialViewTarget();
	}
}

simulated event GetPlayerViewPoint(out vector CameraLocation,out rotator CameraRotation)
{
	bFreeCamera=(!bLockRotationToViewTarget && (bBehindView || Vehicle(ViewTarget)!=none));
	Super.GetPlayerViewPoint(CameraLocation,CameraRotation);
}

simulated function UpdateRotation(float DeltaTime)
{
local rotator NewRotation;

	if (bLockRotationToViewTarget)
		SetRotation(ViewTarget.Rotation);
	else
		Super.UpdateRotation(DeltaTime);

	if (Rotation.Roll!=0)
	{
		NewRotation=Rotation;
		NewRotation.Roll=0;
		SetRotation(NewRotation);
	}
}

defaultproperties
{
	RemoteRole=ROLE_AutonomousProxy
	bDemoOwner=1
	bBehindView=true
}
