class CPDamageType extends DamageType
    /*config(DamageType)*/
    abstract;

var LinearColor     DamageBodyMatColor;
var float           DamageOverlayTime;
var float           DeathOverlayTime;
var float           XRayEffectTime;

var bool                    bCausesBlood;               // Whether damage produces blood from victim
var bool                    bLocationalHit;             // Whether damage is to a specific location on victim, or generalized.

var     bool            bDirectDamage;
var     bool            bSeversHead;
var     bool            bCauseConvulsions;
var     bool            bUseTearOffMomentum;    // For ragdoll death. Add entirety of killing hit's momentum to ragdoll's initial velocity.
var     bool            bThrowRagdoll;
var     bool            bLeaveBodyEffect;
var     bool            bBulletHit;
var     bool            bVehicleHit;        // caused by vehicle running over you
var     bool            bSelfDestructDamage;

var float PhysicsTakeHitMomentumThreshold;

/** Information About the weapon that caused this if available */

var     class<CPWeapon>         DamageWeaponClass;
var     int                     DamageWeaponFireMode;

 /** This will delegate to the death effects to the damage type.  This allows us to have specific
 *  damage effects without polluting the Pawn / Weapon class with checking for the damage type
 *
 **/
var() bool                  bUseDamageBasedDeathEffects;
/** if set, CPPawn::Dying::CalcCamera() calls this DamageType's CalcDeathCamera() function to handle the camera */
var bool bSpecialDeathCamera;

/** This is the Camera Effect you get when you die from this Damage Type **/
var protected class<UDKEmitCameraEffect> DeathCameraEffectVictim;
/** This is the Camera Effect you get when you cause from this Damage Type **/
var protected class<UDKEmitCameraEffect> DeathCameraEffectInstigator;

/************** DEATH ANIM *********/

/** Name of animation to play upon death. */
var(DeathAnim)  name    DeathAnim;
/** How fast to play the death animation */
var(DeathAnim)  float   DeathAnimRate;
/** If true, char is stopped and root bone is animated using a bone spring for this type of death. */
var(DeathAnim)  bool    bAnimateHipsForDeathAnim;
/** If non-zero, motor strength is ramped down over this time (in seconds) */
var(DeathAnim)  float   MotorDecayTime;
/** If non-zero, stop death anim after this time (in seconds) after stopping taking damage of this type. */
var(DeathAnim)  float   StopAnimAfterDamageInterval;

/***********************************/


/** camera anim played instead of the default damage shake when taking this type of damage */
var CameraAnim DamageCameraAnim;

/** Damage scaling when hit warfare node/core */
var float NodeDamageScaling;

/** Name used for stats for kills with this damage type */
var name KillStatsName;

/** Name used for stats for deaths with this damage type */
var name DeathStatsName;

/** Name used for stats for suicides with this damage type */
var name SuicideStatsName;

/** If > 0, how many kills of this type get you a reward announcement */
var int RewardCount;

var class<CPLocalMessage> RewardAnnouncementClass;

/** Announcement switch for reward announcement. */
var int RewardAnnouncementSwitch;

/** Stats event associated with reward */
var name RewardEvent;

/** Custom taunt index for this damage type */
var int CustomTauntIndex;

/** Whether teammates should complain about friendly fire with this damage type */
var bool bComplainFriendlyFire;

/** if set, when taking this damage HUD hit effect is our HitEffectColor instead of the default */
var bool bOverrideHitEffectColor;
var LinearColor HitEffectColor;


/** Whether or not this damage type can cause a blood splatter **/
var bool bCausesBloodSplatterDecals;
/** if true, this damage type should never harm its instigator */
var bool bDontHurtInstigator;

var() localized string      DeathString;                // string to describe death by this type of damage
var() localized string      FemaleSuicide, MaleSuicide; // Strings to display when someone dies

var localized string deathAction;
var localized string deathObject;

////--- DeathCam Props for interpolation, Sarkis
///** Max rotation*/
//var int MaxPitch, MaxRoll, MaxYaw;
///** Max location*/
//var float MaxX, MaxY, MaxZ;
///** temporary values */
////var config int tmpPitch, tmpRoll, tmpYaw;
//var config float tmpX, tmpY, tmpZ;

