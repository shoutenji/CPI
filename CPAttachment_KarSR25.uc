class CPAttachment_KarSR25 extends CPFiringWeaponAttachment;

defaultproperties
{
	WeaponClass=class'CPWeap_KarSR25'
	Begin Object Name=SkeletalMeshComponent0    
		//Rotation=(Pitch=-0,Yaw=-90,Roll=0)
		//Translation=(X=0,Y=0.00,Z=0.00)
		//Scale=0.8
		SkeletalMesh=SkeletalMesh'TA_WP_SR25.Mesh.SK_TA_SR25_3P'
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Sniper_Muzzle_Flash_3rd'
	MuzzleFlashAltPSCTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Sniper_Muzzle_Flash_3rd'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Kar.PS_CP_Kar_SE'

	WeapAnimType = EWAT_Sniper

	FireAnim=Fire_KAC_SR25
	AltFireAnim=Fire_KAC_SR25
	EquipWeapAnim=Equip_KAC_SR25
	PutdownWeapAnim=Putdown_KAC_SR25
	ReloadAnim=Reload_KAC_SR25
	ReloadEmptyAnim=Reload_KAC_SR25
	DropAnim=Drop_KACSR25
	IdleAnim=Idle_ready_KAC_SR25
}
