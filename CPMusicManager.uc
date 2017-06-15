/*
~Drakk :
			TODO's : - the Action music condition should get an update when the Winning/Losing condition changes.
					 - check whenever ECPMusicManagerState and script states are really needed.
					 - investigate the AudioComponent overflow, when the tracks dont call OnTrackFinished but they dont play anything either.
					 - investigate the case of Kismet event retriggering after state switch ( because the state switch kills the events and
						don't trigger them when they should be active according to Kismet )
*/
class CPMusicManager extends Info;

const musicManager_logTag='CPMusicManager';
const musicManager_ACCFLimit=10;
const musicManager_ACLimitRatio=0.4;
const musicManager_DefaultACLimit=10;
const musicManager_Logging=false;            // ~Drakk : set this to false to disable logging

enum ETAMusicState
{
	TMST_Ambient,
	TMST_Camping,
	TMST_Action,
	TMST_Action_Winning,
	TMST_Action_Losing,
	TMST__length,
	TMST_Stinger,
	TMST_Fader,
};

enum ECPMusicManagerState
{
	TMMS_Running,
	TMMS_Startup,
	TMMS_Disabled,
};

enum ETAMusicSegmentQueryValueName
{
	TMSV_CamperWarningMaxLevel,
	TMSV_CampingWarningMaxLevel,
};

enum TAMusicKismetEventType
{
	TMKE_Start,
	TMKE_Stop,
	TMKE_Toggle,
	TMKE_GetState,
};

struct STAMusicTrack
{
	var TAMusicSegment MusicSegment;
	var TASegmentInfo SegmentInfo;
	var AudioComponent AC;
	var bool bReset;
};

struct STAAdjustedTrackControl
{
	var TASegmentInfo SegmentInfo;
	var int OnBeat;
	var bool bBeforeBeat;
	var bool bStop;
};

struct STAMusicKismetEvent
{
	var TAMusicKismetEventType EventType;	
	var name EventName;
	var float VolumeMult;
};

var ECPMusicManagerState ManagerState;
var string ManagerStateReasonStr;

var CPPlayerController PlayerOwner;
var CPMapMusicInfo MusicInfo;

var bool bStarted;
var array<STAMusicTrack> ManagerTracks;
var int ManagerACCreationFails;
var int MaxAudioComponents;

var ETAMusicState MusicState;
var ETAMusicState NextMusicState;
var ETAMusicState FaderPendingMusicState;
var bool bMusicStateChanged;
var float MusicStartTime;
var int MusicSegmentBeatCount;
var float MusicSegmentBeatRate;
var array<float> MusicTackNudgeRates;
var bool bFirstBeat;
var int SegmentStartBeat;

var SoundCue StingerStateSoundCue;
var AudioComponent StingerStateAC;

var array<STAAdjustedTrackControl> TrackAdjusterList;

var bool bLastCamperWarning;
var int LastCamperWarningLevel;

var bool bLastCampingWarning;
var int LastCampingWarningLevel;
var float CampingWarningStopTime;
var int CampingWarningStopLevel;
var float CamperWarningTimeSecOffset;

var array<STAMusicKismetEvent> KismetEventList;
var TASegmentInfo faderSeg;
var bool FaderMode;

var float CamperWarnDistance;
var bool bCamperWarning;

var bool bDEVNoCampingState;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	ManagerState=TMMS_Startup;
	ManagerStateReasonStr="Initial Startup";
}

event Destroyed()
{
	super.Destroyed();
	KillAllTracks();
}

function SwitchToState(ECPMusicManagerState newState,optional string Reason)
{
	if (ManagerState==newState)
		return;
	if (newState==TMMS_Running)
		GotoState('tmms_Running');
	else if (newState==TMMS_Startup)
		GotoState('tmms_Startup');
	else if (newState==TMMS_Disabled)
	{
		GotoState('tmms_Disabled');
		if (Reason!="")
			`log("disabled, reason : "$Reason,musicManager_Logging,musicManager_logTag);
		else
			`log("disabled",musicManager_Logging,musicManager_logTag);
	}
	ManagerState=newState;
	if (Reason!="")
		ManagerStateReasonStr=Reason;
	else
		ManagerStateReasonStr="";
}

function TAMusicSegment GetMusicStateSegment(ETAMusicState testState)
{
local TAMusicSegment EmptySegment;

	if (MusicInfo==none)
		return EmptySegment;
	if (testState==TMST_Ambient)
		return MusicInfo.Segment_Ambient;
	else if (testState==TMST_Camping)
		return MusicInfo.Segment_Camping;
	else if (testState==TMST_Action)
		return MusicInfo.Segment_Action;
	else if (testState==TMST_Action_Winning)
		return MusicInfo.Segment_Action_Winning;
	else if (testState==TMST_Action_Losing)
		return MusicInfo.Segment_Action_Losing;
	return EmptySegment;
}

function SetMusicStateSegment(ETAMusicState testState,TAMusicSegment testSeg)
{
	if (MusicInfo==none)
		return;
	if (testState==TMST_Ambient)
		MusicInfo.Segment_Ambient=testSeg;
	else if (testState==TMST_Camping)
		MusicInfo.Segment_Camping=testSeg;
	else if (testState==TMST_Action)
		MusicInfo.Segment_Action=testSeg;
	else if (testState==TMST_Action_Winning)
		MusicInfo.Segment_Action_Winning=testSeg;
	else if (testState==TMST_Action_Losing)
		MusicInfo.Segment_Action_Losing=testSeg;
}

function bool IsMusicStateAvailable(ETAMusicState testState)
{
local TAMusicSegment testSeg;
local array<TASegmentInfo> segInfo;
local int i;
local bool bFoundBaseLoop;

	if (MusicInfo==none)
		return false;
	testSeg=GetMusicStateSegment(testState);
	segInfo=testSeg.SubSegments;
	bFoundBaseLoop=false;
	for (i=0;i<segInfo.Length;i++)
	{
		if (segInfo[i].Type==TSIT_BaseLoop && segInfo[i].SoundCue!=none)
		{
			bFoundBaseLoop=true;
			break;
		}
	}
	return bFoundBaseLoop;
}

function bool ValidateSoundCueNode(SoundNode inNode,bool bIsStinger)
{
local int f;

	if (inNode==none)
		return false;
	if (inNode.IsA('SoundNodeWave'))
	{
		SoundNodeWave(inNode).bForceRealTimeDecompression=true;
		SoundNodeWave(inNode).bLoopingSound=true;
	}
	else if (bIsStinger && inNode.IsA('SoundNodeLooping'))
	{
		SoundNodeLooping(inNode).bLoopIndefinitely=false;
		SoundNodeLooping(inNode).LoopCountMin=0.0;
		SoundNodeLooping(inNode).LoopCountMax=0.0;
	}
	for (f=0;f<inNode.ChildNodes.Length;f++)
	{
		if (inNode.ChildNodes[f]==none || inNode.ChildNodes[f]==inNode)
			continue;
		if (!ValidateSoundCueNode(inNode.ChildNodes[f],bIsStinger))
			return false;
	}
	return true;
}

function bool ValidateSoundCueNodes(SoundCue testCue,bool bIsStinger)
{
	if (testCue==none || testCue.FirstNode==none)
		return false;
	return ValidateSoundCueNode(testCue.FirstNode,bIsStinger);
}

