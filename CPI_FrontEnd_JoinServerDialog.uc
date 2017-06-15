class CPI_FrontEnd_JoinServerDialog extends CPIFrontEnd_Screen 
    config(UI);

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled=false;

	switch(WidgetName)
	{
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
		//	`log( "CPI_FrontEnd_JoinServerDialog::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}
	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

DefaultProperties
{
}
