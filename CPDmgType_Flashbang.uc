class CPDmgType_Flashbang extends CPDamageType
	abstract;

defaultproperties
{
	//KillStatsName=KILLS_SHOCKRIFLE
	//DeathStatsName=DEATHS_SHOCKRIFLE
	//SuicideStatsName=SUICIDES_SHOCKRIFLE
	DamageWeaponClass=class'CPWeap_FlashBang'
	DamageWeaponFireMode=0

	DamageBodyMatColor=(R=40,B=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	VehicleMomentumScaling=2.0
	VehicleDamageScaling=0.7
	NodeDamageScaling=0.8
	KDamageImpulse=1500.0
	CustomTauntIndex=4
}