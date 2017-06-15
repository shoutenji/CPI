class CPMeleePickup extends CPDroppedPickup;

var int Team;
var CPWeapon Weapon;

event PostBeginPlay()
{
	super.PostBeginPlay();
	
	Weapon = GetLimitedWeapon();
	Weapon.ClipCount = 1;
	Inventory = Weapon;
	
	SetPhysics( PHYS_None );
}

simulated function Init(int aTeam)
{
	Team = aTeam;
}

simulated function CPWeapon GetLimitedWeapon()
{
	return spawn(class'CPWeapon');
}

auto simulated state Pickup
{
	simulated function Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local CPWeapon			_Weapon, _PawnWeapon;
		local CPPawn			_Pawn;
		local int				_Clip;
		local CPPlayerController CPPC;

		_Pawn = CPPawn( Other );
		_Weapon = Weapon;
		
		if(_Pawn != none)
			CPPC = CPPlayerController(_Pawn.Controller);
		
		if ( _Pawn == none || _Weapon == none || CPPC == None || CPPC.GetTeamNum() != Team)
			return;

		_PawnWeapon = CPWeapon( _Pawn.Weapon );
		if ( _PawnWeapon != none && _Weapon.Class == _PawnWeapon.Class )
		{	
			_Clip = Min( _Weapon.MaxClipCount - _PawnWeapon.GetClipCount(), _Weapon.GetClipCount() );	
			if ( _Clip > 0 )
			{
				_Weapon.AddClip( -_Clip );
				_PawnWeapon.AddClip( _Clip );
				_PawnWeapon.PlayClipPickup();
				
				Destroy();
			}
		}
		else
		{
			// We call the super version of GiveTo so the
			// weapon isn't automatically swapped to.
			super.GiveTo( _Pawn );
		}
	}
}

DefaultProperties
{
	bPickupable=true
	Team = -1;
}