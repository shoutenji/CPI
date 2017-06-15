class CPWeaponAttachment extends Actor
    abstract
    dependson(CPPawn);


var class<Actor> SplashEffect;
var SkeletalMeshComponent Mesh;
var protected SkeletalMeshComponent OverlayMesh;
var name MuzzleFlashSocket;

var ParticleSystemComponent MuzzleFlashPSC;
var ParticleSystem MuzzleFlashPSCTemplate,MuzzleFlashAltPSCTemplate;
var color MuzzleFlashColor;
var bool bMuzzleFlashPSCLoops;
var class<UDKExplosionLight> MuzzleFlashLightClass;
var UDKExplosionLight MuzzleFlashLight;
var float MuzzleFlashDuration;
var SkeletalMeshComponent OwnerMesh;
var name AttachmentSocket;
var array<MaterialImpactEffect> ImpactEffects,AltImpactEffects;
var MaterialImpactEffect DefaultImpactEffect,DefaultAltImpactEffect;
var float ImpactEffectRotation;
var SoundCue BulletWhip;
var float MaxImpactEffectDistance;
var float MaxFireEffectDistance;
var bool bAlignToSurfaceNormal;
var class<CPWeapon> WeaponClass;
var float MaxDecalRangeSq;
var float DistFactorForRefPose;
var bool bMakeSplash;
var EWeapAnimType WeapAnimType;

//animations and timings below (keep section clean)
var name            FireAnim, AltFireAnim;
var name            EquipWeapAnim, PutdownWeapAnim;
var name            ReloadAnim, ReloadEmptyAnim;
var name            HackAnim;
var name            DropAnim;
var name            IdleAnim;

var AudioComponent  HackSound;

var ParticleSystemComponent ShellCasingPSC;
var name                    ShellCasingSocket;
var ParticleSystem ShellPSCTemplate;
var float ShellCasingDuration;


simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    SetTimer(1.0,true,'CheckToForceRefPose');
}

simulated event Destroyed()
{
    HackSound = none;
}

simulated function CheckToForceRefPose()
{
    if ((WorldInfo.TimeSeconds-Mesh.LastRenderTime)>1.0 || Mesh.MaxDistanceFactor<DistFactorForRefPose)
    {
        if (Mesh.bForceRefpose==0)
            Mesh.SetForceRefPose(true);
    }
    else
    {
        if (Mesh.bForceRefpose!=0)
            Mesh.SetForceRefPose(false);
    }
}

simulated function CreateOverlayMesh()
{
    if (WorldInfo.NetMode!=NM_DedicatedServer)
    {
        OverlayMesh=new(self) Mesh.Class;
        OverlayMesh.SetScale(1.00);
        OverlayMesh.SetSkeletalMesh(Mesh.SkeletalMesh);
        OverlayMesh.SetOwnerNoSee(true);
        OverlayMesh.SetOnlyOwnerSee(false);
        OverlayMesh.AnimSets=Mesh.AnimSets;
        OverlayMesh.SetParentAnimComponent(Mesh);
        OverlayMesh.bUpdateSkelWhenNotRendered=false;
        OverlayMesh.bIgnoreControllersWhenNotRendered=true;
        OverlayMesh.bOverrideAttachmentOwnerVisibility=true;
        if (UDKSkeletalMeshComponent(OverlayMesh)!=none)
            UDKSkeletalMeshComponent(OverlayMesh).SetFOV(UDKSkeletalMeshComponent(Mesh).FOV);
    }
}


function SetSkin(Material NewMaterial)
{
local int i,Cnt;

    if (NewMaterial==none)
    {
        if (default.Mesh.Materials.Length>0)
        {
            Cnt=Default.Mesh.Materials.Length;
            for (i=0;i<Cnt;i++)
                Mesh.SetMaterial(i,Default.Mesh.GetMaterial(i));
        }
        else if (Mesh.Materials.Length>0)
        {
            Cnt=Mesh.Materials.Length;
            for (i=0;i<Cnt;i++)
                Mesh.SetMaterial(i,none);
        }
    }
    else
    {
        if (default.Mesh.Materials.Length>0 || mesh.GetNumElements()>0)
        {
            Cnt=default.Mesh.Materials.Length>0 ? default.Mesh.Materials.Length : mesh.GetNumElements();
            for (i=0;i<Cnt;i++ )
                Mesh.SetMaterial(i,NewMaterial);
        }
    }
}

simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
    PSC.SetColorParameter('MuzzleFlashColor',MuzzleFlashColor);
}

