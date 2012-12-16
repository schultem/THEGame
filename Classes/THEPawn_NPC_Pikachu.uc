//Actor Pikachu that follows the main character if the main character keeps a Pikachu in their party
class THEPawn_NPC_Pikachu extends Pawn
   placeable;
  
var DynamicLightEnvironmentComponent LightEnvironment;
var bool bInBattle;
var Rotator targetRotation;

var AnimNodeSlot TestSlot;
var AnimNodeBlend IdleSlot;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
}

function Tick(float Delta)
{
	super.Tick(Delta);
	if (bInBattle)
	{
		SetRotation(RInterpTo(Rotation,targetRotation,Delta,90000,true));
	}
	IdleSlot.SetBlendTarget(0.0f, 0.1f);
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

event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
    super.OnAnimEnd(SeqNode, PlayedTime, ExcessTime);
 
}

function SetControllerTarget(Vector target)
{
	THEBot_Pikachu(Controller).target=target;
}

function SetControllerBattleStatus(bool bStatus)
{
	bInBattle = bStatus;
	THEBot_Pikachu(Controller).bInBattle=bStatus;
}

//function SetControllerRotation(Rotator rotator)
//{
//	THEBot_Pikachu(Controller).targetRotation=rotator;
//}

defaultproperties 
{
  ControllerClass=class'THEBot_Pikachu'

  GroundSpeed=240
  AccelRate=512.0

   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
      bSynthesizeSHLight=TRUE
      bIsCharacterLightEnvironment=TRUE
      bUseBooleanEnvironmentShadowing=FALSE
   End Object
   Components.Add(MyLightEnvironment)
   LightEnvironment=MyLightEnvironment

  //Setup default NPC mesh
  Begin Object class=SkeletalMeshComponent Name=SkeletalMeshComponent0
    Translation=(Z=-48.00)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SkeletalMesh_Pokemon.SM_Pikachu'
    AnimSets.add(AnimSet'THEGamePackage.AS_Pikachu')
    AnimtreeTemplate=AnimTree'THEGamePackage.AnimTrees_Pokemon.AT_Pikachu'
  End Object
  Mesh=SkeletalMeshComponent0
  Components.Add(SkeletalMeshComponent0)

  Begin Object Name=CollisionCylinder
      CollisionRadius=+0008.000000
      CollisionHeight=+0044.000000
  End Object
  CylinderComponent=CollisionCylinder
}