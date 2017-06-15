class CPI_FrontEnd_MainMenu extends CPIFrontEnd_Screen 
    config(UI);
var GFxClikWidget   BtnSignIn, PracticeButton, MultiplayerButton, KeybindButton, SettingsButton, JoinGameButton, CreateServerButton, PlayerButton, VideoButton, AudioButton, InputButton, ExitButton, CreditsButton;
var GfxObject VersionLabel, SignInLabel, UserNameLabel, MainBGImage;

//required to hide when disabled
var GfxObject settingsSubMenu;
var GFxClikWidget multiplayerSubMenu;
var localized string   strSignIn, strPractice, strMultiplayer, strKeybinds, strSettings, strJoinGame, strCreateServer, strPlayer, strVideo, strAudio, strInput, strExit, strCredits, strDisconnect;
var localized string   strVersionLabel, strSignInLabel, strNotSignedInLabel, strUserNameLabel;
var string VersionText;
var bool bOpenedIngame;


/*
 *	Ensure we are able to close the pause menu when we are a spectator
*/
function OnEscapeKeyPress()
{
	local WorldInfo WorldInfo;
	local string MapName;

	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if(WorldInfo != none)
	{
		MapName = WorldInfo.GetMapName(true);
		if(MapName != "CPFrontEndMap" || MapName != "CPIFrontEndMap")
		{
			if(bOpenedIngame)
			{
				if(bMovieIsOpen)
				{
					CPHud(GetPC().myHUD).CloseFrontend();
				}
			}
		}
	}
}

function DisableSubComponents(bool bDisableComponents)
{
	super.DisableSubComponents(bDisableComponents);

	//override the disablesubcomponents for mainbgimage.
	if(!bOpenedIngame)
	{
		if(MainBGImage != none)
		{
			MainBGImage.SetColorTransform( NORMAL );
			MainBGImage.SetBool("disabled", false);
		}
	}
}

function PlayOpenAnimation()
{
	if(bOpenedIngame)
	{
		//`Log("TODO expose main MC so we can control playanimation PlayOpenAnimation");
	}
}

function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
	super.OnTopMostView(bPlayOpenAnimation);
	UpdatePlayerName();
}

function Select_Practice(GFxClikWidget.EventData ev)
{
	MenuManager.PushViewByName('PrivateGameView');
}

function Select_Multiplayer(GFxClikWidget.EventData ev)
{
	MenuManager.PushViewByName('MultiplayerMenu');
}

function Select_Keybind(GFxClikWidget.EventData ev)
{
	MenuManager.PushViewByName('KeyBindings');
}

function Select_Settings(GFxClikWidget.EventData ev)
{
	MenuManager.PushViewByName('SettingsMenu');
}

/*
 *	Connects to the dev testing server
 *	Function currently not being used
*/
function Select_JoinGame(GFxClikWidget.EventData ev)
{
	local LocalPlayer LP;

	LP=GetLP();
	if ((LP!=none ) && (LP.ViewportClient.ViewportConsole!=none))
	{
		ConsoleCommand("open ngz.dominatingstudios.com");
		multiplayerSubMenu.SetVisible(false);
	}
}

function Select_CreateServer(GFxClikWidget.EventData ev)
{
	MenuManager.PushViewByName('PrivateServerView');
}

function Select_Player(GFxClikWidget.EventData ev)
{
}

function Select_Video(GFxClikWidget.EventData ev)
{

}

function Select_Audio(GFxClikWidget.EventData ev)
{

}

function Select_Input(GFxClikWidget.EventData ev)
{

}

