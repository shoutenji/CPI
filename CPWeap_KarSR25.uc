class CPWeap_KarSR25 extends CPWeaponScoped;

simulated function float GetWeaponRating()
{
	return 1;
}

simulated function float GetDegreesByMode()
{
	if(PendingFireState == 1)
		return 272.01;
	else if (PendingFireState == 2)
		return 0;
	else return 0.0;
}

defaultproperties
{
	WeaponType=WT_RIFLE
	MaxAmmoCount=10
	MaxClipCount=4
	
	WeaponPrice=4800
    ClipPrice=40

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.68

	//WeaponEquipEmpty               - selecting the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.39

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
	ReloadTime=2.53

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.83

	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	WeaponEmptyFireAnim=WeaponEmptyFire
	ArmsEmptyFireAnim=WeaponEmptyFire
	FireWeaponEmptyTime=0.25

	//WeaponZoomInAnim =weaponscopein
	//WeaponZoomInTime =0.23

	//WeaponSwitchTo[fire mode name]      - switch to a specified mode, should be something like pusshing a button or whatever, only needed when the weapon have more than one firing modes
	WeaponFireModeSwitchAnim[1]=none//WeaponSwitchFireModeToAuto
	ArmsFireModeSwitchAnim[1]=none//WeaponSwitchFireModeToAuto
	FireModeSwitchTime[1]=0.1

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.KAR_DavidY.KAR_Reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.KAR_DavidY.KAR_Reload_Full_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.KAR_DavidY.KAR_Unequip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.KAR_DavidY.KAR_Equip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'


	Spread(0)=0.15
	WeaponEffectiveRange=63000 // ~1200m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Auto
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.3
		MinFireRecoil(0)=(X=-0.020,Y=0.055,Z=0.0)
		MaxFireRecoil(0)=(X=0.020,Y=0.065,Z=0.0)
		MinHitDamage(0)=85
		MaxHitDamage(0)=85
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_KarSR25'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.KAR_DavidY.KAR_Fire_Cue'
		MuzzleFlashPSC(0)=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Sniper_Muzzle_Flash_1st'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Kar.PS_CP_Kar_SE'
	End Object
	FireStates.Add(FireMode_Auto)
	
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_SR25.Mesh.SK_TA_SR25_1P'
		AnimSets(0)=AnimSet'TA_WP_SR25.Anims.AS_TA_SR25_1P'
		AnimTreeTemplate=AnimTree'TA_WP_SR25.Anims.AT_TA_SR25_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_SR25.Mesh.SM_TA_SR25_PICKUP'
		Scale=1.25
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_KarSR25'

	// JUNK
	FireOffset=(X=20,Y=5)

	bNoWeaponCrosshair=true
	
	DroppedPickupOffsetZ = 2.0


	// CPWeaponScoped variables
	ScopeSize=1.1f

	ScopeLevels.Empty()
	SpreadMultipliers.Empty()
	// Zoom level 1
	ScopeLevels.Add( 30.0f )
	SpreadMultipliers.Add( 0.50f )
	// Zoom level 2
	ScopeLevels.Add( 15.0f )
	SpreadMultipliers.Add( 0.25f )


	WeaponFlashName="karsr25"
	InventoryGroup=4

	// WeaponProfileName=KARSR25 //depreciated

 	ZoomInSound=SoundCue'CP_Weapon_Sounds.KAR_DavidY.KAR_Scope_In_Cue'
	ZoomOutSound=SoundCue'CP_Weapon_Sounds.KAR_DavidY.KAR_Scope_Out_Cue'
	
	bWeaponCanFireOnReload=true
}
