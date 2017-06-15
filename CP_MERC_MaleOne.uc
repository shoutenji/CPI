class CP_MERC_MaleOne extends CPFamilyInfo;

defaultproperties
{
	FamilyID="MALE1"
	Faction="MERC"
	CharacterMesh=SkeletalMesh'TA_CH_MERC_Male01.Mesh.TA_SK_MERC_Male01_3P_Body'
	ArmMeshPackageName="TA_WP_Arms_All"
	ArmSkinPackageName="TA_WP_Arms_All"
	ArmMesh=TA_WP_Arms_All.Mesh.SK_TA_SWAT_Male_Arms_1P
	PhysAsset=PhysicsAsset'TA_CH_All.Stuff.TA_PA_Male'
	AnimSets(0)=AnimSet'TA_CH_All.Stuff.TA_AS_Human'
	SoundGroupClass=class'CPPawnSoundGroup'
	VoiceClass=class'CPVoice'

	HeadHair=SkeletalMesh'TA_CH_MERC_Male01.Mesh.TA_SK_MERC_Male01_3P_Head_Hair'
	HeadHelmet=SkeletalMesh'TA_CH_MERC_Male01.Mesh.TA_SK_MERC_Male01_3P_Head_Helmet'
	Vest=SkeletalMesh'TA_CH_MERC_Male01.Mesh.TA_SK_MERC_Male01_3P_Armor'

	CharacterMaterials[0]=Material'TA_CH_MERC_Male01.Mat.TA_M_MERC_Male01_3P_Armor'
	CharacterMaterials[1]=Material'TA_CH_MERC_Male01.Mat.TA_M_MERC_Male01_3P_Body'
	CharacterMaterials[2]=Material'TA_CH_MERC_Male01.Mat.TA_M_MERC_Male01_3P_Outfit'
}