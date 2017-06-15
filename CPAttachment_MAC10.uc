class CPAttachment_MAC10 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_MAC10'
	Begin Object Name=SkeletalMeshComponent0
		Rotation=(Pitch=-0,Yaw=90,Roll=0)
		Translation=(X=0,Y=0.00,Z=0.00)
		Scale=0.8
		SkeletalMesh=SkeletalMesh'TA_WP_Mac10.Mesh.SK_TA_Mac10_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_1P'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_1P'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_SE'

	WeapAnimType = EWAT_SMG

	FireAnim=Fire_MAC10
	//AltFireAnim=Fire_MAC10_Alt
	EquipWeapAnim=Equip_Mac10
	PutdownWeapAnim=Putdown_Mac10
	ReloadAnim=Reload_Mac10
	ReloadEmptyAnim=Reload_MAC10
	IdleAnim=Idle_Ready_Mac10
	DropAnim=Drop_Mac10
}

