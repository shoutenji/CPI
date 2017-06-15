class CPHostage extends UDKBot;

var string GoalString;           
var bool bJustLanded;
var vector TempDest;

var bool bAICanMove;

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
    local array<string> T;
    local Canvas Canvas;
    local int i;
    local float XL, YL, CurYL, BestXL;

    Super.DisplayDebug(HUD, out_YL, out_YPos);
    
    Canvas = HUD.Canvas;

    if (HUD.ShouldDisplayDebug('ai'))
    {
        T[T.Length] = "** GOAL **";
        T[T.Length] = "GoalString:" @ GoalString;
        T[T.Length] = " ";
    }
    
    for (i = 0; i < T.length; i++)
    {
        Canvas.TextSize(T[i], XL, YL);
        CurYL += YL;
        if (XL > BestXL)
            BestXL = XL;
    }

    Canvas.SetPos(2, out_YPos - 2);
    Canvas.SetDrawColor(0, 0, 0, 150);
    Canvas.DrawRect(BestXL + 2, CurYL + 2);
    Canvas.SetPos(4, out_YPos);

    Canvas.SetDrawColor(255, 255, 255);
    for (i = 0; i < T.length; i++)
    {
        Canvas.DrawText(T[i]);
        out_YPos += out_YL;
        Canvas.SetPos(4, out_YPos);
    }
}

