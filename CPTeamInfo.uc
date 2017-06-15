class CPTeamInfo extends TeamInfo;

// NOTE : this is a global defintion!
enum ETATeamIndex
{
	TTI_Mercenaries,
	TTI_SpecialForces,
	TTI_Hostages
};

var color BaseTeamColor[2];
var localized string TeamColorNames[2];

function Initialize(int NewTeamIndex)
{
	TeamIndex=NewTeamIndex;
}

simulated function string GetHumanReadableName()
{
	if (TeamName==Default.TeamName)
	{
		if (TeamIndex<2)
			return TeamColorNames[TeamIndex];
		return TeamName@TeamIndex;
	}
	return TeamName;
}

simulated function color GetHUDColor()
{
	return BaseTeamColor[TeamIndex];
}

DefaultProperties
{
	BaseTeamColor(0)=(r=255,g=64,b=64,a=255)
	BaseTeamColor(1)=(r=64,g=64,b=255,a=255)
}
