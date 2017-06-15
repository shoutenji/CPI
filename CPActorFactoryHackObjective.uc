//==============================================================================
// CPActorFactoryHackObjective
// $wotgreal_dt: 10.03.2014 13:28:22$ by Crusha
//
// Adds functionality to the editor context menu to create a HackObjective actor
// in the map that uses the current selected StaticMesh from the Content Browser.
//==============================================================================
class CPActorFactoryHackObjective extends ActorFactoryDynamicSM;

DefaultProperties
{
    MenuName="Add Hacking Objective"
    NewActorClass=class'CPHackObjective'

    DrawScale3D=(X=1,Y=1,Z=1)
    CollisionType=COLLIDE_BlockAll
    bCastDynamicShadow=true
    bNoEncroachCheck=true
    bNotifyRigidBodyCollision=false
    bBlockRigidBody=true
}