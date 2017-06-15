class CPWeaponShotgunAttachment extends CPWeaponAttachment;


var name		ReloadAnim_Mid, ReloadAnim_End;

simulated function CauseShellLaunch() {}

simulated state Reloading
{
	simulated function PlayMidAnimation()
	{
		local class<CPWeaponShotgun>		_WeaponClass;
		local float							_Duration;

		_WeaponClass = class<CPWeaponShotgun>( WeaponClass );
		_Duration = _WeaponClass != none ? _WeaponClass.default.WeaponReloadShellTime : WeaponClass.default.ReloadTime;
		PlayTopHalfAnimationDuration( ReloadAnim_Mid, _Duration,,, true );
	}

	simulated event BeginState( name PreviousStateName )
	{
		super.BeginState( PreviousStateName );
		SetTimer( WeaponClass.default.ReloadTime, false, 'PlayMidAnimation' );
	}

	simulated event EndState( name NextStateName )
	{
		ClearTimer( 'PlayMidAnimation' );
		
		Super.CauseShellLaunch();
	}
}

simulated state ReloadingEmpty
{
	simulated event BeginState( name PreviousStateName )
	{
		GotoState( 'Reloading' );
	}
}

simulated state ReloadingEnd
{
	simulated event BeginState( name PreviousStateName )
	{
		local class<CPWeaponShotgun>		_WeaponClass;


		_WeaponClass = class<CPWeaponShotgun>( WeaponClass );
		if ( _WeaponClass != none )
			PlayTopHalfAnimationDuration( ReloadAnim_End, _WeaponClass.default.WeaponPumpTime );
	}
}

defaultproperties
{
	ReloadAnim_Mid=None
	ReloadAnim_End=None
}