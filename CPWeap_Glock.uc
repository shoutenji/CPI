class CPWeap_Glock extends CPPistolWeapon;

simulated function float GetWeaponRating()
{
	return 0;
}

defaultproperties
{
	WeaponType=WT_PISTOL
	MaxAmmoCount=13
	MaxClipCount=5
	
	WeaponPrice=300
    ClipPrice=15

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
	WeaponIdleAnims(2)=WeaponIdle2
	ArmIdleAnims(2)=WeaponIdle2

	WeaponEmptyIdleAnims(0)=WeaponIdleEmpty
	ArmEmptyIdleAnims(0)=WeaponIdleEmpty
	WeaponEmptyIdleAnims(1)=WeaponIdleEmpty1
	ArmEmptyIdleAnims(1)=WeaponIdleEmpty1
	WeaponEmptyIdleAnims(2)=WeaponIdleEmpty2
	ArmEmptyIdleAnims(2)=WeaponIdleEmpty2

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.53

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.53

	WeaponEmptyFireAnim=WeaponFireEmpty
	ArmsEmptyFireAnim=WeaponFireEmpty
	FireWeaponEmptyTime=0.2

	WeaponFireModeSwitchAnim[1]=WeaponSwitchToBurst //should be switch to single.
	ArmsFireModeSwitchAnim[1]=WeaponSwitchToBurst //should be switch to single.
	FireModeSwitchTime[1]=0.5

	WeaponFireModeSwitchAnim[2]=WeaponSwitchToBurst
	ArmsFireModeSwitchAnim[2]=WeaponSwitchToBurst
	FireModeSwitchTime[2]=0.5


	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.Glock_DavidY.GLockReload'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.Glock_DavidY.GlockReloadEmpty'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunEquip2_32k_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunUnEquip2_32k_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.02
	Spread(1)=0.02
	WeaponEffectiveRange=1650 // ~32m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit

		FireInterval(0)=0.180
		MinFireRecoil(0)=(X=-0.01,Y=0.02,Z=0.0)
		MaxFireRecoil(0)=(X=0.01,Y=0.025,Z=0.0)
		MinHitDamage(0)=49
		MaxHitDamage(0)=52
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_Glock'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire1
		ArmFireAnims(1)=WeaponFire1
		WeaponFireAnims(2)=WeaponFire2
		ArmFireAnims(2)=WeaponFire2
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestPistols.Glock_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_TA_Weap_9mm'
		MuzzleFlashDuration(0)=0.13 
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_CP_Glock_SE'
	End Object
	FireStates.Add(FireMode_Single)
	
	Begin Object Class=CPWeaponFireMode Name=FireMode_Burst
		ModeName="Burst"
		FireType(0)=ETFT_InstantHit
		FiringState(0)=WeaponFiring_Burst
		FireInterval(0)=0.1400
		MinFireRecoil(0)=(X=-0.015,Y=0.0400,Z=0.0)
		MaxFireRecoil(0)=(X=0.015,Y=0.0450,Z=0.0)
		MinHitDamage(0)=49
		MaxHitDamage(0)=52
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_Glock'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire1
		ArmFireAnims(1)=WeaponFire1
		WeaponFireAnims(2)=WeaponFire2
		ArmFireAnims(2)=WeaponFire2
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestPistols.Glock_John'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_TA_Weap_9mm'
		MuzzleFlashDuration(0)=0.13
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_CP_Glock_SE'
	End Object
	FireStates.Add(FireMode_Burst)

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_Glock18C.Mesh.SK_TA_Glock18C_1P'
		AnimSets(0)=AnimSet'TA_WP_Glock18C.Anims.AS_TA_Glock18C_1P'
		AnimTreeTemplate=AnimTree'TA_WP_Glock18C.Anims.AT_TA_Glock18C_1P'
		Scale=3.0
		FOV=45.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_Glock18C.Mesh.SM_TA_Glock18C_Pickup'
		Scale=0.5
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_Glock'

	bChamberedWeapon=true
	bUsesLaserDot=true
	ShotCost(1)=0

	// JUNK
	FireOffset=(X=20,Y=5)
	
	DroppedPickupOffsetZ = 1.5
	WeaponFlashName="glock"

	fChamberToFullTime= 1.0
	fChamberToEmptyTime=0.03
	InventoryGroup=2

	// WeaponProfileName=Glock18c //depreciated
}
