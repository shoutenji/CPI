class CPFlashlight extends SpotLightMovable
    notplaceable;

var float LightDiameter;
//Note: To change light width alter the OuterConeAngle (below). Default: 44.0

defaultproperties
{
    Begin Object name=SpotLightComponent0
        LightColor=(R=255,G=255,B=255)
		OuterConeAngle=40.0
    End Object
    bNoDelete=FALSE
}