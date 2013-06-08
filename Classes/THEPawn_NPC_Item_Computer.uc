class THEPawn_NPC_Item_Computer extends Pawn
   placeable;
   
var THEPawn THEPawn_Instance;
var AnimNodeBlend IdleSlot;
var int Distance;
var DynamicLightEnvironmentComponent LightEnvironment;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);
 
    if (SkelComp == Mesh)
    {
		IdleSlot = AnimNodeBlend(Mesh.FindAnimNode('IdleSlot'));
    }
}

defaultproperties 
{

   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
      bSynthesizeSHLight=TRUE
      bIsCharacterLightEnvironment=TRUE
      bUseBooleanEnvironmentShadowing=FALSE
   End Object
   Components.Add(MyLightEnvironment)
   LightEnvironment=MyLightEnvironment
  
  //Setup default NPC mesh
  Begin Object Class=SkeletalMeshComponent Name=NPCMesh0
    Translation=(Z=-48.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SM_Computer'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Computer'
    AnimtreeTemplate=AnimTree'THEGamePackage.AT_Computer'
  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+00016.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder

}