function bool ValidateSoundCue(SoundCue testCue,bool bIsStinger)
{
	if (testCue==none || MusicInfo==none)
		return false;
	if (MusicInfo.bDEVDumpVerboseStatusToLog &&
		testCue.SoundClass!='Music' &&
		testCue.SoundClass!='GameMusic' &&
		testCue.SoundClass!='OptionMusic' &&
		testCue.SoundClass!='UserMusic')
	{
		`log("sound cue with non-music sound class : "$testCue,musicManager_Logging,musicManager_logTag);
	}
	if (testCue.VolumeMultiplier<=0.0)
		testCue.VolumeMultiplier=1.0;
	if (testCue.PitchMultiplier<=0.0)
		testCue.PitchMultiplier=1.0;
	if (testCue.MaxConcurrentPlayCount<=8)
		testCue.MaxConcurrentPlayCount=10;
	if (testCue.Duration<0.2)
	{
		if (MusicInfo.bDEVDumpVerboseStatusToLog)
			`log("sound cue too short : "$testCue,musicManager_Logging,musicManager_logTag);
		return false;
	}
	if (!ValidateSoundCueNodes(testCue,bIsStinger) && MusicInfo.bDEVDumpVerboseStatusToLog)
		`log("unable to validate sound cue nodes : "$testCue,musicManager_Logging,musicManager_logTag);
	return true;
}

function bool GetLongestWaveNodeDuration(SoundNode inNode,out float dutationOut)
{
local int f;

	if (inNode==none)
		return false;
	if (inNode.IsA('SoundNodeWave'))
	{
		if (SoundNodeWave(inNode).Duration>0.0 && SoundNodeWave(inNode).Duration>dutationOut)
			dutationOut=SoundNodeWave(inNode).Duration;
	}
	for (f=0;f<inNode.ChildNodes.Length;f++)
	{
		if (inNode.ChildNodes[f]==none || inNode.ChildNodes[f]==inNode)
			continue;
		if (!GetLongestWaveNodeDuration(inNode.ChildNodes[f],dutationOut))
			return false;
	}
	return true;
}

function SetSubSegmentMeasures(out TASegmentInfo _segment,int _BPM)
{
local float longDuration;

	if (_segment.SoundCue==none || _segment.SoundCue.FirstNode==none || _BPM<=0.0)
		return;
	if (!GetLongestWaveNodeDuration(_segment.SoundCue.FirstNode,longDuration))
		return;
	_segment.DurationInBeats=longDuration/(float(_BPM)/60.0);
}

function bool ValidateMusicStates()
{
local int i,k;
local TASegmentInfo subSegment;
local int loopTypeCount_Base;
local int loopTypeCount_Sec;
local int loopTypeCount_Event;
local int loopTypeCount_Stinger;
local int loopTypeCount_FadeHelper;
local int loopTypeCount_Base_fss;
local float loopAvgBeatCount;
local int loopAvgBeatCountNum;
local int loopEventCamperWarnMaxLevel;
local int loopEventCampingWarnMaxLevel;
local string validatorStr;
local TAMusicSegment testSeg;

	if (MusicInfo==none)
		return false;
	for (i=0;i<TMST__length;i++)
	{
		testSeg=GetMusicStateSegment(ETAMusicState(i));
		if (testSeg.SubSegments.length==0)
			continue;
		loopTypeCount_Base=0;
		loopTypeCount_Sec=0;
		loopTypeCount_Event=0;
		loopTypeCount_Stinger=0;
		loopTypeCount_FadeHelper=0;
		loopTypeCount_Base_fss=0;
		loopAvgBeatCount=0;
		loopAvgBeatCountNum=0;
		loopEventCamperWarnMaxLevel=0;
		loopEventCampingWarnMaxLevel=0;
		for (k=0;k<testSeg.SubSegments.Length;k++)
		{
			subSegment=testSeg.SubSegments[k];
			if (subSegment.Type==TSIT_BaseLoop)
				loopTypeCount_Base_fss++;
			if (subSegment.SoundCue==none)
			{
				testSeg.SubSegments.Remove(k,1);
				k--;
				`log("found an invalid sub segment ( no sound cue ) in music state "$MusicStateIntAsString(i)$", deleting",musicManager_Logging,musicManager_logTag);
				continue;
			}
			else if (!ValidateSoundCue(subSegment.SoundCue,(subSegment.Type==TSIT_SegmentStinger)))
			{
				testSeg.SubSegments.Remove(k,1);
				k--;
				`log("found an invalid sub segment ( invalid sound cue ) in music state "$MusicStateIntAsString(i)$", deleting",musicManager_Logging,musicManager_logTag);
				continue;
			}

			SetSubSegmentMeasures(subSegment,(testSeg.SegmentBaseTempoOverride>0.0 ? testSeg.SegmentBaseTempoOverride : MusicInfo.BaseTempo));
			if (subSegment.DurationInBeats>0)
			{
				loopAvgBeatCount+=subSegment.DurationInBeats;
				loopAvgBeatCountNum++;
			}

			if (subSegment.Type==TSIT_EventDependent &&
				subSegment.ConditionListenEvent==TSEN_KismetEvent &&
				subSegment.KismetEventName=='')
			{
				testSeg.SubSegments.Remove(k,1);
				k--;
				`log("found an invalid sub segment setup, a Kismet Event listener with no event name in music state "$MusicStateIntAsString(i)$", deleting",musicManager_Logging,musicManager_logTag);
				continue;
			}

			if (subSegment.Type==TSIT_BaseLoop)
				loopTypeCount_Base++;
			else if (subSegment.Type==TSIT_SecondaryLoop)
				loopTypeCount_Sec++;
			else if (subSegment.Type==TSIT_EventDependent)
			{
				loopTypeCount_Event++;
				if (subSegment.ConditionListenEvent==TSEN_CamperWarning)
					if (subSegment.LoopLevel>loopEventCamperWarnMaxLevel)
						loopEventCamperWarnMaxLevel=subSegment.LoopLevel;
				if (subSegment.ConditionListenEvent==TSEN_CampingWarning)
					if (subSegment.LoopLevel>loopEventCampingWarnMaxLevel)
						loopEventCampingWarnMaxLevel=subSegment.LoopLevel;
			}
			else if (subSegment.Type==TSIT_SegmentStinger)
				loopTypeCount_Stinger++;
			else if (subSegment.Type==TSIT_FadeInHelper || subSegment.Type==TSIT_FadeOutHelper)
				loopTypeCount_FadeHelper++;

			if (subSegment.LoopLevel<1)
				subSegment.LoopLevel=1;
			if (subSegment.PlayWeight<0.0)
				subSegment.PlayWeight=0.0;
			if (subSegment.VolumeMultiplier<0.0 || subSegment.VolumeMultiplier>10.0)
				subSegment.VolumeMultiplier=1.0;
			if (subSegment.FadeInBeatCount<0 || subSegment.FadeInBeatCount>40)
				subSegment.FadeInBeatCount=0;
			if (subSegment.FadeOutBeatCount<0 || subSegment.FadeOutBeatCount>40)
				subSegment.FadeOutBeatCount=0;
		
			testSeg.SubSegments[k]=subSegment;
		}

		testSeg.MaxCamperWarningLevel=loopEventCamperWarnMaxLevel;
		testSeg.MaxCampingWarningLevel=loopEventCampingWarnMaxLevel;
		if (testSeg.MaxCamperWarningLevel>0)
			`log("music state "$MusicStateIntAsString(i)$" highest camper warning level "$testSeg.MaxCamperWarningLevel,musicManager_Logging,musicManager_logTag);
		if (testSeg.MaxCampingWarningLevel>0)
			`log("music state "$MusicStateIntAsString(i)$" highest camping warning level "$testSeg.MaxCampingWarningLevel,musicManager_Logging,musicManager_logTag);

		if (testSeg.SegmentBaseTempoOverride<0.0)
			testSeg.SegmentBaseTempoOverride=0.0;
		if (testSeg.SegmentStingerNudgeRate<=0.0)
			testSeg.SegmentStingerNudgeRate=1.0;
		if (testSeg.SegmentNudgeRatePlayingToStopMult<=0.0)
			testSeg.SegmentNudgeRatePlayingToStopMult=1.0;
		if (testSeg.SegmentNudgeRateStoppedToStartMult<=0.0)
			testSeg.SegmentNudgeRateStoppedToStartMult=1.0;

		if (loopAvgBeatCountNum>0)
			testSeg.AvgSubSegDurationInBeats=loopAvgBeatCount/loopAvgBeatCountNum;

		if (loopTypeCount_Base==0 && loopTypeCount_Base_fss>0)
		{
			`log("music state "$MusicStateIntAsString(i)$" have no base loops while trying to validate it",musicManager_Logging,musicManager_logTag);
			return false;
		}

		if (MusicInfo.bDEVDumpVerboseStatusToLog)
		{
			validatorStr="validated music state "$MusicStateIntAsString(i)$" with "$loopTypeCount_Base$" base ";
			if (loopTypeCount_Sec>0)
				validatorStr$=loopTypeCount_Sec$" secondary ";
			if (loopTypeCount_Event>0)
				validatorStr$=loopTypeCount_Event$" event ";
			if (loopTypeCount_Stinger>0)
				validatorStr$=loopTypeCount_Stinger$" stinger ";
			if (loopTypeCount_FadeHelper>0)
				validatorStr$=loopTypeCount_FadeHelper$" fade helper ";
			validatorStr$="loops";
			`log(validatorStr,musicManager_Logging,musicManager_logTag);
		}

		SetMusicStateSegment(ETAMusicState(i),testSeg);
	}
	return true;
}

function bool ValidateStingerSoundCueNode(SoundNode inNode)
{
local int f;

	if (inNode==none)
		return false;
	if (inNode.IsA('SoundNodeWave'))
	{
		SoundNodeWave(inNode).bForceRealTimeDecompression=true;
		SoundNodeWave(inNode).bLoopingSound=false;
	}
	else if (inNode.IsA('SoundNodeLooping'))
	{
		`log("stinger sound cue contains looping sound node",musicManager_Logging,musicManager_logTag);
		return false;
	}
	for (f=0;f<inNode.ChildNodes.Length;f++)
	{
		if (inNode.ChildNodes[f]==none || inNode.ChildNodes[f]==inNode)
			continue;
		if (!ValidateStingerSoundCueNode(inNode.ChildNodes[f]))
			return false;
	}
	return true;
}

function bool ValidateStingerSoundCueNodes(SoundCue testCue)
{
	if (testCue==none || testCue.FirstNode==none)
		return false;
	return ValidateStingerSoundCueNode(testCue.FirstNode);
}

function bool ValidateStingerSoundCue(SoundCue testCue)
{
	if (testCue==none || MusicInfo==none)
		return false;
	if (MusicInfo.bDEVDumpVerboseStatusToLog &&
		testCue.SoundClass!='Music' &&
		testCue.SoundClass!='GameMusic' &&
		testCue.SoundClass!='OptionMusic' &&
		testCue.SoundClass!='UserMusic')
	{
		`log("stinger sound cue with non-music sound class : "$testCue,musicManager_Logging,musicManager_logTag);
	}
	if (testCue.VolumeMultiplier<=0.0)
		testCue.VolumeMultiplier=1.0;
	if (testCue.PitchMultiplier<=0.0)
		testCue.PitchMultiplier=1.0;
	if (testCue.MaxConcurrentPlayCount<=8)
		testCue.MaxConcurrentPlayCount=10;
	if (testCue.Duration<0.2)
	{
		if (MusicInfo.bDEVDumpVerboseStatusToLog)
			`log("stinger sound cue too short : "$testCue,musicManager_Logging,musicManager_logTag);
		return false;
	}
	if (!ValidateStingerSoundCueNodes(testCue) && MusicInfo.bDEVDumpVerboseStatusToLog)
		`log("unable to validate stringer sound cue nodes : "$testCue,musicManager_Logging,musicManager_logTag);
	return true;
}

function ValidateStingers()
{
	if (MusicInfo==none)
		return;
	if (!ValidateStingerSoundCue(MusicInfo.Stingers.Intro))
		MusicInfo.Stingers.Intro=none;
}

function bool CheckMusicInfo()
{
local CPMapInfo TAMI;
local string reasonStr;

	if (MusicInfo!=none)                        // ~Drakk : recheck? for the case of getting the level switched while we are active?
		return true;
	TAMI=CPMapInfo(WorldInfo.GetMapInfo());
	if (TAMI==none || TAMI.MapMusicInfo==none)
	{
		if (TAMI==none)
			reasonStr="No TA map info for level";
		else
			reasonStr="No TA map music info for level";
		SwitchToState(TMMS_Disabled,reasonStr);
		return false;
	}
	MusicInfo=TAMI.MapMusicInfo;
	if (MusicInfo.BaseTempo<=0.0)
		MusicInfo.BaseTempo=90.0;
	if (MusicInfo.StingerVolumeMultiplier<=0.0)
		MusicInfo.StingerVolumeMultiplier=1.1;
	if (MusicInfo.StateChangeOnBeat<=0)
		MusicInfo.StateChangeOnBeat=1;
	if (MusicInfo.CamperWarningCheckBeatRate<=0)
		MusicInfo.CamperWarningCheckBeatRate=1;
	if (MusicInfo.KismetEventCheckBeatRate<=0)
		MusicInfo.KismetEventCheckBeatRate=1;
	if (!IsMusicStateAvailable(TMST_Ambient) &&
		!IsMusicStateAvailable(TMST_Camping) &&
		!IsMusicStateAvailable(TMST_Action) &&
		!IsMusicStateAvailable(TMST_Action_Winning) &&
		!IsMusicStateAvailable(TMST_Action_Losing))
	{
		SwitchToState(TMMS_Disabled,"None of the music states are available");
		return false;
	}
	if (!ValidateMusicStates())
	{
		SwitchToState(TMMS_Disabled,"Failed to validate music states");
		return false;
	}
	ValidateStingers();
	return true;
}

function StartManager()
{
local AudioDevice aDevice;

	if (ManagerState==TMMS_Running)
		return;
	aDevice=class'Engine'.static.GetAudioDevice();
	if (aDevice!=none)
	{
		MaxAudioComponents=int(aDevice.MaxChannels*musicManager_ACLimitRatio);
		if (MaxAudioComponents<6)
			MaxAudioComponents=musicManager_DefaultACLimit;
	}
	else
	{
		SwitchToState(TMMS_Disabled,"No Audio Device");
		return;
	}
	if ((WorldInfo.Game != none) && WorldInfo.Game.IsA('CPMenuGame'))           // ~Drakk : is there a better way to check this?
	{
		SwitchToState(TMMS_Disabled,"game class is CPMenuGame");
		return;
	}
	if (!CheckMusicInfo())
		return;
	if (Owner==none || !Owner.IsA('CPPlayerController'))
	{
		SwitchToState(TMMS_Disabled,"Owner is not a CPPlayerController");
		return;
	}
	PlayerOwner=CPPlayerController(Owner);
	MusicStartTime=WorldInfo.TimeSeconds;
	CreateNudgeTimeArray();
	bStarted=false;
	SwitchToState(TMMS_Running,"N/A");
}

function string MusicStateIntAsString(int _musicState)
{
	if (_musicState==0)
		return "Ambient";
	else if (_musicState==1)
		return "Camping";
	else if (_musicState==2)
		return "Action";
	else if (_musicState==3)
		return "Action-Winning";
	else if (_musicState==4)
		return "Action-Losing";
	else if (_musicState==6)
		return "Stinger";
	return "";
}

/* track control */
function bool CreateTrack(TAMusicSegment _MusicSegment,TASegmentInfo _SegmentInfo)
{
local STAMusicTrack newTrack;
local bool bFound;
local int k;

	if (_SegmentInfo.SoundCue==none)
		return false;
	if (ManagerACCreationFails>musicManager_ACCFLimit)
	{
		`log("unable to create a new track, reached ACCF limit : "$ManagerACCreationFails,musicManager_Logging,musicManager_logTag);
		SwitchToState(TMMS_Disabled,"Reached ACCF limit");
		return false;
	}
/*
	for (k=0;k<ManagerTracks.Length;k++)
	{
		if (!ManagerTracks[k].bReset && ManagerTracks[k].SegmentInfo==_SegmentInfo)
		{
			`log("trying to play segment info that is already playing "$_SegmentInfo.SoundCue,musicManager_Logging,musicManager_logTag);
			AdjustedStopSegment(ManagerTracks[k].SegmentInfo);
//			return false;
		}
	}
*/
	bFound=false;
	for (k=0;k<ManagerTracks.Length;k++)
	{
		if (ManagerTracks[k].bReset && ManagerTracks[k].AC!=none)
		{
			newTrack=ManagerTracks[k];
			newTrack.AC.SoundCue=_SegmentInfo.SoundCue;
			PlayerOwner.ReattachComponent(newTrack.AC);
			bFound=true;
			break;
		}
	}
	if (!bFound)
		newTrack.AC=PlayerOwner.CreateAudioComponent(_SegmentInfo.SoundCue,false,true);
	newTrack.MusicSegment=_MusicSegment;
	newTrack.SegmentInfo=_SegmentInfo;
	if (newTrack.AC==none)
	{
		ManagerACCreationFails++;
		return false;
	}
	newTrack.bReset=false;
	ManagerACCreationFails=0;
	newTrack.AC.bAutoPlay=false;
	newTrack.AC.bStopWhenOwnerDestroyed=true;
	newTrack.AC.bShouldRemainActiveIfDropped=true;
	newTrack.AC.bSuppressSubtitles=true;
	newTrack.AC.bAllowSpatialization=false;
	newTrack.AC.bApplyRadioFilter=false;
//	newTrack.AC.bIsMusic=true;
	newTrack.AC.VolumeMultiplier*=_SegmentInfo.VolumeMultiplier;
	newTrack.AC.OnAudioFinished=TrackFinished;
	if (!bFound)
		ManagerTracks.AddItem(newTrack);
	else
		ManagerTracks[k]=newTrack;
	return true;
}

