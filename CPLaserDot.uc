class CPLaserDot extends Actor;

var MeshComponent LaserMesh;


function Tick( float DeltaTime )
{
	local vector ViewStartLoc;
	local rotator ViewDir;
	local Vector EndTrace, HitLocation, HitDir;
	local TraceHitInfo HitInfo;	


	if ( Instigator != none )
	{
		Instigator.GetActorEyesViewPoint( ViewStartLoc, ViewDir );
		ViewDir = Instigator.GetBaseAimRotation();
		EndTrace = ViewStartLoc + vector( viewDir ) * 8192.0;

		if ( Trace( HitLocation, HitDir, EndTrace, ViewStartLoc, true,, HitInfo, TRACEFLAG_Bullet ) == none )
		{
			LaserMesh.SetScale( 0.0 );
			return;
		}

		SetLocation( HitLocation );

		LaserMesh.SetScale( FClamp( VSize( Location - ViewStartLoc ) / 768.0, 1.0, 3.0 ) + ( FRand() * 0.33 ) );
		LaserMesh.SetRotation( MakeRotator( Rand(65536), Rand(65536), Rand(65536) ) );
	}
	else
	{
		Destroy();
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=Mesh
		StaticMesh=StaticMesh'CP_LaserDot.LaserDot'
		HiddenGame=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=false
		AbsoluteScale=true
		AbsoluteRotation=true
		AbsoluteTranslation=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		MinDrawDistance=10.0
		bAllowAmbientOcclusion=false
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		CanBlockCamera=true
		CastShadow=false
	End Object
	LaserMesh=Mesh
	Components.Add(Mesh)


	TickGroup=TG_PreAsyncWork
	bReplicateInstigator=true
	bReplicateMovement=false
}