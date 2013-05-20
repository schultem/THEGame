//Follows the main character
class THEPawn_NPC_Enemy_Pidgey extends THEPawn_NPC_Enemy
  placeable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

defaultproperties 
{
  ControllerClass=class'THEBot_Enemy_Pidgey'
  //Used to generate stats for this object
  speciesName="Pidgey"
  bFainted=false
  bInBattle=false

  GroundSpeed=300
  AccelRate=2048
  
  
  //Setup default NPC mesh
  Begin Object Name=NPCMesh0
    Translation=(Z=-41.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Pidgey'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Pidgey'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Pidgey'
  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0016.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}