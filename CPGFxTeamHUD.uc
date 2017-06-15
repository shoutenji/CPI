class CPGFxTeamHUD extends GFxMoviePlayer
    config( UI );

/** If true let weapons draw their crosshairs instead of using GFx crosshair */

var     CONST ASColorTransform WHITE;
var     GFXObject gfxTopCenterPopup, gfxTopCenterPickup;
var     GFXObject mapTime, mapLabel, roundTime, roundLabel, MoneyAmount;
var     GFXObject ammoLabel , weaponMode, weaponModeLabel;
var     GFXObject healthLabel, health;
var     GFXObject actionPercentage , actionPerformed;
var     GFXObject buyZone , genericZone , bombZone, hackingZone;
var     GFXObject HeadArmor, BodyArmor, LegArmor;
var     GFXObject MeleeSlot, PistolSlot, SMGSlot, RifleSlot, ExplosiveSlot, BombSlot, EquippedSlot;
var     bool      BuyZoneShowing, EscapeZoneShowing, RescueZoneShowing, BombZoneShowing, PercentageZoneShowing, HackZoneShowing;
var     bool      bDrawWeaponCrosshairs;

var CPGameReplicationInfo GRI;
var CPPlayerController Controller;
var CPPlayerReplicationInfo PRI;
var Weapon          LastWeapon;
var CPHUD           CachedHud;

var localized string lblTime,lblMap,lblRound,lblAmmo,lblWeaponMode,lblHealth;
var float BombDiffuseStartTime, RemainingBombDiffuseTime;

var string StrCurrentWeaponFlashName;


//Hit Directional MC's
//(N,NE,E,SE,S,SW,W,NW)

var GFxObject SimpleHitLocMC[8];
var GFxObject SplatterHitLocMC[8];

var bool blnHeadArmorSet;
var bool showSplatter;
var int currSplatter;

var WorldInfo WorldInfo;

/*  Chat Variables
*/

// Global Chat Messages
var array<string> ChatMessages;
// Player Names
var array<string> ChatNames;
// Player name colors
var array<ASColorTransform> ChatNameColors;
// Message colors
var array<ASColorTransform> ChatMessageColors;
// If true we are currently chatting
var bool bChatting;
// If false then hide the chat interface
var bool WidgetVisible;
// Chat GFxWidgets
var GFxClikWidget ChatInput, TeamLabel;
var GFxClikWidget  NameOne, MessageOne, NameTwo, MessageTwo, NameThree, MessageThree, NameFour, MessageFour, NameFive, MessageFive;

/** Struct representing a chat entry */
struct ChatEntry
{
	var string PlayerName;
	var string Message;
	var ASColorTransform NameColor;
	var ASColorTransform MessageColor;
};

var array<ChatEntry> ChatData;
// Chat colours
var LinearColor WhiteColor, Green, Blue, LightBlue, Red, Yellow;
// HUD reference
var CPHUD CPHUD;
// The chat 'type' meaning 'Say', 'TeamSay' etc
var string ChatType;

var bool bHideAndDestroyTopRow;
var bool bHideAndDestroySecondRow;
var bool bHideAndDestroyThirdRow;
var bool bHideAndDestroyForthRow;
var bool bHideAndDestroyBottomRow;


/**
 * Called when the movie is first started
 */
function bool Start(optional bool StartPaused = false)
{
    Super.Start(StartPaused);
    Advance(0);

    return false;
}


/**
 */
function InitializeHudMovie(CPHUD HUD)
{
    if (HUD != None)
    {
        CPHUD = HUD;
    }
}


/*
*/
function Init( optional LocalPlayer Player )
{
//  local int j;
//  local array<string> Blank;
//  BottomCenterMC.bMelee=true;
//  BottomCenterMC.bPistol=true;
//  BottomCenterMC.bSMG=true;
//  BottomCenterMC.bRifle=true;
//  BottomCenterMC.bNade=true;
//  BottomCenterMC.bBomb=true;

    Start();

    WorldInfo = class'WorldInfo'.static.GetWorldInfo();

    //cache the GRI and PRI
    controller = CPPlayerController( GetPC() );
    if(controller != none)
    {
        GRI = CPGameReplicationInfo( controller.WorldInfo.GRI );
    }

    PRI = CPPlayerReplicationInfo(controller.PlayerReplicationInfo);
    CachedHud = CPHUD(controller.myHUD);



    gfxTopCenterPopup   = GetVariableObject( "container.center.popupMessage" );
    gfxTopCenterPickup  = GetVariableObject( "container.center.pickup" );

    mapTime             = GetVariableObject( "container.topRight.mapTime" );
    mapLabel            = GetVariableObject( "container.topRight.mapLabel" );
    roundTime           = GetVariableObject( "container.topRight.roundTime" );
    roundLabel          = GetVariableObject( "container.topRight.roundLabel" );
    MoneyAmount         = GetVariableObject( "container.topLeft.moneyAmount" );

    ammoLabel           = GetVariableObject( "container.bottomRight.ammoLabel" );
    weaponMode          = GetVariableObject( "container.bottomRight.weaponMode" );
    weaponModeLabel     = GetVariableObject( "container.bottomRight.weaponModeLabel" );

    healthLabel         = GetVariableObject( "container.bottomleft.healthLabel" );
    health              = GetVariableObject( "container.bottomleft.health" );

    buyZone             = GetVariableObject( "container.leftCenter.buyZoneContainer" );
    buyZone.SetVisible(false);
    genericZone         = GetVariableObject( "container.leftCenter.genericZoneContainer" );
    genericZone.SetVisible(false);
    bombZone            = GetVariableObject( "container.leftCenter.bombZoneContainer" );
    bombZone.SetVisible(false);
    hackingZone         = GetVariableObject( "container.leftCenter.HackingContainer" );
    hackingZone.SetVisible(false);


    HeadArmor           = GetVariableObject( "container.bottomleft.headArmor" );
    BodyArmor           = GetVariableObject( "container.bottomleft.chestArmor" );
    LegArmor            = GetVariableObject( "container.bottomleft.legArmor" );

    MeleeSlot           = GetVariableObject( "container.bottomCenter.melee" );
    PistolSlot          = GetVariableObject( "container.bottomCenter.pistol" );
    SMGSlot             = GetVariableObject( "container.bottomCenter.smg" );
    RifleSlot           = GetVariableObject( "container.bottomCenter.rifle" );
    ExplosiveSlot       = GetVariableObject( "container.bottomCenter.explosive" );
    BombSlot            = GetVariableObject( "container.bottomCenter.bomb" );

    actionPercentage    = GetVariableObject( "container.center.actionPercentage" );
    actionPerformed     = GetVariableObject( "container.center.actionPerformed" );

    SimpleHitLocMC[0] = GetVariableObject( "container.center.dirHit.t" );
    SimpleHitLocMC[1] = GetVariableObject( "container.center.dirHit.tr" );
    SimpleHitLocMC[2] = GetVariableObject( "container.center.dirHit.r" );
    SimpleHitLocMC[3] = GetVariableObject( "container.center.dirHit.br" );
    SimpleHitLocMC[4] = GetVariableObject( "container.center.dirHit.b" );
    SimpleHitLocMC[5] = GetVariableObject( "container.center.dirHit.bl" );
    SimpleHitLocMC[6] = GetVariableObject( "container.center.dirHit.l" );
    SimpleHitLocMC[7] = GetVariableObject( "container.center.dirHit.tl" );

    SplatterHitLocMC[0] = GetVariableObject( "container.center.OuterDirHit.OuterT" );
    SplatterHitLocMC[1] = GetVariableObject( "container.center.OuterDirHit.OuterTR" );
    SplatterHitLocMC[2] = GetVariableObject( "container.center.OuterDirHit.OuterR" );
    SplatterHitLocMC[3] = GetVariableObject( "container.center.OuterDirHit.OuterBR" );
    SplatterHitLocMC[4] = GetVariableObject( "container.center.OuterDirHit.OuterB" );
    SplatterHitLocMC[5] = GetVariableObject( "container.center.OuterDirHit.OuterBL" );
    SplatterHitLocMC[6] = GetVariableObject( "container.center.OuterDirHit.OuterL" );
    SplatterHitLocMC[7] = GetVariableObject( "container.center.OuterDirHit.OuterTL" );

    showSplatter = false;
    currSplatter = 7;

//  Blank[Blank.Length] = "";
//  resetWeaponIcons(Blank);

//    for ( j = 0; j < 5; j++ )
//      InitChatMessageRow();

//  for ( j = 0; j < 5; j++ )
//      InitEventMessageRow();

//  for ( j = 0; j < 5; j++ )
//      InitKillsMessageRow();

    SetLocalizedLabelTexts();
}

function SetCenterTextBottomZone( string Text , ASColorTransform TextColor = WHITE )
{
    if(gfxTopCenterPickup != none)
    {
        gfxTopCenterPickup.SetColorTransform( TextColor );
        CallASPickupMessage(Text);
    }
}

function CallASPickupMessage(string thisText)
{
    ActionScriptVoid("pickupMessage");
}

function SetLocalizedLabelTexts()
{
    mapLabel.SetText(lblMap);
    roundLabel.SetText(lblRound);
    ammoLabel.SetText(lblAmmo);
    weaponModeLabel.SetText(lblWeaponMode);
    healthLabel.SetText(lblHealth);
}

function SetCenterText( string Text )
{
    //`Log("SetCenterText " $ Text);
    if(gfxTopCenterPopup != none)
    {
        CallASPopUpMessage(Text);
    }
}

function CallASPopUpMessage(string thisText)
{
    if(GetPC() != none && CPHUD(GetPC().myHUD) != none) //fixes an editor crash. might need to be applied to all ActionScriptVoid calls defensively.
    {
        ActionScriptVoid("popupMessage");
    }
}

