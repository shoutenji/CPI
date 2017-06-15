class CPHUD extends UDKHUD; //UTHUDBase;

/** Used to pulse crosshair size */
var float LastPickupTime;

/** This holds the base material that will be displayed */
var Material BaseMaterial;

/** maximum hit effect color */
var LinearColor MaxHitEffectColor;

/** reference to the hit effect */
var MaterialEffect HitEffect;

/** the amount the time it takes to fade the hit effect from the maximum values (default.HitEffectFadeTime is max) */
var float HitEffectFadeTime;

/** current hit effect intensity (default.HitEffectIntensity is max) */
var float HitEffectIntensity;

/** material instance for the hit effect */
var transient MaterialInstanceConstant HitEffectMaterialInstance;

/** name of the material parameter that controls the fade */
var name FadeParamName;

/** whether we're currently fading out the hit effect */
var bool bFadeOutHitEffect;

/**
 * Holds the various data for each Damage Type
 */
struct native DamageInfo
{
    var float   FadeTime;
    var float   FadeValue;
    var MaterialInstanceConstant MatConstant;
};


/** List of DamageInfos. */
var array<DamageInfo> DamageData;

/** Holds the Max. # of indicators to be shown */
var int MaxNoOfIndicators;

var linearcolor TeamHUDColor;
var bool bHudMessageRendered;
var color TeamTextColor;

/** This will be true if this is the first player */
var bool bIsFirstPlayer;

/** used to pulse the scaled of several hud elements */
var float LastAmmoPickupTime;
var float LastWeaponBarDrawnTime;

/** The Pawn that is currently owning this hud */
var CPPawn PawnOwner;

/** Cached reference to the another hud texture */
var const Texture2D AltHudTexture;

/** Y offsets for local message areas - value above 1 = special position in right top corner of HUD */
var float MessageOffset[9];

// Colors
var const linearcolor RedLinearColor, BlueLinearColor, DMLinearColor, WhiteLinearColor, GoldLinearColor, SilverLinearColor;
var const color LightGoldColor, LightGreenColor;
var Color CanvasRed, CanvasDarkRed, CanvasGreen, CanvasBlue,
          CanvasWhite, CanvasYellow, CanvasLightBlue, CanvasDarkBlue,
          CanvasTalkBlockColor, CanvasBlockColor;
struct SRadarInfo
{
  //var CPPawn CPPawn;
    var CPHackZone HackZone;
    var MaterialInstanceConstant MaterialInstanceConstant;
    var bool DeleteMe;
    var Vector2D Offset;
    var float Opacity;
};

var array<SRadarInfo> RadarInfo;

var CPGFxTeamHUD            HudMovie;
var array<GFxCPPlayerInfo>  PlayerInfoMovies;

var CONST ASColorTransform RED, BLUE, GREEN;

/** Class of HUD Movie object */
var class<CPGFxTeamHUD> HUDClass;

var GFxCPScoreboard     ScoreboardMovie;
var GFxCPBuyMenu        BuyMenuMovie;
var CPIFrontEnd     CPI_FrontEnd;

/** Whether to let actor overlays get drawn this tick */
var bool    bEnableActorOverlays;

/** Cache viewport size to determine if it has changed */
var float ViewX, ViewY;

/** Cached reference to the GRI */
var CPGameReplicationInfo TAGRI;

/** Timestamp of the last time that we caused damage to another player. */
var float LastHitIndicatorTime;

/** If true, we will alter the crosshair when it's over a friendly */
var bool bCrosshairOnFriendly;

/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

/** Make the crosshair green (found valid friendly */
var bool bGreenCrosshair;

/** If true, we will allow Weapons to show their crosshairs */
var bool bCrosshairShow;

/** caches the selected team 0 for MERC 1 for SWAT*/
var int intTeamSelected;

/** TeamIndexes*/
var byte RedTeamIndex, BlueTeamIndex;

var bool bDrawPlayerInfo;

struct EventsArray
{
    var string msg;
    var int startTime;
    var bool active;
};

var array<EventsArray> EventMessages;

struct AdminMessage
{
    var string msg;
    var int startTime;
    var bool active;
};

var AdminMessage CurrentAdminMessage;

struct KillDeathArray
{
    var string msg;
    var int startTime;
    var bool active;
    var PlayerReplicationInfo Player1;
    var PlayerReplicationInfo Player2;
    var Class<CPDamageType> DamageType;
    var bool bLogged;
};

struct FullKillDeathMessageArray
{
    var int x1;
    var int y1;
    var int color1;
    var String msg1;
    var int x2;
    var int y2;
    var int color2;
    var String msg2;
    var int x3;
    var int y3;
    var int color3;
    var String msg3;
    var int x4;
    var int y4;
    var int color4;
    var String msg4;
};

var array<KillDeathArray> KillDeathMessages;

var int KillFontSize;

var Vector2D DeathPositions;
var Vector2D TeamInfoPosition;
var Vector2D RoundTimePosition;
var Vector2D MapTimePosition;
var Vector2D ChatPositions;
var Vector2D EventPositions;
var Font PlayerFont;
var int currSfPlayers;
var int currTerrPlayers;
var int currSfPlayersTotal;
var int currTerrPlayersTotal;
var int currHsPlayers;
var int currHSPlayersTotal;

struct ChatArray
{
    var string playerName;
    var string msg;
    var int startTime;
    var int msgDuration;
    var Color playerNameColor;
    var Color msgColor;
    var bool removeMessage;
    var name msgType;
    var bool enable;
};

var array<ChatArray> ChatMessages;

///** FLASHBANG BEGIN **/
var float FlashEffectFadeTime;
var float FlashEffectIntensity;
var Vector FlashEffectLocation;
var bool bFadeOutFlashEffect;
var float LastFlashStartTime;
var MaterialInstanceConstant FlashbangProcessMaterialInstanceConstant;
var MaterialEffect FlashbangPostProcessEffect; //doesnt need exposing this is only for fixing the texture.
var const PostProcessChain FlashbangPostProcess;
var LinearColor FlashLocation; //the parameters in the udk use LinearColor for setting parameters!!!
var bool blnSetScreenFlashLocation;
var Vector ScreenFlashLocation;
var bool bKillFlashEffect;
///** FLASHBANG END **/

var bool blnPlayerWelcomed;

event PostRender()
{
    local bool bNeedScoreboardMovie;
    local int TeamIndex;
    local LocalPlayer Lp;
    local vector Screen;

    if(CPI_FrontEnd != none && CPI_FrontEnd.bMovieIsOpen)
    {
        CPI_FrontEnd.Tick();
    }
    else
        SetVisible(true);

    //when you first load the game
    if(CPPlayerController(GetALocalPlayerController()).bIsInMenuGame)
    {
        SetVisible(false);
        return;
    }

    RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
    ResolutionScaleX = Canvas.ClipX/1024;
    ResolutionScale = Canvas.ClipY/768;


    // re-create the HUD movie initially and whenever resolution changes
    if ( (ViewX != Canvas.ClipX) || (ViewY != Canvas.ClipY) )
    {
        ViewX = Canvas.ClipX;
        ViewY = Canvas.ClipY;

        bNeedScoreboardMovie =  ScoreboardMovie != None && ScoreboardMovie.bMovieIsOpen;

        RemoveMovies();
        CreateHUDMovie();
        if ( bNeedScoreboardMovie )
        {
            SetShowScores(true);
        }
    }

    TAGRI = CPGameReplicationInfo(WorldInfo.GRI);

    if (HudMovie!=none)
        HudMovie.TickHud(RenderDelta);
    if (ScoreboardMovie!=none && ScoreboardMovie.bMovieIsOpen)
       ScoreboardMovie.Tick(RenderDelta);

    if ( BuyMenuMovie != None && BuyMenuMovie.bMovieIsOpen )
    {
        bCrosshairShow = false;
        BuyMenuMovie.Tick(RenderDelta);
    }

    if (CPI_FrontEnd!=none && CPI_FrontEnd.bMovieIsOpen)
    {
        bCrosshairShow = false;
        CPI_FrontEnd.Tick();
    }

    CheckCloseBuyMenu();

    if ( bShowHud && bEnableActorOverlays )
    {
            DrawHud();
    }

    if (TAGRI != None && TAGRI.bMatchIsOver)
    {
        //force showing the scoreboard
        if( ScoreboardMovie==none || !ScoreboardMovie.bMovieIsOpen)
            SetShowScores(true);

        //make sure we forcefully close the buymenu
        CheckCloseBuyMenu();
    }

    DrawPlayerInformation();

//  if(bool(TASave.GetItemValue("ShowObjectiveInfo"))) //based on the hud options only show if the user has asked to display it
//  {
//      DrawOnscreenObjectives();
//  }

    LastHUDRenderTime = WorldInfo.TimeSeconds;

    Super.PostRender();

    LP = LocalPlayer(PlayerOwner.Player);
    bIsFirstPlayer = (LP != none) && (LP.Outer.GamePlayers[0] == LP);

    // Clear the flag
    bHudMessageRendered = false;

    PawnOwner = CPPawn(PlayerOwner.ViewTarget);
    if ( PawnOwner == None )
    {
        PawnOwner = CPPawn(PlayerOwner.Pawn);
    }
    // draw any debug text in real-time
    PlayerOwner.DrawDebugTextList(Canvas,RenderDelta);

    // Cache the current Team Index of this hud and the GRI
    TeamIndex = 2;
    if ( PawnOwner != None )
    {
        if ( (PawnOwner.PlayerReplicationInfo != None) && (PawnOwner.PlayerReplicationInfo.Team != None) )
        {
            TeamIndex = PawnOwner.PlayerReplicationInfo.Team.TeamIndex;
        }
    }
    else if ( (PlayerOwner.PlayerReplicationInfo != None) && (PlayerOwner.PlayerReplicationInfo.team != None) )
    {
        TeamIndex = PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
    }

    GetTeamColor(TeamIndex, TeamHUDColor, TeamTextColor);

    // Always update the Damage Indicator
    UpdateDamage();

    // ~WillyG: Update flashbang effect if necessary
    if(bKillFlashEffect)
        KillFlashBangEffect();
    else
        UpdateFlashBang();

    // let iphone draw any always present overlays
    if (bShowMobileHud)
    {
        DrawInputZoneOverlays();
    }

    if(CurrentAdminMessage.active == true)
    {
    //  HudMovie.SetCenterTextBottomZone( msg);

        if((WorldInfo.TimeSeconds - CurrentAdminMessage.startTime) < 4.0)
        {
            DisplayAdminMessage();
        }
        else
        {
            CurrentAdminMessage.active = false;
        }
    }

    DrawKillDeathInfo();

    DrawChatMessages();

    DrawEventMessages();

    RenderMobileMenu();

    DrawBombDetonationRemainingBar();

    if(blnSetScreenFlashLocation)
    {
        Screen = Canvas.Project(FlashEffectLocation);
        ScreenFlashLocation.X = 1.0 - ( Screen.X / ViewX ) - 0.5;
        ScreenFlashLocation.Y = 1.0 - ( Screen.Y / ViewY ) - 0.5;

        blnSetScreenFlashLocation = false;
    }
}

function DrawBombDetonationRemainingBar()
{
    local float X, Y;
    local int BombDetonation;


    if(PawnOwner == none)
        return;

    if(PawnOwner.GetTeamNum() != 0)     //only show the detonation time to merc players
        return;

    if(TAGRI == none)
        return;

    if(!TAGRI.bBombPlanted)
        return;

    if(TAGRI.RemainingBombDetonatonTime == TAGRI.default.RemainingBombDetonatonTime)
        return;

    BombDetonation = Round( TAGRI.RemainingBombDetonatonTime );
    if ( BombDetonation < 0 )
        return;

    X = ViewX / 1280.0;
    Y = ViewY / 720.0;
    Canvas.SetDrawColor(200,255,200);
    Canvas.SetPos(590*X,381*Y);
    Canvas.DrawText( "Bomb Detonates in" @ BombDetonation );
}

function DisplayScore(PlayerReplicationInfo myPRI)
{
    local Vector2D TextSize;
    local Vector2D CurPositions;
    local String CurMessage;

    TextSize.X = 0;
    TextSize.Y = 0;
    CurMessage = String(myPRI.Score);
    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
    CurPositions.X = Canvas.ClipX - (Canvas.ClipX * 0.40);
    CurPositions.Y = Canvas.ClipY - (Canvas.ClipY * 0.20);

    // Event Message
    Canvas.Font = GetMyCurrentFont(0);


    DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, CurMessage, SetCanvasTeamColorGetGlow(244));
}

