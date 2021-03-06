class THEPawn_NPC_Item_Berry_Spawn extends Pawn
   placeable;

var vector spawnLocation;
var rotator spawnRotation;

var THEPawn_NPC_Item_Berry Berry_Instance;
var THEPawn_NPC_Item_Berry_Spawn Berry_Spawn_Instance;
   
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
	SetTimer(100, true, 'AITimer');
}
 
function AITimer()
{

	spawnLocation.X=location.X + Rand(200) - Rand(200);
	spawnLocation.Y=location.Y + Rand(200) - Rand(200);
	spawnLocation.Z=location.Z;
	
	spawnRotation.Pitch = Rand(65536) - Rand(65536);
	spawnRotation.Roll  = Rand(65536) - Rand(65536);
	spawnRotation.Yaw   = Rand(65536) - Rand(65536);

	if (notEnoughBerries())
	{
	    Spawn(class'THEGame.THEPawn_NPC_Item_Berry',,, spawnLocation, spawnRotation);
	}
}

function bool notEnoughBerries()
{
	local int i,j;

	i=0;
	foreach WorldInfo.AllPawns(class'THEPawn_NPC_Item_Berry',Berry_Instance)
    {
		i++;
	}
	j=0;
	foreach WorldInfo.AllPawns(class'THEPawn_NPC_Item_Berry_Spawn',Berry_Spawn_Instance)
    {
		j++;
	}
	if (i/j < 2)
	{
		return true;
	}
	else
	{
		return false;
	}
}

defaultproperties 
{

}