class CPProjectile extends UDKProjectile
	abstract;

var SoundCue AmbientSound;
var SoundCue ExplosionSound;
var	bool bImportantAmbientSound;
var ParticleSystemComponent	ProjEffects;
var ParticleSystem ProjFlightTemplate;
var ParticleSystem ProjExplosionTemplate;
var bool bAdvanceExplosionEffect;
var MaterialInterface ExplosionDecal;
var float DecalWidth, DecalHeight;
var float DurationOfDecal;
var name DecalDissolveParamName;
var float MaxEffectDistance;
var bool bSuppressExplosionFX;
var bool bWaitForEffects;
var float TossZ;
var float GlobalCheckRadiusTweak;
var bool bAttachExplosionToVehicles;
var class<PointLightComponent> ProjectileLightClass;
var PointLightComponent ProjectileLight;
var class<UDKExplosionLight> ExplosionLightClass;
var float MaxExplosionLightDistance;

simulated event CreateProjectileLight()
{
	if (WorldInfo.bDropDetail)
		return;
	ProjectileLight=new(self) ProjectileLightClass;
	AttachComponent(ProjectileLight);
}

simulated event Landed(vector HitNormal,actor FloorActor)
{
	HitWall(HitNormal,FloorActor,none);
}

simulated function bool CanSplash()
{
	return false;
}

simulated function PostBeginPlay()
{
local AudioComponent AmbientComponent;

	if (Role==ROLE_Authority)
	{
		if (!bWideCheck)
			CheckRadius*=GlobalCheckRadiusTweak;
		bWideCheck=bWideCheck ||
					((CheckRadius>0) &&
					(Instigator!=none) &&
					(CPPlayerController(Instigator.Controller)!=none) &&
					CPPlayerController(Instigator.Controller).AimingHelp(false));
	}

	super.PostBeginPlay();

	if (bDeleteMe || bShuttingDown)
		return;
	if (AmbientSound!=none && WorldInfo.NetMode!=NM_DedicatedServer)
	{
		if (bImportantAmbientSound || (!WorldInfo.bDropDetail && (WorldInfo.GetDetailMode()!=DM_Low)))
		{
			AmbientComponent=CreateAudioComponent(AmbientSound,true,true);
			if (AmbientComponent!=none)
				AmbientComponent.bShouldRemainActiveIfDropped=true;
		}
	}
	SpawnFlightEffects();
}

simulated event SetInitialState()
{
	bScriptInitialized=true;
	if (Role<ROLE_Authority && AccelRate!=0.0f)
		GotoState('WaitingForVelocity');
	else
		GotoState((InitialState!='None') ? InitialState : 'Auto');
}

function Init(vector Direction)
{
	SetRotation(rotator(Direction));
	Velocity=Speed*Direction;
	Velocity.Z+=TossZ;
	Acceleration=AccelRate*Normal(Velocity);
}

simulated function ProcessTouch(Actor Other,Vector HitLocation,Vector HitNormal)
{
	if (DamageRadius>0.0)
		Explode(HitLocation,HitNormal);
	else
	{
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer*Normal(Velocity),MyDamageType,,self);
		Shutdown();
	}
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
	if (Damage>0 && DamageRadius>0)
	{
		if (Role==ROLE_Authority)
			MakeNoise(1.0);
		if (!bShuttingDown)
			// ProjectileHurtRadius returns true if some locally authoritative actor is damaged
			if( ProjectileHurtRadius(HitLocation,HitNormal) )
			{
				CPGameReplicationInfo(WorldInfo.GRI).bDamageTaken=true;
			}
	}
	SpawnExplosionEffects(HitLocation, HitNormal);
	ShutDown();
}


simulated function SpawnFlightEffects()
{
	if (WorldInfo.NetMode!=NM_DedicatedServer && ProjFlightTemplate!=none)
	{
		ProjEffects=WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate);
		ProjEffects.SetAbsolute(false,false,false);
		ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ProjEffects.OnSystemFinished=MyOnParticleSystemFinished;
		ProjEffects.bUpdateComponentInTick=true;
		AttachComponent(ProjEffects);
	}
}

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion);

