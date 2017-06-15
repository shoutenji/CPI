class GFxCPPlayerInfo extends GFxMoviePlayer;

struct TAPlayerInfoObject
{
	var	GFxObject	HealthBarMC;
	var	GFxObject	BarBgMC;
	var	GFxObject	NameMC;
	var	GFxObject	root;
};

var TAPlayerInfoObject	InfoObject;
var float				Scale;

function Init(optional LocalPlayer LocPlay)
{
	Start();
	Advance(0);
	InfoObject.HealthBarMC	=GetVariableObject("_root.HealthBarMC");
	InfoObject.BarBgMC	    =GetVariableObject("_root.BarBgMC");
	InfoObject.NameMC	    =GetVariableObject("_root.NameMC");
	InfoObject.root	        =GetVariableObject("_root");
	SetViewScaleMode(SM_NoScale);
	SetAlignment(Align_TopLeft);
	SetVisible(false);
}

function UpdateScale()
{
local ASDisplayInfo DInfo;
local Vector2D      Viewport;

	GetGameViewportClient().GetViewportSize(Viewport);
	Scale=100.0f*Viewport.Y/720;
	DInfo.XScale=Scale;
	DInfo.YScale=Scale;
	DInfo.hasXScale=true;
	DInfo.hasYScale=true;
	InfoObject.root.SetDisplayInfo(DInfo);
}

function SetHealthPercent( float Percent )
{
local ASDisplayInfo DInfo;

	DInfo.XScale=Percent;
	DInfo.hasXScale=true;
	InfoObject.HealthBarMC.SetDisplayInfo(DInfo);
}

function SetOpacity(float alpha)
{
	InfoObject.root.SetFloat("_alpha",alpha);
}

function SetBarsOpacity(float alpha)
{
	InfoObject.BarBgMC.SetFloat("_alpha",alpha*0.5f);
	InfoObject.HealthBarMC.SetFloat("_alpha",alpha);
}

function SetPlayerName(string PlayerName)
{
	InfoObject.NameMC.SetText(PlayerName);
}

function SetPosition(float x,float y)
{
	InfoObject.root.SetPosition(x,y);
}

function SetVisible(bool visible)
{
	InfoObject.root.SetVisible(visible);
}

defaultproperties
{
	bCaptureInput=false
    bDisplayWithHudOff=false
	bCloseOnLevelChange=true
	MovieInfo=SwfMovie'TAPlayerInfo.TAPlayerInfo'
}