function TickHud( float DeltaTime )
{
    local CPWeapon CPWeap;
    local CPPawn tPawn;
    local float Armor;
    local array<CPWeapon> InvArray;
    local int i;
    local CPSaveManager CPSaveManager;
    local ASDisplayInfo ASDisplayInfo;
    local ASColorTransform ChatColorTransform;
    local LinearColor LC;


//  local ASDisplayInfo DI, Compass, ChatBoxArea;
//  local rotator CompDir;
//  local float dirFloat;

//  local CPHUD THUD;

//  local int j;

    if(controller != none)
        tPawn = CPPawn(controller.ViewTarget);

    if(tPawn == none)
        tPawn = CPPawn( controller.Pawn );

//  for (j = 0; j < ChatMessages.Length; j++)
//  {
//      if(ChatMessages[j].MC != none)
//      {
//          if(ChatMessages[j].FadeTimeStamp + 10.0000 < GetPC().WorldInfo.TimeSeconds)
//          {
//              if(!ChatMessages[j].blnIsFading)
//              {
//                  ChatMessages[j].blnIsFading = true;
//                  ChatMessages[j].MC.GotoAndPlay("fadeout");
//              }
//          }
//      }
//  }

//  for (j = 0; j < EventMessages.Length; j++)
//  {
//      if(EventMessages[j].MC != none)
//      {
//          if(EventMessages[j].FadeTimeStamp + 10.0000 < GetPC().WorldInfo.TimeSeconds)
//          {
//              if(!EventMessages[j].blnIsFading)
//              {
//                  EventMessages[j].blnIsFading = true;
//                  EventMessages[j].MC.GotoAndPlay("fadeout");
//              }
//          }
//      }
//  }

//  for (j = 0; j < KillMessages.Length; j++)
//  {
//      if(KillMessages[j].MC != none)
//      {
//          if(KillMessages[j].FadeTimeStamp + 10.0000 < GetPC().WorldInfo.TimeSeconds)
//          {
//              if(!KillMessages[j].blnIsFading)
//              {
//                  KillMessages[j].blnIsFading = true;
//                  KillMessages[j].MC.GotoAndPlay("fadeout");
//              }
//          }
//      }
//  }

//  if(Chatbox != none)
//      ChatBoxArea  = Chatbox.GetDisplayInfo();

//  if ( controller == none )
//      return;

//  if(!Controller.bTyping && !Controller.bTeamTyping)
//  {
//      if(ChatBoxArea.Alpha > 0)
//          ChatBoxArea.Alpha = ChatBoxArea.Alpha - 4.0;

//      if(Chatbox != none)
//      {
//          Chatbox.SetText(""); //make sure the chatbox is empty
//          Chatbox.setBool("focused",false);
//      }
//  }
//  else
//  {
//      if(Chatbox != none)
//      {
//          GetPC().PlayerInput.ResetInput();    //ensure player movement input is stopped so they cannot move while in type mode.

//          if(!Chatbox.getBool("focused"))
//          {
//              Chatbox.setBool("focused",true);
//              Chatbox.SetText(""); //make sure the chatbox is empty
//          }
//      }
//      bCaptureInput=true;                  //we have taken control of the input now so we can now use FilterButtonInput function to build up our chat text area.

//      if (ChatBoxArea.Alpha < 100)
//          ChatBoxArea.Alpha = ChatBoxArea.Alpha + 4.0;
//  }

//  if(Chatbox != none)
//      Chatbox.SetDisplayInfo( ChatBoxArea );

//  tPawn = CPPawn( controller.Pawn );


    if ( tPawn != None && tPawn.PlayerReplicationInfo != None )
    {
        if(MoneyAmount != none)
        {
            MoneyAmount.SetVisible(true);
            MoneyAmount.SetText( "$" $ CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo).Money );
        }
    }
    else
    {
        if(MoneyAmount != none)
        {
            MoneyAmount.SetVisible(false);
            MoneyAmount.SetText( "$" $ 0 );
        }
    }

    if ( GRI != none )
    {
        if(roundTime != none)
        {
            roundTime.SetText( FormatTime( GRI.TimeLimit != 0 ? GRI.RemainingRoundTime : GRI.ElapsedRoundTime ) );
        }

        if(mapTime != none)
        {
            mapTime.SetText( FormatTime( GRI.RemainingTime ) );
        }
    }

    // Spectator should have a pawn if spectating another player. Otherwise he will not. If he is
    // spectating another player then we should try to show as much on the hud as possible
    // that is part of the player being spectated.
    if( tPawn == none )
    {
//      ShowSpectHudElements( true );

        BuyZoneShowing = false;
        CallASenterZone( "buy", "BUY ZONE", false );

        RescueZoneShowing = false;
        EscapeZoneShowing = false;
        CallASenterZone( "generic", "", false );

        BombZoneShowing = false;
        CallASenterZone( "bomb", "", false );

        HackZoneShowing = false;
        CallASenterZone( "hack", "", false );

        PercentageZoneShowing=false;
        CallASactionPercent(0,"");
        CallASsetPlayerInfo("SF", 0, 0);
        CallASsetPlayerInfo("TR", 0, 0);
        CallASsetPlayerInfo("HS", 0, 0);

      //@Wail - 11/01/13: In some circumstances a player who is spectating but has no pawn viewtarget still displays a health value on the scoreboard.
      //                  Haven't had much luck replicating the conditions of when this happens. Rather than show a value, simply try to hide the display.
      if (Health != none)
            Health.SetText(-1); //0
        Health.SetVisible(false);

        MeleeSlot.SetVisible(false);
        PistolSlot.SetVisible(false);
        SMGSlot.SetVisible(false);
        RifleSlot.SetVisible(false);
        ExplosiveSlot.SetVisible(false);
        BombSlot.SetVisible(false);

        if(weaponMode != none)
            weaponMode.SetText("");
        GetVariableObject("_root.container.bottomRight.ammoAmount").SetText("");
        GetVariableObject("_root.container.bottomRight.clipAmount").SetText("");
    }
    else
    {
        //WeaponBarSelectHeldWeapon(tPawn);
        CallASsetPlayerInfo("SF", CachedHud.currSfPlayers, CachedHud.currSfPlayersTotal);
        CallASsetPlayerInfo("TR", CachedHud.currTerrPlayers, CachedHud.currTerrPlayersTotal);
        CallASsetPlayerInfo("HS", CachedHud.currHSPlayers, CachedHud.currHSPlayersTotal);

//      ShowHudElements( true );

        if(buyZone != none)
        {
            if(tPawn.BuyZone != none && !BuyZoneShowing)
            {
                buyZone.SetVisible(true);
                BuyZoneShowing = true;
                CallASenterZone("buy", "BUY ZONE", true);
            }
            else if (tPawn.BuyZone == none && BuyZoneShowing )
            {
                BuyZoneShowing = false;
                CallASenterZone("buy", "BUY ZONE", false); //todo localize text
            }
        }
        else
        {
            if(BuyZoneShowing)
            {
                BuyZoneShowing = false;
                CallASenterZone("buy", "BUY ZONE", false); //todo localize text
            }
        }

        if(genericZone != none)
        {
            if(tPawn.EscapeZone != none && !EscapeZoneShowing)
            {
                genericZone.SetVisible(true);
                EscapeZoneShowing = true;
                CallASenterZone("generic", "ESCAPE ZONE", true);
            }
            else if (tPawn.EscapeZone == none && EscapeZoneShowing )
            {
                EscapeZoneShowing = false;
                CallASenterZone("generic", "ESCAPE ZONE", false); //todo localize text
            }

            if(tPawn.HostageRescueZone != none && !RescueZoneShowing)
            {
                genericZone.SetVisible(true);
                RescueZoneShowing = true;
                CallASenterZone("generic", "RESCUE ZONE", true);
            }
            else if (tPawn.HostageRescueZone == none && RescueZoneShowing )
            {
                RescueZoneShowing = false;
                CallASenterZone("generic", "RESCUE ZONE", false); //todo localize text
            }
        }
        else
        {
            if(EscapeZoneShowing || RescueZoneShowing)
            {
                if(EscapeZoneShowing)
                {
                    EscapeZoneShowing = false;
                    CallASenterZone("generic", "ESCAPE ZONE", false);
                }

                if(RescueZoneShowing)
                {
                    RescueZoneShowing = false;
                    CallASenterZone("generic", "RESCUE ZONE", false);
                }

            }
        }

        if(hackingZone != none) // TODO Wire in the hackzone here.
        {
            if( tPawn.HackZone != none && !HackZoneShowing)
            {
                hackingZone.SetVisible(true);
                HackZoneShowing = true;
                CallASenterZone("hack", "HACK ZONE", true );
            }
            else if ( tPawn.HackZone == none && HackZoneShowing)
            {
                HackZoneShowing = false;
                    CallASenterZone("hack", "HACK ZONE", false );
            }
        }
        else
        {
            if(HackZoneShowing)
            {
                HackZoneShowing = false;
                CallASenterZone("hack", "HACK ZONE", false );
            }
        }


        if(bombZone != none) // TODO Wire in the bombzone here.
        {
            if( tPawn.BombZone != none && !BombZoneShowing)
            {
                bombZone.SetVisible(true);
                BombZoneShowing = true;
                CallASenterZone("bomb", "BOMB ZONE", true );
            }
            else if ( tPawn.BombZone == none && BombZoneShowing)
            {
                BombZoneShowing = false;
                    CallASenterZone("bomb", "BOMB ZONE", false );
            }
        }
        else
        {
            if(BombZoneShowing)
            {
                BombZoneShowing = false;
                CallASenterZone("bomb", "BOMB ZONE", false );
            }
        }

        if(showSplatter)
        {
            if(currSplatter > 7)
            {
                SplatterHitLocMC[0].GotoAndPlay( "on" );
                SplatterHitLocMC[1].GotoAndPlay( "on" );
                SplatterHitLocMC[2].GotoAndPlay( "on" );
                SplatterHitLocMC[3].GotoAndPlay( "on" );
                SplatterHitLocMC[4].GotoAndPlay( "on" );
                SplatterHitLocMC[5].GotoAndPlay( "on" );
                SplatterHitLocMC[6].GotoAndPlay( "on" );
                SplatterHitLocMC[7].GotoAndPlay( "on" );
            }
            else
            {
                SplatterHitLocMC[currSplatter].GotoAndPlay( "on" );
            }
        }

        //percentage code is linked.
        if ( tPawn.bIsUsingObjective && tPawn.HackZone != none && tPawn.HackZone.HackObjective != none )//Hacking the objective
        {
            PercentageZoneShowing = true;
            CallASactionPercent(FFloor( tPawn.HackZone.HackObjective.Percent ), "HACKING PANEL");
        }
        else if ( tPawn.Weapon != none && tPawn.bIsUseKeyDown && tPawn.Weapon.IsA('CPWeap_Bomb') && CPWeap_Bomb(tPawn.Weapon).IsDefusing() && !CPWeap_Bomb(tPawn.Weapon).IsDefused() )//defusing the bomb
        {
            PercentageZoneShowing = true;
            CallASactionPercent( 100 * CPWeap_Bomb(tPawn.Weapon).GetDefusePercent(), "DEFUSING BOMB" );
        }
        else if ( tPawn.Weapon != none && tPawn.Weapon.IsA('CPWeap_Bomb') && CPWeap_Bomb(tPawn.Weapon).IsPlanting() && !CPWeap_Bomb(tPawn.Weapon).IsPlanted() ) //arming the bomb
        {
            PercentageZoneShowing = true;
            CallASactionPercent( 100 * CPWeap_Bomb(tPawn.Weapon).GetPlantPercent(), "ARMING BOMB" );
        }
        else if ( tPawn.Weapon != none && tPawn.Weapon.IsA('CPWeap_HE') && CPWeap_HE(tPawn.Weapon).ChargeStartTime != 0) //arming the bomb
        {
            PercentageZoneShowing = true;
            CallASactionPercent( 100 * CPWeap_HE(tPawn.Weapon).GetPowerPerc() , "");
        }
        else if ( tPawn.Weapon != none && tPawn.Weapon.IsA('CPWeap_FlashBang') && CPWeap_FlashBang(tPawn.Weapon).ChargeStartTime != 0) //arming the bomb
        {
            PercentageZoneShowing = true;
            CallASactionPercent( 100 * CPWeap_FlashBang(tPawn.Weapon).GetPowerPerc() , "");
        }
        else
        {
            BombDiffuseStartTime = 0;
            if(PercentageZoneShowing)
            {
                PercentageZoneShowing=false;
                CallASactionPercent(0,"");
            }
        }

        if(health != none)
        {
            health.SetVisible(true);
            health.SetText(tPawn.Health);
        }
        else
            health.SetVisible(false);

       if(CPInventoryManager(tPawn.InvManager) != none)
        {
    //////////////        CPInventoryManager(tPawn.InvManager).GetWeaponList(InvArray);//Should BE CHanged

    //////////////        if(CPPlayercontroller(tPawn.Controller) != none)
    //////////////        {
    //////////////            CPPlayercontroller(tPawn.Controller).ClearSpectatorWeapons();
    //////////////        }
    //////////////        for(i=0; i<InvArray.Length; i++)
    //////////////        {
    //////////////            if(CPPlayercontroller(tPawn.Controller) != none)
    //////////////            {
				//////////////	//if(InvArray[i] != none)
				//////////////	//{
				//////////////		CPPlayercontroller(tPawn.Controller).SetSpectatorWeapons(InvArray[i], i);
				//////////////	//}
    //////////////            }
    //////////////         }
        }
    else
        {
            MeleeSlot.SetVisible(false);
            PistolSlot.SetVisible(false);
            SMGSlot.SetVisible(false);
            RifleSlot.SetVisible(false);
            ExplosiveSlot.SetVisible(false);
            BombSlot.SetVisible(false);
        }

        UpdateWeaponSlots();
    //////////////    for(i=0; i< 6; i++)
    //////////////    {
    //////////////        if(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo) != none)
    //////////////        {
    //////////////            if(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo).SpectatorWeapons[i] != none)
    //////////////            {
    //////////////                //`Log(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo).SpectatorWeapons[i]);
    //////////////                UpdateWeaponSlot(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo).SpectatorWeapons[i]);
    //////////////            }
    //////////////        }
    //////////////    }


        if(tPawn.Weapon != none)
        {
            CPWeap = CPWeapon(tPawn.Weapon);
        }

    //////////////    if(CPWeap == none)
    //////////////    {
    //////////////        if(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo) != none)
    //////////////        {
				//////////////if(tPawn.SpectateCurrentWeapon != LastWeapon)
				//////////////{
				//////////////	if(tPawn.SpectateCurrentWeapon != none)
				//////////////	{
				//////////////		CPWeap = tPawn.SpectateCurrentWeapon;
				//////////////	}
				//////////////}
    //////////////        }
    //////////////    }

        if(CPWeap != none)
        {
			UpdateWeaponSlot(CPWeap);

            if(CPWeap != LastWeapon)
            {
                SetNewCurrentSlot(CPWeap);
                if(controller != none)
                    controller.ReceiveLocalizedMessage( class'CPMsg_WeaponSwitch',,,, CPWeap );
                LastWeapon = CPWeap;
            }
        }

        Armor = TPawn.HeadStrength;
        if( Armor == 0.0 )
        {
            HeadArmor.SetVisible(false);
            HeadArmor.setfloat("_alpha", 0.f);
        }
        else
        {
            HeadArmor.SetVisible(true);
            HeadArmor.setfloat("_alpha", 100.f);
            HeadArmor.GotoAndStopI(Armor*100);
        }

        Armor = TPawn.BodyStrength;
        if( Armor == 0.0 )
        {
            BodyArmor.SetVisible(false);
            BodyArmor.setfloat("_alpha", 0.f);
        }
        else
        {
            BodyArmor.SetVisible(true);
            BodyArmor.setfloat("_alpha", 100.f);
            BodyArmor.GotoAndStopI(Armor*100);
        }

        Armor = TPawn.LegStrength;
        if( Armor == 0.0 )
        {
            LegArmor.SetVisible(false);
            LegArmor.setfloat("_alpha", 0.f);
        }
        else
        {
            LegArmor.SetVisible(true);
            LegArmor.setfloat("_alpha", 100.f);
            LegArmor.GotoAndStopI(Armor*100);
        }
    }

    /*
     *  The hiding of certain HUD elements
     */
    if ( tPawn != None && tPawn.PlayerReplicationInfo != None )
    {
        // Ensure we have a Save Manager
        CPSaveManager = new () class'CPSaveManager';
        if(CPSaveManager != none)
        {
            // If Show Weapon Icons is false in the Save Manager then hide the weapon icons
            if(!bool(CPSaveManager.GetItem("ShowWeaponIcon")))
            {
                MeleeSlot.SetVisible(false);
                PistolSlot.SetVisible(false);
                SMGSlot.SetVisible(false);
                RifleSlot.SetVisible(false);
                ExplosiveSlot.SetVisible(false);
                BombSlot.SetVisible(false);
            }

            // If Show Time is false in the Save Manager then hide the Round and Map Time
            if(!bool(CPSaveManager.GetItem("ShowTime")))
            {
                roundTime.SetVisible(false);
                mapTime.SetVisible(false);
            }
            else
            {
                // Check if our Round Time GFx is currently visible
                ASDisplayInfo = roundTime.GetDisplayInfo();
                if(!ASDisplayInfo.Visible)
                {
                    roundTime.SetVisible(true);
                }

                // Check if our Map Time GFx is currently visible
                ASDisplayInfo = mapTime.GetDisplayInfo();
                if(!ASDisplayInfo.Visible)
                {
                    mapTime.SetVisible(true);
                }
            }
        }
    }
    
    
    
    
    //~~~~~~~~~~~~~~~~~~~~
    // CHAT RENDERING - FADE IN & OUT
    
    //~~~~~~~~~~~~
	// Top row of Chat // First row
	if(bHideAndDestroyTopRow)
	{
		// ~~~~~~~~ Name
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = NameOne.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		NameOne.SetColorTransform(ChatColorTransform);
		
		// ~~~~~~~~ Message 
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = MessageOne.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		MessageOne.SetColorTransform(ChatColorTransform);
		
		if(LC.A <= 0.15f)
		{	
			// Reset textfields
			NameOne.SetString("text", "");
			MessageOne.SetString("text", "");
			NameOne.SetVisible(false);
			MessageOne.SetVisible(false);
			
			bHideAndDestroyTopRow = false;
		}
	}
	else
	{
		if(NameOne.GetColorTransform().Multiply.A != 1.0f)
		{
			ChatColorTransform = NameOne.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			NameOne.SetColorTransform(ChatColorTransform);
		
			// ~~~~~~~~ Message 
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = MessageOne.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			MessageOne.SetColorTransform(ChatColorTransform);
		}
	}
	
	
	
	//~~~~~~~~~~~~
	// Second row of Chat
	if(bHideAndDestroySecondRow)
	{
		// ~~~~~~~~ Name
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = NameTwo.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		NameTwo.SetColorTransform(ChatColorTransform);
		
		// ~~~~~~~~ Message 
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = MessageTwo.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		MessageTwo.SetColorTransform(ChatColorTransform);
		
		if(LC.A <= 0.15f)
		{	
			// Reset textfields
			NameTwo.SetString("text", "");
			MessageTwo.SetString("text", "");
			NameTwo.SetVisible(false);
			MessageTwo.SetVisible(false);
			
			bHideAndDestroySecondRow = false;
		}
	}
	else
	{
		if(NameTwo.GetColorTransform().Multiply.A != 1.0f)
		{
			// ~~~~~~~~ Name
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = NameTwo.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			NameTwo.SetColorTransform(ChatColorTransform);
		
			// ~~~~~~~~ Message 
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = MessageTwo.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			MessageTwo.SetColorTransform(ChatColorTransform);	
		}
	}
	
	
	
	//~~~~~~~~~~~~
	// Third row of Chat
	if(bHideAndDestroyThirdRow)
	{
		// ~~~~~~~~ Name
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = NameThree.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		NameThree.SetColorTransform(ChatColorTransform);
		
		// ~~~~~~~~ Message 
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = MessageThree.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		MessageThree.SetColorTransform(ChatColorTransform);
		
		if(LC.A <= 0.15f)
		{	
			// Reset textfields
			NameThree.SetString("text", "");
			MessageThree.SetString("text", "");
			NameThree.SetVisible(false);
			MessageThree.SetVisible(false);
			
			bHideAndDestroyThirdRow = false;
		}
	}
	else
	{
		if(NameThree.GetColorTransform().Multiply.A != 1.0f)
		{
			// ~~~~~~~~ Name
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = NameThree.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			NameThree.SetColorTransform(ChatColorTransform);
		
			// ~~~~~~~~ Message 
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = MessageThree.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			MessageThree.SetColorTransform(ChatColorTransform);	
		}
	}
	
	
	
	//~~~~~~~~~~~~
	// Forth row of Chat
	if(bHideAndDestroyForthRow)
	{
		// ~~~~~~~~ Name
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = NameFour.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		NameFour.SetColorTransform(ChatColorTransform);
		
		// ~~~~~~~~ Message 
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = MessageFour.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		MessageFour.SetColorTransform(ChatColorTransform);
		
		if(LC.A <= 0.15f)
		{	
			// Reset textfields
			NameFour.SetString("text", "");
			MessageFour.SetString("text", "");
			NameFour.SetVisible(false);
			MessageFour.SetVisible(false);
			
			bHideAndDestroyForthRow = false;
		}
	}
	else
	{
		if(NameFour.GetColorTransform().Multiply.A != 1.0f)
		{
			// ~~~~~~~~ Name
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = NameFour.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			NameFour.SetColorTransform(ChatColorTransform);
		
			// ~~~~~~~~ Message 
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = MessageFour.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			MessageFour.SetColorTransform(ChatColorTransform);	
		}
	}
	
	
	
	
	
	//~~~~~~~~~~~~
	// Bottom row of Chat //  Fifth row
	if(bHideAndDestroyBottomRow)
	{
		// ~~~~~~~~ Name
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = NameFive.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		NameFive.SetColorTransform(ChatColorTransform);
		
		// ~~~~~~~~ Message 
		// Fetch the Color info of the GFx Chat Log
		ChatColorTransform = MessageFive.GetColorTransform();
		LC = ChatColorTransform.Multiply;

		LC.A = Lerp(LC.A, 0.0f, 4.f * DeltaTime);

		// Set the Color information of the GFx asset
		ChatColorTransform.Multiply = LC;
		MessageFive.SetColorTransform(ChatColorTransform);
		
		if(LC.A <= 0.15f)
		{	
			// Reset textfields
			NameFive.SetString("text", "");
			MessageFive.SetString("text", "");
			NameFive.SetVisible(false);
			MessageFive.SetVisible(false);
			
			// Reset arrays so we don't see previous messages
			ChatData.Length = 0;
			ChatNames.Length = 0;
			ChatMessages.Length = 0;
			ChatNameColors.Length = 0;
			ChatMessageColors.Length = 0;
			
			bHideAndDestroyBottomRow = false;
		}
	}
	else
	{
		if(NameFive.GetColorTransform().Multiply.A != 1.0f)
		{
			// ~~~~~~~~ Name
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = NameFive.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			NameFive.SetColorTransform(ChatColorTransform);
		
			// ~~~~~~~~ Message 
			// Fetch the Color info of the GFx Chat Log
			ChatColorTransform = MessageFive.GetColorTransform();
			LC = ChatColorTransform.Multiply;

			LC.A = 1.0f;

			// Set the Color information of the GFx asset
			ChatColorTransform.Multiply = LC;
			MessageFive.SetColorTransform(ChatColorTransform);
		}	
	}
}


