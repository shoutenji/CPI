class CPWeap_Mossberg590 extends CPWeaponShotgun;

simulated function float GetWeaponRating()
{
	return 0.75;
}

defaultproperties
{
	WeaponType=WT_SHOTGUN
	MaxAmmoCount=8
	MaxClipCount=40
	ShotgunBuyAmmoCount=8
	
	WeaponPrice=1200
    ClipPrice=32

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.56

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.33

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle4 
	ArmIdleAnims(0)=WeaponIdle4

	WeaponIdleAnims(1)=WeaponIdle2 
	ArmIdleAnims(1)=WeaponIdle2

	WeaponIdleAnims(2)=WeaponIdle3 
	ArmIdleAnims(2)=WeaponIdle3

	WeaponIdleAnims(3)=WeaponIdle
	ArmIdleAnims(3)=WeaponIdle

	WeaponReloadSnd =SoundCue'CP_Weapon_Sounds.mossberg_john.Mossberg_reload_raise_Cue'
	WeaponReloadEmptyAnim=WeaponStartReload
	ArmsReloadEmptyAnim=WeaponStartReload
	WeaponReloadAnim=WeaponStartReload
	ArmsReloadAnim=WeaponStartReload
	ReloadEmptyTime=0.633
	ReloadTime=0.633

	WeaponReloadShellSound=SoundCue'CP_Weapon_Sounds.mossberg_john.Mossberg_reload_singleShell_Cue'
	WeaponReloadShellAnim=WeaponReload
	WeaponReloadShellTime=0.575

	WeaponPumpSound=SoundCue'CP_Weapon_Sounds.mossberg_john.Mossberg_reload_cycle_Cue'
	WeaponNoPumpSound=None
	WeaponNoPumpAnim=WeaponEndReload2
	WeaponPumpAnim=WeaponEndReload
	WeaponPumpTime=1.00

	//WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapReload_Cue'
	//WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapReloadEmpty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.mossberg_john.Mossberg_dry_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.mossberg_john.Mossberg_equip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.mossberg_john.Mossberg_UNequip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.065
	WeaponEffectiveRange=1080 // ~20.5m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Default
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.68
		MinFireRecoil(0)=(X=-0.2,Y=0.275,Z=0.0)
		MaxFireRecoil(0)=(X=0.2,Y=0.275,Z=0.0)
		MinHitDamage(0)=16
		MaxHitDamage(0)=18
		HitDamageType(0)=class'CPDmgType_Mossberg590'
		HitMomentum(0)=125.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire2
		ArmFireAnims(1)=WeaponFire2
		WeaponFireAnims(2)=WeaponFire3
		ArmFireAnims(2)=WeaponFire3
		WeaponFireAnims(3)=WeaponFire4
		ArmFireAnims(3)=WeaponFire4
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.mossberg_john.mossberg590Fire_good_Cue'
		MuzzleFlashPSC(0)=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Shotgun_Muzzle_Flash_1st'
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Mossberg.PS_CP_Mossberg_SE'
		PelletsPerShot=8
	End Object
	FireStates.Add(FireMode_Default)
	
	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_Mossberg590'

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'ta_wp_mossberg590.Mesh.SK_TA_Mossberg590_1P'
		AnimSets(0)=AnimSet'ta_wp_mossberg590.Anims.AS_TA_Mossberg590_1P'
		AnimTreeTemplate=AnimTree'ta_wp_mossberg590.Anims.AT_TA_Mossberg590_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'ta_wp_mossberg590.Mesh.SM_TA_Mossberg590_Pickup'
		Scale=0.625
	End Object

	// JUNK 
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 1.5
	WeaponFlashName="mossberg"
	InventoryGroup=3 

	// WeaponProfileName=Mossberg590 //depreciated

	FireWeaponEmptyTime=1.7
}

