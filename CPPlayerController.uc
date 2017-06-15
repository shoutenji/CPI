/**
 * CPPlayerController
 * Author:  Cralexns
 * Date:    Nov. 21st, 2010
 *
 * Editor:  TOP-Proto
 */
class CPPlayerController extends UDKPlayerController
    dependson(CPPawn)
    dependson(CPPlayerReplicationInfo)
    config(Game);
	
/** To limit frequency of received "friendly fire" voice messages */
var float LastFriendlyFireTime;

/** Last time "incoming" message was received by this player */
var float LastIncomingMessageTime;

/** to limit frequency of voice messages */
var float OldMessageTime;

var config bool bSimpleCrosshair;

var float CalcEyeHeight;
var vector CalcWalkBob;
var vector CalcViewActorLocation;
var rotator CalcViewActorRotation;
var vector CalcViewLocation;
var rotator CalcViewRotation;

var float LastCameraTimeStamp; /** Used during matinee sequences */

/** cached result of GetPlayerViewPoint() */
var Actor CalcViewActor;

var class<Camera> MatineeCameraClass;

/** Set to team this player has been identified (with announcement) as being on */
var                 byte    IdentifiedTeam;

var config bool bCenteredWeaponFire;

/** Used to prevent too frequent team changes */
var float LastTeamChangeTime;

/** Used to keep spectator cameras from going out of world boundaries */
var bool    bCameraOutOfWorld;

var localized string MsgPlayerNotFound;

/** camera anim played when hit (blend strength depends on damage taken) */
var CameraAnim DamageCameraAnim;

/** set when the last camera anim we played was caused by damage - we only let damage shakes override other damage shakes */
var bool bCurrentCamAnimIsDamageShake;

/** Vibration  */
var ForceFeedbackWaveform CameraShakeShortWaveForm, CameraShakeLongWaveForm;

/** set if camera anim modifies FOV - don't do any FOV interpolation while camera anim is playing */
var bool bCurrentCamAnimAffectsFOV;

/** Stops someone spamming admin commands **/
var float NextAdminCmdTime;

var config bool bNoCrosshair;

var     bool    bBehindView;
var bool bIsInGhostCam;  // Allows other objects to know if this controller is in ghost cam
var     bool bFreeCamera;

/** if true, while in the spectating state, behindview will be forced on a player */
var bool bForceBehindView;

enum EWeaponHand
{
    HAND_Right,
    HAND_Left,
    HAND_Centered,
    HAND_Hidden,
};
var globalconfig EWeaponHand WeaponHandPreference;
var EWeaponHand WeaponHand;

var globalconfig enum EPawnShadowMode
{
    SHADOW_None,
    SHADOW_Self,
    SHADOW_All
} PawnShadowMode;

var globalconfig bool bFirstPersonWeaponsSelfShadow;

var CPAnnouncer TAAnnounce;

var int MaxTimeoutTime, CurrentTimeoutTime;

var bool bTyping, bTeamTyping; //used so the hud knows when to show the typing box and to pass control of the input to the hud.

struct InventoryItem
{
    var class<Inventory> InventoryClass;
    var string InventoryString;
};

struct WeaponItem
{
    var class<CPWeapon> WeaponClass;
    var string WeaponString;
};

struct PredefinedCrosshairImage
{
    var Texture2D Image;
    var UIRoot.TextureCoordinates ImageTexCoords;
};

struct SCamperInfo
{
    var int UID;
    var Vector CamperPos;
};


var     Pawn EscapedPawn;

var     array<InventoryItem> ServersKnownInventory;
var     array<WeaponItem> ServersKnownWeapons;

var     const float WeaponSwapAimAccuracyPct;         // how well the player needs to aim for weapon swap
var     bool bWeaponAutoReload;                        // weapon Auto Reload, not replicated directly
var     private int WeaponAutoSwitchMode;             // what type of auto switch the player prefers , 0==best 1==last

/* Crosshair settings */
var globalconfig array<PredefinedCrosshairImage> PredefinedCrosshairs;
var int PredefinedCrosshairIdx;
var float PredefinedCrosshairScale;
var Color PredefinedCrosshairColor;

/* player name */
var globalconfig string PlayerName;
var bool bIsInMenuGame;

/* character selection */
var class<CPFamilyInfo> SelectedCharacter;

/* Reverb Volume Hack */
var CPReverbVolumeHackHelper reverbHackHelper;

/* Music */
var CPMusicManager CPMusicManager;
var name CurrentMusicSoundMode;
var name CurrentGameSoundMode;
var float LastTeammateHitTime;

/* DEV variables */
var bool bDEVWeaponTestMode;
var CPExternalUtils taExtUtils;
var bool bDEVOscRouting;
var bool bDEVOscIndexing;
var bool bDEVWeaponDrawTraces;
var bool bDEVWeaponTuneMode;

// camping/camper warning
var bool bCampingWarningActive;
var float CampingStartTime;
var array<SCamperInfo> CamperInfos;

/** List of players that are explicitly muted (outside of gameplay) */
var array<int> IgnoredPlayerList;
var bool bIgnoreAllPlayers;


/** used for the sniper rifle */
var MaterialInstanceConstant SniperPostProcessMaterialInstanceConstant;
var MaterialEffect SniperPostProcessEffect; //doesnt need exposing this is only for fixing the texture.

var SoundCue HitTargetSound;
var CPHud CPHud;
var bool bDontKillFlashAudioCue; //set this flag to true to prevent further StopFlash() calls from disabling the audio cue when it should stay on (eg when the player dies)

var CPWeaponScoped SpecScopedWeapon;
var CPWeaponScoped prevSpecScopedWeapon;

/* spectator replication view values for more accureate spectating*/
//var int SpectatorReplicatedYaw;
//var int SpectatorReplicatedX, SpectatorReplicatedY, SpectatorReplicatedZ;

/* This bit needs to come after all the var defs!! */
`include(GameAnalyticsProfile.uci);


replication
{
}

`if(`notdefined(FINAL_RELEASE))
/**
 */

/**
 * Cheat function to unlock achievements.
 *
 * @param       AchievementId           Achievement Id
 */
exec function UnlockAchievement(int AchievementId)
{
    if (OnlineSub != None && OnlineSub.PlayerInterface != None)
    {
        OnlineSub.PlayerInterface.AddUnlockAchievementCompleteDelegate(0, OnUnlockAchievementComplete);
        OnlineSub.PlayerInterface.UnlockAchievement(0, AchievementID);
    }
}

/**
 * Unlock achievement delegate. Remove in RELEASE MODE
 */
function OnUnlockAchievementComplete(bool bWasSuccessful)
{
    if (OnlineSub != None && OnlineSub.PlayerInterface != None)
    {
        OnlineSub.PlayerInterface.ClearUnlockAchievementCompleteDelegate(0, OnUnlockAchievementComplete);
    }
}

/**
 * Resets all stats and achievements
 */
exec function ResetStats()
{
    local OnlineSubsystemSteamworks OnlineSubsystemSteamworks;

    OnlineSubsystemSteamworks = OnlineSubsystemSteamworks(OnlineSub);
    if (OnlineSubsystemSteamworks != None)
    {
        OnlineSubsystemSteamworks.ResetStats(true);
    }
}
`endif


function SetViewTarget(Actor NewViewTarget, optional ViewTargetTransitionParams TransitionParams)
{
    local Pawn P;
    local EPawnShadowMode AdjustedShadowMode;

    ClearCameraEffect();

    //TOP-Proto LOOK AT THIS... DO WE NEED IT??
    ////// FIXMESTEVE - do this by calling simulated function in Pawn (in base PlayerController version)
    ////if ( CPPawn(ViewTarget) != None )
    ////{
    ////    CPPawn(ViewTarget).AdjustPPEffects(self, true);
    ////}

    Super.SetViewTarget(NewViewTarget, TransitionParams);

    // Rogue. Update the current player being spectated when the ViewTarget changes.
    if (PlayerReplicationInfo != None && (PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bIsSpectator))
    {
        // Verify that the player is actually a full spectator and not in transition.
        if(PlayerReplicationInfo.bIsSpectator && (Pawn != none) && (Pawn.Health > 0))
        {
        }
        // if viewing self or Target is invalid then show that we are in ghostcam mode now.
        else if((NewViewTarget == self) || (CPPawn(ViewTarget) == none))
        {
            // Set spectating message to show that you are specating yourself.
            if(CPPlayerReplicationInfo(PlayerReplicationInfo).Team != none)
                SetServerSpectatingName("Ghostcam", CPPlayerReplicationInfo(PlayerReplicationInfo).Team.TeamIndex);
            else if(CPPlayerReplicationInfo(PlayerReplicationInfo).bOnlySpectator)
            {
                SetServerSpectatingName("Ghostcam", 255);
                bIsInGhostCam = True;
            }
        }
        // If we have valid ViewTarget with valid Player replication info then set this
        // to display current player being spectated.
        else if(CPPawn(ViewTarget).PlayerReplicationInfo != None)
        {
            SetServerSpectatingName("Spectating: "$CPPawn(ViewTarget).PlayerReplicationInfo.PlayerName,
                                                   CPPawn(ViewTarget).PlayerReplicationInfo.Team.TeamIndex);
            bIsInGhostCam = False;
        }
    }
    ////if ( CPPawn(ViewTarget) != None )
    ////{
    ////    CPPawn(ViewTarget).AdjustPPEffects(self, false);
    ////}

    // set sound pitch adjustment based on customtimedilation
    if ( ViewTarget.CustomTimeDilation < 1.0 )
        SetSoundMode('Slow');
    else
        SetSoundMode('Default');

    // remove other players' shadows if viewing drop detail vehicle
    if (IsLocalPlayerController())
    {
        if (class'Engine'.static.IsSplitScreen())
        {
            AdjustedShadowMode = SHADOW_None;
        }
        else
        {
            AdjustedShadowMode = PawnShadowMode;
        }
        foreach WorldInfo.AllPawns(class'Pawn', P)
        {
            if (CPPawn(P) != None)
            {
                CPPawn(P).UpdateShadowSettings(AdjustedShadowMode == SHADOW_All || (AdjustedShadowMode == SHADOW_Self && ViewTarget == P));
            }
        }
    }
}

function bool IsInGhostCam()
{
    return bIsInGhostCam;
}

simulated event PostBeginPlay()
{
    if (WorldInfo.NetMode==NM_Standalone || WorldInfo.NetMode==NM_ListenServer || Role<ROLE_Authority)
        SetWeaponConfig();
    super.PostBeginPlay();
    ChangeClanTag();
    reverbHackHelper=new class'CPReverbVolumeHackHelper';
    reverbHackHelper.Init(WorldInfo);
    taExtUtils=new class'CPExternalUtils';
    if (WorldInfo.NetMode==NM_Client ||
        WorldInfo.NetMode==NM_Standalone ||
        (WorldInfo.NetMode==NM_ListenServer && Role==ROLE_Authority))
    {
        CPMusicManager=Spawn(class'CPMusicManager',self);
        LoadConfig();
        GetCrosshairSettingsFromConfig();
    }
    bDEVOscRouting=false;
}

simulated event Destroyed()
{
    //added missing super
    super.Destroyed();

    ToggleScope(false);
    reverbHackHelper=none;
    if (taExtUtils!=none)
    {
        if (bDEVOscRouting)
        {
            taExtUtils.OscRouterShutDown();
            bDEVOscRouting=false;
        }
        taExtUtils=none;
    }
    if (CPMusicManager!=none)
        CPMusicManager.Destroy();

    if (TAAnnounce != None)
    {
        TAAnnounce.Destroy();
    }

    if (LocalPlayer(Player) != None && LocalPlayer(Player).ViewportClient != none)
    {
        LocalPlayer(Player).ViewportClient.bDisableWorldRendering = false;
    }
}

// ~Drakk : the playername must not be set to anything here, because the pending login will set it later on
//          either to the real player name or if the pending login times out to the default player name of the game info
function InitPlayerReplicationInfo()
{
    PlayerReplicationInfo=Spawn(WorldInfo.Game.PlayerReplicationInfoClass,self,,vect(0,0,0),rot(0,0,0));
}

simulated function SetWeaponConfig()
{
local CPSaveManager TASave;

    TASave=new(none,"") class'CPSaveManager';
    bNeverSwitchOnPickup=!(TASave.GetBool("AutoSwitchOnPickup"));
    WeaponAutoSwitchMode=TASave.GetInt("WeaponAutoSwitchMode");
}

simulated function LoadConfig()
{
local CPSaveManager TASave;
local Color tmpColor;

    TASave=new(none,"") class'CPSaveManager';

    SetGamma(TASave.GetFloat("Gamma"));
    SetHardwarePhysicsEnabled((TASave.GetBool("PhysicsEnabled")));

    SetAudioGroupVolume('master',TASave.GetFloat("MasterVolume")/10.0);
    SetAudioGroupVolume('SFX',TASave.GetFloat("EffectsVolume")/10.0);
    SetAudioGroupVolume('music',TASave.GetFloat("MusicVolume")/10.0);
    SetAudioGroupVolume('voice',TASave.GetFloat("VoiceVolume")/10.0);
    PredefinedCrosshairIdx=TASave.GetInt("PreferredCrosshair");
    PredefinedCrosshairScale=TASave.GetFloat("CrosshairSize");
    tmpColor.R=TASave.GetInt("CrosshairRed");
    tmpColor.G=TASave.GetInt("CrosshairGreen");
    tmpColor.B=TASave.GetInt("CrosshairBlue");
    tmpColor.A=TASave.GetInt("CrosshairAlpha");
    PredefinedCrosshairColor=tmpColor;
}

event InitInputSystem()
{
local CPSaveManager TASave;

    super.InitInputSystem();
    if (PlayerInput!=none)
    {
        TASave=new(none,"") class'CPSaveManager';
        PlayerInput.SetSensitivity(TASave.GetFloat("MouseSensitivity"));
        PlayerInput.bEnableMouseSmoothing=TASave.GetBool("MouseSmoothing");
    }

    CameraAnimPlayer = new(self) class'CameraAnimInst';
}

exec simulated function ResetTAGameConfig()
{
local CPSaveManager TASave;

    TASave=new(none,"") class'CPSaveManager';
    TASave.ResetToDefaults();
    LoadConfig();
    SetWeaponConfig();
}

event PawnDied(Pawn P)
{
    bForceBehindView = true;
    SetBehindView(true);
	ResetScopeSettings();

    if (LocalPlayer(Player) == None)
    {
        ClientSetBehindView(true);
    }
    else if (CPPawn(ViewTarget) != None)
    {
        CPPawn(ViewTarget).SetThirdPersonCamera(true);
    }

    if (Role!=ROLE_Authority)
        CleanCamperInfos();
    super.PawnDied(P);
}


event UnPossess()
{
    if (Role!=ROLE_Authority)
        CleanCamperInfos();
    super.UnPossess();
}

function CheckAutoObjective(bool bOnlyNotifyDifferent)
{

}

/**
 * GetScreenSize uses the viewport to attempt to work out the current screen resolution.
 * Used in the graphics menu to see if a resolution change is required.
 */
final function string GetScreenSize()
{
    local Vector2D ScreenSize;

    LocalPlayer(Player).ViewportClient.GetViewportSize(ScreenSize );
    return int(ScreenSize.X) $ "x" $ int(ScreenSize.Y);
}

/**
 * ChangeWindowedMode will set the windowed mode in the config file and then change it using console commands.
 */
final function ChangeWindowedMode(bool bWindowed)
{
local CPSaveManager TASave;
local string Windowed;

    TASave=new(none,"") class'CPSaveManager';
    Windowed=(bWindowed ? "W" : "F");
    ConsoleCommand("SETRES " $ TASave.GetItem("SelectedResolution") $ Windowed);
    SaveConfig(); //setting ensures the FullScreen bool in SystemSettings is saved for next time the game runs.
}

state TeamSelectionState
{
    ignores RestartLevel, Suicide, ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, StartAltFire, StartFire, PrevWeapon, NextWeapon;

   reliable server function ServerChangeTeam( int N )
   {
        if ( (WorldInfo.TimeSeconds > LastTeamChangeTime + 1.0) )
        {
            LastTeamChangeTime = WorldInfo.TimeSeconds;
            Super.ServerChangeTeam(N);
        }
        Super.ServerChangeTeam(N);
        GotoState('PlayerWaiting');
   }
}

/**
 * This state is used when the player is out of the match waiting to be brought back in
 */
state InQueue extends Spectating
{
    function BeginState(Name PreviousStateName)
    {
        Super.BeginState(PreviousStateName);
        PlayerReplicationInfo.bIsSpectator = true;
    }

    function EndState(Name NextStateName)
    {
        Super.EndState(NextStateName);

        SetBehindView(false);
    }
}

auto state PlayerWaiting
{
    ignores StartFire, StartAltFire;

    exec function SwitchWeapon(byte F){}
    exec function Toggle_Flashlight() {}

    /** called when the actor falls out of the world 'safely' (below KillZ and such) */
    simulated event FellOutOfWorld(class<DamageType> dmgType)
    {
        bCameraOutOfWorld = true;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldLocation;

        OldLocation = Location;
        super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);

        if ( bCameraOutOfWorld )
        {
            bCameraOutOfWorld = false;
            SetLocation(OldLocation);
        }
    }

    //exec function StartFire( optional byte FireModeNum )
    //{
    //  ServerReStartPlayer();
    //}

    reliable server function ServerRestartPlayer()
    {
        Super.ServerRestartPlayer();
        // Native code won't let us spawn in PlayerWaiting while bWaitingToStartMatch is true,
        // it is true during Warmup so we add the option to spawn if the game is in Warmup.
        // Native code will also not allow spawning when a match has started we want to allow
        // spawning only if no damage has been taken.
        if (WorldInfo.Game.bWaitingToStartMatch && CriticalPointGame(WorldInfo.Game).bWarmupRound
            || !CPGameReplicationInfo(WorldInfo.GRI).bDamageTaken)
        {
            WorldInfo.Game.RestartPlayer(self);
        }
    }
    simulated event BeginState(Name PreviousStateName)
    {
        local CPGameReplicationInfo TAGRI;

        super.BeginState(PreviousStateName);


        TAGRI = CPGameReplicationInfo(WorldInfo.GRI);

        // Check if new player needs to select a team. If so place in team selection state.
        if(bIsPlayer &&
            PlayerReplicationInfo != none &&
            !PlayerReplicationInfo.bOnlySpectator &&
            !PlayerReplicationInfo.bOutOfLives &&
            PlayerReplicationInfo.Team == None &&
            !CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped)
        {
            GotoState('TeamSelectionState');
        }
        else if (bIsPlayer &&
            PlayerReplicationInfo != none &&
            !PlayerReplicationInfo.bOnlySpectator &&
            !PlayerReplicationInfo.bOutOfLives &&
            PlayerReplicationInfo.Team != None &&
            TAGRI != none &&
            (!TAGRI.bDamageTaken || CPPlayerReplicationInfo(PlayerReplicationInfo).bConditionalReturn) &&
            !CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped)
        {
            CPPlayerReplicationInfo(PlayerReplicationInfo).bConditionalReturn = false;
            ServerReStartPlayer();
        }
        // Put appropriate players into spectating state. When someone reconnects they will go into the
        // Player waiting state.
        else if( bIsPlayer &&
                 PlayerReplicationInfo != none &&
                 (PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bOutOfLives ||
                  CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped || PlayerReplicationInfo.bIsSpectator) )
        {
				ServerViewNextPlayer();
            GotoState('Spectating');
            ClientGotoState('Spectating');
        }
        else
        {
				ServerViewNextPlayer();
			}
        }

    reliable server function ServerChangeTeam( int N )
    {
        local CPGameReplicationInfo TAGRI;
        Super(CPPlayerController).ServerChangeTeam(N);

        TAGRI = CPGameReplicationInfo(WorldInfo.GRI);

        if (bIsPlayer &&
            PlayerReplicationInfo != none &&
            !PlayerReplicationInfo.bOnlySpectator &&
            !PlayerReplicationInfo.bOutOfLives &&
            PlayerReplicationInfo.Team != None &&
            !CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped &&
            TAGRI != none &&
            !TAGRI.bDamageTaken &&
            !CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped)
        {
            ServerRestartPlayer();
        }
        else if( bIsPlayer &&
                 PlayerReplicationInfo != none &&
                 (PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bOutOfLives ||
                  CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped) &&
                  PlayerReplicationInfo.Team != None)
        {
            ServerViewNextPlayer();
            GotoState('Spectating');
            ClientGotoState('Spectating');
        }
    }
}

state PlayerWalking
{
    ignores SeePlayer, HearNoise, Bump;

    simulated event BeginState(Name PreviousStateName)
	{
		CPPlayerReplicationInfo(PlayerReplicationInfo).bIsNewPlayer = False;
        bDontKillFlashAudioCue=false;
	}
	
	event bool NotifyLanded(vector HitNormal, Actor FloorActor)
    {

        if (Global.NotifyLanded(HitNormal, FloorActor))
        {
            return true;
        }

        return false;
    }

    function PlayerMove( float DeltaTime )
    {
        GroundPitch = 0;
        Super.PlayerMove(DeltaTime);
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local CPGameReplicationInfo     _GRI;
        local CPPawn                    _Pawn;
        local CPWeapon                  _Weapon;
        local Vector                    _AccelNormal;
        local float                     _Weight;

        // We can only move our pawn during a round (after prep time) and during warmup, defined in CriticalPointGame.RoundPreparation and WaitingForPlayers
        // ~Drakk : discard locations based movements but allow rotation

        _Pawn = CPPawn( Pawn );
        if ( _Pawn != none )
        {
            _GRI = CPGameReplicationInfo( WorldInfo.GRI );
            if ( _Pawn.bIsUsingObjective || ( _GRI != none && !_GRI.bCanPlayersMove ) )
            {
                _Pawn.Acceleration = vect( 0.0, 0.0, 0.0 );
                NewAccel = vect( 0.0, 0.0, 0.0 );
                super.ProcessMove( DeltaTime, NewAccel, DoubleClickMove, DeltaRot );
                return;
            }

            if ( _Pawn.bIsCrouched )
            {
                if(NewAccel == vect( 0.0, 0.0, 0.0 ))
                {
                    _Pawn.BaseEyeheight = _Pawn.BaseCrouchHeight;
                }
                else
                {
                    _Pawn.BaseEyeheight = _Pawn.BaseCrouchHeight + 8;
                }
            }
            else
            {
                _Pawn.BaseEyeheight = _Pawn.Default.BaseEyeheight;
            }

            _AccelNormal = Normal( NewAccel );
            _Weapon = CPWeapon( _Pawn.Weapon );
            if ( VSizeSq( _AccelNormal ) != 0.0 && _Weapon != none )
            {
                switch ( _Weapon.WeaponType )
                {
                case WT_GRENADE:
                    _Weight = 3.0;
                    break;

                case WT_PISTOL:
                    _Weight = 6.0;
                    break;

                case WT_SMG:
                    _Weight = 15.0;
                    break;

                case WT_SHOTGUN:
                    _Weight = 20.0;
                    break;

                case WT_RIFLE:
                    _Weight = 25.0;
                    break;

                default:
                    _Weight = 0.0;
                    break;
                }

                _Weight += ( _Pawn.BodyStrength > 0.0 ) ? 10.0 : 0.0;
                _Weight += ( _Pawn.HeadStrength > 0.0 ) ? 5.0 : 0.0;
                _Weight += ( _Pawn.LegStrength > 0.0 ) ? 8.0 : 0.0;
                _Pawn.GroundSpeed = class'CPPawn'.default.GroundSpeed - _Weight;
            }
        }

        super.ProcessMove( DeltaTime, NewAccel, DCLICK_None, DeltaRot );
    }
}

state PlayerFlying
{
    ignores SeePlayer, HearNoise, Bump;

    function PlayerMove(float DeltaTime)
    {
        Super.PlayerMove(DeltaTime);
        CheckJumpOrDuck();
    }
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if( NewVolume.bWaterVolume )
		{
			GotoState( Pawn.WaterMovementState );
		}
		else
		{
			GotoState( Pawn.LandMovementState );
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration	= NewAccel;

		if( bPressedJump )
		{
			Pawn.DoJump( bUpdating );
			if( Pawn.Physics == PHYS_Falling )
			{
				GotoState(Pawn.LandMovementState);
			}
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local rotator OldRotation, ViewRotation;

		GetAxes(Rotation,X,Y,Z);

		if( Pawn == None )
		{
			return;
		}

		// Update acceleration.
		if ( Pawn.OnLadder != None )
		{
			NewAccel = PlayerInput.aForward*Pawn.OnLadder.ClimbDir;
		    if ( Pawn.OnLadder.bAllowLadderStrafing )
				NewAccel += PlayerInput.aStrafe*Y;
		}
		else
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);

		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	event BeginState(Name PreviousStateName)
	{
		if( Pawn == None )
		{
			return;
		}
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
	}

	event EndState(Name NextStateName)
	{
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			Pawn.ShouldCrouch(false);
		}
	}
}

state WaitingForPawn
{
    exec function SwitchWeapon(byte F){}
    exec function Toggle_Flashlight() {}

    /** called when the actor falls out of the world 'safely' (below KillZ and such) */
    simulated event FellOutOfWorld(class<DamageType> dmgType)
    {
        bCameraOutOfWorld = true;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldLocation;

        OldLocation = Location;
        super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);

        if ( bCameraOutOfWorld )
        {
            bCameraOutOfWorld = false;
            SetLocation(OldLocation);
        }
    }

    simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
    {
        if ( PlayerCamera == None )
        {
            out_Location = Location;
            out_Rotation = BlendedTargetViewRotation;
        }
        else
            Global.GetPlayerViewPoint(out_Location, out_Rotation);
    }

}