function SetSplatterShowArea(int area)
{
    if(area < 0)
    {
        showSplatter = false;
        return;
    }
    else
        showSplatter = true;

    currSplatter = area;
}

function CallASenterZone(string zoneName, string customName, bool hideShow)
{
    ActionScriptVoid("enterZone");
}

function CallASactionPercent(int percentage, string action)
{
    ActionScriptVoid("actionPercent");
}

  // strings are SF, TR, HS
function CallASsetPlayerInfo(string fieldName, int fieldCurrent, int fieldMax)
{
    ActionScriptVoid("setPlayerInfo");
}


function AddDeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed, class<CPDamageType> Dmg)
{
    //`Log("AddDeathMessage UNIMPLEMENTED");
//  local string Msg;
//  //local byte index;

//  if (Killer != none)
//      msg = Killer.PlayerName;
//  else
//      msg = "Suicide";

//  // TODO: Change this to a CPWeapon
//  //if ( ( Dmg != none ) && ( Dmg.default.DamageWeaponClass != none ) )
//  //{
//  //  // Linkgun used to be InventoryGroup=5 in UT3, so need special case here
//  //  index = ClassIsChildOf( Dmg.default.DamageWeaponClass, class'UTWeap_Linkgun' ) ? 5 : Dmg.default.DamageWeaponClass.default.InventoryGroup;
//  //}

//  // TODO: Should it be ut3_weapon? This needs to be swapped to a CPWeapon array
//  //if ( index < 12 )
//  //  msg @= "<img src='ut3_weapon" $ index $ "'>";
//  //else
//      msg @= "<img src='skull'>";

//  msg @= Killed.PlayerName;

//  AddKillMessage("htmlText", msg);
}

function AddChatMessage(string type, string msg, optional name MsgType)
{
    `Log("AddChatMessage UNIMPLEMENTED " $ msg);
//  local TAMessageRow mrow;
//  local GFxObject.ASDisplayInfo DI;
//  local int j;
//  local CPPlayerController TAPC;

//  TAPC = CPPlayerController( GetPC() );

//  //TOP-Proto - sometimes its easier to redirect a message than to recode the game.broadcast event.
//  if(MsgType == 'Event')
//  {
//      AddEventMessage(type, msg, MsgType);
//      return;
//  }

//  if (Len(msg) == 0)
//      return;

//  if(FreeChatMessages.Length == 0)
//      InitChatMessageRow();

//  if (FreeChatMessages.Length > 0)
//  {
//      mrow = FreeChatMessages[FreeChatMessages.Length-1];
//      FreeChatMessages.Remove(FreeChatMessages.Length-1,1);
//  }
//  //else if(ChatMessages.Length > 0)
//  //{
//  //  mrow = ChatMessages[ChatMessages.Length-1];
//  //  ChatMessages.Remove(ChatMessages.Length-1,1);
//  //}

//  if (mrow.TF == none)
//      return;

//  if(mrow.MC == none)
//      return;

//  mrow.TF.SetString(type, msg);
//  mrow.Y = 0;
//  DI.hasY = true;
//  DI.Y = 0;
//  mrow.MC.SetDisplayInfo(DI);
//  mrow.MC.GotoAndPlay("show");
//  mrow.MsgType = MsgType;
//  mrow.FadeTimeStamp = GetPC().WorldInfo.TimeSeconds;
//  mrow.blnIsFading = false;

//    if(MsgType == 'Admin')
//  {
//      mrow.TF.SetString("textColor","0xECFF19"); //yellow
//  }
//  else if(MsgType == 'Spectator')
//  {
//      mrow.TF.SetString("textColor","0x57FF19"); //green
//  }
//  else if(MsgType == 'DeadSay')
//  {
//      if(!TAPC.PlayerReplicationInfo.bOutOfLives)
//      {
//          mrow.TF.SetString(type, "");
//      }
//      mrow.TF.SetString("textColor","0xFFFFFF"); // white
//  }
//  else if(MsgType == 'DeadTeamSay')
//  {
//      if(!TAPC.PlayerReplicationInfo.bOutOfLives)
//      {
//          mrow.TF.SetString(type, "");
//      }
//      //which team are *WE* on? - we wont recieve team messages from the other team!
//      if(TAPC.PlayerReplicationInfo.Team.TeamIndex == 1) //blue team
//      {
//          mrow.TF.SetString("textColor","0x1921FF"); //blue
//      }
//      else //red team
//      {
//          mrow.TF.SetString("textColor","0xFF1919"); //red
//      }
//  }
//  else if(MsgType == 'Say')
//  {
//      mrow.TF.SetString("textColor","0xFFFFFF"); // white
//  }
//  else if(MsgType == 'TeamSay')
//  {
//      //which team are *WE* on? - we wont recieve team messages from the other team!
//      if(TAPC.PlayerReplicationInfo.Team.TeamIndex == 1) //blue team
//      {
//          mrow.TF.SetString("textColor","0x1921FF"); //blue
//      }
//      else //red team
//      {
//          mrow.TF.SetString("textColor","0xFF1919"); //red
//      }
//  }

//  for (j = 0; j < ChatMessages.Length; j++)
//  {
//      if(Len(ChatMessages[j].TF.GetText()) > 45)
//      {
//          DI.Y -= MessageHeight * 2; // double height
//      }
//      else
//      {
//          DI.Y -= MessageHeight; // single height
//      }

//      ChatMessages[j].MC.SetDisplayInfo(DI);
//  }

//  if(Len(mrow.TF.GetText()) > 0)
//      ChatMessages.InsertItem(0,mrow);
}

function AddEventMessage(string type, string msg, optional name MsgType)
{
    `Log("AddEventMessage UNIMPLEMENTED " $ msg);
//  local TAMessageRow mrow;
//  local GFxObject.ASDisplayInfo DI;
//  local int j;

//  if (Len(msg) == 0)
//      return;

//  if(FreeEventMessages.Length == 0)
//      InitEventMessageRow();

//  if (FreeEventMessages.Length > 0)
//  {
//      mrow = FreeEventMessages[FreeEventMessages.Length-1];
//      FreeEventMessages.Remove(FreeEventMessages.Length-1,1);
//  }
//  //else
//  //{
//  //  mrow = EventMessages[EventMessages.Length-1];
//  //  EventMessages.Remove(EventMessages.Length-1,1);
//  //}

//  if (mrow.TF == none)
//      return;

//  if(mrow.MC == none)
//      return;

//  mrow.TF.SetString(type, msg);
//  mrow.Y = 0;
//  DI.hasY = true;
//  DI.Y = 0;
//  mrow.MC.SetDisplayInfo(DI);
//  mrow.MC.GotoAndPlay("show");
//  mrow.MsgType = MsgType;
//  mrow.FadeTimeStamp = GetPC().WorldInfo.TimeSeconds;
//  mrow.blnIsFading = false;

//  mrow.TF.SetString("textColor","0xFF1919"); //red

//  for (j = 0; j < EventMessages.Length; j++)
//  {
//      if(Len(EventMessages[j].TF.GetText()) > 45)
//      {
//          DI.Y -= MessageHeight * 2; // double height
//      }
//      else
//      {
//          DI.Y -= MessageHeight; // single height
//      }

//      EventMessages[j].MC.SetDisplayInfo(DI);
//  }

//  if(Len(mrow.TF.GetText()) > 0)
//      EventMessages.InsertItem(0,mrow);
}

function ToggleCrosshair( bool bToggle )
{
    `Log("ToggleCrosshair DEPRECIATED - TO BE REMOVED");
//  bToggle = !bDrawWeaponCrosshairs && bToggle && !CPPlayerController(GetPC()).bNoCrosshair && CPHUD(GetPC().myHUD).bCrosshairShow;

//  if(Crosshair.root != none)
//      Crosshair.root.SetVisible( bToggle );
}

function ShowMajorEventMessage( string Msg )
{
    `Log("ShowMajorEventMessage UNIMPLEMENTED " $ msg);
//  MultiKill.popupNumber.SetText( "1 - 0");
//  MultiKill.popupText.SetText( Msg );
//  MultiKill.root.GotoAndPlay( "on" );
}

function float GetAngle(Vector targetA, Vector targetB)
{
  local int deltaY, deltaX;
  local float angleDegrees;
  deltaY = targetA.Y - targetB.Y;
  deltaX = targetA.X - targetB.X;

  angleDegrees = (atan2(deltaY, deltaX) * 180 / Pi) + 180;

  return angleDegrees;
}

