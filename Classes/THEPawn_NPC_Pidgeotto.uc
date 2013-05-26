class THEPawn_NPC_Pidgeotto extends THEPawn_NPC_Friendly
   placeable;
   
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

defaultproperties 
{
  ControllerClass=class'THEBot_Friendly'

  //Used to generate stats for this object
  speciesName="Pidgeotto"

  GroundSpeed=300
  AccelRate=2048
  
  //Setup default NPC mesh
  Begin Object Name=SkeletalMeshComponent0
    Translation=(Z=-43.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Pidgeotto'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Pidgeotto'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Pidgeotto'
  End Object
  Mesh=SkeletalMeshComponent0
  Components.Add(SkeletalMeshComponent0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0016.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}