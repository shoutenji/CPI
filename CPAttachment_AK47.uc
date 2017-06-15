class CPAttachment_AK47 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_AK47'
	Begin Object Name=SkeletalMeshComponent0
		Rotation=(Pitch=-0,Yaw=-90,Roll=0)
		Translation=(X=0,Y=0.00,Z=0.00)
		Scale=0.8
		SkeletalMesh=SkeletalMesh'TA_WP_MP5A3.Mesh.SK_TA_MP5A3_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_AK47.PS_CP_AK47_1P'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_AK47.PS_CP_AK47_1P'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_MP5A3.PS_CP_MP5A3_SE'

	WeapAnimType = EWAT_SMG

	FireAnim=Fire_SIG552
	AltFireAnim=Fire_SIG552_Alt
	EquipWeapAnim=Equip_SIG552
	PutdownWeapAnim=Putdown_SIG552
	ReloadAnim=Reload_SIG552
	ReloadEmptyAnim=Reload_SIG552
	IdleAnim=Idle_Ready_SIG552
	DropAnim=Drop_SIG552
}