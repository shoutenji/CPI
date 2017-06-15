class CPI_FrontEnd_DialogBoxPrompt extends CPIFrontEnd_Screen 
    config(UI);

var GFxClikWidget DialogBoxBtn;
var GFxObject DialogBoxTitle, DialogBoxMsg;

function SetTitle(string strTitle)
{
	DialogBoxTitle.SetText(strTitle);   
}

function SetBody(string strBody)
{
	DialogBoxMsg.SetText(strBody);   
}

function Select_Button(GFxClikWidget.EventData ev)
{
	CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.RemoveAllMessages();
	MoveBackImpl();
}

function OnEscapeKeyPress()
{
	CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.RemoveAllMessages();
	super.OnEscapeKeyPress();
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled=false;

	switch(WidgetName)
	{
		case ('DialogBoxMsg'):
			DialogBoxMsg=Widget;
			bWasHandled=true; 
		break;	
		case ('DialogBoxTitle'):
			DialogBoxTitle=Widget;
			bWasHandled=true; 
		break;	
		case ('DialogBoxBtn'):
			DialogBoxBtn=GFxClikWidget(Widget);
			DialogBoxBtn.SetString("label","Cancel");
			DialogBoxBtn.AddEventListener('CLIK_press',Select_Button);
			bWasHandled=true; 
		break;	
		case ('DialogBoxBG'):
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
			`log( "CPI_FrontEnd_DialogBoxPrompt::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}
	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="DialogBoxBtn",WidgetClass=class'GFxClikWidget'))
}

