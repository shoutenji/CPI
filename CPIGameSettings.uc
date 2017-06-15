class CPIGameSettings extends UDKGameSettingsCommon;

`include(CPIGameSettingsConstants.uci)

/** The UID of the steam game server, for use with steam sockets */
var databinding string SteamServerId;

/**
 * Builds a URL string out of the properties/contexts and databindings of this object.
 */
function BuildURL(out string OutURL) {
	local int SettingIdx;
	local name PropertyName;

	// Append properties marked with the databinding keyword to the URL
	AppendDataBindingsToURL(OutURL);

	// add all properties
	for (SettingIdx = 0; SettingIdx < Properties.length; SettingIdx++) {
		PropertyName = GetPropertyName(Properties[SettingIdx].PropertyId);
		if (PropertyName != '') {
			switch(Properties[SettingIdx].PropertyId) {
				default:
						OutURL $= "?" $ PropertyName $ "=" $ GetPropertyAsString(Properties[SettingIdx].PropertyId);
					break;
			}
		}
	}
}

/**
 * Updates the game settings object from parameters passed on the URL
 *
 * @param URL the URL to parse for settings
 */
function UpdateFromURL(const out string URL, GameInfo Game)
{	
	local string ValueToCheck;

	setMapName(Game.WorldInfo.GetMapName());
	super.UpdateFromURL(URL,Game);

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "RoundDurationInMinutes");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_ROUNDDURATIONINMINUTES, Criticalpointgame(Game).RoundDurationInMinutes);
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "TimeLimit");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_TIMELIMT, Criticalpointgame(Game).TimeLimit);
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "RoundStartDelay");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_ROUNDSTARTDELAY, Criticalpointgame(Game).RoundStartDelay);
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "NumBots");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_NUMBEROFBOTS, Criticalpointgame(Game).NumBots);
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "FFPercentage");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_FRIENDLYFIREPERCENTAGE, Criticalpointgame(Game).FriendlyFirePercentage);
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "bIsFFenabled");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_ISGRENADEFRIENDLYFIREENABLED, int(Criticalpointgame(Game).bFFenabled));
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "bNadeFFenabled");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_ISGRENADEFRIENDLYFIREENABLED, int(Criticalpointgame(Game).bNadeFFenabled));
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "bTeamsAreForced");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_ARETEAMSFORCED, int(Criticalpointgame(Game).bForceTeams));
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "bBehindViewAllowed");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_ISBEHINDVIEWALLOWED,int( Criticalpointgame(Game).bAllowBehindView));
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "SpectatorMode");
	if ( ValueToCheck == "" )
	{
		SetIntProperty(PROPERTY_WHATISTHESPECTATORMODE, Criticalpointgame(Game).Spectating);
	}

	ValueToCheck = class'GameInfo'.static.ParseOption(URL, "GamePassword");

	if ( ValueToCheck != "" )
	{
		SetIntProperty(PROPERTY_ISTHEGAMEPASSWORDED, 1);
	}
	else
	{
		SetIntProperty(PROPERTY_ISTHEGAMEPASSWORDED, 0);
	}
}

function setServerName(string serverName) 
{
	SetStringProperty(PROPERTY_MYSERVERNAME, serverName);
}

function string getServerName() 
{
	return GetPropertyAsString(PROPERTY_MYSERVERNAME);
}

function setMapName(string mapName) 
{
	SetStringProperty(PROPERTY_MAPNAME, mapName);
}

function string getMapName() 
{
	return GetPropertyAsString(PROPERTY_MAPNAME); 
}

function string getRoundDurationInMinutes()
{
	return GetPropertyAsString(PROPERTY_ROUNDDURATIONINMINUTES);
}

function string getTimeLimit()
{
	return GetPropertyAsString(PROPERTY_TIMELIMT);
}

function string getRoundStartDelayTime()
{
	return GetPropertyAsString(PROPERTY_ROUNDSTARTDELAY);
}

function string getNumberOfBots()
{
	return GetPropertyAsString(PROPERTY_NUMBEROFBOTS);
}

function string getFFPercentage()
{
	return GetPropertyAsString(PROPERTY_FRIENDLYFIREPERCENTAGE);
}

function string getFFEnabled()
{
	return GetPropertyAsString(PROPERTY_ISFRIENDLYFIREENABLED);
}

function string getNadeFFEnabled()
{
	return GetPropertyAsString(PROPERTY_ISGRENADEFRIENDLYFIREENABLED);
}

function string getAreTeamsForced()
{
	return GetPropertyAsString(PROPERTY_ARETEAMSFORCED);
}

function string getIsBehindViewAllowed()
{
	return GetPropertyAsString(PROPERTY_ISBEHINDVIEWALLOWED);
}

function string getSpectatorMode()
{
	return GetPropertyAsString(PROPERTY_WHATISTHESPECTATORMODE);
}

function string getIsGamePassworded()
{
	return GetPropertyAsString(PROPERTY_ISTHEGAMEPASSWORDED);
}

function setServerPlayerInfo(string serverPlayerInfo, int index) 
{
	switch(index)
	{
	case 0:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO0, serverPlayerInfo);
		break;
	case 1:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO1, serverPlayerInfo);
		break;
	case 2:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO2, serverPlayerInfo);
		break;
	case 3:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO3, serverPlayerInfo);
		break;
	case 4:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO4, serverPlayerInfo);
		break;
	case 5:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO5, serverPlayerInfo);
		break;
	case 6:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO6, serverPlayerInfo);
		break;
	case 7:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO7, serverPlayerInfo);
		break;
	case 8:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO8, serverPlayerInfo);
		break;
	case 9:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO9, serverPlayerInfo);
		break;
	case 10:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO10, serverPlayerInfo);
		break;
	case 11:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO11, serverPlayerInfo);
		break;
	case 12:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO12, serverPlayerInfo);
		break;
	case 13:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO13, serverPlayerInfo);
		break;
	case 14:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO14, serverPlayerInfo);
		break;
	case 15:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO15, serverPlayerInfo);
		break;
	case 16:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO16, serverPlayerInfo);
		break;
	case 17:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO17, serverPlayerInfo);
		break;
	case 18:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO18, serverPlayerInfo);
		break;
	case 19:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO19, serverPlayerInfo);
		break;
	case 20:
		SetStringProperty(PROPERTY_SERVERPLAYERINFO20, serverPlayerInfo);
		break;
	}	
}

function string getServerPlayerInfo(int index) 
{
	switch(index)
	{
	case 0:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO0); 
		break;
	case 1:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO1); 
		break;
	case 2:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO2); 
		break;
	case 3:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO3); 
		break;
	case 4:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO4); 
		break;
	case 5:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO5); 
		break;
	case 6:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO6); 
		break;
	case 7:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO7); 
		break;
	case 8:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO8); 
		break;
	case 9:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO9); 
		break;
	case 10:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO10); 
		break;
	case 11:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO11); 
		break;
	case 12:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO12); 
		break;
	case 13:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO13); 
		break;
	case 14:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO14); 
		break;
	case 15:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO15); 
		break;
	case 16:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO16); 
		break;
	case 17:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO17); 
		break;
	case 18:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO18); 
		break;
	case 19:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO19); 
		break;
	case 20:
		return GetPropertyAsString(PROPERTY_SERVERPLAYERINFO20); 
		break;
	default:
		`Log("index " $ index $ " Failed to return any information getServerPlayerInfo");
		return "";
		break;
	}	
}

