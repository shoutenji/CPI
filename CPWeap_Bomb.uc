class CPWeap_Bomb extends CPWeapon;

var const float     DefuseInterval;
var float           DefuseTimestamp, PlantTimestamp;

//var   AudioComponent              ArmingAudioComponent;
//var   AudioComponent              DefusingAudioComponent;

var SoundCue                    SoundTickCue;
var float                       PlayNextTickSound;
var float                       TickBuffer;

var SoundCue ArmingSound;
var SoundCue DiffusingSound;

var vector SoundLocation;

var CPGameReplicationInfo     GRI;

replication
{
    if(bNetDirty)
        SoundLocation;
}

//override any options to set weapons into different hands
simulated function EWeaponHand GetHand()
{
    return HAND_Right;
}

/**
 * A function to check whether the bomb can
 * be planted by the current instigator.
 * @return True if the bomb can be planted.
 * @warning Used on both client and server.
 */
simulated function bool IsPlantable( byte FireModeNum )
{
    local CPGameReplicationInfo     _GRI;
    local CPPawn                    _Pawn;
    local Rotator                   _Rotation;

    if ( FireModeNum != 0 || PlantTimestamp != 0.0 || bEquippingWeapon || bPuttingDownWeapon )
        return false;

    _Pawn = CPPawn( Instigator );
    _GRI = CPGameReplicationInfo( WorldInfo.GRI );
    if ( _GRI != none && !_GRI.bCanPlayersMove || _Pawn == none || !_Pawn.bIsCrouched || _Pawn.GetTeamNum() != TTI_Mercenaries || _Pawn.BombZone == none )
        return false;

    _Rotation = _Pawn.GetBaseAimRotation();
    if ( _Rotation.Pitch > -8192 )
        return false;

    return true;
}

simulated function InstantFire();

simulated function StartFire( byte FireModeNum )
{
    if ( IsPlantable( FireModeNum ) )
    {
        if ( Role < Role_Authority )
            ServerStartFire( FireModeNum );

        super.StartFire( FireModeNum );
    }
}

reliable server function ServerStartFire( byte FireModeNum )
{
    if ( IsPlantable( FireModeNum ) )
        super.ServerStartFire( FireModeNum );
}

/**
 * Checks whether the bomb is currently being defused by a player.
 * @return A boolean, true or false
 */
simulated function bool IsDefusing()
{
    return DefuseTimestamp != 0.0;
}

/**
 * Checks whether the bomb has been successfully defused.
 * @return A boolean, true or false
 */
simulated function bool IsDefused()
{
    return DefuseTimestamp != 0.0 && WorldInfo.TimeSeconds >= DefuseTimestamp;
}

/**
 * Checks whether the bomb is currently being planted by a player.
 * @return A boolean, true or false
 */
simulated function bool IsPlanting()
{
    return PlantTimestamp != 0.0;
}

/**
 * Checks whether the bomb has been successfully planted.
 * @return A boolean, true or false
 */
simulated function bool IsPlanted()
{
	if (GRI != none){
		if (GRI.bRoundIsOver == true){
			StopFire(0);
		}
	}	

    return PlantTimestamp != 0.0 && WorldInfo.TimeSeconds >= PlantTimestamp;
}

/**
 * Gets the planting percentage
 * @return float 0.0-1.0
 */
simulated function float GetPlantPercent()
{
    local float     _FireInterval;


    _FireInterval = GetFireInterval( 0 );
    return IsPlanting() ? FClamp( ( _FireInterval - ( PlantTimestamp - WorldInfo.TimeSeconds ) ) / _FireInterval, 0.0, 1.0 ) : 0.0;
}

/**
 * Gets the defusing percentage
 * @return float 0.0-1.0
 */
simulated function float GetDefusePercent()
{
    local float     _Interval;


    _Interval = class'CPWeap_Bomb'.default.DefuseInterval;
    return IsDefusing() ? FClamp( ( _Interval - ( DefuseTimestamp - WorldInfo.TimeSeconds ) ) / _Interval, 0.0, 1.0 ) : 0.0;
}




