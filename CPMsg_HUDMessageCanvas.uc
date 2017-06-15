class CPMsg_HUDMessageCanvas extends CPLocalMessage;

var localized string Message[12];

static function string GetString(
	optional int SwitchNum,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local Class<CPDamageType> DT;

	// Suicide or something along those lines
	DT = Class<CPDamageType>(OptionalObject);
	switch ( SwitchNum )
	{
	case 10:
		if ( ((RelatedPRI_1 != none) && (RelatedPRI_1 == RelatedPRI_2)) || OptionalObject == class'DmgType_Suicided')
			return RelatedPRI_2.PlayerName @ (DT==none ? " commited suicide." : DT.default.deathAction @ (CPPlayerReplicationInfo(RelatedPRI_2).bIsFemale ? "herself" : "himself" ) @ DT.default.deathObject);
		else if( OptionalObject == class'DmgType_Fell' )
			return RelatedPRI_2.PlayerName @ "fell to his death";
		else if( OptionalObject == class'DmgType_Crushed' )
			return RelatedPRI_2.PlayerName @ "was crushed";
		else if( OptionalObject == class'DmgType_Telefragged' )
			return RelatedPRI_2.PlayerName @ "was telefragged";
		else if( OptionalObject == class'KillZDamageType' ) // Rogue. I am assuming this only happens on falling outside of the zone??
			return RelatedPRI_2.PlayerName @ "fell to his death";
		else if( OptionalObject != none )
		{
			`Log("debug for CPMsg_HUDMessageCanvas accessed none DT=" @DT);
			return RelatedPRI_2.PlayerName @ "died by a" $ (DT==none ? "n unknown object" : " " $ DT.default.DamageWeaponClass.default.ItemName);
		}
		else
			return RelatedPRI_2.PlayerName @ "died";

		break;
	case 11:
		if(RelatedPRI_1 != none && RelatedPRI_2 != none)
		{
			if ( RelatedPRI_1.Team.TeamIndex == RelatedPRI_2.Team.TeamIndex )
				return RelatedPRI_1.PlayerName @ "teamkilled" @ RelatedPRI_2.PlayerName;
			else if ( OptionalObject != none )
				return RelatedPRI_1.PlayerName @ (DT==none ? "??" : DT.default.deathAction) @  RelatedPRI_2.PlayerName @ (DT==none ? "??" : DT.default.deathObject);
		}

		break;
	}

	return "";
}

defaultproperties
{
    bIsSpecial=false
    bIsUnique=false
	bBeep=false
	DrawColor=(R=255,G=255,B=255,A=255)
	FontSize=3
	MessageArea=8
	Lifetime=5
}
