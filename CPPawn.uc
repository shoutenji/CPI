class CPPawn extends UDKPawn
    config(Game)
    notplaceable;

	
//var    AnimNodeAimOffset        CustomAimNode;
var     AnimNodeSequence        WeaponAnimation;
var(Pawn) float ViewYawMin;
var(Pawn) float ViewYawMax;
var(Pawn) float AimSpeed;

var array<CPAnimNode_SeqWeap> WeapAnimNodes; //stores all the animtree weapanimnodes so we can change them for animations when the player changes weapon type

enum EWeapAnimType
{
    EWAT_Rifle,
    EWAT_Pistol,
    EWAT_SMG,
    EWAT_Sniper,
    EWAT_Melee,
    EWAT_Bomb,
    EWAT_Grenade,
    EWAT_Shotgun,
    EWAT_Holster
};

enum EWeaponState
{
    EWS_None,
    EWS_Active,
    EWS_Charging,
    EWS_Firing,
    EWS_FiringRepeat,
    EWS_FireEmpty,
    EWS_Reloading,
    EWS_ReloadingEmpty,
    EWS_ReloadingEnd,
    EWS_PuttingDown,
    EWS_Equipping,
    EWS_Hacking,
    EWS_EmptyState,
};

enum EHitArea
{
    EHA_None,
    EHA_Head,
    EHA_Body,
    EHA_Legs
};

// struct used for replicating a blood decal to other clients. -Crusha
// We use this because structs members are replicated all together, so data doesn't arrive one by one.
struct SBloodDecal
{
    var byte Id; // Even if none of the other properties changes, we can still force a replication by increasing the Id.
    var byte VariantIndex; // Branches to different texture variants in the material.
    var vector SpawnLocation; // Location where the decal got spawned.
    var vector HitNormal; // Direction of a gunshot wound.
    var float DecalRotation; // Random rotation of the texture.
    var float ExpireTime; // Point in time when the decal will disappear.
    //var float SizeX;
    //var float SizeY;
};

const BLOOD_SPLATTER_MAX_WALL_DIST = 30; // How far a wall behind the hit player can be away to still spawn a blood decal.

var     bool    bFixedView;
var vector  FixedViewLoc;
var rotator FixedViewRot;

var(TeamBeacon) float      TeamBeaconPlayerInfoMaxDist;

/** true is last trace test check for drawing postrender beacon succeeded */
var bool bPostRenderTraceSucceeded;

/** Controller vibration for taking falling damage. */
var ForceFeedbackWaveform FallingDamageWaveForm;

/** set on client when valid team info is received; future changes are then ignored unless this gets reset first
 * this is used to prevent the problem where someone changes teams and their old dying pawn changes color
 * because the team change was received before the pawn's dying
 */
var bool bReceivedValidTeam;

/** Socket to find the feet */
var name PawnEffectSockets[2];

/** These values are used for determining headshots */
var float           HeadOffset;
var float           HeadRadius;
var float           HeadHeight;
var name            HeadBone;

const MINTIMEBETWEENPAINSOUNDS=0.35;

var         float       LastPainSound;

var float CameraScaleMin, CameraScaleMax;
var     float   DefaultAirControl;

var                 float   AppliedBob;
var   globalconfig  float   Bob;
var                 float   bobtime;
var                 float   JumpBob;

var                 vector  WalkBob;

var                 float   LandBob;
var bool            bJustLanded;            /** used by eyeheight adjustment.  True if pawn recently landed from a fall */
var bool            bLandRecovery;          /** used by eyeheight adjustment. True if pawn recovering (eyeheight increasing) after lowering from a landing */


var bool bArmsAttached;

/** If true, use end of match "Hero" camera */
var bool bWinnerCam;

/** Used for end of match "Hero" camera */
var(HeroCamera) float HeroCameraScale;

/** Used for end of match "Hero" camera */
var(HeroCamera) int HeroCameraPitch;

/** Third person camera offset */
var vector CamOffset;

var float RagdollLifespan;
/** Set when pawn died on listen server, but was hidden rather than ragdolling (for replication purposes) */
var bool bHideOnListenServer;

/** Stop death camera using OldCameraPosition if true */
var bool bStopDeathCamera;
/** OldCameraPosition saved when dead for use if fall below killz */
var vector OldCameraPosition;
/** OldCameraRotation saved when dead for use - sarkis*/
var Rotator OldCameraRotation;

/** Time at which this pawn entered the dying state */
var float DeathTime;

/** World time that we started the death animation */
var             float   StartDeathAnimTime;
/** Time that we took damage of type DeathAnimDamageType. */
var             float   TimeLastTookDeathAnimDamage;

/** Type of damage that started the death anim */
var             class<CPDamageType> DeathAnimDamageType;

/** Slot node used for playing animations only on the top half. */
var AnimNodeSlot TopHalfAnimSlot;
/** Slot node used for playing full body anims. */
var AnimNodeSlot FullBodyAnimSlot;

var(DeathAnim)  float   DeathHipLinSpring;
var(DeathAnim)  float   DeathHipLinDamp;
var(DeathAnim)  float   DeathHipAngSpring;
var(DeathAnim)  float   DeathHipAngDamp;

/** Array of bodies that should not have joint drive applied. */
var array<name> NoDriveBodies;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/** Mesh scaling default */
var float DefaultMeshScale;

/** client side flag indicating whether attachment should be visible - primarily used when spawning the initial weapon attachment
 * as events that change its visibility might have happened before we received a CurrentWeaponAttachmentClass
 * to spawn and call the visibility functions on
 */
var bool bWeaponAttachmentVisible;

/** This pawn's current family/class info **/
var class<CPFamilyInfo> CurrCharClassInfo;

var repnotify   EWeaponState                WeaponState;

/** This holds the local copy of the current attachment.  This "attachment" actor will exist independantly on all clients */
var             CPWeaponAttachment          CurrentWeaponAttachment;
/** Holds the class type of the current weapon attachment.  Replicated to all clients. */
var repnotify   class<CPWeaponAttachment>   CurrentWeaponAttachmentClass;

/** WeaponSocket contains the name of the socket used for attaching weapons to this pawn. */
var name WeaponSocket, WeaponSocket2;

/** used to smoothly adjust camera z offset in third person */
var float CameraZOffset;

var class<CPPawnSoundGroup> SoundGroupClass;

/** Max distance from listener to play footstep sounds */
var float MaxFootstepDistSq;
/** Max distance from listener to play jump/land sounds */
var float MaxJumpSoundDistSq;

var float CameraScale, CurrentCameraScale; /** multiplier to default camera distance */

/** bones to set fixed when doing the physics take hit effects */
var array<name> TakeHitPhysicsFixedBones;

/** Set the crouch height 1:1 with AOT **/
var     float                   BaseCrouchHeight;
var     bool                    bSwappingWeapon;
var     bool                    bIsUseKeyDown;
var     bool                    bIsUsingObjective;

/** Armor strength values */
var     repnotify float         BodyStrength, HeadStrength, LegStrength;

var     CPBuyZone               BuyZone;
var     CPHackZone              HackZone;
var     CPBombZone              BombZone;
var     CPEscapeZone            EscapeZone;
var     CPHostageRescueZone     HostageRescueZone;

/*********************************************************************************************
 Armor
********************************************************************************************* */
/*var float HeadArmor;
var float BodyArmor;
var float LegArmor;*/

/** laser dot */
var repnotify bool bLaserDotStatus;
var float NextLaserDotStatusCheck;
var const float LaserDotStatusCheckInterval;
var CPLaserDot LaserDotActor;

/* Character Selection*/
var array< class<CPFamilyInfo> > SWATFamArray, MERCFamArray;

/* Hut info */
var repnotify byte HitByEnemy;
var float LastHitTime;

/** Are we in the air - simple check to know if we should play the jump sound.*/
var bool blnInAir; //~Crusha: Can't we just use the Falling state instead?

//for vest
var() SkeletalMeshComponent VestMesh;
//for helmet
var() SkeletalMeshComponent HelmetMesh;

var array<ParticleSystem> BloodImpacts;

var Vector      ServerBones[255];
var float       LastBoneDebug;
var float       DebugBoneUpdateRate;
var bool        ServerBonesPersist;

var RepNotify SBloodDecal BloodSplatterFlash; // to replicate decals caused by gun shots.
var RepNotify SBloodDecal BloodTrailFlash; // to replicate decals from the continuous trail from a wound.
var float NextBloodTrail;
const BLOOD_LIFETIME = 60; // How long blood splatters will stay around.

//Flashlight
var CPFlashlight FlashLight;
var repnotify bool bIsFlashlightOn;
var(Flashlight) bool bHasFlashlight;
//

/** desired location and rotation when dying (to DeathCam) */
var Vector  DC_DesiredLocation;
var Rotator DC_DesiredRotation;
/** values to shake */
var Vector  DC_ShakeValues;
/** start location when entering in dying state */
var vector  DC_StartLocation;
/** start rotation when die */
var Rotator DC_StartRotation;
/** toggles shake when collides */
var bool DC_EnableShake;

var rotator ShooterRotation;

var AnimNodeBlend Walking_WeaponBlend;

var AudioComponent acTinnitusSound;

var CPWeapon SpectateCurrentWeapon;

var byte CurrentFireModeAutoFireCheck;


`include(GameAnalyticsProfile.uci);


replication
{
    if (bNetOwner && bNetDirty)
        /*HackZone,HeadArmor,BodyArmor,LegArmor,*/HitByEnemy;

    if (bNetDirty) //spectator stuff
        SpectateCurrentWeapon, BloodSplatterFlash, BloodTrailFlash, BuyZone, HostageRescueZone,EscapeZone;

    if ( bNetInitial || bNetDirty )
         bIsUseKeyDown, bIsUsingObjective, WeaponState, BodyStrength, HeadStrength, LegStrength, CurrentWeaponAttachmentClass, bHasFlashlight, ShooterRotation;

    if ( (bNetInitial || bNetDirty) && !bNetOwner && (Role == Role_Authority))
        bIsFlashlightOn;

    if (Role==ROLE_Authority)
        bLaserDotStatus;
}

/**
 * Check on various replicated data and act accordingly.
 */
simulated event ReplicatedEvent(name VarName)
{
    if (VarName == 'BloodSplatterFlash')
    {
        SpawnBloodSplatterDecal();
    }
    else if (VarName == 'BloodTrailFlash')
    {
        SpawnBloodTrailDecal();
    }
    else if ( VarName == 'Controller' && Controller != None )
    {
        // Reset the weapon when you get the controller and
        // make sure it has ammo.
        if (CPWeapon(Weapon) != None)
        {
            CPWeapon(Weapon).ClientEndFire(0);
            CPWeapon(Weapon).ClientEndFire(1);
            if ( !Weapon.HasAnyAmmo() )
            {
                Weapon.WeaponEmpty();
            }
        }
    }
    else if ( VarName == 'FlashCount' )
    {
        if ( WeaponState == EWS_Firing || WeaponState == EWS_FiringRepeat && CurrentWeaponAttachment != none )
        {
            if(CurrentWeaponAttachment != none)
                CurrentWeaponAttachment.ThirdPersonFireEffects();
        }
        return;
    }
    else if ( VarName == 'WeaponState' )
    {
        HandleWeaponState();
    }
    // If CurrentWeaponAttachmentClass has changed, the player has switched weapons and
    // will need to update itself accordingly.
    else if ( VarName == 'CurrentWeaponAttachmentClass' )
    {
        WeaponAttachmentChanged();
        return;
    }
    else if ( VarName == 'CompressedBodyMatColor' )
    {
        BodyMatColor.R = CompressedBodyMatColor.Pitch/256.0;
        BodyMatColor.G = CompressedBodyMatColor.Yaw/256.0;
        BodyMatColor.B = CompressedBodyMatColor.Roll/256.0;
    }
    else if ( VarName == 'ClientBodyMatDuration' )
    {
        SetBodyMatColor(BodyMatColor,ClientBodyMatDuration);
    }
    else if ( VarName == 'HeadScale' )
    {
        SetHeadScale(HeadScale);
    }
    else if (VarName == 'PawnAmbientSoundCue')
    {
        SetPawnAmbientSound(PawnAmbientSoundCue);
    }
    else if (VarName == 'WeaponAmbientSoundCue')
    {
        SetWeaponAmbientSound(WeaponAmbientSoundCue);
    }
    else if (VarName == 'ReplicatedBodyMaterial')
    {
        SetSkin(ReplicatedBodyMaterial);
    }
    else if (VarName == 'OverlayMaterialInstance')
    {
        SetOverlayMaterial(OverlayMaterialInstance);
    }
    //else if (VarName == 'bFeigningDeath')
    //{
    //  PlayFeignDeath();
    //}
    else if (VarName == 'WeaponOverlayFlags')
    {
        ApplyWeaponOverlayFlags(WeaponOverlayFlags);
    }
    else if (VarName == 'LastTakeHitInfo')
    {
        PlayTakeHitEffects();
    }
    else if ( VarName == 'BodyStrength' )
    {
        if(VestMesh != none)
        {
            VestMesh.SetHidden( BodyStrength <= 0.0f );
            VestMesh.bCastHiddenShadow = BodyStrength > 0.0f;
        }
    }
    else if ( VarName == 'HeadStrength' )
    {
        if ( GetFamilyInfo() != none )
        {
            if(HelmetMesh != none)
            {
                HelmetMesh.SetSkeletalMesh( HeadStrength <= 0.0f ? GetFamilyInfo().default.HeadHair : GetFamilyInfo().default.HeadHelmet );
            }
        }
    }
    //else if (VarName == 'DrivenWeaponPawn')
    //{
    //  if (DrivenWeaponPawn.BaseVehicle != LastDrivenWeaponPawn.BaseVehicle || DrivenWeaponPawn.SeatIndex != LastDrivenWeaponPawn.SeatIndex)
    //  {
    //      if (DrivenWeaponPawn.BaseVehicle != None)
    //      {
    //          // create a client side pawn to drive
    //          if (ClientSideWeaponPawn == None || ClientSideWeaponPawn.bDeleteMe)
    //          {
    //              ClientSideWeaponPawn = Spawn(class'UTClientSideWeaponPawn', DrivenWeaponPawn.BaseVehicle);
    //          }
    //          ClientSideWeaponPawn.MyVehicle =UTVehicle(DrivenWeaponPawn.BaseVehicle);
    //          ClientSideWeaponPawn.MySeatIndex = DrivenWeaponPawn.SeatIndex;
    //          StartDriving(ClientSideWeaponPawn);
    //      }
    //      else if (ClientSideWeaponPawn != None && ClientSideWeaponPawn == DrivenVehicle)
    //      {
    //          StopDriving(ClientSideWeaponPawn);
    //      }
    //  }
    //  if (ClientSideWeaponPawn != None && ClientSideWeaponPawn == DrivenVehicle && ClientSideWeaponPawn.PlayerReplicationInfo != DrivenWeaponPawn.PRI)
    //  {
    //      ClientSideWeaponPawn.PlayerReplicationInfo = DrivenWeaponPawn.PRI;
    //      ClientSideWeaponPawn.NotifyTeamChanged();
    //  }
    //  LastDrivenWeaponPawn = DrivenWeaponPawn;
    //}
    else if (VarName == 'bIsInvisible')
    {
        SetInvisible(bIsInvisible);
    }
    else if (VarName == 'BigTeleportCount')
    {
        PostBigTeleport();
    }
    else if (VarName == 'FireRateMultiplier')
    {
        FireRateChanged();
    }
    else if (VarName=='bLaserDotStatus')
        LaserStatusUpdateNotify();
    else if (VarName=='HitByEnemy')
    {
        LastHitTime=WorldInfo.TimeSeconds;
        if (CPPlayerController(Controller)!=none)
            CPPlayerController(Controller).OnDamageTaken();
    }
    else if (VarName == 'bIsFlashlightOn')
    {
        FlashLightToggled();
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

simulated function SetWeaponState( EWeaponState NewState = EWS_None )
{
    if(WorldInfo.NetMode != NM_Client)
    {
        WeaponState = NewState;
        HandleWeaponState();
    }
}

function string GetWeaponStateString(EWeaponState NewState)
{
    switch(NewState)
    {
        case EWS_None:
            return "EWS_None";
            break;
        case EWS_Firing:
            return "EWS_Firing";
            break;
        case EWS_Charging:
            return "EWS_Charging";
            break;
        case EWS_FiringRepeat:
            return "EWS_FiringRepeat";
            break;
        case EWS_FireEmpty:
            return "EWS_FireEmpty";
            break;
        case EWS_Reloading:
            return "EWS_Reloading";
            break;
        case EWS_ReloadingEmpty:
            return "EWS_ReloadingEmpty";
            break;
        case EWS_ReloadingEnd:
            return "EWS_ReloadingEnd";
            break;
        case EWS_PuttingDown:
            return "EWS_PuttingDown";
            break;
        case EWS_Equipping:
            return "EWS_Equipping";
            break;
        case EWS_Hacking:
            return "EWS_Hacking";
            break;
        case EWS_EmptyState:
            return "EWS_EmptyState";
            break;
        default:
            return "UNKNOWN WeaponState";
            break;
    }
}

simulated function PuttingDownFinished()
{
    if ( WeaponState == EWS_PuttingDown )
    {
        SetWeaponState( EWS_Equipping );
    }
}

simulated function EquippingFinished()
{
    if ( WeaponState == EWS_Equipping )
    {
        SetWeaponState();
    }
}

simulated function HandleWeaponState()
{
    if ( Weapon == none )
    {
        `Log("@@ error_01 "); 
        return;
    }
        
    switch ( WeaponState )
    {
        case EWS_None:
            Weapon.GotoState( 'Inactive' );
            break;
        case EWS_Active:
            if(!bIsUseKeyDown)
                Weapon.GotoState( 'Active' );
            break;
        case EWS_Charging:
            Weapon.GotoState( 'Charging' );
            break;
        case EWS_Firing:
        case EWS_FiringRepeat:        
            Weapon.GotoState( 'WeaponFiring' );
            break;
        case EWS_FireEmpty:
            Weapon.GotoState( 'FireEmpty' );
            break;
        case EWS_Reloading:
            Weapon.GotoState( 'Reloading' );
            break;
        case EWS_ReloadingEmpty:
            Weapon.GotoState( 'ReloadingEmpty' );
            break;
        case EWS_ReloadingEnd:
            Weapon.GotoState( 'ReloadingEnd' );
            break;
        case EWS_PuttingDown:
            Weapon.GotoState( 'WeaponPuttingDown' );
            break;
        case EWS_Equipping:
            WeaponAttachmentChanged();
            Weapon.GotoState( 'WeaponEquipping' );
            break;
        case EWS_Hacking:
            Weapon.GotoState( 'Hacking' );
            break;
    };
}


simulated function FlashCountUpdated(Weapon InWeapon, Byte InFlashCount, bool bViaReplication)
{
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    //local CPAnimNode_SeqWeap WeapAnimNode; //depreciated
    if (SkelComp == Mesh)
    {
        ClearAnimNodes();
        CacheAnimNodes();

        //find ALL our custom weap anim nodes in the animtree and cache them so we can swap out the animations when changing weapon modes.
        //if (SkelComp == Mesh) //depreciated
        //{
        //  foreach Mesh.AllAnimNodes(class'CPAnimNode_SeqWeap', WeapAnimNode)
        //      WeapAnimNodes[WeapAnimNodes.Length] = WeapAnimNode;
        //}

        LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
        RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
        //FeignDeathBlend = AnimNodeBlend(Mesh.FindAnimNode('FeignDeathBlend'));
        FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
        TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

        Walking_WeaponBlend = AnimNodeBlend(Mesh.FindAnimNode('Walking_WeaponBlend'));

        LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );

        RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );

        RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
        AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
        WeaponAnimation = AnimNodeSequence( mesh.FindAnimNode( 'WeaponAnimation' ) );
        GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
        LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
        RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

        //DrivingNode = UTAnimBlendByDriving( mesh.FindAnimNode('DrivingNode') );
        //VehicleNode = UTAnimBlendByVehicle( mesh.FindAnimNode('VehicleNode') );
        //HoverboardingNode = UTAnimBlendByHoverboarding( mesh.FindAnimNode('Hoverboarding') );

        FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
    }
}

function DeactivateSpawnProtection()
{
}

//function JumpOutOfWater(vector jumpDir)
//{
//  bReadyToDoubleJump = true;
//  bDodging = false;
//  Falling();
//  Velocity = jumpDir * WaterSpeed;
//  Acceleration = jumpDir * AccelRate;
//  velocity.Z = OutofWaterZ; //set here so physics uses this for remainder of tick
//  bUpAndOut = true;
//}

