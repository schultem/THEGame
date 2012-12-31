//The main character pawn
class THEPawn extends Pawn;

var DynamicLightEnvironmentComponent LightEnvironment;

var AnimNodeSlot TestSlot; //Test slot is used to play custom animations
var AnimNodeBlend IdleSlot;
var AnimNodeBlend BattleSlot;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);
 
    if (SkelComp == Mesh)
    {
        TestSlot = AnimNodeSlot(Mesh.FindAnimNode('TestSlot'));
        BattleSlot= AnimNodeBlend(Mesh.FindAnimNode('BattleSlot'));
        IdleSlot = AnimNodeBlend(Mesh.FindAnimNode('IdleSlot'));
    }
}

function Tick(float Delta)
{
	super.Tick(Delta);
	if (THEPlayerController(Controller).bInBattle)
	{
		IdleSlot.SetBlendTarget(1.0f, 0.1f);
                BattleSlot.SetBlendTarget(0.0f, 0.1f);
	}
	else
	{
		IdleSlot.SetBlendTarget(0.0f, 0.1f);
                BattleSlot.SetBlendTarget(0.0f, 0.1f);
	}
}

defaultproperties
{
   WalkingPct=+0.0
   CrouchedPct=+0.0
   BaseEyeHeight=0
   EyeHeight=38.0
   GroundSpeed=150.0
   AirSpeed=440.0
   WaterSpeed=220.0
   AccelRate=1024.0
   JumpZ=0.0
   CrouchHeight=29.0
   CrouchRadius=21.0
   WalkableFloorZ=0.0
   
   Components.Remove(Sprite)

   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
      bSynthesizeSHLight=TRUE
      bIsCharacterLightEnvironment=TRUE
      bUseBooleanEnvironmentShadowing=FALSE
   End Object
   Components.Add(MyLightEnvironment)
   LightEnvironment=MyLightEnvironment

   Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
       //Your Mesh Properties
      SkeletalMesh=SkeletalMesh'THEGamePackage.SM_Red2'
      AnimTreeTemplate=AnimTree'THEGamePackage.AT_Red2'
      AnimSets(0)=AnimSet'THEGamePackage.AS_Red2'
      Translation=(Z=-48.0)
      Scale=1.0
      //General Mesh Properties
      bCacheAnimSequenceNodes=FALSE
      AlwaysLoadOnClient=true
      AlwaysLoadOnServer=true
      bOwnerNoSee=false
      CastShadow=true
      BlockRigidBody=TRUE
      bUpdateSkelWhenNotRendered=false
      bIgnoreControllersWhenNotRendered=TRUE
      bUpdateKinematicBonesFromAnimation=true
      bCastDynamicShadow=true
      RBChannel=RBCC_Untitled3
      RBCollideWithChannels=(Untitled3=true)
      LightEnvironment=MyLightEnvironment
      bOverrideAttachmentOwnerVisibility=true
      bAcceptsDynamicDecals=FALSE
      bHasPhysicsAssetInstance=true
      TickGroup=TG_PreAsyncWork
      MinDistFactorForKinematicUpdate=0.2
      bChartDistanceFactor=true
      RBDominanceGroup=20
      bUseOnePassLightingOnTranslucency=TRUE
      bPerBoneMotionBlur=true
   End Object
   Mesh=WPawnSkeletalMeshComponent
   Components.Add(WPawnSkeletalMeshComponent)

   Begin Object Name=CollisionCylinder
      CollisionRadius=+0017.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}