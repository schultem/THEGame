class THEPawn_NPC_Item_Bed extends Pawn
   placeable;
   
var THEPawn THEPawn_Instance;

defaultproperties 
{
  //Setup default NPC mesh
  Begin Object Class=SkeletalMeshComponent Name=NPCMesh0
    Translation=(Z=-48.00)
    SkeletalMesh=SkeletalMesh'THEGamePackage.SM_Bed'
  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)
}