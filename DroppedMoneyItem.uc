class DroppedMoneyItem extends DynamicSMActor_Spawnable;

var SoundCue PickupSound;
var int MoneyValue;
var int MaxMoney; //Use value from CPPlayerReplicationInfo (move this var to CriticalPointGame)
var int TeamIndexValue; // This will be 0 if DroppedMoneyItem_MERC childclass is spawned, and 1 if DroppedMoneyItem_SWAT

`include(GameAnalyticsProfile.uci);

simulated event PostBeginPlay()
{
	local PlayerController PC;
	
	if( Role < ROLE_Authority )
	{
		PC = GetALocalPlayerController();

		// Use TeamIndexValue to check if this object is in fact currently DroppedMoneyItem_MERC or DroppedMoneyItem_SWAT
		// -1 means we are just DroppedMoneyItem eg team visibility is off
		if( TeamIndexValue < 0 || (PC !=None && PC.IsInState('Spectating')) )
		{
			SetStaticMesh( StaticMesh'CP_CashAsset_razMki_01.StaticMesh.SM_CP_CashAsset' ); 
			SetPhysics( PHYS_Falling );
		}
		// Destroy() me if am a DroppedMoneyItem_MERC but the local PC is SWAT, and vice versa
		// Used to enforce team visibility
		else if( PC !=None && !(TeamIndexValue < 0) && TeamIndexValue != PC.PlayerReplicationInfo.Team.TeamIndex )
		{
			bTearOff = True;
			SetHidden(True);
			SetTickIsDisabled(true);
			Destroy();
		}
	}
	else
	{
		SetStaticMesh( StaticMesh'CP_CashAsset_razMki_01.StaticMesh.SM_CP_CashAsset' ); 
		SetPhysics( PHYS_Falling );
	}
}

function SetMoneyAmount(int Amount)
{
	MoneyValue = Amount;
}


event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	local CPPlayerReplicationInfo	_PRI;

	if( CPPawn(Other) == None || CPPawn(Other).Health <= 0)
	{
		return;
	}

	_PRI = CPPlayerReplicationInfo( CPPawn(Other).PlayerReplicationInfo );
	if ( _PRI == none )
		return;
		
	// Allow pick up only if team visibility is off or team visibility is on and Other is on the right team
	if( TeamIndexValue < 0  ||  !(TeamIndexValue < 0) && TeamIndexValue == _PRI.Team.TeamIndex )
	{
		`if(`bPollPickupEvent)
			if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
				CriticalPointGame(WorldInfo.Game).PollPickupEvent(WorldInfo.TimeSeconds, Pawn(Other).Controller, True, , _PRI.Money + MoneyValue >= MaxMoney ? MaxMoney - _PRI.Money : MoneyValue );
		`endif
		_PRI.ModifyMoney(MoneyValue);
		MoneyValue = 0;
		Other.PlaySound( PickupSound );
		Destroy();
	}
}

defaultproperties
{
	bCollideWorld=TRUE;
	TeamIndexValue=-1  // TeamIndexValue > 0 means "team visibility" is on
	MaxMoney=20000

	Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollisionRadius=+02.000000
		CollisionHeight=+0001.000000
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
	
	Begin Object Class=CylinderComponent NAME=CollisionCylinder02
		CollisionRadius=+25.000000
		CollisionHeight=+70.000000
		CollideActors=true
	End Object
	Components.Add(CollisionCylinder02)

	bBlockActors=FALSE
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_pickup_cash_Cue'

	bOrientOnSlope=true
	
}