function float GetYawInDegrees(int target)
{
    local float degrees;
    // Actors yaw will be negative if rotated counter clockwise. It also is relative to the number
    // of rotations so rotating twice will be 720 degrees and so on.
    // Also the yaw value is not in degrees but is relative to 65535. So 65535 = 360 degrees.
    // This calculation gets a yaw relative to 360 degrees instead.
    degrees = target * (360.0/65535.0) % 360.0;

    // If local pawn rotated in counter clockwise direction yaw will be negative. So convert value
    // to be relative to 0 - 360 instead. Otherwise using a negative yaw necessitates more logic
    // elsewhere. Really not necessary to have a negative yaw.
    if(degrees < 0)
    {
        degrees = degrees + 360.0;
    }

    return degrees;
}

function DisplayHit( vector HitDir, int Damage, class<DamageType> damageType )
{
    local int HitQuadrant;
    local CPSaveManager TASave;
    local int HitDirectionalLevel;

    local Rotator rPawnsRotation;
    local Vector vPawnsLocation;
    local float fAngleBetween;
    local float fAngleBetweenTargets;
    local bool bLeftOfPawn;
    local float vPawnsYawnDegrees;

    TASave=new(none,"") class'CPSaveManager';
    HitDirectionalLevel = TASave.GetInt("HitDirectional");

    if(GRI == none)
        GRI = CPGameReplicationInfo( controller.WorldInfo.GRI );

    //Settings Are Off
    if(HitDirectionalLevel == 0 || !GRI.bAllowHitIndicators) return;

    if ( class<CPDamageType>( damageType ) != none && class<CPDamageType>( damageType ).default.bLocationalHit )
    {
        GetPC().GetActorEyesViewPoint( vPawnsLocation, rPawnsRotation );

        // Actors yaw will be negative if rotated counter clockwise. It also is relative to the number
        // of rotations so rotating twice will be 720 degrees. Also the value is not in degrees but is relative to
        // 65535. So 65535 = 360 degrees. This gets a yaw relative to 360 degrees instead.
        vPawnsYawnDegrees = GetYawInDegrees(rPawnsRotation.Yaw);

        // Get the angle between local pawn and damager.
        fAngleBetweenTargets = GetAngle(vPawnsLocation, HitDir);

        // Only bother to get a positive angle in relation to the yawn of the local pawn and the
        // relative angle of the damager.
        if(fAngleBetweenTargets > vPawnsYawnDegrees)
        {
            fAngleBetween = fAngleBetweenTargets - vPawnsYawnDegrees;
            if(fAngleBetween > 180.0)
            {
                bLeftOfPawn = true;
                // Keep angle less than 180 to make things simple when deciding how to
                // draw hit indicator.
                fAngleBetween = abs(fAngleBetween - 360.0);
            }
            else
            {
                bLeftOfPawn = false;
            }
        }
        else
        {
            fAngleBetween = vPawnsYawnDegrees - fAngleBetweenTargets;
            if(fAngleBetween > 180.0)
            {
                bLeftOfPawn = false;
                // Keep angle less than 180 to make things simple when deciding how to
                // draw hit indicator.
                fAngleBetween = abs(fAngleBetween - 360.0);
            }
            else
            {
                bLeftOfPawn = true;
            }
        }


        if(fAngleBetween > 0.0 && fAngleBetween < 35.0) // TOP
            HitQuadrant = 0;
        else if(fAngleBetween > 35.0 && fAngleBetween < 70.0) // TOP LEFT or TOP RIGHT
            HitQuadrant = (bLeftOfPawn ? 7 : 1);
        else if(fAngleBetween > 70.0 && fAngleBetween < 110.0) // LEFT or RIGHT
            HitQuadrant = (bLeftOfPawn ? 6 : 2);
        else if(fAngleBetween > 110.0 && fAngleBetween < 145.0) // BOTTOM LEFT or BOTTOM RIGHT
            HitQuadrant = (bLeftOfPawn ? 5 : 3);
        else if(fAngleBetween > 145.0 && fAngleBetween < 180.0) // BOTTOM
            HitQuadrant = 4;
    }
    else
    {
        HitQuadrant = 0;
    }

    if(HitDirectionalLevel == 1) //Simple
        SimpleHitLocMC[HitQuadrant].GotoAndPlay( "on" );
    else if(HitDirectionalLevel == 2) //Splatter
        SplatterHitLocMC[HitQuadrant].GotoAndPlay( "on" );
}

static function string FormatTime( int Seconds )
{
    local int Hours, Mins;
    local string NewTimeString;

    Hours = Seconds / 3600;
    Seconds -= Hours * 3600;
    Mins = Seconds / 60;
    Seconds -= Mins * 60;

    if (Hours > 0)
        NewTimeString = ( Hours > 9 ? string( Hours ) : "0" $ string( Hours ) ) $ ":";

    NewTimeString = NewTimeString $ ( Mins > 9 ? string( Mins ) : "0" $ string( Mins ) ) $ ":";
    NewTimeString = NewTimeString $ ( Seconds > 9 ? string( Seconds ) : "0" $ string( Seconds ) );

    return NewTimeString;
}

function UpdateWeaponSlots()
{
    SetWeaponsInWeaponBar(CPPawn(Controller.Pawn));
}

function SetWeaponsInWeaponBar(CPPawn tPawn)
{
    local CPWeapon CPWeap;
    local GFxObject TempSlot;
    local array<GFxObject> UsedSlots;
    local int i;
    local float XPos;
    local array<CPWeapon> WeaponList;

    tPawn = CPPawn(controller.ViewTarget);
    if(tPawn == none)
        tPawn = CPPawn( controller.Pawn );

    if(tPawn.InvManager == none)
    {
        for(i=0; i< 6; i++)
        {

            if(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo) != none)
            {
                if(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo).SpectatorOrderedWeapons[i] != none)
                {
                    //`Log(CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo).SpectatorOrderedWeapons[i]);
                     WeaponList[i] = CPPlayerReplicationInfo(tPawn.PlayerReplicationInfo).SpectatorOrderedWeapons[i];
                }
            }
        }
    }
    else
    {
        CPInventoryManager(tPawn.InvManager).GetOrderedWeaponList(WeaponList);

        if(CPPlayercontroller(tPawn.Controller) != none)
        {
            CPPlayercontroller(tPawn.Controller).ClearSpectatorWeaponsOrdered();
        }

        for(i=0; i<WeaponList.Length; i++)
        {
            if(CPPlayercontroller(tPawn.Controller) != none)
            {
				//if(WeaponList[i] != none)
				//{
					CPPlayercontroller(tPawn.Controller).SetSpectatorWeaponsOrdered(WeaponList[i], i);
				//}
            }
        }
    }

    MeleeSlot.SetVisible(false);
    PistolSlot.SetVisible(false);
    SMGSlot.SetVisible(false);
    RifleSlot.SetVisible(false);
    ExplosiveSlot.SetVisible(false);
    BombSlot.SetVisible(false);

    for(i=0; i<WeaponList.Length; i++)
    {
        CPWeap = WeaponList[i];

		if(CPWeap == none) //player died while spectator viewing...
			return;

        if(CPWeap != none)
        {
            switch(CPWeap.WeaponType)
            {
            case WT_KNIFE:
                TempSlot = MeleeSlot;
                break;
            case WT_PISTOL:
                TempSlot = PistolSlot;
                break;
            case WT_SHOTGUN:
                TempSlot = SMGSlot;
                break;
            case WT_SMG:
                TempSlot = SMGSlot;
                break;
            case WT_RIFLE:
                TempSlot = RifleSlot;
                break;
            case WT_GRENADE:
                TempSlot = ExplosiveSlot;
                break;
            case WT_BOMB:
                TempSlot = BombSlot;
                break;
            }
        }

        if(TempSlot != none)
        {
            TempSlot.SetBool("_visible", true);
            TempSlot.GetObject("weaponIcon").GetObject("weaponIcon").GotoAndStop(CPWeap.WeaponFlashName);
            TempSlot.GetObject("ammoInfo").GetObject("ammoAmount").SetText(CPWeap.GetAmmoCount());
            TempSlot.GetObject("ammoInfo").GetObject("clipAmount").SetText(CPWeap.GetClipCount());
        }

        if(CPWeap != none)
        {
            if(CPWeap.GetAmmoCount() <= 0 && !CPWeap.bAmmoStringNullOnEmpty)
            {
                if(CPWeap.GetClipCount() <= 0)
                {
                    CallASGlow(TempSlot, 2);
                }
                else
                {
                    CallASGlow(TempSlot, 1);
                }
            }
            else
            {
                CallASGlow(TempSlot, 0);
            }
        }

        if(TempSlot != none)
        {
            UsedSlots.AddItem(TempSlot);
        }
    }

    //124 = SlotWidth   -    2=Buffer
    XPos = (((UsedSlots.Length * 124) + (UsedSlots.Length * 2))/2)*-1;
    for(i=0; i<UsedSlots.Length; i++)
    {
        UsedSlots[i].SetFloat("_x", xPos);
        xPos += (124 + 2);
    }
}

function SetNewCurrentSlot(CPWeapon CPWeap)
{
    if(EquippedSlot != none)
    {
        EquippedSlot.GotoAndPlay("out");
    }

    switch(CPWeap.WeaponType)
    {
        case WT_KNIFE:
            EquippedSlot = MeleeSlot;
            break;
        case WT_PISTOL:
            EquippedSlot = PistolSlot;
            break;
        case WT_SHOTGUN:
            EquippedSlot = SMGSlot;
            break;
        case WT_SMG:
            EquippedSlot = SMGSlot;
            break;
        case WT_RIFLE:
            EquippedSlot = RifleSlot;
            break;
        case WT_GRENADE:
            EquippedSlot = ExplosiveSlot;
            break;
        case WT_BOMB:
            EquippedSlot = BombSlot;
            break;
    }
    EquippedSlot.GotoAndPlay("in");
}

function UpdateWeaponSlot(CPWeapon CPWeap)
{

    local string AmmoText, ClipText;
    local GFxObject TempSlot;

    switch(CPWeap.WeaponType)
    {
    case WT_KNIFE:
        TempSlot = MeleeSlot;
        break;
    case WT_PISTOL:
        TempSlot = PistolSlot;
        break;
    case WT_SHOTGUN:
        TempSlot = SMGSlot;
        break;
    case WT_SMG:
        TempSlot = SMGSlot;
        break;
    case WT_RIFLE:
        TempSlot = RifleSlot;
        break;
    case WT_GRENADE:
        TempSlot = ExplosiveSlot;
        break;
    case WT_BOMB:
        TempSlot = BombSlot;
        break;
    }

    if(TempSlot == none)
    {
        if(weaponMode != none)
            weaponMode.SetText("");
        GetVariableObject("_root.container.bottomRight.ammoAmount").SetText("");
        GetVariableObject("_root.container.bottomRight.clipAmount").SetText("");
        return;
    }

    if (CPWeap.GetAmmoCount()==0)
    {
        if(CPWeap.bAmmoStringNullOnEmpty)
        {
            AmmoText = "";
        }
        else
        {
            if(CPWeap.GetClipCount() <= 0)
            {
                CallASGlow( TempSlot, 2 );
            }
            else
            {
                CallASGlow(TempSlot, 1);
            }
            AmmoText = String(CPWeap.GetAmmoCount());
        }
    }
    else
    {
        CallASGlow(TempSlot, 0);
        AmmoText = String(CPWeap.GetAmmoCount());
    }

    if (CPWeap.GetClipCount()==0 && CPWeap.bAmmoStringNullOnEmpty)
    {
        ClipText = "";
    }
    else
    {
        ClipText = String(CPWeap.GetClipCount());
    }

    TempSlot.GetObject("ammoInfo").GetObject("ammoAmount").SetText(AmmoText);
    TempSlot.GetObject("ammoInfo").GetObject("clipAmount").SetText(ClipText);

    if(TempSlot == EquippedSlot)
    {
        GetVariableObject("_root.container.bottomRight.ammoAmount").SetText(AmmoText);
        GetVariableObject("_root.container.bottomRight.clipAmount").SetText(ClipText);

        if(weaponMode != none)
            weaponMode.SetText(CPWeap.GetShotMode());
    }
}

function CallASGlow(GFxObject AffectedObject, int bEmpty)
{
    ActionScriptVoid("adjustWeaponGlow");
}

///** weapon properties  IMPORTANT NOTE THIS ENUM MUST BE IDENTICAL TO THE ONE IN CPWEAPON*/
//enum EWeaponType
//{
//  WT_KNIFE,
//  WT_PISTOL,
//  WT_SHOTGUN,
//  WT_SMG,
//  WT_RIFLE,
//  WT_GRENADE,
//  WT_BOMB,
//  WT_TEST
//};
//var CPWeapon CurrentWeap; //cache this for working out the weapon being held.

//struct TAMessageRow
//{
//  var GFxObject    MC, TF;
//  var float       StartFadeTime;
//  var int         Y;
//  var float       FadeTimeStamp;
//  var name        MsgType;
//  var bool        blnIsFading;
//};

///** Anchor points */
//var config Vector2D CenterRightAnchorPct, BottomCenterAnchorPct, BottomLeftAnchorPct, LeftCenterAnchorPct, TopCenterAnchorPct, CenterCenterAnchorPct, TopLeftAnchorPct, TopRightAnchorPct, BottomRightAnchorPct, CenterBottomTextZoneAnchorPct;

///** Messages */
//var GFxObject         ChatAreaMC, EventAreaMC, KillAreaMC, RootMC, TopCenterMC, LeftCenterMC, CenterZoneMC;
//var int                   MessageHeight, NumChatMessages, NumEventMessages, NumKillMessages;
//var array<TAMessageRow>   ChatMessages, KillMessages, EventMessages, FreeChatMessages, FreeKillMessages, FreeEventMessages;

///** General elements */
//var       GFxObject       CenterTextMC, CenterTextTF;
//var       GFxObject       CenterTextMCBottom, CenterTextTFBottom;



///** Popup */
//struct PopupObj
//{
//  var GFxObject       root, popupNumber, popupText;
//};
//var       PopupObj        MultiKill;

///** Crosshair */
//struct CrosshairObj
//{
//  var GFxObject       root, top, left, bottom, right;
//};
//var       CrosshairObj    Crosshair;

