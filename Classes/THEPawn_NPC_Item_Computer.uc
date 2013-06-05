class THEPawn_NPC_Item_Computer extends Pawn
   placeable;
   
var THEPawn THEPawn_Instance;

defaultproperties 
{
  //Setup default NPC mesh
  Begin Object Class=SkeletalMeshComponent Name=NPCMesh0
    Translation=(Z=-48.00)
    SkeletalMesh=SkeletalMesh'THEGamePackage.SM_Computer'
  End Object
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

}