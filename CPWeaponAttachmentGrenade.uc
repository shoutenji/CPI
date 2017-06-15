class CPWeaponAttachmentGrenade extends CPWeaponAttachment;

var name		FireAnim_Mid, FireAnim_End;

// simulated state Firing
// {
	// simulated function ThirdPersonFireEffects();

	// simulated function PlayMidAnimation()
	// {
		// PlayTopHalfAnimation( FireAnim_Mid,,,, true );
	// }

	// simulated event BeginState( name PreviousStateName )
	// {
		// local class<CPWeap_Grenade>		_WeaponClass;
        // local CPWeapon  _InstigatorWeapon;

         // Super.ThirdPersonFireEffects();
        
        // runs on spectator and local
		// `Log("@@ CPWeaponAttachmentGrenade::BeginState::Firing");
        
        // _WeaponClass = class<CPWeap_Grenade>( WeaponClass );
        // InstigatorWeapon(_InstigatorWeapon);
		// if ( _WeaponClass != none )
		// {
			// `Log("@@ CPWeaponAttachmentGrenade.FireAnim = "$FireAnim);
            // PlayTopHalfAnimationDuration( FireAnim, _WeaponClass.default.ReadyAnimTime,,, true );
            // PlayWeaponAnimation(Name Sequence,float fDesiredDuration,optional bool bLoop,optional SkeletalMeshComponent SkelMesh)
            // _InstigatorWeapon.PlayWeaponAnimation(FireAnim, _WeaponClass.default.ReadyAnimTime,,SkeletalMeshComponent(_InstigatorWeapon.Mesh));
            
            // PlayArmAnimation(FireAnim, _WeaponClass.default.ReadyAnimTime, false, bLoop, SkeletalMeshComponent(Mesh));
            // SetTimer( _WeaponClass.default.ReadyAnimTime, false, 'PlayMidAnimation' );
		// }
		// else
		// {
			// SetTimer( PlayTopHalfAnimation( FireAnim,,,, true ), false, 'PlayMidAnimation' );
		// }
	// }

	// simulated event EndState( name NextStateName )
	// {
		// ClearTimer( 'PlayMidAnimation' );
		// super.EndState( NextStateName );
	// }
// }

// simulated state ReloadingEnd
// {
	// simulated event BeginState( name PreviousStateName )
	// {
		// PlayTopHalfAnimationDuration( FireAnim_End, WeaponClass.default.FireStates[0].FireInterval[0] );
	// }
// }

defaultproperties
{
}
