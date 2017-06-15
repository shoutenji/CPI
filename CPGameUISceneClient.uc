class CPGameUISceneClient extends GameUISceneClient;

function NotifyClientTravel( PlayerController TravellingPlayer, string TravelURL, ETravelType TravelType, bool bIsSeamlessTravel )
{
	CPHUD(TravellingPlayer.myHUD).HudMovie.Close(True);
}

function NotifyGameSessionEnded()
{
	local CPUIInteraction CPUI;
	local LocalPlayer SingleLocalPlayer;
	
	CPUI = CPUIInteraction(GetCurrentUIController());
	// may not work for splitscreen game
	SingleLocalPlayer = CPUI.GetLocalPlayer(0);
	CPHUD(SingleLocalPlayer.Actor.myHUD).HudMovie.Close(true);
}

defaultproperties
{

}