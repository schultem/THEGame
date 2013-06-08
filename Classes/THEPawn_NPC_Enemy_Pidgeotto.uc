//Follows the main character
class THEPawn_NPC_Enemy_Pidgeotto extends THEPawn_NPC_Enemy
  placeable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

defaultproperties 
{
  ControllerClass=class'THEBot_Enemy_Pidgeotto'
  //Used to generate stats for this object
  speciesName="Pidgeotto"
  bFainted=false
  bInBattle=false

  GroundSpeed=300
  AccelRate=2048
  WalkableFloorZ=0.0
  
  
  //Setup default NPC mesh
  Begin Object Name=NPCMesh0
    Translation=(Z=-43.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Pidgeotto'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Pidgeotto'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Pidgeotto'
  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0016.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}