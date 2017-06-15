class CPAttachment_Remington870P extends CPWeaponShotgunAttachment;


defaultproperties
{
	WeaponClass=class'CPWeap_Remington870P'
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'TA_WP_Remington870P.Mesh.SK_TA_Remington870P_3P'
		//Translation=(X=3.00,Y=0.00,Z=0.00)
		//Scale=0.8
	End Object

	// temporaly
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Shotgun_Muzzle_Flash_3rd'
	MuzzleFlashAltPSCTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Shotgun_Muzzle_Flash_3rd'
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Rem.PS_CP_Rem_SE'

	WeapAnimType = EWAT_Shotgun

	FireAnim=Fire_Remington870
	AltFireAnim=Fire_Remington870
	EquipWeapAnim=Equip_Remington870
	PutdownWeapAnim=Putdown_Remington870
	ReloadAnim=Reload_Remington870_Start
	ReloadAnim_Mid=Reload_Remington870_Mid
	ReloadAnim_End=Reload_Remington870_End
	ReloadEmptyAnim=Reload_Remington870_Start
	IdleAnim=Idle_ready_Remington870
	DropAnim=Drop_Remington870

	DefaultImpactEffect=(DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact', DecalWidth=6, DecalHeight=6,ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Beam_Impact'/*, Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_ImpactCue'*/)
	DefaultAltImpactEffect=(DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact', DecalWidth=6,DecalHeight=6, ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Beam_Impact'/*, Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_ImpactCue'*/)
}
