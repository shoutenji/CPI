class CPInventoryManager extends InventoryManager;

var float LastAdjustWeaponTime;
var CPWeapon PendingSwitchWeapon;
var Weapon PreviousWeapon;
var	private int PendingReload;
var	private int PendingWeaponDrop;
var	private int PendingFireModeSwitch;
var	private int PendingFireRelease;


function string ToString()
{
    local string returnString;
    local Inventory _InvItem;
    
    returnString = "\n";
    ForEach InventoryActors(class'Inventory', _InvItem)
	{
        returnString $= _InvItem.Name $ "\n";
    }
    returnString $= "\n";
    
    return returnString;
}


reliable server function ServerToString()
{
    local string returnString;
    local Inventory _InvItem;
    
    returnString = "\n";
    ForEach InventoryActors(class'Inventory', _InvItem)
	{
        returnString $= _InvItem.Name $ "\n";
    }
    returnString $= "\n";
    
    `Log(returnString);
}

// NOTE : if somehow we manage to get a weapon we shouldn't get then discard it
simulated function bool AddInventory(Inventory NewItem,optional bool bDoNotActivate)
{
local bool bResult;
local CPWeapon TAWeap,sWeap;

	if (Role==ROLE_Authority)
	{
		if (CPWeapon(NewItem)!=none)
		{
			foreach InventoryActors(class'CPWeapon',sWeap)
			{
				if (sWeap.WeaponType==CPWeapon(NewItem).WeaponType)
				{
					TAWeap=sWeap;
					break;
				}
			}
			if (TAWeap!=none)
				return true;
		}
		bResult=super(InventoryManager).AddInventory(NewItem,bDoNotActivate);
		if (bResult && CPWeapon(NewItem) != None)
			if (!bDoNotActivate)
				CheckSwitchTo(CPWeapon(NewItem));
	}
	return bResult;
}

simulated function RemoveFromInventory(Inventory ItemToRemove)
{
local Inventory Item;
local bool bFound;
	
	if (Role==ROLE_Authority)
	{
		if (ItemToRemove!=none)
		{
			if (InventoryChain==ItemToRemove)
			{
				bFound=true;
				InventoryChain=ItemToRemove.Inventory;
			}
			else
			{
				for (Item=InventoryChain;Item!=none;Item=Item.Inventory)
				{
					if (Item.Inventory==ItemToRemove)
					{
						bFound=true;
						Item.Inventory=ItemToRemove.Inventory;
						break;
					}
				}
			}
			if (bFound)
			{
				`LogInv("removed"@ItemToRemove);
				ItemToRemove.ItemRemovedFromInvManager();
				ItemToRemove.SetOwner(none);
				ItemToRemove.Inventory=none;
			}
			if (ItemToRemove==Instigator.Weapon)
				Instigator.Weapon=none;
			if (Weapon(ItemToRemove)==PreviousWeapon)
				PreviousWeapon=none;
			if (Instigator.Health>0 && Instigator.Weapon==none && Instigator.Controller!=none && PendingWeapon!=Weapon(ItemToRemove))
			{
				if (CPPawn(Instigator)!=none)
				{
					if (!CPPawn(Instigator).bSwappingWeapon)
					{
						`LogInv("Calling ClientSwitchToBestWeapon");
						if (CPWeapon(ItemToRemove)!=none)
						{
							if (!(CPWeapon(ItemToRemove).bDestroyWhenEmpty && CPWeapon(ItemToRemove).bEmptyDestroyRequest))
							{
								if (CPPlayerController(CPPawn(Instigator).Controller)!=none)
									CPPlayerController(CPPawn(Instigator).Controller).ClientAutoSwitch(true);
								else
									Instigator.Controller.ClientSwitchToBestWeapon(true);
							}
						}
						else
						{
							if (CPPlayerController(CPPawn(Instigator).Controller)!=none)
								CPPlayerController(CPPawn(Instigator).Controller).ClientAutoSwitch(true);
							else
								Instigator.Controller.ClientSwitchToBestWeapon(true);
						}
					}
				}
			}
		}
		if (PendingSwitchWeapon==ItemToRemove)
		{
			PendingSwitchWeapon=none;
			ClearTimer('ProcessRetrySwitch');
		}
	}
}

simulated function SetPendingFire(Weapon InWeapon,int InFiringMode)
{
	if (CPGameReplicationInfo(WorldInfo.GRI).bCanPlayersMove)
		super.SetPendingFire(InWeapon,InFiringMode);
}

simulated function bool IsPendingFireRelease()
{
	return bool(PendingFireRelease);
}

simulated function SetPendingFireRelease()
{
	PendingFireRelease=1;
}

simulated function ClearPendingFire(Weapon InWeapon,int InFiringMode)
{
	super.ClearPendingFire(InWeapon,InFiringMode);
	if (!IsPendingFire(none,0) && !IsPendingFire(none,1))
		PendingFireRelease=0;
}

simulated function ClearAllPendingFire(Weapon InWeapon)
{
	super.ClearAllPendingFire(InWeapon);
	PendingFireRelease=0;
}

simulated function AdjustWeapon(int NewOffset)
{
local Weapon CurrentWeapon;
local array<CPWeapon> WeaponList;
local int i,Index,CurrIndex;

	if (WorldInfo.TimeSeconds-LastAdjustWeaponTime<0.05)
		return;
	LastAdjustWeaponTime=WorldInfo.TimeSeconds;

	CurrentWeapon=CPWeapon(PendingWeapon);
	if (CurrentWeapon==none)
		CurrentWeapon=CPWeapon(Instigator.Weapon);
	
	GetWeaponList(WeaponList);
   	if (WeaponList.length==0)
   		return;
   	
   	for (i=0;i<WeaponList.Length;i++)
	{
		if (WeaponList[i]==CurrentWeapon)
		{
			Index=i;
			break;
		}
	}

	CurrIndex=Index;
	Index+=NewOffset;
	if (Index<0)
		Index=0;
	else if (Index>=WeaponList.Length)
		Index=WeaponList.Length-1;
	if (Index!=CurrIndex)
		SetCurrentWeapon(WeaponList[Index]);
}

simulated function SwitchWeapon(byte NewGroup)
{
local CPWeapon CurrentWeapon;
local array<CPWeapon> WeaponList;
local int NewIndex;

   	GetWeaponList(WeaponList,true,NewGroup);
	if (WeaponList.Length<=0)
	{
		Instigator.GetALocalPlayerController().ReceiveLocalizedMessage(class'CPMsg_NoWeapon',NewGroup);	
		return;
	}
	CurrentWeapon=CPWeapon(PendingWeapon);
	if (CurrentWeapon==none)
		CurrentWeapon=CPWeapon(Instigator.Weapon);
	if (CurrentWeapon==none || CurrentWeapon.InventoryGroup!=NewGroup)
		NewIndex=0;
	else
	{
		for (NewIndex=0;NewIndex<WeaponList.Length;NewIndex++)
		{
			if (WeaponList[NewIndex]==CurrentWeapon)
				break;
		}
		NewIndex++;
		if (NewIndex>=WeaponList.Length)
			NewIndex=0;
	}
	if ( CurrentWeapon != none && !CurrentWeapon.AllowSwitchTo( WeaponList[NewIndex] ) )
		return;

	SetCurrentWeapon(WeaponList[NewIndex]);
}

simulated function bool NeedsSwapToInventoryType(class<Inventory> invType)
{
local CPWeapon TAWeap,sWeap;

	if (InventoryChain==none)
		return false;
	if (class<CPWeapon>(invType)!=none)
	{
		foreach InventoryActors(class'CPWeapon',sWeap)
		{
			if (sWeap.WeaponType==class<CPWeapon>(invType).default.WeaponType) // && sWeap.Class!=invType)
			{
				TAWeap=sWeap;
				break;
			}
		}
		return (TAWeap!=none && TAWeap==Instigator.Weapon);
	}
	return false;
}

simulated function SetPendingReload()
{
	PendingReload=1;
}

simulated function ClearPendingReload()
{
	PendingReload=0;
}

simulated function SetPendingDroppingWeapon()
{
	PendingWeaponDrop=1;
	ServerDropWeapon();
}

reliable server function ServerDropWeapon()
{
	local CPPawn	_Pawn;


	_Pawn = CPPawn( Instigator );
	if ( _Pawn != none )
		_Pawn.TossInventory( _Pawn.Weapon );
}

simulated function ClearPendingDroppingWeapon()
{
	PendingWeaponDrop=0;
}

simulated function bool IsPendingReload()
{
	return bool(PendingReload);
}

simulated function bool IsPendingDrop()
{
	return bool(PendingWeaponDrop);
}

simulated function SetPendingFireModeSwitch()
{
	PendingFireModeSwitch=1;
}

simulated function ClearPendingFireModeSwitch()
{
	PendingFireModeSwitch=0;
}

simulated function bool IsPendingFireModeSwitch()
{
	return bool(PendingFireModeSwitch);
}

simulated function SetPendingWeapon(Weapon DesiredWeapon)
{
    local CPWeapon PrevWeapon,CurrentPending;

	if (Instigator==none)
		return;
	PrevWeapon=CPWeapon(Instigator.Weapon);
	CurrentPending=CPWeapon(PendingWeapon);

	if (CPWeapon(DesiredWeapon)!=none)
	{
		if (CPWeapon(DesiredWeapon).bJustDropped)
		{
			ChangedWeapon();
			`LogInv("trying to select a weapon that was just dropped "$DesiredWeapon);
			return;
		}
	}

	if ( (PrevWeapon==none || PrevWeapon.AllowSwitchTo(DesiredWeapon)) &&
		(CurrentPending==none || CurrentPending.AllowSwitchTo(DesiredWeapon)) )
	{
		if (DesiredWeapon!=none && DesiredWeapon==Instigator.Weapon)
		{
			if (PendingWeapon!=none)
				PendingWeapon=none;
			else
				PrevWeapon.ServerReselectWeapon();

			if (!PrevWeapon.bReadyToFire())
				PrevWeapon.Activate();
			else
				PrevWeapon.bWeaponPutDown=false;
		}
		else
		{
			if (Instigator.IsHumanControlled() && Instigator.IsLocallyControlled())
			{
				if ( CPWeapon(Instigator.Weapon)!=none)
					CPWeapon(Instigator.Weapon).PreloadTextures(false);
				if (PendingWeapon!=none)
					CPWeapon(PendingWeapon).PreloadTextures(false);
				if(DesiredWeapon != none)
					CPWeapon(DesiredWeapon).PreloadTextures(true);
			}
			PendingWeapon=DesiredWeapon;
			if (PrevWeapon!=none && !PrevWeapon.bDeleteMe && !PrevWeapon.IsInState('Inactive'))
				PrevWeapon.TryPutDown();
			else
				ChangedWeapon();
		}
	}
}

