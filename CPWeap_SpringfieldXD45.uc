class CPWeap_SpringfieldXD45 extends CPPistolWeapon;

simulated function float GetWeaponRating()
{
	return 0;
}

defaultproperties
{
	WeaponType=WT_PISTOL
	MaxAmmoCount=13
	MaxClipCount=4
	
	WeaponPrice=300;
    ClipPrice=15;

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.46

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.26

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle
	ArmIdleAnims(0)=WeaponIdle

	WeaponIdleAnims(1)=WeaponIdle1
	ArmIdleAnims(1)=WeaponIdle1

	//WeaponIdleAnims(2)=WeaponIdle2    - MISSING ANIMS
	//ArmIdleAnims(2)=WeaponIdle2       - MISSING ANIMS

	WeaponEmptyIdleAnims(0)=WeaponIdleEmpty
	ArmEmptyIdleAnims(0)=WeaponIdleEmpty

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.53

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.53

	WeaponEmptyFireAnim=WeaponEmptyFireAnim
	ArmsEmptyFireAnim=WeaponEmptyFireAnim
	FireWeaponEmptyTime=0.2

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.Springfield_DavidY.AU_Weap_Springfield_Reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.Springfield_DavidY.AU_Weap_Springfield_ReloadEmpty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunEquip2_32k_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunUnEquip2_32k_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.02
	WeaponEffectiveRange=1650 // ~32m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit

		FireInterval(0)=0.17
		FireInterval(1)=0.001 //for the switching to laser mode to be instant
		MinFireRecoil(0)=(X=-0.01,Y=0.02,Z=0.0)
		MaxFireRecoil(0)=(X=0.01,Y=0.025,Z=0.0)
		MinHitDamage(0)=55
		MaxHitDamage(0)=55
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_SpringfieldXD45'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire1
		ArmFireAnims(1)=WeaponFire1
		WeaponFireAnims(2)=WeaponFire2
		ArmFireAnims(2)=WeaponFire2
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestPistols.XD45_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_TA_Weap_9mm'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Springfield.PS_CP_SF_SE'
	End Object
	FireStates.Add(FireMode_Single)

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_SpringfieldXD45.Mesh.SK_TA_SpringfieldXD45_1P'
		AnimSets(0)=AnimSet'TA_WP_SpringfieldXD45.Anims.AS_TA_SpringfieldXD45_1P'
		AnimTreeTemplate=AnimTree'TA_WP_SpringfieldXD45.Anims.AT_TA_SpringfieldXD45_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_SpringfieldXD45.Mesh.SM_TA_SpringfieldXD45_Pickup'
		Scale=1.0
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_SpringfieldXD45'

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 1.5
	WeaponFlashName="springfield"
	InventoryGroup=2

	bChamberedWeapon=true
	fChamberToFullTime= 1.0
	fChamberToEmptyTime=0.03

	// WeaponProfileName=SpringfieldXD45 //depreciated
	
	bWeaponCanFireOnReload=true
}