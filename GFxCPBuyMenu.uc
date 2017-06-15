class GFxCPBuyMenu extends GFxMoviePlayer;


/** Used to tell the hud when to close this menu */
var bool blnCloseMenu;
/** Used to determine if the right mouse button was pressed on a flash scene */
var bool blnRightMousePressed;

//misc button elements
var	GFxClikWidget	        CancelButton, ResetButton, BuyNowButton;

var CONST ASColorTransform LIGHTGREEN, DARKGREEN, YELLOW, LIGHTRED, BLACK;

//night vision
var	GFxClikWidget	        NightVisionButton;

/**  ClipSection elements */
struct ClipSection
{
	var	GFxClikWidget           AddClip, RemoveClip, ClipValue, ClipCost, WeaponCost;
	var class<CPWeapon>         WeaponClass;
	var int                     CurrentClipAmount, NewClipAmount;
};
var ClipSection MeleeClipSection, PistolClipSection, SMGClipSection, RifleClipSection, GrenadeClipSection;

/**  ArmorButton elements */
struct ArmorButton
{
	var	GFxClikWidget           Button;
	var	bool                    ArmorOwned;
	var	GFxObject   	        ArmorButtonText;

	StructDefaultProperties
	{
		ArmorOwned=false
	}
};

//armor elements
var	ArmorButton	        HeadArmorButton, BodyArmorButton, LegArmorButton;
var bool blnArmorToggle;

/**  WeaponButton elements */
struct WeaponButton
{
	var	GFxClikWidget           WeaponButton;
	var class<CPWeapon>         CurrentWeaponClass, NewWeaponClass; //these are used in the buying and selling of weapons. they know what to buy and what to sell.

	var bool    bOwnWeapon;  //do we own this weapon?
    var bool    bOtherTeamWeapon; //flag to mark this weapon as belonging to the opposite team

	StructDefaultProperties
	{
		bOwnWeapon=false
        CurrentWeaponClass=None
        NewWeaponClass=None
        bOtherTeamWeapon=false
	}
};

//MELEE GROUP
var	GFxClikWidget           MeleeAddClip, MeleeRemoveClip;
var GFxClikWidget           MeleeClipValue;
var array<WeaponButton>     MeleeWeaponButton;

//PISTOL GROUP
var	GFxClikWidget           PistolAddClip, PistolRemoveClip;
var GFxClikWidget           PistolClipValue;
var array<WeaponButton>     PistolWeaponButton;

//SMG GROUP
var	GFxClikWidget           SMGAddClip, SMGRemoveClip;
var GFxClikWidget           SMGClipValue;
var array<WeaponButton>     SMGWeaponButton;

//RIFLE GROUP
var	GFxClikWidget           RifleAddClip, RifleRemoveClip;
var GFxClikWidget           RifleClipValue;
var array<WeaponButton>     RifleWeaponButton;

//GRENADE GROUP
var array<WeaponButton>     GrenadeWeaponButton;
var bool blnArmorSelected;

/** Used to fix the mouse ordering. This should keep the mouse cursor on top of all other buy menu elements */
var GFxObject MouseCursor;

var config array<string> SpecialForcesWeapon, MercenariesWeapon;

var bool blnWeaponLoadoutReset;

var int OtherTeamWeaponIndex;

struct WeaponList
{
	var class<CPWeapon>     WeaponClass;
	var string              WeaponType, ItemName;
	var int                 MaxClipCount;
};
var array<WeaponList> SpecialForcesWeaponList , MercenariesWeaponList, AllWeaponsList, SelectedWeaponList;

//var TextureMovie	AmmoTextureMovie;

var GfxObject           lblWeaponGroup, lblWeaponName, lblEffectiveRange, lblRoundsM, lblMaxClipsValue, lblCashValue, lblReturnValue, lblCostValue;
var GFxClikWidget       btnPreset1,btnPreset2,btnPreset3,btnPreset4,btnPreset5,btnPresetSave;
var int intReturnValue, intCostValue;

/** Spinny weapon camera */

var GfxObject   Root;
var SceneCapture2DActor CamObj;
var Vector SpinnyWeapOffset;

//Armor Range
var int ArmorRangeHigh, ArmorRangeLow, DamagedArmorSellModification;

delegate MousePressDetectDelegate(bool bTrue, string target);

//@@ todo: finish toString function as needed
function string ToString()
{
    local string returnString;
    
    returnString = "\n";
    returnString $= WeapButtonToString(MeleeWeaponButton, "Melee");
    returnString $= WeapButtonToString(PistolWeaponButton, "Pistol");
    returnString $= WeapButtonToString(SMGWeaponButton, "SMG");
    returnString $= WeapButtonToString(RifleWeaponButton, "Rifle");
    returnString $= "\n";
    
    return returnString;
}

function string WeapButtonToString(array<WeaponButton> WeapButtonArray, string WeaponGroupName)
{
    local string returnString;
    local int i;
    
    returnString $= "\n "$ WeaponGroupName $ " \n ------------------ \n";
    for (i = 0 ; i < WeapButtonArray.Length ; i++)
	{
        if(WeapButtonArray[i].WeaponButton.GetBool("selected"))
        {
            if(WeapButtonArray[i].CurrentWeaponClass != None)
            {            
                returnString $= " CurrentWeapon: "$WeapButtonArray[i].CurrentWeaponClass.Name $ "\n";
            }
            if(WeapButtonArray[i].NewWeaponClass != None)
            {
                returnString $= " NewWeapon: "$WeapButtonArray[i].NewWeaponClass.Name $ "\n";
            }
            if(WeapButtonArray[i].CurrentWeaponClass == none && WeapButtonArray[i].NewWeaponClass != none)
			{
				returnString $= " +Buying "$WeapButtonArray[i].NewWeaponClass.name $ "\n";
			}
			else if(WeapButtonArray[i].CurrentWeaponClass != none && WeapButtonArray[i].NewWeaponClass != none)
			{
                returnString $= " +Buying: "$WeapButtonArray[i].NewWeaponClass.name $ "\n";	
                returnString $= " -Selling: "$WeapButtonArray[i].CurrentWeaponClass.name $ "\n";
			}
        }
        else
        {
            if (WeapButtonArray[i].CurrentWeaponClass != none)
			{
				returnString $= " -Selling: "$WeapButtonArray[i].CurrentWeaponClass.name $ "\n";
			}
        }
    }
    return returnString;
}

function bool Start(optional bool StartPaused = false)
{
	super.Start();
    Advance(0);

	Root = GetVariableObject("_root");
	//Root.SetString("_alpha","255");
	//`Log("alpha overridden on buymenu.");

	//SetupSpinnyWeapScene();

	MouseCursor = GetVariableObject("_root.mouseCursor_mc");
	MouseCursor.SetBool("topmostLevel", true);

	//`Log("Initalise stuff!");

	SpecialForcesWeaponList = BuildWeaponData(SpecialForcesWeapon);
	MercenariesWeaponList = BuildWeaponData(MercenariesWeapon);
	AllWeaponsList = BuildAllWeaponData();

	//`Log("We are on" @ GetPC().PlayerReplicationInfo.Team.GetHumanReadableName());
	switch (GetPC().PlayerReplicationInfo.Team.GetHumanReadableName())
	{
		case "Special Forces":
				PopulateWeaponLists(SpecialForcesWeaponList);
				SelectedWeaponList = SpecialForcesWeaponList;
			break;
		case "Mercenaries":
				PopulateWeaponLists(MercenariesWeaponList);
				SelectedWeaponList = MercenariesWeaponList;
			break;
	}

	SetMyDelegate(none); // clear it first
	SetMyDelegate(RightMouseButtonPressed);

	HeadArmorButton.Button = Setupbutton("_root.btnHeadArmor", "HEAD");
	BodyArmorButton.Button = Setupbutton("_root.btnBodyArmor", "BODY");
	LegArmorButton.Button = Setupbutton("_root.btnLegArmor", "LEG");

	NightVisionButton = Setupbutton("_root.btnNightVision", "NIGHT VISION");

	CancelButton = Setupbutton("_root.btnCancel", "CANCEL");
	ResetButton = Setupbutton("_root.btnReset", "RESET");
	BuyNowButton = Setupbutton("_root.btnBuyNow", "BUY NOW");

	//prepop the clip info
	MeleeClipSection.AddClip		    = Setupbutton("_root.btnMeleeWeaponClipAdd", "+");
	MeleeClipSection.RemoveClip         = Setupbutton("_root.btnMeleeWeaponClipRemove", "-");
	MeleeClipSection.ClipValue          = Setuplabel("_root.lblMeleeWeaponClipValue", string(0));
	MeleeClipSection.ClipCost           = Setuplabel("_root.lblMeleeClipsValue", "$0");
	MeleeClipSection.WeaponCost           = Setuplabel("_root.lblMeleeValue", "$0");

	PistolClipSection.AddClip           = Setupbutton("_root.btnPistolWeaponClipAdd", "+");
	PistolClipSection.RemoveClip        = Setupbutton("_root.btnPistolWeaponClipRemove", "-");
	PistolClipSection.ClipValue         = Setuplabel("_root.lblPistolWeaponClipValue", string(0));
	PistolClipSection.ClipCost          = Setuplabel("_root.lblPistolClipsValue", "$0");
	PistolClipSection.WeaponCost        = Setuplabel("_root.lblPistolValue", "$0");

	SMGClipSection.AddClip              = Setupbutton("_root.btnSMGWeaponClipAdd", "+");
	SMGClipSection.RemoveClip           = Setupbutton("_root.btnSMGWeaponClipRemove", "-");
	SMGClipSection.ClipValue            = Setuplabel("_root.lblSMGWeaponClipValue", string(0));
	SMGClipSection.ClipCost             = Setuplabel("_root.lblSMGClipsValue", "$0");
	SMGClipSection.WeaponCost           = Setuplabel("_root.lblSMGValue", "$0");

	RifleClipSection.AddClip            = Setupbutton("_root.btnRifleWeaponClipAdd", "+");
	RifleClipSection.RemoveClip         = Setupbutton("_root.btnRifleWeaponClipRemove", "-");
	RifleClipSection.ClipValue          = Setuplabel("_root.lblRifleWeaponClipValue", string(0));
	RifleClipSection.ClipCost           = Setuplabel("_root.lblRifleClipsValue", "$0");
	RifleClipSection.WeaponCost         = Setuplabel("_root.lblRifleValue", "$0");

	GrenadeClipSection.WeaponCost       = Setuplabel("_root.lblGrenadeValue", "$0");

	HeadArmorButton.ArmorButtonText = GetVariableObject("_root.btnHeadArmor.textField");
	BodyArmorButton.ArmorButtonText = GetVariableObject("_root.btnBodyArmor.textField");
	LegArmorButton.ArmorButtonText = GetVariableObject("_root.btnLegArmor.textField");

	btnPreset1              = Setupbutton("_root.btnPreset1", "PRESET 1");
	btnPreset2              = Setupbutton("_root.btnPreset2", "PRESET 2");
	btnPreset3              = Setupbutton("_root.btnPreset3", "PRESET 3");
	btnPreset4              = Setupbutton("_root.btnPreset4", "PRESET 4");
	btnPreset5              = Setupbutton("_root.btnPreset5", "PRESET 5");
	btnPresetSave           = Setupbutton("_root.btnSave"   , "SAVE");

	btnPreset1.SetBool("disabled",true);
	btnPreset2.SetBool("disabled",true);
	btnPreset3.SetBool("disabled",true);
	btnPreset4.SetBool("disabled",true);
	btnPreset5.SetBool("disabled",true);
	btnPresetSave.SetBool("disabled",true);

	lblCashValue            = Setuplabel("_root.lblCash", "$ 0");
	lblReturnValue          = Setuplabel("_root.lblReturn", "$ 0");
	lblCostValue            = Setuplabel("_root.lblValue", "$ 0");

	blnArmorSelected = true;
	blnWeaponLoadoutReset = true;
	return true;
}