simulated function AttachTo(CPPawn OwnerPawn)
{
    SetWeaponOverlayFlags(OwnerPawn);
    if (OwnerPawn.Mesh!=none)
    {
        if (Mesh!=none)
        {
            OwnerMesh=OwnerPawn.Mesh;
            AttachmentSocket=OwnerPawn.WeaponSocket;
            Mesh.SetShadowParent(OwnerPawn.Mesh);
            Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);
            if (OwnerPawn.ReplicatedBodyMaterial!=none)
                SetSkin(OwnerPawn.ReplicatedBodyMaterial);
            OwnerPawn.Mesh.AttachComponentToSocket(Mesh,OwnerPawn.WeaponSocket);
        }
        if (OverlayMesh!=none)
            OwnerPawn.Mesh.AttachComponentToSocket(OverlayMesh, OwnerPawn.WeaponSocket);
    }
    if (MuzzleFlashSocket!='')
    {
        if (MuzzleFlashPSCTemplate!=none || MuzzleFlashAltPSCTemplate!=none)
        {
            MuzzleFlashPSC=new(self) class'UDKParticleSystemComponent';
            MuzzleFlashPSC.bAutoActivate=false;
            MuzzleFlashPSC.SetOwnerNoSee(true);
            Mesh.AttachComponentToSocket(MuzzleFlashPSC,MuzzleFlashSocket);
        }
    }

    if (ShellCasingSocket != '')
    {
        ShellCasingPSC=new(self) class'UDKParticleSystemComponent';
        ShellCasingPSC.bAutoActivate=false;
        ShellCasingPSC.SetOwnerNoSee(true);
        Mesh.AttachComponentToSocket(ShellCasingPSC, ShellCasingSocket);
    }

    OwnerPawn.SetWeapAnimType(WeapAnimType);
}

simulated function DetachFrom(SkeletalMeshComponent MeshCpnt)
{
    SetSkin(None);
    if (Mesh!=none)
    {
        Mesh.SetShadowParent(None);
        Mesh.SetLightEnvironment(None);
        if (MuzzleFlashPSC!=none)
            Mesh.DetachComponent(MuzzleFlashPSC);
        if (MuzzleFlashLight!=none)
            Mesh.DetachComponent(MuzzleFlashLight);

        if (ShellCasingPSC != none)
            Mesh.DetachComponent(ShellCasingPSC);
    }
    if (MeshCpnt!=none)
    {
        if (Mesh!=none)
            MeshCpnt.DetachComponent(mesh);
        if (OverlayMesh!=none)
            MeshCpnt.DetachComponent(OverlayMesh);
    }
    GotoState('');
}

simulated function MuzzleFlashTimer()
{
    if (MuzzleFlashLight!=none)
        MuzzleFlashLight.SetEnabled(false);
    if (MuzzleFlashPSC!=none && !bMuzzleFlashPSCLoops)
        MuzzleFlashPSC.DeactivateSystem();
}

simulated function CauseMuzzleFlash()
{
local ParticleSystem MuzzleTemplate;

    //if ((!WorldInfo.bDropDetail && !class'Engine'.static.IsSplitScreen()) || WorldInfo.IsConsoleBuild(CONSOLE_Mobile) )
    //{
        if (MuzzleFlashLight==none)
        {
            if (MuzzleFlashLightClass!=none)
            {
                MuzzleFlashLight=new(Outer) MuzzleFlashLightClass;
                if (Mesh!=none && Mesh.GetSocketByName(MuzzleFlashSocket)!=none)
                    Mesh.AttachComponentToSocket(MuzzleFlashLight,MuzzleFlashSocket);
                else if (OwnerMesh!=none)
                    OwnerMesh.AttachComponentToSocket(MuzzleFlashLight, AttachmentSocket);
            }
        }
        else
            MuzzleFlashLight.ResetLight();
    //}
    if (MuzzleFlashPSC!=none)
    {
        if (!bMuzzleFlashPSCLoops || !MuzzleFlashPSC.bIsActive)
        {
            if (Instigator!=none && Instigator.FiringMode==1 && MuzzleFlashAltPSCTemplate!=none)
                MuzzleTemplate=MuzzleFlashAltPSCTemplate;
            else
                MuzzleTemplate=MuzzleFlashPSCTemplate;
            if (MuzzleTemplate!=MuzzleFlashPSC.Template)
                MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
            SetMuzzleFlashParams(MuzzleFlashPSC);
            MuzzleFlashPSC.ActivateSystem();
        }
    }

    SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
}

simulated function CauseShellLaunch()
{
    local ParticleSystem ShellTemplate;

    if (ShellCasingPSC != none)
    {
        ShellTemplate=ShellPSCTemplate;
        if (ShellTemplate != ShellCasingPSC.Template)
            ShellCasingPSC.SetTemplate(ShellTemplate);

        ShellCasingPSC.ActivateSystem();
    }
    SetTimer(ShellCasingDuration, false, 'ShellCasingTimer');
}

