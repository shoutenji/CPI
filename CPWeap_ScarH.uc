class CPWeap_ScarH extends CPFiringWeapon;


simulated function float GetWeaponRating()
{
	return 1.0;
}

simulated function float GetDegreesByMode()
{
	if(PendingFireState == 1)
		return 301.0;
	else if (PendingFireState == 2)
		return 0.0;
	else return 0.0;
}

defaultproperties
{
	WeaponType=WT_RIFLE
	MaxAmmoCount=30
	MaxClipCount=4
	
	WeaponPrice=4600
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

	//WeaponIdleEmpty                 - same as idle except that this is only needed when its visible that the weapon is empty i.e. Chamber is in back position

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.43

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.733

	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	// WeaponEmptyFireAnim         - trying to fire when the weapon is empty, just pulling the trigger and nothing happens 
	WeaponEmptyFireAnim=WeaponEmptyFireAnim
	ArmsEmptyFireAnim=WeaponEmptyFireAnim
	FireWeaponEmptyTime=0.4

	//WeaponSwitchTo[fire mode name]      - switch to a specified mode, should be something like pusshing a button or whatever, only needed when the weapon have more than one firing modes
	WeaponFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	ArmsFireModeSwitchAnim[1]=WeaponSwitchFireModeToAuto
	FireModeSwitchTime[1]=0.5

	WeaponFireModeSwitchAnim[2]=WeaponSwitchFireModeToSingle
	ArmsFireModeSwitchAnim[2]=WeaponSwitchFireModeToSingle
	FireModeSwitchTime[2]=0.5

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.SKAR_john.SKAR_reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.SKAR_john.SKAR_reload_empty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_Equip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.SIG_DavidY.AU_Weap_SIG552_Unequip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.02
	WeaponEffectiveRange=15750 // ~300m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.11
		MinFireRecoil(0)=(X=-0.005,Y=0.02,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.03,Z=0.0)
		MinHitDamage(0)=35
		MaxHitDamage(0)=35
		HitDamageType(0)=class'CPDmgType_ScarH'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire_Auto
		ArmFireAnims(0)=WeaponFire_Auto
		WeaponFireAnims(1)=WeaponFire1_Auto
		ArmFireAnims(1)=WeaponFire1_Auto
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestAssaultRifles.Scar_h_fire_john'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG' 
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_SCAR.PS_CP_SCAR_SE'
	End Object
	FireStates.Add(FireMode_Auto)

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_SCAR-H.Mesh.SK_TA_SCAR-H_1P'
		AnimSets(0)=AnimSet'TA_WP_SCAR-H.Anims.AS_TA_SCAR-H_1P'
		AnimTreeTemplate=AnimTree'TA_WP_SCAR-H.Anims.AT_TA_SCAR-H_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_SCAR-H.Mesh.SM_TA_SCAR-H_Pickup'
		Scale=1.7
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_ScarH'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 2.0
	WeaponFlashName="scar" 
	InventoryGroup=4

	// WeaponProfileName=UMP45 //depreciated
	
	bWeaponCanFireOnReload=true
}
