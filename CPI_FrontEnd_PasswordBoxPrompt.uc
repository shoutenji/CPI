class CPI_FrontEnd_PasswordBoxPrompt extends CPIFrontEnd_Screen 
    config(UI);

var GFxClikWidget PWAcceptBtn, PWCancelBtn;
var GFxObject PwProtectedTitle, PWprotectedPWbox, PWboxLabel, PWValidationTxt;

function OnEnterKeyPress()
{
	doAccept();
}

function OnViewActivated()
{
	SetTextBoxFocus();
}

function SetTextBoxFocus()
{
	if(PWprotectedPWbox != none )
	{
		PWprotectedPWbox.setBool("focused",true);
	}
}

function Select_Button_Accept(GFxClikWidget.EventData ev)
{
	`Log("Select_Button_Accept");
	doAccept();

}

function doAccept()
{
	CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.RemoveAllMessages();
	`Log("doAccept");
	if(PWprotectedPWbox != none)
	{
		if(Len(PWprotectedPWbox.GetText()) != 0)
		{
			if(CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ServerIP == "")
			{
				`Log("Server ip is blank ASSUMING LOCALHOST");
				CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ServerIP = "127.0.0.1";
			}
			`Log("server ip to connect to is" @ CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ServerIP);
			 CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ConsoleCommand("open " $ CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).ServerIP $ "?password=" $ PWprotectedPWbox.GetText());
			MoveBackImpl();
		}
		else
		{
			PWValidationTxt.SetText("No password entered");
			PWValidationTxt.SetVisible(true);
		}
	}
}
function Select_Button_Cancel(GFxClikWidget.EventData ev)
{
	CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.RemoveAllMessages();
	`Log("Select_Button_Cancel");
	MoveBackImpl();
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled=false;

	switch(WidgetName)
	{
		case ('PasswordBoxWindow'):
			bWasHandled=true; 
		break;	
		case ('PWBoxWindow'):
			bWasHandled=true; 
		break;
		case ('PwProtectedTitle'):
			PwProtectedTitle=Widget;
			PwProtectedTitle.SetString("text","SERVER PASSWORDED");
			bWasHandled=true; 
		break;
		case ('PWValidationTxt'):
			PWValidationTxt=Widget;
			PWValidationTxt.SetVisible(false);
			bWasHandled=true; 
		break;
		case ('PWprotectedPWbox'):
			PWprotectedPWbox=Widget;
			bWasHandled=true; 
		break;
		case ('PWboxLabel'):
			PWboxLabel=Widget;
			PWboxLabel.SetString("text","You need to enter a password to join this game");
			bWasHandled=true; 
		break;
		case ('PWAcceptBtn'):
			PWAcceptBtn=GFxClikWidget(Widget);
			PWAcceptBtn.SetString("label","JOIN");
			PWAcceptBtn.AddEventListener('CLIK_press',Select_Button_Accept);
			bWasHandled=true; 
		break;	
		case ('PWCancelBtn'):
			PWCancelBtn=GFxClikWidget(Widget);
			PWCancelBtn.SetString("label","CANCEL");
			PWCancelBtn.AddEventListener('CLIK_press',Select_Button_Cancel);
			bWasHandled=true; 
		break;	
		case ('PWdialog'):
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
			`log( "CPI_FrontEnd_PasswordBoxPrompt::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}
	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="PWCancelBtn",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PWAcceptBtn",WidgetClass=class'GFxClikWidget'))
}

