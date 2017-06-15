class CPInventory extends Inventory
	abstract;

var bool bReceiveOwnerEvents;

simulated static function AddWeaponOverlay(CPGameReplicationInfo GRI);

reliable client function ClientLostItem()
{
	if (Role<ROLE_Authority)
		SetOwner(None);
}

simulated event Destroyed()
{
local Pawn P;

	P=Pawn(Owner);
	if (P!=none && (P.IsLocallyControlled() || (P.DrivenVehicle!=none && P.DrivenVehicle.IsLocallyControlled())))
		ClientLostItem();
	Super.Destroyed();
}

function DropFrom(vector StartLocation,vector StartVelocity)
{
	ClientLostItem();
	Super.DropFrom(StartLocation, StartVelocity);
}

function OwnerEvent(name EventName);

defaultproperties
{
	MessageClass=class'CPMsg_Pickup'
	DroppedPickupClass=class'CPDroppedPickup'
}
