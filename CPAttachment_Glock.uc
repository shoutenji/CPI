class CPAttachment_Glock extends CPFiringWeaponAttachment;

defaultproperties
{

	WeaponClass=class'CPWeap_Glock'
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_Glock18C.Mesh.SK_TA_Glock18C_3P'
	End Object

		// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_TA_Weap_9mm_3p'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_TA_Weap_9mm_3p'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_CP_Glock_SE'

	WeapAnimType = EWAT_Pistol

	FireAnim=Fire_Glock18C
	AltFireAnim=Fire_Glock18C
	EquipWeapAnim=Equip_Glock18C
	PutdownWeapAnim=Putdown_Glock18C
	ReloadAnim=Reload_Glock18C
	ReloadEmptyAnim=Reload_Glock18C
	IdleAnim=Idle_ready_Glock18C
	DropAnim=Drop_Glock18C
}
