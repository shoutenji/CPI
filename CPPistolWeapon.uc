class CPPistolWeapon extends CPFiringWeapon;

var SkelControlSingleBone PistolTopChamber;

var bool bChamberedWeapon; //Affects idle animations when a weapon is empty and needs an emptyidle animation instead of an idle animation
var float fChamberToFullTime, fChamberToEmptyTime;
var(Animations) array<name> WeaponEmptyIdleAnims;
var(Animations) array<name> ArmEmptyIdleAnims;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	PistolTopChamber=SkelControlSingleBone(SkelComp.FindSkelControl('PistolTop'));

	if(PistolTopChamber != none)
		PistolTopChamber.SetSkelControlActive(false); //make sure we start with it not looking empty
}

simulated function SetPistolTopChamberToEmpty()
{
	if(PistolTopChamber != none)
	{
		PistolTopChamber.SetSkelControlActive(true); //make sure we start with it not looking empty
	}
}

simulated function SetPistolTopChamberToFull()
{
	if(PistolTopChamber != none)
	{
		PistolTopChamber.SetSkelControlActive(false); //make sure we start with it not looking empty
	}
}

unreliable client function SetChamber()
{
	SetPistolTopChamberToFull();
}

unreliable client function SetChamberEmpty()
{
	SetPistolTopChamberToEmpty();
}

simulated state Reloading
{
	simulated event BeginState( name PreviousStateName )
	{
		super.BeginState(PreviousStateName);
		
		if( bChamberedWeapon )
			SetTimer( fChamberToFullTime, false, 'SetChamber' );

	}
}

simulated state Active
{
	simulated event BeginState(name PreviousStateName)
	{
		if(PreviousStateName == 'Reloading')
			SetInstigatorWeaponState(EWS_None);
			
		Super.BeginState(PreviousStateName);
	}
    simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		//Idle animation is different for empty chambered weapons, they need to appear empty.
		if( bChamberedWeapon && AmmoCount == 0)
		{
			//setting the index to just 0 here - we still can have cool idle anims but for now its just the first idle animation.
			
			if (ArmsAnimSet!=none && WeaponEmptyIdleAnims[0] != '' && ArmEmptyIdleAnims[0] != '')
			{
				PlayWeaponAnimation(WeaponEmptyIdleAnims[0],0.0,false);
				PlayArmAnimation(ArmEmptyIdleAnims[0],0.0,,false);
			}
			else
			{
				`Log("CPPistolWeapon::Active::OnAnimEnd");
				`LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
				`Log("ARM ANIMATION IS " @ WeaponEmptyIdleAnims[0]);
				`Log("WEP ANIMATION IS " @ ArmEmptyIdleAnims[0]);
			}
		}
		else
		{
			super.OnAnimEnd(SeqNode,PlayedTime,ExcessTime);
		}
	}
}

simulated function PlayFireEffects(byte FireModeNum,optional vector HitLocation)
{
	if (FireModeNum==0)
	{
		//we look for the ammocount to be 1 so we can chamber the weapon during the last shot - this stops the animations flicking too noticiblly ingame.
		if(bChamberedWeapon && AmmoCount == 1)
		{
			//need to slide this back a little earlier than the actual finished reloading...
			SetTimer(fChamberToEmptyTime,false,nameof(SetChamberEmpty));
		}
	}
	super.PlayFireEffects(FireModeNum,HitLocation);
}
DefaultProperties
{
	bChamberedWeapon=false
	fChamberToFullTime= 0.0
	fChamberToEmptyTime=0.0

	WeaponEmptyIdleAnims(0)=WeaponIdle 
	ArmEmptyIdleAnims(0)=WeaponIdle 
}
