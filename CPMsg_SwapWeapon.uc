class CPMsg_SwapWeapon extends CPLocalMessage;

var localized string SwapToNotifyString;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return default.SwapToNotifyString$class<Inventory>(OptionalObject).default.ItemName;
}

defaultproperties
{
    bIsSpecial=true
    bIsUnique=true
	DrawColor=(R=255,G=255,B=255,A=255)
	FontSize=3
	MessageArea=4
	Lifetime=105.5
}
