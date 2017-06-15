//==============================================================================
// CPSeqEvent_ObjectiveCompleted
// $wotgreal_dt: 12.03.2014 16:13:56$ by Crusha
//
// Sequence Event that is triggered by the different game objectives when they
// get completed. Implement support for this in the specific objectives.
//==============================================================================
class CPSeqEvent_ObjectiveCompleted extends SequenceEvent;

defaultproperties
{
    ObjName="Objective Completed"
    ObjCategory="Objective"
}