simulated function SpawnExplosionEffects(vector HitLocation,vector HitNormal)
{
local vector LightHitLocation,LightHitNormal,LightLoc;
local vector Direction;
local ParticleSystemComponent ProjExplosion;
local Actor EffectAttachActor;
local MaterialInstanceTimeVarying MITV_Decal;

	if (WorldInfo.NetMode!=NM_DedicatedServer)
	{
		if (ProjectileLight!=none)
		{
			DetachComponent(ProjectileLight);
			ProjectileLight=none;
		}
		if (ProjExplosionTemplate!=none && EffectIsRelevant(Location,false,MaxEffectDistance))
		{
			EffectAttachActor=ImpactedActor;
			if (!bAdvanceExplosionEffect)
				ProjExplosion=WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate,HitLocation,rotator(HitNormal),EffectAttachActor);
			else
			{
				Direction=normal(Velocity-2.0*HitNormal*(Velocity dot HitNormal))*Vect(1,1,0);
				ProjExplosion=WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate,HitLocation,rotator(Direction),EffectAttachActor);
				ProjExplosion.SetVectorParameter('Velocity',Direction);
				ProjExplosion.SetVectorParameter('HitNormal',HitNormal);
			}
			SetExplosionEffectParameters(ProjExplosion);
			if (!WorldInfo.bDropDetail && ((ExplosionLightClass!=none) || (ExplosionDecal!=none)) && ShouldSpawnExplosionLight(HitLocation,HitNormal))
			{
				if (ExplosionLightClass!=none)
				{
					if (Trace(LightHitLocation,LightHitNormal,HitLocation+(0.25*ExplosionLightClass.default.TimeShift[0].Radius*HitNormal),HitLocation,false)==none)
						LightLoc=HitLocation+(0.25*ExplosionLightClass.default.TimeShift[0].Radius*(vect(1,0,0) >> ProjExplosion.Rotation));
					else
						LightLoc=HitLocation+(0.5*VSize(HitLocation-LightHitLocation)*(vect(1,0,0) >> ProjExplosion.Rotation));
				}
				UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ExplosionLightClass,LightLoc,EffectAttachActor);
			}
			if (ExplosionDecal!=none && Pawn(ImpactedActor)==none)
			{
				if (MaterialInstanceTimeVarying(ExplosionDecal)!=none)
				{
					if (Terrain(ImpactedActor)==none)
					{
						MITV_Decal=new(self) class'MaterialInstanceTimeVarying';
						MITV_Decal.SetParent(ExplosionDecal);
						WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal,HitLocation,rotator(-HitNormal),DecalWidth,DecalHeight,10.0,false);
						MITV_Decal.SetScalarStartTime(DecalDissolveParamName,DurationOfDecal);
					}
				}
				else
					WorldInfo.MyDecalManager.SpawnDecal(ExplosionDecal,HitLocation,rotator(-HitNormal),DecalWidth,DecalHeight,10.0,true);
			}
		}
	}
	if (ExplosionSound!=none)
		PlaySound(ExplosionSound,true);
	bSuppressExplosionFX=true;
}

simulated function bool ShouldSpawnExplosionLight(vector HitLocation,vector HitNormal)
{
	local PlayerController P;
	local float Dist;

	if ( ExplosionLightClass == none )
		return false;

	foreach LocalPlayerControllers( class'PlayerController', P )
	{
		Dist = VSize( P.ViewTarget.Location-Location );
		if ( ( P.Pawn == Instigator ) || ( Dist < ExplosionLightClass.Default.Radius ) || ( ( Dist < MaxExplosionLightDistance ) && ( ( vector( P.Rotation ) dot ( Location-P.ViewTarget.Location ) ) > 0 ) ) )
			return true;
	}

	return false;
}

simulated function Shutdown()
{
local vector HitLocation,HitNormal;

	bShuttingDown=true;
	HitNormal=normal(Velocity * -1);
	Trace(HitLocation,HitNormal,(Location+(HitNormal*-32)),Location+(HitNormal*32),true,vect(0,0,0));
	SetPhysics(PHYS_None);
	if (ProjEffects!=None)
		ProjEffects.DeactivateSystem();
	if (WorldInfo.NetMode!=NM_DedicatedServer && !bSuppressExplosionFX)
		SpawnExplosionEffects(Location,HitNormal);
	HideProjectile();
	SetCollision(false,false);

	if (bWaitForEffects)
	{
		if (bNetTemporary)
		{
			if (WorldInfo.NetMode==NM_DedicatedServer)
				Destroy();
			else
			{
				RemoteRole=ROLE_None;
				LifeSpan=FMax(LifeSpan, 2.0);
			}
		}
		else
		{
			bTearOff=true;
			if (WorldInfo.NetMode==NM_DedicatedServer)
				LifeSpan=0.15;
			else
				LifeSpan=FMax(LifeSpan,2.0);
		}
	}
	else
		Destroy();
}

