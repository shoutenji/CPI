class CPReverbVolumeHackHelper extends Object;

var array<CPReverbVolume> ReverbVolumeList;
var WorldInfo myWorldInfo;

simulated function Init(WorldInfo currWorldInfo)
{
	myWorldInfo=currWorldInfo;
	CacheReverbVolumes();
}

private simulated function CacheReverbVolumes()
{
local CPReverbVolume testVolume;

	if (myWorldInfo==none)
		return;
	ReverbVolumeList.Remove(0,ReverbVolumeList.Length);
	foreach myWorldInfo.AllActors(class'CPReverbVolume',testVolume)
		if (testVolume!=none && testVolume.SoundClassesToOcclude.Length>0)
			ReverbVolumeList.AddItem(testVolume);
}

private simulated function bool GetSoundCueAuttenatorMaxDist(SoundNode inNode,out float maxDist)
{
local int f;

	if (inNode==none)
		return false;
	if (inNode.IsA('SoundNodeAttenuation'))
	{
		if (SoundNodeAttenuation(inNode).bAttenuate)
		{
			maxDist=SoundNodeAttenuation(inNode).RadiusMax;
			return true;
		}
	}
	else if (inNode.IsA('SoundNodeAmbient'))
	{
		if (SoundNodeAmbient(inNode).bAttenuate)
		{
			maxDist=SoundNodeAmbient(inNode).RadiusMax;
			return true;
		}
	}
	for (f=0;f<inNode.ChildNodes.Length;f++)
	{
		if (inNode.ChildNodes[f]==none || inNode.ChildNodes[f]==inNode)
			continue;
		if (GetSoundCueAuttenatorMaxDist(inNode.ChildNodes[f],maxDist))
			return true;
	}
	return false;
}

private simulated function float GetSoundCueMaxAudibleDist(SoundCue Sound)
{
local float maxDistOut;

	if (Sound==none || Sound.FirstNode==none || Sound.FirstNode.ChildNodes.Length==0)
		return 0.0;
	if (GetSoundCueAuttenatorMaxDist(Sound.FirstNode,maxDistOut))
		return maxDistOut;
	return 0.0;
}

simulated function CPReverbVolume GetReverbVolumeFor(Actor checkActor,name cueSoundClass)
{
local int k;

	if (checkActor==none || ReverbVolumeList.Length==0)
		return none;
	for (k=0;k<ReverbVolumeList.Length;k++)
	{
		if (ReverbVolumeList[k].EncompassesPoint(checkActor.Location) &&
			ReverbVolumeList[k].bEnabled &&
			ReverbVolumeList[k].OccludesSoundClass(cueSoundClass))
		{
			return ReverbVolumeList[k];
		}
	}
	return none;
}

simulated function CPPlayerController GetActorTopLevelOwner(Actor testActor)
{
local Actor currentActor;
local int tmpCntr;

	if (testActor==none || testActor.Owner==none)
		return none;
	tmpCntr=0;
	currentActor=testActor;
	while (currentActor!=none && tmpCntr<200)
	{
		if (currentActor.IsA('CPPlayerController'))
			return CPPlayerController(currentActor);
		currentActor=currentActor.Owner;
		tmpCntr++;
	}
	return none;
}

// NOTE : needs to be simulated because even for non-owning clients the pawn calls this function to do the reverb hack
simulated function LocallyPlaySoundWithReverbVolumeHack(CPPlayerController Owner,Actor playActor,SoundCue Sound)
{
local int j;
local bool bIsSourceInReverbVolume;
local bool bIsRecieverInReverbVolume;
local bool bAdjustVolume;
local float VolumeAdjuster;
local CPReverbVolume SourceReverbVolume;
local CPReverbVolume RecvReverbVolume;
local Vector RecvLocation;
local float soundCheckDist;
local Actor testActor;

	if (myWorldInfo==none || Owner==none || playActor==none || Sound==none)
		return;
	bIsSourceInReverbVolume=false;
	if (ReverbVolumeList.Length>0)
	{
		for (j=0;j<playActor.Touching.Length;j++)
		{
			SourceReverbVolume=CPReverbVolume(playActor.Touching[j]);
			if (SourceReverbVolume!=none &&
				SourceReverbVolume.bEnabled &&
				SourceReverbVolume.OccludesSoundClass(Sound.SoundClass))
			{
				bIsSourceInReverbVolume=true;
				break;
			}
		}
	}
	soundCheckDist=GetSoundCueMaxAudibleDist(Sound);
	if (Owner.ViewTarget==Owner)
		RecvLocation=Owner.Location;
	else
		RecvLocation=Owner.ViewTarget.Location;
	if (soundCheckDist>0 && VSize(RecvLocation-playActor.Location)>soundCheckDist)
		return;
	bIsRecieverInReverbVolume=false;
	if (ReverbVolumeList.Length>0)
	{
		if (Owner.ViewTarget==Owner)
		{
			RecvReverbVolume=GetReverbVolumeFor(Owner,Sound.SoundClass);
			bIsRecieverInReverbVolume=(RecvReverbVolume!=none);
		}
		else
		{
			testActor=Owner.ViewTarget;
			for (j=0;j<testActor.Touching.Length;j++)
			{
				RecvReverbVolume=CPReverbVolume(testActor.Touching[j]);
				if (RecvReverbVolume!=none &&
					RecvReverbVolume.bEnabled &&
					RecvReverbVolume.OccludesSoundClass(Sound.SoundClass))
				{
					bIsRecieverInReverbVolume=true;
					break;
				}
			}
		}
	}
	VolumeAdjuster=1.0;
	bAdjustVolume=false;
	if (bIsRecieverInReverbVolume || bIsSourceInReverbVolume)
	{
		bAdjustVolume=true;
		if (bIsSourceInReverbVolume && !bIsRecieverInReverbVolume)
			VolumeAdjuster=SourceReverbVolume.AmbientZoneSettings.InteriorVolume;
		else if (bIsRecieverInReverbVolume && !bIsSourceInReverbVolume)
			VolumeAdjuster=RecvReverbVolume.AmbientZoneSettings.ExteriorVolume;	
		else if (bIsRecieverInReverbVolume && bIsSourceInReverbVolume && RecvReverbVolume!=SourceReverbVolume)
			VolumeAdjuster=RecvReverbVolume.AmbientZoneSettings.ExteriorVolume*SourceReverbVolume.AmbientZoneSettings.InteriorVolume;
	}
	if ((bAdjustVolume ? VolumeAdjuster : 1.0)>0.0)
		Owner.ClientPlaySoundFor(playActor,playActor.Location,Sound,(bAdjustVolume ? VolumeAdjuster : 1.0));
}

