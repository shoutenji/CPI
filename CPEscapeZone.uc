class CPEscapeZone extends Volume
	placeable;

var() int NumToWin;
var int TeamSize;
var int NumEscaped;
var bool bActive;

event PostBeginPlay()
{
local CPGameReplicationInfo GRI;

	GRI=CPGameReplicationInfo(WorldInfo.GRI);
	if (GRI!=none )
		GRI.EscapeZone=self;
}

simulated event UnTouch(Actor Other)
{
	local CPPawn		_Pawn;

	
	_Pawn = CPPawn( Other );
	if ( _Pawn == none || _Pawn.Health <= 0 || _Pawn.GetTeamNum() != TTI_Mercenaries )
		return;

	_Pawn.EscapeZone = none;
}

event Touch(Actor Other,PrimitiveComponent OtherComp,Vector HitLocation,Vector HitNormal)
{
	local CPPlayerController tapc;
	local CriticalPointGame Game;
	local CPGameReplicationInfo GRI;
	local CPPawn		_Pawn;
	local CPTeamInfo TTeamInfo;
	local int i;

	_Pawn = CPPawn( Other );
	
	if ( _Pawn == none || _Pawn.Health <= 0 || _Pawn.GetTeamNum() != TTI_Mercenaries )
		return;

	_Pawn.EscapeZone = self;

	tapc=CPPlayerController(_Pawn.Controller);

	// Rogue. Verify current TeamSize everytime someone tries to escape. Just in case more players
	// enter the map after the first player escapes and no damage has been given.
	
	Game=CriticalPointGame(WorldInfo.Game);
	GRI=CPGameReplicationInfo( WorldInfo.GRI );
	if ( Game != none && GRI != none && !GRI.bDamageTaken)
	{
		for ( i = 0; i < GRI.Teams.Length; i++ )
		{
			if ( !GRI.Teams[i].IsA( 'CPTeamInfo' ) )
				continue;

			TTeamInfo = CPTeamInfo( GRI.Teams[i] );
			if (TTeamInfo.TeamIndex==TTI_Mercenaries)
			{
				TeamSize = TTeamInfo.Size;
				NumToWin = int( float( TTeamInfo.Size ) / Game.EscapePct + 0.5f );
				if ( NumToWin < Game.MinEscapeCount )
					NumToWin = Game.MinEscapeCount;
			}
		}
	}


	if (TeamSize<NumToWin)
		return;

	_Pawn.OnPlayerEscaped();
	NumEscaped++;

	// Escaping would consider the game is at a point where there is no
	// turning back and thus no team swapping... or mid game joining after this point.
	if ( Game != none && GRI != none)
	{
		GRI.bDamageTaken = true;
	}

	if (NumEscaped>=NumToWin)
	{
		NumEscaped=0;
		if (Role==ROLE_Authority)
		{
			Game=CriticalPointGame(WorldInfo.Game);
			if (Game!=none && Game.RoundIsInProgress())
			{
				// Announce mercenaries have escaped message...
				Game.HUDMessage(22);
				Game.EndRound(tapc.PlayerReplicationInfo,"Mercenaries have escaped!");
			}
		}
	}
	else
	{   
		if (Role==ROLE_Authority)
		{
			Game=CriticalPointGame(WorldInfo.Game);
			if (Game!=none)
			{
				Game.CheckMaxLives(tapc.PlayerReplicationInfo, false);
			}
		}
	}
}

DefaultProperties
{
	bHidden=true
	bCollideActors=true
	bProjTarget=true
	bStatic=false
	bNoDelete=true

	NumToWin=0
	NumEscaped=0
	bActive=true
}