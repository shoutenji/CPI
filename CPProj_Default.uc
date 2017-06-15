class CPProj_Default extends CPProjectile;

var vector ColorLevel;
var vector ExplosionColor;

simulated function ProcessTouch(Actor Other,vector HitLocation,vector HitNormal)
{
	if (Other!=Instigator)
	{
		if (!Other.IsA('Projectile') || Other.bProjTarget)
		{
			MomentumTransfer=(CPPawn(Other)!=none) ? 0.0 : 1.0;
			Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer*Normal(Velocity),MyDamageType,,self);
			Explode(HitLocation,HitNormal);
		}
	}
}

simulated event HitWall(vector HitNormal,Actor Wall,PrimitiveComponent WallComp)
{
	MomentumTransfer=1.0;
	Super.HitWall(HitNormal,Wall,WallComp);
}

simulated function SpawnFlightEffects()
{
	Super.SpawnFlightEffects();
	if (ProjEffects!=none)
		ProjEffects.SetVectorParameter('LinkProjectileColor', ColorLevel);
}

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
	Super.SetExplosionEffectParameters(ProjExplosion);
	ProjExplosion.SetVectorParameter('LinkImpactColor',ExplosionColor);
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'TEMP_Cleanup2.Effects.P_WP_Projectile'
	ProjExplosionTemplate=ParticleSystem'TEMP_Cleanup2.Effects.P_WP_Projectile_Impact'
	MaxEffectDistance=7000.0
	Speed=1400
	MaxSpeed=5000
	AccelRate=3000.0
	Damage=26
	DamageRadius=0
	MomentumTransfer=0
	CheckRadius=26.0
	MyDamageType=class'CPDmgType_Default'
	LifeSpan=3.0
	NetCullDistanceSquared=+144000000.0
	bCollideWorld=true
	DrawScale=1.2
	ExplosionSound=SoundCue'CP_Weapon_Sounds.Grenades.GrenadeExpolsion_Cue'
	ColorLevel=(X=1,Y=1.3,Z=1)
	ExplosionColor=(X=1,Y=1,Z=1);
}
