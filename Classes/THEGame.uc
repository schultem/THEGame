class THEGame extends FrameworkGame;

var THEGameState gamestate;

event PreBeginPlay()
{
	super.PreBeginPlay();
	gamestate = new class'THEGameState';
	gamestate.loadPokemonDB();
	gamestate.loadPokemonAttackDB();
}
defaultproperties
{
   PlayerControllerClass=class'THEGame.THEPlayerController'
   DefaultPawnClass=class'THEGame.THEPawn'
   HUDType=class'THEGame.THEHUD'
   bDelayedStart=false
   bRestartLevel=false
}