simulated state Active
{
    simulated event BeginState( name PreviousStateName )
    {
        if ( Instigator != none && Instigator.GetTeamNum() == TTI_SpecialForces )
        {
            SetCurrentFireMode( 0 );
            GotoState( 'Defusing' );
            DefuseTimestamp = WorldInfo.TimeSeconds + class'CPWeap_Bomb'.default.DefuseInterval;
            DefuseTimestamp = ( DefuseTimestamp == 0.0 ) ? 0.0001 : DefuseTimestamp;
        }
        else
        {
            if(PreviousStateName == 'Planting')
            	bWeaponPutDown=true;	
            super.BeginState( PreviousStateName );
        }
    }
}

simulated state Inactive
{
    simulated event BeginState( name PreviousStateName )
    {
        local CPPawn    _Pawn;


        _Pawn = CPPawn( Instigator );
        if ( _Pawn != none && _Pawn.GetTeamNum() == TTI_SpecialForces )
        {
            switch ( PreviousStateName )
            {
            default:
                _Pawn.bIsUsingObjective = false;
                break;
            }
        }

        super.BeginState( PreviousStateName );
    }
}


simulated function EndFire(byte FireModeNum)
{
	// Clear the firing flag for this mode
	ClearPendingFire(FireModeNum);
	if(HasAnyAmmo()) 
	 GotoState( 'Active' );
}


simulated state Planting extends WeaponFiring
{
    simulated function StartFire( byte FireModeNum );

    simulated function StopFire( byte FireModeNum )
    {
        if ( FireModeNum != 0 )
            return;

		PlantTimestamp = 0.0;
        super.StopFire( FireModeNum );
    }

    reliable server function ServerStopFire( byte FireModeNum )
    {
        if ( FireModeNum != 0 )
            return;

		PlantTimestamp = 0.0;

        super.ServerStopFire( FireModeNum );
    }

    simulated event BeginState( name PreviousStateName )
    {
        local CPPawn    _Pawn;

		GRI = CPGameReplicationInfo( WorldInfo.GRI );

		if (GRI.bRoundIsOver == true)
			return;

        PlantTimestamp = WorldInfo.TimeSeconds + GetFireInterval( CurrentFireMode );
        PlantTimestamp = ( PlantTimestamp == 0.0 ) ? -0.0001 : PlantTimestamp; // Just to ensure PlantTimestamp != 0.0 when planting

        _Pawn = CPPawn( Instigator );
        if ( _Pawn != none )
        {
            _Pawn.bIsUsingObjective = true;
            _Pawn.SetWeaponAmbientSound(ArmingSound);
        }

        super.BeginState( PreviousStateName );
    }

    simulated event EndState( name NextStateName )
    {
        local CPGameReplicationInfo     _GRI;
        local CPPawn                    _Pawn;
        local CPPlayerReplicationInfo   _PRI;

        _Pawn = CPPawn( Instigator );
        if ( _Pawn != none && _Pawn.Health >= 0){
            _Pawn.bIsUsingObjective = false;
            _PRI = CPPlayerReplicationInfo(_Pawn.PlayerReplicationInfo);
            _Pawn.SetWeaponAmbientSound(none);
        }

            if (_Pawn.Health <= 0) 
			{
				PlantTimestamp = 0.0;
			}


			if (PlantTimestamp != 0.0 )
			{
				if (_Pawn.Health > 0){
				NextStateName = 'None';

				SoundLocation = Instigator.Location;

				_GRI = CPGameReplicationInfo( WorldInfo.GRI );
				if ( _GRI != none )
					_GRI.bBombPlanted = true;

				if ( _PRI != none )
					_PRI.bPlantedBomb = true;

				SetHidden(True); //fix when weapons float about...

				SetTimer(TickBuffer, false, 'ShouldPlayTickSound');
				SetTimerLog(TickBuffer,false,'ShouldPlayTickSound');
			}

            BeginThrowWeapon();
            if ( Role < ROLE_Authority )
                ServerStartThrowWeapon();
			GotoState( 'Inactive' ); //TOP-Proto fix for server not setting the inactive state properly when bomb is dropped due to the weapon no longer being in the pawns inventory.
        }

        super.EndState( NextStateName );
    }
}

