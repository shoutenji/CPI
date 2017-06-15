class CPWeapon extends UDKWeapon
    dependson(CPPlayerController)           // ~Drakk : just assumed the dependency, if not required then this should be removed
    abstract;

var name lastState;
enum TAFireAmmunitionMode
{
    FA_Normal,
    FA_QuickRepeater,
};

/** offset for dropped pickup mesh */
var float DroppedPickupOffsetZ;
var bool blnWeaponLogging;

var TAFireAmmunitionMode CurrentFireAmmoMode;
var array<CPWeaponFireMode> FireStates;
var byte DefaultFireState;
var byte CurrentFireState;
var byte PendingFireState;
var bool bJustSwitchedFireMode;

//TOP PROTO MERGE START
/** Percent (from right edge) of screen space taken by weapon on x axis. */
var float WeaponCanvasXPct;

/** Percent (from bottom edge) of screen space taken by weapon on y axis. */
var float WeaponCanvasYPct;

/** Distance from target collision box to accept near miss when aiming help is enabled */
var float AimingHelpRadius[2];

/** Set for ProcessInstantHit based on whether aiminghelp was used for this shot */
var bool bUsingAimingHelp;

/** If true, this will will never accept a forwarded pending fire */
var bool bNeverForwardPendingFire;

/** Whether bots should consider this a spray/fast firing weapon */
var     bool    bFastRepeater;

const CROSSHAIR_HIT_FADE_TIMESCALE = 8.0; // Timescale for crosshair hit indicator fading. The bigger it is, the faster it disappears. default 8.0

/** Used to decide whether to red color crosshair */
var float LastHitEnemyTime;
/** The weapon/inventory set, 0-9. */
var byte InventoryGroup;
/** Max ammo count */
var const int MaxAmmoCount;

var config UIRoot.TextureCoordinates CustomCrosshairCoordinates;
var UIRoot.TextureCoordinates CrossHairCoordinates;
var UIRoot.TextureCoordinates SimpleCrossHairCoordinates;

/** Holds the amount of ammo used for a given shot */
var array<int> ShotCost;

var(Animations) AnimSet ArmsAnimSet;
var(Animations) bool bUsesOffhand;
var(Animations) array<name> WeaponIdleAnims;
var(Animations) array<name> ArmIdleAnims;

/** whether to allow this weapon to fire by uncontrolled pawns */
var bool bAllowFiringWithoutController;

/*********************************************************************************************
 * Hint strings
 ********************************************************************************************* */
var localized string UseHintString;

/** Animation to play when the weapon is fired */
var(Animations) array<name> WeaponFireAnim;
var(Animations) array<name> ArmFireAnim;
var(Animations) name    ArmsPutDownAnim;
var(Animations) name    ArmsEquipAnim;


var bool bSuppressSounds;

/** UTWeapon looks to set the color via a color parameter in the emitter */
var color                   MuzzleFlashColor;


/** The final inventory weight.  It's calculated in PostBeginPlay() */
var float InventoryWeight;

/** position within inventory group. (used by prevweapon and nextweapon) */
var float GroupWeight;

/** If true, will be un-hidden on the next setPosition call. */
var bool bPendingShow;

/** Animation to play when the weapon is Equipped */
var(Animations) name    WeaponEquipAnim;
var(Animations) name    WeaponPutDownAnim;

/** The class of the attachment to spawn */
var class<CPWeaponAttachment>   AttachmentClass; //IMPORTANT NOTE CHANGED FROM UTWEAPONATTACHMENT

var config bool bUseCustomCoordinates;

/** Sound to play when the weapon is Put Down */
var(Sounds) SoundCue    WeaponPutDownSnd;
/** Sound to play when the weapon is Equipped */
var(Sounds) SoundCue    WeaponEquipSnd;
/** Sound to play when the weapon is Thrown */
var(Sounds) SoundCue    WeaponThrowSnd;


var bool bForceHidden;

/** special offset when using hidden weapons, as we need to still place the weapon for e.g. attached beams */
var vector HiddenWeaponsOffset;

/** additional offset applied when using small weapons */
var(FirstPerson) vector SmallWeaponsOffset;
/** Offset from view center */
var(FirstPerson) vector PlayerViewOffset;
/** additional offset applied when using small weapons */
var(FirstPerson) float WideScreenOffsetScaling;

/** How much to damp view bob */
var() float BobDamping;
/** How much to damp jump and land bob */
var() float JumpDamping;

/** Last Rotation update for this weapon */
var     Rotator LastRotation;
/** Limit for yaw lead */
var     float MaxYawLag;
/** Limit for pitch lead */
var     float MaxPitchLag;
/** Last Rotation update time for this weapon */
var     float LastRotUpdate;
var     float LastSpectatorBobUpdate;
/** rotational offset only applied when in widescreen */
var rotator WidescreenRotationOffset;

/** Sound to play when the weapon is fired */
var(Sounds) array<SoundCue> WeaponFireSnd;

/** camera anim to play when firing (for camera shakes) */
var array<CameraAnim> FireCameraAnim;

/** controller rumble to play when firing. */
var ForceFeedbackWaveform WeaponFireWaveForm;

/** If true, always show the muzzle flash even when the weapon is hidden. */
var bool                    bShowAltMuzzlePSCWhenWeaponHidden;

/** Normal Fire and Alt Fire Templates */
var ParticleSystem          MuzzleFlashPSCTemplate, MuzzleFlashAltPSCTemplate;
var ParticleSystem          ShellCasingPSCTemplate, ShellCasingAltPSCTemplate;
var bool                    bShellUseAnimNotify;

/** Whether muzzleflash has been initialized */
var bool                    bMuzzleFlashAttached;
var bool                    bShellCasingAttached;

/** Muzzle flash PSC and Templates*/
var UDKParticleSystemComponent  MuzzleFlashPSC;
var UDKParticleSystemComponent  ShellCasingPSC;
/** Set this to true if you want the flash to loop (for a rapid fire weapon like a minigun) */
var bool                    bMuzzleFlashPSCLoops;
//var bool                  bShellCasingPSCLoops;

/** How long the Muzzle Flash should be there */
var() float                 MuzzleFlashDuration;
var() float                 ShellCasingDuration;
var array<name> EffectSockets;

/** dynamic light */
var UDKExplosionLight       MuzzleFlashLight;

/** dynamic light class */
var class<UDKExplosionLight> MuzzleFlashLightClass;

/** Holds the name of the socket to attach a muzzle flash too */
var name                    MuzzleFlashSocket;
var name                    ShellCasingSocket;
/** How far weapon was leading last tick */
var float OldLeadMag[2];

/** rotation magnitude last tick */
var int OldRotDiff[2];

/** max lead amount last tick */
var float OldMaxDiff[2];

/** Scaling faster for leading speed */
var float RotChgSpeed;

/** Scaling faster for returning speed */
var float ReturnChgSpeed;

/** Adjust pivot of rotating pickup */
var vector  PivotTranslation;

/** Most recently calculated rating */
var     float   CurrentRating;

/** ammo management/reloading */
var int ClipCount;                          // [rep/ndef/gpd] Number of clips for the weapon
var repnotify int AmmoCount;
var int MaxClipCount;                   // [def/req] Max number of clips for the weapon
var float ReloadRefillTimePct;      // [def/req] In precentage of time when the weapon should be treated as refilled
var bool bForceReloadWhenEmpty;     // [def] when true the weapon is auto reloaded when the clip is empty ( this ignores user setup for auto reload )
var bool bForceSwitchWhenEmpty;     // [def] when true a weapon switch is issued when the weapon is empty
var SoundCue ClipPickupSound;           // [def] sound to play when the player pickups clips for this weapon
var bool bIssuedReload;                     // [ndef/gpd] true if the weapon is requested a reload ( from active state )
//var int LastAmmoCount;                        // [ndef/gpd] last ammo count in clip before the reload
var int LastClipCount;                      // [ndef/gpd] last clip count in the weapon before reload
//var bool bReloadEarlyNotify;              // [ndef/gpd] true when the GetAmmoCount should return the refilled amount no the last

var bool bAmmoStringNullOnEmpty;

var float ReloadTime;
var float ReloadEmptyTime;
var SoundCue WeaponReloadSnd;
var SoundCue WeaponReloadEmptySnd;

var int IdleIndex;

/** weapon properties  IMPORTANT NOTE THIS ENUM MUST BE IDENTICAL TO THE ONE IN CPGFXTEAMHUD*/
enum EWeaponType
{
    WT_KNIFE,
    WT_PISTOL,
    WT_SHOTGUN,
    WT_SMG,
    WT_RIFLE,
    WT_GRENADE,
    WT_BOMB,
    WT_TEST
};

var const EWeaponType WeaponType;
var localized string WeaponTypeString[7];
var bool bJustDropped;                      // [ndef/gpd] set when the weapon is just dropped, this helps the InvManager to ignore this item during the weapon switch
var bool bDestroyWhenEmpty;                 // [def] when true the weapon is destroyed after the player put it down ( grenade type weapons )
var bool bEmptyDestroyRequest;              // [ndef/gpd] indicatedes that the bDestroyWhenEmpty requested remove from inventory so autoswitch is not needed.
var bool bNoWeaponCrosshair;                // [def] indcates that the weapon doesnt need a crosshair ( knives for example )

/** laser dot properties */
var bool bUsesLaserDot;                     // [def] indicates that this weapon uses the laser dot feature
var bool bLaserDotStatus;                   // [ndef/gpd] current laser dot status

/** effects */
var float MuzzleFlashFOVOverride;

/** Crosshair Coloring */
var const color BlackColor, LightGreenColor, RedColor;

/** Animation */
var array<name> WeaponAltFireAnim;
var array<name> ArmAltFireAnim;

var name WeaponReloadAnim;
var name ArmsReloadAnim;

var name WeaponReloadEmptyAnim;
var name ArmsReloadEmptyAnim;
var AnimNodeBlend WeaponEmptyAnimBlend;
var UDKSkelControl_Rotate FireModeSelector;


/** C4 specific animations */
var name WeaponDiffuseAnim;
var float WeaponDiffuseTime;

var name WeaponEmptyFireAnim;
var name ArmsEmptyFireAnim;
var SoundCue WeaponEmptySnd;
var float FireWeaponEmptyTime;

var array<float> FireModeSwitchTime;
var array<name> WeaponFireModeSwitchAnim;
var array<name> ArmsFireModeSwitchAnim;
var SoundCue FireModeSwitchSnd;

var float LastSpreadRandY;
var float LastSpreadRandZ;
var float RepeaterSpreadScaling;

/** DEV variables */
var float MuzzleFlashScale;
var int DEVTuneValue;

/** custom for idle animations */
var float IdleTimeDialation;
var Vector CachedLocationForIdleCheck;
var Rotator CachedRotationForIdleCheck;

var bool bEquippingWeapon, bPuttingDownWeapon;

var float WeaponEffectiveRange;

var string strAnimationDebugMessages;

/** used for the hud weapon bar */
var string WeaponFlashName;


/** BuyMenu Values*/
var localized string MenuItemName, MenuEffectiveRange, MenuRoundsPerMinute, MenuClipsOfMaxClips;
/** buy menu stuff*/
var int WeaponPrice, ClipPrice;

//var name WeaponProfileName;

//Weapon Components to avoid auto fire on reload.
var bool bWeaponCanFireOnReload, bReloadFireToggle;

var bool bShowMuzzleFlashWhenFiring;

replication
{
    if (bNetDirty)
        AmmoCount, bWeaponCanFireOnReload, bReloadFireToggle, ClipCount, bLaserDotStatus, CurrentFireState;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName=='HitEnemy')
    {
        LastHitEnemyTime=WorldInfo.TimeSeconds;
        if (Instigator!=none && CPPlayerController(Instigator.Controller)!=none)
            CPPlayerController(Instigator.Controller).OnWeaponHitEnemy();
    }
    else
        Super.ReplicatedEvent(VarName);
}

/**
 * Reset the weapon to a neutral state
 */
simulated function Reset()
{
    StopFire( CurrentFireMode );
    //`log( self @ "has reset" );
}



// simulated function StopFire(byte FireModeNum)
// {
	// EndFire(FireModeNum);

	// if( Role < Role_Authority )
	// {
		// ServerStopFire(FireModeNum);
	// }
// }


/**
 * Gets the 'WeaponState' of the Instigator.
 * @return WeaponState of the Instigator, Returns EWS_EmptyState if the Instigator is invalid.
 */
simulated function EWeaponState GetInstigatorWeaponState()
{
    local CPPawn        _Pawn;


    _Pawn = CPPawn( Instigator );
    return _Pawn != none ? _Pawn.WeaponState : EWS_EmptyState;
}

/**
 * Sets the 'WeaponState' of the Instigator.
 */
simulated function SetInstigatorWeaponState( EWeaponState State )
{
    local CPPawn        _Pawn;

	if(blnWeaponLogging)
		`Log("SetInstigatorWeaponState TO " @ State);
    if(WorldInfo.NetMode != NM_Client)
    {
        _Pawn = CPPawn( Instigator );
        if ( _Pawn != none )
            _Pawn.SetWeaponState( State );
    }
}


/**
 * Denies a weapon pickup query if the given
 * weapon is of the same inventory group.
 */
function bool DenyPickupQuery( class<Inventory> ItemClass, Actor Pickup )
{
    local CPDroppedPickup   _Pickup;
    local CPWeapon          _Weapon;


    _Pickup = CPDroppedPickup( Pickup );
    if ( _Pickup != none )
    {
        _Weapon = CPWeapon( _Pickup.Inventory );
        if ( _Weapon != none && _Weapon.InventoryGroup == InventoryGroup )
            return true;
    }

    return super.DenyPickupQuery( ItemClass, Pickup );
}

//MERGED BELOW
//simulated function PostBeginPlay()
//{
//local LinearColor LinColor;
//  InventoryGroup=int(WeaponType);
//  Super.PostBeginPlay();
//TOP PROTO MERGE
//  AmmoCount=MaxAmmoCount;
//  ClipCount=0;
//  if (FireStates.Length==0)
//      `warn("weapon "$self$" have no fire state");
//  else
//  {
//      if (DefaultFireState<FireStates.Length)
//          SetFireState(DefaultFireState);
//      else
//          SetFireState(0);
//  }
//  SetFireAmmunitionBehavior(FA_Normal);
//}

//TOP-Proto moved to merged section
///** coloring */
//simulated function SetSkin(Material NewMaterial)
//{
//  Super.SetSkin(NewMaterial);
//  if (NewMaterial==none && Mesh!=none)
//      Mesh.SetMaterial(0,WeaponMaterialInstance);
//}
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    Super.PostInitAnimTree(SkelComp);
    WeaponEmptyAnimBlend=AnimNodeBlend(SkelComp.FindAnimNode('BlendToEmpty'));
    if (WeaponEmptyAnimBlend!=none)
        WeaponEmptyAnimBlend.SetBlendTarget(0.0,0.0);

    FireModeSelector=UDKSkelControl_Rotate(SkelComp.FindSkelControl('ROF'));

    if(FireModeSelector != none)
        FireModeSelector.SetSkelControlActive(false);
}

/// degrees to use.
/// ebonecontrolspace to use. bcs_bonespace is forward and bcs_otherbonespace is backwards
simulated function SetFireModeSelectorSwitch(int Degrees)
{
    if(FireModeSelector != none)
    {
        FireModeSelector.BoneRotation.Pitch = DegToUnrRot * Degrees;
        FireModeSelector.BoneRotationSpace = BCS_BoneSpace;
        FireModeSelector.SetSkelControlActive(true);
    }
}

/** Debug / Log */
simulated function DisplayDebug(HUD HUD,out float out_YL,out float out_YPos)
{
local Array<String> DebugInfo;
local int i;

    super.DisplayDebug(HUD,out_YL,out_YPos);

    if (CPPawn(Instigator) != None)
    {
        HUD.Canvas.DrawText("Eyeheight "$Instigator.EyeHeight$" base "$Instigator.BaseEyeheight$" landbob "$CPPawn(Instigator).Landbob$" just landed "$CPPawn(Instigator).bJustLanded$" land recover "$CPPawn(Instigator).bLandRecovery, false);
        out_YPos += out_YL;
    }

    HUD.Canvas.SetPos(4,out_YPos);
    out_YPos+= out_YL;

    GetCPWeaponDebug(DebugInfo);
    Hud.Canvas.SetDrawColor(25,255,75);
    for (i=0;i<DebugInfo.Length;i++)
    {
        Hud.Canvas.DrawText("  "@DebugInfo[i]);
        out_YPos+=out_YL;
        Hud.Canvas.SetPos(4,out_YPos);
    }
}

simulated function GetCPWeaponDebug(out Array<String> DebugInfo)
{
local int i;
local int linePos;

    for (i=0;i<FireStates.Length;i++)
    {
        linePos=DebugInfo.Length;
        DebugInfo[linePos]="Fire Mode : "$FireStates[i].ModeName$" ("$FireStates[i]$")";
        if (CurrentFireState==i)
            DebugInfo[linePos]$=" (ACTIVE)";
        if (DefaultFireState==i)
            DebugInfo[linePos]$=" (DEFAULT)";
    }
    DebugInfo[DebugInfo.Length]="Inventory Group ["$InventoryGroup$"] "$IntWeaponTypeToString(int(WeaponType));
    DebugInfo[DebugInfo.Length]="Ammo - In Weapon ["$AmmoCount$"/"$MaxAmmoCount$"] - Clips ["$ClipCount$"] - Pending Reload : "$PendingReload()$" - Pending Fire Mode Switch : "$PendingFireModeSwitch();
    if (CPPawn(Instigator)!=none)
        if (CPPawn(Instigator).CurrentWeaponAttachment!=none)
            DebugInfo[DebugInfo.Length]="Attachment: "$GetItemName(string(CPPawn(Instigator).CurrentWeaponAttachment))$" State: "$CPPawn(Instigator).CurrentWeaponAttachment.GetStateName();
    DebugInfo[DebugInfo.Length]="Laser Status: "$CPPawn(owner).bLaserDotStatus$" Laser Dot Actor: "$CPPawn(owner).LaserDotActor;
    DebugInfo[DebugInfo.Length]="Pending Fire Release: "$IsPendingFireRelease();
}
/** Debug / Log */

simulated function string GetShotMode()
{
    if (FireStates[CurrentFireState]!=none)
        return FireStates[CurrentFireState].ModeName;
    return "Not Set";
}

static function string IntWeaponTypeToString(int wType)
{
    if (wType>7 || wType<0)
        return "";
    return default.WeaponTypeString[wType];
}

simulated function bool CanThrow()
{
    return bCanThrow;
}

simulated function SetFireState(byte newState)
{
    if (newState<FireStates.Length && FireStates[newState]!=none)
        CurrentFireState=newState;
    else
        CurrentFireState=0;
	bForceNetUpdate=true;
}

simulated function bool DenyWeaponFunctionality()
{
    local CPBotPawn     _BotPawn;
    local CPPawn        _Pawn;


    if ( FireStates.Length == 0 )
        return true;

    _Pawn = CPPawn( Instigator );
    if( _Pawn != none && _Pawn.Health > 0 && _Pawn.bIsUsingObjective )
        return true;

    // WHY IS THIS HERE?
    // - Kolby
    _BotPawn = CPBotPawn( Instigator );
    if( _BotPawn != none && Instigator.Health > 0 )
        return true;

    return false;
}

simulated function float GetFireInterval(byte FireModeNum)
{
    if (FireModeNum>=2 || FireStates[CurrentFireState]==none)
        return 1.0;
    return FireStates[CurrentFireState].FireInterval[FireModeNum]*((CPPawn(Owner)!=none) ? CPPawn(Owner).FireRateMultiplier : 1.0);
}

/**
 * Draws a curved portion of a crosshair
 */
simulated function DrawCrosshairCurve( Canvas Canvas, color DrawColor, optional float Start=0.0f, optional float End=Pi*2.0f, optional float Stepping=DegToRad )
{
    local Vector        _Start, _P1, _P2;
    local float         _Angle, _X1, _Y1, _X2, _Y2;


    _Start = Instigator.GetPawnViewLocation();
    for ( _Angle = Start; _Angle <= End - Stepping; _Angle += Stepping )
    {
        _X1 = Cos( _Angle );
        _Y1 = Sin( _Angle );
        _X2 = Cos( _Angle + Stepping );
        _Y2 = Sin( _Angle + Stepping );

        _P1 = Canvas.Project( _Start + vector( AddSpreadDebug( GetAdjustedAim( _Start ), _X1, _Y1 ) ) * 65536.0f );
        _P2 = Canvas.Project( _Start + vector( AddSpreadDebug( GetAdjustedAim( _Start ), _X2, _Y2 ) ) * 65536.0f );

        Canvas.Draw2DLine( _P1.X, _P1.Y, _P2.X, _P2.Y, DrawColor );
    }
}

/**
 * Draws a crosshair with an accurate representation of our spread
 */
