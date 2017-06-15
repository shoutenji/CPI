class CPAttachment_Mossberg590 extends CPWeaponShotgunAttachment;


defaultproperties
{
	WeaponClass=class'CPWeap_Mossberg590'
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
	ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Mossberg.PS_CP_Mossberg_SE'

	WeapAnimType = EWAT_Shotgun

	FireAnim=Fire_Mossberg590
	AltFireAnim=Fire_Fire_Mossberg590
	EquipWeapAnim=Equip_Mossberg590
	PutdownWeapAnim=Putdown_Mossberg590_Start
	ReloadAnim=Reload_Mossberg590_Start
	ReloadAnim_Mid=Reload_Mossberg590_Mid
	ReloadAnim_End=Reload_Mossberg590_End
	ReloadEmptyAnim=Reload_Mossberg590_Start
	IdleAnim=Idle_Ready_Mossberg590
	DropAnim=Drop_Mossberg590

	DefaultImpactEffect=(DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact', DecalWidth=6, DecalHeight=6,ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Beam_Impact'/*, Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_ImpactCue'*/)
	DefaultAltImpactEffect=(DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact', DecalWidth=6,DecalHeight=6, ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Beam_Impact'/*, Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_ImpactCue'*/)
}
