class CPIFrontEnd_Screen extends CPIFrontEnd_View
    config(UI);

var array<GFxObject> myObjects;
var array<GFxClikWidget> myClikObjects;
var CONST ASColorTransform DISABLED, NORMAL;

function DisableSubComponents(bool bDisableComponents)
{
	local int i;
	for(i = 0 ; i < myObjects.Length ; i++)
	{
		if(bDisableComponents)
		{
			myObjects[i].SetColorTransform( DISABLED );
		}
		else
		{
			myObjects[i].SetColorTransform( NORMAL );
		}
		myObjects[i].SetBool("disabled", bDisableComponents);
	}

	for(i = 0 ; i < myClikObjects.Length ; i++)
	{
		if(bDisableComponents)
		{
			myClikObjects[i].SetColorTransform( DISABLED );
		}
		else
		{
			myClikObjects[i].SetColorTransform( NORMAL );
		}
		myClikObjects[i].SetBool("disabled", bDisableComponents);
	}
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget) 
{	
		if(GFxClikWidget(Widget) != none)
		{
			myClikObjects.AddItem(GFxClikWidget(Widget));
		}
		else
		{
			myObjects.AddItem(Widget);
		}

    return false;
}

defaultproperties
{
	DISABLED=(multiply=(R=0,G=0,B=0,A=0.0))
	NORMAL=(multiply=(R=1.0,G=1.0,B=1.0,A=1.0))
}