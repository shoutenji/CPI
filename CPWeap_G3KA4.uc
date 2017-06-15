class CPWeap_G3KA4 extends CPFiringWeapon;

simulated function float GetWeaponRating()
{
	return 1.0;
}

//NEEDS ROF CONTROL!
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
	WeaponType=WT_RIFLE
	MaxAmmoCount=20
	MaxClipCount=4
	
	WeaponPrice=3850
    ClipPrice=50

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.633

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

	//WeaponIdleEmpty                 - same as idle except that this is only needed when its visible that the weapon is empty i.e. Chamber is in back position

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.6

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=3.1

	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	// WeaponEmptyFireAnim         - trying to fire when the weapon is empty, just pulling the trigger and nothing happens 
	WeaponEmptyFireAnim=WeaponStartFireEmpty
	ArmsEmptyFireAnim=WeaponStartFireEmpty
	FireWeaponEmptyTime=0.53

	//WeaponSwitchTo[fire mode name]      - switch to a specified mode, should be something like pusshing a button or whatever, only needed when the weapon have more than one firing modes
	WeaponFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	ArmsFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	FireModeSwitchTime[1]=0.5

	WeaponFireModeSwitchAnim[2]=WeaponSwitchFireModeToSingle
	ArmsFireModeSwitchAnim[2]=WeaponSwitchFireModeToSingle
	FireModeSwitchTime[2]=0.5

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.G3K_john.G3K_reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.G3K_john.G3K_reload_empty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_Equip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_Unequip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.015
	Spread(1)=0.015
	WeaponEffectiveRange=21000 // ~400m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.095
		MinFireRecoil(0)=(X=-0.005,Y=0.01,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.01,Z=0.0)
		MinHitDamage(0)=23
		MaxHitDamage(0)=23
		HitDamageType(0)=class'CPDmgType_G3KA4'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.HKG3KA4_fire_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG' 
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_HKG3.PS_CP_HKG3_SE'
	End Object
	FireStates.Add(FireMode_Auto)

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.095
		MinFireRecoil(0)=(X=-0.005,Y=0.01,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.01,Z=0.0)
		MinHitDamage(0)=34
		MaxHitDamage(0)=34
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_G3KA4'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire1
		ArmFireAnims(0)=WeaponFire1
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.HKG3KA4_fire_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_HKG3.PS_CP_HKG3_SE'
	End Object
	FireStates.Add(FireMode_Single)
	
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_G3KA4.Mesh.SK_TA_G3KA4_1P'
		AnimSets(0)=AnimSet'TA_WP_G3KA4.Anims.AS_TA_G3KA4_1P'
		AnimTreeTemplate=AnimTree'TA_WP_G3KA4.Anims.AT_TA_G3KA4_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_G3KA4.Mesh.SM_TA_G3KA4_pickup'
		Scale=1.7
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_G3KA4'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 2.0
	WeaponFlashName="g3"
	InventoryGroup=4

	// WeaponProfileName=G3KA4 //depreciated
		
	bWeaponCanFireOnReload=true
}