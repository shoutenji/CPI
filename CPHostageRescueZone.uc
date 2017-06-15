class CPHostageRescueZone extends Volume
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
		GRI.HostageRescueZone=self;
}

event reset()
{
	NumEscaped = 0;
}
event Touch(Actor Other,PrimitiveComponent OtherComp,Vector HitLocation,Vector HitNormal)
{
	local CPHostage tapc;
	local CriticalPointGame Game;
	local CPGameReplicationInfo GRI;
	local CPPawn TPawn;
	local CPTeamInfo TTeamInfo;
	local int i;

	TPawn=CPPawn(Other);
	
	if (TPawn==none)
		return;

	TPawn.HostageRescueZone = self;

	tapc=CPHostage(TPawn.Controller);
	if (tapc==none || tapc.GetTeamNum()!=TTI_Hostages)
		return;



	// Rogue. Verify current TeamSize everytime someone tries to escape. Just in case more players
	// enter the map after the first player escapes and no damage has been given.
	
	Game=CriticalPointGame(WorldInfo.Game);
	GRI=CPGameReplicationInfo( WorldInfo.GRI );
	if ( Game != none && GRI != none)
	{
		for ( i = 0; i < GRI.Teams.Length; i++ )
		{
			if ( !GRI.Teams[i].IsA( 'CPTeamInfo' ) )
				continue;

			TTeamInfo = CPTeamInfo( GRI.Teams[i] );
			if (TTeamInfo.TeamIndex==TTI_Hostages)
			{
				TPawn.OnHostageRescued(CPHostage(TPawn.Controller).Enemy.Controller);
				NumEscaped++;
			}
		}
	}

	// Escaping would consider the game is at a point where there is no
	// turning back and thus no team swapping... or mid game joining after this point.
	if ( Game != none && GRI != none)
	{
		GRI.bDamageTaken = true;
	}

	`Log("NumEscaped IS NOW " $ NumEscaped);
	if (NumEscaped>=NumToWin)
	{
		NumEscaped=0;
		if (Role==ROLE_Authority)
		{
			Game=CriticalPointGame(WorldInfo.Game);
			if (Game!=none && Game.RoundIsInProgress())
			{
				Game.HUDMessage(21);
				Game.EndRound(tapc.PlayerReplicationInfo,"Hostages have escaped!");
			}
		}
	}
}

simulated event UnTouch(Actor Other)
{
	local CPPawn		_Pawn;

	
	_Pawn = CPPawn( Other );
	if ( _Pawn == none || _Pawn.Health <= 0)
		return;

	_Pawn.HostageRescueZone = none;
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
