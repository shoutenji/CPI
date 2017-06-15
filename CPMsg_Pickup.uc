class CPMsg_Pickup extends CPLocalMessage;

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
local CPHUD myHud;

	super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	myHud=CPHUD(P.MyHUD);
	if (myHud!=none)
	{
		myHud.LastPickupTime=myHud.WorldInfo.TimeSeconds;
		if (class<CPWeapon>(OptionalObject)!=none)
			myHud.LastWeaponBarDrawnTime=myHud.WorldInfo.TimeSeconds+2.0;
	}		
}

defaultproperties
{
	bIsUnique=true
	bCountInstances=true
	DrawColor=(R=255,G=255,B=128,A=255)
	FontSize=1
	bIsConsoleMessage=false
	MessageArea=5
}
