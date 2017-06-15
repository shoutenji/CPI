class CPWeaponScoped extends CPWeapon;

var const PostProcessChain SniperScopePostProcess;

var SoundCue		ZoomInSound, ZoomOutSound;
/** The last zoom level recorded
 * @warning This should only be modified by the Un/Reset/Zoom functions!
 */
var int				LastZoom;
/** The current zoom level of this weapon
 */
var int				CurrentZoom;
var float			ScopeSize;
var array<float>	ScopeLevels;
/** The spread multipliers for each ScopeLevel
 *  @note Defaults to 1.0f when there is no defined multiplier
 */
var array<float>	SpreadMultipliers;

var repnotify name RemoteZoom;

replication
{
	if ( bNetInitial || bNetDirty )
		RemoteZoom;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'RemoteZoom')
	{
		if(CPPawn( Instigator ).Controller == none) //spectators only
		{			
			if(RemoteZoom == 'Zoom' || RemoteZoom == 'Zoom2')
			{

				Zoom();
			}
			else if(RemoteZoom == 'UnZoom')
			{
				UnZoom();
			}
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/**
 * Reset the weapon to a neutral state
 */
simulated function Reset()
{
	UnZoom();
	super.Reset();
}

simulated function UpdateSpectateZoom()
{
    if(CPPawn( Instigator ).Controller == none) //spectators only
	{		
		if(RemoteZoom == 'Zoom')
		{
			CurrentZoom = -1;
		}
		else if(RemoteZoom == 'Zoom2')
		{
			CurrentZoom = 0;
		}
		else if(RemoteZoom == 'UnZoom')
		{
			CurrentZoom = 1;
		}
		HandleZoom();
	}
}

/**
 * Check if this weapon is currently scoped
 * @return boolean, true if scoped
 */
simulated function bool IsScoped()
{
	return CurrentZoom > -1;
}

/**
 * Handles the generic functionality after zooming
 * @warning Only CPWeaponScoped member functions should call this function!
 *               e.g. Zoom, UnZoom and ResetZoom
 */
simulated function HandleZoom()
{
	local CPPlayerController	_PlayerController;
	local CPPawn                _Pawn;
	local bool                  _Scoped;

	if ( Role == ROLE_SimulatedProxy )
		ServerSetZoom( CurrentZoom );

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		_Scoped = IsScoped();
		// Hide/Show the weapon depending on our scoped state

		Mesh.SetOwnerNoSee( _Scoped );
		SetHidden( _Scoped );

		_Pawn = CPPawn( Instigator );
		if ( _Pawn != none )
		{
			_Pawn.ArmsMesh[0].SetOwnerNoSee( _Scoped );
			_Pawn.ArmsMesh[1].SetOwnerNoSee( _Scoped );


			if(_Pawn.Controller != none)
			{
				_PlayerController = CPPlayerController( _Pawn.Controller );
			}
			else
			{//spectators
				_PlayerController = CPPlayerController( _Pawn.GetALocalPlayerController() );
			}

			
			if ( _PlayerController != none )
			{
				_PlayerController.ToggleScope( _Scoped , self);
				_PlayerController.DesiredFOV = _Scoped ? ScopeLevels[CurrentZoom] : _PlayerController.DefaultFOV;
			}
		}

		if ( CurrentZoom != LastZoom )
			PlaySound( _Scoped ? ZoomInSound : ZoomOutSound, true );
	}
}

/**
 * Zooms the weapon to the next zoom level
 */
simulated function Zoom()
{
	if(RemoteZoom == '')
		RemoteZoom = 'Zoom';
	else if (RemoteZoom == 'Zoom')
		RemoteZoom = 'Zoom2';
	else if (RemoteZoom == 'Zoom2')
		RemoteZoom = 'UnZoom';
	else if (RemoteZoom == 'UnZoom')
		RemoteZoom = 'Zoom';
	else
	{
		`Log("WARNING ZOOM REMOTEZOOM BROKEN!!!");
	}

	LastZoom = CurrentZoom;
	if ( ++CurrentZoom == ScopeLevels.Length )
		CurrentZoom = -1;

	HandleZoom();
}

/**
 * Unzooms the weapon, setting it's CurrentZoom to -1
 */
simulated function UnZoom()
{
	LastZoom = CurrentZoom;
	CurrentZoom = -1;
	HandleZoom();
}

/**
 * A proxy function to be called by the server
 * @warning This is only supposed to be called when resetting rounds etc.
 */
reliable client function ClientUnZoom()
{
	UnZoom();
}

/**
 * Resets the weapon's zoom level to the last level recorded
 */
simulated function ResetZoom()
{
	local int		_Current;


	_Current = CurrentZoom;
	CurrentZoom = LastZoom;
	LastZoom = _Current;
	HandleZoom();
}

/**
 * This function attempts to correct the server if it has the wrong zoom level
 * @warning Do NOT call this function, use the proper handlers above!
 */
reliable server function ServerSetZoom( int Zoom )
{
	//`log( "CPWeaponScoped::ServerSetZoom:" @ Zoom );
	CurrentZoom = Zoom;
}

/**
 * Gets the spread multiplier for a weapon
 * @return A normalized multiplier for the weapon spread
 */
simulated function float SpreadMultiplier()
{
	local Vector	_Velocity;
	local CPPawn    _Pawn;
	local float     _M;


	_Pawn = CPPawn( Instigator );
	if ( _Pawn != none )
	{
		_Velocity = ( _Pawn.Physics != PHYS_Walking ) ? vect( 0.0f, 1.0f, 0.0f ) * _Pawn.GroundSpeed : _Pawn.Velocity;
		_M = FClamp( VSize( _Velocity ) / _Pawn.GroundSpeed, 0.0f, 1.0f );
	}
	else
	{
		_Velocity = vect( 0.0f, 0.0f, 0.0f );
		_M = 1.0f;
	}

	return ( IsScoped() && CurrentZoom < SpreadMultipliers.Length ) ? SpreadMultipliers[CurrentZoom] * _M : 1.0f;
}

reliable client function ClientWeaponThrown()
{
	UnZoom();
	super.ClientWeaponThrown();
}




simulated state Inactive
{
	simulated event BeginState( name PreviousStateName )
	{
		UnZoom();
		super.BeginState( PreviousStateName );
	}
}

simulated state Hacking
{
	simulated event BeginState( name PreviousStateName )
	{
		UnZoom();
		super.BeginState( PreviousStateName );
	}
}

simulated state Reloading
{
	simulated event BeginState( name PreviousStateName )
	{
		UnZoom();
		super.BeginState( PreviousStateName );
	}

	simulated event EndState( name NextStateName )
	{
		if ( NextStateName == 'Active' )
			ResetZoom();

		super.EndState( NextStateName );
	}
}

simulated state Active
{
	simulated event BeginFire( byte FireModeNum )
	{

		if ( FireModeNum == 1 )
			Zoom();

		super.BeginFire( FireModeNum );
	}


	simulated event BeginState( name PreviousStateName )
	{
		local CPPawn    _Pawn;
		local CPPlayerController _PlayerController;


		_Pawn = CPPawn( Instigator );
		if ( _Pawn != none )
		{
			if(_Pawn.Controller == none)
			{//spectators
				_PlayerController = CPPlayerController( _Pawn.GetALocalPlayerController() );
			}

			
			if ( _PlayerController != none )
			{
				_PlayerController.SpecScopedWeapon = self;
			}
		}

		super.BeginState( PreviousStateName );
	}



}

simulated state WeaponFiring
{
	simulated event BeginState( name PreviousStateName )
	{
		if ( Role == ROLE_SimulatedProxy )
			ServerSetZoom( CurrentZoom );

		super.BeginState( PreviousStateName );
	}
}

simulated state WeaponPuttingDown
{
	simulated event BeginState( name PreviousStateName )
	{
		UnZoom();
		super.BeginState( PreviousStateName );
	}
}




defaultproperties
{
 	ZoomInSound=SoundCue'CP_Weapon_Sounds.Zooms.CP_A_weapon_ZoomIn_Cue'
	ZoomOutSound=SoundCue'CP_Weapon_Sounds.Zooms.CP_A_weapon_ZoomOut_Cue'

 	CurrentZoom=-1
	ScopeSize=1.0f

	SniperScopePostProcess=PostProcessChain'CP_PostProcess.CP_ScopePostProcess'
}