simulated function ShellCasingTimer()
{
    if (ShellCasingPSC!=none && !bMuzzleFlashPSCLoops)
        ShellCasingPSC.DeactivateSystem();
}

simulated function ThirdPersonFireEffects()
{
    local CPPawn    _Pawn;

    CauseMuzzleFlash();
    CauseShellLaunch();

    _Pawn = CPPawn( Instigator );
    if ( _Pawn != none && _Pawn.GunRecoilNode != none )
        _Pawn.GunRecoilNode.bPlayRecoil = true;

    if ( !PlayTopHalfAnimationDuration( _Pawn.FiringMode == 1 ? AltFireAnim : FireAnim, WeaponClass.default.FireStates[_Pawn.FiringMode].FireInterval[0] ) )
        PlayTopHalfAnimationDuration( _Pawn.FiringMode == 1 ? FireAnim : AltFireAnim, WeaponClass.default.FireStates[_Pawn.FiringMode].FireInterval[0] );
}

simulated event StopThirdPersonFireEffects()
{
    ClearTimer('MuzzleFlashTimer');
    MuzzleFlashTimer();
    if (MuzzleFlashPSC!=none)
        MuzzleFlashPSC.DeactivateSystem();

    ClearTimer('ShellCasingTimer');
    ShellCasingTimer();
    if (ShellCasingPSC!=none)
        ShellCasingPSC.DeactivateSystem();
}

//TOP-Proto uncomment everything in this function to re-enable impacts per material type hit.
simulated function MaterialImpactEffect GetImpactEffect(PhysicalMaterial HitMaterial)
{
    local int i;
    local CPPhysicalMaterialProperty PhysicalProperty;

    if (HitMaterial!=none)
        PhysicalProperty=CPPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'CPPhysicalMaterialProperty'));

    if (CPPawn(Owner).FiringMode>0)
    {
        if (PhysicalProperty!=none && PhysicalProperty.MaterialType!='None')
        {
            i=AltImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
            if (i!=-1)
                return AltImpactEffects[i];
        }
        return DefaultAltImpactEffect;
    }
    else
    {
        if (PhysicalProperty!=none && PhysicalProperty.MaterialType!='None')
        {
            i=ImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
            if (i!=-1)
                return ImpactEffects[i];
        }
        return DefaultImpactEffect;
    }
}

