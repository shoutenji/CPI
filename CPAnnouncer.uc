class CPAnnouncer extends Info
	config(Game)
	DLLBind(CPIGameINIOptions);

var globalconfig byte AnnouncerLevel;				// 0=none, 1=no possession announcements, 2=all

/** class of currently playing announcement */
var class<CPLocalMessage> PlayingAnnouncementClass;

var int PlayingAnnouncementIndex;

/** Queued announcer messages */
var CPQueuedAnnouncement Queue;

var CPPlayerController PlayerOwner;

/** the sound cue used for announcer sounds. We then use a wave parameter named Announcement to insert the actual sound we want to play.
 * (this allows us to avoid having to change a whole lot of cues together if we want to change SoundCue options for the announcements)
 */
var SoundCue AnnouncerSoundCue;

/** allows overriding AnnouncerSoundCue */
var globalconfig string CustomAnnouncerSoundCue;

/** the sound cue used for all UTVoice sounds. We then use a wave parameter named Announcement to insert the actual sound we want to play.
 * (this allows us to avoid having to change a whole lot of cues together if we want to change SoundCue options for the announcements)
 */
var SoundCue UTVoiceSoundCue;

/** allows overriding UTVoiceSoundCue */
var globalconfig string UTVoiceSoundCueSoundCue;

/** currently playing AudioComponent */
var AudioComponent CurrentAnnouncementComponent;

dllimport final function string GetSettingValue(string configname, string section, string key);

function Destroyed()
{
	local CPQueuedAnnouncement A;

	Super.Destroyed();

	if (CurrentAnnouncementComponent != none)
	{
		if (PlayerOwner != none)
		{
			PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
		}
		CurrentAnnouncementComponent = none;
	}

	for ( A=Queue; A!=None; A=A.nextAnnouncement )
		A.Destroy();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = CPPlayerController(Owner);

	if (CustomAnnouncerSoundCue != "")
	{
		AnnouncerSoundCue = SoundCue(DynamicLoadObject(CustomAnnouncerSoundCue, class'SoundCue')); // this will not work on consoles as there is no hard ref to this CustomAnnounceSoundCue unless it was put into the map
		AnnouncerSoundCue.SoundClass = 'Announcer';
	}

	if (UTVoiceSoundCueSoundCue != "")
	{
		UTVoiceSoundCue = SoundCue(DynamicLoadObject(UTVoiceSoundCueSoundCue, class'SoundCue')); // this will not work on consoles as there is no hard ref to this CustomAnnounceSoundCue unless it was put into the map
		UTVoiceSoundCue.SoundClass = 'SFX';
	}
}

function PlayNextAnnouncement()
{
	local CPQueuedAnnouncement PlayedAnnouncement;

	PlayingAnnouncementClass = None;

	if ( Queue != None )
	{
		PlayedAnnouncement = Queue;
		Queue = PlayedAnnouncement.nextAnnouncement;
		PlayAnnouncementNow(PlayedAnnouncement.AnnouncementClass, PlayedAnnouncement.MessageIndex, PlayedAnnouncement.PRI, PlayedAnnouncement.OptionalObject);
		PlayingAnnouncementClass = PlayedAnnouncement.AnnouncementClass;
		PlayingAnnouncementIndex = PlayedAnnouncement.MessageIndex;
		PlayedAnnouncement.Destroy();
	}
}

