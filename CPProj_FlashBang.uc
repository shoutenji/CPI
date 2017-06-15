class CPProj_FlashBang extends CPProj_Grenade;

static function float GetBlindTime(Vector Loc, Rotator Rot, Vector GrenLoc)
{
	local float distance, degrees;
	local Vector directToGrenade;
	directToGrenade = GrenLoc - Loc;
	distance = VSize(directToGrenade) / 52.5; // in meters
	degrees = Acos(Normal(vect(1,1,0) * Vector(Rot)) dot Normal(vect(1,1,0) * directToGrenade)) * RadToDeg; // in radians
	`log("Distance: "$distance$" Degrees: "$degrees);
	return Sqrt(FClamp(25 - ((distance * Cos(degrees) / 5) ** 2) - ((distance * Sin(degrees) / 4) ** 2), 0, 25));
}

static function float GetDeafTime(Vector Loc, Vector GrenLoc)
{
	return FClamp(7 - VSize(GrenLoc - Loc) / 210, 0, 7);
}

function FlashAndBang(Vector Loc)
{
	local CPPlayerController PC;
	local float Dist, Scale, BlindTime, DeafTime;
	local bool blnFlashed;

	ForEach WorldInfo.AllControllers(class'CPPlayerController', PC)
	{
		if(PC.Pawn != none)
		{
			// Player can't actually see it? Return.
			if(!FastTrace(PC.Pawn.Location, Loc))
				blnFlashed = false;
			else
				blnFlashed = true;

			BlindTime = GetBlindTime(PC.Pawn.Location, PC.Pawn.GetViewRotation(), Loc);
			DeafTime = GetDeafTime(PC.Pawn.Location, Loc);
		}
		
		`log(PC @ "Blind for " $ BlindTime $ " s and deaf for " $ DeafTime $ " s");

		// PLAY SOUND HERE (Sound doesn't care about view targets...)
		if(PC.ViewTarget != none)
		{
			Dist = VSize(Loc - PC.ViewTarget.Location);
			if(Dist < default.DamageRadius * 2.0)
			{
				Scale = (Dist < default.DamageRadius) ? 1.0 : (default.DamageRadius * 2.0 - Dist) / default.DamageRadius;
			
				if(blnFlashed)
					PC.DoFlash(BlindTime, Scale, Location);	
				//PC.ClientPlayCameraAnim(default.BlindCam, Scale, BlindTime/5.0);
			}
		}
	}
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
	super.Explode(HitLocation, HitNormal);
	if(Role == ROLE_Authority)
	{
		FlashAndBang(Location);
	}
}

defaultproperties
{
	ProjExplosionTemplate=ParticleSystem'CP_Juan_FX.Particles.PS_CP_Flash_Grenade_FXs'

	ExplosionDecal=MaterialInstanceTimeVarying'CP_Juan_FX.Decals.D_CP_Flash_Scorch_Decal_MITV'
	DecalWidth=100.0
	DecalHeight=100.0
	DecalDissolveParamName="AlphaControle"
	
	Begin Object Name=StaticMeshComp
		StaticMesh=StaticMesh'TA_WP_FlashBang.Mesh.SM_TA_FlashBang_Pickup'
		bNotifyRigidBodyCollision=True
		Scale=2.0
		ScriptRigidBodyCollisionThreshold=5.000000
	End Object

	MomentumTransfer=0.0
	Damage=0
	DamageRadius=525.0 //about 10 meters
	
	MyDamageType=Class'CPDmgType_Flashbang'
	ExplosionSound=SoundCue'CP_Weapon_Sounds.Grenades.FlashBang_Cue'
	WallBounceSound=SoundCue'CP_Weapon_Sounds.Grenades.CP_A_Flashbang_Drop_Cue'
}