simulated state Defusing extends WeaponFiring
{
    simulated function HandleFinishedFiring();

    simulated event Tick( float DeltaTime )
    {
        local CPPawn    _Pawn;

        _Pawn = CPPawn( Instigator );

		if(_Pawn == none)
			return;

		if(_Pawn.Weapon == none)
			return;

        if ( Role == ROLE_Authority && IsDefused() )
        {
            GotoState( 'Inactive' );
            return;
        }


        if ( _Pawn != none && !_Pawn.bIsUseKeyDown )
        {
            DefuseTimestamp = 0.0;
            GotoState( 'Active' );
        }
    }

    simulated event BeginState( name PreviousStateName )
    {
        local CriticalPointGame         _Game;
        local CPGameReplicationInfo     _GRI;
        local CPPawn    _Pawn;


        if ( Role == ROLE_Authority )
        {
            _Game = CriticalPointGame( WorldInfo.Game );
            if ( _Game != none )
                _Game.AnnounceBombBeingDefused();
        }

        if ( Role == ROLE_SimulatedProxy || Role == ROLE_Authority )
        {
            PlayFireEffects( CurrentFireMode );
        }

        _Pawn = CPPawn( Instigator );
        if(_Pawn != none){
            _Pawn.SetWeaponAmbientSound(DiffusingSound);
        }

        _GRI = CPGameReplicationInfo( WorldInfo.GRI );
        if ( _GRI != none )
            _GRI.bBombBeingDiffused = true;

        SetInstigatorWeaponState( EWS_Firing );
    }

    simulated event EndState( name NextStateName )
    {
        local CriticalPointGame         _Game;
        local CPGameReplicationInfo     _GRI;
        local CPPlayerReplicationInfo   _PRI;
        local CPPawn                    _Pawn;

        _Pawn = CPPawn( Instigator );
        if(_Pawn != none){
            _PRI = CPPlayerReplicationInfo(_Pawn.PlayerReplicationInfo);
            _Pawn.SetWeaponAmbientSound(none);
        }

        _GRI = CPGameReplicationInfo( WorldInfo.GRI );
        if ( IsDefused() )
        {
            ClearTimer('ShouldPlayTickSound');
			ClearTimerLog('ShouldPlayTickSound');

            _Game = CriticalPointGame( WorldInfo.Game );

            if ( _PRI != none)
                _PRI.bDiffusedBomb = true;

            if ( _GRI != none )
                _GRI.bBombPlanted = false;

            if ( _Game != none )
            {
                _Game.AnnounceBombBeingDefused();
                _Game.EndRound( none, "BombDiffused" );
            }

            PlantTimestamp = 0.0;
        }

        BeginThrowWeapon();
        if ( Role < ROLE_Authority )
            ServerStartThrowWeapon();

        DefuseTimestamp = 0.0;
        if ( _GRI != none )
            _GRI.bBombBeingDiffused = false;

        super.EndState( NextStateName );
    }
}

simulated function ShouldPlayTickSound()
{
    local CPGameReplicationInfo     _GRI;
    _GRI = CPGameReplicationInfo( WorldInfo.GRI );

    if(_GRI != none && (_GRI.bRoundIsOver || _GRI.RemainingBombDetonatonTime <= 0))
    {
        ClearTimer('ShouldPlayTickSound');
		ClearTimerLog('ShouldPlayTickSound');
        return;
    }

    if(PlayNextTickSound < WorldInfo.TimeSeconds)
    {
        PlaySound(SoundTickCue, false, true, true, SoundLocation, false);
        PlayNextTickSound = WorldInfo.TimeSeconds + TickBuffer - 0.1;

        if(_GRI != none && _GRI.RemainingBombDetonatonTime > 50 )
        {
            TickBuffer = 2.2 ;
        }
        else if(_GRI != none && _GRI.RemainingBombDetonatonTime > 40 )
        {
            TickBuffer = 1.8;
        }
        else if(_GRI != none && _GRI.RemainingBombDetonatonTime > 30 )
        {
            TickBuffer = 1.4;
        }
        else if(_GRI != none && _GRI.RemainingBombDetonatonTime > 20 )
        {
            TickBuffer = 1.0;
        }
        else if(_GRI != none && _GRI.RemainingBombDetonatonTime > 10 )
        {
            TickBuffer = 0.3;
        }
    }

    SetTimer(TickBuffer, false, 'ShouldPlayTickSound');
	SetTimerLog(TickBuffer,false,'ShouldPlayTickSound');
}


