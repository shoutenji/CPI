class CPI_FrontEnd_LoginDialog extends CPIFrontEnd_Screen 
    config(UI);

//var GFxObject LoadingBG, RotatingLogo, LinkMessage, Loading, LoginTitle, QuoteLine, UserNameLabel, PasswordLabel, UsernameVal, PasswordVal, LoginFailedBG, LoginFailed_Text, Failed;
//var GFxClikWidget LoginButton, PlayOfflineButton, UsernameBox, PasswordBox, OK_Button;
//var localized string PasswordValidationFailed, UserNameValidationFailed, CheckingLoginDetails, Login_Title, Login_Text, Username, Password, LoginButtonText, PlayOfflineButtonText,OKButtonText, LoggingInText;
//var localized string SteamNotLoggedIn, LoginSuccess, UsernameOrPasswordMissing,UsernameOrPasswordWrong,NotRegistered,RegistrationNotApproved,UserIsLocked,NoValidUDKSteamID,NoLoginFromDifferentIPAllowed;
//var CPILinkup Link;
//var int LoginAttempts;
//var config string LoginName;
//var bool blnShowingDialog;

//function OnViewActivated()
//{
//	SetTextBoxFocus();
//	blnShowingDialog = false;
//}

//function SetTextBoxFocus()
//{
//	if(UsernameBox != none && PasswordBox != none)
//	{
//		if(Len(UsernameBox.GetString("text")) == 0)
//		{
//			UsernameBox.setBool("focused",true);
//		}
//		else
//		{
//			PasswordBox.setBool("focused",true);
//		}
//	}
//}

//function Select_Login(GFxClikWidget.EventData ev)
//{
//	DoLogin();
//}

//function DoLogin()
//{
//	local bool blnStopLogin;
	
//	if(Len(UsernameBox.GetString("text")) == 0)
//	{
//		UsernameVal.SetVisible(true);
//		UsernameVal.SetString("text", UserNameValidationFailed);
//		blnStopLogin = true;
//	}
//	else
//		UsernameVal.SetVisible(false);

//	if(Len(PasswordBox.GetString("text")) == 0)
//	{
//		PasswordVal.SetVisible(true);
//		PasswordVal.SetString("text", PasswordValidationFailed);
//		blnStopLogin = true;
//	}
//	else
//		PasswordVal.SetVisible(false);

//	if(blnStopLogin)
//		return;
	
//	Loading.SetString("text",CheckingLoginDetails);
//	ToggleLogin(true);

//	if(Link == none)
//		Link = GetPC().Spawn(class'CPILinkup'); 

//	Link.Login(self, UsernameBox.GetString("text"),PasswordBox.GetString("text"), GetPC());
//}

//function string LocaliseErrorMessage(int returncode)
//{
//	switch(returncode)
//	{
//	case 0:
//		return LoginSuccess;
//	case 1:
//		return UsernameOrPasswordMissing;
//	case 2:
//		return UsernameOrPasswordWrong;
//	case 3:
//		return NotRegistered;
//	case 4:
//		return RegistrationNotApproved;
//	case 5:
//		return UserIsLocked;
//	case 6:
//		return NoValidUDKSteamID;
//	case 7:
//		return NoLoginFromDifferentIPAllowed;
//	default:
//		return returncode @ "Unknown Error";
//	}
//}

//function RecievedUnresolved()
//{
//	ToggleLogin(false);
//	Failed.SetString("text","Unable to resolve www.criticalpointgame.com - are you connected to the internet?");
//	ToggleLoginMessage(true);
//}

//function RecievedLoginInfo(int returncode, string message, int id, string steamid, string udksteamid, string playername, string avatar, string hash)
//{
//	ToggleLogin(false);

//	message = LocaliseErrorMessage(returncode);

//	if(udksteamid == "00" && returncode != 0)
//	{
//		Failed.SetString("text",SteamNotLoggedIn);
//		ToggleLoginMessage(true);
//	}
//	else if(returncode != 0)
//	{
//		LoginAttempts++;

//		if(LoginAttempts < 4)
//		{
//			Failed.SetString("text",message);
//			ToggleLoginMessage(true);
//		}
//		else
//		{
//			ConsoleCommand("Quit");
//		}
//	}
//	else
//	{
//		MenuManager.bLoginRequested = false;

//		MenuManager.SPI.SetProfileInfo(id,steamid,udksteamid,playername,avatar,hash);
//		class'Engine'.static.BasicSaveObject(MenuManager.SPI, "steam_api.bin", false, 1,true);

//		if(MenuManager.MainMenuView.bOpenedIngame)
//		{
//			CPPlayerController(GetPC()).RetryAuth(hash);
//		}

//		//save username so its user friendly.
//		LoginName = UsernameBox.GetString("text");
//		SaveConfig();
//		MoveBackImpl();
//	}
//}

//function OnEscapeKeyPress()
//{
//	ConsoleCommand("quit");
//}

//function Select_PlayOffline(GFxClikWidget.EventData ev)
//{
//	ConsoleCommand("quit");
//}

//function Select_OKButton(GFxClikWidget.EventData ev)
//{
//	ToggleLoginMessage(false);
//}

//event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
//{
//	local bool bWasHandled;
//	bWasHandled=false;

//	switch(WidgetName)
//	{	

