class CPAttachment_Grenade extends CPWeaponAttachmentGrenade;


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
	FireAnim=FireStart_GrenadeHE_Release
	FireAnim_Mid=FireMid_GrenadeHE_Release
	FireAnim_End=FireEnd_GrenadeHE_Release
	AltFireAnim=FireStart_GrenadeHE_Release
	EquipWeapAnim=Equip_GrenadeHE
	PutdownWeapAnim=Putdown_GrenadeHE
	ReloadAnim=none
	ReloadEmptyAnim=none
	IdleAnim=Idle_Ready_GrenadeHE
	DropAnim=Drop_GrenadeHE
	BulletWhip=none
}
