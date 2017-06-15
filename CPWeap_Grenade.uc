class CPWeap_Grenade extends CPThrowingWeapon;

var float FullChargeTime;
var float ChargeStartTime;
var byte FireModeReleasing;

var name GrenadeReadyAnim;
var float ReadyAnimTime;

var float FuseTime;

var bool bCancelThrow;

var float GrenadeMinVelocityPerc;
var float GrenadeVelocityMultiplier;
var float GrenadePitchOffset;

replication
{
	if ( bNetDirty )
		bCancelThrow;
}

/**
 * Reset the weapon to a neutral state
 */
simulated function Reset()
{
	SetCancelThrow();
	super.Reset();
}

function SetCancelThrow()
{
	bCancelThrow = !bCancelThrow;
	ClientSetCancelThrow();
}

reliable client function ClientSetCancelThrow()
{
	if(Role == ROLE_Authority)
		return;

	bCancelThrow = !bCancelThrow;
	EndFire(0);
}

// RMB resets charge timer (client)
reliable client function ClientStartCharge()
{
	if(IsFiring() && CurrentFireMode == 0)
	{
		// ANIMS
	}
	else
	{
		// ANIMS
	}
	ChargeStartTime = WorldInfo.TimeSeconds;
}

// RMB resets charge timer (server)
reliable server function ServerReload()
{
	if(ChargeStartTime == 0 && (IsFiring() || IsInState('Active')))
	{
		ChargeStartTime = WorldInfo.TimeSeconds;
		if(!IsFiring())
			GotoState('Charging');
		ClientStartCharge();
	}
}

simulated function BeginFire(byte FireModeNum)
{
	if(FireModeNum == 1)
	{
		ServerReload();
	}	
	super.BeginFire(FireModeNum);
}

// simulated event Tick(float DeltaTime)
// {
    // Super.Tick(DeltaTime);
    // `Log("@@ "$string(GetStateName()));
// }


simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
    super.PlayFireEffects( FireModeNum, HitLocation );
	if(ROLE != ROLE_Authority)
		ChargeStartTime = 0;
}

simulated event float GetPowerPerc()
{
	if(ChargeStartTime > 0)
		return FClamp((WorldInfo.TimeSeconds - ChargeStartTime) / FullChargeTime, 0.0, 1.0);
	return 0;
}

reliable server function Projectile ServerSpawnGrenadeProjectile(vector RealStartLoc){
	local vector        StartTrace, EndTrace, AimDir;
    local ImpactInfo    TestImpact;
    local Projectile    SpawnedProjectile;
	local CPProj_Grenade G;
	local Rotator R;	

        StartTrace = Instigator.GetPawnViewLocation();
        AimDir = Vector( AddSpread( GetAdjustedAim( StartTrace ) ) ) * GetTraceRange();

        if( StartTrace != RealStartLoc )
        {
            // if projectile is spawned at different location of crosshair,
            // then simulate an instant trace where crosshair is aiming at, Get hit info.
            EndTrace = StartTrace + AimDir * GetTraceRange();
            TestImpact = CalcWeaponFire( StartTrace, EndTrace );

            // Then we realign projectile aim direction to match where the crosshair did hit.
            AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
        }

        // Spawn projectile
        SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
        if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
        {
            SpawnedProjectile.Init( AimDir );
        }

		G = CPProj_Grenade(SpawnedProjectile);

		if(G != None)
		{
			G.Velocity *= ((GrenadeMinVelocityPerc + (FMin(1.0, GetPowerPerc())) * (1 - GrenadeMinVelocityPerc)) * GrenadeVelocityMultiplier);
			R.Pitch = DegToUnrRot * GrenadePitchOffset;
			G.Velocity = G.Velocity >> R;
			G.FuseTime = FuseTime;
			G.LaunchGrenade();
		}
		ChargeStartTime = 0;
        return G;

    if ( CurrentFireAmmoMode == FA_Normal )
        AddRecoil( CurrentFireMode );

    return None;
}

simulated function PlayWeaponPutDown(){
	if(ammoCount > 0)
		super.PlayWeaponPutDown();
}

simulated function Projectile ProjectileFire()
{
	local vector        myloc;
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
    local CPPawn cpp;

    cpp = CPPawn(Instigator);
    compo = cpp.ArmsMesh[0];
	//compo = cpp.mesh;
    if (compo != none)
    {	
        socket = compo.GetSocketByName('WeaponPoint');
        if (socket != none)
        {
			//`log("found Socket");
            myloc = compo.GetBoneLocation(socket.BoneName);
			//`log(myloc);
			return ServerSpawnGrenadeProjectile(myloc);
        }
    }
	return none;
}

