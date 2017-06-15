class CPHostagePawn extends CPPawn;

var repnotify name RemoteAnimation;
var bool bAICanMove;

var array< class<CPFamilyInfo> > HOSTFamArray;

replication
{
	if ( bNetInitial || bNetDirty )
		RemoteAnimation, bAICanMove;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'RemoteAnimation')
	{
		if(RemoteAnimation != '')
		{
			if(RemoteAnimation == 'HostageRise')
			{
				HostageRise();
			}
			else if(RemoteAnimation == 'HostageCapture')
			{
				HostageCapture();
			}
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	//SetPhysics(PHYS_RigidBody);
	Mesh.WakeRigidBody();
	SetMovementPhysics();
}

//Set our character class from our family info, e.g. set which skeletalmesh, animationset, etc. our character uses
simulated function SetCharacterClassFromInfo(class<CPFamilyInfo> Info)
{
   Super.SetCharacterClassFromInfo(HOSTFamArray[Rand(HOSTFamArray.Length)]);
   HelmetMesh = none;
   VestMesh = none;
}

simulated function HostageSetup()
{
	if(Walking_WeaponBlend != none)
		Walking_WeaponBlend.SetBlendTarget( 0.0, 0.0 );
		
	ClearTimer('HostageAnimationEnd');
	
	bIgnoreForces=true;
}

simulated function HostageRise(optional float duration = 4.8)
{
	RemoteAnimation = 'HostageRise';
	HostageSetup();
	HostageCustomAnimation('HostageRise', duration);
	bAICanMove = false;
	
	//SetCollisionSize(GetCollisionRadius(),CylinderComponent.Default.CollisionHeight); //TODO SET DEFAULT COLLISION HEIGHT FOR HOSTAGE PAWNS
	SetTimer(4.9, false, 'HostageAnimationEnd');
	SetBaseEyeheight();
}

simulated function HostageAnimationEnd()
{
	ReattachMesh();
	HostageSetup();

	bAICanMove = true;
	bIgnoreForces=false;
}

simulated function HostageCapture(optional float duration = 2.0)
{
	RemoteAnimation = 'HostageCapture';
	bAICanMove=false;
	HostageSetup();
	HostageCustomAnimation('HostageCapture', duration);
	SetBaseEyeheight();
}

simulated function HostageCustomAnimation(name Animation, float Duration)
{
	if(FullBodyAnimSlot != none)
		FullBodyAnimSlot.PlayCustomAnimByDuration(Animation, Duration, 0.05, -1.0, false, true);
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if(RemoteAnimation != '')
	{
		if(RemoteAnimation == 'HostageCapture')
		{
			HostageCapture(0.1);
		}
		else if (RemoteAnimation == 'HostageRise')
		{
			HostageRise(0.1);
		}
		else
		{
			`Log("CPHostagePawn::RemoteAnimation unknown in PostInitAnimTree");
		}
	}
}

DefaultProperties
{	
	CrouchHeight=24
	MaxStepHeight= 20   
	MaxJumpHeight = 64
	HOSTFamArray[0]=class'CP_HOST_MaleOne'
}
