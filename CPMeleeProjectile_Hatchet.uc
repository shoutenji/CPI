class CPMeleeProjectile_Hatchet extends CPMeleeProjectile;

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComp
		bNotifyRigidBodyCollision=True
		ScriptRigidBodyCollisionThreshold=5.000000
		StaticMesh=StaticMesh'TA_WP_Hatchet.Mesh.SM_TA_Hatchet_Pickup'
		Scale=0.6
		Rotation=(Pitch=0,Yaw=-16384,Roll=0)
	End Object
	Components.Add(StaticMeshComp);
	MeshComp=StaticMeshComp
	CollisionComponent=StaticMeshComp
	
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder);
	
	Damage=34;
	
	Speed=2048.00
	MaxSpeed=5012.00
	
	rSpin=(X=0,Y=-9000,Z=0)
	
	MeleePickupClass=class'CPMeleePickup_Hatchet'
	MyDamageType=class'CPDmgType_Hatchet'
}