class CPUIDataProvider_MapInfo extends UDKUIDataProvider_MapInfo
	PerObjectConfig;

event bool ShouldBeFiltered()
{
	return !SupportedByCurrentGameMode();
}

function bool SupportedByCurrentGameMode()
{
local int Pos,i;
local string ThisMapPrefix,GameModePrefixes;
local array<string> PrefixList;
local bool bResult;

	bResult=true;
	Pos=InStr(MapName,"-");
	ThisMapPrefix=left(MapName,Pos);
	if (ThisMapPrefix=="")
		ThisMapPrefix="CP";
	if (GetDataStoreStringValue("<Registry:SelectedGameModePrefix>",GameModePrefixes) && GameModePrefixes!="")
	{
		bResult=false;
		ParseStringIntoArray(GameModePrefixes,PrefixList,"|",true);
		for (i=0;i<PrefixList.length;i++)
		{
			bResult=(ThisMapPrefix~=PrefixList[i]);
			if (bResult)
				break;
		}
	}
	return bResult;
}

/**
 * Gets the string value of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to retrieve the value of.
 * @param OutStringValue		Variable to store the result string in.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was retrieved, FALSE otherwise.
 */
static function bool GetDataStoreStringValue(string InDataStoreMarkup, out string OutStringValue, optional LocalPlayer OwnerPlayer=none)
{
	//TODO FIX THIS TOP PROTO 2012 merge error.
	//local UIProviderFieldValue FieldValue;
	local bool Result;

	//if(GetDataStoreFieldValue(InDataStoreMarkup, FieldValue, OwnerPlayer))
	//{
	//	OutStringValue = FieldValue.StringValue;
		Result = TRUE;
	//}

	return Result;
}

defaultproperties
{
}
