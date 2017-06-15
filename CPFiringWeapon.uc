class CPFiringWeapon extends CPWeapon
	abstract
	notplaceable
	hidedropdown;


var int BurstCount;


simulated state WeaponFiring_Burst extends WeaponFiring
{
	simulated function bool ShouldRefire()
	{
		if ( BurstCount++ < 2 && AmmoCount > 0 )
			return true;

		return super.ShouldRefire();
	}

	simulated event BeginState(name PreviousStateName)
	{
		BurstCount = 0;
		super.BeginState( PreviousStateName );
	}
}

defaultproperties
{
}