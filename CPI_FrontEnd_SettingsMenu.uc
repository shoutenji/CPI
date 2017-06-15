class CPI_FrontEnd_SettingsMenu extends CPIFrontEnd_Screen
    config(UI)
	DLLBind(CPIGameINIOptions);

var globalconfig bool bForceNoResolutionAutoDetect; //used to stop the auto detection code - might be needed for mac support.
var globalconfig array<Vector2D> PredefinedResolutions; //used to pre-define resolutions.

// Core Panel Objects
var GFxObject HUDMenu, AudioSettings, VideoSettings, GameSettings, CPIsettings, InputSettings, SettingsTooltip, SettingsTitle, Subtitle;

// Core Panel Dragbars
var GFxObject AdvancedDragBar;

// Core Panel Widgets
var GFxClikWidget SettingsListPanel, SettingsBackBtn, SettingsDefaultBtn, SettingsAcceptBtn;

// Video
var GFxClikWidget resolutionDDPH, LevelOfDetailDDPH, FullScreenCB, GammaSlider, SDecalsCB, SkipIntroMovies;

// Audio
var GFxClikWidget MusicVolumeSlider, AnnouncerVolumeSlider ,MasterVolumeSlider ,EffectsVolumeSlider, MaxChannelsDDPH;

// HUD
var GFxClikWidget ShowHudCB, ShowTimeCB, ShowChatCB, ShowHitIndicatorDDPH, ShowArmorCB, ShowWeaponsInfoTxt, ShowHitLocTxt, ShowObjectiveInfoCB, ShowDeathMessageCB, HudScaleSlider;

// Game
var GFxClikWidget ViewBobSlider, WeaponHandDDPH,PlayerNametxtbox,ClanName,AutomaticReloadingCB,AutoswitchonWeaponPickupCB,UseLastweaponafterGrenadeCB,RememberLaserstateCB,AutoshowTeamInfoRadarCB,ShowFPSCB,ColourbindOptionCB, PlayAsSpectatorCB;

// Mouse and Input
var GfxClikWidget VSyncCB, EnableMouseSmoothingCB, MouseSensitivitySlider, ShowCrosshairsCB, CrosshairScaleSlider;

// Crosshairs
var GfxClikWidget CrosshairScaletxt, CrosshairstyleSlider, RedSlider, GreenSlider, BlueSlider, AlphaSlider, CrosshairButton;
var GfxClikWidget Cross_1, Cross_2, Cross_3, Cross_4, Cross_5, Cross_6, Cross_7, Cross_8, Cross_9, Cross_10, Cross_11, Cross_12, Cross_13, Cross_14, Cross_15, Cross_16;
var GfxClikWidget Cross_17, Cross_18, Cross_19, Cross_20, Cross_21, Cross_22, Cross_23, Cross_24, Cross_25, Cross_26, Cross_27, Cross_28, Cross_29, Cross_30, Cross_31, Cross_32;

// Advanced
var GFxClikWidget BloomCB, MotionBlurCB, DShadowsCB, DLightsCB, AmbientOcclusionCB, ParticlesDetailDDPH, AntiAliasingDDPH, GoreLeveDDPH, MaxAnisotropyDD;

// Textboxes
var GFxObject ParticlesDetailtxt, AmbientOcclusiontxt, AntiAliasingtxt,GoreLeveltxt,MouseSensitivitytxt,Redtxt,Greentxt,Alphatxt,Blue,CrosshairColourtxt, Crosshairstyletxt,ViewBobtxt,WeaponHandtxt,PlayerNametxt,HCStxt,SHLTxt,SWILTxt,MusicVolumetxt,EffectsVolumetxt,AnnouncerVolumetxt,PlayVoiceMessagestxt,MaxChannelstxt,MasterVolumetxt,Resolutiontxt,GammaTxt,LevelOfDetailTxt;

// Localisation of text for textboxes
// ToolTip GFx array
var array<GFxClikWidget> GFxToolTip;
// English
var localized array<string> EngToolTipText; // not setup yet
// French
var localized array<string> FrToolTipText; // not setup yet
// German
var localized array<string> GerToolTipText; // not setup yet
// Spanish
var localized array<string> SpaToolTipText; // not setup yet

// Crosshairs array
var array<GFxClikWidget> CrosshairStyles;
// Previous crosshair
var GFxClikWidget PreviousCrosshair;

// Graphics bools
var bool bVSync;
var bool bFullscreen;
var bool bBloom;
var bool bMotionBlur;
var bool bDynamicLights;
var bool bDynamicShadows;
var bool bAmbientOcclusion;
var bool bDecals;
var bool bJustOpened; // on first open of Settings

// Input
var bool bMouseSmoothing;
var bool bShowCrosshair;
var float MouseSensitivity;
var float CrosshairScale;

// Graphics values
var float Gamma;
var int AntiAlias;
var int Anistropy;
var int Gore;
var int LevelOfDetail;
var int Particle;
var int MaxChannel;
var int HitIndicator;

// Audio floats
var float MasterVolume;
var float AnnouncerVolume;
var float MusicVolume;
var float SFXVolume;

// Graphics & Audio arrays
var array<int> Anistropys;
var array<int> AntiAliases;
var array<int> GammaValues;
var array<int> Particles;
var array<int> MaxChannels;
var array<int> HitIndicators;

// HUD
var bool bShowHud;
var bool bShowTime;
var bool bShowChat;
var bool bShowArmor;
var bool bShowWeaponInfo;
var bool bShowHitLocation;
var bool bShowObjectiveInfo;
var bool bShowDeathMessage; // Death Message not hooked up yet
var bool bAutoReload;
var bool bAutoWeaponSwitch;
var bool bPlayAsSpectator;
var bool bShowFPS;
var bool bShowPlayerInfoRadar;
var float HudScale;


// Game
var string PlayerName;
var string DefaultToolTip;



/* Anti-Aliasing */
struct AntiAliasOption
{
	var string OptionName;
};
var array<AntiAliasOption> ListAntiAlias;

/* Anistropy */
struct AnistropyOption
{
	var string OptionName;
};
var array<AnistropyOption> ListAnistropy;


/* Particles Detail */
struct ParticlesOption
{
	var string OptionName;
};
var array<ParticlesOption> ListParticleDetail;

/* Gore Detail */
struct GoreOption
{
	var string OptionName;
};
var array<GoreOption> ListGoreDetail;


/* Level of Detail */
struct DetailOption
{
	var string OptionName;
};
var array<DetailOption> ListLevelOfDetail;


/* Max Channels */
struct ChannelsOption
{
	var string OptionName;
};
var array<ChannelsOption> ListMaxChannels;

/* Hit Indicators */
struct HitOption
{
	var string OptionName;
};
var array<HitOption> ListHitIndicators;



/* SkippableMovies Array */
var array<string> SkippableMovies;

enum EWeaponHand
{
	HAND_Right,
	HAND_Left,
	HAND_Centered,
	HAND_Hidden,
};

dllimport final function string GetSettingValue(string configname, string section, string  key);
dllimport final function string SetSettingValue(string configname, string section, string key, string strvalue);

