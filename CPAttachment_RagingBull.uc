class CPAttachment_RagingBull extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_RagingBull'
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_RagingBull.Mesh.SK_TA_RagingBull_3P'

	End Object

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_RB.PS_TA_Weap_RB'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_RB.PS_TA_Weap_RB'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)

	WeapAnimType=EWAT_Pistol

	FireAnim=Fire_RagingBull
	//AltFireAnim=none
	EquipWeapAnim=Equip_RagingBull
	PutdownWeapAnim=Putdown_RagingBull
	ReloadAnim=Reload_RagingBull
	ReloadEmptyAnim=Reload_RagingBull
	IdleAnim=Idle_Ready_RagingBull
	DropAnim=Drop_RagingBull
	
	bSpawnsShellCasings=false
}