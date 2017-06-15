class CPAttachment_DE extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_DE'
	Begin Object Name=SkeletalMeshComponent0
		Rotation=(Pitch=-0,Yaw=-90,Roll=0)
		Translation=(X=0,Y=0.00,Z=0.00)
		Scale=0.8
		SkeletalMesh=SkeletalMesh'TA_WP_DesertEagle.Mesh.SK_TA_DesertEagle_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_3p'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_3p'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)

	WeapAnimType = EWAT_PISTOL

	FireAnim=Fire_DesertEagle
	//AltFireAnim=none
	EquipWeapAnim=Equip_DesertEagle
	PutdownWeapAnim=Putdown_DesertEagle
	ReloadAnim=Reload_DesertEagle
	ReloadEmptyAnim=Reload_DesertEagle
	IdleAnim=Idle_Ready_DesertEagle
	DropAnim=Drop_DesertEagle
}