simulated function Weapon GetBestWeapon(optional bool bForceADifferentWeapon)
{
    local Weapon W, BestWeapon, MeleeWeapon;
    local float Rating,BestRating;

	ForEach InventoryActors(class'Weapon',W)
	{
		if (W.HasAnyAmmo())
		{
			if (bForceADifferentWeapon && W==Instigator.Weapon)
				continue;
			if (CPWeapon(W)!=none)
				if (CPWeapon(W).bJustDropped /*|| CPWeapon(W).InventoryGroup>3*/)   // WT_RIFLE
					continue;
			Rating=W.GetWeaponRating();
			if (BestWeapon==none || Rating>BestRating)
			{
				BestWeapon=W;
				BestRating=Rating;
			}
		}
		//Added by Molez
		if(CPMeleeWeapon(W) != none)
			MeleeWeapon = W;
	}
	
	//Added by Molez
	if(BestWeapon != none){
		return BestWeapon;
	}else if (MeleeWeapon != none){
		return MeleeWeapon;
	}else{
		`Log("GetBestWeapon() Found no weapon");
		return none;
	}
}



simulated function SwitchToPreviousWeapon()
{
	local CPWeapon		_Previous, _Weapon;

	_Previous = CPWeapon( PreviousWeapon );
	if ( _Previous != none && _Previous.Owner == Owner && !_Previous.bJustDropped )
	{
		_Weapon = CPWeapon( Instigator.Weapon );
		if ( _Weapon != none && !_Weapon.AllowSwitchTo( _Previous ) )
        {
            return;
        }
		PreviousWeapon.ClientWeaponSet( false );
	}
	else
	{
		SwitchToBestWeapon( true );
	}
}

simulated private function InternalSetCurrentWeapon(Weapon DesiredWeapon)
{
	local Weapon PrevWeapon;

	PrevWeapon = Instigator.Weapon;

	`LogInv("PrevWeapon:" @ PrevWeapon @ "DesiredWeapon:" @ DesiredWeapon);

	// Make sure we are switching to a new weapon
	// Handle the case where we're selecting again a weapon we've just deselected
	if( PrevWeapon != None && DesiredWeapon == PrevWeapon && !PrevWeapon.IsInState('WeaponPuttingDown') )
	{
		if(!DesiredWeapon.IsInState('Inactive') && !DesiredWeapon.IsInState('PendingClientWeaponSet'))
		{
			`LogInv("DesiredWeapon == PrevWeapon - abort"@DesiredWeapon.GetStateName());
			return;
		}
	}

	// Set the new weapon as pending
	SetPendingWeapon(DesiredWeapon);

	// if there is an old weapon handle it first.
	if( PrevWeapon != None && PrevWeapon != DesiredWeapon && !PrevWeapon.bDeleteMe && !PrevWeapon.IsInState('Inactive') )
	{
		// Try to put the weapon down.
		`LogInv("Try to put down previous weapon first.");
		PrevWeapon.TryPutdown();
	}
	else
	{
		// We don't have a weapon, force the call to ChangedWeapon
		ChangedWeapon();
	}
}

reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
    // Switch to this weapon
	InternalSetCurrentWeapon(DesiredWeapon);

	// Tell the server we have changed the pending weapon
	if( Role < Role_Authority )
	{
		ServerSetCurrentWeapon(DesiredWeapon);
	}
}


simulated function ClientWeaponSet(Weapon NewWeapon,bool bOptionalSet,optional bool bDoNotActivate)
{
	local CPWeapon OldWeapon;

    OldWeapon = CPWeapon( Instigator.Weapon );
	if (OldWeapon==none || OldWeapon.bDeleteMe || OldWeapon.IsInState('Inactive'))
	{
		SetCurrentWeapon(NewWeapon);
		return;
	}
	if (OldWeapon==NewWeapon)
    {
        return;
    }
	if (!bOptionalSet)
	{
        SetCurrentWeapon(NewWeapon);
		return;
	}
	if (Instigator.IsHumanControlled() && (bDoNotActivate || PlayerController(Instigator.Controller).bNeverSwitchOnPickup))
	{
        NewWeapon.GotoState('Inactive');
		return;
	}
	if (OldWeapon.IsFiring() || OldWeapon.DenyClientWeaponSet() && (CPWeapon(NewWeapon)!=none))
	{
        NewWeapon.GotoState('Inactive');
		RetrySwitchTo(CPWeapon(NewWeapon));
		return;
	}
	if ((PendingWeapon==none || !PendingWeapon.HasAnyAmmo() || PendingWeapon.GetWeaponRating()<NewWeapon.GetWeaponRating()) &&
		(!Instigator.Weapon.HasAnyAmmo() || Instigator.Weapon.GetWeaponRating()<NewWeapon.GetWeaponRating()) &&
		OldWeapon.AllowSwitchTo( NewWeapon ) )
	{
        SetCurrentWeapon(NewWeapon);
		return;
	}
	NewWeapon.GotoState('Inactive');
}

simulated function RetrySwitchTo(CPWeapon NewWeapon)
{
	PendingSwitchWeapon=NewWeapon;
	SetTimer(0.1,false,'ProcessRetrySwitch');
}

simulated function ChangedWeapon()
{
local CPWeapon Wep;
//local CPPawn TAP;

	PreviousWeapon=Instigator.Weapon;
	Super.ChangedWeapon();
	Wep=CPWeapon(Instigator.Weapon);
	if (Wep!=none && Wep.bNeverForwardPendingFire)
		ClearAllPendingFire(Wep);
	//TAP=CPPawn(Instigator);
	//if (TAP!=None)
	//	TAP.SetPuttingDownWeapon((PendingWeapon!=none));
}

simulated function GetWeaponList(out array<CPWeapon> WeaponList,optional bool bFilter,optional int GroupFilter,optional bool bNoEmpty)
{
local CPWeapon Weap;
local int i;

	ForEach InventoryActors(class'CPWeapon',Weap)
	{
		if ((!bFilter || Weap.InventoryGroup==GroupFilter) && (!bNoEmpty || Weap.HasAnyAmmo()))
		{
			if ( WeaponList.Length>0 )
			{
				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight>Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i]=Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length=WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length=1;
				WeaponList[0]=Weap;
			}
		}
	}
}

