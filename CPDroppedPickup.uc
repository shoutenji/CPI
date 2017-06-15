class CPDroppedPickup extends DroppedPickup
	notplaceable;

var PrimitiveComponent			PickupMesh;
var float						StartScale;
var bool						bPickupable;
var LightEnvironmentComponent	MyLightEnvironment;
var const float					MaxPickupRange;
var SoundCue LandedOnFloorSound;

`include(GameAnalyticsProfile.uci);

event PreBeginPlay()
{
	Super.PreBeginPlay();
	bPickupable=(Instigator==none || Instigator.Health<=0);
}

simulated event SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	if (NewPickupMesh!=none && WorldInfo.NetMode!=NM_DedicatedServer)
	{
		PickupMesh=new(self) NewPickupMesh.Class(NewPickupMesh);
		if (class<CPWeapon>(InventoryClass)!=none)
			PickupMesh.SetScale(PickupMesh.Scale);
		PickupMesh.SetLightEnvironment(MyLightEnvironment);
		AttachComponent(PickupMesh);
	}
}

simulated event Landed(vector HitNormal,Actor FloorActor)
{
	local float Offset;
	local vector PickupLocation;

	Super.Landed(HitNormal, FloorActor);
	if (PickupMesh!=none)
	{
		if (class<CPWeapon>(InventoryClass)!=none)
			Offset += class<CPWeapon>(InventoryClass).default.DroppedPickupOffsetZ;

		PickupLocation.Z = Offset;
		PickupLocation.Z -= 5;
		PlaySound(LandedOnFloorSound);
		PickupMesh.SetTranslation(PickupLocation);
	}
}

/**
 * Gives this pickup to a player
 */
function GiveTo( Pawn P )
{
	local CPWeapon	_Weapon;
	local CPPlayerController CPPlayerController;

	// If we are a spectator, don't give us anything
	foreach LocalPlayerControllers(class'CPPlayerController', CPPlayerController)
	{
		if(CPPlayerController != none)
		{
			if(CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bOnlySpectator || CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bIsSpectator)
			{
				return;
			}
		}
	}

	if ( Inventory != none )
	{
		Inventory.AnnouncePickup( P );
		Inventory.GiveTo( P );

		_Weapon = CPWeapon( Inventory );
		if ( _Weapon != none )
			P.SetActiveWeapon( _Weapon );

		Inventory = none;
	}

	PickedUpBy( P );
}

auto simulated state Pickup
{
	simulated function SwapMessageBroadcastTimer()
	{
		local CPPlayerController	_Controller;
		local CPPawn				_Pawn;


		foreach CollidingActors( class'CPPawn', _Pawn, MaxPickupRange )
		{
			_Controller = CPPlayerController( _Pawn.Controller );
			if ( _Controller != none && _Controller.IsLocalPlayerController() )
			{
				_Controller.SendSwapMessageTo( self );
				break;
			}
		}
	}

	simulated function Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local CPWeapon			_Weapon, _PawnWeapon;
		local CPPawn			_Pawn;
		local int				_Clip;
		local CPPlayerController CPPlayerController;

		// If we are a spectator, don't give us anything
		foreach LocalPlayerControllers(class'CPPlayerController', CPPlayerController)
		{
			if(CPPlayerController != none)
			{
				if(CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo) == none)
					return;

				if(CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bOnlySpectator || CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bIsSpectator)
				{
					return;
				}
			}
		}
		
		_Pawn = CPPawn( Other );
		_Weapon = CPWeapon( Inventory );
		if ( _Pawn == none || _Weapon == none )
			return;

		_PawnWeapon = CPWeapon( _Pawn.Weapon );
		if ( _PawnWeapon != none && _Weapon.Class == _PawnWeapon.Class )
		{
			_Clip = Min( _Weapon.MaxClipCount - _PawnWeapon.GetClipCount(), _Weapon.GetClipCount() );	
			if ( _Clip > 0 )
			{
				_Weapon.AddClip( -_Clip );
				_PawnWeapon.AddClip( _Clip );
				_PawnWeapon.PlayClipPickup();
			}
		}
		else if ( ValidTouch( _Pawn ) )
		{
			// We call the super version of GiveTo so the
			// weapon isn't automatically swapped to.
			`if(`bPollPickupEvent)
			if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
				CriticalPointGame(WorldInfo.Game).PollPickupEvent(WorldInfo.TimeSeconds, Pawn(Other).Controller, False, _Weapon);
			`endif
			super.GiveTo( _Pawn );
		}
	}

	simulated function BeginState( name PreviousStateName )
	{
		if ( Role == ROLE_Authority )
			AddToNavigation();

		SetTimer( 1.0, true, 'SwapMessageBroadcastTimer' );
	}

	simulated function EndState( name NextStateName )
	{
		ClearTimer( 'SwapMessageBroadcastTimer' );
	}

	function bool ValidTouch( Pawn Other )
	{
		return bPickupable ? super.ValidTouch( Other ) : false;
	}

	simulated event Landed(vector HitNormal,Actor FloorActor)
	{
		Global.Landed(HitNormal, FloorActor);
		if (Role==ROLE_Authority && !bPickupable)
		{
			bPickupable=true;
			CheckTouching();
		}
	}
}

State FadeOut
{
	simulated event Tick(float DeltaSeconds)
	{
		if (WorldInfo.NetMode==NM_DedicatedServer || PickupMesh==none)
			Disable('Tick');
		else 
			PickupMesh.SetScale(FMax(0.01,PickupMesh.Scale-StartScale*DeltaSeconds));
	}

	simulated function BeginState(Name PreviousStateName)
	{
		bFadeOut=true;
		if (PickupMesh!=none)
			StartScale=PickupMesh.Scale;
		LifeSpan=1.0;
	}
}

defaultproperties
{
	Begin Object NAME=CollisionCylinder
		CollisionRadius=+16.000000
		CollisionHeight=+05.000000
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	Begin Object Class=DynamicLightEnvironmentComponent Name=DroppedPickupLightEnvironment
		bDynamic=false
		bCastShadows=true
		AmbientGlow=(R=0.2,G=0.2,B=0.2,A=1.0)
	End Object
	MyLightEnvironment=DroppedPickupLightEnvironment
	Components.Add(DroppedPickupLightEnvironment)

	bPickupable=true
	bDestroyedByInterpActor=false
	LifeSpan=0.0
	bOrientOnSlope=true

	bAlwaysRelevant = true;

	MaxPickupRange=96.0

	LandedOnFloorSound=SoundCue'CP_Weapon_Sounds.Drops.CP_A_DroppedWeapon_Handgun'
}