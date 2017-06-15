class CPI_FrontEnd_ExitGameDialog extends CPIFrontEnd_Screen 
    config(UI);

var GFxClikWidget YesButton, NoButton;
var GFxObject  Message, Title;
var localized string strMessage, strTitle, strYesButton, strNoButton;

function Select_YesButton(GFxClikWidget.EventData ev)
{
	ConsoleCommand("quit");
}

function Select_NoButton(GFxClikWidget.EventData ev)
{
	MoveBackImpl();
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;
	bWasHandled=false;


	switch(WidgetName)
	{		
		case ('YesButton'):
			YesButton=GFxClikWidget(Widget);
			YesButton.SetString("label",strYesButton);
			YesButton.AddEventListener('CLIK_press',Select_YesButton);
			bWasHandled=true; 
		break;
		case ('NoButton'):
			NoButton=GFxClikWidget(Widget);
			NoButton.SetString("label",strNoButton);
			NoButton.AddEventListener('CLIK_press',Select_NoButton);
			bWasHandled=true; 
		break;
		case ('Quote'):
			Message=Widget;
			Message.SetString("text", strMessage);
			bWasHandled=true; 
		break;
		case ('ExitGameTitle'):
			Title=Widget;
			Title.SetString("text", strTitle);
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled) 
		`log( "CPI_FrontEnd_ExitGameDialog::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);

	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}


DefaultProperties
{
		SubWidgetBindings.Add((WidgetName="YesButton",WidgetClass=class'GFxClikWidget'))
		SubWidgetBindings.Add((WidgetName="NoButton",WidgetClass=class'GFxClikWidget'))
}