function bool Died( Controller Killer, class<DamageType> damageType, Vector HitLocation )
{
    local Inventory inv;
	local int money;
    HackZone = none;
    BuyZone = none;
    EscapeZone = none;
    HostageRescueZone = none;

	// Do not drop money for hostages
    if( CPHostage(Controller) == None && damageType != class'DamageType')    // If I'm not a hostage and my cause of death is not team change
    {
        inv = FindInventoryType(class'CPWeap_Bomb',true);

        // If holding bomb, drop bomb instead of money
        if( inv!=None )
        {
            //DC_StartLocation = Controller.Location;
            //DC_StartRotation = Controller.Rotation;
            if (CPPlayerController(Controller) != None)
                CPPlayerController(Controller).ThrowBombOnDeath();
        }
        else
        {
            money = ThrowMoneyOnDeath(,Killer == Controller);
        }
    }

	//destroy the weapon...
	if (Weapon != none){
		Weapon.GotoState('inactive');
		Weapon.Destroy();
	}
	
	`if(`bPollKillEvent)
		if(CriticalPointGame(WorldInfo.Game) != none && CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
			if(Killer!=None && Controller!=None)
				CriticalPointGame(WorldInfo.Game).PollKillEvent(WorldInfo.TimeSeconds, Killer, Controller);
	`endif
	`if(`bPollKilledEvent)
		if(CriticalPointGame(WorldInfo.Game) != none && CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
			if(Killer!=None && Controller!=None)
				CriticalPointGame(WorldInfo.Game).PollKilledEvent(WorldInfo.TimeSeconds, Killer, Controller, money);
	`endif

    if (Super.Died(Killer, DamageType, HitLocation))
    {
        StartFallImpactTime = WorldInfo.TimeSeconds;
        bCanPlayFallingImpacts = true;
        HideArms(true);
        SetPawnAmbientSound(None);
        SetWeaponAmbientSound(None);
        return true;
    }
    return false;

}

function HideArms(bool hideArms)
{

	if (ArmsMesh[0] != none)
    {
        ArmsMesh[0].SetHidden(hideArms);
    }
    if (ArmsMesh[1] != none)
    {
        ArmsMesh[1].SetHidden(hideArms);
    }
}

exec function ThrowMoney()
{
    ThrowMoneyOnDeath(1000);
}


function int ThrowMoneyOnDeath(optional int amount=-1, optional bool bKillerIsSelf=False)
{
    local CPPlayerReplicationInfo   _PRI;
    local CriticalPointGame         _Game;
    local int                       Money;
    local DroppedMoneyItem          MoneyDrop;
	local vector					SpawnLoc;
	
	if( WorldInfo.NetMode != NM_StandAlone && Role != ROLE_Authority)
		return 0;
	_PRI = CPPlayerReplicationInfo( PlayerReplicationInfo );
	
	//This bit of code lets you throw money while playing standalone game. mainly for testing
	if(amount > -1 && _PRI!=None)
	{
        SpawnLoc = Location + Normal(Vector(GetBaseAimRotation()))*120;
		if(_PRI.Team.TeamIndex == 0)
			MoneyDrop = Spawn( class'DroppedMoneyItem_MERC',,,SpawnLoc,,,true);
		else
			MoneyDrop = Spawn( class'DroppedMoneyItem_SWAT',,,SpawnLoc,,,true);
		MoneyDrop.SetMoneyAmount(amount);
		return -1 * amount;
	}
	
    _Game = CriticalPointGame(WorldInfo.Game);
    if ( _PRI == none || (bKillerIsSelf && !_Game.bDropMoneyOnSuicide))
    {
		return 0;
    }

    if( _PRI.Money <= _Game.BaseMoneyDropAmount)
    {
		return 0;
    }
    else if( _PRI.Money <=  _Game.DropAmountTier1Min)
    {
        Money = _Game.BaseMoneyDropAmount;
    }
    else if( _PRI.Money <= _Game.DropAmountTier1Max )
    {
        Money = _Game.BaseMoneyDropAmount * _Game.DropAmountTier1Multiplier;
    }
    else if( _PRI.Money <= _Game.DropAmountTier2Max )
    {
        Money = _Game.BaseMoneyDropAmount * _Game.DropAmountTier2Multiplier;
    }
    else
    {
        Money = _Game.BaseMoneyDropAmount * _Game.DropAmountTier3Multiplier;
    }
    _PRI.ModifyMoney(-1 * Money);

    // If its a suicide and money drop on suicides is on
    if( bKillerIsSelf && _Game.bTeamOnlyMoneyDropIfSuicide )
    {
        // Spawn DroppedMoneyItem class corresponding to the right team
        if( _PRI.Team.TeamIndex == _Game.MercIndexId )
        {
            MoneyDrop = Spawn( class'DroppedMoneyItem_MERC');
        }
        else if( _PRI.Team.TeamIndex == _Game.SwatIndexId )
        {
            MoneyDrop = Spawn( class'DroppedMoneyItem_SWAT');
        }
    }
    else
    {
        // Team visibility is turned off
        MoneyDrop = Spawn( class'DroppedMoneyItem');
    }


    if ( MoneyDrop == none )
    {
		return 0;
    }
    else
    {
        MoneyDrop.SetMoneyAmount(Money);
		return -1 * Money;
    }
	
}

simulated function ShowArms()
{
    if(ArmsMesh[0] != none)
    {
        ArmsMesh[0].SetHidden(false);
    }
    if(ArmsMesh[1] != none)
    {
        ArmsMesh[1].SetHidden(false);
    }
}

simulated function StartFire(byte FireModeNum)
{
	CurrentFireModeAutoFireCheck = FireModeNum;
	ServSetFireMode(FireModeNum);
    Super.StartFire(FireModeNum);
}

reliable server function ServSetFireMode(byte FireModeNum)
{
	CurrentFireModeAutoFireCheck = FireModeNum;
}

//does this function even work??? - simulated function StopFire(byte FireModeNum) from pawn.uc
function bool StopFiring()
{
    return StopWeaponFiring();
}

//since the pawn handles weapons states,
simulated function StopFire(byte FireModeNum)
{
	if( Weapon != None )
	{
        `Log("@@ CPPawn::StopFire"); 
        if( WeaponState == EWS_Charging)
        {
           `Log("@@ CPPawn::StopFire 01");   
            CPWeapon(Weapon).StartReleaseFire(FireModeNum);
        }
        else
        {
            `Log("@@ CPPawn::StopFire 02"); 
            Weapon.StopFire(FireModeNum);
        }
	}
}


//to set the crouch height 1:1 with AoT
simulated function SetBaseEyeheight()
{
    if ( !bIsCrouched )
        BaseEyeheight = Default.BaseEyeheight;
    else
        BaseEyeheight = BaseCrouchHeight;
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
    //super.PlayTeleportEffect(false,false);
}

function PlayerChangedTeam()
{
    //Rogue - Check if we should Die or not during a change team.
    if(!CheckValidSpawnDuringGame())
    {
        Died( None, class'DamageType', Location );
    }
}

function bool CheckValidSpawnDuringGame()
{
    local CPGameReplicationInfo TAGRI;
    TAGRI = CPGameReplicationInfo(WorldInfo.GRI);

    // Check conditions to decide if we should be able
    // to join the game or change teams or etc without negative
    // side affects.
    if(TAGRI != None && !TAGRI.bDamageTaken)
    {
        return true;
    }

    return false;
}

// ~Drakk : returns true if this pawn is able to swap the specified pickup
simulated function bool WantsToSwap(CPDroppedPickup dp)
{
    if (CPInventoryManager(InvManager)!=none)
        return CPInventoryManager(InvManager).NeedsSwapToInventoryType(dp.InventoryClass);
    return false;
}

// ~Drakk : swap current weapon to this dropped pickup
simulated function bool SwapWeaponTo(CPDroppedPickup dp)
{
    local int i;
    local bool bFoundSelf;
    local class<Inventory> weapClass;
    local Inventory fnInv;

    if (dp==none)
        return false;
    bFoundSelf=false;
    for (i=0;i<dp.Touching.Length;i++)
    {
        if (dp.Touching[i]==self)
        {
            bFoundSelf=true;
            break;
        }
    }
    if (!bFoundSelf)
        return false;
    if (!WantsToSwap(dp))
    {
        `warn("CPPawn:: Trying to swap an item which don't need to be swapped "$dp);
        return false;
    }
    bSwappingWeapon=true;
    ThrowActiveWeapon(false);
    weapClass=dp.InventoryClass;
    dp.RecheckValidTouch();
    fnInv=InvManager.FindInventoryType(weapClass);
    if (Weapon(fnInv)!=none)
        InvManager.SetCurrentWeapon(Weapon(fnInv));
    bSwappingWeapon=false;

	CPPlayerController(Instigator.GetALocalPlayerController()).ClearSpectatorWeaponsOrdered();
    return true;
}

/** Dodging */
function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    return false;
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove,vector Dir,vector Cross)
{
    return false;
}

/** Reloading */
simulated function StartReload()
{
    if (bNoWeaponFIring)
        return;
    if( CPWeapon(Weapon)!=none)
        CPWeapon(Weapon).StartReload();
}

simulated function StopReload()
{
    if (CPWeapon(Weapon)!=none)
        CPWeapon(Weapon).StopReload();
}

/** Fire Mode Switching */
simulated function StartFireModeSwitch()
{
    if (bNoWeaponFIring)
        return;
    if( CPWeapon(Weapon)!=none)
        CPWeapon(Weapon).StartFireModeSwitch();
}

simulated function StopFireModeSwitch()
{
    if (CPWeapon(Weapon)!=none)
        CPWeapon(Weapon).StopFireModeSwitch();
}

// ~Drakk : don't allow weapon throw while reloading ( but allow it if the player is dead )
function ThrowActiveWeapon(optional bool bDestroyWeap)
{
    if (CPWeapon(Weapon)!=none)
        if (!CPWeapon(Weapon).IsReloading() || (CPWeapon(Weapon).IsReloading() && Health<=0))
          CPWeapon(Weapon).StartThrow();
}

function EHitArea FindClosestHitArea( name Bone )
{
    //`log( "CPPawn::FindClosestHitArea:" @ Bone );
    switch ( Bone )
    {
    case 'None':
    case 'Bip_Root':
    case 'Bip_IK_Foot_Root':
    case 'Bip_IK_Hand_Root':
        return EHA_None;
    };

    if ( Bone == 'Bip_Neck' || Mesh.BoneIsChildOf( Bone, 'Bip_Neck' ) )
        return EHA_Head;
    else if ( Bone == 'Bip_L_Thigh' || Bone == 'Bip_R_Thigh' ||
        Mesh.BoneIsChildOf( Bone, 'Bip_L_Thigh' ) ||
        Mesh.BoneIsChildOf( Bone, 'Bip_R_Thigh' ) ||
        Mesh.BoneIsChildOf( Bone, 'Bip_IK_Foot_Root' ) )
        return EHA_Legs;
    else if ( Bone == 'Bip_Pelvis' || Mesh.BoneIsChildOf( Bone, 'Bip_Pelvis' ) || Mesh.BoneIsChildOf( Bone, 'Bip_IK_Hand_Root' ) )
        return EHA_Body;

    return EHA_None;
}

/* AdjustDamage()
adjust damage based on inventory, other attributes
*/
simulated function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
    local CPWeapon DamageWeapon;
    local CPArmor Armor;
    local EHitArea Hit;
    local float Damage;
    local float Scale;
    local float Length;
    local float totalDamage;
    local bool bShouldTempBan;

    bShouldTempBan = false;

    if ( DamageType == class'DmgType_Fell' )
        return;

    if ( DamageType == class'CPDmgType_HE' )
    {
        AdjustGrenadeDamage( InDamage, Momentum, HitLocation, CPProj_Grenade( DamageCauser ) );
    }

    AdjustFFDamage(InDamage, InstigatedBy, DamageType);

    DamageWeapon = CPWeapon( DamageCauser );

    if ( DamageWeapon != none )
    {
        Length = VSize( DamageWeapon.GetPhysicalFireStartLoc() - HitLocation );
        InDamage *= FMin( 1.0, DamageWeapon.WeaponEffectiveRange / Length );
        ShooterRotation = DamageWeapon.Instigator.Rotation;
    }

    if( DamageType.default.bArmorStops && inDamage > 0 )
    {
        if ( HitInfo.BoneName == 'None' )
            HitInfo.BoneName = Mesh.FindClosestBone( HitLocation );

        Scale = 0.0;
        Damage = InDamage;
        Hit = FindClosestHitArea( HitInfo.BoneName );
        //`log( "Bone:" @ HitInfo.BoneName $ ", Hit:" @ Hit );

        switch ( Hit )
        {
        case EHA_Head:
            Damage *= 2.0;
            Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Head', false ) );
            break;

        case EHA_Body:
            Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Body', false ) );
            break;

        case EHA_Legs:
            Damage *= 0.65;
            Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Leg', false ) );
            break;

        case EHA_None:
            Damage = 0.0;
            break;
        }

        if ( Armor != none )
        {
            Scale = Round( FMin( Damage * FMin( Armor.Health / Armor.MaxHealth, Armor.Mitigation ), Armor.Health ) );
            Armor.Health -= Scale;

            `log( "Armor absorbed" @ Scale @ "damage, armor hp is now" @ Armor.Health );
        }

        InDamage = Damage - Scale;
    }

    //scoring for damage taken.
    //  * Damage done to opponent
    //- 10 points for every 10hp made if dealt on the enemy. and minus 20 points if we hit a teammate.
    // No points are lost if we hurt ourselves.

    if (InstigatedBy != none && InstigatedBy.PlayerReplicationInfo != none)
    {
        // Rogue.... Our score should not be adjusting if we are taking damage.... Only if we are
        // giving damage.
        // When we take damage we are either giving damage to ourself or someone else or thing is
        // giving us damage. Take points from or give to whomever is causing the damage.
        if (InDamage < Health)
        {
            totalDamage = InDamage/10.0;

            if (InstigatedBy == Controller)
            {
                //we damaged ourselves. - no point reductions.
            }
            else if (InstigatedBy.GetTeamNum() == Controller.GetTeamNum())
            {   //did we damage someone on our own team?
                InstigatedBy.PlayerReplicationInfo.Score -= (totalDamage * 2.0);
            }
            else if (CPHostage(Controller) != none)
            {
                //rules for hostages
                //1 -minus 20 points (-20) for every 10hp dmg done
                InstigatedBy.PlayerReplicationInfo.Score -= (totalDamage * 2.0);
            }
            else
                InstigatedBy.PlayerReplicationInfo.Score += totalDamage;
        }
        else
        {
            totalDamage = Health/10.0;

            if (InstigatedBy == Controller)
            {
                //we damaged ourselves. - no point reductions.
            }
            else if (InstigatedBy.GetTeamNum() == Controller.GetTeamNum()) //did we damage someone on our own team?
            {
                CPPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).TeamKills++;

                InstigatedBy.PlayerReplicationInfo.Score -= (totalDamage * 2.0);

                if (CPGameReplicationInfo(WorldInfo.GRI) != none)
                {
                    if (CPPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).TeamKills >= CPGameReplicationInfo(WorldInfo.GRI).MaxTeamKills)
                    {
                        `Log("Teamkills=" $ CPPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).TeamKills);
                        `Log("MaxTeamKills=" $ CPGameReplicationInfo(WorldInfo.GRI).MaxTeamKills);
                        bShouldTempBan = true;
                    }
                }
            }
            else if (CPHostage(Controller) != none)
            {
                //rules for hostages
                //1 -minus 20 points (-20) for every 10hp dmg done
                InstigatedBy.PlayerReplicationInfo.Score -= (totalDamage * 2.0);
            }
            else
                InstigatedBy.PlayerReplicationInfo.Score += totalDamage;
        }
    }

    if (CPPlayerController(Controller) != None)
    {
        CPPlayerController(Controller).DrawTakeHit( HitLocation, InDamage, DamageType);
    }
    Controller.NotifyTakeHit( InstigatedBy, HitLocation, InDamage, DamageType, Momentum );

    if (bShouldTempBan)
    {
        if (CPPlayerController(InstigatedBy) != None)
            CPPlayerController(InstigatedBy).ClientBeingKickedForTeamKilling(InstigatedBy.PlayerReplicationInfo.PlayerName, PlayerReplicationInfo.PlayerName);
        AnnounceTeamKillBan(InstigatedBy.PlayerReplicationInfo.PlayerName, PlayerReplicationInfo.PlayerName);
        ServerTempBan(InstigatedBy.PlayerReplicationInfo.PlayerName, "too many teamkills");
    }
}

reliable client function ClientStopFire(byte FireModeNum)
{
	CPWeapon(Controller.Pawn.Weapon).StopFire(FireModeNum);	
}

reliable client function AnnounceTeamKillBan(string Killer, string Victim)
{
    local string S;
    S = "\nPlayer " $ Killer $ " Team Killed Player " $ Victim $ "\nPlayer " $ Killer $ " Reached The Max Team-Kill Limit, Being Auto-Kicked\nPlayer " $ Killer $ " Was Kicked From The Server\n";

    `log(S);
    if( CPPlayerController(Controller).Player != None)
    {
        LocalPlayer( CPPlayerController(Controller).Player ).ViewportClient.ViewportConsole.OutputText( S );
    }
}

/** Allows a player to be temp banned */
reliable server function ServerTempBan(string PlayerToBan, string reason)
{
    if (WorldInfo.Game !=none)
    {
        CPAccessControl(WorldInfo.Game.AccessControl).TempBan(PlayerToBan, reason);
    }
}

function AdjustFFDamage(out int InDamage, Controller InstigatedBy, class<DamageType> DamageType)
{
    local CPGameReplicationInfo TAGRI;
    TAGRI = CPGameReplicationInfo(WorldInfo.GRI);

    // Check if the damage was done by another player
    if (InstigatedBy != none && InstigatedBy.Pawn != none
        && InstigatedBy.PlayerReplicationInfo != none)
    {
        // Teammate gave us damage. Adjust damage based on FF settings.
        if (InstigatedBy.GetTeamNum() == Controller.GetTeamNum())
        {
            if (TAGRI != None)
            {
                if ( DamageType == class'CPDmgType_HE' )
                {
                    if (TAGRI.bNadeFFenabled)
                    {
                        InDamage = InDamage * (TAGRI.NadeFFPercentage/100.0);
                    }
                    else
                    {
                        // If FF is not enabled then we should not be taking damage.
                        InDamage = 0.0;
                    }
                }
                else
                {
                    // FF is enabled. Adjust damage based on FF percentage.
                    if (TAGRI.bIsFFenabled)
                    {
                        InDamage = InDamage * (TAGRI.FFPercentage/100.0);
                    }
                    else
                    {
                        // If FF is not enabled then we should not be taking damage.
                        InDamage = 0.0;
                    }
                }
            }
        }
    }

    return;
}

function AdjustGrenadeDamage( out int InDamage, out Vector Momentum, Vector HitLocation, CPProj_Grenade Grenade )
{
    //`log( "CPPawn::AdjustGrenadeDamage:" @ Grenade$"," @ HitLocation );
}

/**
 * EnableInventoryPickup()
 * Set bCanPickupInventory to true
 */
function EnableInventoryPickup()
{
    bCanPickupInventory = true;
}

/** Play sound's */
function PlayLandingSound()
{
    local PlayerController PC;

    foreach LocalPlayerControllers(class'PlayerController', PC)
    {
        if ((PC.ViewTarget != none) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxJumpSoundDistSq))
        {
            PawnPlaySound(SoundGroupClass.static.GetLandSound(GetMaterialBelowFeet()));
            blnInAir = false;
            return;
        }
    }
}

function PlayJumpingSound()
{
    local PlayerController PC;

    foreach LocalPlayerControllers(class'PlayerController',PC)
    {
        if ((PC.ViewTarget!=none) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxJumpSoundDistSq))
        {
            if (!blnInAir)
            {
                blnInAir=true;
                PawnPlaySound(SoundGroupClass.static.GetJumpSound(GetMaterialBelowFeet()));
            }
            return;
        }
    }
}

simulated function name GetMaterialBelowFeet()
{
    local vector HitLocation, HitNormal;
    local TraceHitInfo HitInfo;
    local CPPhysicalMaterialProperty PhysicalProperty;
    local actor HitActor;
    local float TraceDist;

    TraceDist = 1.5 * GetCollisionHeight();

    HitActor = Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
    if ( WaterVolume(HitActor) != None )
    {
        return (Location.Z - HitLocation.Z < 0.33*TraceDist) ? 'Water' : 'ShallowWater';
    }
    if (HitInfo.PhysMaterial != None)
    {
        PhysicalProperty = CPPhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(class'CPPhysicalMaterialProperty'));
        if (PhysicalProperty != None)
        {
            return PhysicalProperty.MaterialType;
        }
    }
    return '';

}

function PlayDyingSound()
{
    local CPPlayerController PC;
    local SoundCue DieSound;

    if (SoundGroupClass == none)
        return;

    ForEach LocalPlayerControllers(class'CPPlayerController', PC)
    {
        if ((PC.ViewTarget!=none) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxJumpSoundDistSq))
        {
            DieSound = SoundGroupClass.static.GetDyingSound();
            if (DieSound != none)
                PC.LocallyPlaySoundWithReverbVolumeHackFor(self, DieSound);
            break;
        }
    }
}