event TornOff()
{
	ShutDown();
	Super.TornOff();
}

simulated function HideProjectile()
{
local MeshComponent ComponentIt;

	foreach ComponentList(class'MeshComponent',ComponentIt)
		ComponentIt.SetHidden(true);
}

simulated function Destroyed()
{
	if (WorldInfo.NetMode!=NM_DedicatedServer && !bSuppressExplosionFX)
		SpawnExplosionEffects(Location,vector(Rotation)*-1);
	if (ProjEffects!=none)
	{
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects=none;
	}
	super.Destroyed();
}

simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC==ProjEffects)
	{
		if (bWaitForEffects)
		{
			if (bShuttingDown)
				LifeSpan=0.01;
			else
				bWaitForEffects=false;
		}
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects=none;
	}
}

state WaitingForVelocity
{
	simulated function Tick(float DeltaTime)
	{
		if (!IsZero(Velocity))
		{
			Acceleration=AccelRate*Normal(Velocity);
			GotoState((InitialState!='None') ? InitialState : 'Auto');
		}
	}
}

simulated function bool CalcCamera(float fDeltaTime,out vector out_CamLoc,out rotator out_CamRot,out float out_FOV)
{
	out_CamLoc=Location+(CylinderComponent.CollisionHeight*Vect(0,0,1));
	return true;
}

static final function float CalculateTravelTime(float Dist,float MoveSpeed,float MaxMoveSpeed,float AccelMag)
{
local float ProjTime,AccelTime,AccelDist;

	if (AccelMag==0.0)
		return (Dist/MoveSpeed);
	else
	{
		ProjTime=(-MoveSpeed+Sqrt(Square(MoveSpeed)-(2.0*AccelMag*-Dist)))/AccelMag;
		AccelTime=(MaxMoveSpeed-MoveSpeed)/AccelMag;
		if (ProjTime>AccelTime)
		{
			AccelDist=(MoveSpeed*AccelTime)+(0.5*AccelMag*Square(AccelTime));
			ProjTime=AccelTime+((Dist-AccelDist)/MaxMoveSpeed);
		}
		return ProjTime;
	}
}

static simulated function float StaticGetTimeToLocation(vector TargetLoc,vector StartLoc,Controller RequestedBy)
{
	return CalculateTravelTime(VSize(TargetLoc-StartLoc),default.Speed,default.MaxSpeed,default.AccelRate);
}

simulated function float GetTimeToLocation(vector TargetLoc)
{
	return CalculateTravelTime(VSize(TargetLoc-Location),Speed,MaxSpeed,AccelRate);
}

simulated static function float GetRange()
{
local float AccelTime;

	if (default.LifeSpan==0.0)
		return 15000.0;
	else if (default.AccelRate==0.0)
		return (default.Speed*default.LifeSpan);
	else
	{
		AccelTime=(default.MaxSpeed-default.Speed)/default.AccelRate;
		if (AccelTime<default.LifeSpan)
			return ((0.5 * default.AccelRate*AccelTime*AccelTime)+(default.Speed*AccelTime)+(default.MaxSpeed*(default.LifeSpan-AccelTime)));
		else
			return (0.5*default.AccelRate*default.LifeSpan*default.LifeSpan)+(default.Speed*default.LifeSpan);
	}
}

defaultproperties
{
	DamageRadius=+0.0
	TossZ=0.0
	bWaitForEffects=false
	MaxEffectDistance=+10000.0
	MaxExplosionLightDistance=+4000.0
	CheckRadius=0.0
	bBlockedByInstigator=false
	TerminalVelocity=3500.0
	bCollideComplex=true
	bSwitchToZeroCollision=true
	CustomGravityScaling=1.0
	bAttachExplosionToVehicles=true
	bShuttingDown=false
	DurationOfDecal=24.0
	DecalDissolveParamName="DissolveAmount"
	GlobalCheckRadiusTweak=0.5
}
