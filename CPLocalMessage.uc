class CPLocalMessage extends LocalMessage
	abstract;

var int MessageArea;
var int AnnouncementPriority;
var bool bShowPortrait;
var float AnnouncementVolume;
var	float AnnouncementDelay;

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

static function SoundNodeWave AnnouncementSound(int MessageIndex,Object OptionalObject,PlayerController PC);

static function bool ShouldBeRemoved(CPQueuedAnnouncement MyAnnouncement, class<CPLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	return false;
}

static function bool AddAnnouncement(CPAnnouncer Announcer,int MessageIndex,optional PlayerReplicationInfo PRI,optional Object OptionalObject)
{
local CPQueuedAnnouncement NewAnnouncement,A,RemovedAnnouncement;
local bool bPlacedAnnouncement;

	NewAnnouncement=Announcer.Spawn(class'CPQueuedAnnouncement');
	NewAnnouncement.AnnouncementClass=Default.Class;
	NewAnnouncement.MessageIndex=MessageIndex;
	NewAnnouncement.PRI=PRI;
	NewAnnouncement.OptionalObject=OptionalObject;

	if (Announcer.Queue!=none && Announcer.Queue.AnnouncementClass.static.ShouldBeRemoved(Announcer.Queue,Default.Class,MessageIndex))
	{
		RemovedAnnouncement=Announcer.Queue;
		Announcer.Queue=Announcer.Queue.nextAnnouncement;
		RemovedAnnouncement.Destroy();
	}

	if ( Announcer.Queue==none)
	{
		NewAnnouncement.nextAnnouncement=Announcer.Queue;
		Announcer.Queue = NewAnnouncement;
	}
	else
	{
		if (default.AnnouncementPriority>Announcer.Queue.AnnouncementClass.default.AnnouncementPriority)
		{
			NewAnnouncement.nextAnnouncement=Announcer.Queue;
			Announcer.Queue=NewAnnouncement;
			bPlacedAnnouncement=true;
		}
		for (A=Announcer.Queue;A!=None;A=A.nextAnnouncement)
		{
			if (A.nextAnnouncement==none)
			{
				if (!bPlacedAnnouncement)
					A.nextAnnouncement=NewAnnouncement;
				break;
			}
			if (!bPlacedAnnouncement && default.AnnouncementPriority>A.NextAnnouncement.AnnouncementClass.default.AnnouncementPriority)
			{
				bPlacedAnnouncement=true;
				NewAnnouncement.NextAnnouncement=A.nextAnnouncement;
				A.NextAnnouncement=NewAnnouncement;
			}
			else if (A.nextAnnouncement.AnnouncementClass.static.ShouldBeRemoved(A.nextAnnouncement,Default.Class,MessageIndex))
			{
				RemovedAnnouncement=A.nextAnnouncement;
				A.nextAnnouncement=A.nextAnnouncement.nextAnnouncement;
				if (A.nextAnnouncement==none)
				{
					if (!bPlacedAnnouncement)
						A.nextAnnouncement=NewAnnouncement;
					break;
				}
				RemovedAnnouncement.Destroy();
			}
		}
	}
	return false;
}

static function float GetPos(int Switch,HUD myHUD)
{
	return (CPHUD(myHUD)!=none) ? CPHUD(myHUD).MessageOffset[Default.MessageArea] : 0.5;
}

static function bool KilledByVictoryMessage(int AnnouncementIndex)
{
	return (default.AnnouncementPriority<6);
}

defaultproperties
{
	MessageArea=1
	AnnouncementVolume=0.7
}
