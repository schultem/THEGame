class THEPawn_NPC_Pidgey extends THEPawn_NPC_Friendly
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
  speciesName="Pidgey"

  GroundSpeed=300
  AccelRate=2048
  
  //Setup default NPC mesh
  Begin Object Name=SkeletalMeshComponent0
    Translation=(Z=-41.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Pidgey'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Pidgey'
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Pidgey'
  End Object
  Mesh=SkeletalMeshComponent0
  Components.Add(SkeletalMeshComponent0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0016.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}