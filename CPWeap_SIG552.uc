class CPWeap_SIG552 extends CPFiringWeapon;


simulated function float GetWeaponRating()
{
	return 1.0;
}

simulated function float GetDegreesByMode()
{
	if(PendingFireState == 1)
		return 228.0;
	else if (PendingFireState == 2)
		return 114.0;
	else if (PendingFireState == 3)
		return 0.0;
	else return 0.0;
}

defaultproperties
{
	WeaponType=WT_RIFLE
	MaxAmmoCount=30
	MaxClipCount=4
	
	WeaponPrice=3300
    ClipPrice=60

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.63

	//WeaponEquipEmpty               - selecting the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.38

	//WeaponPutDownEmpty         - putting away the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle 
	ArmIdleAnims(0)=WeaponIdle

	WeaponIdleAnims(1)=WeaponIdle1 
	ArmIdleAnims(1)=WeaponIdle1

	WeaponIdleAnims(2)=WeaponIdle2 
	ArmIdleAnims(2)=WeaponIdle2

	WeaponIdleAnims(3)=WeaponIdle3
	ArmIdleAnims(3)=WeaponIdle3

	//WeaponIdleEmpty                 - same as idle except that this is only needed when its visible that the weapon is empty i.e. Chamber is in back position

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.5

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=3.0


	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponStartFire=WeaponStartFire
	// WeaponStartFireTime=0.24

	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFire=WeaponEndFire
	// WeaponEndFireTime=0.64

	// WeaponStartFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position
	// WeaponStartFireEmpty=WeaponStartFireEmpty 
	// WeaponStartFireEmptyTime=0.44

	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position
	// WeaponEndFireEmpty=WeaponEndFireEmpty 
	// WeaponEndFireEmptyTime=0.64

	// WeaponEmptyFireAnim         - trying to fire when the weapon is empty, just pulling the trigger and nothing happens 
	WeaponEmptyFireAnim=WeaponEmptyFireAnim   
	ArmsEmptyFireAnim=WeaponEmptyFireAnim     
	FireWeaponEmptyTime=0.44                  

	// WeaponSwitchTo[fire mode name]      - switch to a specified mode, should be something like pusshing a button or whatever, only needed when the weapon have more than one firing modes

	WeaponFireModeSwitchAnim[1]=WeaponSwitchBurst
	ArmsFireModeSwitchAnim[1]=WeaponSwitchBurst
	WeaponFireModeSwitchAnim[2]=WeaponSwitchSingle
	ArmsFireModeSwitchAnim[2]=WeaponSwitchSingle
	WeaponFireModeSwitchAnim[3]=WeaponSwitchAuto  
	ArmsFireModeSwitchAnim[3]=WeaponSwitchAuto     

	FireModeSwitchTime[1]=0.52
	FireModeSwitchTime[2]=0.52
	FireModeSwitchTime[3]=0.52

	// WeaponScopeIn=WeaponScopeIn
	// WeaponScopeInTime=0.44

	// WeaponScopeOut=WeaponScopeOut
	// WeaponScopeOutTime=0.44

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_Reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_ReloadEmpty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_DryFire_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_Equip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_Unequip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'   
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_ModeSwitch_Cue'

	Spread(0)=0.02
	Spread(1)=0.02
	Spread(2)=0.02
	WeaponEffectiveRange=9500 // ~181m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.11
		MinFireRecoil(0)=(X=-0.005,Y=0.025,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.03,Z=0.0)
		MinHitDamage(0)=36
		MaxHitDamage(0)=36
		HitDamageType(0)=class'CPDmgType_SIG552'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire2
		ArmFireAnims(1)=WeaponFire2
		WeaponFireAnims(2)=WeaponFire3
		ArmFireAnims(2)=WeaponFire3
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.SIG552_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_SIG_SE'

		ShellEjectPSC(0)=ParticleSystem'TA_Molez_Particles.PS_CP_Shell_Ejection'
	End Object
	FireStates.Add(FireMode_Auto)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Burst
		ModeName="Burst"
		FireType(0)=ETFT_InstantHit
		FiringState(0)=WeaponFiring_Burst
		FireInterval(0)=0.11
		MinFireRecoil(0)=(X=-0.01,Y=0.02,Z=0.0)
		MaxFireRecoil(0)=(X=0.01,Y=0.03,Z=0.0)
		MinHitDamage(0)=36
		MaxHitDamage(0)=36
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_SIG552'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire2
		ArmFireAnims(1)=WeaponFire2
		WeaponFireAnims(2)=WeaponFire3
		ArmFireAnims(2)=WeaponFire3
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.SIG552_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_SIG_SE'

		ShellEjectPSC(0)=ParticleSystem'TA_Molez_Particles.PS_CP_Shell_Ejection'
	End Object
	FireStates.Add(FireMode_Burst)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.25
		MinFireRecoil(0)=(X=-0.01,Y=0.02,Z=0.0)
		MaxFireRecoil(0)=(X=0.01,Y=0.03,Z=0.0)
		MinHitDamage(0)=32
		MaxHitDamage(0)=32
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_SIG552'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire2
		ArmFireAnims(1)=WeaponFire2
		WeaponFireAnims(2)=WeaponFire3
		ArmFireAnims(2)=WeaponFire3
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.SIG552_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG'  
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_SIG_SE'
	End Object
	FireStates.Add(FireMode_Single)

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_SIG552.Mesh.SK_TA_SIG552_1P'
		AnimSets(0)=AnimSet'TA_WP_SIG552.Anims.AS_TA_SIG552_1P'
		AnimTreeTemplate=AnimTree'TA_WP_SIG552.Anims.AT_TA_SIG552_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_SIG552.Mesh.SM_TA_SIG552_PICKUP'
		Scale=1.25
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_SIG552'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 1.5
	WeaponFlashName="sig"
	InventoryGroup=4

	// WeaponProfileName=SIG552 //depreciated
	
	bWeaponCanFireOnReload=true
}
