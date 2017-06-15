class CPActorFactoryDestroyable extends ActorFactoryFracturedStaticMesh
	config(Editor);

simulated event PostCreateActor(Actor NewActor, optional const SeqAct_ActorFactory ActorFactoryData)
{
local CPDestroyable newDestroyable;

	if (NewActor==none || CPDestroyable(NewActor)==none)
		return;
	newDestroyable=CPDestroyable(NewActor);
	if (newDestroyable.FracturedStaticMesh!=none && FracturedStaticMesh!=none)
		newDestroyable.FracturedStaticMesh.SetStaticMesh(FracturedStaticMesh);
}

defaultproperties
{
	MenuName="Add CPDestroyable"
	NewActorClass=class'CriticalPoint.CPDestroyable'
}