simulated function DrawCrosshair( HUD Hud )
{
    local Vector        _Start, _P1/*, _P2*/;
    local Canvas        _Canvas;
    local float         _X, _Y, _S;/*
    local float         _Angle, _X1, _Y1, _X2, _Y2;*/


    _Canvas = Hud.Canvas;
    if ( Instigator == none || _Canvas == none)
        return;

    _Start = Instigator.GetPawnViewLocation();
    // Draw a circle
    DrawCrosshairCurve( _Canvas, MakeColor( 255, 0, 255, 96 ), -030.0f*DegToRad, +030.0f*DegToRad, DegToRad*30.0f );
    DrawCrosshairCurve( _Canvas, MakeColor( 255, 0, 255, 96 ), +060.0f*DegToRad, +120.0f*DegToRad, DegToRad*30.0f );
    DrawCrosshairCurve( _Canvas, MakeColor( 255, 0, 255, 96 ), +150.0f*DegToRad, +210.0f*DegToRad, DegToRad*30.0f );
    DrawCrosshairCurve( _Canvas, MakeColor( 255, 0, 255, 96 ), +240.0f*DegToRad, +300.0f*DegToRad, DegToRad*30.0f );

    _Canvas.SetDrawColor( 255, 0, 255, 255 );

    _P1 = _Canvas.Project( _Start + vector( AddSpreadDebug( GetAdjustedAim( _Start ), +0.0f, +1.0f ) ) * 65536.0f ) ;
    _X = float( _Canvas.SizeX ) * 0.5f;
    _Y = float( _Canvas.SizeY ) * 0.5f;
    _S = Round( FMax( Abs( _Y - _P1.Y ), 4.0f ) );

    // Top
    _Canvas.SetPos( _X - 1.0f, _Y - _S - 6.0f, 1.0f );
    _Canvas.DrawBox( 2.0f, 6.0f );
    // Left
    _Canvas.SetPos( _X - _S - 6.0f, _Y - 1.0f, 1.0f );
    _Canvas.DrawBox( 6.0f, 2.0f );
    // Right
    _Canvas.SetPos( _X + _S - 0.0f, _Y - 1.0f, 1.0f );
    _Canvas.DrawBox( 6.0f, 2.0f );
    // Bottom
    _Canvas.SetPos( _X - 1.0f, _Y + _S + 0.0f, 1.0f );
    _Canvas.DrawBox( 2.0f, 6.0f );
}

/** crosshair */
simulated function ActiveRenderOverlays(HUD H)
{
    local CPPlayerController PC;

    if(Instigator != none)
    {
        if(Instigator.Controller != none)
        {
            PC=CPPlayerController(Instigator.Controller);
        }
        else
        {   //spectators
            PC= CPPlayercontroller(CPPawn( Instigator ).GetALocalPlayerController());
        }
    }

    if (PC!=none && !PC.bNoCrosshair && !bNoWeaponCrosshair && (!bUsesLaserDot || (bUsesLaserDot && !GetLaserDotStatus())))
    {
        if(PC.PredefinedCrosshairIdx > -1)
        {
            CrossHairCoordinates = PC.bSimpleCrosshair ? SimpleCrosshairCoordinates : default.CrosshairCoordinates;
            CrossHairCoordinates = SimpleCrosshairCoordinates;
            DrawWeaponCrosshair(H);
        }
        else
        {
            DrawCrosshair( H );
        }
    }

    if(Instigator != none)
    {
    if (CPPlayerController(Instigator.Controller)!=none && CPPlayerController(Instigator.Controller).bDEVWeaponTuneMode)
        {
        DrawTuneMenu(H.Canvas);
}
    }
}

/**
 * Compute the approximate Screen distance from the camera to whatever is at the center of the viewport.
 * Useful for stereoizing the crosshair to reduce eyestrain.
 * NOTE: The dotproduct at the end is currently unnecessary, but if you were to use a different value for
 * TargetLoc that was not at center of screen, it'd become necessary to do the way screen projection works.
 */
simulated function float GetTargetDistance( )
{
    local float VeryFar;
    local vector HitLocation, HitNormal, ProjStart, TargetLoc, X, Y, Z;
    local rotator CameraRot;
    local PlayerController PC;

    if(Instigator.Controller != none)
    {
        PC=CPPlayerController(Instigator.Controller);
    }
    else
    {//spectators
        PC= CPPlayercontroller(CPPawn( Instigator ).GetALocalPlayerController());
    }

    VeryFar = 32768;

    PC.GetPlayerViewPoint(ProjStart, CameraRot);
    GetAxes(CameraRot, X, Y, Z);

    TargetLoc = ProjStart + X * VeryFar;

    if (None == GetTraceOwner().Trace(HitLocation, HitNormal, TargetLoc, ProjStart, true,,, TRACEFLAG_Bullet))
    {
        return VeryFar;
    }

    return (HitLocation - ProjStart) Dot X;
}
simulated function DEVTuneModeControl(int controlID)
{
    if (controlID==0)
    {
        if ((DEVTuneValue-1)<0)
            DEVTuneValue=0;
        else
            DEVTuneValue--;
    }
    else if (controlID==1)
    {
        if ((DEVTuneValue+1)>17)
            DEVTuneValue=17;
        else
            DEVTuneValue++;
    }
    else if (controlID==2)
        DEVTuneModeChangeValue(-1);
    else if (controlID==3)
        DEVTuneModeChangeValue(1);
}

simulated function DEVTuneModeChangeValue(int ctrlID)
{
    if (DEVTuneValue==0)
        EquipTime+=(0.1*ctrlID);
    else if (DEVTuneValue==1)
        PutDownTime+=(0.1*ctrlID);
    else if (DEVTuneValue==2)
        ReloadTime+=(0.1*ctrlID);
    else if (DEVTuneValue==3)
        ReloadEmptyTime+=(0.1*ctrlID);
    else if (DEVTuneValue==4)
        FireWeaponEmptyTime+=(0.01*ctrlID);
    else if (DEVTuneValue==5)
        FireModeSwitchTime[PendingFireState]+=(0.01*ctrlID);
    else if (DEVTuneValue==6)
        FireStates[CurrentFireState].FireInterval[0]+=(0.01*ctrlID);
    else if (DEVTuneValue==7)
    {
        if (FireStates[CurrentFireState].bRepeater[0]==0)
            FireStates[CurrentFireState].bRepeater[0]=1;
        else
            FireStates[CurrentFireState].bRepeater[0]=0;
    }
    else if (DEVTuneValue==8)
        Spread[CurrentFireState]+=(0.005*ctrlID);
    else if (DEVTuneValue==9)
        FireStates[CurrentFireState].MinFireRecoil[0].X+=(0.005*ctrlID);
    else if (DEVTuneValue==10)
        FireStates[CurrentFireState].MinFireRecoil[0].Y+=(0.005*ctrlID);
    else if (DEVTuneValue==11)
        FireStates[CurrentFireState].MaxFireRecoil[0].X+=(0.005*ctrlID);
    else if (DEVTuneValue==12)
        FireStates[CurrentFireState].MaxFireRecoil[0].Y+=(0.005*ctrlID);
    else if (DEVTuneValue==13)
        FireStates[CurrentFireState].MinHitDamage[0]+=(1*ctrlID);
    else if (DEVTuneValue==14)
        FireStates[CurrentFireState].MaxHitDamage[0]+=(1*ctrlID);
    else if (DEVTuneValue==15)
        FireStates[CurrentFireState].HitMomentum[0]+=(1000*ctrlID);
    else if (DEVTuneValue==16)
        WeaponEffectiveRange +=(52.5*ctrlID);
}

simulated exec function DEVSetWeaponRange ( float fWeaponRange )
{
    DEVServerSetWeaponRange( fWeaponRange );
}

reliable server function DEVServerSetWeaponRange( float fWeaponRange )
{
    WeaponEffectiveRange = fWeaponRange;
    `log( "Changed WeaponRange to" @ fWeaponRange);
}


simulated exec function DEVAddMinSpread( float addSpread )
{
    DEVServerAddMinSpread( addSpread );
}

simulated exec function DEVAddMaxSpread( float addSpread )
{
    DEVServerAddMaxSpread( addSpread );
}

simulated exec function DEVAddMinRecoilX( float addRecoil )
{
    DEVServerAddMinRecoilX( addRecoil );
}

simulated exec function DEVAddMinRecoilY( float addRecoil )
{
    DEVServerAddMinRecoilY( addRecoil );
}

simulated exec function DEVAddMaxRecoilX( float addRecoil )
{
    DEVServerAddMaxRecoilX( addRecoil );
}

simulated exec function DEVAddMaxRecoilY( float addRecoil )
{
    DEVServerAddMaxRecoilY( addRecoil );
}

reliable server function DEVServerAddMinRecoilX( float addRecoil )
{
    FireStates[CurrentFireState].MinFireRecoil[0].X += addRecoil;
    `log( "Changed min X recoil of" @ self @ "to" @
        FireStates[CurrentFireState].MinFireRecoil[0].X );
}

reliable server function DEVServerAddMinRecoilY( float addRecoil )
{
    FireStates[CurrentFireState].MinFireRecoil[0].Y += addRecoil;
    `log( "Changed min Y recoil of" @ self @ "to" @
        FireStates[CurrentFireState].MinFireRecoil[0].Y );
}

reliable server function DEVServerAddMaxRecoilX( float addRecoil )
{
    FireStates[CurrentFireState].MaxFireRecoil[0].X += addRecoil;
    `log( "Changed max X recoil of" @ self @ "to" @
        FireStates[CurrentFireState].MaxFireRecoil[0].X );
}

reliable server function DEVServerAddMaxRecoilY( float addRecoil )
{
    FireStates[CurrentFireState].MaxFireRecoil[0].Y += addRecoil;
    `log( "Changed max Y recoil of" @ self @ "to" @
        FireStates[CurrentFireState].MaxFireRecoil[0].Y );
}

reliable server function DEVServerAddMinSpread( float addSpread )
{
    Spread[0] += addSpread;
    `log( "Changed min spread of" @ self @ "to" @ Spread[0] );
}

reliable server function DEVServerAddMaxSpread( float addSpread )
{
    Spread[1] += addSpread;
    `log( "Changed max spread of" @ self @ "to" @ Spread[1] );
}

simulated function DrawTuneMenu(Canvas Canvas)
{
local float XL,YL,YPos;
local array<string> tmpTextList;
local int i;

    if (Canvas==none)
        return;
    Canvas.Font=class'Engine'.Static.GetTinyFont();
    Canvas.DrawColor=class'HUD'.default.ConsoleColor;
    Canvas.StrLen("X",XL,YL);
    YPos=4*YL;

    Canvas.SetDrawColor(0,255,0);

    Canvas.SetPos(8,YPos);
    Canvas.DrawText("Weapon "$self$" with "$FireStates.Length$" fire modes");
    YPos+=YL;

    Canvas.SetDrawColor(100,255,50);

    Canvas.SetPos(8,YPos);
    Canvas.DrawText("== generic timings ==");
    YPos+=YL;

    tmpTextList[tmpTextList.Length]="  Equip "$EquipTime;
    tmpTextList[tmpTextList.Length]="  Put Down "$PutDownTime;
    tmpTextList[tmpTextList.Length]="  Reload "$ReloadTime;
    tmpTextList[tmpTextList.Length]="  Reload Empty "$ReloadEmptyTime;
    tmpTextList[tmpTextList.Length]="  Fire Empty "$FireWeaponEmptyTime;
    tmpTextList[tmpTextList.Length]="  Fire Mode Switch "$FireModeSwitchTime[PendingFireState];

    for (i=0;i<tmpTextList.Length;i++)
    {
        if (DEVTuneValue==i)
            Canvas.SetDrawColor(255,50,50);
        else
            Canvas.SetDrawColor(100,255,50);
        Canvas.SetPos(8,YPos);
        Canvas.DrawText(tmpTextList[i]);
        YPos+=YL;
    }
    tmpTextList.Remove(0,tmpTextList.Length);

	// Show information for grenades if we are holding a grenade instead of the other information
	// which is not pertinent to a grenade.
    if(FireStates[CurrentFireState].FireType[CurrentFireMode] == ETFT_Projectile)
	{           
		tmpTextList[tmpTextList.Length]="  Damage "$ class<CPProjectile>(WeaponProjectiles[0]).Default.Damage;
		tmpTextList[tmpTextList.Length]="  DamageRadius "$class<CPProjectile>(WeaponProjectiles[0]).Default.DamageRadius;
		tmpTextList[tmpTextList.Length]="  MaxEffectiveDistance "$class<CPProjectile>(WeaponProjectiles[0]).Default.MaxEffectDistance;
		tmpTextList[tmpTextList.Length]="  TerminalVelocity "$class<CPProjectile>(WeaponProjectiles[0]).Default.TerminalVelocity;
		tmpTextList[tmpTextList.Length]="  Speed "$class<CPProjectile>(WeaponProjectiles[0]).Default.Speed;
		tmpTextList[tmpTextList.Length]="  MaxSpeed "$class<CPProjectile>(WeaponProjectiles[0]).Default.MaxSpeed;
		tmpTextList[tmpTextList.Length]="  MomentumTransfer "$class<CPProjectile>(WeaponProjectiles[0]).Default.MomentumTransfer;
	}
	else
	{
		tmpTextList[tmpTextList.Length]="  Fire Spread "$Spread[CurrentFireState]@"("@Spread[CurrentFireState]*RadToDeg@"degrees )";
		tmpTextList[tmpTextList.Length]="  Min Fire Recoil X "$FireStates[CurrentFireState].MinFireRecoil[0].X;
		tmpTextList[tmpTextList.Length]="  Min Fire Recoil Y "$FireStates[CurrentFireState].MinFireRecoil[0].Y;
		tmpTextList[tmpTextList.Length]="  Max Fire Recoil X "$FireStates[CurrentFireState].MaxFireRecoil[0].X;
		tmpTextList[tmpTextList.Length]="  Max Fire Recoil Y "$FireStates[CurrentFireState].MaxFireRecoil[0].Y;
		tmpTextList[tmpTextList.Length]="  Min Hit Damage "$FireStates[CurrentFireState].MinHitDamage[0];
		tmpTextList[tmpTextList.Length]="  Max Hit Damage "$FireStates[CurrentFireState].MaxHitDamage[0];
	}

    tmpTextList[tmpTextList.Length]="  Hit Momentum "$FireStates[CurrentFireState].HitMomentum[0];
    tmpTextList[tmpTextList.Length]="  WeaponEffectiveRange "$WeaponEffectiveRange@"("@WeaponEffectiveRange/52.5@"m,"@WeaponEffectiveRange/16@"ft )";

    for (i=0;i<tmpTextList.Length;i++)
    {
        if (DEVTuneValue==5+i && i!=0)
            Canvas.SetDrawColor(255,50,50);
        else
            Canvas.SetDrawColor(100,255,50);
        Canvas.SetPos(8,YPos);
        Canvas.DrawText(tmpTextList[i]);
        YPos+=YL;
    }
    tmpTextList.Remove(0,tmpTextList.Length);

    YPos+=YL;
    Canvas.SetPos(8,YPos);
    Canvas.SetDrawColor(255,0,0);
    Canvas.DrawText(strAnimationDebugMessages);
}

simulated function DrawWeaponCrosshair(Hud HUD)
{
local Vector2D CrosshairSize;
local float crosshairScale;
local float x,y,ScreenX,ScreenY;
local float TargetDist;
local CPHUD H;
local CPPlayerController tapc;
local Texture2D crosshairTex;
local UIRoot.TextureCoordinates crosshairCoords;

    H=CPHUD(HUD);
    if (H==none)
        return;

    tapc=CPPlayerController(H.PlayerOwner);
    if (tapc==none)
        return;
    tapc.GetCrosshairSettings(crosshairTex,crosshairCoords);

    tapc.GetCrosshairSettings(crosshairTex,crosshairCoords);
    if (crosshairTex==none)
        return;
    crosshairScale=tapc.PredefinedCrosshairScale;

    TargetDist=GetTargetDistance();
    CrosshairSize.Y = FClamp((crosshairScale * CrossHairCoordinates.VL * H.Canvas.ClipY / 720), 0, 100);
    CrosshairSize.X = FClamp((CrosshairSize.Y * (CrossHairCoordinates.UL / CrossHairCoordinates.VL)), 0, 100);

    X=H.Canvas.ClipX*0.5;
    Y=H.Canvas.ClipY*0.5;
    ScreenX=X-(CrosshairSize.X*0.5);
    ScreenY=Y-(CrosshairSize.Y*0.5);

    H.Canvas.DrawColor = BlackColor;
    H.Canvas.DrawColor.A = tapc.PredefinedCrosshairColor.A; //fix to alpha the black colour on the crosshair

    H.Canvas.SetPos(ScreenX+1,ScreenY+1,TargetDist);

    H.Canvas.DrawTile(  crosshairTex,
                        CrosshairSize.X,
                        CrosshairSize.Y,
                        crosshairCoords.U,
                        crosshairCoords.V,
                        crosshairCoords.UL,
                        crosshairCoords.VL);

	H.Canvas.DrawColor=tapc.PredefinedCrosshairColor;
    H.Canvas.DrawColor.A = tapc.PredefinedCrosshairColor.A; //fix to alpha the black colour on the crosshair

    H.Canvas.SetPos(ScreenX,ScreenY,TargetDist);
    H.Canvas.DrawTile(  crosshairTex,
                        CrosshairSize.X,
                        CrosshairSize.Y,
                        crosshairCoords.U,
                        crosshairCoords.V,
                        crosshairCoords.UL,
                        crosshairCoords.VL);

	DrawHitIndicator(H, tapc, TargetDist, crosshairCoords, X, Y);                        

}

/**	~Crusha: Draw the indicator that shows that we hit an enemy.
	Opacity of the indicator is based on the time that passed since the hit. */
simulated function DrawHitIndicator(CPHUD H, CPPlayerController tapc, float TargetDist, UIRoot.TextureCoordinates crosshairCoords, float X, float Y)
{
    
	local Vector2D CrosshairSize;
	local float crosshairScale;
	local Texture2D crosshairTex;
	local PredefinedCrosshairImage hit_indicator;
    
    H.Canvas.DrawColor = tapc.PredefinedCrosshairColor;
    H.Canvas.DrawColor.A = 255 - 255*FMin((WorldInfo.TimeSeconds - H.LastHitIndicatorTime)*CROSSHAIR_HIT_FADE_TIMESCALE, 1);
    
    hit_indicator = tapc.PredefinedCrosshairs[8];
	crosshairTex = hit_indicator.Image;
	crosshairCoords.U = hit_indicator.ImageTexCoords.U;
	crosshairCoords.V = hit_indicator.ImageTexCoords.V;
	crosshairCoords.UL = hit_indicator.ImageTexCoords.UL;
	crosshairCoords.VL = hit_indicator.ImageTexCoords.VL;
    crosshairScale = 0.750000;

    CrosshairSize.Y = FClamp((crosshairScale * CrossHairCoordinates.VL * H.Canvas.ClipY / 720), 0, 100);
    CrosshairSize.X = FClamp((CrosshairSize.Y * (CrossHairCoordinates.UL / CrossHairCoordinates.VL)), 0, 100);
    
    H.Canvas.SetPos(X-CrosshairSize.X,Y-CrossHairSize.Y,TargetDist);
    H.Canvas.DrawTile(  crosshairTex,
                        CrosshairSize.X*2,
                        CrosshairSize.Y*2,
                        crosshairCoords.U,
                        crosshairCoords.V,
                        crosshairCoords.UL,
                        crosshairCoords.VL);
}


/** Ammo */
simulated function int GetAmmoCount()
{
    return AmmoCount;
}

simulated function int GetClipCount()
{
    return ClipCount;
}

function int AddAmmo(int Amount)
{
    if (Amount<0)
        AmmoCount=Clamp(AmmoCount+Amount,0,MaxAmmoCount);
    else
    {
        if(WeaponType != WT_Bomb)
        {
            `warn(GetHumanReadableName()$" IGNORED AddAmmo +"$Amount);          // ~Drakk : this is intentional to warn if we ever get to this point
        }
    }
    return AmmoCount;
}

function int AddClip(int Amount)
{
    ClipCount=Clamp(ClipCount+Amount,0,MaxClipCount);
    return ClipCount;
}

// ~Drakk : will be used later on, currently it is the same as the UTWeapon's HasAmmo function
//simulated function bool HasAmmo(byte FireModeNum,optional int Amount)
//{
//  if (Amount==0)
//      return (AmmoCount>=ShotCost[FireModeNum]);
//  return (AmmoCount>=Amount);
//}

simulated function bool HasAnyAmmo()
{
    return ((AmmoCount>0 || ClipCount>0) || (ShotCost[0]==0 && ShotCost[1]==0));
}

simulated function Loaded(optional bool bUseWeaponMax)
{
    AmmoCount=MaxAmmoCount;
    ClipCount=MaxClipCount-1;
}

simulated function WeaponEmpty()
{
    if (IsFiring())
        GotoState('Active');
}

function PlayClipPickup()
{
    if (Instigator==none)
        return;
    WeaponPlaySound(ClipPickupSound,0.4);
}
/** Ammo */

/** Reloading */
simulated function StartReload()
{
    if ((Instigator==none || !Instigator.bNoWeaponFiring) &&
        !DenyWeaponFunctionality() &&
        (IsInState('Active') || IsInState('WeaponFiring') || IsInState('Reloading')))
    {
        if (Role<ROLE_Authority)
            ServerStartReload();
        BeginReload();
    }
}

reliable server function ServerStartReload()
{
    if ((Instigator==none || !Instigator.bNoWeaponFiring) && !DenyWeaponFunctionality())
        BeginReload();
}

simulated function BeginReload()
{
    SetPendingReload();
}

/** Throwing */
simulated function StartThrow()
{
    if ((Instigator==none || !Instigator.bNoWeaponFiring) &&
        !DenyWeaponFunctionality() &&
        (IsInState('Active') || IsInState('WeaponFiring') || IsInState('Reloading')))
    {
        if (Role<ROLE_Authority)
            ServerStartThrowWeapon();
        BeginThrowWeapon();
    }
}
reliable server function ServerStartThrowWeapon()
{
    if ((Instigator==none || !Instigator.bNoWeaponFiring) && !DenyWeaponFunctionality())
    {
    	BeginThrowWeapon();
		CPPlayerController(Instigator.GetALocalPlayerController()).ClearSpectatorWeaponsOrdered();
    }
}

simulated function BeginThrowWeapon()
{
    SetPendingWeaponDrop();
}

simulated function StopReload()
{
    EndReload();
    if (Role<Role_Authority)
        ServerStopReload();
}

reliable server function ServerStopReload()
{
    EndReload();
}