simulated function PlayImpactEffects( Vector HitLocation, Vector HitNormal )
{
    local vector NewHitLoc, FireDir/*, WaterHitNormal*/, HitNormal2, FireDir2;
    local Actor HitActor;
    local TraceHitInfo HitInfo;
    local MaterialImpactEffect ImpactEffect;
    local MaterialInterface MI;
    local MaterialInstanceTimeVarying MITV_Decal;
    local int DecalMaterialsLength;
    local Pawn HitPawn;
    local Vehicle HitVehicle;
    local interpcurvefloat theCurve;

    FireDir = -1 * HitNormal;

    if ( BulletWhip != none && Owner != none)
    {
        HitNormal2 = Normal(Owner.Location - HitLocation);
        FireDir2 = -1 * HitNormal2;
        CheckBulletWhip( FireDir2, HitLocation );
    }

    if ( Owner == none || !EffectIsRelevant( HitLocation, false, MaxImpactEffectDistance ) )
        return;

    HitActor = Trace( HitLocation, HitNormal, HitLocation+(FireDir*32), HitLocation-FireDir, true,, HitInfo, TRACEFLAG_Bullet );
    HitPawn = Pawn( HitActor );

    if( HitPawn != none )
    {
        CheckHitInfo( HitInfo, HitPawn.Mesh, -HitNormal, NewHitLoc );
        HitInfo.PhysMaterial = PhysicalMaterial'TA_CH_All.Stuff.TA_PM_Body';
        //todo need to distinguish between body and armor being hit here using hitinfo...
    }

    ImpactEffect = GetImpactEffect( HitInfo.PhysMaterial );

    HitVehicle = Vehicle( HitActor );

    if ( HitActor != none && HitPawn == none || HitVehicle != none && PortalTeleporter( HitActor ) == none )
    {
        if ( ImpactEffect.Sound != none && !IsZero( HitLocation ) )
        {
            if ( HitVehicle != none && HitVehicle.IsLocallyControlled() && HitVehicle.IsHumanControlled() )
                PlayerController( HitVehicle.Controller ).ClientPlaySound( ImpactEffect.Sound );
            else
                PlaySound( ImpactEffect.Sound, true,,, HitLocation );
        }

        /** TODO: These arguments need extensive testing - Kolby **/
        //if (!WorldInfo.bDropDetail
        //  && (Pawn(HitActor)==none)
        //  && (VSizeSQ(Owner.Location-HitLocation)<MaxDecalRangeSq)
        //  && (((WorldInfo.GetDetailMode()!=DM_Low) && !class'Engine'.static.IsSplitScreen()) || (P.IsLocallyControlled() && P.IsHumanControlled())))
        if ( VSizeSq( Owner.Location - HitLocation ) <= MaxDecalRangeSq )
        {
            DecalMaterialsLength = ImpactEffect.DecalMaterials.length;
            if ( DecalMaterialsLength > 0 )
            {
                MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength-1)];

                if ( MI != none )
                {
                    if ( MaterialInstanceTimeVarying( MI ) != none && Terrain( HitActor ) == none )
                    {
                        MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
                        MITV_Decal.SetParent( MI );
                        WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal,
                                                            HitLocation,
                                                            rotator(-HitNormal),
                                                            ImpactEffect.DecalWidth,
                                                            ImpactEffect.DecalHeight,
                                                            10.0,
                                                            false,
                                                            ((FRand()*ImpactEffectRotation*2.0f)-ImpactEffectRotation),
                                                            HitInfo.HitComponent,
                                                            true,
                                                            false,
                                                            HitInfo.BoneName,
                                                            HitInfo.Item,
                                                            HitInfo.LevelIndex);

                        MITV_Decal.SetScalarStartTime( ImpactEffect.DecalDissolveParamName, ImpactEffect.DurationOfDecal );

                        //if(MI == "");

                    }
                    else
                    {
                        //special case for metal
                        if(ImpactEffect.MaterialType == 'Metal')
                        {
                            MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
                            MITV_Decal.SetParent( MI );
                            WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal,
                                                                HitLocation,
                                                                rotator(-HitNormal),
                                                                ImpactEffect.DecalWidth,
                                                                ImpactEffect.DecalHeight,
                                                                10.0,
                                                                false,
                                                                ((FRand()*ImpactEffectRotation*2.0f)-ImpactEffectRotation),
                                                                HitInfo.HitComponent,
                                                                true,
                                                                false,
                                                                HitInfo.BoneName,
                                                                HitInfo.Item,
                                                                HitInfo.LevelIndex);

                            theCurve.Points.Insert(0,2);
                            theCurve.Points[0].InVal = 0;
                            theCurve.Points[0].OutVal = 1;
                            theCurve.Points[1].InVal = 2;
                            theCurve.Points[1].OutVal = 0;


                            MITV_Decal.SetScalarCurveParameterValue( 'GlowAmount',theCurve);
                            MITV_Decal.SetScalarStartTime( 'GlowAmount' , 2.0 );

                        }
                        else
                        {
                            WorldInfo.MyDecalManager.SpawnDecal(MI,
                                                                HitLocation,
                                                                rotator(-HitNormal),
                                                                ImpactEffect.DecalWidth,
                                                                ImpactEffect.DecalHeight,
                                                                10.0,
                                                                false,
                                                                ((FRand()*ImpactEffectRotation*2.0f)-ImpactEffectRotation),
                                                                HitInfo.HitComponent,
                                                                true,
                                                                false,
                                                                HitInfo.BoneName,
                                                                HitInfo.Item,
                                                                HitInfo.LevelIndex);
                        }
                    }
                }
            }
        }

        if ( ImpactEffect.ParticleTemplate != none )
        {
            if ( !bAlignToSurfaceNormal )
                HitNormal = normal( FireDir - (2*HitNormal*(FireDir dot HitNormal)) );

            if(WorldInfo.MyEmitterPool != none)
                WorldInfo.MyEmitterPool.SpawnEmitter( ImpactEffect.ParticleTemplate, HitLocation, rotator(HitNormal), HitActor);
        }
    }
}

simulated function CheckBulletWhip(vector FireDir,vector HitLocation)
{
local CPPlayerController PC;

    ForEach LocalPlayerControllers(class'CPPlayerController',PC)
    {
		//Check all bullets sounds from both teams
        //if (!WorldInfo.GRI.OnSameTeam(Owner,PC))
        PC.CheckBulletWhip(BulletWhip,Owner.Location,FireDir,HitLocation);
    }
}

