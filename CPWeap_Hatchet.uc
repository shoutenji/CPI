class CPWeap_Hatchet extends CPMeleeWeapon;

simulated function float GetWeaponRating()
{
	return -1.0;
}

defaultproperties
{
	bCanThrow=false
	WeaponType=WT_KNIFE
	MaxAmmoCount=1
	MaxClipCount=0//MaxClipCount=7

    ClipPrice=7
	
	ShotCost(0)=1 //dont use any ammo when knifing.

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip 
	EquipTime=0.44 // org.: 1.04

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	PutDownTime=0.26

	WeaponRange=83.0 // 72uu/4.5ft + ( CPPawn.CylinderComponent.CollisionRadius * 0.5 )

	//note idles dont need animtimes.
	WeaponIdleAnims(0)=WeaponIdle 
	ArmIdleAnims(0)=WeaponIdle

	WeaponIdleAnims(1)=WeaponIdle1 
	ArmIdleAnims(1)=WeaponIdle1

	WeaponReloadSnd=none
	WeaponReloadEmptySnd=none
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_ClipPckUp_Cue'
	WeaponEmptySnd=none
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.meleeWeapons.knifeEquip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_WeapPutDwn_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.UMPmilan.UMP_PickupWeap_Cue'
	FireModeSwitchSnd=none

	Begin Object Class=CPWeaponFireMode Name=FireMode_Melee
		ModeName="Melee"
		FireType(0)=ETFT_InstantHit
		FireInterval(0)=0.85
		MinFireRecoil(0)=(X=0.0,Y=0.0,Z=0.0)
		MaxFireRecoil(0)=(X=0.0,Y=0.0,Z=0.0)
		MinHitDamage(0)=34
		MaxHitDamage(0)=34
		bRepeater(0)=1
		HitDamageType(0)=class'CPDmgType_Hatchet'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		MuzzleFlashLightClass(0)=none
		MuzzleFlashLightClass(1)=none
		MuzzleFlashPSC(0)=none
		MuzzleFlashDuration(0)=0.13
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.meleeWeapons.MeleeSwing_Cue'
	End Object
	FireStates.Add(FireMode_Melee)
	
	/*Begin Object Class=CPWeaponFireMode Name=FireMode_Throw
		ModeName="Throw"
		FireType(0)=ETFT_Projectile
		ProjectileClass(0)=class'CPMeleeProjectile_Hatchet'
		FireInterval(0)=1.0
		MinFireRecoil(0)=(X=0.0,Y=0.0,Z=0.0)
		MaxFireRecoil(0)=(X=0.0,Y=0.0,Z=0.0)
		MinHitDamage(0)=34
		MaxHitDamage(0)=34
		
		RequiredAmmoAmount(0)=1
		
		bRepeater(0)=1
		HitDamageType(0)=class'CPDmgType_Hatchet'
		HitMomentum(0)=1000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireAnims(1)=WeaponFire
		ArmFireAnims(1)=WeaponFire
		WeaponFireAnims(2)=WeaponFire
		ArmFireAnims(2)=WeaponFire
		MuzzleFlashLightClass(0)=none
		MuzzleFlashLightClass(1)=none
		MuzzleFlashPSC(0)=none
		MuzzleFlashDuration(0)=0.0
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.meleeWeapons.MeleeSwing_Cue'
	End Object
	FireStates.Add(FireMode_Throw)*/

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'CPMeleeProjectile_Hatchet'
	
	
	
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_Hatchet.Mesh.SK_TA_Hatchet_1P'
		AnimSets(0)=AnimSet'TA_WP_Hatchet.Anims.AS_TA_Hatchet_1P'
		AnimTreeTemplate=AnimTree'TA_WP_Hatchet.Anims.AT_TA_Hatchet_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true
	End Object

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_Hatchet.Mesh.SM_TA_Hatchet_Pickup'
		Scale=1.7
	End Object

	MuzzleFlashFOVOverride=60.0
	AttachmentClass=class'CPAttachment_Hatchet'

	// JUNK
	FireOffset=(X=20,Y=5)
	
	WeaponFlashName="hatchet"
	InventoryGroup=1
	// WeaponProfileName=Hatchet //depreciated
	bShowMuzzleFlashWhenFiring = FALSE
}