// ~Drakk : This is a temporarily solution to actually hear the dying sound.
//          The Dying stuff is only executed if the body ( pawn ) doesn't get destroyed immediately.
//          Which does normally in TA because the code checks if the Controller's viewtarget is the dead pawn
//          but the TA code switches viewtarget immediately ( the controller is forced to spectate another player ) ,
//          so the according to the body removal code the dead pawn is not our viewtarget so not ours and it gets destoyed immediately.
simulated function PlayDying(class<DamageType> DamageType,vector HitLoc)
{
    local vector ApplyImpulse,ShotDir;
    local TraceHitInfo HitInfo;
    local PlayerController PC;
    //local bool bPlayersRagdoll;
    local bool  bUseHipSpring;
    local class<CPDamageType> CPDamageType;
    local RB_BodyInstance HipBodyInst;
    local int HipBoneIndex;
    local matrix HipMatrix;
    local class<UDKEmitCameraEffect> CameraEffect;

    local bool bStanding, bOnFlatSurface;
    local int HitZone;

    bCanTeleport=false;
    bReplicateMovement=false;

    bTearOff=true;
    bPlayedDeath=true;
    bPlayingFeignDeathRecovery=false;

    HitDamageType=DamageType;           // these are replicated to other clients\
    TakeHitLocation=HitLoc;

    CurrentWeaponAttachmentClass=None;
    WeaponAttachmentChanged();

    if (WorldInfo.NetMode==NM_DedicatedServer)
    {
        CPDamageType=class<CPDamageType>(DamageType);
        GotoState('Dying');
        return;
    }

    // Is this the local player's ragdoll?
    ForEach LocalPlayerControllers(class'PlayerController', PC)
    {
        if( pc.ViewTarget == self )
        {
            if ( CPHud(pc.MyHud) != none )
            {
                CPHud(pc.MyHud).DisplayHit(HitLoc, 100, DamageType);
            }
            //bPlayersRagdoll = true;
            break;
        }
    }

    CPDamageType=class<CPDamageType>(DamageType);
    CheckHitInfo(HitInfo,Mesh,Normal(TearOffMomentum),TakeHitLocation);
    
    if ( CPDamageType != None )
    {
        if (CPDamageType.default.bUseDamageBasedDeathEffects)
        {
            CPDamageType.static.DoCustomDamageEffects(self,CPDamageType,HitInfo,TakeHitLocation);
        }
        if (CPPlayerController(PC)!=none)
        {
            CameraEffect=CPDamageType.static.GetDeathCameraEffectVictim(self);
            if (CameraEffect!=none)
            {
                CPPlayerController(PC).ClientSpawnCameraEffect(CameraEffect);
            }
        }
    }

    StartFallImpactTime = WorldInfo.TimeSeconds;
	bCanPlayFallingImpacts=true;

	// if we had some other rigid body thing going on, cancel it
	if (Physics == PHYS_RigidBody)
	{
		//@note: Falling instead of None so Velocity/Acceleration don't get cleared
		setPhysics(PHYS_Falling);
	}
	// Ensure we are always updating kinematic
	Mesh.MinDistFactorForKinematicUpdate = 0.0;

	SetPawnRBChannels(TRUE);
	Mesh.ForceSkelUpdate();

	// Move into post so that we are hitting physics from last frame, rather than animated from this
	Mesh.SetTickGroup(TG_PostAsyncWork);

	bBlendOutTakeHitPhysics = false;

	PreRagdollCollisionComponent = CollisionComponent;
	CollisionComponent = Mesh;

	// Turn collision on for skelmeshcomp and off for cylinder
	CylinderComponent.SetActorCollision(false, false);
	Mesh.SetActorCollision(true, true);
	Mesh.SetTraceBlocking(true, true);

	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.0;

	// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
	if( Mesh.bNotUpdatingKinematicDueToDistance )
	{
		Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
	}

	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
	Mesh.bUpdateKinematicBonesFromAnimation=FALSE;

	// Set all kinematic bodies to the current root velocity, since they may not have been updated during normal animation
	// and therefore have zero derived velocity (this happens in 1st person camera mode).
	Mesh.SetRBLinearVelocity(Velocity, false);

	// reset mesh translation since adjustment code isn't executed on the server
	// but the ragdoll code uses the translation so we need them to match up for the
	// most accurate simulation
	Mesh.SetTranslation(vect(0,0,1) * BaseTranslationOffset);
	// we'll use the rigid body collision to check for falling damage
	Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
	Mesh.SetNotifyRigidBodyCollision(true);
	Mesh.WakeRigidBody();

    if (CPDamageType != none && CPDamageType.default.DeathAnim != '' && (FRand() > 0.5)) //If there is a death animation
    {
        if (Physics==PHYS_Walking && CPDamageType.default.bAnimateHipsForDeathAnim)
        {
                SetPhysics(PHYS_None);
                bUseHipSpring=true;
        }
        else
        {
                SetPhysics(PHYS_RigidBody);
                SetPawnRBChannels(TRUE);
        }
            Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
            Mesh.bUpdateJointsFromAnimation=TRUE;
            Mesh.PhysicsAssetInstance.SetNamedMotorsAngularPositionDrive(false,false,NoDriveBodies,Mesh,true);
            Mesh.PhysicsAssetInstance.SetAngularDriveScale(1.0f,1.0f,0.0f);

            if(bUseHipSpring)
            {
                HipBodyInst=Mesh.PhysicsAssetInstance.FindBodyInstance('b_Hips', Mesh.PhysicsAsset);
                HipBoneIndex=Mesh.MatchRefBone('b_Hips');
                HipMatrix=Mesh.GetBoneMatrix(HipBoneIndex);
                HipBodyInst.SetBoneSpringParams(DeathHipLinSpring,DeathHipLinDamp,DeathHipAngSpring,DeathHipAngDamp);
                HipBodyInst.bMakeSpringToBaseCollisionComponent = FALSE;
                HipBodyInst.EnableBoneSpring(TRUE,TRUE,HipMatrix);
                HipBodyInst.bDisableOnOverextension=TRUE;
                HipBodyInst.OverextensionThreshold=100.f;
            }
            FullBodyAnimSlot.PlayCustomAnim(CPDamageType.default.DeathAnim,CPDamageType.default.DeathAnimRate,0.05,-1.0,false,false);
            SetTimer(0.1,true,'DoingDeathAnim');
            StartDeathAnimTime=WorldInfo.TimeSeconds;
            TimeLastTookDeathAnimDamage=WorldInfo.TimeSeconds;
            DeathAnimDamageType=CPDamageType;
    }
    else //Select a death animation
    {
        HitZone = GetHitZone();
        //`log("HitZone: " $ HitZone);

        bStanding = !bIsCrouched;
        bOnFlatSurface = Floor.Z <= 1.25 && Floor.Z >= 0.75;

        if (bStanding && bOnFlatSurface && HitZone == 0) //Case 1: Standing, On a flat surface, shot from front = 'death_b'
        {
            //SetCollisionType(COLLIDE_NoCollision);
            FullBodyAnimSlot.SetActorAnimEndNotification(true);
            FullBodyAnimSlot.PlayCustomAnim(Rand(10) % 2 == 0 ? 'Death_BL' : 'Death_B180', 1.0, 0.05, -1.0, false, false);
            LifeSpan=1.0;
        }
        else if (bStanding && bOnFlatSurface && HitZone == 1) //Case 2: Standing, On a flat surface, shot from behind on the left = 'Death_BL'
        {
            //SetCollisionType(COLLIDE_NoCollision);
            FullBodyAnimSlot.SetActorAnimEndNotification(true);
            FullBodyAnimSlot.PlayCustomAnim('Death_B', 1.0, 0.05, -1.0, false, false);
            LifeSpan=1.0;
        }
        else if (bStanding && bOnFlatSurface && HitZone == 2) //Case 2: Standing, On a flat surface, shot from behind = 'death_f'
        {
            //SetCollisionType(COLLIDE_NoCollision);
            FullBodyAnimSlot.SetActorAnimEndNotification(true);
            FullBodyAnimSlot.PlayCustomAnim('Death_BR', 1.0, 0.05, -1.0, false, false);
            LifeSpan=1.0;
        }
        else if (bStanding && bOnFlatSurface && HitZone == 3) //Case 2: Standing, On a flat surface, shot from behind on the right = 'Death_BR'
        {
            //SetCollisionType(COLLIDE_NoCollision);
            FullBodyAnimSlot.SetActorAnimEndNotification(true);
            FullBodyAnimSlot.PlayCustomAnim('Death_F', 1.0, 0.05, -1.0, false, false);
            LifeSpan=1.0;
        }
        else //Play Generic Effect
        {
            if (TearOffMomentum != vect(0,0,0))
            {
                ShotDir = normal(TearOffMomentum);
                ApplyImpulse = ShotDir*DamageType.default.KDamageImpulse;
                if (Velocity.Z>-10)
                    ApplyImpulse+=Vect(0,0,1)*DamageType.default.KDeathUpKick;
                Mesh.AddImpulse(ApplyImpulse,TakeHitLocation,HitInfo.BoneName,true);
            }
        }
    }

    GotoState('Dying');
    DestroyLaserDot();
}

simulated function int GetHitZone()
{
    local int fDegrees;

    if(ShooterRotation == rot(0,0,0))
        return -1;

    fDegrees = (Rotation - ShooterRotation).Yaw * UnrRotToDeg;

    fDegrees -= 180;

    while(fDegrees < 0)
        fDegrees += 360;

    while(fDegrees > 360)
        fDegrees -= 360;

    //`log("Degrees: " $ fDegrees);

    if(fDegrees >= 300 && fDegrees < 350) //Front Right
        return 0;
    else if((fDegrees >= 0 && fDegrees < 10) || (fDegrees >= 350 && fDegrees < 360)) //Front
        return 1;
    else if(fDegrees >= 10 && fDegrees < 60) //Front Left
        return 2;
    else if(fDegrees >= 235 && fDegrees < 280) //Back
        return 3;
    else
        return -1;
}

simulated function DoingDeathAnim()
{
    local RB_BodyInstance HipBodyInst;
    local matrix DummyMatrix;
    local AnimNodeSequence SlotSeqNode;
    local float TimeSinceDeathAnimStart, MotorScale;
    local bool bStopAnim;


    if(DeathAnimDamageType.default.MotorDecayTime != 0.0)
    {
        TimeSinceDeathAnimStart = WorldInfo.TimeSeconds - StartDeathAnimTime;
        MotorScale = 1.0 - (TimeSinceDeathAnimStart/DeathAnimDamageType.default.MotorDecayTime);

        // If motors are scaled to zero, stop death anim
        if(MotorScale <= 0.0)
        {
            bStopAnim = TRUE;
        }
        // If non-zero, scale motor strengths
        else
        {
            Mesh.PhysicsAssetInstance.SetAngularDriveScale(MotorScale, MotorScale, 0.0f);
        }
    }

    // If we want to stop animation after a certain
    if( DeathAnimDamageType != None &&
        DeathAnimDamageType.default.StopAnimAfterDamageInterval != 0.0 &&
        (WorldInfo.TimeSeconds - TimeLastTookDeathAnimDamage) > DeathAnimDamageType.default.StopAnimAfterDamageInterval )
    {
        bStopAnim = TRUE;
    }


    // If done playing custom death anim - turn off bone motors.
    SlotSeqNode = AnimNodeSequence(FullBodyAnimSlot.Children[1].Anim);
    if(!SlotSeqNode.bPlaying || bStopAnim)
    {
        SetPhysics(PHYS_RigidBody);
        Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(false, false);
        HipBodyInst = Mesh.PhysicsAssetInstance.FindBodyInstance('b_Hips', Mesh.PhysicsAsset);
        HipBodyInst.EnableBoneSpring(FALSE, FALSE, DummyMatrix);

        // Ensure we have ragdoll collision on at this point
        SetPawnRBChannels(TRUE);

        ClearTimer('DoingDeathAnim');
        DeathAnimDamageType = None;
    }
}

simulated function SetPawnRBChannels(bool bRagdollMode)
{
    if(bRagdollMode)
    {
        Mesh.SetRBChannel(RBCC_Pawn);
        Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
        Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
        Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
        Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
    }
    else
    {
        Mesh.SetRBChannel(RBCC_Untitled3);
        Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
        Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
    }
}

/**
 * Called when there is a need to change the weapon attachment (either via
 * replication or locally if controlled.
 */
simulated function WeaponAttachmentChanged()
{
    if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass) && Mesh.SkeletalMesh != None)
    {
        // Detach/Destroy the current attachment if we have one
        if (CurrentWeaponAttachment!=None)
        {
            CurrentWeaponAttachment.DetachFrom(Mesh);
            CurrentWeaponAttachment.Destroy();
        }

        // Create the new Attachment.
        if (CurrentWeaponAttachmentClass!=None)
        {
            CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass,self);
            CurrentWeaponAttachment.Instigator = self;
        }
        else
        {
            CurrentWeaponAttachment = none;
        }

        // If all is good, attach it to the Pawn's Mesh.
        if (CurrentWeaponAttachment != None)
        {
            CurrentWeaponAttachment.AttachTo(self);
            CurrentWeaponAttachment.SetSkin(ReplicatedBodyMaterial);
            CurrentWeaponAttachment.ChangeVisibility(bWeaponAttachmentVisible);
        }
    }
}

// ~Drakk : for test purposes removed all checks for causes blood,blood splater and low gore, replaced the
//          familiy info get of the blood hit effect with a hardcoded refernece to our emitter.
simulated function PlayTakeHitEffects()
{
    local class<CPDamageType> TADamage;
    local vector BloodMomentum;
    local CPEmit_HitEffect HitEffect;
    local CPSaveManager TASave;
    local int GoreLevel;


    TADamage = class<CPDamageType>(LastTakeHitInfo.DamageType);
    if (TADamage != none)
    {
        if (Role == ROLE_Authority && !IsZero(LastTakeHitInfo.Momentum))
        {
            BloodSplatterFlash.Id++;
            BloodSplatterFlash.SpawnLocation = LastTakeHitInfo.HitLocation;
            BloodSplatterFlash.HitNormal = LastTakeHitInfo.Momentum;
            BloodSplatterFlash.DecalRotation = FRand() * 360;
            BloodSplatterFlash.ExpireTime = WorldInfo.TimeSeconds + BLOOD_LIFETIME / 2;

            if (WorldInfo.NetMode != NM_DedicatedServer)
            {
                SpawnBloodSplatterDecal();
            }
        }

        TASave=new(none,"") class'CPSaveManager';
        GoreLevel = int(TASave.GetItem("GoreLevel"));

        if (GoreLevel == 0 || !EffectIsRelevant(Location,false)) // Check this after doing the server stuff above!
            return;

        if (!IsFirstPerson() || class'Engine'.static.IsSplitScreen())
        {
            BloodMomentum = Normal(-1.0 * LastTakeHitInfo.Momentum) + (0.5*VRand());
            HitEffect = Spawn(GetFamilyInfo().default.BloodEmitterClass,self,,LastTakeHitInfo.HitLocation,rotator(BloodMomentum));

			if(HitEffect != none)
			{
				HitEffect.SetTemplate(BloodImpacts[Rand(BloodImpacts.Length -1)],true);
				HitEffect.SetDrawScale(0.2f);

				if (GoreLevel == 1)
					HitEffect.SetVectorParameter('Gore_Colour', vect(0.01, 0.09, 0.01)); // German blood

				HitEffect.AttachTo(self, LastTakeHitInfo.HitBone);
			}

            if (!Mesh.bNotUpdatingKinematicDueToDistance)
            {
                if (TADamage != none)
                {
                    if (!class'Engine'.static.IsSplitScreen() && Health > 0 && DrivenVehicle == none && Physics!=PHYS_RigidBody &&
                        VSize(LastTakeHitInfo.Momentum) > TADamage.default.PhysicsTakeHitMomentumThreshold)
                    {
                        if (Mesh.PhysicsAssetInstance!=none)
                        {
                            mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
                            if (bBlendOutTakeHitPhysics)
                                mesh.PhysicsWeight = 0.5;
                        }
                        else if (Mesh.PhysicsAsset!=none)
                        {
                            mesh.PhysicsWeight = 0.5;
                            mesh.PhysicsAssetInstance.SetNamedBodiesFixed(true, TakeHitPhysicsFixedBones, mesh, true);
                            mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
                            bBlendOutTakeHitPhysics = true;
                        }
                    }
                    TADamage.static.SpawnHitEffect(self, LastTakeHitInfo.Damage, LastTakeHitInfo.Momentum, LastTakeHitInfo.HitBone, LastTakeHitInfo.HitLocation);
                }
            }
        }
    }
}

simulated function SwitchWeapon(byte NewGroup)
{
    if (NewGroup == 0)
        return;

    if (CPInventoryManager(InvManager) != None)
        CPInventoryManager(InvManager).SwitchWeapon(NewGroup);
}

function TakeDrowningDamage()
{
    TakeDamage(5, None, Location + GetCollisionHeight() * vect(0,0,0.5)+ 0.7 * GetCollisionRadius() * vector(Controller.Rotation), vect(0,0,0), class'CPDmgType_Drowned');
}


/** Footstepping */
simulated event PlayFootStepSound(int FootDown)
{
local CPPlayerController PC;
local SoundCue FootSound;

    //`log("PlayFootStepSound(FootDown:"$FootDown$")");

    //if (!IsFirstPerson())
    //{
        ForEach LocalPlayerControllers(class'CPPlayerController',PC)
        {
            if ((PC.ViewTarget!=none) && (VSizeSq(PC.ViewTarget.Location-Location)<MaxFootstepDistSq))
            {
                if(PC.Pawn != none && PC.Pawn.bIsCrouched)
                {
                    FootSound=SoundGroupClass.static.GetCrouchedFootstepSound(FootDown,GetMaterialBelowFeet());
                }
                else if(PC.Pawn != none && PC.Pawn.bIsWalking)
                {
                    FootSound=SoundGroupClass.static.GetWalkingFootstepSound(FootDown,GetMaterialBelowFeet());
                }
                else
                {
                    FootSound=SoundGroupClass.static.GetFootstepSound(FootDown,GetMaterialBelowFeet());
                }
                // Don't play own footstep since this is handled elsewhere for local
				// controller.
                if (FootSound!=none && (CPPlayerController(Controller) != PC))
                {
                    PlaySound(FootSound,true);
                }
                break;
            }
        }
        if (Role==ROLE_Authority && (WorldInfo.NetMode==NM_DedicatedServer || WorldInfo.NetMode==NM_ListenServer))
        {
            if (CriticalPointGame(WorldInfo.Game)!=none)
                CriticalPointGame(WorldInfo.Game).PlaySoundWithReverbVolumeHack(self,FootSound,false,true);
        }
    //}
}

// ~Drakk : this is used for local play sound only for first person, see simulated event PlayFootStepSound for 3P play sound
simulated function ActuallyPlayFootstepSound(int FootDown)
{
    local SoundCue FootSound;

    //`log("ActuallyPlayFootstepSound(int FootDown)");

    if(bIsCrouched)
    {
        FootSound=SoundGroupClass.static.GetCrouchedFootstepSound(FootDown,GetMaterialBelowFeet());
    }
    else if(bIsWalking)
    {
        FootSound=SoundGroupClass.static.GetWalkingFootstepSound(FootDown,GetMaterialBelowFeet());
    }
    else
    {
        FootSound=SoundGroupClass.static.GetFootstepSound(FootDown,GetMaterialBelowFeet());
    }

    if (FootSound!=none)
        PlaySound(FootSound,true);
}

/** Laser dot */
simulated function CreateLaserDot()
{
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if ( LaserDotActor != none )
            DestroyLaserDot();

        LaserDotActor = Spawn( class'CPLaserDot', self,, Location, Rotation );
        LaserDotActor.Instigator = self;
    }

    if ( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer )
    {
        bAlwaysRelevant = true;
        bForceNetUpdate = true;
    }
}

simulated function DestroyLaserDot()
{
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if ( LaserDotActor != none )
        {
            LaserDotActor.Instigator = none;
            LaserDotActor.Destroy();
            LaserDotActor = none;
        }
    }

    if ( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer )
    {
        bAlwaysRelevant = false;
        bForceNetUpdate = true;
    }
}

simulated function LaserStatusUpdateNotify()
{
    NextLaserDotStatusCheck=WorldInfo.TimeSeconds-1;
}

exec function DEVServerBonesPersist()
{
    ServerBonesPersist = !ServerBonesPersist;
}

reliable client function ClientDebugBone( float x1, float y1, float z1, float x2, float y2, float z2, int bone1, int bone2 )
{
    local Vector a, b;

    if ( bone1 > 255 || bone1 < 0 || bone2 > 255 || bone2 < 0 || bone1 == bone2 )
        return;

    a.X = x1;
    a.Y = y1;
    a.Z = z1;
    b.X = x2;
    b.Y = y2;
    b.Z = z2;

    ServerBones[bone1] = a;
    ServerBones[bone2] = b;

    if ( ServerBonesPersist )
        DrawDebugLine( a, b, 255, 255, 0, true );
}

function DebugBones( float DeltaTime )
{
    local array<name> BoneNames;
    local Vector a, b;
    local name Parent;
    local int i, p;


    if ( WorldInfo.NetMode == NM_DedicatedServer )
    {
        LastBoneDebug += DeltaTime;
        if ( LastBoneDebug < DebugBoneUpdateRate )
            return;

        LastBoneDebug -= DebugBoneUpdateRate;
    }

    if ( Mesh == none )
        return;

    Mesh.GetBoneNames( BoneNames );

    for ( i = 0; i < BoneNames.Length; i++ )
    {
        if ( FindClosestHitArea( BoneNames[i] ) == EHA_None )
            continue;

        Parent = Mesh.GetParentBone( BoneNames[i] );
        p = Mesh.MatchRefBone( Parent );
        if ( Parent == 'None' )
            continue;

        a = Mesh.GetBoneLocation( BoneNames[i] );
        b = Mesh.GetBoneLocation( Parent );
        //`log( "Index:" @ i @ ">>" @ p );

        if ( WorldInfo.NetMode == NM_DedicatedServer )
        {
            ClientDebugBone( a.X, a.Y, a.Z, b.X, b.Y, b.Z, i, p );
        }
        else
        {
            DrawDebugLine( a, b, 0, 255, 128, false );
            // Draw server
            if ( WorldInfo.NetMode == NM_Client && !ServerBonesPersist )
                DrawDebugLine( ServerBones[i], ServerBones[p], 255, 0, 128, false );
        }
    }
}

simulated event Tick(float DeltaTime)
{
    local CPArmor       _Armor;
    //local Rotator       tempRot;
    local CPPlayerReplicationInfo CPPRI;
	local PlayerController PC;
	//local vector Heading, NewHeading;
	//local float HeadingX, HeadingY, HeadingZ, NewHeadingX, NewHeadingY, NewHeadingZ, DeltaTol;

    super.Tick(DeltaTime);	

	if(Controller == none)
    {
		PC = GetALocalPlayerController();
		
		if( bCanWalk && Mesh != None && !bForceRMVelocity && (Physics == PHYS_Walking || Physics == PHYS_Falling || Physics == PHYS_Swimming|| Physics == PHYS_Spider || Physics == PHYS_Ladder ) )
		{
			// for a pawn being viewed by a spectator
			if( PC != None && PC.ViewTarget == self )
			{
				
			}
			// for a pawn being viewed by another pawn
			else
			{

			}
		}
    }

	if (NextLaserDotStatusCheck-WorldInfo.TimeSeconds<=0.0)
    {
        if (Health>0 && bLaserDotStatus && LaserDotActor==none)
            CreateLaserDot();
        else if ((Health<=0 ||!bLaserDotStatus) && LaserDotActor!=none)
            DestroyLaserDot();
        NextLaserDotStatusCheck=WorldInfo.TimeSeconds+(LaserDotStatusCheckInterval+((FRand()-0.5)*0.002));
    }

	if (Role == ROLE_Authority)
    {
        if (NextBloodTrail - WorldInfo.TimeSeconds <= 0.0 && Health < 90 && Health > 0)
        {
            // Update struct members to force replication.
            BloodTrailFlash.Id++;
            BloodTrailFlash.VariantIndex = Rand(4);
            BloodTrailFlash.SpawnLocation = Location;
            BloodTrailFlash.DecalRotation = FRand() * 360; // This is the same formula as the default assignment, but we want to replicate it for consistency.
            BloodTrailFlash.ExpireTime = WorldInfo.TimeSeconds + BLOOD_LIFETIME;

            if (WorldInfo.NetMode != NM_DedicatedServer)
                SpawnBloodTrailDecal(); // Spawn blood trail on standalone and listen servers.

            if (Health < 20) //1-19HP = large blood pools, frequent drops (trickling), constant
                NextBloodTrail = WorldInfo.TimeSeconds + 1;
            else if (Health < 40) //20-39HP = mid size blood pools, frequent trickling (like a trial of blood), every 2-4 seconds
                NextBloodTrail = WorldInfo.TimeSeconds + 2 + 2*FRand();
            else if (Health < 60) //40-59HP = mid size blood pool, not so frequent, every 4-6 seconds
                NextBloodTrail = WorldInfo.TimeSeconds + 4 + 2*FRand();
            else if (Health < 80) //60-79HP = small blood drops, every 4-8 seconds
                NextBloodTrail = WorldInfo.TimeSeconds + 4 + 4*FRand();
            else //80-89HP = small blood drops, every 10-15seconds
                NextBloodTrail = WorldInfo.TimeSeconds + 10 + 5*FRand();
        }
    }

	CPPRI = CPPlayerReplicationInfo(PlayerReplicationInfo);
    if (CPPRI != None)
    {
        CPPRI.CPHealth = Health;
    } 

	if(Controller == none)
		return;

	if(PlayerController(Controller) == none)
		return;

	if( Role==ROLE_Authority && Controller != None && PlayerController(Controller).ViewTarget != self && Pawn(PlayerController(Controller).ViewTarget) != None)
	{
		PlayerController(Controller).TargetViewRotation = PlayerController(Controller).ViewTarget.Rotation;
	}

	// REFACTOR
	// This bit can probably be moved outside of tick() and into a function which is then called after every event that might change the armor
    // If we're not a spectator then continue
    if (CPPlayerController(Controller) != None)
    {
        if (CPPRI != None && (!CPPRI.bOnlySpectator || !CPPRI.bIsSpectator))
        {
            if ( Role == ROLE_Authority && InvManager != none )
            {
                _Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Body', false ) );
                BodyStrength = _Armor == none ? 0.0f : _Armor.Health / _Armor.MaxHealth;

                _Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Head', false ) );
                HeadStrength = _Armor == none ? 0.0f : _Armor.Health / _Armor.MaxHealth;

                _Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Leg', false ) );
                LegStrength = _Armor == none ? 0.0f : _Armor.Health / _Armor.MaxHealth;

                if ( WorldInfo.NetMode != NM_DedicatedServer )
                {
                    if(VestMesh != none)
                    {
                        VestMesh.SetHidden( BodyStrength <= 0.0f );
                        VestMesh.bCastHiddenShadow = BodyStrength > 0.0f;
                    }

                    if(HelmetMesh != none)
                    {
                        HelmetMesh.SetSkeletalMesh( HeadStrength <= 0.0f ? GetFamilyInfo().default.HeadHair : GetFamilyInfo().default.HeadHelmet );
                    }
                }
            }
        }
    }
}

