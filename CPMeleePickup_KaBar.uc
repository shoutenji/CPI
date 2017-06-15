class CPMeleePickup_KaBar extends CPMeleePickup;

simulated function CPWeapon GetLimitedWeapon()
{
	return spawn(class'CPWeap_KaBar');
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComp
		StaticMesh=StaticMesh'TA_WP_KABar.Mesh.SM_TA_KABar_Pickup'
		Scale=2
	End Object
	PickupMesh=StaticMeshComp;
	Components.Add(StaticMeshComp);
	
	InventoryClass=class'CPWeap_KaBar'
	
	Team = 0;
}