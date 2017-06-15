class CPI_FrontEnd_BuyMenu extends CPIFrontEnd_Screen
    config(UI);
//Main action buttons
var GFxClikWidget btnBuyNow, btnCancel, btnReset;
var localized string btnBuyNowText, btnCancelText, btnResetText;
//used later on for the saved weapon presets.
var GFxClikWidget btnPreset1, btnPreset2, btnPreset3, btnPreset4, btnPreset5, btnSave;
//Melee buttons
var GFxClikWidget btnMeleeWeaponButton1, btnMeleeWeaponButton2, btnMeleeWeaponButton3, btnMeleeWeaponButton4, btnMeleeWeaponButton5, btnMeleeWeaponButton6, btnMeleeWeaponButton7, btnMeleeWeaponButton8;
var localized string btnMeleeWeaponButton1Text, btnMeleeWeaponButton2Text, btnMeleeWeaponButton3Text, btnMeleeWeaponButton4Text, btnMeleeWeaponButton5Text, btnMeleeWeaponButton6Text, btnMeleeWeaponButton7Text, btnMeleeWeaponButton8Text;
//Pistol buttons
var GFxClikWidget btnPistolWeaponButton1, btnPistolWeaponButton2, btnPistolWeaponButton3, btnPistolWeaponButton4, btnPistolWeaponButton5, btnPistolWeaponButton6, btnPistolWeaponButton7, btnPistolWeaponButton8;
var localized string btnPistolWeaponButton1Text, btnPistolWeaponButton2Text, btnPistolWeaponButton3Text, btnPistolWeaponButton4Text, btnPistolWeaponButton5Text, btnPistolWeaponButton6Text, btnPistolWeaponButton7Text, btnPistolWeaponButton8Text;
//SMG buttons
var GFxClikWidget btnSMGWeaponButton1, btnSMGWeaponButton2, btnSMGWeaponButton3, btnSMGWeaponButton4, btnSMGWeaponButton5, btnSMGWeaponButton6, btnSMGWeaponButton7, btnSMGWeaponButton8;
var localized string btnSMGWeaponButton1Text, btnSMGWeaponButton2Text, btnSMGWeaponButton3Text, btnSMGWeaponButton4Text, btnSMGWeaponButton5Text, btnSMGWeaponButton6Text, btnSMGWeaponButton7Text, btnSMGWeaponButton8Text;
//Rifle buttons
var GFxClikWidget btnRifleWeaponButton1, btnRifleWeaponButton2, btnRifleWeaponButton3, btnRifleWeaponButton4, btnRifleWeaponButton5, btnRifleWeaponButton6, btnRifleWeaponButton7, btnRifleWeaponButton8;
var localized string btnRifleWeaponButton1Text, btnRifleWeaponButton2Text, btnRifleWeaponButton3Text, btnRifleWeaponButton4Text, btnRifleWeaponButton5Text, btnRifleWeaponButton6Text, btnRifleWeaponButton7Text, btnRifleWeaponButton8Text;
//Grenade buttons
var GFxClikWidget btnGrenadeWeaponButton1, btnGrenadeWeaponButton2, btnGrenadeWeaponButton3, btnGrenadeWeaponButton4, btnGrenadeWeaponButton5, btnGrenadeWeaponButton6, btnGrenadeWeaponButton7, btnGrenadeWeaponButton8;
var localized string btnGrenadeWeaponButton1Text, btnGrenadeWeaponButton2Text, btnGrenadeWeaponButton3Text, btnGrenadeWeaponButton4Text, btnGrenadeWeaponButton5Text, btnGrenadeWeaponButton6Text, btnGrenadeWeaponButton7Text, btnGrenadeWeaponButton8Text;
//Armor and Night Vision buttons
var GFxClikWidget btnHeadArmor, btnBodyArmor, btnLegArmor, btnNightVision;
var localized string btnHeadArmorText, btnBodyArmorText, btnLegArmorText, btnNightVisionText;
//Melee Clip buttons
var GFxClikWidget btnMeleeWeaponClipAdd, btnMeleeWeaponClipRemove;
var localized string btnMeleeWeaponClipAddText, btnMeleeWeaponClipRemoveText;
//Pistol Clip Buttons
var GFxClikWidget btnPistolWeaponClipAdd, btnPistolWeaponClipRemove;
var localized string btnPistolWeaponClipAddText, btnPistolWeaponClipRemoveText;
//SMG Clip Buttons
var GFxClikWidget btnSMGWeaponClipAdd, btnSMGWeaponClipRemove;
var localized string btnSMGWeaponClipAddText, btnSMGWeaponClipRemoveText;
//Rifle Clip Buttons
var GFxClikWidget btnRifleWeaponClipAdd, btnRifleWeaponClipRemove;
var localized string btnRifleWeaponClipAddText, btnRifleWeaponClipRemoveText;
//Weapon Titles
var GFxObject SMGTitle, RifleTitle, GrenadeTitle, PistolTitle, MeleeTitle;
var localized string SMGTitleText, RifleTitleText, GrenadeTitleText, PistolTitleText, MeleeTitleText;
//Ammo Titles (check are these clik or objects)
var GFxObject MeleeAmmo, PistolAmmo, SMGAmmo, RifleAmmo;
var localized string MeleeAmmoText, PistolAmmoText, SMGAmmoText, RifleAmmoText;
//Weapon Clip Value Labels (check what these are...)
var GFxObject lblSMGWeaponClipValue, lblPistolWeaponClipValue, lblMeleeWeaponClipValue, lblRifleWeaponClipValue;
var localized string lblSMGWeaponClipValueText, lblPistolWeaponClipValueText, lblMeleeWeaponClipValueText, lblRifleWeaponClipValueText;
//Weapon Clip(S) Value Labels (check what these are...)
var GFxObject lblRifleClipsValue, lblMeleeClipsValue, lblSMGClipsValue, lblPistolClipsValue;
var localized string lblRifleClipsValueText, lblMeleeClipsValueText, lblSMGClipsValueText, lblPistolClipsValueText;
//Weapon Values
var GFxObject lblPistolValue, lblSMGValue, lblRifleValue, lblGrenadeValue, lblMeleeValue;
var localized string lblPistolValueText, lblSMGValueText, lblRifleValueText, lblGrenadeValueText, lblMeleeValueText;
//Buy Menu Calculations
var GFxObject lblWallet, lblCost, lblReturn, lblCash, lblValue;
var localized string lblWalletText, lblCostText, lblReturnText, lblCashText, lblValueText;