// Leaves a trail of blood under the player while he is wounded.
// Replicated to all players.
simulated function SpawnBloodTrailDecal()
{
    local Actor TraceActor;
    local vector out_HitLocation;
    local vector out_HitNormal;
    local TraceHitInfo HitInfo;
    local MaterialInstanceTimeVarying MITV_Decal;
    local MaterialInstanceTimeVarying MITV_Decal_Wet;
    local DecalMaterial DC;
    local DecalMaterial DC_Wet;
    local InterpCurvePointFloat Pnt1;
    local InterpCurvePointFloat Pnt2;
    local InterpCurvePointFloat Pnt3;
    local InterpCurveFloat Dissolve_Curve;
    local CPSaveManager TASave;
    local int GoreLevel;
    local LinearColor GermanBlood;
    local LinearColor GermanBloodWet;
    local class<CPFamilyInfo> CPFI;
    CPFI = GetFamilyInfo();

    if (CPFI == none || IsZero(BloodTrailFlash.SpawnLocation) || BloodTrailFlash.ExpireTime <= WorldInfo.TimeSeconds)
        return;

    TASave = new(none,"") class'CPSaveManager';
    GoreLevel = int(TASave.GetItem("GoreLevel"));


    //Creating 3 points for the dissolve curve
    Pnt1.InVal = 0;
    Pnt1.OutVal = 0;
    Pnt1.InterpMode = CIM_Linear;

    Pnt2.InVal = 5;
    Pnt2.OutVal = 0.5;
    Pnt2.InterpMode = CIM_Linear;

    Pnt3.InVal = 10;
    Pnt3.OutVal = 1;
    Pnt3.InterpMode = CIM_Linear;

    //Adding those points to the InterpCurve
    Dissolve_Curve.Points[0] = Pnt1;
    Dissolve_Curve.Points[1] = Pnt2;
    Dissolve_Curve.Points[3] = Pnt3;

    if (Health > 75)
    {
        DC = CPFI.default.BloodSplatterDecalFloorMaterial[2];
        DC_Wet = CPFI.default.BloodSplatterDecalFloorMaterial[5];
    }
    else if( Health < 25)
    {
        DC = CPFI.default.BloodSplatterDecalFloorMaterial[0];
        DC_Wet = CPFI.default.BloodSplatterDecalFloorMaterial[3];
    }
    else
    {
        DC = CPFI.default.BloodSplatterDecalFloorMaterial[1];
        DC_Wet = CPFI.default.BloodSplatterDecalFloorMaterial[4];
    }


    TraceActor = Trace(out_HitLocation, out_HitNormal, BloodTrailFlash.SpawnLocation + vect(0,0,-100), BloodTrailFlash.SpawnLocation, false,, HitInfo, TRACEFLAG_PhysicsVolumes );

    if (TraceActor != None && Pawn(TraceActor) == None) //TODO: Maybe check TraceActor.bWorldGeometry instead? do we want blood on pickups?
    {
        if (WorldInfo.MyDecalManager != none && DC != none && DC_Wet != none)
        {
            MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
            if (MITV_Decal != none)
            {
                MITV_Decal.SetParent( DC );
                MITV_Decal.SetScalarParameterValue('BloodSelect', BloodTrailFlash.VariantIndex);
                //Set Color
                if (GoreLevel < 2)
                {
                    GermanBlood = MakeLinearColor(0.01, 0.09, 0.01, 1);
                    MITV_Decal.SetVectorParameterValue('Gore_Colour', GermanBlood);
                }
                WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, out_HitLocation, rotator(-out_HitNormal),
                                                    30, 30, 50, false, BloodTrailFlash.DecalRotation,
                                                    HitInfo.HitComponent, true, false,
                                                    HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex,
                                                    BloodTrailFlash.ExpireTime - WorldInfo.TimeSeconds);
            }

            MITV_Decal_Wet = new(Outer) class'MaterialInstanceTimeVarying';
            if (MITV_Decal_Wet != none)
            {
                MITV_Decal_Wet.SetParent( DC_Wet );
                MITV_Decal_Wet.SetScalarParameterValue('BloodSelect', BloodTrailFlash.VariantIndex);
                MITV_Decal_Wet.SetScalarCurveParameterValue('DissolveAmount', Dissolve_Curve);
                MITV_Decal_Wet.SetScalarStartTime('DissolveAmount', 0);
                if (GoreLevel < 2) //Set Color
                {
                    GermanBloodWet = MakeLinearColor(0.0195, 0.503, 0.0195, 1);
                    MITV_Decal_Wet.SetVectorParameterValue('Gore_Colour_Wet', GermanBloodWet);
                }
                WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal_Wet, out_HitLocation, rotator(-out_HitNormal),
                                                    30, 30, 50, false, BloodTrailFlash.DecalRotation,
                                                    HitInfo.HitComponent, true, false,
                                                    HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex,
                                                    BloodTrailFlash.ExpireTime - WorldInfo.TimeSeconds);
            }
        }
    }
}


// This will trace against the world and leave a blood splatter decal.
// This is used for having a back spray / exit wound blood effect on the wall behind us.
// Replicated to all players.
simulated function SpawnBloodSplatterDecal()
{
    local Actor TraceActor;
    local vector out_HitLocation;
    local vector out_HitNormal;
    local TraceHitInfo HitInfo;
    local MaterialInstanceTimeVarying MITV_Decal;
    local CPSaveManager TASave;
    local int GoreLevel;
    local LinearColor GermanBlood;
    local class<CPFamilyInfo> CPFI;
    CPFI = GetFamilyInfo();

    if (CPFI == none || IsZero(BloodSplatterFlash.SpawnLocation) || BloodSplatterFlash.ExpireTime <= WorldInfo.TimeSeconds)
        return;

    TASave = new(none,"") class'CPSaveManager';
    GoreLevel = int(TASave.GetItem("GoreLevel"));

    if (GoreLevel == 0)
        return;

    TraceActor = Trace(out_HitLocation, out_HitNormal, BloodSplatterFlash.SpawnLocation + (BloodSplatterFlash.HitNormal * BLOOD_SPLATTER_MAX_WALL_DIST), BloodSplatterFlash.SpawnLocation, false,, HitInfo, TRACEFLAG_PhysicsVolumes );
    //DrawDebugLine(BloodSplatterFlash.SpawnLocation, BloodSplatterFlash.SpawnLocation + (BloodSplatterFlash.HitNormal * BLOOD_SPLATTER_MAX_WALL_DIST), 255, 0, 0, true);

    if (TraceActor != None && Pawn(TraceActor) == None)
    {
        MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
        MITV_Decal.SetParent( CPFI.default.BloodSplatterDecalWallMaterial[Rand(CPFI.default.BloodSplatterDecalWallMaterial.length)] );
        MITV_Decal.SetScalarStartTime('DissolveAmount', 20.0);
        if (GoreLevel == 1) // Set Color
        {
            GermanBlood = MakeLinearColor(0, 255, 0, 1);
            MITV_Decal.SetVectorParameterValue('Gore_Colour', GermanBlood); // German blood
        }
        WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, out_HitLocation, rotator(-out_HitNormal),
                                            30, 30, 50, false, BloodSplatterFlash.DecalRotation,
                                            HitInfo.HitComponent, true, false,
                                            HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex,
                                            BloodSplatterFlash.ExpireTime - WorldInfo.TimeSeconds);
    }
}

simulated event TornOff()
{
    local class<CPDamageType> TADamage;

    Super.TornOff();
    SetPawnAmbientSound(None);
    SetWeaponAmbientSound(None);

    TADamage = class<CPDamageType>(HitDamageType);

    if ( TADamage != None)
    {
        if ( TADamage.default.DamageOverlayTime > 0 )
        {
            SetBodyMatColor(TADamage.default.DamageBodyMatColor, TADamage.default.DamageOverlayTime);
        }
        TADamage.Static.PawnTornOff(self);
    }

    DestroyLaserDot();
}

/** escaping */
simulated function TurnOffEscapedPawn()
{
    StopWeaponFiring();
    SetPawnAmbientSound(none);
    SetWeaponAmbientSound(none);
    SetCollision(false,false);
    Mesh.SetHidden(true);
    if(HelmetMesh != none)
    {
        HelmetMesh.SetHidden(true);
    }
    if(VestMesh != none)
    {
        VestMesh.SetHidden(true);
    }
    if (OverlayMesh!=None)
        OverlayMesh.SetHidden(true);
    if (CurrentWeaponAttachment!=none)
        SetWeaponAttachmentVisibility(false);
    SetHidden(true);

    SetMeshVisibility(false);
    SetInvisible(true);
    mesh.CastShadow = false;
    mesh.bCastDynamicShadow = false;
    UpdateShadowSettings(true);
}

simulated function SetWeaponAttachmentVisibility(bool bAttachmentVisible)
{
    bWeaponAttachmentVisible = bAttachmentVisible;
    if (CurrentWeaponAttachment != None )
    {
        CurrentWeaponAttachment.ChangeVisibility(bAttachmentVisible);
    }
}

function OnPlayerEscaped()
{
local CPPlayerController tapc;

    if (Controller==none)
        return;
    if (Controller.IsA('CPPlayerController'))
    {
        tapc=CPPlayerController(Controller);
        CPPlayerReplicationInfo(tapc.PlayerReplicationInfo).bHasEscaped=true;
        tapc.EscapedPawn=self;
    }
    else
    {
        `warn("CPPawn::OnPlayerEscaped - Unknown controller class ["$Controller$"]");
        return;
    }
    TurnOffEscapedPawn();
    if (tapc!=none)
        tapc.ServerSpectate();
    DetachFromController();
    ClientReStart();
}

function OnHostageRescued(Controller Rescuer)
{
    local CPHostage tapc;
	local CPPlayerReplicationInfo   _PRI;
	local CPGameReplicationInfo TAGRI;
    local CriticalPointGame         _Game;
	local int RescuerTeamIndex, RescueMoney, i;
	
    _Game = CriticalPointGame(WorldInfo.Game);
	
	if(Controller.PlayerReplicationInfo != None)
	{
		_PRI = CPPlayerReplicationInfo(Rescuer.PlayerReplicationInfo);
		if(_PRI.Team != None)
			RescuerTeamIndex = _PRI.Team.TeamIndex;
		else
			return;
	}
	else
		return;
	
	if(_Game.GameReplicationInfo != None)
	{
		TAGRI = CPGameReplicationInfo(_Game.GameReplicationInfo);
	}

    if (Controller==none)
        return;
    if (Controller.IsA('CPHostage'))
    {
        //Message for rescue hostage
		_Game.HUDMessage(40);
		for (i=0; i < TAGRI.PRIArray.Length; i++)
		{
			//If player is new (hence spectating) dont give them money
			if(TAGRI.PRIArray[i].bIsSpectator && CPPlayerReplicationInfo(TAGRI.PRIArray[i]).bIsNewPlayer)
				continue;
			
			//TODO: HostageTeamRescueAmount will be 0, hence just award the rescuer with immediate money, no need to loop over all players
			if (TAGRI.PRIArray[i].Team != none && TAGRI.PRIArray[i].Team.TeamIndex == RescuerTeamIndex )
			{
				if(CPPlayerReplicationInfo(TAGRI.PRIArray[i]).CPPlayerID == _PRI.CPPlayerID)
					RescueMoney = _Game.HostageRescueAmount;
				else
					RescueMoney = _Game.HostageTeamRescueAmount;
				CPPlayerReplicationInfo(TAGRI.PRIArray[i]).ModifyMoney(RescueMoney);
				`log("Hostage Rescued! Award "@RescueMoney@"to Player "@CPPlayerReplicationInfo(TAGRI.PRIArray[i]).CPPlayerID);
				`if(`bPollHostageRescueEvent)
					CriticalPointGame(WorldInfo.Game).PollHostageRescueEvent(WorldInfo.TimeSeconds, Rescuer, Controller, RescueMoney);
				`endif
			}
		}
        tapc=CPHostage(Controller);
        CPPlayerReplicationInfo(tapc.PlayerReplicationInfo).bHasEscaped=true;
        //tapc.EscapedPawn=self;
    }
    else
    {
        `warn("CPPawn::OnPlayerEscaped - Unknown controller class ["$Controller$"]");
        return;
    }
    TurnOffEscapedPawn();
    //if (tapc!=none)
    //  tapc.ServerSpectate();
    DetachFromController();
    ClientReStart();
}