simulated function SetWeaponOverlayFlags(CPPawn OwnerPawn)
{
local MaterialInterface InstanceToUse;
local byte Flags;
local int i;
local CPGameReplicationInfo GRI;

    GRI=CPGameReplicationInfo(WorldInfo.GRI);
    if (GRI!=none)
    {
        Flags=OwnerPawn.WeaponOverlayFlags;
        for (i=0;i<GRI.WeaponOverlays.length;i++)
        {
            if (GRI.WeaponOverlays[i]!=none && bool(Flags & (1 << i)))
            {
                InstanceToUse=GRI.WeaponOverlays[i];
                break;
            }
        }
    }
    if (InstanceToUse!=none)
    {
        if (OverlayMesh==none)
            CreateOverlayMesh();
        if (OverlayMesh!=none)
        {
            for (i=0;i<OverlayMesh.GetNumElements();i++)
                OverlayMesh.SetMaterial(i,InstanceToUse);
            OverlayMesh.SetHidden(false);
            if (!OverlayMesh.bAttached)
                OwnerPawn.Mesh.AttachComponentToSocket(OverlayMesh,OwnerPawn.WeaponSocket);
        }
    }
    else if (OverlayMesh!=none)
    {
        OverlayMesh.SetHidden(true);
        OwnerPawn.Mesh.DetachComponent(OverlayMesh);
    }
}

simulated function ChangeVisibility(bool bIsVisible)
{
    if (Mesh!=none)
        Mesh.SetHidden(!bIsVisible);
    if (OverlayMesh!=none)
        OverlayMesh.SetHidden(!bIsVisible);
}

/**
 * Plays an animation to the top half animation slot of the Instigator
 * @return The length of the animation played
 */
simulated function float PlayTopHalfAnimation( name AnimName, optional float Rate=1.0f, optional float BlendIn=0.2f, optional float BlendOut=0.2f, optional bool Loop=false )
{
    local CPPawn        _Pawn;


    _Pawn = CPPawn( Instigator );
    if ( _Pawn != none && _Pawn.WeaponAnimation != none )
    {
        _Pawn.WeaponAnimation.CameraAnimBlendInTime = BlendIn;
        _Pawn.WeaponAnimation.CameraAnimBlendOutTime = BlendOut;

        _Pawn.WeaponAnimation.SetAnim( AnimName );
        _Pawn.WeaponAnimation.PlayAnim( Loop, Rate );
        return _Pawn.WeaponAnimation.GetAnimPlaybackLength();
    }

    return 0.0f;
}

/**
 * Plays an animation to the top half animation slot of the Instigator with a set duration
 * @return True if the animation played successfully
 */
simulated function bool PlayTopHalfAnimationDuration( name AnimName, float Duration, optional float BlendIn=0.2f, optional float BlendOut=0.2f, optional bool Loop=false )
{
    local CPPawn        _Pawn;


    _Pawn = CPPawn( Instigator );
    if ( _Pawn != none && _Pawn.WeaponAnimation != none && Duration > 0.0 )
    {
        _Pawn.WeaponAnimation.Rate = 1.0f;
        _Pawn.WeaponAnimation.CameraAnimBlendInTime = BlendIn;
        _Pawn.WeaponAnimation.CameraAnimBlendOutTime = BlendOut;

        _Pawn.WeaponAnimation.SetAnim( AnimName );
        // `Log("@@ ***************************************");
        // `Log("@@ Animation.Name = "$string(_Pawn.WeaponAnimation.AnimSeqName));
        // `Log("@@ Animation.Length = "$string(_Pawn.WeaponAnimation.GetAnimPlaybackLength()/Duration));
        // `Log("@@ ***************************************");
        _Pawn.WeaponAnimation.PlayAnim( Loop, _Pawn.WeaponAnimation.GetAnimPlaybackLength() / Duration );
        return true;
    }

    return false;
}

/**
 * Gets the Instigator's Critical Point weapon
 * @arg OutWeapon - Self explanatory?
 * @return True if successful
 */
simulated function bool InstigatorWeapon( out CPWeapon OutWeapon )
{
    OutWeapon = CPWeapon( Instigator.Weapon );
    return OutWeapon != none;
}

simulated function vector GetEffectLocation()
{
    local vector SocketLocation;

    if (MuzzleFlashSocket!='None')
    {
        Mesh.GetSocketWorldLocationAndRotation(MuzzleFlashSocket,SocketLocation);
        return SocketLocation;
    }
    return Mesh.Bounds.Origin+(vect(45,0,0) >> Instigator.Rotation);
}

// auto simulated state Idle
// {
    // simulated event BeginState( name PreviousStateName )
    // {
        // PlayTopHalfAnimation( IdleAnim,,,, true );

		// if(Instigator.Controller == none)
        // {
            // if(Instigator.Weapon != none)
            // {
                // Instigator.Weapon.GotoState('Active');
            // }
        // }
    // }
// }