simulated function ThrowAnimationFinished()
{
	`Log("WARNING OUT OF SYNC TIMER DETECTED! CPWEAP_GRENADE.ThrowAnimationFinished() - CODE WAS NOT CALLED BECAUSE OF THIS! (GOTOSTATE:ACTIVE)");
}


/**
 * So we can hold fire for as long as we like!
 */
simulated state Charging
{
	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function bool TryPutdown()
	{
		bWeaponPutDown = true;
		return true;
	}
    
    simulated function ReleaseFire(byte FireModeNum)
	{
        FireModeReleasing = FireModeNum;
        GoToState('WeaponFiring');
    }
    
	
	simulated function BeginState(Name PreviousStateName)
	{
		local CPPawn _Pawn;

		_Pawn = CPPawn( Instigator );
		if ( _Pawn != none )
			_Pawn.SetWeaponState( EWS_Charging );
        
		PlayWeaponAnimation(GrenadeReadyAnim, ReadyAnimTime);
		ChargeStartTime = WorldInfo.TimeSeconds;
	}

	simulated function EndState(Name NextStateName)
	{
		local CPPawn	_Pawn;

        _Pawn = CPPawn( Instigator );
		if ( _Pawn != none )
        {
			_Pawn.SetWeaponState( EWS_Firing );
        }
	}

	simulated function BeginFire(byte FireModeNum)
	{
		global.BeginFire(FireModeNum);
	}
}

simulated state Active
{
	simulated function bool CanIdleInterrupt(name PreviousStateName)
	{
		return (PreviousStateName != 'Charging') && super.CanIdleInterrupt(PreviousStateName);
	}
}

simulated state WeaponFiring
{
	simulated function ThirdPersonFireEffects();

	simulated function ThrowAnimationFinished()
	{
        local CPPawn	_Pawn;

        _Pawn = CPPawn( Instigator );
        GotoState( 'Inactive' );
	}
    
    simulated function PlayMidAnimation()
	{
		local CPPawn    _Pawn;
        local CPWeaponAttachmentGrenade _WeaponAttachment;
        
        if( Instigator == None)
        {
            `Log("@@ error_23");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_24");
            return;
        }
        _WeaponAttachment = CPWeaponAttachmentGrenade(_Pawn.CurrentWeaponAttachment);
        _WeaponAttachment.PlayTopHalfAnimation(_WeaponAttachment.FireAnim_Mid,,,, true );
        //TODO prolly set this to a timer 
        EndFire(FireModeReleasing);
	}

	simulated event BeginState( name PreviousStateName )
	{
		// local class<CPWeap_Grenade>		_WeaponClass;
        local CPPawn    _Pawn;
        local CPWeaponAttachmentGrenade _WeaponAttachment;
        
        if( Instigator == None)
        {
            `Log("@@ error_25");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_26");
            return;
        }
        
        
        _WeaponAttachment = CPWeaponAttachmentGrenade(_Pawn.CurrentWeaponAttachment);
        PlayMidAnimation();
        
		_WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.FireAnim, ReadyAnimTime,,, true );
		//SetTimer( ReadyAnimTime, false, 'PlayMidAnimation' );
	}

	simulated event EndState( name NextStateName )
	{
		local CPPawn _Pawn;
        if( Instigator == None)
        {
            `Log("@@ error_31");
            return;
        }
        _Pawn = CPPawn(Instigator);
        ClearTimer( 'PlayMidAnimation' );
        FireModeReleasing = default.FireModeReleasing;
         
        //`Log("@@ CurrentWeapon == "$_Pawn.Weapon.Name);
        //_Pawn.SetWeaponState( EWS_None );
		super.EndState( NextStateName );
	}
    
    simulated function EndFire(byte FireModeNum)
	{
		local CPPawn	_Pawn;

		Global.EndFire(FireModeNum);

		if(bCancelThrow)
		{
            bCancelThrow=false;
			ChargeStartTime=0;
			GotoState('Active');

			if (WeaponIdleAnims[0] != '' && ArmsAnimSet != none && ArmIdleAnims[0] != '')
			{
				PlayWeaponAnimation(WeaponIdleAnims[0],0);
				PlayArmAnimation(ArmIdleAnims[0],0);
			}
			else
			{
				`Log("CPWeap_Grenade::EndFire::HeldFireCharging");
				`LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
				`Log("ARM ANIMATION IS " @ ArmIdleAnims[0]);
				`Log("WEP ANIMATION IS " @ WeaponIdleAnims[0]);
			}

			return;
		}

		if ( FireModeNum == CurrentFireMode )
		{
			if ( AmmoCount > 0 )
			{
				FireAmmunition();
				//PlayWeaponAnimation(GrenadeThrowAnim, ThrowAnimTime);
				_Pawn = CPPawn( Instigator );
				if ( _Pawn != none )
				{
                    //_Pawn.SetWeaponState( EWS_ReloadingEnd );
                    //_Pawn.SetWeaponState( EWS_None );
					SetTimer( GetFireInterval( FireModeNum ), false, 'ThrowAnimationFinished' );
					SetTimerLog(GetFireInterval( FireModeNum ),false,'ThrowAnimationFinished');
				}
			}
		}
		else
		{
			//`Log("hey mom im the RMB!!!");
			ChargeStartTime = WorldInfo.TimeSeconds;
		}
	}
}