function InitBuyMenu()
{
	SetVisible(true);
	CheckPlayersInventory();
}

function OnEscapeKeyPress()
{
	MoveBackImpl();
	CPHud(GetPC().myHUD).CloseFrontend();
}

event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
	local bool bWasHandled;
	
	bWasHandled=false;

	switch(WidgetName)
	{
		case ('btnBuyNow'):
			btnBuyNow=GFxClikWidget(Widget);
			btnBuyNow.SetString("label",btnBuyNowText);
			btnBuyNow.AddEventListener('CLIK_press',Select_btnBuyNow);
			bWasHandled=true; 
		break;	
		case ('btnReset'):
			btnReset=GFxClikWidget(Widget);
			btnReset.SetString("label",btnResetText);
			btnReset.AddEventListener('CLIK_press',Select_btnReset);
			bWasHandled=true; 
		break;	
		case ('btnCancel'):
			btnCancel=GFxClikWidget(Widget);
			btnCancel.SetString("label",btnCancelText);
			btnCancel.AddEventListener('CLIK_press',Select_btnCancel);
			bWasHandled=true; 
		break;	
		case ('btnPreset1'):
			btnPreset1=GFxClikWidget(Widget);
			//Disabled for future usage.
			btnPreset1.SetVisible(false);
			bWasHandled=true; 
		break;		
		case ('btnPreset2'):
			btnPreset2=GFxClikWidget(Widget);
			//Disabled for future usage.
			btnPreset2.SetVisible(false);
			bWasHandled=true; 
		break;		
		case ('btnPreset3'):
			btnPreset3=GFxClikWidget(Widget);
			//Disabled for future usage.
			btnPreset3.SetVisible(false);
			bWasHandled=true; 
		break;		
		case ('btnPreset4'):
			btnPreset4=GFxClikWidget(Widget);
			//Disabled for future usage.
			btnPreset4.SetVisible(false);
			bWasHandled=true; 
		break;		
		case ('btnPreset5'):
			btnPreset5=GFxClikWidget(Widget);
			//Disabled for future usage.
			btnPreset5.SetVisible(false);
			bWasHandled=true; 
		break;	
		case ('btnSave'):
			btnSave=GFxClikWidget(Widget);
			//Disabled for future usage.
			btnSave.SetVisible(false);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton1'):
			btnMeleeWeaponButton1=GFxClikWidget(Widget);
			btnMeleeWeaponButton1.SetString("label",btnMeleeWeaponButton1Text);
			btnMeleeWeaponButton1.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton1);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton2'):
			btnMeleeWeaponButton2=GFxClikWidget(Widget);
			btnMeleeWeaponButton2.SetString("label",btnMeleeWeaponButton2Text);
			btnMeleeWeaponButton2.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton2);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton3'):
			btnMeleeWeaponButton3=GFxClikWidget(Widget);
			btnMeleeWeaponButton3.SetString("label",btnMeleeWeaponButton3Text);
			btnMeleeWeaponButton3.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton3);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton4'):
			btnMeleeWeaponButton4=GFxClikWidget(Widget);
			btnMeleeWeaponButton4.SetString("label",btnMeleeWeaponButton4Text);
			btnMeleeWeaponButton4.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton4);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton5'):
			btnMeleeWeaponButton5=GFxClikWidget(Widget);
			btnMeleeWeaponButton5.SetString("label",btnMeleeWeaponButton5Text);
			btnMeleeWeaponButton5.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton5);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton6'):
			btnMeleeWeaponButton6=GFxClikWidget(Widget);
			btnMeleeWeaponButton6.SetString("label",btnMeleeWeaponButton6Text);
			btnMeleeWeaponButton6.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton6);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton7'):
			btnMeleeWeaponButton7=GFxClikWidget(Widget);
			btnMeleeWeaponButton7.SetString("label",btnMeleeWeaponButton7Text);
			btnMeleeWeaponButton7.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton7);
			bWasHandled=true; 
		break;	
		case ('btnMeleeWeaponButton8'):
			btnMeleeWeaponButton8=GFxClikWidget(Widget);
			btnMeleeWeaponButton8.SetString("label",btnMeleeWeaponButton8Text);
			btnMeleeWeaponButton8.AddEventListener('CLIK_press',Select_btnMeleeWeaponButton8);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton1'):
			btnPistolWeaponButton1=GFxClikWidget(Widget);
			btnPistolWeaponButton1.SetString("label",btnPistolWeaponButton1Text);
			btnPistolWeaponButton1.AddEventListener('CLIK_press',Select_btnPistolWeaponButton1);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton2'):
			btnPistolWeaponButton2=GFxClikWidget(Widget);
			btnPistolWeaponButton2.SetString("label",btnPistolWeaponButton2Text);
			btnPistolWeaponButton2.AddEventListener('CLIK_press',Select_btnPistolWeaponButton2);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton3'):
			btnPistolWeaponButton3=GFxClikWidget(Widget);
			btnPistolWeaponButton3.SetString("label",btnPistolWeaponButton3Text);
			btnPistolWeaponButton3.AddEventListener('CLIK_press',Select_btnPistolWeaponButton3);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton4'):
			btnPistolWeaponButton4=GFxClikWidget(Widget);
			btnPistolWeaponButton4.SetString("label",btnPistolWeaponButton4Text);
			btnPistolWeaponButton4.AddEventListener('CLIK_press',Select_btnPistolWeaponButton4);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton5'):
			btnPistolWeaponButton5=GFxClikWidget(Widget);
			btnPistolWeaponButton5.SetString("label",btnPistolWeaponButton5Text);
			btnPistolWeaponButton5.AddEventListener('CLIK_press',Select_btnPistolWeaponButton5);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton6'):
			btnPistolWeaponButton6=GFxClikWidget(Widget);
			btnPistolWeaponButton6.SetString("label",btnPistolWeaponButton6Text);
			btnPistolWeaponButton6.AddEventListener('CLIK_press',Select_btnPistolWeaponButton6);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton7'):
			btnPistolWeaponButton7=GFxClikWidget(Widget);
			btnPistolWeaponButton7.SetString("label",btnPistolWeaponButton7Text);
			btnPistolWeaponButton7.AddEventListener('CLIK_press',Select_btnPistolWeaponButton7);
			bWasHandled=true; 
		break;	
		case ('btnPistolWeaponButton8'):
			btnPistolWeaponButton8=GFxClikWidget(Widget);
			btnPistolWeaponButton8.SetString("label",btnPistolWeaponButton8Text);
			btnPistolWeaponButton8.AddEventListener('CLIK_press',Select_btnPistolWeaponButton8);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton1'):
			btnSMGWeaponButton1=GFxClikWidget(Widget);
			btnSMGWeaponButton1.SetString("label",btnSMGWeaponButton1Text);
			btnSMGWeaponButton1.AddEventListener('CLIK_press',Select_btnSMGWeaponButton1);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton2'):
			btnSMGWeaponButton2=GFxClikWidget(Widget);
			btnSMGWeaponButton2.SetString("label",btnSMGWeaponButton2Text);
			btnSMGWeaponButton2.AddEventListener('CLIK_press',Select_btnSMGWeaponButton2);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton3'):
			btnSMGWeaponButton3=GFxClikWidget(Widget);
			btnSMGWeaponButton3.SetString("label",btnSMGWeaponButton3Text);
			btnSMGWeaponButton3.AddEventListener('CLIK_press',Select_btnSMGWeaponButton3);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton4'):
			btnSMGWeaponButton4=GFxClikWidget(Widget);
			btnSMGWeaponButton4.SetString("label",btnSMGWeaponButton4Text);
			btnSMGWeaponButton4.AddEventListener('CLIK_press',Select_btnSMGWeaponButton4);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton5'):
			btnSMGWeaponButton5=GFxClikWidget(Widget);
			btnSMGWeaponButton5.SetString("label",btnSMGWeaponButton5Text);
			btnSMGWeaponButton5.AddEventListener('CLIK_press',Select_btnSMGWeaponButton5);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton6'):
			btnSMGWeaponButton6=GFxClikWidget(Widget);
			btnSMGWeaponButton6.SetString("label",btnSMGWeaponButton6Text);
			btnSMGWeaponButton6.AddEventListener('CLIK_press',Select_btnSMGWeaponButton6);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton7'):
			btnSMGWeaponButton7=GFxClikWidget(Widget);
			btnSMGWeaponButton7.SetString("label",btnSMGWeaponButton7Text);
			btnSMGWeaponButton7.AddEventListener('CLIK_press',Select_btnSMGWeaponButton7);
			bWasHandled=true; 
		break;	
		case ('btnSMGWeaponButton8'):
			btnSMGWeaponButton8=GFxClikWidget(Widget);
			btnSMGWeaponButton8.SetString("label",btnSMGWeaponButton8Text);
			btnSMGWeaponButton8.AddEventListener('CLIK_press',Select_btnSMGWeaponButton8);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton1'):
			btnRifleWeaponButton1=GFxClikWidget(Widget);
			btnRifleWeaponButton1.SetString("label",btnRifleWeaponButton1Text);
			btnRifleWeaponButton1.AddEventListener('CLIK_press',Select_btnRifleWeaponButton1);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton2'):
			btnRifleWeaponButton2=GFxClikWidget(Widget);
			btnRifleWeaponButton2.SetString("label",btnRifleWeaponButton2Text);
			btnRifleWeaponButton2.AddEventListener('CLIK_press',Select_btnRifleWeaponButton2);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton3'):
			btnRifleWeaponButton3=GFxClikWidget(Widget);
			btnRifleWeaponButton3.SetString("label",btnRifleWeaponButton3Text);
			btnRifleWeaponButton3.AddEventListener('CLIK_press',Select_btnRifleWeaponButton3);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton4'):
			btnRifleWeaponButton4=GFxClikWidget(Widget);
			btnRifleWeaponButton4.SetString("label",btnRifleWeaponButton4Text);
			btnRifleWeaponButton4.AddEventListener('CLIK_press',Select_btnRifleWeaponButton4);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton5'):
			btnRifleWeaponButton5=GFxClikWidget(Widget);
			btnRifleWeaponButton5.SetString("label",btnRifleWeaponButton5Text);
			btnRifleWeaponButton5.AddEventListener('CLIK_press',Select_btnRifleWeaponButton5);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton6'):
			btnRifleWeaponButton6=GFxClikWidget(Widget);
			btnRifleWeaponButton6.SetString("label",btnRifleWeaponButton6Text);
			btnRifleWeaponButton6.AddEventListener('CLIK_press',Select_btnRifleWeaponButton6);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton7'):
			btnRifleWeaponButton7=GFxClikWidget(Widget);
			btnRifleWeaponButton7.SetString("label",btnRifleWeaponButton7Text);
			btnRifleWeaponButton7.AddEventListener('CLIK_press',Select_btnRifleWeaponButton7);
			bWasHandled=true; 
		break;	
		case ('btnRifleWeaponButton8'):
			btnRifleWeaponButton8=GFxClikWidget(Widget);
			btnRifleWeaponButton8.SetString("label",btnRifleWeaponButton8Text);
			btnRifleWeaponButton8.AddEventListener('CLIK_press',Select_btnRifleWeaponButton8);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton1'):
			btnGrenadeWeaponButton1=GFxClikWidget(Widget);
			btnGrenadeWeaponButton1.SetString("label",btnGrenadeWeaponButton1Text);
			btnGrenadeWeaponButton1.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton1);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton2'):
			btnGrenadeWeaponButton2=GFxClikWidget(Widget);
			btnGrenadeWeaponButton2.SetString("label",btnGrenadeWeaponButton2Text);
			btnGrenadeWeaponButton2.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton2);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton3'):
			btnGrenadeWeaponButton3=GFxClikWidget(Widget);
			btnGrenadeWeaponButton3.SetString("label",btnGrenadeWeaponButton3Text);
			btnGrenadeWeaponButton3.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton3);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton4'):
			btnGrenadeWeaponButton4=GFxClikWidget(Widget);
			btnGrenadeWeaponButton4.SetString("label",btnGrenadeWeaponButton4Text);
			btnGrenadeWeaponButton4.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton4);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton5'):
			btnGrenadeWeaponButton5=GFxClikWidget(Widget);
			btnGrenadeWeaponButton5.SetString("label",btnGrenadeWeaponButton5Text);
			btnGrenadeWeaponButton5.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton5);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton6'):
			btnGrenadeWeaponButton6=GFxClikWidget(Widget);
			btnGrenadeWeaponButton6.SetString("label",btnGrenadeWeaponButton6Text);
			btnGrenadeWeaponButton6.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton6);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton7'):
			btnGrenadeWeaponButton7=GFxClikWidget(Widget);
			btnGrenadeWeaponButton7.SetString("label",btnGrenadeWeaponButton7Text);
			btnGrenadeWeaponButton7.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton7);
			bWasHandled=true; 
		break;	
		case ('btnGrenadeWeaponButton8'):
			btnGrenadeWeaponButton8=GFxClikWidget(Widget);
			btnGrenadeWeaponButton8.SetString("label",btnGrenadeWeaponButton8Text);
			btnGrenadeWeaponButton8.AddEventListener('CLIK_press',Select_btnGrenadeWeaponButton8);
			bWasHandled=true; 
		break;	
		case ('btnHeadArmor'):
			btnHeadArmor=GFxClikWidget(Widget);
			btnHeadArmor.SetString("label",btnHeadArmorText);
			btnHeadArmor.AddEventListener('CLIK_press',Select_btnHeadArmor);
			bWasHandled=true; 
		break;	
		case ('btnBodyArmor'):
			btnBodyArmor=GFxClikWidget(Widget);
			btnBodyArmor.SetString("label",btnBodyArmorText);
			btnBodyArmor.AddEventListener('CLIK_press',Select_btnBodyArmor);
			bWasHandled=true; 
		break;
		case ('btnLegArmor'):
			btnLegArmor=GFxClikWidget(Widget);
			btnLegArmor.SetString("label",btnLegArmorText);
			btnLegArmor.AddEventListener('CLIK_press',Select_btnLegArmor);
			bWasHandled=true; 
		break;
		case ('btnNightVision'):
			btnNightVision=GFxClikWidget(Widget);
			btnNightVision.SetString("label",btnNightVisionText);
			btnNightVision.AddEventListener('CLIK_press',Select_btnNightVision);
			bWasHandled=true; 
		break;
		case ('btnMeleeWeaponClipAdd'):
			btnMeleeWeaponClipAdd=GFxClikWidget(Widget);
			btnMeleeWeaponClipAdd.SetString("label",btnMeleeWeaponClipAddText);
			btnMeleeWeaponClipAdd.AddEventListener('CLIK_press',Select_btnMeleeWeaponClipAdd);
			bWasHandled=true; 
		break;
		case ('btnMeleeWeaponClipRemove'):
			btnMeleeWeaponClipRemove=GFxClikWidget(Widget);
			btnMeleeWeaponClipRemove.SetString("label",btnMeleeWeaponClipRemoveText);
			btnMeleeWeaponClipRemove.AddEventListener('CLIK_press',Select_btnMeleeWeaponClipRemove);
			bWasHandled=true; 
		break;
		case ('btnPistolWeaponClipAdd'):
			btnPistolWeaponClipAdd=GFxClikWidget(Widget);
			btnPistolWeaponClipAdd.SetString("label",btnPistolWeaponClipAddText);
			btnPistolWeaponClipAdd.AddEventListener('CLIK_press',Select_btnPistolWeaponClipAdd);
			bWasHandled=true; 
		break;
		case ('btnPistolWeaponClipRemove'):
			btnPistolWeaponClipRemove=GFxClikWidget(Widget);
			btnPistolWeaponClipRemove.SetString("label",btnPistolWeaponClipRemoveText);
			btnPistolWeaponClipRemove.AddEventListener('CLIK_press',Select_btnPistolWeaponClipRemove);
			bWasHandled=true; 
		break;
		case ('btnSMGWeaponClipAdd'):
			btnSMGWeaponClipAdd=GFxClikWidget(Widget);
			btnSMGWeaponClipAdd.SetString("label",btnSMGWeaponClipAddText);
			btnSMGWeaponClipAdd.AddEventListener('CLIK_press',Select_btnSMGWeaponClipAdd);
			bWasHandled=true; 
		break;
		case ('btnSMGWeaponClipRemove'):
			btnSMGWeaponClipRemove=GFxClikWidget(Widget);
			btnSMGWeaponClipRemove.SetString("label",btnSMGWeaponClipRemoveText);
			btnSMGWeaponClipRemove.AddEventListener('CLIK_press',Select_btnSMGWeaponClipRemove);
			bWasHandled=true; 
		break;

		case ('btnRifleWeaponClipAdd'):
			btnRifleWeaponClipAdd=GFxClikWidget(Widget);
			btnRifleWeaponClipAdd.SetString("label",btnRifleWeaponClipAddText);
			btnRifleWeaponClipAdd.AddEventListener('CLIK_press',Select_btnRifleWeaponClipAdd);
			bWasHandled=true; 
		break;
		case ('btnRifleWeaponClipRemove'):
			btnRifleWeaponClipRemove=GFxClikWidget(Widget);
			btnRifleWeaponClipRemove.SetString("label",btnRifleWeaponClipRemoveText);
			btnRifleWeaponClipRemove.AddEventListener('CLIK_press',Select_btnRifleWeaponClipRemove);
			bWasHandled=true; 
		break;
		case ('SMGTitle'):
			SMGTitle=Widget;
			SMGTitle.SetString("text",SMGTitleText);
			bWasHandled=true; 
		break;
		case ('RifleTitle'):
			RifleTitle=Widget;
			RifleTitle.SetString("text",RifleTitleText);
			bWasHandled=true; 
		break;
		case ('GrenadeTitle'):
			GrenadeTitle=Widget;
			GrenadeTitle.SetString("text",GrenadeTitleText);
			bWasHandled=true; 
		break;
		case ('PistolTitle'):
			PistolTitle=Widget;
			PistolTitle.SetString("text",PistolTitleText);
			bWasHandled=true; 
		break;
		case ('MeleeTitle'):
			MeleeTitle=Widget;
			MeleeTitle.SetString("text",MeleeTitleText);
			bWasHandled=true; 
		break;
		case ('MeleeAmmo'):
			MeleeAmmo=Widget;
			MeleeAmmo.SetString("text",MeleeAmmoText);
			bWasHandled=true; 
		break;
		case ('PistolAmmo'):
			PistolAmmo=Widget;
			PistolAmmo.SetString("text",PistolAmmoText);
			bWasHandled=true; 
		break;
		case ('SMGAmmo'):
			SMGAmmo=Widget;
			SMGAmmo.SetString("text",SMGAmmoText);
			bWasHandled=true; 
		break;
		case ('RifleAmmo'):
			RifleAmmo=Widget;
			RifleAmmo.SetString("text",RifleAmmoText);
			bWasHandled=true; 
		break;
		case ('lblSMGWeaponClipValue'):
			lblSMGWeaponClipValue=Widget;
			lblSMGWeaponClipValue.SetString("text",lblSMGWeaponClipValueText);
			bWasHandled=true; 
		break;
		case ('lblPistolWeaponClipValue'):
			lblPistolWeaponClipValue=Widget;
			lblPistolWeaponClipValue.SetString("text",lblPistolWeaponClipValueText);
			bWasHandled=true; 
		break;
		case ('lblMeleeWeaponClipValue'):
			lblMeleeWeaponClipValue=Widget;
			lblMeleeWeaponClipValue.SetString("text",lblMeleeWeaponClipValueText);
			bWasHandled=true; 
		break;
		case ('lblRifleWeaponClipValue'):
			lblRifleWeaponClipValue=Widget;
			lblRifleWeaponClipValue.SetString("text",lblRifleWeaponClipValueText);
			bWasHandled=true; 
		break;
		case ('lblRifleClipsValue'):
			lblRifleClipsValue=Widget;
			lblRifleClipsValue.SetString("text",lblRifleClipsValueText);
			bWasHandled=true; 
		break;
		case ('lblMeleeClipsValue'):
			lblMeleeClipsValue=Widget;
			lblMeleeClipsValue.SetString("text",lblMeleeClipsValueText);
			bWasHandled=true; 
		break;
		case ('lblSMGClipsValue'):
			lblSMGClipsValue=Widget;
			lblSMGClipsValue.SetString("text",lblSMGClipsValueText);
			bWasHandled=true; 
		break;
		case ('lblPistolClipsValue'):
			lblPistolClipsValue=Widget;
			lblPistolClipsValue.SetString("text",lblPistolClipsValueText);
			bWasHandled=true; 
		break;
		case ('lblPistolValue'):
			lblPistolValue=Widget;
			lblPistolValue.SetString("text",lblPistolValueText);
			bWasHandled=true; 
		break;
		case ('lblSMGValue'):
			lblSMGValue=Widget;
			lblSMGValue.SetString("text",lblSMGValueText);
			bWasHandled=true; 
		break;
		case ('lblRifleValue'):
			lblRifleValue=Widget;
			lblRifleValue.SetString("text",lblRifleValueText);
			bWasHandled=true; 
		break;
		case ('lblGrenadeValue'):
			lblGrenadeValue=Widget;
			lblGrenadeValue.SetString("text",lblGrenadeValueText);
			bWasHandled=true; 
		break;
		case ('lblMeleeValue'):
			lblMeleeValue=Widget;
			lblMeleeValue.SetString("text",lblMeleeValueText);
			bWasHandled=true; 
		break;
		case ('lblWallet'):
			lblWallet=Widget;
			lblWallet.SetString("text",lblWalletText);
			bWasHandled=true; 
		break;
		case ('lblCost'):
			lblCost=Widget;
			lblCost.SetString("text",lblCostText);
			bWasHandled=true; 
		break;
		case ('lblReturn'):
			lblReturn=Widget;
			lblReturn.SetString("text",lblReturnText);
			bWasHandled=true; 
		break;
		case ('lblCash'):
			lblCash=Widget;
			lblCash.SetString("text",lblCashText);
			bWasHandled=true; 
		break;
		case ('lblValue'):
			lblValue=Widget;
			lblValue.SetString("text",lblValueText);
			bWasHandled=true; 
		break;
		default:
			bWasHandled=false;
	}

	if(!bWasHandled)
	{
		`log( "CP_BuyMenu::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	}

	return super.WidgetInitialized(WidgetName,WidgetPath,Widget);
}

function CheckPlayersInventory()
{
	local array<CPWeapon> WeaponsCarried;
	local int i;

	//Grab a list of the weapons in our inventory
	if(GetPC().Pawn != none && GetPC().Pawn.InvManager != none)
	{
		CPInventoryManager(GetPC().Pawn.InvManager).GetWeaponList(WeaponsCarried);
	}

	`Log("CHECKING PLAYERS INVENTORY...");
	for (i = 0 ; i < WeaponsCarried.Length ; i++)
	{
		`Log("**********************************");
		`Log("Weapon Name          " @ WeaponsCarried[i].ItemName);
		`Log("Weapon Type          " @ WeaponsCarried[i].WeaponType);
		`Log("Weapon Clips (owned) " @ WeaponsCarried[i].GetClipCount());
		`Log("Weapon Max Clips     " @ WeaponsCarried[i].Default.MaxClipCount);
		`Log("**********************************");
	}

	CheckIfArmorItemCarried(class'CriticalPoint.CPArmor_Head');
	CheckIfArmorItemCarried(class'CriticalPoint.CPArmor_Body');
	CheckIfArmorItemCarried(class'CriticalPoint.CPArmor_Leg');
}