simulated function EndReload()
{
    ClearPendingReload();
}

simulated function EndWeaponDrop()
{
    ClearPendingWeaponDrop();
}

final simulated function bool PendingReload()
{
    if (CPInventoryManager(InvManager)!=none)
        return CPInventoryManager(InvManager).IsPendingReload();
    return false;
}

final simulated function SetPendingReload()
{
    if (CPInventoryManager(InvManager)!=none)
        CPInventoryManager(InvManager).SetPendingReload();
}

final simulated function ClearPendingReload()
{
    if (CPInventoryManager(InvManager)!=none)
        CPInventoryManager(InvManager).ClearPendingReload();
}

final simulated function bool PendingDropWeapon()
{
    if (CPInventoryManager(InvManager)!=none)
        return CPInventoryManager(InvManager).IsPendingDrop();
    return false;
}

final simulated function SetPendingWeaponDrop()
{
    if (CPInventoryManager(InvManager)!=none)
        CPInventoryManager(InvManager).SetPendingDroppingWeapon();
}

final simulated function ClearPendingWeaponDrop()
{
    if (CPInventoryManager(InvManager)!=none)
        CPInventoryManager(InvManager).ClearPendingDroppingWeapon();
}

final simulated function bool NeedsReload()
{
    if (AmmoCount<MaxAmmoCount && ClipCount>0)
        return true;
    return false;
}

final simulated function SendToReloadState()
{
    GotoState('Reloading');
}

simulated function bool IsReloading()
{
    return false;
}

simulated function FinishedReloading()
{
	`Log("WARNING OUT OF SYNC TIMER DETECTED! CPWEAPON.FinishedReloading() - CODE WAS NOT CALLED BECAUSE OF THIS!");
}

simulated function bool ShouldAutoReload()
{
local CPPawn tp;

    tp=CPPawn(Instigator);
    if (tp!=none)
    {
        if (CPPlayerController(tp.Controller)!=none)
            return CPPlayerController(tp.Controller).bWeaponAutoReload;
    }
    return false;
}

simulated function AutoFire()
{
	local CPPawn _Pawn;

    _Pawn=CPPawn(Instigator);

	if(GetStateName() == 'Inactive')
		return;

    if(_Pawn == none)
		return;

	if(_Pawn.CurrentFireModeAutoFireCheck != 0)
		return;

	if(CurrentFireMode != 0)
		return;

    if(bWeaponCanFireOnReload && bReloadFireToggle)
    {
        GoToState('WeaponFiring');
        StartFire(CurrentFireMode);

        if(Role < Role_Authority)
            ServerStartFire(CurrentFireMode);
    }
}


/** Fire Mode Switching */
simulated function StartFireModeSwitch()
{
    if ((Instigator==none || !Instigator.bNoWeaponFiring) &&
        !DenyWeaponFunctionality() &&
        (IsInState('Active') || IsInState('WeaponFiring') || IsInState('FireModeSwitching')))
    {
        if (Role<ROLE_Authority)
            ServerStartFireModeSwitch();
        BeginFireModeSwitch();
    }
}

reliable server function ServerStartFireModeSwitch()
{
    if ((Instigator==none || !Instigator.bNoWeaponFiring) && !DenyWeaponFunctionality())
        BeginFireModeSwitch();
}

simulated function BeginFireModeSwitch()
{
    if (!CanSwitchFireMode())
        return;
    SetPendingFireModeSwitch();
}

simulated function StopFireModeSwitch()
{
    EndFireModeSwitch();
    if (Role<Role_Authority)
        ServerStopFireModeSwitch();
}

reliable server function ServerStopFireModeSwitch()
{
    EndFireModeSwitch();
}

simulated function EndFireModeSwitch()
{
    ClearPendingFireModeSwitch();
}

final simulated function bool PendingFireModeSwitch()
{
    if (bJustSwitchedFireMode)
        return false;
    if (CPInventoryManager(InvManager)!=none)
        return CPInventoryManager(InvManager).IsPendingFireModeSwitch();
    return false;
}

final simulated function SetPendingFireModeSwitch()
{
    if (bJustSwitchedFireMode)
        bJustSwitchedFireMode=false;
    if (CPInventoryManager(InvManager)!=none)
        CPInventoryManager(InvManager).SetPendingFireModeSwitch();
}

final simulated function ClearPendingFireModeSwitch()
{
    if (bJustSwitchedFireMode)
        bJustSwitchedFireMode=false;
    if (CPInventoryManager(InvManager)!=none)
        CPInventoryManager(InvManager).ClearPendingFireModeSwitch();
}

final simulated function SendToFireModeSwitchState()
{
    GotoState('FireModeSwitching');
}

simulated function bool CanSwitchFireMode()
{
    return (FireStates.Length>1);
}

simulated function bool IsFireModeSwitch()
{
    return false;
}

simulated function FinishedFireModeSwitch()
{
	`Log("WARNING OUT OF SYNC TIMER DETECTED! CPWEAPON.FinishedFireModeSwitch() - CODE WAS NOT CALLED BECAUSE OF THIS! ");
}

simulated function TimeWeaponFireModeSwitch()
{
    PlayWeaponFireModeSwitch();
    SetTimer(FireModeSwitchTime[PendingFireState]>0 ? FireModeSwitchTime[PendingFireState] : 1.0,false,nameof(FinishedFireModeSwitch));
	SetTimerLog(FireModeSwitchTime[PendingFireState]>0 ? FireModeSwitchTime[PendingFireState] : 1.0,false,nameof(FinishedFireModeSwitch));
}

simulated function PlayWeaponFireModeSwitch()
{
    if (ArmsFireModeSwitchAnim[PendingFireState]!='' && ArmsAnimSet!=none && WeaponFireModeSwitchAnim[PendingFireState]!='')
    {
        PlayWeaponAnimation(WeaponFireModeSwitchAnim[PendingFireState],FireModeSwitchTime[PendingFireState]);
        PlayArmAnimation(ArmsFireModeSwitchAnim[PendingFireState],FireModeSwitchTime[PendingFireState]);
    }
    else
    {
        `Log("CPWeapon::PlayWeaponFireModeSwitch");
        `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
        `Log("ARM ANIMATION IS " @ ArmsFireModeSwitchAnim[PendingFireState]);
        `Log("WEP ANIMATION IS " @ WeaponFireModeSwitchAnim[PendingFireState]);
    }

    if (FireModeSwitchSnd!=none)
        WeaponPlaySound(FireModeSwitchSnd);

    PlayDelayedWeaponFireModeSwitch(GetDegreesByMode());
}

simulated function PlayDelayedWeaponFireModeSwitch(int Degrees)
{
    SetFireModeSelectorSwitch(Degrees);
    if (FireModeSwitchSnd!=none)
        WeaponPlaySound(FireModeSwitchSnd);
}

simulated function float GetDegreesByMode()
{
    if(PendingFireState == 1)
        return 180.0;
    else if (PendingFireState == 2)
        return 0.0;
    else return 1.0;
}


/** Pickup/drop stuff */
function GivenTo(Pawn thisPawn,optional bool bDoNotActivate)                // server only
{
    local CPPlayerController CPPlayerController;

    // If we are a spectator, don't give us anything
    foreach LocalPlayerControllers(class'CPPlayerController', CPPlayerController)
    {
        if(CPPlayerController != none)
        {
            if(CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bOnlySpectator || CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bIsSpectator)
            {
                return;
            }
        }
    }

    super.GivenTo(thisPawn,bDoNotActivate);
    bJustDropped=false;
    bEmptyDestroyRequest=false;

    if(Instigator != none)
    {
        if(Instigator.PlayerReplicationInfo != none)
        {
            if(Instigator.PlayerReplicationInfo.bBot)       // BOTHACK
                Loaded();
        }
    }

	UpdateClipAndAmmoCountToClient(); //used for when throwing weapons etc as they will get out of sync otherwise.
}

reliable client function ClientGivenTo(Pawn NewOwner,bool bDoNotActivate)   // client only
{
    Super.ClientGivenTo(NewOwner,bDoNotActivate);
    bJustDropped=false;
    bEmptyDestroyRequest=false;
}

function ItemRemovedFromInvManager()                                        // server only
{
    SetLaserDotStatus(false);
    bJustDropped=true;
    bJustSwitchedFireMode=false;
    super.ItemRemovedFromInvManager();
}

//merged below
//reliable client function ClientWeaponThrown()                               // client only
//{
//  bJustDropped=true;
//  bJustSwitchedFireMode=false;
//  super.ClientWeaponThrown();
//}
/** Pickup/drop stuff */

/** Effects */
simulated function PlayWeaponEmptyFire()
{
    if (ArmsEmptyFireAnim!='' && ArmsAnimSet!=none && WeaponEmptyFireAnim!='')
    {
        PlayWeaponAnimation(WeaponEmptyFireAnim,FireWeaponEmptyTime);
        PlayArmAnimation(ArmsEmptyFireAnim,FireWeaponEmptyTime);
    }
    else
    {
        `Log("CPWeapon::PlayWeaponEmptyFire");
        `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
        `Log("ARM ANIMATION IS " @ ArmsEmptyFireAnim);
        `Log("WEP ANIMATION IS " @ WeaponEmptyFireAnim);
    }

    if (WeaponEmptySnd!=none)
        WeaponPlaySound(WeaponEmptySnd);
}
simulated function EmptyFiringEndTimer()
{
	//`Log("WARNING OUT OF SYNC TIMER DETECTED! CPWEAPON.EmptyFiringEndTimer() - CODE WAS NOT CALLED BECAUSE OF THIS!");
	HandleFinishedFiring();
}

final simulated function bool IsPendingFireRelease()
{
    if (CPInventoryManager(InvManager)!=none)
        return CPInventoryManager(InvManager).IsPendingFireRelease();
    return false;
}

final simulated function SetPendingFireRelease()
{
    if (CPInventoryManager(InvManager)!=none)
        CPInventoryManager(InvManager).SetPendingFireRelease();
}

/**
 * Don't send a zoomed fire mode in to a firing state
 */
simulated function SendToFiringState(byte FireModeNum)
{
    if (FireModeNum>=2)
        return;
    SetCurrentFireMode(FireModeNum);
    if (FireStates[CurrentFireState]==none)
    {
        GotoState('WeaponFiring');
        return;
    }
    `LogInv(FireModeNum @ "Sending to state:" @ FireStates[CurrentFireState].FiringState[FireModeNum]);
    GotoState(FireStates[CurrentFireState].FiringState[FireModeNum]);
}

//like SendToFiringState() but used for spectators and called from the weaponattachment
simulated function GoToFiringState(byte FireModeNum)
{
    if (FireStates[CurrentFireState]==none)
    {
        GotoState('WeaponFiring');
        return;
    }
    `LogInv(FireModeNum @ "Sending to state:" @ FireStates[CurrentFireState].FiringState[FireModeNum]);
    GotoState(FireStates[CurrentFireState].FiringState[FireModeNum]);
}


simulated function bool ShouldRefire()
{
    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none || !HasAmmo(CurrentFireMode) || DenyWeaponFunctionality())
        return false;
    return (StillFiring(CurrentFireMode) && FireStates[CurrentFireState].bRepeater[CurrentFireMode]==1);
}

simulated function StartFire(byte FireModeNum)
{
    bReloadFireToggle=true;
    if(bEquippingWeapon) //stop any fire attempts during the weapon equip animations
        return;

    if(bPuttingDownWeapon) //stop any fire attempts during the weapon putdown animations
        return;

    //`log("!bNoWeaponFiring = " $ !Instigator.bNoWeaponFiring);
    //`log("!DenyWeaponFunctionality() = " $ !DenyWeaponFunctionality());

    if ((Instigator==none || !Instigator.bNoWeaponFiring) && !DenyWeaponFunctionality())
    {
        if (Role<Role_Authority)
            ServerStartFire(FireModeNum);
        BeginFire(FireModeNum);
    }
}

simulated function EndFire( byte FireModeNum )
{
    bReloadFireToggle = false;

    Super.EndFire(FireModeNum);
}

reliable server function ServerStartFire(byte FireModeNum)
{
    if ((Instigator==none || Instigator.Controller!=none || bAllowFiringWithoutController) && !DenyWeaponFunctionality())
        super(UDKWeapon).ServerStartFire(FireModeNum);
}

