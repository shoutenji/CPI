class CPAttachment_UMP45 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_UMP45'
	Begin Object Name=SkeletalMeshComponent0
		Rotation=(Pitch=-0,Yaw=-90,Roll=0)
		Translation=(X=0,Y=0.00,Z=0.00)
		Scale=0.8
		SkeletalMesh=SkeletalMesh'TA_WP_Ump45.Mesh.SK_TA_Ump45_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_3p'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_3p'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_UMP.PS_CP_UMP_SE'

	WeapAnimType = EWAT_SMG

	FireAnim=Fire_UMP45
	AltFireAnim=Fire_UMP45_Alt
	EquipWeapAnim=Equip_UMP45
	PutdownWeapAnim=Putdown_UMP45
	ReloadAnim=Reload_UMP45
	ReloadEmptyAnim=Reload_UMP45
	IdleAnim=Idle_Ready_UMP45
	DropAnim=Drop_UMP45
}
