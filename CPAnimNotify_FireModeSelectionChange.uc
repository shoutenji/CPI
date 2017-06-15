class CPAnimNotify_FireModeSelectionChange extends AnimNotify_Scripted;

var() int Degrees;

event Notify(Actor Owner, AnimNodeSequence AnimSeqInstigator)
{
	local Pawn P;
	local CPWeapon W;

	P = Pawn(Owner);
	if (P != None && P.IsLocallyControlled())
	{
		W = CPWeapon(P.Weapon);

		if (W != None)
		{
			W.PlayDelayedWeaponFireModeSwitch(Degrees);
		}
	}
}


defaultproperties
{
	Degrees = 0;
}