function SetupSpinnyWeapScene()
{
	////we need to find a scenecapture2dactor camera in the world...
	//local SceneCapture2DComponent SC2DC;
	//local ScaleformSkeletalMeshActor FindSpinnyWeap;
	//local SceneCapture2DActor Cam;

	//foreach GetPC().WorldInfo.AllActors(class'SceneCapture2DActor', Cam)
	//{
	//	SC2DC = SceneCapture2DComponent(Cam.SceneCapture);
	//	if(SC2DC != none && SC2DC.TextureTarget != none)
	//	{
	//		if(SC2DC.TextureTarget == TextureRenderTarget2D'CP_Greenscreen.RTT_Greenscreen')
	//		{
	//			CamObj = Cam;
	//			SetExternalTexture("popup_bg",TextureRenderTarget2D'CP_Greenscreen.RTT_Greenscreen');

	//			foreach GetPC().WorldInfo.AllActors(class'ScaleformSkeletalMeshActor', FindSpinnyWeap)
	//			{
	//				if(FindSpinnyWeap.Tag == 'SpinnyWeap')
	//				{
	//					SpinnyWeapon = FindSpinnyWeap;
	//					break;
	//				}
	//			}
	//			if(SpinnyWeapon == none)
	//			{
	//				SpinnyWeapon = GetPC().Spawn(class'ScaleformSkeletalMeshActor',GetPC(),'SpinnyWeap',CamObj.Location - SpinnyWeapOffset);
	//			}
	//			else
	//			{
	//				SpinnyWeapon.SetHidden(false);
	//			}
	//		}
	//	}
	//}
}

function OnHeadArmorButtonPressed()
{
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnHeadArmorButtonPressed");

	HeadArmorButton.Button.SetBool("focused", false);
}

function OnBodyArmorButtonPressed()
{
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnBodyArmorButtonPressed");

	BodyArmorButton.Button.SetBool("focused", false);
}

function OnLegArmorButtonPressed()
{
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnLegArmorButtonPressed");

	LegArmorButton.Button.SetBool("focused", false);
}

function OnNightVisionButtonPressed()
{
	//`Log("GFxCPBuyMenu::    RIGHT MOUSE PRESSED    ::OnNightVisionButtonPressed");

	NightVisionButton.SetBool("focused", false);
}

function OnCancelButtonPressed()
{
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnCancelButtonPressed");
	blnCloseMenu = true;

	//if(SpinnyWeapon != none)
	//	SpinnyWeapon.SetHidden(true);
}

function OnResetButtonPressed()
{
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnResetButtonPressed");
	blnWeaponLoadoutReset = true;
}

function OnLeftClickClipLabel(ClipSection Clip)
{
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnMeleeWeaponLeftClickClipLabel");
}

function OnRightClickClipLabel(ClipSection Clip)
{
	//`Log("GFxCPBuyMenu::    RIGHT MOUSE PRESSED    ::OnMeleeWeaponRightClickClipLabel");
}