simulated function GetOrderedWeaponList(out array<CPWeapon> WeaponList)
{
	local CPWeapon Weap;
	local array<CPWeapon> TempWeaponList;
	local int i, j, b;
	
	GetWeaponList(TempWeaponList);

	for(i=0; i<TempWeaponList.Length; i++)
	{
		j=i;
		b = TempWeaponList[i].InventoryGroup;
		Weap = TempWeaponList[i];
		while((j > 0) && (TempWeaponList[j-1].GroupWeight > b))
		{
			TempWeaponList[j] = TempWeaponList[j-i];
			j--;
		}
		TempWeaponList[j] = Weap;
	}

	WeaponList = TempWeaponList;
}

simulated function bool NeedsAmmo(class<CPWeapon> TestWeapon)
{
local array<CPWeapon> WeaponList;
local int i;

	GetWeaponList(WeaponList);
	for (i=0;i<WeaponList.Length;i++)
	{
		if (ClassIsChildOf(WeaponList[i].Class,TestWeapon))
			return (WeaponList[i].AmmoCount<WeaponList[i].MaxAmmoCount);
	}
	return true;

}

simulated function CheckSwitchTo(CPWeapon NewWeapon)
{
	if (CPWeapon(Instigator.Weapon)==none ||
		(Instigator!=none && PlayerController(Instigator.Controller)!=none &&
		CPWeapon(Instigator.Weapon).ShouldSwitchTo(NewWeapon)))
	{
		NewWeapon.ClientWeaponSet(true);
	}
}