function DisplayAdminMessage()
{
    local Vector2D TextSize;
    local Vector2D CurPositions;
    local String CurMessage;

    TextSize.X = 0;
    TextSize.Y = 0;
    CurMessage = CurrentAdminMessage.msg;
    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
    CurPositions.X = Canvas.ClipX/2 - (TextSize.X/2);
    CurPositions.Y = Canvas.ClipY * 0.09;

    // Event Message
    Canvas.Font = GetMyCurrentFont(0);


    DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, CurMessage, SetCanvasTeamColorGetGlow(244));
}

function DrawEventMessages()
{
    local int i;// Index;
    local Vector2D TextSize;
    local Vector2D CurPositions;
    local String CurMessage;
    local Vector2D StartBoxPosition;

    if(EventMessages.Length > 0)
    {
        TextSize.X = 0;
        TextSize.Y = 0;
        CurPositions.X = EventPositions.X;
        CurPositions.Y = EventPositions.Y*ResolutionScale;

        for(i = 0; i < EventMessages.Length; i++)
        {
            if((WorldInfo.TimeSeconds - EventMessages[i].startTime) > 4.0)
            {
                EventMessages.Remove(i,1);
            }
            else
            {
                if(EventMessages[i].msg != "")
                {
                    // Event Message
                    Canvas.Font = GetMyCurrentFont(0);
                    CurMessage = EventMessages[i].msg;
                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);

                    StartBoxPosition.X = CurPositions.X;
                    StartBoxPosition.Y = CurPositions.Y;
                    Canvas.SetDrawColorStruct(CanvasBlockColor);
                    Canvas.SetPos(StartBoxPosition.X,StartBoxPosition.Y);
                    Canvas.DrawRect(TextSize.X, TextSize.Y);

                    DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, CurMessage, SetCanvasTeamColorGetGlow(244));

                    // Move to next position for next event message
                    CurPositions.Y = CurPositions.Y + TextSize.Y;
                    CurPositions.X = EventPositions.X;
                }
            }
        }
    }
}

