class CPAttachment_Bomb extends CPWeaponAttachment;

DefaultProperties
{
	// temporaly
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_C4Bomb.Mesh.SK_TA_C4Bomb_3P'
		//Translation=(X=-10.00,Y=0.00,Z=5.00)
		//Rotation=(Pitch=-0,Yaw=0,Roll=-20)
		//Scale=0.6
		
	End Object

	WeaponClass=class'CPWeap_Bomb'
	MuzzleFlashLightClass=none
	WeapAnimType=EWAT_Bomb

	FireAnim=Fire_C4Bomb
	AltFireAnim=Fire_C4Bomb
	EquipWeapAnim=Equip_C4Bomb
	PutdownWeapAnim=Putdown_C4Bomb
	ReloadAnim=none
	ReloadEmptyAnim=none
	IdleAnim=Idle_Ready_C4Bomb
	DropAnim=Drop_C4Bomb
	BulletWhip=none
}