// simulated state FireEmpty
// {
    // simulated event BeginState( name PreviousStateName )
    // {
		// local CPPawn    _Pawn;

        // _Pawn = CPPawn( Instigator );
        // if ( _Pawn != none && _Pawn.GunRecoilNode != none )
            // _Pawn.GunRecoilNode.bPlayRecoil = true;

		// TODO FireAnim --> FireEmptyAnim

		// TOP-Proto some weapons have an alt function such as DE for laser dots - we do not want to play fire empty animations for things like that in 3rd person mode
		// Totally removing the ability to play any animations in 3rd person when using the alt fire functionality.
		// if(_Pawn.FiringMode != 1)
		// {
			// if ( !PlayTopHalfAnimationDuration( FireAnim, WeaponClass.default.FireStates[0].FireInterval[0] ) )
				// PlayTopHalfAnimationDuration( FireAnim , WeaponClass.default.FireStates[0].FireInterval[0] );
		// }

		// if(Instigator.Controller == none)
        // {
            // if(Instigator.Weapon != none)
            // {
				// `Log("efi weap" @ Instigator.Weapon);
				// Instigator.Weapon.GotoState('WeaponEmptyFiring');               
            // }
        // }
    // }
// }

// simulated state Firing
// {
    // simulated function ThirdPersonFireEffects()
    // {
        // local CPPawn    _Pawn;
 
		// local and spectator for springfield but not nade
        // `Log("@@ ThirdPersonFireEffects");
        // CauseMuzzleFlash();
		// CauseShellLaunch();

        // _Pawn = CPPawn( Instigator );
        // if ( _Pawn != none && _Pawn.GunRecoilNode != none )
            // _Pawn.GunRecoilNode.bPlayRecoil = true;

        // if ( !PlayTopHalfAnimationDuration( _Pawn.FiringMode == 1 ? AltFireAnim : FireAnim, WeaponClass.default.FireStates[_Pawn.FiringMode].FireInterval[0] ) )
            // PlayTopHalfAnimationDuration( _Pawn.FiringMode == 1 ? FireAnim : AltFireAnim, WeaponClass.default.FireStates[_Pawn.FiringMode].FireInterval[0] );

        // for spectator 
        // if(Instigator.Controller == none)
        // {
            // `Log("@@ CPWeaponAttachment::Firing::ThirdPersonFireEffects");  
            // if(Instigator.Weapon != none)
            // {
                // Instigator.Weapon.GotoState('WeaponFiring');
                // CPWeapon(Instigator.Weapon).GoToFiringState(Instigator.Weapon.CurrentFireMode);
            // }
        // }
    // }
    
    // simulated event BeginState( name PreviousStateName )
	// {
         // ThirdPersonFireEffects();
        // `Log("@@ CPWeaponAttachment::BeginState::Firing");
    // }
// }

// simulated state Equipping
// {
    // simulated event BeginState( name PreviousStateName )
    // {
        // PlayTopHalfAnimationDuration( EquipWeapAnim, WeaponClass.default.EquipTime );

        // if(Instigator.Controller == none)
        // {
            // if(Instigator.Weapon != none)
            // {
                // `Log("eq weap" @ Instigator.Weapon);
                // Instigator.Weapon.GotoState('WeaponEquipping');
            // }
        // }
        // Instigator.SetTimer( WeaponClass.default.EquipTime, false, 'EquippingFinished' );
    // }
// }

// simulated state HoldingFire
// {
    // simulated event BeginState( name PreviousStateName )
	// {
        // `Log("@@ CPWeaponAttachment::BeginState::HoldingFire");
    // }
// }

// simulated state PuttingDown
// {
    // simulated event BeginState( name PreviousStateName )
    // {
        // PlayTopHalfAnimationDuration( PutdownWeapAnim, WeaponClass.default.PutDownTime );

        // if(Instigator.Controller == none)
        // {
            // if(Instigator.Weapon != none)
            // {
                // `Log("pd weap" @ Instigator.Weapon);
                // Instigator.Weapon.GotoState('WeaponPuttingDown');
            // }
        // }

        // Instigator.SetTimer( WeaponClass.default.PutdownTime, false, 'PuttingDownFinished' ); //x
    // }
// }

// simulated state Reloading
// {
    // simulated event BeginState( name PreviousStateName )
    // {
        // PlayTopHalfAnimationDuration( ReloadAnim, WeaponClass.default.ReloadTime );

        // if(Instigator.Controller == none)
        // {
            // if(Instigator.Weapon != none)
            // {
                // `Log("re weap" @ Instigator.Weapon);
                // Instigator.Weapon.GotoState('Reloading');
            // }
        // }
    // }
// }

// simulated state ReloadingEmpty
// {
    // simulated event BeginState( name PreviousStateName )
    // {
        // PlayTopHalfAnimationDuration( ReloadEmptyAnim, WeaponClass.default.ReloadEmptyTime );

        // if(Instigator.Controller == none)
        // {
            // if(Instigator.Weapon != none)
            // {
                // `Log("ree weap" @ Instigator.Weapon);
                // Instigator.Weapon.GotoState('Reloading'); //todo check this
            // }
        // }
    // }
// }