DefaultProperties
{
	// Properties and their mappings
	Properties(0)=(PropertyId=PROPERTY_MYSERVERNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(0)=(Id=PROPERTY_MYSERVERNAME,Name="ServerName")
	Properties(1)=(PropertyId=PROPERTY_MAPNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(1)=(Id=PROPERTY_MAPNAME,Name="MapName")	
	Properties(2)=(PropertyId=PROPERTY_SERVERPLAYERINFO0,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(2)=(Id=PROPERTY_SERVERPLAYERINFO0,Name="ServerPlayerInfo0")	
	Properties(3)=(PropertyId=PROPERTY_SERVERPLAYERINFO1,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(3)=(Id=PROPERTY_SERVERPLAYERINFO1,Name="ServerPlayerInfo1")	
	Properties(4)=(PropertyId=PROPERTY_SERVERPLAYERINFO2,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(4)=(Id=PROPERTY_SERVERPLAYERINFO2,Name="ServerPlayerInfo2")	
	Properties(5)=(PropertyId=PROPERTY_SERVERPLAYERINFO3,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(5)=(Id=PROPERTY_SERVERPLAYERINFO3,Name="ServerPlayerInfo3")
	Properties(6)=(PropertyId=PROPERTY_SERVERPLAYERINFO4,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(6)=(Id=PROPERTY_SERVERPLAYERINFO4,Name="ServerPlayerInfo4")	
	Properties(7)=(PropertyId=PROPERTY_SERVERPLAYERINFO5,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(7)=(Id=PROPERTY_SERVERPLAYERINFO5,Name="ServerPlayerInfo5")	
	Properties(8)=(PropertyId=PROPERTY_SERVERPLAYERINFO6,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(8)=(Id=PROPERTY_SERVERPLAYERINFO6,Name="ServerPlayerInfo6")	
	Properties(9)=(PropertyId=PROPERTY_SERVERPLAYERINFO7,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(9)=(Id=PROPERTY_SERVERPLAYERINFO7,Name="ServerPlayerInfo7")	
	Properties(10)=(PropertyId=PROPERTY_SERVERPLAYERINFO8,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(10)=(Id=PROPERTY_SERVERPLAYERINFO8,Name="ServerPlayerInfo8")	
	Properties(11)=(PropertyId=PROPERTY_SERVERPLAYERINFO9,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(11)=(Id=PROPERTY_SERVERPLAYERINFO9,Name="ServerPlayerInfo9")	
	Properties(12)=(PropertyId=PROPERTY_SERVERPLAYERINFO10,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(12)=(Id=PROPERTY_SERVERPLAYERINFO10,Name="ServerPlayerInfo10")	
	Properties(13)=(PropertyId=PROPERTY_SERVERPLAYERINFO11,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(13)=(Id=PROPERTY_SERVERPLAYERINFO11,Name="ServerPlayerInfo11")	
	Properties(14)=(PropertyId=PROPERTY_SERVERPLAYERINFO12,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(14)=(Id=PROPERTY_SERVERPLAYERINFO12,Name="ServerPlayerInfo12")	
	Properties(15)=(PropertyId=PROPERTY_SERVERPLAYERINFO13,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(15)=(Id=PROPERTY_SERVERPLAYERINFO13,Name="ServerPlayerInfo13")	
	Properties(16)=(PropertyId=PROPERTY_SERVERPLAYERINFO14,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(16)=(Id=PROPERTY_SERVERPLAYERINFO14,Name="ServerPlayerInfo14")
	Properties(17)=(PropertyId=PROPERTY_SERVERPLAYERINFO15,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(17)=(Id=PROPERTY_SERVERPLAYERINFO15,Name="ServerPlayerInfo15")	
	Properties(18)=(PropertyId=PROPERTY_SERVERPLAYERINFO16,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(18)=(Id=PROPERTY_SERVERPLAYERINFO16,Name="ServerPlayerInfo16")	
	Properties(19)=(PropertyId=PROPERTY_SERVERPLAYERINFO17,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(19)=(Id=PROPERTY_SERVERPLAYERINFO17,Name="ServerPlayerInfo17")	
	Properties(20)=(PropertyId=PROPERTY_SERVERPLAYERINFO18,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(20)=(Id=PROPERTY_SERVERPLAYERINFO18,Name="ServerPlayerInfo18")	
	Properties(21)=(PropertyId=PROPERTY_SERVERPLAYERINFO19,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(21)=(Id=PROPERTY_SERVERPLAYERINFO19,Name="ServerPlayerInfo19")	
	Properties(22)=(PropertyId=PROPERTY_SERVERPLAYERINFO20,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(22)=(Id=PROPERTY_SERVERPLAYERINFO20,Name="ServerPlayerInfo20")	

	Properties(66)=(PropertyId=PROPERTY_ROUNDDURATIONINMINUTES,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(66)=(Id=PROPERTY_ROUNDDURATIONINMINUTES,Name="RoundDurationInMinutes")	
	Properties(67)=(PropertyId=PROPERTY_TIMELIMT,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(67)=(Id=PROPERTY_TIMELIMT,Name="TimeLimit")	
	Properties(68)=(PropertyId=PROPERTY_ROUNDSTARTDELAY,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(68)=(Id=PROPERTY_ROUNDSTARTDELAY,Name="RoundStartDelay")	
	Properties(69)=(PropertyId=PROPERTY_NUMBEROFBOTS,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(69)=(Id=PROPERTY_NUMBEROFBOTS,Name="NumBots")	
	Properties(70)=(PropertyId=PROPERTY_FRIENDLYFIREPERCENTAGE,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(70)=(Id=PROPERTY_FRIENDLYFIREPERCENTAGE,Name="FFPercentage")	
	Properties(71)=(PropertyId=PROPERTY_ISFRIENDLYFIREENABLED,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(71)=(Id=PROPERTY_ISFRIENDLYFIREENABLED,Name="bIsFFenabled")	
	Properties(72)=(PropertyId=PROPERTY_ISGRENADEFRIENDLYFIREENABLED,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(72)=(Id=PROPERTY_ISGRENADEFRIENDLYFIREENABLED,Name="bNadeFFenabled")	
	Properties(73)=(PropertyId=PROPERTY_ARETEAMSFORCED,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(73)=(Id=PROPERTY_ARETEAMSFORCED,Name="bTeamsAreForced")	
	Properties(74)=(PropertyId=PROPERTY_ISBEHINDVIEWALLOWED,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(74)=(Id=PROPERTY_ISBEHINDVIEWALLOWED,Name="bBehindViewAllowed")	
	Properties(75)=(PropertyId=PROPERTY_WHATISTHESPECTATORMODE,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(75)=(Id=PROPERTY_WHATISTHESPECTATORMODE,Name="SpectatorMode")	
	Properties(76)=(PropertyId=PROPERTY_ISTHEGAMEPASSWORDED,Data=(Type=SDT_Int32),AdvertisementType=ODAT_QoS)
	PropertyMappings(76)=(Id=PROPERTY_ISTHEGAMEPASSWORDED,Name="IsGamePassworded")	

	NumPublicConnections=16
}