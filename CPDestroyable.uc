class CPDestroyable extends FracturedStaticMeshActor
	hidecategories(Object)
	hidecategories(Debug)
	hidecategories(Movement)
	hidecategories(Display)
	hidecategories(Attachment)
	hidecategories(Collision)
	hidecategories(Physics)
	hidecategories(Advanced)
	hidecategories(FracturedStaticMeshActor)
	AutoExpandCategories(CPDestroyable);

// TA Destroyable
var() CPDummyStaticMeshComponent FracturedStaticMesh;
var() int Health;
var int CurrentHealth;
var() bool UseBrokenState;
var() float BrokenStateHealthPct;		// only used if UseBrokenState is true
var repnotify int meshState;            // replicated server side state
var int lastMeshState;                  // NON-replicated client side ( last known ) state

// Fractured Static Mesh Warpers
var() SoundCue LargeExplosionSound;
var() SoundCue SingleFractureSound;
var() array<ParticleSystem>	DestroyEffects;
var const editconst DynamicLightEnvironmentComponent LightEnvironment;

replication
{   
	if (Role==ROLE_Authority)
		meshState;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName=='meshState')
	{
		updateMeshState();			// we call this whenever the state ( the server thinks is the current )  arrives
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated event PostBeginPlay()
{
	FracturedStaticMeshComponent.SetStaticMesh(FracturedStaticMesh.StaticMesh);
	OverrideFragmentDestroyEffects=DestroyEffects;
	ExplosionFractureSound=LargeExplosionSound;
	SingleChunkFractureSound=SingleFractureSound;
	DetachComponent(FracturedStaticMesh);
	meshState=1; // we only use 0 as a placeholder so the 'healthy' state is 1
	lastMeshState=meshState;
	CurrentHealth=Health;
	super.PostBeginPlay();
}


simulated event TakeDamage(int Damage,Controller EventInstigator,vector HitLocation,vector Momentum,class<DamageType> DamageType,optional TraceHitInfo HitInfo,optional Actor DamageCauser)
{
	local bool bStateChanged;

	if (Role<ROLE_Authority)
	{
		return;
	}
	CurrentHealth-=Damage;

	if (meshState == 1)
	{
		if(UseBrokenState && (float(CurrentHealth)/float(Health))<=BrokenStateHealthPct)
		{
			meshState=2;
			bStateChanged=true;				
		}
		else if(CurrentHealth<=0)
		{
			meshState=3;
			bStateChanged=true;
		}
	}
	else if (CurrentHealth<=0)
	{
		meshState=3;
		bStateChanged=true;
	}

	if (bStateChanged)
	{
		UpdateMeshState();
	}
}

// the game info calls Reset on all actors ( for exceptions see ResetLevel function in CriticalPointGame ) because
// this is server only we need to update here and the replication will take care of letting the clients know about this.
function Reset()
{
	meshState=1;
	UpdateMeshState();
}

simulated function UpdateMeshState()
{
	local array<byte> visibleBytes;
	local int i;
	

	if (lastMeshState!=meshState)
	{
		if (lastMeshState==1 && meshState==2 && WorldInfo.NetMode != NM_DedicatedServer)  // if it was NORMAL and we BROKE it and it's a client
		{
			ExecuteBrokenState();
		}
		if ((lastMeshState==1 || lastMeshState==2) && meshState==3 && WorldInfo.NetMode != NM_DedicatedServer) // if it was NORMAL or BROKEN and it's a client, we DESTROY it
		{
			// If its in view, then do the explode animation
			if(WorldInfo.TimeSeconds - FracturedStaticMeshComponent.LastRenderTime < 2.0)
			{
				Explode();
			}
			// Otherwise just remove
			else
			{		
				// Set fracture pieces invisible
				visibleBytes = FracturedStaticMeshComponent.GetVisibleFragments();
				for(i=0; i<visibleBytes.length; i++)
				{
					visibleBytes[i] = 0;
				}			
				
				FracturedStaticMeshComponent.SetVisibleFragments(visibleBytes);
			}

			// Turn off collision
			SetCollisionType(COLLIDE_NoCollision);	
		}
		if ((lastMeshState==3 || lastMeshState==2) && meshState==1) // if it was DESTROYED or BROKEN we restore it to NORMAL
		{
			RestoreNormalState();
		}
		lastMeshState=meshState;
	}
}

simulated function RestoreNormalState()
{
	CurrentHealth=Health;
	ResetVisibility();
	SetCollisionType(COLLIDE_BlockAll);	
}

simulated function ExecuteBrokenState()
{
	local int randomFragmentAmount;
	local int randomIndex;
	local array<byte> FragmentVis;
	local int i;
	local vector SpawnDir;
	local FracturedStaticMesh FracMesh;
	local FracturedStaticMeshPart FracPart;
	local float PartScale;

	FracMesh=FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);
	FragmentVis=FracturedStaticMeshComponent.GetVisibleFragments();
	randomFragmentAmount=FragmentVis.length/10;

	for (i=0;i<randomFragmentAmount;i++)
	{
		randomIndex=Rand(FragmentVis.length);

		if ((FragmentVis[randomIndex]!=0) && (randomIndex!=FracturedStaticMeshComponent.GetCoreFragmentIndex()))
		{
			SpawnDir=FracturedStaticMeshComponent.GetFragmentAverageExteriorNormal(randomIndex); // This causes an error on the server if called
			PartScale=FracMesh.ExplosionPhysicsChunkScaleMin+FRand()*(FracMesh.ExplosionPhysicsChunkScaleMax-FracMesh.ExplosionPhysicsChunkScaleMin);
			FracPart=SpawnPart(randomIndex,(0.5*SpawnDir*FracMesh.ChunkLinVel)+Velocity,0.5*VRand()*FracMesh.ChunkAngVel,PartScale,TRUE);
			if (FracPart!=none)
			{
				FracPart.FracturedStaticMeshComponent.SetRBCollidesWithChannel(RBCC_FracturedMeshPart, FALSE);
			}
			FragmentVis[randomIndex]=0;
		}
	}
	FracturedStaticMeshComponent.SetVisibleFragments(FragmentVis); 	
}

DefaultProperties
{
	RemoteRole=ROLE_SimulatedProxy
	Health=100
	CurrentHealth=100
	BrokenStateHealthPct=0.5
	UseBrokenState = false

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	Begin Object Class=CPDummyStaticMeshComponent Name=StaticMeshComponent0
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	CollisionComponent=StaticMeshComponent0
	FracturedStaticMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
}
