class CPProj_Grenade extends CPProjectile;

// Set by weapon
var repnotify float FuseTime;

var StaticMeshComponent GrenadeMeshComp;

// We can specify how "spinny" we want our grenade to be.
var repnotify vector AngVelocity;

// Next bounce we can play
var float NextSoundTime;

var vector LastHitLocation, LastHitNormal;

var repnotify vector NetLocation, NetVelocity;
var float LastGrenadeNetFixTime;
var SoundCue WallBounceSound;

replication
{
	if (Role==ROLE_Authority && bNetInitial)
		FuseTime, AngVelocity;
	if (Role==ROLE_Authority && bNetDirty)
		NetLocation, NetVelocity;
}

simulated event ReplicatedEvent(name VarName)
{
	if( VarName == 'FuseTime' )
	{
		LaunchGrenade();
	}
	else if( VarName == 'NetLocation' )
	{
		GrenadeMeshComp.SetRBPosition(NetLocation);
	}
	else if( VarName == 'NetVelocity' )
	{
		GrenadeMeshComp.SetRBLinearVelocity(NetVelocity);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function LaunchGrenade()
{
	//`log("INSIDE THE LAUNCHGRENADE FUNC!!!");
	if(GrenadeMeshComp.BodyInstance == None || !GrenadeMeshComp.BodyInstance.IsValidBodyInstance())
	{
		Destroy();
		return;
	}
	SetTimer(FuseTime, false);
	GrenadeMeshComp.WakeRigidBody();
	GrenadeMeshComp.SetRBLinearVelocity(Velocity, false);
	GrenadeMeshComp.SetRBAngularVelocity(AngVelocity, false);
	//`log("[GRENADE] HAS BEEN LAUNCHED WITH VELOCITY: "$Velocity);
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetPhysics(PHYS_RigidBody);
	GrenadeMeshComp.SetRBCollidesWithChannel(RBCC_Default, true);
	GrenadeMeshComp.SetRBCollidesWithChannel(RBCC_EffectPhysics, false);
	GrenadeMeshComp.SetRBCollidesWithChannel(RBCC_Pawn, false);
	GrenadeMeshComp.SetRBCollidesWithChannel(RBCC_Untitled3, false);
}

simulated event Timer()
{
	Explode(Location, vect(0,0,1));
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	GrenadeMeshComp.SetRBLinearVelocity(-Velocity * 0.2, false);
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp) {}

simulated event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	if(VSizeSq(Velocity) > 10000)
	{
		if(WorldInfo.TimeSeconds >= NextSoundTime && (OtherComponent==None || OtherComponent.RBChannel != RBCC_EffectPhysics))
		{
			WallBounceSound.VolumeMultiplier = 30.0;
			PlaySound(WallBounceSound);
			NextSoundTime = WorldInfo.TimeSeconds + 0.10;
		}
		if(Role == ROLE_Authority && (WorldInfo.TimeSeconds-LastGrenadeNetFixTime) > 0.5)
		{
			LastGrenadeNetFixTime = WorldInfo.TimeSeconds;
			NetLocation = Location;
			NetVelocity = Velocity;
		}
	}
}

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
	Super.SetExplosionEffectParameters(ProjExplosion);
	ProjExplosion.SetScale(1.5);
}

simulated function GrenadeHitPawn(Pawn P, Vector HitLoc, Vector HitNorm)
{
	Velocity = 0.1 * (Velocity - 2.0 * HitNorm * (Velocity dot HitNorm));
	if(P != None)
		Velocity += P.Velocity;
	GrenadeMeshComp.SetRBLinearVelocity( Velocity, false );
}

/**
 * Some things to make sure grenade does what it's supposed to...
 */
simulated event Tick( float DeltaTime )
{
	local Vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local Actor Other;
	local float Dampen;

	super.Tick(DeltaTime);

	Other = Trace( HitLocation, HitNormal, Location + Velocity * DeltaTime, Location, true, vect( 2, 2, 2 ), HitInfo, TRACEFLAG_Bullet );
	if ( Other != none )
	{		
		//`log( "CProj_Grenade::Tick: Hit a wall" );
		Dampen = ( HitInfo.PhysMaterial == none ) ? 0.5 : 1.0 - HitInfo.PhysMaterial.Friction;

		//GrenadeMeshComp.SetRBPosition( HitLocation );
		GrenadeMeshComp.SetRBLinearVelocity( MirrorVectorByNormal( Velocity, HitNormal ) * Dampen, false );
	}

	// Attach any effects to grenade (fuse?)
	if(ProjEffects != None)
	{
		ProjEffects.SetTranslation(Location + (Vect(0,0,12) >> Rotation));
		ProjEffects.SetRotation(Rotation);
	}
}

simulated function SpawnFlightEffects()
{
	if(WorldInfo.NetMode != NM_DedicatedServer && ProjEffects != None)
	{
		ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
		AttachComponent(ProjEffects);
		ProjEffects.ActivateSystem();
	}
}

defaultproperties
{
	// BASICS
	/*
	ImpactSound=SoundCue''
	ProjExplosionTemplate=ParticleSystem''
	*/

	WallBounceSound=SoundCue'CP_Weapon_Sounds.Grenades.CP_A_Grenade_Drop_Cue'
	ExplosionSound=SoundCue'CP_Weapon_Sounds.Grenades.GrenadeExpolsion_Cue'
	//ProjExplosionTemplate=ParticleSystem'TA_Molez_Particles.PS_CP_Hand_Grenade'
	
	Begin Object Class=StaticMeshComponent Name=StaticMeshComp
		StaticMesh=StaticMesh'TA_WP_FlashBang.Mesh.SM_TA_FlashBang_Pickup'
		bNotifyRigidBodyCollision=True
		Scale=2.0
		ScriptRigidBodyCollisionThreshold=5.000000
	End Object
	GrenadeMeshComp=StaticMeshComp
	bAttachExplosionToVehicles=False

	CylinderComponent=CollisionCylinder
	Components(0)=CollisionCylinder
	Components(1)=StaticMeshComp
	// FUSE
	/*
	Begin Object Class=UDKParticleSystemComponent Name=FuseEffectComponent
		Template=ParticleSystem''
		bAutoActivate=False
		AbsoluteTranslation=True
		AbsoluteRotation=True
	End Object
	ProjEffects=FuseEffectComponent*/

	// DECAL
	/*
	ExplosionDecal=MaterialInstanceTimeVarying''
	DecalWidth=128.000000
	DecalHeight=128.000000
	*/
	
	Speed=1600.000000
	MaxSpeed=2048.000000
	bSwitchToZeroCollision=False

	Damage=180.000000
	DamageRadius=512.000000
	MomentumTransfer=75000.000000
	MyDamageType=Class'CPDmgType_Default'

	Physics=PHYS_RigidBody
	bNetTemporary=False
	bCollideWorld=False
	bCollideComplex=False
	bNoEncroachCheck=True
	LifeSpan=12.000000
	
	//CollisionComponent=CollisionCylinder
	CollisionComponent=StaticMeshComp

	TickGroup=TG_PostAsyncWork
}
