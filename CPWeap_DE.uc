class CPWeap_DE extends CPPistolWeapon;

simulated function float GetWeaponRating()
{
	return 1.0;
}

defaultproperties
{
	WeaponType=WT_PISTOL
	MaxAmmoCount=7
	MaxClipCount=7
	
	WeaponPrice=500
    ClipPrice=25

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	EquipTime=0.43

	//WeaponEquipEmpty               - selecting the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.233

	//WeaponPutDownEmpty         - putting away the weapon when it's empty, this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle 
	ArmIdleAnims(0)=WeaponIdle

	WeaponEmptyIdleAnims(0)=WeaponIdleEmpty
	ArmEmptyIdleAnims(0)=WeaponIdleEmpty

	WeaponReloadAnim=WeaponReload
	ArmsReloadAnim=WeaponReload
	ReloadTime=2.433

	WeaponReloadEmptyAnim=WeaponReloadEmpty
	ArmsReloadEmptyAnim=WeaponReloadEmpty
	ReloadEmptyTime=2.433

	// WeaponStartFire              - moving the weapon into firing position ( or just pressing the trigger ), only needed for rapid firing weapons
	// WeaponEndFire                - moving the weapon into idle position after fire loop, only needed for rapid firing weapons
	// WeaponEndFireEmpty           - after firing ended and the weapon is empty,  this is only needed when its visible that the weapon is empty, i.e. Chamber is in back position

	// WeaponEmptyFireAnim         - trying to fire when the weapon is empty, just pulling the trigger and nothing happens 
	WeaponEmptyFireAnim=WeaponEmptyFireAnim
	ArmsEmptyFireAnim=WeaponEmptyFireAnim
	FireWeaponEmptyTime=0.3

	WeaponReloadSnd=SoundCue'CP_Weapon_Sounds.DE_john.DE_reload_Cue'
	WeaponReloadEmptySnd=SoundCue'CP_Weapon_Sounds.DE_john.DE_reload_empty_Cue'
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapEmpty_Cue'
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunEquip2_32k_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.handgunEquipUnEquip_john.handgunUnEquip2_32k_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireModeSwitchSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_FireModeSwtch_Cue'

	Spread(0)=0.01
	WeaponEffectiveRange=3000 // ~57m

	Begin Object Class=CPWeaponFireMode Name=FireMode_Single
		ModeName="Single"
		FireType(0)=ETFT_InstantHit
		FireType(1)=ETFT_InstantHit
		FiringState(1)=SwitchingLaser
		
		FireInterval(0)=0.22
		FireInterval(1)=0.001 //for the switching to laser mode to be instant
		MinFireRecoil(0)=(X=-0.005,Y=0.025,Z=0.0)
		MaxFireRecoil(0)=(X=0.005,Y=0.030,Z=0.0)
		MinHitDamage(0)=48
		MaxHitDamage(0)=48
		bRepeater(0)=0
		HitDamageType(0)=class'CPDmgType_DE'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire1
		ArmFireAnims(1)=WeaponFire1
		WeaponFireAnims(2)=WeaponFire2
		ArmFireAnims(2)=WeaponFire2
		MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
		MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.TestPistols.DesertEagle_fire_john'
		MuzzleFlashPSC(0)=ParticleSystem'TA_Molez_Particles.Weap_DE.PS_TA_Weap_DE'
		ShellCasingPSC=ParticleSystem'TA_Molez_Particles.Weap_DE.PS_CP_DE_SE'
		MuzzleFlashDuration(0)=0.13
	End Object
	FireStates.Add(FireMode_Single)
	
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_DesertEagle.Mesh.SK_TA_DesertEagle_1P'
		AnimSets(0)=AnimSet'TA_WP_DesertEagle.Anims.AS_TA_DesertEagle_1P'
		AnimTreeTemplate=AnimTree'TA_WP_DesertEagle.Anims.AT_TA_DesertEagle_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_DesertEagle.Mesh.SM_TA_DesertEagle_Pickup'
		Scale=1.7
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_DE'
	

	bUsesLaserDot=true
	ShotCost(1)=0

	// JUNK
	FireOffset=(X=20,Y=5)

	DroppedPickupOffsetZ = 2.0
	WeaponFlashName="deserteagle" //depreciated
	InventoryGroup=2

	//WeaponProfileName=DesertEagle

	bChamberedWeapon=true
	fChamberToFullTime= 1.0
	fChamberToEmptyTime=0.03
}

