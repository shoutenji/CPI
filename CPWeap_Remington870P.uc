class CPWeap_Remington870P extends CPWeaponShotgun;


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
	
	WeaponPrice=2500
    ClipPrice=32

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.56

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.28

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle 
	ArmIdleAnims(0)=WeaponIdle

	WeaponIdleAnims(1)=WeaponIdle2 
	ArmIdleAnims(1)=WeaponIdle2

	WeaponIdleAnims(2)=WeaponIdle3 
	ArmIdleAnims(2)=WeaponIdle3

	WeaponIdleAnims(3)=WeaponIdle4
	ArmIdleAnims(3)=WeaponIdle4

	WeaponIdleAnims(4)=WeaponIdle5 
	ArmIdleAnims(4)=WeaponIdle5

	WeaponReloadSnd =SoundCue'CP_Weapon_Sounds.Remington_DavidY.AU_Weap_Remington_Equip_Cue'
	WeaponReloadEmptyAnim=WeaponStartReload
	ArmsReloadEmptyAnim=WeaponStartReload
	WeaponReloadAnim=WeaponStartReload
	ArmsReloadAnim=WeaponStartReload
	ReloadEmptyTime=0.633
	ReloadTime=0.633

	WeaponReloadShellSound=SoundCue'CP_Weapon_Sounds.Remington_DavidY.AU_Weap_Remington_LoadShell_Cue'
	WeaponReloadShellAnim=WeaponReload
	WeaponReloadShellTime=0.575

	WeaponPumpSound =SoundCue'CP_Weapon_Sounds.Remington_DavidY.AU_Weap_Remington_Rack_Cue'
	WeaponNoPumpSound =SoundCue'CP_Weapon_Sounds.Remington_DavidY.AU_Weap_Remington_Equip_Cue'
	WeaponNoPumpAnim=WeaponEndReload
	WeaponPumpAnim=WeaponEndReloadPump
	WeaponPumpTime=1.00  //  old1.500

	//WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapReload_Cue'
	//WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapReloadEmpty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.mossberg_john.Mossberg_dry_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.Remington_DavidY.AU_Weap_Remington_Equip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.Remington_DavidY.AU_Weap_Remington_Unequip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.065
	WeaponEffectiveRange=1342 // ~25.5m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Default
		ModeName="Auto"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.76
		MinFireRecoil(0)=(X=-0.2,Y=0.275,Z=0.0)
		MaxFireRecoil(0)=(X=0.2,Y=0.275,Z=0.0)
		MinHitDamage(0)=16
		MaxHitDamage(0)=18
		HitDamageType(0)=class'CPDmgType_Remmington870P'
		HitMomentum(0)=125.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire2
		ArmFireAnims(1)=WeaponFire2
		WeaponFireAnims(2)=WeaponFire3
		ArmFireAnims(2)=WeaponFire3
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.remington_john.Remington_Fire_Cue'
		MuzzleFlashPSC(0)=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Shotgun_Muzzle_Flash_1st'
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Rem.PS_CP_Rem_SE'
		PelletsPerShot=8
	End Object
	FireStates.Add(FireMode_Default)
	
	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_Remington870P'

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_Remington870P.Mesh.SK_TA_Remington870P_1P'
		AnimSets(0)=AnimSet'TA_WP_Remington870P.Anims.AS_TA_Remington870P_1P'
		AnimTreeTemplate=AnimTree'TA_WP_Remington870P.Anims.AT_TA_Remington870P_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_Remington870P.Mesh.SM_TA_Remington870P_Pickup'
		Scale=0.8
	End Object

	// JUNK 
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 1.5
	WeaponFlashName="remington870"
	InventoryGroup=3

	// WeaponProfileName=Remmington870p //depreciated
	FireWeaponEmptyTime=0.5
}