// BOTHACK : force the bots to use primary fire so they wont get stuck with specal alt fires ( like the laser dot )
function byte BestMode()
{
    return 0;
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


/**
 * PlayFireEffects Is the root function that handles all of the effects associated with
 * a weapon.  This function creates the 1st person effects.  It should only be called
 * on a locally controlled player.
 */

simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
    local int fireIndex;

    if (FireModeNum>=2 || FireStates[CurrentFireState]==none)
        return;
    if (FireModeNum==0)
    {
        fireIndex=Rand(FireStates[CurrentFireState].WeaponFireAnims.Length);

        if (FireStates[CurrentFireState].ArmFireAnims[fireIndex]!='' && ArmsAnimSet!=none && FireStates[CurrentFireState].WeaponFireAnims[fireIndex]!='')
        {
            PlayArmAnimation(FireStates[CurrentFireState].ArmFireAnims[fireIndex],GetFireInterval(FireModeNum));
            PlayWeaponAnimation(FireStates[CurrentFireState].WeaponFireAnims[fireIndex],GetFireInterval(FireModeNum));
        }
        else
        {
            `Log("CPWeapon::PlayFireEffects A");
            `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
            `Log("ARM ANIMATION IS " @ FireStates[CurrentFireState].ArmFireAnims[fireIndex]);
            `Log("WEP ANIMATION IS " @ FireStates[CurrentFireState].WeaponFireAnims[fireIndex]);
        }

            CauseMuzzleFlash();

            if(!bShellUseAnimNotify)
                CauseShellLaunch();

            ShakeView();
    }
    else if (FireModeNum==1)
    {
        if(!bUsesLaserDot)
        {
            fireIndex=Rand(FireStates[CurrentFireState].WeaponAltFireAnims.Length);

            if (FireStates[CurrentFireState].ArmAltFireAnims[fireIndex]!='' && ArmsAnimSet!=none && FireStates[CurrentFireState].WeaponAltFireAnims[fireIndex]!='')
            {
                PlayWeaponAnimation(FireStates[CurrentFireState].WeaponAltFireAnims[fireIndex],GetFireInterval(FireModeNum));
                PlayArmAnimation(FireStates[CurrentFireState].ArmAltFireAnims[fireIndex],GetFireInterval(FireModeNum));
            }
            else
            {
                `Log("CPWeapon::PlayFireEffects B");
                `Log("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
                `Log("ARM ANIMATION IS " @ FireStates[CurrentFireState].ArmAltFireAnims[fireIndex]);
                `Log("WEP ANIMATION IS " @ FireStates[CurrentFireState].WeaponAltFireAnims[fireIndex]);
            }

            CauseMuzzleFlash();

            if(!bShellUseAnimNotify)
                CauseShellLaunch();

            ShakeView();
        }
    }
}

/**
 * Show the weapon begin equipped
 */
simulated function PlayWeaponEquip()
{
    local CPPawn TAP;
    //Mesh.SetOwnerNoSee(false);

    TAP=CPPawn(Instigator);
    if(TAP==none)
        return;

    //TAP.ArmsMesh[0].SetOwnerNoSee(false);
    //TAP.ArmsMesh[1].SetOwnerNoSee(false);

    bEquippingWeapon = true;

    SetTimer(EquipTime,false,'CompletedWeaponEquip');
	SetTimerLog(EquipTime,false,'CompletedWeaponEquip');

    if (WeaponEmptyAnimBlend!=none && AmmoCount==0)
        WeaponEmptyAnimBlend.SetBlendTarget(1.0,0.0);

    if (ArmsEquipAnim!='' && ArmsAnimSet!=none && WeaponEquipAnim!='')
    {
        PlayWeaponAnimation(WeaponEquipAnim,EquipTime);
        PlayArmAnimation(ArmsEquipAnim,EquipTime);
    }
    else
    {
        `Log("CPWeapon::PlayWeaponEquip");
        `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
        `Log("ARM ANIMATION IS " @ ArmsEquipAnim);
        `Log("WEP ANIMATION IS " @ WeaponEquipAnim);
    }

    if (WeaponEquipSnd!=none)
        WeaponPlaySound(WeaponEquipSnd);
}

simulated function CompletedWeaponEquip()
{
    bEquippingWeapon = false;
    IdleTimeDialation = 0.0f; //reset the idle timer when we equip
}

/**
 * Show the weapon being put away
 */
simulated function PlayWeaponPutDown()
{
    bPuttingDownWeapon = true;
    SetTimer(EquipTime,false,'CompletedWeaponPutdown');
	SetTimerLog(EquipTime,false,'CompletedWeaponPutdown');

    if (ArmsPutDownAnim!='' && ArmsAnimSet!=none && WeaponPutDownAnim != '')
    {
        PlayWeaponAnimation(WeaponPutDownAnim,PutDownTime);
        PlayArmAnimation(ArmsPutDownAnim,PutDownTime);
    }
    else
    {
        `Log("CPWeapon::PlayWeaponPutDown for weapon " @self);
        `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
        `Log("ARM ANIMATION IS " @ ArmsPutDownAnim);
        `Log("WEP ANIMATION IS " @ WeaponPutDownAnim);
    }

    if (WeaponPutDownSnd!=none)
        WeaponPlaySound(WeaponPutDownSnd);
}

simulated function CompletedWeaponPutdown()
{
    bPuttingDownWeapon = false;
}


simulated function AnimNodeSequence GetWeaponAnimNodeSeq()
{
    local AnimTree Tree;
    local SkeletalMeshComponent SkelMesh;
    local AnimNodeSequence AnimSeq;

    SkelMesh=SkeletalMeshComponent(Mesh);
    if(SkelMesh!=none)
    {
        Tree=AnimTree(SkelMesh.Animations);
        if (Tree!=none)
        {
            AnimSeq=AnimNodeSequence(Tree.FindAnimNode('WeaponAnimOut'));
            if (AnimSeq!=none)
            {
                return AnimSeq;
            }
            return AnimNodeSequence(Tree.Children[0].Anim);
        }
        else
        {
            return AnimNodeSequence(SkelMesh.Animations);
        }
    }
    return None;
}

simulated function PlayWeaponAnimation(Name Sequence,float fDesiredDuration,optional bool bLoop,optional SkeletalMeshComponent SkelMesh)
{
    local AnimNodeSequence WeapNode;
    local float DesiredRate;
   
    if (Mesh==none || !Mesh.bAttached || WorldInfo.NetMode==NM_DedicatedServer)
        return;
    if (SkelMesh==none)
        SkelMesh=SkeletalMeshComponent(Mesh);
    if (SkelMesh==none || GetWeaponAnimNodeSeq()==none)
        return;
    WeapNode=GetWeaponAnimNodeSeq();
    if (WeapNode!=none)
    {
        WeapNode.SetAnim(Sequence);
        if (WeapNode.AnimSeq!=none)
        {
            DesiredRate=(fDesiredDuration>0.0) ? (WeapNode.AnimSeq.SequenceLength/(fDesiredDuration*WeapNode.AnimSeq.RateScale)) : 1.0;

			if(Instigator != none)
			{
				if(CPPlayerController(Instigator.Controller) != none)
				{
					if(CPPlayerController(Instigator.Controller).bDEVWeaponTuneMode)
						strAnimationDebugMessages = "Playing Weapon Animation " $ Sequence $ " for " $ fDesiredDuration $ " Seconds. Animation Length " $WeapNode.AnimSeq.SequenceLength ;
				}
			}
        }
        WeapNode.PlayAnim(bLoop,DesiredRate);
        PlayArmAnimation(Sequence,fDesiredDuration,false,bLoop,SkelMesh);
    }

}

simulated function PlayArmAnimation(name Sequence,float fDesiredDuration,optional bool OffHand,optional bool bLoop,optional SkeletalMeshComponent SkelMesh)
{
    local CPPawn TAP;
    local SkeletalMeshComponent ArmMeshComp;
    local AnimNodeSequence ArmNode, WeapNode;
    local float DesiredRate;

    if (Mesh==none || !Mesh.bAttached || WorldInfo.NetMode==NM_DedicatedServer)
    {
        return;
    }
    if (SkelMesh==none)
        SkelMesh=SkeletalMeshComponent(Mesh);
    if (SkelMesh==none || GetWeaponAnimNodeSeq()==none)
    {
        return;
    }
    if (WorldInfo.NetMode==NM_DedicatedServer || Instigator==none || !Instigator.IsFirstPerson())
    {
        return;
    }

    TAP=CPPawn(Instigator);
    if(TAP==none)
    {
        return;
    }
    if (TAP.bArmsAttached)
    {
        // Choose the right arm
        if(!OffHand)
        {
            ArmMeshComp = TAP.ArmsMesh[0];
        }
        else
        {
            ArmMeshComp = TAP.ArmsMesh[1];
        }

        // Check we have access to mesh and animations
        if( ArmMeshComp == None || ArmsAnimSet == none || GetArmAnimNodeSeq() == None )
        {
            return;
        }

        // If we are not specifying a duration, use the default play rate.
        //if(fDesiredDuration > 0.0)
        //{
            // @todo - this should call GetWeaponAnimNodeSeq, move 'duration' code into AnimNodeSequence and use that.
            ArmMeshComp.PlayAnim(Sequence, fDesiredDuration, bLoop);

            WeapNode = AnimNodeSequence(ArmMeshComp.Animations);
            WeapNode.SetAnim(Sequence);
            WeapNode.PlayAnim(bLoop, DefaultAnimSpeed);
        //}
        //else
        //{
        //  WeapNode = AnimNodeSequence(ArmMeshComp.Animations);
        //  WeapNode.SetAnim(Sequence);
        //  WeapNode.PlayAnim(bLoop, DefaultAnimSpeed);
        //}


        if (ArmsAnimSet==none || GetArmAnimNodeSeq()==none)
        {
            `Log("PlayArmAnimation failed to play the animation" @ Sequence @ "for" @ self);
            `Log("ArmsAnimSet =" @ArmsAnimSet);
            `Log("GetArmAnimNodeSeq() =" @GetArmAnimNodeSeq());

            return;
        }
        ArmNode=GetArmAnimNodeSeq();
        if (ArmNode!=none)
        {
            ArmNode.SetAnim(Sequence);
            if (ArmNode.AnimSeq!=none)
            {
                DesiredRate=(fDesiredDuration>0.0) ? (ArmNode.AnimSeq.SequenceLength/(fDesiredDuration*ArmNode.AnimSeq.RateScale)) : 1.0;
                ArmNode.PlayAnim(bLoop,DesiredRate);
            }
            else
            {
                `Log("PlayArmAnimation failed to play the animation ArmNode.AnimSeq is NONE - was expecting " @ Sequence @ "for" @ self);
            }
        }
        else
        {
            `Log("PlayArmAnimation failed to play the animation ArmNode is NONE - was expecting" @ Sequence @ "for" @ self);
        }
    }
}

simulated function HandleFinishedFiring()
{
    local bool bStateSwitched;

    if (AmmoCount==0)
    {
        if (WeaponEmptyAnimBlend!=none)
            WeaponEmptyAnimBlend.SetBlendTarget(1.0,0.0);
        if (!IsInState('WeaponEmptyFiring') && (PendingFire(0) || PendingFire(1)) && IsPendingFireRelease())
        {
            bStateSwitched=true;
            GotoState('WeaponEmptyFiring');
        }
    }
    if (!bStateSwitched)
    {
        GotoState('Active');
    }
}

/**
 * This function is called from the pawn when the visibility of the weapon changes
 */
simulated function ChangeVisibility(bool bIsVisible)
{
local CPPawn TAP;
local SkeletalMeshComponent SkelMesh;
local PrimitiveComponent Primitive;


    TAP=CPPawn(Instigator);
    if (Mesh!=none)
    {
        if (bIsVisible && !Mesh.bAttached)
        {
            // Returns on cases: map changing, etc.
            if(TAP==None || TAP.Controller == None || TAP.Controller.PlayerReplicationInfo == None || InvManager == None)
                return;
            AttachComponent(Mesh);
            EnsureWeaponOverlayComponentLast();
        }
        SetHidden(!bIsVisible);
        SkelMesh=SkeletalMeshComponent(Mesh);
        if (SkelMesh!=none)
        {
            foreach SkelMesh.AttachedComponents(class'PrimitiveComponent',Primitive)
            {
                Primitive.SetHidden(!bIsVisible);
            }
        }
    }
    if (ArmsAnimSet!=none && GetHand()!=HAND_Hidden)
    {

        if (TAP!=none && TAP.ArmsMesh[0]!=none)
        {
			TAP.HideArms(!bIsVisible);
        }
    }
    //if (OverlayMesh!=none)
        //OverlayMesh.SetHidden(!bIsVisible || (GetHand()==HAND_Hidden));
}

simulated function SetupArmsAnim()
{
    local CPPawn TAP;
    local SkeletalMeshComponent skelComp;

    TAP=CPPawn(Instigator);
    skelComp=SkeletalMeshComponent(Mesh);
    if (TAP!=none && skelComp!=none)
    {
		ArmsAnimSet = skelComp.AnimSets[0]; //sets 1st
		TAP.ArmsMesh[0].AnimSets[1] = skelComp.AnimSets[0]; //sets 3rd
		TAP.ArmsMesh[0].SetLightEnvironment(TAP.LightEnvironment);
		Mesh.SetLightEnvironment(TAP.LightEnvironment);
		

   //     if (skelComp.AnimSets[0]!=none)
   //     {
			//if(TAP.ArmsMesh[0].AnimSets[1] != skelComp.AnimSets[0])
			//{
			//	TAP.ArmsMesh[0].AnimSets[1]=skelComp.AnimSets[0];
			//	ArmsAnimSet=skelComp.AnimSets[0];
			//}

			//if(ArmsAnimSet != TAP.ArmsMesh[0].AnimSets[1])
			//{            
				//TAP.ArmsMesh[0].SetLightEnvironment(TAP.LightEnvironment);
			//	//NOTE TO ADAM I HAD TO ADD THIS LINE AS ARMSANIMSET IS USED EVERYWHERE AND IT WAS NOT SET ANYWHERE - REMOVE THIS LINE AND THE ARMS STOP WORKING
				//ArmsAnimSet = TAP.ArmsMesh[0].AnimSets[1];
			//}
   //     }
   //     else if (ArmsAnimSet!=none)
   //     {
			//if(TAP.ArmsMesh[0].AnimSets[1] != ArmsAnimSet)
			//{
			//	TAP.ArmsMesh[0].AnimSets[1]=ArmsAnimSet;
			//	TAP.ArmsMesh[0].SetLightEnvironment(TAP.LightEnvironment);
			//}
   //     }
   //     else
   //     {
   //     }
    }
			
    //`Log("self" @ self);
	//`Log("TAP.ArmsMesh[0].AnimSets[0] = " @TAP.ArmsMesh[0].AnimSets[0]);
	//`Log("TAP.ArmsMesh[0].AnimSets[1] = " @TAP.ArmsMesh[0].AnimSets[1]);
	//`Log("skelComp.AnimSets[0] = " @skelComp.AnimSets[0]);
	//`Log("ArmsAnimSet = " @ArmsAnimSet);
}



/** laser */
simulated function SetLaserDotStatus(bool bNewStatus)
{
    if (Owner==none)
        return;
    if (Owner.isa('CPPawn'))
    {
        CPPawn(Owner).bLaserDotStatus=bNewStatus;
        CPPawn(Owner).LaserStatusUpdateNotify();
    }
}

simulated function bool GetLaserDotStatus()
{
	if(!bUsesLaserDot)
		return false;
	
    if (Owner==none)
        return bLaserDotStatus;	

    if (Owner.isa('CPPawn'))
        return CPPawn(Owner).bLaserDotStatus;
}

simulated function SetFireAmmunitionBehavior(TAFireAmmunitionMode newMode)
{
    CurrentFireAmmoMode=newMode;
}

simulated function FireAmmunition()
{
    local int i;

    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none || CurrentFireMode == 1)
        return;

    PlayFiringSound();
    if ( Role == ROLE_SimulatedProxy || Role == ROLE_Authority )
    {
        PlayFireEffects( CurrentFireMode );
    }

    ConsumeAmmo(CurrentFireMode);
    switch (FireStates[CurrentFireState].FireType[CurrentFireMode])
    {
        case ETFT_InstantHit:
            for ( i = 0; i < FireStates[CurrentFireState].PelletsPerShot; i++ )
                InstantFire();
            break;
        case ETFT_Projectile:
            //`warn("NOT IMPLEMENTED YET");
            for ( i = 0; i < FireStates[CurrentFireState].PelletsPerShot; i++ )
                ProjectileFire();
            break;
    }
    NotifyWeaponFired(CurrentFireMode);

    if(InvManager != none)
        CPInventoryManager(InvManager).OwnerEvent('FiredWeapon');
}

simulated function rotator GetFireSpreadFor( rotator BaseAim, optional float SpreadScaling, optional bool bReuseLastSpread )
{
    local vector X,Y,Z;
    local float CurrentSpread;
    local float TmpSpread;

    if ( CurrentFireMode >= 2 || FireStates[CurrentFireState] == none )
        return BaseAim;

    CurrentSpread = Spread[CurrentFireMode];
    if (CurrentSpread == 0.0 )
        return BaseAim;

    GetAxes( BaseAim, X, Y, Z );
    CurrentSpread *= ( SpreadScaling > 0.0 ) ? SpreadScaling : 1.0;
    if ( bReuseLastSpread )
    {
        TmpSpread = FRand() - 0.5;
        LastSpreadRandY += FRand() - 0.5;
        LastSpreadRandZ += Sqrt( 0.5 - Square( TmpSpread ) ) * ( FRand() - 0.5 );
    }
    else
    {
        LastSpreadRandY = FRand() - 0.5;
        LastSpreadRandZ = Sqrt( 0.5 - Square( LastSpreadRandY ) ) * ( FRand() - 0.5 );
    }

    return rotator( X + LastSpreadRandY * CurrentSpread * Y + LastSpreadRandZ * CurrentSpread * Z );
}

simulated function vector InstantFireStartTrace()
{
    return GetPhysicalFireStartLoc();
}

///**
//* @returns position of trace start for instantfire()
//*/
//simulated function vector InstantFireStartTrace()
//{
//  return Instigator.GetWeaponStartTraceLocation();
//}

/**
 * Gets the spread multiplier for a weapon
 * @return A normalized multiplier for the weapon spread
 */
simulated function float SpreadMultiplier()
{
    return 1.0f;
}

/**
 * TODO: This is a DEBUG stub function; REDO SPREAD FUNCTIONS!
 */
simulated function rotator AddSpreadDebug( rotator BaseAim, optional float YOverride=0.0f, optional float ZOverride=0.0f )
{
    local vector X, Y, Z;
    local float CurrentSpread;

    CurrentSpread = ( CurrentFireState > Spread.Length ) ? 0.0 : Spread[CurrentFireState] * SpreadMultiplier();
    if ( CurrentSpread == 0 )
        return BaseAim;

    GetAxes( BaseAim, X, Y, Z );
    return Rotator( X + YOverride * CurrentSpread * Y + ZOverride * CurrentSpread * Z );
}

/**
 * Adds any fire spread offset to the passed in rotator
 * @param BaseAim the base aim direction
 * @return the adjusted aim direction
 */
simulated function rotator AddSpread( rotator BaseAim )
{
    local vector X, Y, Z;
    local float CurrentSpread, Angle;


    CurrentSpread = ( CurrentFireState > Spread.Length ) ? 0.0 : Spread[CurrentFireState] * SpreadMultiplier();
    if ( CurrentSpread == 0 )
        return BaseAim;

    // Add in any spread.
    GetAxes( BaseAim, X, Y, Z );
    Angle = FRand() * Pi * 2.0f;
    return rotator( X + Cos( Angle ) * CurrentSpread * FRand() * Y + Sin( Angle ) * CurrentSpread * FRand() * Z );
}

simulated function AddRecoil( byte FiringMode )
{
    local CPWeaponFireMode  mode;
    local Vector2D          random;
    local vector            /*x, y, z,*/ max, min;
    local Rotator           _Rotation;

    mode = FireStates[CurrentFireState];
    if ( FiringMode >= 2 || mode == none || Instigator == none || Instigator.Controller == none )
        return;

    max = mode.MaxFireRecoil[FiringMode];
    min = mode.MinFireRecoil[FiringMode];
    random.X = ( min.X + FRand() * ( max.X - min.X ) ) / FireStates[CurrentFireState].PelletsPerShot;
    random.Y = ( min.Y + FRand() * ( max.Y - min.Y ) ) / FireStates[CurrentFireState].PelletsPerShot;
    //random.X *= Abs( Cos( (Instigator.Controller.Rotation.Pitch - 32768) * 0.000095873799 ) );

    //GetAxes( Instigator.Controller.Rotation, x, y, z );
    //_Rotation = Rotator( x + random.X * y + random.Y * z );

    if(Instigator.Controller != none && Instigator.Controller.IsA('CPPlayerController'))
    {
        _Rotation = Instigator.Controller.Rotation;
        _Rotation.Yaw += int( 8192.0 * random.X );
        _Rotation.Pitch += int( 8192.0 * random.Y );
        _Rotation = CPPlayerController( Instigator.Controller ).LimitViewRotation( _Rotation, -16384, 16383 );
        Instigator.Controller.SetRotation( _Rotation );
    }
}


/**
 * GetAdjustedAim begins a chain of function class that allows the weapon, the pawn and the controller to make
 * on the fly adjustments to where this weapon is pointing.
 */
simulated function Rotator GetAdjustedAim( vector StartFireLoc )
{
    local rotator R;

    // Start the chain, see Pawn.GetAdjustedAimFor()
    if( Instigator != None )
    {
        R = Instigator.GetAdjustedAimFor( Self, StartFireLoc );
    }

    return R;
}

simulated function InstantFire()
{
    local vector StartTrace, EndTrace, DebugColor, n;
    local Array<ImpactInfo> ImpactList;
    local int Idx;
    local ImpactInfo RealImpact;
    // Used for generating colors ( Debug weapon traces )
    local int r, g, b;
    // Impact effect locals
    local CPPlayerController P;
    local CPPawn PawnOwner;


    StartTrace = Instigator.GetPawnViewLocation(); //this goes native so need to check it..
    EndTrace = StartTrace + vector( AddSpread( GetAdjustedAim( StartTrace ) ) ) * GetTraceRange();
    RealImpact = CalcWeaponFire( StartTrace, EndTrace, ImpactList );

    if ( Role == ROLE_Authority )
    {
        PawnOwner = CPPawn( Owner );
        if ( Owner != none )
        {
            n = RealImpact.HitNormal;
            foreach WorldInfo.AllControllers( class'CPPlayerController', P )
                P.ClientImpactEffect( PawnOwner, RealImpact.HitLocation, n.X, n.Y, n.Z );
        }
    }

    for ( Idx = 0; Idx < ImpactList.Length; Idx++ )
    {
        if(Role < ROLE_Authority)
            ServerProcessIntantHit( CurrentFireMode, ImpactList[Idx] );
        else
            ProcessInstantHit( CurrentFireMode, ImpactList[Idx] );

        if ( Instigator != none && CPPlayerController( Instigator.Controller ) != none )
        {
            if ( CPPlayerController( Instigator.Controller ).bDEVWeaponDrawTraces )
            {
                /** Kolby's super awesome random color generator **/
                DebugColor = Normal( ImpactList[Idx].HitLocation );
                DebugColor.X = ( DebugColor.X < 0.0f ) ? DebugColor.X * -1.0f : DebugColor.X;
                DebugColor.Y = ( DebugColor.Y < 0.0f ) ? DebugColor.Y * -1.0f : DebugColor.Y;
                DebugColor.Z = ( DebugColor.Z < 0.0f ) ? DebugColor.Z * -1.0f : DebugColor.Z;
                DebugColor *= (128 + Max( 1, Rand( 192 ) ));
                DebugColor += vect( 63.0f, 63.0f, 63.0f );

                r = int( DebugColor.X ) + 1;
                g = int( DebugColor.Y ) + 1;
                b = int( DebugColor.Z ) + 1;
                /** --- **/

                DrawDebugLine( StartTrace,
                               ImpactList[Idx].HitLocation,
                               (r ^ g * b + r * g ^ b) % 255,
                               (g ^ b * r + g * b ^ r) % 255,
                               (b ^ r * g + b * r ^ g) % 255,
                               true );
            }
        }
    }

    if ( CurrentFireAmmoMode == FA_Normal )
        AddRecoil( CurrentFireMode );
}

simulated function Projectile ProjectileFire()
{
    local vector        StartTrace, EndTrace, RealStartLoc, AimDir;
    local ImpactInfo    TestImpact;
    local Projectile    SpawnedProjectile;


    if( Role == ROLE_Authority )
    {
        StartTrace = Instigator.GetPawnViewLocation();
        AimDir = Vector( AddSpread( GetAdjustedAim( StartTrace ) ) ) * GetTraceRange();

        // this is the location where the projectile is spawned.
        RealStartLoc = GetPhysicalFireStartLoc(AimDir);

        if( StartTrace != RealStartLoc )
        {
            // if projectile is spawned at different location of crosshair,
            // then simulate an instant trace where crosshair is aiming at, Get hit info.
            EndTrace = StartTrace + AimDir * GetTraceRange();
            TestImpact = CalcWeaponFire( StartTrace, EndTrace );

            // Then we realign projectile aim direction to match where the crosshair did hit.
            AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
        }

        // Spawn projectile
        SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
        if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
        {
            SpawnedProjectile.Init( AimDir );
        }

        // Return it up the line
        return SpawnedProjectile;
    }

    if ( CurrentFireAmmoMode == FA_Normal )
        AddRecoil( CurrentFireMode );

    return None;
}

reliable server function ServerProcessIntantHit(byte FiringMode,ImpactInfo Impact,optional int NumHits)
{
    ProcessInstantHit(FiringMode, Impact, NumHits);
}

simulated function ProcessInstantHit(byte FiringMode,ImpactInfo Impact,optional int NumHits)
{
local bool bFixMomentum;
local int TotalDamage;
local KActorFromStatic NewKActor;
local StaticMeshComponent HitStaticMesh;

    if (FiringMode>=2 || FireStates[CurrentFireState]==none)
        return;
    if (Impact.HitActor!=none)
    {
        if (Impact.HitActor.bWorldGeometry)
        {
            HitStaticMesh=StaticMeshComponent(Impact.HitInfo.HitComponent);
            if ((HitStaticMesh!=none) && HitStaticMesh.CanBecomeDynamic())
            {
                NewKActor=class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
                if (NewKActor!=none)
                    Impact.HitActor=NewKActor;
            }
        }
        if (!Impact.HitActor.bStatic && (Impact.HitActor != Instigator))
        {
            if (CPPlayerController(Instigator.Controller)!=none)
                CPPlayerController(Instigator.Controller).OnWeaponHitEnemy();

            if((WorldInfo.GRI.OnSameTeam(Instigator,Impact.HitActor) && Impact.HitActor.IsA('CPPawn') )|| Impact.HitActor.IsA('CPHostagePawn'))
            {
                //same team
                if(CPPlayerController(Instigator.Controller) != none)
                    CPPlayerController(Instigator.Controller).ClientPlaySound(SoundCue'CP_Weapon_Sounds.Impacts.CP_A_HitTarget_TeamShot_Cue');
            }
            else if (Impact.HitActor.IsA('CPPawn'))
            {
                //enemy
                if(CPPlayerController(Instigator.Controller) != none)
                    CPPlayerController(Instigator.Controller).ClientPlaySound(SoundCue'CP_Weapon_Sounds.Impacts.CP_A_HitTarget_EnemyShot_Cue');
            }

            if (Impact.HitActor.Role==ROLE_Authority && Impact.HitActor.bProjTarget
                && !WorldInfo.GRI.OnSameTeam(Instigator,Impact.HitActor)
                && Impact.HitActor.Instigator!=Instigator
                && PhysicsVolume(Impact.HitActor)==none)
            {
                HitEnemy++;
                LastHitEnemyTime=WorldInfo.TimeSeconds;
                if (WorldInfo.NetMode==NM_ListenServer)
                    if (CPPlayerController(Instigator.Controller)!=none)
                        CPPlayerController(Instigator.Controller).OnWeaponHitEnemy();
            }
            if ((CPPawn(Impact.HitActor)==none) && (FireStates[CurrentFireState].HitMomentum[FiringMode]==0))
            {
                FireStates[CurrentFireState].HitMomentum[FiringMode]=1;
                bFixMomentum=true;
            }
            if (Impact.HitActor!=none)
            {
                NumHits=Max(NumHits,1);
                TotalDamage=FireStates[CurrentFireState].MinHitDamage[FiringMode]+((FireStates[CurrentFireState].MaxHitDamage[FiringMode]-FireStates[CurrentFireState].MinHitDamage[FiringMode])*FRand());
                if (Impact.HitActor.bWorldGeometry)
                {
                    HitStaticMesh=StaticMeshComponent(Impact.HitInfo.HitComponent);
                    if ((HitStaticMesh!=none) && HitStaticMesh.CanBecomeDynamic())
                    {
                        NewKActor=class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
                        if (NewKActor!=none)
                            Impact.HitActor=NewKActor;
                    }
                }
                Impact.HitActor.TakeDamage(TotalDamage,Instigator.Controller,
                        Impact.HitLocation,FireStates[CurrentFireState].HitMomentum[FiringMode]*Impact.RayDir,
                        FireStates[CurrentFireState].HitDamageType[FiringMode],Impact.HitInfo,self);
            }
            if (bFixMomentum)
                FireStates[CurrentFireState].HitMomentum[FiringMode]=0;
        }
    }
}



simulated function AttachMuzzleFlash()
{
local SkeletalMeshComponent SKMesh;
local float EmitterFOV;

    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none)
        return;

    bMuzzleFlashAttached=true;
    SKMesh=SkeletalMeshComponent(Mesh);
    if (SKMesh!=none)
    {
        if ((FireStates[CurrentFireState].MuzzleFlashPSC[0]!=none) ||
            (FireStates[CurrentFireState].MuzzleFlashPSC[1]!=none))
        {
            if (MuzzleFlashFOVOverride>0)
                EmitterFOV=MuzzleFlashFOVOverride;
            else
                EmitterFOV=UDKSkeletalMeshComponent(SKMesh).FOV;

            MuzzleFlashPSC=new(Outer) class'UDKParticleSystemComponent';
            MuzzleFlashPSC.bAutoActivate=false;
            MuzzleFlashPSC.SetDepthPriorityGroup(SDPG_Foreground);
            MuzzleFlashPSC.SetFOV(EmitterFOV);
            SKMesh.AttachComponentToSocket(MuzzleFlashPSC,MuzzleFlashSocket);
        }
    }
}

simulated function AttachShellCasing()
{
local SkeletalMeshComponent SKMesh;
local float EmitterFOV;

    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none)
        return;
    bShellCasingAttached=true;
    SKMesh=SkeletalMeshComponent(Mesh);
    if (SKMesh!=none)
    {
        if ((FireStates[CurrentFireState].ShellCasingPSC[0]!=none) ||
            (FireStates[CurrentFireState].ShellCasingPSC[1]!=none))
        {
            if (MuzzleFlashFOVOverride>0)
                EmitterFOV=MuzzleFlashFOVOverride;
            else
                EmitterFOV=UDKSkeletalMeshComponent(SKMesh).FOV;

            if(ShellCasingPSC == none)
            {
                ShellCasingPSC=new(Outer) class'UDKParticleSystemComponent';
                ShellCasingPSC.bAutoActivate=false;
                ShellCasingPSC.SetDepthPriorityGroup(SDPG_World);
                ShellCasingPSC.SetFOV(EmitterFOV);
                SKMesh.AttachComponentToSocket(ShellCasingPSC,ShellCasingSocket);
            }
        }
    }
}

