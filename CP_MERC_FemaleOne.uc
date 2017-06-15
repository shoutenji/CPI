class CP_MERC_FemaleOne extends CPFamilyInfo;

defaultproperties
{
	FamilyID="FEMALE1"
	Faction="MERC"
	bIsFemale=true
	CharacterMesh=SkeletalMesh'TA_CH_MERC_Female01.Mesh.TA_SK_Merc_Female01_3P_Body'
	ArmMeshPackageName="TA_WP_Arms_All"
	ArmSkinPackageName="TA_WP_Arms_All"
	ArmMesh=TA_WP_Arms_All.Mesh.SK_TA_SWAT_Female_Arms_1P
	PhysAsset=PhysicsAsset'TA_CH_All.Stuff.TA_PA_Female'
	AnimSets(0)=AnimSet'TA_CH_All.Stuff.TA_AS_Human'
	SoundGroupClass=class'CPPawnSoundGroup_Female'
	VoiceClass=class'CPVoice'

	HeadHair=SkeletalMesh'TA_CH_MERC_Female01.Mesh.TA_SK_Merc_Female01_3P_Head_Hair'
	HeadHelmet=SkeletalMesh'TA_CH_MERC_Female01.Mesh.TA_SK_Merc_Female01_3P_Head_Helmet'
	Vest=SkeletalMesh'TA_CH_MERC_Female01.Mesh.TA_SK_Merc_Female01_3P_Armor'

	CharacterMaterials[0]=Material'TA_CH_MERC_Female01.Mat.TA_M_MERC_Female01_Outfit'
	CharacterMaterials[1]=Material'TA_CH_MERC_Female01.Mat.TA_M_MERC_Female01_Hair'

}