state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide, DrawHud;

    exec function PrevWeapon() {}
    exec function NextWeapon() {}
    exec function SwitchWeapon(byte T) {}
    exec function ToggleMelee() {}
    exec function Toggle_Flashlight() {}

    /**
     * Limit the player's view rotation. (Pitch component).
     */
    event Rotator LimitViewRotation( Rotator ViewRotation, float ViewPitchMin, float ViewPitchMax )
    {
        ViewRotation.Pitch = ViewRotation.Pitch & 65535;

        if( ViewRotation.Pitch > 8192 &&
            ViewRotation.Pitch < (65535+ViewPitchMin) )
        {
            if( ViewRotation.Pitch < 32768 )
            {
                ViewRotation.Pitch = 8192;
            }
            else
            {
                ViewRotation.Pitch = 65535 + ViewPitchMin;
            }
        }

        return ViewRotation;
    }

    unreliable client function LongClientAdjustPosition
    (
        float TimeStamp,
        name newState,
        EPhysics newPhysics,
        float NewLocX,
        float NewLocY,
        float NewLocZ,
        float NewVelX,
        float NewVelY,
        float NewVelZ,
        Actor NewBase,
        float NewFloorX,
        float NewFloorY,
        float NewFloorZ
    )
    {
        if ( newState == 'PlayerWaiting' )
            GotoState( newState );
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local Rotator DeltaRot, ViewRotation;

        GetAxes(Rotation,X,Y,Z);
        // Update view rotation.
        ViewRotation = Rotation;
        // Calculate Delta to be applied on ViewRotation
        DeltaRot.Yaw    = PlayerInput.aTurn;
        DeltaRot.Pitch  = PlayerInput.aLookUp;
        ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
        SetRotation(ViewRotation);

        ViewShake(DeltaTime);

        if ( Pawn != none )
            Pawn.Velocity = vect(0,0,0); //fix for moving at the start of a new round.

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));

        bPressedJump = false;
    }

    function ShowScoreboard()
    {
        //local CPGameReplicationInfo GRI;

        //GRI = CPGameReplicationInfo(WorldInfo.GRI);
        //if (GRI != None && GRI.bMatchIsOver)
        //{
        //  ShowMidGameMenu('ScoreTab',true);
        //}
        //else
        if (myHUD != None)
        {
            myHUD.SetShowScores(true);
        }
        AutoContinueToNextRound();
    }

    /** This will auto continue to the next round.  Very useful doing soak testing and testing traveling to next level **/
    function AutoContinueToNextRound()
    {
        if ( Role == ROLE_Authority && WorldInfo.Game.ShouldAutoContinueToNextRound() )
        {
            myHUD.SetShowScores(false);
            StartFire( 0 );
        }
    }

    function BeginState(Name PreviousStateName)
    {
        Super.BeginState(PreviousStateName);

        // this is a good stop gap measure for any cases that we miss / other code getting turned on / called
        // there is never a case where we want the tilt to be on at this point
        SetOnlyUseControllerTiltInput( FALSE );
        SetUseTiltForwardAndBack( TRUE );
        SetControllerTiltActive( FALSE );

        //if (CriticalPointGame(WorldInfo.Game) != None)
        //{
        //  // don't let player restart the game until the end game sequence is complete
        //  SetTimer(FMax(GetTimerRate(), CriticalPointGame(WorldInfo.Game).ResetTimeDelay), false);
        //}

        //bAlreadyReset = false;

        if ( myHUD != None )
        {
            myHUD.SetShowScores(false);
            // the power core explosion is 15 seconds  so we wait 1 additional for the awe factor (the total time of the matinee is 18-20 seconds to avoid popping back to start)
            // so for DM/CTF will get to see the winner in GLORIOUS detail and listen to the smack talking
            SetTimer(16, false, 'ShowScoreboard');
        }
        
    }

    function EndState(name NextStateName)
    {
        Super.EndState(NextStateName);
        SetBehindView(false);
        StopViewShaking();
        StopCameraAnim(true);
        if (myHUD != None)
        {
            myHUD.SetShowScores(false);
        }

    }
}

state Dead
{
    ignores SeePlayer, HearNoise, KilledBy, NextWeapon, PrevWeapon;

    exec function SwitchWeapon(byte T){}
    exec function Toggle_Flashlight() {}
    exec function ToggleMelee() {}
    exec function StartFire( optional byte FireModeNum )
    {
        if ( bFrozen )
        {
            if ( !IsTimerActive() || GetTimerCount() > MinRespawnDelay )
                bFrozen = false;
            return;
        }
        if ( PlayerReplicationInfo.bOutOfLives )
            ServerSpectate();
        else
            super.StartFire( FireModeNum );
    }

    function Timer()
    {
        if (!bFrozen)
            return;

        // force garbage collection while dead, to avoid GC during gameplay
        if ( (WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone) )
        {
            WorldInfo.ForceGarbageCollection();
        }
        bFrozen = false;
        bUsePhysicsRotation = false;
        bPressedJump = false;
    }

    reliable client event ClientSetViewTarget( Actor A, optional ViewTargetTransitionParams TransitionParams )
    {
        if( A == None )
        {
            ServerVerifyViewTarget();
            return;
        }
        // don't force view to self while dead (since server may be doing it having destroyed the pawn)
        if ( A == self )
            return;
        SetViewTarget( A, TransitionParams );
    }


    function FindGoodView()
    {
        //`log( "CPPlayerController::FindGoodView: I'm a big 'ol retarded function that likes to roll your view for no good reason." );
        GoToState( 'Spectating' );
    }

    function BeginState( Name PreviousStateName )
    {
        if(string(PreviousStateName) == "PlayerWalking")
        {
            StopFlash(false);
        }
        super.BeginState( PreviousStateName );
        SetBehindView( false );
    }

    function EndState(name NextStateName)
    {
        bUsePhysicsRotation = false;
        Super.EndState(NextStateName);
        SetBehindView(false);
        StopViewShaking();
    }

    Begin:
    Sleep(5.0);

    if ( CPPawn(Pawn) != None && CPPawn(Pawn).bIsFlashlightOn )
        CPPawn(Pawn).Toggle_Flashlight();

    if ( (ViewTarget == None) || (ViewTarget == self) || (VSize(ViewTarget.Velocity) < 1.0) )
    {
        Sleep(1.0);
    }
    else
        Goto('Begin');
}


/**
 * Set new camera mode
 *
 * @param   NewCamMode, new camera mode.
 */
function SetCameraMode( name NewCamMode )
{
    if ( PlayerCamera != None )
    {
        super.SetCameraMode(NewCamMode);
    }
    else if ( NewCamMode == 'ThirdPerson' )
    {
        if ( !bBehindView )
            SetBehindView(true);
    }
    else if ( NewCamMode == 'FreeCam' )
    {
        if ( !bBehindView )
        {
            SetBehindView(true);
        }
    }
    else
    {
        if ( bBehindView )
            SetBehindView(false);
    }
}



reliable client function ClientSetBehindView(bool bNewBehindView)
{
    if (LocalPlayer(Player) != None)
    {
        SetBehindView(bNewBehindView);
    }
}

function ServerSpectate()
{
    GotoState('Spectating');
}

unreliable server function SetGhostcam()
{
    return;
}

unreliable server function ServerSpectateOtherTeam()
{
    return;
}


state Spectating
{
    exec function SwitchWeapon(byte F){}
    exec function Toggle_Flashlight(){}

    simulated function bool PerformedUseAction(){ return true;};

    function BeginState( Name PreviousStateName )
    {
        if(string(PreviousStateName) != "Dead")
        {
            StopFlash();
        }
        //make sure arms are hidden when we go into spectating mode.
		if(CPPawn(Instigator) != none)
			CPPawn(Instigator).HideArms(true);

        Super.BeginState(PreviousStateName);

        ClearTimer( 'ServerViewNextPlayer' );

        if (PlayerReplicationInfo != none)
        {
            PlayerReplicationInfo.bIsSpectator = true;
        }

        // Get a player to spectate
        bForceBehindView = false;

        if (LocalPlayer(Player) == None)
        {
            ClientSetBehindView(false);
        }
        else if (CPPawn(ViewTarget) != None)
        {
            CPPawn(ViewTarget).SetThirdPersonCamera(false);
        }
        
    }

    function EndState( Name NextStateName )
    {
        bForceBehindView = false;
        bBehindView = false;
        SetServerSpectatingName("", 2);
        if ( PlayerReplicationInfo != None )
        {
            if ( PlayerReplicationInfo.bOnlySpectator )
            {
                `log("WARNING - Spectator only player leaving spectating state to go to "$NextStateName);
            }
            PlayerReplicationInfo.bIsSpectator = false;
        }
        ClearTimer( 'ServerViewNextPlayer' );
    }

    function SetServerViewNextPlayer()
    {
        ServerViewNextPlayer();
    }



    /** called when the actor falls out of the world 'safely' (below KillZ and such) */
    simulated event FellOutOfWorld(class<DamageType> dmgType)
    {
        bCameraOutOfWorld = true;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldLocation;

        OldLocation = Location;
        super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);

        if ( bCameraOutOfWorld )
        {
            bCameraOutOfWorld = false;
            SetLocation(OldLocation);
        }
    }

    /**
     * The Prev/Next weapon functions are used to move forward and backwards through the player list
     */

    exec function PrevWeapon()
    {
		local actor prevViewTarget;
		prevViewTarget = ViewTarget;
        ServerViewPrevPlayer();
		if(prevViewTarget != ViewTarget)
		{
			ToggleScope(false);
		}
    }

    exec function NextWeapon()
    {
		local actor prevViewTarget;
		prevViewTarget = ViewTarget;
        ServerViewNextPlayer();
        if(prevViewTarget != ViewTarget)
		{
			ToggleScope(false);
		}
    }

    exec function StartFire( optional byte FireModeNum )
    {
        ServerViewNextPlayer();
    }

    exec function StartAltFire( optional byte FireModeNum )
    {
		local actor prevViewTarget;
		prevViewTarget = ViewTarget;
        SetGhostcam();
        if(prevViewTarget != ViewTarget)
		{
			ToggleScope(false);
		}
    }

    // If view all players and are spectating then switch to
    // other team. Otherwise this will do nothing.
    unreliable server function ServerSpectateOtherTeam()
    {
        SpectateOtherTeam();
    }

    // If we are spectating then we should change to GhostCam
    // only if the server allows Ghost cam.
    unreliable server function SetGhostcam()
    {
        // Goto Ghostcam mode in both OWN TEAM modes and ALL PLAYERS mode.
        // Only do this is ghost cam is enabled.
        if(WorldInfo.Game != none && CriticalPointGame(WorldInfo.Game).bAllowGhostCam )
        {
            bIsInGhostCam = True;
            SetViewTarget(self);
        }
    }

    // If using the use key and we are spectating then we will switch from one
    // team to another if the spectating rules allow it.
    unreliable server function ServerUse()
    {
        // If we're in Spectator Mode or spawned as Spectator then goto GhostCam
        if(PlayerReplicationInfo.bOnlySpectator)
        {
            SetGhostcam();
        }
        // Otherwise spectate opposite team
        else
        {
            ServerSpectateOtherTeam();
        }
    }

    // Switch to next player after switching teams.
    reliable server function ServerChangeTeam( int N )
    {
        //Super(CPPlayerController).ServerChangeTeam(N);
        //ServerViewNextPlayer();

        //@Wail - 11/25/13 - We need to restart the player if they try to change teams
        local CPGameReplicationInfo TAGRI;
        Super(CPPlayerController).ServerChangeTeam(N);

        TAGRI = CPGameReplicationInfo(WorldInfo.GRI);

        if (bIsPlayer &&
            PlayerReplicationInfo != none &&
            !PlayerReplicationInfo.bOnlySpectator &&
            !PlayerReplicationInfo.bOutOfLives &&
            !CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped &&
            TAGRI != none &&
            !TAGRI.bDamageTaken)
        {
            ServerRestartPlayer();
        }
        else if( bIsPlayer &&
                 PlayerReplicationInfo != none &&
                 (PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bOutOfLives ||
                  CPPlayerReplicationInfo(PlayerReplicationInfo).bHasEscaped) &&
                  PlayerReplicationInfo.Team != None)
        {
            ServerViewNextPlayer();
            //GotoState('Spectating');
            //ClientGotoState('Spectating');
        }

    }

    exec function ViewPlayerByName(string sPlayerName)
    {
        ServerViewPlayerByName(sPlayerName);
    }

    /**
     * Handle forcing behindview/etc
     */
    simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
    {
        // Force first person mode in spectating state
        SetBehindView(false);

        Global.GetPlayerViewPoint(out_Location, out_Rotation);
    }

    // Rogue. Verify that we have a valid target when switching to Spectator. If we do not then
    // switch to ghostcam mode if available.
    Begin:

    if(CPPawn(ViewTarget) == none || ViewTarget == none)
    {
        SetGhostcam();
        Sleep(1.0);
    }

}

/**
 * View next active player in PRIArray.
 * @param dir is the direction to go in the array
 *
 * This function should act like the following.
 * 1. If server is set to OWN TEAM.
 * 2. Should see message "spectating player "name" at bottom of screen. The names should
 * be colored. Blue for swat and Red for Merc.
 * 3. Forward view player should cycle forward through own team
 * 4. Backward view player should cycle backwards through own team.
 *
 * 1. If server is set to ALL PLAYERS.
 * 2. Should see message "spectating player "name" at the bottom of the screen.
 * 3. Supposed to cycle through live members of first team. Then cycle through second team and then repeat.
 * 4. Forward goes forward through team and back goes back.
 */
function ViewAPlayer(int dir)
{
    local int i, CurrentIndex, NewIndex;
    local PlayerReplicationInfo PRI;
    local bool bCannotFindPRI;
    //local int CurrentTeam;

    CurrentIndex = -1;
    NewIndex=-1;
    bCannotFindPRI = False;
    if ( RealViewTarget != None )
    {
		if(WorldInfo.GRI != none)
		{
			// Find index of current viewtarget's PRI
			For ( i = 0; i < WorldInfo.GRI.PRIArray.Length; i++ )
			{
				if ( RealViewTarget == WorldInfo.GRI.PRIArray[i] )
				{
					CurrentIndex = i;
					//CurrentTeam = RealViewTarget.Team.TeamIndex;
					break;
				}
			}
		}
    }

    // make sure dir is -1  or 1
    dir = dir >= 1 ? 1 : -1;

    // Find next valid viewtarget in appropriate direction.
	if(WorldInfo.GRI != none)
	{
		for ( NewIndex = CurrentIndex + dir; (NewIndex >= 0) && (NewIndex < WorldInfo.GRI.PRIArray.Length); NewIndex = NewIndex + dir )
		{
			PRI = WorldInfo.GRI.PRIArray[NewIndex];
			if ( (PRI != None) && (Controller(PRI.Owner) != None) && (Controller(PRI.Owner).Pawn != None) && WorldInfo.Game.CanSpectate(self, PRI)
				&& (PRI.Team != none) /*&& (CurrentTeam == PRI.Team.TeamIndex)*/ )
			{
				SetViewTarget(PRI);
				return;
			}

			// Haven't found a PRI, so wrap around to the other side
			if ( NewIndex <= 0 || NewIndex >= WorldInfo.GRI.PRIArray.Length - 1 )
			{
				// couldn't find a PRI
				if ( bCannotFindPRI )
					return;
				CurrentIndex = (dir > -1) ? -1 : WorldInfo.GRI.PRIArray.Length;
				NewIndex = CurrentIndex + dir;
				bCannotFindPRI = True;
			}
		}
	}
}

/**
 * View active player.
 * @param playerID is ID of player we want to move our view to.
 *
 * 
 */
function ViewPlayerID(int playerId)
{
    local int NewIndex;
    local CPPlayerReplicationInfo PRI;


    // Switch to player if player is available.
	if(WorldInfo.GRI != none)
	{
		for ( NewIndex = 0; NewIndex < WorldInfo.GRI.PRIArray.Length; NewIndex++ )
		{
			PRI = CPPlayerReplicationInfo(WorldInfo.GRI.PRIArray[NewIndex]);
			if ( (PRI != None) && (Controller(PRI.Owner) != None) && (Controller(PRI.Owner).Pawn != None) && WorldInfo.Game.CanSpectate(self, PRI)
				&& (PRI.Team != none) && (playerId == PRI.PlayerID) )
			{
				SetViewTarget(PRI);
				return;
			}
		}
	}
}

/**
 * Set Spectating name and team.
 * @param SpecdPlayerName is the currently name that we are spectating
 * @param SpecdPlayerTeam si the current team of the name we are spectating
 */
reliable client function SetServerSpectatingName(string SpecdPlayerName, int SpecdPlayerTeam)
{
    if(myHUD != none)
    {
        //CPHUD(myHUD).SpectatingName = SpecdPlayerName;
        //CPHUD(myHUD).SpectatingPlayerTeam = SpecdPlayerTeam;
    }
}

/**
 * Switch to other team.
 * This function will swap from the currently selected team to the opposing team
 * when spectating.
 */
function SpectateOtherTeam()
{
    local int i, CurrentIndex, NewIndex;
    local PlayerReplicationInfo PRI;
    local int CurrentTeam;

    CurrentIndex = -1;
    if ( RealViewTarget != None )
    {
        // Find index of current viewtarget's PRI
        For ( i=0; i<WorldInfo.GRI.PRIArray.Length; i++ )
        {
            if ( RealViewTarget == WorldInfo.GRI.PRIArray[i] )
            {
                if(RealViewTarget.Team != none)
                {
                CurrentTeam = RealViewTarget.Team.TeamIndex;
                break;
                }
            }
        }
    }

    // Find next valid viewtarget on opposite team
    for ( NewIndex=CurrentIndex+1; (NewIndex>=0)&&(NewIndex<WorldInfo.GRI.PRIArray.Length); NewIndex=NewIndex+1 )
    {
        PRI = WorldInfo.GRI.PRIArray[NewIndex];
        if ( (PRI != None) && (PRI.Team != none) && (Controller(PRI.Owner) != None) && (Controller(PRI.Owner).Pawn != None)
            && WorldInfo.Game.CanSpectate(self, PRI) && CurrentTeam != PRI.Team.TeamIndex )
        {
            SetViewTarget(PRI);
            return;
        }
    }

}


exec function PlayerInfoToggle()
{
local CPSaveManager TSave;
local CPHUD THUD;

    THUD=CPHUD(myHUD);
    TSave=new class'CPSaveManager';
    THUD.bDrawPlayerInfo=!THUD.bDrawPlayerInfo;
    TSave.SetBool("DrawPlayerInfo",THUD.bDrawPlayerInfo);
    `log("CPPlayerController::PlayerInfoToggle");
}

function ChangeMercModel ( optional int CharacterSelected )
{
    if (CPGameReplicationInfo(WorldInfo.GRI).RoundIsActive())
    {
        // at this point we force a suicide even if changing from one model on the same team to the other
        // this is because the pawn's hitsounds are not updated when the model is updated.
        // && CPHud(cppc.myHUD).intTeamSelected != cppc.GetTeamNum()
        if (CPPawn(Pawn) != none)
        {
            // In a single-player or private game
            if (WorldInfo.NetMode == NM_StandAlone)
            {
                CPPawn(Pawn).Suicide();
            }
            // In a multi-player or online game
            else
            {
                ServerSuicide();
            }
        }
    }

    SetPendingCharacterClass( GetMercCharacterClass(CharacterSelected) );
}

function ChangeSwatModel ( optional int CharacterSelected )
{
    if (CPGameReplicationInfo(WorldInfo.GRI).RoundIsActive())
    {
        // at this point we force a suicide even if changing from one model on the same team to the other
        // this is because the pawn's hitsounds are not updated when the model is updated.
        // && CPHud(cppc.myHUD).intTeamSelected != cppc.GetTeamNum()
        if (CPPawn(Pawn) != none)
        {
            // In a single-player or private game
            if (WorldInfo.NetMode == NM_StandAlone)
            {
                CPPawn(Pawn).Suicide();
            }
            // In a multi-player or online game
            else
            {
                ServerSuicide();
            }
        }
    }

    SetPendingCharacterClass(GetSwatCharacterClass(CharacterSelected));
}

protected simulated function class<CPFamilyInfo> GetMercCharacterClass (int inValue)
{
    switch(inValue)
    {
        case 0:
            return class'CriticalPoint.CP_MERC_MaleOne';
            break;
        case 1:
            return class'CriticalPoint.CP_MERC_FemaleOne';
            break;
        default:
            return class'CriticalPoint.CP_MERC_MaleOne';
            break;
    }

    return class'CriticalPoint.CP_MERC_MaleOne';
}

protected simulated function class<CPFamilyInfo> GetSwatCharacterClass (int inValue)
{
    switch(inValue)
    {
        case 0:
            return class'CriticalPoint.CP_SWAT_MaleOne';
            break;
        case 1:
            return class'CriticalPoint.CP_SWAT_FemaleOne';
            break;
        default:
            return class'CriticalPoint.CP_SWAT_MaleOne';
            break;
    }

    return class'CriticalPoint.CP_SWAT_MaleOne';
}

exec function ChangeTeam( optional string TeamName )
{
    local int N;

    if (TeamName ~= "SF" || TeamName ~= "1")
    {
        N = 1;
    }
    else if (TeamName ~= "Merc" || TeamName ~= "0")
    {
        N = 0;
    }
    else if (TeamName ~= "Spectator" || TeamName ~= "255")
    {
        //@Wail - 11/25/13 - Ensure that when players switch to spectating / spectator team, their pawn is cleaned up
        if (Pawn != None)
            CleanupPawn();
        N = 255;
    }
    else
        N = 1 - PlayerReplicationInfo.Team.TeamIndex;

    ServerChangeTeam(N);
}

reliable server function ServerChangeTeam(int N)
{
    local TeamInfo OldTeam;

    if (PlayerReplicationInfo.Team != None)
    {
        OldTeam = PlayerReplicationInfo.Team;
    }

    if (WorldInfo.Game != none)
    {
        WorldInfo.Game.ChangeTeam(self, N, true);

        if (WorldInfo.Game.bTeamGame && OldTeam != None && PlayerReplicationInfo.Team != None && PlayerReplicationInfo.Team != OldTeam)
        {
            // Force model changes when utilizing any sort of team changing functionality
            // SetPendingCharacterClass will check itself whether we need to immediately force a model change, or just update the pending model
            if (CPPlayerReplicationInfo(PlayerReplicationInfo).Team.TeamIndex == 1)
            {
                // preserve gender choice of player in model chosen
                SetPendingCharacterClass( GetSwatCharacterClass(int(CPPlayerReplicationInfo(PlayerReplicationInfo).bIsFemale)) );
            }
            if (CPPlayerReplicationInfo(PlayerReplicationInfo).Team.TeamIndex == 0)
            {
                // preserve gender choice of player in model chosen
                SetPendingCharacterClass( GetMercCharacterClass(int(CPPlayerReplicationInfo(PlayerReplicationInfo).bIsFemale)) );
            }

            if (Pawn != None)
            {
                ThrowBombOnDeath();
                Pawn.PlayerChangedTeam();
                //Rogue - Check if player is still alive after switching teams.
                // if alive then restart player - we want to preserve their inventory , money and score
                if (Pawn != None && Pawn.Health > 0)
                {
                    //fix up HUD if neeed be
                    ClientResetHUD();
                    // Reset Controller
                    CriticalPointGame(WorldInfo.Game).RestartPlayer(self);
                }
            }
            // Check if round should end after swapping teams.
            if (CPGameReplicationInfo(WorldInfo.GRI) != none && CPGameReplicationInfo(WorldInfo.GRI).RoundIsActive())
            {
                CriticalPointGame(WorldInfo.Game).CheckMaxLives(PlayerReplicationInfo, true);
            }
        }
    }
}

// used to clean-up/reset stuff in HUD
reliable client function ClientResetHUD()
{
    CloseBuyMenuIfOpen();
    bDontKillFlashAudioCue=false; 
    StopFlash();
}

function bool CloseBuyMenuIfOpen()
{
    local GFxCPBuyMenu BuyMenuMovie;
    
    BuyMenuMovie = CPHUD(myHUD).BuyMenuMovie;
    
    if ( BuyMenuMovie != None )
    {
        if(!BuyMenuMovie.CloseMenu())
        {
            BuyMenuMovie.PlayCloseAnimation();
            BuyMenuMovie.Close(true);
            CPHUD(myHUD).BuyMenuMovie = None;
            CPHUD(myHUD).bCrosshairShow = true;
            return true;
        }
    }
    return false;
}


//@Wail - 12/09/13 - When players return to game from spectate...
exec function BecomeActive()
{
    if (PlayerReplicationInfo.bOnlySpectator)
    {
        PlayerReplicationInfo.bOutOfLives = false;
		ServerBecomeActivePlayer();
    }
}

//@Wail - 12/09/13 - When players return to game from spectate...
//spectating player wants to become active and join the game
reliable server function ServerBecomeActivePlayer()
{
    local CriticalPointGame Game;

    Game = CriticalPointGame(WorldInfo.Game);
    if ( PlayerReplicationInfo.bOnlySpectator && !WorldInfo.IsInSeamlessTravel() && HasClientLoadedCurrentWorld() && Game != None ) //&& Game.AllowBecomeActivePlayer(self)
    {
        SetBehindView(false);
        FixFOV();
        ServerViewSelf();
		PlayerReplicationInfo.bOutOfLives = false;
        PlayerReplicationInfo.bOnlySpectator = false;
        Game.NumSpectators--;
        Game.NumPlayers++;

        BroadcastLocalizedMessage(Game.GameMessageClass, 1, PlayerReplicationInfo);
        if (Game.bTeamGame)
        {
            //@FIXME: get team preference!
            //Game.ChangeTeam(self, Game.PickTeam(0, None), false);
        }
        if (!Game.bDelayedStart)
        {
            // start match, or let player enter, immediately
            Game.bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
            if (Game.bWaitingToStartMatch)
            {
                PlayerReplicationInfo.bOutOfLives = false;
                Game.StartMatch();
            }
            else
            {
                PlayerReplicationInfo.bOutOfLives = false;
                Game.RestartPlayer(self);
            }
            Game.bRestartLevel = Game.Default.bRestartLevel;
        }
        else
        {
            GotoState('PlayerWaiting');
            ClientGotoState('PlayerWaiting');
        }

        //ClientBecameActivePlayer();
    }
}

function Reset()
{
    SpecScopedWeapon = none;
    ToggleScope(false);

	if (PlayerReplicationInfo.bOnlySpectator)
    {
        return;
    }
    Super.Reset();
    if ( PlayerCamera != None )
    {
        PlayerCamera.Destroy();
    }
}

/**
 * Advanced LOS check, check if the actor is in the player's LOS and secondly check how well the player aims at the actor.
 *
 * @param chka          actor to check
 * @param aimError      how much error is allowed
 * @param MaxDistance   (optional) max. distance to check
 */
simulated function bool IsLookingAtActorWithPct(Actor chka,float aimError,optional float MaxDistance)
{
local Vector V;
local float dotError;

    if (chka==none || chka==self || chka==Pawn || chka==Pawn.Weapon)
        return false;
    if (VSize(chka.Location-Pawn.Location)>MaxDistance)
        return false;
    if (!LineOfSightTo(chka))
        return false;

    if (aimError>1.0)
        dotError=1.0;
    else if (aimError<0.0)
        dotError=0.0;
    else
        dotError=aimError;
    dotError=1.0-dotError;
    V=Normal(chka.Location-Pawn.Location);

    return ((V dot vector(pawn.GetViewRotation()))>dotError);
}

/** by pass use function when not allowed to use */
exec function Use()
{
    /*
    *   For the Scaleform chat system
    *   If Enter is hit then send message
    */
    CPHUD = CPHUD(myHUD);
    if(CPHUD != none)
    {
        if(CPHUD.HudMovie != none)
        {
            if(CPHUD.HudMovie.bChatting)
            {
                CPHUD.HudMovie.bCaptureInput = true;

                if(CPHUD.HudMovie.ChatType != "")
                {
                    CPHUD.HudMovie.OnChatSend(CPHUD.HudMovie.ChatType);
                }
            }
        }
    }

    //`log( ".. CPPlayerController::Use" );
    if (CPGameReplicationInfo(WorldInfo.GRI).bCanPlayersMove)
    {
        if( Role < Role_Authority )
            PerformedUseAction();

        ServerUse();
    }
}



exec function StopUse()
{
    ServerStopUse();
}

unreliable server function ServerUse()
{
    local Vector            _Location, _Direction;
    local Rotator           _Rotation;
    local CPDroppedPickup   _Pickup;
    local CPHostage         _Hostage, _FoundHostage;
    local CPDroppedBomb     _DroppedBomb;
    local CPWeapon          _Weapon, _DroppedWeapon;
    local CPWeap_Bomb       _Bomb;
    local CPPawn            _Pawn;
    local float             _Length, _Closest, _Delta;
	local CPGameReplicationInfo     _GRI;

    //local Actor _HitActor;
    //local Vector _HitLocation, _HitNormal, _HitDistance, _RotationAsVector;

    //local Rotator PawnFacing, HackingAngle;
    //local Vector VectToHackZone;
    //local bool bHitFromFront;

    _Pawn = CPPawn( Pawn );
    if ( _Pawn == none )
        return;

    //`log( ".. CPPlayerController::ServerUse" );
    if ( CPGameReplicationInfo( WorldInfo.GRI ).bCanPlayersMove )
    {
        _Weapon = CPWeapon( _Pawn.Weapon );

        PerformedUseAction();
        _Pawn.bIsUseKeyDown = true;

        GetActorEyesViewPoint( _Location, _Rotation );
        _Direction = Vector( _Rotation );

        // If we are a spectator, don't give us anything
        if(CPPlayerReplicationInfo(PlayerReplicationInfo) != none)
        {
            if(!CPPlayerReplicationInfo(PlayerReplicationInfo).bOnlySpectator || !CPPlayerReplicationInfo(PlayerReplicationInfo).bIsSpectator)
            {
                if( _Pawn.HackZone != none )
                {
                    /*
                    _RotationAsVector = Vector(_Rotation);

                    //Distance Vector
                    _HitDistance = _Location + normal(_RotationAsVector)*(_Pawn.HackZone.ZoneExtent);

                    //Get Actor
                    _HitActor = Trace(_HitLocation, _HitNormal, _HitDistance, _Location, true);

                    VectToHackZone = _Pawn.HackZone.Location - Location;
                    VectToHackZone.Z = 0;
                    HackingAngle = Rotator(VectToHackZone);

                    PawnFacing = Rotation;
                    PawnFacing.Pitch = 0;

                    bHitFromFront = RDiff(PawnFacing, HackingAngle) <= 90;

                    // Did we hit the zones physical mesh or bsp AND are we looking 30 degrees or less towards it?
                    if (_HitActor != none && bHitFromFront && _Pawn.HackZone.Use( _Pawn ))
                    {
                        return;
                    }
                    */

                    if (_Pawn.Controller.IsAimingAt(_Pawn.HackZone.HackObjective, _Pawn.HackZone.HackObjective.AimEpsilon))
                    {
                        _Pawn.HackZone.HackObjective.UsedBy(_Pawn);
                    }
                }

                // Deal with hostages
                _Closest = 1024.0f;
                foreach WorldInfo.AllControllers( class'CPHostage', _Hostage )
                {
                    if ( _Hostage.Pawn == none )
                        continue;

                    _Length = VSize( _Hostage.Pawn.Location - _Location );
                    _Delta = VSizeSq( _Hostage.Pawn.Location - (_Location + _Direction * _Length) );

                    // Are we in range and looking at the hostage?
                    if ( _Length > 192.0f || _Delta > _Closest )
                        continue;

                    _FoundHostage = _Hostage;
                }

                //Hostage Target Toggle
                if(_FoundHostage != none && _FoundHostage.Enemy != none)
                {
                    _FoundHostage.Enemy = none;
                }
                else if(_FoundHostage != none)
                {
                    _FoundHostage.Enemy = _Pawn;
                }

                // Are we crouched, and ready to defuse a bomb?
                foreach _Pawn.CollidingActors( class'CPDroppedPickup', _Pickup, class'CPDroppedPickup'.default.MaxPickupRange )
                {
                    if ( _Pickup.IsA( 'CPDroppedBomb' ) )// We're dealing with a CP_DroppedBomb
                    {
                        if ( !_Pawn.bIsCrouched || _Pawn.GetTeamNum() != TTI_SpecialForces )
                            continue;

                        `log( "Boop crouched SF" );
                        _DroppedBomb = CPDroppedBomb( _Pickup );
                        _Bomb = CPWeap_Bomb( _DroppedBomb.Inventory );
                        if ( _Bomb == none )
                            continue;

                        `log( "Boop bomb" @ _Bomb.PlantTimestamp @ WorldInfo.TimeSeconds );
                        // The bomb must be armed and not currently being Defused
                        if( !_Bomb.IsPlanted() /*|| _DroppedBomb.bDiffuseAttempt*/ )
                            continue;

                        `log( "Boop planted" );
                        _Length = VSize( _DroppedBomb.Location - _Location );

                        // Are we in range and looking at the bomb?
                        if ( _Length > 64.0f || VSizeSq( _DroppedBomb.Location - (_Location + _Direction * _Length) ) > 256.0f )
                            continue;

                        `log( "Boop looking at" );
                        //_DroppedBomb.Diffuser = self;
                        //_DroppedBomb.bDiffuseAttempt = true;
						//777
						
						_GRI = CPGameReplicationInfo( WorldInfo.GRI );

						if (_GRI.bRoundIsOver == false){
							_DroppedBomb.GiveTo( _Pawn );
							_Pawn.bIsUsingObjective = true;
						}
                        //_Bomb.GotoState( 'Defusing' );
                    }
                    else // We're dealing with a CPDroppedPickup
                    {
                        if ( _Weapon == none || _Weapon.IsReloading() || _Weapon.IsFiring() )
                            continue;

                        _DroppedWeapon = CPWeapon( _Pickup.Inventory );
                        if ( _DroppedWeapon == none )
                            continue;

                        _Length = VSize( _Pickup.Location - _Location );

                        // Are we looking at the pickup?
                        if ( VSizeSq( _Pickup.Location - (_Location + _Direction * _Length) ) > 256.0f )
                            continue;

                        if ( _Weapon.InventoryGroup == _DroppedWeapon.InventoryGroup )
                        {
                            _Pawn.TossInventory( _Pawn.Weapon );
                            _Pickup.GiveTo( _Pawn );
                            break;
                        }
                    }
                }
            }
        }
    }
    else
    {
        _Pawn.bIsUseKeyDown = false;
    }
}

unreliable server function ServerStopUse()
{
    local CPPawn TPawn;

    //`log( ".. CPPlayerController::ServerStopUse" );
    TPawn = CPPawn( Pawn );
    if ( TPawn != none )
        TPawn.bIsUseKeyDown = false;
}

exec function StartReload()
{
    if (CPPawn(Pawn)!=none && !bCinematicMode)
        CPPawn(Pawn).StartReload();
}

exec function StopReload()
{
    if (CPPawn(Pawn)!=none)
        CPPawn(Pawn).StopReload();
}

exec function StartFireModeSwitch()
{
    if (CPPawn(Pawn)!=none && !bCinematicMode)
        CPPawn(Pawn).StartFireModeSwitch();
}

exec function StopFireModeSwitch()
{
    if (CPPawn(Pawn)!=none)
        CPPawn(Pawn).StopFireModeSwitch();
}

/** Weapon Auto Reload functions */
function SetWeaponAutoReload(bool bShouldWeapAutoReload)
{
    ServerSetWeaponAutoReload(bShouldWeapAutoReload);
    bWeaponAutoReload=bShouldWeapAutoReload;
}

reliable server function ServerSetWeaponAutoReload(bool bShouldWeapAutoReload)
{
    bWeaponAutoReload=bShouldWeapAutoReload;
}

/** auto switch functions */
exec function SwitchToLastWeapon(optional bool bForceNewWeapon)
{
    if (CPPawn(Pawn)==none || CPInventoryManager(Pawn.InvManager)==none)
    {
        return;
    }
    CPInventoryManager(Pawn.InvManager).SwitchToPreviousWeapon();
}

reliable client function ResetScopeSettings()
{
    SpecScopedWeapon = None;
    ToggleScope(false);
}

reliable client function ClientSwitchToLastWeapon(optional bool bForceNewWeapon)
{
    SwitchToLastWeapon(bForceNewWeapon);
}

reliable client function ClientAutoSwitch(optional bool bForceNewWeapon)
{
    if (WeaponAutoSwitchMode==0)
        ClientSwitchToBestWeapon(bForceNewWeapon);
    else if (WeaponAutoSwitchMode==1)
        ClientSwitchToLastWeapon(bForceNewWeapon);
    else
    {
        `warn("invalid auto switch mode was specified ["$WeaponAutoSwitchMode$"], reverted to switch to best");
        WeaponAutoSwitchMode=0;
    }
}

    //1. take clips
    //2. remove weapon
    //3. add weapon
    //4. add clip
final function array<string> sortShoppingList(array<string> ShoppingCommands)
{
    local int i;
    local array<string> Command, sortedShoppingCommands;
    local string strCommand;

    for(i = 0 ; i < ShoppingCommands.Length ; i++)
    {
        //`Log(ShoppingCommands[i]);
        Command = SplitString(ShoppingCommands[i], ":",true);
        strCommand = Command[0]; //bug if you put command[0] into a switch!

        if(strCommand == "TakeClip")
        {
            sortedShoppingCommands.InsertItem(sortedShoppingCommands.Length, ShoppingCommands[i]);
        }
    }

    for(i = 0 ; i < ShoppingCommands.Length ; i++)
    {
        //`Log(ShoppingCommands[i]);
        Command = SplitString(ShoppingCommands[i], ":",true);
        strCommand = Command[0]; //bug if you put command[0] into a switch!

        if(strCommand == "RemoveWeapon")
        {
            sortedShoppingCommands.InsertItem(sortedShoppingCommands.Length, ShoppingCommands[i]);
        }
    }

    for(i = 0 ; i < ShoppingCommands.Length ; i++)
    {
        //`Log(ShoppingCommands[i]);
        Command = SplitString(ShoppingCommands[i], ":",true);
        strCommand = Command[0]; //bug if you put command[0] into a switch!

        if(strCommand == "CreateWeaponInventory")
        {
            sortedShoppingCommands.InsertItem(sortedShoppingCommands.Length, ShoppingCommands[i]);
        }
    }

    for(i = 0 ; i < ShoppingCommands.Length ; i++)
    {
        //`Log(ShoppingCommands[i]);
        Command = SplitString(ShoppingCommands[i], ":",true);
        strCommand = Command[0]; //bug if you put command[0] into a switch!

        if(strCommand == "AddClip")
        {
            sortedShoppingCommands.InsertItem(sortedShoppingCommands.Length, ShoppingCommands[i]);
        }
    }

    for(i = 0 ; i < ShoppingCommands.Length ; i++)
    {
        //`Log(ShoppingCommands[i]);
        Command = SplitString(ShoppingCommands[i], ":",true);
        strCommand = Command[0]; //bug if you put command[0] into a switch!

        if(strCommand == "RemoveArmorFromInventory")
        {
            sortedShoppingCommands.InsertItem(sortedShoppingCommands.Length, ShoppingCommands[i]);
        }
    }

    for(i = 0 ; i < ShoppingCommands.Length ; i++)
    {
        //`Log(ShoppingCommands[i]);
        Command = SplitString(ShoppingCommands[i], ":",true);
        strCommand = Command[0]; //bug if you put command[0] into a switch!

        if(strCommand == "CreateInventory")
        {
            sortedShoppingCommands.InsertItem(sortedShoppingCommands.Length, ShoppingCommands[i]);
        }
    }

	ClearSpectatorWeaponsOrdered();

    return sortedShoppingCommands;
}


reliable server function int ShoppingList(string ShopArray)
{
    local array<string> ShoppingCommands, Command;
    local int i;
    local string strCommand;

	if(CPPawn(Pawn) == none)
		return 0;

    if(CPPawn(Pawn).BuyZone == none)
    {
        `Log("ATTEMPT TO BUY WHEN NOT IN BUYZONE DETECTED!");
        return 0;
    }
    //`Log("ShoppingList:: ShopArray RESULT STRING IS" @ ShopArray);

    //split this string into commands.
    ShoppingCommands = SplitString(ShopArray, " ",true);
    ShoppingCommands = sortShoppingList(ShoppingCommands);

    for(i = 0 ; i < ShoppingCommands.Length ; i++)
    {
        Command = SplitString(ShoppingCommands[i], ":",true);
        strCommand = Command[0]; //bug if you put command[0] into a switch!

        //`log(strCommand $ ": " $ Command[1]);
        switch(strCommand)
        {
            case "CreateWeaponInventory":
                CreateWeaponInventory(Command[1]);
            break;
            case "CreateInventory":
                CreateInventory(Command[1]);
            break;
            case "RemoveArmorFromInventory":
                RemoveArmorFromInventory(Command[1]);
            break;
            case "RemoveWeapon":
                RemoveWeapon(Command[1]);
            break;
                case "AddClip":
                DoClip(Command[1]);
            break;
                case "TakeClip":
                DoClip(Command[1]);
            break;
        }
    }
    return CPPlayerReplicationInfo(PlayerReplicationInfo).Money;

    //the return allows the server to issue everything before we close the menus.
    //return true;
}

function DoClip(string InventoryObjectAndClip)
{
    local array<string> Command;
    local string strWeapon;
    local int intWeaponClipsToAdd;
    local CPWeapon Inv;
    local class<CPWeapon> MyInventory;


    Command = SplitString(InventoryObjectAndClip, "|",true);
    strWeapon = Command[0];
    intWeaponClipsToAdd = int(Command[1]);


    MyInventory = FindWeaponClassByStringID(strWeapon);

    if (MyInventory == none)
        return;


    Inv = CPWeapon(Pawn.InvManager.FindInventoryType(MyInventory,true));

    if(Inv != none)
    {
        //BuyCheck(int Cost, int MoneyBack)
        if(intWeaponClipsToAdd > 0 && !CPPlayerReplicationInfo(PlayerReplicationInfo).BuyCheck(intWeaponClipsToAdd * MyInventory.default.ClipPrice, 0))
        {
            return;
        }

        Inv.AddClip(intWeaponClipsToAdd);

        if(intWeaponClipsToAdd > 0)
        {
            if(MyInventory.Default.WeaponType != WT_Shotgun)
            {
                //take clip price!!
                CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(-1 * intWeaponClipsToAdd * MyInventory.default.ClipPrice);
				`if(`bPollMarketTransactionEvent)
					if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
						CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Inv, -1 * intWeaponClipsToAdd * MyInventory.Default.ClipPrice, True, intWeaponClipsToAdd);
				`endif
			}
            else
            {
                //take clip price!!
                CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(-1 * (intWeaponClipsToAdd /  class<CPWeaponShotgun>(MyInventory).default.ShotgunBuyAmmoCount ) * MyInventory.default.ClipPrice);
				`if(`bPollMarketTransactionEvent)
					if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
						CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Inv, -1 * (intWeaponClipsToAdd /  class<CPWeaponShotgun>(MyInventory).Default.ShotgunBuyAmmoCount ) * MyInventory.Default.ClipPrice, True, intWeaponClipsToAdd);
				`endif
			}

        }
        else
        {
            if(MyInventory.Default.WeaponType != WT_Shotgun)
            {
                //refund the clip price!!
                CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(Abs(intWeaponClipsToAdd) * MyInventory.default.ClipPrice);
				`if(`bPollMarketTransactionEvent)
					if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
						CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Inv, Abs(intWeaponClipsToAdd) * MyInventory.Default.ClipPrice, True, -intWeaponClipsToAdd);
				`endif
			}
            else
            {
                //refund the clip price!!
                CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(Abs((intWeaponClipsToAdd /  class<CPWeaponShotgun>(MyInventory).default.ShotgunBuyAmmoCount )) * MyInventory.default.ClipPrice);
				`if(`bPollMarketTransactionEvent)
					if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
						CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Inv, Abs((intWeaponClipsToAdd /  class<CPWeaponShotgun>(MyInventory).Default.ShotgunBuyAmmoCount )) * MyInventory.Default.ClipPrice, True, intWeaponClipsToAdd);
				`endif
			}
        }
    }
}


function class<Inventory> FindClassByStringID(string InventoryObject)
{
    local int i;

    for ( i = 0 ; i < ServersKnownInventory.Length ; i++)
    {
        if(ServersKnownInventory[i].InventoryString == InventoryObject)
            return ServersKnownInventory[i].InventoryClass;
    }
    return none;
}

function class<CPWeapon> FindWeaponClassByStringID(string WeaponObject)
{
    local int i;
    local string strWeaponString;

    for ( i = 0 ; i < ServersKnownWeapons.Length ; i++)
    {
        strWeaponString = ServersKnownWeapons[i].WeaponString; //fix for some weird uscript bug where it was trying to find shit in array int=56445
        if(strWeaponString == WeaponObject)
        {
            return ServersKnownWeapons[i].WeaponClass;
        }
    }
    return none;
}

function CreateWeaponInventory(string WeaponObject)
{
    local class<CPWeapon> MyWeaponInventory;
    MyWeaponInventory = FindWeaponClassByStringID(WeaponObject);
    Pawn.CreateInventory(MyWeaponInventory,false);

    //take the money!!
    CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(-1 * MyWeaponInventory.default.WeaponPrice);
	`if(`bPollMarketTransactionEvent)
		if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
			CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Spawn(MyWeaponInventory), -1 * MyWeaponInventory.default.WeaponPrice, False, 1);
	`endif
}

function CreateInventory(string InventoryObject)
{
    local class<Inventory> MyInventory;
    local CPArmor ArmorPiece;

    RemoveArmorFromInventory(InventoryObject);
    MyInventory = FindClassByStringID(InventoryObject);
    Pawn.CreateInventory(MyInventory,false);
    bForceNetUpdate=true;

    //Get The Armor
    ArmorPiece = CPArmor(Pawn.InvManager.FindInventoryType(MyInventory,false));

    //take the money!!
    CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(-1 * ArmorPiece.Cost);
	`if(`bPollMarketTransactionEvent)
		if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
			CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Spawn(MyInventory), -1 * ArmorPiece.Cost, False, 1);
	`endif
}

function RemoveWeapon(string WeaponObject)
{
    local CPWeapon Inv;
    local class<CPWeapon> MyInventory;

    MyInventory = FindWeaponClassByStringID(WeaponObject);

    if (MyInventory == none)
        return;
    Inv = CPWeapon(Pawn.InvManager.FindInventoryType(MyInventory,false));
	
	//Only sell a melee weapon if there is any "ammo"
	if(Inv.IsA('CPMeleeWeapon') && !CPMeleeWeapon(Inv).HasAnyAmmo())
		return;

    if(Inv != none)
    {
        if ( Pawn != None )
        {
            Pawn.InvManager.RemoveFromInventory(Inv);

            //refund weapon cost!!
            CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(MyInventory.default.WeaponPrice);
			`if(`bPollMarketTransactionEvent)
				if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
				CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Spawn(MyInventory), MyInventory.default.WeaponPrice, False, 1);
			`endif
		}
    }
}


function RemoveArmorFromInventory(string InventoryObject)
{
    local CPArmor Inv;
    local class<Inventory> MyInventory;

    MyInventory = FindClassByStringID(InventoryObject);

    Inv = CPArmor(Pawn.InvManager.FindInventoryType(MyInventory,false));

    if(Inv != none)
    {
        if ( Pawn != None )
        {
            Pawn.InvManager.RemoveFromInventory(Inv);

            //refund the money if armor health more 50!!
            if (  Inv.Health > 50 )
			{
                CPPlayerReplicationInfo(PlayerReplicationInfo).ModifyMoney(Inv.Cost);
				`if(`bPollMarketTransactionEvent)
					if(CriticalPointGame(WorldInfo.Game).bEnableGamePlayerPoll)
						CriticalPointGame(WorldInfo.Game).PollMarketTransactionEvent(WorldInfo.TimeSeconds, self, Spawn(MyInventory), Inv.Cost, False, 1);
				`endif
			}
			bForceNetUpdate=true;
        }
    }
}

