class CPPawnSoundGroup extends Object
	abstract
	dependson(CPPhysicalMaterialProperty);

var SoundCue DodgeSound;
var SoundCue DoubleJumpSound;
var SoundCue DefaultJumpingSound;
var SoundCue LandSound;
var SoundCue FallingDamageLandSound;
var SoundCue DyingSound;
var SoundCue HitSounds[3];
var SoundCue DrownSound;
var SoundCue GaspSound;

struct FootstepSoundInfo
{
	var name MaterialType;
	var SoundCue Sound;
};

var array<FootstepSoundInfo> FootstepSounds; 
var array<FootstepSoundInfo> CrouchFootstepSounds;
var array<FootstepSoundInfo> WalkingFootstepSounds;
var SoundCue DefaultFootstepSound;
var SoundCue DefaultCrouchedFootstepSound;
var SoundCue DefaultWalkingFootstepSound;
var array<FootstepSoundInfo> JumpingSounds;
var array<FootstepSoundInfo> LandingSounds;
var SoundCue DefaultLandingSound;
var SoundCue BulletImpactSound;
var SoundCue CrushedSound;

static function PlayBulletImpact(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.BulletImpactSound);
}

static function PlayCrushedSound(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.CrushedSound);
}

static function PlayBodyExplosion(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.CrushedSound);
}

static function PlayDodgeSound(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.DodgeSound);
}

static function PlayDoubleJumpSound(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.DoubleJumpSound);
}

static function PlayJumpSound(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.DefaultJumpingSound);
}

static function PlayLandSound(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.LandSound);
}

static function PlayFallingDamageLandSound(Pawn P)
{
	CPPawn(P).PawnPlaySound(Default.FallingDamageLandSound);
}

static function SoundCue GetDyingSound()
{
	return default.DyingSound;
}

static function PlayGaspSound(Pawn P)
{
	P.PlaySound(default.GaspSound, true);
}

static function PlayDrownSound(Pawn P)
{
	P.PlaySound(default.DrownSound, true);
}

static function SoundCue GetFootstepSound(int FootDown, name MaterialType)
{
local int i;

	i=default.FootstepSounds.Find('MaterialType', MaterialType);
	return (i==-1 || MaterialType=='') ? default.DefaultFootstepSound : default.FootstepSounds[i].Sound;
}

static function SoundCue GetCrouchedFootstepSound(int FootDown, name MaterialType)
{
local int i;

	i=default.FootstepSounds.Find('MaterialType', MaterialType);
	return (i==-1 || MaterialType=='') ? default.DefaultCrouchedFootstepSound : default.CrouchFootstepSounds[i].Sound;
}

static function SoundCue GetWalkingFootstepSound(int FootDown, name MaterialType)
{
local int i;

	i=default.FootstepSounds.Find('MaterialType', MaterialType);
	return (i==-1 || MaterialType=='') ? default.DefaultWalkingFootstepSound : default.WalkingFootstepSounds[i].Sound;
}

static function SoundCue GetJumpSound(name MaterialType)
{
local int i;

	i=default.JumpingSounds.Find('MaterialType',MaterialType);
	return (i==-1 || MaterialType=='') ? default.DefaultJumpingSound : default.JumpingSounds[i].Sound;
}

static function SoundCue GetLandSound(name MaterialType)
{
local int i;

	i=default.LandingSounds.Find('MaterialType', MaterialType);
	return (i==-1 || MaterialType=='') ? default.DefaultLandingSound : default.LandingSounds[i].Sound;
}

static function PlayTakeHitSound(Pawn P,int Damage)
{
local int HitSoundIndex;

	if (P.Health>0.5*P.HealthMax)
		HitSoundIndex=(Damage<20) ? 0 : 1;
	else
		HitSoundIndex=(Damage<20) ? 1 : 2;
	CPPawn(P).ServerPawnPlaySound(default.HitSounds[HitSoundIndex],true);
}

