class CPAttachment_Flashbang extends CPWeaponAttachmentGrenade;

defaultproperties
{
	// temporaly
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_FlashBang.Mesh.SK_TA_FlashBang_3P'
		//Translation=(X=1.0,Y=0.3,Z=-1.0)
		//Scale=0.75
	End Object

	WeaponClass=class'CPWeap_FlashBang'


	//TODO smoke is GrenadeM18Smoke
	FireAnim=FireStart_FlashBang_Release
	FireAnim_Mid=FireMid_FlashBang_Release
	FireAnim_End=FireEnd_FlashBang_Release
	AltFireAnim=FireStart_FlashBang_Release
	EquipWeapAnim=Equip_FlashBang
	PutdownWeapAnim=Putdown_FlashBang
	ReloadAnim=none
	ReloadEmptyAnim=none
	IdleAnim=Idle_Ready_FlashBang
	DropAnim=Drop_FlashBang
	BulletWhip=none
}
