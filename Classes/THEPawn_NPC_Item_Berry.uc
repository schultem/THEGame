class THEPawn_NPC_Item_Berry extends THEPawn_NPC_Item
   placeable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
	SetDrawScale(2);
}
   
defaultproperties 
{
  ControllerClass=class'THEBot_Item'
  //Used to generate stats for this object
  itemName="Berry"

  GroundSpeed=300
  AccelRate=2048
  
  //Setup default NPC mesh
  Begin Object Name=NPCMesh0
    Translation=(Z=+1)
    LightEnvironment=MyLightEnvironment
    SkeletalMesh=SkeletalMesh'THEGamePackage.SM_Berry'

  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)
}