simulated function SetCharacterClassFromInfo(class<CPFamilyInfo> Info)
{
    local CPPlayerReplicationInfo PRI;
    local int i;
    local int TeamNum;
    local MaterialInterface TeamMaterialArms;

    PRI = CPPlayerReplicationInfo(PlayerReplicationInfo);

    if (Info != none)
    {
        // If we're not a spectator then continue
        if (!PRI.bOnlySpectator)
        {
            if (Info != CurrCharClassInfo)
            {
                // Set Family Info
                CurrCharClassInfo = Info;

                // get the team number (0 red, 1 blue, 255 no team)
                TeamNum = GetTeamNum();

                // AnimSets
                Mesh.AnimSets = Info.default.AnimSets;

                // 3P Mesh and materials
                SetCharacterMeshInfo(Info.default.CharacterMesh, Info.default.CharacterMaterials);


                if (Info.default.HeadHair != none)
                {
                    // set head which corresponds to head armor status
                    HelmetMesh.SetSkeletalMesh( HeadStrength <= 0.0f ? GetFamilyInfo().default.HeadHair : GetFamilyInfo().default.HeadHelmet );
					//HelmetMesh.SetSkeletalMesh(Info.default.HeadHair);
                    HelmetMesh.AnimSets = Mesh.AnimSets;
                    HelmetMesh.SetParentAnimComponent(Mesh);
                    HelmetMesh.SetOwnerNoSee(true);
                }

                if (Info.default.Vest != none)
                {
                    //setup vest armor but hide if not player doesn't already have the corresponding body armor
                    VestMesh.SetSkeletalMesh(Info.default.Vest);
                    VestMesh.AnimSets = Mesh.AnimSets;
                    VestMesh.SetParentAnimComponent(Mesh);
                    VestMesh.SetOwnerNoSee(true);
					VestMesh.SetHidden( BodyStrength <= 0.0f );
					VestMesh.bCastHiddenShadow = BodyStrength > 0.0f;
                }

                // First person arms mesh/material (if necessary)
                if (WorldInfo.NetMode != NM_DedicatedServer /*&& IsHumanControlled() && IsLocallyControlled()*/)
                {
                    TeamMaterialArms = Info.static.GetFirstPersonArmsMaterial(TeamNum);
                    SetFirstPersonArmsInfo(Info.static.GetFirstPersonArms(), TeamMaterialArms);
                }

                // PhysicsAsset
                // Force it to re-initialise if the skeletal mesh has changed (might be flappy bones etc).
                Mesh.SetPhysicsAsset(Info.default.PhysAsset, true);

                if (HelmetMesh != none)
                {
                    Mesh.AttachComponent(HelmetMesh,'Bip_Head');
                }
                if (VestMesh != none)
                {
                    Mesh.AttachComponent(VestMesh,'Bip_Spine1');
                }

                // Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
                Mesh.bEnableFullAnimWeightBodies = FALSE;
                for (i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
                {
                    // See if a bone has bAlwaysFullAnimWeight set and also
                    if (Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
                        Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
                    {
                        Mesh.bEnableFullAnimWeightBodies = TRUE;
                    }
                }

                //Overlay mesh for effects
                if (OverlayMesh != None)
                {
                    //TODO - TOP-Proto: May need to support the armor system and head here
                    OverlayMesh.SetSkeletalMesh(Info.default.CharacterMesh);
                }

                //Set some properties on the PRI
                if (PRI != None)
                {
                    PRI.bIsFemale = Info.default.bIsFemale;
                    PRI.VoiceClass = Info.static.GetVoiceClass();

                    // a little hacky, relies on presumption that enum vals 0-3 are male, 4-8 are female
                    if ( PRI.bIsFemale )
                    {
                        PRI.TTSSpeaker = ETTSSpeaker(Rand(4));
                    }
                    else
                    {
                        PRI. TTSSpeaker = ETTSSpeaker(Rand(5) + 4);
                    }
                }

                // Bone names
                LeftFootBone = Info.default.LeftFootBone;
                RightFootBone = Info.default.RightFootBone;
                TakeHitPhysicsFixedBones = Info.default.TakeHitPhysicsFixedBones;

                // sounds
                SoundGroupClass = Info.default.SoundGroupClass;

                Mesh.SetScale(DefaultMeshScale);
                CrouchTranslationOffset = BaseTranslationOffset + CylinderComponent.Default.CollisionHeight - CrouchHeight;
            }
        }
    }
}

/** Assign an arm mesh and material to this pawn */
simulated function SetFirstPersonArmsInfo(SkeletalMesh FirstPersonArmMesh, MaterialInterface ArmMaterial)
{
    // Arms
    ArmsMesh[0].SetSkeletalMesh(FirstPersonArmMesh);
    ArmsMesh[1].SetSkeletalMesh(FirstPersonArmMesh);


    SetArmsSkin(ArmMaterial);
}

simulated protected function SetArmsSkin(MaterialInterface NewMaterial)
{
    local int i,Cnt;

    // if no material specified, grab default from PRI (if that's None too, use mesh default)
    if (NewMaterial == None)
    {
        NewMaterial = CurrCharClassInfo.static.GetFirstPersonArmsMaterial(GetTeamNum());
    }

    if ( NewMaterial == None )  // Clear the materials
    {
        if(default.ArmsMesh[0] != none && ArmsMesh[0] != none)
        {
            if( default.ArmsMesh[0].Materials.Length > 0)
            {
                Cnt = Default.ArmsMesh[0].Materials.Length;
                for(i=0;i<Cnt;i++)
                {
                    ArmsMesh[0].SetMaterial(i,Default.ArmsMesh[0].GetMaterial(i) );
                }
            }
            else if(ArmsMesh[0].Materials.Length > 0)
            {
                Cnt = ArmsMesh[0].Materials.Length;
                for(i=0;i<Cnt;i++)
                {
                    ArmsMesh[0].SetMaterial(i,none);
                }
            }
        }

        if(default.ArmsMesh[1] != none && ArmsMesh[1] != none)
        {
            if( default.ArmsMesh[1].Materials.Length > 0)
            {
                Cnt = Default.ArmsMesh[1].Materials.Length;
                for(i=0;i<Cnt;i++)
                {
                    ArmsMesh[1].SetMaterial(i,Default.ArmsMesh[1].GetMaterial(i) );
                }
            }
            else if(ArmsMesh[1].Materials.Length > 0)
            {
                Cnt = ArmsMesh[1].Materials.Length;
                for(i=0;i<Cnt;i++)
                {
                    ArmsMesh[1].SetMaterial(i,none);
                }
            }
        }
    }
    else
    {
        if ((default.ArmsMesh[0] != none && ArmsMesh[0] != none) && (default.ArmsMesh[0].Materials.Length > 0 || ArmsMesh[0].GetNumElements() > 0))
        {
            Cnt = default.ArmsMesh[0].Materials.Length > 0 ? default.ArmsMesh[0].Materials.Length : ArmsMesh[0].GetNumElements();
            for(i=0; i<Cnt;i++)
            {
                ArmsMesh[0].SetMaterial(i,NewMaterial);
            }
        }
        if ((default.ArmsMesh[1] != none && ArmsMesh[1] != none) && (default.ArmsMesh[1].Materials.Length > 0 || ArmsMesh[1].GetNumElements() > 0))
        {
            Cnt = default.ArmsMesh[1].Materials.Length > 0 ? default.ArmsMesh[1].Materials.Length : ArmsMesh[1].GetNumElements();
            for(i=0; i<Cnt;i++)
            {
                ArmsMesh[1].SetMaterial(i,NewMaterial);
            }
        }
    }
}

/** Accessor that sets the character mesh to use for this pawn, and updates instance of player in map if there is one. */
simulated function SetCharacterMeshInfo(SkeletalMesh SkelMesh, array<MaterialInterface> CharacterMaterials)
{
    local int i;
    //crashes???
    Mesh.SetSkeletalMesh(SkelMesh);

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        if (VerifyBodyMaterialInstance())
        {
            for ( i = 0 ; i < CharacterMaterials.Length ; i ++)
            {
                BodyMaterialInstances[i].SetParent(CharacterMaterials[i]);
            }
            //BodyMaterialInstances[0].SetParent(HeadMaterial);
            //if (BodyMaterialInstances.length > 1)
            //{
            //   BodyMaterialInstances[1].SetParent(BodyMaterial);
            //}
        }
        else
        {
            `log("VerifyBodyMaterialInstance failed on pawn"@self);
        }
    }
}

/**
 * This function will verify that the BodyMaterialInstance variable is setup and ready to go.  This is a key
 * component for the BodyMat overlay system
 */
simulated function bool VerifyBodyMaterialInstance()
{
    local int i;

    if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None && BodyMaterialInstances.length < Mesh.GetNumElements())
    {
        // set up material instances (for overlay effects)
        BodyMaterialInstances.length = Mesh.GetNumElements();
        for (i = 0; i < BodyMaterialInstances.length; i++)
        {
            if (BodyMaterialInstances[i] == None)
            {
                BodyMaterialInstances[i] = Mesh.CreateAndSetMaterialInstanceConstant(i);
            }
        }
    }
    return (BodyMaterialInstances.length > 0);
}

simulated function class<CPFamilyInfo> RandomCharSelect()
{
    //randomly select a character for the bots.
    if(self.PlayerReplicationInfo.Team.TeamIndex == 0)
    {
        return MERCFamArray[Rand(MERCFamArray.Length)];
    }
    else
    {
        return SWATFamArray[Rand(SWATFamArray.Length)];
    }
}

simulated function PawnPlaySound(SoundCue Sound,optional bool bRepToOwner)
{
    if (Sound!=none && Sound.SoundClass!='Ambient')
    {
        if (!bRepToOwner)
            PlaySound(Sound,true);
        ServerPawnPlaySound(Sound,bRepToOwner);
        return;
    }
    PlaySound(Sound,false,!bRepToOwner);
}

unreliable server function ServerPawnPlaySound(SoundCue Sound,optional bool bRepToOwner)
{
    if (Sound!=none && Sound.SoundClass!='Ambient' && CriticalPointGame(WorldInfo.Game)!=none)
        CriticalPointGame(WorldInfo.Game).PlaySoundWithReverbVolumeHack(self,Sound,bRepToOwner);
}


function SpawnDefaultController()
{
    Super.SpawnDefaultController();
}

simulated function PostBeginPlay()
{
    local rotator R;
    local PlayerController PC;
    local CPPlayerController CPPC;


    if (SoundGroupClass==none)
        return;

    ForEach LocalPlayerControllers(class'CPPlayerController',CPPC)
    {
        if ((CPPC.ViewTarget!=none) && (VSizeSq(CPPC.ViewTarget.Location-Location)<MaxJumpSoundDistSq))
        {
            CPPC.resetWalkAndDuck();

            break;
        }
    }


    SplashTime = 0;
    SpawnTime = WorldInfo.TimeSeconds;
    EyeHeight   = BaseEyeHeight;

    // automatically add controller to pawns which were placed in level
    // NOTE: pawns spawned during gameplay are not automatically possessed by a controller
    if ( WorldInfo.bStartup && (Health > 0) && !bDontPossess )
    {
        SpawnDefaultController();
    }

    if( FacialAudioComp != None )
    {
        FacialAudioComp.OnAudioFinished = FaceFXAudioFinished;
    }

    // Spawn Inventory Container
    if ( Role == ROLE_Authority && InvManager == none && InventoryManagerClass != none )
    {
        InvManager = Spawn( InventoryManagerClass, self );
        if ( InvManager == none )
            `log( "Warning! Couldn't spawn InventoryManager" @ InventoryManagerClass @ "for" @ self @ GetHumanReadableName() );
        else
            InvManager.SetupFor( self );
    }

    //debug
    ClearPathStep();

    StartedFallingTime = WorldInfo.TimeSeconds;

    Super.PostBeginPlay();


    if (!bDeleteMe)
    {
        if (Mesh != None)
        {
            //BaseTranslationOffset = Mesh.Translation.Z;
            //CrouchTranslationOffset = Mesh.Translation.Z + CylinderComponent.CollisionHeight - CrouchHeight;
    //      OverlayMesh.SetParentAnimComponent(Mesh);
        }
    }

    // Zero out Pitch and Roll
    R.Yaw = Rotation.Yaw;
    SetRotation(R);

    // add to local HUD's post-rendered list
    ForEach LocalPlayerControllers(class'PlayerController', PC)
    {
        if ( PC.MyHUD != None )
        {
            PC.MyHUD.AddPostRenderedActor(self);
        }
    }

    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        UpdateShadowSettings(class'CPPlayerController'.default.PawnShadowMode == SHADOW_All);
    }

    //Spawn The Flashlight
    FlashLight = Spawn(class'CPFlashlight', self);
    FlashLight.SetBase(self);
    FlashLight.LightComponent.SetEnabled(bIsFlashlightOn);


}

exec function DEVSetGroundSpeed(float val)
{
    GroundSpeed=val;
    SDEVSetGroundSpeed(val);
}

reliable server function SDEVSetGroundSpeed(float val)
{
    GroundSpeed=val;
}

exec function DEVSetWaterSpeed(float val)
{
    WaterSpeed=val;
    SDEVSetWaterSpeed(val);
}

reliable server function SDEVSetWaterSpeed(float val)
{
    WaterSpeed=val;
}

exec function DEVSetJumpZ(float val)
{
    JumpZ=val;
    SDEVSetJumpZ(val);
}

reliable server function SDEVSetJumpZ(float val)
{
    JumpZ=val;
}

exec function DEVSetAirControl(float val)
{
    AirControl=val;
    SDEVSetAirControl(val);
}

reliable server function SDEVSetAirControl(float val)
{
    AirControl=val;
}

exec function DEVSetEyeHeight(float val)
{
    BaseEyeHeight=val;
    EyeHeight=val;
    SDEVSetEyeHeight(val);
}

reliable server function SDEVSetEyeHeight(float val)
{
    BaseEyeHeight=val;
    EyeHeight=val;
}

exec function DEVSetCrouchHeight(float val)
{
    CrouchHeight=val;
    SDEVSetCrouchHeight(val);
}

reliable server function SDEVSetCrouchHeight(float val)
{
    CrouchHeight=val;
}

exec function DEVSetCrouchWalkSpeed(float val)
{
    CrouchedPct=val;
    SDEVSetCrouchWalkSpeed(val);
}

reliable server function SDEVSetCrouchWalkSpeed(float val)
{
    CrouchedPct=val;
}

exec function DEVSetWalkSpeed(float val)
{
    WalkingPct=val;
    SDEVSetWalkSpeed(val);
}

reliable server function SDEVSetWalkSpeed(float val)
{
    WalkingPct=val;
}

/** TurnOff()
Freeze pawn - stop sounds, animations, physics, weapon firing
*/
simulated function TurnOff()
{
    super.TurnOff();
    PawnAmbientSound.Stop();
}

simulated function TurnOffPawn()
{
    // hide everything, turn off collision
    if (Physics == PHYS_RigidBody)
    {
        Mesh.SetHasPhysicsAssetInstance(FALSE);
        Mesh.PhysicsWeight = 0.f;
        SetPhysics(PHYS_None);
    }
    if (!IsInState('Dying')) // so we don't restart Begin label and possibly play dying sound again
    {
        GotoState('Dying');
    }
    SetPhysics(PHYS_None);
    SetCollision(false, false);
    //@warning: can't set bHidden - that will make us lose net relevancy to everyone
    Mesh.SetHidden(true);

    if(HelmetMesh != none)
        HelmetMesh.SetHidden(true);

    if(VestMesh != none)
        VestMesh.SetHidden(true);

    if (OverlayMesh != None)
    {
        OverlayMesh.SetHidden(true);
    }
}

simulated event Destroyed()
{
    local PlayerController PC;
    local Actor A;

    DestroyLaserDot();

    Super.Destroyed();

    AimNode = None;
    WeaponAnimation = none;
    foreach BasedActors(class'Actor', A)
    {
        A.PawnBaseDied();
    }

    // remove from local HUD's post-rendered list
    ForEach LocalPlayerControllers(class'PlayerController', PC)
    {
        if ( PC.MyHUD != None )
        {
            PC.MyHUD.RemovePostRenderedActor(self);
        }
    }

    if (CurrentWeaponAttachment != None)
    {
        CurrentWeaponAttachment.DetachFrom(Mesh);
        CurrentWeaponAttachment.Destroy();
    }
}

simulated function SetThirdPersonCamera(bool bNewBehindView)
{
    if ( bNewBehindView )
    {
        CurrentCameraScale = 1.0;
        CameraZOffset = GetCollisionHeight() + Mesh.Translation.Z;
    }
    SetMeshVisibility(bNewBehindView);
}

/** sets whether or not the owner of this pawn can see it */
simulated function SetMeshVisibility(bool bVisible)
{
    // Handle the main player mesh
    if (Mesh != None)
    {
        if(VestMesh != none)
        {
            VestMesh.SetOwnerNoSee(!bVisible);
        }
        if(HelmetMesh != none)
        {
            HelmetMesh.SetOwnerNoSee(!bVisible);
        }
        Mesh.SetOwnerNoSee(!bVisible);
        ArmsMesh[0].SetOwnerNoSee(bVisible);
        ArmsMesh[1].SetOwnerNoSee(bVisible);
    }

    SetOverlayVisibility(bVisible);

    // Handle any weapons they might have
    SetWeaponVisibility(!bVisible);
}

exec function FixedView(string VisibleMeshes)
{
    local bool bVisibleMeshes;
    local float fov;

    if (WorldInfo.NetMode == NM_Standalone)
    {
        if (VisibleMeshes != "")
        {
            bVisibleMeshes = ( VisibleMeshes ~= "yes" || VisibleMeshes~="true" || VisibleMeshes~="1" );

            if (VisibleMeshes ~= "default")
                bVisibleMeshes = !IsFirstPerson();

            SetMeshVisibility(bVisibleMeshes);
        }

        if (!bFixedView)
            CalcCamera( 0.0f, FixedViewLoc, FixedViewRot, fov );

        bFixedView = !bFixedView;
        `Log("FixedView:" @ bFixedView);
    }
}

simulated function ClientReStart()
{
    local rotator AdjustedRotation;

    Super.ClientRestart();

    if (Controller != None)
    {
        AdjustedRotation = Controller.Rotation;
        AdjustedRotation.Roll = 0;
        Controller.SetRotation(AdjustedRotation);
		CPPlayerController(Controller).ResetScopeSettings();
    }

    if (bIsFlashlightOn )
        Toggle_Flashlight();


}

simulated function SetWeaponVisibility(bool bWeaponVisible)
{
    local CPWeapon Weap;
    local AnimNodeSequence WeaponAnimNode, ArmAnimNode;
    local int i;

    Weap = CPWeapon(Weapon);
    if (Weap != None)
    {
        Weap.ChangeVisibility(bWeaponVisible);

        // make the arm animations copy the current weapon anim
        WeaponAnimNode = Weap.GetWeaponAnimNodeSeq();
        if (WeaponAnimNode != None)
        {
            for (i = 0; i < ArrayCount(ArmsMesh); i++)
            {
                if (ArmsMesh[i].bAttached)
                {
                    ArmAnimNode = AnimNodeSequence(ArmsMesh[i].Animations);
                    if (ArmAnimNode != None)
                    {
                        ArmAnimNode.SetAnim(WeaponAnimNode.AnimSeqName);
                        ArmAnimNode.PlayAnim(WeaponAnimNode.bLooping, WeaponAnimNode.Rate, WeaponAnimNode.CurrentTime);
                    }
                }
            }
        }
    }
}

simulated function TakeFallingDamage()
{
    local CPPlayerController TAPC;

    Super.TakeFallingDamage();

    if (Velocity.Z < -0.5 * MaxFallSpeed)
    {
        TAPC = CPPlayerController(Controller);
        if(TAPC != None && LocalPlayer(TAPC.Player) != None)
        {
            TAPC.ClientPlayForceFeedbackWaveform(FallingDamageWaveForm);
        }
    }
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
                    const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
    // only check fall damage for Z axis collisions
    if (Abs(RigidCollisionData.ContactInfos[0].ContactNormal.Z) > 0.5)
    {
        Velocity = Mesh.GetRootBodyInstance().PreviousVelocity;
        TakeFallingDamage();
        // zero out the z velocity on the body now so that we don't get stacked collisions
        Velocity.Z = 0.0;
        Mesh.SetRBLinearVelocity(Velocity, false);
        Mesh.GetRootBodyInstance().PreviousVelocity = Velocity;
        Mesh.GetRootBodyInstance().Velocity = Velocity;
    }
}

function bool NeedToTurn(vector targ)
{
    local vector LookDir, AimDir;
    local float RequiredAim;

    LookDir = Vector(Rotation);
    LookDir.Z = 0;
    LookDir = Normal(LookDir);
    AimDir = targ - Location;
    AimDir.Z = 0;
    AimDir = Normal(AimDir);

    RequiredAim = 0.93;
    return ((LookDir Dot AimDir) < RequiredAim);
}


//TOP-Proto - do we need an overlay mesh???
simulated function SetOverlayVisibility(bool bVisible)
{
    OverlayMesh.SetOwnerNoSee(!bVisible);
}

/** This will determine and then return the FamilyInfo for this pawn **/
simulated function class<CPFamilyInfo> GetFamilyInfo()
{
    local CPPlayerReplicationInfo TAPRI;

    TAPRI = CPPlayerReplicationInfo(PlayerReplicationInfo);
    if (TAPRI != None)
    {
        return TAPRI.CharClassInfo;
    }

    return CurrCharClassInfo;
}

function bool StopWeaponFiring()
{
    local int i;
    local bool bResult;
    local CPWeapon TAWeap;

    TAWeap = CPWeapon(Weapon);
    if (TAWeap != None)
    {
        Weapon.StopFire(Weapon.CurrentFireMode);
        //TAWeap.ClientEndFire(0);
        //TAWeap.ClientEndFire(1);
        //TAWeap.ServerStopFire(0);
        //TAWeap.ServerStopFire(1);
        bResult = true;
    }

    if (InvManager != None)
    {
        for (i = 0; i < InvManager.GetPendingFireLength(Weapon); i++)
        {
            if( InvManager.IsPendingFire(Weapon, i) )
            {
                bResult = true;
                InvManager.ClearPendingFire(Weapon, i);
            }
        }
    }

    return bResult;
}

function byte ChooseFireMode()
{
    if ( CPWeapon(Weapon) != None )
    {
        return CPWeapon(Weapon).BestMode();
    }
    return 0;
}


/** starts playing the given sound via the PawnAmbientSound AudioComponent and sets PawnAmbientSoundCue for replicating to clients
 *  @param NewAmbientSound the new sound to play, or None to stop any ambient that was playing
 */
simulated function SetPawnAmbientSound(SoundCue NewAmbientSound)
{
    // if the component is already playing this sound, don't restart it
    if (NewAmbientSound != PawnAmbientSound.SoundCue)
    {
        PawnAmbientSoundCue = NewAmbientSound;
        PawnAmbientSound.Stop();
        PawnAmbientSound.SoundCue = NewAmbientSound;
        if (NewAmbientSound != None)
        {
            PawnAmbientSound.Play();
        }
    }
}

simulated function SoundCue GetPawnAmbientSound()
{
    return PawnAmbientSoundCue;
}

/** starts playing the given sound via the WeaponAmbientSound AudioComponent and sets WeaponAmbientSoundCue for replicating to clients
 *  @param NewAmbientSound the new sound to play, or None to stop any ambient that was playing
 */
simulated function SetWeaponAmbientSound(SoundCue NewAmbientSound)
{
    // if the component is already playing this sound, don't restart it
    if (NewAmbientSound != WeaponAmbientSound.SoundCue)
    {
        WeaponAmbientSoundCue = NewAmbientSound;
        WeaponAmbientSound.Stop();
        WeaponAmbientSound.SoundCue = NewAmbientSound;
        if (NewAmbientSound != None)
        {
            WeaponAmbientSound.Play();
        }
    }
}

simulated function SoundCue GetWeaponAmbientSound()
{
    return WeaponAmbientSoundCue;
}

//TOP-Proto - Drak use this to set the anim profile
/** Change the type of weapon animation we are playing. */
simulated function SetWeapAnimType(EWeapAnimType AnimType)
{
    //local int i;
    local name profile;

    if (AimNode != None)
    {
        switch(AnimType)
        {
            case EWAT_Rifle:
                profile = 'Rifle';
                break;
            case EWAT_Pistol:
                profile = 'Pistol';
                break;
            case EWAT_SMG:
                profile = 'SMG';
                break;
            case EWAT_Sniper:
                profile = 'Sniper';
                break;
            case EWAT_Melee:
                profile = 'Rifle';
                break;
            case EWAT_Bomb:
                profile = 'Rifle';
                break;
            case EWAT_Grenade:
                profile = 'Grenade';
                break;
            case EWAT_Shotgun:
                profile = 'Shotgun';
                break;
            default:
                profile = 'Holster';
                break;
        }


        //the magic happens here for changing the weap anim nodes to use the correct animations
        //for (i = 0; i < WeapAnimNodes.length; i++)
        //  WeapAnimNodes[i].SetWeapProfileByName(profile, CPWeapon(self.Weapon));

        AimNode.SetActiveProfileByName(profile);
    }
}

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
    if ( (Vehicle(Other) != None) && (Weapon != None) && Weapon.IsA('UTTranslauncher') )
        return true;

    return Super.EncroachingOn(Other);
}

event EncroachedBy(Actor Other)
{
    local CPPawn P;

    // don't get telefragged by non-vehicle ragdolls and pawns feigning death
    P = CPPawn(Other);
    if (P == None || (P.Physics != PHYS_RigidBody))
    {
        Super.EncroachedBy(Other);
    }
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
    Super.JumpOffPawn();
    bNoJumpAdjust = true;
}

/** Called when pawn cylinder embedded in another pawn.  (Collision bug that needs to be fixed).
*/
event StuckOnPawn(Pawn OtherPawn)
{
    //encroachment fix??? to be tested
    //if( CPPawn(OtherPawn) != None )
    //{
    //  TakeDamage( 10, None,Location, vect(0,0,0) , class'DmgType_Crushed');
    //}
}

event Falling()
{
}

/**
 *  Calculate camera view point, when viewing this pawn.
 *
 * @param   fDeltaTime  delta time seconds since last update
 * @param   out_CamLoc  Camera Location
 * @param   out_CamRot  Camera Rotation
 * @param   out_FOV     Field of View
 *
 * @return  true if Pawn should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
    // Handle the fixed camera

    if (bFixedView)
    {
        out_CamLoc = FixedViewLoc;
        out_CamRot = FixedViewRot;
    }
    else
    {
        if ( !IsFirstPerson() ) // Handle BehindView
        {
            CalcThirdPersonCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
        }
        else
        {
            // By default, we view through the Pawn's eyes..
            GetActorEyesViewPoint( out_CamLoc, out_CamRot );
        }

        if ( CPWeapon(Weapon) != none)
        {
            CPWeapon(Weapon).WeaponCalcCamera(fDeltaTime, out_CamLoc, out_CamRot);
        }
    }

    return true;
}

simulated State Dying
{
ignores OnAnimEnd, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

    event bool EncroachingOn(Actor Other)
    {
        // don't abort moves in ragdoll
        return false;
    }

    simulated event Timer()
    {
        //local PlayerController PC;
        //local bool bBehindAllPlayers;
        //local vector ViewLocation;
        //local rotator ViewRotation;

        // let the dead bodies stay if the game is over
        if (WorldInfo.GRI != None && WorldInfo.GRI.bMatchIsOver)
        {
            LifeSpan = 0.0;
            return;
        }

        //@Wail 11/08/13 - Intentionally disable all collision here. 2 seconds of Ragdolling around is enough.
        Mesh.SetTraceBlocking(false, false);
        Mesh.SetActorCollision(false, false);
    }

    /**
    *   Calculate camera view point, when viewing this pawn.
    *
    * @param    fDeltaTime  delta time seconds since last update
    * @param    out_CamLoc  Camera Location
    * @param    out_CamRot  Camera Rotation
    * @param    out_FOV     Field of View
    *
    * @return   true if Pawn should provide the camera point of view.
    */
    simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
    {
        local vector LookAt;
        local class<CPDamageType> TADamage;

        TADamage = class<CPDamageType>(HitDamageType);

        if (TADamage == None || !TADamage.default.bSpecialDeathCamera)
        {

            CalcThirdPersonCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
            bStopDeathCamera = bStopDeathCamera || (out_CamLoc.Z < WorldInfo.KillZ);
            if ( bStopDeathCamera && (OldCameraPosition != vect(0,0,0)) )
            {
                // Don't allow camera to go below killz, by re-using old camera position once dead pawn falls below killz
                out_CamLoc = OldCameraPosition;
                LookAt = Location;
                CameraZOffset = (fDeltaTime < 0.2) ? (1 - 5*fDeltaTime) * CameraZOffset : 0.0;
                LookAt.Z += CameraZOffset;
                out_CamRot = rotator(LookAt - out_CamLoc);
            }

            OldCameraPosition = out_CamLoc;

            // sarkis
            OldCameraRotation = out_CamRot;

            return true;
        }
        else
        {
            bStopDeathCamera = bStopDeathCamera || (OldCameraPosition.Z != 0 && (OldCameraPosition.Z < WorldInfo.KillZ || OldCameraPosition.Z < EyeHeight / 2));

            if (OldCameraPosition != vect(0,0,0) )
            {
                if (!bStopDeathCamera)
                {
                    out_CamLoc = OldCameraPosition;
                    out_CamRot = OldCameraRotation;

                    //--- check for collisions (wall and floor)
                    CheckCollision(out_CamLoc, out_CamRot);
                    //--- performs all interpolations
                    TADamage.static.CalcDeathCamera(self, fDeltaTime, out_CamLoc, out_CamRot, out_FOV, DC_DesiredLocation, DC_DesiredRotation);
                }
                else
                {
                    out_CamLoc = OldCameraPosition;
                    out_CamRot = OldCameraRotation;
                }

                // simulates a cam shake
                if (DC_EnableShake)
                    ForceCamShake(out_CamLoc);
            }

            OldCameraPosition = out_CamLoc;
            OldCameraRotation = out_CamRot;

            return true;
        }
    }

    // checks wall collisions to reverse direction when falls and floor collision to stop DC
    simulated function CheckCollision(out vector CameraLocation, out Rotator CameraRotation)
    {
        local vector HitLocation, HitNormal, traceStart, traceEnd, traceEnd1, traceEnd2, traceEnd3;
        local Actor HitActor;
        local vector _x, _y, _z;
        local float z;
        //local float iHA;

        //--- Get orientation axis
        GetAxes(DC_StartRotation, _x, _y, _z);

        //perform a trace to checks right collision
        traceStart = CameraLocation;

        // all endtrace points (at least one must be != none)
        traceEnd  = traceStart + 20.0f * _x ;
        traceEnd1 = traceStart - 20.0f * _x;
        traceEnd2 = traceStart + 20.0f * _y ;
        traceEnd3 = traceStart - 20.0f * _y;

        //--- to know exactly which trace was reached
        HitActor  = Trace(HitLocation, HitNormal, traceStart, traceEnd);
        //iHA = 0;

        if (HitActor == none)
        {
            HitActor = Trace(HitLocation, HitNormal, traceStart, traceEnd1);
            //iHA = 1;
        }

        if (HitActor == none)
        {
            HitActor = Trace(HitLocation, HitNormal, traceStart, traceEnd2);
            //iHA = 2;
        }

        if (HitActor == none)
        {
            HitActor = Trace(HitLocation, HitNormal, traceStart, traceEnd3);
            //iHA = 3;
        }

        //if touch actor at right fall, do some stuff
        if (HitActor !=none)
        {
            //--- enables shake
            DC_EnableShake = true;

            //--- stores this value to restores bellow
            z  = DC_DesiredLocation.Z;
            DC_DesiredLocation = CameraLocation;

            //--- have to invert this axes otherwise not works (dont understand why)
            DC_DesiredLocation.X += (30 * _y.X) * -1;
            DC_DesiredLocation.Y += (30 * _x.X) * -1;

            //--- restore previous value stored
            DC_DesiredLocation.Z = z;

            //--- inverse rotation - for now not exactly
            DC_DesiredRotation        = camerarotation;
            dc_desiredrotation.roll  -= 12000;
            dc_desiredrotation.pitch -= 10000; // not working
            dc_desiredrotation.yaw   -= 10000; // not working
            return;
        }

        //--- perform trace to check floor collision
        traceStart = CameraLocation;
        traceEnd = traceStart + EyeHeight/2 * vect(0,0,1);
        HitActor = Trace(HitLocation, HitNormal, traceStart, traceEnd);

        //--- if found any actor, stop deathcam
        if (HitActor !=none || DC_DesiredLocation.Z > CameraLocation.Z - 10)
        {
            //--- enables shake
            DC_EnableShake = true;
            //--- reset values for shake
            DC_ShakeValues = default.DC_ShakeValues;
            //--- stops DC
            bStopDeathCamera = true;
            return;
        }

    }

    // function to simulates a cam shake
    simulated function ForceCamShake(out vector CameraLocation)
    {
        // if not reached 0, continue with shake (decreasing)
        // X axes
        if (abs(DC_ShakeValues.X) > 0.0f)
        {
            if (DC_ShakeValues.X > 0)
            {
                CameraLocation.X += DC_ShakeValues.X;
                DC_ShakeValues.X *= -1;
            }
            else
            {
                CameraLocation.X += DC_ShakeValues.X;
                DC_ShakeValues.X *= -1;
                DC_ShakeValues.X -= 1;
            }
        }

        // Y axes
        if (abs(DC_ShakeValues.Y) > 0.0f)
        {
            if (DC_ShakeValues.Y > 0)
            {
                CameraLocation.Y += DC_ShakeValues.Y;
                DC_ShakeValues.Y *= -1;
            }
            else
            {
                CameraLocation.Y += DC_ShakeValues.Y;
                DC_ShakeValues.Y *= -1;
                DC_ShakeValues.Y -= 1;
            }
        }

        // Z axes
        if (abs(DC_ShakeValues.Z) > 0.0f)
        {
            if (DC_ShakeValues.Z > 0)
            {
                CameraLocation.Z += DC_ShakeValues.Z;
                DC_ShakeValues.Z *= -1;
            }
            else
            {
                CameraLocation.Z += DC_ShakeValues.Z;
                DC_ShakeValues.Z *= -1;
                DC_ShakeValues.Z -= 1;
            }
        }

    }

    simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
    {
        local Vector shotDir, ApplyImpulse,BloodMomentum;
        local class<CPDamageType> TADamage;
        local CPEmit_HitEffect HitEffect;
        local CPSaveManager TASave;
        local int GoreLevel;
        local LinearColor GermanBlood;

        TASave=new(none,"") class'CPSaveManager';
        GoreLevel = int(TASave.GetItem("GoreLevel"));
        GermanBlood = MakeLinearColor(0, 255, 0, 1);

        if(GoreLevel == 0)
            return;

        // When playing death anim, we keep track of how long since we took that kind of damage.
        if(DeathAnimDamageType != None)
        {
            if(DamageType == DeathAnimDamageType)
            {
                TimeLastTookDeathAnimDamage = WorldInfo.TimeSeconds;
            }
        }

        if ((InstigatedBy != None || EffectIsRelevant(Location, true, 0)))
        {
            TADamage = class<CPDamageType>(DamageType);
            Health -= Damage;

         if ( TADamage != None )
            {
                if ( !bHideOnListenServer && (WorldInfo.NetMode != NM_DedicatedServer) )
                {
                    CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );
                    TADamage.Static.SpawnHitEffect(self, Damage, Momentum, HitInfo.BoneName, HitLocation);

                    if ( TADamage.default.bCausesBlood && !class'CriticalPointGame'.Static.UseLowGore(WorldInfo)
                        && ((PlayerController(Controller) == None) || (WorldInfo.NetMode != NM_Standalone)) )
                    {
                        BloodMomentum = Momentum;
                        if ( BloodMomentum.Z > 0 )
                            BloodMomentum.Z *= 0.5;
                        HitEffect = Spawn(GetFamilyInfo().default.BloodEmitterClass,self,, HitLocation, rotator(BloodMomentum));
                        HitEffect.AttachTo(self,HitInfo.BoneName);
                    }

                    if ( (TADamage.default.DamageOverlayTime > 0) && (TADamage.default.DamageBodyMatColor != class'CPDamageType'.default.DamageBodyMatColor) )
                    {
                        SetBodyMatColor((GoreLevel == 1 ? GermanBlood : TADamage.default.DamageBodyMatColor), TADamage.default.DamageOverlayTime);
                    }

                    if( (Physics != PHYS_RigidBody) || (Momentum == vect(0,0,0)) || (HitInfo.BoneName == '') )
                        return;

                    shotDir = Normal(Momentum);
                    ApplyImpulse = (DamageType.Default.KDamageImpulse * shotDir);

                    if( TADamage.Default.bThrowRagdoll && (Velocity.Z > -10) )
                    {
                        ApplyImpulse += Vect(0,0,1)*DamageType.default.KDeathUpKick;
                    }
                    // AddImpulse() will only wake up the body for the bone we hit, so force the others to wake up
                    Mesh.WakeRigidBody();
                    Mesh.AddImpulse(ApplyImpulse, HitLocation, HitInfo.BoneName, true);
                }
            }
        }
    }

    simulated event Tick(FLOAT DeltaSeconds)
    {
        if ( (Mesh == None) )
        {
            Disable('Tick');
        }
    }

    simulated function BeginState(Name PreviousStateName)
    {
        local class<CPDamageType> TADamage;

        Super.BeginState(PreviousStateName);

        //--- here, try to let the damage class give the desired loc. and rot.
        //--- As DmgType_Suicided class is not a subclass of CPDamageType, soon will not have the properties and functions.
        //--- then, when the HitDamageType class was DmgType_Suicided just replace to the base class CPDamageType to fix two problems
        //--- Sarkis, 2/11/2014
        if (HitDamageType == class'DmgType_Suicided')
            HitDamageType = class'CPDamageType';

        TADamage = class<CPDamageType>(HitDamageType);

        //---This prevents scriptwarning
        //---[1158.10] ScriptWarning: Accessed null class context 'TADamage'
        //---      CPPawn CP-Frostbite.TheWorld: PersistentLevel.CPPawn_3
        //---      Function CriticalPoint.CPPawn: Dying.BeginState: 0063
        if (TADamage != none)
            TADamage.static.GetDesiredValues(self, DC_DesiredLocation, DC_DesiredRotation);

        //--- at this point the variables DC_DesiredLocation and DC_DesiredRotation already has its values defined
        //--- Sarkis, 2/11/2014

        //@Wail 11/08/13 - Let's manually hide our 1P arms meshes when we die.

        HideArms(true);
        //@Wail 11/23/13 - Manually set our collision to false
        SetCollision(false, false);

        CustomGravityScaling = 1.0;
        DeathTime = WorldInfo.TimeSeconds;
        CylinderComponent.SetActorCollision(false, false);

        if ( bIsFlashlightOn )
            Toggle_Flashlight();

        if ( bTearOff && (bHideOnListenServer || (WorldInfo.NetMode == NM_DedicatedServer)) )
            LifeSpan = RagDollLifeSpan;
        else
        {
            if ( Mesh != None )
            {
                Mesh.SetTraceBlocking(true, true);
                Mesh.SetActorCollision(true, false);

                // Move into post so that we are hitting physics from last frame, rather than animated from this
                Mesh.SetTickGroup(TG_PostAsyncWork);
            }

            SetTimer(2.0, false);
            LifeSpan = RagDollLifeSpan;
        }
    }
}


/**
 * Performs an Emote command.  This is typically an action that
 * tells the bots to do something.  It is server-side only
 *
 * @Param EInfo         The emote we are working with
 * @Param PlayerID      The ID of the player this emote is directed at.  255 = All Players
 */
function PerformEmoteCommand(EmoteInfo EInfo, int PlayerID)
{
    local array<CPPlayerReplicationInfo> PRIs;
    local Controller Sender;

    Sender = Controller;
    if (Sender == None && DrivenVehicle != None)
    {
        Sender = DrivenVehicle.Controller;
    }
    if (Sender != None)
    {
        // If we require a player for this command, look it up
        if ( EInfo.bRequiresPlayer || EInfo.CategoryName == 'Order' )
        {
            if ( PRIs.Length == 0 )
            {
                return;
            }
        }
        else    // See with our own just to have the loop work
        {
            PRIs[0] = CPPlayerReplicationInfo(PlayerReplicationInfo);
        }
    }
}

/**
 * We override TakeDamage and allow the weapon to modify it
 * @See Pawn.TakeDamage
 */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    local CPPlayerController tapc;

    //if the player gets hit when using something stop the use
    if (CPPlayerController(Controller)!=none)
        CPPlayerController(Controller).StopUse();

    //if the player gets hit when planting the bomb, stop the planting.
    if(Controller != none && Controller.Pawn!= none && CPWeapon(Controller.Pawn.Weapon) != none)
    {
        if(CPWeapon(Controller.Pawn.Weapon).IsA('CPWeap_Bomb'))
        {
            if( CPPawn( Controller.Pawn ).bIsUsingObjective )
            {
                ClientStopFire(0);
            }
        }
    }
    // reduce rocket jumping
    if (EventInstigator == Controller)
    {
        momentum *= 0.6;
    }
    // ~WillyG: to prevent nade jumping
    if(CPProj_Grenade(DamageCauser) != none)
        Momentum.Z *= 0.5;

    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

    if (Controller!=none &&
        CPPlayerController(Controller)!=none &&
        //InstigatedBy!=Controller &&
        //InstigatedBy.GetTeamNum()!=Controller.GetTeamNum() && ////////////// TOP-PROTO I BROKE THIS I DONT KNOW WHAT THE FCUK THIS CODES DOING!!
        Damage>0 &&
        Health>0)
    {
        HitByEnemy++;
        LastHitTime=WorldInfo.TimeSeconds;
        if (WorldInfo.NetMode==NM_ListenServer)
            if (CPPlayerController(Controller)!=none)
                CPPlayerController(Controller).OnDamageTaken();

        foreach WorldInfo.AllControllers(class'CPPlayerController',tapc)
        {
            if (tapc !=none &&
                !tapc.IsDead() &&
                tapc.Pawn!=none &&
                tapc.Pawn.IsSameTeam(self) &&
                tapc.PlayerReplicationInfo!=none &&
                !tapc.PlayerReplicationInfo.bIsSpectator &&
                !tapc.PlayerReplicationInfo.bOutOfLives &&
                tapc.IsLookingAtActorWithPct(self,0.4,500.0))
            {
                tapc.OnTeammateHit();
            }
        }
    }
}

/**
 * Called when a pawn's weapon has fired and is responsibile for
 * delegating the creation off all of the different effects.
 *
 * bViaReplication denotes if this call in as the result of the
 * flashcount/flashlocation being replicated.  It's used filter out
 * when to make the effects.
 */
simulated function WeaponFired( Weapon InWeapon, bool bViaReplication, optional vector HitLocation )
{
    /*if ( CurrentWeaponAttachment == none || IsFirstPerson() )
        return;

    `log( "Weapon has fired" );
    CurrentWeaponAttachment.ThirdPersonFireEffects( HitLocation );*/
}

simulated function WeaponStoppedFiring( Weapon InWeapon, bool bViaReplication )
{
    /*if ( CurrentWeaponAttachment == none || IsFirstPerson() )
        return;

    `log( "Weapon has stopped firing" );
    CurrentWeaponAttachment.StopThirdPersonFireEffects();*/
    //CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
}
simulated function bool CalcThirdPersonCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
    local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset;
    local float DesiredCameraZOffset;

    //ModifyRotForDebugFreeCam(out_CamRot);

    CamStart = Location;
    CurrentCamOffset = CamOffset;

    if ( bWinnerCam )
    {
        // use "hero" cam
        SetHeroCam(out_CamRot);
        CurrentCamOffset = vect(0,0,0);
        CurrentCamOffset.X = GetCollisionRadius();
    }
    else
    {
        DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
        CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
        if ( Health <= 0 )
        {
            CurrentCamOffset = vect(0,0,0);
            CurrentCamOffset.X = GetCollisionRadius();
        }
    }
    CamStart.Z += CameraZOffset;
    GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
    CamDirX *= CurrentCameraScale;

    if ( (Health <= 0) || bFeigningDeath )
    {
        // adjust camera position to make sure it's not clipping into world
        // @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
        FindSpot(GetCollisionExtent(),CamStart);
    }
    if (CurrentCameraScale < CameraScale)
    {
        CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
    }
    else if (CurrentCameraScale > CameraScale)
    {
        CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
    }
    if (CamDirX.Z > GetCollisionHeight())
    {
        CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
    }
    out_CamLoc = CamStart - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;
    if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
    {
        out_CamLoc = HitLocation;
        return false;
    }
    return true;
}

simulated event FellOutOfWorld(class<DamageType> dmgType)
{
    super.FellOutOfWorld(DmgType);
    bStopDeathCamera = true;
}

simulated function SetBodyMatColor(LinearColor NewBodyMatColor, float NewOverlayDuration)
{
    RemainingBodyMatDuration = NewOverlayDuration;
    ClientBodyMatDuration = RemainingBodyMatDuration;
    BodyMatFadeDuration = 0.5 * RemainingBodyMatDuration;
    BodyMatColor = NewBodyMatColor;
    CompressedBodyMatColor.Pitch = 256.0 * BodyMatColor.R;
    CompressedBodyMatColor.Yaw = 256.0 * BodyMatColor.G;
    CompressedBodyMatColor.Roll = 256.0 * BodyMatColor.B;

    CurrentBodyMatColor = BodyMatColor;
    CurrentBodyMatColor.R += 1;             // make sure CurrentBodyMatColor differs from BodyMatColor to force update
    VerifyBodyMaterialInstance();
}

simulated function FindGoodEndView(PlayerController InPC, out Rotator GoodRotation)
{
    local rotator ViewRotation;
    local int tries;
    local float bestdist, newdist;
    local CPPlayerController PC;

    PC = CPPlayerController(InPC);

    bWinnerCam = true;
    SetHeroCam(GoodRotation);
    GoodRotation.Pitch = HeroCameraPitch;
    ViewRotation = GoodRotation;
    ViewRotation.Yaw = Rotation.Yaw + 32768 + 8192;
    if ( TryNewCamRot(PC, ViewRotation, newdist) )
    {
        GoodRotation = ViewRotation;
        return;
    }

    ViewRotation = GoodRotation;
    ViewRotation.Yaw = Rotation.Yaw + 32768 - 8192;
    if ( TryNewCamRot(PC, ViewRotation, newdist) )
    {
        GoodRotation = ViewRotation;
        return;
    }

    // failed with Hero cam
    ViewRotation.Pitch = 56000;
    tries = 0;
    bestdist = 0.0;
    CameraScale = Default.CameraScale;
    CurrentCameraScale = Default.CameraScale;
    for (tries=0; tries<16; tries++)
    {
        if ( TryNewCamRot(PC, ViewRotation, newdist) )
        {
            GoodRotation = ViewRotation;
            return;
        }

        if (newdist > bestdist)
        {
            bestdist = newdist;
            GoodRotation = ViewRotation;
        }
        ViewRotation.Yaw += 4096;
    }
}

simulated function SetHeroCam(out rotator out_CamRot)
{
    CameraZOffset = 0.0;
    CameraScale = HeroCameraScale;
    CurrentCameraScale = HeroCameraScale;
}

simulated function bool TryNewCamRot(CPPlayerController PC, rotator ViewRotation, out float CamDist)
{
    local vector cameraLoc;
    local rotator cameraRot;
    local float FOVAngle;

    cameraLoc = Location;
    cameraRot = ViewRotation;
    if ( CalcThirdPersonCam(0, cameraLoc, cameraRot, FOVAngle) )
    {
        CamDist = VSize(cameraLoc - Location - vect(0,0,1)*CameraZOffset);
        return true;
    }
    CamDist = VSize(cameraLoc - Location - vect(0,0,1)*CameraZOffset);
    return false;
}

/** Called when teleporting */
simulated function PostBigTeleport()
{
    ForceUpdateComponents();
    Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
}

/* BecomeViewTarget
    Called by Camera when this actor becomes its ViewTarget */
simulated event BecomeViewTarget( PlayerController PC )
{
    local CPPlayerController TAPC;
    local CPWeapon TAWeap;

    Super.BecomeViewTarget(PC);

    if (LocalPlayer(PC.Player) != None)
    {
        PawnAmbientSound.bAllowSpatialization = false;
        WeaponAmbientSound.bAllowSpatialization = false;

        bArmsAttached = true;
        AttachComponent(ArmsMesh[0]);
        TAWeap = CPWeapon(Weapon);
        if (TAWeap != None)
        {
            if (TAWeap.bUsesOffhand)
            {
                AttachComponent(ArmsMesh[1]);
            }
        }

        TAPC = CPPlayerController(PC);
        if (TAPC != None)
        {
            SetMeshVisibility(TAPC.bBehindView);
        }
        else
        {
            SetMeshVisibility(true);
        }
        bUpdateEyeHeight = true;
    }
}

/* EndViewTarget
    Called by Camera when this actor becomes its ViewTarget */
simulated event EndViewTarget( PlayerController PC )
{
    PawnAmbientSound.bAllowSpatialization = true;
    WeaponAmbientSound.bAllowSpatialization = true;

    if (LocalPlayer(PC.Player) != None)
    {
        SetMeshVisibility(true);
        HideArms(true);
        bArmsAttached=false;		
        DetachComponent(ArmsMesh[0]);
        DetachComponent(ArmsMesh[1]);
    }
}

simulated function vector WeaponBob(float BobDamping, float JumpDamping)
{
    Local Vector WBob;

    WBob = BobDamping * WalkBob;
    WBob.Z = (0.45 + 0.55 * BobDamping)*WalkBob.Z;
    WBob.Z += JumpDamping *(LandBob - JumpBob);
    return WBob;
}

simulated function float GetEyeHeight()
{
    if ( !IsLocallyControlled() )
        return BaseEyeHeight;
    else
        return EyeHeight;
}

simulated function string GetScreenName()
{
    return PlayerReplicationInfo.PlayerName;
}

/**
PostRenderFor()
Hook to allow pawns to render HUD overlays for themselves.
Called only if pawn was rendered this tick.
Assumes that appropriate font has already been set
@todo FIXMESTEVE - special beacon when speaking (SpeakingBeaconTexture)
*/
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
    local float TextXL, XL, YL, Dist;
    local vector ScreenLoc;
    local LinearColor TeamColor;
    local Color TextColor;
    local string ScreenName;
    local CPWeapon Weap;
    local CPPlayerReplicationInfo PRI;
    local CPHUD HUD;

    screenLoc = Canvas.Project(Location + GetCollisionHeight()*vect(0,0,1));
    // make sure not clipped out
    if (screenLoc.X < 0 ||
        screenLoc.X >= Canvas.ClipX ||
        screenLoc.Y < 0 ||
        screenLoc.Y >= Canvas.ClipY)
    {
        return;
    }

    PRI=CPPlayerReplicationInfo(PlayerReplicationInfo);
    if (!WorldInfo.GRI.OnSameTeam(self,PC))
        return;

    // make sure not behind weapon
    if ( CPPawn(PC.Pawn) != None )
    {
        Weap = CPWeapon(CPPawn(PC.Pawn).Weapon);
        if ( (Weap != None) && Weap.CoversScreenSpace(screenLoc, Canvas) )
        {
            return;
        }
    }

    // periodically make sure really visible using traces
    if ( WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5 )
    {
        LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
        bPostRenderTraceSucceeded = FastTrace(Location, CameraPosition)
                                    || FastTrace(Location+GetCollisionHeight()*vect(0,0,1), CameraPosition);
    }
    if ( !bPostRenderTraceSucceeded )
    {
        return;
    }

    class'CPHUD'.Static.GetTeamColor( GetTeamNum(), TeamColor, TextColor);

    Dist = VSize(CameraPosition - Location);
    if ( Dist < TeamBeaconPlayerInfoMaxDist )
    {
        ScreenName = GetScreenName();
        Canvas.StrLen(ScreenName, TextXL, YL);
        XL = Max( TextXL, 24 * Canvas.ClipX/1024 * (1 + 2*Square((TeamBeaconPlayerInfoMaxDist-Dist)/TeamBeaconPlayerInfoMaxDist)));
    }
    else
    {
        XL = Canvas.ClipX * 16 * TeamBeaconPlayerInfoMaxDist/(Dist * 1024);
        YL = 0;
    }

    Class'CPHUD'.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-1.8*YL,1.4*XL,1.9*YL, TeamColor, Canvas);

    if ( (PRI != None) && (Dist < TeamBeaconPlayerInfoMaxDist) )
    {
        Canvas.DrawColor = TextColor;
        Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.2*YL);
        Canvas.DrawText( ScreenName, true, , , class'CPHUD'.default.TextRenderInfo );
    }

    HUD = CPHUD(PC.MyHUD);
    if ( (HUD != None) && !HUD.bCrosshairOnFriendly
        && (Abs(screenLoc.X - 0.5*Canvas.ClipX) < 0.1 * Canvas.ClipX)
        && (screenLoc.Y <= 0.5*Canvas.ClipY) )
    {
        // check if top to bottom crosses center of screen
        screenLoc = Canvas.Project(Location - GetCollisionHeight()*vect(0,0,1));
        if ( screenLoc.Y >= 0.5*Canvas.ClipY )
        {
            HUD.bCrosshairOnFriendly = true;
        }
    }
}

simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
    if ( Physics == PHYS_Ladder && OnLadder != none )
    {
        NewRotation = OnLadder.Walldir;
    }
    else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
    {
        NewRotation.Pitch = 0;
    }
    NewRotation.Roll = Rotation.Roll;
    SetRotation(NewRotation);
}


/* UpdateEyeHeight()
* Update player eye position, based on smoothing view while moving up and down stairs, and adding view bobs for landing and taking steps.
* Called every tick only if bUpdateEyeHeight==true.
*/
event UpdateEyeHeight( float DeltaTime )
{
    local float smooth, MaxEyeHeight, OldEyeHeight;
    local Actor HitActor;
    local vector HitLocation,HitNormal;

    if ( bTearOff )
    {
        // no eyeheight updates if dead
        EyeHeight = Default.BaseEyeheight;
        bUpdateEyeHeight = false;
        return;
    }

    if ( abs(Location.Z - OldZ) > 15 )
    {
        // if position difference too great, don't do smooth land recovery
        bJustLanded = false;
        bLandRecovery = false;
    }

    if ( !bJustLanded )
    {
        // normal walking around
        // smooth eye position changes while going up/down stairs
        smooth = FMin(0.9, 10.0 * DeltaTime/CustomTimeDilation);
        LandBob *= (1 - smooth);
        if( Physics == PHYS_Walking || Physics==PHYS_Spider || Controller.IsInState('PlayerSwimming') )
        {
            OldEyeHeight = EyeHeight;
            EyeHeight = FMax((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
                                -0.5 * CylinderComponent.CollisionHeight);
        }
        else
        {
            EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
        }
    }
    else if ( bLandRecovery )
    {
        // return eyeheight back up to full height
        smooth = FMin(0.9, 9.0 * DeltaTime);
        OldEyeHeight = EyeHeight;
        LandBob *= (1 - smooth);
        // linear interpolation at end
        if ( Eyeheight > 0.9 * BaseEyeHeight )
        {
            Eyeheight = Eyeheight + 0.15*BaseEyeheight*Smooth;  // 0.15 = (1-0.75)*0.6
        }
        else
            EyeHeight = EyeHeight * (1 - 0.6*smooth) + BaseEyeHeight*0.6*smooth;
        if ( Eyeheight >= BaseEyeheight)
        {
            bJustLanded = false;
            bLandRecovery = false;
            Eyeheight = BaseEyeheight;
        }
    }
    else
    {
        // drop eyeheight a bit on landing
        smooth = FMin(0.65, 8.0 * DeltaTime);
        OldEyeHeight = EyeHeight;
        EyeHeight = EyeHeight * (1 - 1.5*smooth);
        LandBob += 0.08 * (OldEyeHeight - Eyeheight);
        if ( (Eyeheight < 0.25 * BaseEyeheight + 1) || (LandBob > 2.4)  )
        {
            bLandRecovery = true;
            Eyeheight = 0.25 * BaseEyeheight + 1;
        }
    }

    // don't bob if disabled, or just landed
    if( bJustLanded || !bUpdateEyeheight )
    {
        BobTime = 0;
        WalkBob = Vect(0,0,0);
    }
    else
    {
		calcWalkBob(DeltaTime);
    }
    if ( (CylinderComponent.CollisionHeight - Eyeheight < 12) && IsFirstPerson() )
    {
      // desired eye position is above collision box
      // check to make sure that viewpoint doesn't penetrate another actor
        // min clip distance 12
        if (bCollideWorld)
        {
            HitActor = trace(HitLocation,HitNormal, Location + WalkBob + (MaxStepHeight + CylinderComponent.CollisionHeight) * vect(0,0,1),
                          Location + WalkBob, true, vect(12,12,12),, TRACEFLAG_Blocking);
            MaxEyeHeight = (HitActor == None) ? CylinderComponent.CollisionHeight + MaxStepHeight : HitLocation.Z - Location.Z;
            Eyeheight = FMin(Eyeheight, MaxEyeHeight);
        }
    }
}

simulated event CalcWalkBob(float DeltaTime)
{
	
	local float Speed2D, OldBobTime;
    local vector X, Y, Z;
    local int m,n;

    // add some weapon bob based on jumping
    if ( Velocity.Z > 0 )
    {
      JumpBob = FMax(-1.5, JumpBob - 0.03 * DeltaTime * FMin(Velocity.Z,300));
    }
    else
    {
      JumpBob *= (1 -  FMin(1.0, 8.0 * DeltaTime));
    }

    // Add walk bob to movement
    OldBobTime = BobTime;

    Bob = FClamp(Bob, -0.05, 0.05);

    if (Physics == PHYS_Walking )
    {
      GetAxes(Rotation,X,Y,Z);
      Speed2D = VSize(Velocity);
      if ( Speed2D < 10 )
          BobTime += 0.2 * DeltaTime;
      else
          BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
      WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
      AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
      WalkBob.Z = AppliedBob;
      if ( Speed2D > 10 )
          WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
    }
    else if ( Physics == PHYS_Swimming )
    {
      GetAxes(Rotation,X,Y,Z);
      BobTime += DeltaTime;
      Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
      WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * BobTime);
      WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * BobTime);
    }
    else
    {
      BobTime = 0;
      WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
    }
    
    if ( bNetOwner && (Physics == PHYS_Walking) && (VSizeSq(Velocity) > 100) && IsFirstPerson() )
    {
        m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
        n = int(0.5 * Pi + 9.0 * BobTime/Pi);

        if ( (m != n) )
        {
            ActuallyPlayFootStepSound(0);
        }
    }    

}