simulated event MuzzleFlashTimer()
{
    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none)
    {
        MuzzleFlashPSC.DeactivateSystem();
        return;
    }
    if (MuzzleFlashPSC!=none && FireStates[CurrentFireState].bMuzzleFlashPSCLoops[CurrentFireMode]!=1)
        MuzzleFlashPSC.DeactivateSystem();

}

simulated event ShellCasingTimer()
{
    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none)
    {
        ShellCasingPSC.DeactivateSystem();
        return;
    }
    if (ShellCasingPSC!=none && FireStates[CurrentFireState].bMuzzleFlashPSCLoops[CurrentFireMode]!=1)
    {
        ShellCasingPSC.DeactivateSystem();
    }
}

simulated event CauseMuzzleFlashLight()
{
    if ( MuzzleFlashLight != none && MuzzleFlashLight.Class == FireStates[CurrentFireState].MuzzleFlashLightClass[CurrentFireMode] )
    {
        MuzzleFlashLight.ResetLight();
        return;
    }
    if ( FireStates[CurrentFireState].MuzzleFlashLightClass[CurrentFireMode] == none )
        return;
    MuzzleFlashLight = new( Outer ) FireStates[CurrentFireState].MuzzleFlashLightClass[CurrentFireMode];
    SkeletalMeshComponent( Mesh ).AttachComponent( MuzzleFlashLight, 'Root' );
}

/** Sound player functions */
simulated function PlayFiringSound()
{
local int fireIndex;

    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none)
        return;
    if (CurrentFireMode==0)
    {
        fireIndex=Rand(FireStates[CurrentFireState].WeaponFireSnds.Length);
        if (FireStates[CurrentFireState].WeaponFireSnds[fireIndex]!=none)
        {
            MakeNoise(1.0);
            WeaponPlaySound(FireStates[CurrentFireState].WeaponFireSnds[fireIndex]);
        }
    }
    else if (CurrentFireMode==1)
    {
        fireIndex=Rand(FireStates[CurrentFireState].WeaponAltFireSnds.Length);
        if (FireStates[CurrentFireState].WeaponAltFireSnds[fireIndex]!=none)
        {
            MakeNoise(1.0);
            WeaponPlaySound(FireStates[CurrentFireState].WeaponAltFireSnds[fireIndex]);
        }
    }
}

simulated function WeaponPlaySound(SoundCue Sound,optional float NoiseLoudness)
{
    if (Sound!=none && CPPawn(Instigator)!=none && Instigator.Controller!=none && !bSuppressSounds)
    {
        if (Sound.SoundClass!='Ambient')
        {
            Instigator.PlaySound(Sound,true);
            if (Role==ROLE_Authority)
            {
                if (CriticalPointGame(WorldInfo.Game)!=none)
                    CriticalPointGame(WorldInfo.Game).PlaySoundWithReverbVolumeHack(Instigator,Sound);
                else
                    Instigator.PlaySound(Sound,false,true);
            }
        }
        else
            Instigator.PlaySound(Sound,false,true);
    }
}

/*
DEV Functions
*/
simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
local Vector vect;

    vect.X=MuzzleFlashScale;
    vect.Y=MuzzleFlashScale;
    vect.Z=MuzzleFlashScale;
    PSC.SetColorParameter('MuzzleFlashColor',MuzzleFlashColor);
    PSC.SetVectorParameter('MFlashScale',vect);                 // used by DEV commands to set the scale
}

exec function DEVSwapMeshAnims(string WeapName)
{
local string weapMesh,weapTemp,weapAnim;
local SkeletalMesh sm;
local AnimTree at;
local AnimSet as;

    weapMesh="TA_WP_"$WeapName$".Mesh.SK_TA_"$WeapName$"_1P";
    weapTemp="TA_WP_"$WeapName$".Anims.AT_TA_"$WeapName$"_1P";
    weapAnim="TA_WP_"$WeapName$".Anims.AS_TA_"$WeapName$"_1P";

    sm=SkeletalMesh(DynamicLoadObject(weapMesh,class'SkeletalMesh'));
    if (sm==none)
    {
        if (Instigator!=none && PlayerController(Instigator.Controller)!=none)
            PlayerController(Instigator.Controller).ClientMessage("DEVSwapMeshAnims : failed to load skeletal mesh - "$weapMesh,'Event');
        `log("unable to swap mesh anims, failed to load skeletal mesh - "$weapMesh,,'DEVSwapMeshAnims');
        return;
    }

    as=AnimSet(DynamicLoadObject(weapAnim,class'AnimSet'));
    if (as==none)
    {
        if (Instigator!=none && PlayerController(Instigator.Controller)!=none)
            PlayerController(Instigator.Controller).ClientMessage("DEVSwapMeshAnims : failed to load skeletal animation - "$weapAnim,'Event');
        `log("unable to swap mesh anims, failed to load skeletal animation - "$weapAnim,,'DEVSwapMeshAnims');
        return;
    }

    at=AnimTree(DynamicLoadObject(weapTemp,class'AnimTree'));

    SkeletalMeshComponent(Mesh).SetSkeletalMesh(sm);
    SkeletalMeshComponent(Mesh).AnimSets[0]=as;
    SkeletalMeshComponent(Mesh).SetAnimTreeTemplate(at);
    SkeletalMeshComponent(Mesh).UpdateAnimations();
    DEVPlayWeapAnim('WeaponIdle');
}

exec function DEVPlayWeapAnim(name Sequence,optional bool bLoop)
{
    PlayWeaponAnimation(Sequence,SkeletalMeshComponent(Mesh).GetAnimLength(Sequence),bLoop);
    PlayArmAnimation(Sequence,SkeletalMeshComponent(Mesh).GetAnimLength(Sequence),bLoop);
}

/*
DEV Checker
*/

function bool IsInTestMode()
{
    if (CPPlayerController(Instigator.Controller)!=none)
        return CPPlayerController(Instigator.Controller).bDEVWeaponTestMode;
    return false;
}

simulated final function float CalcFOVForAspectRatio(float OriginalFOV,float SizeX,float SizeY)
{
    return ATan2((Tan(OriginalFOV*Pi/360.0)*0.75*SizeX/SizeY),1)*360.0/Pi;
}

simulated function SetFOV(float NewFOV)
{
    if (UDKSkeletalMeshComponent(Mesh)!=none)
        UDKSkeletalMeshComponent(Mesh).SetFOV(NewFOV);
    if (CPPawn(Instigator)!=none && CPPawn(Instigator).ArmsMesh[0]!=none)
        CPPawn(Instigator).ArmsMesh[0].SetFOV(NewFOV);
    if (MuzzleFlashPSC!=none)
        MuzzleFlashPSC.SetFOV(NewFOV);
}

//TOP PROTO FUNCTION MERGE START
/**
 * Each Weapon needs to have a unique InventoryWeight in order for weapon switching to
 * work correctly.  This function calculates that weight using the various inventory values
 */
simulated function CalcInventoryWeight()
{
    InventoryWeight = ((InventoryGroup+1) * 1000) + (GroupWeight * 100);
    if ( Priority < 0 )
    {
        Priority = InventoryWeight;
    }
}

/**
 * tell the bot how much it wants this weapon pickup
 * called when the bot is trying to decide which inventory pickup to go after next
 */
static function float BotDesireability(Actor PickupHolder, Pawn P, Controller C)
{
    return 0;
}

//TOP-Proto remove if not required any more.
///**
// * This function is used to add ammo back to a weapon.  It's called from the Inventory Manager
// */
//function int AddAmmo( int Amount )
//{
//  AmmoCount = Clamp(AmmoCount + Amount,0,MaxAmmoCount);
//  // check for infinite ammo
//  if (AmmoCount <= 0 && (CPInventoryManager(InvManager) == None || CPInventoryManager(InvManager).bInfiniteAmmo))
//  {
//      AmmoCount = MaxAmmoCount;
//  }

//  return AmmoCount;
//}

/**
 * Returns true if the ammo is maxed out
 */
simulated function bool AmmoMaxed(int mode)
{
    return (AmmoCount >= MaxAmmoCount);
}

/**
 * This function retuns how much of the clip is empty.
 */
simulated function float DesireAmmo(bool bDetour)
{
    return (1.f - float(AmmoCount)/MaxAmmoCount);
}

/**
 * Material control
 *
 * NewMaterial      The new material to apply or none to clear it
 */
simulated function SetSkin(Material NewMaterial)
{
    local int i,Cnt;

    if ( NewMaterial == None )
    {
        // Clear the materials
        if ( default.Mesh.Materials.Length > 0 )
        {
            Cnt = Default.Mesh.Materials.Length;
            for (i=0;i<Cnt;i++)
            {
                Mesh.SetMaterial( i, Default.Mesh.GetMaterial(i) );
            }
        }
        else if (Mesh.Materials.Length > 0)
        {
            Cnt = Mesh.Materials.Length;
            for ( i=0; i < Cnt; i++ )
            {
                Mesh.SetMaterial(i, none);
            }
        }
    }
    else
    {
        // Set new material
        if ( default.Mesh.Materials.Length > 0 || Mesh.GetNumElements() > 0 )
        {
            Cnt = default.Mesh.Materials.Length > 0 ? default.Mesh.Materials.Length : Mesh.GetNumElements();
            for ( i=0; i < Cnt; i++ )
            {
                Mesh.SetMaterial(i, NewMaterial);
            }
        }
    }

        //TOP-PROTO CHECK THIS I REMOVED BUT MIGHT BE NEEDED!!!!
    //if (NewMaterial==none && Mesh!=none)
    //  Mesh.SetMaterial(0,WeaponMaterialInstance);
}

 /**
 * Attach Weapon Mesh, Weapon MuzzleFlash and Muzzle Flash Dynamic Light to a SkeletalMesh
 */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
    local CPPawn TAP;
    TAP = CPPawn(Instigator);
    if(Tap==None)
        return;
    // Attach 1st Person Muzzle Flashes, etc,
    if ( Instigator.IsFirstPerson() )
    {
        AttachComponent(Mesh);
        EnsureWeaponOverlayComponentLast();
        //SetHidden(True);
        bPendingShow = TRUE;
        Mesh.SetLightEnvironment(TAP.LightEnvironment);
        if (GetHand() == HAND_Hidden)
        {
            TAP.HideArms(true);
        }
    }
    else
    {
        //SetHidden(True);
        if (TAP != None)
        {
            Mesh.SetLightEnvironment(TAP.LightEnvironment);
            TAP.HideArms(true);
        }
    }

    SetWeaponOverlayFlags(TAP);

    // Spawn the 3rd Person Attachment
    if (Role == ROLE_Authority && TAP != None)
    {
        TAP.CurrentWeaponAttachmentClass = AttachmentClass;
        if ( TAP.CurrentWeaponAttachment == none )
            TAP.WeaponAttachmentChanged();
    }

    SetSkin(CPPawn(Instigator).ReplicatedBodyMaterial);
}

/**
 * Detach weapon from skeletal mesh
 *
 * @param   SkeletalMeshComponent weapon is attached to.
 */
simulated function DetachWeapon()
{
    local CPPawn P;

    DetachComponent( Mesh );
    if (OverlayMesh != None)
    {
        DetachComponent(OverlayMesh);
    }

    SetSkin(None);

    P = CPPawn(Instigator);
    if (P != None)
    {
        if (Role == ROLE_Authority && P.CurrentWeaponAttachmentClass == AttachmentClass)
        {
            P.CurrentWeaponAttachmentClass = None;
            if (!Instigator.IsLocallyControlled())
            {
				P.HideArms(true);
                //P.WeaponAttachmentChanged();
            }
        }
    }

    //SetHidden(True);
    SetBase(None);
    DetachMuzzleFlash();
    Mesh.SetLightEnvironment(None);
}

///**
// * Initialize the weapon
// */
simulated function PostBeginPlay()
{
    //InventoryGroup=int(WeaponType);
    Super.PostBeginPlay();


    if (FireStates.Length==0)
        `warn("weapon "$self$" have no fire state");
    else
    {
        if (DefaultFireState<FireStates.Length)
            SetFireState(DefaultFireState);
        else
            SetFireState(0);
    }
    SetFireAmmunitionBehavior(FA_Normal);

    CalcInventoryWeight();
    if ( Mesh != None )
    {
        Mesh.CastShadow = class'CPPlayerController'.default.bFirstPersonWeaponsSelfShadow;
    }

    bConsiderProjectileAcceleration = bConsiderProjectileAcceleration
                                        && (((WeaponProjectiles[0] != None) && (class<CPProjectile>(WeaponProjectiles[0]).Default.AccelRate > 0))
                                            || ((WeaponProjectiles[1] != None) && (class<CPProjectile>(WeaponProjectiles[1]).Default.AccelRate > 0)) );

    if ( bUseCustomCoordinates )
    {
        SimpleCrosshairCoordinates = CustomCrosshairCoordinates;
    }

    //TOP-PROTO CHECK THIS I REMOVED BUT MIGHT BE NEEDED!!!!
    ///** coloring */
    //if (bSetWeaponColor)
    //{
    //  WeaponMaterialInstance=Mesh.CreateAndSetMaterialInstanceConstant(0);
    //  LinColor=ColorToLinearColor(WeaponDisplayColor);
    //  WeaponMaterialInstance.SetVectorParameterValue('TeamColor',LinColor);
    //  LinColor=ColorToLinearColor(WeaponDisplayColor);
    //  WeaponMaterialInstance.SetVectorParameterValue('Paint_Color',LinColor);
    //}
    ///** coloring */

    AmmoCount=MaxAmmoCount;
    ClipCount=0;
}

/**
 * Consumes some of the ammo
 */
simulated function ConsumeAmmo( byte FireModeNum )
{
    // Subtract the Ammo
    AddAmmo(-ShotCost[FireModeNum]);
}


/**
 * This function checks to see if the weapon has any ammo available for a given fire mode.
 *
 * @param   FireModeNum     - The Fire Mode to Test For
 * @param   Amount          - [Optional] Check to see if this amount is available.  If 0 it will default to checking
 *                            for the ShotCost
 */
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
    if (Amount==0)
        return (AmmoCount >= ShotCost[FireModeNum]);
    else
        return ( AmmoCount >= Amount );
}

simulated function tick(float DeltaTime)
{
    local CPPawn        _Pawn;

    _Pawn = CPPawn( Instigator );
    
	//fixes spectator floating arms and weapon when dead
	if(_Pawn != none && _Pawn.Health <= 0)
	{
		_Pawn.HideArms(true);
		SetHidden(true);
	}

	//if(WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
	//{
	//	if(_Pawn != none && _Pawn.IsAliveAndWell())
	//	{
	//		if (_Pawn.InvManager != none) //dont do anything for spectators...
	//		{
	//			if(_Pawn.Weapon == none)
	//			{
	//				_Pawn.SetActiveWeapon(self);
	//				`Log("weapon was none - forcefully switched weapon to " @ _Pawn.Weapon.ItemName);
	//			}
	//		}
	//	}
	//}

    if(_Pawn != none)
    {
		if(_Pawn.Weapon != none)
		{
			if(_Pawn.Weapon == self)
			{
				if(_Pawn.Controller != none)
				{
					if(_Pawn.SpectateCurrentWeapon != self)
					{
						//`Log("Setting spectator weapon to " @ self);
						_Pawn.SpectateCurrentWeapon = self;
						SetHidden(false);
					}
				}
			}
		}

		if(_Pawn.Weapon != _Pawn.SpectateCurrentWeapon)
		{
			if(_Pawn.Controller == none) //none for spectators...
			{
				if(_Pawn.SpectateCurrentWeapon == self)
				{
					GotoState('WeaponPuttingDown');
					_Pawn.Weapon = _Pawn.SpectateCurrentWeapon;
					_Pawn.CurrentWeaponAttachmentClass = AttachmentClass;
					_Pawn.WeaponAttachmentChanged();
					SetupArmsAnim(); //makes the arms visible for spectators
					//_Pawn.CurrentWeaponAttachment.GotoState( 'Equipping' );

					
					
					//_Pawn.ArmsMesh[0].SetDepthPriorityGroup(SDPG_Foreground);

					//SetHidden(false);
					//Mesh.SetHidden(false);
				}
			}
		}
    }

    //SPECTATORS
    //if(_Pawn != none && _Pawn.SpectateCurrentWeapon != none && _Pawn.InvManager == none)
    //{
		
		//if(_Pawn.Weapon != none)
		//{
			//if(_Pawn.Weapon != _Pawn.SpectateCurrentWeapon)
			//{
	//if(_Pawn != none && _Pawn.SpectateCurrentWeapon != none)
 //   {
	//	if(self == _Pawn.Weapon)
	//	{
	//		if(self == _Pawn.Weapon)
	//		{
	//			if(_Pawn.Weapon == _Pawn.SpectateCurrentWeapon)
	//			{
	//				SetupArmsAnim();
	//				`Log("Im a mofo spectator using a " @ _Pawn.SpectateCurrentWeapon);
	//				`Log("PAWN CURRENT WEAPON IS " @ _Pawn.Weapon);
	//				`Log("SELF CURRENT WEAPON IS " @ self);
	//			}
	//		}
	//	}
	//	else if (_Pawn.InvManager == none)
	//	{
	//		if(WorldInfo.NetMode == NM_Client)
	//		{
	//			if(_Pawn.Weapon != _Pawn.SpectateCurrentWeapon)
	//			{
	//				_Pawn.Weapon = _Pawn.SpectateCurrentWeapon;
	//				`Log("spectator is now using " @ _Pawn.SpectateCurrentWeapon);
	//				//`Log("spectator with no weapon - now we change to spectatecurrentweapon - should be changing to " @ _Pawn.SpectateCurrentWeapon);
	//			}
	//		}
	//	}
 //   }
				//_Pawn.Weapon = _Pawn.SpectateCurrentWeapon;
				//`Log("spectator weapon is now " @ self @ " and equipping it!");
				//GotoState('WeaponEquipping');
//				_Pawn.Weapon.Activate(); 
			//}
		//}
    //}

    if(_Pawn != none && _Pawn.Weapon != none && _Pawn.Weapon != self)
    {
        //AFFECTS SPECTATORS
        if (_Pawn.InvManager == none)
        {
            //GotoState('Inactive');
            SetHidden(true);
        }
    }
}

/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(UDKPawn Holder)
{
    local vector DrawOffset, ViewOffset, FinalSmallWeaponsOffset, FinalLocation;
    local EWeaponHand CurrentHand;
    local rotator NewRotation, FinalRotation, SpecRotation;
    local PlayerController PC;
    local vector2D ViewportSize;
    local bool bIsWideScreen;
    local vector SpecViewLoc;
    local CPPawn curPawn;

	curPawn = CPPawn(Holder);

    if ( !curPawn.IsFirstPerson() )
        return;

    // Hide the weapon if hidden
    CurrentHand = GetHand();
    if ( bForceHidden || CurrentHand == HAND_Hidden)
    {
        Mesh.SetHidden(True);
        curPawn.HideArms(true);
        NewRotation = curPawn.GetViewRotation();
        SetLocation(Instigator.GetPawnViewLocation() + (HiddenWeaponsOffset >> NewRotation));
        SetRotation(NewRotation);
        SetBase(Instigator);
        return;
    }

    if(bPendingShow)
    {
        SetHidden(False);
		Mesh.SetHidden(False);
        bPendingShow = FALSE;
    }
    
    foreach LocalPlayerControllers(class'PlayerController', PC)
    {
        LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
        break;
    }
    bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.34);

    // Adjust for the current hand
    ViewOffset = PlayerViewOffset;
    FinalSmallWeaponsOffset = SmallWeaponsOffset;

    switch ( CurrentHand )
    {
        case HAND_Left:

            Mesh.SetHidden(False);
            curPawn.HideArms(False);

            Mesh.SetScale3D(default.Mesh.Scale3D * vect(1,-1,1));
            Mesh.SetRotation(rot(0,0,0) - default.Mesh.Rotation);

            if (ArmsAnimSet != None)
            {
                curPawn.ArmsMesh[0].SetScale3D(curPawn.default.ArmsMesh[0].Scale3D * vect(1,-1,1));
                curPawn.ArmsMesh[1].SetScale3D(curPawn.default.ArmsMesh[1].Scale3D * vect(1,-1,1));
            }

            ViewOffset.Y *= -1.0;
            FinalSmallWeaponsOffset.Y *= -1.0;

            break;

        case HAND_Centered:

            Mesh.SetHidden(False);
            curPawn.HideArms(False);

            ViewOffset.Y = 0.0;
            FinalSmallWeaponsOffset.Y = 0.0;

            break;

        case HAND_Right:

            Mesh.SetHidden(False);
            curPawn.HideArms(False);

            Mesh.SetScale3D(default.Mesh.Scale3D);
            Mesh.SetRotation(default.Mesh.Rotation);

            if (ArmsAnimSet != None)
            {
                curPawn.ArmsMesh[0].SetScale3D(curPawn.default.ArmsMesh[0].Scale3D);
                curPawn.ArmsMesh[1].SetScale3D(curPawn.default.ArmsMesh[1].Scale3D);
            }

            break;
        default:
            break;
    }

    //SetFOV(bIsWideScreen ? CalcFOVForAspectRatio(60.0,ViewportSize.X,ViewportSize.Y) : 60.0);
    SetFOV( 55.0f );
    ViewOffset += FinalSmallWeaponsOffset;
    //if ( bIsWideScreen )
        ViewOffset.Z += CalcFOVForAspectRatio( 5.0f, ViewportSize.X, ViewportSize.Y );

    // Calculate the draw offset
    if ( curPawn.Controller == None )
    {
        if ( CPDemoRecSpectator(PC) != None )
        {
            PC.GetPlayerViewPoint(SpecViewLoc, SpecRotation);
            DrawOffset = ViewOffset >> SpecRotation;
            DrawOffset += curPawn.WeaponBob(BobDamping, JumpDamping);
            FinalLocation = SpecViewLoc + DrawOffset;
            SetLocation(FinalLocation);
            SetBase(curPawn);

            // Add some rotation leading
            /*
            SpecRotation.Yaw = LagRot(SpecRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
            SpecRotation.Pitch = LagRot(SpecRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
            LastRotUpdate = WorldInfo.TimeSeconds;
            LastRotation = SpecRotation;
            */


            if ( bIsWideScreen )
            {
                SpecRotation += WidescreenRotationOffset;
            }
            SetRotation(SpecRotation);
            return;
        }
        else
        {
        	DrawOffset = (ViewOffset >> curPawn.GetBaseAimRotation()) + curPawn.GetEyeHeight() * vect(0,0,1);
        	if(PC.PlayerReplicationInfo.bIsSpectator)
        	{
        		curPawn.calcWalkBob(WorldInfo.TimeSeconds - LastSpectatorBobUpdate);
        		LastSpectatorBobUpdate = WorldInfo.TimeSeconds; 
        		DrawOffset += curPawn.WeaponBob(BobDamping, JumpDamping);	
    		}
		}
    }
    else
    {
        DrawOffset.Z = curPawn.GetEyeHeight();
        DrawOffset += curPawn.WeaponBob(BobDamping, JumpDamping);

        if ( CPPlayerController(curPawn.Controller) != None )
        {
            DrawOffset += CPPlayerController(curPawn.Controller).ShakeOffset >> curPawn.Controller.Rotation;
        }

        DrawOffset = DrawOffset + ( ViewOffset >> curPawn.Controller.Rotation );
    }

    // Adjust it in the world
    FinalLocation = curPawn.Location + DrawOffset;

    if(CachedLocationForIdleCheck != FinalLocation)
    {
        //fix to stop custom idle anims if the player moves
        CachedLocationForIdleCheck = FinalLocation;
        IdleTimeDialation = 0.0f;
    }

    if( CachedRotationForIdleCheck != curPawn.Rotation)
    {
        //fix to stop custom idle anims if the player rotates
        CachedRotationForIdleCheck = curPawn.Rotation;
        IdleTimeDialation = 0.0f;
    }

    SetLocation(FinalLocation);
    SetBase(curPawn);

    if (ArmsAnimSet != None)
    {
        curPawn.ArmsMesh[0].SetTranslation(DrawOffset);
        curPawn.ArmsMesh[1].SetTranslation(DrawOffset);
    }

    NewRotation = (curPawn.Controller == None) ? curPawn.GetBaseAimRotation() : curPawn.Controller.Rotation;

    // Add some rotation leading