function Possess(Pawn aPawn, bool bVehicleTransition)
{
    if (aPawn.bDeleteMe)
    {	
        `Warn(self @ GetHumanReadableName() @ "attempted to possess destroyed Pawn" @ aPawn);
        ScriptTrace();
        GotoState('Dead');
    }
    else
    {
        Super.Possess(aPawn, bVehicleTransition);
        Pawn.SetMovementPhysics();
        if (Pawn.Physics == PHYS_Walking)
            Pawn.SetPhysics(PHYS_Falling);
    }

    WhatToDoNext();
}

/** triggers ExecuteWhatToDoNext() to occur during the next tick
 * this is also where logic that is unsafe to do during the physics tick should be added
 * @note: in state code, you probably want LatentWhatToDoNext() so the state is paused while waiting for ExecuteWhatToDoNext() to be called
 */
simulated event WhatToDoNext()
{
    Super.WhatToDoNext();
    
    if (bExecutingWhatToDoNext)
    {
        `Log("WhatToDoNext loop:" @ GetHumanReadableName());
    }

    if (Pawn == None)
    {
        `Warn(GetHumanReadableName() @ "WhatToDoNext with no pawn");
        return;
    }
    
    DecisionComponent.bTriggered = true;
}


/*
ExecuteWhatToDoNext
    Entry point for AI decision making
    This gets executed during the physics tick so actions that could change the physics state (e.g. firing weapons) are not allowed
*/
protected event ExecuteWhatToDoNext()
{
    if (Pawn == None)
        return;

    GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;

    //if (Pawn.Physics == PHYS_None)
    //    Pawn.SetMovementPhysics();

    if ((Pawn.Physics == PHYS_Falling) && DoWaitForLanding())
        return;
    
    if ((Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)))
        Enemy = None;

    if (Enemy != None)
    {
        GoalString @= "- Follow " @ Enemy;
        GotoState('Follow');
    }
	else
	{
		GoalString @= "- Waiting to Follow someone";
        GotoState('NotFollowing');
	}
}

/*
DoWaitForLanding
    Called from ExecuteWhatToDoNext when falling.
    Overridden in other states as needed.
*/
function bool DoWaitForLanding()
{
    GotoState('WaitingForLanding');
    return true;
}

/*
WaitingForLanding
    State set by DoWaitForLanding().
*/
state WaitingForLanding
{
    function bool DoWaitForLanding()
    {        
        if (bJustLanded)
            return false;

        BeginState(GetStateName());
        return true;
    }

    event bool NotifyLanded(vector HitNormal, Actor FloorActor)
    {
        bJustLanded = true;
        Global.NotifyLanded(HitNormal, FloorActor);
        return false;
    }

    function Timer()
    {
    }

    function BeginState(Name PreviousStateName)
    {
        bJustLanded = false;
    }

Begin:
    if (Pawn.PhysicsVolume.bWaterVolume || (Pawn.Physics == PHYS_Swimming))
        LatentWhatToDoNext();

    if (Pawn.GetGravityZ() > 0.9 * WorldInfo.DefaultGravityZ)
    {
         if ((MoveTarget == None) || (MoveTarget.Location.Z > Pawn.Location.Z))
        {
            NotifyMissedJump();
            if (MoveTarget != None)
                MoveToward(MoveTarget,Focus,,true);
        }
        else if (Pawn.Physics != PHYS_Falling)
            LatentWhatToDoNext();
        else
        {
            Sleep(0.5);
            Goto('Begin');
        }
    }

    GoalString = "Waiting for us to land...";
    WaitForLanding();
    LatentWhatToDoNext();
    Sleep(0.5);
    Goto('Begin');
}

simulated function bool TraceLoc(out vector out_Loc, out vector out_Normal)
{
    local vector HitLocation, HitNormal, TraceStart, TraceEnd;
    local actor HitActor;
    
    if (Pawn == None)
        return false;
    
    TraceStart = out_Loc;
    TraceStart.Z += (Pawn.GetCollisionHeight() * 2);
    TraceEnd = out_Loc;
    TraceEnd.Z -= (Pawn.GetCollisionHeight() * 2);
    
    ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, TraceStart)
    {
        // Block if we've hit world geometry
        if (HitActor.bWorldGeometry || HitActor.IsA('InterpActor'))
        {
            out_Loc = HitLocation;
            out_Normal = HitNormal;
            return true;
            break;
        }
    }
    
    return false;
}

state NotFollowing
{
	event BeginState( name PreviousStateName )
	{			
		//Pawn.SetCollisionSize(Pawn.GetCollisionRadius(),Pawn.CrouchHeight); //TODO SET DEFAULT COLLISION HEIGHT FOR HOSTAGE PAWNS
		bAICanMove = false;
			
		if(WorldInfo.NetMode == NM_Standalone || WorldInfo.NetMode == NM_DedicatedServer)
			CPHostagePawn(Pawn).HostageCapture();
		else
			CPHostagePawn(Pawn).RemoteAnimation = 'HostageCapture';
			
		Focus = none;
		
		super.BeginState( PreviousStateName );
	}

Begin:
	LatentWhatToDoNext();    
    Goto('Begin');
}

function HostageAnimationEnd()
{
	bAICanMove = true;
	CPHostagePawn(Pawn).HostageAnimationEnd();
	
	Pawn.SetPhysics(PHYS_Falling);
}

simulated state Follow
{
    ignores SeePlayer;
    
    function bool FindNavMeshPath()
    {
        // Clear cache and constraints (ignore recycling for the moment)
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;

        // Create constraints
        class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle, Enemy);
        class'NavMeshGoal_At'.static.AtActor(NavigationHandle, Enemy, 32);

        // Find path
        return NavigationHandle.FindPath();
    }

	simulated event BeginState( name PreviousStateName )
	{
		//if ( Pawn != none )
		//	Pawn.ShouldCrouch( false );
										
		if(WorldInfo.NetMode == NM_Standalone)
			CPHostagePawn(Pawn).HostageRise();
		else
			CPHostagePawn(Pawn).RemoteAnimation = 'HostageRise';
		
		if(Pawn != none)
		{
			Pawn.SetPhysics(PHYS_None);
			Pawn.ShouldCrouch( false );
		}
			
		SetTimer(5.1, false, 'HostageAnimationEnd');
		
		super.BeginState( PreviousStateName );
	}
	
	simulated event EndState( name NextStateName )
	{
		ClearTimer('HostageAnimationEnd');
		
		//if ( Pawn != none )
		//	Pawn.ShouldCrouch( true );
		super.EndState( NextStateName );
	}

Begin:

	//`log("Pawn = '" $ CPHostagePawn(Pawn).bAICanMove $ "', Controller = '" $ bAICanMove $ "'");
	if (NavigationHandle.ActorReachable(Enemy))
    {
        NavigationHandle.SetFinalDestination(Enemy.Location);

        // move to the first node on the path
        if (NavigationHandle.GetNextMoveLocation(TempDest, Pawn.GetCollisionRadius()))
        {
			if(CPHostagePawn(Pawn).bAICanMove && bAICanMove)
			{
				if (VSizeSq2D(CPHostagePawn(Pawn).Location - Enemy.Location) > 4000)
				{	
					MoveTo(TempDest, Enemy, 64);					
					sleep(0.1);
				}
					else
				{
					MoveTo(CPHostagePawn(Pawn).Location + vector(CPHostagePawn(Pawn).Rotation)*-100, Enemy);					
					sleep(0.5);
				}
			}
			else
				Sleep(1.0);
        }
    
    }
    else
    {
        // Lost enemy and/or couldn't figure out how to get to them.
        // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetStateName() @ "Lost enemy and/or couldn't figure out how to get to them.");
        //Enemy = None;
		if (enemy != none)
		{
			MoveTo(Enemy.Location, Enemy,64);
			if (Enemy != none)
			if (VSizeSq2D(CPHostagePawn(Pawn).Location - Enemy.Location) < 4000)
				{
					MoveTo(CPHostagePawn(Pawn).Location + vector(CPHostagePawn(Pawn).Rotation)*-100, Enemy);		
					sleep(0.5);
				}
		}
        // We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        LatentWhatToDoNext();
    }
    
    Goto('Begin');
}

state Dead
{
	Begin:
	if ( WorldInfo.Game.bGameEnded )
		GotoState('RoundEnded');
	Sleep(0.2);
	TryAgain:
	if ( CriticalPointGame(WorldInfo.Game) == None )
		destroy();
	else
	{
		Sleep(0.75 + CriticalPointGame(WorldInfo.Game).SpawnWait(self));
//		LastRespawnTime = WorldInfo.TimeSeconds;
		WorldInfo.Game.ReStartPlayer(self);
		Goto('TryAgain');
	}

	MPStart:
		Sleep(0.75 + FRand());
		WorldInfo.Game.ReStartPlayer(self);
		Goto('TryAgain');
}

DefaultProperties
{
	bIsPlayer=true
}

