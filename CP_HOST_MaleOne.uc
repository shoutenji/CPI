class CP_HOST_MaleOne extends CPFamilyInfo;

defaultproperties
{
	FamilyID="MALE1"
	Faction="HOSTAGE"
	CharacterMesh=SkeletalMesh'ta_ch_hostage_joe.Mesh.TA_SK_Hostage_Joe_3P'
   ArmMeshPackageName="TA_WP_Arms_All"
	ArmSkinPackageName="TA_WP_Arms_All"
	ArmMesh=TA_WP_Arms_All.Mesh.SK_TA_SWAT_Male_Arms_1P
	PhysAsset=PhysicsAsset'TA_CH_All.Stuff.TA_PA_Male'
	AnimSets(0)=AnimSet'TA_CH_All.Stuff.TA_AS_Human'
	SoundGroupClass=class'CPPawnSoundGroup'
	VoiceClass=class'CPVoice'
}
