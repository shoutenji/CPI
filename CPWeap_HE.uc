class CPWeap_HE extends CPWeap_Grenade;

simulated function float GetWeaponRating()
{
	return -1.0;
}

defaultproperties
{

    WeaponPrice=500
	
	WeaponIdleAnims(1)=WeaponIdle1 
	ArmIdleAnims(1)=WeaponIdle1
	WeaponIdleAnims(2)=WeaponIdle2 
	ArmIdleAnims(2)=WeaponIdle2
	WeaponIdleAnims(3)=WeaponIdle3 
	ArmIdleAnims(3)=WeaponIdle3
    
	
	Begin Object Class=CPWeaponFireMode Name=FireMode_Default
		ModeName="Auto"
		FireType(0)=ETFT_Projectile
		FireInterval(0)=0.24
		FiringState(0)=HoldingFire
		HitDamageType(0)=class'CPDmgType_HE'
		HitMomentum(0)=20000.0
		WeaponFireAnims(0)=WeaponFire
		ArmFireAnims(0)=WeaponFire
		WeaponFireSnds(0)=SoundCue'CP_Weapon_Sounds.Grenades.CP_A_Grenade_throw_Cue'
	End Object
	FireStates.Add(FireMode_Default)
	

	/*
	// ReloadTime=4.0
	// ReloadEmptyTime=4.5
	// WeaponReloadSnd=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_Reload'
	// WeaponReloadEmptySnd=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_Reload'
	*/
	
	ClipPickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Clip_Cue'

	WeaponEmptySnd=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'
	FireWeaponEmptyTime=0.4
	WeaponEmptyFireAnim=WeaponSwitchFireMode

	EquipTime=0.4
	PutDownTime=0.2
	WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.Grenades.Grenade_Equip_Cue'
	WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.Grenades.Grenade_Unequip_Cue'
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Weapon_Cue'

	//AttachmentClass=class'CPAttachment_Grenade'
    AttachmentClass=class'CPAttachment_Flashbang'

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'TA_WP_ConcussionNade.Mesh.SK_TA_ConcussionNade_1P'
		AnimSets(0)=AnimSet'TA_WP_ConcussionNade.Anims.AS_TA_ConcussionNade_1P'
		AnimTreeTemplate=AnimTree'TA_WP_ConcussionNade.Anims.AT_TA_ConcussionNade_1P'
		FOV=45.0
		Scale=3.0
		bUpdateSkelWhenNotRendered=true 
	End Object
	Mesh=FirstPersonMesh

	Begin Object Name=PickupMesh
		StaticMesh=StaticMesh'TA_WP_ConcussionNade.Mesh.SM_TA_ConcussionNade_Pickup'
		Scale=2.0
	End Object

	bForceSwitchWhenEmpty=true
	bDestroyWhenEmpty=true
	
	WeaponReloadAnim=WeaponPutDown
	ArmsReloadAnim=WeaponPutDown

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown

	//WeaponFireSnd(0)=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_FireCue'
	//WeaponFireSnd(1)=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_FireCue'

	FireOffset=(X=12,Y=10,Z=-10)

	WeaponProjectiles(0)=class'CPProj_HE'
	WeaponProjectiles(1)=class'CPProj_HE'
	FireInterval(0)=+0.24
	FireInterval(1)=+0.15

	InstantHitDamageTypes(0)=class'CPDmgType_HE'
	InstantHitDamageTypes(1)=class'CPDmgType_HE'

	DroppedPickupOffsetZ = 2.5
	WeaponFlashName="grenade"
	InventoryGroup=5

	// WeaponProfileName=HEGrenade //depreciated
}