function PlayAnnouncementNow(class<CPLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	local SoundNodeWave ASound;
	local bool bUsingVoiceCue;
	
	local float MasterVolume;
	local CPSaveManager CPSaveManager;
	
	CPSaveManager = new () class'CPSaveManager';
	if(CPSaveManager != none)
	{
		MasterVolume = float(CPSaveManager.GetItem("VoiceVolume"));		
	}

	ASound = InMessageClass.Static.AnnouncementSound(MessageIndex, OptionalObject, PlayerOwner);

	if ( ASound != None )
	{
		if (CurrentAnnouncementComponent != none)
		{
			if (PlayerOwner != none)
			{
				PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
			}
			CurrentAnnouncementComponent = none;
		}

		//@FIXME: part of playsound pool?
		// if we are a UTVoice when we want to use the special UTVoiceSoundCue which is in the correct SoundClass (i.e. effects)
		if ( ClassIsChildOf( InMessageClass, class'CPVoice' ) || ClassIsChildOf( InMessageClass, class'CPScriptedVoiceMessage' ) )
		{
			CurrentAnnouncementComponent = PlayerOwner.CreateAudioComponent(UTVoiceSoundCue, false, false);
			bUsingVoiceCue = TRUE;
		}
		else
		{
			CurrentAnnouncementComponent = PlayerOwner.CreateAudioComponent(AnnouncerSoundCue, false, false);
			bUsingVoiceCue = FALSE;
		}

		// CurrentAnnouncementComponent will be none if -nosound option used
		if ( CurrentAnnouncementComponent != None )
		{
			CurrentAnnouncementComponent.SetWaveParameter('Announcement', ASound);
			if( bUsingVoiceCue )
			{
				UTVoiceSoundCue.Duration = ASound.Duration;
				UTVoiceSoundCue.VolumeMultiplier = MasterVolume; //InMessageClass.Default.AnnouncementVolume;
			}
			else
			{
				AnnouncerSoundCue.Duration = ASound.Duration;
				AnnouncerSoundCue.VolumeMultiplier = MasterVolume; //InMessageClass.Default.AnnouncementVolume;
			}
			CurrentAnnouncementComponent.VolumeMultiplier = MasterVolume;
			CurrentAnnouncementComponent.bAutoDestroy = true;
			CurrentAnnouncementComponent.bShouldRemainActiveIfDropped = true;
			CurrentAnnouncementComponent.bAllowSpatialization = false;
			CurrentAnnouncementComponent.bAlwaysPlay = TRUE;
			
			CurrentAnnouncementComponent.Play();
		}
		PlayingAnnouncementClass = InMessageClass;
		PlayingAnnouncementIndex = MessageIndex;

		// NOTE: Audio always plays back in real-time, so we'll scale our duration by the world's time dilation
		SetTimer(ASound.Duration * WorldInfo.TimeDilation + 0.05, false,'AnnouncementFinished');

		//if ( InMessageClass.default.bShowPortrait 
		//	&& (CPHUD(PlayerOwner.MyHUD) != None) 
		//	&& (CPPlayerReplicationInfo(PRI) != None) 
		//	&& (PRI != PlayerOwner.PlayerReplicationInfo) )
		//{
		//	CPHUD(PlayerOwner.MyHUD).ShowPortrait(CPPlayerReplicationInfo(PRI), ASound.Duration+0.5, ClassIsChildOf(InMessageClass, class'UTScriptedVoiceMessage'));
		//}
	}
	else
	{
		//`log("NO SOUND FOR "$InMessageClass@MessageIndex@OptionalObject@OptionalObject.name);
		PlayNextAnnouncement();
	}
}

function AnnouncementFinished(AudioComponent AC)
{
	if ((PlayerOwner != none) && (CurrentAnnouncementComponent != none))
	{
		PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
	}
	CurrentAnnouncementComponent = None;
	PlayingAnnouncementClass = None;
	PlayNextAnnouncement();
}

function PlayAnnouncement(class<CPLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI,  optional Object OptionalObject)
{
	if ( InMessageClass.Static.AnnouncementLevel(MessageIndex) > AnnouncerLevel )
	{
		return;
	}

	if ( (CurrentAnnouncementComponent == None) || CurrentAnnouncementComponent.bFinished )
	{
		PlayingAnnouncementClass = None;
		CurrentAnnouncementComponent = None;
	}

	if ( PlayingAnnouncementClass == None )
	{
		if ( (InMessageClass.default.AnnouncementDelay == 0.0) || ((PRI != None) && !PRI.bBot) )
		{
			// play immediately
			PlayAnnouncementNow(InMessageClass, MessageIndex, PRI, OptionalObject);
			return;
		}
		else
		{
			// NOTE: Audio always plays back in real-time, so we'll scale our delay by the world's time dilation
			SetTimer(InMessageClass.default.AnnouncementDelay * WorldInfo.TimeDilation, false,'AnnouncementFinished');
		}
	}

	//TOP-Proto fix this
	if ( InMessageClass.static.AddAnnouncement(self, MessageIndex, PRI, OptionalObject) )
	{
		if ( CurrentAnnouncementComponent != None )
		{
			CurrentAnnouncementComponent.Stop();
			if (PlayerOwner != none)
			{
				PlayerOwner.DetachComponent(CurrentAnnouncementComponent);
			}
			CurrentAnnouncementComponent = None;
		}
		PlayNextAnnouncement();
	}
}

defaultproperties
{
	AnnouncerSoundCue=SoundCue'TEMP_Cleanup.SoundCues.AnnouncerCue'
	UTVoiceSoundCue=SoundCue'TEMP_Cleanup.SoundCues.TAVoiceSoundCue'
}
