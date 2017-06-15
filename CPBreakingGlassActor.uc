class CPBreakingGlassActor extends DynamicSMActor_Spawnable
	//hidecategories(DynamicSMActor)
	hidecategories(Movement)
	hidecategories(Display)	
	hidecategories(Attachment)
	hidecategories(Collision)
	hidecategories(Physics)
	hidecategories(Advanced)
	hidecategories(Debug)
	hidecategories(Object)
	Placeable;

var(SETUPGLASS) SoundCue SoundToPlayOnDamage;
var(SETUPGLASS) StaticMesh BrokenGlassMesh;
var StaticMesh UnBrokenGlassMesh;
var(SETUPGLASS) ParticleSystem	GlassParticleEffect;
var ParticleSystemComponent	PSCGlassEffect;
//var(SETUPGLASS) const editconst StaticMeshComponent	StaticMeshComponent;

var repnotify bool bGlassBroken;

replication 
{ 
	if(bNetDirty) bGlassBroken; 
}

simulated event ReplicatedEvent(name VarName) 
{
	if(VarName == 'bGlassBroken')
		ClientPlayGlassBreakFX(bGlassBroken); 
	super.ReplicatedEvent(VarName);
}

event PostBeginPlay()
{
	UnBrokenGlassMesh = StaticMeshComponent.StaticMesh;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(!bGlassBroken)
	{
		bGlassBroken=true;
		PlaySound(SoundToPlayOnDamage); //ensure sound is replicated correctly.
		SetStaticMesh(BrokenGlassMesh);

		if(Worldinfo.NetMode == NM_Standalone) //this just allows the effect to play in offline mode - all online mode use ClientPlayGlassBreakFX
		{
			if(WorldInfo.MyEmitterPool != none)
				PSCGlassEffect=WorldInfo.MyEmitterPool.SpawnEmitter(GlassParticleEffect,self.Location,rotator(Normal(self.Location)),self);
		}
	}
}

simulated function ClientPlayGlassBreakFX(bool bIsGlassBroken)
{
	if(bIsGlassBroken)
	{
		if(WorldInfo.MyEmitterPool != none)
			PSCGlassEffect=WorldInfo.MyEmitterPool.SpawnEmitter(GlassParticleEffect,self.Location,rotator(Normal(self.Location)),self);
	}
}

event Reset()
{
	bGlassBroken=false;
	SetStaticMesh(UnBrokenGlassMesh);

	if(PSCGlassEffect != none)
	{
		PSCGlassEffect.DeactivateSystem();
		//PSCGlassEffect = none;
		PSCGlassEffect.SetTemplate(GlassParticleEffect);
	}
}

DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh = StaticMesh'TA_pAldredAssets.Meshes.SM_TA_3x4Window_Glass'
	End Object

	//maybe need to setup the lighting on this.
	SoundToPlayOnDamage=SoundCue'CP_Weapon_Sounds.WeaponImpacts.CP_A_weapon_breakingGlass_Cue'

	BrokenGlassMesh             = StaticMesh'TA_pAldredAssets.Meshes.SM_TA_3x4Window_GlassBroken'
	GlassParticleEffect         = ParticleSystem'TA_JasonMathews_Particles.Particles.PS_TA_GlassShatter' 
	
	//Object.Emitter.ParticleSystemComponent.Object.Lighting.LightingChannels (bInitialized=True,BSP=False,Static=False,Dynamic=True,CompositeDynamic=False,Skybox=False,Unnamed_1=False,Unnamed_2=False,Unnamed_3=False,Unnamed_4=False,Unnamed_5=False,Unnamed_6=False,Cinematic_1=False,Cinematic_2=False,Cinematic_3=False,Cinematic_4=False,Cinematic_5=False,Cinematic_6=False,Cinematic_7=False,Cinematic_8=False,Cinematic_9=False,Cinematic_10=False,Gameplay_1=False,Gameplay_2=False,Gameplay_3=False,Gameplay_4=False,Crowd=False)
	bGlassBroken=false;
	bAlwaysRelevant=true;
}