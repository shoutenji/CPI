class CPAttachment_SIG552 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_SIG552'
	Begin Object Name=SkeletalMeshComponent0
		//Rotation=(Pitch=0,Yaw=-2,Roll=-20)
		//Translation=(X=2.20,Y=0.20,Z=0.00)
		//Scale=0.9
		SkeletalMesh=SkeletalMesh'TA_WP_SIG552.Mesh.SK_TA_SIG552_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG_3P'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_Weap_SIG_3P'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_SIG.PS_CP_SIG_SE'

	WeapAnimType = EWAT_Rifle

	FireAnim=Fire_SIG552
	AltFireAnim=Fire_SIG552_Alt
	EquipWeapAnim=Equip_SIG552
	PutdownWeapAnim=Putdown_SIG552
	ReloadAnim=Reload_SIG552
	ReloadEmptyAnim=Reload_SIG552
	IdleAnim=Idle_ready_SIG552
	DropAnim=Drop_SIG552
}
