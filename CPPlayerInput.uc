class CPPlayerInput extends UDKPlayerInput within CPPlayerController
	config(Input);

var float LastDuckTime;
var bool bHoldDuck;
var bool blnDuckKeyPressed;

function bool InputKey(int ControllerId,name Key,EInputEvent EventType,float AmountDepressed=1.0,bool bGamepad=false)
{
	if (bDEVWeaponTuneMode)
	{
		if(Pawn == none)
			return false; //no pawn so dont tune weapons!

		if (CPWeapon(Pawn.Weapon)!=none && EventType==IE_Pressed)
		{
			if (Key=='Up')
			{	
				CPWeapon(Pawn.Weapon).DEVTuneModeControl(0);
				return true;
			}
			else if (Key=='Down')
			{	
				CPWeapon(Pawn.Weapon).DEVTuneModeControl(1);
				return true;
			}
			else if (Key=='Left')
			{	
				CPWeapon(Pawn.Weapon).DEVTuneModeControl(2);
				return true;
			}
			else if (Key=='Right')
			{	
				CPWeapon(Pawn.Weapon).DEVTuneModeControl(3);
				return true;
			}
		}
	}
	return false;
}

simulated exec function Walk()
{
	if (CPPawn(Pawn)!=none)
	{
		CPPawn(Pawn).bIsWalking=true;
		bRun=1;
	}
}

simulated exec function StopWalk()
{
	if (CPPawn(Pawn)!=none)
	{
		CPPawn(Pawn).bIsWalking=false;
		bRun=0;
	}
}


simulated exec function Duck()
{
	local CPGameReplicationInfo		_GRI;
	local CPPawn					_Pawn;


	blnDuckKeyPressed = true;
	_Pawn = CPPawn( Pawn );
	if ( _Pawn != none && !_Pawn.bIsUsingObjective )
	{
		_GRI = CPGameReplicationInfo( WorldInfo.GRI );
		if( _GRI != none && _GRI.bCanPlayersMove )
		{
			if ( bHoldDuck )
			{
				bHoldDuck = false;
				bDuck = 0;
				return;
			}

			bDuck = 1;

			if ( WorldInfo.TimeSeconds - LastDuckTime < DoubleClickTime )
				bHoldDuck = true;

			LastDuckTime = WorldInfo.TimeSeconds;
		}
	}
}

simulated exec function UnDuck()
{
	local CPPawn		_Pawn;


	blnDuckKeyPressed = false;
	if ( !bHoldDuck )
	{
		_Pawn = CPPawn( Pawn );
		if ( _Pawn != none && _Pawn.bIsUsingObjective )
			return;

		bDuck = 0;
	}
}

simulated function ForcedUnDuck()
{
	if(!blnDuckKeyPressed)
	{
		UnDuck();
	}
}


exec function Jump()
{
	local CPGameReplicationInfo		_GRI;
	local CPPawn					_Pawn;


	_Pawn = CPPawn( Pawn );
	if ( _Pawn != none && !_Pawn.bIsUsingObjective )
	{
		_GRI = CPGameReplicationInfo( WorldInfo.GRI );
		if( _GRI != none && _GRI.bCanPlayersMove )
		{
			if ( IsMoveInputIgnored() )
				return;

	 		if ( bDuck > 0 )
	 		{
	 			bDuck = 0;
	 			bHoldDuck = false;
	 		}

			_Pawn.PlayJumpingSound();
			Super.Jump();
		}
	}
}

function name FindKeyForCommand(string Command)
{
	local int		    BindIndex;
	for(BindIndex = Bindings.Length-1;BindIndex >= 0;BindIndex--)
	{
			if(Bindings[BindIndex].Command == Command)
			{
				//`Log("Command"@Bindings[BindIndex].Command@"is set to"@Bindings[BindIndex].Name);
				return Bindings[BindIndex].Name;
			}
	}

	return '';
}

function CPISetBind(name OldBindName, name newBindName, string newBindCommand, string oldBindCommand, bool blnSecondaryBind)
{
	local KeyBind	NewBind;
	local int		    BindIndex;
	local array<int>    Binds;       

	//1. clear out any keybind using the newBindName 
	for(BindIndex = Bindings.Length-1;BindIndex >= 0;BindIndex--)
	{
			if(Bindings[BindIndex].Name == newBindName)
			{
					//`Log("CLEARING"@newBindName);
					Bindings[BindIndex].Name = '';
					SaveConfig();
				}
	}

	//2. delete any more than 2 binds starting from largest bind number
	for(BindIndex = 0;  BindIndex < Binds.Length-1; BindIndex++)
	{
		if(Binds.Length > 2)
		{
			//`Log("DELETING BIND because theres more than 2 "@newBindCommand);
			Bindings.Remove(Binds[BindIndex],1);
			SaveConfig();
		}
	}

	//3. Find out how many bind positions there are for the command.
	for(BindIndex = 0 ; BindIndex < Bindings.Length;BindIndex++)
	{
		if(Bindings[BindIndex].Command == newBindCommand)
		{
				Binds[Binds.Length] = BindIndex;
		}
	}

	//`Log(Binds.Length@" Were found for "@newBindCommand);

	//4. add the binds left in binds
	//`Log("Remaining Binds"@Binds.Length);

	if(blnSecondaryBind)
	{
		//`Log("Fill in second bind");
		if(Binds.Length == 1)
		{
			//`Log("adding second bind as it does not exist");
			NewBind.Name = newBindName;
			NewBind.Command = newBindCommand;
			Bindings[Bindings.Length] = NewBind;
			SaveConfig();
		}
		else
		{
			if(OldBindName != newBindName)
			{
				//`Log("CHANGING"@OldBindName@"TO"@newBindName@"FROM"@newBindCommand);
				Bindings[Binds[1]].Name = newBindName;
				SaveConfig();
			}
		}
	}
	else
	{
		//`Log("Fill in first bind");
		if(Binds.Length == 0)
		{
			//`Log("adding second bind as it does not exist");
			NewBind.Name = newBindName;
			NewBind.Command = newBindCommand;
			Bindings[Bindings.Length] = NewBind;
			SaveConfig();
		}
		else
		{
			if(OldBindName != newBindName)
			{
				//`Log("CHANGING"@OldBindName@"TO"@newBindName@"FROM"@newBindCommand);
				Bindings[Binds[0]].Name = newBindName;
				SaveConfig();
			}
		}
	}
}

defaultproperties
{
	bEnableFOVScaling=true
	OnReceivedNativeInputKey=InputKey
}