//--- News
/** desired offset vector to apply when dying*/
var Vector AdjustedOffset;
/** final location */
var vector FinalLocation;
/** final rotation */
var rotator FinalRotation;
/** max rotation */
var rotator MaxRotation;
/** Interval to performs a interpolation */
var float LerpInterval;
//---

/**
  * @RETURN string for death caused by this damagetype.
  */
static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
    return Default.DeathString;
}

/**
  * @RETURN string for suicide caused by this damagetype.
  */
static function string SuicideMessage(PlayerReplicationInfo Victim)
{
    if ( (CPPlayerReplicationInfo(Victim) != None) && CPPlayerReplicationInfo(Victim).bIsFemale )
        return Default.FemaleSuicide;
    else
        return Default.MaleSuicide;
}

/**
 * Possibly spawn a custom hit effect
 */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation);

/** @return duration of hit effect, primarily used for replication timeout to avoid replicating out of date hits to clients when pawns become relevant */
static function float GetHitEffectDuration(Pawn P, float Damage)
{
    return 0.5;
}

static function int IncrementKills(CPPlayerReplicationInfo KillerPRI)
{
    //local int KillCount;

    ////KillCount = KillerPRI.IncrementKillStat(static.GetStatsName('KILLS'));
    //if ( (KillCount == Default.RewardCount)  && (CPPlayerController(KillerPRI.Owner) != None) )
    //{
    //  CPPlayerController(KillerPRI.Owner).ReceiveLocalizedMessage( Default.RewardAnnouncementClass, Default.RewardAnnouncementSwitch );
    //  if ( default.RewardEvent == '' )
    //  {
    //      `warn("No reward event for "$default.class);
    //  }
    //  else
    //  {
    //      //KillerPRI.IncrementEventStat(default.RewardEvent);
    //  }
    //}
    //return KillCount;
    return 0;
}

static function IncrementDeaths(CPPlayerReplicationInfo KilledPRI)
{
    //KilledPRI.IncrementDeathStat(static.GetStatsName('DEATHS'));
}

static function IncrementSuicides(CPPlayerReplicationInfo KilledPRI)
{
    //KilledPRI.IncrementSuicideStat(static.GetStatsName('SUICIDES'));
}

