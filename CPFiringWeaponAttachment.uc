class CPFiringWeaponAttachment extends CPWeaponAttachment;

var name ShellEjectorSocket;
var ParticleSystem ShellParticle;
var ParticleSystemComponent ShellCaseSystemComponent;
var bool bSpawnsShellCasings;
/*
simulated function SpawnShellCasing()
{
	local vector SocketLocation;
	local Rotator SocketRotation;
	
	if (ShellEjectorSocket != 'None')
	{
		Mesh.GetSocketWorldLocationAndRotation(ShellEjectorSocket, SocketLocation, SocketRotation);
	
		if(WorldInfo.MyEmitterPool != none)
			ShellCaseSystemComponent = WorldInfo.MyEmitterPool.SpawnEmitter(ShellParticle, SocketLocation, SocketRotation,);
		
		if(ShellCaseSystemComponent != none)
			ShellCaseSystemComponent.SetDepthPriorityGroup(SDPG_World);
	
	}
}

simulated state Firing
{
	simulated function ThirdPersonFireEffects()
	{
		if (Instigator.FiringMode == 0 && bSpawnsShellCasings)
		{
			SpawnShellCasing();
		}
		
		Super.ThirdPersonFireEffects();
	}
}

simulated event StopThirdPersonFireEffects()
{
	if(ShellCaseSystemComponent != none)
		ShellCaseSystemComponent.DeactivateSystem();
	
	ShellCaseSystemComponent = none;
	
	Super.StopThirdPersonFireEffects();
}
*/
DefaultProperties
{
	ShellParticle=ParticleSystem'TA_Molez_Particles.PS_CP_Shell_Ejection_Single'
	ShellEjectorSocket=EjectionSocket
	bSpawnsShellCasings=true
}