// simulated state Hacking
// {
    // simulated function PlayIdleAnimation()
    // {
        // Mesh.SetHidden( true );
        // PlayTopHalfAnimation( HackAnim,,,, true );
    // }

    // simulated event BeginState( name PreviousStateName )
    // {
        // if ( Instigator != none && Instigator.Weapon != none && !Instigator.Weapon.IsInState('Hacking'))
            // Instigator.Weapon.GotoState( 'Hacking' );

        // HackSound.Play(); // Now handled in HackObjective.
        // PlayTopHalfAnimationDuration( PutdownWeapAnim, WeaponClass.default.PutDownTime );
        // SetTimer( WeaponClass.default.PutDownTime, false, 'PlayIdleAnimation' );
    // }

    // simulated event EndState( name NextStateName )
    // {
        // if ( Instigator != none && Instigator.Weapon != none && Instigator.Weapon.IsA( 'CPWeapon' ))
            // Instigator.Weapon.Activate();

        // HackSound.Stop(); // Now handled in HackObjective.
        // Mesh.SetHidden( false );
        // ClearTimer( 'PlayIdleAnimation' );
    // }
// }

// simulated state ReloadingEnd
// {

// }

simulated function PlayIdleAnimation()
{
    ClearTimer('PlayIdleAnimation');
}