/*
 *	Save all settings here after pressing Accept Changes button in menu
*/
function SaveSettings()
{
	local CPSaveManager CPSaveManager;
	local CPPlayerController CPPlayerController;
	local WorldInfo WorldInfo;
	local string MapName;
	local AudioDevice aDevice;
	local Vector2D currentMode;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		// Set Clan Tag
		CPSaveManager.SetItem("ClanTag",ClanName.GetString("text"));
		CPPlayerController(GetPC()).ChangeClanTag(); //gets it from being saved earlier

		// Set name
		CPSaveManager.SetItem("PlayerName", PlayerNametxtbox.GetString("text"));
		ConsoleCommand("setname "@PlayerNametxtbox.GetString("text"));

		// Level of Detail
		if(LevelOfDetailDDPH != None)
		{
			LevelOfDetail = int(LevelOfDetailDDPH.GetFloat("selectedIndex"));
			ConsoleCommand("scale Bucket Bucket"$ LevelOfDetail);
			CPSaveManager.SetItem("LevelOfDetail", string(LevelOfDetail));
		}


		// Crosshair Scale
		if(CrosshairScaleSlider != none)
		{
			// Set the scale value
			CPPlayerController(GetPC()).PredefinedCrosshairScale = CrosshairScaleSlider.GetFloat("value");

			// Save the crosshair information
			CPPlayerController(GetPC()).SaveCrosshairSettings();
		}


		// Auto Weapon Switching
		if(AutoswitchonWeaponPickupCB != none)
		{
			bAutoWeaponSwitch = AutoswitchonWeaponPickupCB.GetBool("selected");
			AutoswitchonWeaponPickupCB.SetBool("selected", bAutoWeaponSwitch);
			CPSaveManager.SetItem("AutoSwitchOnPickup", string(bAutoWeaponSwitch));
		}

		// Auto Reload
		if(AutomaticReloadingCB != none)
		{
			bAutoReload = AutomaticReloadingCB.GetBool("selected");
			AutomaticReloadingCB.SetBool("selected", bAutoReload);
			CPSaveManager.SetItem("AutoReloadWeapon", string(bAutoReload));
		}

		// Show FPS
		if(ShowFPSCB != none)
		{
			bShowFPS = ShowFPSCB.GetBool("selected");
			ShowFPSCB.SetBool("selected", bShowFPS);
			CPSaveManager.SetItem("ShowFPS", string(bShowFPS));
		}

		// Play as Spectator
		if(PlayAsSpectatorCB != none)
		{
			bPlayAsSpectator = PlayAsSpectatorCB.GetBool("selected");
			PlayAsSpectatorCB.SetBool("selected", bPlayAsSpectator);

			WorldInfo = class'WorldInfo'.static.GetWorldInfo();
			if(WorldInfo != none)
			{
				CPPlayerController = CPPlayerController(GetPC());
				if (CPPlayerController != none)
				{
					if(CPPlayerController.PlayerReplicationInfo != none)
					{
						CPPlayerController.PlayerReplicationInfo.bOnlySpectator = bPlayAsSpectator;
						CPPlayerController.ServerSetBOnlySpectator(bPlayAsSpectator);
						CPPlayerController.PlayerReplicationInfo.bOutOfLives = bPlayAsSpectator;
						CPPlayerController.PlayerReplicationInfo.bWaitingPlayer = !bPlayAsSpectator;

						CPSaveManager.SetItem("Spectator", string(bPlayAsSpectator));

						MapName = WorldInfo.GetMapName(true);
						if(MapName != "CPFrontEndMap" || MapName != "CPIFrontEndMap")
						{
							if(CPPawn(CPPlayerController.Pawn) != none)
							{
								if(!bool(CPSaveManager.GetItem("Spectator")))
								{
									// If we're in a match, and bPlayAsSpectator is false then goto 'Player Waiting' state
									CPPlayerController.BecomeActive();
								}
								else
								{
									// In a single-player or private game
									if(WorldInfo.NetMode == NM_StandAlone)
									{
										CPPawn(CPPlayerController.Pawn).Suicide();
									}
									// In a multi-player or online game
									else
									{
										CPPlayerController.ServerSuicide();
									}

									CPPlayerController.ChangeTeam("Spectator");
								}
							}
						}
					}
				}
			}
		}

		// Show Chat
		if(ShowChatCB != none)
		{
			bShowChat = ShowChatCB.GetBool("selected");
			ShowChatCB.SetBool("selected", bShowChat);
			CPSaveManager.SetItem("ShowChat", string(bShowChat));

			CPPlayerController = CPPlayerController(GetPC());
			if(CPPlayerController != none)
			{
				//TOP-Proto fix for when not ingame - CPHUD is none in menus.
				if(CPPlayerController.CPHUD != none)
				{
					if(!bShowChat)
					{
						// Set the current chat's visibilty
						CPPlayerController.CPHUD.HudMovie.ChatLogInvisible();
					}
					else
					{
						// Set the current chat's visibilty
						CPPlayerController.CPHUD.HudMovie.ChatLogVisible();
					}
				}
			}
		}

		// Show Time
		if(ShowTimeCB != none)
		{
			bShowTime = ShowTimeCB.GetBool("selected");
			ShowTimeCB.SetBool("selected", bShowTime);
			CPSaveManager.SetItem("ShowTime", string(bShowTime));
		}

		// Show HUD
		if(ShowHudCB != none)
		{
			bShowHUD = ShowHudCB.GetBool("selected");
			ShowHudCB.SetBool("selected", bShowHUD);
			CPSaveManager.SetItem("ShowHUD", string(bShowHUD));
		}

		// Show Hit Indicator
		if(ShowHitIndicatorDDPH != none)
		{
			HitIndicator = ShowHitIndicatorDDPH.GetInt("selectedIndex");
			ShowHitIndicatorDDPH.SetFloat("selectedIndex", HitIndicator);
			CPSaveManager.SetItem("HitDirectional", string(HitIndicator));
		}


		// Show Armor
		if(ShowArmorCB != none)
		{
			bShowArmor = ShowArmorCB.GetBool("selected");
			ShowArmorCB.SetBool("selected", bShowArmor);
			CPSaveManager.SetItem("DrawPlayerInfo", string(bShowArmor));
		}

		// Show Weapon Icons
		if(ShowWeaponsInfoTxt != none)
		{
			bShowWeaponInfo = ShowWeaponsInfoTxt.GetBool("selected");
			ShowWeaponsInfoTxt.SetBool("selected", bShowWeaponInfo);
			CPSaveManager.SetItem("ShowWeaponIcon", string(bShowWeaponInfo));
		}

		// Show Hit Location
		if(ShowHitLocTxt != none)
		{
			bShowHitLocation = ShowHitLocTxt.GetBool("selected");
			ShowHitLocTxt.SetBool("selected", bShowHitLocation);
			CPSaveManager.SetItem("ShowHitLocation", string(bShowHitLocation));
		}

		// Show Objective Info
		if(ShowObjectiveInfoCB != none)
		{
			bShowObjectiveInfo = ShowObjectiveInfoCB.GetBool("selected");
			ShowObjectiveInfoCB.SetBool("selected", bShowObjectiveInfo);
			CPSaveManager.SetItem("ShowObjectiveInfo", string(bShowObjectiveInfo));
		}

		// Show Player Info Radar
		if(AutoshowTeamInfoRadarCB != none)
		{
			bShowPlayerInfoRadar = AutoshowTeamInfoRadarCB.GetBool("selected");
            CPSaveManager.SetItem("DrawPlayerInfo", string(bShowPlayerInfoRadar));
		}


		// HUD Scale
		if(HudScaleSlider != none)
		{
			HudScale = HudScaleSlider.GetInt("value");
			HudScaleSlider.SetFloat("value", HudScale);
			CPSaveManager.SetItem("HUDScale", string(HudScale));
		}

		// Gore Level
		if(GoreLeveDDPH != none)
		{
			Gore = GoreLeveDDPH.GetInt("selectedIndex");
			GoreLeveDDPH.SetFloat("selectedIndex", Gore);
			CPSaveManager.SetItem("GoreLevel", string(Gore));
		}

		// Show Crosshair
		if(ShowCrosshairsCB != None)
		{
			CPPlayerController = CPPlayerController(GetPC());
			if(CPPlayerController != None)
			{
				bShowCrosshair = ShowCrosshairsCB.GetBool("selected");
				CPSaveManager.SetItem("HideCrosshair", string(bShowCrosshair));

				if(bShowCrosshair)
					CPPlayerController.PredefinedCrosshairColor.A = 0.0;
				else
					CPPlayerController.PredefinedCrosshairColor.A = AlphaSlider.GetFloat("value");

				CPPlayerController.SaveConfig();
			}
		}

		// Apply the Mouse Sensitivity
		if(MouseSensitivitySlider != None)
		{
			MouseSensitivity = MouseSensitivitySlider.GetFloat("value");
			CPPlayerInput(GetPC().PlayerInput).MouseSensitivity = MouseSensitivity;
			CPSaveManager.SetItem("MouseSensitivity", string(MouseSensitivity));
		}

		// Apply anti alias
		if (AntiAliasingDDPH != None)
		{
			AntiAlias = AntiAliasingDDPH.GetInt("selectedIndex");
			ConsoleCommand("scale set MaxMultiSamples" @ AntiAliases[AntiAlias]);
			CPSaveManager.SetItem("AntiAlias", string(AntiAlias));
		}

		// Apply anistropy
		if (MaxAnisotropyDD != None)
		{
			Anistropy = MaxAnisotropyDD.GetInt("selectedIndex");
			ConsoleCommand("scale set MaxAnisotropy" @ Anistropys[Anistropy]);
			CPSaveManager.SetItem("Anistropy", string(Anistropy));
		}

		// Particles LOD Detail
		if(ParticlesDetailDDPH != none)
		{
			Particle = ParticlesDetailDDPH.GetInt("selectedIndex");
			ConsoleCommand("scale set ParticleLODBias" @ Particles[Particle]);
			CPSaveManager.SetItem("Particles", string(Particle));
		}

		// Apply Mouse Smoothing
		if(EnableMouseSmoothingCB != None)
		{
			bMouseSmoothing = EnableMouseSmoothingCB.GetBool("selected");
			CPPlayerInput(GetPC().PlayerInput).bEnableMouseSmoothing = bMouseSmoothing;
			CPSaveManager.SetItem("MouseSmoothing", string(bMouseSmoothing));
		}

		// Apply the Decals
		if(SDecalsCB != None)
		{
			bDecals = SDecalsCB.GetBool("selected");
			ConsoleCommand("scale set StaticDecals" @((bDecals) ? "true" : "false"));
			CPSaveManager.SetItem("bDecals", string(bDecals));
		}

		// Apply the Ambient Occlusion
		if(AmbientOcclusionCB != None)
		{
			bAmbientOcclusion = AmbientOcclusionCB.GetBool("selected");
			ConsoleCommand("scale set AmbientOcclusion" @((bAmbientOcclusion) ? "True" : "False"));
			CPSaveManager.SetItem("bAmbientOcclusion", string(bAmbientOcclusion));
		}

		// Apply the Dynamic Lights
		if(DLightsCB != None)
		{
			bDynamicLights = DLightsCB.GetBool("selected");
			ConsoleCommand("scale set DynamicLights" @((bDynamicLights) ? "true" : "false"));
			CPSaveManager.SetItem("bDynamicLights", string(bDynamicLights));
		}

		// Apply the Dynamic Shadows
		if(DShadowsCB != None)
		{
			bDynamicShadows = DShadowsCB.GetBool("selected");
			ConsoleCommand("scale set DynamicShadows" @((bDynamicShadows) ? "true" : "false"));
			CPSaveManager.SetItem("bDynamicShadows", string(bDynamicShadows));
		}

		// Apply the Motion Blur
		if(MotionBlurCB != None)
		{
			bMotionBlur = MotionBlurCB.GetBool("selected");
			ConsoleCommand("scale set MotionBlur" @((bMotionBlur) ? "true" : "false"));
			CPSaveManager.SetItem("bMotionBlur", string(bMotionBlur));
		}

		// Apply the Bloom
		if(BloomCB != None)
		{
			bBloom = BloomCB.GetBool("selected");
			ConsoleCommand("scale set Bloom" @((bBloom) ? "true" : "false"));
			CPSaveManager.SetItem("bBloom", string(bBloom));
		}

		// Apply the Fullscreen
		if (FullScreenCB != None)
		{
			bFullscreen = FullScreenCB.GetBool("selected");
			ConsoleCommand("scale set Fullscreen" @((bFullscreen) ? "true" : "false"));
			CPSaveManager.SetItem("Fullscreen", string(bFullscreen));
		}

		// Apply the VSync
		if (VSyncCB != None)
		{
			bVSync = VSyncCB.GetBool("selected");
			ConsoleCommand("scale set UseVsync" @((bVSync) ? "true" : "false"));
			CPSaveManager.SetItem("bVSync", string(bVSync));
		}

		// Apply the Gamma
		if(GammaSlider != None)
		{
			Gamma = GammaSlider.GetFloat("value");
			ConsoleCommand("Gamma " @GammaSlider.GetFloat("value"));
			CPSaveManager.SetItem("Gamma", string(Gamma));
		}

		if(MaxChannelsDDPH != none)
		{
			aDevice = class'Engine'.static.GetAudioDevice();
			if(aDevice != none)
			{
				MaxChannel = MaxChannelsDDPH.GetInt("selectedIndex");

				//aDevice.MaxChannels = MaxChannels[MaxChannel]; // MaxChannels variable needs to be changed from const in Engine.AudioDevice.uc
				CPSaveManager.SetItem("MaxChannel", string(MaxChannel));
			}
		}

		// Apply resolution change
		if(resolutionDDPH != none)
		{
			if(bFullscreen)
			{
				ConsoleCommand("SETRES " $ resolutionDDPH.GetString("label") $ "F");
			}
			else
			{
				ConsoleCommand("SETRES " $ resolutionDDPH.GetString("label") $ "W");
			}

			GetLP().ViewportClient.GetViewportSize(currentMode);
			//`Log("current resolution is " @ int(currentMode.X)$"x"$int(currentMode.Y),,'CPIMenus');

			ConsoleCommand("scale set ResX "$currentMode.X);
			ConsoleCommand("scale set ResY "$currentMode.Y);

			// DLLBind - Windows Only
			SetSettingValue("UDKSystemSettings.ini", "[SystemSettings]", "ResX", string(currentMode.X));
			SetSettingValue("UDKSystemSettings.ini", "[SystemSettings]", "ResY", string(currentMode.Y));
		}
	}

	// Save the config information
	SaveConfig();
	CPSaveManager.SaveConfig();
	CPPlayerInput(GetPC().PlayerInput).SaveConfig();

}

function OnEscapeKeyPress()
{
	MoveBackImpl();
}

function Select_SettingsBackBtn(GFxClikWidget.EventData ev)
{
	MoveBackImpl();
}


