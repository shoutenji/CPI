class CPPawnSoundGroup_Female extends CPPawnSoundGroup;

defaultproperties
{
	LandSound=SoundCue'CP_Character_Pain.female_pain.CP_Effort_Female_LandLight_Cue'
	DyingSound=SoundCue'CP_Character_Pain.female_pain.CP_Effort_Death_female'
	
	HitSounds[0]=SoundCue'CP_Character_Pain.female_pain.CP_Effort_Pain_Small_female'
	HitSounds[1]=SoundCue'CP_Character_Pain.female_pain.CP_Effort_Pain_Medium_female'
	HitSounds[2]=SoundCue'CP_Character_Pain.female_pain.CP_Effort_Pain_Large_female'

	FallingDamageLandSound=SoundCue'CP_Character_Pain.female_pain.CP_Effort_Female_LandHeavy_Cue'
	CrushedSound=SoundCue'TEMP_CharacterSounds.BodyImpacts.A_Character_BodyExplosion_Cue'

	DefaultFootStepSound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue'
	FootstepSounds.Empty()
	
	// the ones that doesn't exist yet for TA are tabbed out
	FootstepSounds[0]=(MaterialType=Carpet,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_CarpetCue')
	FootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue')
	//	FootstepSounds[2]=(MaterialType=Glass,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue')
	//	FootstepSounds[12]=(MaterialType=GlassBroken,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
	FootstepSounds[3]=(MaterialType=Grass,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_GrassCue')
	//	FootstepSounds[4]=(MaterialType=Water,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue')
	FootstepSounds[5]=(MaterialType=ShallowWater,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_WaterShallowCue')
	FootstepSounds[6]=(MaterialType=Metal,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_MetalCue')
	FootstepSounds[7]=(MaterialType=Snow,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_SnowCue')
	FootstepSounds[8]=(MaterialType=Stone,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_StoneCue')
	FootstepSounds[9]=(MaterialType=Tile,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_TileCue')
	FootstepSounds[10]=(MaterialType=Wood,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_WoodCue')
	FootstepSounds[11]=(MaterialType=Mud,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_MudCue')

	DefaultLandingSound=SoundCue'TA_Character_Footsteps.Land.LND_Dirt_Cue'

	LandingSounds.Empty()
	LandingSounds[0]=(MaterialType=Stone,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Stone_Cue')
	LandingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Dirt_Cue')
	//	LandingSounds[2]=(MaterialType=Energy,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_EnergyLandCue')
	//	LandingSounds[3]=(MaterialType=Flesh_Human,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_FleshLandCue')
	//	LandingSounds[4]=(MaterialType=Foliage,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_FoliageLandCue')
	//	LandingSounds[5]=(MaterialType=Glass,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassPlateLandCue')
	//	LandingSounds[6]=(MaterialType=GlassBroken,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
	LandingSounds[7]=(MaterialType=Grass,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Grass_Cue')
	LandingSounds[8]=(MaterialType=Metal,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Metal_Cue')
	LandingSounds[9]=(MaterialType=Mud,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Mud_Cue')
	LandingSounds[10]=(MaterialType=Snow,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Snow_Cue')
	LandingSounds[11]=(MaterialType=Tile,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Tile_Cue')
	//	LandingSounds[12]=(MaterialType=Water,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_WaterDeepLandCue')
	LandingSounds[13]=(MaterialType=ShallowWater,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Water_Sh_Cue')
	LandingSounds[14]=(MaterialType=Wood,Sound=SoundCue'TA_Character_Footsteps.Land.LND_Wood_Cue')

	DefaultJumpingSound=SoundCue'TA_Character_Footsteps.Jump.JMP_Dirt_Cue'
	JumpingSounds.Empty()
	JumpingSounds[0]=(MaterialType=Stone,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Stone_Cue')
	JumpingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Dirt_Cue')
	//	JumpingSounds[2]=(MaterialType=Energy,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_EnergyLandCue')
	//	JumpingSounds[3]=(MaterialType=Flesh_Human,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_FleshLandCue')
	//	JumpingSounds[4]=(MaterialType=Foliage,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_FoliageLandCue')
	//	JumpingSounds[5]=(MaterialType=Glass,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassPlateLandCue')
	//	JumpingSounds[6]=(MaterialType=GlassBroken,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
	JumpingSounds[7]=(MaterialType=Grass,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Grass_Cue')
	JumpingSounds[8]=(MaterialType=Metal,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Metal_Cue')
	JumpingSounds[9]=(MaterialType=Mud,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Mud_Cue')
	JumpingSounds[10]=(MaterialType=Snow,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Snow_Cue')
	JumpingSounds[11]=(MaterialType=Tile,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Tile_Cue')
	//	JumpingSounds[12]=(MaterialType=Water,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_WaterDeepLandCue')
	JumpingSounds[13]=(MaterialType=ShallowWater,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Water_Sh_Cue')
	JumpingSounds[14]=(MaterialType=Wood,Sound=SoundCue'TA_Character_Footsteps.Jump.JMP_Wood_Cue')
}