defaultproperties
{
    Begin Object class=UDKAnimNodeSequence Name=MeshSequenceA
    End Object

    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
        bOwnerNoSee=true
        bOnlyOwnerSee=false
        CollideActors=false
        AlwaysLoadOnClient=true
        AlwaysLoadOnServer=true
        MaxDrawDistance=4000
        bForceRefPose=1
        bUpdateSkelWhenNotRendered=false
        bIgnoreControllersWhenNotRendered=true
        bOverrideAttachmentOwnerVisibility=true
        bAcceptsDynamicDecals=false
        Animations=MeshSequenceA
        bCastHiddenShadow=true
        CastShadow=true
        bCastDynamicShadow=true
        bPerBoneMotionBlur=true
    End Object
    Mesh=SkeletalMeshComponent0

    TickGroup=TG_DuringAsyncWork
    NetUpdateFrequency=10
    RemoteRole=ROLE_None
    bReplicateInstigator=true
    MaxImpactEffectDistance=4000.0
    MaxFireEffectDistance=5000.0
    bAlignToSurfaceNormal=true
    MuzzleFlashDuration=0.5
    MuzzleFlashLightClass=class'CPDefaultMuzzleFlashLight'
    MuzzleFlashColor=(R=255,G=255,B=255,A=255)
    MaxDecalRangeSQ=16000000.0
    DistFactorForRefPose=0.14

    ImpactEffects.Empty()
    ImpactEffects(0)=         (MaterialType=Carpet,       /*ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Carpet_Impact',*/        Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Carpet_cue',                  DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact',        DecalWidth=4,DecalHeight=4)
    ImpactEffects(1)=         (MaterialType=Dirt,         /*ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Dirt_Impact',*/          Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Dirt_cue',                    DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact',        DecalWidth=4,DecalHeight=4)
    ImpactEffects(2)=         (MaterialType=Glass,        ParticleTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Impact_Glass_Shrapnel',        Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Glass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Bullet_Impact_Glass',      DecalWidth=4,DecalHeight=4)
    ImpactEffects(3)=         (MaterialType=GlassBroken,  /*ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_GlassBroken_Impact',*/   Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Glass_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Bullet_Impact_Glass',      DecalWidth=4,DecalHeight=4)
    ImpactEffects(4)=         (MaterialType=Grass,        /*ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Grass_Impact',*/         Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Grass_cue',                   DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact',        DecalWidth=4,DecalHeight=4)
    ImpactEffects(5)=         (MaterialType=Water,        ParticleTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Impact_Water_Spash',           Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Water_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Bullet_Impact_Water',      DecalWidth=4,DecalHeight=4)
    ImpactEffects(6)=         (MaterialType=ShallowWater, ParticleTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Impact_Water_Spash',           Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Water_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Bullet_Impact_Water',      DecalWidth=4,DecalHeight=4)
    ImpactEffects(7)=         (MaterialType=Metal,        ParticleTemplate=ParticleSystem'CP_bluewithenvy_FX.Particles.P_CP_MetalImpact',           Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Steel_cue',                   DecalMaterials[0]=DecalMaterial'CP_bluewithenvy_FX.Decals.D_CP_Metal_Impact',     DecalWidth=4,DecalHeight=4)
    ImpactEffects(8)=         (MaterialType=Snow,         ParticleTemplate=ParticleSystem'CP_bluewithenvy_FX.Particles.P_CP_SnowImpact',            Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Snow_cue',                    DecalMaterials[0]=DecalMaterial'CP_bluewithenvy_FX.Decals.D_CP_Snow_Impact',      DecalWidth=4,DecalHeight=4)
    ImpactEffects(9)=         (MaterialType=Stone,        ParticleTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Impact_Stone_Shrapnel',        Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Stone_cue',                   DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Bullet_Impact_Stone',      DecalWidth=4,DecalHeight=4)
    ImpactEffects(10)=        (MaterialType=Tile,         /*ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Tile_Impact',*/          Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Tile_cue',                    DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact',        DecalWidth=4,DecalHeight=4)
    ImpactEffects(11)=        (MaterialType=Wood,         ParticleTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Impact_Wood_Shrapnel',         Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Wood_cue',                    DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Bullet_Impact_Wood',       DecalWidth=4,DecalHeight=4)
    ImpactEffects(12)=        (MaterialType=Mud,          ParticleTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Impact_Mud',                   Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Mud_cue',                     DecalMaterials[0]=DecalMaterial'CP_Juan_FX.Decals.D_CP_Bullet_Impact_Mud',        DecalWidth=4,DecalHeight=4)
    ImpactEffects(13)=        (MaterialType=Plastic,      /*ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Plastic_Impact',*/       Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_Impact_Plastic_cue',                 DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact',        DecalWidth=4,DecalHeight=4)
    ImpactEffects(14)=        (MaterialType=Flesh,        /*ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Tile_Impact', */         Sound=SoundCue'CP_Character_Impacts.CP_Impact_Flesh',                             DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact',        DecalWidth=4,DecalHeight=4)

    DefaultImpactEffect=      (                                                                                                                     Sound=SoundCue'CP_Weapon_Sounds.Impacts.CP_A_DevTestSound_Cue',                    DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact',        DecalWidth=4,DecalHeight=4)

    AltImpactEffects.Empty()
    //AltImpactEffects(0)=       (MaterialType=Carpet,       ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Carpet_Impact',      Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_CarpetImpactCue')
    //AltImpactEffects(1)=       (MaterialType=Dirt,         ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Dirt_Impact',        Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_DirtImpactCue')
    //AltImpactEffects(2)=       (MaterialType=Glass,        ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Glass_Impact',       Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_GlassImpactCue')
    //AltImpactEffects(3)=       (MaterialType=GlassBroken,  ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_GlassBroken_Impact', Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_GlassBrokenImpactCue')
    //AltImpactEffects(4)=       (MaterialType=Grass,        ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Grass_Impact',       Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_GrassImpactCue')
    //AltImpactEffects(5)=       (MaterialType=Water,        ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Water_Impact',       Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_WaterImpactCue')
    //AltImpactEffects(6)=       (MaterialType=ShallowWater, ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_ShallowWater_Impact',Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_ShallowImpactCue')
    //AltImpactEffects(7)=       (MaterialType=Metal,        ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Metal_Impact',       Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_MetalImpactCue')
    //AltImpactEffects(8)=       (MaterialType=Snow,         ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Snow_Impact',        Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_SnowImpactCue')
    //AltImpactEffects(9)=       (MaterialType=Stone,        ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Stone_Impact',       Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_StoneImpactCue')
    //AltImpactEffects(10)=      (MaterialType=Tile,         ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Tile_Impact',        Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_TileImpactCue')
    //AltImpactEffects(11)=      (MaterialType=Wood,         ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Wood_Impact',        Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_WoodImpactCue')
    //AltImpactEffects(12)=      (MaterialType=Mud,          ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Mud_Impact',         Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_MudImpactCue')
    //AltImpactEffects(13)=      (MaterialType=Plastic,      ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Plastic_Impact',     Sound=SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_PlasticImpactCue')

    DefaultAltImpactEffect=(DecalMaterials[0]=DecalMaterial'CP_bulletImpact.Decal.D_CP_Bullet_Impact', DecalWidth=4,DecalHeight=4, ParticleTemplate=ParticleSystem'TEMP_WeaponAssets.Particles.WP_Beam_Impact'/*, Sound=SoundCue'CP_Character_Impacts.CP_Impact_Flesh'*/)

    WeapAnimType = EWAT_Melee

    ImpactEffectRotation=180.0f

    //GLOBAL
    HackAnim=Idle_Ready_Holster
    Begin Object Class=AudioComponent Name=HackSoundComponent
        SoundCue = SoundCue'CP_Weapon_Sounds.BombAndHackSounds.HackingLoop_Cue'
    End Object
    HackSound=HackSoundComponent
    Components.Add( HackSoundComponent );

    ShellCasingSocket=EjectionSocket
    ShellCasingDuration=1.3
    ShellPSCTemplate=ParticleSystem'TA_Molez_Particles.Weap_Mac10.PS_CP_Mac10_SE'


    BulletWhip=SoundCue'CP_Weapon_Sounds.BulletWhizz.CP_A_BulletWhip_Cue'
}