/*
 *	Set all settings to Default
*/
function Select_SettingsDefaultBtn(GFxClikWidget.EventData ev)
{
	local CPSaveManager CPSaveManager;
	local CPPlayerController CPPlayerController;
	local WorldInfo WorldInfo;
	local string MapName;
	local AudioDevice aDevice;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		// Set Clan Tag
		CPSaveManager.SetItem("ClanTag", class'CPSaveManager'.default.DefaultConfigItems[0].ItemValue);
		CPPlayerController(GetPC()).ChangeClanTag(); //gets it from being saved earlier

		// Set name
		CPSaveManager.SetItem("PlayerName", class'CPSaveManager'.default.DefaultConfigItems[41].ItemValue);
		ConsoleCommand("setname "@PlayerNametxtbox.GetString("text"));

		// Level of Detail
		if(LevelOfDetailDDPH != None)
		{
			LevelOfDetail = int(class'CPSaveManager'.default.DefaultConfigItems[40].ItemValue);

			ConsoleCommand("scale Bucket Bucket"$ LevelOfDetail);
			CPSaveManager.SetItem("LevelOfDetail", string(LevelOfDetail));
			LevelOfDetailDDPH.SetFloat("selectedIndex", LevelOfDetail);
		}


		// Crosshair Scale
		if(CrosshairScaleSlider != none)
		{
			// Set the scale value
			CPPlayerController(GetPC()).PredefinedCrosshairScale = CrosshairScaleSlider.GetFloat("value");

			// Save the crosshair information
			CPPlayerController(GetPC()).SaveCrosshairSettings();
		}


		// Auto Weapon Switching
		if(AutoswitchonWeaponPickupCB != none)
		{
			bAutoWeaponSwitch = bool(class'CPSaveManager'.default.DefaultConfigItems[12].ItemValue);

			AutoswitchonWeaponPickupCB.SetBool("selected", bAutoWeaponSwitch);
			CPSaveManager.SetItem("AutoSwitchOnPickup", string(bAutoWeaponSwitch));
		}

		// Auto Reload
		if(AutomaticReloadingCB != none)
		{
			bAutoReload = bool(class'CPSaveManager'.default.DefaultConfigItems[11].ItemValue);

			AutomaticReloadingCB.SetBool("selected", bAutoReload);
			CPSaveManager.SetItem("AutoReloadWeapon", string(bAutoReload));
		}

		// Show FPS
		if(ShowFPSCB != none)
		{
			bShowFPS = bool(class'CPSaveManager'.default.DefaultConfigItems[29].ItemValue);

			ShowFPSCB.SetBool("selected", bShowFPS);
			CPSaveManager.SetItem("ShowFPS", string(bShowFPS));
		}

		// Play as Spectator
		if(PlayAsSpectatorCB != none)
		{
			bPlayAsSpectator = bool(class'CPSaveManager'.default.DefaultConfigItems[28].ItemValue);

			PlayAsSpectatorCB.SetBool("selected", bPlayAsSpectator);

			WorldInfo = class'WorldInfo'.static.GetWorldInfo();
			if(WorldInfo != none)
			{
				CPPlayerController = CPPlayerController(GetPC());
				if (CPPlayerController != none)
				{
					if(CPPlayerController.PlayerReplicationInfo != none)
					{
						CPPlayerController.PlayerReplicationInfo.bOnlySpectator = bPlayAsSpectator;
						CPPlayerController.ServerSetBOnlySpectator(bPlayAsSpectator);
						CPPlayerController.PlayerReplicationInfo.bOutOfLives = bPlayAsSpectator;
						CPPlayerController.PlayerReplicationInfo.bWaitingPlayer = !bPlayAsSpectator;

						CPSaveManager.SetItem("Spectator", string(bPlayAsSpectator));

						MapName = WorldInfo.GetMapName(true);
						if(MapName != "CPFrontEndMap" || MapName != "CPIFrontEndMap")
						{
							if(CPPawn(CPPlayerController.Pawn) != none)
							{
								if(!bool(CPSaveManager.GetItem("Spectator")))
								{
									// If we're in a match, and bPlayAsSpectator is false then goto 'Player Waiting' state
									CPPlayerController.BecomeActive();
								}
								else
								{
									// In a single-player or private game
									if(WorldInfo.NetMode == NM_StandAlone)
									{
										CPPawn(CPPlayerController.Pawn).Suicide();
									}
									// In a multi-player or online game
									else
									{
										CPPlayerController.ServerSuicide();
									}

									CPPlayerController.ChangeTeam("Spectator");
								}
							}
						}
					}
				}
			}
		}

		// Show Chat
		if(ShowChatCB != none)
		{
			bShowChat = bool(class'CPSaveManager'.default.DefaultConfigItems[31].ItemValue);

			ShowChatCB.SetBool("selected", bShowChat);
			CPSaveManager.SetItem("ShowChat", string(bShowChat));

			CPPlayerController = CPPlayerController(GetPC());
			if(CPPlayerController != none)
			{
				//TOP-Proto fix for when not ingame - CPHUD is none in menus.
				if(CPPlayerController.CPHUD != none)
				{
					if(!bShowChat)
					{
						// Set the current chat's visibilty
						CPPlayerController.CPHUD.HudMovie.ChatLogInvisible();
					}
					else
					{
						// Set the current chat's visibilty
						CPPlayerController.CPHUD.HudMovie.ChatLogVisible();
					}
				}
			}
		}

		// Show Time
		if(ShowTimeCB != none)
		{
			bShowTime = bool(class'CPSaveManager'.default.DefaultConfigItems[30].ItemValue);

			ShowTimeCB.SetBool("selected", bShowTime);
			CPSaveManager.SetItem("ShowTime", string(bShowTime));
		}

		// Show HUD
		if(ShowHudCB != none)
		{
			bShowHUD = bool(class'CPSaveManager'.default.DefaultConfigItems[24].ItemValue);

			ShowHudCB.SetBool("selected", bShowHUD);
			CPSaveManager.SetItem("ShowHUD", string(bShowHUD));
		}

		// Show Hit Indicator
		if(ShowHitIndicatorDDPH != none)
		{
			HitIndicator = float(class'CPSaveManager'.default.DefaultConfigItems[27].ItemValue);

			ShowHitIndicatorDDPH.SetFloat("selectedIndex", HitIndicator);
			CPSaveManager.SetItem("HitDirectional", string(HitIndicator));
		}


		// Show Armor
		if(ShowArmorCB != none)
		{
			bShowArmor = bool(class'CPSaveManager'.default.DefaultConfigItems[14].ItemValue);

			ShowArmorCB.SetBool("selected", bShowArmor);
			CPSaveManager.SetItem("DrawPlayerInfo", string(bShowArmor));
		}

		// Show Weapon Icons
		if(ShowWeaponsInfoTxt != none)
		{
			bShowWeaponInfo = bool(class'CPSaveManager'.default.DefaultConfigItems[23].ItemValue);

			ShowWeaponsInfoTxt.SetBool("selected", bShowWeaponInfo);
			CPSaveManager.SetItem("ShowWeaponIcon", string(bShowWeaponInfo));
		}

		// Show Hit Location
		if(ShowHitLocTxt != none)
		{
			bShowHitLocation = bool(class'CPSaveManager'.default.DefaultConfigItems[22].ItemValue);

			ShowHitLocTxt.SetBool("selected", bShowHitLocation);
			CPSaveManager.SetItem("ShowHitLocation", string(bShowHitLocation));
		}

		// Show Objective Info
		if(ShowObjectiveInfoCB != none)
		{
			bShowObjectiveInfo = bool(class'CPSaveManager'.default.DefaultConfigItems[25].ItemValue);

			ShowObjectiveInfoCB.SetBool("selected", bShowObjectiveInfo);
			CPSaveManager.SetItem("ShowObjectiveInfo", string(bShowObjectiveInfo));
		}

        // Show Player Info Radar
		if(AutoshowTeamInfoRadarCB != none)
		{
			bShowPlayerInfoRadar = bool(class'CPSaveManager'.default.DefaultConfigItems[14].ItemValue);

            AutoshowTeamInfoRadarCB.SetBool("selected", bShowPlayerInfoRadar);
            CPSaveManager.SetItem("DrawPlayerInfo", string(bShowPlayerInfoRadar));
		}

		// HUD Scale
		if(HudScaleSlider != none)
		{
			HudScale = float(class'CPSaveManager'.default.DefaultConfigItems[17].ItemValue);

			HudScaleSlider.SetFloat("value", HudScale);
			CPSaveManager.SetItem("HUDScale", string(HudScale));
		}

		// Gore Level
		if(GoreLeveDDPH != none)
		{
			Gore = int(class'CPSaveManager'.default.DefaultConfigItems[26].ItemValue);
			GoreLeveDDPH.SetFloat("selectedIndex", Gore);
			CPSaveManager.SetItem("GoreLevel", string(Gore));
		}

		// Show Crosshair
		if(ShowCrosshairsCB != None)
		{
			CPPlayerController = CPPlayerController(GetPC());
			if(CPPlayerController != None)
			{
				bShowCrosshair = bool(class'CPSaveManager'.default.DefaultConfigItems[39].ItemValue);

				CPSaveManager.SetItem("HideCrosshair", string(bShowCrosshair));
				ShowCrosshairsCB.SetBool("selected", bShowCrosshair);

				if(bShowCrosshair)
					CPPlayerController.PredefinedCrosshairColor.A = 0.0;
				else
					CPPlayerController.PredefinedCrosshairColor.A = AlphaSlider.GetFloat("value");

				CPPlayerController.SaveConfig();
			}
		}

		// Apply the Mouse Sensitivity
		if(MouseSensitivitySlider != None)
		{
			MouseSensitivity = float(class'CPSaveManager'.default.DefaultConfigItems[2].ItemValue);

			CPPlayerInput(GetPC().PlayerInput).MouseSensitivity = MouseSensitivity;
			CPSaveManager.SetItem("MouseSensitivity", string(MouseSensitivity));
			MouseSensitivitySlider.SetFloat("value", MouseSensitivity);
		}

		// Apply anti alias
		if (AntiAliasingDDPH != None)
		{
			AntiAlias = int(class'CPSaveManager'.default.DefaultConfigItems[42].ItemValue);

			ConsoleCommand("scale set MaxMultiSamples" @ AntiAliases[AntiAlias]);
			CPSaveManager.SetItem("AntiAlias", string(AntiAlias));
			AntiAliasingDDPH.SetFloat("selectedIndex", AntiAliasToInt(class'CPSaveManager'.default.DefaultConfigItems[42].ItemValue));
		}

		// Apply anistropy
		if (MaxAnisotropyDD != None)
		{
			Anistropy = int(class'CPSaveManager'.default.DefaultConfigItems[43].ItemValue);

			ConsoleCommand("scale set MaxAnisotropy" @ Anistropys[Anistropy]);
			CPSaveManager.SetItem("Anistropy", string(Anistropy));
			MaxAnisotropyDD.SetFloat("selectedIndex", AnistropyToInt(class'CPSaveManager'.default.DefaultConfigItems[43].ItemValue));
		}

		// Particles LOD Detail
		if(ParticlesDetailDDPH != none)
		{
			Particle = int(class'CPSaveManager'.default.DefaultConfigItems[44].ItemValue);

			ConsoleCommand("scale set ParticleLODBias" @ Particles[Particle]);
			CPSaveManager.SetItem("Particles", string(Particle));
			ParticlesDetailDDPH.SetFloat("selectedIndex", ParticleLODToInt(class'CPSaveManager'.default.DefaultConfigItems[44].ItemValue));
		}

		// Apply Mouse Smoothing
		if(EnableMouseSmoothingCB != None)
		{
			bMouseSmoothing = bool(class'CPSaveManager'.default.DefaultConfigItems[1].ItemValue);

			CPPlayerInput(GetPC().PlayerInput).bEnableMouseSmoothing = bMouseSmoothing;
			CPSaveManager.SetItem("MouseSmoothing", string(bMouseSmoothing));
			EnableMouseSmoothingCB.SetBool("selected", bMouseSmoothing);
		}

		// Apply the Decals
		if(SDecalsCB != None)
		{
			bDecals = bool(class'CPSaveManager'.default.DefaultConfigItems[38].ItemValue);

			ConsoleCommand("scale set StaticDecals" @((bDecals) ? "true" : "false"));
			CPSaveManager.SetItem("bDecals", string(bDecals));
			SDecalsCB.SetBool("selected", bDecals);
		}

		// Apply the Ambient Occlusion
		if(AmbientOcclusionCB != None)
		{
			bAmbientOcclusion = bool(class'CPSaveManager'.default.DefaultConfigItems[37].ItemValue);

			ConsoleCommand("scale set AmbientOcclusion" @((bAmbientOcclusion) ? "True" : "False"));
			CPSaveManager.SetItem("bAmbientOcclusion", string(bAmbientOcclusion));
			AmbientOcclusionCB.SetBool("selected", bAmbientOcclusion);
		}

		// Apply the Dynamic Lights
		if(DLightsCB != None)
		{
			bDynamicLights = bool(class'CPSaveManager'.default.DefaultConfigItems[35].ItemValue);

			ConsoleCommand("scale set DynamicLights" @((bDynamicLights) ? "true" : "false"));
			CPSaveManager.SetItem("bDynamicLights", string(bDynamicLights));
			DLightsCB.SetBool("selected", bDynamicLights);
		}

		// Apply the Dynamic Shadows
		if(DShadowsCB != None)
		{
			bDynamicShadows = bool(class'CPSaveManager'.default.DefaultConfigItems[36].ItemValue);

			ConsoleCommand("scale set DynamicShadows" @((bDynamicShadows) ? "true" : "false"));
			CPSaveManager.SetItem("bDynamicShadows", string(bDynamicShadows));
			DShadowsCB.SetBool("selected", bDynamicShadows);
		}

		// Apply the Motion Blur
		if(MotionBlurCB != None)
		{
			bMotionBlur = bool(class'CPSaveManager'.default.DefaultConfigItems[34].ItemValue);

			ConsoleCommand("scale set MotionBlur" @((bMotionBlur) ? "true" : "false"));
			CPSaveManager.SetItem("bMotionBlur", string(bMotionBlur));
			MotionBlurCB.SetBool("selected", bMotionBlur);
		}

		// Apply the Bloom
		if(BloomCB != None)
		{
			bBloom = bool(class'CPSaveManager'.default.DefaultConfigItems[33].ItemValue);

			ConsoleCommand("scale set Bloom" @((bBloom) ? "true" : "false"));
			CPSaveManager.SetItem("bBloom", string(bBloom));
			BloomCB.SetBool("selected", bBloom);
		}

		// Apply the Fullscreen
		if (FullScreenCB != None)
		{
			bFullscreen = bool(class'CPSaveManager'.default.DefaultConfigItems[3].ItemValue);

			ConsoleCommand("scale set Fullscreen" @((bFullscreen) ? "true" : "false"));
			CPSaveManager.SetItem("Fullscreen", string(bFullscreen));
			FullScreenCB.SetBool("selected", bFullscreen);
		}

		// Apply the VSync
		if (VSyncCB != None)
		{
			bVSync = bool(class'CPSaveManager'.default.DefaultConfigItems[32].ItemValue);

			ConsoleCommand("scale set UseVsync" @((bVSync) ? "true" : "false"));
			CPSaveManager.SetItem("bVSync", string(bVSync));
			VSyncCB.SetBool("selected", bVSync);
		}

		// Apply the Gamma
		if(GammaSlider != None)
		{
			Gamma = float(class'CPSaveManager'.default.DefaultConfigItems[5].ItemValue);

			ConsoleCommand("Gamma " @GammaSlider.GetFloat("value"));
			CPSaveManager.SetItem("Gamma", string(Gamma));
			GammaSlider.SetFloat("value", Gamma);
		}

		if(MaxChannelsDDPH != none)
		{
			aDevice = class'Engine'.static.GetAudioDevice();
			if(aDevice != none)
			{
				MaxChannel = int(class'CPSaveManager'.default.DefaultConfigItems[45].ItemValue);

				//aDevice.MaxChannels = MaxChannels[MaxChannel]; // MaxChannels variable needs to be changed from const in Engine.AudioDevice.uc
				CPSaveManager.SetItem("MaxChannel", string(MaxChannel));
				MaxChannelsDDPH.SetFloat("selectedIndex", MaxChannelsToInt(class'CPSaveManager'.default.DefaultConfigItems[45].ItemValue));
			}
		}
	}

	// Save the config information
	SaveConfig();
	CPSaveManager.SaveConfig();
	CPPlayerInput(GetPC().PlayerInput).SaveConfig();
}


function Select_SettingsAcceptBtn(GFxClikWidget.EventData ev)
{
	SaveSettings();
	MoveBackImpl();
}