/*
    if (curPawn.Controller != None)
    {
        FinalRotation.Yaw = LagRot(NewRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
        FinalRotation.Pitch = LagRot(NewRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
        FinalRotation.Roll = NewRotation.Roll;
    }
    else
    {
*/
        FinalRotation = NewRotation;
/*
    }
    LastRotUpdate = WorldInfo.TimeSeconds;
    LastRotation = NewRotation;
*/
    if ( bIsWideScreen )
    {
        FinalRotation += WidescreenRotationOffset;
    }
    SetRotation(FinalRotation);
    if (ArmsAnimSet != None )
    {
        curPawn.ArmsMesh[0].SetRotation(FinalRotation);
        curPawn.ArmsMesh[1].SetRotation(FinalRotation);
    }
}

//TODO MERGE WITH ONE ABOVE
//reliable server function ServerStartFire(byte FireModeNum)
//{
//  // don't allow firing if no controller (generally, because player entered/exited a vehicle while simultaneously pressing fire)
//  if (Instigator == None || Instigator.Controller != None || bAllowFiringWithoutController)
//  {
//      Super.ServerStartFire(FireModeNum);
//  }
//}

/** plays view shake on the owning client only */
simulated function ShakeView()
{
    local CPPlayerController PC;

    PC = CPPlayerController(Instigator.Controller);
    if (PC != None && LocalPlayer(PC.Player) != None && CurrentFireMode < FireCameraAnim.length && FireCameraAnim[CurrentFireMode] != None)
    {
        PC.PlayCameraAnim(FireCameraAnim[CurrentFireMode], 1.0);
    }

    // Play controller vibration
    if( PC != None && LocalPlayer(PC.Player) != None )
    {
        // only do rumble if we are a player controller
        CPPlayerController(Instigator.Controller).ClientPlayForceFeedbackWaveform( WeaponFireWaveForm );
    }
}

//OVERRIDEN BY A HACK!
///**
// * BestMode()
// * choose between regular or alt-fire
// */
//function byte BestMode()
//{
//  local byte Best;
//  if ( IsFiring() )
//      return CurrentFireMode;

//  if ( FRand() < 0.5 )
//      Best = 1;

//  if ( Best < bZoomedFireMode.Length && bZoomedFireMode[Best] != 0 )
//      return 0;
//  else
//      return Best;
//}

/**
 * Returns the current Weapon Hand
 */
simulated function EWeaponHand GetHand()
{
    local CPPlayerController PC;

    // Get the Weapon Hand from the controller or default to HAND_Right
    if (Instigator != None)
    {
        PC = CPPlayerController(Instigator.Controller);
        if (PC != None)
        {
            return PC.WeaponHand;
        }
    }
    return HAND_Right;
}

/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 */
simulated event CauseMuzzleFlash()
{
    local CPPawn P;
    local ParticleSystem MuzzleTemplate;

	if(	!bShowMuzzleFlashWhenFiring ) //need to check this when 3rd person weapons are synched properly
		return;

    if (CurrentFireMode>=2 || FireStates[CurrentFireState]==none)
        return;
    if ( WorldInfo.NetMode != NM_Client )
    {
        P = CPPawn(Instigator);
        if ( (P == None) || !P.bUpdateEyeHeight )
        {
            return;
        }
    }

    CauseMuzzleFlashLight();

    if (GetHand()!=HAND_Hidden)
    {
        if (!bMuzzleFlashAttached)
            AttachMuzzleFlash();

        if (MuzzleFlashPSC!=none)
        {
            if (FireStates[CurrentFireState].bMuzzleFlashPSCLoops[CurrentFireMode]!=0 ||
                (!MuzzleFlashPSC.bIsActive || MuzzleFlashPSC.bWasDeactivated))
            {
                MuzzleTemplate=FireStates[CurrentFireState].MuzzleFlashPSC[CurrentFireMode];
                if (MuzzleTemplate!=MuzzleFlashPSC.Template)
                {
                    MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
                }

                SetMuzzleFlashParams(MuzzleFlashPSC);
                MuzzleFlashPSC.ActivateSystem();
            }
        }
        SetTimer(FireStates[CurrentFireState].MuzzleFlashDuration[CurrentFireMode],false,'MuzzleFlashTimer');
		SetTimerLog(FireStates[CurrentFireState].MuzzleFlashDuration[CurrentFireMode],false,'MuzzleFlashTimer');
    }
}

simulated event CauseShellLaunch()
{
    local ParticleSystem Shelltemplate;

    if (GetHand()!=HAND_Hidden)
    {
        if (!bShellCasingAttached)
            AttachShellCasing();

        AttachShellCasing();

        if (ShellCasingPSC != none)
        {
            ShellTemplate=FireStates[CurrentFireState].ShellCasingPSC[CurrentFireMode];
            if (ShellTemplate!=ShellCasingPSC.Template)
                ShellCasingPSC.SetTemplate(ShellTemplate);

            ShellCasingPSC.ActivateSystem();

        }
        SetTimer(FireStates[CurrentFireState].ShellCasingDuration[CurrentFireMode],false,'ShellCasingTimer');
		SetTimerLog(FireStates[CurrentFireState].MuzzleFlashDuration[CurrentFireMode],false,'ShellCasingTimer');
    }
}

/** @return the location + offset from which to spawn effects (primarily tracers) */
simulated function vector GetEffectLocation()
{
    local vector SocketLocation;

    if (GetHand() == HAND_Hidden)
    {
        SocketLocation = Instigator.Location;
    }
    else if (SkeletalMeshComponent(Mesh) != None && EffectSockets[CurrentFireMode] != '')
    {
        if (!SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndrotation(EffectSockets[CurrentFireMode], SocketLocation))
        {
            SocketLocation = Location;
        }
    }
    else if (Mesh != None)
    {
        SocketLocation = Mesh.Bounds.Origin + (vect(45,0,0) >> Rotation);
    }
    else
    {
        SocketLocation = Location;
    }

    return SocketLocation;
}

simulated function SetWeaponOverlayFlags(CPPawn OwnerPawn)
{
    local MaterialInterface InstanceToUse;
    local byte Flags;
    local int i;
    local CPGameReplicationInfo GRI;

    if(OwnerPawn != none)
    {
        GRI = CPGameReplicationInfo(WorldInfo.GRI);
        if (GRI != None)
        {
            Flags = OwnerPawn.WeaponOverlayFlags;
            for (i = 0; i < GRI.WeaponOverlays.length; i++)
            {
                if (GRI.WeaponOverlays[i] != None && bool(Flags & (1 << i)))
                {
                    InstanceToUse = GRI.WeaponOverlays[i];
                    break;
                }
            }
        }
        if (InstanceToUse != None)
        {
            CreateOverlayMesh();
        }
        if ( OverlayMesh != None )
        {
            if (InstanceToUse != none)
            {
                for (i=0;i<OverlayMesh.GetNumElements(); i++)
                {
                    OverlayMesh.SetMaterial(i, InstanceToUse);
                }

                if (!OverlayMesh.bAttached)
                {
                    //OverlayMesh.SetHidden(Mesh.HiddenGame);
                    AttachComponent(OverlayMesh);
                }
            }
            else if ( OverlayMesh.bAttached )
            {
                DetachComponent(OverlayMesh);
                //OverlayMesh.SetHidden(true);
            }
        }
    }
}


/**
 * Remove/Detach the muzzle flash components
 */
simulated function DetachMuzzleFlash()
{
    local SkeletalMeshComponent SKMesh;

    bMuzzleFlashAttached = false;
    SKMesh = SkeletalMeshComponent(Mesh);
    if (  SKMesh != none )
    {
        if (MuzzleFlashPSC != none)
            SKMesh.DetachComponent( MuzzleFlashPSC );
    }
    MuzzleFlashPSC = None;
}

/**
  * Adjust weapon equip and fire timings so they match between PC and console
  * This is important so the sounds match up.
  */
simulated function AdjustWeaponTimingForConsole()
{
    local int i;

    For ( i=0; i<FireInterval.Length; i++ )
    {
        FireInterval[i] = FireInterval[i]/1.1;
    }
    EquipTime = EquipTime/1.1;
    PutDownTime = PutDownTime/1.1;
}
//double check this before discarding
///**
// * Access to HUD and Canvas.
// * Event always called when the InventoryManager considers this Inventory Item currently "Active"
// * (for example active weapon)
// *
// * @param HUD         - HUD with canvas to draw on
// */
//simulated function ActiveRenderOverlays( HUD H )
//{
//  local CPPlayerController PC;

//  PC = CPPlayerController(Instigator.Controller);
//  if ( (PC != None) && !PC.bNoCrosshair )
//  {
//      CrossHairCoordinates = PC.bSimpleCrosshair ? SimpleCrosshairCoordinates : default.CrosshairCoordinates;
//      DrawWeaponCrosshair( H );
//  }
//}

simulated function AnimNodeSequence GetArmAnimNodeSeq()
{
    local CPPawn P;

    P = CPPawn(Instigator);
    if (P != None && P.ArmsMesh[0] != None)
    {
        return AnimNodeSequence(P.ArmsMesh[0].Animations);
    }

    return None;
}

/** @return whether the weapon's rotation is allowed to lag behind the holder's rotation */
simulated function bool ShouldLagRot()
{
    return false;
}

simulated function int LagRot(int NewValue, int LastValue, float MaxDiff, int Index)
{
    local int RotDiff;
    local float LeadMag, DeltaTime;

    if ( NewValue ClockWiseFrom LastValue )
    {
        if ( LastValue > NewValue )
        {
            LastValue -= 65536;
        }
    }
    else
    {
        if ( NewValue > LastValue )
        {
            NewValue -= 65536;
        }
    }

    DeltaTime = WorldInfo.TimeSeconds - LastRotUpdate;
    RotDiff = NewValue - LastValue;
    if ( (RotDiff == 0) || (OldRotDiff[Index] == 0) )
    {
        LeadMag = ShouldLagRot() ? OldLeadMag[Index] : 0.0;
        if ( (RotDiff == 0) && (OldRotDiff[Index] == 0) )
        {
            OldMaxDiff[Index] = 0;
        }
    }
    else if ( (RotDiff > 0) == (OldRotDiff[Index] > 0) )
    {
        if (ShouldLagRot())
        {
            MaxDiff = FMin(1, Abs(RotDiff)/(12000*DeltaTime)) * MaxDiff;
            if ( OldMaxDiff[Index] != 0 )
                MaxDiff = FMax(OldMaxDiff[Index], MaxDiff);

            OldMaxDiff[Index] = MaxDiff;
            LeadMag = (NewValue > LastValue) ? -1* MaxDiff : MaxDiff;
        }
        else
        {
            LeadMag = 0;
        }
        if ( DeltaTime < 1/RotChgSpeed )
        {
            LeadMag = (1.0 - RotChgSpeed*DeltaTime)*OldLeadMag[Index] + RotChgSpeed*DeltaTime*LeadMag;
        }
        else
        {
            LeadMag = 0;
        }
    }
    else
    {
        LeadMag = 0;
        OldMaxDiff[Index] = 0;
        if ( DeltaTime < 1/ReturnChgSpeed )
        {
            LeadMag = (1 - ReturnChgSpeed*DeltaTime)*OldLeadMag[Index] + ReturnChgSpeed*DeltaTime*LeadMag;
        }
    }
    OldLeadMag[Index] = LeadMag;
    OldRotDiff[Index] = RotDiff;

    return NewValue + LeadMag;
}

reliable client function ClientWeaponThrown()
{
    bJustSwitchedFireMode=false;
    bJustDropped=true;

    Super.ClientWeaponThrown();
}

simulated function CreateOverlayMesh()
{
    //local SkeletalMeshComponent SKM_Source, SKM_Target;
    //local StaticMeshComponent STM;
    //local CPPawn P;

    //if (OverlayMesh == None && WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
    //{
    //    if ( WorldInfo.NetMode != NM_Client )
    //    {
    //        P = CPPawn(Instigator);
    //        if ( (P == None) || !P.bUpdateEyeHeight )
    //        {
    //            return;
    //        }
    //    }

    //    OverlayMesh = new(outer) Mesh.Class;
    //    if (OverlayMesh != None)
    //    {
    //        OverlayMesh.SetScale(1.00);
    //        OverlayMesh.SetOwnerNoSee(Mesh.bOwnerNoSee);
    //        OverlayMesh.SetOnlyOwnerSee(true);
    //        OverlayMesh.SetDepthPriorityGroup(SDPG_Foreground);
    //        OverlayMesh.CastShadow = false;

    //        SKM_Target = SkeletalMeshComponent(OverlayMesh);
    //        if ( SKM_Target != none )
    //        {
    //            SKM_Source = SkeletalMeshComponent(Mesh);

    //            SKM_Target.SetSkeletalMesh(SKM_Source.SkeletalMesh);
    //            SKM_Target.AnimSets = SKM_Source.AnimSets;
    //            SKM_Target.SetParentAnimComponent(SKM_Source);
    //            SKM_Target.bUpdateSkelWhenNotRendered = false;
    //            SKM_Target.bIgnoreControllersWhenNotRendered = true;

    //            if (UDKSkeletalMeshComponent(SKM_Target) != none)
    //            {
    //                UDKSkeletalMeshComponent(SKM_Target).SetFOV(UDKSkeletalMeshComponent(SKM_Source).FOV);
    //            }
    //        }
    //        else if ( StaticMeshComponent(OverlayMesh) != none )
    //        {
    //            STM = StaticMeshComponent(OverlayMesh);
    //            STM.SetStaticMesh(StaticMeshComponent(Mesh).StaticMesh);
    //            STM.SetScale3D(Mesh.Scale3D);
    //            STM.SetTranslation(Mesh.Translation);
    //            STM.SetRotation(Mesh.Rotation);
    //        }
    //        OverlayMesh.SetHidden(Mesh.HiddenGame);
    //    }
    //    else
    //    {
    //        `Warn("Could not create Weapon Overlay mesh for" @ self @ Mesh);
    //    }
    //}
}

/**
* Called when the pawn is changing weapons
*/
simulated function PerformWeaponChange()
{
	//`Log("PerformWeaponChange");
    if ( CPPawn(Instigator) != None )
    {
        if ( Instigator.IsLocallyControlled() )
        {
            CPPawn(Instigator).WeaponChanged(self);
			//`Log("WeaponChanged");
        }
	// VERY BROKEN - CAUSES INFINITE LOOP!
   //     else if ( Instigator.Controller == None )// If the controller has not been replicated, try again later
   //     {
			//`Log("SetTimer PerformWeaponChange");
   //         SetTimer(0.01, false, 'PerformWeaponChange');
			//SetTimerLog(0.01,false,'PerformWeaponChange');
   //     }
    }
}

client reliable simulated function ClientEndFire(byte FireModeNum)
{
    if (Role != ROLE_Authority)
    {
        ClearPendingFire(FireModeNum);
        EndFire(FireModeNum);
    }
}

/**
 * Returns a weight reflecting the desire to use the
 * given weapon, used for AI and player best weapon
 * selection.
 *
 * @param   Weapon W
 * @return  Weapon rating (range -1.f to 1.f)
 */
simulated function float GetWeaponRating()
{
    return 0;
}

//TODO do we need this??
//simulated static function DrawKillIcon(Canvas Canvas, float ScreenX, float ScreenY, float HUDScaleX, float HUDScaleY)
//{
//  local color CanvasColor;

//  // save current canvas color
//  CanvasColor = Canvas.DrawColor;

//  // draw weapon shadow
//  Canvas.DrawColor = class'CPHUD'.default.BlackColor;
//  Canvas.DrawColor.A = CanvasColor.A;
//  Canvas.SetPos( ScreenX - 2, ScreenY - 2 );
//  Canvas.DrawTile(class'CPHUD'.default.AltHudTexture, 4 + HUDScaleX * 96, 4 + HUDScaleY * 64, default.IconCoordinates.U, default.IconCoordinates.V, default.IconCoordinates.UL, default.IconCoordinates.VL);

//  // draw the weapon icon
//  Canvas.DrawColor =  class'CPHUD'.default.WhiteColor;
//  Canvas.DrawColor.A = CanvasColor.A;
//  Canvas.SetPos( ScreenX, ScreenY );
//  Canvas.DrawTile(class'CPHUD'.default.AltHudTexture, HUDScaleX * 96, HUDScaleY * 64, default.IconCoordinates.U, default.IconCoordinates.V, default.IconCoordinates.UL, default.IconCoordinates.VL);
//  Canvas.DrawColor = CanvasColor;
//}

/** called on both Instigator's current weapon and its pending weapon (if they exist)
 * @return whether Instigator is allowed to switch to NewWeapon
 */
simulated function bool AllowSwitchTo(Weapon NewWeapon)
{
    return true;
}

/**
 * This function is called whenever you attempt to reselect the same weapon
 */
reliable server function ServerReselectWeapon();

/**
 * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
 */
simulated function bool bReadyToFire()
{
    return true;
}

/**
  * Force streamed textures to be loaded.  Used to get MIPS streamed in before weapon comes up
  * bForcePreload if true causes streamed textures to be force loaded, if false, clears force loading
  */
simulated function PreloadTextures(bool bForcePreload)
{
    if ( UDKSkeletalMeshComponent(Mesh) != None )
    {
        UDKSkeletalMeshComponent(Mesh).PreloadTextures(bForcePreload, WorldInfo.TimeSeconds + 2);
    }
}

simulated event Destroyed()
{
	local CPPawn TAP;
    TAP=CPPawn(Instigator);

    SetLaserDotStatus(false); //merged

	if(TAP != none)
	{
		TAP.HideArms(True);
	}

    if (Instigator != None && Instigator.IsHumanControlled() && Instigator.IsLocallyControlled())
    {
        PreloadTextures(false);
    }
    super.Destroyed();
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
    if (Instigator != None && Instigator.IsHumanControlled() && Instigator.IsLocallyControlled())
    {
        PreloadTextures(false);
    }

    Super.DropFrom(StartLocation, StartVelocity);
}

/**
 * returns true if this weapon is currently lower priority than InWeapon
 * used to determine whether to switch to InWeapon
 * this is the server check, so don't check clientside settings (like weapon priority) here
 */
simulated function bool ShouldSwitchTo(CPWeapon InWeapon)
{
    // if we should, but can't right now, tell InventoryManager to try again later
    if (IsFiring() || DenyClientWeaponSet())
    {
        CPInventoryManager(InvManager).RetrySwitchTo(InWeapon);
        return false;
    }
    else
    {
        return true;
    }
}


/**
 * called every time owner takes damage while holding this weapon - used by shield gun
 */
function AdjustPlayerDamage( out int Damage, Controller InstigatedBy, Vector HitLocation,
                 out Vector Momentum, class<DamageType> DamageType)
{
}

simulated function bool EnableFriendlyWarningCrosshair()
{
    return true;
}




/**
* returns end trace position for instantfire()
*/
simulated function vector InstantFireEndTrace(vector StartTrace)
{
    return StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange();
}

