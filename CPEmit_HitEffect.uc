class CPEmit_HitEffect extends CPEmitter;

simulated function AttachTo(Pawn P,name NewBoneName)
{
	if (NewBoneName=='')
		SetBase(P);
	else
		SetBase(P,,P.Mesh,NewBoneName);
}

simulated function PawnBaseDied()
{
	if (ParticleSystemComponent!=None)
		ParticleSystemComponent.DeactivateSystem();
}

defaultproperties
{
}