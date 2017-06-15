class CPWeap_AK47 extends CPFiringWeapon;

simulated function float GetWeaponRating()
{
	return 0.5;
}

//simulated function float GetDegreesByMode()
//{
//	if(PendingFireState == 1)
//		return 320.0;
//	else if (PendingFireState == 2)
//		return 0.0;
//	else return 0.0;
//}

defaultproperties
{
	WeaponType=WT_RIFLE
	MaxAmmoCount=30
	MaxClipCount=5
	
	WeaponPrice=3200
    ClipPrice=60

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
	WeaponIdleAnims(1)=WeaponIdle1 
	ArmIdleAnims(1)=WeaponIdle1
	WeaponIdleAnims(2)=WeaponIdle2 
	ArmIdleAnims(2)=WeaponIdle2
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
	WeaponEmptyFireAnim=WeaponFireEmpty
	ArmsEmptyFireAnim=WeaponFireEmpty
	FireWeaponEmptyTime=0.2

	//WeaponSwitchTo[fire mode name]      - switch to a specified mode, should be something like pusshing a button or whatever, only needed when the weapon have more than one firing modes
	WeaponFireModeSwitchAnim[1]=WeaponSwitchToAuto
	ArmsFireModeSwitchAnim[1]=WeaponSwitchToAuto
	FireModeSwitchTime[1]=0.5

	WeaponFireModeSwitchAnim[2]=WeaponSwitchToSingle
	ArmsFireModeSwitchAnim[2]=WeaponSwitchToSingle
	FireModeSwitchTime[2]=0.5

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.MP5_John.MP5reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.MP5_John.MP5reload_empty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.SubGun_equipUnEquip.SubGun_equip_cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.SubGun_equipUnEquip.SubGun_UnEquip_cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.02
	Spread(1)=0.02
	Spread(2)=0.02
	WeaponEffectiveRange=5880 

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.09
		MinFireRecoil(0)=(X=-0.015,Y=0.015,Z=0.0)
		MaxFireRecoil(0)=(X=0.015,Y=0.035,Z=0.0)
		MinHitDamage(0)=34
		MaxHitDamage(0)=34
		HitDamageType(0)=class'CPDmgType_AK47'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire1
		ArmFireAnims(1)=WeaponFire1
		WeaponFireAnims(2)=WeaponFire2
		ArmFireAnims(2)=WeaponFire2
		WeaponFireAnims(3)=WeaponFire3
		ArmFireAnims(3)=WeaponFire3
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.AK47_Fire_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_AK47.PS_CP_AK47_1P'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_MP5A3.PS_CP_MP5A3_SE'
	End Object
	FireStates.Add(FireMode_Auto)
	
	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.09
		MinFireRecoil(0)=(X=-0.015,Y=0.015,Z=0.0)
		MaxFireRecoil(0)=(X=0.015,Y=0.035,Z=0.0)
		MinHitDamage(0)=34
		MaxHitDamage(0)=34
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_AK47'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire1
		ArmFireAnims(1)=WeaponFire1
		WeaponFireAnims(2)=WeaponFire2
		ArmFireAnims(2)=WeaponFire2
		WeaponFireAnims(3)=WeaponFire3
		ArmFireAnims(3)=WeaponFire3
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.AK47_Fire_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_AK47.PS_CP_AK47_1P'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_MP5A3.PS_CP_MP5A3_SE'
	End Object
	FireStates.Add(FireMode_Single)
	
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_AK47.Mesh.SK_TA_AK47_1P'
		AnimSets(0)=AnimSet'TA_WP_AK47.Anims.AS_TA_AK47'
		AnimTreeTemplate=AnimTree'TA_WP_AK47.Anims.AT_TA_AK47_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_AK47.Mesh.SM_TA_AK47_Pickup'
		Scale=0.66
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_AK47'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 2.0
	WeaponFlashName="ak47"
	InventoryGroup=4

	// WeaponProfileName=MP5a3 //depreciated
}