function DrawKillDeathInfo()
{
    local int i;// Index;
    local Vector2D TextSize;
    local Vector2D CurPositions;
    local String CurMessage;
    local Vector2D StartBoxPosition;
    local Vector2D SayBoxSize;
    local FullKillDeathMessageArray MyDeathMessage;

    if(Canvas!=none && WorldInfo!= none && KillDeathMessages.Length > 0)
    {
        TextSize.X = 0;
        TextSize.Y = 0;
        CurPositions.X = DeathPositions.X;
        CurPositions.Y = DeathPositions.Y*ResolutionScale;
        StartBoxPosition.X = CurPositions.X;
        StartBoxPosition.Y = CurPositions.Y;

        for(i = 0; i < KillDeathMessages.Length; i++)
        {
            SayBoxSize.X = 0;
            SayBoxSize.Y = 0;
            if((WorldInfo.TimeSeconds - KillDeathMessages[i].startTime) > 8.0)
            {
                KillDeathMessages.Remove(i,1);
            }
            else
            {
                if ((KillDeathMessages[i].Player1 != none && KillDeathMessages[i].Player2 != none) && (KillDeathMessages[i].Player1 != KillDeathMessages[i].Player2) && KillDeathMessages[i].active)
                {
                    // Killer name message
                    Canvas.Font = GetMyCurrentFont(0);
                    CurMessage = " "$KillDeathMessages[i].Player1.PlayerName;
                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
                    //DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, SetCanvasTeamColorGetGlow(KillDeathMessages[i].Player1.Team.TeamIndex), CurMessage);
                    MyDeathMessage.x1 = CurPositions.X;
                    MyDeathMessage.y1 = CurPositions.Y;
                    if(KillDeathMessages[i].Player1.Team != none)
                    {
                        MyDeathMessage.color1 = KillDeathMessages[i].Player1.Team.TeamIndex;
                    }
                    MyDeathMessage.msg1 = CurMessage;
                    SayBoxSize.Y = TextSize.Y;
                    SayBoxSize.X = SayBoxSize.X + TextSize.X;

                    // Killed message
                    CurPositions.X = CurPositions.X + TextSize.X;
                    if (KillDeathMessages[i].Player1.Team != None && KillDeathMessages[i].Player2.Team != None && KillDeathMessages[i].Player1.Team.TeamIndex == KillDeathMessages[i].Player2.Team.TeamIndex)
                    {
                        CurMessage = " teamkilled ";
                    }
                    else
                    {
                        if(KillDeathMessages[i].DamageType != none)
                        {
                            CurMessage = " "$KillDeathMessages[i].DamageType.default.deathAction$" ";
                        }
                        else
                        {
                            CurMessage = " killed ";
                        }
                    }
                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
                    //DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, SetCanvasTeamColorGetGlow(244), CurMessage);
                    MyDeathMessage.x2 = CurPositions.X;
                    MyDeathMessage.y2 = CurPositions.Y;
                    MyDeathMessage.color2 = 244;
                    MyDeathMessage.msg2 = CurMessage;
                    SayBoxSize.X = SayBoxSize.X + TextSize.X;


                    // Player Killed Name message
                    CurPositions.X = CurPositions.X + TextSize.X;
                    CurMessage = KillDeathMessages[i].Player2.PlayerName;
                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
                    //DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y,
                    //                     SetCanvasTeamColorGetGlow(KillDeathMessages[i].Player2.Team.TeamIndex),
                    //                     CurMessage);
                    MyDeathMessage.x3 = CurPositions.X;
                    MyDeathMessage.y3 = CurPositions.Y;
                    MyDeathMessage.color3 = KillDeathMessages[i].Player2.Team.TeamIndex;
                    MyDeathMessage.msg3 = CurMessage;
                    SayBoxSize.X = SayBoxSize.X + TextSize.X;

                    // Weapon killed with message
                    if(KillDeathMessages[i].Player1.Team != None && KillDeathMessages[i].Player2.Team != None && KillDeathMessages[i].Player1.Team.TeamIndex != KillDeathMessages[i].Player2.Team.TeamIndex)
                    {
                        CurPositions.X = CurPositions.X + TextSize.X;
                        if(KillDeathMessages[i].DamageType != none)
                        {
                            CurMessage = " "$KillDeathMessages[i].DamageType.default.deathObject$" ";
                        }
                        else
                        {
                            CurMessage = " unknown object ";
                        }
                        Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
                        //DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y,
                        //                     SetCanvasTeamColorGetGlow(244),
                        //                     CurMessage);
                        MyDeathMessage.x4 = CurPositions.X;
                        MyDeathMessage.y4 = CurPositions.Y;
                        MyDeathMessage.color4 = 244;
                        MyDeathMessage.msg4 = CurMessage;
                        SayBoxSize.X = SayBoxSize.X + TextSize.X;

                        if(CPGameReplicationInfo(WorldInfo.GRI).bShowKillersHealthInMessage && PlayerOwner != None && PlayerOwner.PlayerReplicationInfo == KillDeathMessages[i].Player2)
                        {
                            MyDeathMessage.msg4 $= "(" $ CPPlayerReplicationInfo(KillDeathMessages[i].Player1).CPHealth $ " HP)";
                        }
                    }
                    else
                    {
                        CurPositions.X = CurPositions.X + TextSize.X;
                        MyDeathMessage.x4 = CurPositions.X;
                        MyDeathMessage.y4 = CurPositions.Y;
                        MyDeathMessage.color4 = 244;
                        MyDeathMessage.msg4 = "";
                    }

                    // Move to next position for next kill/death message
                    CurPositions.Y = CurPositions.Y + TextSize.Y;
                    CurPositions.X = DeathPositions.X;

                    Canvas.SetDrawColorStruct(CanvasBlockColor);
                    Canvas.SetPos(StartBoxPosition.X,StartBoxPosition.Y);
                    Canvas.DrawRect(SayBoxSize.X, SayBoxSize.Y);
                    StartBoxPosition.X = CurPositions.X;
                    StartBoxPosition.Y = CurPositions.Y;

                    DrawCanvasTextOnScreen(MyDeathMessage.x1, MyDeathMessage.y1, MyDeathMessage.msg1, SetCanvasTeamColorGetGlow(MyDeathMessage.color1));
                    DrawCanvasTextOnScreen(MyDeathMessage.x2, MyDeathMessage.y2, MyDeathMessage.msg2, SetCanvasTeamColorGetGlow(MyDeathMessage.color2));
                    DrawCanvasTextOnScreen(MyDeathMessage.x3, MyDeathMessage.y3, MyDeathMessage.msg3, SetCanvasTeamColorGetGlow(MyDeathMessage.color3));
                    DrawCanvasTextOnScreen(MyDeathMessage.x4, MyDeathMessage.y4, MyDeathMessage.msg4, SetCanvasTeamColorGetGlow(MyDeathMessage.color4));

                    if(!KillDeathMessages[i].bLogged)
                    {
                        KillDeathMessages[i].bLogged = true;
                        `log(MyDeathMessage.msg1 $ MyDeathMessage.msg2 $ MyDeathMessage.msg3 $ MyDeathMessage.msg4);

                        LocalPlayer( PlayerOwner.Player ).ViewportClient.ViewportConsole.OutputText(MyDeathMessage.msg1 $ MyDeathMessage.msg2 $ MyDeathMessage.msg3 $ MyDeathMessage.msg4);
                    }
                }
                else if((KillDeathMessages[i].Player1 != none && KillDeathMessages[i].Player2 != none) && (KillDeathMessages[i].Player1 == KillDeathMessages[i].Player2) && KillDeathMessages[i].active)
                {
                    // Suicided player name message
                    Canvas.Font = GetMyCurrentFont(0);
                    CurMessage = KillDeathMessages[i].Player1.PlayerName;
                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
                    //DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, SetCanvasTeamColorGetGlow(KillDeathMessages[i].Player2.Team.TeamIndex), CurMessage);
                    MyDeathMessage.x1 = CurPositions.X;
                    MyDeathMessage.y1 = CurPositions.Y;
                    if(KillDeathMessages[i].Player1.Team != none)
                    {
                        MyDeathMessage.color1 = KillDeathMessages[i].Player1.Team.TeamIndex;
                    }
                    MyDeathMessage.msg1 = CurMessage;
                    SayBoxSize.Y = TextSize.Y;
                    SayBoxSize.X = SayBoxSize.X + TextSize.X;

                    // Weapon killed with message
                    CurPositions.X = CurPositions.X + TextSize.X;

                    if(KillDeathMessages[i].DamageType != none)
                    {
                        CurMessage = " killed himself "$KillDeathMessages[i].DamageType.default.deathObject$".";
                    }
                    else
                    {
                        CurMessage = " killed himself.";
                    }

                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
                    //DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, SetCanvasTeamColorGetGlow(244), CurMessage);
                    MyDeathMessage.x2 = CurPositions.X;
                    MyDeathMessage.y2 = CurPositions.Y;
                    MyDeathMessage.color2 = 244;
                    MyDeathMessage.msg2 = CurMessage;
                    SayBoxSize.X = SayBoxSize.X + TextSize.X;

                    // Move to next position for next kill/death message
                    CurPositions.Y = CurPositions.Y + TextSize.Y;
                    CurPositions.X = DeathPositions.X;

                    Canvas.SetDrawColorStruct(CanvasBlockColor);
                    Canvas.SetPos(StartBoxPosition.X,StartBoxPosition.Y);
                    Canvas.DrawRect(SayBoxSize.X, SayBoxSize.Y);
                    StartBoxPosition.X = CurPositions.X;
                    StartBoxPosition.Y = CurPositions.Y;

                    DrawCanvasTextOnScreen(MyDeathMessage.x1, MyDeathMessage.y1, MyDeathMessage.msg1, SetCanvasTeamColorGetGlow(MyDeathMessage.color1));
                    DrawCanvasTextOnScreen(MyDeathMessage.x2, MyDeathMessage.y2, MyDeathMessage.msg2, SetCanvasTeamColorGetGlow(MyDeathMessage.color2));
                }
                // Something besides a player or himself killed this player. Like falling....
                else if((KillDeathMessages[i].Player2 != none) && (KillDeathMessages[i].Player1 == none) && KillDeathMessages[i].active)
                {
                    // Suicided player name message
                    Canvas.Font = GetMyCurrentFont(0);

                    if(KillDeathMessages[i].DamageType != None)
                        CurMessage $= CurMessage $ KillDeathMessages[i].DamageType.default.deathObject $ ".";

                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);
                    //DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, SetCanvasTeamColorGetGlow(KillDeathMessages[i].Player2.Team.TeamIndex), CurMessage);
                    MyDeathMessage.x1 = CurPositions.X;
                    MyDeathMessage.y1 = CurPositions.Y;
                    MyDeathMessage.color1 = KillDeathMessages[i].Player2.Team.TeamIndex;
                    MyDeathMessage.msg1 = CurMessage;
                    SayBoxSize.Y = TextSize.Y;
                    SayBoxSize.X = SayBoxSize.X + TextSize.X;

                    // Weapon killed with message
                    CurPositions.X = CurPositions.X + TextSize.X;

                    Canvas.TextSize(CurMessage, TextSize.X, TextSize.Y);

                    Canvas.SetDrawColorStruct(CanvasBlockColor);
                    Canvas.SetPos(StartBoxPosition.X,StartBoxPosition.Y);
                    Canvas.DrawRect(SayBoxSize.X, SayBoxSize.Y);
                    StartBoxPosition.X = CurPositions.X;
                    StartBoxPosition.Y = CurPositions.Y;

                    DrawCanvasTextOnScreen(MyDeathMessage.x1, MyDeathMessage.y1, MyDeathMessage.msg1, SetCanvasTeamColorGetGlow(MyDeathMessage.color1));
                }
            }
        }
    }
}

function DrawChatMessages()
{
    local int i;// Index;
    local Vector2D TextSize;
    local Vector2D CurPositions;
    local Color HighLightColor;
    HighLightColor.R = 250;
    HighLightColor.G = 250;
    HighLightColor.B = 250;
    HighLightColor.A = 180;

    if(ChatMessages.Length > 0)
    {
        TextSize.X = 0;
        TextSize.Y = 0;
        CurPositions.X = ChatPositions.X;
        CurPositions.Y = ChatPositions.Y*ResolutionScale;

        for(i = 0; i < ChatMessages.Length; i++)
        {
            // Wait till message is enabled before trying to display message
            if((ChatMessages[i].enable != true) || (ChatMessages[i].playerName == ""))
            {
            }
            // Remove chat message if it has timedout
            else if((WorldInfo.TimeSeconds - ChatMessages[i].startTime) > ChatMessages[i].msgDuration)
            {
                // Remove message from array
                ChatMessages.Remove(i,1);
            }
            // Draw chat
            else
            {
                    // Player Chat Name
                    Canvas.Font = GetMyCurrentFont(0);
                    Canvas.TextSize((ChatMessages[i].playerName$ChatMessages[i].msg), TextSize.X, TextSize.Y);

                    // Do not Handle admin. Admin will be straight yellow. No highlight
                    if(ChatMessages[i].msgType != 'Admin')
                    {
                        // Get color of Player name
                        Canvas.SetDrawColorStruct(ChatMessages[i].playerNameColor);
                        Canvas.TextSize(ChatMessages[i].playerName, TextSize.X, TextSize.Y);
                        // Draw highlight of the playerName message
                        DrawCanvasTextOnScreen(CurPositions.X-1, CurPositions.Y-1, ChatMessages[i].playerName);
                        DrawCanvasTextOnScreen(CurPositions.X+1, CurPositions.Y+1, ChatMessages[i].playerName);
                        DrawCanvasTextOnScreen(CurPositions.X-1, CurPositions.Y+1, ChatMessages[i].playerName);
                        DrawCanvasTextOnScreen(CurPositions.X+1, CurPositions.Y-1, ChatMessages[i].playerName);

                        // Draw Player name over the highlight.
                        Canvas.SetDrawColorStruct(HighLightColor);
                        DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, ChatMessages[i].playerName);

                    }
                    else
                    {
                        // Draw admin message
                        Canvas.SetDrawColorStruct(ChatMessages[i].playerNameColor);
                        Canvas.TextSize(ChatMessages[i].playerName, TextSize.X, TextSize.Y);
                        DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, ChatMessages[i].playerName);
                    }

                    // Do not draw second part of the string if empty. Some of the messages are combined with the
                    // playername since they will all be same color. Like spectating, admin, or teamsay
                    if(ChatMessages[i].msg != "")
                    {
                        CurPositions.X = CurPositions.X + TextSize.X;
                        Canvas.SetDrawColorStruct(ChatMessages[i].msgColor);
                        DrawCanvasTextOnScreen(CurPositions.X, CurPositions.Y, ChatMessages[i].msg);
                    }

                    // Move to next position for next chat message
                    CurPositions.Y = CurPositions.Y + TextSize.Y;
                    CurPositions.X = ChatPositions.X;
            }
        }
    }
}

function SetMapAndRoundTime(String Maptime, String Roundtime)
{
    local Vector2D TextSizeMap;
    local Vector2D TextSizeRound;
    local Vector2D CurPositions;
    local Vector2D BoxSize;

    // Get font
    Canvas.Font = GetMyCurrentFont(0);
    // Get size of first message which will be the largest;
    Canvas.TextSize("MAP: "$Maptime, TextSizeMap.X, TextSizeMap.Y);
    // Get size of first message which will be the largest;
    Canvas.TextSize("ROUND: "$Roundtime, TextSizeRound.X, TextSizeRound.Y);

    // Use message size to display message away from edge of screen
    CurPositions.Y = (MapTimePosition.Y*ResolutionScale);

    BoxSize.Y = TextSizeMap.Y + 3;
    BoxSize.X = TextSizeMap.X + TextSizeRound.X + 20 + 6;
    Canvas.SetDrawColor(255,255,255,160);
    Canvas.SetPos(ViewX-TextSizeRound.X-10-TextSizeMap.X-20-3, CurPositions.Y-3);
    Canvas.DrawBox(BoxSize.X, BoxSize.Y);
    Canvas.SetDrawColorStruct(CanvasBlockColor);
    Canvas.SetPos(ViewX-TextSizeRound.X-10-TextSizeMap.X-20-3, CurPositions.Y-3);
    Canvas.DrawRect(BoxSize.X, BoxSize.Y);
    //DrawRoundTimeMessage
    DrawCanvasTextOnScreen(ViewX-TextSizeMap.X-10, CurPositions.Y, "MAP: "$Maptime, SetCanvasTeamColorGetGlow(244));
    DrawCanvasTextOnScreen(ViewX-TextSizeRound.X-10-TextSizeMap.X-20, CurPositions.Y, "ROUND: "$Roundtime, SetCanvasTeamColorGetGlow(244));
}

function DrawCanvasTextOnScreen(int xPos, int yPos, String message, optional FontRenderInfo NewRenderInfo, optional float scaleX = 1.0, optional float scaleY = 1.0)
{
    Canvas.SetPos(xPos,yPos);
    Canvas.DrawText(message, , scaleX, scaleY, NewRenderInfo);
}

function DrawTeamInfo()
{
    local Vector2D TextSize;
    local String SwatMessage;
    local String TerrMessage;
    local Vector2D CurPositions;

    // Could valid players to display on Team Info
    CountValidPlayers();
    // Don't draw team info until we have valid players
    if(currSfPlayersTotal == 0 && currTerrPlayersTotal == 0)
        return;

    // Determine messages to display
    SwatMessage = "Swat"@currSfPlayers@"("$ currSfPlayersTotal $")";
    TerrMessage = "Merc"@currTerrPlayers@"("$ currTerrPlayersTotal $")";

    // Get font
    Canvas.Font = GetMyCurrentFont(0);
    // Get size of first message which will be the largest;
    Canvas.TextSize(SwatMessage, TextSize.X, TextSize.Y);
    // Use message size to display message away from edge of screen
    CurPositions.Y = ViewY-(TeamInfoPosition.Y*ResolutionScale);
    //DrawSfMessage
    DrawCanvasTextOnScreen(ViewX-TextSize.X-10, CurPositions.Y,              SwatMessage, SetCanvasTeamColorGetGlow(BlueTeamIndex));
    //DrawTerrMessage
    DrawCanvasTextOnScreen(ViewX-TextSize.X-10, CurPositions.Y + TextSize.Y, TerrMessage, SetCanvasTeamColorGetGlow(RedTeamIndex));
}

function DrawSpectatingInfo(string Text , string colorText)
{
    local Vector2D TextSize;
    local Vector2D CurPositions;
	local float TextScale;

    TextScale = 1.58;
	// Get font
    Canvas.Font = GetMyCurrentFont(0);
    // Get size of first message which will be the largest;
    Canvas.TextSize(Text, TextSize.X, TextSize.Y);
    // Use message size to display message away from edge of screen
    CurPositions.Y = ViewY/14;
    //DrawSfMessage
    if(colorText == "BLUE")
        DrawCanvasTextOnScreen(ViewX/2-TextSize.X/2*TextScale, CurPositions.Y, Text, SetCanvasTeamColorGetGlow(BlueTeamIndex), TextScale, TextScale);
    else if(colorText == "RED")
        DrawCanvasTextOnScreen(ViewX/2-TextSize.X/2*TextScale, CurPositions.Y, Text, SetCanvasTeamColorGetGlow(RedTeamIndex), TextScale, TextScale);
    else if(colorText == "GREEN")
        DrawCanvasTextOnScreen(ViewX/2-TextSize.X/2*TextScale, CurPositions.Y, Text, SetCanvasTeamColorGetGlow(200), TextScale, TextScale);

}

function CountValidPlayers()
{
    local int sfPlayers;
    local int terrPlayers;
    local int hostagePlayers;
    local int sfPlayersTotal;
    local int terrPlayersTotal;
    local int hostagePlayersTotal;

    local CPPlayerReplicationInfo PRI;
    local int i;
    sfPlayers = 0;
    terrPlayers = 0;

    if ( TAGRI == None )
    {
        return;
    }

    for (i=0; i < TAGRI.PRIArray.Length; i++)
    {
        PRI = CPPlayerReplicationInfo(TAGRI.PRIArray[i]);
        if ( PRI == none || (!PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
        (PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None))) )
        {
        }
        else
        {
            if(PRI.Team != None && PRI.Team.TeamIndex == 2 && !PRI.bOnlySpectator)
            {
                if(!PRI.bIsSpectator && !PRI.bOutOfLives && !PRI.bHasEscaped)
                {
                    hostagePlayers++;
                }

                hostagePlayersTotal++;
            }
            else if(PRI.Team != None && PRI.Team.TeamIndex == 1 && !PRI.bOnlySpectator)
            {
                if(!PRI.bIsSpectator && !PRI.bOutOfLives)
                {
                    sfPlayers++;
                }

                sfPlayersTotal++;
            }
            else if(PRI.Team != None && PRI.Team.TeamIndex == 0 && !PRI.bOnlySpectator)
            {
                if(!PRI.bIsSpectator && !PRI.bOutOfLives)
                {
                    terrPlayers++;
                }

                terrPlayersTotal++;
            }
        }
    }

    currSfPlayers = sfPlayers;
    currTerrPlayers = terrPlayers;
    currSfPlayersTotal = sfPlayersTotal;
    currTerrPlayersTotal = terrPlayersTotal;
    currHsPlayers = hostagePlayers;
    currHSPlayersTotal = hostagePlayersTotal;
}

function FontRenderInfo SetCanvasTeamColorGetGlow(int teamColor)
{
    if(teamColor == BlueTeamIndex)
    {
        Canvas.SetDrawColorStruct(CanvasBlue);
        return Canvas.CreateFontRenderInfo(,true);
    }
    else if(teamColor == 244)
    {
        Canvas.SetDrawColorStruct(CanvasWhite);
        return Canvas.CreateFontRenderInfo(,true);
    }
    else if(teamColor == 200 || teamColor == 2)
    {
        Canvas.SetDrawColorStruct(CanvasGreen);
        return Canvas.CreateFontRenderInfo(,true);
    }
    else
    {
        Canvas.SetDrawColorStruct(CanvasRed);
        return Canvas.CreateFontRenderInfo(,true);
    }
}

function Font GetMyCurrentFont(int type)
{
    if(type == 0)
    {
        if(Canvas.ClipX >= 1280)
        {
            return class'Engine'.static.GetSmallFont();
        }
        else if(Canvas.ClipX >= 800)
        {
            return class'Engine'.static.GetTinyFont();
        }
        else
        {
            return class'Engine'.static.GetLargeFont();
        }
    }
    else
    {
        return class'Engine'.static.GetSubtitleFont();
    }

    return class'Engine'.static.GetSubtitleFont();
}

exec function DevChangeHudColors(int type,byte R,byte G,byte B,byte A)
{
    if(type == 1)
    {   //CanvasRed=(R=255,G=0,B=0,A=255)
        CanvasRed.R = R;
        CanvasRed.G = G;
        CanvasRed.B = B;
        CanvasRed.A = A;
    }
    else if(type == 2)
    {   //CanvasBlue=(R=0,G=0,B=255,A=255)
        CanvasBlue.R = R;
        CanvasBlue.G = G;
        CanvasBlue.B = B;
        CanvasBlue.A = A;
    }
    else if(type == 3)
    {
        //CanvasGreen=(R=0,G=128,B=0,A=255)
        CanvasGreen.R = R;
        CanvasGreen.G = G;
        CanvasGreen.B = B;
        CanvasGreen.A = A;
    }
    else if(type == 4)
    {
        //CanvasBlockColor=(R=255,G=255,B=255,A=100)
        CanvasBlockColor.R = R;
        CanvasBlockColor.G = G;
        CanvasBlockColor.B = B;
        CanvasBlockColor.A = A;
    }
    else if(type == 5)
    {
        //CanvasTalkBlockColor=(R=227,G=227,B=227,A=200)
        CanvasTalkBlockColor.R = R;
        CanvasTalkBlockColor.G = G;
        CanvasTalkBlockColor.B = B;
        CanvasTalkBlockColor.A = A;
    }
    else
    {
        //CanvasWhite=(R=255,G=255,B=255,A=255)
        CanvasWhite.R = R;
        CanvasWhite.G = G;
        CanvasWhite.B = B;
        CanvasWhite.A = A;
    }
}

exec function DevChangeKillSize(int size)
{
    if(size < 10)
    {
        KillFontSize = size;
    }
}

exec function DevChangeKillLocation(int type, int x, int y)
{
    if(type == 1)
    {
    DeathPositions.X = x;
    DeathPositions.Y = y;
    }
    else
    {
        TeamInfoPosition.X = x;
        TeamInfoPosition.Y = y;
    }
}

/**
 * Update Damage always needs to be called
 */
function UpdateDamage()
{
    local int i;
    local float HitAmount;
    local LinearColor HitColor;

    for (i=0; i<MaxNoOfIndicators; i++)
    {
        if (DamageData[i].FadeTime > 0)
        {
            DamageData[i].FadeValue += ( 0 - DamageData[i].FadeValue) * (RenderDelta / DamageData[i].FadeTime);
            DamageData[i].FadeTime -= RenderDelta;
            DamageData[i].MatConstant.SetScalarParameterValue(FadeParamName,DamageData[i].FadeValue);
        }
    }

    // Update the color/fading on the full screen distortion
    if (bFadeOutHitEffect)
    {
        HitEffectMaterialInstance.GetScalarParameterValue('HitAmount', HitAmount);
        HitAmount -= HitEffectIntensity * RenderDelta / HitEffectFadeTime;

        if (HitAmount <= 0.0)
        {
            HitEffect.bShowInGame = false;
            bFadeOutHitEffect = false;
        }
        else
        {
            HitEffectMaterialInstance.SetScalarParameterValue('HitAmount', HitAmount);
            // now scale the color
            HitEffectMaterialInstance.GetVectorParameterValue('HitColor', HitColor);
            HitColor = HitColor - MaxHitEffectColor * (RenderDelta / HitEffectFadeTime);
            HitEffectMaterialInstance.SetVectorParameterValue('HitColor', HitColor);
        }
    }
}

function DrawPlayerInformation()
{
    local CPPawn  TPawn;
    local Vector  Delta;
    local Vector  Output;
    local Vector  Screen;
    local Vector  CamLoc;
    local Vector  CamDir;
    local Rotator CamRot;
    local bool    Aiming;
    local float   Length;
    local float   DProd;
    local int     i;
    local CPSaveManager CPSaveManager;


    for ( i = 0; i < PlayerInfoMovies.Length; i++ )
        PlayerInfoMovies[i].SetVisible( false );

    CPSaveManager = new class'CPSaveManager';
    bDrawPlayerInfo = CPSaveManager.GetBool("DrawPlayerInfo");

    if ( !bDrawPlayerInfo )
        return;

    if ( PlayerOwner == none || PlayerOwner.Pawn == none )
        return;

    PlayerOwner.GetPlayerViewPoint( CamLoc, CamRot );
    CamDir = Vector( CamRot );

    i = 0;
    foreach AllActors( class'CPPawn', TPawn )
    {
        if ( TPawn == PlayerOwner.Pawn || TPawn.Health == 0 || !TPawn.IsSameTeam( PlayerOwner.Pawn ) )
            continue;


        Delta = TPawn.Location - CamLoc;
        Length = VSize( Delta );
        DProd = Normal( Delta ) dot CamDir;
        if ( DProd <= 0 ) // Are we facing the player?
            continue;

        // Is the player visible?
        if ( Trace( Output, Delta, CamLoc, TPawn.Location, false ) != none )
            continue;

        // Calculate the Screen Position
        Screen = TPawn.Location + TPawn.GetCollisionHeight() * vect( 0, 0, -1 );
        Screen = Canvas.Project( Screen );

        // Check if we're aiming at the player by doing a BoundingSphere radius check
        Aiming = VSize( TPawn.Location - ( CamLoc + CamDir * Length ) ) <= 60.0f + ( Length / 1024.0f );

        if ( !Aiming )
        {
            Screen.Y -= 10.0f;
            PlayerInfoMovies[i].SetBarsOpacity( 0.0f );
        }
        else
        {
            PlayerInfoMovies[i].SetBarsOpacity( 100.0f );
        }

        PlayerInfoMovies[i].SetVisible( true );
        PlayerInfoMovies[i].SetPosition( FCeil( Screen.X ), FCeil( Screen.Y ) );
        PlayerInfoMovies[i].SetHealthPercent( TPawn.Health );
        PlayerInfoMovies[i].SetPlayerName( TPawn.PlayerReplicationInfo.PlayerName );
        i++;
    }
}

function AddPostRenderedActor(Actor A)
{
    // Remove post render call for CPPawns as we don't want the name bubbles showing
    if (CPPawn(A) != None)
    {
        return;
    }

    Super.AddPostRenderedActor(A);
}


event DrawOnscreenObjectives()
{
  local int i;//, Index;
  local Vector WorldHUDLocation, ScreenHUDLocation, ActualPointerLocation, CameraViewDirection, PawnDirection, CameraLocation;
  local Rotator CameraRotation;
  local CPHackZone HackZone;
  //local LinearColor TeamLinearColor;
  local float PointerSize;


  if (PlayerOwner == None || PlayerOwner.Pawn == None)
  {
    return;
  }

  // Set all radar infos to delete if not found
  for (i = 0; i < RadarInfo.Length; ++i)
  {
    RadarInfo[i].DeleteMe = true;
  }

  // Update the radar infos and see if we need to add or remove any
  ForEach DynamicActors(class'CPHackZone', HackZone)
  {
    //if (CPPawn != PlayerOwner.Pawn)
    //{

      //Index = RadarInfo.Find('HackZone', HackZone);
      // This objective was not found in our radar infos, so add it
      //if ( Index == INDEX_NONE)
      //{
        i = RadarInfo.Length;
        RadarInfo.Length = RadarInfo.Length + 1;
        RadarInfo[i].HackZone = HackZone;
        RadarInfo[i].MaterialInstanceConstant = new () class'MaterialInstanceConstant';

        if (RadarInfo[i].MaterialInstanceConstant != None)
        {
//          RadarInfo[i].MaterialInstanceConstant.SetParent(Material'GemOnscreenRadarContent.PointerMaterial');

          //if (CPPawn.PlayerReplicationInfo != None && CPPawn.PlayerReplicationInfo.Team != None)
          //{
          //  TeamLinearColor = (CPPawn.PlayerReplicationInfo.Team.TeamIndex == 0) ? Default.RedLinearColor : Default.BlueLinearColor;
          //  RadarInfo[i].MaterialInstanceConstant.SetVectorParameterValue('TeamColor', TeamLinearColor);
          //}
          //else
          //{
            RadarInfo[i].MaterialInstanceConstant.SetVectorParameterValue('TeamColor', Default.DMLinearColor);
          //}
        }

        RadarInfo[i].DeleteMe = false;
      //}
      //else if (CPPawn.Health > 0)
      //{
      //  RadarInfo[Index].DeleteMe = false;
      //}
    //}
  }

  // Handle rendering of all of the radar infos
  PointerSize = Canvas.ClipX * 0.083f;
  PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraRotation);
  CameraViewDirection = Vector(CameraRotation);

  for (i = 0; i < RadarInfo.Length; ++i)
  {
    if (!RadarInfo[i].DeleteMe)
    {
      if (RadarInfo[i].HackZone != None && RadarInfo[i].MaterialInstanceConstant != None)
      {
        // Handle the opacity of the pointer. If the player cannot see this pawn,
        // then fade it out half way, otherwise if he can, fade it in
        //if (WorldInfo.TimeSeconds - RadarInfo[i].HackZone.LastRenderTime > 0.1f)
        //{
        //  // Player has not seen this pawn in the last 0.1 seconds
        //  RadarInfo[i].Opacity = Lerp(RadarInfo[i].Opacity, 0.4f, RenderDelta * 4.f);
        //}
        //else
        //{
        //  // Player has seen this pawn in the last 0.1 seconds
        //  RadarInfo[i].Opacity = Lerp(RadarInfo[i].Opacity, 1.f, RenderDelta * 4.f);
        //}
        //// Apply the opacity
        //RadarInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Opacity', RadarInfo[i].Opacity);

        // Get the direction from the player's pawn to the pawn
        PawnDirection = Normal(RadarInfo[i].HackZone.Location - PlayerOwner.Pawn.Location);

        // Check if the pawn is in front of me
        if (PawnDirection dot CameraViewDirection >= 0.f)
        {
          // Get the world HUD location, which is just above the pawn's head
          WorldHUDLocation = RadarInfo[i].HackZone.Location /*+ (RadarInfo[i].HackZone.GetCollisionHeight() * Vect(0.f, 0.f, 1.f))*/;
          // Project the world HUD location into screen HUD location
          ScreenHUDLocation = Canvas.Project(WorldHUDLocation);

          // If the screen HUD location is more to the right, then swing it to the left
          if (ScreenHUDLocation.X > (Canvas.ClipX * 0.5f))
          {
            RadarInfo[i].Offset.X -= PointerSize * RenderDelta * 4.f;
          }
          else
          {
            // If the screen HUD location is more to the left, then swing it to the right
            RadarInfo[i].Offset.X += PointerSize * RenderDelta * 4.f;
          }
          RadarInfo[i].Offset.X = FClamp(RadarInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);

          // Set the rotation of the material icon
          ActualPointerLocation.X = Clamp(ScreenHUDLocation.X, 8, Canvas.ClipX - 8) + RadarInfo[i].Offset.X;
          ActualPointerLocation.Y = Clamp(ScreenHUDLocation.Y - PointerSize + RadarInfo[i].Offset.Y, 8, Canvas.ClipY - 8 - PointerSize) + (PointerSize * 0.5f);
          RadarInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Rotation', GetAngle(ActualPointerLocation, ScreenHUDLocation));

          // Draw the material pointer
          Canvas.SetPos(ActualPointerLocation.X - (PointerSize * 0.5f), ActualPointerLocation.Y - (PointerSize * 0.5f));
          Canvas.DrawMaterialTile(RadarInfo[i].MaterialInstanceConstant, PointerSize, PointerSize, 0.f, 0.f, 1.f, 1.f);
        }
        else
        {
          // Handle rendering the on screen indicator when the actor is behind the camera
          // Project the pawn's location
          ScreenHUDLocation = Canvas.Project(RadarInfo[i].HackZone.Location);

          // Inverse the Screen HUD location
          ScreenHUDLocation.X = Canvas.ClipX - ScreenHUDLocation.X;

          // If the screen HUD location is on the right edge, then swing it to the left
          if (ScreenHUDLocation.X > (Canvas.ClipX - 8))
          {
            RadarInfo[i].Offset.X -= PointerSize * RenderDelta * 4.f;
            RadarInfo[i].Offset.X = FClamp(RadarInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
          }
          else if (ScreenHUDLocation.X < 8)
          {
            // If the screen HUD location is on the left edge, then swing it to the right
            RadarInfo[i].Offset.X += PointerSize * RenderDelta * 4.f;
            RadarInfo[i].Offset.X = FClamp(RadarInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
          }
          else
          {
            // If the screen HUD location is somewhere in the middle, then straighten it up
            RadarInfo[i].Offset.X = Lerp(RadarInfo[i].Offset.X, 0.f, 4.f * RenderDelta);
          }

          // Set the screen HUD location
          ScreenHUDLocation.X = Clamp(ScreenHUDLocation.X, 8, Canvas.ClipX - 8);
          ScreenHUDLocation.Y = Canvas.ClipY - 8;

          // Set the actual pointer location
          ActualPointerLocation.X = ScreenHUDLocation.X + RadarInfo[i].Offset.X;
          ActualPointerLocation.Y = ScreenHUDLocation.Y - (PointerSize * 0.5f);

          // Set the rotation of the material icon
          RadarInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Rotation', GetAngle(ActualPointerLocation, ScreenHUDLocation));

          // Draw the material pointer
          Canvas.SetPos(ActualPointerLocation.X - (PointerSize * 0.5f), ActualPointerLocation.Y - (PointerSize * 0.5f));
          Canvas.DrawMaterialTile(RadarInfo[i].MaterialInstanceConstant, PointerSize, PointerSize, 0.f, 0.f, 1.f, 1.f);
        }
      }
    }
    else
    {
      // Null the variables previous stored so garbage collection can occur
      RadarInfo[i].HackZone = None;
      RadarInfo[i].MaterialInstanceConstant = None;
      // Remove from the radar info array
      RadarInfo.Remove(i, 1);
      // Back step one, to maintain the for loop
      --i;
    }
  }
}



function float GetAngle(Vector PointB, Vector PointC)
{
  // Check if angle can easily be determined if it is up or down
  if (PointB.X == PointC.X)
  {
    return (PointB.Y < PointC.Y) ? Pi : 0.f;
  }

  // Check if angle can easily be determined if it is left or right
  if (PointB.Y == PointC.Y)
  {
    return (PointB.X < PointC.X) ? (Pi * 1.5f) : (Pi * 0.5f);
  }

  return (2.f * Pi) - atan2(PointB.X - PointC.X, PointB.Y - PointC.Y);
}

/**
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
    return class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
}

/**
  * Call PostRenderFor() on actors that want it.
  */
event DrawHUD()
{
    local vector ViewPoint;
    local rotator ViewRotation;
    local float XL, YL, YPos;

    if (TAGRI != None && !TAGRI.bMatchIsOver  )
    {
        Canvas.Font = GetFontSizeIndex(0);
        PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
        DrawActorOverlays(Viewpoint, ViewRotation);
    }

    if ( bCrosshairOnFriendly )
    {
        // verify that crosshair trace might hit friendly
        bGreenCrosshair = CheckCrosshairOnFriendly();
        bCrosshairOnFriendly = false;
    }
    else
    {
        bGreenCrosshair = false;
    }

    if( HudMovie != none)
    {
        if ( HudMovie.bDrawWeaponCrosshairs )
        {
            PlayerOwner.DrawHud(self);
        }
    }


    if((PlayerOwner.PlayerReplicationInfo != none) && (PlayerOwner.PlayerReplicationInfo.bIsSpectator || PlayerOwner.PlayerReplicationInfo.bOnlySpectator))
    {
        if( (Pawn(PlayerOwner.ViewTarget) != None) && (Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo != None) && (PlayerOwner.ViewTarget != self))
        {
            if (Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.Team != None)
            {
                if(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.Team.TeamIndex == BlueTeamIndex)
                {
                        //if( HudMovie != none)
                    DrawSpectatingInfo( "Spectating: "$Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.PlayerName, "BLUE");
                           //HudMovie.SetCenterTextBottom( "Spectating: "$Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.PlayerName, BLUE);
                }
                else if(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.Team.TeamIndex == RedTeamIndex)
                {
                          //if( HudMovie != none)
                    DrawSpectatingInfo( "Spectating: "$Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.PlayerName, "RED");
                          //HudMovie.SetCenterTextBottom( "Spectating: "$Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.PlayerName, RED);
                }
             }
        }
        else
        {
            if(TAGRI != none && !TAGRI.bRoundIsOver)
                DrawSpectatingInfo( "GhostCam", "GREEN");
                //HudMovie.SetCenterTextBottom( "GhostCam", GREEN);
        }
    }

    // Show team info
    CountValidPlayers(); //used for scaleform.
    //DrawTeamInfo();

    if ( bShowDebugInfo )
    {
        Canvas.Font = GetFontSizeIndex(0);
        Canvas.DrawColor = ConsoleColor;
        Canvas.StrLen("X", XL, YL);
        YPos = 0;
        PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

        if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
        {
            DrawRoute(Pawn(PlayerOwner.ViewTarget));
        }
        return;
    }
}

function SetAdminBroadcastMessage(string msg)
{
    if(CurrentAdminMessage.active)
    {
        CurrentAdminMessage.startTime = WorldInfo.TimeSeconds;
        CurrentAdminMessage.active = true;
        CurrentAdminMessage.msg = msg;
    }
    else
    {
        CurrentAdminMessage.msg = msg;
        CurrentAdminMessage.startTime = WorldInfo.TimeSeconds;
        CurrentAdminMessage.active = true;
    }

    //if(CurrentAdminMessage.active == true)
    //{
    //  HudMovie.SetCenterTextBottomZone( msg);

    //  if((WorldInfo.TimeSeconds - CurrentAdminMessage.startTime) > 4.0)
    //  {

    //  }
    //  else
    //  {
    //      CurrentAdminMessage.active == false;
    //  }
    //}
}

function AddCanvasEventMsg(string msg)
{
    if(EventMessages.Length == 0)
    {
        EventMessages.Length = EventMessages.Length + 1;
        EventMessages[0].msg = msg;
        EventMessages[0].startTime = WorldInfo.TimeSeconds;
        EventMessages[0].active = true;
        //`Log("CPHUD::AddEventMsg first Message msgNumbers="@EventMessages.Length);
    }
    else
    {
        if(EventMessages.Length >= 5)
        {
            EventMessages.Remove(0,1);
            EventMessages.Length = EventMessages.Length + 1;
            EventMessages[EventMessages.Length-1].msg = msg;
            EventMessages[EventMessages.Length-1].startTime = WorldInfo.TimeSeconds;
            EventMessages[EventMessages.Length-1].active = true;
            //`Log("CPHUD::AddEventMsg reached end of messages="@EventMessages.Length);
        }
        else
        {
            EventMessages.Length = EventMessages.Length + 1;
            EventMessages[EventMessages.Length-1].msg = msg;
            EventMessages[EventMessages.Length-1].startTime = WorldInfo.TimeSeconds;
            EventMessages[EventMessages.Length-1].active = true;
            //`Log("CPHUD::AddEventMsg appending to next messages="@EventMessages.Length);
        }
    }
}

function AddCanvasKillDeathMsg(string msg,
                               optional PlayerReplicationInfo   RelatedPRI_1,
                               optional PlayerReplicationInfo   RelatedPRI_2,
                               optional object          OptionalObject)
{
    if((RelatedPRI_2 != none) && (RelatedPRI_2.Team != none))
    {
        if(KillDeathMessages.Length == 0)
        {
            KillDeathMessages.Length = KillDeathMessages.Length + 1;
            KillDeathMessages[0].msg = msg;
            KillDeathMessages[0].startTime = WorldInfo.TimeSeconds;
            KillDeathMessages[0].Player1 = RelatedPRI_1;
            KillDeathMessages[0].Player2 = RelatedPRI_2;
            KillDeathMessages[0].DamageType = Class<CPDamageType>(OptionalObject);
            KillDeathMessages[0].active = true;

            //`Log("CPHUD::AddCanvasKillDeathMsg first Message msgNumbers="@KillDeathMessages.Length);
        }
        else
        {
            if(KillDeathMessages.Length >= 5)
            {
                KillDeathMessages.Remove(0,1);
                KillDeathMessages.Length = KillDeathMessages.Length + 1;
                KillDeathMessages[KillDeathMessages.Length-1].msg = msg;
                KillDeathMessages[KillDeathMessages.Length-1].startTime = WorldInfo.TimeSeconds;
                KillDeathMessages[KillDeathMessages.Length-1].Player1 = RelatedPRI_1;
                KillDeathMessages[KillDeathMessages.Length-1].Player2 = RelatedPRI_2;
                KillDeathMessages[KillDeathMessages.Length-1].DamageType = Class<CPDamageType>(OptionalObject);
                KillDeathMessages[KillDeathMessages.Length-1].active = true;
                //`Log("CPHUD::AddCanvasKillDeathMsg reached end of messages="@KillDeathMessages.Length);
            }
            else
            {
                KillDeathMessages.Length = KillDeathMessages.Length + 1;
                KillDeathMessages[KillDeathMessages.Length-1].msg = msg;
                KillDeathMessages[KillDeathMessages.Length-1].startTime = WorldInfo.TimeSeconds;
                KillDeathMessages[KillDeathMessages.Length-1].Player1 = RelatedPRI_1;
                KillDeathMessages[KillDeathMessages.Length-1].Player2 = RelatedPRI_2;
                KillDeathMessages[KillDeathMessages.Length-1].DamageType = Class<CPDamageType>(OptionalObject);
                KillDeathMessages[KillDeathMessages.Length-1].active = true;
                //`Log("CPHUD::AddCanvasKillDeathMsg appending to next messages="@KillDeathMessages.Length);
            }
        }
    }
}

function LocalizedMessage
(
    class<LocalMessage>     InMessageClass,
    PlayerReplicationInfo   RelatedPRI_1,
    PlayerReplicationInfo   RelatedPRI_2,
    string                  CriticalString,
    int                     Switch,
    float                   Position,
    float                   LifeTime,
    int                     FontSize,
    color                   DrawColor,
    optional object         OptionalObject
)
{
    local class<CPLocalMessage> TAMessageClass;

    TAMessageClass = class<CPLocalMessage>(InMessageClass);

    //if (InMessageClass == class'UTMultiKillMessage')
    //  HudMovie.ShowMultiKill(Switch, "Kill Streak!");
    //else

    if(InMessageClass == none)
    {
        `Log("Invalid InMessageClass message class. Unhandled message!!");
    }
    //else if (ClassIsChildOf (InMessageClass, class'CPMsg_Death'))
    //{
        //if( (HudMovie != none) && (OptionalObject != none) )
        //{
        //  HudMovie.AddDeathMessage (RelatedPRI_1, RelatedPRI_2, class<CPDamageType>(OptionalObject));
        //}
    //}
    else  if ((TAMessageClass == None) || (TAMessageClass.default.MessageArea > 8) )
    {
        //this is for events. like player joined / left or admin logged in etc
        //if( HudMovie != none)
        //  HudMovie.AddEventMessage("text", InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
        //`Log(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
        AddCanvasEventMsg(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
    }
    // Handle Kill/Death/Suicide messages
    else if (TAMessageClass.default.MessageArea == 8)
    {
        AddCanvasKillDeathMsg(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject),
                              RelatedPRI_1, RelatedPRI_2, OptionalObject);
        //log message locally
        //`Log(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
    }
    else if (TAMessageClass.default.MessageArea < 4)
    {
        if(Switch == 6)
        {
            if( HudMovie != none)
            {
                if(OptionalObject != none)
                {
                    HudMovie.ShowMajorEventMessage( StringHolder(OptionalObject).str);
                }
            }
        }
        else
        {
            if( HudMovie != none)
                HudMovie.SetCenterText(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
        }
    }                                       //5 is pickup messages
    else if (TAMessageClass.default.MessageArea == 4 || TAMessageClass.default.MessageArea == 5)
    {
        //use the botttom center notify zone for these messages.
        if( HudMovie != none)
            HudMovie.SetCenterTextBottomZone(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
    }
    else
    {
        `Log("unhandled message!! - MessageArea is " @ TAMessageClass.default.MessageArea);
    }

}

/**
 * Add a new console message to display.
 */
function TAAddConsoleMessage(string M, class<LocalMessage> InMessageClass, PlayerReplicationInfo PRI, optional float LifeTime, optional name MsgType)
{
    // check for beep on message receipt
    if( bMessageBeep && InMessageClass.default.bBeep )
    {
        PlayerOwner.PlayBeepSound();
    }

    if( HudMovie != none)
        HudMovie.AddChatMessage("text", M, MsgType);
}

// Console Messages
function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType, optional float LifeTime )
{
    local string strID;
    //local string reasonMsg;

    if ( bMessageBeep )
        PlayerOwner.PlayBeepSound();

    if ( (  MsgType == 'Say') || (MsgType == 'TeamSay') || MsgType == 'Spectator' || MsgType == 'Admin' || MsgType == 'DeadSay' || MsgType == 'DeadTeamSay' || MsgType == 'Whisper' || MsgType =='DeadWhisper')
    {
        if(PRI != none)
        {
            // Rogue. Add message to HUD array containing Canvas chat messages
            if(!MessageFromIgnoredID(PRI.GetALocalPlayerController(), PRI))
            {
                if( MsgType == 'Whisper' || MsgType =='DeadWhisper')
                {
                //  //TODO dead can only talk to dead!!!
                    strID = Split(Msg,' ',true);
                    Msg = Split(strID,' ',true);
                    strID =  Repl(" " $ strID,Msg,"",true);

                    //senders message
                    if(CPPlayerReplicationInfo(CPPlayerController(PRI.GetALocalPlayerController()).PlayerReplicationInfo).CPPlayerID == CPPlayerReplicationInfo(PRI).CPPlayerID)
                    {
                        AddCanvasChatMessage(Msg, PRI, MsgType, int(strID));
                        TAAddConsoleMessage(Msg,class'LocalMessage',PRI,LifeTime, MsgType);
                    }
                    //recievers message
                    if(CPPlayerReplicationInfo(CPPlayerController(PRI.GetALocalPlayerController()).PlayerReplicationInfo).CPPlayerID == int(strID))
                    {
                        //recievers only recieve messages if they are in the same state as the sender (both alive or both dead)
                        if(CPPlayerReplicationInfo(CPPlayerController(PRI.GetALocalPlayerController()).PlayerReplicationInfo).bOutOfLives && CPPlayerReplicationInfo(PRI).bOutOfLives)
                        {
                            AddCanvasChatMessage(Msg, PRI, MsgType, int(strID));
                            TAAddConsoleMessage(Msg,class'LocalMessage',PRI,LifeTime, MsgType);
                        }
                        else if(!CPPlayerReplicationInfo(CPPlayerController(PRI.GetALocalPlayerController()).PlayerReplicationInfo).bOutOfLives && !CPPlayerReplicationInfo(PRI).bOutOfLives)
                        {
                            AddCanvasChatMessage(Msg, PRI, MsgType, int(strID));
                            TAAddConsoleMessage(Msg,class'LocalMessage',PRI,LifeTime, MsgType);
                        }
                    }
                }
                else
                {
                    AddCanvasChatMessage(Msg, PRI, MsgType);
                    Msg = PRI.PlayerName$": "$Msg;
                    TAAddConsoleMessage(Msg,class'LocalMessage',PRI,LifeTime, MsgType);
                }
            }
        }
    }
    else if(MsgType == 'Vote')
    {
        // FIXME. Add code to handle reasons once implemented.
        //reasonMsg = Split(Msg,' ',true);
        //if(reasonMsg != "")
        //{
        //  AddCanvasEventMsg(PRI.PlayerName@"voted"@msg@"out for"@reasonMsg$".");
        //}
        //else
        //{
        if(PRI != none)
        {
            AddCanvasEventMsg(PRI.PlayerName@"voted"@msg@"out.");
            LocalPlayer( PlayerOwner.Player ).ViewportClient.ViewportConsole.OutputText(PRI.PlayerName@"voted"@msg@"out.");
        }
        //}
    }
    else if((MsgType == 'AdminKickEvent') || (MsgType == 'AdminLoginEvent') || (MsgType == 'AdminLogoutEvent') || (MsgType == 'VoteKicked'))
    {
        AddCanvasEventMsg(msg);
        LocalPlayer( PlayerOwner.Player ).ViewportClient.ViewportConsole.OutputText(msg);
    }
    else if(MsgType == 'SettingsEvent')
    {
        AddCanvasEventMsg(msg);
        LocalPlayer( PlayerOwner.Player ).ViewportClient.ViewportConsole.OutputText(msg);
    }
}

function bool MessageFromIgnoredID(PlayerController PC, PlayerReplicationInfo PRI)
{
    if(CPPlayerReplicationInfo(CPPlayerController(PC).PlayerReplicationInfo).CPPlayerID == CPPlayerReplicationInfo(PRI).CPPlayerID)
        return false; //dont ignore the originator

    if(CPPlayerController(PC).bIgnoreAllPlayers)
        return true;

    if (CPPlayerController(PC).IgnoredPlayerList.Find(CPPlayerReplicationInfo(PRI).CPPlayerID) != INDEX_NONE)
    {
        return true;
    }
    return false;
}

function AddCanvasChatMessage(string msg, PlayerReplicationInfo PRI, name MsgType, optional int intOtherPlayersID)
{
    local Color msgColor;
    local Color playerMsgColor;
    local string playerName;
    local int msgDuration;

    // Don't add empty message or malformed message
    if ((Len(msg) == 0) || (PRI == none))
        return;

    // Set playername
    playerName = PRI.PlayerName$": ";

    switch(MsgType)
    {
    case('Whisper'):
        // Yellow name + yellow text
        playerMsgColor=CanvasYellow;
        msgColor=CanvasYellow;
        // Append message to name since they are same color

        if(CPPlayerReplicationInfo(CPPlayerController(PRI.GetALocalPlayerController()).PlayerReplicationInfo).CPPlayerID == CPPlayerReplicationInfo(PRI).CPPlayerID)
        {
            playerName = "You Whispered"@GetPlayerNameFromPRI(intOtherPlayersID)$ ":"@msg;
        }
        else
        {
            playerName = PRI.PlayerName@"Whispered You:"$msg;
        }
        LocalPlayer( PlayerOwner.Player ).ViewportClient.ViewportConsole.OutputText(playerName); //log whispers to console
        // clear msg
        msg = "";
        // Set message duration in seconds
        msgDuration = 10;
        break;

    case('Vote'):
        // Yellow name + yellow text
        playerMsgColor=CanvasYellow;
        msgColor=CanvasYellow;

        //the message contains who the vote is for and thats it. (could contain a reason too!!)

        if(CPPlayerReplicationInfo(CPPlayerController(PRI.GetALocalPlayerController()).PlayerReplicationInfo).CPPlayerID == CPPlayerReplicationInfo(PRI).CPPlayerID)
        {
            playerName = "You Voted " $ msg $ " Out";
        }
        else
        {
            if(CPPlayerReplicationInfo(CPPlayerController(PRI.GetALocalPlayerController()).PlayerReplicationInfo).PlayerName == msg)
            {
                playerName = PRI.PlayerName $ " Voted you out";
            }
            else
            {
                //if its not the person being voted out say whos being voted
                playerName = PRI.PlayerName $ " Voted " $ msg $ " out";
            }
        }
        LocalPlayer( PlayerOwner.Player ).ViewportClient.ViewportConsole.OutputText(playerName); //log votes to console
        // clear msg
        msg = "";
        // Set message duration in seconds
        msgDuration = 10;
        break;


    case('Admin'):
        // Yellow name + yellow text
        playerMsgColor=CanvasYellow;
        msgColor=CanvasYellow;
        // Append message to name since they are same color
        playerName = playerName$msg;
        // clear msg
        msg = "";
        // Set message duration in seconds
        msgDuration = 10;
        break;
    case('Spectator'):
        // Green name + green text
        playerMsgColor=CanvasGreen;
        msgColor=CanvasGreen;
        // Append message to name since they are same color
        playerName = playerName$msg;
        msg = "";
        // Set message duration in seconds
        msgDuration = 10;
        break;
    case('Say'):
    case('DeadSay'):
        // Merc: player name = DARK RED + text = white
        // Swat: player name = DARK BLUE + text = white
        // Do not show dead messages to live players
        if(!CPPlayerController(PlayerOwner).PlayerReplicationInfo.bOutOfLives && (MsgType == 'DeadSay'))
        {
            return;
        }
        // Set message for team
        if(PRI.Team != none && PRI.Team.TeamIndex == BlueTeamIndex)
        {
            //Swat: player name = DARK BLUE + text = white
            playerMsgColor=CanvasDarkBlue;
        }
        else if(PRI.Team != none)
        {
            // Merc: player name = DARK RED + text = white
            playerMsgColor=CanvasDarkRed;
        }
        msgColor=CanvasWhite;
        msgDuration = 10;

        break;
    case('TeamSay'):
    case('DeadTeamSay'):
        // text and player name = light blue (Arny would like to see a version in light orange)
        // Do not show dead messages to live players
        if(!CPPlayerController(PlayerOwner).PlayerReplicationInfo.bOutOfLives && (MsgType == 'DeadTeamSay'))
        {
            return;
        }
        msgColor=CanvasLightBlue;
        playerMsgColor=CanvasLightBlue;
        // Append message to name since they are same color
        playerName = playerName$"Teamsay: "$msg;

        msg = "";
        msgDuration = 10;
        break;
    default:
        // Do not append invalid message
        return;
    }

    // No chat message exists. Add a new one
    if(ChatMessages.Length == 0)
    {
        ChatMessages.Length = ChatMessages.Length + 1;
        ChatMessages[0].enable = false;
        ChatMessages[0].msg = msg;
        ChatMessages[0].playerName = playerName;
        ChatMessages[0].startTime = WorldInfo.TimeSeconds;
        ChatMessages[0].msgColor = msgColor;
        ChatMessages[0].msgDuration = msgDuration;
        ChatMessages[0].playerNameColor = playerMsgColor;
        ChatMessages[0].removeMessage = false;
        ChatMessages[0].msgType = MsgType;
        ChatMessages[0].enable = true;
    }
    else
    {
        // Chat messages should never be more than 6 messages
        if(ChatMessages.Length >= 6)
        {
            // Remove first message to make room for another.
            ChatMessages.Remove(0,1);
            // Add new message to end of array
            ChatMessages.Length = ChatMessages.Length + 1;
            ChatMessages[ChatMessages.Length-1].enable = false;
            ChatMessages[ChatMessages.Length-1].msg = msg;
            ChatMessages[ChatMessages.Length-1].playerName = playerName;
            ChatMessages[ChatMessages.Length-1].startTime = WorldInfo.TimeSeconds;
            ChatMessages[ChatMessages.Length-1].msgColor = msgColor;
            ChatMessages[ChatMessages.Length-1].msgDuration = msgDuration;
            ChatMessages[ChatMessages.Length-1].playerNameColor = playerMsgColor;
            ChatMessages[ChatMessages.Length-1].msgType = MsgType;
            ChatMessages[ChatMessages.Length-1].enable = true;
        }
        else
        {
            // Add new message to end of array
            ChatMessages.Length = ChatMessages.Length + 1;
            ChatMessages[ChatMessages.Length-1].enable = false;
            ChatMessages[ChatMessages.Length-1].msg = msg;
            ChatMessages[ChatMessages.Length-1].playerName = playerName;
            ChatMessages[ChatMessages.Length-1].startTime = WorldInfo.TimeSeconds;
            ChatMessages[ChatMessages.Length-1].msgColor = msgColor;
            ChatMessages[ChatMessages.Length-1].msgDuration = msgDuration;
            ChatMessages[ChatMessages.Length-1].playerNameColor = playerMsgColor;
            ChatMessages[ChatMessages.Length-1].msgType = MsgType;
            ChatMessages[ChatMessages.Length-1].enable = true;
        }
    }
}

function string GetPlayerNameFromPRI(int id)
{
    local CPGameReplicationInfo GRI;
    local int i;

    GRI = CPGameReplicationInfo(WorldInfo.GRI);

    if (GRI != None)
    {
        for (i=0; i < GRI.PRIArray.Length; i++)
        {
            if(CPPlayerReplicationInfo(GRI.PRIArray[i]).CPPlayerID == id)
            {
                return GRI.PRIArray[i].PlayerName;
            }
        }
    }
    return "unknown name";
}

singular event Destroyed()
{
    RemoveMovies();
    Super.Destroyed();
}

/**
  * Destroy existing Movies
  */
function RemoveMovies()
{
    if (HUDMovie!=none)
    {
        HUDMovie.Close(true);
        HUDMovie=none;
    }
    if (ScoreboardMovie!=none)
    {
        ScoreboardMovie.Close(true);
        ScoreboardMovie=none;
    }

    if ( BuyMenuMovie != None )
    {
        BuyMenuMovie.Close(true);
        BuyMenuMovie = None;
    }
}

simulated function PostBeginPlay()
{
    local Pawn P;
    local int i;
    local LocalPlayer LP;

    super.PostBeginPlay();

	if(!blnPlayerWelcomed)
    {
        blnPlayerWelcomed = true;
        ShowWelcomeMenu();
    }

    // Setup Damage indicators,etc.

    // Create the 3 Damage Constants
    DamageData.Length = MaxNoOfIndicators;

    for (i = 0; i < MaxNoOfIndicators; i++)
    {
        DamageData[i].FadeTime = 0.0f;
        DamageData[i].FadeValue = 0.0f;
        DamageData[i].MatConstant = new(self) class'MaterialInstanceConstant';
        if (DamageData[i].MatConstant != none && BaseMaterial != none)
        {
            DamageData[i].MatConstant.SetParent(BaseMaterial);
        }
    }

    // create hit effect material instance
    HitEffect = MaterialEffect(LocalPlayer(PlayerOwner.Player).PlayerPostProcess.FindPostProcessEffect('HitEffect'));
    if (HitEffect != None)
    {
        if (MaterialInstanceConstant(HitEffect.Material) != None && HitEffect.Material.GetPackageName() == 'Transient')
        {
            // the runtime material already exists; grab it
            HitEffectMaterialInstance = MaterialInstanceConstant(HitEffect.Material);
        }
        else
        {
            HitEffectMaterialInstance = new(HitEffect) class'MaterialInstanceConstant';
            HitEffectMaterialInstance.SetParent(HitEffect.Material);
            HitEffect.Material = HitEffectMaterialInstance;
        }
        HitEffect.bShowInGame = false;
    }
        LP = LocalPlayer(PlayerOwner.Player);
        if (LP != None && LP.PlayerPostProcess != None)
        {

            if(LP.PlayerPostProcess.FindPostProcessEffect('FlashEffect') == none)
                LocalPlayer(PlayerOwner.Player).InsertPostProcessingChain(FlashbangPostProcess, 0, true); //add the post process only if it has not been added before.

            // Get the post process chain material effect
            FlashbangPostProcessEffect = MaterialEffect(LP.PlayerPostProcess.FindPostProcessEffect('FlashEffect'));
            if (FlashbangPostProcessEffect != None)
            {
                // Create a new material instance constant
                FlashbangProcessMaterialInstanceConstant = new () class'MaterialInstanceConstant';
                if (FlashbangProcessMaterialInstanceConstant != None)
                {
                    // Assign the parent of the material instance constant to the one stored in the material effect
                    FlashbangProcessMaterialInstanceConstant.SetParent(FlashbangPostProcessEffect.Material);
                    // Set the material effect to use the newly created material instance constant
                    FlashbangPostProcessEffect.Material = FlashbangProcessMaterialInstanceConstant;
                    FlashbangPostProcessEffect.bShowInGame = false;
                }
            }
        }

    // add actors to the PostRenderedActors array
    ForEach DynamicActors(class'Pawn', P)
    {
        if ( (CPPawn(P) != None) )
            AddPostRenderedActor(P);
    }

    if (CPPlayerController(PlayerOwner).TAAnnounce == None)
    {
        CPPlayerController(PlayerOwner).TAAnnounce = Spawn(class'CPAnnouncer', PlayerOwner);
    }

    PlayerInfoMovies.Add( 32 );
    `log( PlayerInfoMovies.Length );
    for ( i = 0; i < 32; i++ )
    {
        PlayerInfoMovies[i] = new class'GFxCPPlayerInfo';
        PlayerInfoMovies[i].SetTimingMode( TM_Real );
        PlayerInfoMovies[i].Init();
    }

    CreateHUDMovie();
}


/**
  * Create and initialize the HUDMovie.
  */
function CreateHUDMovie()
{
    if( HUDClass != none)
    {
        HudMovie=new HUDClass;
        HudMovie.SetTimingMode(TM_Real);
        HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
        HudMovie.InitializeHudMovie(self);
        HudMovie.AddFocusIgnoreKey('Enter');
        HudMovie.AddFocusIgnoreKey('Escape');
        HudMovie.AddFocusIgnoreKey('Up');
        HudMovie.AddFocusIgnoreKey('Down');
        HudMovie.AddFocusIgnoreKey('Tab');
        SetVisible(false);
    }
}



/**
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
local CPSaveManager TSave;

    TSave=new class'CPSaveManager';
    bDrawPlayerInfo=TSave.GetBool("DrawPlayerInfo");
    if (HudMovie!=none)
    {
        if (bNewVisible)
        {
            //HudMovie.ToggleCrosshair(TSave.GetBool("ShowHUD"));
            bEnableActorOverlays=TSave.GetBool("ShowHUD");
            bShowHUD=TSave.GetBool("ShowHUD");
        }
        else
        {
            //HudMovie.ToggleCrosshair(false);
            bEnableActorOverlays=false;
            bShowHUD=false;
        }
    }
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
local CPSaveManager TASave;

    TASave=new(none,"") class'CPSaveManager';
    if (!TASave.GetBool("ShowHitLocation"))
        return;
    if( HudMovie != none)
        HudMovie.DisplayHit(HitDir,Damage,DamageType);
}

/*
 * Complete close of Scoreboard.  Fired from Flash
 * when the "close" animation is finished.
 */
function OnCloseAnimComplete()
{
    // Close the scoreboard but keep it in memory.
    ScoreboardMovie.Close(false);
}

function bool CheckCrosshairOnFriendly()
{
    local float Size;
    local vector HitLocation, HitNormal, StartTrace, EndTrace;
    local actor HitActor;
//  local UTVehicle V, HitV;
    local CPWeapon W;
    local Pawn MyPawnOwner;

    MyPawnOwner = Pawn(PlayerOwner.ViewTarget);
    if ( MyPawnOwner == None )
    {
        return false;
    }

    W = CPWeapon(MyPawnOwner.Weapon);
    if ( W != None && W.EnableFriendlyWarningCrosshair())
    {
        StartTrace = W.InstantFireStartTrace();
        EndTrace = StartTrace + W.MaxRange() * vector(PlayerOwner.Rotation);
        HitActor = MyPawnOwner.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true, vect(0,0,0),, TRACEFLAG_Bullet);

        if ( Pawn(HitActor) == None )
        {
            HitActor = (HitActor == None) ? None : Pawn(HitActor.Base);
        }
    }


    if ( (Pawn(HitActor) == None) || !Worldinfo.GRI.OnSameTeam(HitActor, MyPawnOwner) )
    {
        return false;
    }

    // if trace hits friendly, draw "no shoot" symbol
    Size = 28 * (Canvas.ClipY / 768);
    Canvas.SetPos( (Canvas.ClipX * 0.5) - (Size *0.5), (Canvas.ClipY * 0.5) - (Size * 0.5) );
    return true;
}

exec function BuyCurrentWeaponAmmo()
{
    local int MoneyA, MoneyB;

    if(CPPlayerController(PlayerOwner) != none)
    {
        if(CPPlayerController(PlayerOwner).Pawn != none)
        {
            if(CPPlayerController(PlayerOwner).Pawn.Weapon != none)
            {
                //check we are in the buyzone!
                if(CPPawn(CPPlayerController(PlayerOwner).Pawn).BuyZone != none)
                {
                    //check max ammo
                    if(CPWeapon(CPPlayerController(PlayerOwner).Pawn.Weapon).ClipCount < CPWeapon(CPPlayerController(PlayerOwner).Pawn.Weapon).MaxClipCount)
                    {
                        MoneyA = CPPlayerReplicationInfo(PlayerOwner.Pawn.PlayerReplicationInfo).Money;

                        //`log("BuyCurrentWeaponAmmo pawns current weapon" @ CPPlayerController(PlayerOwner).Pawn.Weapon);
                        //`log("class as string =" @ CPWeapon(CPPlayerController(PlayerOwner).Pawn.Weapon).Class);

                        if(CPWeapon(CPPlayerController(PlayerOwner).Pawn.Weapon).WeaponType == WT_Shotgun)
                            MoneyB = CPPlayerController(PlayerOwner).ShoppingList("AddClip:CriticalPoint." $ CPWeaponShotgun(CPPlayerController(PlayerOwner).Pawn.Weapon).Class $ "|" $ CPWeaponShotgun(CPPlayerController(PlayerOwner).Pawn.Weapon).ShotgunBuyAmmoCount);
                        else
                            MoneyB = CPPlayerController(PlayerOwner).ShoppingList("AddClip:CriticalPoint." $ CPWeapon(CPPlayerController(PlayerOwner).Pawn.Weapon).Class $ "|1");

                        //PlayerOwner.Pawn.PlayerReplicationInfo.bNetDirty = true;
                        //MoneyB = CPPlayerReplicationInfo(PlayerOwner.Pawn.PlayerReplicationInfo).Money;

                        //`log(MoneyA);
                        //`log(MoneyB);

                        if(MoneyA > MoneyB)
                            CPPlayerController(PlayerOwner).PlaySound(SoundCue'TA_BuyMenu.Sounds.CP_UI_BuyMenu_MagSelect_01_Cue',true);
                    }
                }
            }
        }
    }
}

reliable server function int ServerGetMoney()
{
    return CPPlayerReplicationInfo(PlayerOwner.Pawn.PlayerReplicationInfo).Money;
}

/** JoinTeamBalanced()
* Works out which team has the least players on and sets that as the team to join
*/
function byte JoinTeamBalanced()
{
    local int redTeam, blueTeam;
    local int redTeamScore, blueTeamScore;
    local int i;
    local CPPlayerReplicationInfo PRI;

    redTeam = 0;
    blueTeam = 0;
    redTeamScore = 0;
    blueTeamScore = 0;

    if (TAGRI != None)
    {
        for (i=0; i < TAGRI.PRIArray.Length; i++)
        {
            PRI = CPPlayerReplicationInfo(TAGRI.PRIArray[i]);
            if ( PRI != none && IsValidPlayer(PRI) && PRI.Team != None)
            {
                if(PRI.Team.TeamIndex == RedTeamIndex)
                {
                    redTeam++;
                    redTeamScore = PRI.Team.Score;
                }
                else if(PRI.Team.TeamIndex == BlueTeamIndex)
                {
                    blueTeam++;
                    blueTeamScore = PRI.Team.Score;
                }
            }
        }
    }

    if(redTeam > blueTeam)
    {
        return BlueTeamIndex;
    }
    else if(redTeam == blueTeam)
    {
        if(redTeamScore > blueTeamScore)
        {
            return BlueTeamIndex;
        }
        else if(redTeamScore == blueTeamScore)
        {
            return Rand(2);
        }
    }

    return RedTeamIndex;
}

function bool IsValidPlayer( CPPlayerReplicationInfo PRI)
{
    if ( !PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
        (PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None)) )
    {
        return false;
    }

    return true;
}

    /*
    local int randPlayer;

    randPlayer = Rand(2);

    if(TAGI != none)
    {
        randPlayer = TAGI.JoinTeamBalanced();
        `Log("Getting Random Player from JoinTeamBalanced");
    }
    else
    {
        `Log("WorldInfo Game is none in Team Select Get Random Team");
    }
    return randPlayer;
}*/

static simulated function GetTeamColor(int TeamIndex, optional out LinearColor ImageColor, optional out Color TextColor)
{
    switch ( TeamIndex )
    {
        case 0 :
            ImageColor = Default.RedLinearColor;
            TextColor = Default.LightGoldColor;
            break;
        case 1 :
            ImageColor = Default.BlueLinearColor;
            TextColor = Default.LightGoldColor;
            break;
        default:
            ImageColor = Default.DMLinearColor;
            ImageColor.A = 1.0f;
            TextColor = Default.LightGoldColor;
            break;
    }
}

static simulated function DrawBackground(float X, float Y, float Width, float Height, LinearColor DrawColor, Canvas DrawCanvas)
{
    DrawCanvas.SetPos(X,Y);
    DrawColor.R *= 0.25;
    DrawColor.G *= 0.25;
    DrawColor.B *= 0.25;
    DrawCanvas.DrawTile(Default.AltHudTexture, Width, Height, 631,202,98,48, DrawColor);
}

function NotifyFlashBang(float Time, float Scale, Vector Loc)
{
    FlashEffectFadeTime = Time;
    FlashEffectIntensity = Scale;
    FlashEffectLocation = Loc;

    blnSetScreenFlashLocation = true;

    if(FlashbangPostProcessEffect != none)
        FlashbangPostProcessEffect.bShowInGame = true;

    //Reset Time in case double flash!
    LastFlashStartTime = 0.0;
    bFadeOutFlashEffect = true;
}

function StopFlashBangHUDEffect()
{
    bKillFlashEffect = true;
}

function KillFlashBangEffect()
{
    if(FlashbangPostProcessEffect != none)
    {
        FlashbangPostProcessEffect.bShowInGame = false;
        bKillFlashEffect = false;
        bFadeOutFlashEffect = false;
    }
}

function UpdateFlashBang()
{
    local float Intensity;
    local LinearColor ScreenLocation, FlashBlindEffectScale;

    if(bFadeOutFlashEffect)
    {
        //this is to set the size of the flash blind effect - we want this to be bigger closer and smaller further away.
        FlashBlindEffectScale.R = FlashEffectIntensity;
        FlashBlindEffectScale.G = FlashEffectIntensity;

        //this is to set the location of the flash blind effect
        ScreenLocation = MakeLinearColor( ScreenFlashLocation.X, ScreenFlashLocation.Y, 0.0, 1.0 );
       
        if(LastFlashStartTime == 0.0)
        {
            LastFlashStartTime = WorldInfo.TimeSeconds;
        }

        Intensity = FlashEffectFadeTime - (WorldInfo.TimeSeconds - LastFlashStartTime);

        if(Intensity <= 0.0)
        {
            if(FlashbangPostProcessEffect != none)
                FlashbangPostProcessEffect.bShowInGame = false;
        }

        if(FlashbangProcessMaterialInstanceConstant != none)
        {
            FlashbangProcessMaterialInstanceConstant.SetVectorParameterValue('CenterScale', FlashBlindEffectScale); // this is the size of the flash blind effect (r 1.3 and g 1.3 seem to make the object circular
            FlashbangProcessMaterialInstanceConstant.SetVectorParameterValue('CenterLocation', ScreenLocation);
            FlashbangProcessMaterialInstanceConstant.SetScalarParameterValue('ShiftedVisionAmount', FMin(Intensity,1.0)); //max of 5 here, affects the double vision
            FlashbangProcessMaterialInstanceConstant.SetScalarParameterValue('CenterWhiteness', FMin(Intensity,1.0)); //this is the fade amount on the flash blind effect
            FlashbangProcessMaterialInstanceConstant.SetScalarParameterValue('ScreenWhiteness', FMin(Intensity, 1.0)); //1 is max whiteout screen. - not working?!?!
            FlashbangProcessMaterialInstanceConstant.SetScalarParameterValue('MaterialEffectAmount', FMin(Intensity, 1.0)); //10 is max whiteout screen. - not working?!?!
        }
    }
}

exec function SetSplatterShowArea(int area)
{
    if( HudMovie != none)
        HudMovie.SetSplatterShowArea(area);
}

/*
 * SetShowScores() override to display GFx Scoreboard.
 * If the scoreboard has been loaded, this will play the appropriate
 * Flash animation.
 */
exec function SetShowScores(bool bEnableShowScores)
{
    if(bEnableShowScores)
    {
        if (ScoreboardMovie==none)
        {
            ScoreboardMovie=new class'GFxCPScoreboard';
            ScoreboardMovie.LocalPlayerOwnerIndex=GetLocalPlayerOwnerIndex();
            ScoreboardMovie.SetTimingMode(TM_Real);
            ScoreboardMovie.ExternalInterface=self;
        }
        if (!ScoreboardMovie.bMovieIsOpen)
        {
            ScoreboardMovie.Start();
            ScoreboardMovie.PlayOpenAnimation();
        }
        SetVisible(false);
        bShowHUD = true;
    }
    else if ((ScoreboardMovie!=none) && ScoreboardMovie.bMovieIsOpen)
    {
        ScoreboardMovie.PlayCloseAnimation();
        SetVisible(true);
    }
}

exec function UserOpenBuyMenu()
{
    local CPPawn Pawn;

    if ( TAGRI.bMatchIsOver || !TAGRI.bRoundHasBegun || PlayerOwner == none )
        return;

    // Check if we're in a BuyZone
    Pawn = CPPawn( PlayerOwner.Pawn );
    if ( Pawn == none || Pawn.BuyZone == none )
        return;

    if ( BuyMenuMovie == None )
    {
        BuyMenuMovie = new class'GFxCPBuyMenu';
        BuyMenuMovie.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
        BuyMenuMovie.SetTimingMode(TM_Real);
        BuyMenuMovie.ExternalInterface = self;
        BuyMenuMovie.Start();
        BuyMenuMovie.PlayOpenAnimation();
    }
}

function CheckCloseBuyMenu()
{
    local CPPawn Pawn;

    if ( BuyMenuMovie != None )
    {
        Pawn = CPPawn( PlayerOwner.Pawn );

        if(BuyMenuMovie.CloseMenu() || Pawn == none)
        {
            BuyMenuMovie.PlayCloseAnimation();
            BuyMenuMovie.Close(true);
            BuyMenuMovie = None;
            bCrosshairShow = true;
        }
    }
}

//function ShowAdminMenu()
//{
//  `Log("Show Admin Menu");
//}

//exec function ShowClientAdminMenu()
//{
//  `Log("ShowClientAdminMenu");
//  bShowAdminMenu = true;
//}


/*
*/
exec function ShowMenu()
{
    if(HudMovie != none)
    {
        if(HudMovie.bChatting)
        {
            HudMovie.TeamLabel.SetVisible(false);
            HudMovie.bCaptureInput = false;
			HudMovie.ChatInput.SetString("text", "");
			HudMovie.ChatInput.SetBool("focused", false);
			HudMovie.ChatInput.SetBool("visible", false);
			HudMovie.bChatting = false;
        }
        else
        {
            if(CPI_FrontEnd != none && CPI_FrontEnd.bMovieIsOpen)
            {
				//if its a dialog showing - close the dialog but not the ingame menus...
				if(!CPI_FrontEnd.DialogBoxPrompt.bMovieShowing)
				{
					CloseFrontend();
				}
				else
				{
					CPI_FrontEnd.DialogBoxPrompt.OnEscapeKeyPress();
				}
            }
            else
            {
                if(CPI_FrontEnd == none)
                {
                    CPI_FrontEnd = new () class'CPIFrontEnd';

                    //do not allow the user to escape the welcome screen on first joining.
                    if(CPPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).Team != none)
                        CPI_FrontEnd.AddFocusIgnoreKey(CPPlayerInput(PlayerOwner.PlayerInput).FindKeyForCommand("GBA_ShowMenu"));

                    CPI_FrontEnd.LocalPlayerOwnerIndex=GetLocalPlayerOwnerIndex();
                    CPI_FrontEnd.SetTimingMode(TM_Real);
                    CPI_FrontEnd.ExternalInterface = self;
                }

                CPI_FrontEnd.bOpenedIngame = true;
                CPI_FrontEnd.Start();
            }
        }
    }
    else
    {
        if(CPI_FrontEnd != none && CPI_FrontEnd.bMovieIsOpen)
        {
            CloseFrontend();
        }
        else
        {
            if(CPI_FrontEnd == none)
            {
                CPI_FrontEnd = new () class'CPIFrontEnd';

                //do not allow the user to escape the welcome screen on first joining.
                if(CPPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).Team != none)
                    CPI_FrontEnd.AddFocusIgnoreKey(CPPlayerInput(PlayerOwner.PlayerInput).FindKeyForCommand("GBA_ShowMenu"));

                CPI_FrontEnd.LocalPlayerOwnerIndex=GetLocalPlayerOwnerIndex();
                CPI_FrontEnd.SetTimingMode(TM_Real);
                CPI_FrontEnd.ExternalInterface = self;
            }

            CPI_FrontEnd.bOpenedIngame = true;
            CPI_FrontEnd.Start();
        }
    }
}


/** Generate a dialogbox and ask the user to quit the game*/
function ShowCharacterSelectMenu(int Team)
{
    if (CPI_FrontEnd == none)
    {
        OpenFrontend();

        if (CPI_FrontEnd != none)
            CPI_FrontEnd.blnOpenCharacterSelectMenu = true;
    }
    else
    {
        CPI_FrontEnd.blnOpenCharacterSelectMenu = true;
        CPI_FrontEnd.Start();
    }
}



exec function ShowWelcomeMenu()
{
    if (CPI_FrontEnd == none)
    {
        OpenFrontend();

        if (CPI_FrontEnd != none)
            if (CPI_FrontEnd.bOpenedIngame)
                CPI_FrontEnd.blnOpenWelcomeMenu = true;
    }
    else
    {
        if (CPI_FrontEnd.bOpenedIngame)
            CPI_FrontEnd.blnOpenWelcomeMenu = true;

        CPI_FrontEnd.Start();
		blnPlayerWelcomed = false;
    }
}

function CloseFrontend()
{
    if (CPI_FrontEnd != none)
        CPI_FrontEnd.Close(false); // Keep pause menu loaded in memory for reuse.
}


function OpenFrontend()
{
    if (CPI_FrontEnd == none)
    {
        CPI_FrontEnd = new () class'CPIFrontEnd';

        // do not allow the user to escape the welcome screen on first joining.
        //~Crusha: Not sure for what this if-check is needed in the first place.
        if (PlayerOwner.PlayerReplicationInfo != none && PlayerOwner.PlayerReplicationInfo.Team != none)
            CPI_FrontEnd.AddFocusIgnoreKey(CPPlayerInput(PlayerOwner.PlayerInput).FindKeyForCommand("GBA_ShowMenu"));

        CPI_FrontEnd.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
        CPI_FrontEnd.SetTimingMode(TM_Real);
        CPI_FrontEnd.bOpenedIngame = true;
        CPI_FrontEnd.ExternalInterface = self;
        CPI_FrontEnd.Start();
    }
}

defaultproperties
{
    bEnableActorOverlays=true
    HUDClass=class'CPGFxTeamHUD'
    BlueTeamIndex = 1
    RedTeamIndex = 0

    RED=(add=(R=255,G=0,B=0,A=20))
    BLUE=(add=(R=0,G=0,B=255,A=20))
    GREEN=(add=(R=0,G=128,B=0,A=20))

    CanvasRed=(R=255,G=0,B=0,A=255)
    CanvasDarkRed=(R=128,G=0,B=0,A=255)
    CanvasGreen=(R=0,G=128,B=0,A=255)
    CanvasBlue=(R=0,G=0,B=255,A=255)
    CanvasDarkBlue=(R=0,G=0,B=128,A=255)
    CanvasLightBlue=(R=0,G=128,B=128,A=255)
    CanvasYellow=(R=255,G=255,B=0,A=255)
    CanvasWhite=(R=255,G=255,B=255,A=255)
    CanvasBlockColor=(R=0,G=0,B=0,A=110)
    CanvasTalkBlockColor=(R=250,G=250,B=250,A=180)

    KillFontSize=1
    currSfPlayers=0
    currTerrPlayers=0

    DeathPositions=(X=20,Y=50)
    EventPositions=(X=20,Y=125)
    ChatPositions=(X=20,Y=300)
    TeamInfoPosition=(X=120,Y=200)
    RoundTimePosition=(X=130,Y=10)
    MapTimePosition=(X=130,Y=10)


    RedLinearColor=(R=3.0,G=0.0,B=0.05,A=0.8)
    BlueLinearColor=(R=0.5,G=0.8,B=10.0,A=0.8)
    DMLinearColor=(R=1.0,G=1.0,B=1.0,A=0.5)
    WhiteLinearColor=(R=1.0,G=1.0,B=1.0,A=1.0)
    GoldLinearColor=(R=1.0,G=1.0,B=0.0,A=1.0)
    SilverLinearColor=(R=0.75,G=0.75,B=0.75,A=1.0)
    LightGoldColor=(R=255,G=255,B=128,A=255)
    LightGreenColor=(R=128,G=255,B=128,A=255)

    MessageOffset(0)=0.15
    MessageOffset(1)=0.242
    MessageOffset(2)=0.36
    MessageOffset(3)=0.58
    MessageOffset(4)=0.78
    MessageOffset(5)=0.83
    MessageOffset(6)=2.0
    MessageOffset(7)=2.0
    MessageOffset(8)=2.0

//  AltHudTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseA'

    MaxNoOfIndicators=3
    FadeParamName=DamageDirectionAlpha
    HitEffectIntensity=0.25
    HitEffectFadeTime=0.50

    MaxHitEffectColor=(R=2.0,G=-1.0,B=-1.0)
//  BaseMaterial=Material'UI_HUD.HUD.M_UI_HUD_DamageDir'
    FlashBangPostProcess=PostProcessChain'CP_PostProcess.CP_FlashbangPostProcess'

}
