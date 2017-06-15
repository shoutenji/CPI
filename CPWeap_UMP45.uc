class CPWeap_UMP45 extends CPFiringWeapon;

simulated function float GetWeaponRating()
{
	return 0.5;
}

simulated function float GetDegreesByMode()
{
	if(PendingFireState == 1)
		return 15.0;
	else if (PendingFireState == 2)
		return 10.0;
	else return 0.0;
}

defaultproperties
{
	WeaponType=WT_SMG
	MaxAmmoCount=30
	MaxClipCount=6
	
	WeaponPrice=1500
    ClipPrice=40

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.50

	//WeaponEquipEmpty               - selecting the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.33

	//WeaponPutDownEmpty         - putting away the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle 
	ArmIdleAnims(0)=WeaponIdle

	WeaponIdleAnims(1)=WeaponIdle1 
	ArmIdleAnims(1)=WeaponIdle1

	WeaponIdleAnims(2)=WeaponIdle2 
	ArmIdleAnims(2)=WeaponIdle2

	//WeaponIdleEmpty                 - same as idle except that this is only needed when its visible that the weapon is empty i.e. Chamber is in back position

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.0

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.5

	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	// WeaponEmptyFireAnim         - trying to fire when the weapon is empty, just pulling the trigger and nothing happens 
	WeaponEmptyFireAnim=WeaponEmptyFireAnim
	ArmsEmptyFireAnim=WeaponEmptyFireAnim
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

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapReload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapReloadEmpty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEquip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapPutDwn_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.03
	Spread(1)=0.03
	WeaponEffectiveRange=2600 // ~49m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.075
		MinFireRecoil(0)=(X=-0.010,Y=0.015,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.025,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		HitDamageType(0)=class'CPDmgType_UMP45'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Auto
		ArmFireAnims(0)=WeaponFire_Auto
		WeaponFireAnims(1)=WeaponFire2_Auto
		ArmFireAnims(1)=WeaponFire2_Auto
		WeaponFireAnims(2)=WeaponFire3_Auto
		ArmFireAnims(2)=WeaponFire3_Auto
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.UMP45_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_1p' 
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_SE'
	End Object
	FireStates.Add(FireMode_Auto)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Burst
		ModeName="Burst"
		FireType(0)=ETFT_InstantHit
		FiringState(0)=WeaponFiring_Burst
		FireInterval(0)=0.075
		MinFireRecoil(0)=(X=-0.010,Y=0.015,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.025,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_UMP45'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Burst
		ArmFireAnims(0)=WeaponFire_Burst
		WeaponFireAnims(1)=WeaponFire2_Burst
		ArmFireAnims(1)=WeaponFire2_Burst
		WeaponFireAnims(2)=WeaponFire3_Burst
		ArmFireAnims(2)=WeaponFire3_Burst
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.UMP45_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.PS_TA_Weapon_Flash_45cal' 
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_SE'
	End Object
	FireStates.Add(FireMode_Burst)

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_Ump45.Mesh.SK_TA_UMP45_1P'
		AnimSets(0)=AnimSet'TA_WP_Ump45.Anims.AS_TA_ump45_1P'
		AnimTreeTemplate=AnimTree'TA_WP_Ump45.Anims.AT_TA_UMP45_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_Ump45.Mesh.SM_TA_Ump45_pickup'
		Scale=1.7
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_UMP45'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 2.0
	WeaponFlashName="ump"
	InventoryGroup=3

	// WeaponProfileName=UMP45 //depreciated
	
	bWeaponCanFireOnReload=true
}
