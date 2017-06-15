class CPAttachment_Hatchet extends CPMeleeWeaponAttachment;

defaultproperties
{
	// temporaly
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_Hatchet.Mesh.SK_TA_HATCHET_3P'
		//Translation=(Z=1)
		//Rotation=(Roll=-400)
		//Scale=0.9
	End Object

	WeaponClass=class'CPWeap_Hatchet'
	WeapAnimType = EWAT_Melee

	FireAnim=Fire_Hatch_Stab
	AltFireAnim=Fire_Hatch_Stab
	EquipWeapAnim=Equip_Hatch
	PutdownWeapAnim=Putdown_Hatch
	ReloadAnim=none
	ReloadEmptyAnim=none
	IdleAnim=Idle_Ready_Hatch
	DropAnim=Drop_Hatch
	BulletWhip=none
}
