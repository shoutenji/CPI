class CPEmitter extends Emitter
	dependsOn(CPPawn)
	notplaceable;

static final function ParticleSystem GetTemplateForDistance(const out array<DistanceBasedParticleTemplate> TemplateList,vector SpawnLocation,WorldInfo WI)
{
local PlayerController PC;
local int i;
local float Dist;

	if (TemplateList.length==0 || WI.NetMode==NM_DedicatedServer)
		return none;

	Dist=TemplateList[0].MinDistance*10.0;
	foreach WI.LocalPlayerControllers(class'PlayerController',PC)
		Dist=FMin(Dist, VSize(PC.ViewTarget.Location-SpawnLocation)*PC.LODDistanceFactor);
	for (i=0;i<TemplateList.length;i++)
	{
		if (Dist>=TemplateList[i].MinDistance)
			return TemplateList[i].Template;
	}
	return none;
}

simulated event SetTemplate(ParticleSystem NewTemplate,optional bool bDestroyOnFinish)
{
local PlayerController PC;
local int LODLevel;

	Super.SetTemplate(NewTemplate,bDestroyOnFinish);
	if (NewTemplate!=none)
	{
		if (WorldInfo.bDropDetail)
			LODLevel=1;
		else if (NewTemplate.LODDistances.length>1)
		{
			LODLevel=1;
			foreach LocalPlayerControllers(class'PlayerController', PC)
			{
				if (PC.ViewTarget!=none && VSize(PC.ViewTarget.Location-Location)*PC.LODDistanceFactor<NewTemplate.LODDistances[1] &&
					vector(PC.Rotation) dot (Location-PC.ViewTarget.Location)>=0.0)
				{
					LODLevel=0;
					break;
				}
			}
		}
		ParticleSystemComponent.SetLODLevel(LODLevel);
	}
}

function SetLightEnvironment(LightEnvironmentComponent Light)
{
	if (ParticleSystemComponent!=none)
		ParticleSystemComponent.SetLightEnvironment(Light);
}

defaultproperties
{
	Components.Remove(ArrowComponent0)
	Components.Remove(Sprite)

	Begin Object Name=ParticleSystemComponent0
		bAcceptsLights=false
		SecondsBeforeInactive=0
		bOverrideLODMethod=true
		LODMethod=PARTICLESYSTEMLODMETHOD_DirectSet
	End Object

	LifeSpan=7.0
	bDestroyOnSystemFinish=true
	bNoDelete=false
}
