class CPReverbVolume extends ReverbVolume
	placeable
	dontsortcategories(ReverbVolume)
	hidecategories(Advanced,Attachment,Collision,Volume,Toggle);

var(ReverbVolume) array<name> SoundClassesToOcclude;

simulated function bool OccludesSoundClass(name testSoundCls)
{
local int k;

	if (SoundClassesToOcclude.Length==0)
		return false;
	for (k=0;k<SoundClassesToOcclude.Length;k++)
	{
		if (SoundClassesToOcclude[k]==testSoundCls)
			return true;
	}
	return false;
}

DefaultProperties
{
	Begin Object Name=BrushComponent0
		bAcceptsLights=false
		CollideActors=true
		BlockNonZeroExtent=true
	End Object

	bCollideActors=true
	BrushColor=(R=255,G=255,B=60,A=255)
	SoundClassesToOcclude.Empty
	SoundClassesToOcclude(0)=Weapon
	SoundClassesToOcclude(1)=Item
	SoundClassesToOcclude(2)=Vehicle
	SoundClassesToOcclude(3)=Character
}