exec function AdminSwapTeams()
{
	if (PlayerReplicationInfo.bAdmin)
	{
		ExecuteSwapTeams();
	}
}

reliable server function ExecuteSwapTeams()
{
    local string MessageString;
    if ( PlayerReplicationInfo.bAdmin )
    {
		MessageString = PlayerReplicationInfo.PlayerName@"is swapping teams ";

        `log(MessageString);
        WorldInfo.Game.Broadcast( self, MessageString, 'Event' );

        CriticalPointGame(WorldInfo.Game).ExecuteSwapTeams();       
    }
}

exec function AdminReset()
{
	if (PlayerReplicationInfo.bAdmin)
	{
		ResetAndRestartLevel();
	}
}
reliable server function ResetAndRestartLevel()
{
    local string MessageString;
    if ( PlayerReplicationInfo.bAdmin )
    {
		MessageString = PlayerReplicationInfo.PlayerName@"is resetting map ";

        `log(MessageString);
        WorldInfo.Game.Broadcast( self, MessageString, 'Event' );

        CriticalPointGame(WorldInfo.Game).ResetAndRestartLevel();       
    }
}
exec function AdminSetNextMap( string URL )
{
    if (PlayerReplicationInfo.bAdmin)
    {
        SendAllAdminMessage(9);
        ServerSetNextMap(URL);

    }
}

exec function AdminKickBan( string S )
{
    if (PlayerReplicationInfo.bAdmin)
    {
        ServerKickBan(S,true);
    }
}

reliable client function LogAndOutMessage(string Msg)
{
    `Log(Msg);
    LocalPlayer(Player).ViewportClient.ViewportConsole.OutputText(Msg);
}

exec function AdminKick( string S )
{
    if ( PlayerReplicationInfo.bAdmin )
    {
        ServerKickBan(S,false);
    }
}

/** Allows the local player or admin to kick a player */
reliable server function ServerKickBan(string PlayerToKick, bool bBan)
{
    local PlayerController P;
    if (PlayerReplicationInfo.bAdmin)
    {
        P = PlayerController(CPAccessControl(WorldInfo.Game.AccessControl).GetControllerFromString(PlayerToKick));
        if(P != none)
            LogAndOutMessage("[Admin Kick] you kicked " $ P.PlayerReplicationInfo.PlayerName $ " from the server");

        if (bBan)
        {
            CPAccessControl(WorldInfo.Game.AccessControl).KickBan(PlayerToKick);
        }
        else
        {
            CPAccessControl(WorldInfo.Game.AccessControl).Kick(PlayerToKick);
        }
    }
}

reliable server function ServerSetNextMap(string URL)
{
    local string MessageString;
    if ( PlayerReplicationInfo.bAdmin )
    {
        CriticalPointGame(WorldInfo.Game).AdminSetNextMap(URL);
        //`Log("CPPlayerController::ServerSetNextMap SETTING NEXT MAP TO " $ URL);

        MessageString = PlayerReplicationInfo.PlayerName@"has set the next map to " $URL;

        `log(MessageString);
        WorldInfo.Game.Broadcast( self, MessageString, 'Event' );
    }
}

exec function AdminBalanceTeams()
{
    if (PlayerReplicationInfo != none && PlayerReplicationInfo.bAdmin)
    {
        ServerBalanceTeams();
    }
}

reliable server function ServerBalanceTeams()
{
    if ( PlayerReplicationInfo.bAdmin )
    {
        CriticalPointGame(WorldInfo.Game).AdminBalanceTeams();
    }
}

exec function AdminEndRound()
{
    if (PlayerReplicationInfo != none && PlayerReplicationInfo.bAdmin)
    {
        ServerAdminEndRound();
    }
    else if(WorldInfo.NetMode == NM_Standalone)
    {
        CriticalPointGame(WorldInfo.Game).EndRound( none, "ADMINENDROUND" );
    }
}

reliable server function ServerAdminEndRound()
{
    if (PlayerReplicationInfo != none && PlayerReplicationInfo.bAdmin)
    {
        //`Log("CPPlayerController::ServerAdminEndRound ");
        CriticalPointGame(WorldInfo.Game).EndRound( none, "ADMINENDROUND" );
    }
}

exec function AdminForceChangeTeam(controller c, int teamindex)
{
    if (PlayerReplicationInfo != none && PlayerReplicationInfo.bAdmin)
    {
        ServerAdminForceChangeTeam(c,teamindex);
        SendAllAdminMessage(10);
    }
}

reliable server function ServerAdminForceChangeTeam(controller c, int teamindex)
{
    if (PlayerReplicationInfo != none && PlayerReplicationInfo.bAdmin)
    {
        //`Log("CPPlayerController::ServerAdminForceChangeTeam ");
        CPPlayerReplicationInfo(c.PlayerReplicationInfo).bServerForcedRestart = true;
        CriticalPointGame(WorldInfo.Game).ChangeTeam(c,teamindex,false);
        c.Pawn.KilledBy(none);
        CriticalPointGame(WorldInfo.Game).RestartPlayer(c);
    }
}

reliable server function GetAdminPassword() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: Sending a broadcast message which is '"$ CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).GetAdminPassword() $"'.");
            self.ReceiveAdminPassword(CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).GetAdminPassword());
        }
    }
}

reliable server function GetGamePassword() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: Sending a broadcast message which is '"$ CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).GetGamePassword() $"'.");
            self.ReceiveGamePassword(CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).GetGamePassword());
        }
    }
}

reliable server function GetPreRoundTime() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        //if ( PlayerReplicationInfo.bAdmin )
        //{
            //`Log(Self$":: Sending a broadcast message which is '"$ CriticalPointGame(WorldInfo.Game).default.RoundStartDelay $"'.");
            self.ReceivePreRoundTime(string(CriticalPointGame(WorldInfo.Game).RoundStartDelay));
        //}
    }
}

reliable server function GetRoundDuration() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        //if ( PlayerReplicationInfo.bAdmin )
        //{
            //`Log(Self$":: Sending a broadcast message which is '"$ CriticalPointGame(WorldInfo.Game).default.RoundDurationInMinutes $"'.");
            self.ReceiveRoundDuration(string(CriticalPointGame(WorldInfo.Game).RoundDurationInMinutes));
        //}
    }
}

reliable server function GetMapTimeDuration(optional bool blnTeamSelectMenuUpdate) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        //if ( PlayerReplicationInfo.bAdmin )
        //{
            //`Log(Self$":: Sending a broadcast message which is '"$ (CriticalPointGame(WorldInfo.Game).TimeLimit)$"'.");
            self.ReceiveMapTimeDuration(string(CriticalPointGame(WorldInfo.Game).TimeLimit), blnTeamSelectMenuUpdate);
        //}
    }
}

reliable server function GetMaxPlayerCount() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        //if ( PlayerReplicationInfo.bAdmin )
        //{
            //`Log(Self$":: Sending a broadcast message which is '"$ (CriticalPointGame(WorldInfo.Game).MaxPlayers)$"'.");
            self.ReceiveMaxPlayerCount(string(CriticalPointGame(WorldInfo.Game).MaxPlayers));
        //}
    }
}