//struct TopLeftZoneObj
//{
//  var GFxObject       root, lblMoneyAmount;
//};
//var       TopLeftZoneObj      TopLeftZoneMC;

///** HackZone */
//struct HackZoneObj
//{
//  var GFxObject       root, MCPercentageBar, PercentageOfPercentageText, ActionPerformedText;
//};
//var       HackZoneObj     HackZone;

///** TopRight Zone elements */
//struct TopRightZoneObj
//{
//  var GFxObject       root, lblRoundTime, lblMapTime;
//};
//var       TopRightZoneObj TopRightZoneMC;

///** BottomCenter Zone elements */
//struct BottomCenterMCObj
//{
//  //weapon bar movie clip object holder zones
//  var GFxObject       root, WeaponZoneBG, KnifeZone, PistolZone, SMGZone, RifleZone, NadeZone, BombZone;
//  //weaponbar clip values
//  var GFXObject        lblPistolClipValue, lblSMGClipValue, lblRifleClipValue;
//  //weaponbar ammo values
//  var GFxObject       lblMeleeAmmoValue, lblPistolAmmoValue, lblSMGAmmoValue, lblRifleAmmoValue;
//  // dynamic weapon icon selection
//  var GFxObject       gfxTheMeleeWeapon, gfxThePistolWeapon, gfxTheSMGWeapon, gfxTheRifleWeapon, gfxTheGrenadeWeapon, gfxTheBombWeapon;
//  //keep track of what weapon zones are up and down
//  var bool            bMelee, bPistol, bSMG, bRifle, bNade, bBomb;
//  //flash problem means the labels dont move with the animation if BottomCenterMC.lblPistolAmmoValue.GetText() != string(Weap.AmmoCount)) is constantly called means we need to cache the ammocount values.
//  var int             intKnifeAmmoCount, intPistolAmmoCount, intPistolClipCount, intSMGAmmoCount, intSMGClipCount, intRifleAmmoCount, intRifleClipCount;
//};
//var       BottomCenterMCObj   BottomCenterMC;


///** Ammo Zone elements */
//struct AmmoZoneObj
//{
//  var GFxObject       root, lblBulletValue, lblClipValue, lblShotMode;
//};
//var       AmmoZoneObj     AmmoZone;
//var       Weapon          CurWeapon;
//var       int             CurAmmoCount, CurClipCount;
//var       string          CurShotMode;
//var       config
//      int             ShotModeTextLength;

///**  Health Zone elements */
//struct HealthZoneObj
//{
//  var GFxObject       root, MCHealth, lblHealthValue, lblHealthStatus;
//};
//var       HealthZoneObj   HealthZone;
//var       int             CurHealthValue;

///**  Notify Zone elements */
//struct NotifyZoneObj
//{
//  var GFxObject       root, BuyZone_Icon, GenericZone_Icon, GenericZone_IconText;
//  var bool            BuyZoneShowing, GenericZoneShowing;
//  var string          strZoneText;

//  StructDefaultProperties
//  {
//      strZoneText = "";
//      BuyZoneShowing=false
//      GenericZoneShowing=false
//  }
//};
//var       NotifyZoneObj   NotifyZone;


///** Armor Zone elements */
//struct ArmorZoneObj
//{
//  var GFxObject       root, HeadZone, BodyZone, LegZone;
//};
//var       ArmorZoneObj    ArmorZone;
//var CONST ASColorTransform LIGHTGREEN, DARKGREEN, YELLOW, LIGHTRED, WHITE;



///** Compass icon */
//var GFxObject                CompassIcon;

///** Chat Box for talking ingame*/
//var GFxObject                   Chatbox;
//var       bool                    blnFadeOut;     //used to control the fade in and out of the textbox for asthetical reasons.

////x left right  (1920)
////y up down     (1200)

//// to convert to a percentage
//// Take your value and divide it by your max value
//function ScaleHUD( float scale )
//{
//  //add components here.
//  ScaleHUDComponent( TopLeftZoneMC.root,  scale, TopLeftAnchorPct );
//  ScaleHUDComponent( LeftCenterMC,        scale, LeftCenterAnchorPct );
//  ScaleHUDComponent( HealthZone.root,     scale, BottomLeftAnchorPct );       //bottom right
//  ScaleHUDComponent( TopRightZoneMC.root, scale, TopRightAnchorPct );
//  ScaleHUDComponent( AmmoZone.root,       scale, BottomRightAnchorPct );      //bottom left
//  ScaleHUDComponent( TopCenterMC,         scale, TopCenterAnchorPct );
//  ScaleHUDComponent( CenterZoneMC,        scale, CenterCenterAnchorPct );
//  ScaleHUDComponent( BottomCenterMC.root, scale, BottomCenterAnchorPct );
//  ScaleHUDComponent( NotifyZone.root,     scale, CenterRightAnchorPct );      //center right
//  ScaleHUDComponent( CenterTextMCBottom,  scale, CenterBottomTextZoneAnchorPct );
//}

//function ScaleHUDComponent( GFxObject MovieClip, float scale, Vector2D Anchor )
//{
//  local ASDisplayInfo DInfo;
//  local CPHUD THUD;

//  THUD = CPHUD( GetPC().myHUD );

//  if(THUD == none || RootMC == none)
//      return;

//  if ( ( THUD.ViewX / THUD.ViewY ) > 1.3333f )
//      scale *= THUD.ViewY / RootMC.GetFloat( "_height" ); // Widescreen
//  else
//      scale *= THUD.ViewX / RootMC.GetFloat( "_width" ); // Non-Widescreen

//  DInfo.hasX = true;
//  DInfo.hasY = true;
//  DInfo.hasXScale = true;
//  DInfo.hasYScale = true;
//  DInfo.X = Round( CPHUD( GetPC().myHUD ).ViewX * Anchor.X );
//  DInfo.Y = Round( CPHUD( GetPC().myHUD ).ViewY * Anchor.Y );
//  DInfo.XScale = scale * 100;
//  DInfo.YScale = scale * 100;

//  MovieClip.SetDisplayInfo( DInfo );
//}

//function bool IsValidPlayer( CPPlayerReplicationInfo PRI)
//{
//  if ( !PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
//      (PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None)) )
//  {
//      return false;
//  }

//  return true;
//}


//function SetupWeaponBar()
//{
//  //weapon bar movie clip object holder zones implementation
//  BottomCenterMC.root                 = GetVariableObject( "_root.BOTTOMBAR" );
//  BottomCenterMC.WeaponZoneBG         = BottomCenterMC.root.GetObject("WeaponZoneBG");
//  BottomCenterMC.KnifeZone            = BottomCenterMC.WeaponZoneBG.GetObject("KnifeZone");
//  BottomCenterMC.PistolZone           = BottomCenterMC.WeaponZoneBG.GetObject("PistolZone");
//  BottomCenterMC.SMGZone              = BottomCenterMC.WeaponZoneBG.GetObject("SMGZone");
//  BottomCenterMC.RifleZone            = BottomCenterMC.WeaponZoneBG.GetObject("RifleZone");
//  BottomCenterMC.NadeZone             = BottomCenterMC.WeaponZoneBG.GetObject("NadeZone");
//  BottomCenterMC.BombZone             = BottomCenterMC.WeaponZoneBG.GetObject("BombZone");

//  //ammo and clip implementation
//  BottomCenterMC.lblMeleeAmmoValue    = BottomCenterMC.KnifeZone.GetObject("ammoKnife").GetObject("lblMeleeAmmoValue");
//  BottomCenterMC.lblPistolAmmoValue   = BottomCenterMC.PistolZone.GetObject("ammoPistol").GetObject("lblPistolAmmoValue");
//  BottomCenterMC.lblPistolClipValue   = BottomCenterMC.PistolZone.GetObject("clipPistol").GetObject("lblPistolClipValue");
//  BottomCenterMC.lblSMGAmmoValue      = BottomCenterMC.SMGZone.GetObject("ammoSMG").GetObject("lblSMGAmmoValue");
//  BottomCenterMC.lblSMGClipValue      = BottomCenterMC.SMGZone.GetObject("clipSMG").GetObject("lblSMGClipValue");
//  BottomCenterMC.lblRifleAmmoValue    = BottomCenterMC.RifleZone.GetObject("ammoRifle").GetObject("lblRifleAmmoValue");
//  BottomCenterMC.lblRifleClipValue    = BottomCenterMC.RifleZone.GetObject("clipRifle").GetObject("lblRifleClipValue");

//  //dynamic weapon icon implementation
//  BottomCenterMC.gfxTheMeleeWeapon    = BottomCenterMC.KnifeZone.GetObject("gfxTheMeleeWeapon");
//  BottomCenterMC.gfxThePistolWeapon   = BottomCenterMC.PistolZone.GetObject("gfxThePistolWeapon");
//  BottomCenterMC.gfxTheSMGWeapon      = BottomCenterMC.SMGZone.GetObject("gfxTheSMGWeapon");
//  BottomCenterMC.gfxTheRifleWeapon    = BottomCenterMC.RifleZone.GetObject("gfxTheRifleWeapon");
//  BottomCenterMC.gfxTheGrenadeWeapon  = BottomCenterMC.NadeZone.GetObject("gfxTheGrenadeWeapon");

//  BottomCenterMC.gfxTheBombWeapon = BottomCenterMC.BombZone.GetObject("gfxTheBombWeapon");
//}

//function AddKillMessage(string type, string msg, optional name MsgType)
//{
//  local TAMessageRow mrow;
//  local GFxObject.ASDisplayInfo DI;
//  local int j;

//  if (Len(msg) == 0)
//      return;

//  if(FreeKillMessages.Length == 0)
//      InitKillsMessageRow();

//  if (FreeKillMessages.Length > 0)
//  {
//      mrow = FreeKillMessages[FreeKillMessages.Length-1];
//      FreeKillMessages.Remove(FreeKillMessages.Length-1,1);
//  }

//  //else
//  //{
//      //mrow = KillMessages[KillMessages.Length-1];
//      //KillMessages.Remove(KillMessages.Length-1,1);
//  //}

//  if (mrow.TF == none)
//      return;

//  if(mrow.MC == none)
//      return;

//  mrow.TF.SetString(type, msg);
//  mrow.Y = 0;
//  DI.hasY = true;
//  DI.Y = 0;
//  mrow.MC.SetDisplayInfo(DI);
//  mrow.MC.GotoAndPlay("show");
//  mrow.MsgType = MsgType;
//  mrow.FadeTimeStamp = GetPC().WorldInfo.TimeSeconds;
//  mrow.blnIsFading = false;

//  mrow.TF.SetString("textColor","0x57FF19"); //green

//  for (j = 0; j < KillMessages.Length; j++)
//  {
//      if(Len(KillMessages[j].TF.GetText()) > 45)
//      {
//          DI.Y -= MessageHeight * 2; // double height
//      }
//      else
//      {
//          DI.Y -= MessageHeight; // single height
//      }

//      KillMessages[j].MC.SetDisplayInfo(DI);
//  }

//  if(Len(mrow.TF.GetText()) > 0)
//      KillMessages.InsertItem(0,mrow);
//}

//function GFxObject CreateChatMessageRow()
//{
//  if(ChatAreaMC != none)
//      return ChatAreaMC.AttachMovie( "LogMessage", "logMessage" $ NumChatMessages++ );
//}

//function GFxObject CreateEventMessageRow()
//{
//  return EventAreaMC.AttachMovie( "LogMessage", "logMessage" $ NumEventMessages++ );
//}

//function GFxObject CreateKillMessageRow()
//{
//  return KillAreaMC.AttachMovie( "LogMessage", "logMessage" $ NumKillMessages++ );
//}

//function InitChatMessageRow()
//{
//  local TAMessageRow MRow;

//  mrow.Y = 0;
//  if(mrow.MC != none)
//      mrow.MC = CreateChatMessageRow();

//  if(mrow.TF != none)
//  {
//      mrow.TF = mrow.MC.GetObject( "message" ).GetObject( "textField" );
//      mrow.TF.SetBool( "html", true );
//      mrow.TF.SetString( "htmlText", "" );
//  }

//  FreeChatMessages.AddItem(mrow);
//}

//function InitEventMessageRow()
//{
//  local TAMessageRow MRow;

//  mrow.Y = 0;

//  if(mrow.MC != none)
//      mrow.MC = CreateEventMessageRow();

//  if(mrow.TF != none)
//  {
//      mrow.TF = mrow.MC.GetObject( "message" ).GetObject( "textField" );
//      mrow.TF.SetBool( "html", true );
//      mrow.TF.SetString( "htmlText", "" );
//  }
//  FreeEventMessages.AddItem(mrow);
//}

//function InitKillsMessageRow()
//{
//  local TAMessageRow MRow;

//  mrow.Y = 0;

//  if(mrow.MC != none)
//      mrow.MC = CreateKillMessageRow();

//  if(mrow.TF != none)
//  {
//      mrow.TF = mrow.MC.GetObject( "message" ).GetObject( "textField" );
//      mrow.TF.SetBool( "html", true );
//      mrow.TF.SetString( "htmlText", "" );
//  }

//  FreeKillMessages.AddItem(mrow);
//}


//function ShowHudElements( bool Show )
//{
//  if(ArmorZone.root != none)
//      ArmorZone.root.SetVisible( Show );

//  if(AmmoZone.root != none)
//      AmmoZone.root.SetVisible( Show );

//  if(HealthZone.root != none)
//      HealthZone.root.SetVisible( Show );

//  if(NotifyZone.root != none)
//      NotifyZone.root.SetVisible( Show );
//  //TopRightZoneMC.root.SetVisible( Show );
//  // Rogue. Disable this element for now until the Scaleform HUD is complete
//  // and functional.
//  if(TopRightZoneMC.root != none)
//      TopRightZoneMC.root.SetVisible( false );
//}

//function ShowSpectHudElements( bool Show )
//{
//  if(ArmorZone.root != none)
//      ArmorZone.root.SetVisible( false );

//  if(AmmoZone.root != none)
//      AmmoZone.root.SetVisible( false );

