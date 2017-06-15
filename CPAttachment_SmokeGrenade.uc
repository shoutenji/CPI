class CPAttachment_SmokeGrenade extends CPWeaponAttachmentGrenade;




defaultproperties
{
	// temporaly
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_GrenadeHE.Mesh.SK_TA_GrenadeHE_3P'
		//Translation=(X=1.0,Y=0.3,Z=-1.0)
		//Scale=0.75
	End Object

	WeaponClass=class'CPWeap_Grenade'


	//TODO smoke is GrenadeM18Smoke
	FireAnim=FireStart_GrenadeM18Smoke_Release
	FireAnim_Mid=FireMid_GrenadeM18Smoke_Release
	FireAnim_End=FireEnd_GrenadeM18Smoke_Release
	AltFireAnim=FireStart_GrenadeM18Smoke_Release
	EquipWeapAnim=Equip_GrenadeM18Smoke
	PutdownWeapAnim=Putdown_GrenadeM18Smoke
	ReloadAnim=none
	ReloadEmptyAnim=none
	IdleAnim=Idle_Ready_GrenadeM18Smoke
	DropAnim=Drop_GrenadeM18Smoke
	BulletWhip=none
}