reliable server function GetServerName() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        //if ( PlayerReplicationInfo.bAdmin )
        //{
            //`Log(Self$":: Sending a broadcast message which is '"$ (CriticalPointGame(WorldInfo.Game).GameReplicationInfo.ServerName)$"'.");
            self.ReceiveServerName(CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).ServerName);
        //}
    }
}

reliable server function GetGhostCamSetting() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        //if ( PlayerReplicationInfo.bAdmin )
        //{
            //`Log(Self$":: Sending a broadcast message which is bAllowGhostCam'"$ String(CriticalPointGame(WorldInfo.Game).bAllowGhostCam)$"'.");
            self.ReceiveGhostCamSetting(String(CriticalPointGame(WorldInfo.Game).bAllowGhostCam));
        //}
    }
}

reliable server function GetMOTD() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        //if ( PlayerReplicationInfo.bAdmin )
        //{
            //`Log(Self$":: Sending a broadcast message which is '"$ CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).MessageOfTheDay$"'.");
            self.ReceiveMOTD(CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).MessageOfTheDay);
        //}
    }
}

exec function SetBuyTime(int Value)
{
    SetPreRoundTime(Value);
}

reliable server function SetPreRoundTime(int Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: SETTING CriticalPointGame(WorldInfo.Game).default.RoundStartDelay which is '"$ CriticalPointGame(WorldInfo.Game).default.RoundStartDelay $"' to" @ Value);
            // Rogue. Restrict Buytime to between 15 and 6 seconds.
            if(Value > 15)
                Value = 15;
            if(Value < 6)
                Value = 6;
            CriticalPointGame(WorldInfo.Game).RoundStartDelay = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            MessageString = PlayerReplicationInfo.PlayerName@"has changed the pre-round time to " $Value;

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}
exec function SetRoundTime(int Value)
{
    SetRoundDuration(Value);
}

exec function SetNadeFFPercent(int Value)
{
    SetNadeFFPercentage(Value);
}
exec function SetFFPercentage(int Value)
{
    SetFFPercent(Value);
}
exec function SetEnableFF(bool Value)
{
    EnableFF(Value);
}
exec function SetEnableNadeFF(bool Value)
{
    EnableNadeFF(Value);
}

exec function SetMaxTeamKills(int value)
{
    SetTeamKills(value);
}

reliable server function SetNadeFFPercentage(int Value)
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            if(Value > 100)
                Value = 100;
            if(Value < 0)
                Value = 0;

            CriticalPointGame(WorldInfo.Game).NadeFriendlyFirePercentage = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            MessageString = PlayerReplicationInfo.PlayerName@"has changed bomb FF Percentage to " $Value;

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}

reliable server function SetFFPercent(int Value)
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            if(Value > 100)
                Value = 100;
            if(Value < 0)
                Value = 0;

            CriticalPointGame(WorldInfo.Game).FriendlyFirePercentage = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            MessageString = PlayerReplicationInfo.PlayerName@"has changed FF Percentage to " $Value;

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}

reliable server function EnableFF(bool Value)
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            CriticalPointGame(WorldInfo.Game).bFFenabled = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            if(Value == true)
            {
                MessageString = PlayerReplicationInfo.PlayerName@"has enabled FF";
            }
            else
            {
                MessageString = PlayerReplicationInfo.PlayerName@"has disabled FF";
            }

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}

reliable server function EnableNadeFF(bool Value)
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            CriticalPointGame(WorldInfo.Game).bNadeFFenabled = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            if(Value == true)
            {
                MessageString = PlayerReplicationInfo.PlayerName@"has enabled Bomb FF";
            }
            else
            {
                MessageString = PlayerReplicationInfo.PlayerName@"has disabled Bomb FF";
            }

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}

reliable server function SetTeamKills(int value)
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            if(value > 10)
            {
                value = 10;
            }
            else if (value < 0)
            {
                value = 0;
            }
            CriticalPointGame(WorldInfo.Game).MaxTeamKills = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();
            MessageString = "Admin has set Max Team kills to " @ value;
            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}
reliable server function SetRoundDuration(int Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: SETTING CriticalPointGame(WorldInfo.Game).RoundDurationInMinutes which is '"$ CriticalPointGame(WorldInfo.Game).default.RoundDurationInMinutes $"' to" @ Value);
            // Rogue.Restrict round duration between 10 and 3 minutes.
            if(Value > 10)
                Value = 10;
            if(Value < 3)
                Value = 3;

            CriticalPointGame(WorldInfo.Game).RoundDurationInMinutes = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            MessageString = PlayerReplicationInfo.PlayerName@"has changed the round duration to " $Value;

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}

reliable server function SetMaxPlayers(int Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: SETTING CriticalPointGame(WorldInfo.Game).MaxPlayers which is '"$ CriticalPointGame(WorldInfo.Game).default.MaxPlayers $"' to" @ Value);
            CriticalPointGame(WorldInfo.Game).MaxPlayers = value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            MessageString = PlayerReplicationInfo.PlayerName@"has changed the maximum player count to " $Value;

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }
}

exec function SetMapTime(int Value)
{
    SetMapTimeDuration(Value);
}

reliable server function SetMapTimeDuration(int Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    local string MessageString;
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            // Rogue. Restrict Map Duration between 60 and 15 minutes
            if(Value > 60)
                Value = 60;
            if(Value < 15)
                Value = 15;

            // Rogue. Map time to be restricted to 5 minute increments.
            if((Value % 5) != 0)
            {
                Value = Value/5;
                Value = Value*5;
            }
            //`Log(Self$":: SETTING CriticalPointGame(WorldInfo.Game).TimeLimit which is '"$ CriticalPointGame(WorldInfo.Game).TimeLimit $"' to" @ Value);
            CriticalPointGame(WorldInfo.Game).TimeLimit = Value;
            CriticalPointGame(WorldInfo.Game).SaveConfig();

            MessageString = PlayerReplicationInfo.PlayerName@"has changed the map time to " $Value;

            `log(MessageString);
            WorldInfo.Game.Broadcast( self, MessageString, 'SettingsEvent' );
        }
    }


}

reliable client function ReceiveGhostCamSetting(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetGhostCamValue(bool(ReceivedText));
        }
  }
  */
}

reliable client function ReceiveRoundDuration(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetRoundDurationValue(float(ReceivedText));
        }
  }
  */
}

reliable client function ReceiveMapTimeDuration(String ReceivedText, optional bool blnTeamSelectMenuUpdate)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
    if(blnTeamSelectMenuUpdate)
    {
          if ( CPHUD(myHUD) != None )
          {
                if(CPHUD(myHUD).TeamSelectionMC  != none)
                {
                    CPHUD(myHUD).TeamSelectionMC.SetMapTimeDurationValue(float(ReceivedText));
                }
          }
    }
    else
    {
          if ( CPHUD(myHUD) != None )
          {
                if(CPHUD(myHUD).AdminMenuMC != none)
                {
                    CPHUD(myHUD).AdminMenuMC.SetMapTimeDurationValue(float(ReceivedText));
                }
          }
    }
    */
}

reliable client function ReceiveMaxPlayerCount(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetMaxPlayerValue(float(ReceivedText));
        }
  }
  */
}

reliable client function ReceiveServerName(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetServerNameValue(ReceivedText);
        }
  }
  */
}

reliable client function ReceiveMOTD(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetMOTDValue(ReceivedText);
        }
  }
  */
}

reliable client function ReceivePreRoundTime(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetPreRoundValue(float(ReceivedText));
        }
  }
  */
}

reliable client function ReceiveAdminPassword(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetAdminPasswordValue(ReceivedText);
        }
  }
  */
}

reliable client function ReceiveGamePassword(String ReceivedText)
{
  //`Log(Self$":: Server sent me '"$ReceivedText$"'.");
  /*
  if ( CPHUD(myHUD) != None )
  {
        if(CPHUD(myHUD).AdminMenuMC != none)
        {
            CPHUD(myHUD).AdminMenuMC.SetGamePasswordValue(ReceivedText);
        }
  }
  */
}

reliable server function SetAdminPassword(string Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: SETTING CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).strAdminPassword which is '"$ CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).GetAdminPassword() $"' to" @ Value);
            CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).SetAdminPassword(value);
            CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).SaveConfig();
        }
    }
}

reliable server function SetGamePassword(string Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: SETTING CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).strGamePassword which is '"$ CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).GetGamePassword() $"' to" @ Value);
            CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).SetGamePassword(value);
            CPAccessControl(CriticalPointGame(WorldInfo.Game).AccessControl).SaveConfig();
        }
    }
}

reliable server function SetServerName(string Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: SETTING CriticalPointGame(WorldInfo.Game).GameReplicationInfo.ServerName which is '"$ CriticalPointGame(WorldInfo.Game).GameReplicationInfo.ServerName $"' to" @ Value);
            CriticalPointGame(WorldInfo.Game).GameReplicationInfo.ServerName = value;
            CriticalPointGame(WorldInfo.Game).GameReplicationInfo.SaveConfig();
        }
    }
}

reliable server function SetMOTD(string Value) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: SETTING CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).MessageOfTheDay which is '"$ CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).MessageOfTheDay $"' to" @ Value);
            CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).MessageOfTheDay = value;
            CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).SaveConfig();
        }
    }
}

exec function ToggleGhostCam()
{
    ToggleGhostCamOption();
}

reliable server function ToggleGhostCamOption() //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            //`Log(Self$":: CriticalPointGame(WorldInfo.Game).bAllowGhostCam which is '"$ CriticalPointGame(WorldInfo.Game).bAllowGhostCam $"' to" @ !CriticalPointGame(WorldInfo.Game).bAllowGhostCam);
            CriticalPointGame(WorldInfo.Game).bAllowGhostCam = !CriticalPointGame(WorldInfo.Game).bAllowGhostCam;
            CriticalPointGame(WorldInfo.Game).SaveConfig();
            GetGhostCamSetting(); // used to update the UI
        }
    }
}

exec function TakeScreenshot()
{
    ConsoleCommand("screenshot");

    //TODO make it play a camera sound when taking screenshots.
    //PlaySound(SoundCue'A_Gameplay.A_Gameplay_PlayerSpawn01Cue', TRUE, TRUE, FALSE, Location, TRUE );
}

exec function ToggleScreenShotMode()
{
    if ( CPHUD(myHUD) == none)
        return;


    if ( CPHUD(myHUD).bCrosshairShow )
    {
        CPHUD(myHUD).bCrosshairShow = false;
        SetHand(HAND_Hidden);
        myHUD.bShowHUD = false;
		CPHUD(myHUD).RemoveMovies();

        if ( CPPawn(Pawn) != None )
            CPPawn(Pawn).TeamBeaconMaxDist = 0;
    }
    else
    {
		CPHUD(myHUD).CreateHUDMovie();
        // return to normal
        CPHUD(myHUD).bCrosshairShow = true;
        SetHand(HAND_Right);
        myHUD.bShowHUD = true;
        if ( CPPawn(Pawn) != None )
        {
            CPPawn(Pawn).TeamBeaconMaxDist = CPPawn(Pawn).default.TeamBeaconMaxDist;
            CPPawn(Pawn).ShowArms();
        }
    }
}

function SetHand(EWeaponHand NewWeaponHand)
{
    WeaponHandPreference = NewWeaponHand;
    WeaponHand = WeaponHandPreference;
    SaveConfig();

    ServerSetHand(NewWeaponHand);
}

reliable server function ServerSetHand(EWeaponHand NewWeaponHand)
{
    WeaponHand = NewWeaponHand;
}

reliable server function WelcomeScreenGetServerInfo()
{
    if (WorldInfo != None && WorldInfo.Game != None && CriticalPointGame(WorldInfo.Game).SrvGeoLocation != none)
    {
        self.WelcomeScreenReceiveServerInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo.ServerName,
                                            CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).AdminEmail,
                                            CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).AdminName,
                                            CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).MessageOfTheDay,
                                            CriticalPointGame(WorldInfo.Game).SrvGeoLocation.Country $ "," $ CriticalPointGame(WorldInfo.Game).SrvGeoLocation.City $ " " $ CriticalPointGame(WorldInfo.Game).SrvGeoLocation.Region,
                                            string(CriticalPointGame(WorldInfo.Game).RoundDurationInMinutes),
                                            string(CriticalPointGame(WorldInfo.Game).TimeLimit),
                                            string(CriticalPointGame(WorldInfo.Game).RoundStartDelay),
                                            string(CriticalPointGame(WorldInfo.Game).NumBots),
                                            string(CriticalPointGame(WorldInfo.Game).FriendlyFirePercentage),
                                            string(CriticalPointGame(WorldInfo.Game).bFFenabled),
                                            string(CriticalPointGame(WorldInfo.Game).bNadeFFenabled),
                                            string(CriticalPointGame(WorldInfo.Game).bForceTeams),
                                            string(CriticalPointGame(WorldInfo.Game).bAllowBehindView),
                                            string(CriticalPointGame(WorldInfo.Game).Spectating),
                                            string(CriticalPointGame(WorldInfo.Game).RequiresPassword()));
    }
}

reliable client function WelcomeScreenReceiveServerInfo(string ServerName, string AdminEmail, string AdminName, string MOTD, string ServerLocation, string RoundDurationInMinutes, string TimeLimit, string RoundStartDelay, string NumberOfBots, string FFPercentage, string FFEnabled, string GrenadeFF, string ForcedTeams, string BehindViewEnabled, string SpectatorMode, string PasswordedServer)
{
      if ( CPHUD(myHUD) != None )
      {
            if(CPHUD(myHUD).CPI_FrontEnd != none)
            {
                if(CPHUD(myHUD).CPI_FrontEnd.WelcomeMenu != none)
                {
                    CPHUD(myHUD).CPI_FrontEnd.WelcomeMenu.PopulateWelcomeScreenServerInfo(ServerName, AdminEmail, AdminName, MOTD, ServerLocation, RoundDurationInMinutes, TimeLimit, RoundStartDelay, NumberOfBots, FFPercentage, FFEnabled, GrenadeFF,ForcedTeams,BehindViewEnabled, SpectatorMode,PasswordedServer);
                }
            }
      }
}

reliable server function ServerAdminLogOut()
{
    if ( WorldInfo != none && WorldInfo.Game != none && WorldInfo.Game.AccessControl != none )
    {
        if ( CPAccessControl(WorldInfo.Game.AccessControl).AdminLogOut(self) )
        {
            WorldInfo.Game.AccessControl.AdminExited(Self);
        }
    }
}

reliable server function SendAllAdminMessage(int intMessageNumber) //reliable server  is required to get WorldInfo.Game - but you do NOT need it to send to clients otherwise
{
    local PlayerController P;

    if (WorldInfo != None && WorldInfo.Game != None)
    {
        if ( PlayerReplicationInfo.bAdmin )
        {
            foreach WorldInfo.AllControllers(class'PlayerController', P)
            {
                P.ReceiveLocalizedMessage( class'CPMsg_HUDMessageTopCenter', intMessageNumber,,,);
            }
        }
    }
}

function bool AdminCmdOk()
{
    //If we are the server then commands are ok
    if (WorldInfo.NetMode == NM_ListenServer && LocalPlayer(Player) != None)
    {
        return true;
    }

    if (WorldInfo.TimeSeconds < NextAdminCmdTime)
    {
        return false;
    }

    NextAdminCmdTime = WorldInfo.TimeSeconds + 5.0;
    return true;
}

reliable server function ServerAdminLogin(string Password)
{
    if ( (WorldInfo.Game.AccessControl != none) && AdminCmdOk() )
    {
        if ( WorldInfo.Game.AccessControl.AdminLogin(self, Password) )
        {
            WorldInfo.Game.AccessControl.AdminEntered(Self);
        }
    }
}

exec function AdminLogin(string Password)
{
    if (Password != "")// && AdminCmdOk() )
    {
        ServerAdminLogin(Password);
    }
}

exec function VoteKick(string Target)
{
    if (Target != "")
    {
        ServerVoteKick(Target);
    }
}

/** Allows a player to be voted out */
reliable server function ServerVoteKick(string PlayerToKick)
{
    CPAccessControl(WorldInfo.Game.AccessControl).VoteKick(PlayerToKick);
}

exec function AdminLogOut()
{
    //if ( AdminCmdOk() )
    //{
        ServerAdminLogOut();
    //}

    self.PlayerReplicationInfo.bAdmin = false; //make sure we always logout not just if the huds availible.

    //close the admin menu if its open.
      if ( CPHUD(myHUD) != None )
      {
            `Log("Close Admin Menu");
            CPHUD(myHUD).SetVisible(true);
      }

}

exec function AdminChangeMap( string URL )
{
    if (PlayerReplicationInfo.bAdmin)
    {
        ServerChangeMap(URL);
        AdminLogOut();
    }
}

reliable server function ServerChangeMap(string URL)
{
    local Pawn P;
    if ( PlayerReplicationInfo.bAdmin )
    {
        if (WorldInfo != None && WorldInfo.Game != None)
        {
            WorldInfo.ServerTravel(URL);

            CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).bStopCountDown = true;
            foreach WorldInfo.AllPawns(class'Pawn', P)
            {
                P.Destroy(); //stops pawns from speedrunning when a map is changed.
            }
        }

        SendAllAdminMessage(8);
        AdminLogOut(); // Making sure the server logs us out
    }
}

exec function AdminRestartMap()
{
    if (PlayerReplicationInfo.bAdmin)
    {
        ServerRestartMap();
        SendAllAdminMessage(7);
        AdminLogOut();
    }
}

reliable server function ServerRestartMap()
{
	local Pawn P;
    if ( PlayerReplicationInfo.bAdmin )
    {
		if(WorldInfo != None && WorldInfo.Game != None)
		{
			CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).bStopCountDown = true;
			CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).bCanPlayersMove = false;
			foreach WorldInfo.AllPawns(class'Pawn', P)
			{
				P.Destroy(); //stops pawns from speedrunning when a map is changed.
			}
		}

		if(WorldInfo != None)
		{
			WorldInfo.ServerTravel("?restart", false);
		}		
	}
}

reliable client function ClientReset()
{
    local CPPawn tp;
    local FracturedStaticMeshPart meshPart;

    foreach AllActors(class'CPPawn',tp)
    {
        if (!tp.bDeleteMe && (tp.Health<=0 || tp.IsInState('Dying') || tp.bTearOff))
        {
            //@Wail - 11/09/13 - This should be destroying and ragdolls that are left behind on round changes for dedicated server clients.
            //                   If this issue persists we might have to investigate further.
            tp.TurnOffPawn();
            tp.Destroy();

            //`log("ClientReset: Destroying Dead CPPawn.");
        }
    }

    // Cleans up any fracture pieces still remaining
    foreach WorldInfo.AllActors(class'FracturedStaticMeshPart', meshPart)
    {
        meshPart.RecyclePart(true);
    }

	/*
	if (PlayerReplicationInfo != None && PlayerReplicationInfo.bOnlySpectator)
    {
        return;
    }

    if ( PlayerCamera != None )
    {
        PlayerCamera.Destroy();
    }
	*/
	
    super.ClientReset();
}

exec function ToggleConsole()
{
    `log("Toggle the console!");
}

simulated function ChangeClanTag()
{
local CPSaveManager TASave;

    TASave=new(none,"") class'CPSaveManager';
    ServerSetClanTag(TASave.GetItem("ClanTag"));
}



reliable server function ServerSetClanTag(string Value)
{
    //`log("ServerSetClanTag::"@Value);
	if(self.PlayerReplicationInfo != none)
		CPPlayerReplicationInfo(self.PlayerReplicationInfo).ClanTag = Value;
}

reliable server function ServerSetBOnlySpectator(bool Value)
{
    CPPlayerReplicationInfo(self.PlayerReplicationInfo).bOnlySpectator = Value;
}

exec function SetClanTag(optional string Value)
{
local CPSaveManager TASave;


    if(len(Value) > 6)
    {
        Value = Left(Value,6);
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "CLANTAG TOO LONG! TRUNCATING TO 6 CHARS!! its now " $ Value );
        `Log("CLANTAG TOO LONG! TRUNCATING TO 6 CHARS!! its now " $ Value);
    }

    TASave=new(none,"") class'CPSaveManager';
    TASave.SetItem("ClanTag",Value);
    ChangeClanTag();
    CPPlayerReplicationInfo(self.PlayerReplicationInfo).ClanTag=Value;
}

reliable server function ServerSuicide()
{
    if ( (Pawn != None) && ((WorldInfo.TimeSeconds - Pawn.LastStartTime > 10) || (WorldInfo.NetMode == NM_Standalone)) )
    {
        // Rogue- Do not allow suiciding if round is over and if players are not allowed to move yet.
        if(!CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).bRoundIsOver &&
            CPGameReplicationInfo(CriticalPointGame(WorldInfo.Game).GameReplicationInfo).bCanPlayersMove)
        {
            Pawn.Suicide();
        }
    }
}

/* Copy server IP */
exec function CopyServerAddress()
{
local string tmpWorldInfoAddr;
local string tmpLocalPort;
local int tmpPos;
local TcpLink tmpTcp;
local IpAddr localIP;

    if (bIsInMenuGame)
        return;
    if (WorldInfo.NetMode==NM_Client)
        tmpWorldInfoAddr=WorldInfo.GetAddressURL();
    else if (WorldInfo.NetMode==NM_ListenServer)
    {
        tmpTcp=Spawn(class'TcpLink');                   // NOTE : only the local address is available in listen mode,
        if (tmpTcp!=none)                               //        all other functions return nothing useful
        {
            tmpTcp.GetLocalIP(localIP);
            tmpWorldInfoAddr=tmpTcp.IpAddrToString(localIP);
            tmpTcp.Destroy();
            tmpTcp=none;
            if (tmpWorldInfoAddr!="")
            {
                tmpLocalPort=WorldInfo.GetAddressURL();
                if (tmpLocalPort!="")
                {
                    tmpPos=InStr(tmpWorldInfoAddr,":",false,true);
                    if (tmpPos>0)
                        tmpWorldInfoAddr=Left(tmpWorldInfoAddr,tmpPos);
                    tmpWorldInfoAddr=tmpWorldInfoAddr$tmpLocalPort;
                }
            }
        }
    }
    else
        tmpWorldInfoAddr=WorldInfo.GetMapName(true);
    if (tmpWorldInfoAddr=="")
    {
        `log("Unable to copy server's URL, for CopyServerAddress()");
        return;
    }
    CopyToClipboard(tmpWorldInfoAddr);
    if (WorldInfo.NetMode==NM_Client)
        ClientMessage("Copied server's address ["$tmpWorldInfoAddr$"] to the clipboard");
    else if (WorldInfo.NetMode==NM_ListenServer)
        ClientMessage("Copied your server's address ["$tmpWorldInfoAddr$"] to the clipboard");
    else if (WorldInfo.NetMode==NM_Standalone)
        ClientMessage("Copied the map's name you're playing on ["$tmpWorldInfoAddr$"] to the clipboard");
}

/* Weapon Crosshair */
exec function ChangeWeaponCrosshair(int newPrdfChrIdx)
{
    PredefinedCrosshairIdx=newPrdfChrIdx;
    CheckCrosshairSettings();
    SaveConfig();
    SaveCrosshairSettings();
}

exec function ChangeWeaponCrosshairScale(float newScale)
{
    PredefinedCrosshairScale=newScale;
    CheckCrosshairSettings();
    SaveConfig();
    SaveCrosshairSettings();
}

exec function ChangeWeaponCrosshairColor(byte R,byte G,byte B,byte A)
{
    PredefinedCrosshairColor.R=R;
    PredefinedCrosshairColor.G=G;
    PredefinedCrosshairColor.B=B;
    PredefinedCrosshairColor.A=A;
    SaveConfig();
    SaveCrosshairSettings();
}

// Called by GameInfo when we damaged an enemy.
reliable client function NotifyEnemyHit()
{
    if (CPHUD(myHUD) != none)
    {
        CPHUD(myHUD).LastHitIndicatorTime = WorldInfo.TimeSeconds;
    }
}

simulated function GetCrosshairSettingsFromConfig()
{
    local CPSaveManager TASave;

    TASave=new(none,"") class'CPSaveManager';
    PredefinedCrosshairIdx = float(TASave.GetItem("PreferredCrosshair"));
    PredefinedCrosshairScale = float(TASave.GetItem("CrosshairSize"));
    PredefinedCrosshairColor.R = int(TASave.GetItem("CrosshairRed"));
    PredefinedCrosshairColor.G = int(TASave.GetItem("CrosshairGreen"));
    PredefinedCrosshairColor.B = int(TASave.GetItem("CrosshairBlue"));
    PredefinedCrosshairColor.A = int(TASave.GetItem("CrosshairAlpha"));
}

simulated function SaveCrosshairSettings()
{
    local CPSaveManager TASave;

    TASave=new(none,"") class'CPSaveManager';
    TASave.SetItem("PreferredCrosshair",PredefinedCrosshairIdx);
    TASave.SetItem("CrosshairSize",PredefinedCrosshairScale);
    TASave.SetItem("CrosshairRed",PredefinedCrosshairColor.R);
    TASave.SetItem("CrosshairGreen",PredefinedCrosshairColor.G);
    TASave.SetItem("CrosshairBlue",PredefinedCrosshairColor.B);
    TASave.SetItem("CrosshairAlpha",PredefinedCrosshairColor.A);
}

simulated function CheckCrosshairSettings()
{
    if (PredefinedCrosshairIdx<-1)
        PredefinedCrosshairIdx=-1;
    else if (PredefinedCrosshairIdx>(PredefinedCrosshairs.Length-1))
        PredefinedCrosshairIdx=PredefinedCrosshairs.Length-1;

    if (PredefinedCrosshairScale<0.01)
        PredefinedCrosshairScale=0.01;
    else if (PredefinedCrosshairScale>5.0)
        PredefinedCrosshairScale=5.0;

    /*if (PredefinedCrosshairs[PredefinedCrosshairIdx].Image==none)
    {
        PredefinedCrosshairs[PredefinedCrosshairIdx].Image=Texture2D'TA_Crosshairs.Basic.TA_Crosshairs_01';
        PredefinedCrosshairs[PredefinedCrosshairIdx].ImageTexCoords.U=64;
        PredefinedCrosshairs[PredefinedCrosshairIdx].ImageTexCoords.V=0;
        PredefinedCrosshairs[PredefinedCrosshairIdx].ImageTexCoords.UL=64;
        PredefinedCrosshairs[PredefinedCrosshairIdx].ImageTexCoords.VL=64;
    }*/
}

simulated function GetCrosshairSettings(out Texture2D crosshairTex,out UIRoot.TextureCoordinates texCoords)
{
    CheckCrosshairSettings();
    crosshairTex=PredefinedCrosshairs[PredefinedCrosshairIdx].Image;
    texCoords=PredefinedCrosshairs[PredefinedCrosshairIdx].ImageTexCoords;
}

/* Pending login */
reliable client function ClientPendingLoginNotify()
{
    ServerSlientSetName((PlayerName!="") ? PlayerName : GetDefaultURL("name"));
}

