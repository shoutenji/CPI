class CPVoice extends CPLocalMessage
	abstract;

var Array<SoundNodeWave> AckSounds;
var Array<SoundNodeWave> FriendlyFireSounds;
var Array<SoundNodeWave> GotYourBackSounds;
var Array<SoundNodeWave> NeedOurFlagSounds;
var Array<SoundNodeWave> SniperSounds;
var Array<SoundNodeWave> InPositionSounds;
var Array<SoundNodeWave> HaveFlagSounds;
var Array<SoundNodeWave> AreaSecureSounds;

var SoundNodeWave IncomingSound;
var SoundNodeWave EnemyFlagCarrierSound;
var SoundNodeWave EnemyFlagCarrierHereSound;
var SoundNodeWave EnemyFlagCarrierHighSound;
var SoundNodeWave EnemyFlagCarrierLowSound;
var SoundNodeWave MidfieldSound;
var SoundNodeWave GotOurFlagSound;

var int LocationSpeechOffset;

const ACKINDEXSTART=600;
const FRIENDLYFIREINDEXSTART=700;
const GOTYOURBACKINDEXSTART=800;
const NEEDOURFLAGINDEXSTART=900;
const SNIPERINDEXINDEXSTART=1000;
const LOCATIONUPDATEINDEXSTART=1100;
const INPOSITIONINDEXSTART=1200;
const ENEMYSTATUSINDEXSTART=1300;
const KILLEDVEHICLEINDEXSTART=1400;
const ENEMYFLAGCARRIERINDEXSTART=1500;
const HOLDINGFLAGINDEXSTART=1600;
const AREASECUREINDEXSTART=1700;
const GOTOURFLAGINDEXSTART=1900;
const NODECONSTRUCTEDINDEXSTART=2000;

static function int GetAckMessageIndex(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
	if ( default.AckSounds.Length==0)
		return -1;
	return ACKINDEXSTART+Rand(default.AckSounds.Length);
}

static function int GetFriendlyFireMessageIndex(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
	if ((default.FriendlyFireSounds.Length==0) || (Recipient==none) || (CPPlayerController(Recipient.Owner)==none))
		return -1;
	CPPlayerController(Recipient.Owner).LastFriendlyFireTime=Sender.WorldInfo.TimeSeconds;
	return FRIENDLYFIREINDEXSTART+Rand(default.FriendlyFireSounds.Length);
}

static function int GetGotYourBackMessageIndex(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
	if (default.GotYourBackSounds.Length==0)
		return -1;
	return GOTYOURBACKINDEXSTART+Rand(default.GotYourBackSounds.Length);
}

static function int GetNeedOurFlagMessageIndex(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
	if (default.NeedOurFlagSounds.Length==0)
		return -1;
	return NEEDOURFLAGINDEXSTART+Rand(default.NeedOurFlagSounds.Length);
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	CPPlayerController(P).PlayAnnouncement(default.class,Switch,RelatedPRI_1,OptionalObject);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex,Object OptionalObject,PlayerController PC)
{
	MessageIndex-=500;
	if (MessageIndex<0)
		return none;
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<default.AckSounds.Length)
		return default.AckSounds[MessageIndex];
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<default.FriendlyFireSounds.Length)
		return default.FriendlyFireSounds[MessageIndex];
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<default.GotYourBackSounds.Length)
		return default.GotYourBackSounds[MessageIndex];
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<default.NeedOurFlagSounds.Length)
		return default.NeedOurFlagSounds[MessageIndex];
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<default.SniperSounds.Length)
		return default.SniperSounds[MessageIndex];
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<100)
		return default.MidFieldSound;
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<default.InPositionSounds.Length)
		return default.InPositionSounds[MessageIndex];
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex==0)
		return EnemySound(PC,OptionalObject);
	
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	MessageIndex-=100;
	if (MessageIndex<0)
		return none;
	MessageIndex-=100;
	if (MessageIndex<0)
		return none;

	if (MessageIndex<default.AreaSecureSounds.Length)
		return default.AreaSecureSounds[MessageIndex];

	MessageIndex-=200;
	if (MessageIndex<0)
		return none;
	if (MessageIndex==0)
		return default.GotOurFlagSound;
	return None;
}

