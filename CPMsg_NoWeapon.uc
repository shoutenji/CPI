class CPMsg_NoWeapon extends CPLocalMessage;

var localized string NoWeaponGroupString;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return class'CriticalPointGame'.Static.ParseKillMessage(class'CPWeapon'.static.IntWeaponTypeToString(Switch),"",default.NoWeaponGroupString);
}

defaultproperties
{
    bIsSpecial=false
    bIsUnique=false
	bBeep=true
	DrawColor=(R=255,G=255,B=255,A=255)
	FontSize=3
	MessageArea=1
	Lifetime=3
}
