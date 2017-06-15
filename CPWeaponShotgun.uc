class CPWeaponShotgun extends CPWeapon;


/**
 * TempAmmoCount is just to resolve timer resolution
 * errors between the client and server. This caused
 * issues, such as Shotguns pumping before finishing
 * a reload cycle as the server replicated AmmoCount
 */
var int				TempAmmoCount, ShotgunBuyAmmoCount;
var bool			bCancelReload, bShouldPump;
var name			WeaponReloadShellAnim, WeaponPumpAnim, WeaponNoPumpAnim;
var float			WeaponReloadShellTime, WeaponPumpTime;
var SoundCue		WeaponReloadShellSound, WeaponPumpSound, WeaponNoPumpSound;

/**
* This function makes sure to cancel a reload on the server
* @warning This function only works in the 'Reloading' state!
*/
reliable server function ServerCancelReload();

simulated state Reloading
{
	/**
	 * Called once the shotgun is returned to an idle state
	 */
	simulated function FinishedPumping()
	{
		bCancelReload = true;
		if ( bWeaponPutDown )
			PutDownWeapon();
		else
			GotoState( 'Active' );
	}

	simulated function FinishedReloading()
	{
		local SoundCue			_WeaponSound;

		if ( ( bCancelReload || bWeaponPutDown ) && TempAmmoCount > 0 || ClipCount == 0 || TempAmmoCount == MaxAmmoCount )
		{
			SetInstigatorWeaponState( EWS_ReloadingEnd );

			PlayWeaponAnimation( ( bShouldPump && TempAmmoCount > 0 ) ? WeaponPumpAnim : WeaponNoPumpAnim, WeaponPumpTime );
			_WeaponSound = ( bShouldPump && TempAmmoCount > 0 ) ? WeaponPumpSound : WeaponNoPumpSound;
			if ( _WeaponSound != none )
				WeaponPlaySound( _WeaponSound );

			SetTimer( WeaponPumpTime, false, 'FinishedPumping' );
		}
		else
		{
			if ( ClipCount > 0 )
			{
				TempAmmoCount++;
				if ( WorldInfo.NetMode != NM_DedicatedServer )
					AmmoCount = TempAmmoCount;

				ClipCount--;
			}

			PlayWeaponAnimation( WeaponReloadShellAnim, WeaponReloadShellTime );
			if ( WeaponReloadShellSound != none )
				WeaponPlaySound( WeaponReloadShellSound );

			SetTimer( WeaponReloadShellTime, false, 'FinishedReloading' );
		}
	}

	simulated function StartFire( byte FireModeNum )
	{
		bCancelReload = true;
		ServerCancelReload();
	}

	simulated event BeginState( name PreviousStateName )
	{
		bCancelReload = false;
		bShouldPump = AmmoCount == 0;
		TempAmmoCount = AmmoCount;
		super.BeginState( PreviousStateName );
	}
	
	simulated event EndState( name NextStateName )
	{
		AmmoCount = TempAmmoCount;
		ClearTimer( 'FinishedReloading' );
		super.EndState( NextStateName );
	}

	simulated function bool TryPutDown()
	{
		bWeaponPutDown = true;
		return true;
	}

	reliable server function ServerCancelReload()
	{
		bCancelReload = true;
	}
}

defaultproperties
{
	ShotgunBuyAmmoCount=0
	bShellUseAnimNotify=true
}