function CheckIfArmorItemCarried(class<CPArmor> classname)
{
	local float ArmorHealthValue;
    local CPArmor       _Armor;

	_Armor = CPArmor( CPInventoryManager(GetPC().Pawn.InvManager).FindInventoryType( classname, false ) );
	if(_Armor != none)
	{
		ArmorHealthValue = _Armor == none ? 0.0f : _Armor.Health / _Armor.MaxHealth;
		`Log("**********************************");
		`Log("Armor Name            " @ _Armor.ItemName);
		`Log("Armor Health          " @ ArmorHealthValue);
		`Log("**********************************");
	}
	else
	{
		`Log("**********************************");
		`Log("Armor Name            " @ classname);
		`Log("THIS ITEM IS NOT OWNED BY THE PLAYER");
		`Log("**********************************");
	}
}

function Select_btnBuyNow(GFxClikWidget.EventData ev)
{
	`Log("Buy Now Button Pressed");
}

function Select_btnReset(GFxClikWidget.EventData ev)
{
	`Log("Reset Button Pressed");
}

function Select_btnCancel(GFxClikWidget.EventData ev)
{
	`Log("Cancel Button Pressed");
}

function Select_btnMeleeWeaponButton1(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 1 Pressed");
}

function Select_btnMeleeWeaponButton2(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 2 Pressed");
}

function Select_btnMeleeWeaponButton3(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 3 Pressed");
}

function Select_btnMeleeWeaponButton4(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 4 Pressed");
}

function Select_btnMeleeWeaponButton5(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 5 Pressed");
}

function Select_btnMeleeWeaponButton6(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 6 Pressed");
}

function Select_btnMeleeWeaponButton7(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 7 Pressed");
}

function Select_btnMeleeWeaponButton8(GFxClikWidget.EventData ev)
{
	`Log("Melee Weapon Button 8 Pressed");
}