function Select_Exit(GFxClikWidget.EventData ev)
{
	if(bOpenedIngame)
	{
		if(GetPC().WorldInfo.IsPlayInEditor())
		{
			`Log("PLAY IN EDITOR QUIT");
			ConsoleCommand("Quit");
		}
		else
		{
			ConsoleCommand("disconnect");
		}
	}
	else
	{
		MenuManager.PushViewByName('ExitGameDialog');
	}
}

function Select_Credits(GFxClikWidget.EventData ev)
{
}

//function Select_SignIn(GFxClikWidget.EventData ev)
//{
//	MenuManager.PushViewByName('LoginDialog');
//}

function UpdatePlayerName()
{
//	class'Engine'.static.BasicLoadObject(MenuManager.SPI, "steam_api.bin", false, 1);	
	
	if(SignInLabel == none)
		return;
	if(UserNameLabel == none)
		return;
	if(BtnSignIn == none)
		return;

	//if(MenuManager.SPI != none)
	//{

	//	if(MenuManager.SPI.playername != "")
	//	{
	//		UserNameLabel.SetString("text",MenuManager.SPI.playername);
	//		SignInLabel.SetVisible(true);
	//		BtnSignIn.SetVisible(false);
	//		SignInLabel.SetString("text",strSignInLabel);
	//		UserNameLabel.SetVisible(true);
	//	}
	//	else
	//	{
	//		SignInLabel.SetString("text",strNotSignedInLabel);
	//		UserNameLabel.SetString("text","");
	//		UserNameLabel.SetVisible(false);
	//		BtnSignIn.SetVisible(true);
	//	}
	//}
}


/**
 */
function OnButtonRollOver(GFxClikWidget.EventData EventData)
{
	local GFxClikWidget Target;

	if (EventData._this != None)
	{
		Target = GFxClikWidget(EventData._this.GetObject("target", class'GFxClikWidget'));
		if (Target != None)
		{
			//Target.SetBool("focused", true);

			if(multiplayerSubMenu != none)
				multiplayerSubMenu.SetVisible(true);
		}
	}
}


/**
 */
function OnButtonRollOut(GFxClikWidget.EventData EventData)
{
	local GFxClikWidget Target;

	if (EventData._this != None)
	{
		Target = GFxClikWidget(EventData._this.GetObject("target", class'GFxClikWidget'));
		if (Target != None)
		{
			//Target.SetBool("focused", false);

			if(multiplayerSubMenu != none)
				multiplayerSubMenu.SetVisible(false);
		}
	}
}


event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;
	bWasHandled=false;

	switch(WidgetName)
	{		
		case ('practice'):
			PracticeButton=GFxClikWidget(Widget);
			if(PracticeButton != none)
			{
				PracticeButton.SetString("label",strPractice);
				PracticeButton.AddEventListener('CLIK_press',Select_Practice);
			}
			bWasHandled=true; 
		break;
		case ('Multiplayer'):
			MultiplayerButton=GFxClikWidget(Widget);
			if(MultiplayerButton != none)
			{
				MultiplayerButton.SetString("label",strMultiplayer);
				MultiplayerButton.AddEventListener('CLIK_rollOver', OnButtonRollOver);
			}
			bWasHandled=true; 
		break;
		case ('community'):
			KeybindButton=GFxClikWidget(Widget);
			if(KeybindButton != none)
			{
				KeybindButton.SetString("label",strKeybinds);
				KeybindButton.AddEventListener('CLIK_press',Select_Keybind);
			}
			bWasHandled=true; 
		break;
		case ('Settings'):
			SettingsButton=GFxClikWidget(Widget);
			if(SettingsButton != none)
			{
				SettingsButton.SetString("label",strSettings);
				SettingsButton.AddEventListener('CLIK_press',Select_Settings);
			}
			bWasHandled=true; 
		break;
		case ('joinServer'):
			JoinGameButton=GFxClikWidget(Widget);
			if(JoinGameButton != none)
			{
				JoinGameButton.SetString("label", "SERVER BROWSER");
				JoinGameButton.AddEventListener('CLIK_press',Select_Multiplayer);
			}
			bWasHandled=true; 
		break;
		case ('createServer'):
			CreateServerButton=GFxClikWidget(Widget);
			if(CreateServerButton != none)
			{
				CreateServerButton.SetString("label",strCreateServer);
				CreateServerButton.AddEventListener('CLIK_press',Select_CreateServer);
			}
			bWasHandled=true; 
		break;
		case ('Player'):
			PlayerButton=GFxClikWidget(Widget);
			if(PlayerButton != none)
			{
				PlayerButton.SetString("label",strPlayer);
				PlayerButton.AddEventListener('CLIK_press',Select_Player);
			}
			bWasHandled=true; 
		break;
		case ('video'):
			VideoButton=GFxClikWidget(Widget);
			if(VideoButton != none)
			{
				VideoButton.SetString("label",strVideo);
				VideoButton.AddEventListener('CLIK_press',Select_Video);
			}
			bWasHandled=true; 
		break;
		case ('Audio'):
			AudioButton=GFxClikWidget(Widget);
			if(AudioButton != none)
			{
				AudioButton.SetString("label",strAudio);
				AudioButton.AddEventListener('CLIK_press',Select_Audio);
			}
			bWasHandled=true; 
		break;
		case ('Input'):
			InputButton=GFxClikWidget(Widget);
			if(InputButton != none)
			{
				InputButton.SetString("label",strInput);
				InputButton.AddEventListener('CLIK_press',Select_Input);
			}
			bWasHandled=true; 
		break;
		case ('SignInLabel'):
			SignInLabel=Widget;
			if(SignInLabel != none)
			{
				//if(bOpenedIngame)
				//{
				//	UserNameLabel = Widget;
				//	UpdatePlayerName();
				//}
				//else
				//{
					SignInLabel.SetVisible(false);
				//}
				SignInLabel.SetString("text",strNotSignedInLabel);
				UpdatePlayerName();
			}
			bWasHandled=true; 
		break;
		case ('UserName'):
			UserNameLabel=Widget;
			if(UserNameLabel != none)
			{
				UserNameLabel.SetString("text",strUserNameLabel);
				UserNameLabel.SetVisible(false);
				UpdatePlayerName();
			}
			bWasHandled=true; 
		break;	
		case ('Exit'):
			ExitButton=GFxClikWidget(Widget);
			if(ExitButton != none)
			{
				if(bOpenedIngame)
				{
					ExitButton.SetString("label",strDisconnect);
				}
				else
				{
					ExitButton.SetString("label",strExit);
				}
				ExitButton.AddEventListener('CLIK_press',Select_Exit);
			}
			bWasHandled=true; 
		break;
		case ('credits'):
			CreditsButton=GFxClikWidget(Widget);
			if(CreditsButton != none)
			{
				CreditsButton.SetString("label",strCredits);
				CreditsButton.AddEventListener('CLIK_press',Select_Credits);
			}
			bWasHandled=true; 
		break;		
		case ('BtnSignIn'):
			BtnSignIn=GFxClikWidget(Widget);
			if(BtnSignIn != none)
			{
				//if(bOpenedIngame)
				//{
				//	BtnSignIn.SetVisible(false);
				//}
				//else
				//{
				//	BtnSignIn.SetVisible(true);
				//}
				BtnSignIn.SetVisible(false);
				BtnSignIn.SetString("label",strSignIn);
//				BtnSignIn.AddEventListener('CLIK_press',Select_SignIn);
				UpdatePlayerName();
			}
			bWasHandled=true; 
		break;		
		case ('multiplayerSubMenu'):
			multiplayerSubMenu = GFxClikWidget(Widget);
			if(multiplayerSubMenu != none)
			{
				if(bOpenedIngame)
				{
					multiplayerSubMenu.SetBool("disabled", false);
				}
				else
				{
					multiplayerSubMenu.SetBool("disabled", true);
				}

				multiplayerSubMenu.AddEventListener('CLIK_rollOut', OnButtonRollOut);
			}
			bWasHandled=true; 
		break;	
		case ('settingsSubMenu'):
			settingsSubMenu=Widget;
			if(settingsSubMenu != none)
			{
				if(bOpenedIngame)
				{
					settingsSubMenu.SetBool("disabled", false);
				}
				else
				{
					settingsSubMenu.SetBool("disabled", true);
				}
			}
			bWasHandled=true; 
		break;	
		case ('credits'):
			CreditsButton=GFxClikWidget(Widget);
			if(CreditsButton != none)
			{
				CreditsButton.SetString("label",strCredits);
				CreditsButton.AddEventListener('CLIK_press',Select_Credits);
			}
			bWasHandled=true; 
		break;	
		case ('MainBGImage'):
			MainBGImage=Widget;
			if(MainBGImage != none)
			{
				if(bOpenedIngame)
				{
					MainBGImage.SetBool("focused",true); //hack so we select the menu progamically - without this escape doesnt work unless you focus something.
					MainBGImage.SetVisible(false);
				}
				else
				{
					MainBGImage.SetVisible(true);
				}
			}
			bWasHandled=true; 
		break;	
		case ('VersionLabel'):
			VersionText = class'CPConsole'.default.GameVersion;
			if(!bOpenedIngame)
			{
				`Log("========================");
				`Log("Critical Point:Incursion");
				`Log("BETA");
				`Log(VersionText);
				`Log("========================");
			}
			VersionLabel=Widget;
			VersionLabel.SetString("text",VersionText);
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled) 
		`log( "CPI_FrontEnd_MainMenu::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);

	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="practice",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="multiplayer",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="multiplayerSubMenu",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="community",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Settings",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="joinServer",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="createServer",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Player",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="video",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Audio",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Input",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Exit",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="credits",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BtnSignIn",WidgetClass=class'GFxClikWidget'))
}