static function name GetStatsName(name StatType)
{
    switch(StatType)
    {
    case 'KILLS':
        if ( Default.KillStatsName != '' )
        {
            return Default.KillStatsName;
        }
        else
        {
            `log(Default.Name$" does not have a Killstat value");
            return 'KILLS_ENVIRONMENT';
        }
    case 'DEATHS':
        if ( Default.DeathStatsName != '' )
        {
            return Default.DeathStatsName;
        }
        else
        {
            `log(Default.Name$" does not have a Death stat value");
            return 'DEATHS_ENVIRONMENT';
        }
    case 'SUICIDES':
        if ( Default.SuicideStatsName != '' )
        {
            return Default.SuicideStatsName;
        }
        else
        {
            `log(Default.Name$" does not have a suicide stat value");
            return 'SUICIDES_ENVIRONMENT';
        }
    }

    `log(StatType$" was invalid");
    return 'BAD_STAT';
}

static function ScoreKill(CPPlayerReplicationInfo KillerPRI, CPPlayerReplicationInfo KilledPRI, Pawn KilledPawn)
{
    if ( KillerPRI == KilledPRI )
    {
        if ( KillerPRI != None )
        {
            IncrementSuicides(KillerPRI);
        }
    }
    else
    {
        if ( KillerPRI != None )
            IncrementKills(KillerPRI);
        if ( KilledPRI != None )
            IncrementDeaths(KilledPRI);
    }
}

static function PawnTornOff(CPPawn DeadPawn);

static function DoCustomDamageEffects(CPPawn ThePawn, class<CPDamageType> TheDamageType, const out TraceHitInfo HitInfo, vector HitLocation)
{
    `log("CPDamageType base DoCustomDamageEffects should never be called");
    // ScriptTrace();
}

simulated static function CalcDeathCamera(CPPawn P, float DeltaTime, out vector CameraLocation, out rotator CameraRotation, out float CameraFOV, vector FinalCameraLocation, rotator FinalCameraRotation)
{
    //--- perform a individual interpolation for each axe
    CameraLocation.X = Lerp(CameraLocation.X, FinalCameraLocation.X, Default.LerpInterval);
    CameraLocation.Y = Lerp(CameraLocation.Y, FinalCameraLocation.Y, Default.LerpInterval);
    CameraLocation.Z = Lerp(CameraLocation.Z, FinalCameraLocation.Z, Default.LerpInterval);

    //--- perform a complete interpolation for a rotation all struct components (maybe suffer changes for a individual one)
    CameraRotation   = RLerp(CameraRotation, FinalCameraRotation, Default.LerpInterval);
}

//--- this function uses the actual player location and rotation and apply some basic math
//--- calcs to obtain the desired (final) location and rotation based on properties defined in default place
simulated static function GetDesiredValues(CPPawn DiedPawn, out vector DesiredLocation, out rotator DesiredRotation)
{
    local vector _x, _y, _z;

    //--- Get orientation axis
    GetAxes(DiedPawn.DC_StartRotation, _x, _y, _z);

    //--- desired location
    DesiredLocation = DiedPawn.Location;

    //--- applying offset to it
    DesiredLocation += default.AdjustedOffset.X *_x + default.AdjustedOffset.Y * _y;

    //--- just ensures that z values is 35, i think this is a good distance between floor and head
    DesiredLocation.Z -= DiedPawn.EyeHeight/1;

    //--- desired rotation
    DesiredRotation = DiedPawn.DC_StartRotation;
    DesiredRotation += default.MaxRotation;
}

/** Return the DeathCameraEffect that will be played on the instigator that was caused by this damagetype and the Pawn type (e.g. robot) */
simulated static function class<UDKEmitCameraEffect> GetDeathCameraEffectInstigator( CPPawn UTP )
{
    return default.DeathCameraEffectInstigator;
}

/** Return the DeathCameraEffect that will be played on the victim that was caused by this damagetype and the Pawn type (e.g. robot) */
simulated static function class<UDKEmitCameraEffect> GetDeathCameraEffectVictim( CPPawn UTP )
{
    return default.DeathCameraEffectVictim;
}


defaultproperties
{
    KillStatsName=KILLS_ENVIRONMENT //catchall for stats
    DeathStatsName=DEATHS_ENVIRONMENT //catchall for stats
    SuicideStatsName=SUICIDES_ENVIRONMENT //catchall for stats
    //DeathMessageInfo=(deathAction="killed",deathObject="with an WEAPON");
    RewardAnnouncementClass=none //class'UTWeaponRewardMessage'

    //~Crusha: if this is true, it messes up the hit direction calculations that we need for blood splatter traces.
    // Engine.Pawn.TakeDamage() will modify the Momentum in that case.
    bExtraMomentumZ=false

    DamageBodyMatColor=(R=10)
    DamageOverlayTime=0.1
    DeathOverlayTime=0.1
    bDirectDamage=true
    PhysicsTakeHitMomentumThreshold=250.0
    RadialDamageImpulse=750

    bAnimateHipsForDeathAnim=true
    DeathAnimRate=1.0

    NodeDamageScaling=1.0
    CustomTauntIndex=-1
    bComplainFriendlyFire=true

    bCausesFracture=true

    // Short "pop" of damage
    Begin Object class=ForceFeedbackWaveform Name=ForceFeedbackWaveform0
        Samples(0)=(LeftAmplitude=64,RightAmplitude=96,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.25)
    End Object
    DamagedFFWaveform=ForceFeedbackWaveform0
    // Pretty violent rumble
    Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform1
        Samples(0)=(LeftAmplitude=100,RightAmplitude=100,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.75)
    End Object
    KilledFFWaveform=ForceFeedbackWaveform1

    bLocationalHit=true

    //--- by default always will use DemageType.CalcDeathCamera(..) - sarkis
    bSpecialDeathCamera=true

    //--- DC properties
    MaxRotation    = (Pitch=0, Roll=16000, Yaw=0)
    AdjustedOffset = (X=-10.0f, Y=80.0f, Z=0.0f)
    FinalLocation  = (X=0, Y=0, Z=0)
    FinalRotation  = (Pitch=0, Roll=0, Yaw=0)
    LerpInterval   = 0.023f
}

