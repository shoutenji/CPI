class CPMeleePickup_Hatchet extends CPMeleePickup;

simulated function CPWeapon GetLimitedWeapon()
{
	return spawn(class'CPWeap_Hatchet');
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComp
		StaticMesh=StaticMesh'TA_WP_Hatchet.Mesh.SM_TA_Hatchet_Pickup'
		Rotation=(Pitch=0,Yaw=-16384,Roll=0)
		Scale=0.6
	End Object
	PickupMesh=StaticMeshComp;
	Components.Add(StaticMeshComp);
	
	InventoryClass=class'CPWeap_Hatchet'
	Team = 1;
}