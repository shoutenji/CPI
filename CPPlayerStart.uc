class CPPlayerStart extends UDKTeamPlayerStart;

defaultproperties
{

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00040.000000
		CollisionHeight=+00080.000000
	End Object

	Begin Object NAME=Sprite LegacyClassName=PlayerStart_PlayerStartSprite_Class
		Sprite=Texture2D'EditorResources.S_Player'
		SpriteCategoryName="PlayerStart"
	End Object

}
