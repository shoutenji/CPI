class CPMeleeProjectile extends CPProjectile
	abstract;

var vector rSpin;
var class<CPMeleePickup> MeleePickupClass;
var repnotify vector AngVelocity;
var repnotify vector NetLocation, NetVelocity;
var float ThetaThreshold;

var StaticMeshComponent MeshComp;

replication
{
	if (Role==ROLE_Authority && bNetInitial)
		AngVelocity;
	if (Role==ROLE_Authority && bNetDirty)
		NetLocation, NetVelocity;
}

simulated event ReplicatedEvent(name VarName)
{
	if( VarName == 'NetLocation' )
	{
		MeshComp.SetRBPosition(NetLocation);
	}
	else if( VarName == 'NetVelocity' )
	{
		MeshComp.SetRBLinearVelocity(NetVelocity);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function Throw()
{
	if(MeshComp.BodyInstance == None || !MeshComp.BodyInstance.IsValidBodyInstance())
	{
		Destroy();
		return;
	}
	MeshComp.WakeRigidBody();
	MeshComp.SetRBLinearVelocity(Velocity, false);
	MeshComp.SetRBAngularVelocity(rSpin, false);
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	SetPhysics(PHYS_RigidBody);
	MeshComp.SetRBCollidesWithChannel(RBCC_Default, true);
	MeshComp.SetRBCollidesWithChannel(RBCC_EffectPhysics, false);
	MeshComp.SetRBCollidesWithChannel(RBCC_Pawn, false);
	MeshComp.SetRBCollidesWithChannel(RBCC_Untitled3, false);
}

function Tick(float DeltaTime)
{
	local Vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local Actor Other;
	local float Dampen;
	local CPMeleePickup CPMP;

	super.Tick(DeltaTime);

	Other = Trace( HitLocation, HitNormal, Location + Velocity * DeltaTime, Location, true, vect( 2, 2, 2 ), HitInfo, TRACEFLAG_Bullet );
	if ( Other != none )
	{		
		//Hit A Wall
		Dampen = ( HitInfo.PhysMaterial == none ) ? 0.5 : 1.0 - HitInfo.PhysMaterial.Friction;
		MeshComp.SetRBLinearVelocity( MirrorVectorByNormal( Velocity, HitNormal ) * Dampen, false );
	}
	
	if(Velocity.y > 0.0 && Velocity.y < 8.0)
	{

		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		SetCollisionSize(0.0, 0.0);
		
		CPMP = Spawn(MeleePickupClass,,,self.Location+vect(0,32,0), self.Rotation);
		
		if(CPMP != none)
			CPMP.Init(Instigator.GetTeamNum());
		
		Destroy();
		
	}
}

simulated function ProcessTouch(Actor Other,Vector HitLocation,Vector HitNormal)
{
	if(Other.IsA('CPPawn'))
	{
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer*Normal(Velocity),MyDamageType,,self);
		Destroy();
	}
	else
	{
		MeshComp.SetRBLinearVelocity(-Velocity * 0.2, false);
	}
}

simulated event Landed(vector HitNormal,actor FloorActor)
{}

simulated event HitWall (Vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{}

simulated function StickInWall(Vector HitNormal)
{
	//local CPMeleePickup CPMP;
	
	//local rotator OutOfWall;
	//OutOfWall = rotator(HitNormal);
	//OutOfWall.Pitch += 16384;

	//CPMP = Spawn(MeleePickupClass,,,self.Location);
	
	//if(CPMP != none)
		//CPMP.Init(Instigator.GetTeamNum());
	
	//Destroy();
}

DefaultProperties
{
	Damage=34;
	
	Speed=256.00
	MaxSpeed=512.00
	
	ThetaThreshold=64
	
	rSpin=(X=0,Y=-1000,Z=0)
	
	MeleePickupClass=class'CPMeleePickup'
	
	bNetTemporary=False
	bCollideWorld=False
	bCollideComplex=False
	bNoEncroachCheck=True
	LifeSpan=10.000000
	
	TickGroup=TG_PostAsyncWork
}