// server play sound
function PlaySoundWithReverbVolumeHack(Actor playActor,SoundCue Sound,optional bool bAlsoRepToSource,optional bool bOnlyRepToNonRelevantRecvrs)
{
local int j;
local bool bIsSourceInReverbVolume;
local bool bIsRecieverInReverbVolume;
local CPPlayerController tapc;
local bool bAdjustVolume;
local float VolumeAdjuster;
local CPReverbVolume SourceReverbVolume;
local CPReverbVolume RecvReverbVolume;
local Vector RecvLocation;
local float soundCheckDist;
local Actor testActor;
local CPPlayerController tempCntrl;

	if (myWorldInfo==none || playActor==none || Sound==none)
		return;

	if (bOnlyRepToNonRelevantRecvrs)        // ~Drakk : temporarly since the non-relevant sound playback for clients is not working at the moment
		return;

	bIsSourceInReverbVolume=false;
	if (ReverbVolumeList.Length>0)
	{
		for (j=0;j<playActor.Touching.Length;j++)
		{
			SourceReverbVolume=CPReverbVolume(playActor.Touching[j]);
			if (SourceReverbVolume!=none &&
				SourceReverbVolume.bEnabled &&
				SourceReverbVolume.OccludesSoundClass(Sound.SoundClass))
			{
				bIsSourceInReverbVolume=true;
				break;
			}
		}
	}
	soundCheckDist=GetSoundCueMaxAudibleDist(Sound);
	if (!bAlsoRepToSource)
		tempCntrl=GetActorTopLevelOwner(playActor);
	foreach myWorldInfo.AllControllers(class'CPPlayerController',tapc)
	{
		if (!bAlsoRepToSource)
		{
			if (tempCntrl!=none && tapc==tempCntrl)
				continue;
		}
		if (tapc.ViewTarget==tapc)
			RecvLocation=tapc.Location;
		else
			RecvLocation=tapc.ViewTarget.Location;
		if (soundCheckDist>0 && VSize(RecvLocation-playActor.Location)>soundCheckDist)
			continue;
		bIsRecieverInReverbVolume=false;
		if (ReverbVolumeList.Length>0)
		{
			if (tapc.ViewTarget==tapc)
			{
				RecvReverbVolume=GetReverbVolumeFor(tapc,Sound.SoundClass);
				bIsRecieverInReverbVolume=(RecvReverbVolume!=none);
			}
			else
			{
				testActor=tapc.ViewTarget;
				for (j=0;j<testActor.Touching.Length;j++)
				{
					RecvReverbVolume=CPReverbVolume(testActor.Touching[j]);
					if (RecvReverbVolume!=none &&
						RecvReverbVolume.bEnabled &&
						RecvReverbVolume.OccludesSoundClass(Sound.SoundClass))
					{
						bIsRecieverInReverbVolume=true;
						break;
					}
				}
			}
		}
		VolumeAdjuster=1.0;
		bAdjustVolume=false;
		if (bIsRecieverInReverbVolume || bIsSourceInReverbVolume)
		{
			bAdjustVolume=true;
			if (bIsSourceInReverbVolume && !bIsRecieverInReverbVolume)
				VolumeAdjuster=SourceReverbVolume.AmbientZoneSettings.InteriorVolume;
			else if (bIsRecieverInReverbVolume && !bIsSourceInReverbVolume)
				VolumeAdjuster=RecvReverbVolume.AmbientZoneSettings.ExteriorVolume;	
			else if (bIsRecieverInReverbVolume && bIsSourceInReverbVolume && RecvReverbVolume!=SourceReverbVolume)
				VolumeAdjuster=RecvReverbVolume.AmbientZoneSettings.ExteriorVolume*SourceReverbVolume.AmbientZoneSettings.InteriorVolume;
		}
		if ((bAdjustVolume ? VolumeAdjuster : 1.0)>0.0)
			tapc.ClientPlaySoundFor(playActor,playActor.Location,Sound,(bAdjustVolume ? VolumeAdjuster : 1.0));
	}
}

DefaultProperties
{
}