function bool FadeTrack(TASegmentInfo _SegmentInfo,bool bFadeMode)
{
local int k;
local float beatRate;

	if (_SegmentInfo.SoundCue==none)
		return false;
	for (k=0;k<ManagerTracks.Length;k++)
	{
		if (!ManagerTracks[k].bReset && ManagerTracks[k].SegmentInfo==_SegmentInfo)
		{
			if (ManagerTracks[k].MusicSegment.SegmentBaseTempoOverride>0.0)
				beatRate=ManagerTracks[k].MusicSegment.SegmentBaseTempoOverride;
			else
				beatRate=MusicInfo.BaseTempo;
			beatRate=(60.0/beatRate);
			if (bFadeMode)
				ManagerTracks[k].AC.FadeOut(ManagerTracks[k].SegmentInfo.FadeOutBeatCount*beatRate,0.0);
			else
				ManagerTracks[k].AC.FadeIn(ManagerTracks[k].SegmentInfo.FadeInBeatCount*beatRate,1.0);			
			return true;
		}
	}
	return false;
}

function bool KillTrack(TASegmentInfo _SegmentInfo)
{
local int k;

	if (_SegmentInfo.SoundCue==none)
		return false;
	for (k=0;k<ManagerTracks.Length;k++)
	{
		if (!ManagerTracks[k].bReset && ManagerTracks[k].SegmentInfo==_SegmentInfo)
		{
			ManagerTracks[k].AC.Stop();
			ManagerTracks[k].AC.ResetToDefaults();
			if (ManagerTracks.Length>MaxAudioComponents)
				ManagerTracks.Remove(k,1);
			else
				ManagerTracks[k].bReset=true;
			return true;
		}
	}
	return false;
}

function KillAllTracks()
{
local int k;

	for (k=0;k<ManagerTracks.Length;k++)
		ManagerTracks[k].AC.Stop();
	ManagerTracks.Remove(0,ManagerTracks.Length);
}

function bool IsTrack(TASegmentInfo _SegmentInfo)
{
local int k;

	if (_SegmentInfo.SoundCue==none)
		return false;
	for (k=0;k<ManagerTracks.Length;k++)
		if (!ManagerTracks[k].bReset && ManagerTracks[k].SegmentInfo==_SegmentInfo)
			return true;
	return false;
}

function bool IsTrackTypePlaying(ETASegmentInfoType segType,int loopLevel,out TASegmentInfo segOut,optional ETASegmentEventName listenType,optional name eventName)
{
local int k;

	for (k=0;k<ManagerTracks.Length;k++)
	{
		if (!ManagerTracks[k].bReset && ManagerTracks[k].SegmentInfo.Type==segType &&
			ManagerTracks[k].MusicSegment==GetMusicStateSegment(MusicState))
		{
			if ((((segType==TSIT_SecondaryLoop || segType==TSIT_SegmentStinger) && ManagerTracks[k].SegmentInfo.LoopLevel==loopLevel) ||
				(segType==TSIT_EventDependent && ManagerTracks[k].SegmentInfo.ConditionListenEvent==listenType && ManagerTracks[k].SegmentInfo.LoopLevel==loopLevel) ||
				(segType==TSIT_EventDependent && listenType==TSEN_KismetEvent && ManagerTracks[k].SegmentInfo.ConditionListenEvent==listenType && ManagerTracks[k].SegmentInfo.KismetEventName==eventName) ||
				(segType!=TSIT_SecondaryLoop && segType!=TSIT_SegmentStinger && segType!=TSIT_EventDependent)) && !ManagerTracks[k].AC.IsFadingOut())
			{
				segOut=ManagerTracks[k].SegmentInfo;
				return true;
			}
		}
	}
	return false;
}

function TrackFinished(AudioComponent AC)
{
local int k;

	if (AC==none)
		return;
	for (k=0;k<ManagerTracks.Length;k++)
	{
		if (ManagerTracks[k].AC==AC)
		{
			AC.ResetToDefaults();
			if (ManagerTracks.Length>MaxAudioComponents)
				ManagerTracks.Remove(k,1);
			else
				ManagerTracks[k].bReset=true;
			return;
		}
	}
	`log("ERRORORRR CGDF GFDGHDFGHDFGRDTURTRDGDFGNFDNGKF");
}
/* track control */

/* music state control */
function bool SetMusicState(ETAMusicState _newState,optional SoundCue stingerCue)
{
	if (_newState<TMST__length && !IsMusicStateAvailable(_newState))
		return false;
	if (MusicState==_newState)
		return true;
	if (_newState==TMST_Stinger)
		StingerStateSoundCue=stingerCue;
	NextMusicState=_newState;
	bMusicStateChanged=true;
	return true;
}

function SetAValidMusicState()
{
	if (!SetMusicState(TMST_Ambient))
		SetAMusicState();
}

function SetAMusicState()
{
local int i;

	for (i=0;i<TMST__length;i++)
	{
		if (IsMusicStateAvailable(ETAMusicState(i)))
		{
			NextMusicState=ETAMusicState(i);
			bMusicStateChanged=true;
			return;
		}
	}
}

function SafeSetMusicState(ETAMusicState newState)
{
	if (!SetMusicState(newState))
		SetAValidMusicState();
}

function ETAMusicState GetActionMusicState()
{
local int i;
local CPPlayerReplicationInfo PRI;
local CPGameReplicationInfo GRI;
local int ownTeamCount,ownTeamCountAlive;
local int enemyTeamCount,enemyTeamCountAlive;
local int ownTeamIdx;

	GRI=CPGameReplicationInfo(WorldInfo.GRI);
	if (GRI==none)
		return TMST_Action;
	ownTeamIdx=PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
	for (i=0;i<GRI.PRIArray.Length;i++)
	{
		PRI=CPPlayerReplicationInfo(GRI.PRIArray[i]);
		if (PRI!=none && !PRI.bIsInactive && !PRI.bOnlySpectator && (PRI.Owner!=none ||
			(CPPlayerController(PRI.Owner)!=none && CPPlayerController(PRI.Owner).Player!=none)))
		{
			if (PRI.Team.TeamIndex==ownTeamIdx)
			{
				ownTeamCount++;
				if (!PRI.bOutOfLives && !PRI.bHasEscaped)
					ownTeamCountAlive++;
			}
			else
			{
				enemyTeamCount++;
				if (!PRI.bOutOfLives && !PRI.bHasEscaped)
					enemyTeamCountAlive++;
			}
		}
	}
	if (ownTeamCount<2 || enemyTeamCount<2)
		return TMST_Action;
	if (ownTeamCount>=3 && enemyTeamCount>=3)
	{
		if (ownTeamCountAlive-enemyTeamCountAlive>=2)
			return TMST_Action_Winning;
		else if (enemyTeamCountAlive-ownTeamCountAlive>=2)
			return TMST_Action_Losing;
	}
	if (ownTeamCount>=2 && enemyTeamCount>=2)
	{
		if (ownTeamCountAlive-enemyTeamCountAlive>=1)
			return TMST_Action_Winning;
		else if (enemyTeamCountAlive-ownTeamCountAlive>=1)
			return TMST_Action_Losing;
	}
	return TMST_Action;
}

function UpdateMusicState()
{
	if (MusicInfo==none || PlayerOwner==none)
		return;
	if (MusicInfo.DEVStartWithMusicState>=0)
		return;
	if (PlayerOwner.PlayerReplicationInfo==none ||
		PlayerOwner.Pawn==none ||
		CPGameReplicationInfo(WorldInfo.GRI)==none)
	{
		SafeSetMusicState(TMST_Ambient);
		return;
	}
	if (PlayerOwner.IsDead() ||
		PlayerOwner.PlayerReplicationInfo.bIsSpectator ||
		PlayerOwner.PlayerReplicationInfo.bOnlySpectator ||
		PlayerOwner.PlayerReplicationInfo.bWaitingPlayer ||
		PlayerOwner.PlayerReplicationInfo.bOutOfLives ||
		!CPGameReplicationInfo(WorldInfo.GRI).bRoundHasBegun ||
		CPGameReplicationInfo(WorldInfo.GRI).bRoundIsOver ||
		CPGameReplicationInfo(WorldInfo.GRI).bWarmup ||
		!CPGameReplicationInfo(WorldInfo.GRI).bCanPlayersMove)
	{
		SafeSetMusicState(TMST_Ambient);
		return;	
	}
	if (PlayerOwner.bCampingWarningActive && !bDEVNoCampingState)
	{
		SafeSetMusicState(TMST_Camping);
		return;
	}
	if ((CPWeapon(PlayerOwner.Pawn.Weapon)!=none && CPWeapon(PlayerOwner.Pawn.Weapon).LastHitEnemyTime>WorldInfo.TimeSeconds-8.0) ||
		(CPPawn(PlayerOwner.Pawn)!=none && CPPawn(PlayerOwner.Pawn).LastHitTime>WorldInfo.TimeSeconds-8.0) ||
		(PlayerOwner.LastTeammateHitTime>WorldInfo.TimeSeconds-8.0))
	{
		SafeSetMusicState(GetActionMusicState());
		return;
	}
	if (bCamperWarning && !bDEVNoCampingState)
	{
		SafeSetMusicState(TMST_Camping);
		return;
	}
	SafeSetMusicState(TMST_Ambient);
}

function StartMusicPlayback()
{
	if (MusicState==TMST__length && !bStarted)
	{
		if (MusicInfo!=none && PlayerOwner!=none)
		{
			if (MusicInfo.DEVStartWithMusicState>=0 && MusicInfo.DEVStartWithMusicState<TMST__length)
			{
				if (!SetMusicState(ETAMusicState(MusicInfo.DEVStartWithMusicState)))
					UpdateMusicState();
			}
			else
			{
				if (MusicInfo.Stingers.Intro!=none)
				{
					if (!SetMusicState(TMST_Stinger,MusicInfo.Stingers.Intro))
						UpdateMusicState();
				}
				else
					UpdateMusicState();
			}
		}
		bStarted=true;
	}
}

// sound mode
function SetStateSoundMode()
{
local TAMusicSegment taMusSeg;

	if (MusicInfo==none || PlayerOwner==none)
		return;
	taMusSeg=GetMusicStateSegment(MusicState);
	PlayerOwner.SetMusicSoundMode(taMusSeg.SegmentSoundMode);
}

// quick query
// ~Drakk : quick way to get a value from the current music state, instead of getting the struct
//          this function does a direct access which I suppose is faster, right now only the
//          camper warning level is used
function int GetMusicSegmentValueInt(ETAMusicSegmentQueryValueName value)
{
	if (MusicInfo==none)
		return 0;
	if (MusicState==TMST_Ambient)
	{
		if (value==TMSV_CamperWarningMaxLevel)
			return MusicInfo.Segment_Ambient.MaxCamperWarningLevel;
		else if (value==TMSV_CampingWarningMaxLevel)
			return MusicInfo.Segment_Ambient.MaxCampingWarningLevel;
	}
	else if (MusicState==TMST_Camping)
	{
		if (value==TMSV_CamperWarningMaxLevel)
			return MusicInfo.Segment_Camping.MaxCamperWarningLevel;
		else if (value==TMSV_CampingWarningMaxLevel)
			return MusicInfo.Segment_Camping.MaxCampingWarningLevel;
	}
	else if (MusicState==TMST_Action)
	{
		if (value==TMSV_CamperWarningMaxLevel)
			return MusicInfo.Segment_Action.MaxCamperWarningLevel;
		else if (value==TMSV_CampingWarningMaxLevel)
			return MusicInfo.Segment_Action.MaxCampingWarningLevel;
	}
	else if (MusicState==TMST_Action_Winning)
	{
		if (value==TMSV_CamperWarningMaxLevel)
			return MusicInfo.Segment_Action_Winning.MaxCamperWarningLevel;
		else if (value==TMSV_CampingWarningMaxLevel)
			return MusicInfo.Segment_Action_Winning.MaxCampingWarningLevel;
	}
	else if (MusicState==TMST_Action_Losing)
	{
		if (value==TMSV_CamperWarningMaxLevel)
			return MusicInfo.Segment_Action_Losing.MaxCamperWarningLevel;
		else if (value==TMSV_CampingWarningMaxLevel)
			return MusicInfo.Segment_Action_Losing.MaxCampingWarningLevel;
	}
	return 0;
}

// stinger state
function StingerStateTrackFinished(AudioComponent AC)
{
	`log("stinger state track finished",musicManager_Logging,musicManager_logTag);
	UpdateMusicState();
	StingerStateAC=none;
	StingerStateSoundCue=none;
}