//  if(HealthZone.root != none)
//      HealthZone.root.SetVisible( false );

//  if(NotifyZone.root != none)
//      NotifyZone.root.SetVisible( false );
//  //TopRightZoneMC.root.SetVisible( Show );
//  // Rogue. Disable this element for now until the Scaleform HUD is complete
//  // and functional.

//  if(TopRightZoneMC.root != none)
//      TopRightZoneMC.root.SetVisible( false );
//}

//function ShowMultiKill( int Count, string Msg )
//{
//  MultiKill.popupNumber.SetText( Count + 1 );
//  MultiKill.popupText.SetText( Msg );
//  MultiKill.root.GotoAndPlay( "on" );
//}

//function ASColorTransform SetArmorColor( float ArmorValue )
//{
//  return ( ArmorValue < 0.75 ) ? ( ArmorValue < 0.5 ) ? ( ArmorValue < 0.25 ) ? LIGHTRED : YELLOW : LIGHTGREEN : DARKGREEN;
//}



///** Customised for the keybind menu - this is a hook to intercept the keybinds*/
//event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
//{
//  if(!bCaptureInput)
//  {
//      super.FilterButtonInput(ControllerID,ButtonName,InputEvent);
//      return false;
//  }

//  if (InputEvent == IE_Pressed && ButtonName == 'Enter') //Escape to be worked on cause escape is what pops the menus.
//  {
//      if(Chatbox != none)
//      {
//          if(Len(Chatbox.GetText()) != 0)
//          {
//              if(CPPlayerController(GetPC()).bTyping)
//              {
//                  ConsoleCommand("Say " $ Chatbox.GetText());
//              }
//              else if (CPPlayerController(GetPC()).bTeamTyping)
//              {
//                  ConsoleCommand("TeamSay " $ Chatbox.GetText());
//              }
//          }
//      }
//      CPPlayerController(GetPC()).bTyping = false;
//      CPPlayerController(GetPC()).bTeamTyping = false;
//      bCaptureInput = false;
//      //send the text.

//      return true;
//  }

//  return false;
//}

//function GetWeaponbarWeaponry(CPPawn CPP)
//{
//  local CPWeapon Weap;
//  local int weapontypeindex;
//  local array<string> weaponIcons;

//  if(CPP.InvManager != none)
//  {
//      for(weapontypeindex = 0; weapontypeindex < EWeaponType.EnumCount; weapontypeindex++)
//      {
//          switch( GetEnum(enum'EWeaponType',weapontypeindex) )
//          {
//              case 'WT_KNIFE':
//                  if(HoldingWeaponType(CPP, WT_KNIFE, Weap))
//                  {
//                      if(BottomCenterMC.gfxTheMeleeWeapon != none)
//                          BottomCenterMC.gfxTheMeleeWeapon.GotoAndStopI(Weap.WeaponIconIndex);

//                      if(BottomCenterMC.intKnifeAmmoCount != Weap.AmmoCount)
//                      {
//                          BottomCenterMC.intKnifeAmmoCount = Weap.AmmoCount;
//                          if(BottomCenterMC.lblMeleeAmmoValue != none)
//                              BottomCenterMC.lblMeleeAmmoValue.SetText(Weap.AmmoCount);
//                      }

//                      weaponIcons[ weaponIcons.Length ] = "knife";
//                  }
//              break;

//              case 'WT_PISTOL':
//                  if(HoldingWeaponType(CPP, WT_PISTOL, Weap))
//                  {
//                      if(BottomCenterMC.gfxThePistolWeapon != none)
//                          BottomCenterMC.gfxThePistolWeapon.GotoAndStopI(Weap.WeaponIconIndex);

//                      if(BottomCenterMC.intPistolAmmoCount != Weap.AmmoCount)
//                      {
//                          BottomCenterMC.intPistolAmmoCount = Weap.AmmoCount;

//                          if(BottomCenterMC.lblPistolAmmoValue != none)
//                              BottomCenterMC.lblPistolAmmoValue.SetText(Weap.AmmoCount);
//                      }

//                      if(BottomCenterMC.intPistolClipCount != Weap.ClipCount)
//                      {
//                          BottomCenterMC.intPistolClipCount = Weap.ClipCount;

//                          if(BottomCenterMC.lblPistolClipValue != none)
//                              BottomCenterMC.lblPistolClipValue.SetText(Weap.ClipCount);
//                      }

//                      weaponIcons[ weaponIcons.Length ] = "pistol";
//                  }
//              break;

//              //case 'WT_SHOTGUN': //handled in WT_SMG.

//              case 'WT_SMG':
//                  if(HoldingWeaponType(CPP, WT_SMG, Weap))
//                  {
//                      if(BottomCenterMC.gfxTheSMGWeapon != none)
//                          BottomCenterMC.gfxTheSMGWeapon.GotoAndStopI(Weap.WeaponIconIndex);

//                      if(BottomCenterMC.intSMGAmmoCount != Weap.AmmoCount)
//                      {
//                          BottomCenterMC.intSMGAmmoCount = Weap.AmmoCount;

//                          if(BottomCenterMC.lblSMGAmmoValue != none)
//                              BottomCenterMC.lblSMGAmmoValue.SetText(Weap.AmmoCount);
//                      }

//                      if(BottomCenterMC.intSMGClipCount != Weap.ClipCount)
//                      {
//                          BottomCenterMC.intSMGClipCount = Weap.ClipCount;

//                          if(BottomCenterMC.lblSMGClipValue != none)
//                              BottomCenterMC.lblSMGClipValue.SetText(Weap.ClipCount);
//                      }

//                      weaponIcons[ weaponIcons.Length ] = "smg";
//                  }
//                  else
//                  {
//                      if(HoldingWeaponType(CPP, WT_SHOTGUN, Weap))
//                      {
//                          if(BottomCenterMC.gfxTheSMGWeapon != none)
//                              BottomCenterMC.gfxTheSMGWeapon.GotoAndStopI(Weap.WeaponIconIndex);

//                          if(BottomCenterMC.intSMGAmmoCount != Weap.AmmoCount)
//                          {
//                              BottomCenterMC.intSMGAmmoCount = Weap.AmmoCount;

//                              if(BottomCenterMC.lblSMGAmmoValue != none)
//                                  BottomCenterMC.lblSMGAmmoValue.SetText(Weap.AmmoCount);
//                          }

//                          if(BottomCenterMC.intSMGClipCount != Weap.ClipCount)
//                          {
//                              BottomCenterMC.intSMGClipCount = Weap.ClipCount;

//                              if(BottomCenterMC.lblSMGClipValue != none)
//                                  BottomCenterMC.lblSMGClipValue.SetText(Weap.ClipCount);
//                          }

//                          weaponIcons[ weaponIcons.Length ] = "smg";
//                      }
//                  }
//              break;

//              case 'WT_RIFLE':
//                  if(HoldingWeaponType(CPP, WT_RIFLE, Weap))
//                  {
//                      if(BottomCenterMC.gfxTheRifleWeapon != none)
//                          BottomCenterMC.gfxTheRifleWeapon.GotoAndStopI(Weap.WeaponIconIndex);

//                      if(BottomCenterMC.intRifleAmmoCount != Weap.AmmoCount)
//                      {
//                          BottomCenterMC.intRifleAmmoCount = Weap.AmmoCount;

//                          if(BottomCenterMC.lblRifleAmmoValue != none)
//                              BottomCenterMC.lblRifleAmmoValue.SetText(Weap.AmmoCount);
//                      }

//                      if(BottomCenterMC.intRifleClipCount != Weap.ClipCount)
//                      {
//                          BottomCenterMC.intRifleClipCount = Weap.ClipCount;

//                          if(BottomCenterMC.lblRifleClipValue != none)
//                              BottomCenterMC.lblRifleClipValue.SetText(Weap.ClipCount);
//                      }

//                      weaponIcons[ weaponIcons.Length ] = "rifle";
//                  }
//              break;

//              case 'WT_GRENADE':
//                  if(HoldingWeaponType(CPP, WT_GRENADE, Weap))
//                  {
//                      if(BottomCenterMC.gfxTheGrenadeWeapon != none)
//                          BottomCenterMC.gfxTheGrenadeWeapon.GotoAndStopI(Weap.WeaponIconIndex);
//                      weaponIcons[ weaponIcons.Length ] = "nade";
//                  }
//              break;

//              case 'WT_BOMB':
//                  if(HoldingWeaponType(CPP, WT_BOMB, Weap))
//                  {
//                      if(BottomCenterMC.gfxTheBombWeapon != none)
//                          BottomCenterMC.gfxTheBombWeapon.GotoAndStopI(Weap.WeaponIconIndex);
//                      weaponIcons[ weaponIcons.Length ] = "bomb";
//                  }
//              break;
//          }
//      }

//      resetWeaponIcons(weaponIcons);
//  }

//  if(CurrentWeap != CPP.Weapon)
//  {
//      CurrentWeap = CPWeapon(CPP.Weapon);

//      if ( CurrentWeap != none )
//          switch( CurrentWeap.WeaponType )
//          {
//              case WT_KNIFE:
//                  BottomCenterMC.bMelee = true;
//                  SelectKnife();
//              break;
//              case WT_PISTOL:
//                  BottomCenterMC.bPistol = true;
//                  SelectPistol();
//              break;
//              case WT_SHOTGUN:
//                  BottomCenterMC.bSMG = true;
//                  SelectSMG();
//              break;
//              case WT_SMG:
//                  BottomCenterMC.bSMG = true;
//                  SelectSMG();
//              break;
//              case WT_RIFLE:
//                  BottomCenterMC.bRifle = true;
//                  SelectRifle();
//              break;
//              case WT_GRENADE:
//                  BottomCenterMC.bNade = true;
//                  SelectNade();
//              break;
//              case WT_BOMB:
//                  BottomCenterMC.bBomb = true;
//                  SelectBomb();
//              break;
//          }
//  }
//}

//function bool HoldingWeaponType(CPPawn CPP, EWeapontype theWeaponType, out CPWeapon Weap)
//{
//  local CPWeapon HoldingWeap;

//  ForEach CPP.InvManager.InventoryActors(class'CPWeapon',HoldingWeap)
//  {
//      if(HoldingWeap.WeaponType == theWeaponType)
//      {
//          Weap = HoldingWeap;
//          return true;
//      }
//  }
//  return false;
//}

//function SelectKnife()
//{
//  BottomCenterMC.KnifeZone.GotoAndPlay("selected");
//  DeSelectPistol();
//  DeSelectSMG();
//  DeSelectRifle();
//  DeSelectNade();
//  DeSelectBomb();
//}

//function SelectPistol()
//{
//  BottomCenterMC.PistolZone.GotoAndPlay("selected");
//  DeSelectKnife();
//  DeSelectSMG();
//  DeSelectRifle();
//  DeSelectNade();
//  DeSelectBomb();
//}

//function SelectSMG()
//{
//  BottomCenterMC.SMGZone.GotoAndPlay("selected");
//  DeSelectKnife();
//  DeSelectPistol();
//  DeSelectRifle();
//  DeSelectNade();
//  DeSelectBomb();
//}

//function SelectRifle()
//{
//  BottomCenterMC.RifleZone.GotoAndPlay("selected");
//  DeSelectKnife();
//  DeSelectPistol();
//  DeSelectSMG();
//  DeSelectNade();
//  DeSelectBomb();
//}

//function SelectNade()
//{
//  BottomCenterMC.NadeZone.GotoAndPlay("selected");
//  DeSelectKnife();
//  DeSelectPistol();
//  DeSelectSMG();
//  DeSelectRifle();
//  DeSelectBomb();
//}

//function SelectBomb()
//{
//  BottomCenterMC.BombZone.GotoAndPlay("selected");
//  DeSelectKnife();
//  DeSelectPistol();
//  DeSelectSMG();
//  DeSelectRifle();
//  DeSelectNade();
//}

//function DeSelectBomb()
//{
//  if(BottomCenterMC.bBomb)
//  {
//      BottomCenterMC.bBomb = false;
//      BottomCenterMC.BombZone.GotoAndPlay("deselected");
//  }
//}

//function DeSelectKnife()
//{
//  if(BottomCenterMC.bMelee)
//  {
//      BottomCenterMC.bMelee = false;
//      BottomCenterMC.KnifeZone.GotoAndPlay("deselected");
//  }
//}

//function DeSelectPistol()
//{
//  if(BottomCenterMC.bPistol)
//  {
//      BottomCenterMC.bPistol = false;
//      BottomCenterMC.PistolZone.GotoAndPlay("deselected");
//  }
//}

//function DeSelectSMG()
//{
//  if(BottomCenterMC.bSMG)
//  {
//      BottomCenterMC.bSMG = false;
//      BottomCenterMC.SMGZone.GotoAndPlay("deselected");
//  }
//}

//function DeSelectRifle()
//{
//  if(BottomCenterMC.bRifle)
//  {
//      BottomCenterMC.bRifle = false;
//      BottomCenterMC.RifleZone.GotoAndPlay("deselected");
//  }
//}

//function DeSelectNade()
//{
//  if(BottomCenterMC.bNade)
//  {
//      BottomCenterMC.bNade = false;
//      BottomCenterMC.NadeZone.GotoAndPlay("deselected");
//  }
//}

//function resetWeaponIcons(array<string> weaponIcons)
//{
//  ActionScriptVoid("resetWeaponIcons");
//}