function Select_btnPistolWeaponButton1(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 1 Pressed");
}

function Select_btnPistolWeaponButton2(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 2 Pressed");
}

function Select_btnPistolWeaponButton3(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 3 Pressed");
}

function Select_btnPistolWeaponButton4(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 4 Pressed");
}

function Select_btnPistolWeaponButton5(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 5 Pressed");
}

function Select_btnPistolWeaponButton6(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 6 Pressed");
}

function Select_btnPistolWeaponButton7(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 7 Pressed");
}

function Select_btnPistolWeaponButton8(GFxClikWidget.EventData ev)
{
	`Log("Pistol Weapon Button 8 Pressed");
}

function Select_btnSMGWeaponButton1(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 1 Pressed");
}

function Select_btnSMGWeaponButton2(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 2 Pressed");
}

function Select_btnSMGWeaponButton3(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 3 Pressed");
}

function Select_btnSMGWeaponButton4(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 4 Pressed");
}

function Select_btnSMGWeaponButton5(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 5 Pressed");
}

function Select_btnSMGWeaponButton6(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 6 Pressed");
}

function Select_btnSMGWeaponButton7(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 7 Pressed");
}

function Select_btnSMGWeaponButton8(GFxClikWidget.EventData ev)
{
	`Log("SMG Weapon Button 8 Pressed");
}

