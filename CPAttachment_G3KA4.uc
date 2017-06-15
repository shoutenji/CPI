class CPAttachment_G3KA4 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_G3KA4'
	Begin Object Name=SkeletalMeshComponent0
		Rotation=(Pitch=-0,Yaw=-90,Roll=0)
		Translation=(X=0,Y=0.00,Z=0.00)
		Scale=0.8
		SkeletalMesh=SkeletalMesh'TA_WP_G3KA4.Mesh.SK_TA_G3KA4_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG_3P'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG_3P'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_HKG3.PS_CP_HKG3_SE'

	WeapAnimType = EWAT_Rifle

	FireAnim=Fire_G3KA4
	AltFireAnim=Fire_G3KA4_Alt
	EquipWeapAnim=Equip_G3KA4
	PutdownWeapAnim=Putdown_G3KA4
	ReloadAnim=Reload_G3KA4
	ReloadEmptyAnim=Reload_G3KA4
	IdleAnim=Idle_Ready_G3KA4
	DropAnim=Drop_G3KA4
}