function OnMeleeWeaponClicked(int index)
{
	//melee weapon can not be sold so we dont want to unselect it.
    MeleeWeaponButton[index].WeaponButton.SetBool("selected",true);
	MeleeWeaponButton[index] = CheckToggleStatus(MeleeWeaponButton, MeleeWeaponButton[index], MeleeClipSection, index);

	if(!blnRightMousePressed)
	{
		//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}
	else
	{
		//`Log("GFxCPBuyMenu::    RIGHT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}

	//MeleeWeaponButton[index] = RefundMoney(MeleeWeaponButton[index]); since you cant sell your knife this isnt needed.
	//MeleeWeaponButton[index] = MeleeWeaponButton(PistolWeaponButton[index]);
    if(MeleeWeaponButton[index].bOtherTeamWeapon)
    {
        MeleeWeaponButton[index].NewWeaponClass = None;
    }
}

function OnPistolWeaponClicked(int index)
{
	PistolWeaponButton[index] = CheckToggleStatus(PistolWeaponButton, PistolWeaponButton[index], PistolClipSection, index);
	if(!blnRightMousePressed)
	{
		//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}
	else
	{
		//`Log("GFxCPBuyMenu::    RIGHT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}

//	PistolWeaponButton[index] = RefundMoney(PistolWeaponButton[index],PistolWeaponButton);
//	PistolWeaponButton[index] = ChargeMoney(PistolWeaponButton[index], PistolWeaponButton, "_root.lblPistolValue");
    //weapons taken from the other team must have their buttons double toggled
    if(PistolWeaponButton[index].bOtherTeamWeapon)
    {
        PistolWeaponButton[index] = CheckToggleStatus(PistolWeaponButton, PistolWeaponButton[index], PistolClipSection, index);
    }
}

function OnSMGWeaponClicked(int index)
{
	SMGWeaponButton[index] = CheckToggleStatus(SMGWeaponButton, SMGWeaponButton[index],SMGClipSection,index);
	if(!blnRightMousePressed)
	{
		//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}
	else
	{
		//`Log("GFxCPBuyMenu::    RIGHT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}

//	SMGWeaponButton[index] = RefundMoney(SMGWeaponButton[index],SMGWeaponButton);
//	SMGWeaponButton[index] = ChargeMoney(SMGWeaponButton[index], SMGWeaponButton, "_root.lblSMGValue");
    if(SMGWeaponButton[index].bOtherTeamWeapon)
    {
        SMGWeaponButton[index] = CheckToggleStatus(SMGWeaponButton, SMGWeaponButton[index],SMGClipSection,index);
    }
}

function OnRifleWeaponClicked(int index)
{
	RifleWeaponButton[index] = CheckToggleStatus(RifleWeaponButton, RifleWeaponButton[index],RifleClipSection,index);
	if(!blnRightMousePressed)
	{
		//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}
	else
	{
		//`Log("GFxCPBuyMenu::    RIGHT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}

//	RifleWeaponButton[index] = RefundMoney(RifleWeaponButton[index],RifleWeaponButton);
//	RifleWeaponButton[index] = ChargeMoney(RifleWeaponButton[index], RifleWeaponButton, "_root.lblRifleValue");
    if(RifleWeaponButton[index].bOtherTeamWeapon)
    {
        RifleWeaponButton[index] = CheckToggleStatus(RifleWeaponButton, RifleWeaponButton[index],RifleClipSection,index);
    }
}

function OnGrenadeWeaponClicked(int index)
{
	GrenadeWeaponButton[index] = CheckToggleStatus(GrenadeWeaponButton, GrenadeWeaponButton[index],GrenadeClipSection,index);
	if(!blnRightMousePressed)
	{
		//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}
	else
	{
		//`Log("GFxCPBuyMenu::    RIGHT MOUSE PRESSED    ::OnMeleeWeaponClicked::" @ index);
	}

//	GrenadeWeaponButton[index] = RefundMoney(GrenadeWeaponButton[index],GrenadeWeaponButton);
//	GrenadeWeaponButton[index] = ChargeMoney(GrenadeWeaponButton[index], GrenadeWeaponButton, "_root.lblGrenadeValue");
}

function OnFocus(GFxClikWidget.EventData ev)
{
	local string ObjectName;

	ObjectName = ev.target.GetString("_name");

	switch(ObjectName)
	{
		case "btnMeleeWeaponButton1" :
			 OnMeleeWeaponFocused(0);
			 break;
		case "btnMeleeWeaponButton2" :
			 OnMeleeWeaponFocused(1);
			 break;
		case "btnMeleeWeaponButton3" :
			 OnMeleeWeaponFocused(2);
			 break;
		case "btnMeleeWeaponButton4" :
			 OnMeleeWeaponFocused(3);
			 break;
		case "btnMeleeWeaponButton5" :
			 OnMeleeWeaponFocused(4);
			 break;
		case "btnMeleeWeaponButton6" :
			 OnMeleeWeaponFocused(5);
			 break;
		case "btnMeleeWeaponButton7" :
			 OnMeleeWeaponFocused(6);
			 break;
		case "btnMeleeWeaponButton8" :
			 OnMeleeWeaponFocused(7);
			 break;
		case "btnPistolWeaponButton1" :
			 OnPistolWeaponFocused(0);
			 break;
		case "btnPistolWeaponButton2" :
			 OnPistolWeaponFocused(1);
			 break;
		case "btnPistolWeaponButton3" :
			 OnPistolWeaponFocused(2);
			 break;
		case "btnPistolWeaponButton4" :
			 OnPistolWeaponFocused(3);
			 break;
		case "btnPistolWeaponButton5" :
			 OnPistolWeaponFocused(4);
			 break;
		case "btnPistolWeaponButton6" :
			 OnPistolWeaponFocused(5);
			 break;
		case "btnPistolWeaponButton7" :
			 OnPistolWeaponFocused(6);
			 break;
		case "btnPistolWeaponButton8" :
			 OnPistolWeaponFocused(7);
			 break;
		case "btnSMGWeaponButton1" :
			 OnSMGWeaponFocused(0);
			 break;
		case "btnSMGWeaponButton2" :
			 OnSMGWeaponFocused(1);
			 break;
		case "btnSMGWeaponButton3" :
			 OnSMGWeaponFocused(2);
			 break;
		case "btnSMGWeaponButton4" :
			 OnSMGWeaponFocused(3);
			 break;
		case "btnSMGWeaponButton5" :
			 OnSMGWeaponFocused(4);
			 break;
		case "btnSMGWeaponButton6" :
			 OnSMGWeaponFocused(5);
			 break;
		case "btnSMGWeaponButton7" :
			 OnSMGWeaponFocused(6);
			 break;
		case "btnSMGWeaponButton8" :
			 OnSMGWeaponFocused(7);
			 break;
		case "btnRifleWeaponButton1" :
			 OnRifleWeaponFocused(0);
			 break;
		case "btnRifleWeaponButton2" :
			 OnRifleWeaponFocused(1);
			 break;
		case "btnRifleWeaponButton3" :
			 OnRifleWeaponFocused(2);
			 break;
		case "btnRifleWeaponButton4" :
			 OnRifleWeaponFocused(3);
			 break;
		case "btnRifleWeaponButton5" :
			 OnRifleWeaponFocused(4);
			 break;
		case "btnRifleWeaponButton6" :
			 OnRifleWeaponFocused(5);
			 break;
		case "btnRifleWeaponButton7" :
			 OnRifleWeaponFocused(6);
			 break;
		case "btnRifleWeaponButton8" :
			 OnRifleWeaponFocused(7);
			 break;
		case "btnGrenadeWeaponButton1" :
			 OnGrenadeWeaponFocused(0);
			 break;
		case "btnGrenadeWeaponButton2" :
			 OnGrenadeWeaponFocused(1);
			 break;
		case "btnGrenadeWeaponButton3" :
			 OnGrenadeWeaponFocused(2);
			 break;
		case "btnGrenadeWeaponButton4" :
			 OnGrenadeWeaponFocused(3);
			 break;
		case "btnGrenadeWeaponButton5" :
			 OnGrenadeWeaponFocused(4);
			 break;
		case "btnGrenadeWeaponButton6" :
			 OnGrenadeWeaponFocused(5);
			 break;
		case "btnGrenadeWeaponButton7" :
			 OnGrenadeWeaponFocused(6);
			 break;
		case "btnGrenadeWeaponButton8" :
			 OnGrenadeWeaponFocused(7);
			 break;
	}
}

function SetupWeaponDescWindow(class<CPWeapon> SelectedWeapon, string strWeaponName ,array<WeaponList> WeaponClassList, string strWeaponGroup)
{
	local int i;
	local string strName; //bug in array where it can do weird out of bounds stuff

	if(SelectedWeapon != none)
	{
		if ( lblWeaponGroup != none ) lblWeaponGroup.SetText(strWeaponGroup);
		if ( lblWeaponName != none ) lblWeaponName.SetText(SelectedWeapon.Default.MenuItemName);
		if ( lblEffectiveRange != none ) lblEffectiveRange.SetText(SelectedWeapon.Default.MenuEffectiveRange);
		if ( lblRoundsM != none ) lblRoundsM.SetText(SelectedWeapon.Default.MenuRoundsPerMinute);
		if ( lblMaxClipsValue != none ) lblMaxClipsValue.SetText(SelectedWeapon.Default.MenuClipsOfMaxClips);

		//if(SpinnyWeapon != none && CamObj != none)
		//{
		//	if(UDKSkeletalMeshComponent(SelectedWeapon.default.Mesh).SkeletalMesh != none)
		//	{

		//		SpinnyWeapOffset.X = 0.87;
		//		SpinnyWeapOffset.Y = -42.14;
		//		SpinnyWeapOffset.Z = 0.89;
		//		SpinnyWeapon.SetLocation(CamObj.Location - SpinnyWeapOffset);
		//		SpinnyWeapon.SkeletalMeshComponent.SetSkeletalMesh(UDKSkeletalMeshComponent(SelectedWeapon.default.Mesh).SkeletalMesh);
		//		SpinnyWeapon.SetHidden(false);
		//	}
		//	else
		//		SpinnyWeapon.SetHidden(true);
		//}
	}
	else
	{
		for(i = 0 ; i < WeaponClassList.Length ; i++)
		{
			strName = WeaponClassList[i].ItemName;
			if(strName == strWeaponName)
			{
				if ( lblWeaponGroup != none ) lblWeaponGroup.SetText(strWeaponGroup);
				if ( lblWeaponName != none ) lblWeaponName.SetText(WeaponClassList[i].WeaponClass.Default.MenuItemName);
				if ( lblEffectiveRange != none ) lblEffectiveRange.SetText(WeaponClassList[i].WeaponClass.Default.MenuEffectiveRange);
				if ( lblRoundsM != none ) lblRoundsM.SetText(WeaponClassList[i].WeaponClass.Default.MenuRoundsPerMinute);
				if ( lblMaxClipsValue != none ) lblMaxClipsValue.SetText(WeaponClassList[i].WeaponClass.Default.MenuClipsOfMaxClips);

				//if(SpinnyWeapon != none && CamObj != none)
				//{
				//	if(UDKSkeletalMeshComponent(WeaponClassList[i].WeaponClass.default.Mesh).SkeletalMesh != none)
				//	{
				//		SpinnyWeapOffset.X = 0.87;
				//		SpinnyWeapOffset.Y = -42.14;
				//		SpinnyWeapOffset.Z = 0.89;
				//		SpinnyWeapon.SetLocation(CamObj.Location - SpinnyWeapOffset);

				//		SpinnyWeapon.SkeletalMeshComponent.SetSkeletalMesh(UDKSkeletalMeshComponent(WeaponClassList[i].WeaponClass.default.Mesh).SkeletalMesh);
				//		SpinnyWeapon.SetHidden(false);
				//	}
				//	else
				//		SpinnyWeapon.SetHidden(true);
				//}
			}
		}
	}
}

function OnMeleeWeaponFocused(int index)
{
	//`Log("GFxCPBuyMenu::    OnMeleeWeaponFocused over a" @MeleeWeaponButton[index].CurrentWeaponClass);
	SetupWeaponDescWindow(MeleeWeaponButton[index].CurrentWeaponClass, MeleeWeaponButton[index].WeaponButton.GetString("label"), SelectedWeaponList, "MELEE |");
}

function OnPistolWeaponFocused(int index)
{
	//`Log("GFxCPBuyMenu::    OnPistolWeaponFocused");
	SetupWeaponDescWindow(PistolWeaponButton[index].CurrentWeaponClass, PistolWeaponButton[index].WeaponButton.GetString("label"), SelectedWeaponList,"PISTOL |");
}

function OnSMGWeaponFocused(int index)
{
	//`Log("GFxCPBuyMenu::    OnSMGWeaponFocused");
	SetupWeaponDescWindow(SMGWeaponButton[index].CurrentWeaponClass, SMGWeaponButton[index].WeaponButton.GetString("label"),SelectedWeaponList, "SMG   |");
}

function OnRifleWeaponFocused(int index)
{
	//`Log("GFxCPBuyMenu::    OnRifleWeaponFocused");
	SetupWeaponDescWindow(RifleWeaponButton[index].CurrentWeaponClass, RifleWeaponButton[index].WeaponButton.GetString("label"),SelectedWeaponList, "RIFLE |");
}

function OnGrenadeWeaponFocused(int index)
{
	//`Log("GFxCPBuyMenu::    OnGrenadeWeaponFocused");
	SetupWeaponDescWindow(GrenadeWeaponButton[index].CurrentWeaponClass, GrenadeWeaponButton[index].WeaponButton.GetString("label"),SelectedWeaponList, "GRENADE |");
}

function OnLeftMouseButtonPressed(GFxClikWidget.EventData ev)
{
	local string ObjectName;

    ObjectName = ev.target.GetString("_name");
    switch(ObjectName)
	{
		case "btnHeadArmor" :
			 OnHeadArmorButtonPressed();
			break;
		case "btnBodyArmor" :
			 OnBodyArmorButtonPressed();
			break;
		case "btnLegArmor" :
			 OnLegArmorButtonPressed();
			 break;
		case "btnNightVision" :
			 OnNightVisionButtonPressed();
			 break;
		case "btnCancel" :
			 OnCancelButtonPressed();
			 break;
		case "btnReset" :
			 OnResetButtonPressed();
			 break;
		case "btnBuyNow" :
			 OnBuyNowButtonPressed();
			 break;
		case "btnMeleeWeaponClipAdd" :
			OnClipAdd(MeleeClipSection); //removed until throwing knifes are added
			 break;
		case "btnMeleeWeaponClipRemove" :
			OnClipRemove(MeleeClipSection);
			 break;
		case "lblMeleeWeaponClipValue" :
			 OnLeftClickClipLabel(MeleeClipSection);
			 break;
		case "btnPistolWeaponClipAdd" :
			 OnClipAdd(PistolClipSection);
			 break;
		case "btnPistolWeaponClipRemove" :
			 OnClipRemove(PistolClipSection);
			 break;
		case "lblPistolWeaponClipValue" :
			 OnLeftClickClipLabel(PistolClipSection);
			 break;
		case "btnSMGWeaponClipAdd" :
			 OnClipAdd(SMGClipSection);
			 break;
		case "btnSMGWeaponClipRemove" :
			 OnClipRemove(SMGClipSection);
			 break;
		case "lblSMGWeaponClipValue" :
			 OnLeftClickClipLabel(SMGClipSection);
			 break;
		case "btnRifleWeaponClipAdd" :
			 OnClipAdd(RifleClipSection);
			 break;
		case "btnRifleWeaponClipRemove" :
			 OnClipRemove(RifleClipSection);
			 break;
		case "lblRifleWeaponClipValue" :
			 OnLeftClickClipLabel(RifleClipSection);
			 break;
		case "btnMeleeWeaponButton1" :
			 OnMeleeWeaponClicked(0);
			 break;
		case "btnMeleeWeaponButton2" :
			 OnMeleeWeaponClicked(1);
			 break;
		case "btnMeleeWeaponButton3" :
			 OnMeleeWeaponClicked(2);
			 break;
		case "btnMeleeWeaponButton4" :
			 OnMeleeWeaponClicked(3);
			 break;
		case "btnMeleeWeaponButton5" :
			 OnMeleeWeaponClicked(4);
			 break;
		case "btnMeleeWeaponButton6" :
			 OnMeleeWeaponClicked(5);
			 break;
		case "btnMeleeWeaponButton7" :
			 OnMeleeWeaponClicked(6);
			 break;
		case "btnMeleeWeaponButton8" :
			 OnMeleeWeaponClicked(7);
			 break;
		case "btnPistolWeaponButton1" :
			 OnPistolWeaponClicked(0);
			 break;
		case "btnPistolWeaponButton2" :
			 OnPistolWeaponClicked(1);
			 break;
		case "btnPistolWeaponButton3" :
			 OnPistolWeaponClicked(2);
			 break;
		case "btnPistolWeaponButton4" :
			 OnPistolWeaponClicked(3);
			 break;
		case "btnPistolWeaponButton5" :
			 OnPistolWeaponClicked(4);
			 break;
		case "btnPistolWeaponButton6" :
			 OnPistolWeaponClicked(5);
			 break;
		case "btnPistolWeaponButton7" :
			 OnPistolWeaponClicked(6);
			 break;
		case "btnPistolWeaponButton8" :
			 OnPistolWeaponClicked(7);
			 break;
		case "btnSMGWeaponButton1" :
			 OnSMGWeaponClicked(0);
			 break;
		case "btnSMGWeaponButton2" :
			 OnSMGWeaponClicked(1);
			 break;
		case "btnSMGWeaponButton3" :
			 OnSMGWeaponClicked(2);
			 break;
		case "btnSMGWeaponButton4" :
			 OnSMGWeaponClicked(3);
			 break;
		case "btnSMGWeaponButton5" :
			 OnSMGWeaponClicked(4);
			 break;
		case "btnSMGWeaponButton6" :
			 OnSMGWeaponClicked(5);
			 break;
		case "btnSMGWeaponButton7" :
			 OnSMGWeaponClicked(6);
			 break;
		case "btnSMGWeaponButton8" :
			 OnSMGWeaponClicked(7);
			 break;
		case "btnRifleWeaponButton1" :
			 OnRifleWeaponClicked(0);
			 break;
		case "btnRifleWeaponButton2" :
			 OnRifleWeaponClicked(1);
			 break;
		case "btnRifleWeaponButton3" :
			 OnRifleWeaponClicked(2);
			 break;
		case "btnRifleWeaponButton4" :
			 OnRifleWeaponClicked(3);
			 break;
		case "btnRifleWeaponButton5" :
			 OnRifleWeaponClicked(4);
			 break;
		case "btnRifleWeaponButton6" :
			 OnRifleWeaponClicked(5);
			 break;
		case "btnRifleWeaponButton7" :
			 OnRifleWeaponClicked(6);
			 break;
		case "btnRifleWeaponButton8" :
			 OnRifleWeaponClicked(7);
			 break;
		case "btnGrenadeWeaponButton1" :
			 OnGrenadeWeaponClicked(0);
			 break;
		case "btnGrenadeWeaponButton2" :
			 OnGrenadeWeaponClicked(1);
			 break;
		case "btnGrenadeWeaponButton3" :
			 OnGrenadeWeaponClicked(2);
			 break;
		case "btnGrenadeWeaponButton4" :
			 OnGrenadeWeaponClicked(3);
			 break;
		case "btnGrenadeWeaponButton5" :
			 OnGrenadeWeaponClicked(4);
			 break;
		case "btnGrenadeWeaponButton6" :
			 OnGrenadeWeaponClicked(5);
			 break;
		case "btnGrenadeWeaponButton7" :
			 OnGrenadeWeaponClicked(6);
			 break;
		case "btnGrenadeWeaponButton8" :
			 OnGrenadeWeaponClicked(7);
			 break;
	}
}

function RightMouseButtonPressed(bool bTrue, string target)
{
	//hold this for the events itself
	//TODO: get rid of the junk off target!!
	blnRightMousePressed = btrue;

	if(bTrue)
	{
		switch(target)
		{
			case "_level0.btnHeadArmor" :
					 ToggleAllArmorButtons();
					break;
			case "_level0.btnBodyArmor" :
					ToggleAllArmorButtons();
				break;
			case "_level0.btnLegArmor" :
					ToggleAllArmorButtons();
				break;
			case "_level0.btnMeleeWeaponClipAdd" :
				 OnClipAddAll(MeleeClipSection);
				 break;
			case "_level0.btnMeleeWeaponClipAdd" :
				 OnClipAddAll(MeleeClipSection);
				 break;
			case "_level0.btnMeleeWeaponClipRemove" :
				 OnClipRemoveAll(MeleeClipSection);
				 break;
			case "_level0.btnMeleeWeaponClipRemove" :
				 OnClipRemoveAll(MeleeClipSection);
				 break;
			case "_level0.lblMeleeWeaponClipValue" :
				 OnRightClickClipLabel(MeleeClipSection);
				 break;
			case "_level0.btnPistolWeaponClipAdd" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponClipRemove" :
				 OnClipRemoveAll(PistolClipSection);
				 break;
			case "_level0.lblPistolWeaponClipValue" :
				 OnRightClickClipLabel(PistolClipSection);
				 break;
			case "_level0.btnSMGWeaponClipAdd" :
				 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponClipRemove" :
				 OnClipRemoveAll(SMGClipSection);
				 break;
			case "_level0.lblSMGWeaponClipValue" :
				 OnRightClickClipLabel(SMGClipSection);
				 break;
			case "_level0.btnRifleWeaponClipAdd" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponClipRemove" :
				 OnClipRemoveAll(RifleClipSection);
				 break;
			case "_level0.lblRifleWeaponClipValue" :
				 OnRightClickClipLabel(RifleClipSection);
				 break;
			case "_level0.btnMeleeWeaponButton1" :
				 //OnMeleeWeaponClicked(0);
				 break;
			case "_level0.btnMeleeWeaponButton2" :
				 //OnMeleeWeaponClicked(1);
				 break;
			case "_level0.btnMeleeWeaponButton3" :
				 //OnMeleeWeaponClicked(2);
				 break;
			case "_level0.btnMeleeWeaponButton4" :
				 //OnMeleeWeaponClicked(3);
				 break;
			case "_level0.btnMeleeWeaponButton5" :
				 //OnMeleeWeaponClicked(4);
				 break;
			case "_level0.btnMeleeWeaponButton6" :
				 //OnMeleeWeaponClicked(5);
				 break;
			case "_level0.btnMeleeWeaponButton7" :
				 //OnMeleeWeaponClicked(6);
				 break;
			case "_level0.btnMeleeWeaponButton8" :
				 //OnMeleeWeaponClicked(7);
				 break;
			case "_level0.btnPistolWeaponButton1" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponButton2" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponButton3" :
			  	 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponButton4" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponButton5" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponButton6" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponButton7" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnPistolWeaponButton8" :
				 OnClipAddAll(PistolClipSection);
				 break;
			case "_level0.btnSMGWeaponButton1" :
				 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponButton2" :
				 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponButton3" :
				 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponButton4" :
			 	 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponButton5" :
				 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponButton6" :
				 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponButton7" :
			 	OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnSMGWeaponButton8" :
				 OnClipAddAll(SMGClipSection);
				 break;
			case "_level0.btnRifleWeaponButton1" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponButton2" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponButton3" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponButton4" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponButton5" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponButton6" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponButton7" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnRifleWeaponButton8" :
				 OnClipAddAll(RifleClipSection);
				 break;
			case "_level0.btnGrenadeWeaponButton1" :
				 OnGrenadeWeaponClicked(0);
				 break;
			case "_level0.btnGrenadeWeaponButton2" :
				 OnGrenadeWeaponClicked(1);
				 break;
			case "_level0.btnGrenadeWeaponButton3" :
				 OnGrenadeWeaponClicked(2);
				 break;
			case "_level0.btnGrenadeWeaponButton4" :
				 OnGrenadeWeaponClicked(3);
				 break;
			case "_level0.btnGrenadeWeaponButton5" :
				 OnGrenadeWeaponClicked(4);
				 break;
			case "_level0.btnGrenadeWeaponButton6" :
				 OnGrenadeWeaponClicked(5);
				 break;
			case "_level0.btnGrenadeWeaponButton7" :
				 OnGrenadeWeaponClicked(6);
				 break;
			case "_level0.btnGrenadeWeaponButton8" :
				 OnGrenadeWeaponClicked(7);
				 break;
		}
	}
}

function Tick(Float DeltaTime)
{
	local int i, j, k;
	local array<CPWeapon> WeaponArray;
	local int HeadStr, BodyStr, LegStr;
	local CPPlayerReplicationInfo CPPRI;

	CPPRI = CPPlayerReplicationInfo(GetPC().PlayerReplicationInfo);

	if(GetPC().Pawn == none)
		return;
        

	HeadStr = CPPawn(GetPC().Pawn).HeadStrength * 100;
	BodyStr = CPPawn(GetPC().Pawn).BodyStrength * 100;
	LegStr = CPPawn(GetPC().Pawn).LegStrength * 100;

	//get the values updated on the hud.
	lblCashValue.SetString("text","$" $ CPPRI.Money);
	lblReturnValue.SetString("text","$" $ intReturnValue);
	lblCostValue.SetString("text","$" $ intCostValue);

	// Disable the BUY NOW button if we don't have enough cash!
	if(CPPRI != none)
	{
		if(CPPRI.BuyCheck(intCostValue, intReturnValue))
		{
			BuyNowButton.SetBool("enabled", true);
			BuyNowButton.SetBool("disabled", false);
		}
		else
		{
			BuyNowButton.SetBool("enabled", false);
			BuyNowButton.SetBool("disabled", true);
		}
	}

    GetPC().PlayerInput.ResetInput(); //stops any controls locking when we open the menus up

	//Grab a list of the weapons in our inventory
    if(GetPC().Pawn != none && GetPC().Pawn.InvManager != none)
	{
		CPInventoryManager(GetPC().Pawn.InvManager).GetWeaponList(WeaponArray);
	}

	//we do need to constantly check this - in case someone gives us a weapon or something unexpected. - handle an event in inventory to tell us if this happens (Drakk to do ;) )
	if(blnWeaponLoadoutReset)
	{

		HideClipSection(MeleeClipSection);
		HideClipSection(PistolClipSection);
		HideClipSection(SMGClipSection);
		HideClipSection(RifleClipSection);
		DeselectAllButtons();
        
        ResetButton.SetBool("selected", false);
        ResetButton.SetBool("_disableFocus", true);

		//`log("Check the armor we have");
		if(HeadStr <= ArmorRangeHigh && HeadStr >= ArmorRangeLow)
		{
			HeadArmorButton.Button.SetBool("selected", true); //manually press the button
			HeadArmorButton.ArmorOwned = true;
			blnArmorToggle = true;
		}
		else
		{
			HeadArmorButton.Button.SetBool("selected", false); //manually press the button
			HeadArmorButton.ArmorOwned = false;
		}

		if(BodyStr <= ArmorRangeHigh && BodyStr >= ArmorRangeLow)
		{
			BodyArmorButton.Button.SetBool("selected", true); //manually press the button
			BodyArmorButton.ArmorOwned = true;
			blnArmorToggle = true;
		}
		else
		{
			BodyArmorButton.Button.SetBool("selected", false); //manually press the button
			BodyArmorButton.ArmorOwned = false;
		}

		if(LegStr <= ArmorRangeHigh && LegStr >= ArmorRangeLow)
		{
			LegArmorButton.Button.SetBool("selected", true); //manually press the button
			LegArmorButton.ArmorOwned = true;
			blnArmorToggle = true;
		}
		else
		{
			LegArmorButton.Button.SetBool("selected", false); //manually press the button
			LegArmorButton.ArmorOwned = false;
		}

		//`Log("We are carrying ");
		for (i = 0 ; i < WeaponArray.Length ; i++)
		{
			//`Log(WeaponArray[i].ItemName @ "of the weapon group" @ CPWeapon(WeaponArray[i]).IntWeaponTypeToString(CPWeapon(WeaponArray[i]).WeaponType) @ "With" @ CPWeapon(WeaponArray[i]).GetClipCount() @ "Clips Remaining with a maximum of" @ CPWeapon(WeaponArray[i]).Default.MaxClipCount @ "Clips we can hold." );
			for ( j = 0 ; j < AllWeaponsList.Length ; j ++)
			{
				if(WeaponArray[i].ItemName == AllWeaponsList[j].ItemName)
				{
					//find the weapon group it belongs to
					switch(AllWeaponsList[j].WeaponType)
					{
						case "WT_KNIFE" :
								ShowWeapon(MeleeWeaponButton, WeaponArray[i], MeleeClipSection,"_root.btnMeleeWeaponClipAdd","_root.btnMeleeWeaponClipRemove","_root.lblMeleeWeaponClipValue","_root.lblMeleeValue","_root.btnMeleeWeaponButton");
								break;
						case "WT_PISTOL" :
								ShowWeapon(PistolWeaponButton, WeaponArray[i], PistolClipSection,"_root.btnPistolWeaponClipAdd","_root.btnPistolWeaponClipRemove","_root.lblPistolWeaponClipValue","_root.lblPistolValue","_root.btnPistolWeaponButton");
								break;
						case "WT_SMG" :
								ShowWeapon(SMGWeaponButton, WeaponArray[i], SMGClipSection,"_root.btnSMGWeaponClipAdd","_root.btnSMGWeaponClipRemove","_root.lblSMGWeaponClipValue","_root.lblSMGValue","_root.btnSMGWeaponButton");
								break;
						case "WT_SHOTGUN" :
								ShowWeapon(SMGWeaponButton, WeaponArray[i], SMGClipSection,"_root.btnSMGWeaponClipAdd","_root.btnSMGWeaponClipRemove","_root.lblSMGWeaponClipValue","_root.lblSMGValue","_root.btnSMGWeaponButton");
								break;
						case "WT_RIFLE" :
								ShowWeapon(RifleWeaponButton, WeaponArray[i], RifleClipSection,"_root.btnRifleWeaponClipAdd","_root.btnRifleWeaponClipRemove","_root.lblRifleWeaponClipValue","_root.lblRifleValue","_root.btnRifleWeaponButton");
								break;
						case "WT_GRENADE" :
								ShowWeapon(GrenadeWeaponButton, WeaponArray[i], GrenadeClipSection,"_root.btnGrenadeWeaponClipAdd","_root.btnGrenadeWeaponClipRemove","_root.lblGrenadeWeaponClipValue","_root.lblGrenadeValue","_root.btnGrenadeWeaponButton");
							break;
					}
				}
			}

			//which button group does this weapon belong in
			//we need to select the weapon from the weapon array

		}

		//setup weapon section now

		lblWeaponGroup                  = Setuplabel("_root.lblRifle", "");
		lblWeaponName                   = lblWeaponGroup.GetObject("textField2");
		lblEffectiveRange               = Setuplabel("_root.lblEffectiveRangeValue", "");
		lblRoundsM                      = Setuplabel("_root.lblRoundsMValue", "");
		lblMaxClipsValue                = Setuplabel("_root.lbClipMaxClipValue", "");
		OnMeleeWeaponFocused(0);
        
	}

	UpdateWeaponCosting();
	UpdateClipCosting();
	UpdateArmorCosting();

	DisplayClipSection(MeleeClipSection);
	DisplayClipSection(PistolClipSection);
	DisplayClipSection(SMGClipSection);
	DisplayClipSection(RifleClipSection);

	if(HeadArmorButton.ArmorOwned)
	{
		HeadArmorButton.ArmorButtonText.SetText("HEAD" $ " " $ int(CPPawn(GetPC().Pawn).HeadStrength * 100) $ "%");
	}

	if(BodyArmorButton.ArmorOwned)
	{
		BodyArmorButton.ArmorButtonText.SetText("BODY" $ " " $ int(CPPawn(GetPC().Pawn).BodyStrength * 100) $ "%");
	}

	if(LegArmorButton.ArmorOwned)
	{
		LegArmorButton.ArmorButtonText.SetText("LEG" $ " " $ int(CPPawn(GetPC().Pawn).LegStrength * 100) $ "%");
	}

	//UpdateArmorElement(HeadArmorButton, "HEAD", CPPawn(GetPC().Pawn).HeadStrength * 100);
	//UpdateArmorElement(BodyArmorButton, "BODY", CPPawn(GetPC().Pawn).BodyStrength * 100);
	//UpdateArmorElement(LegArmorButton,  "LEG" , CPPawn(GetPC().Pawn).LegStrength * 100);
    
    if(blnWeaponLoadoutReset)
    {
        blnWeaponLoadoutReset = false;
    }
    
    //hack: prevent stolen meleee weapon button from influencing the shopping cart. should delete this part when ammo for melee weapons in implemented
    for(k=0; k<MeleeWeaponButton.Length; k++)
    {
        if(MeleeWeaponButton[k].NewWeaponClass != None)
        {
            MeleeWeaponButton[k].NewWeaponClass = None;
        }
    }
}

function UpdateArmorCosting()
{
	local int HeadStr, BodyStr, LegStr;
	local int ArmorPieceCost;

	HeadStr = CPPawn(GetPC().Pawn).HeadStrength * 100;
	BodyStr = CPPawn(GetPC().Pawn).BodyStrength * 100;
	LegStr = CPPawn(GetPC().Pawn).LegStrength * 100;

	ArmorPieceCost = class'CPArmor_Head'.default.Cost;
	if(HeadArmorButton.Button.GetBool("selected"))
	{
		if(!HeadArmorButton.ArmorOwned)
			intCostValue += ArmorPieceCost;
	}
	else
	{
		if(HeadArmorButton.ArmorOwned &&  HeadStr >= 99)
			intReturnValue += ArmorPieceCost;
		else if(HeadArmorButton.ArmorOwned && HeadStr > 49)
			intReturnValue += ArmorPieceCost / DamagedArmorSellModification;
	}

	ArmorPieceCost = class'CPArmor_Body'.default.Cost;
	if(BodyArmorButton.Button.GetBool("selected"))
	{
		if(!BodyArmorButton.ArmorOwned)
			intCostValue += ArmorPieceCost;
	}
	else
	{
		if(BodyArmorButton.ArmorOwned && CPPawn(GetPC().Pawn).BodyStrength >= 99)
			intReturnValue += ArmorPieceCost;
		else if(BodyArmorButton.ArmorOwned && BodyStr > 49)
			intReturnValue += ArmorPieceCost / DamagedArmorSellModification;
	}

	ArmorPieceCost = class'CPArmor_Leg'.default.Cost;
	if(LegArmorButton.Button.GetBool("selected"))
	{
		if(!LegArmorButton.ArmorOwned)
			intCostValue += ArmorPieceCost;
	}
	else
	{
		if(LegArmorButton.ArmorOwned && CPPawn(GetPC().Pawn).LegStrength >= 99)
			intReturnValue += ArmorPieceCost;
		else if(LegArmorButton.ArmorOwned && LegStr > 49)
			intReturnValue += ArmorPieceCost / DamagedArmorSellModification;
	}
}


function UpdateClipCosting()
{
	local array<int> subPrices;

	subPrices = SubPriceClip(MeleeClipSection, MeleeWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];

	subPrices = SubPriceClip(PistolClipSection, PistolWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];

	subPrices = SubPriceClip(SMGClipSection, SMGWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];

	subPrices = SubPriceClip(RifleClipSection, RifleWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];

}

function array<int> SubPriceClip(ClipSection Clip, array<WeaponButton> theButtonGroup)
{
	local array<int> Prices;
	local int i;

	if (Clip.WeaponClass == none && Clip.AddClip == none) //dont need to check the rest - its not created them if these are both none
		return Prices;

	if(Clip.WeaponClass != none)
	{
		//refund extra clips we might have wanted to buy but did NOT YET buy
		if( Clip.NewClipAmount * Clip.WeaponClass.Default.ClipPrice >= 0)
		{
			if(Clip.WeaponClass.Default.WeaponType != WT_Shotgun)
			{
				Prices[0] = Clip.NewClipAmount * Clip.WeaponClass.Default.ClipPrice;
				Clip.ClipCost.SetString("text", "$" $ Prices[0]);
			}
			else
			{
				Prices[0] = (Clip.NewClipAmount /  class<CPWeaponShotgun>(Clip.WeaponClass).Default.ShotgunBuyAmmoCount ) * Clip.WeaponClass.Default.ClipPrice;
				Clip.ClipCost.SetString("text", "$" $ Prices[0]);
			}
		}
		else if(Clip.NewClipAmount < 0) //we own the weapon and ammo but we are trying to sell back just the ammo
		{

			if(Clip.WeaponClass.Default.WeaponType != WT_Shotgun) // todo need to find the weaponbutton with bOwnWeapon.
			{
				Prices[1] = Abs(Clip.NewClipAmount * Clip.WeaponClass.Default.ClipPrice);
				Clip.ClipCost.SetString("text", "$ -" $ Prices[1]);
			}
			else
			{
				Prices[1] = Abs((Clip.NewClipAmount /  class<CPWeaponShotgun>(Clip.WeaponClass).Default.ShotgunBuyAmmoCount ) * Clip.WeaponClass.Default.ClipPrice);
				Clip.ClipCost.SetString("text", "$ -" $ Prices[1]);
			}
		}

	}
	else if(Clip.CurrentClipAmount != 0) //refund clips we ALREADY BROUGHT - careful we only show this if the weapon + clip are being sold.
	{
		for (i = 0 ; i < theButtonGroup.Length ; i ++)
		{

			if( theButtonGroup[i].bOwnWeapon )
			{
				if(theButtonGroup[i].CurrentWeaponClass.Default.WeaponType != WT_Shotgun) // todo need to find the weaponbutton with bOwnWeapon.
				{
					Prices[1] = Abs(Clip.CurrentClipAmount * theButtonGroup[i].CurrentWeaponClass.Default.ClipPrice);
					Clip.ClipCost.SetString("text", "$ -" $ Prices[1]);
				}
				else
				{
					Prices[1] = Abs((Clip.CurrentClipAmount /  class<CPWeaponShotgun>(theButtonGroup[i].CurrentWeaponClass).Default.ShotgunBuyAmmoCount ) * theButtonGroup[i].CurrentWeaponClass.Default.ClipPrice);
					Clip.ClipCost.SetString("text", "$ -" $ Prices[1]);
				}
			}
		}
	}
	return Prices;
}

function UpdateWeaponCosting()
{
	local array<int> subPrices;

	intCostValue = 0;
	intReturnValue = 0;

	subPrices = SubPriceWeapon(MeleeWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];
	subPrices = SubPriceWeapon(PistolWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];
	subPrices = SubPriceWeapon(SMGWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];
	subPrices = SubPriceWeapon(RifleWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];
	subPrices = SubPriceWeapon(GrenadeWeaponButton);
	if(subPrices.Length >= 1)
		intCostValue += subPrices[0];
	if(subPrices.Length >= 2)
		intReturnValue += subPrices[1];

}

function array<int> SubPriceWeapon(array<WeaponButton> wBut)
{
	local int i;
	local array<int> Prices;

	for (i = 0 ; i < wBut.Length ; i++)
	{
		//need to know if this is the selected button.
		if(wBut[i].WeaponButton.GetBool("selected"))
		{
			if(wBut[i].CurrentWeaponClass == none && wBut[i].NewWeaponClass != none)
			{
				//buy
				Prices[0] = wBut[i].NewWeaponClass.default.WeaponPrice;
			}
		}
		else
		{
			//buttons off but what do we sell?
			if (wBut[i].CurrentWeaponClass != none)
			{
				//sell
				Prices[1] = wBut[i].CurrentWeaponClass.default.WeaponPrice;
			}
		}
	}

	return Prices;
}

function ShowWeapon(out array<WeaponButton> theButtonArray, CPWeapon theWeapon,out ClipSection theClip, string strClipAdd, string strClipRemove,string strClipValue,string strWeaponValue,string strWeaponButton)
{
	local bool blnFoundWeapon;
	local int i;
    
	for (i = 0 ; i < theButtonArray.Length ; i ++)
	{
		if(theButtonArray[i].WeaponButton.GetString("label") == theWeapon.ItemName)
		{
			blnFoundWeapon = true;
			theButtonArray[i].WeaponButton.SetBool("selected", true); //manually press the button
			theButtonArray[i].CurrentWeaponClass = theWeapon.Class;
            theButtonArray[i].NewWeaponClass = none;
			theButtonArray[i].bOwnWeapon       =   true; //set here to show we own this weapon.
            theButtonArray[i].bOtherTeamWeapon  =   false;
            ShowClip(theClip,theWeapon,strClipAdd, strClipRemove, strClipValue, strWeaponValue);
			break;
		}
	}
	if(!blnFoundWeapon) //did not find the weapon in the default weapon list - we need to add it because its probably a weapon from the other team...
	{
        theButtonArray.Insert( theButtonArray.Length, 1);
		theButtonArray[theButtonArray.Length - 1].WeaponButton = Setupbutton(strWeaponButton $ theButtonArray.Length, theWeapon.ItemName, true);
		theButtonArray[theButtonArray.Length - 1].WeaponButton.SetBool("selected", true); //manually press the button
        theButtonArray[theButtonArray.Length - 1].WeaponButton.SetBool("_disableFocus", true);
        theButtonArray[theButtonArray.Length - 1].CurrentWeaponClass = theWeapon.Class;
        theButtonArray[theButtonArray.Length - 1].NewWeaponClass = none; 
		theButtonArray[theButtonArray.Length - 1].bOwnWeapon = true; //set here to show we own this weapon.
        theButtonArray[theButtonArray.Length - 1].bOtherTeamWeapon = true;
        
        ShowClip(theClip,theWeapon,strClipAdd, strClipRemove, strClipValue, strWeaponValue);
	}
}

function ShowClip(out ClipSection Clip, CPWeapon theWeapon, string strClipAdd,string strClipRemove,string strClipValue,string strWeaponValue)
{
	if(theWeapon.WeaponType == WT_GRENADE)
		return;

	//show the clip section too now.
	Clip.AddClip		    = Setupbutton(strClipAdd, "+");
	Clip.RemoveClip         = Setupbutton(strClipRemove, "-");
	Clip.ClipValue          = Setuplabel(strClipValue, string(theWeapon.GetClipCount()));
	Clip.WeaponClass        = theWeapon.Class;
	Clip.CurrentClipAmount  = theWeapon.GetClipCount();
	Clip.WeaponCost         = Setuplabel(strWeaponValue, "$0");
}

function DisplayClipSection(ClipSection Clip)
{
	if (Clip.WeaponClass == none && Clip.AddClip == none) //dont need to check the rest - its not created them if these are both none
		return;

	if(Clip.WeaponClass == none)
	{
		//check here to see if the clip elements been wired up.
		Clip.AddClip.SetVisible(false);
		Clip.ClipValue.SetVisible(false);
		Clip.RemoveClip.SetVisible(false);
		Clip.ClipCost.SetVisible(false);
		Clip.WeaponCost.SetVisible(false);
	}
	else
	{
		Clip.AddClip.SetVisible(true);
		Clip.ClipValue.SetVisible(true);
		Clip.RemoveClip.SetVisible(true);
		Clip.ClipCost.SetVisible(true);
		Clip.WeaponCost.SetVisible(true);
	}
}

function PlayOpenAnimation()
{
    //OverlayMC.GotoAndPlay("open");
}

function PlayCloseAnimation()
{
    //OverlayMC.GotoAndPlay("close");
}

/** Customised for the keybind menu - this is a hook to intercept the keybinds */
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	local CPPlayerInput TAInput;
	local int BindingIdx;

	super.FilterButtonInput(ControllerID,ButtonName,InputEvent);

	TAInput = CPPlayerInput(CPPlayerController(GetPC()).PlayerInput);

	if (InputEvent == IE_Pressed && ButtonName == 'Escape')
	{
		blnCloseMenu = true;

//		if(SpinnyWeapon != none)
//			SpinnyWeapon.SetHidden(true);
		return true;
	}

	for(BindingIdx = 0;BindingIdx < TAInput.Bindings.Length;BindingIdx++)
	{
		if(TAInput.Bindings[BindingIdx].Command == "GBA_BuyMenu")
		{
			if(TAInput.Bindings[BindingIdx].Name == ButtonName)
			{
				if (InputEvent == IE_Pressed)
				{
					//close this menu
//					if(SpinnyWeapon != none)
//						SpinnyWeapon.SetHidden(true);

					blnCloseMenu = true;
					return true;
				}
			}
		}
	}
	return false;
}

function array<WeaponList> BuildWeaponData(array<string> myWeaponList)
{
	local array<WeaponList>  WeaponArray; //Moved here so its only initalised the once.
	local int i;

	WeaponArray.Length = myWeaponList.Length;

	for(i = 0 ; i < WeaponArray.Length ; i++)
	{
		WeaponArray[i].WeaponClass  = class<CPWeapon>(DynamicLoadObject(myWeaponList[i], class'Class'));
		WeaponArray[i].MaxClipCount = WeaponArray[i].WeaponClass.default.MaxClipCount - 1;
		WeaponArray[i].WeaponType   = string(WeaponArray[i].WeaponClass.default.WeaponType);
		WeaponArray[i].ItemName     = WeaponArray[i].WeaponClass.default.ItemName;

	}
	Return WeaponArray;
}

function array<WeaponList> BuildAllWeaponData()
{
	local array<WeaponList>  WeaponArraySwat, WeaponArrayMerc, WeaponArrayAll;
	local int i;

	WeaponArraySwat = BuildWeaponData(SpecialForcesWeapon);
	WeaponArrayMerc = BuildWeaponData(MercenariesWeapon);


	WeaponArrayAll.Length = WeaponArraySwat.Length + WeaponArrayMerc.Length;
	for(i = 0 ; i < WeaponArrayAll.Length ; i++)
	{
		if(i < WeaponArraySwat.Length)
		{
			WeaponArrayAll[i].ItemName = WeaponArraySwat[i].ItemName;
			WeaponArrayAll[i].MaxClipCount = WeaponArraySwat[i].MaxClipCount;
			WeaponArrayAll[i].WeaponClass = WeaponArraySwat[i].WeaponClass;
			WeaponArrayAll[i].WeaponType = WeaponArraySwat[i].WeaponType;
		}
		else
		{
			WeaponArrayAll[i] = WeaponArrayMerc[i - WeaponArraySwat.Length];
		}
	}

	return WeaponArrayAll;
}

function PopulateWeaponLists(array<WeaponList> WeaponSet)
{
	local int i;

	for(i = 0 ; i < WeaponSet.Length ; i++)
	{
		switch(WeaponSet[i].WeaponType)
		{
			case "WT_KNIFE" :
					MeleeWeaponButton.Insert( MeleeWeaponButton.Length, 1);
					MeleeWeaponButton[MeleeWeaponButton.Length - 1].WeaponButton = Setupbutton("_root.btnMeleeWeaponButton" $ MeleeWeaponButton.Length, WeaponSet[i].ItemName);
					break;
			case "WT_PISTOL" :
					PistolWeaponButton.Insert( PistolWeaponButton.Length, 1);
					PistolWeaponButton[PistolWeaponButton.Length - 1].WeaponButton = Setupbutton("_root.btnPistolWeaponButton" $ PistolWeaponButton.Length, WeaponSet[i].ItemName);
					break;
			case "WT_SMG" :
					SMGWeaponButton.Insert( SMGWeaponButton.Length, 1);
					SMGWeaponButton[SMGWeaponButton.Length - 1].WeaponButton = Setupbutton("_root.btnSMGWeaponButton" $ SMGWeaponButton.Length, WeaponSet[i].ItemName);
					break;
			case "WT_SHOTGUN" :
					SMGWeaponButton.Insert( SMGWeaponButton.Length, 1);
					SMGWeaponButton[SMGWeaponButton.Length - 1].WeaponButton = Setupbutton("_root.btnSMGWeaponButton" $ SMGWeaponButton.Length, WeaponSet[i].ItemName);
					break;
			case "WT_RIFLE" :
					RifleWeaponButton.Insert( RifleWeaponButton.Length, 1);
					RifleWeaponButton[RifleWeaponButton.Length - 1].WeaponButton = Setupbutton("_root.btnRifleWeaponButton" $ RifleWeaponButton.Length, WeaponSet[i].ItemName);
					break;
			case "WT_GRENADE" :
					GrenadeWeaponButton.Insert( GrenadeWeaponButton.Length, 1);
					GrenadeWeaponButton[GrenadeWeaponButton.Length - 1].WeaponButton = Setupbutton("_root.btnGrenadeWeaponButton" $ GrenadeWeaponButton.Length, WeaponSet[i].ItemName);
					break;

		}
	}
}

final function bool CloseMenu()
{
	return blnCloseMenu;
}

function SetMyDelegate( delegate<MousePressDetectDelegate> InDelegate)
{
    local GFxObject _global;
    _global = GetVariableObject("_global");
    ActionScriptSetFunction(_global, "RightMouseButtonPressed");
}

function GFxClikWidget Setupbutton(string strButtonObj, string strButtonTitle, optional bool blnSelect = false)
{
	local GFxClikWidget Button;

	Button = GFxClikWidget(GetVariableObject(strButtonObj , class'GFxClikWidget' ));
	Button.SetString("label", strButtonTitle);

	if(blnSelect)
	{
		Button.RemoveAllEventListeners("CLIK_select");
		Button.RemoveAllEventListeners("select");
		Button.AddEventListener('CLIK_select', OnLeftMouseButtonPressed);
	}
	else
	{
		Button.RemoveAllEventListeners("CLIK_press");
		Button.RemoveAllEventListeners("press");
		Button.AddEventListener('CLIK_press', OnLeftMouseButtonPressed);
	}
	Button.AddEventListener('CLIK_rollOver', OnFocus);
	Button.SetVisible(true);

	return Button;
}

function GFxClikWidget Setuplabel(string strLabelObj, string strLabelTitle)
{
	local GFxClikWidget Label;
	Label = GFxClikWidget(GetVariableObject(strLabelObj , class'GFxClikWidget' ));
	Label.SetString("text", strLabelTitle);
	//Label.AddEventListener('CLIK_Press', OnLeftMouseButtonPressed); TOP-Proto TODO: UNSUPPORTED: if we require this functionality we need to create a custom button.
	Label.SetVisible(true);
	return Label;
}

function HideClipSection(out ClipSection Clip)
{
	Clip.WeaponClass = none;
	Clip.AddClip.SetVisible(False);
	Clip.ClipValue.SetVisible(False);
	Clip.RemoveClip.SetVisible(False);
}

function DeselectAllButtons()
{
	local int i;

	for (i = 0 ; i < MeleeWeaponButton.Length ; i ++)
	{
		MeleeWeaponButton[i].WeaponButton.SetBool("_disableFocus", true); //manually press the button
		MeleeWeaponButton[i].WeaponButton.SetBool("selected", false); //manually press the button
	}

	for (i = 0 ; i < PistolWeaponButton.Length ; i ++)
	{
		PistolWeaponButton[i].WeaponButton.SetBool("_disableFocus", true); //manually press the button
		PistolWeaponButton[i].WeaponButton.SetBool("selected", false); //manually press the button
	}

	for (i = 0 ; i < SMGWeaponButton.Length ; i ++)
	{
		SMGWeaponButton[i].WeaponButton.SetBool("_disableFocus", true); //manually press the button
		SMGWeaponButton[i].WeaponButton.SetBool("selected", false); //manually press the button
	}

	for (i = 0 ; i < RifleWeaponButton.Length ; i ++)
	{
		RifleWeaponButton[i].WeaponButton.SetBool("_disableFocus", true); //manually press the button
		RifleWeaponButton[i].WeaponButton.SetBool("selected", false); //manually press the button
	}

	for (i = 0 ; i < GrenadeWeaponButton.Length ; i ++)
	{
		GrenadeWeaponButton[i].WeaponButton.SetBool("_disableFocus", true); //manually press the button
		GrenadeWeaponButton[i].WeaponButton.SetBool("selected", false); //manually press the button
	}
}

simulated function OnBuyNowButtonPressed()
{
	local string ShopArray;

	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    ::OnBuyNowButtonPressed");

    //logic
	//1 we cannot sell the melee weaponry at all

	//2 we can buy a weapon
	//ShopArray = ShopArray @ "CreateWeaponInventory:CriticalPoint.CPWeap_Glock";
	//3 we can sell our weapon
	//ShopArray = ShopArray @ "RemoveWeapon:CriticalPoint.CPWeap_Springfield";
	//4 we can sell our current weapon for another weapon
	//ShopArray = ShopArray @ "RemoveWeapon:CriticalPoint.CPWeap_Springfield";
	//ShopArray = ShopArray @ "CreateWeaponInventory:CriticalPoint.CPWeap_Glock";

	//5 we can buy ammo for the melee or pistol
	//ShopArray = ShopArray @ "AddClip:CriticalPoint.CPWeap_Springfield|1";
	//6 we can sell ammo for the melee or pistol
	//ShopArray = ShopArray @ "TakeClip:CriticalPoint.CPWeap_Springfield|1";


	//1 currentweaponclass will always be what we are holding in our hands. we should never change this to none.
	//2 newweaponclass will be what new weapon we select if we change the weapon.

	//1 we know if theirs a sell action as the currentweaponclass will be the weapon and the button will be off**

	ShopArray = DoClip(ShopArray, MeleeClipSection , MeleeWeaponButton)
                $ DoClip(ShopArray, PistolClipSection, PistolWeaponButton)
                $ DoClip(ShopArray, SMGClipSection, SMGWeaponButton)
                $ DoClip(ShopArray, RifleClipSection, RifleWeaponButton)
                $ DoWeapon(ShopArray, MeleeWeaponButton)
                $ DoWeapon(ShopArray, PistolWeaponButton)
                $ DoWeapon(ShopArray, SMGWeaponButton)
                $ DoWeapon(ShopArray, RifleWeaponButton)
                $ DoWeapon(ShopArray, GrenadeWeaponButton)
                $ DoArmor(ShopArray);

	//`Log("YOUR ORDER TO THE SERVER IS ");
	//`Log(ShopArray);

	CPPlayerController(GetPC()).ShoppingList(ShopArray);
	blnCloseMenu = true;
//	if(SpinnyWeapon != none)
//		SpinnyWeapon.SetHidden(true);
	//removed temp for testing
	//if(	CPPlayerController(GetPC()).ShoppingList(ShopArray))
	//{
	//	blnCloseMenu = true;
	//}
}

function string DoWeapon(string ShopArray, array<WeaponButton> wBut)
{
	local int i;
	//do this for all weapon groups!
	for (i = 0 ; i < wBut.Length ; i++)
	{
		//need to know if this is the selected button.
		if(wBut[i].WeaponButton.GetBool("selected"))
		{
            if(wBut[i].CurrentWeaponClass == none && wBut[i].NewWeaponClass != none)
			{
				//buy
				// `Log("CurrentWeaponClass" @ wBut[i].CurrentWeaponClass);
				// `Log("CreateWeaponInventory ::NewWeaponClass" @ wBut[i].NewWeaponClass);
				ShopArray $= "CreateWeaponInventory:" $ "CriticalPoint." $ wBut[i].NewWeaponClass.name $ " ";
			}
			else if (wBut[i].CurrentWeaponClass != none && wBut[i].NewWeaponClass != none)
			{
				//sell old and buy new
				// `Log("RemoveWeapon ::CurrentWeaponClass" @ wBut[i].CurrentWeaponClass);
				// `Log("CreateWeaponInventory  ::NewWeaponClass" @ wBut[i].NewWeaponClass);
				ShopArray $= "RemoveWeapon:" $ "CriticalPoint." $ wBut[i].CurrentWeaponClass.name @ "CreateWeaponInventory:" $ "CriticalPoint." $ wBut[i].NewWeaponClass.name $ " "; //must do a remove weapon before create weapon for weapons of the same group otherwise you get a weird bug when removing inventory.
			}
		}
		else
		{
			//buttons off but what do we sell?
			if (wBut[i].CurrentWeaponClass != none)
			{
				//sell
                // `Log("RemoveWeapon ::CurrentWeaponClass" @ wBut[i].CurrentWeaponClass);
				// `Log("NewWeaponClass" @ wBut[i].NewWeaponClass);
				ShopArray = "RemoveWeapon:" $ "CriticalPoint." $ wBut[i].CurrentWeaponClass.name $ " " $ ShopArray;
			}
		}
	}
	return ShopArray;
}

function string DoClip(string ShopArray, ClipSection wClip, array<WeaponButton> theButtonGroup)
{
	local int i;

	if(wClip.CurrentClipAmount != wClip.CurrentClipAmount + wClip.NewClipAmount)
	{
		if (wClip.NewClipAmount != 0)
		{
			if(wClip.NewClipAmount + wClip.NewClipAmount >  wClip.CurrentClipAmount)
			{
				// `Log("AddClip for " $ wClip.WeaponClass.name $ " Adding " $ wClip.NewClipAmount $ " Clips");
				ShopArray = ShopArray @ "AddClip:" $ "CriticalPoint." $ wClip.WeaponClass.name $ "|" $ wClip.NewClipAmount $ " ";
			}
			else if(wClip.NewClipAmount <  wClip.CurrentClipAmount)
			{
				// `Log("TakeClip for " $ wClip.WeaponClass.name $ " taking " $ wClip.NewClipAmount $ " Clips");
				ShopArray = ShopArray @ "TakeClip:" $ "CriticalPoint." $ wClip.WeaponClass.name $ "|" $ wClip.NewClipAmount $ " ";
			}
		}
	}
	else if(wClip.WeaponClass == none) // we sold the weapon so we must sell the ammo too
	{
		if (wClip.CurrentClipAmount != 0)
		{
			for (i = 0 ; i < theButtonGroup.Length ; i ++)
			{
				if( theButtonGroup[i].bOwnWeapon )
				{
					// `Log("TakeClip for " $ theButtonGroup[i].CurrentWeaponClass.name $ " taking -" $ wClip.CurrentClipAmount $ " Clips (because the weapon has been sold)");
					ShopArray = ShopArray @ "TakeClip:" $ "CriticalPoint." $ theButtonGroup[i].CurrentWeaponClass.name $ "|-" $ wClip.CurrentClipAmount $ " ";
				}
			}
		}
	}
	return ShopArray;
}

function string DoArmor(string ShopArray)
{
	local CPArmor Inv;

	if(HeadArmorButton.Button.GetBool("selected"))
	{
		//BUY
		Inv=CPArmor(GetPC().Pawn.InvManager.FindInventoryType(class'CriticalPoint.CPArmor_Head',true));
		if(Inv==none || inv.Health < ArmorRangeLow)
			ShopArray=ShopArray@"CreateInventory:CriticalPoint.CPArmor_Head";
		else
		{
//			if(HeadArmorButton.bRepairMode)
//				ShopArray=ShopArray@"CreateInventory:CriticalPoint.CPArmor_Head";
		}
	}
	else
	{
		//SELL
		Inv=CPArmor(GetPC().Pawn.InvManager.FindInventoryType(class'CriticalPoint.CPArmor_Head',true));
		if (Inv!=none && inv.Health < 100)
			ShopArray=ShopArray@"RemoveArmorFromInventory:CriticalPoint.CPArmor_Head";
	}

	if(BodyArmorButton.Button.GetBool("selected"))
	{
		//BUY
		Inv=CPArmor(GetPC().Pawn.InvManager.FindInventoryType(class'CriticalPoint.CPArmor_Body',true));

		if(Inv==none || CPPawn(GetPC().Pawn).BodyStrength*100 < ArmorRangeLow)
				ShopArray=ShopArray@"CreateInventory:CriticalPoint.CPArmor_Body";
		else
		{
//			if (BodyArmorButton.bRepairMode)
//				ShopArray=ShopArray@"CreateInventory:CriticalPoint.CPArmor_Body";
		}
	}
	else
	{
		//SELL
		Inv=CPArmor(GetPC().Pawn.InvManager.FindInventoryType(class'CriticalPoint.CPArmor_Body',true));
		if (Inv!=none && inv.Health < 100)
			ShopArray=ShopArray@"RemoveArmorFromInventory:CriticalPoint.CPArmor_Body";
	}

	if(LegArmorButton.Button.GetBool("selected"))
	{
		//BUY
		Inv=CPArmor(GetPC().Pawn.InvManager.FindInventoryType(class'CriticalPoint.CPArmor_Leg',true));
		if (Inv==none || CPPawn(GetPC().Pawn).LegStrength*100 < ArmorRangeLow)
			ShopArray=ShopArray@"CreateInventory:CriticalPoint.CPArmor_Leg";
		else
		{
//			if(LegArmorButton.bRepairMode)
//				ShopArray=ShopArray@"CreateInventory:CriticalPoint.CPArmor_Leg";
		}
	}
	else
	{
		//SELL
		Inv=CPArmor(GetPC().Pawn.InvManager.FindInventoryType(class'CriticalPoint.CPArmor_Leg',true));
		if (Inv!=none && inv.Health < 100)
			ShopArray=ShopArray@"RemoveArmorFromInventory:CriticalPoint.CPArmor_Leg";
	}
	return ShopArray;
}

function DeselectAllButtonsFromWeaponGroupExceptOneSelected(array<WeaponButton> theButtonGroup, WeaponButton theSelectedBtn)
{
	local int i;

    //go though the array and unselect all buttons that are not the selected one.
	for (i = 0 ; i < theButtonGroup.Length ; i++)
	{
		theButtonGroup[i].WeaponButton.RemoveAllEventListeners("CLIK_select");
		theButtonGroup[i].WeaponButton.RemoveAllEventListeners("select");
		if(theButtonGroup[i].WeaponButton.GetBool("selected") && theButtonGroup[i] != theSelectedBtn) //if the buttons on and its not the button we just pressed...
		{
            theButtonGroup[i].WeaponButton.SetBool("_disableFocus", true);
			theButtonGroup[i].WeaponButton.SetBool("selected", false); // turn off the button
		}
		theButtonGroup[i].WeaponButton.AddEventListener('CLIK_select', OnLeftMouseButtonPressed);
	}
}

function WeaponButton CheckToggleStatus(array<WeaponButton> theButtonGroup, WeaponButton theSelectedBtn, out ClipSection Clip, optional int index = 0)
{
    
    if(blnRightMousePressed)
	{
        if(theSelectedBtn.CurrentWeaponClass != none)
		{
            theSelectedBtn.WeaponButton.RemoveAllEventListeners("CLIK_select");
			theSelectedBtn.WeaponButton.RemoveAllEventListeners("select");
			//have to manually press the button...
			theSelectedBtn.WeaponButton.SetBool("selected", true);
			theSelectedBtn.WeaponButton.AddEventListener('CLIK_select', OnLeftMouseButtonPressed);
		}
	}
    
    if(theSelectedBtn.bOtherTeamWeapon)
    {
        theSelectedBtn.WeaponButton.RemoveAllEventListeners("CLIK_select");
        theSelectedBtn.WeaponButton.RemoveAllEventListeners("select");
        if(theSelectedBtn.WeaponButton.GetBool("selected"))
        {
           theSelectedBtn.WeaponButton.SetBool("selected", false); 
        }
        else
        {
            theSelectedBtn.WeaponButton.SetBool("selected", true);
        }
        theSelectedBtn.WeaponButton.AddEventListener('CLIK_select', OnLeftMouseButtonPressed);
        
        //TestClassVar = GetWeaponClassForButton(theSelectedBtn);
        if( ClassIsChildOf(GetWeaponClassForButton(theSelectedBtn), class'CPMeleeWeapon') )
        {
            theSelectedBtn.NewWeaponClass = None;
            theSelectedBtn.CurrentWeaponClass = GetWeaponClassForButton(theSelectedBtn);
        }
        
    }
    
    DeselectAllButtonsFromWeaponGroupExceptOneSelected(theButtonGroup, theSelectedBtn);

	//show the clip section
	Clip.WeaponClass = GetWeaponClassForButton(theSelectedBtn);


	if(theSelectedBtn.WeaponButton.GetBool("selected"))
	{
        theSelectedBtn.NewWeaponClass = Clip.WeaponClass;

		//add the weapon cost here, but make sure we add the cost if we own the weapon!
		if(!theSelectedBtn.bOwnWeapon)
		{
			Clip.WeaponCost.SetString("text", "$" $ string(Clip.WeaponClass.default.WeaponPrice) );

			if(Clip.ClipValue != none) //grenades its none
				Clip.ClipValue.SetString("text", "0");

		}
		else
		{
			Clip.WeaponCost.SetString("text", "$0");

			//since we own the weapon, do we have any clips with it?
			if(Clip.ClipValue != none) //grenades its none
				Clip.ClipValue.SetString("text",string(Clip.CurrentClipAmount));
		}

		if(blnRightMousePressed)
		{
			//`Log("adding all clips - rightmouse pressed");
			OnClipAddAll(Clip);
		}
	}

	return theSelectedBtn;
}

function class<CPWeapon> GetWeaponClassForButton(WeaponButton theButton)
{
	local int i;

	for (i = 0 ; i < AllWeaponsList.Length ; i++)
	{
		if(AllWeaponsList[i].ItemName == theButton.WeaponButton.GetString("label"))
		{
			return AllWeaponsList[i].WeaponClass;
		}
	}

	return none;
}

function OnClipAdd(out ClipSection Clip)
{
	local int CurrentClipValue;
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    OnClipAdd::" @ Clip.WeaponClass.default.ItemName);
	CurrentClipValue = int(Clip.ClipValue.GetString("text"));

	if(Clip.WeaponClass.default.WeaponType == WT_Shotgun)
	{
		if( CurrentClipValue >= (Clip.WeaponClass.Default.MaxClipCount))
		{
			Clip.ClipValue.SetString("text",string(Clip.WeaponClass.Default.MaxClipCount));

			if(Clip.CurrentClipAmount == Clip.WeaponClass.Default.MaxClipCount)
			{
				Clip.NewClipAmount = 0; //do not add or try to buy clips if we own maxclips
			}
		}
		else
		{
			if(CurrentClipValue + class<CPWeaponShotgun>(Clip.WeaponClass).default.ShotgunBuyAmmoCount < Clip.WeaponClass.Default.MaxClipCount)
			{
				Clip.ClipValue.SetString("text",string(CurrentClipValue + class<CPWeaponShotgun>(Clip.WeaponClass).default.ShotgunBuyAmmoCount));
				Clip.NewClipAmount = Clip.NewClipAmount + class<CPWeaponShotgun>(Clip.WeaponClass).default.ShotgunBuyAmmoCount;
			}
			else
			{
				Clip.ClipValue.SetString("text",string(class<CPWeaponShotgun>(Clip.WeaponClass).Default.MaxClipCount));
				Clip.NewClipAmount = Clip.WeaponClass.Default.MaxClipCount;
			}
		}
	}
	else
	{
		if( CurrentClipValue >= (Clip.WeaponClass.Default.MaxClipCount))
		{
			Clip.ClipValue.SetString("text",string(Clip.WeaponClass.Default.MaxClipCount));

			if(Clip.CurrentClipAmount == Clip.WeaponClass.Default.MaxClipCount)
			{
				Clip.NewClipAmount = 0; //do not add or try to buy clips if we own maxclips
			}

			if(Clip.NewClipAmount >= (Clip.WeaponClass.Default.MaxClipCount))
			{
				Clip.NewClipAmount = Clip.WeaponClass.Default.MaxClipCount;
			}

		}
		else
		{
			Clip.ClipValue.SetString("text",string(CurrentClipValue + 1));
			Clip.NewClipAmount = Clip.NewClipAmount + 1; //add one new clip
		}
	}
}

function OnClipRemove(out ClipSection Clip)
{
	local int CurrentClipValue;
	//`Log("GFxCPBuyMenu::    LEFT MOUSE PRESSED    OnClipRemove::" @ Clip.WeaponClass.default.ItemName);

	if(CurrentClipValue == 0 && int(Clip.ClipValue.GetString("text")) == 0)
		return;

	CurrentClipValue = int(Clip.ClipValue.GetString("text"));

	if(Clip.WeaponClass.default.WeaponType == WT_Shotgun)
	{
		if( CurrentClipValue <= 0)
		{
			Clip.ClipValue.SetString("text",string(0));
			Clip.NewClipAmount = 0; //do not remove or try to buy clips if we own no clips
		}
		else
		{
			if(CurrentClipValue - class<CPWeaponShotgun>(Clip.WeaponClass).default.ShotgunBuyAmmoCount >= 0)
			{
				Clip.ClipValue.SetString("text",string(CurrentClipValue - class<CPWeaponShotgun>(Clip.WeaponClass).default.ShotgunBuyAmmoCount));
				Clip.NewClipAmount = Clip.NewClipAmount - class<CPWeaponShotgun>(Clip.WeaponClass).default.ShotgunBuyAmmoCount;

			}
			else
			{
				Clip.ClipValue.SetString("text","0");
				Clip.NewClipAmount = 0;
			}
		}
	}
	else
	{
		if( CurrentClipValue <= 0)
		{
			Clip.ClipValue.SetString("text",string(0));
			Clip.NewClipAmount = 0; //do not remove or try to buy clips if we own no clips
		}
		else
		{
			Clip.ClipValue.SetString("text",string(CurrentClipValue -1));
			Clip.NewClipAmount = Clip.NewClipAmount--; //take away one clip
		}
	}
}

function OnClipAddAll(out ClipSection Clip)
{
	local int i;

	if(Clip.WeaponClass == none)
		return;

    if(Clip.WeaponClass.default.WeaponType == WT_GRENADE)
		return; //grenades dont have clips

	for(i = 0 ; i < Clip.WeaponClass.Default.MaxClipCount; i++)
	{
		OnClipAdd(Clip);
	}
}

function OnClipRemoveAll(out ClipSection Clip)
{
	local int i;

	if(Clip.WeaponClass.default.WeaponType == WT_GRENADE)
		return; //grenades dont have clips

	for(i = 0 ; i < Clip.WeaponClass.Default.MaxClipCount; i++)
	{
		OnClipRemove(Clip);
	}
}

///** ARMOR FUNCTIONS */
function ToggleAllArmorButtons()
{
	if(!blnArmorToggle)
	{
		blnArmorToggle= true;
		HeadArmorButton.Button.SetBool("selected", true); //manually press the button
		BodyArmorButton.Button.SetBool("selected", true); //manually press the button
		LegArmorButton.Button.SetBool("selected", true); //manually press the button
	}
	else
	{
		blnArmorToggle= false;
		HeadArmorButton.Button.SetBool("selected", false); //manually press the button
		BodyArmorButton.Button.SetBool("selected", false); //manually press the button
		LegArmorButton.Button.SetBool("selected", false); //manually press the button
	}

}
//function ToggleAllArmorButtons()
//{
//	local bool blnRepairmode;

//	blnRepairmode = SetRepairMode(); //set the repair mode early.
//	CheckSync();
//	SetArmorMode(HeadArmorButton, blnRepairmode);
//	SetArmorMode(BodyArmorButton, blnRepairmode);
//	SetArmorMode(LegArmorButton, blnRepairmode);
//	//basic logic we should always select all, then deselect all if repressed except if theyre all pressed anyway.
//}

//function CheckSync()
//{
//	if(HeadArmorButton.Button.GetBool("selected") && BodyArmorButton.Button.GetBool("selected") && LegArmorButton.Button.GetBool("selected"))
//	{
////
//	}
//	else if (!HeadArmorButton.Button.GetBool("selected") && !BodyArmorButton.Button.GetBool("selected") && !LegArmorButton.Button.GetBool("selected"))
//	{
////
//	}
//	else
//	{
//		//setup the buttons to sync.
//		HeadArmorButton.Button.SetBool("selected" , true);
//		BodyArmorButton.Button.SetBool("selected" , true);
//		LegArmorButton.Button.SetBool("selected" , true);
//		HeadArmorButton.bRepairMode = false;
//		BodyArmorButton.bRepairMode = false;
//		LegArmorButton.bRepairMode = false;
//	}
//}

//function SetArmorMode(out ArmorButton ArmButton, bool blnRepairmode)
//{
//	if(!ArmButton.Button.GetBool("selected"))
//	{
//		//`Log("TOGGLE BUTTON ON");
//		ArmButton.Button.SetBool("selected" , true);
//		ArmButton.bRepairMode = false;
//		blnArmorSelected = true;
//	}
//	else
//	{
//		//go to REPAIR before BUTTON OFF
//		if(blnRepairmode && !ArmButton.bRepairMode)
//		{
//			//`Log("TOGGLE BUTTON REPAIR");
//			ArmButton.bRepairMode = true;
//			ArmButton.Button.SetBool("selected" , true);
//			blnArmorSelected = true;
//		}
//		else
//		{
//			//`Log("TOGGLE BUTTON OFF");
//			ArmButton.bRepairMode = false;
//			ArmButton.Button.SetBool("selected" , false);
//			blnArmorSelected = false;
//		}
//	}
//}

//function bool SetRepairMode()
//{
//	if(CPPawn(GetPC().Pawn).GetHeadArmorStrength() != 100 && CPPawn(GetPC().Pawn).GetHeadArmorStrength() != 0)
//	{
//			return true;
//	}

//	if(CPPawn(GetPC().Pawn).GetBodyArmorStrength() != 100 && CPPawn(GetPC().Pawn).GetBodyArmorStrength() != 0)
//	{
//			return true;
//	}

//	if(CPPawn(GetPC().Pawn).GetLegArmorStrength() != 100 && CPPawn(GetPC().Pawn).GetLegArmorStrength() != 0)
//	{
//			return true;
//	}

//	return false;
//}


/** what a right fucked up thing this is!! TOP-Proto */
function UpdateArmorElement(ArmorButton ArmButton, string strButtonText, int ArmorPercentage)
{
	local string strArmorText;
	strArmorText = ArmButton.ArmorButtonText.GetText();

	if(strArmorText != strButtonText)// $ " " $ string(ArmorPercentage) $ "%")
		ArmButton.ArmorButtonText.SetText(strButtonText $ " " $ string(ArmorPercentage) $ "%");

	//if(CPPawn(GetPC().Pawn) != none)
	//{
	//	if(ArmButton.ArmorOwned)
	//	{
	//		//ensure we follow the loop
	//		//If i own this armor
	//		//BUTTON ON --> REPAIR --> BUTTON OFF (loop)

	//		if( ArmorPercentage != 100 && ArmorPercentage != 0)
	//		{
	//			if(ArmButton.bRepairMode)
	//			{
	//				//`Log("BUTTON REPAIR MODE");
	//				ArmButton.Button.SetBool("selected", true);
	//				ArmButton.ArmorButtonText.SetColorTransform(SetArmorColor(100));
	//				ArmButton.ArmorButtonText.SetText(strButtonText @ 100 $ "%");
	//			}
	//			else
	//			{
	//				if(ArmButton.Button.GetBool("selected"))
	//				{
	//					//`Log("BUTTON ON");
	//					ArmButton.ArmorButtonText.SetColorTransform(SetArmorColor(ArmorPercentage));
	//					ArmButton.ArmorButtonText.SetText(strButtonText @ ArmorPercentage $ "%");
	//				}
	//				else
	//				{
	//					//`Log("BUTTON OFF");
	//					ArmButton.ArmorButtonText.SetColorTransform(SetArmorColor(100));
	//					ArmButton.ArmorButtonText.SetText(strButtonText @ 0 $ "%");
	//				}
	//			}
	//		}
	//		else
	//		{
	//			if(ArmButton.Button.GetBool("selected"))
	//			{
	//				ArmButton.ArmorButtonText.SetColorTransform(SetArmorColor(100));
	//				ArmButton.ArmorButtonText.SetText(strButtonText @ 100 $ "%");
	//			}
	//			else
	//			{
	//				ArmButton.ArmorButtonText.SetColorTransform(SetArmorColor(100));
	//				ArmButton.ArmorButtonText.SetText(strButtonText @ 0 $ "%");
	//			}
	//		}
	//	}
	//	else
	//	{
	//		if(ArmButton.Button.GetBool("selected"))
	//		{
	//			ArmButton.ArmorButtonText.SetColorTransform(SetArmorColor(100));
	//			ArmButton.ArmorButtonText.SetText(strButtonText @ 100 $ "%");
	//		}
	//		else
	//		{
	//			ArmButton.ArmorButtonText.SetColorTransform(SetArmorColor(100));
	//			ArmButton.ArmorButtonText.SetText(strButtonText @ 0 $ "%");
	//		}
	//	}
	//}
}

function ASColorTransform SetArmorColor(int ArmorValue)
{
	local ASColorTransform Cxform;

	if(ArmorValue >= 100 || ArmorValue == 0)
	{
		Cxform = BLACK;
		return Cxform;
	}

	Cxform = ( ArmorValue < 75 ) ? ( ArmorValue < 50 ) ? ( ArmorValue < 25 ) ? LIGHTRED : YELLOW : LIGHTGREEN : DARKGREEN;
	return Cxform;
}

defaultproperties
{

	MovieInfo=SwfMovie'TA_BuyMenu.TABuyMenu'
	blnCloseMenu=false
	bCaptureInput=true
	bIgnoreMouseInput = false

	LIGHTGREEN=(add=(R=128,G=236,B=12,A=0))
	DARKGREEN=(add=(R=57,G=106,B=4,A=0))
	YELLOW=(add=(R=255,G=255,B=0,A=0))
	LIGHTRED=(add=(R=236,G=102,B=102,A=0))
	BLACK=(add=(R=0,G=0,B=0,A=0))

	bEnableGammaCorrection=false

	ArmorRangeHigh=100
	ArmorRangeLow=50
	DamagedArmorSellModification=1
}
