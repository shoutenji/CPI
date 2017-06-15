class CPBuyZone extends Volume
	placeable;

var() int Team;
var bool bActive;
var const int InactiveTime;

simulated function HandleTouch(Actor Other,bool Leaving)
{
	local CPPawn		_Pawn;
		
	if(!IsTimerActive('CheckLatentTouchingActors'))
	{
		SetTimer(0.5,true, 'CheckLatentTouchingActors');
	}

	_Pawn = CPPawn( Other );
	if ( _Pawn == none || _Pawn.Health <= 0 || _Pawn.GetTeamNum() != Team )
		return;

	_Pawn.BuyZone = self;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(0.5,true, 'CheckLatentTouchingActors');
}

simulated event CheckLatentTouchingActors()
{
	local CPPawn P;

	if (bActive==false)
		return;
	foreach TouchingActors(class'CPPawn',P)
	{
		if (P.BuyZone != self)
			HandleTouch(P,false);
	}
}

simulated event Touch(Actor Other,PrimitiveComponent OtherComp,vector HitLocation,vector HitNormal)
{
	HandleTouch(Other,false);
}

simulated event UnTouch(Actor Other)
{
	local CPPawn		_Pawn;

	_Pawn = CPPawn( Other );
	if ( _Pawn != none )
		_Pawn.BuyZone = none;
}

DefaultProperties
{
	bHidden=true
	bCollideActors=true
	bProjTarget=true
	bStatic=false
	bNoDelete=true

	Team=-1
	bActive=true
	InactiveTime=60
}