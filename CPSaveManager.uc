class CPSaveManager extends Object
	config(CPGameSettings);

struct ConfigItem
{
	var string ItemName;
	var string ItemValue;
};

var config array<ConfigItem> ConfigItems;
var array<ConfigItem> DefaultConfigItems;

function bool IsItem(coerce string strPropertyName)
{
local ConfigItem localConfigItem;

	if (strPropertyName=="")
	{
		`warn("IsItem with no property name");
		return false;
	}
	foreach ConfigItems(localConfigItem)
	{
		if(localConfigItem.ItemName==strPropertyName)
			return true;
	}
	return false;
}

function string GetItem(coerce string strPropertyName)
{
local int index;
local ConfigItem localConfigItem;

	if (strPropertyName=="")
	{
		`warn("GetItem with no property name");
		return "";
	}
	if (!IsItem(strPropertyName))
	{
		foreach DefaultConfigItems(localConfigItem)
		{
			if(localConfigItem.ItemName==strPropertyName)
			{
				AddItem(strPropertyName,localConfigItem.ItemValue);
				return localConfigItem.ItemValue;
			}
		}
		`warn("GetItem item "$strPropertyName$" doesn't exist and doesn't have a default value");
		return "";
	}
	index=ConfigItems.Find('ItemName',strPropertyName);
	return ConfigItems[index].ItemValue;
}

function bool GetBool(string strPropertyName)
{
	return bool(GetItem(strPropertyName));
}

function int GetInt(string strPropertyName)
{
	return int(GetItem(strPropertyName));
}

function float GetFloat(string strPropertyName)
{
	return float(GetItem(strPropertyName));
}

function bool SetItem(coerce string strPropertyName,coerce string strPropertyValue)
{
local int index;

	if (strPropertyName=="")
	{
		`warn("SetItem with no property name");
		return false;
	}
	if (!IsItem(strPropertyName))
		return AddItem(strPropertyName,strPropertyValue);

	index=ConfigItems.Find('ItemName',strPropertyName);
	ConfigItems[index].ItemValue=strPropertyValue;
	SaveConfig();
	return true;
}

function bool SetBool(string strPropertyName,bool boolPropertyValue)
{
	return SetItem(strPropertyName,string(boolPropertyValue));
}

function bool SetInt(string strPropertyName,int intPropertyValue)
{
	return SetItem(strPropertyName,string(intPropertyValue));
}

function bool SetFloat(string strPropertyName,float floatPropertyValue)
{
	return SetItem(strPropertyName,string(floatPropertyValue));
}

function bool AddItem(coerce string strPropertyName,coerce string strPropertyValue)
{
local ConfigItem localItem;

	if (strPropertyName=="")
	{
		`warn("AddItem with no property name");
		return false;
	}
	if (IsItem(strPropertyName))
	{
		`warn("AddItem trying to add an item that already exist "$strPropertyName);
		return false;
	}
	localItem.ItemName=strPropertyName;
	localItem.ItemValue=strPropertyValue;
	ConfigItems.AddItem(localItem);
	SaveConfig();
	return true;
}

function bool RemoveItem(coerce string strPropertyName)
{
local int index;

	if (strPropertyName=="")
	{
		`warn("RemoveItem with no property name");
		return false;
	}
	if(!IsItem(strPropertyName))
	{
		`warn("RemoveItem trying to remove an item that doesn't exist "$strPropertyName);
		return false;
	}

	for (index=0;index<ConfigItems.Length;index++)
	{
		if (ConfigItems[index].ItemName==strPropertyName)
		{
			ConfigItems.Remove(index,1);
			SaveConfig();
			break;
		}
	}
	return true;
}

simulated function ResetToDefaults()
{
local ConfigItem localConfigItem;

	ConfigItems.Remove(0,ConfigItems.Length);
	foreach DefaultConfigItems(localConfigItem)
		ConfigItems.AddItem(localConfigItem);
	SaveConfig();
}