/**
 * Widget has been initialized by Scaleform. Perform any other widget initialization here.
 *
 * @param       WidgetName      Name of the widget that was initialized
 * @param       WidgetPath      Path of the widget that was initialized
 * @param       Widget          Object reference of the widget that was initialized
 * @return                      Returns true if the widget was initialized
 */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local CPSaveManager CPSaveManager;

    CPSaveManager = new () class'CPSaveManager';

    switch(WidgetName)
    {
        case ('chatInput'):
            ChatInput = GFxClikWidget(Widget);
            if(ChatInput != none)
            {
                if(CPSaveManager != none)
                {
                    WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                    ChatInput.SetVisible(WidgetVisible);
                }
            }
        break;
        case ('TeamLabel'):
            TeamLabel = GFxClikWidget(Widget);
            if(TeamLabel != none)
            {
                TeamLabel.SetVisible(false);
            }
        break;
		
		case ('name1'):
		NameOne = GFxClikWidget(Widget);
		if(NameOne != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                NameOne.SetVisible(WidgetVisible);
            }
            
			NameOne.SetString("text", " ");
		}
		break;
		
		case ('message1'):
		MessageOne = GFxClikWidget(Widget);
		if(MessageOne != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                MessageOne.SetVisible(WidgetVisible);
            }
            
			MessageOne.SetString("text", " ");
		}
		break;
		
		case ('name2'):
		NameTwo = GFxClikWidget(Widget);
		if(NameTwo != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                NameTwo.SetVisible(WidgetVisible);
            }
            
			NameTwo.SetString("text", " ");
		}
		break;
		
		case ('message2'):
		MessageTwo = GFxClikWidget(Widget);
		if(MessageTwo != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                MessageTwo.SetVisible(WidgetVisible);
            }
            
			MessageTwo.SetString("text", " ");
		}
		break;
		
		case ('name3'):
		NameThree = GFxClikWidget(Widget);
		if(NameThree != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                NameThree.SetVisible(WidgetVisible);
            }
            
			NameThree.SetString("text", " ");
		}
		break;
		
		case ('message3'):
		MessageThree = GFxClikWidget(Widget);
		if(MessageThree != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                MessageThree.SetVisible(WidgetVisible);
            }
            
			MessageThree.SetString("text", " ");
		}
		break;
		
		case ('name4'):
		NameFour = GFxClikWidget(Widget);
		if(NameFour != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                NameFour.SetVisible(WidgetVisible);
            }
            
			NameFour.SetString("text", " ");
		}
		break;
		
		case ('message4'):
		MessageFour = GFxClikWidget(Widget);
		if(MessageFour != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                MessageFour.SetVisible(WidgetVisible);
            }
            
			MessageFour.SetString("text", " ");
		}
		break;
		
		case ('name5'):
		NameFive = GFxClikWidget(Widget);
		if(NameFive != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                NameFive.SetVisible(WidgetVisible);
            }
            
			NameFive.SetString("text", " ");
		}
		break;
		
		case ('message5'):
		MessageFive = GFxClikWidget(Widget);
		if(MessageFive != none)
		{
			if(CPSaveManager != none)
            {
                WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
                MessageFive.SetVisible(WidgetVisible);
            }
            
			MessageFive.SetString("text", " ");
		}
		break;

        default:
            break;
    }

    return true;
}


/*
 *	Set each row of text and their colours
*/
function SetUpDataProvider()
{
	local int i;

	for (i = 0; i < ChatData.Length; i++)
	{      			
		GetPC().ClearTimer(NameOf(HideAndDestroyBottomRow), self);
		bHideAndDestroyBottomRow = false;
		
		NameFive.SetVisible(true);
		MessageFive.SetVisible(true);
		
		// Set bottom row // Fifth row
		NameFive.SetString("text", ChatData[i].PlayerName);
		MessageFive.SetString("text", ChatData[i].Message);
		NameFive.SetColorTransform(ChatData[i].NameColor);
		MessageFive.SetColorTransform(ChatData[i].MessageColor);
		
		
		GetPC().SetTimer(6.5f, false, NameOf(HideAndDestroyBottomRow), self);	
		
		if(ChatData.Length > 1)
		{
			if(i > 0)
			{			
				if(NameFive.GetBool("visible"))
				{
					GetPC().ClearTimer(NameOf(HideAndDestroyForthRow), self);
					bHideAndDestroyForthRow = false;
					
					NameFour.SetVisible(true);
					MessageFour.SetVisible(true);
					
					// Set forth row
					NameFour.SetString("text", ChatData[i - 1].PlayerName);
					MessageFour.SetString("text", ChatData[i - 1].Message);
					NameFour.SetColorTransform(ChatData[i - 1].NameColor);
					MessageFour.SetColorTransform(ChatData[i - 1].MessageColor);
				
					GetPC().SetTimer(5.0f, false, NameOf(HideAndDestroyForthRow), self);	
				}
				
				if(ChatData.Length > 2)
				{
					if(i > 1)
					{		
						if(NameFour.GetBool("visible"))
						{		
							GetPC().ClearTimer(NameOf(HideAndDestroyThirdRow), self);
							bHideAndDestroyThirdRow = false;
							
							NameThree.SetVisible(true);
							MessageThree.SetVisible(true);
			
							// Set third row
							NameThree.SetString("text", ChatData[i - 2].PlayerName);
							MessageThree.SetString("text", ChatData[i - 2].Message);
							NameThree.SetColorTransform(ChatData[i - 2].NameColor);
							MessageThree.SetColorTransform(ChatData[i - 2].MessageColor);
						

							GetPC().SetTimer(3.5f, false, NameOf(HideAndDestroyThirdRow), self);	
						}
						
						if(ChatData.Length > 3)
						{
							if(i > 2)
							{		
								if(NameThree.GetBool("visible"))
								{		
									GetPC().ClearTimer(NameOf(HideAndDestroySecondRow), self);
									bHideAndDestroySecondRow = false;
							
									NameTwo.SetVisible(true);
									MessageTwo.SetVisible(true);
			
									// Set second row 
									NameTwo.SetString("text", ChatData[i - 3].PlayerName);
									MessageTwo.SetString("text", ChatData[i - 3].Message);
									NameTwo.SetColorTransform(ChatData[i - 3].NameColor);
									MessageTwo.SetColorTransform(ChatData[i - 3].MessageColor);
						

									GetPC().SetTimer(2.0f, false, NameOf(HideAndDestroySecondRow), self);	
								}
								
								if(ChatData.Length > 4)
								{
									if(i > 3)
									{		
										if(NameTwo.GetBool("visible"))
										{		
											GetPC().ClearTimer(NameOf(HideAndDestroyTopRow), self);
											bHideAndDestroyTopRow = false;
							
											NameOne.SetVisible(true);
											MessageOne.SetVisible(true);
			
											// Set top row // First row
											NameOne.SetString("text", ChatData[i - 4].PlayerName);
											MessageOne.SetString("text", ChatData[i - 4].Message);
											NameOne.SetColorTransform(ChatData[i - 4].NameColor);
											MessageOne.SetColorTransform(ChatData[i - 4].MessageColor);
						

											GetPC().SetTimer(0.5f, false, NameOf(HideAndDestroyTopRow), self);	
										}
									}
								}
							}
						}
					}
				}
			}
		}	
	}	

}

function HideAndDestroyTopRow()
{
	bHideAndDestroyTopRow = true;
}

function HideAndDestroySecondRow()
{
	bHideAndDestroySecondRow = true;
}

function HideAndDestroyThirdRow()
{
	bHideAndDestroyThirdRow = true;
}

function HideAndDestroyForthRow()
{
	bHideAndDestroyForthRow = true;
}

function HideAndDestroyBottomRow()
{
	bHideAndDestroyBottomRow = true;
}



/*
 *  This is where we set focus to the chat input and start typing our message
*/
function OnChat()
{
    bChatting=true;
    ChatInput.SetBool("focused", true);
}


/*
 * @param   MessageType     Determine the message type to send, 'Say', 'TeamSay' etc
*/
function ToggleChat(string MessageType)
{
    local CPSaveManager CPSaveManager;

    CPSaveManager = new () class'CPSaveManager';

    WidgetVisible = bool(CPSaveManager.GetItem("ShowChat"));
    // If ShowChat is false then return out of the function
    if(!WidgetVisible)
    {
        return;
    }

    ChatType = MessageType;
    if(!bChatting)
    {
        // If 'TeamSay' then set the (TEAM) label's visiblity to true
        if(ChatType == "TeamSay" || ChatType == "DeadTeamSay")
        {
            if(TeamLabel != none)
            {
                TeamLabel.SetString("text", "(TEAM)");
                TeamLabel.SetVisible(true);
            }
        }
        else if(ChatType == "DeadSay")
        {
            if(TeamLabel != none)
            {
                TeamLabel.SetString("text", "(DEAD)");
                TeamLabel.SetVisible(true);
            }
        }
		else if(ChatType == "Whisper" || ChatType == "DeadWhisper")
        {
            if(TeamLabel != none)
            {
                TeamLabel.SetString("text", "(WHISPER)");
                TeamLabel.SetVisible(true);
            }
        }
        else
        {
            if(TeamLabel != none)
            {
                TeamLabel.SetVisible(false);
            }
        }

        self.bCaptureInput = true;
        ChatInput.SetString("text", "");
        ChatInput.SetBool("visible", true);
        OnChat();
    }
}


/*
 *  Send the chat message
 *
 * @param   MessageType     Determine the message type to send, 'Say', 'TeamSay' etc
*/
function OnChatSend(string MessageType)
{
    local string Message;
    local int TeamIndex;

    // Grab the message entered in the ChatInput asset
    Message = ChatInput.GetString("text");

    `log("----------- Message Type : " @ MessageType );

    if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).Team != none)
    {
        TeamIndex = CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).Team.TeamIndex;
        `log("----------- Team Index : " @ TeamIndex );
    }

	if(Message != "")
    {
        // Send the message to the server
        controller.SendTextToServer(controller, Message, MessageType, TeamIndex);
    }

    // Reset the ChatInput message area
    self.bCaptureInput = false;
    bCaptureInput = false;
    ChatInput.SetString("text", "");
    ChatInput.SetBool("focused", false);
    ChatInput.SetBool("visible", false);
    bChatting = false;

    // Once Enter has been pressed then set the (TEAM) label's visiblity to false
    if(TeamLabel != none)
    {
        TeamLabel.SetVisible(false);
    }
}



