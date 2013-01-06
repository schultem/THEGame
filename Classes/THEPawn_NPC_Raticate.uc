class THEPawn_NPC_Raticate extends THEPawn_NPC_Friendly
   placeable;
   
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

defaultproperties 
{
  ControllerClass=class'THEBot_Friendly'

  GroundSpeed=105
  AccelRate=1024
  
  //Setup default NPC mesh
  Begin Object Name=SkeletalMeshComponent0
    Translation=(Z=-48.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Raticate'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Raticate'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Raticate'
  End Object
  Mesh=SkeletalMeshComponent0
  Components.Add(SkeletalMeshComponent0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0013.000000
      CollisionHeight=+0048.000000
   End Object
   CylinderComponent=CollisionCylinder
}