class CPAnimNotify_ShellEjection extends AnimNotify_Scripted;

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
			W.CauseShellLaunch();
		}
	}
}
