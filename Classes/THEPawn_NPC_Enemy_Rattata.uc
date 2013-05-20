//Follows the main character
class THEPawn_NPC_Enemy_Rattata extends THEPawn_NPC_Enemy
  placeable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
	SetDrawScale(1.5); //I screwed up and made the skeletal mesh the wrong size.
}

defaultproperties 
{
  ControllerClass=class'THEBot_Enemy_Rattata'
  //Used to generate stats for this object
  speciesName="Rattata"
  bFainted=false
  bInBattle=false

  GroundSpeed=250
  AccelRate=1024
  
  
  //Setup default NPC mesh
  Begin Object Name=NPCMesh0
    Translation=(Z=-31.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Rattata'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Rattata'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Rattata'
  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0010.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}