reliable client function PendingLoginCompleted()
{
    local CPSaveManager TASave;
    TASave=new class'CPSaveManager';
    SetWeaponAutoReload(TASave.GetBool("AutoReloadWeapon"));
}

function PendingLoginTimedout()
{
    if (WorldInfo.Game.IsA('CriticalPointGame') && !bIsInMenuGame)
        CriticalPointGame(WorldInfo.Game).PendingLoginCompletedFor(self);
}

/* Name handling */
reliable server function ServerSlientSetName(string newName)
{
    if (PlayerReplicationInfo==none || newName=="" || !PlayerReplicationInfo.IsA('CPPlayerReplicationInfo'))
        return;
    PlayerReplicationInfo.PlayerName=newName;
    CPPlayerReplicationInfo(PlayerReplicationInfo).bRecievedPlayerName=true;
    CPPlayerReplicationInfo(PlayerReplicationInfo).CheckPendingLoginStatus();
    PlayerReplicationInfo.bForceNetUpdate=true;
}


/*
*/
exec function SetName(coerce string S)
{
    local LocalPlayer LocPlayer;

    Super.SetName(S);

    if(S != "")
    {
        LocPlayer = LocalPlayer(Player);
        if (OnlineSub == None)
        {
            // Limit the player name to 15 characters
            if(len(S) > 15)
            {
                S = Left(S,15);
                LocPlayer.ViewportClient.ViewportConsole.OutputText( "PLAYER NAME TOO LONG! TRUNCATING TO 15 CHARS!! its now " $ S );
            }
        }
        else
        {
            if (LocPlayer != None && OnlineSub.GameInterface != None && OnlineSub.PlayerInterface != None)
            {
                // Limit the player name to 15 characters
                if(len(S) > 15)
                {
                    S = Left(S,15);
                    LocPlayer.ViewportClient.ViewportConsole.OutputText( "PLAYER NAME TOO LONG! TRUNCATING TO 15 CHARS!! its now " $ S );
                }

                ServerChangeName(S);
            }
        }
    }

    UpdateURL("Name", S, true);
    PlayerName = S;
    SaveConfig();

}

/* Client ( hacked play ) sound handling */
unreliable client function ClientPlaySoundFor(Actor sourceActor,Vector sourceLocation,SoundCue SoundToPlay,float playVolume)
{
local AudioComponent AC;

    if (SoundToPlay==none)
    {
        `log("unable to play sound requested by the server because the sound cue is missing!");
        return;
    }
    if (sourceActor==none)
    {
        AC=GetPooledAudioComponent(SoundToPlay,sourceActor,false,true,sourceLocation);
        if (AC==none)
            return;
        AC.bUseOwnerLocation=false;
        AC.Location=sourceLocation;
    }
    else
    {
        AC=GetPooledAudioComponent(SoundToPlay,sourceActor,true);
        if (AC==none)
            return;
    }
    AC.AdjustVolume(0.0,playVolume);
    AC.Play();
}

simulated function LocallyPlaySoundWithReverbVolumeHackFor(Actor sourceActor,SoundCue SoundToPlay)
{
    if (sourceActor==none || SoundToPlay==none)
        return;
    if (reverbHackHelper==none)
    {
        `warn("Local Reverb volume hack function called but no helper object exists");
        return;
    }
    reverbHackHelper.LocallyPlaySoundWithReverbVolumeHack(self,sourceActor,SoundToPlay);
}

simulated function SetSelectedCharacter(class<CPFamilyInfo> NewCharacter)
{
    SelectedCharacter = NewCharacter;
}

unreliable client event ClientHearSound(SoundCue ASound,Actor SourceActor,vector SourceLocation,bool bStopWhenOwnerDestroyed,optional bool bIsOccluded)
{
local int soundIndex;
local bool bPlaySound;

    bPlaySound=true;
    if (bDEVOscRouting && !bDEVOscIndexing)
    {
        if (DEVOscIsIndexedSound(ASound,soundIndex))
        {
            DEVOscSendMessageInt("SoundIndex",soundIndex);
            DEVOscSendMessageFloat("SoundVolumeMultiplier",ASound.VolumeMultiplier);
            DEVOscSendMessageFloat("SoundPitchMultiplier",ASound.PitchMultiplier);
            DEVOscSendMessageBool("SoundOutput",true);
            DEVOscSendMessageBool("SoundOutput",false);
            bPlaySound=false;
        }
    }
    if (bDEVOscIndexing && taExtUtils!=none)
        DEVOscIndexSoundName(string(ASound));
    if (bPlaySound)
        super.ClientHearSound(ASound,SourceActor,SourceLocation,bStopWhenOwnerDestroyed,bIsOccluded);
}

/*
dev exec funcs
*/
exec function DEVSetWeaponMf(string tmplName,optional string slotType)
{
local ParticleSystem newPsc;

    if (tmplName=="")
    {
        `Log("unable to set weapon muzzle flash, new emitter name is not specified");
        return;
    }
    if (Pawn==none)
    {
        `Log("unable to set weapon muzzle flash, no pawn");
        return;
    }
    if (CPWeapon(Pawn.Weapon)==none)
    {
        `Log("unable to set weapon muzzle flash, no suitable weapon for pawn");
        return;
    }
    newPsc=ParticleSystem(DynamicLoadObject(tmplName,class'ParticleSystem'));
    if (newPsc==none)
    {
        `warn("failed to load new muzzle flash emitter ("$tmplName$") for weapon");
        return;
    }
    if (slotType~="alt")
        CPWeapon(Pawn.Weapon).MuzzleFlashAltPSCTemplate=newPsc;
    else
        CPWeapon(Pawn.Weapon).MuzzleFlashPSCTemplate=newPsc;
}

exec function DEVSetWeaponMfColor(byte r,byte g,byte b,optional byte a)
{
local Color clr;

    if (Pawn==none)
    {
        `Log("unable to set weapon muzzle flash color, no pawn");
        return;
    }
    if (CPWeapon(Pawn.Weapon)==none)
    {
        `Log("unable to set weapon muzzle flash color, no suitable weapon for pawn");
        return;
    }
    clr.R=r;
    clr.G=g;
    clr.B=b;
    if (a!=0)
        clr.A=a;
    else
        clr.A=255;
    CPWeapon(Pawn.Weapon).MuzzleFlashColor=clr;
}

exec function DEVSetWeaponMfScale(float newScale)
{
    if (Pawn==none)
    {
        `Log("unable to set weapon muzzle flash scale, no pawn");
        return;
    }
    if (CPWeapon(Pawn.Weapon)==none)
    {
        `Log("unable to set weapon muzzle flash scale, no suitable weapon for pawn");
        return;
    }
    CPWeapon(Pawn.Weapon).MuzzleFlashScale=newScale;
}

exec function DEVSetWeaponMfLoop(bool bLoop)
{
    if (Pawn==none)
    {
        `Log("unable to set weapon muzzle flash loop, no pawn");
        return;
    }
    if (CPWeapon(Pawn.Weapon)==none)
    {
        `Log("unable to set weapon muzzle flash loop, no suitable weapon for pawn");
        return;
    }
    CPWeapon(Pawn.Weapon).bMuzzleFlashPSCLoops=bLoop;
}

exec function DEVSetWeaponMfDuration(float newDuration)
{
    if (Pawn==none)
    {
        `Log("unable to set weapon muzzle flash loop, no pawn");
        return;
    }
    if (CPWeapon(Pawn.Weapon)==none)
    {
        `Log("unable to set weapon muzzle flash loop, no suitable weapon for pawn");
        return;
    }
    CPWeapon(Pawn.Weapon).MuzzleFlashDuration=newDuration;
}


// ~WillyG: Grenade DEV Functions
exec function DEVSetGrenadeVelocityMultiplier(float newMultiplier)
{
    if(Pawn == none)
    {
        `log("Unable to set grenade velocity multiplier, no pawn");
        return;
    }
    if(CPWeap_Grenade(Pawn.Weapon) == none)
    {
        `log("Unable to set grenade velocity multiplier, weapon is not a grenade");
        return;
    }
    CPWeap_Grenade(Pawn.Weapon).GrenadeVelocityMultiplier=newMultiplier;
}

exec function DEVSetGrenadePitchOffset(float newPitch)
{
    if(Pawn == none)
    {
        `log("Unable to set grenade pitch offset, no pawn");
        return;
    }
    if(CPWeap_Grenade(Pawn.Weapon) == none)
    {
        `log("Unable to set grenade pitch offset, weapon is not a grenade");
        return;
    }
    CPWeap_Grenade(Pawn.Weapon).GrenadePitchOffset=newPitch;
}


exec function DEVWeaponTestMode()
{
    bDEVWeaponTestMode=!bDEVWeaponTestMode;
}

exec function DEVGiveArmor ()
{
    ServerGiveArmor();
}

reliable server function ServerGiveArmor ()
{
   local CPArmor_Body BodyArmor;
   local CPArmor_Head HeadArmor;
   local CPArmor_Leg LegArmor;
   local CPInventoryManager InvManager;

   if (CPPawn(Pawn) == None && CPInventoryManager(CPPawn(Pawn).InvManager) == None)
   {
      return;
   }

   if (PlayerReplicationInfo.bAdmin || WorldInfo.NetMode == NM_Standalone)
    {
        InvManager = CPInventoryManager(CPPawn(Pawn).InvManager);

      BodyArmor = CPArmor_Body(InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Body', false ));
      if (BodyArmor == None)
      {
         BodyArmor = Spawn(class'CPArmor_Body', self, , Pawn.Location, Pawn.Rotation);
         BodyArmor.GiveTo(Pawn);
         BodyArmor.GivenTo(Pawn);
      }
      BodyArmor.Health = BodyArmor.MaxHealth;

      HeadArmor = CPArmor_Head(InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Head', false ));
      if (HeadArmor == None)
      {
         HeadArmor = Spawn(class'CPArmor_Head', self, , Pawn.Location, Pawn.Rotation);
         HeadArmor.GiveTo(Pawn);
         HeadArmor.GivenTo(Pawn);
      }
      HeadArmor.Health = HeadArmor.MaxHealth;

      LegArmor = CPArmor_Leg(InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Leg', false ));
      if (LegArmor == None)
      {
         LegArmor = Spawn(class'CPArmor_Leg', self, , Pawn.Location, Pawn.Rotation);
         LegArmor.GiveTo(Pawn);
         LegArmor.GivenTo(Pawn);
      }
      LegArmor.Health = LegArmor.MaxHealth;
   }
}

exec function DEVRemoveArmor()
{
   ServerRemoveArmor();
}

reliable server function ServerRemoveArmor()
{
   local CPArmor Armor;
   local CPInventoryManager InvManager;

   if (CPPawn(Pawn) == None && CPInventoryManager(CPPawn(Pawn).InvManager) == None)
   {
      return;
   }

   if (PlayerReplicationInfo.bAdmin || WorldInfo.NetMode == NM_Standalone)
    {
      InvManager = CPInventoryManager(CPPawn(Pawn).InvManager);

        Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Body', false ) );
        if (Armor != None)
           Armor.Health = 0.0;
        Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Head', false ) );
        if (Armor != None)
           Armor.Health = 0.0;
        Armor = CPArmor( InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Leg', false ) );
        if (Armor != None)
           Armor.Health = 0.0;
    }
}

exec function DEVSetHealth (int i)
{
   ServerSetHealth(i);
}

reliable server function ServerSetHealth (int i)
{
    if (Pawn == None )
    {
        return;
    }

    if (PlayerReplicationInfo.bAdmin || WorldInfo.NetMode == NM_Standalone)
    {
        Pawn.Health = Min(100, Max(1,i));
    }
}

/*
exec function DEVSetAdmin()
{
   ServerSetAdmin();
}

reliable server function ServerSetAdmin()
{
   PlayerReplicationInfo.bAdmin = true;
}
*/


//TOP-Proto removed..
//exec function DEVForceRagdoll()
//{
//  if (CPPawn(Pawn)!=none)
//      CPPawn(Pawn).ForceRagdoll();
//}

exec function DEVOscStartRouting(optional string overrideHostIP,optional int overrideHostPort)
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object refernece is none while trying to use DEV function");
        return;
    }
    if (bDEVOscRouting)
    {
        ClientMessage("Audio routing trough OSC is already enabled!");
        return;
    }
    if (overrideHostIP!="")
        taExtUtils.oscRouterHostIP=overrideHostIP;
    if (overrideHostPort>0)
        taExtUtils.oscRouterHostPort=overrideHostPort;
    bDEVOscRouting=taExtUtils.OscRouterInit();
    if (bDEVOscRouting)
    {
        DEVOscSendMessageBool("RoutingStatus",true);
        DEVOscSendMessageInt("RouterVersion",1);
        DEVOscSendMessageInt("UDKEngineVersion",GetEngineVersion());
        DEVOscSendMessageInt("UDKEngineBuildChangeListNumber",GetBuildChangelistNumber());
        ClientMessage("Started routing audio events trough OSC with host "$taExtUtils.oscRouterHostIP$":"$taExtUtils.oscRouterHostPort);
    }
    else
        ClientMessage("Failed to start audio event routing...");
}

exec function DEVOscStopRouting()
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    if (!bDEVOscRouting)
        return;
    DEVOscSendMessageBool("RoutingStatus",false);
    taExtUtils.OscRouterShutDown();
    bDEVOscRouting=false;
    ClientMessage("Stopped audio event routing trough OSC");
}

exec function DEVOscSaveConfig()
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    taExtUtils.SaveConfig();
}

exec function DEVOscStartIndexing()
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    if (!bDEVOscRouting)
    {
        ClientMessage("Unable to start sound cue indexing, start OSC routing first!");
        return;
    }
    if (bDEVOscIndexing)
    {
        ClientMessage("Sound cue indexing is already running...");
        return;
    }
    ClientMessage("Started OSC sound indexing...");
    taExtUtils.oscSoundCueIndexer.Remove(0,taExtUtils.oscSoundCueIndexer.Length);
    bDEVOscIndexing=true;
}

exec function DEVOscStopIndexing()
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    if (bDEVOscIndexing)
    {
        bDEVOscIndexing=false;
        DEVOscSaveConfig();
        ClientMessage("Stopped OSC sound indexing with "$taExtUtils.oscSoundCueIndexer.Length$" index(es) saved");
    }
}

exec function DEVOscPrintIndexesToLog()
{
local int k;

    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    if (!bDEVOscRouting)
    {
        ClientMessage("Unable to print sound cue indexes to log, start OSC routing first!");
        return;
    }
    if (bDEVOscIndexing)
    {
        ClientMessage("Unable to print sound cue indexes to log, indexing is still running");
        return;
    }
    `log("=========================================",,'DEVOscSoundCueIndexer');
    for(k=0;k<taExtUtils.oscSoundCueIndexer.Length;k++)
    {
        if (taExtUtils.oscSoundCueIndexer[k]!="")
            `log("index: "$k$", "$taExtUtils.oscSoundCueIndexer[k],,'DEVOscSoundCueIndexer');
    }
}

exec function DEVMusicManagerSetState(int newState)
{
    if (CPMusicManager!=none)
        CPMusicManager.DebugSwitchMusicState(newState);
}

exec function DEVMusicManagerForceNudge(int loopType,float nextNudgeTime,optional int loopLevel)
{
    if (CPMusicManager!=none)
        CPMusicManager.DebugForceNudge(loopType,nextNudgeTime,loopLevel);
}

exec function DEVMusicManagerCamperMode(bool bSetTo)
{
    if (CPMusicManager!=none)
        CPMusicManager.DebugSetCamperMusicMode(bSetTo);
}

exec function DEVSetWeaponViewOffset(float X,float Y,float Z)
{
local CPWeapon taWep;

    if (Pawn==none)
        return;
    taWep=CPWeapon(Pawn.Weapon);
    if (taWep==none)
        return;
    taWep.PlayerViewOffset.X=X;
    taWep.PlayerViewOffset.Y=Y;
    taWep.PlayerViewOffset.Z=Z;
}

exec function DEVGetWeaponViewOffset()
{
local CPWeapon taWep;

    if (Pawn==none)
        return;
    taWep=CPWeapon(Pawn.Weapon);
    if (taWep==none)
        return;
    `log("weapon view offset X "$taWep.PlayerViewOffset.X$" Y "$taWep.PlayerViewOffset.Y$" Z "$taWep.PlayerViewOffset.Z);
}

exec function DEVWeaponDrawTraces(bool bDrawState)
{
    bDEVWeaponDrawTraces=bDrawState;
    if (Pawn!=none && Pawn.Weapon!=none)
        Pawn.Weapon.FlushPersistentDebugLines();
}

exec function DEVToggleWeaponTuneMode()
{
    bDEVWeaponTuneMode=!bDEVWeaponTuneMode;
}

exec function DEVSetBehindView ()
{
    if (CPGameReplicationInfo(WorldInfo.GRI) != None)
    {
        CPGameReplicationInfo(WorldInfo.GRI).bAllowBehindView = true;
    }
    BehindView();
}
/*
dev exec funcs
*/

/*
dev functions
*/
function DEVOscIndexSoundName(string SoundName)
{
local int k;

    if (SoundName=="")
        return;
    for (k=0;k<taExtUtils.oscSoundCueIndexer.Length;k++)
        if (taExtUtils.oscSoundCueIndexer[k]==SoundName)
            return;
    taExtUtils.oscSoundCueIndexer.AddItem(SoundName);
    `log("indexed sound cue: "$SoundName$" at "$taExtUtils.oscSoundCueIndexer.Length-1,,'DEVOscSoundCueIndexer');
}

function bool DEVOscIsIndexedSound(SoundCue testSound,out int soundIndex)
{
local int k;
local string soundName;

    if (testSound==none)
        return false;
    soundName=string(testSound);
    for (k=0;k<taExtUtils.oscSoundCueIndexer.Length;k++)
    {
        if (taExtUtils.oscSoundCueIndexer[k]==soundName)
        {
            soundIndex=k;
            return true;
        }
    }
    return false;
}

function string DEVOscComposeMessageURL(string varName)
{
    if (varName=="")
        return "/UDK/TA/OSCRouter/UnknownValue";
    return ("/UDK/TA/OSCRouter/"$varName);
}

function DEVOscSendMessageBool(string varName,bool varValue)
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    taExtUtils.OscRouterSendBool(DEVOscComposeMessageURL(varName),varValue);
}

function DEVOscSendMessageInt(string varName,int varValue)
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    taExtUtils.OscRouterSendInt(DEVOscComposeMessageURL(varName),varValue);
}

function DEVOscSendMessageFloat(string varName,float varValue)
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    taExtUtils.OscRouterSendFloat(DEVOscComposeMessageURL(varName),varValue);
}

function DEVOscSendMessageString(string varName,string varValue)
{
    if (taExtUtils==none)
    {
        `warn("TA External Utils object reference is none while trying to use DEV function");
        return;
    }
    taExtUtils.OscRouterSendString(DEVOscComposeMessageURL(varName),varValue);
}
/*
dev funcitons
*/

// showdebug stuff
simulated function DisplayDebug(HUD HUD,out float out_YL,out float out_YPos)
{
local int i;

    super.DisplayDebug(HUD,out_YL,out_YPos);
    if (HUD.ShouldDisplayDebug('music'))
    {
        if (CPMusicManager!=none)
            CPMusicManager.DisplayDebug(HUD,out_YL,out_YPos);
        else
        {
            HUD.Canvas.SetDrawColor(255,0,0);
            HUD.Canvas.DrawText("NO MUSIC MANAGER");
            out_YPos+=out_YL;
            HUD.Canvas.SetPos(4,out_YPos);
        }
    }

    HUD.Canvas.SetDrawColor(205,100,0);

    HUD.Canvas.DrawText("++ Camper Infos ++");
    out_YPos+=out_YL;
    HUD.Canvas.SetPos(4,out_YPos);

    for (i=0;i<CamperInfos.Length;i++)
    {
        HUD.Canvas.DrawText("Camper UID "$CamperInfos[i].UID$" at X="$CamperInfos[i].CamperPos.X$" Y="$CamperInfos[i].CamperPos.Y$" Z="$CamperInfos[i].CamperPos.Z);
        out_YPos+=out_YL;
        HUD.Canvas.SetPos(4,out_YPos);
    }
}

// music system helper
function AcknowledgePossession(Pawn P)
{
    Super.AcknowledgePossession(P);

    if ( LocalPlayer(Player) != None )
    {
        ServerPlayerPreferences(WeaponHandPreference, true, bCenteredWeaponFire);

        if ( (PlayerReplicationInfo != None)
            && (PlayerReplicationInfo.Team != None)
            && (IdentifiedTeam != PlayerReplicationInfo.Team.TeamIndex) )
        {
            // identify your team the first time you spawn on it
            IdentifiedTeam = PlayerReplicationInfo.Team.TeamIndex;
            if ( IdentifiedTeam < 2 )
            {
                ReceiveLocalizedMessage( class'CPMsg_Team', IdentifiedTeam+1, PlayerReplicationInfo);
            }
        }
    }

    if (CPMusicManager!=none && !CPMusicManager.bStarted && CPMusicManager.ManagerState==TMMS_Running)
        CPMusicManager.StartMusicPlayback();
}

// music system
function bool MusicManagerKismetEvent(TAMusicKismetEventType eventType,name eventName,optional float eventVolume)
{
local float tmpVolume;

    if (CPMusicManager==none || eventName=='')
        return false;
    if (CPMusicManager.ManagerState!=TMMS_Running)
        return false;
    if (eventType==TMKE_GetState)
        return CPMusicManager.QueryKismetEvent(eventName);
    tmpVolume=eventVolume;
    if (tmpVolume<0.0)
        tmpVolume=0.0;
    if (tmpVolume>5.0)
        tmpVolume=5.0;
    CPMusicManager.QueneKismetEvent(eventType,eventName,tmpVolume);
    return true;
}

function SetMusicSoundMode(name soundModeToSet)
{
    if (soundModeToSet=='')
    {
        SoundModeChanged('',true);
        return;
    }
    if (CurrentMusicSoundMode!=soundModeToSet)
        SoundModeChanged(soundModeToSet,true);
}

function OnSetSoundMode(SeqAct_SetSoundMode Action)
{
    if (Action.InputLinks[0].bHasImpulse && (Action.SoundMode!=none))
        SoundModeChanged(Action.SoundMode.Name,false);
    else
        SoundModeChanged('',false);
}

// TODO : add a multiplexer into this function to be able to blend a few sound modes together. The music
//          sound mode and the game sound mode should coexist, but we can only set 1 of them trough the
//          Audio Device so in order to use both they must be blended together.
function SoundModeChanged(name newSoundMode,bool bMusicMode)
{
local AudioDevice Audio;
local name soundModeName;

    Audio=class'Engine'.static.GetAudioDevice();
    if (Audio==none)
        return;
    if (newSoundMode=='')
        soundModeName='Default';
    else
        soundModeName=newSoundMode;

    if (bMusicMode)
    {
        if (soundModeName!=CurrentMusicSoundMode)
        {
            if (Audio.SetSoundMode(soundModeName))
                CurrentMusicSoundMode=soundModeName;
            else
                `log("failed to set music sound mode to "$soundModeName);
        }
    }
    else
    {
        if (soundModeName!=CurrentGameSoundMode)
        {
            if (Audio.SetSoundMode(soundModeName))
                CurrentGameSoundMode=soundModeName;
            else
                `log("failed to set game sound mode to "$soundModeName);
        }
    }
}

reliable client simulated function ClientPawnDied()
{
    bCampingWarningActive=false;
	ResetScopeSettings();
    if (CPMusicManager!=none && CPMusicManager.ManagerState==TMMS_Running)
        CPMusicManager.Notify_PawnDied();
    CamperInfos.Remove(0,CamperInfos.Length);

    // Unduck if ducking
    bDuck = 0;
}

reliable client function SetClientCampingStatus(bool bNewStatus)
{
    if (Pawn!=none && Pawn.IsA('CPPawn'))
        bCampingWarningActive=bNewStatus;
    else
        bCampingWarningActive=false;
    CampingStartTime=WorldInfo.TimeSeconds;
    if (CPMusicManager!=none && CPMusicManager.ManagerState==TMMS_Running)
        CPMusicManager.UpdateMusicState();
}

// camper info, client side
reliable client function ClientAddCamperPosition(int pos,float X,float Y,float Z)
{
local int i;
local SCamperInfo newInfo;

    for (i=0;i<CamperInfos.Length;i++)
    {
        if (CamperInfos[i].UID==pos)
        {
            CamperInfos[i].CamperPos.X=X;
            CamperInfos[i].CamperPos.Y=Y;
            CamperInfos[i].CamperPos.Z=Z;
            return;
        }
    }
    newInfo.UID=pos;
    newInfo.CamperPos.X=X;
    newInfo.CamperPos.Y=Y;
    newInfo.CamperPos.Z=Z;
    CamperInfos.AddItem(newInfo);
}

reliable client function ClientRemoveCamperPosition(int pos)
{
local int i;

    for (i=0;i<CamperInfos.Length;i++)
    {
        if (CamperInfos[i].UID==pos)
        {
            CamperInfos.Remove(i,1);
            i--;
        }
    }
}

unreliable client function ClientUpdateCamperPosition(int pos,float X,float Y,float Z)
{
local int i;

    for (i=0;i<CamperInfos.Length;i++)
    {
        if (CamperInfos[i].UID==pos)
        {
            CamperInfos[i].CamperPos.X=X;
            CamperInfos[i].CamperPos.Y=Y;
            CamperInfos[i].CamperPos.Z=Z;
            return;
        }
    }
}

function CleanCamperInfos()
{
    CamperInfos.Remove(0,CamperInfos.Length);
}

simulated function OnWeaponHitEnemy()
{
    CPGameReplicationInfo(WorldInfo.GRI).bDamageTaken=true;

    if (CPMusicManager!=none && CPMusicManager.ManagerState==TMMS_Running)
        CPMusicManager.UpdateMusicState();
}

simulated function OnDamageTaken()
{
    CPGameReplicationInfo(WorldInfo.GRI).bDamageTaken=true;

    if (CPMusicManager!=none && CPMusicManager.ManagerState==TMMS_Running)
        CPMusicManager.UpdateMusicState();
}

reliable client function OnTeammateHit()
{
    CPGameReplicationInfo(WorldInfo.GRI).bDamageTaken=true;

    LastTeammateHitTime=WorldInfo.TimeSeconds;
    if (CPMusicManager!=none && CPMusicManager.ManagerState==TMMS_Running)
        CPMusicManager.UpdateMusicState();
}

exec function Vote()
{
    local Console PlayerConsole;
    local LocalPlayer LP;

    LP = LocalPlayer( Player );
    if( ( LP != None ) && CanCommunicate() && ( LP.ViewportClient.ViewportConsole != None ) )
    {
        PlayerConsole = LocalPlayer( Player ).ViewportClient.ViewportConsole;
        PlayerConsole.StartTyping( "Vote " );
    }
}

reliable client event ClientBeingKickedForTeamKilling(string Killer, string Victim)
{
    local string S;
    S = "\nYou Teamkilled " $ Victim $ "\nMax Team-Kill Limit Reached, Auto-Kick" $ "\nYou Were Kicked From The Server";

    `log(S);
    if( Player != None)
    {
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( S );
    }
}

reliable client event ClientWasVoteKicked()
{
    `Log("You were voted out for the remaining of this map");
    LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText("You were voted out for the remaining of this map");
    CPGameViewportClient(LocalPlayer( Player ).ViewportClient).blnVoted = true;
}

exec function Whisper()
{
    /*local Console PlayerConsole;
    local LocalPlayer LP;

    LP = LocalPlayer( Player );
    if( ( LP != None ) && CanCommunicate() && ( LP.ViewportClient.ViewportConsole != None ) )
    {
        PlayerConsole = LocalPlayer( Player ).ViewportClient.ViewportConsole;
        PlayerConsole.StartTyping( "Whisper " );
    }*/

	CPHUD = CPHUD(myHUD);
    if(CPHUD != none)
    {
        if(CPHUD.HudMovie != none)
        {
			if(PlayerReplicationInfo.bOutOfLives)
			{
				CPHUD.HudMovie.ToggleChat("DeadWhisper");
			}
			else
			{
				CPHUD.HudMovie.ToggleChat("Whisper");
			}
        }
	}
}

function string ConsoleCommand(string Command, optional bool bWriteToLog = true)
{
    local string strID, Msg;
    local int intCheck;
    if(CAPS(LEFT(Command,8)) == "WHISPER ")
    {
        //now we need to get the id of whos being whispered

        strID = Split(Command,' ',true);
        Msg = Split(strID,' ',true);

        if(LEN(strID) > 0)
            strID =  Repl(" " $ strID, Msg,"",true);
        else
        {
            LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "you must supply a user to whisper!" );
            return "";
        }

        intCheck = int(strID); //FEATURE strID could in fact be a players name that could be recognised later on.

        if(intCheck == 0)
        {
            LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText("ID Not recognised! example use Whisper 1 hi OR Whisper 10 hi");
            return "";
        }

        if(intCheck == CPPlayerReplicationInfo(PlayerReplicationInfo).CPPlayerID)
        {
            LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "you cant whisper yourself!" );
            return "";
        }

        //dont whisper if the id doesnt exist!
        if( GetPlayerNameFromPRI(int(strID)) == "unknown name")
        {
            LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "player doesnt exist" );
            return "";
        }
        ServerWhisper(strID, msg);
    }
    else if(CAPS(LEFT(Command,5)) == "VOTE ")
    {
        //now we need to get the id of whos being whispered

        strID = Split(Command,' ',true);
        Msg = Split(strID,' ',true);

        if(strID != Msg) //in cases of no reason for the vote
            strID =  Repl(" " $ strID,Msg,"",true);

        intCheck = int(strID); //FEATURE strID could in fact be a players name that could be recognised later on.

        if(intCheck == 0)
        {
            LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText("ID Not recognised! example use Whisper 1 hi OR Whisper 10 hi");
            return "";
        }

        if(intCheck == CPPlayerReplicationInfo(PlayerReplicationInfo).CPPlayerID)
        {
            LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "you cant vote yourself!" );
            return "";
        }

        //dont whisper if the id doesnt exist!
        if( GetPlayerNameFromPRI(int(strID)) == "unknown name")
        {
            LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "player doesnt exist" );
            return "";
        }
        ServerVote(strID, msg);
    }

    return super.ConsoleCommand(Command,bWriteToLog);
}

unreliable server function ServerVote(string strID, string Msg )
{
    local CPPlayerController P;

    foreach WorldInfo.AllControllers(class'CPPlayerController', P)
    {
        if(CPPlayerReplicationInfo(P.PlayerReplicationInfo).CPPlayerID == int(strID)) //who the votes for
        {
            AddVote(CPPlayerReplicationInfo(P.PlayerReplicationInfo), CPPlayerReplicationInfo(PlayerReplicationInfo).CPPlayerID); //who the votes from
            return;
        }
    }
}

unreliable server function AddVote(CPPlayerReplicationInfo PRI, int strID)
{
    //add votecount
    if (PRI.VoteList.Find(strID) == INDEX_NONE)
    {
        //broadcast someones being voted
        WorldInfo.Game.Broadcast(self,PRI.PlayerName, 'Vote'); //just send who the vote is for
        PRI.VoteList.AddItem(strID);
    }
    else
    {
        //TOP-Proto accessed nones with this.. trying to message client on the server.
        if( (Player != none) && (LocalPlayer(Player) != none) )
           LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "you cant vote someone twice!" );
        //already voted
    }

    //if voted set a flag to identify someones been voted out (used to ban them for the map)
    `Log("number of votes " $ PRI.VoteList.Length);
    `Log("number of players " $ WorldInfo.GRI.PRIArray.Length);
    if(VotePassed(PRI.VoteList.Length , WorldInfo.GRI.PRIArray.Length)) //todo set this to 51% of the people voting
    {
        WorldInfo.Game.Broadcast(self, PRI.PlayerName $ " was voted off the server.", 'VoteKicked');
        ServerVoteKick(PRI.PlayerName);
    }
}

function bool VotePassed( int numVotes, int numPlayers )
{
    return ( float( numVotes ) / float( numPlayers ) ) > 0.5;
}

unreliable server function ServerWhisper(string strID, string Msg )
{
    local bool IdOutOfLives;
    LastActiveTime = WorldInfo.TimeSeconds;

    IdOutOfLives = GetPlayerLifeStatusFromPRI(int(strID));

    if(PlayerReplicationInfo.bOutOfLives && IdOutOfLives)
    {
        CriticalPointGame(WorldInfo.Game).Broadcast( self, strID @ Msg, 'DeadWhisper'); //support whispering people when YOU are dead.. but THEY must also be dead too...
    }
    else if(PlayerReplicationInfo.bOutOfLives && !IdOutOfLives)
    {
        //have to call this on the client because we want the client hud to show this message.
        CantWhisperAlivePlayersWhenDead();
    }
    else
    {
        CriticalPointGame(WorldInfo.Game).Broadcast( self, strID @ Msg, 'Whisper');
    }
}

function unreliable client CantWhisperAlivePlayersWhenDead()
{
    if(CPHUD(myHUD) != none)
    {
        CPHUD(myHUD).AddCanvasEventMsg( "you cant whisper alive players when dead" );
    }
}

function bool GetPlayerLifeStatusFromPRI(int id)
{
    local CPGameReplicationInfo GRI;
    local int i;

    GRI = CPGameReplicationInfo(WorldInfo.GRI);

    if (GRI != None)
    {
        for (i=0; i < GRI.PRIArray.Length; i++)
        {
            if(CPPlayerReplicationInfo(GRI.PRIArray[i]).CPPlayerID == id)
            {
                return GRI.PRIArray[i].bOutOfLives;
            }
        }
    }
    return true;
}


unreliable server function ServerSay( string Msg )
{
    local PlayerController PC;

    if(WorldInfo != none)
    {
        // center print admin messages which start with #
        if (PlayerReplicationInfo.bAdmin && left(Msg,1) == "#" )
        {
            Msg = right(Msg,len(Msg)-1);
            foreach WorldInfo.AllControllers(class'PlayerController', PC)
            {
                `log("ServerSay Broadcasting Client Admin Message" @ Msg);
                PC.ClientAdminMessage(Msg);
            }
            return;
        }

        if(WorldInfo.Game != none)
        {
            //used to color admin messages
            if(PlayerReplicationInfo.bAdmin)
            {
                WorldInfo.Game.Broadcast(self, Msg, 'Admin');
            }
            else if(PlayerReplicationInfo.bOnlySpectator) //used to color spectator messages
            {
                WorldInfo.Game.Broadcast(self, Msg, 'Spectator');
            }
            else
            {
                if(PlayerReplicationInfo.bOutOfLives)
                {
                    WorldInfo.Game.BroadcastTeam( self, Msg, 'DeadSay');
                }
                else
                {
                    WorldInfo.Game.Broadcast(self, Msg, 'Say');
                }
            }
        }
    }
}