/** called when we have been stuck falling for a long time with zero velocity
 * and couldn't find a place to move to get out of it
 */
event StuckFalling()
{
    if (AIController(Controller) != None)
    {
        Suicide();
    }
    else
    {
        StartedFallingTime = WorldInfo.TimeSeconds;
    }
}
simulated function bool IsFirstPerson()
{
    local CPPlayerController PC;

    ForEach LocalPlayerControllers(class'CPPlayerController', PC)
    {
        if(CPPawn(PC.Pawn) != none && CPPawn(PC.Pawn).bFixedView)
            return false;
        if ( (PC.ViewTarget == self) && PC.UsingFirstPersonCamera() )
            return true;
    }
    return false;
}

//TOP-Proto go though this function as its got all sorts in it!
event Landed(vector HitNormal, actor FloorActor)
{
    local vector Impulse;

    Super.Landed(HitNormal, FloorActor);

    // adds impulses to vehicles and dynamicSMActors (e.g. KActors)
    Impulse.Z = Velocity.Z * 4.0f; // 4.0f works well for landing on a Scorpion
    if (DynamicSMActor(FloorActor) != None)
    {
        DynamicSMActor(FloorActor).StaticMeshComponent.AddImpulse(Impulse, Location);
    }

    if ( Velocity.Z < -200 )
    {
        OldZ = Location.Z;
        bJustLanded = bUpdateEyeHeight && (Controller != None) && Controller.LandingShake();
    }

    if (CPInventoryManager(InvManager) != None)
    {
        CPInventoryManager(InvManager).OwnerEvent('Landed');
    }

    AirControl = DefaultAirControl;

    if(!bHidden)
    {
        PlayLandingSound();
    }
    if (Velocity.Z < -MaxFallSpeed)
    {
        SoundGroupClass.Static.PlayFallingDamageLandSound(self);
    }
    else if (Velocity.Z < MaxFallSpeed * -0.5)
    {
        SoundGroupClass.Static.PlayLandSound(self);
    }

    SetBaseEyeheight();
}

/**
 * Called when a weapon is changed and is responsible for making sure
 * the new weapon respects the current pawn's states/etc.
 */

simulated function WeaponChanged(CPWeapon NewWeapon)
{
    local UDKSkeletalMeshComponent UTSkel;

    // Make sure the new weapon respects behindview
    if (NewWeapon.Mesh != None)
    {
        NewWeapon.Mesh.SetHidden(!IsFirstPerson());
        UTSkel = UDKSkeletalMeshComponent(NewWeapon.Mesh);
        if (UTSkel != none)
        {
            ArmsMesh[0].SetFOV(UTSkel.FOV);
            ArmsMesh[1].SetFOV(UTSkel.FOV);
            ArmsMesh[0].SetScale(UTSkel.Scale);
            ArmsMesh[1].SetScale(UTSkel.Scale);
            NewWeapon.PlayWeaponEquip();
        }
    }
}

//TOP-Proto use the one in pawn.uc!!
///**
// * Return world location to start a weapon fire trace from.
// *
// * @return    World location where to start weapon fire traces from
// */
//simulated function Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
//{
//  return GetPawnViewLocation();
//}

function Gasp()
{
    SoundGroupClass.Static.PlayGaspSound(self);
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
    local int i,j;
    local PrimitiveComponent P;
    local string s;
    local float xl,yl;

    Super.DisplayDebug(HUD, out_YL, out_YPos);

    if (HUD.ShouldDisplayDebug('twist'))
    {
        Hud.Canvas.SetDrawColor(255,255,200);
        Hud.Canvas.SetPos(4,out_YPos);
        Hud.Canvas.DrawText(""$Self$" - "@Rotation@" RootYaw:"@RootYaw@" CurrentSkelAim"@CurrentSkelAim.X@CurrentSkelAim.Y);
        out_YPos += out_YL;
    }

    if ( !HUD.ShouldDisplayDebug('component') )
        return;

    Hud.Canvas.SetDrawColor(255,255,128,255);

    for (i=0;i<Mesh.Attachments.Length;i++)
    {
        HUD.Canvas.SetPos(4,out_YPos);

        s = ""$Mesh.Attachments[i].Component;
        Hud.Canvas.Strlen(s,xl,yl);
        j = len(s);
        while ( xl > (Hud.Canvas.ClipX*0.5) && j>10)
        {
            j--;
            s = Right(S,j);
            Hud.Canvas.StrLen(s,xl,yl);
        }

        HUD.Canvas.DrawText("Attachment"@i@" = "@Mesh.Attachments[i].BoneName@s);
        out_YPos += out_YL;

        P = PrimitiveComponent(Mesh.Attachments[i].Component);
        if (P!=None)
        {
            HUD.Canvas.SetPos(24,out_YPos);
            HUD.Canvas.DrawText("Component = "@P.Owner@P.HiddenGame@P.bOnlyOwnerSee@P.bOwnerNoSee);
            out_YPos += out_YL;

            s = ""$P;
            Hud.Canvas.Strlen(s,xl,yl);
            j = len(s);
            while ( xl > (Hud.Canvas.ClipX*0.5) && j>10)
            {
                j--;
                s = Right(S,j);
                Hud.Canvas.StrLen(s,xl,yl);
            }

            HUD.Canvas.SetPos(24,out_YPos);
            HUD.Canvas.DrawText("Component = "@s);
            out_YPos += out_YL;
        }
    }

    out_YPos += out_YL*2;
    HUD.Canvas.SetPos(24,out_YPos);
    HUD.Canvas.DrawText("Driven Vehicle = "@DrivenVehicle);
    out_YPos += out_YL;
}

/* GetPawnViewLocation()
Called by PlayerController to determine camera position in first person view.  Returns
the location at which to place the camera
*/
simulated function Vector GetPawnViewLocation()
{
    if ( bUpdateEyeHeight )
        return Location + EyeHeight * vect(0,0,1) + WalkBob;
    else
        return Location + BaseEyeHeight * vect(0,0,1);
}

/** moves the camera in or out one */
simulated function AdjustCameraScale(bool bMoveCameraIn)
{
    if ( !IsFirstPerson() )
    {
        CameraScale = FClamp(CameraScale + (bMoveCameraIn ? -1.0 : 1.0), CameraScaleMin, CameraScaleMax);
    }
}

simulated event rotator GetViewRotation()
{
    return Super.GetViewRotation();
}


/** InCombat()
returns true if pawn is currently in combat, as defined by specific game implementation.
*/
function bool InCombat()
{
    return (WorldInfo.TimeSeconds - LastPainSound < 1) && !PhysicsVolume.bPainCausing;
}

simulated function ClearBodyMatColor()
{
    RemainingBodyMatDuration = 0;
    ClientBodyMatDuration = 0;
    BodyMatFadeDuration = 0;
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
    local CPPlayerController Hearer;
    local class<CPDamageType> TADamage;

    if ( InstigatedBy != None && (class<CPDamageType>(DamageType) != None) && class<CPDamageType>(DamageType).default.bDirectDamage )
    {
        Hearer = CPPlayerController(InstigatedBy);
        if (Hearer != None)
        {
            Hearer.bAcuteHearing = true;
        }
    }

    if (WorldInfo.TimeSeconds - LastPainSound >= MinTimeBetweenPainSounds)
    {
        LastPainSound = WorldInfo.TimeSeconds;

        if (Damage > 0 && Health > 0)
        {

            if ( DamageType == class'CPDmgType_Drowned' )
            {
                SoundGroupClass.static.PlayDrownSound(self);
            }
            else
            {
                SoundGroupClass.static.PlayTakeHitSound(self, Damage);
            }
        }
    }

    if ( Health <= 0 && PhysicsVolume.bDestructive && (WaterVolume(PhysicsVolume) != None) && (WaterVolume(PhysicsVolume).ExitActor != None) )
    {
        Spawn(WaterVolume(PhysicsVolume).ExitActor);
    }

    super.PlayHit(Damage, InstigatedBy, HitLocation, DamageType, Momentum, HitInfo);

    if (Hearer != None)
    {
        Hearer.bAcuteHearing = false;
    }

    TADamage = class<CPDamageType>(DamageType);

    if (Damage > 0 || (Controller != None && Controller.bGodMode))
    {
        CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );

        // play serverside effects
        //if (bShieldAbsorb)
        //{
        //  SetBodyMatColor(SpawnProtectionColor, 1.0);
        //  PlaySound(ArmorHitSound);
        //  bShieldAbsorb = false;
        //  return;
        //}
        //else
            if (TADamage != None && TADamage.default.DamageOverlayTime > 0.0 && TADamage.default.XRayEffectTime <= 0.0)
        {
            SetBodyMatColor(TADamage.default.DamageBodyMatColor, TADamage.default.DamageOverlayTime);
        }

        LastTakeHitInfo.Damage = Damage;
        LastTakeHitInfo.HitLocation = HitLocation;
        LastTakeHitInfo.Momentum = Momentum;
        LastTakeHitInfo.DamageType = DamageType;
        LastTakeHitInfo.HitBone = HitInfo.BoneName;
        LastTakeHitTimeout = WorldInfo.TimeSeconds + ( (TADamage != None) ? TADamage.static.GetHitEffectDuration(self, Damage)
                                    : class'CPDamageType'.static.GetHitEffectDuration(self, Damage) );

        // play clientside effects
        PlayTakeHitEffects();
    }
}

function bool IsLocationOnHead(const out ImpactInfo Impact, float AdditionalScale)
{
    local vector HeadLocation;
    local float Distance;

    if (HeadBone == '')
    {
        return False;
    }

    Mesh.ForceSkelUpdate();
    HeadLocation = Mesh.GetBoneLocation(HeadBone) + vect(0,0,1) * HeadHeight;

    // Find distance from head location to bullet vector
    Distance = PointDistToLine(HeadLocation, Impact.RayDir, Impact.HitLocation);

    return ( Distance < (HeadRadius * HeadScale * AdditionalScale) );
}

simulated function SetHeadScale(float NewScale)
{
    local SkelControlBase SkelControl;

    HeadScale = NewScale;
    SkelControl = Mesh.FindSkelControl('HeadControl');
    if (SkelControl != None)
    {
        SkelControl.BoneScale = NewScale;
        SkelControl.IgnoreAtOrAboveLOD = 1000;
    }

    // we need to scale the neck bone also as otherwise the head piece leaves a point and doesn't show the neck cavity
    SkelControl = Mesh.FindSkelControl('NeckControl');
    if (SkelControl != None)
    {
        // NeckScale should only ever between 0 or 1
        SkelControl.BoneScale = FClamp( NewScale, 0.f, 1.0f );
        SkelControl.IgnoreAtOrAboveLOD = 1000;
    }
}

/**
 * SetSkin is used to apply a single material to the entire model, including any applicable attachments.
 * NOTE: Attachments (ie: the weapons) need to handle resetting their default skin if NewMaterinal = NONE
 *
 * @Param   NewMaterial     The material to apply
 */

simulated function SetSkin(Material NewMaterial)
{
    local int i;

    // Replicate the Material to remote clients
    ReplicatedBodyMaterial = NewMaterial;

    if (VerifyBodyMaterialInstance())       // Make sure we have setup the BodyMaterialInstances array
    {
        // Propagate it to the 3rd person weapon attachment
        if (CurrentWeaponAttachment != None)
        {
            CurrentWeaponAttachment.SetSkin(NewMaterial);
        }

        // Propagate it to the 1st person weapon
        if (CPWeapon(Weapon) != None)
        {
            CPWeapon(Weapon).SetSkin(NewMaterial);
        }

        // Set the skin
        if (NewMaterial == None)
        {
            for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++)
            {
                Mesh.SetMaterial(i, BodyMaterialInstances[i]);
            }
        }
        else
        {
            for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++)
            {
                Mesh.SetMaterial(i, NewMaterial);
            }
        }

        SetArmsSkin(NewMaterial);
    }
}

/**
 * Apply a given overlay material to the overlay mesh.
 *
 * @Param   NewOverlay      The material to overlay
 */
simulated function SetOverlayMaterial(MaterialInterface NewOverlay)
{
    local int i;

    // If we are authoritative, then set up replication of the new overlay
    if (Role == ROLE_Authority)
    {
        OverlayMaterialInstance = NewOverlay;
    }

    if (Mesh.SkeletalMesh != None)
    {
        if (NewOverlay != None)
        {
            for (i = 0; i < OverlayMesh.SkeletalMesh.Materials.Length; i++)
            {
                OverlayMesh.SetMaterial(i, OverlayMaterialInstance);
            }

            // attach the overlay mesh
            if (!OverlayMesh.bAttached)
            {
                AttachComponent(OverlayMesh);
            }
        }
        else if (OverlayMesh.bAttached)
        {
            //if (ShieldBeltArmor > 0)
            //{
            //  // reapply shield belt overlay
            //  SetOverlayMaterial(GetShieldMaterialInstance(WorldInfo.Game.bTeamGame));
            //}
            //else
            //{
                DetachComponent(OverlayMesh);
            //}
        }
    }
}

/**
 * This function is a pass-through to the weapon/weapon attachment that is used to set the various overlays
 */

simulated function ApplyWeaponOverlayFlags(byte NewFlags)
{
    local CPWeapon Weap;

    if (Role == ROLE_Authority)
    {
        WeaponOverlayFlags = NewFlags;
    }

    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        Weap = CPWeapon(Weapon);
        if ( Weap != none)
        {
            Weap.SetWeaponOverlayFlags(self);
        }

        if ( CurrentWeaponAttachment != none )
        {
            CurrentWeaponAttachment.SetWeaponOverlayFlags(self);
        }
    }
}

simulated function SetInvisible(bool bNowInvisible)
{
    bIsInvisible = bNowInvisible;

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        if (bIsInvisible)
        {
            Mesh.CastShadow = false;
            Mesh.bCastDynamicShadow = false;

            if(HelmetMesh != none)
            {
                HelmetMesh.CastShadow = false;
                HelmetMesh.bCastDynamicShadow = false;
            }

            if(VestMesh != none)
            {
                VestMesh.CastShadow = false;
                VestMesh.bCastDynamicShadow = false;
            }

            ReattachMesh();
        }
        else
        {
            Mesh.CastShadow = true;
            Mesh.bCastDynamicShadow = true;

            if(HelmetMesh != none)
            {
                HelmetMesh.CastShadow = true;
                HelmetMesh.bCastDynamicShadow = true;
            }

            if(VestMesh != none)
            {
                VestMesh.CastShadow = true;
                VestMesh.bCastDynamicShadow = true;
            }

            UpdateShadowSettings(!class'Engine'.static.IsSplitScreen() && class'CPPlayerController'.default.PawnShadowMode == SHADOW_All);
        }
    }
}

/** reattaches the mesh component, because settings were updated */
simulated function ReattachMesh()
{
    DetachComponent(Mesh);
    AttachComponent(Mesh);
    EnsureOverlayComponentLast();
}

/** called when FireRateMultiplier is changed to update weapon timers */
simulated function FireRateChanged()
{
    if (Weapon != None && Weapon.IsTimerActive('RefireCheckTimer'))
    {
        // make currently firing weapon slow down firing rate
        Weapon.ClearTimer('RefireCheckTimer');
        Weapon.TimeWeaponFiring(Weapon.CurrentFireMode);
    }
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
    Super.PossessedBy(C, bVehicleTransition);
    NotifyTeamChanged();
}

simulated function NotifyTeamChanged()
{
    local CPPlayerReplicationInfo PRI;
    local int i;

    // set mesh to the one in the PRI, or default for this team if not found
    PRI = CPPlayerReplicationInfo(PlayerReplicationInfo);

    if (PRI != None)
    {
        SetCharacterClassFromInfo(GetFamilyInfo());

        if (WorldInfo.NetMode != NM_DedicatedServer)
        {
            // refresh weapon attachment
            if (CurrentWeaponAttachmentClass != None)
            {
                // recreate weapon attachment in case the socket on the new mesh is in a different place
                if (CurrentWeaponAttachment != None)
                {
                    CurrentWeaponAttachment.DetachFrom(Mesh);
                    CurrentWeaponAttachment.Destroy();
                    CurrentWeaponAttachment = None;
                }
                WeaponAttachmentChanged();
            }
            // refresh overlay
            if (OverlayMaterialInstance != None)
            {
                SetOverlayMaterial(OverlayMaterialInstance);
            }
        }

        // Make sure physics is in the correct state.
        // Rebuild array of bodies to not apply joint drive to.
        if(Mesh.PhysicsAsset != none)
        {
            NoDriveBodies.length = 0;
            for( i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
            {
                if(Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight)
                {
                    NoDriveBodies.AddItem(Mesh.PhysicsAsset.BodySetup[i].BoneName);
                }
            }
        }
        // Reset physics state.
        bIsHoverboardAnimPawn = FALSE;
        ResetCharPhysState();
    }

    if (!bReceivedValidTeam)
    {
        SetTeamColor();
        bReceivedValidTeam = (GetTeam() != None);
    }
}

/**
 * When a pawn's team is set or replicated, SetTeamColor is called.  By default, this will setup
 * any required material parameters.
 */
simulated function SetTeamColor()
{
    local int i;
    local CPPlayerReplicationInfo PRI;
    local LinearColor LinColor;

    if ( PlayerReplicationInfo != None )
    {
        PRI = CPPlayerReplicationInfo(PlayerReplicationInfo);
    }

    if ( PRI == None )
        return;

    LinColor.A = 1.0;

    if ( PRI.Team == None )
    {
        if ( VerifyBodyMaterialInstance() )
        {
            LinColor.R = 2.0;
            LinColor.G = 2.0;

            for (i = 0; i < BodyMaterialInstances.length; i++)
            {
                BodyMaterialInstances[i].SetVectorParameterValue('Char_TeamColor', LinColor);
                BodyMaterialInstances[i].SetScalarParameterValue('Char_DistSaturateSwitch', 1.0);
            }
        }
    }
    else if (VerifyBodyMaterialInstance())
    {
        if ( PRI.Team.TeamIndex == 0 )
        {
            LinColor.R = 2.0;
            for (i = 0; i < BodyMaterialInstances.length; i++)
            {
                BodyMaterialInstances[i].SetVectorParameterValue('Char_TeamColor', LinColor);
                BodyMaterialInstances[i].SetScalarParameterValue('Char_DistSaturateSwitch', 1.0);
            }
        }
        else
        {
            LinColor.B = 2.0;
            for (i = 0; i < BodyMaterialInstances.length; i++)
            {
                BodyMaterialInstances[i].SetVectorParameterValue('Char_TeamColor', LinColor);
                BodyMaterialInstances[i].SetScalarParameterValue('Char_DistSaturateSwitch', 1.0);
            }
        }
    }
}

/** called when bBlendOutTakeHitPhysics is true and our Mesh's PhysicsWeight has reached 0.0 */
simulated event TakeHitBlendedOut()
{
    Mesh.PhysicsWeight = 0.0;
    Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
}

/** Enable or disable IK that keeps hands on IK bones. */
simulated function SetHandIKEnabled(bool bEnabled)
{
    if (WorldInfo.NetMode != NM_DedicatedServer && Mesh.Animations != None)
    {
        if (bEnabled)
        {
            LeftHandIK.SetSkelControlStrength(1.0, 0.0);
            RightHandIK.SetSkelControlStrength(1.0, 0.0);
        }
        else
        {
            LeftHandIK.SetSkelControlStrength(0.0, 0.0);
            RightHandIK.SetSkelControlStrength(0.0, 0.0);
        }
    }
}

/** Util for scaling running anims etc. */
simulated function SetAnimRateScale(float RateScale)
{
    Mesh.GlobalAnimRateScale = RateScale;
}

simulated function ResetCharPhysState()
{
    if(Mesh.PhysicsAssetInstance != None)
    {
        // Now set up the physics based on what we are currently doing.
        if(Physics == PHYS_RigidBody)
        {
            // Ragdoll case
            Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
            SetPawnRBChannels(TRUE);
            SetHandIKEnabled(FALSE);
        }
        else
        {
            // Normal case
            Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
            Mesh.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, Mesh);

            SetPawnRBChannels(FALSE);
            SetHandIKEnabled(TRUE);
        }
    }
}


