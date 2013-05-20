class THEPawn_NPC_Rattata extends THEPawn_NPC_Friendly
   placeable;
   
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
	SetDrawScale(1.5); //I screwed up and made the skeletal mesh the wrong size.
}

defaultproperties 
{
  ControllerClass=class'THEBot_Friendly'

  //Used to generate stats for this object
  speciesName="Rattata"

  GroundSpeed=105
  AccelRate=1024
  
  //Setup default NPC mesh
  Begin Object Name=SkeletalMeshComponent0
    Translation=(Z=-31.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Rattata'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Rattata'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Rattata'
  End Object
  Mesh=SkeletalMeshComponent0
  Components.Add(SkeletalMeshComponent0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0010.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}