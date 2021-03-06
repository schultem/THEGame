//Follows the main character
class THEPawn_NPC_Enemy extends Pawn
  placeable;
  
var DynamicLightEnvironmentComponent LightEnvironment;
var String speciesName;
var AnimNodeSlot TestSlot;
var AnimNodeBlend IdleSlot;
var bool bInBattle;
var bool bFainted;
var Rotator targetRotation;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

function Tick(float Delta)
{
	super.Tick(Delta);
	if (bInBattle || bFainted)
	{
		SetRotation(RInterpTo(Rotation,targetRotation,Delta,90000,true));
	}
	if (bFainted)
	{
		IdleSlot.SetBlendTarget(1.0f, 0.0f);
	}
	else
	{
		SetRotation(RInterpTo(Rotation,targetRotation,Delta,90000,true));
		IdleSlot.SetBlendTarget(0.0f, 0.1f);
	}
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);
 
    if (SkelComp == Mesh)
    {
        TestSlot = AnimNodeSlot(Mesh.FindAnimNode('TestSlot'));
		IdleSlot = AnimNodeBlend(Mesh.FindAnimNode('IdleSlot'));
    }
}

defaultproperties 
{
  ControllerClass=class'THEBot_Enemy_Pikachu'
  speciesName="Default"
  bInBattle=false
  bFainted=false

  GroundSpeed=100
  AccelRate=1024
  
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