/**
 * Adjusts weapon aiming direction.
 * Gives Pawn a chance to modify its aiming. For example aim error, auto aiming, adhesion, AI help...
 * Requested by weapon prior to firing.
 *
 * @param   W, weapon about to fire
 * @param   StartFireLoc, world location of weapon fire start trace, or projectile spawn loc.
 */
//this origingal function got out of sync in server/client models
simulated function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
    if(Controller != none)
        return Controller.GetAdjustedAimFor( W, StartFireLoc );
    else
        return GetALocalPlayerController().GetAdjustedAimFor( W, StartFireLoc );
}

/**
 * returns base Aim Rotation without any adjustment (no aim error, no autolock, no adhesion.. just clean initial aim rotation!)
 *
 * @return  base Aim rotation.
 */
simulated singular event Rotator GetBaseAimRotation()
{
    local Vector    _Location;
    local Rotator   _Rotation;

    // If we have a controller, by default we aim at the player's 'eyes' direction
    // that is by default Controller.Rotation for AI, and camera (crosshair) rotation for human players.
    if( Controller != None && !InFreeCam() )
    {
        Controller.GetPlayerViewPoint( _Location, _Rotation );
		return _Rotation;
    }
	else
	{
		_Rotation = GetViewRotation();
		if( _Rotation.Pitch == 0 )
		{
			_Rotation.Pitch = RemoteViewPitch << 8;
		}
		return _Rotation;
	}
}

//fix when throwing the bomb to the floor.
function TossInventory(Inventory Inv, optional vector ForceVelocity)
{
    local Vector        POVLoc, TossVel;
    local Rotator       POVRot;
    local float         TossPower;
    local CPWeap_Bomb   Bomb;


    if(Inv == none)
        return;

	bForceNetUpdate=true; //force an update to the weapon to replicate any and all values when the weapon is throewn

    TossPower = 384.0f;
    if ( ForceVelocity != vect(0,0,0) )
    {
        TossVel = ForceVelocity;
    }
    else
    {
        GetActorEyesViewPoint(POVLoc, POVRot);
        TossVel = Vector(POVRot);
    }

    Bomb = CPWeap_Bomb( Inv );
    if ( Bomb != none )
    {
        if ( GetTeamNum() == TTI_Mercenaries )
        {
            if ( Bomb.IsPlanting() )
            {
                AnnounceBombPlanted();
                TossPower = 0.0f;
            }
            else
            {
                AnnounceBombTossed();
            }
        }
    }

    Inv.DropFrom( Location, TossVel * TossPower );

    If(self.Health > 0)
    {
        PlaySound(CPWeapon( Inv ).WeaponThrowSnd);
    }
}

reliable server function AnnounceBombTossed()
{
    if (CriticalPointGame(WorldInfo.Game)!=none)
        CriticalPointGame(WorldInfo.Game).AnnounceBombTossed();
}

reliable server function AnnounceBombPlanted()
{
    if (CriticalPointGame(WorldInfo.Game)!=none)
        CriticalPointGame(WorldInfo.Game).AnnounceBombPlanted();
}

/*
simulated function SetCustomAimNode(rotator ViewRot, float DeltaTime)
{
    local float         _Pitch;


    if ( CustomAimNode == none )
        return;

    _Pitch = float( NormalizeRotAxis( ViewRot.Pitch ) );

    CustomAimNode.bForceAimDir = false;
    CustomAimNode.ForcedAimDir = ANIMAIM_CENTERUP;
    CustomAimNode.Aim.Y = FClamp( _Pitch / ( ( _Pitch > 0 ? ViewPitchMax : -ViewPitchMin ) ), -1.0f, 1.0f );
    CustomAimNode.Aim.X = 0.0f;
}
*/

simulated function Toggle_Flashlight()
{
    if(bHasFlashlight)
    {
        bIsFlashlightOn = !bIsFlashlightOn;
        FlashLightToggled();

        if( Role < Role_Authority )
        {
            ServerToggleFlashlight();
        }
    }
}

reliable server function ServerToggleFlashlight()
{
    bIsFlashlightOn = !bIsFlashlightOn;
}

simulated function FlashLightToggled()
{
    FlashLight.LightComponent.SetEnabled(bIsFlashlightOn);
}

simulated function DamageArmor()
{
    local CPArmor Armor;

    Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Head', false ) );
    if(Armor != none)
        Armor.Health = 74;

    Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Body', false ) );
    if(Armor != none)
            Armor.Health = 74;

    Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Leg', false ) );
    if(Armor != none)
        Armor.Health = 74;
}

function NotifyFlashBang(float Time, float Scale, Vector Loc)
{
    acTinnitusSound.Stop();
    acTinnitusSound.VolumeMultiplier = Scale;
    acTinnitusSound.Play();
}

function StopFlashBangAudioCue()
{
    acTinnitusSound.Stop();
}

DefaultProperties
{
    Components.Remove(Sprite)

    Begin Object Class=AudioComponent Name=TinnitusSound
        SoundCue=SoundCue'CP_Weapon_Sounds.Grenades.FlashBangTinnitus_Cue'
        bAutoPlay=false
        bStopWhenOwnerDestroyed=true
        bUseOwnerLocation=true
    End Object
    acTinnitusSound=TinnitusSound
    Components.Add(TinnitusSound);

    // Remove UDKPawn's defined skeletal mesh
    //Components.Remove(WPawnSkeletalMeshComponent)

    // Create the animation sequence
    //Begin Object class=AnimNodeSequence Name=AnimNodeSequence
    //End Object


    SWATFamArray[0]=class'CriticalPoint.CP_SWAT_MaleOne'
    SWATFamArray[1]=class'CriticalPoint.CP_SWAT_FemaleOne'

    MERCFamArray[0]=class'CriticalPoint.CP_MERC_MaleOne'
    MERCFamArray[1]=class'CriticalPoint.CP_MERC_FemaleOne'

    //default movement speeds : 1:1 with AoT
    GroundSpeed=302
    JumpZ=350
    AirControl=0.275 //~WillyG
    DefaultAirControl=0.275 //~WillyG

    CrouchedPct=0.32
    WalkingPct=0.32

    BaseEyeHeight=34.25         //1:1
    EyeHeight=34.25             //1:1
    AirSpeed=300.000000                            // + weapon weight
    WaterSpeed=270.000000                          // AoT didnt have water speed - TODO what was water speed in ut99??
    AccelRate=1800.000000                          // + weapon weight
    CrouchHeight=32.00001
    CrouchRadius=22.0           //What was this in ut99? (did it have a separate crouch radius?)
    WalkableFloorZ=0.78
    CollisionType=COLLIDE_TouchAll

    AlwaysRelevantDistanceSquared=+1960000.0

    bReplicateHealthToAll=true

    Begin Object Name=CollisionCylinder
        CollisionRadius=+22.000000
        CollisionHeight=+44.000000
        BlockActors=true
        BlockZeroExtent=false
        BlockNonZeroExtent=true
        CollideActors=true
        AlwaysCheckCollision=true
    End Object
    CylinderComponent=CollisionCylinder
    CollisionComponent=CollisionCylinder

    Begin Object Class=CPAmbientSoundComponent name=AmbientSoundComponent
    End Object
    PawnAmbientSound=AmbientSoundComponent
    Components.Add(AmbientSoundComponent)

    Begin Object Class=CPAmbientSoundComponent name=AmbientSoundComponent2
    End Object
    WeaponAmbientSound=AmbientSoundComponent2
    Components.Add(AmbientSoundComponent2)

    ViewPitchMin=-16384.0       // 90 degrees
    ViewPitchMax=16384.0        // 90 degrees

    MeleeRange=+40.0            //1:1


    BaseCrouchHeight=20.0      //added var to allow us to crouch as in AoT   1:1

    //possible eyeheight when swimming adjustment?
    SwimmingZOffset=-30.0
    SwimmingZOffsetSpeed=45.0

    //will stop AI from double jumping
    bCanDoubleJump=False
    MaxMultiJump=0
    MultiJumpRemaining=0

    bCanWalkOffLedges=true

    BuyZone=none

    LastHitTime=-1000.0

    // custom inventory manager
    InventoryManagerClass=class'CPInventoryManager'
    SoundGroupClass=class'CPPawnSoundGroup'

    LaserDotStatusCheckInterval=0.008

    DefaultMeshScale=1.3
    BaseTranslationOffset=14

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=TRUE
        bIsCharacterLightEnvironment=TRUE
        bUseBooleanEnvironmentShadowing=FALSE
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment

    /* TOP-Proto TODO go though this section carefully */
    Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
        bCacheAnimSequenceNodes=true
        AlwaysLoadOnClient=true
        AlwaysLoadOnServer=true
        AlwaysCheckCollision=true
        BlockZeroExtent=true
        BlockNonZeroExtent=true
        CollideActors=true
        BlockActors=false
        bOwnerNoSee=false
        BlockRigidBody=true
        bUpdateSkelWhenNotRendered=true
        bTickAnimNodesWhenNotRendered=true
        bIgnoreControllersWhenNotRendered=false
        bUpdateKinematicBonesFromAnimation=true
        Translation=(Z=14.0)
        RBChannel=RBCC_Untitled3
        RBCollideWithChannels=(Untitled3=true)
        LightEnvironment=MyLightEnvironment
        bOverrideAttachmentOwnerVisibility=true
        bAcceptsDynamicDecals=FALSE
        AnimTreeTemplate=AnimTree'TA_CH_All.Stuff.TA_AT_Human_CP_New'
        //AnimTreeTemplate=AnimTree'TA_CH_All.Stuff.TA_AT_Human_CP_New_02'
        bHasPhysicsAssetInstance=true
        TickGroup=TG_PreAsyncWork
        MinDistFactorForKinematicUpdate=0.2
        bChartDistanceFactor=true
        //bSkipAllUpdateWhenPhysicsAsleep=true
        RBDominanceGroup=20
        // Nice lighting for hair
        bPerBoneMotionBlur=true
        bCastHiddenShadow=true
        CastShadow=true
        bCastDynamicShadow=true
        bUseOnePassLightingOnTranslucency=TRUE
        AnimationLODFrameRate=1
    End Object
    Mesh=WPawnSkeletalMeshComponent
    Components.Add(WPawnSkeletalMeshComponent)

    //for the Vest
    Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponentVest
        bCacheAnimSequenceNodes=FALSE
        AlwaysLoadOnClient=true
        AlwaysLoadOnServer=true
        AlwaysCheckCollision=true
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        CollideActors=false
        BlockActors=false
        bOwnerNoSee=true
        BlockRigidBody=false
        bUpdateSkelWhenNotRendered=true
        bIgnoreControllersWhenNotRendered=TRUE
        bUpdateKinematicBonesFromAnimation=true
        RBChannel=RBCC_Untitled3
        RBCollideWithChannels=(Untitled3=true)
        LightEnvironment=MyLightEnvironment
        bOverrideAttachmentOwnerVisibility=true
        bAcceptsDynamicDecals=FALSE
        bHasPhysicsAssetInstance=false
        TickGroup=TG_PreAsyncWork
        MinDistFactorForKinematicUpdate=0.2
        bChartDistanceFactor=true
        RBDominanceGroup=20
        // Nice lighting for hair
        bPerBoneMotionBlur=true


        bCastHiddenShadow=false
        CastShadow=true
        bCastDynamicShadow=true
        bUseOnePassLightingOnTranslucency=TRUE

        // Assign the parent animation component to the head skeletal mesh component. This ensures that
        // the pawn animates as if it was one skeletal mesh component.
        ParentAnimComponent=WPawnSkeletalMeshComponent
        // Assign the shadow parent component to the head skeletal mesh component. This is used to speed up
        // the rendering of the shadow for this pawn and to prevent shadow overlaps from occur.
        ShadowParent=WPawnSkeletalMeshComponent

    End Object
    VestMesh=WPawnSkeletalMeshComponentVest
    Components.Add(WPawnSkeletalMeshComponentVest)

    //for the helmet
    Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponentHelmet
        bCacheAnimSequenceNodes=true
        AlwaysLoadOnClient=true
        AlwaysLoadOnServer=true
        AlwaysCheckCollision=true
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        CollideActors=false
        BlockActors=false
        bOwnerNoSee=true
        BlockRigidBody=false
        bUpdateSkelWhenNotRendered=true
        bIgnoreControllersWhenNotRendered=TRUE
        bUpdateKinematicBonesFromAnimation=true
        RBCollideWithChannels=(Untitled3=true)
        LightEnvironment=MyLightEnvironment
        bOverrideAttachmentOwnerVisibility=true
        bAcceptsDynamicDecals=FALSE
        bHasPhysicsAssetInstance=false
        TickGroup=TG_PreAsyncWork
        MinDistFactorForKinematicUpdate=0.2
        bChartDistanceFactor=true
        RBDominanceGroup=20
        // Nice lighting for hair
        bPerBoneMotionBlur=true


        bCastHiddenShadow=true
        CastShadow=true
        bCastDynamicShadow=true
        bUseOnePassLightingOnTranslucency=TRUE

        // Assign the parent animation component to the head skeletal mesh component. This ensures that
        // the pawn animates as if it was one skeletal mesh component.
        ParentAnimComponent=WPawnSkeletalMeshComponent
        // Assign the shadow parent component to the head skeletal mesh component. This is used to speed up
        // the rendering of the shadow for this pawn and to prevent shadow overlaps from occur.
        ShadowParent=WPawnSkeletalMeshComponent
    End Object
    HelmetMesh=WPawnSkeletalMeshComponentHelmet
    Components.Add(WPawnSkeletalMeshComponentHelmet)

    Begin Object Name=OverlayMeshComponent0 Class=SkeletalMeshComponent
        Scale=1.04
        bAcceptsDynamicDecals=FALSE
        bOwnerNoSee=false
        bUpdateSkelWhenNotRendered=true
        bOverrideAttachmentOwnerVisibility=true
        TickGroup=TG_PostAsyncWork
        bPerBoneMotionBlur=true

        CastShadow=FALSE

    End Object
    OverlayMesh=OverlayMeshComponent0

    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

    Begin Object class=AnimNodeSequence Name=MeshSequenceB
    End Object

    Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms
        bCacheAnimSequenceNodes=true
        //PhysicsAsset=None
        FOV=55
        Animations=MeshSequenceA
        DepthPriorityGroup=SDPG_Foreground
		ViewOwnerDepthPriorityGroup=SDPG_Foreground
        bUpdateSkelWhenNotRendered=false
        bIgnoreControllersWhenNotRendered=true
        bOnlyOwnerSee=true
        bOverrideAttachmentOwnerVisibility=true
        bAcceptsDynamicDecals=FALSE
        AbsoluteTranslation=false
        AbsoluteRotation=true
        AbsoluteScale=true
        bSyncActorLocationToRootRigidBody=false
        TickGroup=TG_DuringASyncWork
        Scale=3.0
		bUseViewOwnerDepthPriorityGroup=true
    End Object
    ArmsMesh[0]=FirstPersonArms

    Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms2
        bCacheAnimSequenceNodes=true
        //PhysicsAsset=None
        FOV=55
        Scale3D=(Y=-1.0)
        Animations=MeshSequenceB
        DepthPriorityGroup=SDPG_Foreground
		ViewOwnerDepthPriorityGroup=SDPG_Foreground
        bUpdateSkelWhenNotRendered=false
        bIgnoreControllersWhenNotRendered=true
        bOnlyOwnerSee=true
        bOverrideAttachmentOwnerVisibility=true
        HiddenGame=true
        bAcceptsDynamicDecals=FALSE
        AbsoluteTranslation=false
        AbsoluteRotation=true
        AbsoluteScale=true
        bSyncActorLocationToRootRigidBody=false
        CastShadow=false
        TickGroup=TG_DuringASyncWork
        Scale=3.0
		bUseViewOwnerDepthPriorityGroup=true
    End Object
    ArmsMesh[1]=FirstPersonArms2


    //sounds
    MaxFootstepDistSq=9000000.0
    MaxJumpSoundDistSq=16000000.0

    bWeaponAttachmentVisible=true

    //contols the hip during the deathanim stage
    DeathHipLinSpring=10000.0
    DeathHipLinDamp=500.0
    DeathHipAngSpring=10000.0
    DeathHipAngDamp=500.0

    RagdollLifespan=300 //@Wail - This should be set to the Game's duration value.

    CamOffset=(X=4.0,Y=16.0,Z=-13.0)


    //TODO
    //  MeleeRange=+20.0
    //bMuffledHearing=true

    //Buoyancy=+000.99000000
    //UnderWaterTime=+00020.000000
    //bCanStrafe=True
    //bCanSwim=true
    RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
    //MaxLeanRoll=2048
    bCanCrouch=true
    bCanClimbLadders=True
    bCanPickupInventory=True
    //SightRadius=+12000.0


    //TransInEffects(0)=class'UTEmit_TransLocateOutRed'
    //TransInEffects(1)=class'UTEmit_TransLocateOut'

    MaxStepHeight=26.0
    MaxJumpHeight=49.0
    //MaxDoubleJumpHeight=87.0
    //DoubleJumpEyeHeight=43.0

    //HeadRadius=+9.0
    //HeadHeight=5.0
    //HeadScale=+1.0
    //HeadOffset=32

    //SpawnProtectionColor=(R=40,G=40)
    //TranslocateColor[0]=(R=20)
    //TranslocateColor[1]=(B=20)
    //DamageParameterName=DamageOverlay
    //SaturationParameterName=Char_DistSatRangeMultiplier

    TeamBeaconMaxDist=3000.f
    TeamBeaconPlayerInfoMaxDist=3000.f

    bPhysRigidBodyOutOfWorldCheck=TRUE
    bRunPhysicsWithNoController=true

    ControllerClass=class'AIController'

    CurrentCameraScale=1.0
    CameraScale=9.0
    CameraScaleMin=3.0
    CameraScaleMax=40.0

    LeftFootControlName=LeftFootControl
    RightFootControlName=RightFootControl
    bEnableFootPlacement=true
    MaxFootPlacementDistSquared=56250000.0 // 7500 squared

    SlopeBoostFriction=0.2
    //bStopOnDoubleLanding=true
    //DoubleJumpThreshold=160.0
    FireRateMultiplier=1.0

    //ArmorHitSound=SoundCue'A_Gameplay.Gameplay.A_Gameplay_ArmorHitCue'
    //SpawnSound=SoundCue'A_Gameplay.A_Gameplay_PlayerSpawn01Cue'
    //TeleportSound=SoundCue'A_Weapon_Translocator.Translocator.A_Weapon_Translocator_Teleport_Cue'

    MaxFallSpeed=850.0
    //AIMaxFallSpeedFactor=1.1 // so bots will accept a little falling damage for shorter routes
    LastPainSound=-1000.0

    //FeignDeathBodyAtRestSpeed=12.0
    bReplicateRigidBodyLocation=true

    //MinHoverboardInterval=0.7
    //HoverboardClass=class'UTVehicle_Hoverboard'

    //FeignDeathPhysicsBlendOutSpeed=2.0
    //TakeHitPhysicsBlendOutSpeed=0.5

    TorsoBoneName=b_Spine2
    //FallImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_BodyFall_Cue'
    //FallSpeedThreshold=125.0

    //SuperHealthMax=199

    //// moving here for now until we can fix up the code to have it pass in the armor object
    //ShieldBeltMaterialInstance=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Overlay'
    //ShieldBeltTeamMaterialInstances(0)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Red'
    //ShieldBeltTeamMaterialInstances(1)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Blue'
    //ShieldBeltTeamMaterialInstances(2)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Red'
    //ShieldBeltTeamMaterialInstances(3)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Blue'

    HeroCameraPitch=6000
    HeroCameraScale=6.0

    ////@TEXTURECHANGEFIXME - Needs actual UV's for the Player Icon
    //IconCoords=(U=657,V=129,UL=68,VL=58)
    //MapSize=1.0

    WeaponState=EWS_None

    //// default bone names
    WeaponSocket=WeaponPoint
    WeaponSocket2=DualWeaponPoint
    HeadBone=b_Head
    PawnEffectSockets[0]=L_JB
    PawnEffectSockets[1]=R_JB


    MinTimeBetweenEmotes=1.0


    //TransCameraAnim[0]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN_Red'
    //TransCameraAnim[1]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN_Blue'
    //TransCameraAnim[2]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN'

    //MaxFootstepDistSq=9000000.0
    //MaxJumpSoundDistSq=16000000.0

    //SwimmingZOffset=-30.0
    //SwimmingZOffsetSpeed=45.0

    //TauntNames(0)=TauntA
    //TauntNames(1)=TauntB
    //TauntNames(2)=TauntC
    //TauntNames(3)=TauntD
    //TauntNames(4)=TauntE
    //TauntNames(5)=TauntF

    Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformFall
        Samples(0)=(LeftAmplitude=50,RightAmplitude=40,LeftFunction=WF_Sin90to180,RightFunction=WF_Sin90to180,Duration=0.200)
    End Object
    FallingDamageWaveForm=ForceFeedbackWaveformFall

    blnInAir=false;

    BloodImpacts[0]=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Player_Blood_Spurt_directional'
    BloodImpacts[1]=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Player_Blood_Spurt_directional2'
    BloodImpacts[2]=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Player_Blood_Spurt2'

    LastBoneDebug=0.0f
    ServerBonesPersist=false
    DebugBoneUpdateRate=1.0f

    MaxYawAim=0 //KOLBY THIS MIGHT BE IMPORTANT FOR THE AIMING FIX.

    //Flashlight
    bIsFlashlightOn = false
    bHasFlashlight = true

    bAlwaysRelevant=true

    // DC Aux Properties
    DC_ShakeValues = (X=4, Y=4, Z=4)
}
