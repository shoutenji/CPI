class CPMapMusicInfo extends UDKMapMusicInfo
	hidecategories(Object,UDKMapMusicInfo)
	editinlinenew;

enum ETASegmentTiming
{
	TST_AtBeginningOfBeat,
	TST_AtEndOfBeat,
	TST_IgnoreBeat,
};

enum ETASegmentInfoType
{
	TSIT_BaseLoop,
	TSIT_SecondaryLoop,
	TSIT_EventDependent,
	TSIT_SegmentStinger,
	TSIT_FadeInHelper,
	TSIT_FadeOutHelper,
};

enum ETASegmentEventName
{
	TSEN_CamperWarning,
	TSEN_CampingWarning,
	TSEN_KismetEvent,
};

enum ETASegmentPlayBehavior
{
	TSPB_Randomized,
	TSPB_Immediate,
};

struct TASegmentInfo
{
	var() ETASegmentInfoType Type					<ToolTip=Defines how this sound cue is used within the music segment>;
	var() SoundCue SoundCue							<ToolTip=The sound cue associated with this music segment info>;
	var() int LoopLevel								<ToolTip=Holds the channel of the loop if TSIT_SecondaryLoop is used in the SegmentType|UIMin=1|UIMax=7>;
	var() ETASegmentEventName ConditionListenEvent	<ToolTip=The events name this sound cue reacts to, only used when SegmentType is TSIT_EventDependent>;
	var() name KismetEventName						<ToolTip=The even from Kismet this sound cue reacts to, only used when SegmentType is TSIT_EventDependent and the listen event is TSEN_KismetEvent>;
	var() float PlayWeight							<ToolTip=A.K.A. Probability. The weight of this segment info compared to the others>;
	var() float VolumeMultiplier					<ToolTip=Volume multipiler just for this sound cue>;
	var() int FadeInBeatCount						<ToolTip=Percent of the whole sound duration used for fading in>;
	var() int FadeOutBeatCount					    <ToolTip=Percent of the whole sound duration used for fading out>;
	var() array<int> FadeOnBeatIndexes              <ToolTip=A list of beat indexes where fading to this segment is allowed if this list is empty then all beats are allowed>;
	var() ETASegmentTiming FadeTiming				<ToolTip=Defines how to crossfade for this segment>;
	var float DurationInBeats;

	structdefaultproperties
	{
		Type=TSIT_BaseLoop
		LoopLevel=1
		PlayWeight=1.0
		VolumeMultiplier=1.0
		FadeInBeatCount=1
		FadeOutBeatCount=1
		FadeOnBeatIndexes(0)=1
	}
};

struct TAMusicSegment
{
	var() array<TASegmentInfo> SubSegments					<ToolTip=List of segment infos associated with this segment>;
	var() ETASegmentPlayBehavior SegmentPlayMode			<ToolTip=The mode this segment should be played with>;
	var() name SegmentSoundMode						        <ToolTip=The sound mode for this segment, this is blended with the players sound mode>;
	var() float SegmentBaseTempoOverride					<ToolTip=The main tempo if this segment is active, 0 means use BaseTempo>;
	var() float SegmentStingerNudgeRate						<ToolTip=The rate compared to the current base loop duration when a stinger should be played, so 1.0 is once per base loop duration, 2.0 is twice per base loop, 0.5 once per 2 base loops>;
	var() float SegmentNudgeRatePlayingToStopMult           <ToolTip=Multiplier for nudge times when the track wants to stop>;
	var() float SegmentNudgeRateStoppedToStartMult          <ToolTip=Multiplier for nudge times when the track wants to start>;
	var float AvgSubSegDurationInBeats;
	var int MaxCamperWarningLevel;
	var int MaxCampingWarningLevel;

	structdefaultproperties
	{
		SegmentStingerNudgeRate=1.0
		SegmentNudgeRatePlayingToStopMult=1.0;
		SegmentNudgeRateStoppedToStartMult=1.0;
	}
};

struct TAMapStingers
{
	var() SoundCue Intro;
};

var(Stingers) float StingerVolumeMultiplier				<ToolTip=The volume multiplier just for stingers>;
var(Stingers) TAMapStingers Stingers					<ToolTip=Stingers for this music info>;

var(MusicInfo) bool bDEVDumpVerboseStatusToLog			<ToolTip=if enabled detailed status information will be dumped to the log>;
var(MusicInfo) int DEVStartWithMusicState               <ToolTip=starts with the specified music state ID if Settings to -1 no music state if forced>;
var(MusicInfo) float BaseTempo							<ToolTip=Base tempo ( BPM ) for this music info NOTE : music segments can override this!>;
var(MusicInfo) int StateChangeOnBeat                    <ToolTip=defines on which beat the state switching should happen>;
var(MusicInfo) int CamperWarningCheckBeatRate           <ToolTip=defines on which beat the camper warning must be checked>;
var(MusicInfo) int CampingWarningCheckBeatRate          <ToolTip=defines on which beat the camping warning must be checked>;
var(MusicInfo) int KismetEventCheckBeatRate             <ToolTip=defines on which beat the kismet event must be checked>;
var(MusicInfo) TAMusicSegment Segment_Ambient			<ScriptOrder=true|ToolTip=Played when nothing happens, this is the base segment>;
var(MusicInfo) TAMusicSegment Segment_Camping			<ScriptOrder=true|ToolTip=Played when for the session owner who is cammping or to somone how is near a camper>;
var(MusicInfo) TAMusicSegment Segment_Action			<ScriptOrder=true|ToolTip=Played when something happens that is related to the gameplay, shoting sighting enemy for example>;
var(MusicInfo) TAMusicSegment Segment_Action_Winning	<ScriptOrder=true|ToolTip=Played when the session owner's team is winning>;
var(MusicInfo) TAMusicSegment Segment_Action_Losing		<ScriptOrder=true|ToolTip=Played when the session owner's team is losing>;

defaultproperties
{
	StingerVolumeMultiplier=1.0
	BaseTempo=90.0
	StateChangeOnBeat=4
	CamperWarningCheckBeatRate=2
	CampingWarningCheckBeatRate=2
	KismetEventCheckBeatRate=2
	DEVStartWithMusicState=-1
}
