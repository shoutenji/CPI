class CPArmor extends CPInventory; 

var float Health;
var float MaxHealth;
var float Mitigation;
var int Cost;


// Network replication.
replication
{
	// Things the server should send to the client.
	if ( (Role==ROLE_Authority) && bNetDirty && bNetOwner )
		Health, MaxHealth;
}

function GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
	Health = MaxHealth;
	CPPlayerController(thisPawn.Controller).ClientPlaySound(PickupSound);
	super.GivenTo( thisPawn, bDoNotActivate );
}

DefaultProperties
{
	Health=0
	MaxHealth=100
	Mitigation=0.5
	PickupSound=SoundCue'CP_Weapon_Sounds.Pickups.CP_A_Pickup_BodyArmor_Cue'
}
