class CPMsg_Team extends CPLocalMessage;

var localized string RequestTeamSwapPrefix;
var localized string RequestTeamSwapPostfix;
var localized string YouAreOnRedMessage;
var localized string YouAreOnBlueMessage;
var color RedDrawColor;
var color BlueDrawColor;
var SoundNodeWave AnnouncerSounds[2];

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	if ((Switch>0) && (default.AnnouncerSounds[Switch-1]!=none) && !class'Engine'.static.IsSplitScreen())
		CPPlayerController(P).PlayTAAnnouncement(default.class,Switch);
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			return Default.RequestTeamSwapPrefix@RelatedPRI_1.PlayerName@Default.RequestTeamSwapPostfix;
			break;
		case 1:
			return Default.YouAreOnRedMessage;
			break;
		case 2:
			return Default.YouAreOnBlueMessage;
			break;
	}
	return "";
}

static function SoundNodeWave AnnouncementSound(int MessageIndex,Object OptionalObject,PlayerController PC)
{
	if (MessageIndex>0)
		return default.AnnouncerSounds[MessageIndex-1];
	return none;
}

static function int GetFontSize(int Switch,PlayerReplicationInfo RelatedPRI1,PlayerReplicationInfo RelatedPRI2,PlayerReplicationInfo LocalPlayer)
{
	if (Switch>0)
		return 2;
    return default.FontSize;
}

static function float GetPos(int Switch,HUD myHUD)
{
	if (CPHUD(myHUD)==none)
		return 0.5;
	if (Switch>0)
		return CPHUD(myHUD).MessageOffset[Default.MessageArea];
	return CPHUD(myHUD).MessageOffset[4];
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 1:
			return default.RedDrawColor;
			break;
		case 2:
			return default.BlueDrawColor;
			break;
	}
	return Default.DrawColor;
}

defaultproperties
{
	bIsConsoleMessage=true
	RedDrawColor=(R=255,G=32,B=10,A=255)
	BlueDrawColor=(R=10,G=32,B=255,A=255)
	MessageArea=2
	AnnouncementPriority=19
}
