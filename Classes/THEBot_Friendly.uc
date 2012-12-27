class THEBot_Friendly extends AIController;

var THEPawn P;
var Vector target;
//var Rotator targetRotation;
var bool bInBattle;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    GoToState('InBattle');
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
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
