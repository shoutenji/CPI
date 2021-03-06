class CP_SWAT_MaleOne extends CPFamilyInfo;

defaultproperties
{
	FamilyID="MALE1"
	Faction="SWAT"
	CharacterMesh=SkeletalMesh'TA_CH_SWAT_Male02.Mesh.TA_SK_SWAT_Male02_3P_Body'
	ArmMeshPackageName="TA_WP_Arms_All"
	ArmSkinPackageName="TA_WP_Arms_All"
	ArmMesh=TA_WP_Arms_All.Mesh.SK_TA_SWAT_Male_Arms_1P
	PhysAsset=PhysicsAsset'TA_CH_All.Stuff.TA_PA_Male'
	AnimSets(0)=AnimSet'TA_CH_All.Stuff.TA_AS_Human'
	SoundGroupClass=class'CPPawnSoundGroup'
	VoiceClass=class'CPVoice'

	HeadHair=SkeletalMesh'TA_CH_SWAT_Male02.Mesh.TA_SK_SWAT_Male02_3P_Head_Hair' 
	HeadHelmet=SkeletalMesh'TA_CH_SWAT_Male02.Mesh.TA_SK_SWAT_Male02_3P_Head_Helmet' 
	Vest=SkeletalMesh'TA_CH_SWAT_Male02.Mesh.TA_SK_SWAT_Male02_3P_Armor'

	CharacterMaterials[0]=Material'TA_CH_SWAT_Male02.Mat.TA_M_SWAT_Male02_Body'
	CharacterMaterials[1]=Material'TA_CH_SWAT_Male02.Mat.TA_M_SWAT_Male02_Hair'
	CharacterMaterials[2]=Material'TA_CH_SWAT_Male02.Mat.TA_M_SWAT_Male02_Outfit'
}