static function SoundNodeWave EnemySound(PlayerController PC,object OptionalObject)
{
local CPPlayerController TAPC;

	TAPC=CPPlayerController(PC);
	if ((TAPC!=none) && (TAPC.WorldInfo.TimeSeconds-TAPC.LastIncomingMessageTime>35))
	{
		TAPC.LastIncomingMessageTime=TAPC.WorldInfo.TimeSeconds;
		return default.IncomingSound;
	}
	return None;
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "";
}

static function bool AllowVoiceMessage(name MessageType, CPPlayerController PC,PlayerController Recipient)
{
local float CurrentTime;

	if (PC.WorldInfo.NetMode==NM_Standalone)
		return true;
	CurrentTime=PC.WorldInfo.TimeSeconds;
	if (CurrentTime-PC.OldMessageTime<4)
	{
		if ((MessageType=='TAUNT') || (CurrentTime-PC.OldMessageTime<1))
			return false;
	}
	if ((Recipient!=none) && Recipient.IsPlayerMuted(PC.PlayerReplicationInfo.UniqueID))
		return false;
	if (CurrentTime-PC.OldMessageTime<6 )
		PC.OldMessageTime=CurrentTime+3;
	else
		PC.OldMessageTime=CurrentTime;
	return true;
}

static function SendVoiceMessage(Controller Sender,PlayerReplicationInfo Recipient,Name Messagetype,class<DamageType> DamageType)
{
local CPPlayerController PC,SenderPC,RecipientPC;
local int MessageIndex;
local bool bFoundFriendlyPlayer;
local CPPlayerReplicationInfo SenderPRI;

	SenderPRI=CPPlayerReplicationInfo(Sender.PlayerReplicationInfo);
	if (SenderPRI==none)
		return;
	SenderPC=CPPlayerController(Sender);
	RecipientPC=(Recipient!=none) ? CPPlayerController(Recipient.Owner) : none;

	if ((RecipientPC==none) && Sender.WorldInfo.Game.bTeamGame)
	{
		foreach Sender.WorldInfo.AllControllers(class'CPPlayerController',PC)
		{
			if ((Sender.PlayerReplicationInfo!=none) && (PC.PlayerReplicationInfo!=none) 
				&& (Sender.PlayerReplicationInfo.Team==PC.PlayerReplicationInfo.Team) && (Sender!=PC))
			{
				bFoundFriendlyPlayer=true;
				break;
			}
		}
		if (!bFoundFriendlyPlayer)
			return;
	}
	if ((SenderPC!=none) && !AllowVoiceMessage(MessageType,SenderPC,RecipientPC))
		return;
	MessageIndex=GetMessageIndex(Sender,Recipient,MessageType,DamageType);
	if (MessageIndex==-1)
		return;
}

static function int GetMessageIndex(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype,class<DamageType> DamageType)
{
    switch (Messagetype)
    {
		case 'TAUNT':
			return -1;
		case 'INJURED':
			InitCombatUpdate(Sender,Recipient,MessageType);
			return -1;
		case 'STATUS':
			InitStatusUpdate(Sender,Recipient,MessageType);
			return -1;
		case 'INCOMING':
			return -1;
		case 'INPOSITION':
			SendInPositionMessage(Sender,Recipient,MessageType);
			return -1;
		case 'MANDOWN':
			return -1;
		case 'FRIENDLYFIRE':
			return GetFriendlyFireMessageIndex(Sender,Recipient,MessageType);
		case 'ENCOURAGEMENT':
			return -1;
		case 'FLAGKILL':
			return -1;
		case 'ACK':
			return GetAckMessageIndex(Sender,Recipient,MessageType);
		case 'GOTYOURBACK':
			return GetGotYourBackMessageIndex(Sender,Recipient,MessageType);
		case 'HOLDINGFLAG':
			SetHoldingFlagUpdate(Sender,Recipient,MessageType);
			return -1;
		case 'GOTOURFLAG':
			return GOTOURFLAGINDEXSTART;
		case 'NEEDOURFLAG':
			return GetNeedOurFlagMessageIndex(Sender,Recipient,MessageType);
	}
	return -1;
}

