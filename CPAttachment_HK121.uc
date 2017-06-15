class CPAttachment_HK121 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_HK121'
	Begin Object Name=SkeletalMeshComponent0
		Rotation=(Pitch=-0,Yaw=-90,Roll=0)
		Translation=(X=0,Y=0.00,Z=0.00)
		Scale=0.8
		SkeletalMesh=SkeletalMesh'TA_WP_HK121.Mesh.SK_TA_HK121_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG_3P'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG_3P'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_HK121.PS_CP_HK121_SE'

	WeapAnimType = EWAT_RIFLE

	FireAnim=Fire_SCAR-H
	AltFireAnim=Fire_SCAR-H_Alt
	EquipWeapAnim=Equip_SCAR-H
	PutdownWeapAnim=Putdown_SCAR-H
	ReloadAnim=Reload_SCAR-H
	ReloadEmptyAnim=Reload_SCAR-H
	IdleAnim=Idle_Ready_SCAR-H
	DropAnim=Drop_SCAR-H
}