function bool CreateTrackForStingerState()
{
local float duration;

	`log("create track for stinger state with : "$StingerStateSoundCue,musicManager_Logging,musicManager_logTag);
	if (StingerStateSoundCue==none)
		return false;
	if (!GetLongestWaveNodeDuration(StingerStateSoundCue.FirstNode,duration))
		return false;
	StingerStateAC=PlayerOwner.CreateAudioComponent(StingerStateSoundCue,false,true);
	if (StingerStateAC==none)
		return false;
	StingerStateAC.bAutoPlay=false;
	StingerStateAC.bStopWhenOwnerDestroyed=true;
	StingerStateAC.bShouldRemainActiveIfDropped=true;
	StingerStateAC.bSuppressSubtitles=true;
	StingerStateAC.bAllowSpatialization=false;
	StingerStateAC.bApplyRadioFilter=false;
	StingerStateAC.bIsMusic=true;
	StingerStateAC.OnAudioFinished=StingerStateTrackFinished;
	StingerStateAC.VolumeMultiplier*=MusicInfo.StingerVolumeMultiplier;
	StingerStateAC.FadeIn(duration*0.2,1.0);
	return true;
}

// duration
function float GetSegmentRealDuration(TASegmentInfo _seg)
{
local float realDuration;

	if (_seg.SoundCue==none)
		return 10000.0;
	realDuration=GetCurrentStateBeatRate()*_seg.DurationInBeats;
	if (realDuration<=0.0)
		`log("real duration is incorrect "$realDuration,musicManager_Logging,musicManager_logTag);
	return realDuration;
}

function float GetCurrentStateBeatRate()
{
local TAMusicSegment taMusSeg;
local int bpmBase;

	taMusSeg=GetMusicStateSegment(MusicState);
	if (taMusSeg.SegmentBaseTempoOverride>0.0)
		bpmBase=taMusSeg.SegmentBaseTempoOverride;
	else
		bpmBase=MusicInfo.BaseTempo;
	return (bpmBase/60.0);
}

// main
function OnFaderCompleted()
{
	AdjustedStopSegment(faderSeg);
	if (FaderMode)
		FaderMode=false;
	else
		FaderMode=true;
	SetMusicState(FaderPendingMusicState);
}

function bool HandleMusicStateSwitch()
{
local TASegmentInfo junkObject;
local ETAMusicState oldMusState;

	if (FaderPendingMusicState!=NextMusicState && NextMusicState!=TMST_Fader && !FaderMode)
	{
		FaderPendingMusicState=NextMusicState;
		if (GetMusicStateSegmentSuggestion(TSIT_FadeOutHelper,0,junkObject,faderSeg))
		{
			SetTimer(GetSegmentRealDuration(faderSeg)-(faderSeg.FadeOutBeatCount*GetCurrentStateBeatRate()),false,nameof(OnFaderCompleted));
			SetMusicState(TMST_Fader);
			CleanOutOldTracks();
			AdjustedPlaySegment(faderSeg);
			return false;
		}
		else
			FaderMode=true;
	}
	if (FaderMode && NextMusicState!=TMST_Fader)
	{
		FaderPendingMusicState=NextMusicState;
		oldMusState=MusicState;
		MusicState=NextMusicState;
		if (GetMusicStateSegmentSuggestion(TSIT_FadeInHelper,0,junkObject,faderSeg))	
		{
			SetTimer(GetSegmentRealDuration(faderSeg)-(faderSeg.FadeOutBeatCount*GetCurrentStateBeatRate()),false,nameof(OnFaderCompleted));
			MusicState=oldMusState;
			SetMusicState(TMST_Fader);
			CleanOutOldTracks();
			AdjustedPlaySegment(faderSeg);
			return false;
		}
	}
	if (FaderMode && NextMusicState!=TMST_Fader)
		FaderMode=false;
	MusicState=NextMusicState;
	return true;
}

function Tick(float DeltaTime)
{
local int i;

	if (ManagerState!=TMMS_Running)
		return;
	if (bMusicStateChanged && ((MusicSegmentBeatCount % MusicInfo.StateChangeOnBeat)==0 || MusicState==TMST_Stinger || MusicState==TMST__length || MusicState==TMST_Fader))
	{
		bMusicStateChanged=false;
		if (NextMusicState!=TMST_Fader)
		{
			CleanNudgeTimeArray();
			PurgeKismetEvents();
			PurgeTrackAdjusters();
		}

		if (MusicState==TMST_Stinger)
			MusicState=NextMusicState;
		else if (!HandleMusicStateSwitch())
			return;
		
		MusicSegmentBeatRate=GetCurrentStateBeatRate();
		if (MusicState!=TMST_Fader)
			CleanOutOldTracks();
		if (MusicState==TMST_Stinger)
		{
			if (!CreateTrackForStingerState())
			{
				UpdateMusicState();
				return;
			}
		}
		else if (MusicState!=TMST_Fader)
		{
			PreNudgeByLoopTypes();
			NudgeStateBaseLoop();
			SetStateSoundMode();
		}
		bLastCamperWarning=false;
		LastCamperWarningLevel=0;
		bFirstBeat=true;
		SegmentStartBeat=MusicSegmentBeatCount+1;
		`log("switched music state to "$MusicState,musicManager_Logging,musicManager_logTag);
	}
	if (MusicState==TMST_Stinger || MusicState==TMST__length)
		return;
	MusicSegmentBeatCount=FFloor((WorldInfo.TimeSeconds-MusicStartTime)*MusicSegmentBeatRate);
	if (bFirstBeat && MusicSegmentBeatCount>SegmentStartBeat)
		bFirstBeat=false;
	if (MusicState==TMST_Fader)
	{
		TrackAdjusterTick();
		return;
	}

	if ((MusicState==TMST_Action || MusicState==TMST_Action_Losing || MusicState==TMST_Action_Winning) &&
		((CPWeapon(PlayerOwner.Pawn.Weapon)!=none && CPWeapon(PlayerOwner.Pawn.Weapon).LastHitEnemyTime<WorldInfo.TimeSeconds-8.0) ||
		(CPPawn(PlayerOwner.Pawn)!=none && CPPawn(PlayerOwner.Pawn).LastHitTime<WorldInfo.TimeSeconds-8.0) ||
		(PlayerOwner.LastTeammateHitTime>WorldInfo.TimeSeconds-8.0)))
	{   
		UpdateMusicState();
	}

	if (NeedsNudge(TSIT_BaseLoop))
	{
		`log("nudging base loop",musicManager_Logging,musicManager_logTag);
		NudgeStateBaseLoop();
	}
	for (i=1;i<8;i++)
	{
		if (NeedsNudge(TSIT_SegmentStinger,i))
		{
			`log("nudging stinger loop level "$i,musicManager_Logging,musicManager_logTag);
			NudgeStateStingerLoop(i);
		}
	}
	for (i=1;i<8;i++)
	{
		if (NeedsNudge(TSIT_SecondaryLoop,i))
		{
			`log("nudging secondary loop level "$i,musicManager_Logging,musicManager_logTag);
			NudgeStateSecondaryLoop(i);
		}
	}

	if (((MusicSegmentBeatCount % MusicInfo.CamperWarningCheckBeatRate)==0) && GetMusicSegmentValueInt(TMSV_CamperWarningMaxLevel)>0)
		UpdateEvent_CamperWarning();

	if (((MusicSegmentBeatCount % MusicInfo.CampingWarningCheckBeatRate)==0) && GetMusicSegmentValueInt(TMSV_CampingWarningMaxLevel)>0)
		UpdateEvent_CampingWarning();

	if (KismetEventList.Length>0 && ((MusicSegmentBeatCount % MusicInfo.KismetEventCheckBeatRate)==0))
		UpdateEvent_Kismet();

	UpdateCamperWarningInfo();
	TrackAdjusterTick();
}

