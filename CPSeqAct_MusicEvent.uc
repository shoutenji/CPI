class CPSeqAct_MusicEvent extends SequenceAction
	hidecategories(SequenceAction);

var() name EventName;

event Activated()
{
local CPPawn tmpPawn;
local float eventVolume;
local bool bTmpResult;
local SeqVar_Object seqObj;
local SeqVar_Float seqFloat;
local SeqVar_Bool seqBool;

	if (EventName=='')
	{
		ScriptLog("Music Event "$self$" activated without an event name");
		return;
	}

	foreach LinkedVariables(class'SeqVar_Object',seqObj,"Music Manager Owner")
		if (seqObj.GetObjectValue()!=none)
			break;
	
	if (seqObj==none)
	{
		ScriptLog("Music Event "$self$" activated without a linked instigator object");
		return;
	}
	tmpPawn=CPPawn(seqObj.GetObjectValue());
	if (tmpPawn==none || CPPlayerController(tmpPawn.Controller)==none)
		return;
	if (LocalPlayer(CPPlayerController(tmpPawn.Controller).Player)==none)
	{
		ScriptLog("Music Event "$self$" must be instignated by a local player");
		return;
	}
	
	foreach LinkedVariables(class'SeqVar_Float',seqFloat,"Volume Multiplier")
		break;
	if (seqFloat!=none)
		eventVolume=seqFloat.FloatValue;
	else
		eventVolume=1.0;

	if (InputLinks[0].bHasImpulse)
		CPPlayerController(tmpPawn.Controller).MusicManagerKismetEvent(TMKE_Start,EventName,eventVolume);
	else if (InputLinks[1].bHasImpulse)
		CPPlayerController(tmpPawn.Controller).MusicManagerKismetEvent(TMKE_Stop,EventName,eventVolume);
	else if (InputLinks[2].bHasImpulse)
		CPPlayerController(tmpPawn.Controller).MusicManagerKismetEvent(TMKE_Toggle,EventName,eventVolume);
	else if (InputLinks[3].bHasImpulse)
	{
		foreach LinkedVariables(class'SeqVar_Bool',seqBool,"State Out")
			break;
		if (seqBool==none)
		{
			ScriptLog("Music Event "$self$" get state input requires a boolean value to be connected");
			return;
		}
		bTmpResult=CPPlayerController(tmpPawn.Controller).MusicManagerKismetEvent(TMKE_GetState,EventName);
		seqBool.bValue=int(bTmpResult);
	}
}

static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion()+1;
}

defaultproperties
{
	ObjName="CP Music Event"
	ObjCategory="Music"
	ObjColor=(R=255,G=128,B=0,A=255)
	InputLinks.Empty
	OutputLinks.Empty
	VariableLinks.Empty
	InputLinks(0)=(LinkDesc="Start")
	InputLinks(1)=(LinkDesc="Stop")
	InputLinks(2)=(LinkDesc="Toggle")
	InputLinks(3)=(LinkDesc="Get State")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Music Manager Owner")
	VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Volume Multiplier")
	VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="State Out",bWriteable=true,PropertyName=StateOut)
}
