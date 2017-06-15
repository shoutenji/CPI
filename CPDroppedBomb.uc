class CPDroppedBomb extends CPDroppedPickup	
	notplaceable;

/** Cached reference to the GRI */
var CPGameReplicationInfo   TAGRI;

/** Sound to play when bomb explodes. */
var	SoundCue				ExplosionSound;

/** Effect to play when bomb explodes. */
var ParticleSystem          ExplosionTemplate;

auto simulated state Pickup
{
	simulated event Tick( float DeltaSeconds )
	{
		local CPGameReplicationInfo		_GRI;

		_GRI = CPGameReplicationInfo( WorldInfo.GRI );
		
		if( _GRI != none && _GRI.RemainingBombDetonatonTime <= 0 )
		{
			GotoState( 'Explode' );
		}
	}

	simulated function Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		if( Other != none && Other.GetTeamNum() != TTI_Mercenaries )
			return;

		super.Touch( Other, OtherComp, HitLocation, HitNormal );
	}

	function bool ValidTouch( Pawn Other )
	{
		local CPWeap_Bomb	_Bomb;
		
		_Bomb = CPWeap_Bomb( Inventory );
		if ( _Bomb != none && _Bomb.IsPlanted() )
			return false;

		return super.ValidTouch( Other );
	}
}

simulated state Explode extends Pickup
{
	simulated event BeginState( name PreviousStateName )
	{
		local ParticleSystemComponent  PSE;

		if(PickupMesh != none)
		{
			PickupMesh.SetHidden(true);
			PickupMesh = none;
		}

		if (WorldInfo.NetMode != NM_DedicatedServer)  //dont play the effects on the servers.
		{
			PSE = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, Location, Rotation);
			PSE.SetScale(3.0); //scaled up because we are using the nade explosion atm

			PlaySound(ExplosionSound, TRUE);
		}
		
		//TODO a few hurt radiuses for those that are too close...
		HurtRadius( 50.0, 500.0, class'CPDamageType', 1000.0, Location,,, True );
	}

	function bool ValidTouch( Pawn Other )
	{
		return false;
	}
}

defaultproperties
{
	ExplosionSound=SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombExplosion_Cue'
	ExplosionTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_C4_Explosive' 
}