defaultproperties
{
	LandSound=SoundCue'CP_Character_Pain.CP_Effort_Male_LandLight_Cue'
	DyingSound=SoundCue'CP_Character_Pain.CP_Effort_Death'
	HitSounds[0]=SoundCue'CP_Character_Pain.CP_Effort_Pain_Small'
	// HitSounds[0]=SoundCue'TEMP_CharacterSounds.Mean_Efforts.A_Effort_PainSmall_Cue'
	HitSounds[1]=SoundCue'CP_Character_Pain.CP_Effort_Pain_Medium'
	// HitSounds[1]=SoundCue'TEMP_CharacterSounds.Mean_Efforts.A_Effort_PainMedium_Cue'
	HitSounds[2]=SoundCue'CP_Character_Pain.CP_Effort_Pain_Large'
	// HitSounds[2]=SoundCue'TEMP_CharacterSounds.Mean_Efforts.A_Effort_PainLarge_Cue'
	FallingDamageLandSound=SoundCue'CP_Character_Pain.CP_Effort_Male_LandHeavy_Cue'
	CrushedSound=SoundCue'TEMP_CharacterSounds.BodyImpacts.A_Character_BodyExplosion_Cue'

	DefaultFootStepSound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue'

	FootstepSounds.Empty()
	
	// the ones that doesn't exist yet for TA are tabbed out
	FootstepSounds[0]=(MaterialType=Carpet,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_CarpetCue')
	FootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue')
	//	FootstepSounds[2]=(MaterialType=Glass,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue')
	//	FootstepSounds[12]=(MaterialType=GlassBroken,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
	FootstepSounds[3]=(MaterialType=Grass,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_GrassCue')
	FootstepSounds[4]=(MaterialType=Water,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_Water_Deep')
	FootstepSounds[5]=(MaterialType=ShallowWater,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_WaterShallowCue')
	FootstepSounds[6]=(MaterialType=Metal,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_MetalCue')
	FootstepSounds[7]=(MaterialType=Snow,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_SnowCue')
	FootstepSounds[8]=(MaterialType=Stone,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_StoneCue')
	FootstepSounds[9]=(MaterialType=Tile,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_TileCue')
	FootstepSounds[10]=(MaterialType=Wood,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_WoodCue')
	FootstepSounds[11]=(MaterialType=Mud,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_MudCue')

	DefaultCrouchedFootstepSound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_DefaultCue'

	CrouchFootstepSounds.Empty()
	
	// the ones that doesn't exist yet for TA are tabbed out
	CrouchFootstepSounds[0]=(MaterialType=Carpet,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_CarpetCue')
	CrouchFootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_DefaultCue')
	//	CrouchFootstepSounds[2]=(MaterialType=Glass,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue')
	//	CrouchFootstepSounds[12]=(MaterialType=GlassBroken,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
	CrouchFootstepSounds[3]=(MaterialType=Grass,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_GrassCue')
	CrouchFootstepSounds[4]=(MaterialType=Water,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_Water_Deep')
	CrouchFootstepSounds[5]=(MaterialType=ShallowWater,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_WaterShallowCue')
	CrouchFootstepSounds[6]=(MaterialType=Metal,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_MetalCue')
	CrouchFootstepSounds[7]=(MaterialType=Snow,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_SnowCue')
	CrouchFootstepSounds[8]=(MaterialType=Stone,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_StoneCue')
	CrouchFootstepSounds[9]=(MaterialType=Tile,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_TileCue')
	CrouchFootstepSounds[10]=(MaterialType=Wood,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_WoodCue')
	CrouchFootstepSounds[11]=(MaterialType=Mud,Sound=SoundCue'TA_Character_Footsteps.CrouchSteps.TA_Character_Crouchstep_MudCue')

	DefaultWalkingFootstepSound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_DefaultCue'
	
	WalkingFootstepSounds.Empty()

	// the ones that doesn't exist yet for TA are tabbed out
	WalkingFootstepSounds[0]=(MaterialType=Carpet,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_CarpetCue')
	WalkingFootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_DefaultCue')
	//	WalkingFootstepSounds[2]=(MaterialType=Glass,Sound=SoundCue'TA_Character_Footsteps.FootSteps.TA_Character_Footstep_DefaultCue')
	//	WalkingFootstepSounds[12]=(MaterialType=GlassBroken,Sound=SoundCue'TEMP_CharacterSounds.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
	WalkingFootstepSounds[3]=(MaterialType=Grass,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_GrassCue')
	WalkingFootstepSounds[4]=(MaterialType=Water,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_Water_Deep')
	WalkingFootstepSounds[5]=(MaterialType=ShallowWater,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_WaterShallowCue')
	WalkingFootstepSounds[6]=(MaterialType=Metal,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_MetalCue')
	WalkingFootstepSounds[7]=(MaterialType=Snow,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_SnowCue')
	WalkingFootstepSounds[8]=(MaterialType=Stone,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_StoneCue')
	WalkingFootstepSounds[9]=(MaterialType=Tile,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_TileCue')
	WalkingFootstepSounds[10]=(MaterialType=Wood,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_WoodCue')
	WalkingFootstepSounds[11]=(MaterialType=Mud,Sound=SoundCue'TA_Character_Footsteps.WalkSteps.TA_Character_Walkstep_MudCue')

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
