class CPWeap_MAC10 extends CPFiringWeapon;

simulated function float GetWeaponRating()
{
	return 0.5;
}

simulated function float GetDegreesByMode()
{
	return Super.GetDegreesByMode();
}

defaultproperties
{
	WeaponType=WT_SMG
	MaxAmmoCount=32
	MaxClipCount=6
	
	WeaponPrice=950
    ClipPrice=30

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.5

	//WeaponEquipEmpty               - selecting the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.26

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

	WeaponIdleAnims(4)=WeaponIdle4 
	ArmIdleAnims(4)=WeaponIdle4

	//WeaponIdleEmpty                 - same as idle except that this is only needed when its visible that the weapon is empty i.e. Chamber is in back position

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.36

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.66

	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	// WeaponEmptyFireAnim         - trying to fire when the weapon is empty, just pulling the trigger and nothing happens 
	WeaponEmptyFireAnim=WeaponEmptyFireAnim
	ArmsEmptyFireAnim=WeaponEmptyFireAnim
	FireWeaponEmptyTime=0.366

	//WeaponSwitchTo[fire mode name]      - switch to a specified mode, should be something like pusshing a button or whatever, only needed when the weapon have more than one firing modes
	WeaponFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	ArmsFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	FireModeSwitchTime[1]=0.5

	//WeaponFireModeSwitchAnim[2]=WeaponSwitchFireModeToBurst
	//ArmsFireModeSwitchAnim[2]=WeaponSwitchFireModeToBurst
	//FireModeSwitchTime[2]=0.5

	WeaponFireModeSwitchAnim[2]=WeaponSwitchFireModeToSingle
	ArmsFireModeSwitchAnim[2]=WeaponSwitchFireModeToSingle
	FireModeSwitchTime[2]=0.5

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.Mac10_john.Mac10_reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.Mac10_john.Mac10_reload_empty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.SubGun_equipUnEquip.SubGun_equip_cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.SubGun_equipUnEquip.SubGun_UnEquip_cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.05
	Spread(1)=0.05
	WeaponEffectiveRange=2600 // ~49m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.070
		MinFireRecoil(0)=(X=-0.010,Y=0.01,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.015,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		HitDamageType(0)=class'CPDmgType_MAC10'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Auto
		ArmFireAnims(0)=WeaponFire_Auto
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.Mac10_FIre_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_1P'
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_SE'
		MuzzleFlashDuration(0)=0.13
		ShellCasingDuration(0)=0.13
		bMuzzleFlashPSCLoops(0)=1
	End Object
	FireStates.Add(FireMode_Auto)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.1
		MinFireRecoil(0)=(X=-0.010,Y=0.015,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.01,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_MAC10'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Single
		ArmFireAnims(0)=WeaponFire_Single
		WeaponFireAnims(1)=WeaponFire2_Single
		ArmFireAnims(1)=WeaponFire2_Single
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.Mac10_FIre_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_1P'
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_SE'
		ShellCasingDuration(0)=0.13
	End Object
	FireStates.Add(FireMode_Single)
	
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_Mac10.Mesh.SK_TA_Mac10_1P'
		AnimSets(0)=AnimSet'TA_WP_Mac10.Anims.AS_TA_Mac10_1P'
		AnimTreeTemplate=AnimTree'TA_WP_Mac10.Anims.AT_TA_Mac10_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		// pickup mesh is missing, uncomment for now
		StaticMesh=StaticMesh'TA_WP_Mac10.Mesh.SM_TA_Mac10_Pickup'
		Scale=1.7
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_MAC10'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 2.0
	WeaponFlashName="mac10"
	InventoryGroup=3

	// WeaponProfileName=MAC10 //depreciated
	
	bWeaponCanFireOnReload=true
}
