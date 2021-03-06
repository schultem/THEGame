//The main character pawn
class THEPawn extends Pawn;

var DynamicLightEnvironmentComponent LightEnvironment;

var AnimNodeSlot TestSlot; //Test slot is used to play custom animations while idle
var AnimNodeBlend IdleSlot;
var AnimNodeBlend BattleSlot;
var AnimNodeBlend WalkSlot;
var AnimNodeBlend RecallSlot;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);
 
    if (SkelComp == Mesh)
    {
        TestSlot   = AnimNodeSlot(Mesh.FindAnimNode('TestSlot'));
        BattleSlot = AnimNodeBlend(Mesh.FindAnimNode('BattleSlot'));
		WalkSlot   = AnimNodeBlend(Mesh.FindAnimNode('WalkSlot'));
        IdleSlot   = AnimNodeBlend(Mesh.FindAnimNode('IdleSlot'));
		RecallSlot = AnimNodeBlend(Mesh.FindAnimNode('RecallSlot'));
    }
}

function Tick(float Delta)
{
	super.Tick(Delta);
	if (THEPlayerController(Controller).bInBattle)
	{
	    if (THEPlayerController(Controller).bAttemptToCatchWildPokemon)
		{
			if (THEPlayerController(Controller).bShowPokeballCloud)
			{
				IdleSlot.SetBlendTarget(0.0f, 0.1f);
			    BattleSlot.SetBlendTarget(0.0f, 0.1f);
			    WalkSlot.SetBlendTarget(0.0f, 0.1f);
			    RecallSlot.SetBlendTarget(0.0f, 0.1f);
			}
			else
			{
			    IdleSlot.SetBlendTarget(1.0f, 0.1f);
			    BattleSlot.SetBlendTarget(1.0f, 0.1f);
			    WalkSlot.SetBlendTarget(1.0f, 0.1f);
			    RecallSlot.SetBlendTarget(0.0f, 0.1f);
			}
		}
		else if (THEPlayerController(Controller).bSelectBattlePokemon || THEPlayerController(Controller).bShowPokeballCloud)
		{
			IdleSlot.SetBlendTarget(0.0f, 0.1f);
			BattleSlot.SetBlendTarget(0.0f, 0.1f);
			WalkSlot.SetBlendTarget(1.0f, 0.1f);
			RecallSlot.SetBlendTarget(1.0f, 0.1f);
		}
		else
		{
			IdleSlot.SetBlendTarget(1.0f, 0.1f);
			BattleSlot.SetBlendTarget(0.0f, 0.1f);
			WalkSlot.SetBlendTarget(0.0f, 0.1f);
			RecallSlot.SetBlendTarget(0.0f, 0.1f);
		}
	}
	else
	{
		if (THEPlayerController(Controller).bShowPokeballCloud)
		{
		    IdleSlot.SetBlendTarget(0.0f, 0.1f);
            BattleSlot.SetBlendTarget(0.0f, 0.1f);
		    WalkSlot.SetBlendTarget(1.0f, 0.0f);
		    RecallSlot.SetBlendTarget(1.0f, 0.1f);
		}
		else
		{
			IdleSlot.SetBlendTarget(0.0f, 0.1f);
            BattleSlot.SetBlendTarget(0.0f, 0.1f);
		    WalkSlot.SetBlendTarget(0.0f, 0.0f);
		    RecallSlot.SetBlendTarget(0.0f, 0.1f);
		}
	}
}

defaultproperties
{
   WalkingPct=+2.0 //Used as running percentage instead..
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
   WalkableFloorZ=0.9
   
   //Components.Remove(Sprite)

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
    SkeletalMesh=SkeletalMesh'THEGamePackage.SM_Red2'
    AnimTreeTemplate=AnimTree'THEGamePackage.AT_Red2'
    AnimSets(0)=AnimSet'THEGamePackage.AS_Red2'
  End Object
  
  Mesh=SkeletalMeshComponent0
  Components.Add(SkeletalMeshComponent0)

   Begin Object Name=CollisionCylinder
      CollisionRadius=+0010.000000
      CollisionHeight=+0044.000000
   End Object
   CylinderComponent=CollisionCylinder
}