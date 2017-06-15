class CPMsg_Victim extends CPLocalMessage;

var(Message) localized string YouWereKilledBy,KilledByTrailer;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
local string VictimString;
local class<CPDamageType> VictimDamageType;
	
	if (RelatedPRI_1==none)
		return "";
	if (RelatedPRI_1.PlayerName!="")
	{
		VictimString=Default.YouWereKilledBy@RelatedPRI_1.PlayerName$Default.KilledByTrailer;
		VictimDamageType=Class<CPDamageType>(OptionalObject);
		if (VictimDamageType!=none)
		{
			if (VictimDamageType.default.DamageWeaponClass!=none)
				VictimString=VictimString$" ("$VictimDamageType.default.DamageWeaponClass.default.Itemname$")";
		}

		return VictimString;
	}
	return "";
}

defaultproperties
{
	bIsUnique=True
	Lifetime=6
	DrawColor=(R=255,G=0,B=0,A=255)
	FontSize=2
	MessageArea=8
}