function Select_btnRifleWeaponButton1(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 1 Pressed");
}

function Select_btnRifleWeaponButton2(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 2 Pressed");
}

function Select_btnRifleWeaponButton3(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 3 Pressed");
}

function Select_btnRifleWeaponButton4(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 4 Pressed");
}

function Select_btnRifleWeaponButton5(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 5 Pressed");
}

function Select_btnRifleWeaponButton6(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 6 Pressed");
}

function Select_btnRifleWeaponButton7(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 7 Pressed");
}

function Select_btnRifleWeaponButton8(GFxClikWidget.EventData ev)
{
	`Log("Rifle Weapon Button 8 Pressed");
}

function Select_btnGrenadeWeaponButton1(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 1 Pressed");
}

function Select_btnGrenadeWeaponButton2(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 2 Pressed");
}

function Select_btnGrenadeWeaponButton3(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 3 Pressed");
}

function Select_btnGrenadeWeaponButton4(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 4 Pressed");
}

function Select_btnGrenadeWeaponButton5(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 5 Pressed");
}

function Select_btnGrenadeWeaponButton6(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 6 Pressed");
}

function Select_btnGrenadeWeaponButton7(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 7 Pressed");
}

function Select_btnGrenadeWeaponButton8(GFxClikWidget.EventData ev)
{
	`Log("Grenade Weapon Button 8 Pressed");
}