defaultproperties
{
    WeaponType=WT_BOMB
    ShotCost(0)=0

    Begin Object Class=CPWeaponFireMode Name=FireMode_ArmBomb
        ModeName="Bomb"
        FireType(0)=ETFT_InstantHit
        FiringState(0)=Planting
        FiringState(1)=Defusing
        FireInterval(0)=5.0
        FireInterval(1)=5.0
        MinFireRecoil(0)=(X=0.0,Y=0.0,Z=0.0)
        MaxFireRecoil(0)=(X=0.0,Y=0.0,Z=0.0)
        MinHitDamage(0)=0
        MaxHitDamage(0)=0
        bRepeater(0)=0
        HitDamageType(0)=class'CPDmgType_Bomb'
        HitMomentum(0)=20000.0
        WeaponFireAnims(0)=WeaponArming
        ArmFireAnims(0)=WeaponArming
        WeaponAltFireAnims(0)=WeaponArming
        MuzzleFlashLightClass(0)=none
        MuzzleFlashLightClass(1)=none
        WeaponFireSnds(0)=None//SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombArming_Cue' //should be the sound for arming - matches the fireinterval time.
        WeaponFireSnds(1)=None//SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombDisarming_Cue' //should be the sound for defusing.
        MuzzleFlashPSC(0)=none
        MuzzleFlashDuration(0)=0.0
    End Object
    FireStates.Add(FireMode_ArmBomb)

    ClipPickupSound=none//SoundCue'TEMP_WeaponSounds.Cue.A_Weapon_Clip_Pickup'

    WeaponEmptySnd=none
    FireWeaponEmptyTime=0.0
    WeaponEmptyFireAnim=none

    EquipTime=0.46
    PutDownTime=0.23
    WeaponEquipSnd=SoundCue'CP_Weapon_Sounds.BombAndHackSounds.Bomb_Equip_Cue'
    WeaponPutDownSnd=SoundCue'CP_Weapon_Sounds.BombAndHackSounds.Bomb_Unequip_Cue'
    PickupSound=none//SoundCue'TEMP_WeaponSounds.Cue.A_Pickup_Weapon_Cue'

    AttachmentClass=class'CPAttachment_Bomb'

    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'TA_WP_C4Bomb.Mesh.SK_TA_C4Bomb_1P'
        AnimSets(0)=AnimSet'TA_WP_C4Bomb.Anims.AS_TA_C4Bomb_1P'
        AnimTreeTemplate=AnimTree'TA_WP_C4Bomb.Anims.AT_TA_C4Bomb_1P'

        FOV=45.0
        Scale=3.0
        bUpdateSkelWhenNotRendered=true
    End Object
    Mesh=FirstPersonMesh

    Begin Object Name=PickupMesh
        StaticMesh=StaticMesh'TA_WP_C4Bomb.Mesh.SM_TA_C4Bomb_Pickup'
        Scale=0.8
        Rotation=(Pitch=0,Yaw=0,Roll=0)
    End Object

    bForceSwitchWhenEmpty=true
    bDestroyWhenEmpty=true

    WeaponReloadAnim=none
    ArmsReloadAnim=none

    WeaponPutDownAnim=WeaponPutDown
    ArmsPutDownAnim=WeaponPutDown

    FireOffset=(X=12,Y=10,Z=-10)

    bNoWeaponCrosshair=true
    DroppedPickupClass=class'CPDroppedBomb'
    WeaponFlashName="bomb"
    InventoryGroup=6
    //WeaponProfileName=C4Bomb //depreciated
    bAmmoStringNullOnEmpty=false

    DefuseInterval=5.0

    DefuseTimestamp=0.0
    PlantTimestamp=0.0

    ArmingSound = SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombArming_Cue';
    DiffusingSound = SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombDisarming_Cue'

    /*
    //var   AudioComponent              ArmingAudioComponent;
    Begin Object Class=AudioComponent Name=ArmingSound
        SoundCue=SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombArming_Cue'
    End Object
    ArmingAudioComponent=ArmingSound
    Components.Add(ArmingSound);

    //var   AudioComponent              DefusingAudioComponent;
    Begin Object Class=AudioComponent Name=DiffusingSound
        SoundCue=SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombDisarming_Cue'
    End Object
    DefusingAudioComponent=DiffusingSound
    Components.Add(DiffusingSound);
    */
    SoundTickCue=SoundCue'CP_Weapon_Sounds.BombAndHackSounds.BombTicking_Cue'
    TickBuffer=2

    MaxAmmoCount=1
    MaxClipCount=0
	bShowMuzzleFlashWhenFiring = FALSE
}