//		case ('Failed'):
//			Failed=Widget;
//			Failed.SetVisible(false);
//			bWasHandled=true; 
//		break;	
//		case ('LoginFailed_Text'):
//			LoginFailed_Text=Widget;
//			LoginFailed_Text.SetVisible(false);
//			bWasHandled=true; 
//		break;
//		case ('LoginFailedBG'):
//			LoginFailedBG=Widget;
//			LoginFailedBG.SetVisible(false);
//			bWasHandled=true; 
//		break;
//		case ('LoadingBG'):
//			LoadingBG=Widget;
//			LoadingBG.SetVisible(false);
//			bWasHandled=true; 
//		break;
//		case ('RotatingLogo'):
//			RotatingLogo=Widget;
//			RotatingLogo.SetVisible(false);
//			bWasHandled=true; 
//		break;
//		case ('LinkMessage'):
//			LinkMessage=Widget;
//			LinkMessage.SetVisible(false);
//			LinkMessage.SetString("text",LoggingInText);
//			bWasHandled=true; 
//		break;
//		case ('Loading'):
//			Loading=Widget;
//			Loading.SetVisible(false);
//			bWasHandled=true; 
//		break;
//		case ('LoginTitle'):
//			LoginTitle=Widget;
//			LoginTitle.SetString("text",Login_Title);
//			bWasHandled=true; 
//		break;		
//		case ('QuoteLine'):
//			QuoteLine=Widget;
//			QuoteLine.SetString("text",Login_Text);
//			bWasHandled=true; 
//		break;	
//		case ('UserNameLabel'):
//			UserNameLabel=Widget;
//			UserNameLabel.SetString("text",Username);
//			bWasHandled=true; 
//		break;	
//		case ('PasswordLabel'):
//			PasswordLabel=Widget;
//			PasswordLabel.SetString("text",Password);
//			bWasHandled=true; 
//		break;	
//		case ('UsernameVal'):
//			UsernameVal=Widget;
//			UsernameVal.SetVisible(false);
//			bWasHandled=true; 
//		break;	
//			case ('PasswordVal'):
//			PasswordVal=Widget;
//			PasswordVal.SetVisible(false);
//			bWasHandled=true; 
//		break;	
//		case ('LoginButton'):
//			LoginButton=GFxClikWidget(Widget);
//			LoginButton.SetString("label",LoginButtonText);
//			LoginButton.AddEventListener('CLIK_press',Select_Login);
//			bWasHandled=true; 
//		break;		
//		case ('PlayOfflineButton'):
//			PlayOfflineButton=GFxClikWidget(Widget);
//			PlayOfflineButton.SetString("label",PlayOfflineButtonText);
//			PlayOfflineButton.AddEventListener('CLIK_press',Select_PlayOffline);
//			bWasHandled=true; 
//		break;		
//		case ('OK_Button'):
//			OK_Button=GFxClikWidget(Widget);
//			OK_Button.SetString("label",OKButtonText);
//			OK_Button.AddEventListener('CLIK_press',Select_OKButton);
//			OK_Button.SetVisible(false);
//			bWasHandled=true; 
//		break;				
//		case ('UsernameBox'):
//			UsernameBox=GFxClikWidget(Widget);
//			UsernameBox.SetString("text",LoginName);
//			SetTextBoxFocus();
//			bWasHandled=true; 
//		break;
//		case ('PasswordBox'):
//			PasswordBox=GFxClikWidget(Widget);
//			PasswordBox.SetString("text","");
//			SetTextBoxFocus();
//			bWasHandled=true; 
//		break;
//		case ('LoginBG'):
//			bWasHandled=true; 
//		break;
//		default:
//			bWasHandled=false;
//	}
		
//	if(!bWasHandled) 
//		`log( "CPI_FrontEnd_LoginDialog::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);

//	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
//}

//function ToggleLoginMessage(bool bVisible)
//{
//	ToggleControls(bVisible);
//	LoginFailedBG.SetVisible(bVisible);
//	OK_Button.SetVisible(bVisible);
//	LoginFailed_Text.SetVisible(bVisible);
//	Failed.SetVisible(bVisible);
//	blnShowingDialog = bVisible;
//}

//function ToggleLogin(bool bVisible)
//{
//	ToggleControls(bVisible);
//	LoadingBG.SetVisible(bVisible);
//	RotatingLogo.SetVisible(bVisible);
//	LinkMessage.SetVisible(bVisible);
//	Loading.SetVisible(bVisible);
//	blnShowingDialog = bVisible;
//}

//function ToggleControls(bool bDisableComponents)
//{
//	LoginButton.SetBool("disabled", bDisableComponents);
//	PlayOfflineButton.SetBool("disabled", bDisableComponents);
//	UsernameBox.SetBool("disabled", bDisableComponents);
//	PasswordBox.SetBool("disabled", bDisableComponents);
//	OK_Button.SetBool("disabled", !bDisableComponents);
//}

//function OnEnterKeyPress()
//{
//	if(	blnShowingDialog)
//	{
//		ToggleLoginMessage(false);
//	}
//	else
//	{
//		DoLogin();
//	}
//}

//DefaultProperties
//{
//	SubWidgetBindings.Add((WidgetName="LoginButton",WidgetClass=class'GFxClikWidget'))
//	SubWidgetBindings.Add((WidgetName="PlayOfflineButton",WidgetClass=class'GFxClikWidget'))
//	SubWidgetBindings.Add((WidgetName="UsernameBox",WidgetClass=class'GFxClikWidget'))
//	SubWidgetBindings.Add((WidgetName="PasswordBox",WidgetClass=class'GFxClikWidget'))
//	SubWidgetBindings.Add((WidgetName="OK_Button",WidgetClass=class'GFxClikWidget'))
//}