reliable client function ClientAdminMessage(string Msg)
{
    local LocalPlayer LP;

    LP = LocalPlayer(Player);
    if (LP != None)
    {
        `log("ServerSay Broadcasting Client Admin Message" @ Msg);
        LP.ViewportClient.ClearProgressMessages();
        LP.ViewportClient.SetProgressTime(6);
        LP.ViewportClient.SetProgressMessage(PMT_AdminMessage, Msg);
        if (CPHUD(myHUD) != None)
        {
            CPHUD(myHUD).SetAdminBroadcastMessage(Msg);
        }
    }
}


exec function adminSay( string Msg)
{
    Msg = "# "$Left(Msg,128);

    if ( AllowTextMessage(Msg) )
        ServerSay(Msg);
}


unreliable server function ServerTeamSay( string Msg )
{
    LastActiveTime = WorldInfo.TimeSeconds;

    if( !WorldInfo.GRI.GameClass.Default.bTeamGame )
    {
        Say( Msg );
        return;
    }

    //Teamsay message should be handled normal even if admin......
    //if(PlayerReplicationInfo.bAdmin)
    //{
    //  WorldInfo.Game.Broadcast(self, Msg, 'AdminTeamSay');
    //}
    if(PlayerReplicationInfo.bOnlySpectator) //used to color spectator messages
    {
        // Don't allow spectator to teamsay.. Just ignore the message
        // WorldInfo.Game.Broadcast(self, Msg, 'Spectator');
    }
    else
    {
        if(PlayerReplicationInfo.bOutOfLives)
        {
            WorldInfo.Game.BroadcastTeam( self, Msg, 'DeadTeamSay');
        }
        else
        {
            WorldInfo.Game.BroadcastTeam( self, Msg, 'TeamSay');
        }
    }
}


simulated private function bool CanCommunicate()
{
    return TRUE;
}

reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
    //local bool bIsUserCreated;
    local bool blnDead;

    if( CanCommunicate() )
    {
        if( myHUD != None )
        {
            myHUD.Message( PRI, S, Type, MsgLifeTime );
        }

        //fix so the content is added to the console log and is always appended with the name.
        if( ( ( Type == 'Say' ) || ( Type == 'TeamSay' ) || ( Type == 'Admin' )  ) && ( PRI != None ) )
        {
            if(Type == 'TeamSay')
            {
                S = PRI.PlayerName$": Teamsay: "$S;
            }
            else
            {
                S = PRI.PlayerName$": "$S;
            }
            // This came from a user so flag as user created
            //bIsUserCreated = true;

            // since this is on the client, we can assume that if Player exists, it is a LocalPlayer
            if( Player != None)
            {
                // Don't allow this if the parental controls block it
                //if( !bIsUserCreated || ( bIsUserCreated && CanViewUserCreatedContent() ) )
                //{
                    // I assume this is what is stopping arny's messages from showing in consol. If we see them
                    // on screen then why stop them here?
                    LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( S );
                //}
            }
        }
        else if((Type == 'DeadSay' || Type == 'DeadTeamSay' ) && ( PRI != None ))
        {
            S = PRI.PlayerName$": (Dead) "$S;
            //but we dont want to send dead messages to players consoles that are still alive
            if(PlayerReplicationInfo.bOutOfLives)
            {
                blnDead = true;
            }
            else
            {
                blnDead = false;
            }

            // since this is on the client, we can assume that if Player exists, it is a LocalPlayer
            if( Player != None && blnDead)
            {
                // Don't allow this if the parental controls block it
                //if( !bIsUserCreated || ( bIsUserCreated && CanViewUserCreatedContent() ) )
                //{
                    // I assume this is what is stopping arny's messages from showing in consol. If we see them
                    // on screen then why stop them here?
                    LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( S );
                //}
            }
        }
        else if((Type == 'AdminKickEvent') || (Type == 'AdminLoginEvent') || (Type == 'AdminLogoutEvent'))
        {
            // since this is on the client, we can assume that if Player exists, it is a LocalPlayer
            if( Player != None)
            {
                // Don't allow this if the parental controls block it
                //if( !bIsUserCreated || ( bIsUserCreated && CanViewUserCreatedContent() ) )
                //{
                    // I assume this is what is stopping arny's messages from showing in consol. If we see them
                    // on screen then why stop them here?
                    LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( S );
                //}
            }
        }
        //`log("CPPlayerController::TeamMessage Received msg Type=" @ Type @" msg=" @ S);
    }
}

/** used to decide whenever the rednering is started yet or not */
simulated function bool FirstFrameDrawn()
{
    if (LocalPlayer(Player)!=none && CPGameViewportClient(LocalPlayer(Player).ViewportClient)!=none)
        return CPGameViewportClient(LocalPlayer(Player).ViewportClient).bRenderedAFrame;
    return false;
}

function PlayTAAnnouncement(class<CPLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
    // Wait for player to be up to date with replication when joining a server, before stacking up messages
    if ( WorldInfo.GRI == None || TAAnnounce == None ||
        (CPGameReplicationInfo(WorldInfo.GRI) != None && CPGameReplicationInfo(WorldInfo.GRI).bAnnouncementsDisabled) )
    {
        return;
    }
    TAAnnounce.PlayAnnouncement(InMessageClass, MessageIndex, PRI, OptionalObject);
}

reliable client function ClientTAPlayAnnouncement(class<CPLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
    PlayTAAnnouncement(InMessageClass, MessageIndex, PRI, OptionalObject);
}

reliable client function ClientPlayAnnouncement(class<CPLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
    `Log("ClientPlayAnnouncement Playing something it shouldnt!! route to ClientTAPlayAnnouncement");
}

function PlayAnnouncement(class<CPLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
    `Log("PlayAnnouncement Playing something it shouldnt!! route to PlayTAAnnouncement");
}

/** Causes a view shake based on the amount of damage
    Should only be called on the owning client */
function DamageShake(int Damage, class<DamageType> DamageType)
{
    local float BlendWeight;
    local class<CPDamageType> TADamage;
    local CameraAnim AnimToPlay;

    TADamage = class<CPDamageType>(DamageType);
    if (TADamage != None && TADamage.default.DamageCameraAnim != None)
    {
        AnimToPlay = TADamage.default.DamageCameraAnim;
    }
    else
    {
        AnimToPlay = DamageCameraAnim;
    }
    if (AnimToPlay != None)
    {
        // don't override other anims unless it's another, weaker damage anim
        BlendWeight = FClamp(Damage / 200.0, 0.0, 1.0);
        if ( CameraAnimPlayer != None && ( CameraAnimPlayer.bFinished ||
                        (bCurrentCamAnimIsDamageShake && CameraAnimPlayer.CurrentBlendWeight < BlendWeight) ) )
        {
            PlayCameraAnim(AnimToPlay, BlendWeight,,,,, true);
        }
    }
}

/** plays the specified camera animation with the specified weight (0 to 1)
 * local client only
 */
function PlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
            optional float BlendInTime, optional float BlendOutTime, optional bool bLoop, optional bool bIsDamageShake )
{
    local Camera MatineeAnimatedCam;

    bCurrentCamAnimAffectsFOV = false;

    // if we have a real camera, e.g we're watching through a matinee camera,
    // send the CameraAnim to be played there
    MatineeAnimatedCam = PlayerCamera;
    if (MatineeAnimatedCam != None)
    {
        MatineeAnimatedCam.PlayCameraAnim(AnimToPlay, Rate, Scale, BlendInTime, BlendOutTime, bLoop, FALSE);
    }
    else if (CameraAnimPlayer != None)
    {
        // play through normal UT camera
        CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
        CameraAnimPlayer.Play(AnimToPlay, self, Rate, Scale, BlendInTime, BlendOutTime, bLoop, false);
    }

    // Play controller vibration - don't do this if damage, as that has its own handling
    if( !bIsDamageShake && !bLoop && WorldInfo.NetMode != NM_DedicatedServer )
    {
        if( AnimToPlay.AnimLength <= 1 )
        {
            ClientPlayForceFeedbackWaveform(CameraShakeShortWaveForm);
        }
        else
        {
            ClientPlayForceFeedbackWaveform(CameraShakeLongWaveForm);
        }
    }

    bCurrentCamAnimIsDamageShake = bIsDamageShake;
}

unreliable client event ClientPlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
                                             optional float BlendInTime, optional float BlendOutTime, optional bool bLoop,
                                             optional bool bRandomStartTime, optional ECameraAnimPlaySpace Space=CAPS_CameraLocal, optional rotator CustomPlaySpace )
{
    PlayCameraAnim(AnimToPlay, Scale, Rate, BlendInTime, BlendOutTime, bLoop);
}

/** called through camera anim code when it modifies FOVAngle */
function OnUpdatePropertyFOVAngle()
{
    bCurrentCamAnimAffectsFOV = true;
    // adjust the anim's FOV so that it is relative to our desired FOV
    FOVAngle = DesiredFOV + (FOVAngle - 90.0);
}

/* epic ===============================================
* ::CheckBulletWhip
*
 * @param   BulletWhip - whip sound to play
 * @param   FireLocation - where shot was fired
 * @param   FireDir - direction shot was fired
 * @param   HitLocation - impact location of shot
* =====================================================
*/
function CheckBulletWhip(soundcue BulletWhip, vector FireLocation, vector FireDir, vector HitLocation)
{
    local vector PlayerDir;
    local float Dist, PawnDist;

    if ( ViewTarget != None  )
    {
        // if bullet passed by close enough, play sound
        // first check if bullet passed by at all
        PlayerDir = ViewTarget.Location - FireLocation;
        Dist = PlayerDir Dot FireDir;

        if ( (Dist > 0) && ((FireDir Dot (HitLocation - ViewTarget.Location)) > 0) )
        {
            // check distance from bullet to vector
            PawnDist = VSize(PlayerDir);
            // These Distances are Units squared. 50 Units should be good which is about 3 feet or so or 2500 Squared Units.
            if ( abs(Square(PawnDist) - Square(Dist)) < 2500 )
            {
                // check line of sight
                if ( FastTrace(ViewTarget.Location + class'CPPawn'.default.BaseEyeheight*vect(0,0,1), FireLocation + Dist*FireDir) )
                {
					PlaySound(BulletWhip, true,,, HitLocation);
                }
            }
        }
    }
}

/**
* @returns the a scaling factor for the distance from the collision box of the target to accept aiming help (for instant hit shots)
*/
function float AimHelpModifier()
{
    local float AimingHelp;

    AimingHelp = FOVAngle < DefaultFOV - 8 ? 0.5 : 0.75;

    // reduce aiming help at higher difficulty levels
    if ( WorldInfo.Game.GameDifficulty > 2 )
        AimingHelp *= 0.33 * (5 - WorldInfo.Game.GameDifficulty);

    return AimingHelp;
}

unreliable server function ServerViewPlayerByName(string sPlayerName)
{
    local int i;
    for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
    {
        if (WorldInfo.GRI.PRIArray[i].PlayerName ~= sPlayerName)
        {
            if ( WorldInfo.Game.CanSpectate(self, WorldInfo.GRI.PRIArray[i]) )
            {
                SetViewTarget(WorldInfo.GRI.PRIArray[i]);
            }
            return;
        }
    }

    ClientMessage(MsgPlayerNotFound);
}

/** Turns off any view shaking */
function StopViewShaking()
{
    if (CameraAnimPlayer != None)
    {
        CameraAnimPlayer.Stop();
    }
}

/** Stops the currently playing camera animation. */
function StopCameraAnim(optional bool bImmediate)
{
    if (CameraAnimPlayer != None)
    {
        CameraAnimPlayer.Stop(bImmediate);
    }
}

/**
  * return true if music manager is already playing action track
  * return true if no music manager (no need to tell non-existent music manager to change tracks
  */
function bool AlreadyInActionMusic()
{
    return false;
    //return (CPMusicManager != None) ? MusicManager.AlreadyInActionMusic() : true;
}

simulated function SetCharacterClass(class<CPFamilyInfo> CharClassInfo)
{
    LastTeamChangeTime = WorldInfo.TimeSeconds;

    CPPlayerReplicationInfo(PlayerReplicationInfo).CharClassInfo = CharClassInfo;
    CPPlayerReplicationInfo(PlayerReplicationInfo).bIsFemale = CharClassInfo.default.bIsFemale;
    //TODO: Set character voice?
    ServerSetCharacterClass(CharClassInfo);
}

/** tells the server about the character this player is using */
reliable server function ServerSetCharacterClass(class<CPFamilyInfo> CharClassInfo)
{
    CPPlayerReplicationInfo(PlayerReplicationInfo).CharClassInfo = CharClassInfo;
    CPPlayerReplicationInfo(PlayerReplicationInfo).bIsFemale = CharClassInfo.default.bIsFemale;
    //TODO: Set character voice?
}


function DrawHUD( HUD H )
{
    // force scoreboard on if dedicated server spectator
    if (bDedicatedServerSpectator && !H.bShowScores)
    {
        H.ShowScores();
    }

    if( (Pawn != None) && (CPWeapon(Pawn.Weapon) != None) )
    {
        CPWeapon(Pawn.Weapon).ActiveRenderOverlays(H);
    }
    else if( IsInState('Spectating') && !IsInGhostCam() && ViewTarget!=None && Pawn(ViewTarget)!=None && Pawn(ViewTarget).IsAliveAndWell() && Pawn(ViewTarget).Weapon!=None)
    {
        CPWeapon(Pawn(ViewTarget).Weapon).ActiveRenderOverlays(H);
    }
}

/* CheckJumpOrDuck()
Called by ProcessMove()
handle jump and duck buttons which are pressed
*/
function CheckJumpOrDuck()
{
    if ( Pawn == None )
    {
        return;
    }
    else if ( bPressedJump )
    {
        Pawn.DoJump( bUpdating );
    }
    if ( Pawn.Physics != PHYS_Falling && Pawn.bCanCrouch )
    {
        // crouch if pressing duck
        Pawn.ShouldCrouch(bDuck != 0);
    }
}

reliable client function ClientRestart(Pawn NewPawn)
{
    local CPPawn tp;

    bDontKillFlashAudioCue=false; 
    StopFlash();
    Super.ClientRestart(NewPawn);
    ServerPlayerPreferences(WeaponHandPreference, true, bCenteredWeaponFire);

    if (NewPawn != None)
    {
        // if new pawn has empty weapon, autoswitch to new one
        // (happens when switching from Redeemer remote control, for example)
        if (NewPawn.Weapon != None && !NewPawn.Weapon.HasAnyAmmo())
        {
            SwitchToBestWeapon();
        }

    }
    else
    {
        FixFOV();
    }

    //@Wail - 11/22/13 - This should be destroying and ragdolls that are left behind on round changes for dedicated server clients. (CriticalPointGame calls ClientRestart on PCs)
   foreach AllActors(class'CPPawn',tp)
    {
        if (!tp.bDeleteMe && (tp.Health<=0 || tp.IsInState('Dying') || tp.bTearOff))
        {

         tp.TurnOffPawn();
            tp.Destroy();

            //`log("ClientReset: Destroying Dead CPPawn.");
        }
    }

    resetWalkAndDuck();
}

/* epic ===============================================
* ::Possess
*
* Handles attaching this controller to the specified
* pawn.
*
* =====================================================
*/
event Possess(Pawn inPawn, bool bVehicleTransition)
{
    Super.Possess(inPawn, bVehicleTransition);

    // force garbage collection when possessing pawn, to avoid GC during gameplay
    if ( (WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone) )
    {
        WorldInfo.ForceGarbageCollection();
    }

    Pawn.SetMovementPhysics();

    if (Pawn.Physics == PHYS_Walking)
        Pawn.SetPhysics(PHYS_Falling);

}

/**
 * Called after this PlayerController's viewport/net connection is associated with this player controller.
 */
simulated event ReceivedPlayer()
{
    //TOP-Proto this should disable any steam stuff...
    //Super.ReceivedPlayer();
}

reliable server function ServerPlayerPreferences(EWeaponHand NewWeaponHand, bool bNewAutoTaunt, bool bNewCenteredWeaponFire)
{
    ServerSetHand(NewWeaponHand);
    //ServerSetAutoTaunt(bNewAutoTaunt);

    bCenteredWeaponFire = bNewCenteredWeaponFire;
}

event ResetCameraMode()
{}

/**
* return whether viewing in first person mode
*/
function bool UsingFirstPersonCamera()
{
    return !bBehindView;
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
    Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);
}

function DrawTakeHit(vector HitOrigin, int Damage, class<DamageType> damageType)
{
    local int iDam;

    iDam = Clamp(Damage,0,250);
    if ( (iDam > 0 || bGodMode) && (Pawn != None) )
    {
        ClientPlayTakeHit(HitOrigin, iDam, damageType);
    }
}

