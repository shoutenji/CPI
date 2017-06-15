class CPBombZone extends Volume
    placeable;




simulated function bool IsTouching( Actor Other )
{
    local Actor     _Actor;


    foreach TouchingActors( class'Actor', _Actor )
    {
        if ( _Actor == Other )
            return true;
    }
    return false;
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
    local CPPawn        _Pawn;


    _Pawn = CPPawn( Other );
    if ( _Pawn == none || _Pawn.Health <= 0 || _Pawn.GetTeamNum() != TTI_Mercenaries )
        return;

    _Pawn.BombZone = self;
}

simulated event UnTouch( Actor Other )
{
    local CPPawn        _Pawn;


    _Pawn = CPPawn( Other );
    if ( _Pawn != none )
        _Pawn.BombZone = none;
}




defaultproperties
{
    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=10.0

    bHidden=true
    bCollideActors=true
    bProjTarget=true
    bStatic=false
    bNoDelete=true
}
