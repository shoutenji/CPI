class CPProj_HE extends CPProj_Grenade;

defaultproperties
{
	
	ProjExplosionTemplate=ParticleSystem'TA_Molez_Particles.Weap_HG.PS_CP_Hand_Grenade'

	ExplosionDecal=MaterialInstanceTimeVarying'CP_Juan_FX.Decals.D_CP_Flash_Scorch_Decal_MITV'
	DecalWidth=100.0
	DecalHeight=100.0
	DecalDissolveParamName="AlphaControle"
	
	Begin Object Name=StaticMeshComp
		StaticMesh=StaticMesh'TA_WP_ConcussionNade.Mesh.SM_TA_ConcussionNade_Pickup'
		bNotifyRigidBodyCollision=True
		Scale=2.0
		ScriptRigidBodyCollisionThreshold=5.000000
	End Object

	Damage=360.000000
	
	MyDamageType=Class'CPDmgType_HE'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

}
