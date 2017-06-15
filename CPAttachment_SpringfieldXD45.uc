class CPAttachment_SpringfieldXD45 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_SpringfieldXD45'
	Begin Object Name=SkeletalMeshComponent0
		//Rotation=(Pitch=-10,Yaw=-0,Roll=-20)
		//Translation=(X=3.0,Y=0.5,Z=0.00)
		SkeletalMesh=SkeletalMesh'TA_WP_SpringfieldXD45.Mesh.SK_TA_SpringfieldXD45_3P'
	End Object

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_TA_Weap_9mm_3p'
	MuzzleFlashAltPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Glock.PS_TA_Weap_9mm_3p'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Springfield.PS_CP_SF_SE'

	WeapAnimType = EWAT_Pistol

	FireAnim=Fire_SpringfieldXD45
	AltFireAnim=Fire_SpringfieldXD45
	EquipWeapAnim=Equip_SpringfieldXD45
	PutdownWeapAnim=Putdown_SpringfieldXD45
	ReloadAnim=Reload_SpringfieldXD45
	ReloadEmptyAnim=Reload_SpringfieldXD45
	DropAnim=Drop_SpringfieldXD45
	IdleAnim=Idle_Ready_SpringfieldXD45
}