function Select_btnHeadArmor(GFxClikWidget.EventData ev)
{
	`Log(" Head Armor Button Pressed");
}

function Select_btnBodyArmor(GFxClikWidget.EventData ev)
{
	`Log(" Body Armor Button Pressed");
}

function Select_btnLegArmor(GFxClikWidget.EventData ev)
{
	`Log(" Leg Armor Button Pressed");
}

function Select_btnNightVision(GFxClikWidget.EventData ev)
{
	`Log(" Night Vision Button Pressed");
}

function Select_btnMeleeWeaponClipAdd(GFxClikWidget.EventData ev)
{
	`Log(" Melee ADD Clip Button Pressed");
}

function Select_btnMeleeWeaponClipRemove(GFxClikWidget.EventData ev)
{
	`Log(" Melee REMOVE Clip Button Pressed");
}

function Select_btnPistolWeaponClipAdd(GFxClikWidget.EventData ev)
{
	`Log(" Pistol ADD Clip Button Pressed");
}

function Select_btnPistolWeaponClipRemove(GFxClikWidget.EventData ev)
{
	`Log(" Pistol REMOVE Clip Button Pressed");
}

function Select_btnSMGWeaponClipAdd(GFxClikWidget.EventData ev)
{
	`Log(" SMG ADD Clip Button Pressed");
}

function Select_btnSMGWeaponClipRemove(GFxClikWidget.EventData ev)
{
	`Log(" SMG REMOVE Clip Button Pressed");
}

