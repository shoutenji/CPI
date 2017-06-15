class CPWeap_RagingBull extends CPFiringWeapon;

simulated function float GetWeaponRating()
{
	return 0;
}

defaultproperties
{
	WeaponType=WT_PISTOL
	MaxAmmoCount=6
	MaxClipCount=7
	
	WeaponPrice=700
    ClipPrice=30

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.56

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.26

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

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.8000

	WeaponReloadEmptyAnim=WeaponReload
	ArmsReloadEmptyAnim=WeaponReload
	ReloadEmptyTime=2.8000

	WeaponEmptyFireAnim=WeaponStartFireEmpty
	ArmsEmptyFireAnim=WeaponStartFireEmpty
	FireWeaponEmptyTime=0.53


	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.RagingBull_john.Bull_reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.RagingBull_john.Bull_reload_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunEquip2_32k_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunUnEquip2_32k_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=None

	Spread(0)=0.015
	WeaponEffectiveRange=2500 // ~47m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.53
		MinFireRecoil(0)=(X=-0.030,Y=0.110,Z=0.0)
		MaxFireRecoil(0)=(X=+0.030,Y=0.125,Z=0.0)
		MinHitDamage(0)=65
		MaxHitDamage(0)=65
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_RagingBull'
		HitMomentum(0)=0.0
		WeaponFireAnims(0)=WeaponShoot
		ArmFireAnims(0)=WeaponShoot
		WeaponFireAnims(1)=WeaponShoot1
		ArmFireAnims(1)=WeaponShoot1
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestPistols.RagingBull'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_RB.PS_TA_Weap_RB' 
		MuzzleFlashDuration(0)=0.13
	End Object
	FireStates.Add(FireMode_Single)

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_RagingBull.Mesh.SK_TA_RagingBull_1P'
		AnimSets(0)=AnimSet'TA_WP_RagingBull.Anims.AS_TA_RagingBull_1P'
		AnimTreeTemplate=AnimTree'TA_WP_RagingBull.AT_TA_RagingBull_1P'
		Scale=3.0
		FOV=45.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_RagingBull.Mesh.SM_TA_RagingBull_Pickup'
		Scale=0.5
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_RagingBull'

	bUsesLaserDot=false
	
	DroppedPickupOffsetZ = 1.5
	WeaponFlashName="bull"

	InventoryGroup=2

	// WeaponProfileName=None //depreciated
	
	bWeaponCanFireOnReload=true
}