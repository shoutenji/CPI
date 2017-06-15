class CPMeleeWeaponAttachment extends CPWeaponAttachment
	abstract;

defaultproperties
{
	MuzzleFlashLightClass=none
	
	ImpactEffects.Empty()
	ImpactEffects(0)=         (MaterialType=Carpet,       Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Carpet_cue',                  DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(1)=         (MaterialType=Dirt,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Dirt_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(2)=         (MaterialType=Glass,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Glass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(3)=         (MaterialType=GlassBroken,  Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Glass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(4)=         (MaterialType=Grass,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Grass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(5)=         (MaterialType=Water,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Water_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(6)=         (MaterialType=ShallowWater, Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Water_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(7)=         (MaterialType=Metal,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Steel_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(8)=         (MaterialType=Snow,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Snow_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(9)=         (MaterialType=Stone,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Stone_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(10)=        (MaterialType=Tile,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Tile_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(11)=        (MaterialType=Wood,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Wood_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(12)=        (MaterialType=Mud,          Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Mud_cue',                     DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(13)=        (MaterialType=Plastic,      Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Plastic_cue',                 DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	ImpactEffects(14)=        (MaterialType=Flesh,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Flesh_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	
	DefaultImpactEffect=   ( DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8, Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_DevTestSound_Cue' )
	
	AltImpactEffects.Empty()
	//AltImpactEffects(0)=         (MaterialType=Carpet,       Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Carpet_cue',                  DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(1)=         (MaterialType=Dirt,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Dirt_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(2)=         (MaterialType=Glass,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Glass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(3)=         (MaterialType=GlassBroken,  Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Glass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(4)=         (MaterialType=Grass,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Grass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(5)=         (MaterialType=Water,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Water_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(6)=         (MaterialType=ShallowWater, Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Water_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(7)=         (MaterialType=Metal,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Steel_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(8)=         (MaterialType=Snow,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Snow_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(9)=         (MaterialType=Stone,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Stone_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(10)=        (MaterialType=Tile,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Tile_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(11)=        (MaterialType=Wood,         Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Wood_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(12)=        (MaterialType=Mud,          Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Mud_cue',                     DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(13)=        (MaterialType=Plastic,      Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Plastic_cue',                 DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	//AltImpactEffects(14)=        (MaterialType=Flesh,        Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Flesh_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8)
	
	DefaultAltImpactEffect=( DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Knife_Impact', DecalWidth=8, DecalHeight=8, Sound=SoundCue'CP_Weapon_Sounds.MeleeImpacts.CP_A_MeleeImpact_Dirt_cue'  )

	ImpactEffectRotation=30.0f
}