function Select_SettingsListPanel_ChangeSetting(GFxClikWidget.EventData ev)
{
	switch(int(ev.target.GetFloat("selectedIndex")))
	{
		case (0):
			VideoSettings.SetVisible(true);
			AudioSettings.SetVisible(false);
			HUDMenu.SetVisible(false);
			GameSettings.SetVisible(false);
			CPIsettings.SetVisible(false); AdvancedDragBar.SetVisible(false);
			InputSettings.SetVisible(false);

			if(Subtitle != None)
				Subtitle.SetString("text", "Video");
		break;
		case (1):
			AudioSettings.SetVisible(true);
			VideoSettings.SetVisible(false);
			HUDMenu.SetVisible(false);
			GameSettings.SetVisible(false);
			CPIsettings.SetVisible(false); AdvancedDragBar.SetVisible(false);
			InputSettings.SetVisible(false);

			if(Subtitle != None)
				Subtitle.SetString("text", "Audio");
		break;
		case (2):
			HUDMenu.SetVisible(false);
			AudioSettings.SetVisible(false);
			VideoSettings.SetVisible(false);
			GameSettings.SetVisible(true);
			CPIsettings.SetVisible(false); AdvancedDragBar.SetVisible(false);
			InputSettings.SetVisible(false);

			if(Subtitle != None)
				Subtitle.SetString("text", "HUD");
		break;
		case (3):
			GameSettings.SetVisible(false);
			HUDMenu.SetVisible(true);
			AudioSettings.SetVisible(false);
			VideoSettings.SetVisible(false);
			CPIsettings.SetVisible(false); AdvancedDragBar.SetVisible(true);
			InputSettings.SetVisible(false);

			if(Subtitle != None)
				Subtitle.SetString("text", "Game");
		break;
		case (4):
			InputSettings.SetVisible(true);
			HUDMenu.SetVisible(false);
			AudioSettings.SetVisible(false);
			VideoSettings.SetVisible(false);
			GameSettings.SetVisible(false);
			CPIsettings.SetVisible(false); AdvancedDragBar.SetVisible(false);

			if(Subtitle != None)
				Subtitle.SetString("text", "Mouse & Input");

			// Populate the crosshair array and slider
			Populate_CrosshairstyleSlider();
			// Update the colour and scale
			UpdateCrosshairColourAndScale();

		break;
		case (5):
			CPIsettings.SetVisible(true); AdvancedDragBar.SetVisible(false);
			HUDMenu.SetVisible(false);
			AudioSettings.SetVisible(false);
			VideoSettings.SetVisible(false);
			GameSettings.SetVisible(false);
			InputSettings.SetVisible(false);

			if(Subtitle != None)
				Subtitle.SetString("text", "Advanced");
		break;
	}
}


/*
 *	Populate the resolution drop down list
*/
function Populate_resolutionDDPH()
{
	local CPGameViewportClient tavp;
	local array<Vector2D> dispModes;
	local Vector2D currentMode;
	local int i, selectedIndex;
	local GFxObject DataProvider,TempObj;
	local bool blnCurrentModeInDropdown;

	blnCurrentModeInDropdown = false;
	DataProvider = CreateArray();
	tavp = CPGameViewportClient(GetLP().ViewportClient);

	GetLP().ViewportClient.GetViewportSize(currentMode);
	//`Log("current resolution is " @ int(currentMode.X)$"x"$int(currentMode.Y),,'CPIMenus');

	if (tavp!=none && !bForceNoResolutionAutoDetect)
		dispModes = tavp.GetDisplayModes();

	if (dispModes.Length == 0 || bForceNoResolutionAutoDetect)
	{
		dispModes.Add(PredefinedResolutions.Length);
		for (i = 0; i < PredefinedResolutions.Length; i++)
			dispModes[i] = PredefinedResolutions[i];
	}

	for (i = 0; i < dispModes.Length; i++)
	{
			TempObj = CreateObject("Object");
			TempObj.SetString("name","");
			TempObj.SetString("desc","");
			TempObj.SetString("label", (int(dispModes[i].X) $ "x" $ int(dispModes[i].Y)));
			DataProvider.SetElementObject(i, TempObj);

			if(currentMode.X == dispModes[i].X && currentMode.Y == dispModes[i].Y)
			{
				blnCurrentModeInDropdown = true;
				selectedIndex = i;
			}
	}

	if(!blnCurrentModeInDropdown)
	{
			TempObj = CreateObject("Object");
			TempObj.SetString("name","");
			TempObj.SetString("desc","");
			TempObj.SetString("label", (int(currentMode.X) $ "x" $ int(currentMode.Y)));
			DataProvider.SetElementObject(dispModes.Length, TempObj);
			selectedIndex = dispModes.Length;

	}
    resolutionDDPH.SetObject("dataProvider", DataProvider);
	resolutionDDPH.SetFloat("selectedIndex", selectedIndex);
}


/*
 * Populate Drop Down Lists Dynamically
*/
function SetUpDataProvider(GFxObject Widget)
{
	local byte i;
	local GFxObject DataProvider;
	local CPSaveManager CPSaveManager;

	DataProvider = CreateArray();
	CPSaveManager = new () class'CPSaveManager';

	switch(Widget)
	{
		// Level of Detail DropDown
		case(LevelOfDetailDDPH):

			for (i = 0; i < ListLevelOfDetail.Length; i++)
			{
				DataProvider.SetElementString(i, ListLevelOfDetail[i].OptionName);
			}

			// Set the height of the dropdown list
			Widget.SetFloat("rowCount", ListLevelOfDetail.Length);
			break;


		// Anistropy DropDown
		case(MaxAnisotropyDD):

			for (i = 0; i < ListAnistropy.Length; i++)
			{
				DataProvider.SetElementString(i, ListAnistropy[i].OptionName);
			}

			// Set the height of the dropdown list
			Widget.SetFloat("rowCount", ListAnistropy.Length);
			break;


			// Anti-Aliasing DropDown
		case(AntiAliasingDDPH):
			for (i = 0; i < ListAntiAlias.Length; i++)
			{
				DataProvider.SetElementString(i, ListAntiAlias[i].OptionName);
			}

			// Set the height of the dropdown list
			Widget.SetFloat("rowCount", ListAntiAlias.Length);
			break;


			// Particles Detail DropDown
		case(ParticlesDetailDDPH):
			for (i = 0; i < ListParticleDetail.Length; i++)
			{
				DataProvider.SetElementString(i, ListParticleDetail[i].OptionName);
			}

			// Set the height of the dropdown list
			Widget.SetFloat("rowCount", ListParticleDetail.Length);
			break;


			// Gore Level DropDown
		case(GoreLeveDDPH):
			for (i = 0; i < ListGoreDetail.Length; i++)
			{
				DataProvider.SetElementString(i, ListGoreDetail[i].OptionName);
			}

			// Set the height of the dropdown list
			Widget.SetFloat("rowCount", ListGoreDetail.Length);
			break;

		// Max Channels DropDown
		case(MaxChannelsDDPH):
			for (i = 0; i < ListMaxChannels.Length; i++)
			{
				DataProvider.SetElementString(i, ListMaxChannels[i].OptionName);
			}

			// Set the height of the dropdown list
			Widget.SetFloat("rowCount", ListMaxChannels.Length);
			break;

		// Max Channels DropDown
		case(ShowHitIndicatorDDPH):
			for (i = 0; i < ListHitIndicators.Length; i++)
			{
				DataProvider.SetElementString(i, ListHitIndicators[i].OptionName);
			}

			// Set the height of the dropdown list
			Widget.SetFloat("rowCount", ListHitIndicators.Length);
			break;


		default:
			break;
	}

	Widget.SetObject("dataProvider", DataProvider);



	// Set our selected indexes
	if(LevelOfDetailDDPH != None)
		LevelOfDetailDDPH.SetFloat("selectedIndex", int(CPSaveManager.GetItem("LevelOfDetail")));

	if(MaxAnisotropyDD != None)
		MaxAnisotropyDD.SetFloat("selectedIndex", int(CPSaveManager.GetItem("Anistropy")));

	if(AntiAliasingDDPH != None)
		AntiAliasingDDPH.SetFloat("selectedIndex", int(CPSaveManager.GetItem("AntiAlias")));

	if(ParticlesDetailDDPH != none)
		ParticlesDetailDDPH.SetFloat("selectedIndex", int(CPSaveManager.GetItem("Particles")));

	if(GoreLeveDDPH != none)
	{
		Gore = int(CPSaveManager.GetItem("GoreLevel"));
		GoreLeveDDPH.SetFloat("selectedIndex", Gore);
	}

	if(MaxChannelsDDPH != none)
	{
		MaxChannelsDDPH.SetFloat("selectedIndex", int(CPSaveManager.GetItem("MaxChannel")));
	}

	if(ShowHitIndicatorDDPH != none)
	{
		HitIndicator = int(CPSaveManager.GetItem("HitDirectional"));
		ShowHitIndicatorDDPH.SetFloat("selectedIndex", HitIndicator);
	}
}


/*
 * Converting particle value to integer
*/
function int ParticleLODToInt(string Setting)
{
	switch(Setting)
	{
		case "-1":
			return 0;
			break;
		case "0":
			return 1;
			break;
		case "1":
			return 2;
			break;
		case "2":
			return 3;
			break;
		case "3":
			return 4;
			break;
		case "4":
			return 5;
			break;

		default:
			break;
	}
	return 0;
}


/*
 * Converting Anistropy value to integer
*/
function int AnistropyToInt(string Setting)
{
	switch(Setting)
	{
		case "0":
			return 0;
			break;
		case "2":
			return 1;
			break;
		case "4":
			return 2;
			break;
		case "8":
			return 3;
			break;
		case "16":
			return 4;
			break;

		default:
			break;
	}
	return 0;
}


/*
 * Converting Anti Alias value to integer
*/
function int AntiAliasToInt(string Setting)
{
	switch(Setting)
	{
		case "0":
			return 0;
			break;
		case "2":
			return 1;
			break;
		case "4":
			return 2;
			break;
		case "8":
			return 3;
			break;

		default:
			break;
	}
	return 0;
}


/*
 * Converting Max Channels value to integer
*/
function int MaxChannelsToInt(string Setting)
{
	switch(Setting)
	{
	case "16":
		return 0;
		break;
	case "32":
		return 1;
		break;
	case "48":
		return 2;
		break;
	case "64":
		return 3;
		break;
	default:
		break;
	}
	return 0;
}



/*
 *	Change volume settings in real-time //
*/
function OnEffectsVolumeSliderChange(GFxClikWidget.EventData ev)
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		CPSaveManager.SetItem("EffectsVolume", string(EffectsVolumeSlider.GetFloat("value")));
		GetPC().SetAudioGroupVolume('SFX',EffectsVolumeSlider.GetFloat("value") / 10);
	}
}

function Populate_EffectsVolumeSlider()
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		EffectsVolumeSlider.SetFloat("value", float(CPSaveManager.GetItem("EffectsVolume")));
		GetPC().SetAudioGroupVolume('SFX',EffectsVolumeSlider.GetFloat("value") / 10);
	}
}

function OnMasterVolumeSliderChange(GFxClikWidget.EventData ev)
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		CPSaveManager.SetItem("MasterVolume", string(MasterVolumeSlider.GetFloat("value")));
		GetPC().SetAudioGroupVolume('Master',MasterVolumeSlider.GetFloat("value") / 10);
	}
}

function Populate_MasterVolumeSlider()
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		MasterVolumeSlider.SetFloat("value", float(CPSaveManager.GetItem("MasterVolume")));
		GetPC().SetAudioGroupVolume('Master',MasterVolumeSlider.GetFloat("value") / 10);
	}
}

function OnAnnouncerVolumeSliderChange(GFxClikWidget.EventData ev)
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		CPSaveManager.SetItem("VoiceVolume", string(AnnouncerVolumeSlider.GetFloat("value")));
		GetPC().SetAudioGroupVolume('Announcer',AnnouncerVolumeSlider.GetFloat("value") / 10);
	}
}

function Populate_AnnouncerVolumeSlider()
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		AnnouncerVolumeSlider.SetFloat("value", float(CPSaveManager.GetItem("VoiceVolume")));
		GetPC().SetAudioGroupVolume('Announcer',AnnouncerVolumeSlider.GetFloat("value") / 10);
	}
}

function OnMusicVolumeSliderChange(GFxClikWidget.EventData ev)
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{

		CPSaveManager.SetItem("MusicVolume", string(MusicVolumeSlider.GetFloat("value")));
		GetPC().SetAudioGroupVolume('Music',MusicVolumeSlider.GetFloat("value") / 10);
	}
}

function Populate_MusicVolumeSlider()
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		MusicVolumeSlider.SetFloat("value", float(CPSaveManager.GetItem("MusicVolume")));
		GetPC().SetAudioGroupVolume('Music',MusicVolumeSlider.GetFloat("value") / 10);
	}
}




function Populate_WeaponHandDDPH()
{
	local GFxObject DataProvider,TempObj;
	local CPSaveManager CPSaveManager;
	local CPPlayerController CPPlayerController;

	CPPlayerController = CPPlayerController(GetPC());
	if(CPPlayerController != none)
	{
		CPSaveManager = new () class'CPSaveManager';
		if(CPSaveManager != none)
		{
			DataProvider = CreateArray();

			TempObj = CreateObject("Object");
			TempObj.SetString("name","");
			TempObj.SetString("desc","");
			TempObj.SetString("label","Right");
			DataProvider.SetElementObject(0,TempObj);

			TempObj = CreateObject("Object");
			TempObj.SetString("name","");
			TempObj.SetString("desc","");
			TempObj.SetString("label","Left");
			DataProvider.SetElementObject(1,TempObj);

			TempObj = CreateObject("Object");
			TempObj.SetString("name","");
			TempObj.SetString("desc","");
			TempObj.SetString("label","Centered");
			DataProvider.SetElementObject(2,TempObj);

			TempObj = CreateObject("Object");
			TempObj.SetString("name","");
			TempObj.SetString("desc","");
			TempObj.SetString("label","Hidden");
			DataProvider.SetElementObject(3,TempObj);

			WeaponHandDDPH.SetObject("dataProvider",DataProvider);
			WeaponHandDDPH.SetFloat("selectedIndex", WeaponHandToInt(string(CPPlayerController.WeaponHandPreference)));

			CPSaveManager.SetItem("WeaponHand", WeaponHandNameToConfig(WeaponHandDDPH.GetString("label")));
		}
	}
}

