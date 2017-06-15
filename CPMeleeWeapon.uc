class CPMeleeWeapon extends CPWeapon
	abstract
	notplaceable
	hidedropdown;

simulated function bool HasAnyAmmo()
{
	//TODO return true when carrying 2 or more
	return false; //fix so if you throw weapons you can select the melee weapons
}


simulated function FireAmmunition()
{
	if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none)
		return;

	PlayFiringSound();
	if ( Role == ROLE_SimulatedProxy || Role == ROLE_Authority )
		PlayFireEffects( CurrentFireMode );

	if (IsInTestMode())
		IncrementFlashCount();
	else
	{
		switch (FireStates[CurrentFireState].FireType[CurrentFireMode])
		{
			case ETFT_InstantHit:
				SetTimer( FireStates[CurrentFireState].FireInterval[0] * 0.25f, false, 'InstantFire' );
				break;
			case ETFT_Projectile:
				ConsumeAmmo(CurrentFireMode);
				SetTimer( FireStates[CurrentFireState].FireInterval[0] * 0.25f, false, 'ProjectileFire' );
				break;
		}
	}
	NotifyWeaponFired(CurrentFireMode);

	if(InvManager != none)
		CPInventoryManager(InvManager).OwnerEvent('FiredWeapon');
}

simulated function StartFireModeSwitch()
{
	if(FireStates[CurrentFireState].FireType[CurrentFireMode] == ETFT_InstantHit)
	{
		if(ClipCount > 0)
			super.StartFireModeSwitch();
	}
	else if(FireStates[CurrentFireState].FireType[CurrentFireMode] == ETFT_Projectile)
	{
		super.StartFireModeSwitch();
	}
}

simulated state Active
{
	simulated function BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if(FireStates[CurrentFireState].FireType[CurrentFireMode] == ETFT_Projectile && ClipCount == 0)
			StartFireModeSwitch();
	}
	simulated function BeginFire( byte FireModeNum )
	{
		if ( FireModeNum == 0 )
			super.BeginFire( FireModeNum );
	}
}

simulated function TimerEarlyReloadNotify();

simulated state WeaponFiring
{
	simulated function BeginFire( byte FireModeNum )
	{
		if ( FireModeNum == 0 )
			super.BeginFire( FireModeNum );		
	}
}

simulated function Projectile ProjectileFire()
{
	local Projectile P;
	local CPMeleeProjectile CPMP;
	local Rotator R;

	P = super.ProjectileFire();
	CPMP = CPMeleeProjectile(P);

	if(CPMP != None)
	{
		CPMP.Velocity *= ((0.15 + (1.0) * (1 - 0.15)) * 0.75);
		R.Pitch = 0.0;
		CPMP.Velocity = CPMP.Velocity >> R;
		CPMP.NetVelocity = CPMP.Velocity;
		
		CPMP.Throw();
	}
	
	return P;
}

defaultproperties
{
	bNoWeaponCrosshair=true

	bAmmoStringNullOnEmpty=false
	
	ReloadTime=0.1
	ReloadEmptyTime=0.1
	bForceReloadWhenEmpty=true
}
