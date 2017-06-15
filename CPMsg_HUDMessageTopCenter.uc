class CPMsg_HUDMessageTopCenter extends CPLocalMessage;

var localized string Message[41];
var SoundNodeWave AnnouncerSounds[41];

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	if ((Switch>0) && (default.AnnouncerSounds[Switch]!=none || Switch == 6) && !class'Engine'.static.IsSplitScreen())
	{
		switch(Switch)
		{
			case 6:
				if(RelatedPRI_1.Team.TeamIndex == 1)
				{
					//SF WIN
					CPPlayerController(P).PlayTAAnnouncement(default.class,37);
				}
				else
				{
					//MERC WIN
					CPPlayerController(P).PlayTAAnnouncement(default.class,36);
				}
				break;
			case 7: // Admin Restart Map
			case 8: // Server Change Map
			    if(switch == 7)
			    {
					`log("CPMsg_HUDMessageTopCenter.ClientReceive should sound Admin Restart Map=" @ Switch);
			    }
				else
				{
			        `log("CPMsg_HUDMessageTopCenter.ClientReceive should sound Server Change Map=" @ Switch);
				}			
				break;
			case 20: // Mercenaries have escaped.
				`log("CPMsg_HUDMessageTopCenter.ClientReceive should sound Mercenaries have escaped=" @ Switch);
				break;
			default:
				CPPlayerController(P).PlayTAAnnouncement(default.class,Switch);
				return;
		}

	}
}

static function string GetString(
	optional int SwitchNum,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{

	switch(SwitchNum)
	{
	case 2:
	case 3:
		if (CPGameReplicationInfo(OptionalObject)!=none)
			return default.Message[SwitchNum]@CPGameReplicationInfo(OptionalObject).RoundTimeBuffer@"...";
		break;
	case 5:
		if (OptionalObject!=none)
			return default.Message[SwitchNum]@StringHolder(OptionalObject).str@"...";
		else
			return default.Message[12];
		break;
	case 6:
		if (OptionalObject!=none)
			return default.Message[SwitchNum]@StringHolder(OptionalObject).str@default.Message[7]@RelatedPRI_1.Team.GetHumanReadableName();
		break;
	default:
		return default.Message[SwitchNum];
	}

	return default.Message[SwitchNum];
}

static function SoundNodeWave AnnouncementSound(int MessageIndex,Object OptionalObject,PlayerController PC)
{
	local int randnum;
	if (MessageIndex == 4)
	{
		randnum = RandRange(4,12);


		if(default.AnnouncerSounds[randnum] != none)
			return default.AnnouncerSounds[randnum];
	}
	else if (MessageIndex>0)
	{
		if(default.AnnouncerSounds[MessageIndex] != none)
			return default.AnnouncerSounds[MessageIndex];
	}
	return none;
}

defaultproperties
{
    bIsSpecial=true
    bIsUnique=false
	bBeep=false
	DrawColor=(R=255,G=255,B=255,A=255)
	FontSize=3
	MessageArea=1
	Lifetime=10
	bIsConsoleMessage=true

	AnnouncerSounds(1)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_FinalRound'
	AnnouncerSounds(2)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_Standby'
	AnnouncerSounds(3)=SoundNodeWave'GFxTAFrontEnd.Sounds.TA_UI_SimpleBeep'
	AnnouncerSounds(4)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_beginMission'
	AnnouncerSounds(5)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_Commence'
	AnnouncerSounds(6)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_LetsGetItOn'
	AnnouncerSounds(7)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_GoForIt'
	AnnouncerSounds(8)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_GoGetm'
	AnnouncerSounds(9)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_KickAss'
	AnnouncerSounds(10)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_LetsDoThing'
	AnnouncerSounds(11)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_GoGoGo'
	AnnouncerSounds(12)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_S_LetsGo'
	AnnouncerSounds(13)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_30Seconds'
	AnnouncerSounds(14)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_1Minute'
	AnnouncerSounds(15)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_30Seconds'
	AnnouncerSounds(16)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_2Minute'
	AnnouncerSounds(17)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_HostagesSecured'
	AnnouncerSounds(18)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_ObjBreach'
	AnnouncerSounds(19)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_lastStanding'


	AnnouncerSounds(32)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_MercWin'
	AnnouncerSounds(33)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_SFWin'

	AnnouncerSounds(36)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_MercWin'
	AnnouncerSounds(37)=SoundNodeWave'CP_Announcer.Status.CP_LM_announcer_SFWin'
	AnnouncementPriority=18
}
