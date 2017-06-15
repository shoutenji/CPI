//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CPiOnlineStatsRead extends OnlineStatsRead;

final function int GetCPiStats(UniqueNetId Player)
{
	local int ReturnVal;

	GetIntStatValueForPlayer(Player, 0, ReturnVal);

	return ReturnVal;
}


DefaultProperties
{
    ViewName="Stats"

	// Column names
	ColumnIds.Add(0);

	// Column metadata
	ColumnMappings.Add((Id=0,Name="CPiStats"))
}