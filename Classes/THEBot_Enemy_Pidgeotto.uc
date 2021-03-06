class THEBot_Enemy_Pidgeotto extends AIController;

var Vector MyTarget;
var THEPawn P;
var float AIticks;
var float Distance;
var Vector initialLocation;
var int Territory;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    
    SetTimer(0.1, true, 'AITimer');
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
	initialLocation=Pawn.Location;
}

function AITimer()
{
    AIticks+=1;
    if (!THEPawn_NPC_Enemy(Pawn).bInBattle)
	{
		if (!THEPawn_NPC_Enemy(Pawn).bFainted)
		{
	        if (GetStateName()=='MoveAbout' || GetStateName()=='MoveAboutStopRotation')
	        {
	            WaitToReachDestination();
	        }
	        else
	        {
	            ChooseNewDestination();
	        }
		}
		else
		{
			if(GetStateName()!='Fainted')
			{
				AIticks=0;
				//`log("gotostatefainted");
				GoToState('Fainted');
			}
			if (AIticks>=1000) //time to wait to recover
			{
				//`log("aiticks>=10");
				THEPawn_NPC_Enemy(Pawn).bFainted=false;
			    ChooseNewDestination();
			}
		}
	}
	else
	{
		//Stop and rotate to face the pokemon the player has chosen
		MyTarget=Pawn.Location;
	    GoToState('BattlePosition');
	}
}

function ChooseNewDestination()
{   
    local int OffsetX;
    local int OffsetY;
    //`log('ChooseNewDestination');
    OffsetX = Rand(Territory)-Rand(Territory);
    OffsetY = Rand(Territory)-Rand(Territory);
	
	if (OffsetX>-500 && OffsetX<500)
	{
		OffsetX=500;
	}

	if (OffsetY>-500 && OffsetY<500)
	{
		OffsetY=-500;
	}

    MyTarget.X = Pawn.Location.X + OffsetX;
    MyTarget.Y = Pawn.Location.Y + OffsetY;
    MyTarget.Z = Pawn.Location.Z;
	
	THEPawn_NPC_Enemy(Pawn).targetRotation=Rotator(MyTarget-Pawn.Location);

    GoToState('MoveAbout');
}

function WaitToReachDestination()
{
	if(VSize2D(Pawn.Location-initialLocation)>Territory)
	{
		//`log(VSize2D(Pawn.Location-initialLocation));
	    MyTarget=initialLocation;
		THEPawn_NPC_Enemy(Pawn).targetRotation=Rotator(MyTarget-Pawn.Location);
		AIticks=0;
		GoToState('MoveAbout');
	}
	if (AIticks>(1000+Rand(1000)) || (VSize2D(Pawn.Location-MyTarget)<500))
	{
	    AIticks=0;
	    ChooseNewDestination();
	}
}

state MoveAbout
{
Begin:
    MoveTo(MyTarget);
}

auto state Idle
{
Begin:
    StopLatentExecution();
    Pawn.Acceleration = vect(0,0,0);
}

state BattlePosition
{
Begin:
	StopLatentExecution();
    Pawn.Acceleration = vect(0,0,0);
	MoveTo(MyTarget);
}

state Fainted
{
Begin:
    StopLatentExecution();
    Pawn.Acceleration = vect(0,0,0);
}

defaultproperties
{
    Territory=7000;
}