// camper warning
function UpdateCamperWarningInfo()
{
local int i;
local float fDist;
local float tmpDist;

	if (PlayerOwner.Pawn==none || PlayerOwner.IsDead())
	{
		if (bCamperWarning)
		{
			bCamperWarning=false;
			UpdateMusicState();
		}
		return;
	}
	fDist=1200.0;
	for (i=0;i<PlayerOwner.CamperInfos.Length;i++)
	{
		tmpDist=VSize(PlayerOwner.CamperInfos[i].CamperPos-PlayerOwner.Pawn.Location);
		if (tmpDist<1000.0)
		{
			if (tmpDist<fDist)
			{
				fDist=tmpDist;
				CamperWarnDistance=fDist;
			}
		}
	}
	if (fDist>0 && fDist<1200.0)
	{
		if (!bCamperWarning)
		{
			bCamperWarning=true;
			UpdateMusicState();
		}
	}
	else
	{
		if (bCamperWarning)
		{
			bCamperWarning=false;
			UpdateMusicState();
		}
	}
}

// track adjuster
function PurgeTrackAdjusters()                  // ~Drakk : does this need to be in a separate function?
{
	TrackAdjusterList.Remove(0,TrackAdjusterList.Length);
}

function QueneTrackAdjuster(TASegmentInfo _seg,bool bBeforeBeat,bool bFadeOut,int fadeBeat)
{
local STAAdjustedTrackControl adsTrack;

	if (_seg.SoundCue==none)
		return;
	if (fadeBeat<MusicSegmentBeatCount)
	{
		`log("unable to quene adjuster for segment "$_seg.SoundCue$", fade beat expired",musicManager_Logging,musicManager_logTag);
		if (!bFadeOut)
			DoSegmentFadeIn(_seg);
		else
			DoSegmentFadeOut(_seg);
		return;
	}
	adsTrack.bBeforeBeat=bBeforeBeat;
	adsTrack.bStop=bFadeOut;
	adsTrack.OnBeat=fadeBeat;
	adsTrack.SegmentInfo=_seg;
	TrackAdjusterList.AddItem(adsTrack);
}

function TrackAdjusterTick()
{
local int i;

	for (i=0;i<TrackAdjusterList.Length;i++)
	{
		if ((TrackAdjusterList[i].bBeforeBeat && (MusicSegmentBeatCount+1)>=TrackAdjusterList[i].OnBeat) ||
			(!TrackAdjusterList[i].bBeforeBeat && MusicSegmentBeatCount>=TrackAdjusterList[i].OnBeat))
		{
			if (!TrackAdjusterList[i].bStop)
			{
				`log("Track adjuster fade in for "$TrackAdjusterList[i].SegmentInfo.SoundCue,musicManager_Logging,musicManager_logTag);
				DoSegmentFadeIn(TrackAdjusterList[i].SegmentInfo);
			}
			else
			{
				`log("Track adjuster fade out for "$TrackAdjusterList[i].SegmentInfo.SoundCue,musicManager_Logging,musicManager_logTag);
				DoSegmentFadeOut(TrackAdjusterList[i].SegmentInfo);
			}
			TrackAdjusterList.Remove(i,1);
			i--;
		}
	}
}

// loop functions
function CleanOutOldTracks()
{
//local TAMusicSegment taMusSeg;
local int i;

	`log("cleaning old tracks",musicManager_Logging,musicManager_logTag);
//	taMusSeg=GetMusicStateSegment(MusicState);
	for (i=0;i<ManagerTracks.Length;i++)
	{
//		if (!ManagerTracks[i].bReset && ManagerTracks[i].MusicSegment!=taMusSeg)
		if (!ManagerTracks[i].bReset && ManagerTracks[i].SegmentInfo.Type!=TSIT_FadeOutHelper && ManagerTracks[i].SegmentInfo.Type!=TSIT_FadeInHelper)
		{
			`log("cleaning, issued fade out for "$ManagerTracks[i].SegmentInfo.SoundCue,musicManager_Logging,musicManager_logTag);
			DoSegmentFadeOut(ManagerTracks[i].SegmentInfo);
		}
	}
}

function CreateNudgeTimeArray()
{
	`log("create nudge time array",musicManager_Logging,musicManager_logTag);
	MusicTackNudgeRates.Remove(0,MusicTackNudgeRates.Length);
	MusicTackNudgeRates.Add(15);
}

function CleanNudgeTimeArray()
{
local int i;

	`log("clean nudge time array",musicManager_Logging,musicManager_logTag);
	for (i=0;i<MusicTackNudgeRates.Length;i++)
		MusicTackNudgeRates[i]=0.0;
}

function PreNudgeByLoopTypes()
{
local TAMusicSegment musSeg;
local TASegmentInfo testSeg;
local int k;

	`log("music segment pre nudging by loop types",musicManager_Logging,musicManager_logTag);
	musSeg=GetMusicStateSegment(MusicState);
	for (k=0;k<musSeg.SubSegments.Length;k++)
	{
		testSeg=musSeg.SubSegments[k];
		if (testSeg.Type!=TSIT_SecondaryLoop && testSeg.Type!=TSIT_SegmentStinger)
			continue;
		if (GetNudgeTimeFor(testSeg.Type,testSeg.LoopLevel)==0.0)
		{
			if (testSeg.Type==TSIT_SecondaryLoop && musSeg.SegmentPlayMode==TSPB_Immediate)
				SetNudgeTimeFor(testSeg.Type,0.1,testSeg.LoopLevel);
			else
				SetNudgeTimeFor(testSeg.Type,GetSegmentRealDuration(testSeg)*CheckNudgeMult(musSeg.SegmentNudgeRateStoppedToStartMult*1.5*FRand()),testSeg.LoopLevel);
			`log("pre nudge for "$testSeg.Type$" with loop level "$testSeg.LoopLevel,musicManager_Logging,musicManager_logTag);
		}
	}
	for (k=1;k<8;k++)
	{
		if (GetNudgeTimeFor(TSIT_SecondaryLoop,k)<=0.0)
			SetNudgeTimeFor(TSIT_SecondaryLoop,100000.0,k);
		if (GetNudgeTimeFor(TSIT_SegmentStinger,k)<=0.0)
			SetNudgeTimeFor(TSIT_SegmentStinger,100000.0,k);
	}
}

function float GetNudgeTimeFor(ETASegmentInfoType segType,optional int _level)
{
	if (MusicTackNudgeRates.Length<15)
		return 100000.0;
	if (segType==TSIT_BaseLoop)
		return MusicTackNudgeRates[0];
	else if (segType==TSIT_SegmentStinger && _level>0 && _level<8)
		return MusicTackNudgeRates[0+_level];
	else if (segType==TSIT_SecondaryLoop && _level>0 && _level<8)
		return MusicTackNudgeRates[7+_level];
	return 10000.0;
}

function SetNudgeTimeFor(ETASegmentInfoType segType,float nextCheckTime,optional int _level)
{
local float tmpTimeSec;
local float checkTime;

	if (MusicTackNudgeRates.Length<15)
		return;
	if (nextCheckTime<0.4)
		`log("set nudge time for "$segType$" is too low "$nextCheckTime$" for level "$_level,musicManager_Logging,musicManager_logTag);
	checkTime=FMax(nextCheckTime,0.4);
	tmpTimeSec=WorldInfo.TimeSeconds;
	if (segType==TSIT_BaseLoop)
		MusicTackNudgeRates[0]=tmpTimeSec+checkTime;
	else if (segType==TSIT_SegmentStinger && _level>0 && _level<8)
		MusicTackNudgeRates[0+_level]=tmpTimeSec+checkTime;
	else if (segType==TSIT_SecondaryLoop && _level>0 && _level<8)
		MusicTackNudgeRates[7+_level]=tmpTimeSec+checkTime;
}

function bool NeedsNudge(ETASegmentInfoType segType,optional int _level)
{
local float testTimeSecs;

	if (segType==TSIT_EventDependent ||
		segType==TSIT_FadeInHelper ||
		segType==TSIT_FadeOutHelper ||
		MusicTackNudgeRates.Length<15)
	{
		return false;
	}
	testTimeSecs=GetNudgeTimeFor(segType,_level);
	if (testTimeSecs<=0.0)
		return true;
	return ((WorldInfo.TimeSeconds-testTimeSecs)>(0.0+(FRand()*1.5-0.5)));
}

function bool GetMusicStateSegmentSuggestion(ETASegmentInfoType segType,int loopLevel,TASegmentInfo matchSeg,out TASegmentInfo segOut,optional ETASegmentEventName eventType,optional name eventName)
{
local TAMusicSegment musSeg;
local TASegmentInfo testSeg;
local int k;
local array<TASegmentInfo> sggSegList;
local float weightSum;
local float weightRnd;

	`log("music segment suggestion for "$segType,musicManager_Logging,musicManager_logTag);
	musSeg=GetMusicStateSegment(MusicState);
	for (k=0;k<musSeg.SubSegments.Length;k++)
	{
		testSeg=musSeg.SubSegments[k];
		if ((((testSeg.Type==TSIT_SecondaryLoop || testSeg.Type==TSIT_SegmentStinger) && testSeg.LoopLevel==loopLevel) ||
			(testSeg.Type==TSIT_EventDependent && testSeg.ConditionListenEvent==eventType && testSeg.LoopLevel==loopLevel) ||
			(testSeg.Type==TSIT_EventDependent && eventType==TSEN_KismetEvent && testSeg.ConditionListenEvent==eventType && testSeg.KismetEventName==eventName) ||
			(testSeg.Type!=TSIT_SecondaryLoop && testSeg.Type!=TSIT_SegmentStinger && testSeg.Type!=TSIT_EventDependent)) &&
			testSeg.Type==segType && matchSeg!=testSeg)
		{
			sggSegList.AddItem(testSeg);
		}
	}
	if (sggSegList.Length==0)
	{
		`log("failed to find loop type "$segType$" to make a suggestion",musicManager_Logging,musicManager_logTag);
		return false;
	}
	weightSum=0;
	for(k=0;k<sggSegList.Length;k++)
	   weightSum+=sggSegList[k].PlayWeight;
	weightRnd=FRand()*weightSum;
	for(k=0;k<sggSegList.Length;k++)
	{
		weightSum=sggSegList[k].PlayWeight;
		if(weightRnd<weightSum)
		{
			`log("music segment suggestion, choosen "$sggSegList[k].SoundCue,musicManager_Logging,musicManager_logTag);
			segOut=sggSegList[k];
			return true;
		}
		weightRnd-=weightSum;
	}
	`warn("should never get here");
	return false;
}

function DoSegmentFadeOut(TASegmentInfo _seg)
{
	if (_seg.SoundCue==none)
		return;
	if (!IsTrack(_seg))
		return;
	`log("do segment fade out for "$_seg.SoundCue,musicManager_Logging,musicManager_logTag);
	FadeTrack(_seg,true);
}

function DoSegmentFadeIn(TASegmentInfo _seg)
{
	if (_seg.SoundCue==none)
		return;
	if (!IsTrack(_seg))
		CreateTrack(GetMusicStateSegment(MusicState),_seg);
	`log("do segment fade in for "$_seg.SoundCue,musicManager_Logging,musicManager_logTag);
	FadeTrack(_seg,false);
}

function AdjustedPlaySegment(TASegmentInfo _seg)
{
local int pickedBeat;
local int maxBeatStep;
local int k,l;

	`log("adjusted play segment "$_seg.SoundCue,musicManager_Logging,musicManager_logTag);
	if (_seg.FadeTiming==TST_IgnoreBeat)
	{
		DoSegmentFadeIn(_seg);
		return;
	}
	if (_seg.FadeOnBeatIndexes.Length==0)
		pickedBeat=MusicSegmentBeatCount+1;
	else
	{
		maxBeatStep=0;
		for (k=0;k<_seg.FadeOnBeatIndexes.Length;k++)
		{
			if (_seg.FadeOnBeatIndexes[k]>maxBeatStep)
				maxBeatStep=_seg.FadeOnBeatIndexes[k];
		}
		if (maxBeatStep<=1)
			pickedBeat=MusicSegmentBeatCount+1;	
		else
		{
			for (k=0;k<maxBeatStep;k++)
			{
				for (l=0;l<_seg.FadeOnBeatIndexes.Length;l++)
				{
					if (((MusicSegmentBeatCount+k) % _seg.FadeOnBeatIndexes[l])==0)
					{
						pickedBeat=MusicSegmentBeatCount+k;
						break;					
					}
				}
			}
		}
	}
	`log("adjusted play segment quened with on beat "$pickedBeat,musicManager_Logging,musicManager_logTag);
	QueneTrackAdjuster(_seg,(_seg.FadeTiming==TST_AtBeginningOfBeat),false,pickedBeat);
}

function AdjustedStopSegment(TASegmentInfo _seg)
{
local int pickedBeat;
local int maxBeatStep;
local int k,l;

	`log("adjusted stop segment "$_seg.SoundCue,musicManager_Logging,musicManager_logTag);
	if (_seg.FadeTiming==TST_IgnoreBeat)
	{
		DoSegmentFadeOut(_seg);
		return;
	}
	if (_seg.FadeOnBeatIndexes.Length==0)
		pickedBeat=MusicSegmentBeatCount+1;
	else
	{
		maxBeatStep=0;
		for (k=0;k<_seg.FadeOnBeatIndexes.Length;k++)
		{
			if (_seg.FadeOnBeatIndexes[k]>maxBeatStep)
				maxBeatStep=_seg.FadeOnBeatIndexes[k];
		}
		if (maxBeatStep<=1)
			pickedBeat=MusicSegmentBeatCount+1;	
		else
		{
			for (k=0;k<maxBeatStep;k++)
			{
				for (l=0;l<_seg.FadeOnBeatIndexes.Length;l++)
				{
					if (((MusicSegmentBeatCount+k) % _seg.FadeOnBeatIndexes[l])==0)
					{
						pickedBeat=MusicSegmentBeatCount+k;
						break;					
					}
				}
			}
		}
	}
	`log("adjusted stop segment quened with on beat "$pickedBeat,musicManager_Logging,musicManager_logTag);
	QueneTrackAdjuster(_seg,(_seg.FadeTiming==TST_AtBeginningOfBeat),true,pickedBeat);
}

function AdjustedSwitchSegment(TASegmentInfo _segFrom,TASegmentInfo _segTo)
{
	`log("adjusted switch segment from "$_segFrom.SoundCue$" to "$_segTo.SoundCue,musicManager_Logging,musicManager_logTag);
	if (_segFrom==_segTo)
		return;
	if (_segFrom.FadeTiming!=TST_IgnoreBeat)               // ~Drakk : not sure if this is a good way to handle this
		AdjustedStopSegment(_segFrom);
	else
		DoSegmentFadeOut(_segFrom);
	if (_segTo.FadeTiming!=TST_IgnoreBeat)
		AdjustedPlaySegment(_segTo);
	else
		DoSegmentFadeIn(_segTo);
}

function float GetSegmentStingerNudgeRate()
{
local TASegmentInfo segInfo;

	if (!IsTrackTypePlaying(TSIT_BaseLoop,0,segInfo))
		return 100000.0;
	return (GetSegmentRealDuration(segInfo)*GetMusicStateSegment(MusicState).SegmentStingerNudgeRate);
}

// kismet event handling
function PurgeKismetEvents()
{
	KismetEventList.Remove(0,KismetEventList.Length);
}

function bool QueryKismetEvent(name eventName)
{
local int i;
local bool bQueryResult;
local TASegmentInfo taSegOut;

	if (eventName=='')
		return false;
	bQueryResult=false;
	for (i=0;i<KismetEventList.Length;i++)
	{
		if (KismetEventList[i].EventName==eventName)
			bQueryResult=(KismetEventList[i].EventType==TMKE_Start);
	}
	if (bQueryResult)
		return true;
	if (IsTrackTypePlaying(TSIT_EventDependent,0,taSegOut,TSEN_KismetEvent,eventName))
		return true;
	for (i=0;i<TrackAdjusterList.Length;i++)
	{
		if (TrackAdjusterList[i].SegmentInfo.Type==TSIT_EventDependent &&
			TrackAdjusterList[i].SegmentInfo.ConditionListenEvent==TSEN_KismetEvent &&
			TrackAdjusterList[i].SegmentInfo.KismetEventName==eventName &&
			!TrackAdjusterList[i].bStop)
		{
			return true;
		}
	}
	return false;
}

function QueneKismetEvent(TAMusicKismetEventType eventType,name eventName,float eventVolume)
{
local TASegmentInfo taSegOut;
local int i;
local bool bTrackPlaying;
local STAMusicKismetEvent kEvent;

	if (eventName=='' || eventType==TMKE_GetState)
		return;

	bTrackPlaying=IsTrackTypePlaying(TSIT_EventDependent,0,taSegOut,TSEN_KismetEvent,eventName);
	if ((eventType==TMKE_Start && bTrackPlaying) || (eventType==TMKE_Stop && !bTrackPlaying))
	{
		`log("failed to quene Kismet event "$eventName$" as "$eventType,musicManager_Logging,musicManager_logTag);
		return;
	}
	for (i=0;i<TrackAdjusterList.Length;i++)
	{
		if (TrackAdjusterList[i].SegmentInfo.Type==TSIT_EventDependent &&
			TrackAdjusterList[i].SegmentInfo.ConditionListenEvent==TSEN_KismetEvent &&
			TrackAdjusterList[i].SegmentInfo.KismetEventName==eventName)
		{
			if ((eventType==TMKE_Start && !TrackAdjusterList[i].bStop) ||
				(eventType==TMKE_Stop && TrackAdjusterList[i].bStop))
			{
				`log("failed to quene Kismet event "$eventName$" as "$eventType$" already in track adjusters",musicManager_Logging,musicManager_logTag);
				return;
			}
		}
	}
	for (i=0;i<KismetEventList.Length;i++)
	{
		if (KismetEventList[i].EventName==eventName && KismetEventList[i].EventType==eventType)
		{	
			`log("failed to quene Kismet event "$eventName$" as "$eventType$" already quened",musicManager_Logging,musicManager_logTag);
			return;
		}
	}
	kEvent.EventName=eventName;
	kEvent.EventType=eventType;
	kEvent.VolumeMult=eventVolume;
	KismetEventList.AddItem(kEvent);
	`log("quened Kismet event "$eventName$" as "$eventType,musicManager_Logging,musicManager_logTag);
}

// nudgers
function float CheckNudgeMult(float fIn)
{
	if (fIn<=0.0)
		`log("check nudge mult failed with : "$fIn,musicManager_Logging,musicManager_logTag);
	return fIn;
}

function NudgeStateBaseLoop()
{
local TASegmentInfo taSegInfo;
local TASegmentInfo taSegSuggested;
local TASegmentInfo junkObject;
local TAMusicSegment musSeg;

	musSeg=GetMusicStateSegment(MusicState);
	if (IsTrackTypePlaying(TSIT_BaseLoop,0,taSegInfo))
	{
		if (GetMusicStateSegmentSuggestion(TSIT_BaseLoop,0,taSegInfo,taSegSuggested))
		{
			if (FRand()>taSegSuggested.PlayWeight)
				AdjustedSwitchSegment(taSegInfo,taSegSuggested);
			else
				`log("nudge state base loop,not playing suggestion but using it : "$taSegSuggested.SoundCue,musicManager_Logging,musicManager_logTag);				
			SetNudgeTimeFor(TSIT_BaseLoop,GetSegmentRealDuration(taSegSuggested)*CheckNudgeMult(musSeg.SegmentNudgeRatePlayingToStopMult*2.0*FRand()));
			`log("nudge state base loop, already playing, suggestion : "$taSegSuggested.SoundCue,musicManager_Logging,musicManager_logTag);
		}
		else
		{
			SetNudgeTimeFor(TSIT_BaseLoop,100000.0);
			`log("nudge state base loop, already playing, but no suggestion",musicManager_Logging,musicManager_logTag);
		}
	}
	else
	{
		`log("nudge state base loop, no loop playing",musicManager_Logging,musicManager_logTag);
		GetMusicStateSegmentSuggestion(TSIT_BaseLoop,0,junkObject,taSegSuggested);
		AdjustedPlaySegment(taSegSuggested);
		SetNudgeTimeFor(TSIT_BaseLoop,GetSegmentRealDuration(taSegSuggested)*CheckNudgeMult(musSeg.SegmentNudgeRatePlayingToStopMult*2.0*FRand()));
	}
}

function NudgeStateStingerLoop(int _level)
{
local TASegmentInfo taSegInfo;
local TASegmentInfo taSegSuggested;
local TASegmentInfo junkObject;

	if (IsTrackTypePlaying(TSIT_SegmentStinger,_level,taSegInfo))
	{
		KillTrack(taSegInfo);
		SetNudgeTimeFor(TSIT_SegmentStinger,(GetSegmentStingerNudgeRate()+GetSegmentRealDuration(taSegInfo))*(1.7*FRand()),_level);
		`log("segment stinger nudge for loop level "$_level$", killing track that's already playing",musicManager_Logging,musicManager_logTag);
		return;
	}
	if (FRand()<0.46)
	{
		SetNudgeTimeFor(TSIT_SegmentStinger,GetSegmentStingerNudgeRate()*(0.7*FRand()),_level);
		return;
	}
	if (GetMusicStateSegmentSuggestion(TSIT_SegmentStinger,_level,junkObject,taSegSuggested))
	{
		`log("nudge segment stinger loop level "$_level,musicManager_Logging,musicManager_logTag);
		AdjustedPlaySegment(taSegSuggested);
		SetNudgeTimeFor(TSIT_SegmentStinger,(GetSegmentStingerNudgeRate()+GetSegmentRealDuration(taSegSuggested))*(3.0*FRand()),_level);
	}
	else
	{
		SetNudgeTimeFor(TSIT_SegmentStinger,100000.0,_level);
		`log("failed to nudge segment stinger level "$_level$", no suggestion",musicManager_Logging,musicManager_logTag);
	}
}

function NudgeStateSecondaryLoop(int _level)
{
local TASegmentInfo taSegInfo;
local TASegmentInfo taSegSuggested;
local TASegmentInfo junkObject;
local TAMusicSegment musSeg;

	musSeg=GetMusicStateSegment(MusicState);
	if (musSeg.SegmentPlayMode==TSPB_Immediate && bFirstBeat)
	{
		if (GetMusicStateSegmentSuggestion(TSIT_SecondaryLoop,_level,taSegInfo,taSegSuggested))
		{
			`log("segment secondary loop playing immediate suggestion "$taSegSuggested.SoundCue$" for level "$_level,musicManager_Logging,musicManager_logTag);
			AdjustedPlaySegment(taSegSuggested);
			SetNudgeTimeFor(TSIT_SecondaryLoop,GetSegmentRealDuration(taSegSuggested)*CheckNudgeMult(musSeg.SegmentNudgeRatePlayingToStopMult*2.0*FRand()),_level);
			return;
		}
	}
	if (IsTrackTypePlaying(TSIT_SecondaryLoop,_level,taSegInfo))
	{
		if (FRand()>0.535)
		{
			AdjustedStopSegment(taSegInfo);
			SetNudgeTimeFor(TSIT_SecondaryLoop,GetSegmentRealDuration(taSegInfo)*CheckNudgeMult(musSeg.SegmentNudgeRateStoppedToStartMult*2.2*FRand()),_level);
			`log("segment secondary loop , killing loop for level "$_level,musicManager_Logging,musicManager_logTag);
			return;
		}
		else
		{
			if (FRand()<0.46)
			{
				SetNudgeTimeFor(TSIT_SecondaryLoop,GetSegmentRealDuration(taSegInfo)*CheckNudgeMult(musSeg.SegmentNudgeRatePlayingToStopMult*1.7*FRand()),_level);
				`log("segment secondary loop , keeping the loop playing for level "$_level,musicManager_Logging,musicManager_logTag);
				return;
			}
			else
			{
				AdjustedStopSegment(taSegInfo);
				`log("segment secondary loop , killing loop for level "$_level,musicManager_Logging,musicManager_logTag);
			}
		}
	}
	if (FRand()<0.46)
	{
		`log("segment secondary loop , not playing anything for level "$_level,musicManager_Logging,musicManager_logTag);
		IsTrackTypePlaying(TSIT_BaseLoop,0,taSegInfo);                                                    // ~Drakk : this returs the currently playing base loop
		SetNudgeTimeFor(TSIT_SecondaryLoop,GetSegmentRealDuration(taSegInfo)*CheckNudgeMult(musSeg.SegmentNudgeRateStoppedToStartMult*0.5*FRand()),_level);
		return;
	}
	if (GetMusicStateSegmentSuggestion(TSIT_SecondaryLoop,_level,taSegInfo,taSegSuggested))
	{
		`log("segment secondary loop playing suggestion "$taSegSuggested.SoundCue$" for level "$_level,musicManager_Logging,musicManager_logTag);
		AdjustedPlaySegment(taSegSuggested);
		SetNudgeTimeFor(TSIT_SecondaryLoop,GetSegmentRealDuration(taSegSuggested)*CheckNudgeMult(musSeg.SegmentNudgeRatePlayingToStopMult*2.0*FRand()),_level);
	}
	else
	{
		`log("segment secondary loop no different suggestion, trying to pick something else for level "$_level,musicManager_Logging,musicManager_logTag);
		if (GetMusicStateSegmentSuggestion(TSIT_SecondaryLoop,_level,junkObject,taSegSuggested))
		{
			`log("segment secondary loop playing suggestion "$taSegSuggested.SoundCue$" for level "$_level,musicManager_Logging,musicManager_logTag);
			AdjustedPlaySegment(taSegSuggested);
			SetNudgeTimeFor(TSIT_SecondaryLoop,GetSegmentRealDuration(taSegSuggested)*CheckNudgeMult(musSeg.SegmentNudgeRatePlayingToStopMult*2.0*FRand()),_level);
		}
		else
		{
			SetNudgeTimeFor(TSIT_SecondaryLoop,100000.0,_level);
			`log("failed to nudge segment secondary loop level "$_level$", no suggestion",musicManager_Logging,musicManager_logTag);
		}
	}
}

// events
function UpdateEvent_CamperWarning()
{
local int CurrentCamperWarningLevel;
local int MaxCamperWarnLevel;
local int i;
local TASegmentInfo segOut;
local TASegmentInfo junkObject;
local bool bWarningStatus;

	MaxCamperWarnLevel=GetMusicSegmentValueInt(TMSV_CamperWarningMaxLevel);
	if (!PlayerOwner.bCampingWarningActive)
		bWarningStatus=bCamperWarning;
	else
		bWarningStatus=false;

	if (bWarningStatus!=bLastCamperWarning)
	{
		if (!bWarningStatus)
		{
			for (i=1;i<MaxCamperWarnLevel+1;i++)
			{
				if (IsTrackTypePlaying(TSIT_EventDependent,i,segOut,TSEN_CamperWarning))
					AdjustedStopSegment(segOut);
			}
			LastCamperWarningLevel=0;
			`log("camper warning event : off",musicManager_Logging,musicManager_logTag);
		}
		else
			`log("camper warning event : on",musicManager_Logging,musicManager_logTag);
	}
	bLastCamperWarning=bWarningStatus;

	if (bWarningStatus)
	{
		CurrentCamperWarningLevel=MaxCamperWarnLevel-FFloor(CamperWarnDistance/(1000.0/MaxCamperWarnLevel));
		if (CurrentCamperWarningLevel!=LastCamperWarningLevel)
		{ 
			for (i=1;i<MaxCamperWarnLevel+1;i++)
			{
				if (IsTrackTypePlaying(TSIT_EventDependent,i,segOut,TSEN_CamperWarning) && i!=CurrentCamperWarningLevel)
					AdjustedStopSegment(segOut);
			}
			if (!IsTrackTypePlaying(TSIT_EventDependent,CurrentCamperWarningLevel,segOut,TSEN_CamperWarning))
				if (GetMusicStateSegmentSuggestion(TSIT_EventDependent,CurrentCamperWarningLevel,junkObject,segOut,TSEN_CamperWarning))
					AdjustedPlaySegment(segOut);
		}
		LastCamperWarningLevel=CurrentCamperWarningLevel;
	}
}

function UpdateEvent_CampingWarning()
{
local int CurrentCampingWarningLevel;
local int MaxCampingWarnLevel;
local int i;
local TASegmentInfo segOut;
local TASegmentInfo junkObject;

	MaxCampingWarnLevel=GetMusicSegmentValueInt(TMSV_CampingWarningMaxLevel);
	if (PlayerOwner.bCampingWarningActive!=bLastCampingWarning)
	{
		if (!PlayerOwner.bCampingWarningActive)             // ~Drakk : is this really needed? Levels already control the tracks
		{
			for (i=1;i<MaxCampingWarnLevel+1;i++)
			{
				if (IsTrackTypePlaying(TSIT_EventDependent,i,segOut,TSEN_CampingWarning))
					AdjustedStopSegment(segOut);
			}
			CampingWarningStopLevel=LastCampingWarningLevel;
			CampingWarningStopTime=WorldInfo.TimeSeconds;
			`log("camping warning event : off",musicManager_Logging,musicManager_logTag);
		}
		else
		{
			LastCampingWarningLevel=CampingWarningStopLevel-(FFloor(FMin(WorldInfo.TimeSeconds-CampingWarningStopTime,39.0)/(40.0/MaxCampingWarnLevel)));
			if (LastCampingWarningLevel>0)
				CamperWarningTimeSecOffset=FMax((LastCampingWarningLevel-1)*(40.0/MaxCampingWarnLevel),0.0);
			else
				CamperWarningTimeSecOffset=0.0;
			LastCampingWarningLevel=0;
			`log("camping warning event : on",musicManager_Logging,musicManager_logTag);
		}
	}
	bLastCampingWarning=PlayerOwner.bCampingWarningActive;

	if (PlayerOwner.bCampingWarningActive)
	{
		CurrentCampingWarningLevel=FFloor(FMin((WorldInfo.TimeSeconds+CamperWarningTimeSecOffset)-PlayerOwner.CampingStartTime,39.0)/(40.0/MaxCampingWarnLevel))+1;
		if (CurrentCampingWarningLevel!=LastCampingWarningLevel)
		{ 
			for (i=1;i<MaxCampingWarnLevel+1;i++)
			{
				if (IsTrackTypePlaying(TSIT_EventDependent,i,segOut,TSEN_CampingWarning) && i!=CurrentCampingWarningLevel)
					AdjustedStopSegment(segOut);
			}
			if (!IsTrackTypePlaying(TSIT_EventDependent,CurrentCampingWarningLevel,segOut,TSEN_CampingWarning))
				if (GetMusicStateSegmentSuggestion(TSIT_EventDependent,CurrentCampingWarningLevel,junkObject,segOut,TSEN_CampingWarning))
					AdjustedPlaySegment(segOut);
		}
		LastCampingWarningLevel=CurrentCampingWarningLevel;
	}
}

function UpdateEvent_Kismet()
{
local int i;
local TASegmentInfo segOut;
local TASegmentInfo junkSeg;
local bool bIsPlaying;

	if (KismetEventList.Length==0)
		return;
	for (i=0;i<KismetEventList.Length;i++)
	{
		if (KismetEventList[i].EventName=='' || KismetEventList[i].EventType==TMKE_GetState)
			continue;
		bIsPlaying=IsTrackTypePlaying(TSIT_EventDependent,0,segOut,TSEN_KismetEvent,KismetEventList[i].EventName);
		if (KismetEventList[i].EventType==TMKE_Start)
		{
			if (bIsPlaying)
			{
				`log("unable to play Kismet event "$KismetEventList[i].EventName$" event is already playing",musicManager_Logging,musicManager_logTag);
				KismetEventList.Remove(i,1);
				i--;
				continue;
			}
			if (!GetMusicStateSegmentSuggestion(TSIT_EventDependent,0,junkSeg,segOut,TSEN_KismetEvent,KismetEventList[i].EventName))
			{
				`log("unable to play Kismet event "$KismetEventList[i].EventName$" no suggestion",musicManager_Logging,musicManager_logTag);
				KismetEventList.Remove(i,1);
				i--;
				continue;
			}
			`log("playing Kismet event "$KismetEventList[i].EventName,musicManager_Logging,musicManager_logTag);
			AdjustedPlaySegment(segOut);
			KismetEventList.Remove(i,1);
			i--;
		}
		else if (KismetEventList[i].EventType==TMKE_Stop)
		{
			if (!bIsPlaying)
			{
				`log("unable to stop Kismet event "$KismetEventList[i].EventName$" the event is not playing currently",musicManager_Logging,musicManager_logTag);
				KismetEventList.Remove(i,1);
				i--;
				continue;
			}
			`log("stopping Kismet event "$KismetEventList[i].EventName,musicManager_Logging,musicManager_logTag);
			AdjustedStopSegment(segOut);
			KismetEventList.Remove(i,1);
			i--;
		}
		else if (KismetEventList[i].EventType==TMKE_Toggle)
		{
			if (bIsPlaying)
			{
				AdjustedStopSegment(segOut);
				`log("stoped playing Kismet event "$KismetEventList[i].EventName,musicManager_Logging,musicManager_logTag);
			}
			else
			{
				if (!GetMusicStateSegmentSuggestion(TSIT_EventDependent,0,junkSeg,segOut,TSEN_KismetEvent,KismetEventList[i].EventName))
				{
					`log("unable to play Kismet event "$KismetEventList[i].EventName$" no suggestion",musicManager_Logging,musicManager_logTag);
					KismetEventList.Remove(i,1);
					i--;
					continue;
				}
				AdjustedPlaySegment(segOut);
				`log("playing stopped Kismet event "$KismetEventList[i].EventName,musicManager_Logging,musicManager_logTag);
			}
			KismetEventList.Remove(i,1);
			i--;
		}
	}
}

// Notifies
function Notify_PawnDied()
{
local int i;

	`log("notify pawn died, killing kismet music events",musicManager_Logging,musicManager_logTag);
	PurgeKismetEvents();

	for (i=0;i<TrackAdjusterList.Length;i++)
	{
		if (TrackAdjusterList[i].SegmentInfo.Type==TSIT_EventDependent && TrackAdjusterList[i].SegmentInfo.ConditionListenEvent==TSEN_KismetEvent)
		{
			TrackAdjusterList.Remove(i,1);
			i--;
		}
	}

	for (i=0;i<ManagerTracks.Length;i++)
	{
		if (!ManagerTracks[i].bReset &&
			ManagerTracks[i].SegmentInfo.Type==TSIT_EventDependent &&
			ManagerTracks[i].SegmentInfo.ConditionListenEvent==TSEN_KismetEvent)
		{
			AdjustedStopSegment(ManagerTracks[i].SegmentInfo);
		}
	}

	UpdateMusicState();
}
/* music state control */

/* States Block */
state tmms_Startup
{
	function BeginState(name PreviousName)
	{
		StartManager();
	}

//	function EndState(name NextStateName)
//	{
//		`log("leaving state , tmms_Startup",,musicManager_logTag);	
//	}
}

state tmms_Running
{
/*
	function BeginState(name PreviousName)
	{
	}
	function EndState(name NextStateName)
	{	
	}
*/
}

state tmms_Disabled
{
ignores CreateTrack,KillTrack,SetMusicState;

	function BeginState(name PreviousName)
	{
		KillAllTracks();
	}

//	function EndState(name NextStateName)
//	{
//		`log("leaving state , tmms_Disabled",,musicManager_logTag);	
//	}
}
/* States Block */

/* debug stuff */
function DebugSwitchMusicState(int newState)
{
	if (newState<0 || newState>TMST__length)
		return;
	if (!SetMusicState(ETAMusicState(newState)))
		`log("failed to set music state to "$ETAMusicState(newState),musicManager_Logging,musicManager_logTag);
}

function DebugForceNudge(int loopType,float newNudgeTime,int loopLevel)
{
	if (newNudgeTime<=0.0)
		newNudgeTime=1.0;
	if (loopType<0 || loopType>TSIT_FadeOutHelper)
		loopType=0;
	SetNudgeTimeFor(ETASegmentInfoType(loopType),newNudgeTime,loopLevel);
}

function DebugSetCamperMusicMode(bool bDisable)
{
	bDEVNoCampingState=!bDisable;
}

simulated function DisplayDebug(HUD HUD,out float out_YL,out float out_YPos)
{
local name stateName;
local int k;
local int numPlaying,numPlaying__;
local float timeSecs;
local float nudgeSum;
//local AudioComponent aComp;

	stateName=GetStateName();
	if (stateName=='tmms_Disabled')
		HUD.Canvas.SetDrawColor(190,50,50);
	else
		HUD.Canvas.SetDrawColor(0,216,255);
	HUD.Canvas.DrawText("Music manager state : "$stateName$" Reason : "$ManagerStateReasonStr);
	HUD.Canvas.SetDrawColor(0,216,255);
	out_YPos+=out_YL;
	if (stateName!='tmms_Disabled')
	{
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("Music Info "$MusicInfo$" owner "$PlayerOwner$" ACCF "$ManagerACCreationFails);
		out_YPos+=out_YL;
		HUD.Canvas.SetPos(4,out_YPos);
		if (MusicState==TMST_Stinger)
			HUD.Canvas.DrawText("Music state : "$MusicState$" with "$StingerStateSoundCue);
		else
			HUD.Canvas.DrawText("Music state : "$MusicState$" Beat "$(MusicSegmentBeatCount % 4)+1$"/4");
		out_YPos+=out_YL;

		if (MusicState==TMST_Stinger)
			return;

		if (MusicState!=TMST_Fader)
		{
			if (PlayerOwner.bCampingWarningActive)
			{
				HUD.Canvas.SetPos(4,out_YPos);
				if (GetMusicSegmentValueInt(TMSV_CampingWarningMaxLevel)>0)
					HUD.Canvas.DrawText("Camping Warning Level "$LastCampingWarningLevel);
				else
					HUD.Canvas.DrawText("Camping Warning Active , but not used");
				out_YPos+=out_YL;
			}
			else if (bCamperWarning)
			{
				HUD.Canvas.SetPos(4,out_YPos);
				if (GetMusicSegmentValueInt(TMSV_CamperWarningMaxLevel)>0)
					HUD.Canvas.DrawText("Camper Warning Level "$LastCamperWarningLevel);
				else
					HUD.Canvas.DrawText("Camper Warning Active , but not used");
				out_YPos+=out_YL;
			}
			else
			{
				HUD.Canvas.SetPos(4,out_YPos);
				HUD.Canvas.DrawText("No Camper/Camping Warning!");
				out_YPos+=out_YL;
			}
			timeSecs=WorldInfo.TimeSeconds;
			nudgeSum=MusicTackNudgeRates[0]-timeSecs;
			if (nudgeSum<60.0)
			{
				HUD.Canvas.SetPos(4,out_YPos);
				HUD.Canvas.DrawText(" | Base loop next nudge "$(nudgeSum<0.0 ? "pending" : string(FFloor(nudgeSum))));
				out_YPos+=out_YL;
			}
			for (k=1;k<8;k++)
			{
				nudgeSum=MusicTackNudgeRates[k]-timeSecs;
				if (nudgeSum<60.0)
				{
					HUD.Canvas.SetPos(4,out_YPos);
					HUD.Canvas.DrawText(" | Stinger loop level "$k$" next nudge "$(nudgeSum<0.0 ? "pending" : string(FFloor(nudgeSum))));
					out_YPos+=out_YL;
				}
			}
			for (k=8;k<14;k++)
			{
				nudgeSum=MusicTackNudgeRates[k]-timeSecs;
				if (nudgeSum<60.0)
				{
					HUD.Canvas.SetPos(4,out_YPos);
					HUD.Canvas.DrawText(" | Secondary loop level "$k-7$" next nudge "$(nudgeSum<0.0 ? "pending" : string(FFloor(nudgeSum))));
					out_YPos+=out_YL;
				}
			}
		}

		numPlaying=0;
		for (k=0;k<ManagerTracks.Length;k++)
		{
			if (ManagerTracks[k].bReset)
				continue;
			if (ManagerTracks[k].AC.IsPlaying())
				numPlaying++;
		}
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("  Track info - currently playing "$numPlaying$", all audio components "$ManagerTracks.Length$" - limit "$MaxAudioComponents);
		out_YPos+=out_YL;
		numPlaying__=0;
		for (k=0;k<ManagerTracks.Length;k++)
		{
			if (ManagerTracks[k].bReset)
				continue;
			if (numPlaying__>6)
			{
				HUD.Canvas.SetPos(4,out_YPos);
				HUD.Canvas.DrawText("  and "$numPlaying-numPlaying__$" more...");
				out_YPos+=out_YL;
				break;
			}
			HUD.Canvas.SetPos(4,out_YPos);
			HUD.Canvas.DrawText("   Track ("$ManagerTracks[k].SegmentInfo.Type$") DIB "$ManagerTracks[k].SegmentInfo.DurationInBeats$" - "$ManagerTracks[k].SegmentInfo.SoundCue);
			out_YPos+=out_YL;
			numPlaying__++;
		}
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText(" Track Adjusters - "$TrackAdjusterList.Length);
		out_YPos+=out_YL;
		for (k=0;k<TrackAdjusterList.Length;k++)
		{
			if (k>6)
			{
				HUD.Canvas.SetPos(4,out_YPos);
				HUD.Canvas.DrawText("  and "$k-6$" more...");
				out_YPos+=out_YL;
				break;
			}
			HUD.Canvas.SetPos(4,out_YPos);
			HUD.Canvas.DrawText("  "$((!TrackAdjusterList[k].bStop) ? "+" : "-")$" Adjuster "$TrackAdjusterList[k].SegmentInfo.SoundCue$" "$((TrackAdjusterList[k].bBeforeBeat) ? "before" : "after")$" beat within "$TrackAdjusterList[k].OnBeat-MusicSegmentBeatCount$" beats");
			out_YPos+=out_YL;
		}
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText(" Kismet Events - "$KismetEventList.Length);
		out_YPos+=out_YL;
		for (k=0;k<KismetEventList.Length;k++)
		{
			if (k>6)
			{
				HUD.Canvas.SetPos(4,out_YPos);
				HUD.Canvas.DrawText("  and "$k-6$" more...");
				out_YPos+=out_YL;
				break;
			}
			HUD.Canvas.SetPos(4,out_YPos);
			HUD.Canvas.DrawText("  "$KismetEventList[k].EventName$" "$KismetEventList[k].EventType$" with volume "$KismetEventList[k].VolumeMult);
			out_YPos+=out_YL;
		}
	}

//	foreach PlayerOwner.AllOwnedComponents(class'AudioComponent',aComp)
//	{
//		HUD.Canvas.SetPos(4,out_YPos);
//		HUD.Canvas.DrawText("  Audio Component : "$aComp$" with cue "$aComp.SoundCue);
//		out_YPos+=out_YL;
//	}
}
/* debug stuff */

defaultproperties
{
	InitialState=tmms_Startup
	MusicState=TMST__length
	FaderPendingMusicState=TMST__length
}