function Select_btnRifleWeaponClipAdd(GFxClikWidget.EventData ev)
{
	`Log(" Rifle ADD Clip Button Pressed");
}

function Select_btnRifleWeaponClipRemove(GFxClikWidget.EventData ev)
{
	`Log(" Rifle REMOVE Clip Button Pressed");
}

function PlayOpenAnimation()
{
	`Log("WARNING DEPRECIATED FUNCTION CALLED! PlayOpenAnimation");
}

function PlayCloseAnimation()
{
	`Log("WARNING DEPRECIATED FUNCTION CALLED! PlayCloseAnimation");
}

function bool CloseMenu()
{
	`Log("WARNING DEPRECIATED FUNCTION CALLED! CloseMenu");
	return false;
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="btnBuyNow",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnCancel",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnReset",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btnPreset1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPreset2",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPreset3",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPreset4",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPreset5",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSave",WidgetClass=class'GFxClikWidget'))	
	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton2",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton3",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton4",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton5",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton6",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton7",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponButton8",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton2",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton3",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton4",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton5",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton6",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton7",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponButton8",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton2",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton3",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton4",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton5",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton6",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton7",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponButton8",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton2",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton3",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton4",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton5",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton6",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton7",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponButton8",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton1",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton2",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton3",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton4",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton5",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton6",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton7",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnGrenadeWeaponButton8",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btnHeadArmor",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnBodyArmor",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnLegArmor",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnNightVision",WidgetClass=class'GFxClikWidget'))	

	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponClipAdd",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnMeleeWeaponClipRemove",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponClipAdd",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnPistolWeaponClipRemove",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponClipAdd",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnSMGWeaponClipRemove",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponClipAdd",WidgetClass=class'GFxClikWidget'))	
	SubWidgetBindings.Add((WidgetName="btnRifleWeaponClipRemove",WidgetClass=class'GFxClikWidget'))	
}
