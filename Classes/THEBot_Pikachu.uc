//If the main character has a pikachu on the team, let it visibly follow
class THEBot_Pikachu extends AIController;

var THEPawn P;
var Vector target;
//var Rotator targetRotation;
var bool bInBattle;

simulated event PostBeginPlay()
{
super.PostBeginPlay();

SetTimer(0.1, true, 'AITimer');
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}

function AITimer()
{
    local float Distance;

    foreach WorldInfo.AllPawns(class'THEPawn', P)
    {
        if (P != None)
        {
			if (bInBattle)
			{
				GoToState('InBattle');
			}
			else
			{
                 Distance = VSize2D(Pawn.Location - P.Location);
	 	        //Follow
                 if (Distance > 40)
	 	        {
					if (Distance > 150)
					{
						THEPawn_NPC_Pikachu(Pawn).GroundSpeed=305;
					}
					else
					{
						THEPawn_NPC_Pikachu(Pawn).GroundSpeed=150;
					}
	 	            target = P.Location;
                    target.Z = P.Location.Z;
                    GoToState('MoveAbout');

	 	        }
	 	        else
	 	        {
	 	            GoToState('Idle');
	 	        }
			}
        }
        else
        {
        GoToState('Idle');
        }
    }
}

state MoveAbout
{
Begin:
    MoveTo(target);
}

state InBattle
{
Begin:
	//if((VSize2D(Pawn.Location - target)>20))
	//{
	MoveTo(target);
	//}
	//THEPawn_NPC_Pikachu(Pawn).bInBattle(targetRotation);
}

auto state Idle
{
Begin:
    StopLatentExecution();
    Pawn.Acceleration = vect(0,0,0);
}



defaultproperties
{

}
