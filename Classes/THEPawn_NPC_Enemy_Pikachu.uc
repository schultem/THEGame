//Follows the main character
class THEPawn_NPC_Enemy_Pikachu extends THEPawn_NPC_Enemy
  placeable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

defaultproperties 
{
  ControllerClass=class'THEBot_Enemy_Pikachu'
  //Used to generate stats for this object
  speciesName="Pikachu"
  bFainted=false
  bInBattle=false

  GroundSpeed=100
  AccelRate=1024
  
  //Setup default NPC mesh
  Begin Object Name=NPCMesh0
    Translation=(Z=-48.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Pikachu'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Pikachu'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Pikachu'
  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0008.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}