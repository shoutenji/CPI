class CPAnimNode_SeqWeap extends UDKAnimNodeSequence;
//depreciated
//struct WeapAnimInfo
//{
//	var() Name ProfileName;		// name of profile
//	var() Name AnimSequence;	// animation that goes with this profile
//	var() float fRate;			// rate of the animation
//	var() bool bLoop;			// does the animation loop
//	structdefaultproperties
//	{
//		fRate=1.0f
//		bLoop=true
//	}	
//};

///** Array of animations to blend */
//var(Animations) editinline export Array<WeapAnimInfo> Anims;

///**
// *	Change the currently active profile to the one with the supplied name.
// *	If a profile with that name does not exist, this does nothing.
// */
//simulated function SetWeapProfileByName(out name AnimProfile, CPWeapon theWeapon)
//{
//	local WeapAnimInfo Anim;
//	local int i;
	
//	if(theWeapon != none)
//	{
//		AnimProfile = theWeapon.WeaponProfileName;
//	}

//	for (i = 0; i < Anims.Length; i++)
//	{
//		if (Anims[i].ProfileName == AnimProfile)
//		{
//			Anim = Anims[i];
//			SetAnim(Anim.AnimSequence);
//				PlayAnim(Anim.bLoop, Anim.fRate);
//			break;
//		}
//	}
//}

//defaultproperties
//{
//	//important array MUST MATCH the aimnode profile names.
//	Anims(0)=(ProfileName="Rifle")
//	Anims(1)=(ProfileName="Pistol")
//	Anims(2)=(ProfileName="SMG")
//	Anims(3)=(ProfileName="Sniper")
//	Anims(4)=(ProfileName="Melee")
//	Anims(5)=(ProfileName="Bomb")
//	Anims(6)=(ProfileName="Grenade")
//	Anims(7)=(ProfileName="Shotgun")
//	Anims(8)=(ProfileName="Holster")

//	//custom profiles for all our weapons.
//	Anims(9)=(ProfileName="SpringfieldXD45")
//	Anims(10)=(ProfileName="Hatchet")
//	Anims(11)=(ProfileName="KABAR")
//	Anims(12)=(ProfileName="Glock18c")
//	Anims(13)=(ProfileName="DesertEagle")
//	Anims(14)=(ProfileName="RagingBull")
//	Anims(15)=(ProfileName="MP5a3")
//	Anims(16)=(ProfileName="MAC10")
//	Anims(17)=(ProfileName="UMP45")
//	Anims(18)=(ProfileName="MP5k")
//	Anims(19)=(ProfileName="Mossberg590")
//	Anims(20)=(ProfileName="Remmington870p")
//	Anims(21)=(ProfileName="AKMS")
//	Anims(22)=(ProfileName="HK416")
//	Anims(23)=(ProfileName="SIG552")
//	Anims(24)=(ProfileName="KARSR25")
//	Anims(25)=(ProfileName="M700")
//	Anims(26)=(ProfileName="SCARH")
//	Anims(27)=(ProfileName="G3kA4")
//	Anims(28)=(ProfileName="HK121")
//	Anims(29)=(ProfileName="HEGrenade")
//	Anims(30)=(ProfileName="FlashGrenade")
//	Anims(31)=(ProfileName="SmokeGrenade")
//	Anims(32)=(ProfileName="ConcGrenade")
//	Anims(33)=(ProfileName="C4Bomb")
//}