static function InitStatusUpdate(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
	InitCombatUpdate(Sender,Recipient,MessageType);
}

static function InitCombatUpdate(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
local int MessageIndex;

	if (Sender.Enemy==none)
	{
		if (default.AreaSecureSounds.Length==0)
			return;
		MessageIndex=AREASECUREINDEXSTART+Rand(default.AreaSecureSounds.Length);
	}
	else
		return;
	SendLocalizedMessage(Sender,Recipient,MessageType,MessageIndex);
}

static function SetHoldingFlagUpdate(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
local int MessageIndex;

	MessageIndex=HOLDINGFLAGINDEXSTART;
	if (default.HaveFlagSounds.Length==0)
		return;
	MessageIndex+=50+Rand(default.HaveFlagSounds.Length);
	SendLocalizedMessage(Sender,Recipient,MessageType,MessageIndex);
}

static function SendLocalizedMessage(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, int MessageIndex, optional object LocationObject)
{
local CPPlayerReplicationInfo SenderPRI;

	SenderPRI=CPPlayerReplicationInfo(Sender.PlayerReplicationInfo);
	if (SenderPRI==none)
		return;
}

static function SendInPositionMessage(Controller Sender,PlayerReplicationInfo Recipient,name Messagetype)
{
	if (default.InPositionSounds.Length>0)
		SendLocalizedMessage(Sender,Recipient,MessageType,INPOSITIONINDEXSTART+Rand(default.InPositionSounds.Length));
	InitCombatUpdate(Sender,Recipient,MessageType);
}

static function bool ShouldBeRemoved(CPQueuedAnnouncement MyAnnouncement,class<CPLocalMessage> NewAnnouncementClass,int NewMessageIndex)
{
local CPQueuedAnnouncement A;
local int VoiceMessageCount,MaxCount;

	if (NewAnnouncementClass==class'CPScriptedVoiceMessage')
		return true;
	if (ClassIsChildOf(NewAnnouncementClass,class'CPVoice'))
	{
		MaxCount=((MyAnnouncement.MessageIndex>=LOCATIONUPDATEINDEXSTART) && (MyAnnouncement.MessageIndex<LOCATIONUPDATEINDEXSTART+100))
					? 0
					: 1;
		for (A=MyAnnouncement.NextAnnouncement;A!=none;A=A.NextAnnouncement)
		{
			if (ClassIsChildOf(A.AnnouncementClass,class'CPVoice'))
			{
				VoiceMessageCount++;
				if (VoiceMessageCount>MaxCount)
					return true;
			}
		}
	}
	return false;
}

static function bool AddAnnouncement(CPAnnouncer Announcer,int MessageIndex,optional PlayerReplicationInfo PRI,optional Object OptionalObject)
{
local CPQueuedAnnouncement A;

	for (A=Announcer.Queue;A!=none;A=A.NextAnnouncement)
	{
		if (A.AnnouncementClass==class'CPScriptedVoiceMessage')
			return false;
	}
	super.AddAnnouncement(Announcer,MessageIndex,PRI,OptionalObject);
	return false;
}

defaultproperties
{
	bShowPortrait=true
	bIsConsoleMessage=false
	AnnouncementDelay=0.75
	AnnouncementPriority=-1
	AnnouncementVolume=0.7
}