DefaultProperties
{
	DefaultConfigItems(0)=(ItemName="ClanTag",ItemValue="")

	// GFxCPFrontEnd_MouseSettings_Dialog Settings
	DefaultConfigItems(1)=(ItemName="MouseSmoothing",ItemValue="true")
	DefaultConfigItems(2)=(ItemName="MouseSensitivity",ItemValue="38")

	// GFxCPFrontEnd_GraphicSettings_Dialog Settings
	DefaultConfigItems(3)=(ItemName="Fullscreen",ItemValue="false")
	DefaultConfigItems(4)=(ItemName="PhysicsEnabled",ItemValue="false")
	DefaultConfigItems(5)=(ItemName="Gamma",ItemValue="2.2")
	DefaultConfigItems(6)=(ItemName="SelectedResolution",ItemValue="1280x1024")
	DefaultConfigItems(7)=(ItemName="MasterVolume",ItemValue="7.0")
	DefaultConfigItems(8)=(ItemName="EffectsVolume",ItemValue="7.0")
	DefaultConfigItems(9)=(ItemName="MusicVolume",ItemValue="7.0")
	DefaultConfigItems(10)=(ItemName="VoiceVolume",ItemValue="7.0")	

	// Weapon system settings
	DefaultConfigItems(11)=(ItemName="AutoReloadWeapon",ItemValue="false")
	DefaultConfigItems(12)=(ItemName="AutoSwitchOnPickup",ItemValue="true")
	DefaultConfigItems(13)=(ItemName="WeaponAutoSwitchMode",ItemValue="0")

	// GFxCPPlayerInfo Settings
	DefaultConfigItems(14)=(ItemName="DrawPlayerInfo",ItemValue="true")
	
	// GFxCPFrontEnd_HUDDialog
	DefaultConfigItems(15)=(ItemName="HUDScale",ItemValue="100.0")
	DefaultConfigItems(16)=(ItemName="PreferredCrosshair",ItemValue="1")
	DefaultConfigItems(17)=(ItemName="CrosshairSize",ItemValue="0.700")
	DefaultConfigItems(18)=(ItemName="CrosshairRed",ItemValue="255")
	DefaultConfigItems(19)=(ItemName="CrosshairGreen",ItemValue="255")
	DefaultConfigItems(20)=(ItemName="CrosshairBlue",ItemValue="255")
	DefaultConfigItems(21)=(ItemName="CrosshairAlpha",ItemValue="255")
	DefaultConfigItems(22)=(ItemName="ShowHitLocation",ItemValue="true")
	DefaultConfigItems(23)=(ItemName="ShowWeaponIcon",ItemValue="true")
	DefaultConfigItems(24)=(ItemName="ShowHUD",ItemValue="true")
	DefaultConfigItems(25)=(ItemName="ShowObjectiveInfo",ItemValue="true")
	DefaultConfigItems(26)=(ItemName="GoreLevel",ItemValue="2")
	DefaultConfigItems(27)=(ItemName="HitDirectional",ItemValue="1")
	DefaultConfigItems(28)=(ItemName="Spectator",ItemValue="false")
	DefaultConfigItems(29)=(ItemName="ShowFPS",ItemValue="false")
	DefaultConfigItems(30)=(ItemName="ShowTime",ItemValue="true")
	DefaultConfigItems(31)=(ItemName="ShowChat",ItemValue="true")

	// More video/audio settings
	DefaultConfigItems(32)=(ItemName="bVSync",ItemValue="false")
	DefaultConfigItems(33)=(ItemName="bBloom",ItemValue="false")
	DefaultConfigItems(34)=(ItemName="bMotionBlur",ItemValue="false")
	DefaultConfigItems(35)=(ItemName="bDynamicLights",ItemValue="true")
	DefaultConfigItems(36)=(ItemName="bDynamicShadows",ItemValue="true")
	DefaultConfigItems(37)=(ItemName="bAmbientOcclusion",ItemValue="false")
	DefaultConfigItems(38)=(ItemName="bDecals",ItemValue="true")
	DefaultConfigItems(39)=(ItemName="HideCrosshair",ItemValue="false")
	DefaultConfigItems(40)=(ItemName="LevelOfDetail",ItemValue="4")
	DefaultConfigItems(41)=(ItemName="PlayerName",ItemValue="Player")
	DefaultConfigItems(42)=(ItemName="AntiAlias",ItemValue="2")
	DefaultConfigItems(43)=(ItemName="Anistropy",ItemValue="0")
	DefaultConfigItems(44)=(ItemName="Particles",ItemValue="0")
	DefaultConfigItems(45)=(ItemName="MaxChannel",ItemValue="3")
	DefaultConfigItems(46)=(ItemName="WeaponHand",ItemValue="HAND_Right")
}