simulated function bool CoversScreenSpace(vector ScreenLoc, Canvas Canvas)
{
    return ( (ScreenLoc.X > (1-WeaponCanvasXPct)*Canvas.ClipX)
        && (ScreenLoc.Y > (1-WeaponCanvasYPct)*Canvas.ClipY) );
}

/**
 * Sets the timing for equipping a weapon.
 * The WeaponEquipped event is trigged when expired
 */
simulated function TimeWeaponEquipping()
{
	if(instigator != none && instigator.Mesh != none)
	{
		// The weapon is equipped, attach it to the mesh.
		AttachWeaponTo( Instigator.Mesh );
		CPPawn(Instigator).HideArms(false);
		// Play the animation
		PlayWeaponEquip();

		SetTimer( GetEquipTime() , false, 'WeaponEquipped');
		SetTimerLog(GetEquipTime(),false,'WeaponEquipped');
	}
}

simulated function WeaponEquipped() 
{
	if( bWeaponPutDown )
	{
		PutDownWeapon();
		return;
	}
	GotoState('Active');
}



simulated function float GetEquipTime()
{
    local float ETime;

    ETime = EquipTime>0 ? EquipTime : 0.01;

	if(ETime != 0.01)
	{
		if ( PendingFire(0) || PendingFire(1) )
		{
			ETime += 0.25;
		}
	}
    return ETime;
}


//simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
//{
//  local bool bFixMomentum;
//  local KActorFromStatic NewKActor;
//  local StaticMeshComponent HitStaticMesh;

//  if ( Impact.HitActor != None )
//  {
//      if ( Impact.HitActor.bWorldGeometry )
//      {
//          HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
//          if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
//          {
//              NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
//              if ( NewKActor != None )
//              {
//                  Impact.HitActor = NewKActor;
//              }
//          }
//      }
//      if ( !Impact.HitActor.bStatic && (Impact.HitActor != Instigator) )
//      {
//          if ( Impact.HitActor.Role == ROLE_Authority && Impact.HitActor.bProjTarget
//              && !WorldInfo.GRI.OnSameTeam(Instigator, Impact.HitActor)
//              && Impact.HitActor.Instigator != Instigator
//              && PhysicsVolume(Impact.HitActor) == None )
//          {
//              HitEnemy++;
//              LastHitEnemyTime = WorldInfo.TimeSeconds;
//          }
//          if ( (CPPawn(Impact.HitActor) == None) && (InstantHitMomentum[FiringMode] == 0) )
//          {
//              InstantHitMomentum[FiringMode] = 1;
//              bFixMomentum = true;
//          }
//          Super.ProcessInstantHit(FiringMode, Impact, NumHits);
//          if (bFixMomentum)
//          {
//              InstantHitMomentum[FiringMode] = 0;
//          }
//      }
//  }
//}

simulated function Activate()
{
	SetupArmsAnim();
    super.Activate();
}

/**
 * WeaponCalcCamera allows a weapon to adjust the pawn's controller's camera.
 * ~WillyG - modified to include loc/rot of socket b_camera
 */
simulated function WeaponCalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot)
{
    local CPPawn cpp;
    //local vector tempLoc;
    //local rotator tempRot;
    local SkeletalMeshSocket meshSock;
    local CPPlayerController CPPlayerController;


    if(WorldInfo.NetMode == NM_DedicatedServer)
        return;

    cpp = CPPawn(Instigator);
    if(cpp == none)
        return;
    if(cpp.ArmsMesh[0] == none)
        return;

    // If we are not a spectator, continue with the weapon socket
    foreach LocalPlayerControllers(class'CPPlayerController', CPPlayerController)
    {
        if(CPPlayerController != none)
        {
            if(!CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bOnlySpectator || !CPPlayerReplicationInfo(CPPlayerController.PlayerReplicationInfo).bIsSpectator)
            {
                if(cpp.ArmsMesh[0].GetSocketByName('b_camera') != none)
                {
                    meshSock = cpp.ArmsMesh[0].GetSocketByName('b_camera');
                    if (meshSock!=none && cpp.bArmsAttached)
                    {
                        //Disabled the camera bone completely for now.
                        //cpp.ArmsMesh[0].GetSocketWorldLocationAndRotation('b_camera',tempLoc,tempRot,1);
                        //out_CamLoc+=tempLoc;
                        //out_CamRot+=tempRot;
                    }
                }
            }
        }
    }
}

//TOP PROTO FUNCTION MERGE END


//TODO MERGE WITH OUR STATE
//simulated state Active
//{
//  /**
//   * We override BeginFire() so that we can check for zooming
//   */
//  simulated function BeginFire( Byte FireModeNum )
//  {
//      if (WorldInfo.NetMode != NM_DedicatedServer)
//      {
//          if ( CheckZoom(FireModeNum) )
//          {
//              return;
//          }
//      }
//      Super.BeginFire(FireModeNum);
//  }

//  simulated function bool ShouldLagRot()
//  {
//      return true;
//  }

//  reliable server function ServerStartFire( byte FireModeNum )
//  {
//      // Check to see if the weapon is active, but not the current weapon.  If it is, force the
//      // client to reset
//      if (Instigator != none && Instigator.Weapon != self)
//      {
//          `Log("########## WARNING: Server Received ServerStartFire on "$self$" while in the active state but not current weapon.  Attempting Realignment");
//          `log("##########        : "$Instigator.PlayerReplicationInfo.PlayerName);
//          `log("##########        : "$Instigator.Weapon@Instigator.Weapon.GetStateName());
//          CPInventoryManager(InvManager).ClientSyncWeapon(Instigator.Weapon);
//          Global.ServerStartFire(FireModeNum);
//      }
//      else
//      {
//          Global.ServerStartFire(FireModeNum);
//      }
//  }



reliable server function UpdateClipAndAmmoCountToClient()
{
	RecieveUpdatesToClipAndAmmoCount(ClipCount, AmmoCount, CurrentFireState);
}

reliable client function RecieveUpdatesToClipAndAmmoCount(int clip, int ammo, byte firemode)
{
	ClipCount = clip;
	AmmoCount = ammo;
	CurrentFireState = firemode;
}


//~WillyG: fixing putdown anim
simulated function TimeWeaponPutDown()
{
    PlayWeaponPutDown();
    super.TimeWeaponPutDown();
}


// simulated state Equipping
// {
    // simulated event BeginState( name PreviousStateName )
    // {
        // local CPPawn _Pawn;
        // local CPWeaponAttachment _WeaponAttachment;
        // if( Instigator == None)
        // {
            // `Log("@@ error_05");
            // return;
        // }
        // _Pawn = CPPawn(Instigator);
        // if(_Pawn.CurrentWeaponAttachment == None)
        // {
            // `Log("@@ error_06");
            // return;
        // }
        // _WeaponAttachment = _Pawn.CurrentWeaponAttachment;
        
        // _WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.EquipWeapAnim, _WeaponAttachment.WeaponClass.default.EquipTime );
        // Instigator.SetTimer( _WeaponAttachment.WeaponClass.default.EquipTime, false, 'EquippingFinished' );
    // }
// }

// simulated state PuttingDown
// {
    // simulated event BeginState( name PreviousStateName )
    // {
        // local CPPawn _Pawn;
        // local CPWeaponAttachment _WeaponAttachment;
        // if( Instigator == None)
        // {
            // `Log("@@ error_03");
            // return;
        // }
        // _Pawn = CPPawn(Instigator);
        // if(_Pawn.CurrentWeaponAttachment == None)
        // {
            // `Log("@@ error_04");
            // return;
        // }
        // _WeaponAttachment = _Pawn.CurrentWeaponAttachment;
        
        // _WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.PutdownWeapAnim, _WeaponAttachment.WeaponClass.default.PutDownTime );

        // _Pawn.SetTimer( _WeaponAttachment.WeaponClass.default.PutdownTime, false, 'PuttingDownFinished' ); //x
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


/**
 * This function is called to put a weapon down
 */
simulated function PutDownWeapon()
{
    local CPPawn TAP;

    //`Log("PutDownWeapon");

    TAP=CPPawn(Instigator);
    if(TAP==none)
    {
        //`Log("PutDownWeapon TAP IS NONE!");
        return;
    }

    //Mesh.SetOwnerNoSee(false);
    //TAP.ArmsMesh[0].SetOwnerNoSee(false);
    //TAP.ArmsMesh[1].SetOwnerNoSee(false);

    IdleTimeDialation = 0.0f; //reset the idle timer when we put a weapon down
    GotoState('WeaponPuttingDown');
}

exec function devIdleAnim( int devIdleIndex)
{
    if(devIdleIndex == 0 )
    {
        `Log("devIdleAnim the default idle animation always plays....");
        return;
    }

    if(devIdleIndex > WeaponIdleAnims.Length - 1)
    {
        `Log("devIdleAnim no animation at that index number");
        return;
    }


    if (ArmIdleAnims.Length>devIdleIndex && ArmsAnimSet!=none && WeaponIdleAnims[devIdleIndex] != '' && ArmIdleAnims[devIdleIndex] != '')
    {
        PlayWeaponAnimation(WeaponIdleAnims[devIdleIndex],0.0);
        PlayArmAnimation(ArmIdleAnims[devIdleIndex],0.0);
    }
    else
    {
        `Log("CPWeapon::devIdleAnim");
        `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
        `Log("ARM ANIMATION IS " @ ArmIdleAnims[devIdleIndex]);
        `Log("WEP ANIMATION IS " @ WeaponIdleAnims[devIdleIndex]);
    }
}

unreliable client function SetTimerLog(float timerTime,bool IsItLooping, name NameOfFunction)
{
	if( blnWeaponLogging )
	{
		if(IsItLooping)
		{
			`Log("TIMER SET: " @ NameOfFunction @"LOOPING t:" @ timerTime @ "W:" @ self);
		}
		else
		{
			`Log("TIMER SET: " @ NameOfFunction @ "t:" @ timerTime @ "W:" @ self);
		}
	}
}

unreliable client function ClearTimerLog(name NameOfFunctionLooping)
{
	if( blnWeaponLogging )
	{
		`Log("TIMER CLEARED: " @ NameOfFunctionLooping @ "W:" @ self);
	}
}

simulated state Reloading
{
    /**
     * Called when the current 'reloading cycle' has been finished.
     * @note For example a shotgun will load multiple single shells, each shell reload is a cycle.
     */
    simulated function FinishedReloading()
    {
		local CPPawn _Pawn;
        
		ClearTimer( 'FinishedReloading' );
		ClearTimerLog('FinishedReloading');
	
		_Pawn=CPPawn(Instigator);

		//Fix for spectator ammo counts going out of sync??
		if(_Pawn != none)
		{
			AmmoCount = MaxAmmoCount;
			if ( Role == ROLE_Authority && ClipCount > 0 )
			{
			    ClipCount--;
			}

			if ( bWeaponPutDown )
				PutDownWeapon();
			else
            {
                GotoState( 'Active' );
            }
		}
    }

    //simulated function TimerEarlyReloadNotify();

    simulated event BeginState( name PreviousStateName )
    {
        local float         _ReloadTime;
        local name          _ArmAnim, _ReloadAnim;
        local SoundCue      _ReloadSound;
        local bool          _Empty;
        local CPPawn        _Pawn;
        local CPWeaponAttachment _WeaponAttachment;

        if ( bIssuedReload )
        {
            bIssuedReload = false;
            StopReload();
        }

        bReloadFireToggle=false;

        _Empty = AmmoCount == 0;
        SetInstigatorWeaponState( _Empty ? EWS_ReloadingEmpty : EWS_Reloading );

        _ReloadTime = ( _Empty && ReloadEmptyTime > 0.0f ) ? ReloadEmptyTime : ReloadTime;
        _ArmAnim = ( _Empty && ArmsReloadEmptyAnim != '' ) ? ArmsReloadEmptyAnim : ArmsReloadAnim;
        _ReloadAnim = ( _Empty && WeaponReloadEmptyAnim != '' ) ? WeaponReloadEmptyAnim : WeaponReloadAnim;
        _ReloadSound = ( _Empty && WeaponReloadEmptySnd != none ) ? WeaponReloadEmptySnd : WeaponReloadSnd;;

        if (_ArmAnim != '' && ArmsAnimSet != none && _ReloadAnim != '')
        {
            PlayWeaponAnimation( _ReloadAnim, _ReloadTime );
            PlayArmAnimation( _ArmAnim, _ReloadTime );
            if( Instigator == None)
            {
                `Log("@@ error_17");
                return;
            }
            _Pawn = CPPawn(Instigator);
            if(_Pawn.CurrentWeaponAttachment == None)
            {
                `Log("@@ error_18");
                return;
            }
            _WeaponAttachment = _Pawn.CurrentWeaponAttachment;  
            _WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.ReloadAnim, _WeaponAttachment.WeaponClass.default.ReloadTime );
        }
        else
        {
            `Log("CPWeapon::BeginState::Reloading for " @self);
            `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
            `Log("ARM ANIMATION IS " @ _ArmAnim);
            `Log("WEP ANIMATION IS " @ _ReloadAnim);
        }

        if ( _ReloadSound != none )
            WeaponPlaySound( _ReloadSound );

        SetTimer( _ReloadTime, false, 'FinishedReloading' );
		SetTimerLog(_ReloadTime,false,'FinishedReloading');
        //SetTimer( FClamp( _ReloadTime * ReloadRefillTimePct, 0.1f, _ReloadTime ), false, 'TimerEarlyReloadNotify' );
		//SetTimerLog(FClamp( _ReloadTime * ReloadRefillTimePct, 0.1f, _ReloadTime ),false,'TimerEarlyReloadNotify');
    }

    simulated event EndState( name NextStateName )
    {
        local EWeaponState      _WeaponState;

        _WeaponState = GetInstigatorWeaponState();
        if ( _WeaponState == EWS_Reloading || _WeaponState == EWS_ReloadingEmpty || _WeaponState == EWS_ReloadingEnd )
            SetInstigatorWeaponState( EWS_Active );

        ClearTimer( 'FinishedReloading' );
		ClearTimerLog('FinishedReloading');
        //ClearTimer( 'TimerEarlyReloadNotify' );
		//ClearTimerLog('TimerEarlyReloadNotify');

        SetTimer(0.4, false, 'AutoFire');
		SetTimerLog(0.4,false,'AutoFire');
    }

    simulated function Activate();

    simulated function bool IsReloading()
    {
        return true;
    }

    simulated function bool ReadyToFire( bool bFinished )     // for AI
    {
        return false;
    }

    simulated function bool DenyClientWeaponSet()
    {
        return true;
    }

    simulated function bool TryPutDown()
    {
        bWeaponPutDown = true;
        GotoState( 'Active' );
        return false;
    }

    simulated function bool CanThrow()
    {
        return true;
    }
}

simulated state FireModeSwitching
{
    simulated function FinishedFireModeSwitch()
    {
        SetFireState(PendingFireState);
        bJustSwitchedFireMode=true;
        if (bWeaponPutDown)
            PutDownWeapon();
        else
        {
            GotoState('Active');
        }
    }

    simulated function BeginState(name PreviousStateName)
    {
        if (FireStates.Length<(CurrentFireState+1))
            PendingFireState=0;
        else
            PendingFireState=CurrentFireState+1;
        TimeWeaponFireModeSwitch();
    }

    simulated function EndState(name NextStateName)
    {
        if (IsTimerActive(nameof(FinishedFireModeSwitch)))
            PendingFireState=CurrentFireState;
    }

    simulated function bool IsFireModeSwitch()
    {
        return true;
    }

    simulated function StartFire(byte FireModeNum)
    {
        IdleTimeDialation = 0.0f; //reset the idle timer when we fire
    }

    simulated function bool ReadyToFire(bool bFinished)     // for AI
    {
        return false;
    }

    simulated function Activate()
    {
    }

    simulated function bool DenyClientWeaponSet()
    {
        return true;
    }

    simulated function bool TryPutDown()
    {
        bWeaponPutDown=true;
        return true;
    }

    simulated function bool CanThrow()
    {
        return false;
    }
}

simulated state WeaponEmptyFiring
{
    simulated event bool IsFiring()
    {
        return true;
    }

    //simulated function EmptyFiringEndTimer()
    //{
    //    HandleFinishedFiring();
    //}

    simulated event BeginState(name PreviousStateName)
    {
        SetInstigatorWeaponState(EWS_FireEmpty);
        if ( PreviousStateName != 'SwitchingLaser' )
            PlayWeaponEmptyFire();

        SetTimer(FireWeaponEmptyTime,false,nameof(EmptyFiringEndTimer));
		SetTimerLog(FireWeaponEmptyTime,false,nameof(EmptyFiringEndTimer));
    }

    simulated function bool DenyClientWeaponSet()
    {
        return true;
    }

    simulated event EndState( Name NextStateName )
    {
        SetInstigatorWeaponState( EWS_Active );
    }
}

simulated state Active
{
    simulated function BeginFire(byte FireModeNum)
    {
        if (DenyWeaponFunctionality() || FireModeNum>=2 || FireStates[CurrentFireState]==none)
            return;
        if (FireStates[CurrentFireState].FireType[FireModeNum]==ETFT_None)
            return;
        if (!bDeleteMe && Instigator!=none)
        {
            Global.BeginFire(FireModeNum);
            if (PendingFire(FireModeNum))
            {
                if (IsPendingFireRelease())
                    return;
                else
                    SetPendingFireRelease();
                if (HasAmmo(FireModeNum))
                    SendToFiringState(FireModeNum);
                else if (!Instigator.bNoWeaponFiring && FireWeaponEmptyTime>0.0)
                    GotoState('WeaponEmptyFiring');
            }
        }
    }

    simulated function PlayWeaponAnimation( Name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
    {
        Global.PlayWeaponAnimation(Sequence,fDesiredDuration,bLoop,SkelMesh);
        //ClearTimer('OnAnimEnd');
		//ClearTimerLog('OnAnimEnd');
        //if (!bLoop)
        //{
        //  SetTimer(fDesiredDuration,false,'OnAnimEnd');
		//	SetTimerLog(fDesiredDuration,false,'OnAnimEnd');
        //}
    }

    simulated function ChangeVisibility(bool bIsVisible)
    {
        Global.ChangeVisibility(bIsVisible);
    }

    simulated function bool ShouldLagRot()
    {
        return true;
    }

    reliable server function ServerStartFire( byte FireModeNum )
    {
        // Check to see if the weapon is active, but not the current weapon.  If it is, force the
        // client to reset
        if (Instigator != none && Instigator.Weapon != self)
        {
            `Log("########## WARNING: Server Received ServerStartFire on "$self$" while in the active state but not current weapon.  Attempting Realignment");
            `log("##########        : "$Instigator.PlayerReplicationInfo.PlayerName);
            `log("##########        : "$Instigator.Weapon@Instigator.Weapon.GetStateName());
            CPInventoryManager(InvManager).ClientSyncWeapon(Instigator.Weapon);
            Global.ServerStartFire(FireModeNum);
        }
        else
        {
            Global.ServerStartFire(FireModeNum);
        }
    }

    simulated function BeginReload()
    {
        IdleTimeDialation = 0.0f; //reset the idle timer when we reload

        if (DenyWeaponFunctionality())
            return;
        if (!bDeleteMe && Instigator!=none)
        {
            Global.BeginReload();
            if (PendingReload() && NeedsReload())
                SendToReloadState();
        }
    }

    simulated function BeginFireModeSwitch()
    {
        IdleTimeDialation = 0.0f; //reset the idle timer when we switch fire mode
        if (DenyWeaponFunctionality())
            return;
        if (!bDeleteMe && Instigator!=none)
        {
            Global.BeginFireModeSwitch();
            if (PendingFireModeSwitch())
                SendToFireModeSwitchState();
        }
    }

    // ~WillyG: Override to allow some longer anims (such as grenade throw) to play out
    simulated function bool CanIdleInterrupt(name PreviousStateName)
    {
        return true;
    }

    simulated function BeginState(name PreviousStateName)
    {   
       `Log("@@ "$self.Name$"::Active::BeginState"); 
        if ( PreviousStateName == 'SwitchingLaser' )
            return;

        bIssuedReload=false;

        if (WorldInfo.NetMode==NM_Standalone || WorldInfo.NetMode==NM_ListenServer || Role<ROLE_Authority)
        {
            if (bForceSwitchWhenEmpty && Instigator!=none && Instigator.Controller!=none && !HasAnyAmmo())
            {
                if (CPPlayerController(CPPawn(Instigator).Controller)!=none)
                    CPPlayerController(CPPawn(Instigator).Controller).ClientAutoSwitch(true);
                else
                    Instigator.Controller.ClientSwitchToBestWeapon(true);
            }
        }

        if (Role==ROLE_Authority)
        {
            SetLaserDotStatus(bLaserDotStatus);
            CacheAIController();
        }
        if (AmmoCount==0 && NeedsReload())
        {
            if (bForceReloadWhenEmpty || ShouldAutoReload())
            {
                bIssuedReload=true;
                BeginReload();
                return;
            }
        }

        if (bWeaponPutDown)
        {
            `LogInv("Weapon put down requested during transition, put it down now");
            PutDownWeapon();
        }
        else if (!HasAnyAmmo())
            WeaponEmpty();
        else
        {
            if (PendingReload() && NeedsReload())
                BeginReload();
            else if (PendingFireModeSwitch())
                BeginFireModeSwitch();
/*
            else
            {
                for (i=0;i<GetPendingFireLength();i++)
                {
                    if (PendingFire(i))
                    {
                        BeginFire(i);
                        break;
                    }
                }
            }
*/
        }
        //TODO look at this code
        if (InvManager!=none && InvManager.LastAttemptedSwitchToWeapon!=none)
        {
            if (InvManager.LastAttemptedSwitchToWeapon!=self)
                InvManager.LastAttemptedSwitchToWeapon.ClientWeaponSet(true);
            InvManager.LastAttemptedSwitchToWeapon=none;
        }

		PlayWeaponAnimation(WeaponIdleAnims[0],0.0);//fire off initial idle animation
    }
    
    simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
    {
        if (/*WorldInfo.NetMode!=NM_DedicatedServer &&*/ WeaponIdleAnims.Length>0)  //this stops some idle offset issues
        {
            IdleTimeDialation += 1;
            //`Log("self=" @self);
            //`Log("self.name=" @self.MenuItemName);

            if(IdleTimeDialation < 10.0)
            {
                //always play idle0 unless we are inactive a while
                if(IdleIndex != 0)
                    IdleIndex=0;
            }
            else
            {
                //must work with spectators too.
                if(IdleIndex + 1 < WeaponIdleAnims.Length)
                {
                    IdleIndex= IdleIndex + 1;
                }
                else
                {
                    IdleIndex = 0;
                }

                IdleTimeDialation = 0.0f;
                //`Log("idleindex is now " @ IdleIndex);
            }


            if (ArmIdleAnims.Length>IdleIndex && ArmsAnimSet!=none && WeaponIdleAnims[IdleIndex] != '' && ArmIdleAnims[IdleIndex] != '')
            {
				if(Instigator.Controller == none)
				{
					if(CPPawn(Instigator).SpectateCurrentWeapon == self)
					{
						//`Log("Play an idle for " @self);
						PlayWeaponAnimation(WeaponIdleAnims[IdleIndex],0.0);
						PlayArmAnimation(WeaponIdleAnims[IdleIndex],0.0);
					}
					else
					{
						//`log("sending rogue weapon to inactive state! " @self);
						GotoState('Inactive');
					}
				}
				else
				{
					PlayWeaponAnimation(WeaponIdleAnims[IdleIndex],0.0);
					PlayArmAnimation(WeaponIdleAnims[IdleIndex],0.0);
				}
            }
            else
            {
                `Log("CPWeapon::OnAnimEnd::Active");
                `LOG("ANIMATION ERROR WARNING ArmsAnimSet=" @ArmsAnimSet);
                `Log("ARM ANIMATION IS " @ ArmIdleAnims[IdleIndex]);
                `Log("WEP ANIMATION IS " @ WeaponIdleAnims[IdleIndex]);
            }
        }
    }
    
    simulated event EndState(name PreviousStateName)
    {
        `Log("@@ "$self.Name$"::Active::BeginState");  
        Super.EndState(PreviousStateName);
    }
}

auto simulated state Inactive
{
    simulated event BeginState(name PreviousStateName)
    {
        local PlayerController PC;
        
        `Log("@@ "$self.Name$"::Inactive::BeginState");
        if (Role==ROLE_Authority)
            SetLaserDotStatus(false);
        if (bDestroyWhenEmpty && !HasAnyAmmo())
        {
            bEmptyDestroyRequest=true;
            if (Instigator!=none && Instigator.InvManager!=none)
                Instigator.InvManager.RemoveFromInventory(Self);
            Destroy();
        }

        if ( Instigator != None )
        {
          PC = PlayerController(Instigator.Controller);
          if ( PC != None && LocalPlayer(PC.Player)!= none )
          {
              PC.SetFOV(PC.DefaultFOV);
          }
        }
        super.BeginState(PreviousStateName);
    }
    
    simulated event EndState(name PreviousStateName)
    {
        `Log("@@ "$self.Name$"::Inactive::EndState");
    }

    /**
     * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
     */
    simulated function bool bReadyToFire()
    {
        return false;
    }

	reliable server function ServerStartFire(byte FireModeNum)
	{
		`Log("debug serverstartfire fix for inactive state log - what weapon tried to fire? " @self);
		super.ServerStartFire(FireModeNum);
	}
}