function int WeaponHandToInt(string WeaponHandAsString)
{
	switch(WeaponHandAsString)
	{
		case "HAND_Right":
			return 0;
			break;
		case "HAND_Left":
			return 1;
			break;
		case "HAND_Centered":
			return 2;
			break;
		case "HAND_Hidden":
			return 3;
			break;
		default:
			break;
	}

	return 0;
}

function string WeaponHandNameToConfig(string WeaponHandAsString)
{
	switch(WeaponHandAsString)
	{
		case "Right":
			return "HAND_Right";
			break;
		case "Left":
			return "HAND_Left";
			break;
		case "Centered":
			return "HAND_Centered";
			break;
		case "Hidden":
			return "HAND_Hidden";
			break;
		default:
			break;
	}

	return "HAND_Right";
}

function OnWeaponHandDDPHChange(GFxClikWidget.EventData ev)
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		switch( WeaponHandNameToConfig(WeaponHandDDPH.GetString("label")) )
		{
			case "HAND_Right":
				CPPlayerController(GetPC()).SetHand(HAND_Right);
				break;
			case "HAND_Left":
				CPPlayerController(GetPC()).SetHand(HAND_Left);
				break;
			case "HAND_Centered":
				CPPlayerController(GetPC()).SetHand(HAND_Centered);
				break;
			case "HAND_Hidden":
				CPPlayerController(GetPC()).SetHand(HAND_Hidden);
				break;
		}

		CPSaveManager.SetItem("WeaponHand", WeaponHandNameToConfig(WeaponHandDDPH.GetString("label")));
		CPSaveManager.SaveConfig();
	}
}

function Populate_ClanName()
{
	local CPSaveManager CPSaveManager;

	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		ClanName.SetString("text", CPSaveManager.GetItem("ClanTag"));
	}
}



function Populate_AutoswitchonWeaponPickupCB()
{
	`Log("Populate_AutoswitchonWeaponPickupCB::TODO",,'CPIMenus');
}

function OnAutoswitchonWeaponPickupCBClick(GFxClikWidget.EventData ev)
{
	`Log("OnAutoswitchonWeaponPickupCBClick::TODO",,'CPIMenus');
}

function Populate_UseLastweaponafterGrenadeCB()
{
	`Log("Populate_UseLastweaponafterGrenadeCB::TODO",,'CPIMenus');
}

function OnUseLastweaponafterGrenadeCBClick(GFxClikWidget.EventData ev)
{
	`Log("OnUseLastweaponafterGrenadeCBClick::TODO",,'CPIMenus');
}

function Populate_RememberLaserstateCB()
{
	`Log("Populate_RememberLaserstateCB::TODO",,'CPIMenus');
}

function OnRememberLaserstateCBClick(GFxClikWidget.EventData ev)
{
	`Log("OnRememberLaserstateCBClick::TODO",,'CPIMenus');
}


function Populate_ColourbindOptionCB()
{
	`Log("Populate_ColourbindOptionCB::TODO",,'CPIMenus');
}

function OnColourbindOptionCBClick(GFxClikWidget.EventData ev)
{
	`Log("OnColourbindOptionCBClick::TODO",,'CPIMenus');
}



/*
 *	Populate the Crosshair array and set Crosshair visiblity
*/
function Populate_CrosshairstyleSlider()
{
	local int i, CrosshairIndex;

	// Ensure we have a playercontroller
	if(CPPlayerController(GetPC()) != none)
	{
		// Load the config information
		CPPlayerController(GetPC()).GetCrosshairSettingsFromConfig();

		// Find the crosshair index
		CrosshairIndex = CPPlayerController(GetPC()).PredefinedCrosshairIdx;
		if(CrosshairIndex > -1)
		{
			for(i = 0; i < CrosshairStyles.Length; i++)
			{
				// Our predefined crosshair index needs to equal our new GFxWidget array selection
				if(CrosshairIndex == i)
				{
					// Ensure our arrays match
					if(CrosshairStyles.Length == CPPlayerController(GetPC()).PredefinedCrosshairs.Length)
					{
						if(CrosshairstyleSlider != none)
						{
							CrosshairstyleSlider.SetFloat("value", CrosshairIndex);
						}

						CrosshairStyles[i].SetVisible(true);
						PreviousCrosshair = CrosshairStyles[i];

						// Update colour and scale
						UpdateCrosshairColourAndScale();
					}
				}
			}
		}
	}
}


/*
 *	Purge previous crosshair
*/
function PurgePreviousCrosshair()
{
	// Hide our previous crosshair if it existed
	if(PreviousCrosshair != none)
	{
		PreviousCrosshair.SetVisible(false);
	}
}


/*
 *	Crosshair slider
 *  Adjusts in real time
*/
function OnCrosshairstyleSliderChange(GFxClikWidget.EventData ev)
{
	CPPlayerController(GetPC()).PredefinedCrosshairIdx = CrosshairstyleSlider.GetFloat("value");
	CPPlayerController(GetPC()).SaveCrosshairSettings();

	// Purge previous crosshair
	PurgePreviousCrosshair();
	// Update crosshair image
	Populate_CrosshairstyleSlider();
}


/*
 *	Update crosshair colour and scale
*/
function UpdateCrosshairColourAndScale()
{
	local ASColorTransform CrosshairColorTransform;
	local ASDisplayInfo CrosshairDisplayInfo;
	local int i, CrosshairIndex;
	local Color C;

	// Ensure we have a playercontroller
	if(CPPlayerController(GetPC()) != none)
	{
		// Load the config information
		CPPlayerController(GetPC()).GetCrosshairSettingsFromConfig();

		// Find the crosshair index
		CrosshairIndex = CPPlayerController(GetPC()).PredefinedCrosshairIdx;
		if(CrosshairIndex > -1)
		{
			for(i = 0; i < CrosshairStyles.Length; i++)
			{
				// Our predefined crosshair index needs to equal our new GFxWidget array selection
				if(CrosshairIndex == i)
				{
					// Ensure our arrays match
					if(CrosshairStyles.Length == CPPlayerController(GetPC()).PredefinedCrosshairs.Length)
					{
						if(RedSlider != none)
							C.R = RedSlider.GetFloat("value");
						if(GreenSlider != none)
							C.G = GreenSlider.GetFloat("value");
						if(BlueSlider != none)
							C.B = BlueSlider.GetFloat("value");
						if(AlphaSlider != none)
							C.A = AlphaSlider.GetFloat("value");

						// Fetch the Color info of the GFx crosshair asset
						CrosshairColorTransform = CrosshairStyles[i].GetColorTransform();

						// Alter the color according to the sliders information
						CrosshairColorTransform.Multiply = ColorToLinearColor(C);

						// Set the Color information of the GFx asset
						CrosshairStyles[i].SetColorTransform(CrosshairColorTransform);

						// Fetch the Display info of the GFx crosshair asset
						CrosshairDisplayInfo = CrosshairStyles[i].GetDisplayInfo();

						// Alter the scale to represent the true scaling of the crosshair which is set in CPWeapon.uc
						CrosshairDisplayInfo.XScale = FClamp((CPPlayerController(GetPC()).PredefinedCrosshairScale * 100 / 5), 0, 100) * 2;
						CrosshairDisplayInfo.YScale = FClamp((CPPlayerController(GetPC()).PredefinedCrosshairScale * 100 / 5), 0, 100) * 2;
						CrosshairDisplayInfo.ZScale = FClamp((CPPlayerController(GetPC()).PredefinedCrosshairScale * 100 / 5), 0, 100) * 2;

						// Set the Display info the GFx crosshair asset
						CrosshairStyles[i].SetDisplayInfo(CrosshairDisplayInfo);

						// Do our crosshair bounds checks
						CPPlayerController(GetPC()).CheckCrosshairSettings();
					}
				}
			}
		}
	}
}


/*
 *	Real-time colour and scale slider
*/
function OnColorAndScaleSliderChange(GFxClikWidget.EventData ev)
{
	// Set the sliders values
	CPPlayerController(GetPC()).PredefinedCrosshairColor.R = RedSlider.GetFloat("value");
	CPPlayerController(GetPC()).PredefinedCrosshairColor.G = GreenSlider.GetFloat("value");
	CPPlayerController(GetPC()).PredefinedCrosshairColor.B = BlueSlider.GetFloat("value");
	CPPlayerController(GetPC()).PredefinedCrosshairColor.A = AlphaSlider.GetFloat("value");

	// Set the scale value
	CPPlayerController(GetPC()).PredefinedCrosshairScale = CrosshairScaleSlider.GetFloat("value");

	// Save the crosshair information
	CPPlayerController(GetPC()).SaveCrosshairSettings();

	UpdateCrosshairColourAndScale();
}


/*
 *	A customized Tick? pulled from CPIFrontEnd.uc
*/
function Tick()
{
	UpdateToolTips();

	// Set the mouse sensitivity display
	if(MouseSensitivitytxt != none)
	{
		MouseSensitivitytxt.SetText("Mouse Sensitivity: " $ int(MouseSensitivitySlider.GetFloat("value")));
	}
}