simulated state Inactive
{
    simulated event BeginState( name PreviousStateName )
    {
        local CPPawn _Pawn;
        
        if( Instigator == None)
        {
            `Log("@@ error_40");
            return;
        }
        _Pawn = CPPawn(Instigator); 
        if (PreviousStateName == 'WeaponFiring' && _Pawn != none && _Pawn.Controller != None && CPPlayerController(_Pawn.Controller) != None )
        {
            CPPlayerController(_Pawn.Controller).SwitchToLastWeapon(true);
        }
        Super.BeginState(PreviousStateName);
    }
}

simulated state ReloadingEnd
{
	simulated event BeginState( name PreviousStateName )
	{
		local CPPawn    _Pawn;
        local CPWeaponAttachmentGrenade _WeaponAttachment;
        if( Instigator == None)
        {
            `Log("@@ error_25");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_26");
            return;
        }
        _WeaponAttachment = CPWeaponAttachmentGrenade(_Pawn.CurrentWeaponAttachment);
        _WeaponAttachment.PlayTopHalfAnimationDuration(_WeaponAttachment.FireAnim_End, FireStates[0].FireInterval[0] );
	}
}

function HolderDied()
{
	super.HolderDied();
	if(ChargeStartTime > 0)
		FireAmmunition();
}

simulated state Hacking
{
	simulated event BeginState( name PreviousStateName )
	{
		ChargeStartTime = 0;
		SetCancelThrow();
		super.BeginState( PreviousStateName );
	}
}

simulated function float GetWeaponRating()
{
	return -1.0;
}

defaultproperties
{
	FullChargeTime=1.5
	FuseTime=3.0

	WeaponType=WT_GRENADE
	// For testing
	MaxAmmoCount=1
	MaxClipCount=0

	GrenadeReadyAnim=WeaponStartFire
	ReadyAnimTime=0.8667

	WeaponIdleAnims(1)=WeaponIdle1 
	ArmIdleAnims(1)=WeaponIdle1
	WeaponIdleAnims(2)=WeaponIdle2 
	ArmIdleAnims(2)=WeaponIdle2
	WeaponIdleAnims(3)=WeaponIdle3 
	ArmIdleAnims(3)=WeaponIdle3

	Begin Object Class=CPWeaponFireMode Name=FireMode_Default
		ModeName="Throw"
		FireType(0)=ETFT_Projectile
		FireInterval(0)=0.4333
		FiringState(0)=Charging
		HitDamageType(0)=class'CPDmgType_Default'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.Grenades.CP_A_Grenade_throw_Cue'
		MuzzleFlashLightClass(0)=none
		MuzzleFlashLightClass(1)=none
	 End Object
	 FireStates.Add(FireMode_Default)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Clear
		ModeName="Clear"
		FireType(0)=ETFT_Projectile
		FiringState(0)=Charging
		MuzzleFlashLightClass(0)=none
		MuzzleFlashLightClass(1)=none
	End Object
	FireStates.Add(FireMode_Clear)

	ClipPickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Clip_Cue'

	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireWeaponEmptyTime=0.4
	WeaponEmptyFireAnim=WeaponSwitchFireMode

	EquipTime=0.6 // org.: 1.0
	PutDownTime=0.4 // org.: 1.0
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.Grenades.Grenade_Equip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.Grenades.Grenade_Unequip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'

	bForceSwitchWhenEmpty=true
	bDestroyWhenEmpty=true
	
	WeaponReloadAnim=WeaponPutDown
	ArmsReloadAnim=WeaponPutDown

	//WeaponFireSnd(0)=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_FireCue'
	//WeaponFireSnd(1)=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_FireCue'

	FireOffset=(X=12,Y=10,Z=-10)
	
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(0)=class'CPProj_Grenade'
	WeaponProjectiles(1)=class'CPProj_Grenade'
	FireInterval(0)=+0.24
	FireInterval(1)=+0.15
	
	FiringStatesArray(0)=HeldFireCharging
	FiringStatesArray(1)=Charging
	
	ShouldFireOnRelease(0)=1
	ShouldFireOnRelease(1)=1

	DroppedPickupOffsetZ = 2.5
	WeaponFlashName="grenade"

	GrenadeMinVelocityPerc=0.15
	GrenadeVelocityMultiplier=0.85
	GrenadePitchOffset=0
	InventoryGroup=5
	bShowMuzzleFlashWhenFiring = FALSE
}
