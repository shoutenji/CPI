class CPAttachment_KaBar extends CPMeleeWeaponAttachment;

defaultproperties
{
	// temporaly
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_KABar.Mesh.SK_TA_KABar_3P'
		//Translation=(X=0.00,Y=1.00,Z=-2.00)
		//Rotation=(Pitch=-20,Yaw=0,Roll=-20)
		
	End Object

	WeaponClass=class'CPWeap_KaBar'
	WeapAnimType = EWAT_Melee

	FireAnim=Fire_KABar_Slash
	AltFireAnim=Fire_KABar_Slash
	EquipWeapAnim=Equip_KABar
	PutdownWeapAnim=Putdown_KABar
	ReloadAnim=none
	ReloadEmptyAnim=none
	IdleAnim=Idle_ready_KABar
	DropAnim=Drop_KABar
	BulletWhip=none
}