/*
 *	Update the tooltips for each setting in the menu
*/
function UpdateToolTips()
{
	// Ensure the tooltips widget exists
	if(SettingsTooltip != none)
	{
		if(ShowCrosshairsCB != none && ShowCrosshairsCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Hide the crosshair in-game");

		else if(BloomCB != none && BloomCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Bloom");

		else if(MotionBlurCB != none && MotionBlurCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Motion Blur");

		else if(DShadowsCB != none && DShadowsCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Dynamic Shadows");

		else if(GoreLeveDDPH != none && GoreLeveDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "How much blood do you want to see?");

		else if(DLightsCB != none && DLightsCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Dynamic Lighting");

		else if(AmbientOcclusionCB != none && AmbientOcclusionCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Ambient Occlusion");

		else if(ParticlesDetailDDPH != none && ParticlesDetailDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Set how detailed the particles are");

		else if(AntiAliasingDDPH != none && AntiAliasingDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Reduce hard edges on world objects");

		else if(MaxAnisotropyDD != none && MaxAnisotropyDD.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enhance image quality of in-game textures");

		else if(resolutionDDPH != none && resolutionDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Select the resolution suited for you");

		else if(LevelOfDetailDDPH != none && LevelOfDetailDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Set your overall level of detail");

		else if(FullScreenCB != none && FullScreenCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Fullscreen");

		else if(GammaSlider != none && GammaSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Set a higher/lower brightness level");

		else if(SDecalsCB != none && SDecalsCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Decals, these are gunshots on walls etc");

		else if(MusicVolumeSlider != none && MusicVolumeSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Set the music volume");

		else if(AnnouncerVolumeSlider != none && AnnouncerVolumeSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Set the announcer volume");

		else if(MasterVolumeSlider != none && MasterVolumeSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Set the master volume");

		else if(EffectsVolumeSlider != none && EffectsVolumeSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Set the effects volume");

		else if(MaxChannelsDDPH != none && MaxChannelsDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Select the audio quality");

		else if(SettingsBackBtn != none && SettingsBackBtn.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Go back to the Main Menu");

		else if(SettingsDefaultBtn != none && SettingsDefaultBtn.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Return all settings to default values");

		else if(SettingsAcceptBtn != none && SettingsAcceptBtn.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Accept the settings and return to Main Menu");

		//
		else if(CrosshairScaletxt != none && CrosshairScaletxt.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Adjust the scale for your crosshair");

		else if(CrosshairstyleSlider != none && CrosshairstyleSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Select a crosshair style");

		else if(VSyncCB != none && VSyncCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable VSync");

		else if(EnableMouseSmoothingCB != none && EnableMouseSmoothingCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Mouse Smoothing");

		else if(MouseSensitivitySlider != none && MouseSensitivitySlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Adjust the sensitivity of the aiming");

		else if(CrosshairScaleSlider != none && CrosshairScaleSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Adjust the scale for your crosshair");

		else if(ShowHudCB != none && ShowHudCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide the Heads Up Display");

		else if(ShowTimeCB != none && ShowTimeCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide the Time");

		else if(ShowChatCB != none && ShowChatCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide the Chat");

		else if(ShowHitIndicatorDDPH != none && ShowHitIndicatorDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide the Hit Indicators");

		else if(ShowArmorCB != none && ShowArmorCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide the Armor Guy");

		else if(ShowObjectiveInfoCB != none && ShowObjectiveInfoCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide the Objective Information");

		else if(ShowDeathMessageCB != none && ShowDeathMessageCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide the Death Messages");

		else if(HudScaleSlider != none && HudScaleSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Adjust the size of the Heads Up Display");

		else if(ViewBobSlider != none && ViewBobSlider.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Adjust amplitude camera bob when walking");

		else if(WeaponHandDDPH != none && WeaponHandDDPH.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Select position of weapon on screen");

		else if(AutomaticReloadingCB != none && AutomaticReloadingCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Automatic Reloading at the end of a magazine");

		else if(AutoswitchonWeaponPickupCB != none && AutoswitchonWeaponPickupCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Automatic Weapon Switching on Pickup");

		else if(ShowFPSCB != none && ShowFPSCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Frames Per Second (benchmark testing)");

		else if(ColourbindOptionCB != none && ColourbindOptionCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Colourblind Mode");

		else if(PlayAsSpectatorCB != none && PlayAsSpectatorCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enable/Disable Play as Spectator on server joining");

		else if(ClanName != none && ClanName.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enter your Clan name");

		else if(PlayerNametxtbox != none && PlayerNametxtbox.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Enter your Player name");

		else if(AutoshowTeamInfoRadarCB != none && AutoshowTeamInfoRadarCB.GetString("state") == "over")
				SettingsTooltip.SetString("text", "Show/Hide your team on radar");
		else
		{
			if(SettingsTooltip.GetString("text") != DefaultToolTip)
				SettingsTooltip.SetString("text", DefaultToolTip);
			else
				return;
		}
	}
}


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;
	local PlayerController PlayerController;
	local CPPlayerController CPPlayerController;
	local CPPlayerInput CPPlayerInput;
	local CPSaveManager CPSaveManager;

	bWasHandled=false;
	CPSaveManager = new () class'CPSaveManager';

	switch(WidgetName)
	{
		case ('SettingsBackBtn'):
			SettingsBackBtn=GFxClikWidget(Widget);
			if(SettingsBackBtn != none)
			{
				SettingsBackBtn.SetString("label","Back");
				SettingsBackBtn.AddEventListener('CLIK_press',Select_SettingsBackBtn);
			}
			bWasHandled=true;
		break;
		case ('SettingsDefaultBtn'):
			SettingsDefaultBtn=GFxClikWidget(Widget);
			if(SettingsDefaultBtn != none)
			{
				SettingsDefaultBtn.SetString("label","Default Settings");
				SettingsDefaultBtn.AddEventListener('CLIK_press',Select_SettingsDefaultBtn);
			}
			bWasHandled=true;
		break;
		case ('SettingsAcceptBtn'):
			SettingsAcceptBtn=GFxClikWidget(Widget);
			if(SettingsAcceptBtn != none)
			{
				SettingsAcceptBtn.SetString("label","Accept Changes");
				SettingsAcceptBtn.AddEventListener('CLIK_press',Select_SettingsAcceptBtn);
			}
			bWasHandled=true;
		break;
		case ('SettingsListPanel'):
			SettingsListPanel=GFxClikWidget(Widget);

			SettingsListPanel.SetInt("selectedIndex",0); //selects the first option in the list panel for us.
			if(SettingsListPanel != none)
			{
				SettingsListPanel.AddEventListener('CLIK_change', Select_SettingsListPanel_ChangeSetting);
			}
			bWasHandled=true;
		break;
		case ('AudioSettings'):
			AudioSettings=Widget;
			AudioSettings.SetVisible(false);
			bWasHandled=true;
		break;
		case ('HUDSettings'):
			HUDMenu=Widget;
			HUDMenu.SetVisible(false);
			bWasHandled=true;
		break;
		case ('GameSettings'):
			GameSettings=Widget;
			GameSettings.SetVisible(false);
			bWasHandled=true;
		break;
		case ('VideoSettings'):
			VideoSettings=Widget;
			bWasHandled=true;
		break;
		case ('CPIsettings'):
			CPIsettings=Widget;
			CPIsettings.SetVisible(false);
			bWasHandled=true;
		break;
		case ('InputSettings'):
			InputSettings=Widget;
			InputSettings.SetVisible(false);
			bWasHandled=true;
		break;
		case ('SettingsTitle'):
			SettingsTitle=Widget;
			SettingsTitle.SetString("text", "Settings");
			bWasHandled=true;
		break;
		case ('Subtitle'):
			Subtitle=Widget;
			if(Subtitle != none)
			{
				Subtitle.SetString("text", "Video");
			}
			bWasHandled=true;
		break;
		case ('SettingsTooltip'):
			SettingsTooltip=Widget;
			SettingsTooltip.SetString("text", DefaultToolTip);
			bWasHandled=true;
		break;



		// Video //
		case ('resolutionDDPH'):
			resolutionDDPH=GFxClikWidget(Widget);
			if(resolutionDDPH != none)
			{
				Populate_resolutionDDPH();
			}
			bWasHandled=true;
		break;
		case ('LevelOfDetailDDPH'):
			LevelOfDetailDDPH=GFxClikWidget(Widget);
			if(LevelOfDetailDDPH != None)
			{
				SetUpDataProvider(LevelOfDetailDDPH);
			}
			bWasHandled=true;
		break;
		case ('FullScreenCB'):
			FullScreenCB=GFxClikWidget(Widget);
			if (FullScreenCB != None)
			{
				bFullscreen = bool(CPSaveManager.GetItem("Fullscreen"));
				FullScreenCB.SetBool("selected", bFullscreen);
			}
			bWasHandled=true;
		break;
		case ('SDecalsCB'):
			SDecalsCB=GFxClikWidget(Widget);
			if (SDecalsCB != None)
			{
				bDecals = bool(CPSaveManager.GetItem("bDecals"));
				SDecalsCB.SetBool("selected", bDecals);
			}
			bWasHandled=true;
		break;
		case ('GammaSlider'):
			GammaSlider=GFxClikWidget(Widget);
			if(GammaSlider != none)
			{
				Gamma = float(CPSaveManager.GetItem("Gamma"));
				GammaSlider.SetFloat("value", Gamma);
				ConsoleCommand("Gamma " @ Gamma);
			}
			bWasHandled=true;
		break;
		case ('SkipIntroMovies'):
			SkipIntroMovies=GFxClikWidget(Widget);
			if(SkipIntroMovies != none)
			{
				SkipIntroMovies.SetVisible(false);
			}
			bWasHandled=true;
		break;




		// Audio //
		case ('MaxChannelsDDPH'):
			MaxChannelsDDPH=GFxClikWidget(Widget);
			if(MaxChannelsDDPH != none)
			{
				SetUpDataProvider(MaxChannelsDDPH);
			}
			bWasHandled=true;
		break;
		case ('MusicVolumeSlider'):
			MusicVolumeSlider=GFxClikWidget(Widget);
			Populate_MusicVolumeSlider();
			MusicVolumeSlider.AddEventListener('CLIK_change',OnMusicVolumeSliderChange);
			bWasHandled=true;
		break;
		case ('AnnouncerVolumeSlider'):
			AnnouncerVolumeSlider=GFxClikWidget(Widget);
			Populate_AnnouncerVolumeSlider();
			AnnouncerVolumeSlider.AddEventListener('CLIK_change',OnAnnouncerVolumeSliderChange);
			bWasHandled=true;
		break;
		case ('MasterVolumeSlider'):
			MasterVolumeSlider=GFxClikWidget(Widget);
			Populate_MasterVolumeSlider();
			MasterVolumeSlider.AddEventListener('CLIK_change',OnMasterVolumeSliderChange);
			bWasHandled=true;
		break;
		case ('EffectsVolumeSlider'):
			EffectsVolumeSlider=GFxClikWidget(Widget);
			Populate_EffectsVolumeSlider();
			EffectsVolumeSlider.AddEventListener('CLIK_change',OnEffectsVolumeSliderChange);
			bWasHandled=true;
		break;




		case ('AdvancedDragBar'):
			AdvancedDragBar=Widget;
			bWasHandled=true;
		break;
		case ('Thumb'):
			bWasHandled=true;
		break;



		case ('WeaponHandDDPH'):
			WeaponHandDDPH=GFxClikWidget(Widget);
			Populate_WeaponHandDDPH();
			WeaponHandDDPH.AddEventListener('CLIK_change',OnWeaponHandDDPHChange);
			bWasHandled=true;
		break;
		case ('PlayerNametxtbox'):
			PlayerNametxtbox=GFxClikWidget(Widget);
			if(PlayerNametxtbox != none)
			{
				CPPlayerController = CPPlayerController(GetPC());
				if (CPPlayerController != none)
				{
					PlayerName = CPSaveManager.GetItem("PlayerName");
					PlayerNametxtbox.SetString("text", PlayerName);
				}
			}
			bWasHandled=true;
		break;
		case ('ClanName'):
			ClanName=GFxClikWidget(Widget);
			Populate_ClanName();
			bWasHandled=true;
		break;
		case ('AutomaticReloadingCB'):
			AutomaticReloadingCB=GFxClikWidget(Widget);
			if(AutomaticReloadingCB != none)
			{
				bAutoReload = bool(CPSaveManager.GetItem("AutoReloadWeapon"));
				AutomaticReloadingCB.SetBool("selected", bAutoReload);
			}
			bWasHandled=true;
		break;
		case ('AutoswitchonWeaponPickupCB'):
			AutoswitchonWeaponPickupCB=GFxClikWidget(Widget);
			if(AutoswitchonWeaponPickupCB != none)
			{
				bAutoWeaponSwitch = bool(CPSaveManager.GetItem("AutoSwitchOnPickup"));
				AutoswitchonWeaponPickupCB.SetBool("selected", bAutoWeaponSwitch);
			}
			bWasHandled=true;
		break;
		case ('UseLastweaponafterGrenadeCB'):
			UseLastweaponafterGrenadeCB=GFxClikWidget(Widget);
			Populate_UseLastweaponafterGrenadeCB();
			UseLastweaponafterGrenadeCB.AddEventListener('CLIK_click',OnUseLastweaponafterGrenadeCBClick);
			bWasHandled=true;
		break;
		case ('RememberLaserstateCB'):
			RememberLaserstateCB=GFxClikWidget(Widget);
			Populate_RememberLaserstateCB();
			RememberLaserstateCB.AddEventListener('CLIK_click',OnRememberLaserstateCBClick);
			bWasHandled=true;
		break;

		// Draw Team info Radar/ Draw Player Info
		case ('AutoshowTeamInfoRadarCB'):
			AutoshowTeamInfoRadarCB=GFxClikWidget(Widget);
			if(AutoshowTeamInfoRadarCB != none)
			{
				bShowPlayerInfoRadar = bool(CPSaveManager.GetItem("DrawPlayerInfo"));
				AutoshowTeamInfoRadarCB.SetBool("selected", bShowPlayerInfoRadar);
			}
			bWasHandled=true;
		break;

		// Show FPS
		case ('ShowFPSCB'):
			ShowFPSCB=GFxClikWidget(Widget);
			if(ShowFPSCB != none)
			{
				bShowFPS = bool(CPSaveManager.GetItem("ShowFPS"));
				ShowFPSCB.SetBool("selected", bShowFPS);

				PlayerController = GetPC();
				if (PlayerController != none)
				{
					if(bShowFPS)
						ConsoleCommand("stat fps");
				}
			}
			bWasHandled=true;
		break;
		case ('ColourbindOptionCB'):
			ColourbindOptionCB=GFxClikWidget(Widget);
			Populate_ColourbindOptionCB();
			ColourbindOptionCB.AddEventListener('CLIK_click',OnColourbindOptionCBClick);
			bWasHandled=true;
		break;
		case ('PlayAsSpectatorCB'):
			PlayAsSpectatorCB=GFxClikWidget(Widget);
			if(PlayAsSpectatorCB != none)
			{
				bPlayAsSpectator = bool(CPSaveManager.GetItem("Spectator"));
				PlayAsSpectatorCB.SetBool("selected", bPlayAsSpectator);

				PlayerController = GetPC();
				if (PlayerController != none)
				{
					if(PlayerController.PlayerReplicationInfo != none)
					{
						PlayerController.PlayerReplicationInfo.bOnlySpectator = bPlayAsSpectator;
						PlayerController.PlayerReplicationInfo.bIsSpectator = bPlayAsSpectator;
						PlayerController.PlayerReplicationInfo.bOutOfLives = bPlayAsSpectator;
						PlayerController.PlayerReplicationInfo.bWaitingPlayer = !bPlayAsSpectator;
					}
				}
			}
			bWasHandled=true;
		break;


		case ('ParticlesDetailtxt'):
			ParticlesDetailtxt=Widget;
			bWasHandled=true;
		break;
		case ('AmbientOcclusiontxt'):
			AmbientOcclusiontxt=Widget;
			bWasHandled=true;
		break;
		case ('AntiAliasingtxt'):
			AntiAliasingtxt=Widget;
			bWasHandled=true;
		break;
		case ('GoreLeveltxt'):
			GoreLeveltxt=Widget;
			bWasHandled=true;
		break;
		case ('MouseSensitivitytxt'):
			MouseSensitivitytxt=Widget;
			if(MouseSensitivitytxt != none)
			{
				if(MouseSensitivitySlider != none)
				{
                	MouseSensitivitytxt.SetText("Mouse Sensitivity: " $ int(MouseSensitivitySlider.GetFloat("value")));
                }
			}
			bWasHandled=true;
		break;
		case ('Redtxt'):
			Redtxt=Widget;
			bWasHandled=true;
		break;
		case ('Greentxt'):
			Greentxt=Widget;
			bWasHandled=true;
		break;
		case ('Alphatxt'):
			Alphatxt=Widget;
			bWasHandled=true;
		break;
		case ('Blue'):
			Blue=Widget;
			bWasHandled=true;
		break;
		case ('CrosshairColourtxt'):
			CrosshairColourtxt=Widget;
			if(CrosshairColourtxt != none)
			{
				CrosshairColourtxt.SetString("text", "Crosshair Options");
			}
			bWasHandled=true;
		break;
		case ('CrosshairScaletxt'):
			CrosshairScaletxt=GFxClikWidget(Widget);
			if(CrosshairScaletxt != none)
			{
				CrosshairScaletxt.SetString("text", "Scale");
			}
			bWasHandled=true;
		break;
		case ('Crosshairstyletxt'):
			Crosshairstyletxt=Widget;
			bWasHandled=true;
		break;
		case ('ViewBobtxt'):
			ViewBobtxt=Widget;
			bWasHandled=true;
		break;
		case ('WeaponHandtxt'):
			WeaponHandtxt=Widget;
			bWasHandled=true;
		break;
		case ('PlayerNametxt'):
			PlayerNametxt=Widget;
			bWasHandled=true;
		break;
		case ('HCStxt'):
			HCStxt=Widget;
			bWasHandled=true;
		break;
		case ('SHLTxt'):
			SHLTxt=Widget;
			bWasHandled=true;
		break;
		case ('MusicVolumetxt'):
			MusicVolumetxt=Widget;
			bWasHandled=true;
		break;
		case ('EffectsVolumetxt'):
			EffectsVolumetxt=Widget;
			bWasHandled=true;
		break;
		case ('AnnouncerVolumetxt'):
			AnnouncerVolumetxt=Widget;
			bWasHandled=true;
		break;
		case ('PlayVoiceMessagestxt'):
			PlayVoiceMessagestxt=Widget;
			bWasHandled=true;
		break;
		case ('MaxChannelstxt'):
			MaxChannelstxt=Widget;
			bWasHandled=true;
		break;
		case ('MasterVolumetxt'):
			MasterVolumetxt=Widget;
			bWasHandled=true;
		break;
		case ('Resolutiontxt'):
			Resolutiontxt=Widget;
			bWasHandled=true;
		break;
		case ('GammaTxt'):
			GammaTxt=Widget;
			bWasHandled=true;
		break;
		case ('LevelOfDetailTxt'):
			LevelOfDetailTxt=Widget;
			bWasHandled=true;
		break;



		// Advanced //
		case ('BloomCB'):
			BloomCB=GFxClikWidget(Widget);
			if (BloomCB != None)
			{
				bBloom = bool(CPSaveManager.GetItem("bBloom"));
				BloomCB.SetBool("selected", bBloom);
			}
			bWasHandled=true;
		break;
		case ('MotionBlurCB'):
			MotionBlurCB=GFxClikWidget(Widget);
			if (MotionBlurCB != None)
			{
				bMotionBlur = bool(CPSaveManager.GetItem("bMotionBlur"));
				MotionBlurCB.SetBool("selected", bMotionBlur);
			}
			bWasHandled=true;
		break;
		case ('DShadowsCB'):
			DShadowsCB=GFxClikWidget(Widget);
			if (DShadowsCB != None)
			{
				bDynamicShadows = bool(CPSaveManager.GetItem("bDynamicShadows"));
				DShadowsCB.SetBool("selected", bDynamicShadows);
			}
			bWasHandled=true;
		break;
		case ('DLightsCB'):
			DLightsCB=GFxClikWidget(Widget);
			if (DLightsCB != None)
			{
				bDynamicLights = bool(CPSaveManager.GetItem("bDynamicLights"));
				DLightsCB.SetBool("selected", bDynamicLights);
			}
			bWasHandled=true;
		break;
		case ('AmbientOcclusionCB'):
			AmbientOcclusionCB=GFxClikWidget(Widget);
			if (AmbientOcclusionCB != None)
			{
				bAmbientOcclusion = bool(CPSaveManager.GetItem("bAmbientOcclusion"));
				AmbientOcclusionCB.SetBool("selected", bAmbientOcclusion);
			}
			bWasHandled=true;
		break;
		case ('ParticlesDetailDDPH'):
			ParticlesDetailDDPH=GFxClikWidget(Widget);
			if (ParticlesDetailDDPH != None)
			{
				SetUpDataProvider(ParticlesDetailDDPH);
			}
			bWasHandled=true;
		break;
		case ('AntiAliasingDDPH'):
			AntiAliasingDDPH=GFxClikWidget(Widget);
			if (AntiAliasingDDPH != None)
			{
				SetUpDataProvider(AntiAliasingDDPH);
			}
			bWasHandled=true;
		break;
		case ('GoreLeveDDPH'):
			GoreLeveDDPH=GFxClikWidget(Widget);
			if (GoreLeveDDPH != None)
			{
				SetUpDataProvider(GoreLeveDDPH);
			}
			bWasHandled=true;
		break;
		case ('MaxAnisotropyDD'):
			MaxAnisotropyDD=GFxClikWidget(Widget);
			if (MaxAnisotropyDD != None)
			{
				MaxAnisotropyDD.SetInt("selectedIndex", int(CPSaveManager.GetItem("Anistropy")));
				SetUpDataProvider(MaxAnisotropyDD);
			}
			bWasHandled=true;
		break;








		// Mouse & Input //
		case ('VSyncCB'):
			VSyncCB=GFxClikWidget(Widget);
			if (VSyncCB != None)
			{
				bVSync = bool(CPSaveManager.GetItem("bVSync"));
				VSyncCB.SetBool("selected", bVSync);
			}
			bWasHandled=true;
		break;
		case ('EnableMouseSmoothingCB'):
			EnableMouseSmoothingCB=GFxClikWidget(Widget);
			if (EnableMouseSmoothingCB != None)
			{
				bMouseSmoothing = bool(CPSaveManager.GetItem("MouseSmoothing"));
				EnableMouseSmoothingCB.SetBool("selected", bMouseSmoothing);
			}
			bWasHandled=true;
		break;
		case ('MouseSensitivitySlider'):
			MouseSensitivitySlider=GFxClikWidget(Widget);
			if(MouseSensitivitySlider != None)
			{
				PlayerController = GetPC();
				if (PlayerController != none && PlayerController.PlayerInput != None)
				{
					CPPlayerInput = CPPlayerInput(PlayerController.PlayerInput);
					if(CPPlayerInput != None)
					{
						MouseSensitivity = CPPlayerInput.MouseSensitivity;
						MouseSensitivitySlider.SetFloat("value", MouseSensitivity);
					}
				}
			}
			bWasHandled=true;
		break;
		case ('ShowCrosshairsCB'):
			ShowCrosshairsCB=GFxClikWidget(Widget);
			if (ShowCrosshairsCB != None)
			{
				// Show Crosshair now becomes Hide crosshair for consistency
				ShowCrosshairsCB.SetString("label", "Hide Crosshair");
				bShowCrosshair = bool(CPSaveManager.GetItem("HideCrosshair"));
				ShowCrosshairsCB.SetBool("selected", bShowCrosshair);
			}
			bWasHandled=true;
		break;
		case ('CrosshairScaleSlider'):
			CrosshairScaleSlider=GFxClikWidget(Widget);
			if(CrosshairScaleSlider != None)
			{
				if(CPPlayerController(GetPC()) != none)
				{
					// Load the config
					CPPlayerController(GetPC()).GetCrosshairSettingsFromConfig();

					// Set the sliders values
					CrosshairScaleSlider.SetFloat("value", CPPlayerController(GetPC()).PredefinedCrosshairScale);
					UpdateCrosshairColourAndScale();
				}

				CrosshairScaleSlider.AddEventListener('CLIK_change', OnColorAndScaleSliderChange);
			}
			bWasHandled=true;
		break;
		case ('CrosshairstyleSlider'):
			CrosshairstyleSlider=GFxClikWidget(Widget);
			if(CrosshairstyleSlider != None)
			{
				CrosshairstyleSlider.AddEventListener('CLIK_change',OnCrosshairstyleSliderChange);
			}
			bWasHandled=true;
		break;
		case ('RedSlider'):
			RedSlider=GFxClikWidget(Widget);
			if(RedSlider != none)
			{
				if(CPPlayerController(GetPC()) != none)
				{
					// Load the config
					CPPlayerController(GetPC()).GetCrosshairSettingsFromConfig();

					// Set the sliders values
					RedSlider.SetFloat("value", CPPlayerController(GetPC()).PredefinedCrosshairColor.R);
					UpdateCrosshairColourAndScale();
				}

				RedSlider.AddEventListener('CLIK_change', OnColorAndScaleSliderChange);
			}
			bWasHandled=true;
		break;
		case ('GreenSlider'):
			GreenSlider=GFxClikWidget(Widget);
			if(GreenSlider != none)
			{
				if(CPPlayerController(GetPC()) != none)
				{
					CPPlayerController(GetPC()).GetCrosshairSettingsFromConfig();

					// Set the sliders values
					GreenSlider.SetFloat("value", CPPlayerController(GetPC()).PredefinedCrosshairColor.G);
					UpdateCrosshairColourAndScale();
				}

				GreenSlider.AddEventListener('CLIK_change', OnColorAndScaleSliderChange);
			}
			bWasHandled=true;
		break;
		case ('BlueSlider'):
			BlueSlider=GFxClikWidget(Widget);
			if(BlueSlider != none)
			{
				if(CPPlayerController(GetPC()) != none)
				{
					CPPlayerController(GetPC()).GetCrosshairSettingsFromConfig();

					// Set the sliders values
					BlueSlider.SetFloat("value", CPPlayerController(GetPC()).PredefinedCrosshairColor.B);
					UpdateCrosshairColourAndScale();
				}

				BlueSlider.AddEventListener('CLIK_change', OnColorAndScaleSliderChange);
			}
			bWasHandled=true;
		break;
		case ('AlphaSlider'):
			AlphaSlider=GFxClikWidget(Widget);
			if(AlphaSlider != none)
			{
				if(CPPlayerController(GetPC()) != none)
				{
					CPPlayerController(GetPC()).GetCrosshairSettingsFromConfig();

					// Set the sliders values
					AlphaSlider.SetFloat("value", CPPlayerController(GetPC()).PredefinedCrosshairColor.A);
					UpdateCrosshairColourAndScale();
				}

				AlphaSlider.AddEventListener('CLIK_change', OnColorAndScaleSliderChange);
			}
			bWasHandled=true;
		break;
		case ('CrosshairButton'):
			CrosshairButton=GFxClikWidget(Widget);
			if (CrosshairButton != None)
			{
				CrosshairButton.SetVisible(false);
			}
			bWasHandled=true;
		break;



		// HUD //
		case ('SHCB'):
			ShowHudCB=GFxClikWidget(Widget);
			if (ShowHudCB != None)
			{
				bShowHud = bool(CPSaveManager.GetItem("ShowHUD"));
				ShowHudCB.SetBool("selected", bShowHud);
			}
			bWasHandled=true;
		break;
		case ('STCB'):
			ShowTimeCB=GFxClikWidget(Widget);
			if (ShowTimeCB != None)
			{
				bShowTime = bool(CPSaveManager.GetItem("ShowTime"));
				ShowTimeCB.SetBool("selected", bShowTime);
			}
			bWasHandled=true;
		break;
		case ('SCCB'):
			ShowChatCB=GFxClikWidget(Widget);
			if (ShowChatCB != None)
			{
				bShowChat = bool(CPSaveManager.GetItem("ShowChat"));
				ShowChatCB.SetBool("selected", bShowChat);
			}
			bWasHandled=true;
		break;
		case ('HIDD'):
			ShowHitIndicatorDDPH=GFxClikWidget(Widget);
			if (ShowHitIndicatorDDPH != None)
			{
				ShowHitIndicatorDDPH.SetInt("selectedIndex", int(CPSaveManager.GetItem("HitDirectional")));
				SetUpDataProvider(ShowHitIndicatorDDPH);
			}
			bWasHandled=true;
		break;
		case ('SAGCB'):
			ShowArmorCB=GFxClikWidget(Widget);
			if (ShowArmorCB != None)
			{
				bShowArmor = bool(CPSaveManager.GetItem("DrawPlayerInfo"));
				ShowArmorCB.SetBool("selected", bShowArmor);
			}
			bWasHandled=true;
		break;
		case ('SWILTxt'):
			ShowWeaponsInfoTxt=GFxClikWidget(Widget);
			if (ShowWeaponsInfoTxt != None)
			{
				bShowWeaponInfo = bool(CPSaveManager.GetItem("ShowWeaponIcon"));
				ShowWeaponsInfoTxt.SetBool("selected", bShowWeaponInfo);
			}
			bWasHandled=true;
		break;
		case ('SHLTxt'):
			ShowHitLocTxt=GFxClikWidget(Widget);
			if (ShowHitLocTxt != None)
			{
				bShowHitLocation = bool(CPSaveManager.GetItem("ShowHitLocation"));
				ShowHitLocTxt.SetBool("selected", bShowHitLocation);
			}
			bWasHandled=true;
		break;
		case ('SPAWSCB'):
			ShowObjectiveInfoCB=GFxClikWidget(Widget);
			if (ShowObjectiveInfoCB != None)
			{
				ShowObjectiveInfoCB.SetString("label", "Show Objective");
				bShowObjectiveInfo = bool(CPSaveManager.GetItem("ShowObjectiveInfo"));
				ShowObjectiveInfoCB.SetBool("selected", bShowObjectiveInfo);
			}
			bWasHandled=true;
		break;
		case ('SDMCB'):
			ShowDeathMessageCB=GFxClikWidget(Widget);
			if (ShowDeathMessageCB != None)
			{
				`log("Show Death Message not hooked up yet...");
				//bShowDeathMessage = bool(CPSaveManager.GetItem("ShowDeathMessage"));
				//ShowDeathMessageCB.SetBool("selected", bShowDeathMessage);
			}
			bWasHandled=true;
		break;
		case ('HCSSlider'):
			HudScaleSlider=GFxClikWidget(Widget);
			if (HudScaleSlider != None)
			{
				HudScale = float(CPSaveManager.GetItem("HUDScale"));
				HudScaleSlider.SetFloat("value", HudScale);
			}
			bWasHandled=true;
		break;



		// Crosshairs
		case ('Cross_1'):
			Cross_1=GFxClikWidget(Widget);
			if (Cross_1 != None)
			{
				CrosshairStyles[0] = Cross_1;
				Cross_1.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_2'):
			Cross_2=GFxClikWidget(Widget);
			if (Cross_2 != None)
			{
				CrosshairStyles[1] = Cross_2;
				Cross_2.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_3'):
			Cross_3=GFxClikWidget(Widget);
			if (Cross_3 != None)
			{
				CrosshairStyles[2] = Cross_3;
				Cross_3.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_4'):
			Cross_4=GFxClikWidget(Widget);
			if (Cross_4 != None)
			{
				CrosshairStyles[3] = Cross_4;
				Cross_4.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_5'):
			Cross_5=GFxClikWidget(Widget);
			if (Cross_5 != None)
			{
				CrosshairStyles[4] = Cross_5;
				Cross_5.SetVisible(false);
			}
			bWasHandled=true;
		break;

		case ('Cross_6'):
			Cross_6=GFxClikWidget(Widget);
			if (Cross_6 != None)
			{
				CrosshairStyles[5] = Cross_6;
				Cross_6.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_7'):
			Cross_7=GFxClikWidget(Widget);
			if (Cross_7 != None)
			{
				CrosshairStyles[6] = Cross_7;
				Cross_7.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_8'):
			Cross_8=GFxClikWidget(Widget);
			if (Cross_8 != None)
			{
				CrosshairStyles[7] = Cross_8;
				Cross_8.SetVisible(false);
			}
			bWasHandled=true;
		break;

		case ('Cross_9'):
			Cross_9=GFxClikWidget(Widget);
			if (Cross_9 != None)
			{
				CrosshairStyles[8] = Cross_9;
				Cross_9.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_10'):
			Cross_10=GFxClikWidget(Widget);
			if (Cross_10 != None)
			{
				CrosshairStyles[9] = Cross_10;
				Cross_10.SetVisible(false);
			}
			bWasHandled=true;
		break;

		case ('Cross_11'):
			Cross_11=GFxClikWidget(Widget);
			if (Cross_11 != None)
			{
				CrosshairStyles[10] = Cross_11;
				Cross_11.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_12'):
			Cross_12=GFxClikWidget(Widget);
			if (Cross_12 != None)
			{
				CrosshairStyles[11] = Cross_12;
				Cross_12.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_13'):
			Cross_13=GFxClikWidget(Widget);
			if (Cross_13 != None)
			{
				CrosshairStyles[12] = Cross_13;
				Cross_13.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_14'):
			Cross_14=GFxClikWidget(Widget);
			if (Cross_14 != None)
			{
				CrosshairStyles[13] = Cross_14;
				Cross_14.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_15'):
			Cross_15=GFxClikWidget(Widget);
			if (Cross_15 != None)
			{
				CrosshairStyles[14] = Cross_15;
				Cross_15.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_16'):
			Cross_16=GFxClikWidget(Widget);
			if (Cross_16 != None)
			{
				CrosshairStyles[15] = Cross_16;
				Cross_16.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_17'):
			Cross_17=GFxClikWidget(Widget);
			if (Cross_17 != None)
			{
				CrosshairStyles[16] = Cross_17;
				Cross_17.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_18'):
			Cross_18=GFxClikWidget(Widget);
			if (Cross_18 != None)
			{
				CrosshairStyles[17] = Cross_18;
				Cross_18.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_19'):
			Cross_19=GFxClikWidget(Widget);
			if (Cross_19 != None)
			{
				CrosshairStyles[18] = Cross_19;
				Cross_19.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_20'):
			Cross_20=GFxClikWidget(Widget);
			if (Cross_20 != None)
			{
				CrosshairStyles[19] = Cross_20;
				Cross_20.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_21'):
			Cross_21=GFxClikWidget(Widget);
			if (Cross_21 != None)
			{
				CrosshairStyles[20] = Cross_21;
				Cross_21.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_22'):
			Cross_22=GFxClikWidget(Widget);
			if (Cross_22 != None)
			{
				CrosshairStyles[21] = Cross_22;
				Cross_22.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_23'):
			Cross_23=GFxClikWidget(Widget);
			if (Cross_23 != None)
			{
				CrosshairStyles[22] = Cross_23;
				Cross_23.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_24'):
			Cross_24=GFxClikWidget(Widget);
			if (Cross_24 != None)
			{
				CrosshairStyles[23] = Cross_24;
				Cross_24.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_25'):
			Cross_25=GFxClikWidget(Widget);
			if (Cross_25 != None)
			{
				CrosshairStyles[24] = Cross_25;
				Cross_25.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_26'):
			Cross_26=GFxClikWidget(Widget);
			if (Cross_26 != None)
			{
				CrosshairStyles[25] = Cross_26;
				Cross_26.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_27'):
			Cross_27=GFxClikWidget(Widget);
			if (Cross_27 != None)
			{
				CrosshairStyles[26] = Cross_27;
				Cross_27.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_28'):
			Cross_28=GFxClikWidget(Widget);
			if (Cross_28 != None)
			{
				CrosshairStyles[27] = Cross_28;
				Cross_28.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_29'):
			Cross_29=GFxClikWidget(Widget);
			if (Cross_29 != None)
			{
				CrosshairStyles[28] = Cross_29;
				Cross_29.SetVisible(false);
			}
			bWasHandled=true;
		break;

		case ('Cross_30'):
			Cross_30=GFxClikWidget(Widget);
			if (Cross_30 != None)
			{
				CrosshairStyles[29] = Cross_30;
				Cross_30.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_31'):
			Cross_31=GFxClikWidget(Widget);
			if (Cross_31 != None)
			{
				CrosshairStyles[30] = Cross_31;
				Cross_31.SetVisible(false);
			}
			bWasHandled=true;
		break;
		case ('Cross_32'):
			Cross_32=GFxClikWidget(Widget);
			if (Cross_32 != None)
			{
				CrosshairStyles[31] = Cross_32;
				Cross_32.SetVisible(false);
			}
			bWasHandled=true;
		break;


		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
		//`log( "CPI_FrontEnd_SettingsMenu::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}
	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}


DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="SettingsListPanel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SettingsBackBtn",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SettingsDefaultBtn",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SettingsAcceptBtn",WidgetClass=class'GFxClikWidget'))

	// Video
	SubWidgetBindings.Add((WidgetName="resolutionDDPH",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="LevelOfDetailDDPH",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FullScreenCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="GammaSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SDecalsCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SkipIntroMovies",WidgetClass=class'GFxClikWidget'))

	// Audio
	SubWidgetBindings.Add((WidgetName="MusicVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AnnouncerVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MasterVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="EffectsVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MaxChannelsDDPH",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="AdvancedDragBar",WidgetClass=class'GFxObject'))

	SubWidgetBindings.Add((WidgetName="ViewBobSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="WeaponHandDDPH",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PlayerNametxtbox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ClanName",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AutomaticReloadingCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AutoswitchonWeaponPickupCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="UseLastweaponafterGrenadeCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="RememberLaserstateCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AutoshowTeamInfoRadarCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ShowFPSCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ColourbindOptionCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PlayAsSpectatorCB",WidgetClass=class'GFxClikWidget'))

	// Advanced
	SubWidgetBindings.Add((WidgetName="BloomCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MotionBlurCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DShadowsCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DLightsCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AmbientOcclusionCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ParticlesDetailDDPH",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AntiAliasingDDPH",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="GoreLeveDDPH",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MaxAnisotropyDD",WidgetClass=class'GFxClikWidget'))


	// Mouse & Input
	SubWidgetBindings.Add((WidgetName="VSyncCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="EnableMouseSmoothingCB",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MouseSensitivitySlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ShowCrosshairsCB",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="CrosshairScaletxt",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CrosshairScaleSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CrosshairstyleSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="RedSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="GreenSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BlueSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AlphaSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CrosshairButton",WidgetClass=class'GFxClikWidget'))

	//HUD
	//Show hud
	SubWidgetBindings.Add((WidgetName="SHCB",WidgetClass=class'GFxClikWidget'))
	//Show Time
	SubWidgetBindings.Add((WidgetName="STCB",WidgetClass=class'GFxClikWidget'))
	//Show chat
	SubWidgetBindings.Add((WidgetName="SCCB",WidgetClass=class'GFxClikWidget'))
	//show hit indicators
	SubWidgetBindings.Add((WidgetName="HIDD",WidgetClass=class'GFxClikWidget'))
	//show armor guy
	SubWidgetBindings.Add((WidgetName="SAGCB",WidgetClass=class'GFxClikWidget'))
	//Show weapons info
	SubWidgetBindings.Add((WidgetName="SWILTxt",WidgetClass=class'GFxClikWidget'))
	//Show hit location
	SubWidgetBindings.Add((WidgetName="SHLTxt",WidgetClass=class'GFxClikWidget'))
	//Show player and weapon status
	SubWidgetBindings.Add((WidgetName="SPAWSCB",WidgetClass=class'GFxClikWidget'))
	//Show death messages
	SubWidgetBindings.Add((WidgetName="SDMCB",WidgetClass=class'GFxClikWidget'))
	//Hud scale
	SubWidgetBindings.Add((WidgetName="HCSSlider",WidgetClass=class'GFxClikWidget'))

	// Crosshairs

// Using RenderToTexture2D may be better for the crosshairs
	SubWidgetBindings.Add((WidgetName="Cross_1",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_2",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_3",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_4",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_5",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_6",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_7",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_8",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_9",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_10",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_11",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_12",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_13",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_14",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_15",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_16",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_17",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_18",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_19",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_20",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_21",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_22",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_23",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_24",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_25",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_26",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_27",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_28",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_29",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_30",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_31",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Cross_32",WidgetClass=class'GFxClikWidget'))


	// Gamma Values
	GammaValues[0]=1.0
	GammaValues[1]=1.25
	GammaValues[2]=1.5
	GammaValues[3]=1.85
	GammaValues[4]=2.2
	GammaValues[5]=2.2
	GammaValues[6]=2.75
	GammaValues[7]=3.0
	GammaValues[8]=3.25
	GammaValues[9]=3.5
	GammaValues[10]=3.75

	// Anti Alias Values
	AntiAliases[0]=0
	AntiAliases[1]=2
	AntiAliases[2]=4
	AntiAliases[3]=8

	// Anistropys
	Anistropys[0]=0
	Anistropys[1]=2
	Anistropys[2]=4
	Anistropys[3]=8
	Anistropys[4]=16

	// Particles Detail
	Particles[0]=-1
	Particles[1]=0
	Particles[2]=1
	Particles[3]=2
	Particles[4]=3
	Particles[5]=4

	// Max Channels
	MaxChannels[0]=16
	MaxChannels[1]=32
	MaxChannels[2]=48
	MaxChannels[3]=64

	HitIndicators[0]=0
	HitIndicators[1]=1
	HitIndicators[2]=2

	// ListAnistropy List Values
	ListAnistropy(0)=(OptionName="0")
	ListAnistropy(1)=(OptionName="2")
	ListAnistropy(2)=(OptionName="4")
	ListAnistropy(3)=(OptionName="8")
	ListAnistropy(4)=(OptionName="16")

	// Anti Alias List Values
	ListAntiAlias(0)=(OptionName="0")
	ListAntiAlias(1)=(OptionName="2")
	ListAntiAlias(2)=(OptionName="4")
	ListAntiAlias(3)=(OptionName="8")

	// Particle Detail List Values
	ListParticleDetail(0)=(OptionName="-1 Best")
	ListParticleDetail(1)=(OptionName="0 ")
	ListParticleDetail(2)=(OptionName="1")
	ListParticleDetail(3)=(OptionName="2")
	ListParticleDetail(4)=(OptionName="3")
	ListParticleDetail(5)=(OptionName="4 Worse")

	// Gore Detail List Values
	ListGoreDetail(0)=(OptionName="Off")
	ListGoreDetail(1)=(OptionName="1")
	ListGoreDetail(2)=(OptionName="2")

	// Hit Indicators List Values
	ListHitIndicators(0)=(OptionName="Off")
	ListHitIndicators(1)=(OptionName="1")
	ListHitIndicators(2)=(OptionName="2")

	// Level of Detail Values
	ListLevelOfDetail(0)=(OptionName="Ultra Low")
	ListLevelOfDetail(1)=(OptionName="Low")
	ListLevelOfDetail(2)=(OptionName="Medium")
	ListLevelOfDetail(3)=(OptionName="High")
	ListLevelOfDetail(4)=(OptionName="Ultra High")

	// List Max Channels
	ListMaxChannels(0)=(OptionName="16")
	ListMaxChannels(1)=(OptionName="32")
	ListMaxChannels(2)=(OptionName="48")
	ListMaxChannels(3)=(OptionName="64")

	// Skippable Movies
	SkippableMovies[0]="UE3_logo"
	SkippableMovies[1]="Dominating"
	SkippableMovies[2]="Sponsors"
	SkippableMovies[3]="UDKFrontEnd.udk_loading"

	DefaultToolTip="Select various graphical / audio settings here and click Accept Changes to take effect."
}
