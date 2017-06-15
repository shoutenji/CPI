//==============================================================================
// CPHackZone
// $wotgreal_dt: 10.03.2014 15:24:13$ by Crusha
//
// This denotes the area that a player needs to stand in to attempt hacking a
// CPHackObjective. The Use() code will make sure that the player is looking
// at the HackObjective that got assigned to this Volume while standing inside it.
// The benefit of this approach is that it's lighter on the performance.
//==============================================================================
class CPHackZone extends Volume
    placeable;

var() CPHackObjective HackObjective; // The CPHackObjective that is associated with this HackZone.

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    `warn(self@"No HackObjective has been assigned!", HackObjective == none);
}


simulated event Touch(Actor Other,PrimitiveComponent OtherComp,Vector HitLocation,Vector HitNormal)
{
    local CPPawn        _Pawn;

    _Pawn = CPPawn( Other );
    if ( _Pawn != none && _Pawn.Health > 0 && _Pawn.GetTeamNum() == HackObjective.HackableTeamIndex )
        _Pawn.HackZone = self;
}

simulated event UnTouch(Actor Other)
{
    local CPPawn        _Pawn;

    _Pawn = CPPawn( Other );
    if ( _Pawn != none )
        _Pawn.HackZone = none;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
}