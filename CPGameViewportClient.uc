class CPGameViewportClient extends UDKGameViewportClient
    dependson(CPExternalUtils);

var Font theFont;
var private bool bCachedDisplayModeList;
var private array<Vector2D> dispModes;
var bool bRenderedAFrame;

var string strLastConsoleCommand;
var bool blnVoted;

//used to queue messages to display to the user
var CP_Frontend_Message_Queue DialogMessageQueue;

event bool Init(out string OutError)
{
local bool bSuperResult;

    bSuperResult=super.Init(OutError);
    bCachedDisplayModeList=false;
    CacheDisplayInfo();

	DialogMessageQueue = new class'CP_Frontend_Message_Queue';
    return bSuperResult;
}

event Destroyed()
{
    theFont = none;
}

function string GetMapName()
{
    return Outer.TransitionDescription;
}

function PlayCustomLoadingMovie()
{
    local WorldInfo WorldInfo;
    local PlayerController PC;
    local string MovieName;

    WorldInfo = class'Engine'.static.GetCurrentWorldInfo();
    ForEach WorldInfo.AllControllers(class'PlayerController', PC)
    {
        if(PC != none)
        {
            if (GamePlayers[0].Actor!=none)
                PC = GamePlayers[0].Actor;

            MovieName = Localize("MapInfo","MapMovie",GetMapName());
            if(MovieName != "")
            {
                class'Engine'.static.StopMovie(true);
                GamePlayerController(PC).ClientPlayMovie(MovieName,0,0,false,false,false);
            }
        }
    }
}

event PostRender(Canvas Canvas)
{
    if (!bRenderedAFrame)
        bRenderedAFrame=true;
    super.PostRender(Canvas);
}

function DrawTransition(Canvas Canvas)
{
    if (Outer.TransitionType==TT_None)
        return;
    if (Outer.TransitionType==TT_Loading)
    {
        PlayCustomLoadingMovie();
        BlackBG(Canvas);
    }
}

function BlackBG(Canvas Canvas)
{
    local int intTipNumber;
    local string strTest;

    `log("Loaded Map name is"@CAPS(Outer.TransitionDescription));

    if (CAPS(Outer.TransitionDescription)=="CPFRONTENDMAP")
    {
        class'Engine'.static.RemoveAllOverlays();
        `log("Loading FrontEndMap, skipping Loading Screen Hints");
        return;
    }

    intTipNumber=Rand(class'CriticalPointGame'.default.tipString.Length);
    strTest=class'CriticalPointGame'.default.tipString[intTipNumber];
    class'Engine'.static.RemoveAllOverlays();
    class'Engine'.static.AddOverlay(theFont, Outer.TransitionDescription, 0.040, 0.120, 1.0, 1.0, false);
    class'Engine'.static.AddOverlay(theFont, "Random Tip " $ intTipNumber, 0.200, 0.750, 1.0, 1.0, false);

    //Fix to text overlap.
    class'Engine'.static.AddOverlayWrapped(theFont,strTest,0.200,0.780,1.0,1.0,4096);

    Canvas.SetPos(0,0);
    Canvas.SetDrawColor(0,0,0,255);
    Canvas.DrawRect(Canvas.SizeX,Canvas.SizeY);
    Canvas.SetDrawColor(255,0,0,255);
}

static final function string GetRightMostSpace(coerce string Text)
{
local int Idx;

    Idx=InStr(Text," ");
    while (Idx!=-1)
    {
        Text=Mid(Text,Idx+1,Len(Text));
        Idx=InStr(Text," ");
    }
    return Text;
}

private function CacheDisplayInfo()
{
local CPExternalUtils taUtils;

    if (bCachedDisplayModeList)
        return;
    taUtils=new class'CPExternalUtils';
    if (!taUtils.GetDisplayModes(dispModes))
    {
        `log("error: failed to cache display modes");
        return;
    }
    bCachedDisplayModeList=true;
}

function array<Vector2D> GetDisplayModes()
{
    if (!bCachedDisplayModeList)
        CacheDisplayInfo();
    return dispModes;
}

function NotifyConnectionError(EProgressMessageType MessageType, optional string Message=Localize("Errors", "ConnectionFailed", "Engine"), optional string Title=Localize("Errors", "ConnectionFailed_Title", "Engine") )
{
	//note this function eventually calls SetProgressMessage - do not add code to DialogMessageQueue in here.
    super.NotifyConnectionError(MessageType,Message,Title);
}

event SetProgressMessage(EProgressMessageType MessageType, string Message, optional string Title, optional bool bIgnoreFutureNetworkMessages)
{
	DialogMessageQueue.AddMessage(Title,Message,MessageType);
    super.SetProgressMessage(MessageType,Message,Title,bIgnoreFutureNetworkMessages);
}

defaultproperties
{
    theFont=MultiFont'UI_Fonts_Final.HUD.MF_Medium'
}