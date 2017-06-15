class CPMsg_Death extends CPLocalMessage
	config(game);

var localized string SomeoneString;
var config bool bNoConsoleDeathMessages;

static function color GetConsoleColor(PlayerReplicationInfo RelatedPRI_1)
{
    return class'HUD'.Default.GreenColor;
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
local string KillerName,VictimName;
local class<CPDamageType> KillDamageType;


	KillDamageType=(Class<CPDamageType>(OptionalObject)!=none) ? Class<CPDamageType>(OptionalObject) : class'CPDamageType';

	if (RelatedPRI_1==none)
		KillerName=Default.SomeoneString;
	else
		KillerName=RelatedPRI_1.PlayerName;

	if (RelatedPRI_2==none)
		VictimName=Default.SomeoneString;
	else
		VictimName=RelatedPRI_2.PlayerName;

	if (Switch==1)
	{
		return class'CriticalPointGame'.Static.ParseKillMessage(
			KillerName,
			VictimName,
			KillDamageType.Static.SuicideMessage(RelatedPRI_2));
	}

	return class'CriticalPointGame'.Static.ParseKillMessage(
		KillerName,
		VictimName,
		KillDamageType.Static.DeathMessage(RelatedPRI_1,RelatedPRI_2));
}

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch==1)
	{
		if (!Default.bNoConsoleDeathMessages)
			Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
		return;
	}
	if ((RelatedPRI_1==P.PlayerReplicationInfo)
		|| ((P.PlayerReplicationInfo!=none) && P.PlayerReplicationInfo.bIsSpectator && (Pawn(P.ViewTarget)!=none) && (Pawn(P.ViewTarget).PlayerReplicationInfo==RelatedPRI_1)))
	{
		if (P.myHud!=none)
			P.myHUD.LocalizedMessage(
				class'CPMsg_Killer',
				RelatedPRI_1,
				RelatedPRI_2,
				class'CPMsg_Killer'.static.GetString(Switch,RelatedPRI_1==P.PlayerReplicationInfo,RelatedPRI_1,RelatedPRI_2,OptionalObject),
				Switch,
				class'CPMsg_Killer'.static.GetPos(Switch, P.myHUD),
				class'CPMsg_Killer'.static.GetLifeTime(Switch),
				class'CPMsg_Killer'.static.GetFontSize(Switch,RelatedPRI_1,RelatedPRI_2,P.PlayerReplicationInfo),
				class'CPMsg_Killer'.static.GetColor(Switch,RelatedPRI_1,RelatedPRI_2),
				OptionalObject);

		//if (!Default.bNoConsoleDeathMessages)
			//Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	}
	else if (RelatedPRI_2==P.PlayerReplicationInfo)
	{
		if (P.myHud!=none)
			P.myHUD.LocalizedMessage(
				class'CPMsg_Victim',
				RelatedPRI_1,
				RelatedPRI_2,
				class'CPMsg_Victim'.static.GetString(Switch,true,RelatedPRI_1,RelatedPRI_2,OptionalObject),
				0,
				class'CPMsg_Victim'.static.GetPos(Switch,P.myHUD),
				class'CPMsg_Victim'.static.GetLifeTime(Switch),
				class'CPMsg_Victim'.static.GetFontSize(Switch,RelatedPRI_1,RelatedPRI_2,P.PlayerReplicationInfo),
				class'CPMsg_Victim'.static.GetColor(Switch,RelatedPRI_1,RelatedPRI_2),
				OptionalObject);
				
		//if (!Default.bNoConsoleDeathMessages)
			//Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	}
	else if (!Default.bNoConsoleDeathMessages)
		Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	
	
}

defaultproperties
{
	MessageArea=8
	DrawColor=(R=255,G=0,B=0,A=255)
	bIsSpecial=false
}