simulated function ProcessRetrySwitch()
{
local CPWeapon NewWeapon;

	NewWeapon=PendingSwitchWeapon;
	PendingSwitchWeapon=none;
	if (NewWeapon!=none)
		CheckSwitchTo(NewWeapon);
}

simulated function OwnerEvent(name EventName)
{
local CPInventory Inv;

	ForEach InventoryActors(class'CPInventory',Inv)
	{
		if (Inv.bReceiveOwnerEvents)
			Inv.OwnerEvent(EventName);
	}
}

reliable client function ClientSyncWeapon(Weapon NewWeapon)
{
local Weapon OldWeapon;

	if (NewWeapon==Instigator.Weapon )
		return;
	`LogInv("Forcing weapon:" @ NewWeapon @ "from:" @ Instigator.Weapon);
	OldWeapon=Instigator.Weapon;
	Instigator.Weapon=NewWeapon;
	Instigator.PlayWeaponSwitch(OldWeapon,NewWeapon);
	if (NewWeapon!=none)
	{
		Instigator.Weapon.Instigator=Instigator;
		if (WorldInfo.Game!=none)
			Instigator.MakeNoise(0.1,'ChangedWeapon');
		Instigator.Weapon.Activate();
	}
	if (Instigator.Controller!=none)
		Instigator.Controller.NotifyChangedWeapon(OldWeapon,Instigator.Weapon);
}

simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass,optional bool bDoNotActivate)
{
	if (Role==ROLE_Authority)
		return Super.CreateInventory(NewInventoryItemClass,bDoNotActivate);
	return none;
}






// ~WillyG: Added
simulated function PrevWeapon()
{
	local CPWeapon StartWeapon, _Weapon;
	local int i, len;

	local array<CPWeapon> WeaponList;

	//`log("Hello Prev");
	GetOrderedWeaponList(WeaponList);
	len = WeaponList.Length;

	if(len == 1)
		return;

	
	StartWeapon = CPWeapon((PendingWeapon != none) ? PendingWeapon : Instigator.Weapon);
	if(StartWeapon == none)
		return;

	for(i = 0; i < len; i++)
	{
		if(StartWeapon.WeaponType == WeaponList[i].WeaponType)
			break;
	}
	_Weapon = CPWeapon( Instigator.Weapon );
	if ( _Weapon != none && !_Weapon.AllowSwitchTo( WeaponList[(len + i - 1) % len] ) )
		return;

	SetCurrentWeapon(WeaponList[(len + i - 1) % len]);
}


// ~WillyG: Added
simulated function NextWeapon()
{
	local CPWeapon StartWeapon, _Weapon;
	local int i, len;

	local array<CPWeapon> WeaponList;

	//`log("Hello Next");
	GetOrderedWeaponList(WeaponList);
	len = WeaponList.Length;

	if(len == 1)
		return;

	StartWeapon = CPWeapon((PendingWeapon != none) ? PendingWeapon : Instigator.Weapon);
	if(StartWeapon == none)
		return;

	for(i = 0; i < len; i++)
	{
		if(StartWeapon.WeaponType == WeaponList[i].WeaponType)
			break;
	}
	_Weapon = CPWeapon( Instigator.Weapon );
	if ( _Weapon != none && !_Weapon.AllowSwitchTo( WeaponList[(i + 1) % len] ) )
		return;

	SetCurrentWeapon(WeaponList[(i + 1) % len]);
}



defaultproperties
{
	bMustHoldWeapon=true
	PendingFire(0)=0
	PendingFire(1)=0
	PendingFireRelease=0
}
