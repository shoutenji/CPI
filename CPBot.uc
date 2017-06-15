class CPBot extends UDKBot;
//this is the controller.
//credit for the base of this controller http://forums.epicgames.com/threads/750562-Trouble-with-my-AI-Controller

//================================================================================================================================================
// BEGIN VARIABLES
//================================================================================================================================================

var string GoalString;            // for debugging - used to show what bot is thinking (with 'ShowDebug')
var    bool bJustLanded;

var float fLastHeardTime;
var Actor LastHeardActor;

var float fLastSeenTime;
var Pawn LastSeenPawn;

var vector TempDest;

//================================================================================================================================================
// END VARIABLES
//================================================================================================================================================

//================================================================================================================================================
// START DEBUG DISPLAY
//================================================================================================================================================

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
        T[T.Length] = "** HEARD **";
        T[T.Length] = "Last Time:" @ fLastHeardTime;
        T[T.Length] = "Last Actor:" @ LastHeardActor;
        T[T.Length] = "** SEEN **";
        T[T.Length] = "Last Time:" @ fLastSeenTime;
        T[T.Length] = "Last Pawn:" @ LastSeenPawn;
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

//================================================================================================================================================
// END DEBUG DISPLAY
//================================================================================================================================================

function Possess(Pawn aPawn, bool bVehicleTransition)
{
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "DecisionComponent:" @ DecisionComponent);
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

/*
HearNoise
    Counterpart to the Actor::MakeNoise() function, called whenever this player is within range of a given noise.
    Used as AI audio cues, instead of processing actual sounds.
*/
event HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
    fLastHeardTime = WorldInfo.TimeSeconds;
    LastHeardActor = NoiseMaker;
}

/*
SeePlayer
    Called whenever Seen is within of our line of sight    if Seen.bIsPlayer==true.
*/
event SeePlayer(Pawn Seen)
{
    fLastSeenTime = WorldInfo.TimeSeconds;
    LastSeenPawn = Seen;
    
    // Only chase humans for now
    if ((Enemy == None) && Seen.IsHumanControlled())
    {
        Enemy = Seen;
        //`log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "Enemy:" @ Enemy);
        WhatToDoNext();
    }
    
    if (Enemy == Seen)
    {
        VisibleEnemy = Enemy;
        EnemyVisibilityTime = WorldInfo.TimeSeconds;
        bEnemyIsVisible = true;
    }
}

/** triggers ExecuteWhatToDoNext() to occur during the next tick
 * this is also where logic that is unsafe to do during the physics tick should be added
 * @note: in state code, you probably want LatentWhatToDoNext() so the state is paused while waiting for ExecuteWhatToDoNext() to be called
 */
event WhatToDoNext()
{
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName());
    Super.WhatToDoNext();
    
    if (bExecutingWhatToDoNext)
    {
        //`Log("WhatToDoNext loop:" @ GetHumanReadableName());
        // ScriptTrace();
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
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName());

    // pawn got destroyed between WhatToDoNext() and now - abort
    if (Pawn == None)
        return;

    GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;

    if (Pawn.Physics == PHYS_None)
        Pawn.SetMovementPhysics();

    if ((Pawn.Physics == PHYS_Falling) && DoWaitForLanding())
        return;
        
    if ((Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)))
        Enemy = None;

    if (Enemy != None)
    {
        GoalString @= "- Follow " @ Enemy;
        GotoState('Follow');
        return;
    }
        
    GoalString @= "- Wander or Camp at" @ WorldInfo.TimeSeconds;
    WanderOrCamp();
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
State WaitingForLanding
{
    function bool DoWaitForLanding()
    {
        // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "bJustLanded:" @ bJustLanded);
        
        if (bJustLanded)
            return false;

        BeginState(GetStateName());
        return true;
    }

    event bool NotifyLanded(vector HitNormal, Actor FloorActor)
    {
        bJustLanded = true;
        Global.NotifyLanded(HitNormal, FloorActor);
        // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "bJustLanded:" @ bJustLanded);
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

/*
WanderOrCamp
    With nothing better to do, wander around.
*/
function WanderOrCamp()
{
    GotoState('Wander', 'Begin');
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

/*
WaitingForLanding
    State set by DoWaitForLanding().
*/
State Wander
{
    function bool RandomlyPickLocation()
    {
        local rotator BaseRot, NewRot;
        local vector RandomPlace, Normals;
        local int i, j;
        
        BaseRot = Pawn.Rotation;
        BaseRot.Pitch = 0;
        // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetStateName() @ "BaseRot:" @ BaseRot);
        
        for(i = 0; i < 4; i++)
        {
            // Try a direction just to the left/right
            for(j = 0; j < 4; j++)
            {
                NewRot = BaseRot;
                NewRot.Yaw += (-1.0 + (2.0 * FRand())) * ((8192 * i) + rand(8192));
            
                // `log("NewRot:" @ NewRot);

                RandomPlace = Pawn.Location + (Normal(vector(NewRot)) * Pawn.GroundSpeed);

                if (TraceLoc(RandomPlace, Normals)) //  && PointReachable(RandomPlace))
                {
                    SetDestinationPosition(RandomPlace);
                    return true;
                }
            }
        }
        
        return false;
    }

Begin:
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetStateName() @ "Begin: GetDestinationPosition():" @ GetDestinationPosition());
    if (!RandomlyPickLocation())
        Goto('WaitAndTryAgain');
    
    Goto('Moving');
        
WaitAndTryAgain:
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetStateName() @ "WaitAndTryAgain");
    Sleep(0.1f);
    Goto('Begin');
    
Moving:
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetStateName() @ "Moving");
	if (CPGameReplicationInfo( WorldInfo.GRI ).bCanPlayersMove)
	{
		MoveTo(GetDestinationPosition());
		LatentWhatToDoNext();
	}
	else
		Sleep(0.5f);
		Goto('Begin');
}


state Follow
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

Begin:
    if (NavigationHandle.ActorReachable(Enemy))
    {
        // Direct move
        MoveToward(Enemy, Enemy, 128);
		PushState('Shoot');
    }
    else if (FindNavMeshPath())
    {
        NavigationHandle.SetFinalDestination(Enemy.Location);
        
        // move to the first node on the path
        if (NavigationHandle.GetNextMoveLocation(TempDest, Pawn.GetCollisionRadius()))
        {
            MoveTo(TempDest, Enemy);
        }
		
    }
    else
    {
        // Lost enemy and/or couldn't figure out how to get to them.
        // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetStateName() @ "Lost enemy and/or couldn't figure out how to get to them.");
        Enemy = None;
        
        // We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        LatentWhatToDoNext();
    }
    
    Goto('Begin');
}

state Shoot
{
    function Aim()
    {
        local Rotator final_rot;
        final_rot = Rotator(vect(0,0,1)); //Look straight up
        Pawn.SetViewRotation(final_rot);
    }
Begin:
  
    Aim();

	if(CPWeapon(Pawn.Weapon) != none && CPWeapon(Pawn.Weapon).AmmoCount != 0)
	{
		Pawn.StartFire(0);
		Pawn.StopFire(0);
		PopState();
 	}
	else
	{
		PushState('Reload');
		PopState();
	}
}

state Reload
{
Begin:

	`Log("Reloading");
	CPWeapon(Pawn.Weapon).StartReload();
	sleep(3.0);

	`Log("Finished Reloading");
	CPWeapon(Pawn.Weapon).EndReload();
	PopState();
}

DefaultProperties
{
	bIsPlayer=true
}