function SpawnCamera()
{
    local Actor OldViewTarget;

    // Associate Camera with PlayerController
    PlayerCamera = Spawn(MatineeCameraClass, self);
    if (PlayerCamera != None)
    {
        OldViewTarget = ViewTarget;
        PlayerCamera.InitializeFor(self);
        PlayerCamera.SetViewTarget(OldViewTarget);
    }
    else
    {
        `Log("Couldn't Spawn Camera Actor for Player!!");
    }
}

reliable client function ClientImpactEffect( CPPawn OwnerPawn, Vector HitLocation, float nx, float ny, float nz )
{
    local Vector HitNormal;


    HitNormal.X = nx;
    HitNormal.Y = ny;
    HitNormal.Z = nz;
    if ( OwnerPawn != none && OwnerPawn.CurrentWeaponAttachment != none )
        OwnerPawn.CurrentWeaponAttachment.PlayImpactEffects( HitLocation, HitNormal );
}

unreliable client function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> DamageType)
{
    DamageShake(Damage, DamageType);

    //if(Pawn != none)
        //HitLoc += Pawn.Location;

    if ( CPHUD(MyHUD) != None )
    {
        CPHUD(MyHUD).DisplayHit(HitLoc, Damage, DamageType);
    }
}


/* GetPlayerViewPoint: Returns Player's Point of View
    For the AI this means the Pawn's Eyes ViewPoint
    For a Human player, this means the Camera's ViewPoint */
simulated event GetPlayerViewPoint( out vector POVLocation, out Rotator POVRotation )
{
    local float DeltaTime;
    local CPPawn P;
//	local rotator SpecRotation;
//	local vector SpecLocation;

	super.GetPlayerViewPoint(POVLocation,POVRotation);
    P = IsLocalPlayerController() ? CPPawn(CalcViewActor) : None;

    if (LastCameraTimeStamp == WorldInfo.TimeSeconds
        && CalcViewActor == ViewTarget
        && CalcViewActor != None
        && CalcViewActor.Location == CalcViewActorLocation
        && CalcViewActor.Rotation == CalcViewActorRotation
        )
    {
        if ( (P == None) || ((P.EyeHeight == CalcEyeHeight) && (P.WalkBob == CalcWalkBob)) )
        {
            // use cached result
            POVLocation = CalcViewLocation;
            POVRotation = CalcViewRotation;
            return;
        }
    }

    DeltaTime = WorldInfo.TimeSeconds - LastCameraTimeStamp;
    LastCameraTimeStamp = WorldInfo.TimeSeconds;

    // support for using CameraActor views
    if ( CameraActor(ViewTarget) != None )
    {
        if ( PlayerCamera == None )
        {
            super.ResetCameraMode();
            SpawnCamera();
        }
        super.GetPlayerViewPoint( POVLocation, POVRotation );
    }
    else
    {
        if ( PlayerCamera != None )
        {
            PlayerCamera.Destroy();
            PlayerCamera = None;
        }

        if ( ViewTarget != None )
        {
            POVRotation = Rotation;
//TOP-Proto this was added and does increase accuracy but doesnt fix spectator problems... left code around though.
/*
			if(PlayerReplicationInfo != none && !PlayerReplicationInfo.bIsSpectator)
			{
				//GetActorEyesViewPoint
*/
				ViewTarget.CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
/*				//`Log(PlayerReplicationInfo.PlayerName@"POVRotation=" @ POVRotation);
			}
			else
			{
				if(CPPawn(ViewTarget) != none && CPPawn(ViewTarget).PlayerReplicationInfo != none)
				{
					//need to get the loc and rot of the person we are spectating....
					if (Role == ROLE_Authority)
					{
						if(ViewTarget != none)
						{
							//`Log("SERV Yaw=" @ CPPawn(ViewTarget).Rotation.Yaw);
							UpdateSpectatorYawView(CPPawn(ViewTarget).Rotation.Yaw);
							UpdateSpectatorLocView(CPPawn(ViewTarget).Location.X,CPPawn(ViewTarget).Location.Y,CPPawn(ViewTarget).Location.Z);

							ViewTarget.CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
							//`Log("SERV " @CPPawn(ViewTarget).PlayerReplicationInfo.PlayerName@"Rotation=" @ CPPawn(ViewTarget).Rotation @ "Location=" @ CPPawn(ViewTarget).Location);
							return;
						}
					}
					else
					{
						if(ViewTarget != none)
						{
							SpecRotation = CPPawn(ViewTarget).Rotation;
							SpecRotation.Yaw = SpectatorReplicatedYaw;
							SpecLocation.X = SpectatorReplicatedX;
							SpecLocation.Y = SpectatorReplicatedY+ 10000;
							SpecLocation.Z = SpectatorReplicatedZ;

							POVLocation = SpecLocation;
							POVRotation = SpecRotation;

							ViewTarget.CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
							//`Log("SPEC " @CPPawn(ViewTarget).PlayerReplicationInfo.PlayerName@"Rotation=" @ SpecRotation @ "Location=" @ SpecLocation);
						}
					}
				}
			}
*/
            if ( bFreeCamera )
            {
                POVRotation = Rotation;
            }
        }
        else
        {
            CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
            return;
        }
    }

    // apply view shake
    POVRotation = Normalize(POVRotation + ShakeRot);
    POVLocation += ShakeOffset >> Rotation;

    if( CameraEffect != none )
    {
        CameraEffect.UpdateLocation(POVLocation, POVRotation, GetFOVAngle());
    }


    // cache result
	if(ViewTarget != none)
	{
		CalcViewActor = ViewTarget;
		CalcViewActorLocation = ViewTarget.Location;
		CalcViewActorRotation = ViewTarget.Rotation;
	}
    CalcViewLocation = POVLocation;
    CalcViewRotation = POVRotation;

    if ( P != None )
    {
        CalcEyeHeight = P.EyeHeight;
        CalcWalkBob = P.WalkBob;
    }
}

/*
reliable client function UpdateSpectatorYawView(int yaw)
{
	//`Log("SPEC y" @ yaw);
	SpectatorReplicatedYaw = yaw;
	//`Log("SPEC SpectatorReplicatedYaw" @ SpectatorReplicatedYaw);
}

reliable client function UpdateSpectatorLocView(int x, int y, int z)
{
	//`Log("SPEC x" @ x @ "y" @ y @ "z" @ z);
	SpectatorReplicatedX = x;
	SpectatorReplicatedY = y;
	SpectatorReplicatedZ = z;
}
*/

simulated function SendSwapMessageTo( CPDroppedPickup Pickup, optional bool bRemove=false )
{
    local class<CPWeapon>   _DroppedClass;
    local CPPawn            _Pawn;
    local CPWeapon          _Weapon;
    local Vector            _Location, _Direction;
    local Rotator           _Rotation;
    local float             _Length;
    local CPHud             _Hud;


    if ( !bRemove )
    {
        _Pawn = CPPawn( Pawn );
        _DroppedClass = class<CPWeapon>( Pickup.InventoryClass );
        if ( _Pawn == none || _DroppedClass == none )
            return;

        _Weapon = CPWeapon( _Pawn.Weapon );
        if ( _Weapon == none || _Weapon.InventoryGroup != _DroppedClass.default.InventoryGroup )
            return;

        GetPlayerViewPoint( _Location, _Rotation );
        _Direction = Vector( _Rotation );
        _Length = VSize( Pickup.Location - _Location );

        if ( VSizeSq( Pickup.Location - ( _Location + _Direction * _Length ) ) <= 256.0f )
            ReceiveLocalizedMessage( class'CPMsg_SwapWeapon',,,, Pickup.InventoryClass );
    }
    else
    {
        _Hud = CPHUD( myHud );
        if ( _Hud != none )
            _Hud.HudMovie.SetCenterTextBottomZone( "" );
    }
}

// ~WillyG: Edited
exec function PrevWeapon()
{
    if((Vehicle(Pawn) != none) || (Pawn == none))
    {
        AdjustCameraScale(true);
    }
    if(CPInventoryManager(Pawn.InvManager) != none)
    {
        CPInventoryManager(Pawn.InvManager).PrevWeapon();
    }
    else
    {
        super.PrevWeapon();
    }
}

// ~WillyG: Edited
exec function NextWeapon()
{
    if((Vehicle(Pawn) != none) || (Pawn == none))
    {
        AdjustCameraScale(false);
    }
    if(CPInventoryManager(Pawn.InvManager) != none)
    {
        CPInventoryManager(Pawn.InvManager).NextWeapon();
    }
    else
    {
        super.NextWeapon();
    }
}

/** moves the camera in or out */
exec function AdjustCameraScale(bool bIn)
{
    if (CPPawn(ViewTarget) != None)
    {
        CPPawn(ViewTarget).AdjustCameraScale(bIn);
    }
}

/* epic ===============================================
* ::ClientGameEnded
*
* Replicated equivalent to GameHasEnded().
*
 * @param   EndGameFocus - actor to view with camera
 * @param   bIsWinner - true if this controller is on winning team
* =====================================================
*/
reliable client function ClientGameEnded(Actor EndGameFocus, bool bIsWinner)
{
    if( EndGameFocus == None )
        ServerVerifyViewTarget();
    else
    {
        SetViewTarget(EndGameFocus);
    }

    //if ( (PlayerReplicationInfo != None) && !PlayerReplicationInfo.bOnlySpectator )
    //  PlayWinMessage( bIsWinner );

    SetBehindView(true);

    GotoState('RoundEnded');

}


/* epic ===============================================
* ::RoundHasEnded
*
 * @param   EndRoundFocus - actor to view with camera
* =====================================================
*/
function RoundHasEnded(optional Actor EndRoundFocus)
{
    SetViewTarget(EndRoundFocus);
    ClientRoundEnded(EndRoundFocus);
    GotoState('RoundEnded');
}

/* epic ===============================================
* ::ClientRoundEnded
*
 * @param   EndRoundFocus - actor to view with camera
* =====================================================
*/
reliable client function ClientRoundEnded(Actor EndRoundFocus)
{
    if( EndRoundFocus == None )
        ServerVerifyViewTarget();
    else
    {
        SetViewTarget(EndRoundFocus);
    }

    GotoState('RoundEnded');

    SetBehindView(true);
}

/* epic ===============================================
* ::PawnDied - Called when a pawn dies
*
 * @param   P - The pawn that died
* =====================================================
*/

//function PawnDied(Pawn P)
//{
//  Super.PawnDied(P);
//  ClientPawnDied();
//}

simulated function UpdateRotation( float DeltaTime )
{
    local CPPawn                    _Pawn;

    _Pawn = CPPawn( Pawn );
    if ( ( _Pawn != none && _Pawn.bIsUsingObjective ) )
        return;

    super.UpdateRotation( DeltaTime );
}

/** called when the GRI finishes processing custom character meshes */
function CharacterProcessingComplete()
{
    local string LastMovie;
    local LocalPlayer LP;

    LastMovie = class'Engine'.Static.GetLastMovieName();

    if(InStr(LastMovie, "UE3_logo") != -1)
    {
        // stop the loading movie that was up during precaching
        class'Engine'.static.StopMovie(true);
    }

    // if the controller was yanked while we were loading, we couldn't pause the game because that would cause character construction
    // to never complete, so check for a missing controller now

    // don't check for None so that we know if we don't have a valid OnlineSub at this point.
    LP = LocalPlayer(Player);
    if ( LP != None )
    {
        if ( OnlineSub != None && OnlineSub.SystemInterface != None &&
            !OnlineSub.SystemInterface.IsControllerConnected(LP.ControllerId) )
        {
            OnControllerChanged(LP.ControllerId, false);
        }
    }
}

function bool CanRestartPlayer()
{
    return Super.CanRestartPlayer();
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, float Wait, optional class<DamageType> DamageType)
{
    if ( (MessageType == 'TAUNT') && (Recipient != None) && (CPPlayerController(Recipient.Owner) != None) )
    {
        // don't autotaunt people who don't want it
        return;
    }
    CPPlayerReplicationInfo(PlayerReplicationInfo).VoiceClass.static.SendVoiceMessage(self, Recipient, MessageType, DamageType);
}

/** sets NetSpeed on the server, so it won't send the client more than this many bytes */
reliable server function ServerSetNetSpeed(int NewSpeed)
{
    if ( (WorldInfo.Game != None) && (WorldInfo.NetMode == NM_ListenServer) )
    {
        NewSpeed = Min(NewSpeed, WorldInfo.Game.AdjustedNetSpeed);
    }
    SetNetSpeed(NewSpeed);
}

//TODO TOP-PROTO OPTIMISE THESE FUNCTIONS
function CallServerMove
(
    SavedMove NewMove,
    vector ClientLoc,
    byte ClientRoll,
    int View,
    SavedMove OldMove
)
{
    local vector BuildAccel;
    local byte OldAccelX, OldAccelY, OldAccelZ;

    // compress old move if it exists
    if ( OldMove != None )
    {
        // old move important to replicate redundantly
        BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
        OldAccelX = CompressAccel(BuildAccel.X);
        OldAccelY = CompressAccel(BuildAccel.Y);
        OldAccelZ = CompressAccel(BuildAccel.Z);

        OldServerMove(OldMove.TimeStamp,OldAccelX, OldAccelY, OldAccelZ, OldMove.CompressedFlags());
    }

    if ( PendingMove != None )
    {
        DualServerMove
        (
            PendingMove.TimeStamp,
            PendingMove.Acceleration * 10,
            PendingMove.CompressedFlags(),
            ((PendingMove.Rotation.Yaw & 65535) << 16) + (PendingMove.Rotation.Pitch & 65535),
            NewMove.TimeStamp,
            NewMove.Acceleration * 10,
            ClientLoc,
            NewMove.CompressedFlags(),
            ClientRoll,
            View
        );
    }
    else if ( (NewMove.Acceleration * 10 == vect(0,0,0)) && (NewMove.DoubleClickMove == DCLICK_None) && !NewMove.bDoubleJump )
    {
        ShortServerMove
        (
            NewMove.TimeStamp,
            ClientLoc,
            NewMove.CompressedFlags(),
            ClientRoll,
            View
        );
    }
    else
        ServerMove
    (
        NewMove.TimeStamp,
        NewMove.Acceleration * 10,
        ClientLoc,
            NewMove.CompressedFlags(),
        ClientRoll,
        View
    );
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
unreliable server function ShortServerMove
(
    float TimeStamp,
    vector ClientLoc,
    byte NewFlags,
    byte ClientRoll,
    int View
)
{
    ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewFlags,ClientRoll,View);
}

unreliable client function LongClientAdjustPosition( float TimeStamp, name NewState, EPhysics NewPhysics,
                    float NewLocX, float NewLocY, float NewLocZ,
                    float NewVelX, float NewVelY, float NewVelZ, Actor NewBase,
                    float NewFloorX, float NewFloorY, float NewFloorZ )
{
    local CPPawn P;
    local vector OldPos, NewPos;

    P = CPPawn(Pawn);
    if (P != None)
    {
        OldPos = P.Mesh.GetPosition();
    }

    Super.LongClientAdjustPosition( TimeStamp, NewState, NewPhysics, NewLocX, NewLocY, NewLocZ,
                    NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ );

    // allow changing location of rigid body pawn if feigning death
    if (P != None && P.bFeigningDeath && P.Physics == PHYS_RigidBody)
    {
        // the actor's location (and thus the mesh) were moved in the Super call, so we just need
        // to tell the physics system to do the same
        NewPos = P.Mesh.GetPosition();
        if (VSizeSq(NewPos - OldPos) > REP_RBLOCATION_ERROR_TOLERANCE_SQ)
        {
            P.Mesh.SetRBPosition(P.Mesh.GetPosition());
        }
    }
}

exec function BehindView()
{
    SetBehindView(!bBehindView);
}

function SetBehindView(bool bNewBehindView)
{
    local CPGameReplicationInfo CPGRI;
    CPGRI = CPGameReplicationInfo(WorldInfo.GRI);

    if (CPGRI != none && CPGRI.bAllowBehindView)
    {
        bBehindView = bNewBehindView;
        if ( !bBehindView )
        {
            bFreeCamera = false;
        }

        if (LocalPlayer(Player) == None)
        {
            ClientSetBehindView(bNewBehindView);
        }
        else if (CPPawn(ViewTarget) != None)
        {
            CPPawn(ViewTarget).SetThirdPersonCamera(bNewBehindView);
        }
    }
}


/**
 * Adjusts weapon aiming direction.
 * Gives controller a chance to modify the aiming of the pawn. For example aim error, auto aiming, adhesion, AI help...
 * Requested by weapon prior to firing.
 *
 * @param   W, weapon about to fire
 * @param   StartFireLoc, world location of weapon fire start trace, or projectile spawn loc.
 */

//had to modify this function as the server/client firing were getting out of sync
function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
    local vector    FireDir, HitLocation, HitNormal;
    local actor     BestTarget, HitActor;
    //local bool        bInstantHit;
    local rotator   BaseAimRot;

    //bInstantHit = ( W == None || W.bInstantHit );

    BaseAimRot = (Pawn != None) ? CPPawn(Pawn).GetBaseAimRotation() : Rotation;

    FireDir = vector(BaseAimRot);
    HitActor = Trace(HitLocation, HitNormal, StartFireLoc + W.GetTraceRange() * FireDir, StartFireLoc, true);

    if ( (HitActor != None) && HitActor.bProjTarget )
    {
        BestTarget = HitActor;
    }

    ShotTarget = Pawn(BestTarget);
    return BaseAimRot;
}

exec function ignore( string id )
{
    local string message;

    if(int(id) == CPPlayerReplicationInfo(PlayerReplicationInfo).CPPlayerID)
    {
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "you cant ignore yourself!" );
        return;
    }

    if(CAPS(id) == "ALL")
    {
        //ignore all
        bIgnoreAllPlayers=true;
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "you are now ignoring all players" );
        if(CPHUD(myHUD) != none)
        {
            CPHUD(myHUD).AddCanvasEventMsg( "you are now ignoring all players" );
        }
        return;
    }
    else if(CAPS(id) == "NONE")
    {
        //unignore all
        bIgnoreAllPlayers=false;
        //clear out all manual ignores too
        IgnoredPlayerList.Length = 0;
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "you are now listening to all players" );
        if(CPHUD(myHUD) != none)
        {
            CPHUD(myHUD).AddCanvasEventMsg( "you are now listening to all players" );
        }
        return;
    }

    if (GetPlayerNameFromPRI(int(id)) == "unknown name") //check the player exists.
    {
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText("Player not found");
        return;
    }
    else if (IgnoredPlayerList.Find(int(id)) == INDEX_NONE)
    {
        IgnoredPlayerList.AddItem(int(id));
        message = "you are now ignoring " $ GetPlayerNameFromPRI(int(id));
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( message );
        if(CPHUD(myHUD) != none)
        {
            CPHUD(myHUD).AddCanvasEventMsg(message);
        }
        return;
    }
    else
    {
        //.already being ignored, assume the player wants to unignore them
        IgnoredPlayerList.RemoveItem(int(id));
        message = "you are now listening to " $ GetPlayerNameFromPRI(int(id));
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( message );
        if(CPHUD(myHUD) != none)
        {
            CPHUD(myHUD).AddCanvasEventMsg(message);
        }
        return;
    }
}

exec function unignore(int id)
{
    local string message;

    if (IgnoredPlayerList.Find(id) != INDEX_NONE)
    {
        IgnoredPlayerList.RemoveItem(id);
        message = "you are now listening to " $ GetPlayerNameFromPRI(id);
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( message );
        if(CPHUD(myHUD) != none)
        {
            CPHUD(myHUD).AddCanvasEventMsg(message);
        }
    }
}

function string GetPlayerNameFromPRI(int id)
{
    local CPGameReplicationInfo GRI;
    local int i;

    GRI = CPGameReplicationInfo(WorldInfo.GRI);

    if (GRI != None)
    {
        for (i=0; i < GRI.PRIArray.Length; i++)
        {
            if(CPPlayerReplicationInfo(GRI.PRIArray[i]).CPPlayerID == id)
            {
                return GRI.PRIArray[i].PlayerName;
            }
        }
    }
    return "unknown name";
}

/** Sets ShakeOffset and ShakeRot to the current view shake that should be applied to the camera */
function ViewShake(float DeltaTime)
{
    if (CameraAnimPlayer != None && !CameraAnimPlayer.bFinished)
    {
        // advance the camera anim - the native code will set ShakeOffset/ShakeRot appropriately
        CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
        CameraAnimPlayer.AdvanceAnim(DeltaTime, false);
    }
    else
    {
        ShakeOffset = vect(0,0,0);
        ShakeRot = rot(0,0,0);
    }
}


simulated function ThrowBombOnDeath()
{
    `Log("ThrowBombOnDeath");
    if ((Pawn == None))
        return;

    ServerThrowBombOnDeath();
}

reliable server function ServerThrowBombOnDeath()
{
    local inventory inv;

    if(Pawn != none)
    {
        inv = Pawn.FindInventoryType(class'CPWeap_Bomb',true);

        //`Log("ServerThrowBombOnDeath inv=" @ inv);
        if(CriticalPointGame(WorldInfo.Game) != none)
        {
            CriticalPointGame(WorldInfo.Game).HUDMessage(30);
            if ( inv != None )
            {
                Pawn.TossInventory(inv);
            }
        }
    }
}

reliable client function ClientResetEffectsAndDecals()
{
    local int index;

    if(WorldInfo.MyDecalManager == none)
        return;

    for (index = 0 ; index < WorldInfo.MyDecalManager.ActiveDecals.Length ; index++)
    {
        WorldInfo.MyDecalManager.ActiveDecals[index].LifetimeRemaining = 0;
    }

    for (index = 0 ; index < WorldInfo.MyEmitterPool.ActiveComponents.Length ; index++)
    {
        WorldInfo.MyEmitterPool.ActiveComponents[index].KillParticlesForced();
        WorldInfo.MyEmitterPool.ActiveComponents[index].DeactivateSystem();
    }
}

