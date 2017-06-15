class CPWeaponFireMode extends Object;

enum ETAFireType
{
	ETFT_None,
	ETFT_InstantHit,
	ETFT_Projectile,
	ETFT_Zoom,
	ETFT_LaserDot,
};

var string ModeName;						// should be localized

var ETAFireType FireType[2];                // not implemented
var name FiringState[2];
var int RequiredAmmoAmount[2];              // not implemented
	
var Vector FireOffset[2];		            // not implemented, for pojectile start
var class<Projectile> ProjectileClass[2];   // not implemented

var float FireInterval[2];
var byte bRepeater[2];
var Vector MinFireRecoil[2];
var Vector MaxFireRecoil[2];
var float MinHitDamage[2];
var float MaxHitDamage[2];
var class<DamageType> HitDamageType[2];
var float HitMomentum[2];
var float WeaponRangeScale[2];          	// not implemented

var ParticleSystem MuzzleFlashPSC[2];
var ParticleSystem ShellCasingPSC[2];
var byte bMuzzleFlashPSCLoops[2];
var class<UDKExplosionLight> MuzzleFlashLightClass[2];
var float MuzzleFlashDuration[2];
var float ShellCasingDuration[2];

var array<name>	WeaponFireAnims;
var array<name> ArmFireAnims;
var array<SoundCue>	WeaponFireSnds;

var array<name>	WeaponAltFireAnims;
var array<name> ArmAltFireAnims;
var array<SoundCue>	WeaponAltFireSnds;

var int PelletsPerShot;						// Meant for shotgun pellets

var ParticleSystem ShellEjectPSC[2];


defaultproperties
{
	ModeName="Auto"
	FiringState(0)=WeaponFiring
	FiringState(1)=WeaponFiring
	RequiredAmmoAmount(0)=1
	RequiredAmmoAmount(1)=1
	FireInterval(0)=0.5
	FireInterval(1)=0.5
	bRepeater(0)=1
	bRepeater(1)=1
	WeaponFireAnims(0)=WeaponFire
	ArmFireAnims(0)=WeaponFire
	WeaponAltFireAnims(0)=WeaponAltFire
	ArmAltFireAnims(0)=WeaponAltFire
	PelletsPerShot=1
	MuzzleFlashLightClass(0)=class'CPDefaultMuzzleFlashLight'
	MuzzleFlashLightClass(1)=class'CPDefaultMuzzleFlashLight'
	
	ShellCasingDuration(0)=0.5
	ShellCasingDuration(1)=0.5
}