simulated state Hacking extends Inactive
{
    simulated function PlayIdleAnimation()
    {
        local CPPawn    _Pawn;
        local CPWeaponAttachment _WeaponAttachment;
        if( Instigator == None)
        {
            `Log("@@ error_13");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_14");
            return;
        }
        
        _WeaponAttachment = _Pawn.CurrentWeaponAttachment; 
        Mesh.SetHidden( true );
        _WeaponAttachment.PlayTopHalfAnimation( _WeaponAttachment.HackAnim,,,, true );
    } 
    
    simulated event BeginState( name PreviousStateName )
    {
        local CPPawn    _Pawn;
        local CPWeaponAttachment _WeaponAttachment;
        
        if( Instigator == None)
        {
            `Log("@@ error_11");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_12");
            return;
        } 
        _WeaponAttachment = _Pawn.CurrentWeaponAttachment;
        
        PlayWeaponPutDown();
        _WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.PutdownWeapAnim, _WeaponAttachment.WeaponClass.default.PutDownTime );
        SetTimer( _WeaponAttachment.WeaponClass.default.PutDownTime, false, 'PlayIdleAnimation' );
        super.BeginState( PreviousStateName );
    }
    
    simulated event EndState( name NextStateName )
    {
        Activate();

        //HackSound.Stop(); // Now handled in HackObjective.
        Mesh.SetHidden( false );
        ClearTimer( 'PlayIdleAnimation' );
    }

    reliable server function ServerStartFire( byte FireModeNum );

    simulated function bool DenyWeaponFunctionality()
    {
        return true;
    }

    simulated function bool AllowSwitchTo( Weapon NewWeapon )
    {
        local CPPawn P;
        P = CPPawn(Instigator);

        if(P != none && !P.bIsUsingObjective)
            return true;
        else
            return false;
    }

    simulated function bool ShouldSwitchTo( CPWeapon InWeapon )
    {
        return false;
    }

    simulated function bool bReadyToFire()
    {
        return false;
    }
}

simulated state WeaponFiring
{
    simulated event ReplicatedEvent(name VarName)
    {
        if (VarName=='AmmoCount' && !HasAnyAmmo())
            return;
        Global.ReplicatedEvent(VarName);
    }

    simulated function BeginFire( Byte FireModeNum )
    {
        Global.BeginFire(FireModeNum);
        if (!HasAmmo(FireModeNum))
        {
            WeaponEmpty();
            return;
        }
    }

    simulated function FireWeapon()
    {
        local bool                  _Repeater;

        FireAmmunition();
        IncrementFlashCount();
        _Repeater = FireStates[CurrentFireState].bRepeater[CurrentFireMode] != 0;
        SetInstigatorWeaponState( _Repeater ? EWS_FiringRepeat : EWS_Firing );
    }

    simulated function RefireCheckTimer()
    {
        if (bWeaponPutDown)
        {
            `LogInv("Weapon put down requested during fire, put it down now");
            PutDownWeapon();
            return;
        }
        if (ShouldRefire())
        {
            FireWeapon();
            return;
        }
        HandleFinishedFiring();
    }

    simulated event BeginState(name PreviousStateName)
    {
        `LogInv("PreviousStateName:" @ PreviousStateName);
        FireWeapon();
        TimeWeaponFiring(CurrentFireMode);
    }

    simulated event EndState( Name NextStateName )
    {
        `LogInv("NextStateName:" @ NextStateName);
        ClearTimer( nameof(RefireCheckTimer) );
		ClearTimerLog(nameof(RefireCheckTimer));
        NotifyWeaponFinishedFiring( CurrentFireMode );
        //SetInstigatorWeaponState( EWS_None );
    }

    simulated function bool DenyClientWeaponSet()
    {
        return true;
    }

    simulated event bool IsFiring()
    {
        return true;
    }
}

simulated state SwitchingLaser extends WeaponFiring
{
    simulated function StartFire(byte FireModeNum);

    simulated function bool ReadyToFire(bool bFinished)     // for AI
    {
        return false;
    }

    simulated function Activate()
    {
    }

    simulated function bool DenyClientWeaponSet()
    {
        return true;
    }

    simulated function bool TryPutDown()
    {
        bWeaponPutDown=true;
        return true;
    }

    simulated function bool CanThrow()
    {
        return false;
    }
/*
    simulated function PlayFireEffects(byte FireModeNum,optional vector HitLocation)
    {
        if (FireModeNum<WeaponFireAnim.Length && WeaponFireAnim[FireModeNum]!='')
            PlayWeaponAnimation(WeaponFireAnim[FireModeNum],GetFireInterval(FireModeNum));
        if (FireModeNum<ArmFireAnim.Length && ArmFireAnim[FireModeNum]!='' && ArmsAnimSet!=none )
            PlayArmAnimation(ArmFireAnim[FireModeNum],GetFireInterval(FireModeNum));
        ShakeView();
    }
*/
    simulated function RefireCheckTimer()
    {
        if (bWeaponPutDown)
        {
            PutDownWeapon();
            return;
        }
        if (Role==ROLE_Authority)
        {
            bLaserDotStatus=!bLaserDotStatus;
            SetLaserDotStatus(bLaserDotStatus);
        }
        HandleFinishedFiring();
    }

    simulated event BeginState(name PreviousStateName)
    {
        PlayFireEffects(CurrentFireMode);
        TimeWeaponFiring(CurrentFireMode);
    }
}

simulated state WeaponEquipping
{
    /**
     * We want to being this state by setting up the timing and then notifying the pawn
     * that the weapon has changed.
     */

    simulated function BeginState(Name PreviousStateName)
    {
        local CPPawn    _Pawn;
        local CPWeaponAttachment _WeaponAttachment;
        
        
        if (Role==ROLE_Authority)                   //merge
            SetLaserDotStatus(bLaserDotStatus);     //merge

        _Pawn = CPPawn( Instigator );
        
        _Pawn.CurrentWeaponAttachmentClass = AttachmentClass;
        _Pawn.WeaponAttachmentChanged();
        
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_21");
            return;
        }
        _WeaponAttachment = _Pawn.CurrentWeaponAttachment;
        
        _WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.EquipWeapAnim, _WeaponAttachment.WeaponClass.default.EquipTime );
        _Pawn.SetTimer( _WeaponAttachment.WeaponClass.default.EquipTime, false, 'EquippingFinished' );
        
        TimeWeaponEquipping();
		bWeaponPutDown	= false;
        //super.BeginState(PreviousStateName);

        PerformWeaponChange();
    }

    simulated function bool TryPutDown()
    {
        bWeaponPutDown=true;
        return true;
    }

    simulated function EndState(Name NextStateName)
    {
        if (SkeletalMeshComponent(Mesh) == none || WeaponEquipAnim == '')
        {
            Mesh.SetRotation(Default.Mesh.Rotation);
        }
        ClearTimer('WeaponEquipped');
		//ClearTimerLog('WeaponEquipped');
    }
}

simulated state WeaponPuttingDown
{
    simulated function BeginState( name PreviousStateName )
    {
        local CPPawn    _Pawn;
        local CPWeaponAttachment _WeaponAttachment;
        
        
        if( Instigator == None)
        {
            `Log("@@ error_19");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_20");
            return;
        }
        _WeaponAttachment = _Pawn.CurrentWeaponAttachment;
        
        _WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.PutdownWeapAnim, _WeaponAttachment.WeaponClass.default.PutDownTime );

        _Pawn.SetTimer( _WeaponAttachment.WeaponClass.default.PutdownTime, false, 'PuttingDownFinished' ); //x
        if ( Role == ROLE_Authority )
            SetLaserDotStatus( false );

        if ( _Pawn != none )
        {
			if(Instigator.Controller == none &&  _Pawn.SpectateCurrentWeapon == self)
				return;
            //_Pawn.SetWeaponState( EWS_Unequipping );
        }

		TimeWeaponPutDown();

	    bIssuedReload = false;	
	    bWeaponPutDown = FALSE;

		// Make sure all pending fires are cleared.
		ForceEndFire();
    }

    simulated function EndState(Name NextStateName)
    {
        Super.EndState(NextStateName); 
        if (SkeletalMeshComponent(Mesh) == none || WeaponEquipAnim == '')
        {
            Mesh.SetRotation(Default.Mesh.Rotation);
        }
    }

    simulated function Activate();

    /**
     * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
     */
    simulated function bool bReadyToFire()
    {
        return false;
    }

    simulated function WeaponIsDown()
    {
		//`Log("       ***************************                    WeaponIsDown");
        if( InvManager != none)
        {
            if( InvManager.CancelWeaponChange() )
            {
                return;
            }

            `LogInv("");

            // This weapon is down, remove it from the mesh
            DetachWeapon();

            // Put weapon to sleep
            //@warning: must be before ChangedWeapon() because that can reactivate this weapon in some cases
            GotoState('Inactive');

            // switch to pending weapon
            InvManager.ChangedWeapon();
        }
        else
        {
			//`Log("WeaponIsDown::SPECTATOR");
            //SPECTATOR 1st PERSON STUFF
            DetachWeapon();
            GotoState('Inactive');
        }
    }
}

simulated state FireEmpty
{
    simulated event BeginState( name PreviousStateName )
    {
		local CPPawn    _Pawn;
        local CPWeaponAttachment _WeaponAttachment;
        if( Instigator == None)
        {
            `Log("@@ error_09");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if(_Pawn.CurrentWeaponAttachment == None)
        {
            `Log("@@ error_10");
            return;
        }
        _WeaponAttachment = _Pawn.CurrentWeaponAttachment;
        if ( _Pawn != none && _Pawn.GunRecoilNode != none )
            _Pawn.GunRecoilNode.bPlayRecoil = true;

		//TODO FireAnim --> FireEmptyAnim

		//TOP-Proto some weapons have an alt function such as DE for laser dots - we do not want to play fire empty animations for things like that in 3rd person mode
		//Totally removing the ability to play any animations in 3rd person when using the alt fire functionality.
		if(_Pawn.FiringMode != 1)
		{
			if ( !_WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.FireAnim, _WeaponAttachment.WeaponClass.default.FireStates[0].FireInterval[0] ) )
				_WeaponAttachment.PlayTopHalfAnimationDuration( _WeaponAttachment.FireAnim , _WeaponAttachment.WeaponClass.default.FireStates[0].FireInterval[0] );
		}

    }
}

//the function called to transition from the charging to the weaponfiring state
simulated function StartReleaseFire(byte FireModeNum)
{
    if(Role < Role_Authority)
    {
        ServerReleaseFire(FireModeNum); 
    }
    else
    {
        ReleaseFire(FireModeNum);
    }
}

simulated function ReleaseFire(byte FireModeNum){}

server reliable function ServerReleaseFire(byte FireModeNum)
{
    ReleaseFire(FireModeNum);
}

simulated state Charging
{
    simulated event BeginState( name PreviousStateName )
	{
    }
    
    simulated function ReleaseFire(byte FireModeNum)
    {
    }
}


simulated state ReloadingEmpty
{
    simulated event BeginState( name PreviousStateName )
    {
        local CPPawn _Pawn;
        if( Instigator == None)
        {
            `Log("@@ error_02");
            return;
        }
        _Pawn = CPPawn(Instigator);
        if( _Pawn.CurrentWeaponAttachment != None )
        {
            _Pawn.CurrentWeaponAttachment.PlayTopHalfAnimationDuration( _Pawn.CurrentWeaponAttachment.ReloadEmptyAnim, _Pawn.CurrentWeaponAttachment.WeaponClass.default.ReloadEmptyTime );
        }
    }
}

simulated state ReloadingEnd
{

}

//TOP PROTO state MERGE END
defaultproperties
{
    MaxAmmoCount=1
    MaxClipCount=1
    ReloadRefillTimePct=0.45;
    DroppedPickupClass=class'CPDroppedPickup'


    WeaponPutDownAnim=WeaponPutDown
    ArmsPutDownAnim=WeaponPutDown

    WeaponEquipAnim=WeaponEquip
    ArmsEquipAnim=WeaponEquip

    WeaponIdleAnims(0)=WeaponIdle
    ArmIdleAnims(0)=WeaponIdle

    WeaponReloadAnim=WeaponReload
    ArmsReloadAnim=WeaponReload

    WeaponReloadEmptyAnim=WeaponReloadEmpty
    ArmsReloadEmptyAnim=WeaponReloadEmpty

    WeaponEmptyFireAnim=WeaponStartFireEmpty
    ArmsEmptyFireAnim=WeaponStartFireEmpty

    ReloadTime=2.0
    ReloadEmptyTime=2.5

    FireModeSwitchTime[0]=0.2
    WeaponFireModeSwitchAnim[0]=WeaponSwitchFireMode
    ArmsFireModeSwitchAnim[0]=WeaponSwitchFireMode

    FireModeSwitchTime[1]=0.2
    WeaponFireModeSwitchAnim[1]=WeaponSwitchFireMode
    ArmsFireModeSwitchAnim[1]=WeaponSwitchFireMode

    RepeaterSpreadScaling=0.0

    // JUNK
    BlackColor = (R=0,G=0,B=0,A=255)
    LightGreenColor=(R=128,G=255,B=128,A=255)
    RedColor=(R=255,G=0,B=0,A=255)
    MuzzleFlashScale=0.5

    //TOP PROTO MERGED DEFAULTS
    MessageClass=class'CPMsg_Pickup'
    FiringStatesArray(0)=WeaponFiring
    FiringStatesArray(1)=WeaponFiring

    WeaponFireTypes(0)=EWFT_InstantHit
    WeaponFireTypes(1)=EWFT_InstantHit

    FireInterval(0)=+1.0
    FireInterval(1)=+1.0

    ShotCost(0)=1
    ShotCost(1)=1

    Spread(0)=0.0
    Spread(1)=0.0
    Spread(2)=0.0

    WeaponFireAnim(0)=WeaponFire
    WeaponFireAnim(1)=WeaponFire
    ArmFireAnim(0)=WeaponFire
    ArmFireAnim(1)=WeaponFire

    InstantHitDamage(0)=0.0
    InstantHitDamage(1)=0.0
    InstantHitMomentum(0)=0.0
    InstantHitMomentum(1)=0.0
    InstantHitDamageTypes(0)=class'DamageType'
    InstantHitDamageTypes(1)=class'DamageType'

    WeaponRange=32768
    WeaponEffectiveRange=32768

    ShouldFireOnRelease(0)=0
    ShouldFireOnRelease(1)=0

    SimpleCrossHairCoordinates=(U=276,V=84,UL=22,VL=25)

    //WeaponPutDownSnd
    WeaponFireSnd(0)=none
    WeaponFireSnd(1)=none

    HiddenWeaponsOffset=(Y=-50.0,Z=-50.0)
    SmallWeaponsOffset=(X=16.0,Y=6.0,Z=-6.0)
    WideScreenOffsetScaling=0.8

    BobDamping=0.85000
    JumpDamping=1.0

    MaxYawLag=800
    MaxPitchLag=600
    RotChgSpeed=3.0
    ReturnChgSpeed=3.0
    MaxDesireability=0.5

    Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
        Samples(0)=(LeftAmplitude=30,RightAmplitude=20,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.100)
    End Object
    WeaponFireWaveForm=ForceFeedbackWaveformShooting1

    EffectSockets(0)=MuzzleFlashSocket
    EffectSockets(1)=MuzzleFlashSocket
    MuzzleFlashSocket=MuzzleFlashSocket
    ShellCasingSocket=EjectionSocket
    bShellUseAnimNotify=false
    MuzzleFlashDuration=0.33
    ShellCasingDuration=0.33

    bUsesOffhand=false

    Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
        DepthPriorityGroup=SDPG_Foreground
		ViewOwnerDepthPriorityGroup=SDPG_Foreground
        //bOnlyOwnerSee=true //stops spectators seeing this weapon...
        bOverrideAttachmentOwnerVisibility=true
		bUseViewOwnerDepthPriorityGroup=true
    End Object
    Mesh=FirstPersonMesh

    Begin Object Class=StaticMeshComponent Name=PickupMesh
        bOnlyOwnerSee=false
        CastShadow=false
        bForceDirectLightMap=true
        bCastDynamicShadow=false
        CollideActors=false
        BlockRigidBody=false
        MaxDrawDistance=6000
        //bForceRefPose=1
        //bUpdateSkelWhenNotRendered=false
        //bIgnoreControllersWhenNotRendered=true
        bAcceptsStaticDecals=FALSE
        bAcceptsDynamicDecals=FALSE
        Rotation=(Pitch=0,Yaw=16384,Roll=16384)
    End Object
    DroppedPickupMesh=PickupMesh
    PickupFactoryMesh=PickupMesh
    PivotTranslation=(Y=-25.0)

    CurrentRating=+0.5

    bFastRepeater=true;

    WeaponProjectiles(0)=none
    WeaponProjectiles(1)=none

    AimingHelpRadius[0]=20.0
    AimingHelpRadius[1]=20.0

    WeaponCanvasXPct=0.35
    WeaponCanvasYPct=0.35
    //TOP PROTO MERGED DEFAULTS END

    // ~WillyG - IMPORTANT. Stupid Epic decided to put Pitch = 900, not changing the pitch actually fixes widescreen
    WidescreenRotationOffset=(Pitch=0)
    PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)

    FireWeaponEmptyTime=0.01 // DO NOT REMOVE - Weapons that do not have this set will experience a reload bug

    bEquippingWeapon=false
    bPuttingDownWeapon=false

    MuzzleFlashFOVOverride=60.0
    //MuzzleFlashFOVOverride=-1

    //GLOBAL DO NOT MOVE!!!
    WeaponDiffuseAnim=WeaponDiffuse
    WeaponDiffuseTime=7.86
    WeaponPrice=1000;
    ClipPrice=10;

    InventoryGroup=0

    //WeaponProfileName=Holster

    bReloadFireToggle=false
    bWeaponCanFireOnReload=false
    WeaponThrowSnd=SoundCue'CP_Weapon_Sounds.Grenades.CP_A_Grenade_throw_Cue'

	blnWeaponLogging = FALSE; //TOP-Proto use this to turn on/off weapon log spam for checking weapon related problems.

	bShowMuzzleFlashWhenFiring = TRUE;
}