event PlayerTick(float DeltaTime)
{
    local CPWeaponScoped ScopedWeapon;
    local CPWeaponAttachment CPWA;
    local LocalPlayer LocalPlayer;
    local LinearColor LC;
    local float RatioX, RatioY;
    local CPHUD CHud;

    local CPPawn _Pawn;
    local vector _Location;
    local Rotator _Rotation;

    Super.PlayerTick(DeltaTime);

    CHud = CPHud( myHUD );
    if( CHud == none )
        return;
                
    RatioX = ( CHud.ViewY == 0 ) ? 1.0 : CHud.ViewX / CHud.ViewY;
    RatioY = 1.0;

    _Pawn = CPPawn(Pawn);

    if(_Pawn != none)
        CPWA = _Pawn.CurrentWeaponAttachment;

    if ( _Pawn != None && _Pawn.FlashLight != None )
    {
        GetActorEyesViewPoint( _Location, _Rotation );

        _Pawn.FlashLight.SetLocation(_Location);
        _Pawn.FlashLight.SetRotation(_Rotation);
    }

    //Stop Renegade Hacksound
    if(_Pawn != None && _Pawn.HackZone == None && CPWA != none && CPWA.HackSound != none && CPWA.HackSound.IsPlaying())
    {
        CPWA.HackSound.Stop();
    }

    if ( Pawn != none && Pawn.Weapon != none )
    {
        ScopedWeapon = CPWeaponScoped( Pawn.Weapon );
        if ( ScopedWeapon != none )
            RatioY = ScopedWeapon.ScopeSize;
    }
    else
    {
        if (SpecScopedWeapon != none)
        {
            ScopedWeapon = SpecScopedWeapon;
 
			// Need to set our zoom level here when switching
			// targets since the zoom level is event triggered and
			// we don't get an event when we first switch views.
			if(prevSpecScopedWeapon != ScopedWeapon)
			{
                prevSpecScopedWeapon = SpecScopedWeapon;
				ScopedWeapon.UpdateSpectateZoom();
			}

            if ( ScopedWeapon != none )
                RatioY = ScopedWeapon.ScopeSize;
            
        }
		else
		{
			prevSpecScopedWeapon = None;
		}
    }

    if (SniperPostProcessMaterialInstanceConstant == None)
    {
        if (ScopedWeapon == none)
            return;

        `Log("ScopedWeapon SUCCESS");
        // Get the local player, which stores the post process chain
        LocalPlayer = LocalPlayer(Player);
        if (LocalPlayer != None && LocalPlayer.PlayerPostProcess != None)
        {

            if(LocalPlayer.PlayerPostProcess.FindPostProcessEffect('SniperScope') == none)
                LocalPlayer(Player).InsertPostProcessingChain(ScopedWeapon.SniperScopePostProcess, 0, true); //add the post process only if it has not been added before.

            // Get the post process chain material effect
            SniperPostProcessEffect = MaterialEffect(LocalPlayer.PlayerPostProcess.FindPostProcessEffect('SniperScope'));
            if (SniperPostProcessEffect != None)
            {
                // Create a new material instance constant
                SniperPostProcessMaterialInstanceConstant = new () class'MaterialInstanceConstant';
                if (SniperPostProcessMaterialInstanceConstant != None)
                {
                    // Assign the parent of the material instance constant to the one stored in the material effect
                    SniperPostProcessMaterialInstanceConstant.SetParent(SniperPostProcessEffect.Material);
                    // Set the material effect to use the newly created material instance constant
                    SniperPostProcessEffect.Material = SniperPostProcessMaterialInstanceConstant;

                    // Adjust the scope color
                    LC.R = 0.f;
                    LC.G = 0.f;
                    LC.B = 0.f;
                    LC.A = 1.f;
                    SniperPostProcessMaterialInstanceConstant.SetVectorParameterValue('ScopeColor', LC);
                    SniperPostProcessMaterialInstanceConstant.SetScalarParameterValue('AlphaMaskMin', -0.5f);
                    SniperPostProcessEffect.bShowInGame = false;
                }
            }
        }

        // Adjust the scopes size location
        LC.R = RatioX*RatioY;
        LC.G = RatioY;
        LC.B = 0.f;
        LC.A = 0.f;
        SniperPostProcessMaterialInstanceConstant.SetVectorParameterValue('CenterScale', LC);

        // Adjust the center of the scopes location
        LC.R = -((RatioX*RatioY-1)/2);
        LC.G = -((RatioY-1)/2);
        LC.B = 0.f;
        LC.A = 0.f;
        SniperPostProcessMaterialInstanceConstant.SetVectorParameterValue('CenterLocation', LC);
    }
    
    // If we're a spectator / not actively playing
    if ( Pawn == None && !bIsInGhostCam && CPPawn(ViewTarget) != none && CPPawn(ViewTarget).PlayerReplicationInfo != None)
    {
        // @TODO: Determine if the weapon is scoped
        if (SpecScopedWeapon == None || CPPawn(ViewTarget).Weapon != SpecScopedWeapon || SpecScopedWeapon.CurrentZoom == -1 || CPPawn(ViewTarget).PlayerReplicationInfo.bOutOfLives)
        {
            SpecScopedWeapon = None;
            ToggleScope(false);
        }
    }

	if(Pawn == None && CPPawn(ViewTarget) == none && SpecScopedWeapon != None)
	{
		ResetScopeSettings();
	}
}

simulated function ToggleScope(bool Toggle, optional CPWeaponScoped SpecWeapon)
{
    if (Toggle)
    {
        SpecScopedWeapon = SpecWeapon;
    }
    else
    {
        SpecScopedWeapon = none;
        ResetFOV();
    }

    if (SniperPostProcessEffect != none)
    {
        SniperPostProcessEffect.bShowInGame = Toggle;
    }
}

exec function AddBotsToMERC(int numberToAdd)
{
    ServerAddBotsToMERC(numberToAdd);
}

exec function AddHostages(int numberToAdd)
{
    ServerAddHostages(numberToAdd);
}

exec function AddBotsToSWAT(int numberToAdd)
{
    ServerAddBotsToSWAT(numberToAdd);
}

unreliable server function ServerAddHostages(int numberToAdd)
{
    local CPHostage P;
    local CPGameReplicationInfo TAGRI;
    local int i, intNumberOfHostages;

    TAGRI = CPGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(TAGRI.PRIArray[i].Team != none)
        {
            if(TAGRI.PRIArray[i].Team.TeamIndex == 2)
            {
                // Count how many players are on Hostages
                intNumberOfHostages++;

                // Lets cap it at 5 then return
                if(intNumberOfHostages > 4)
                {
                    return;
                }
            }
        }
    }

    for(i = 0; i < numberToAdd; i++)
    {
        if(i > 4 )
            break;

        P = Spawn(class'CPHostage');
        if(P != none)
        {
            P.PlayerReplicationInfo.Team = TAGRI.Teams[2];
            P.PlayerReplicationInfo.Team.TeamIndex = 2;
            P.PlayerReplicationInfo.PlayerName = CriticalPointGame(WorldInfo.Game).Swat[i];
            P.PlayerReplicationInfo.bBot = true;
            CPPlayerReplicationInfo(P.PlayerReplicationInfo).ClanTag = "ImAHostage";
            CriticalPointGame(WorldInfo.Game).RestartPlayer(P);
        }
    }
}

unreliable server function ServerAddBotsToSWAT(int numberToAdd)
{
    local CPBot P;
    local CPGameReplicationInfo TAGRI;
    local int i, intNumberOfSwat;

    TAGRI = CPGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(TAGRI.PRIArray[i].Team != none)
        {
            if(TAGRI.PRIArray[i].Team.TeamIndex == 1)
            {
                // Count how many players are on SWAT
                intNumberOfSwat++;

                // Lets cap it at 8 then return
                if(intNumberOfSwat > 7)
                {
                    return;
                }
            }
        }
    }

    for(i = 0 ; i < numberToAdd ; i++)
    {
        if(i > 7 )
            break;

        P = Spawn(class'CPBot');
        if(P != none)
        {
            P.PlayerReplicationInfo.Team = TAGRI.Teams[1];
            P.PlayerReplicationInfo.Team.TeamIndex = 1;
            P.PlayerReplicationInfo.PlayerName = CriticalPointGame(WorldInfo.Game).Swat[i];
            P.PlayerReplicationInfo.bBot = true;
            CPPlayerReplicationInfo(P.PlayerReplicationInfo).CPPlayerID=CriticalPointGame(WorldInfo.Game).GetCPPlayerID();
            P.PlayerReplicationInfo.PlayerID=CPPlayerReplicationInfo(P.PlayerReplicationInfo).CPPlayerID;
            if(Rand(2) == 0)
                CPPlayerReplicationInfo(P.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_SWAT_FemaleOne';
            else
                CPPlayerReplicationInfo(P.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_SWAT_MaleOne';
            CPPlayerReplicationInfo(P.PlayerReplicationInfo).ClanTag = "ImABot";
            CriticalPointGame(WorldInfo.Game).RestartPlayer(P);
            CriticalPointGame(WorldInfo.Game).NumBots++;
        }
    }
}

unreliable server function ServerAddBotsToMERC(int numberToAdd)
{
    local CPBot P;
    local CPGameReplicationInfo TAGRI;
    local int i, intNumberOfMerc;

    TAGRI = CPGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        if(TAGRI.PRIArray[i].Team != None)
        {
            if(TAGRI.PRIArray[i].Team.TeamIndex == 0)
            {
                // Count how many players are on MERC
                intNumberOfMerc++;

                // Lets cap it at 8 then return
                if(intNumberOfMerc > 7)
                {
                    return;
                }
            }
        }
    }

    for(i = 0; i < numberToAdd; i++)
    {
        if(i > 7 )
            break;

        P = Spawn(class'CPBot');
        if(P != none)
        {
            P.PlayerReplicationInfo.Team = TAGRI.Teams[0];
            P.PlayerReplicationInfo.Team.TeamIndex = 0;
            P.PlayerReplicationInfo.PlayerName = CriticalPointGame(WorldInfo.Game).Merc[i];
            P.PlayerReplicationInfo.bBot = true;
            CPPlayerReplicationInfo(P.PlayerReplicationInfo).CPPlayerID=CriticalPointGame(WorldInfo.Game).GetCPPlayerID();

            if(Rand(2) == 0)
                CPPlayerReplicationInfo(P.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_MERC_FemaleOne';
            else
                CPPlayerReplicationInfo(P.PlayerReplicationInfo).CharClassInfo = class'CriticalPoint.CP_MERC_MaleOne';
            P.PlayerReplicationInfo.PlayerID=CPPlayerReplicationInfo(P.PlayerReplicationInfo).CPPlayerID;
            CPPlayerReplicationInfo(P.PlayerReplicationInfo).ClanTag = "ImABot";
            CriticalPointGame(WorldInfo.Game).RestartPlayer(P);
            CriticalPointGame(WorldInfo.Game).NumBots++;
        }
    }
}

function HandleWalking()
{
    if ( Pawn != None )
    {
        if (bRun == 0)
            Pawn.bCanWalkOffLedges=true;
        else
            Pawn.bCanWalkOffLedges=false;

        Pawn.SetWalking( bRun != 0 );
    }
}

exec function SwitchWeapon(byte T)
{
    if (CPPawn(Pawn) != None)
        CPPawn(Pawn).SwitchWeapon(t);
}

reliable client function DoFlash(float BlindTime, float Scale, vector Loc)
{
    `log("-----Playing Flash!!!-----");
    if(CPHUD(myHUD) != none)
        CPHUD(myHUD).NotifyFlashBang(BlindTime, Scale, Loc);

    if (CPPawn(Pawn) != None)
        CPPawn(Pawn).NotifyFlashBang(BlindTime, Scale, Loc);
}

reliable client function StopFlash(optional bool bCutAudioCue = true)
{
    if(CPHUD(myHUD) != none)
        CPHUD(myHUD).StopFlashBangHUDEffect();
    if(!bCutAudioCue)
    {
        bDontKillFlashAudioCue=true;
    }
    if(!bDontKillFlashAudioCue)
    {
        if(CPPawn(Pawn) != None)
        {
            CPPawn(Pawn).StopFlashBangAudioCue();
        }
    }
}

exec function ToggleFlashlight()
{
    if (CPPawn(Pawn) != None)
        CPPawn(Pawn).Toggle_Flashlight();
}

exec function GiveMoney(optional int Amount)
{
    local Pawn P;

    if (PlayerReplicationInfo != none && (PlayerReplicationInfo.bAdmin || WorldInfo.NetMode == NM_Standalone))
    {
        foreach WorldInfo.AllActors(class'Pawn', P)
        {
            if (P.PlayerReplicationInfo != none)
                ServerGiveMoney(CPPlayerReplicationInfo(P.PlayerReplicationInfo), (Amount > 0 ? Amount : 5000));
        }
    }
}

exec function SetMoney(optional int Amount)
{
    local Pawn P;

    if (PlayerReplicationInfo != none && (PlayerReplicationInfo.bAdmin || WorldInfo.NetMode == NM_Standalone))
    {
        foreach WorldInfo.AllActors(class'Pawn', P)
        {
            if (P.PlayerReplicationInfo != none)
                ServerSetMoney(CPPlayerReplicationInfo(P.PlayerReplicationInfo), abs(Amount));
        }
    }
}

exec function LogBuyMenu()
{
    if(CPHUD(myHUD).BuyMenuMovie == None)
    {
        `Log("open buymenu if you want to query it");
        return;
    }
    else
    {
        `Log(CPHUD(myHUD).BuyMenuMovie.ToString());
    }
}

exec function DEVGetWeaponState()
{
    if(Pawn != None) 
    {
        `Log("@@ "$CPPawn(Pawn).GetWeaponStateString(CPPawn(Pawn).WeaponState));
    }
    else
    {
       `Log("@@ no pawn or weapon available");
    }
}

exec function LogInventoryAll()
{
    if(WorldInfo.NetMode == NM_Standalone) 
    {
        `Log(CPInventoryManager(Pawn.InvManager).ToString());
    }
    else
    {
        CPInventoryManager(Pawn.InvManager).ServerToString();
    }
}

exec function debugGiveMoney()
{
    if (Pawn.PlayerReplicationInfo != None)
    {
        ServerGiveMoney(CPPlayerReplicationInfo(Pawn.PlayerReplicationInfo), 50000);
    }
}

function resetWalkAndDuck()
{
    local CPPlayerInput CPPI;
    CPPI = CPPlayerInput(PlayerInput);

    CPPI.StopWalk();
    CPPI.UnDuck();
    CPPI.bHoldDuck=false;
}

reliable server function ServerGiveMoney(CPPlayerReplicationInfo PRI, int Amount)
{
    PRI.ModifyMoney(Amount);
}

reliable server function ServerSetMoney(CPPlayerReplicationInfo PRI, int Amount)
{
    PRI.SetMoney(Amount);
}

exec function SetGoreLevel(int Level)
{
    local CPSaveManager TASave;

    if(Level < 0)
        Level = 0;
    else if (Level > 2)
        Level = 2;

    if(PlayerReplicationInfo != none && (PlayerReplicationInfo.bAdmin || WorldInfo.NetMode == NM_Standalone))
    {
        TASave=new(none,"") class'CPSaveManager';
        TASave.SetItem("GoreLevel", Level);
    }
}

function Restart(bool bVehicleTransition)
{
    //if(Pawn != None)  //not sure if this line was neccessary
	Super.Restart(bVehicleTransition);
}

simulated unreliable client function LogServerMessage(string Message)
{
    `log(Message);
}

//server reliable function RetryAuth(string hash)
//{
//    `Log("Server should RETRY AUTH now.",,'CPIGame');
//    CPPlayerReplicationInfo(self.PlayerReplicationInfo).hash = hash;
//    CriticalPointGame(WorldInfo.Game).CV.Validate(string(PlayerReplicationInfo.UniqueId.Uid.A) $ string(PlayerReplicationInfo.UniqueId.Uid.B),CPPlayerReplicationInfo(self.PlayerReplicationInfo).hash, self);
//}

//client unreliable function ShowLoginDialog()
//{
//    `Log("Server asked you to show login dialog.");
//    if(CPHUD(myHUD) != none)
//        CPHUD(myHUD).ShowLoginMenu();
//}

client unreliable function ShowWelcomeDialog()
{
    //`Log("Server asked you to show welcome dialog.");
    if(CPHUD(myHUD) != none)
        CPHUD(myHUD).ShowWelcomeMenu();
}


exec function SetHitDirectional(int Level)
{
    local CPSaveManager TASave;

    if(Level < 0)
        Level = 0;
    else if (Level > 2)
        Level = 2;

    TASave=new(none,"") class'CPSaveManager';
    TASave.SetItem("HitDirectional", Level);

    if(Level == 0)
        `log("HitDirection settings are set to 'off'");
    else if(Level == 1)
        `log("HitDirection settings are set to 'simple'");
    else if(Level == 2)
        `log("HitDirection settings are set to 'splatter'");
}



/**
 * Executable command fired from DefaultInput.ini
 *
*/
exec function Talk()
{
    local CPSaveManager CPSaveManager;
	
    CPSaveManager = new () class'CPSaveManager';
    if(CPSaveManager != none)
    {
        if(!bool(CPSaveManager.GetItem("ShowChat")))
        {
            return;
        }
    }

    CPHUD = CPHUD(myHUD);
    if(CPHUD != none)
    {
        if(CPHUD.HudMovie != none)
        {
            if(PlayerReplicationInfo.bAdmin)
            {
                `log("--- Toggle Admin chat ------- ");
                CPHUD.HudMovie.ToggleChat("Admin");
            }
            else if(PlayerReplicationInfo.bOutOfLives)
            {
                `log("--- Toggle DeadSay chat ------- ");
                CPHUD.HudMovie.ToggleChat("DeadSay");
            }
            else if(PlayerReplicationInfo.bOnlySpectator)
            {
                `log("--- Toggle Spectator chat ------- ");
                CPHUD.HudMovie.ToggleChat("Spectator");
            }
            else
            {
                `log("--- Toggle Say chat ------- ");
                CPHUD.HudMovie.ToggleChat("Say");
            }
        }
    }
}


/**
 * Executable command fired from DefaultInput.ini
 *
*/
exec function TeamTalk()
{
    local CPSaveManager CPSaveManager;
	
    CPSaveManager = new () class'CPSaveManager';
    if(CPSaveManager != none)
    {
        if(!bool(CPSaveManager.GetItem("ShowChat")))
        {
            return;
        }
    }

    CPHUD = CPHUD(myHUD);
    if(CPHUD != none)
    {
        if(CPHUD.HudMovie != none)
        {
            // If spectator, return out of team chat
            if(PlayerReplicationInfo.bOnlySpectator)
            {
                return;
            }

            if(PlayerReplicationInfo.bOutOfLives)
            {
                `log("--- Toggle Dead Team Say chat ------- ");
                CPHUD.HudMovie.ToggleChat("DeadTeamSay");
            }
            else
            {
                `log("--- Toggle Team Say chat ------- ");
                CPHUD.HudMovie.ToggleChat("TeamSay");
            }
        }
    }
}



/*
 *  Custom chat implementation below
*/
/*
*/
exec function SendTextToServer(CPPlayerController PC, String TextToSend, string MessageType, optional int TeamIndex)
{
    ServerReceiveText(PC, TextToSend, MessageType, TeamIndex);
}


/*
*/
reliable server function ServerReceiveText(CPPlayerController PC, String ReceivedText, string MessageType, optional int TeamIndex)
{
    if(CriticalPointGame(WorldInfo.Game) == none)
        return;

    if(TeamIndex > -1)
        CriticalPointGame(WorldInfo.Game).SupplyTeamIndex(TeamIndex);

    if(MessageType == "Say")
        CriticalPointGame(WorldInfo.Game).Broadcast(PC, ReceivedText, 'Say');
    else if(MessageType == "DeadSay")
        CriticalPointGame(WorldInfo.Game).Broadcast(PC, ReceivedText, 'DeadSay');
    else if(MessageType == "TeamSay")
        CriticalPointGame(WorldInfo.Game).BroadcastTeam(PC, ReceivedText, 'TeamSay');
    else if(MessageType == "DeadTeamSay")
        CriticalPointGame(WorldInfo.Game).BroadcastTeam(PC, ReceivedText, 'DeadTeamSay');
    else if(MessageType == "Admin")
        CriticalPointGame(WorldInfo.Game).Broadcast(PC, ReceivedText, 'Admin');
    else if(MessageType == "Spectator")
        CriticalPointGame(WorldInfo.Game).Broadcast(PC, ReceivedText, 'Spectator');
	else if(MessageType == "Whisper")
        CriticalPointGame(WorldInfo.Game).Broadcast(PC, ReceivedText, 'Whisper');
    else if(MessageType == "DeadWhisper")
        CriticalPointGame(WorldInfo.Game).Broadcast(PC, ReceivedText, 'DeadWhisper');
}


/*
*/
reliable client function ReceiveBroadcast(String ChatPlayerName, String ReceivedText, name Type, optional int TeamIndex)
{
    if(CPHud(myHUD) != none)
    {
        if(CPHud(myHUD).HudMovie != none)
        {
            if(Type == 'Say')
            {
                CPHud(myHUD).HudMovie.UpdateChatLog(ChatPlayerName $ ": ", ReceivedText, TeamIndex);
            }
            else if(Type == 'DeadSay')
            {
                CPHud(myHUD).HudMovie.UpdateDeadChatLog(ChatPlayerName $ " (DEAD): ", ReceivedText, TeamIndex);
            }
            else if(Type == 'TeamSay')
            {
            	if(TeamIndex == 1)
            	{
					CPHud(myHUD).HudMovie.UpdateSWATChatLog(ChatPlayerName $ " (TEAM): " , ReceivedText, TeamIndex);
				}
				else if(TeamIndex == 0)
            	{
					CPHud(myHUD).HudMovie.UpdateMERCChatLog(ChatPlayerName $ " (TEAM): " , ReceivedText, TeamIndex);
				}
            }
            else if(Type == 'DeadTeamSay')
            {
            	if(TeamIndex == 1)
            	{
					CPHud(myHUD).HudMovie.UpdateDEADSWATChatLog(ChatPlayerName $ " (DEAD): ", ReceivedText, TeamIndex);
				}
				else if(TeamIndex == 0)
            	{
					CPHud(myHUD).HudMovie.UpdateDEADMERCChatLog(ChatPlayerName $ " (DEAD): ", ReceivedText, TeamIndex);
				}
            }
            else if(Type == 'Admin')
            {
                CPHud(myHUD).HudMovie.UpdateChatLog(ChatPlayerName $ " (Admin): ", ReceivedText, TeamIndex);
            }
            else if(Type == 'Spectator')
            {
                CPHud(myHUD).HudMovie.UpdateSpectatorChatLog(ChatPlayerName $ " (Spec): ", ReceivedText);
            }
            else if(Type == 'Whisper')
            {
            	CPHud(myHUD).HudMovie.UpdateWhisperChatLog(ChatPlayerName $ " (Whisper): ", ReceivedText);
            }
			else if(Type == 'DeadWhisper')
            {
            	CPHud(myHUD).HudMovie.UpdateDEADWhisperChatLog(ChatPlayerName $ " (Whisper): ", ReceivedText);
            }
        }
    }
}

simulated function ClearSpectatorWeapons()
{
    local int i;

    for (i = 0 ; i < 6 ; i ++)
    {
        CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorWeapons[i] = none;
    }
    ServerClearSpectatorWeapons();
}

unreliable server function ServerClearSpectatorWeapons()
{
    local int i;

    for (i = 0 ; i < 6 ; i ++)
    {
        CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorWeapons[i] = none;
    }
}

simulated function SetSpectatorWeapons(CPWeapon value, int index)
{
    //`Log("SetSpectatorWeapons index " @ index @ " is " @ value);
    CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorWeapons[index] = value;
    ServerSetSpectatorWeapons(value, index);
}

unreliable server function ServerSetSpectatorWeapons(CPWeapon value, int index)
{
	if(CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorWeapons[index] != value)
	{
		CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorWeapons[index] = value;
	}
}

simulated function ClearSpectatorWeaponsOrdered()
{
    local int i;

    for (i = 0 ; i < 6 ; i ++)
    {
        CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorOrderedWeapons[i] = none;
    }
    ServerClearSpectatorWeaponsOrdered();
}

unreliable server function ServerClearSpectatorWeaponsOrdered()
{
    local int i;

    for (i = 0 ; i < 6 ; i ++)
    {
        CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorOrderedWeapons[i] = none;
    }
}


simulated function SetSpectatorWeaponsOrdered(CPWeapon value, int index)
{
	if(CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorOrderedWeapons[index] != value)
	{
		CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorOrderedWeapons[index] = value;
		ServerSetSpectatorWeaponsOrdered(value, index);
	}
}

unreliable server function ServerSetSpectatorWeaponsOrdered(CPWeapon value, int index)
{
	//if(CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorOrderedWeapons[index] != value)
	//{
		CPPlayerReplicationInfo(PlayerReplicationInfo).SpectatorOrderedWeapons[index] = value;
	//}
}

// @Wail - SetPendingCharacterClass essentially handles any behavior where model switching is required (e.g. player changed model in UI, changed teams using UI/console commands). Sometimes because a RoundIsActive we don't want to change models right away (it'll leave behind the incorrect dead body) therefore we set the PendingCharacterClass which is utilized in CrticalPointGame when we spawn our next pawn.
simulated function SetPendingCharacterClass(class<CPFamilyInfo> PendingCharClass)
{
    //`log(">> SetPendingCharacterClass :"@PendingCharClass@CPPlayerReplicationInfo(PlayerReplicationInfo).PendingCharClass @ "RoundIsActive?"@CPGameReplicationInfo(WorldInfo.GRI).RoundIsActive());
    if (CPGameReplicationInfo(WorldInfo.GRI).RoundIsActive())
    {
        CPPlayerReplicationInfo(PlayerReplicationInfo).PendingCharClass = PendingCharClass;
        ServerSetPendingCharacterClass(PendingCharClass);
    }
    else
    {
        SetCharacterClass(PendingCharClass);
    }
}

reliable server function ServerSetPendingCharacterClass(class<CPFamilyInfo> PendingCharClass)
{
    // don't even bother checking whether the round is active here. SetPendingCharacterClass will never call us unless RoundIsActive() is true
    CPPlayerReplicationInfo(PlayerReplicationInfo).PendingCharClass = PendingCharClass;
}

reliable server function ServerPurgePoll()
{
	CriticalPointGame(WorldInfo.Game).PurgePoll(self);
}

// Might not work on consoles
reliable client function ClientNotifyPollPurged(bool Success, optional string message="")
{
	LocalPlayer(Player).ViewportClient.ViewportConsole.OutputTextLine(Success ? "Poll purged" : message);
}

exec function PurgePoll()
{
	ServerPurgePoll();
}

event AdjustHUDRenderSize(out int X, out int Y, out int SizeX, out int SizeY, const int FullScreenSizeX, const int FullScreenSizeY)
{
	if(myHUD == none)
		return;

	super.AdjustHUDRenderSize(X,Y,SizeX,SizeY,FullScreenSizeX,FullScreenSizeY);
}


function OnInviteJoinComplete(name SessionName,bool bWasSuccessful)
{
	local string URL;

	if (bWasSuccessful)
	{
		if (OnlineSub != None && OnlineSub.GameInterface != None)
		{
			// Get the platform specific information
			if (OnlineSub.GameInterface.GetResolvedConnectString(SessionName,URL))
			{

				//pass this ip to console...
				CPConsole(CPGameViewportClient(LocalPlayer(Player).ViewportClient).ViewportConsole).ServerIP = URL;

				URL $= "?bIsFromInvite";

				// allow game to override
				URL = ModifyClientURL(URL);

				`Log("Resulting url is ("$URL$")");
				// Open a network connection to it
				ClientTravel(URL, TRAVEL_Absolute);
			}
		}
	}
	else
	{
		// Do some error handling
		NotifyInviteFailed();
	}
	ClearInviteDelegates();
}

reliable server function ServerThrowWeapon()
{
	if(Pawn != none)
	{
		if ( Pawn.CanThrowWeapon() )
		{
			Pawn.ThrowActiveWeapon();
		}
	}
}

unreliable client function MessageToConsole(string strMessage)
{
	if (LocalPlayer(Player) != None && LocalPlayer(Player).ViewportClient != none)
    {
		if(LocalPlayer(Player).ViewportClient.ViewportConsole != none)
		{
			LocalPlayer(Player).ViewportClient.ViewportConsole.OutputText( strMessage );
		}
    }
}

exec function DEVSetBodyArmorDamagePercent(float Armor)
{
   local CPArmor_Body BodyArmor;
   local CPArmor_Head HeadArmor;
   local CPArmor_Leg LegArmor;
   local CPInventoryManager InvManager;

    if (WorldInfo.NetMode == NM_Standalone)
    {
        InvManager = CPInventoryManager(CPPawn(Pawn).InvManager);

		if(Armor > 100)
			Armor = 100;
		if(Armor < 0)
			Armor = 0;

		HeadArmor = CPArmor_Head(InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Head', false ));
		if (HeadArmor != None)
		{
			HeadArmor.Health = Armor;
		}

		BodyArmor = CPArmor_Body(InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Body', false ));
		if (BodyArmor != None)
		{
			BodyArmor.Health = Armor;
		}

		LegArmor = CPArmor_Leg(InvManager.FindInventoryType( class'CriticalPoint.CPArmor_Leg', false ));
		if (LegArmor != None)
		{
			LegArmor.Health = Armor;
		}
    }
	else
	{
		`Log("Must offline to use this!");
	}
}

DefaultProperties
{   
    DesiredFOV=90.000000
    DefaultFOV=90.000000
    FOVAngle=90.000

    CameraClass=none
    DamageCameraAnim=CameraAnim'TEMP_Cleanup.DamageViewShake'
    MatineeCameraClass=class'Engine.Camera'
    bForceBehindview=true
    MaxTimeoutTime = 10;
    //Completely customised playerinput. we bypass other player inputs completely.
    InputClass=class'CriticalPoint.CPPlayerInput'

    // how accurate the player needs to be when swapping weapons
    WeaponSwapAimAccuracyPct=0.18       // 32,4 degrees from the weapon pickups center
    ServersKnownInventory(0)=(InventoryClass=class'CriticalPoint.CPArmor_Head',InventoryString="CriticalPoint.CPArmor_Head")
    ServersKnownInventory(1)=(InventoryClass=class'CriticalPoint.CPArmor_Leg',InventoryString="CriticalPoint.CPArmor_Leg")
    ServersKnownInventory(2)=(InventoryClass=class'CriticalPoint.CPArmor_Body',InventoryString="CriticalPoint.CPArmor_Body")

    ServersKnownWeapons(0)=(WeaponClass=class'CriticalPoint.CPWeap_KaBar',WeaponString="CriticalPoint.CPWeap_KaBar")
    ServersKnownWeapons(1)=(WeaponClass=class'CriticalPoint.CPWeap_Hatchet',WeaponString="CriticalPoint.CPWeap_Hatchet")
    ServersKnownWeapons(2)=(WeaponClass=class'CriticalPoint.CPWeap_Glock',WeaponString="CriticalPoint.CPWeap_Glock")
    ServersKnownWeapons(3)=(WeaponClass=class'CriticalPoint.CPWeap_Grenade',WeaponString="CriticalPoint.CPWeap_Grenade")

    ServersKnownWeapons(4)=(WeaponClass=class'CriticalPoint.CPWeap_UMP45',WeaponString="CriticalPoint.CPWeap_UMP45")
    ServersKnownWeapons(5)=(WeaponClass=class'CriticalPoint.CPWeap_MP5A3',WeaponString="CriticalPoint.CPWeap_MP5A3")
    ServersKnownWeapons(6)=(WeaponClass=class'CriticalPoint.CPWeap_Remington870P',WeaponString="CriticalPoint.CPWeap_Remington870P")
    ServersKnownWeapons(7)=(WeaponClass=class'CriticalPoint.CPWeap_Mossberg590',WeaponString="CriticalPoint.CPWeap_Mossberg590")
    ServersKnownWeapons(8)=(WeaponClass=class'CriticalPoint.CPWeap_SIG552',WeaponString="CriticalPoint.CPWeap_SIG552")
    ServersKnownWeapons(9)=(WeaponClass=class'CriticalPoint.CPWeap_SpringfieldXD45',WeaponString="CriticalPoint.CPWeap_SpringfieldXD45")
    ServersKnownWeapons(10)=(WeaponClass=class'CriticalPoint.CPWeap_KarSR25',WeaponString="CriticalPoint.CPWeap_KarSR25")

    ServersKnownWeapons(11)=(WeaponClass=class'CriticalPoint.CPWeap_HE',WeaponString="CriticalPoint.CPWeap_HE")
    ServersKnownWeapons(12)=(WeaponClass=class'CriticalPoint.CPWeap_FlashBang',WeaponString="CriticalPoint.CPWeap_FlashBang")

    ServersKnownWeapons(13)=(WeaponClass=class'CriticalPoint.CPWeap_RagingBull',WeaponString="CriticalPoint.CPWeap_RagingBull")
    ServersKnownWeapons(14)=(WeaponClass=class'CriticalPoint.CPWeap_ScarH',WeaponString="CriticalPoint.CPWeap_ScarH")
    ServersKnownWeapons(15)=(WeaponClass=class'CriticalPoint.CPWeap_DE',WeaponString="CriticalPoint.CPWeap_DE")
    ServersKnownWeapons(16)=(WeaponClass=class'CriticalPoint.CPWeap_G3KA4',WeaponString="CriticalPoint.CPWeap_G3KA4")
    ServersKnownWeapons(17)=(WeaponClass=class'CriticalPoint.CPWeap_MAC10',WeaponString="CriticalPoint.CPWeap_MAC10")
    ServersKnownWeapons(18)=(WeaponClass=class'CriticalPoint.CPWeap_HK121',WeaponString="CriticalPoint.CPWeap_HK121")
    ServersKnownWeapons(19)=(WeaponClass=class'CriticalPoint.CPWeap_AK47',WeaponString="CriticalPoint.CPWeap_AK47")

    Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform7
        Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.200)
    End Object
    CameraShakeShortWaveForm=ForceFeedbackWaveform7

    Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform8
        Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.400)
    End Object
    CameraShakeLongWaveForm=ForceFeedbackWaveform8

    LastTeamChangeTime=-1000.0
    IdentifiedTeam=255

    OldMessageTime=-100.0

    bIsPlayer=true
    bDontKillFlashAudioCue=false

    HitTargetSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_Clip_Cue'
}
