class CPWeap_MP5A3 extends CPFiringWeapon;

simulated function float GetWeaponRating()
{
	return 0.5;
}

simulated function float GetDegreesByMode()
{
	if(PendingFireState == 1)
		return 320.0;
	else if (PendingFireState == 2)
		return 0.0;
	else return 0.0;
}

defaultproperties
{
	WeaponType=WT_SMG
	MaxAmmoCount=30
	MaxClipCount=5
	
	WeaponPrice=1500
    ClipPrice=40

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.48

	//WeaponEquipEmpty               - selecting the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.33

	//WeaponPutDownEmpty         - putting away the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle 
	ArmIdleAnims(0)=WeaponIdle

	//WeaponIdleEmpty                 - same as idle except that this is only needed when its visible that the weapon is empty i.e. Chamber is in back position

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.2

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.5

	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	// WeaponEmptyFireAnim         - trying to fire when the weapon is empty, just pulling the trigger and nothing happens 
	WeaponEmptyFireAnim=WeaponStartFireEmpty
	ArmsEmptyFireAnim=WeaponStartFireEmpty
	FireWeaponEmptyTime=0.2

	//WeaponSwitchTo[fire mode name]      - switch to a specified mode, should be something like pusshing a button or whatever, only needed when the weapon have more than one firing modes
	WeaponFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	ArmsFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	FireModeSwitchTime[1]=0.5

	WeaponFireModeSwitchAnim[2]=WeaponSwitchFireModeToBurst
	ArmsFireModeSwitchAnim[2]=WeaponSwitchFireModeToBurst
	FireModeSwitchTime[2]=0.5

	WeaponFireModeSwitchAnim[3]=WeaponSwitchFireModeToSingle
	ArmsFireModeSwitchAnim[3]=WeaponSwitchFireModeToSingle
	FireModeSwitchTime[3]=0.5

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.MP5_John.MP5reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.MP5_John.MP5reload_empty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.SubGun_equipUnEquip.SubGun_equip_cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.SubGun_equipUnEquip.SubGun_UnEquip_cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.025
	Spread(1)=0.025
	Spread(2)=0.025
	WeaponEffectiveRange=3540 // ~67m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.09
		MinFireRecoil(0)=(X=-0.01,Y=0.01,Z=0.0)
		MaxFireRecoil(0)=(X=0.015,Y=0.02,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		HitDamageType(0)=class'CPDmgType_MP5A3'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Auto
		ArmFireAnims(0)=WeaponFire_Auto
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.MP5_John'
		MuzzleFlashPSC(0)=ParticleSystem'CP_Juan_FX.Particles.PS_CP_MP5_Muzzle_Flash_1st' 
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_MP5A3.PS_CP_MP5A3_SE'
	End Object
	FireStates.Add(FireMode_Auto)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Burst
		ModeName="Burst"
		FireType(0)=ETFT_InstantHit
		FiringState(0)=WeaponFiring_Burst
		FireInterval(0)=0.09
		MinFireRecoil(0)=(X=-0.01,Y=0.01,Z=0.0)
		MaxFireRecoil(0)=(X=0.015,Y=0.02,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_MP5A3'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Burst
		ArmFireAnims(0)=WeaponFire_Burst
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.MP5_John'
		MuzzleFlashPSC(0)=ParticleSystem'CP_Juan_FX.Particles.PS_CP_MP5_Muzzle_Flash_1st'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_MP5A3.PS_CP_MP5A3_SE'
	End Object
	FireStates.Add(FireMode_Burst)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.14
		MinFireRecoil(0)=(X=-0.01,Y=0.01,Z=0.0)
		MaxFireRecoil(0)=(X=0.015,Y=0.02,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_MP5A3'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Single
		ArmFireAnims(0)=WeaponFire_Single
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.MP5_John'
		MuzzleFlashPSC(0)=ParticleSystem'CP_Juan_FX.Particles.PS_CP_MP5_Muzzle_Flash_1st'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_MP5A3.PS_CP_MP5A3_SE'
	End Object
	FireStates.Add(FireMode_Single)
	
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_MP5A3.Mesh.SK_TA_MP5A3_1P'
		AnimSets(0)=AnimSet'TA_WP_MP5A3.Anims.AS_TA_MP5A3_1P'
		AnimTreeTemplate=AnimTree'TA_WP_MP5A3.Anims.AT_TA_MP5A3_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_MP5A3.Mesh.SM_TA_MP5A3_Pickup'
		Scale=0.66
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_MP5A3'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 2.0
	WeaponFlashName="mp5"
	InventoryGroup=3

	// WeaponProfileName=MP5a3 //depreciated
	
	bWeaponCanFireOnReload=true

	FireWeaponEmptyTime=0.5
}
