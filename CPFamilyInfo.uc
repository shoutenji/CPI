class CPFamilyInfo extends Object
	dependsOn(CPPawn)
	abstract;

/**  @TODO - hookup character portraits   */
//var Texture DefaultHeadPortrait;
//var array<Texture> DefaultTeamHeadPortrait;
var string FamilyID;
var string Faction;
var SkeletalMesh CharacterMesh;
var string ArmMeshPackageName;
var SkeletalMesh ArmMesh;
var	string ArmSkinPackageName;
var PhysicsAsset PhysAsset;
var	array<AnimSet> AnimSets;
var name LeftFootBone;
var name RightFootBone;
var array<name> TakeHitPhysicsFixedBones;
var class<CPPawnSoundGroup> SoundGroupClass;
var class<CPVoice>	VoiceClass;
var array<DecalMaterial> BloodSplatterDecalWallMaterial;
var array<DecalMaterial> BloodSplatterDecalFloorMaterial;
var class<CPEmit_HitEffect> BloodEmitterClass;
var array<DistanceBasedParticleTemplate> BloodEffects;
var bool bIsFemale;
var SkeletalMesh HeadHair, HeadHelmet, Vest;
var array<MaterialInterface> CharacterMaterials;

function static SkeletalMesh GetFirstPersonArms()
{
	if (default.ArmMesh==none)
		`warn("Unable to load first person arms");
	return default.ArmMesh;
}

function static MaterialInterface GetFirstPersonArmsMaterial(int TeamNum)
{
   return GetFirstPersonArms().Materials[0];
}

function static GetTeamMaterials(int TeamNum,out array<MaterialInterface> oCharacterMaterials)
{
	//cant trust character setup process to get this right so we implicitly set these!
	oCharacterMaterials = default.CharacterMaterials;
}

static function class<CPVoice> GetVoiceClass()
{
	return Default.VoiceClass;
}

defaultproperties
{
/*
	LeftFootBone=b_LeftAnkle
	RightFootBone=b_RightAnkle
	TakeHitPhysicsFixedBones[0]=b_LeftAnkle
	TakeHitPhysicsFixedBones[1]=b_RightAnkle
*/
	LeftFootBone=Bip_L_Foot
	RightFootBone=Bip_R_Foot
	TakeHitPhysicsFixedBones[0]=Bip_L_Foot
	TakeHitPhysicsFixedBones[1]=Bip_R_Foot
	
	SoundGroupClass=class'CPPawnSoundGroup'
	BloodEmitterClass=class'CPEmit_BloodSpray'
	BloodSplatterDecalWallMaterial[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Blood_Wall_Splatter1'
	BloodSplatterDecalWallMaterial[1]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Blood_Wall_Splatter2'
	BloodSplatterDecalWallMaterial[2]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Blood_Wall_Splatter3'

	BloodSplatterDecalFloorMaterial[0]=DecalMaterial'TA_Molez_Particles.CP_Blood.D_CP_Blood_Pool_Large'
	BloodSplatterDecalFloorMaterial[1]=DecalMaterial'TA_Molez_Particles.CP_Blood.D_CP_Blood_Pool_Medium'
	BloodSplatterDecalFloorMaterial[2]=DecalMaterial'TA_Molez_Particles.CP_Blood.D_CP_Blood_Pool_Small'
	BloodSplatterDecalFloorMaterial[3]=DecalMaterial'TA_Molez_Particles.CP_Blood.D_CP_Blood_Pool_Large_Wet'
	BloodSplatterDecalFloorMaterial[4]=DecalMaterial'TA_Molez_Particles.CP_Blood.D_CP_Blood_Pool_Medium_Wet'
	BloodSplatterDecalFloorMaterial[5]=DecalMaterial'TA_Molez_Particles.CP_Blood.D_CP_Blood_Pool_Small_Wet'

	BloodEffects[0]=(Template=ParticleSystem'TEMP_Cleanup2.Effects.P_FX_Bloodhit_Far',MinDistance=750.0)
	BloodEffects[1]=(Template=ParticleSystem'TEMP_Cleanup2.Effects.P_FX_Bloodhit_Mid',MinDistance=350.0)
	BloodEffects[2]=(Template=ParticleSystem'TEMP_Cleanup2.Effects.P_FX_Bloodhit_Near',MinDistance=0.0)
}