/*
 *  Update the global chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateChatLog(string PlayersName, string BroadcastMessage, int TeamIndex)
{
    local LocalPlayer LocalPlayer;
    local int i;
    local ASColorTransform NameTransform, MessageTransform;
    
    // Set colour for admin
    if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bAdmin)
    {
        // Change colour
		NameTransform.multiply = Yellow;
		MessageTransform.multiply = Yellow;
    }	
    else
    {		
		if(TeamIndex == 0)
		{
    		// Change colour
			NameTransform.multiply = Red;
			MessageTransform.multiply = WhiteColor;
		}
		else
		{
			// Change colour
			NameTransform.multiply = Blue;
			MessageTransform.multiply = WhiteColor;
		}
	}
	

    ChatNames.AddItem(PlayersName);
    ChatMessages.AddItem(BroadcastMessage);
    ChatNameColors.AddItem(NameTransform);
    ChatMessageColors.AddItem(MessageTransform);
    	
    ChatData.Length = ChatMessages.Length;
	for (i = 0; i < ChatMessages.Length; i++)
	{
        // Set the chat array data
        ChatData[i].PlayerName = ChatNames[i];
        ChatData[i].Message = ChatMessages[i];
        ChatData[i].NameColor = ChatNameColors[i];
        ChatData[i].MessageColor = ChatMessageColors[i]; 
     }
     
     SetUpDataProvider();
      
	
	// Output to console
    LocalPlayer = LocalPlayer(GetPC().Player);
    if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
    {
        LocalPlayer.ViewportClient.ViewportConsole.OutputText("[CHAT] " @ PlayersName $ " : " $ BroadcastMessage);
    }
}


/*
 *  Update the DEAD global chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateDeadChatLog(string PlayersName, string BroadcastMessage, int TeamIndex)
{
    local LocalPlayer LocalPlayer;
    local int i;
    local ASColorTransform NameTransform, MessageTransform;
    
    // Dead global chat
    if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bOutOfLives)
    {    
    	
		// Set colour for admin
		if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bAdmin)
		{
			// Change colour
			NameTransform.multiply = Yellow;
			MessageTransform.multiply = Yellow;
		}	
		else
		{		
			if(TeamIndex == 0)
			{
    			// Change colour
				NameTransform.multiply = Red;
				MessageTransform.multiply = WhiteColor;
			}
			else
			{
				// Change colour
				NameTransform.multiply = Blue;
				MessageTransform.multiply = WhiteColor;
			}
		}
        
    	ChatNames.AddItem(PlayersName);
		ChatMessages.AddItem(BroadcastMessage);
		ChatNameColors.AddItem(NameTransform);
		ChatMessageColors.AddItem(MessageTransform);
    	
		ChatData.Length = ChatMessages.Length;
		for (i = 0; i < ChatMessages.Length; i++)
		{
			// Set the chat array data
			ChatData[i].PlayerName = ChatNames[i];
			ChatData[i].Message = ChatMessages[i];
			ChatData[i].NameColor = ChatNameColors[i];
			ChatData[i].MessageColor = ChatMessageColors[i]; 
		 }
        
        SetUpDataProvider();


        // Output to console
        LocalPlayer = LocalPlayer(GetPC().Player);
        if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
        {
            LocalPlayer.ViewportClient.ViewportConsole.OutputText("[DEAD] " @ PlayersName $ " : " $ BroadcastMessage);
        }
    }
}


/*
 *  Update the spectator chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateSpectatorChatLog(string PlayersName, string BroadcastMessage)
{
    local LocalPlayer LocalPlayer;
    local int i;
    local ASColorTransform NameTransform, MessageTransform;
    
	if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bOnlySpectator)
    {    
    	NameTransform.multiply = Green;
		MessageTransform.multiply = Green;
	
		ChatNames.AddItem(PlayersName);
		ChatMessages.AddItem(BroadcastMessage);
		ChatNameColors.AddItem(NameTransform);
		ChatMessageColors.AddItem(MessageTransform);
    	
		ChatData.Length = ChatMessages.Length;
		for (i = 0; i < ChatMessages.Length; i++)
		{
			// Set the chat array data
			ChatData[i].PlayerName = ChatNames[i];
			ChatData[i].Message = ChatMessages[i];
			ChatData[i].NameColor = ChatNameColors[i];
			ChatData[i].MessageColor = ChatMessageColors[i]; 
		 }
		
		// Change colour and set widget
		SetUpDataProvider();


		 // Output to console
		 LocalPlayer = LocalPlayer(GetPC().Player);
		 if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
		 {
			 LocalPlayer.ViewportClient.ViewportConsole.OutputText("[SPEC] " @ PlayersName $ " : " $ BroadcastMessage);
		 }
     }
}


/*
 *  Update the SWAT chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateSWATChatLog(string PlayersName, string BroadcastMessage, int TeamIndex)
{
    local LocalPlayer LocalPlayer;
    local int i;
    local ASColorTransform NameTransform, MessageTransform;
    
	if(TeamIndex == CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).Team.TeamIndex)
	{
		NameTransform.multiply = LightBlue;
		MessageTransform.multiply = LightBlue;
	
		ChatNames.AddItem(PlayersName);
		ChatMessages.AddItem(BroadcastMessage);
		ChatNameColors.AddItem(NameTransform);
		ChatMessageColors.AddItem(MessageTransform);
    	
		ChatData.Length = ChatMessages.Length;
		for (i = 0; i < ChatMessages.Length; i++)
		{
			// Set the chat array data
			ChatData[i].PlayerName = ChatNames[i];
			ChatData[i].Message = ChatMessages[i];
			ChatData[i].NameColor = ChatNameColors[i];
			ChatData[i].MessageColor = ChatMessageColors[i]; 
		 }
		
		// Change colour and set widget
		SetUpDataProvider();

		 // Output to console
		 LocalPlayer = LocalPlayer(GetPC().Player);
		 if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
		 {
			 LocalPlayer.ViewportClient.ViewportConsole.OutputText("[SWAT] " @ PlayersName $ " : " $ BroadcastMessage);
		 }
   }
}


/*
 *  Update the MERC chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateMERCChatLog(string PlayersName, string BroadcastMessage, int TeamIndex)
{
    local LocalPlayer LocalPlayer;
    local int i;
    local ASColorTransform NameTransform, MessageTransform;
    
	if(TeamIndex == CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).Team.TeamIndex)
	{
		NameTransform.multiply = LightBlue;
		MessageTransform.multiply = LightBlue;
	
		ChatNames.AddItem(PlayersName);
		ChatMessages.AddItem(BroadcastMessage);
		ChatNameColors.AddItem(NameTransform);
		ChatMessageColors.AddItem(MessageTransform);
		
		`log("----- Name colour :  " $ LightBlue.R $ " " $ LightBlue.G $ " " $ LightBlue.B $ " " $ LightBlue.A);
    	
		ChatData.Length = ChatMessages.Length;
		for (i = 0; i < ChatMessages.Length; i++)
		{
			// Set the chat array data
			ChatData[i].PlayerName = ChatNames[i];
			ChatData[i].Message = ChatMessages[i];
			ChatData[i].NameColor = ChatNameColors[i];
			ChatData[i].MessageColor = ChatMessageColors[i]; 
		 }
		
		// Change colour and set widget
		SetUpDataProvider();

		 // Output to console
		 LocalPlayer = LocalPlayer(GetPC().Player);
		 if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
		 {
			 LocalPlayer.ViewportClient.ViewportConsole.OutputText("[MERC] " @ PlayersName $ " : " $ BroadcastMessage);
		 }
   }
}


/*
 *  Update the DEAD SWAT chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateDEADSWATChatLog(string PlayersName, string BroadcastMessage, int TeamIndex)
{
    local LocalPlayer LocalPlayer;
    local int i;
    local ASColorTransform NameTransform, MessageTransform;
    
	if(TeamIndex == CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).Team.TeamIndex)
	{
		NameTransform.multiply = LightBlue;
		MessageTransform.multiply = LightBlue;
		
		if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bOutOfLives)
		{ 
			 
			ChatNames.AddItem(PlayersName);
			ChatMessages.AddItem(BroadcastMessage);
			ChatNameColors.AddItem(NameTransform);
			ChatMessageColors.AddItem(MessageTransform);
    	
			ChatData.Length = ChatMessages.Length;
			for (i = 0; i < ChatMessages.Length; i++)
			{
				// Set the chat array data
				ChatData[i].PlayerName = ChatNames[i];
				ChatData[i].Message = ChatMessages[i];
				ChatData[i].NameColor = ChatNameColors[i];
				ChatData[i].MessageColor = ChatMessageColors[i]; 
			 }
			
			// Change colour and set widget
			SetUpDataProvider();

			 // Output to console
			 LocalPlayer = LocalPlayer(GetPC().Player);
			 if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
			 {
				 LocalPlayer.ViewportClient.ViewportConsole.OutputText("[SWAT][DEAD] " @ PlayersName $ " : " $ BroadcastMessage);
			 }
		 }
     }
}


/*
 *  Update the DEAD MERC chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateDEADMERCChatLog(string PlayersName, string BroadcastMessage, int TeamIndex)
{
    local LocalPlayer LocalPlayer;
    local int i;
    local ASColorTransform NameTransform, MessageTransform;
    
	if(TeamIndex == CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).Team.TeamIndex)
	{
		NameTransform.multiply = LightBlue;
		MessageTransform.multiply = LightBlue;
	
		if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bOutOfLives)
		{ 
			ChatNames.AddItem(PlayersName);
			ChatMessages.AddItem(BroadcastMessage);
			ChatNameColors.AddItem(NameTransform);
			ChatMessageColors.AddItem(MessageTransform);
    	
			ChatData.Length = ChatMessages.Length;
			for (i = 0; i < ChatMessages.Length; i++)
			{
				// Set the chat array data
				ChatData[i].PlayerName = ChatNames[i];
				ChatData[i].Message = ChatMessages[i];
				ChatData[i].NameColor = ChatNameColors[i];
				ChatData[i].MessageColor = ChatMessageColors[i]; 
			}
			
			// Change colour and set widget
			SetUpDataProvider();

			// Output to console
			LocalPlayer = LocalPlayer(GetPC().Player);
			if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
			{
				LocalPlayer.ViewportClient.ViewportConsole.OutputText("[MERC][DEAD] " @ PlayersName $ " : " $ BroadcastMessage);
			}
		 }
     } 
}



/*
 *  Update the WHISPER chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateWhisperChatLog(string PlayersName, string BroadcastMessage)
{
	local ASColorTransform NameTransform, MessageTransform;
    local LocalPlayer LocalPlayer;
    local string Msg, PlayerName;
    local bool IdOutOfLives;
    local int i;
    
	// Msg is now the message body
	Msg = Split(BroadcastMessage,' ',true); 
	
	if(LEN(BroadcastMessage) > 0)
	{
		// BroadcastMessage is now the Name of the player being whispered 
		BroadcastMessage = Repl(BroadcastMessage, Msg, "", true); 

		if(CPPlayerController(GetPC()) != none)
		{
			IdOutOfLives = CPPlayerController(GetPC()).GetPlayerLifeStatusFromPRI(int(BroadcastMessage));
			if(!CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bOutOfLives && !IdOutOfLives)
			{
				PlayerName = CPPlayerController(GetPC()).PlayerName $ " ";
				if(PlayerName == BroadcastMessage)
				{ 
					NameTransform.multiply = WhiteColor;
					MessageTransform.multiply = WhiteColor;
	
					ChatNames.AddItem(PlayersName);
					ChatMessages.AddItem(Msg);
					ChatNameColors.AddItem(NameTransform);
					ChatMessageColors.AddItem(MessageTransform);
    	
					ChatData.Length = ChatMessages.Length;
					for (i = 0; i < ChatMessages.Length; i++)
					{
						// Set the chat array data
						ChatData[i].PlayerName = ChatNames[i];
						ChatData[i].Message = ChatMessages[i];
						ChatData[i].NameColor = ChatNameColors[i];
						ChatData[i].MessageColor = ChatMessageColors[i]; 
					}
			
					// Change colour and set widget
					SetUpDataProvider();

					// Output to console
					LocalPlayer = LocalPlayer(GetPC().Player);
					if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
					{
						LocalPlayer.ViewportClient.ViewportConsole.OutputText("[WHISPER] " @ PlayersName $ " : " $ Msg);
					}
				 }
			 }
		 }
	 }
}



/*
 *  Update the DEAD WHISPER chat log
 *
 * @param	PlayersName			The players name
 * @param   BroadcastMessage    The actual message to broadcast
*/
unreliable client function UpdateDEADWhisperChatLog(string PlayersName, string BroadcastMessage)
{
	local ASColorTransform NameTransform, MessageTransform;
    local LocalPlayer LocalPlayer;
    local string Msg, PlayerName;
    local bool IdOutOfLives;
    local int i;
    
    if(CPPlayerController(GetPC()) != none)
	{		
		// Msg is now the message body
		Msg = Split(BroadcastMessage,' ',true); 
	
		if(LEN(BroadcastMessage) > 0)
		{
			// BroadcastMessage is now the Name of the player being whispered 
			BroadcastMessage = Repl(BroadcastMessage, Msg, "", true); 
    
			// Check to see if the target player is out of lives
			IdOutOfLives = CPPlayerController(GetPC()).GetPlayerLifeStatusFromPRI(int(BroadcastMessage));
			if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bOutOfLives && !IdOutOfLives)
			{
				CPPlayerController(GetPC()).CantWhisperAlivePlayersWhenDead();
			}
			else if(CPPlayerReplicationInfo(CPPlayerController(GetPC()).PlayerReplicationInfo).bOutOfLives && IdOutOfLives)
			{ 
				PlayerName = CPPlayerController(GetPC()).PlayerName $ " ";
				if(PlayerName == BroadcastMessage)
				{ 
					NameTransform.multiply = WhiteColor;
					MessageTransform.multiply = WhiteColor;
	
					ChatNames.AddItem(PlayersName);
					ChatMessages.AddItem(Msg);
					ChatNameColors.AddItem(NameTransform);
					ChatMessageColors.AddItem(MessageTransform);
    	
					ChatData.Length = ChatMessages.Length;
					for (i = 0; i < ChatMessages.Length; i++)
					{
						// Set the chat array data
						ChatData[i].PlayerName = ChatNames[i];
						ChatData[i].Message = ChatMessages[i];
						ChatData[i].NameColor = ChatNameColors[i];
						ChatData[i].MessageColor = ChatMessageColors[i]; 
					}
			
					// Change colour and set widget
					SetUpDataProvider();

					// Output to console
					LocalPlayer = LocalPlayer(GetPC().Player);
					if (LocalPlayer != None && LocalPlayer.ViewportClient != None)
					{
						LocalPlayer.ViewportClient.ViewportConsole.OutputText("[WHISPER] " @ PlayersName $ " : " $ Msg);
					}
				 }
			 }
		}
	}
}


/*
 *  Set the chat to invisible when ShowChat is false in the settings menu
*/
function ChatLogInvisible()
{
    NameOne.SetVisible(false);
	NameTwo.SetVisible(false);
	NameThree.SetVisible(false);
	NameFour.SetVisible(false);
	NameFive.SetVisible(false);
	
	MessageOne.SetVisible(false);
	MessageTwo.SetVisible(false);
	MessageThree.SetVisible(false);
	MessageFour.SetVisible(false);
	MessageFive.SetVisible(false);
	
	ChatInput.SetVisible(false);
}


/*
 *  Set the chat to visible when ShowChat is true in the settings menu
*/
function ChatLogVisible()
{
    NameOne.SetVisible(true);
	NameTwo.SetVisible(true);
	NameThree.SetVisible(true);
	NameFour.SetVisible(true);
	NameFive.SetVisible(true);
	
	MessageOne.SetVisible(true);
	MessageTwo.SetVisible(true);
	MessageThree.SetVisible(true);
	MessageFour.SetVisible(true);
	MessageFive.SetVisible(true);
	
	ChatInput.SetVisible(true);
}


DefaultProperties
{
	bHideAndDestroyTopRow = false
	bHideAndDestroySecondRow = false
	bHideAndDestroyThirdRow = false
	bHideAndDestroyForthRow = false
	bHideAndDestroyBottomRow = false
	
    bDisplayWithHudOff=false
    MovieInfo=SwfMovie'TA_HUD.TAHUD'
    //bEnableGammaCorrection=false
    bDrawWeaponCrosshairs=true

    //bAllowInput=false
    //bAllowFocus=false

    bCaptureInput=false;
//  LIGHTGREEN=(add=(R=128,G=236,B=12,A=0))
//  DARKGREEN=(add=(R=57,G=106,B=4,A=0))
//  YELLOW=(add=(R=255,G=255,B=0,A=0))
//  LIGHTRED=(add=(R=236,G=102,B=102,A=0))
    WHITE=(add=(R=255,G=255,B=255,A=0))
    
    // Chat colours
    WhiteColor=(R=1.f, G=1.f, B=1.f, A=1.f)
	Blue=(R=0.f, G=0.f, B=1.f, A=1.f)
	Green=(R=0.f, G=1.f, B=0.f, A=1.f)
	Yellow=(R=1.f, G=1.f, B=0.f, A=1.f)
	LightBlue=(R=0.f, G=1.f, B=1.f, A=1.f)
	Red=(R=1.f, G=0.0f, B=0.f, A=1.f)

    WidgetBindings.Add((WidgetName="chatInput",WidgetClass=class'GFxClikWidget'))
    WidgetBindings.Add((WidgetName="TeamLabel",WidgetClass=class'GFxClikWidget'))
	
	// Top row of chat
	WidgetBindings.Add((WidgetName="name1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="message1",WidgetClass=class'GFxClikWidget'))
	
	// Second row of chat
	WidgetBindings.Add((WidgetName="name2",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="message2",WidgetClass=class'GFxClikWidget'))
	
	// Third row of chat
	WidgetBindings.Add((WidgetName="name3",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="message3",WidgetClass=class'GFxClikWidget'))
	
	// Forth row of chat
	WidgetBindings.Add((WidgetName="name4",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="message4",WidgetClass=class'GFxClikWidget'))
	
	// Bottom row of chat
	WidgetBindings.Add((WidgetName="name5",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="message5",WidgetClass=class'GFxClikWidget'))
}

