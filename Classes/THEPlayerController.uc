class THEPlayerController extends PlayerController;

/** 
 * DATA LOAD/SAVE FUNCTIONS
 */
var THEGameState gamestate;

/**
 * CHARACTER DATA
 */
var THECharacter char;

/** 
 * MISC VARIABLES
 */
var float  Distance;
var float  typeDiffPerc[225];
var String typeNameList[15];
var String pokemonBattleParticipatedList[6]; //A list to keep track of each pokemon that fought in a battle
Struct pokemonMove
{
	var String species; 
	var String attack;
};
var array<pokemonMove> pokemonThatCanLearnNewMove;    //A list to keep track of each pokemon that recently leveled and can learn a new move

var THEPawn_NPC_Enemy WildPokemon;
var THEPawn_NPC_Enemy EnemyPokemon;
var THEPokemonInventory EnemyPokemonDBInstance;
var int currentEnemySelectedBattleAttack;
var float wildLevelMultiplier;

var THEPawn thePawn;
var THEPokemonInventory currentSelectedBattlePokemon;
var int currentSelectedBattleAttack;

/** 
 * STATE VARIABLES
 */
var bool bSelectCharacter;
var bool bSelectBattlePokemon;
var bool bSelectBattleOption;
var bool bSelectBattleAttack;
var bool bSelectBattleItems;
var bool bPlayerPokemonVictory;
var bool bPlayBattleAnimations;
var bool bPlayerAttackFirst;
var bool bPlayerAttackAnimStarted;
var bool bEnemyAttackAnimStarted;
var bool bPartyPokemonCanLearnNewMove;
var bool bPartyPokemonReplaceMove;
var bool bInBattle;

/** 
 * FOLLOWER VARIABLES
 */
var class<THEPawn_NPC_Pikachu>  FollowerPawnClass;
var THEPawn_NPC_Pikachu         Follower;

var ParticleSystemComponent spawnedParticleComponents;
var Vector particleLocation;
var Rotator particleRotation;

/** 
 * LAST NUMERAL KEYPRESS
 */
var int  lastNumeral;
var bool bNumeralPressed;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	//Initial "State"/GameControl Variables, maybe move these to default eventually
	bSelectCharacter              = true;
	bSelectBattlePokemon          = false;
	bSelectBattleOption           = false;
	bSelectBattleAttack           = false;
	bSelectBattleItems            = false;
	bPlayerPokemonVictory         = false;
	bPlayBattleAnimations         = false;
	bPlayerAttackFirst            = false;
	bPlayerAttackAnimStarted      = false;
	bEnemyAttackAnimStarted       = false;
	bPartyPokemonCanLearnNewMove  = false;
	bPartyPokemonReplaceMove      = false;
	bInBattle                     = false;
	currentSelectedBattleAttack=0;
	
	TypeArrayInit();
	pokemonBattleParticipatedInit();
	pokemonThatCanLearnNewMoveInit();

	//Input
	ResetNumeralPress();
	
	//Data Input Output Controller
	gamestate = THEGame(WorldInfo.Game).gamestate;
	
	SetTimer(0.1, true, 'PCTimer');
}

// ******************************************************************
// *  
// *  
// *  
// *                            GAMEFLOW
// *  
// *  
// *  
// *  
// ******************************************************************
function PCTimer()
{
    local int i,j,k;
	local float temp;
	local String fainted;
    local array<string> chars;
    thePawn = THEPawn(Pawn);

	if (bSelectCharacter)
	{
	    GoToState('SelectCharacter');
		if (bNumeralPressed)
	    {
		    if (lastNumeral<=3 && lastNumeral > 0)
		    {
		        chars = gamestate.getCharacters();
				if (lastNumeral<=chars.Length)
				{
		            char = gamestate.loadCharacter(chars[lastNumeral-1]);
		    	    bSelectCharacter=false;
				    
				    for (i = 0; i < char.pokemonInventory.Length; ++i)
				    {
				        if (char.pokemonInventory[i].pokemonSpecies == "Pikachu")
				    	{
				    	    if (char.pokemonInventory[i].inPlayerParty)
				    		{
				    			SpawnFollowerPikachu();
				    		}
				    	}
				    }
				    RegainPlayerControl();
		    	    //TeamMessage(none, "Loaded character "$chars[lastNumeral-1], 'none');
				}
		    }
		ResetNumeralPress();
	    }
	}
    
	if (bInBattle)
	{
	    if (bSelectBattlePokemon)
	    {
		    if (bNumeralPressed)
	        {
			    if (lastNumeral<=6 && lastNumeral > 0)
		        {
					//Too close to the enemy to spawn/move
					if (VSize2D(Pawn.Location - EnemyPokemon.Location) > 300)
					{
						//Count number of pokemon in party
					    j=0;
	                    for (i = 0; i < char.pokemonInventory.Length; ++i)
	                    {
	                        if (char.pokemonInventory[i].inPlayerParty)
	                    	{
	                            j++;
	                    	}
					    	if (j==lastNumeral)
					    	{
					    	    if (char.pokemonInventory[i].isFainted==false)
					    		{
					    	        
					    			//move or spawn player pokemon between player and enemy and set to idle
					    			//if the selected pokemon is the follower, move the follower, stop it's movement, then rotate it to the enemy
					    			if (char.pokemonInventory[i].pokemonSpecies=="Pikachu")
					    			{
					    				MoveFollowerForBattle();
					    				RotateEnemyPokemonToFollower();
					    			}
					    			currentSelectedBattlePokemon=char.pokemonInventory[i];
					    			for(k=0;k<ArrayCount(pokemonBattleParticipatedList);++k)
					    			{
					    				if (pokemonBattleParticipatedList[k] == char.pokemonInventory[i].pokemonSpecies)
					    				{
					    					break;
					    				}
					    				else
					    				{
					    					if (pokemonBattleParticipatedList[k] == "")
					    					{
					    						pokemonBattleParticipatedList[k] = char.pokemonInventory[i].pokemonSpecies;
					    						break;
					    					}
					    				}
					    			}
					    			
				                    bSelectBattlePokemon=false;
					                bSelectBattleOption=true;
					                //RegainPlayerControl();
					    		}
					    	}
	                    }
					}
					else
					{
						//display a warning as to why you can't select here
					}
				}
			ResetNumeralPress();
			}
	    }
		//Run is manual
		if (VSize2D(Pawn.Location - EnemyPokemon.Location) > 500)
		{
		    //Player has run too far from the match and will exit the battle after the oppenent gets another attack in
			//reset menus and temporary pokemon stats
			ResetCharacterTemporaryBattleStats();
			BattleStateExitCleanup();
		}
		
	    if (bSelectBattleOption)
		{
			if (bNumeralPressed)
	        {
			    if (lastNumeral==1)
		        {
				    //Goto fight option
					bSelectBattleOption=false;
					bSelectBattleAttack=true;
				}
				if (lastNumeral==2)
		        {
				    //Goto Select Pokemon option
					bSelectBattleOption=false;
					bSelectBattlePokemon=true;
				}
				if (lastNumeral==3)
		        {
				    //Goto Items option
					bSelectBattleOption=false;
					bSelectBattleItems=true;
				}
			ResetNumeralPress();
			}
		}
		
	    if (bSelectBattleAttack)
		{
			//Continuously rotate to follower if the player switches around
			if (char.pokemonInventory[i].pokemonSpecies=="Pikachu")
			{
				RotateEnemyPokemonToFollower();
				RotateFollowerPokemonToEnemy();
			}
		    if (bNumeralPressed)
	        {
			    if (lastNumeral<=currentSelectedBattlePokemon.pokemonAttackInventory.Length && lastNumeral > 0)
		        {
				    currentSelectedBattleAttack=(lastNumeral-1);
					CheckStatusAilments();
				    ExchangeBattleAttacks();
				    bSelectBattleAttack=false;
					bPlayBattleAnimations = true;
				}
			ResetNumeralPress();
			}
		}

	    if (bSelectBattleItems)
		{
			if (bNumeralPressed)
	        {
			    switch (lastNumeral)
				{
				case (1):
					UseInventory("berry",currentSelectedBattlePokemon.pokemonSpecies);
					//give opponent a chance to attack here
					bSelectBattleItems=false;
					bSelectBattleOption=true;
					break;
				}
				currentEnemySelectedBattleAttack=Rand(EnemyPokemonDBInstance.pokemonAttackInventory.Length);
				OpponentPokemonAttackCharacterPokemon();
			ResetNumeralPress();
			}
		}
		
		if (bPlayerPokemonVictory)
		{
		    if (bNumeralPressed)
	        {
				if (pokemonThatCanLearnNewMove.Length > 0)
				{
					bPartyPokemonCanLearnNewMove = true;
				   	bPlayerPokemonVictory  = false;
				}
				else
				{
					//Finally, set wild pokemon to fainted
					BattleStateExitCleanup();
					RegainPlayerControl();
			        EnemyPokemon.bFainted  = true;
			        EnemyPokemon.bInBattle = false;
			        bPlayerPokemonVictory  = false;
			        bInBattle = false;
				}
			ResetNumeralPress();
			}
			else
			{
				//Put player in idle to wait for a button press while viewing experience
			    GoToState('Idle');
			}
		}
		
		if (bPartyPokemonCanLearnNewMove)
		{
			if (pokemonThatCanLearnNewMove.Length == 0)
			{
				//Finally, set wild pokemon to fainted
				BattleStateExitCleanup();
				RegainPlayerControl();
				EnemyPokemon.bFainted  = true;
				EnemyPokemon.bInBattle = false;
				bPartyPokemonCanLearnNewMove  = false;
				bInBattle = false;
			}
			else
			{
				if (bNumeralPressed)
				{
					for (i = 0; i < char.pokemonInventory.Length; ++i) //it might be best to replace this syntax used throughout the code with a single function that returns the inventory object, but again it doesn't really matter
	                {
						if (char.pokemonInventory[i].pokemonSpecies == pokemonThatCanLearnNewMove[pokemonThatCanLearnNewMove.Length-1].species)
						{
						    if (char.pokemonInventory[i].pokemonAttackInventory.Length<4)
						    {
								//add the attack
								AddPokemonAttackForLevel(char.pokemonInventory[i].pokemonSpecies,char.pokemonInventory[i].Level);
								//pop the last struct from pokemonThatCanLearnNewMove
								pokemonThatCanLearnNewMove.removeItem(pokemonThatCanLearnNewMove[pokemonThatCanLearnNewMove.Length-1]);
						    }
						    else
						    {
								//goto state bPartyPokemonReplaceMove
								bPartyPokemonCanLearnNewMove = false;
								bPartyPokemonReplaceMove = true;
						    }
						}
					}
				ResetNumeralPress();
				}
			}
		}
		
		if(bPartyPokemonReplaceMove)
		{
				if (bNumeralPressed && lastNumeral>=1 && lastNumeral<=5)
				{
					if (lastNumeral != 5)
					{
						chars = GetPokemonToLearnAttackList();
						for (i = 0; i < char.pokemonInventory.Length; ++i)
	                    {
							if (char.pokemonInventory[i].pokemonSpecies == pokemonThatCanLearnNewMove[pokemonThatCanLearnNewMove.Length-1].species)
							{
								removePokemonAttack(char.pokemonInventory[i].pokemonSpecies, chars[lastNumeral-1]);
								AddPokemonAttackForLevel(char.pokemonInventory[i].pokemonSpecies,char.pokemonInventory[i].Level);
							}
						}
					}
					//pop the last struct from pokemonThatCanLearnNewMove
					pokemonThatCanLearnNewMove.removeItem(pokemonThatCanLearnNewMove[pokemonThatCanLearnNewMove.Length-1]);
					bPartyPokemonCanLearnNewMove = true;
					bPartyPokemonReplaceMove = false;
					
				ResetNumeralPress();
				}
		}
		
		if (bPlayBattleAnimations)
		{
			if(bPlayerAttackFirst)
			{
				if (!bPlayerAttackAnimStarted && !bEnemyAttackAnimStarted)
				{
					bPlayerAttackAnimStarted = true;
					bEnemyAttackAnimStarted = false;
					StartPlayerPokemonAnimation();
				}
			}
			else
			{
				if (!bPlayerAttackAnimStarted && !bEnemyAttackAnimStarted)
				{
					bEnemyAttackAnimStarted = true;
					bPlayerAttackAnimStarted = false;
					StartEnemyPokemonAnimation();
				}
			}
			
			if(bPlayerAttackAnimStarted)
			{
				if (bPlayerAttackFirst)
				{
				    if (Follower.TestSlot.GetPlayedAnimation() == '')
				    {
				    	//animation was started and finished
						//make sure the enemy did not faint after getting attacked, if so though, go to player victory
						StopPokemonParticleComponent();
						fainted = CheckFainted();
						if (fainted=="enemy")
						{	
							//player animation has started, player attacked first, player animation finished, something fainted => enemy fainted
							`log("enemy fainted, anim/control");
							//This section defines what happens after an opposing pokemon has fainted
							bPlayerPokemonVictory=true;
							PlayerPokemonVictory(); //This is separate from the state defined by bPlayerPokemonVictory so it only gets performed once
							//reset play animation flags
							bEnemyAttackAnimStarted = false;
							bPlayerAttackAnimStarted = false;
							bPlayBattleAnimations = false;
						}
						else
						{
							bEnemyAttackAnimStarted = true;
							StartEnemyPokemonAnimation();
							bPlayerAttackAnimStarted = false;
						}
				    }
				}
				else
				{
					if (Follower.TestSlot.GetPlayedAnimation() == '')
				    {
						//if both animations have finished, change state
						//if enemy attacked first and resulted in a player faint, change state appropriately
						StopPokemonParticleComponent();
						fainted = CheckFainted();
						if (fainted == "enemy")
						{
							//player animation has started, enemy attacked first, player animation finished, enemy fainted => enemy fainted
							`log("enemy fainted, anim/control");
							bPlayerPokemonVictory=true;
							PlayerPokemonVictory(); //This is separate from the state defined by bPlayerPokemonVictory so it only gets performed once
							//reset play animation flags
							bEnemyAttackAnimStarted = false;
							bPlayerAttackAnimStarted = false;
							bPlayBattleAnimations = false;
						}
						else
						{
							bEnemyAttackAnimStarted = false;
							bPlayerAttackAnimStarted = false;
							bPlayBattleAnimations = false;
							bSelectBattleOption=true;
						}
					}
				}
			}
			
			if(bEnemyAttackAnimStarted)
			{
				if (!bPlayerAttackFirst)
				{
				    if (EnemyPokemon.TestSlot.GetPlayedAnimation() == '')
				    {
				    	//animation was started and finished
						//make sure the player did not faint after getting attacked, if so though, go to enemy victory
						StopPokemonParticleComponent();
						fainted = CheckFainted();
						if (fainted == "player")
						{	
							`log("player fainted, anim/control");
							//This section defines what happens after a player pokemon has fainted
							//bSelectBattleAttack=false;
							bSelectBattlePokemon=true;
							//reset play animation flags
							bEnemyAttackAnimStarted = false;
							bPlayerAttackAnimStarted = false;
							bPlayBattleAnimations = false;
						}
						else
						{
							bPlayerAttackAnimStarted = true;
							StartPlayerPokemonAnimation();
							bEnemyAttackAnimStarted = false;
						}
				    }
				}
				else
				{
					if (EnemyPokemon.TestSlot.GetPlayedAnimation() == '')
				    {
						//if both animations have finished, change state
						//if player attacked first and resulted in an enemy faint, change state appropriately
						StopPokemonParticleComponent();
						fainted = CheckFainted();
						if (fainted == "player")
						{
							`log("player fainted, anim/control");
							//bSelectBattleAttack=false;
							bSelectBattlePokemon=true;
							//reset play animation flags
							bEnemyAttackAnimStarted = false;
							bPlayerAttackAnimStarted = false;
							bPlayBattleAnimations = false;
						}
						else
						{
							bEnemyAttackAnimStarted = false;
							bPlayerAttackAnimStarted = false;
							bPlayBattleAnimations = false;
							bSelectBattleOption=true;
						}
					}
				}
			}
		}
	}
	else
 	{
        foreach WorldInfo.AllPawns(class'THEPawn_NPC_Enemy', WildPokemon)
        {
            if (WildPokemon != None && WildPokemon.bFainted == false)
            {
                Distance = VSize2D(Pawn.Location - WildPokemon.Location);
                if (Distance < 400)
	     	    {

	    			bInBattle = true;
					bSelectBattlePokemon=true;
					EnemyPokemon=WildPokemon;
					EnemyPokemon.bInBattle=true;
					//Create enemy instance, need a random level based on character level..
					temp=GetCharacterMaxLevelPokemon();
					//Make a calculation to determine the wild opponent's level
					temp = Rand(wildLevelMultiplier*temp);
					if (temp<=1)
					{
					    temp=1;
					}
					if (temp>100)
					{
					    temp=100;
					}
					EnemyPokemonDBInstance=CreateWildEnemyPokemonFromDB(temp);
					//Add attacks to EnemyPokemonDBInstance
					AddOpponentAttackForLevel();
					
					RotateEnemyPokemonToPlayer();
					
	    		    //GoToState('Idle');
	     	    }
            }
        }
	}
	ResetNumeralPress();
}

//******************************************************************
// *  
// *  
// *  
// *                            STATES
// *  
// *  
// *  
// *  
// ******************************************************************
//Disable Player Control to wait for input
state Idle
{
Begin:
	StopLatentExecution();
    Pawn.Acceleration = vect(0,0,0);
}

state SelectCharacter
{
Begin:
	StopLatentExecution();
    Pawn.Acceleration = vect(0,0,0);
}

//******************************************************************
//*  
//*  
//*  
//*                        HELPER FUNCTIONS
//*  
//*  
//*  
//*  
//******************************************************************
function PlayerPokemonVictory()
{

	ResetCharacterTemporaryBattleStats();
	UpdatePlayerPartyExperience();
	UpdatePlayerPartyLevelAndStats();
	//UpdatePlayerPartyEvolution();
}

function SpawnFollowerPikachu()
{
	`Log("Spawn Pikachu");
	Follower = Spawn(FollowerPawnClass,,, Pawn.Location - vect(200,200,0), Pawn.Rotation);
}

function MoveFollowerForBattle()
{
	local Vector enemyLocation,characterLocation;
	local Vector target;
	local Rotator targetRotation;
	local float resultantx,resultanty;//x,y desired follower offset from player
	local float tx,ty;//x,y offset of enemy from player
	local float signx,signy;//there are four solutions to the equation, sign for the correct one

	enemyLocation     = EnemyPokemon.Location;
	characterLocation = Pawn.Location;

	tx=abs(enemyLocation.X-characterLocation.X);
	ty=abs(enemyLocation.Y-characterLocation.Y);
	
	if (enemyLocation.X<characterLocation.X)
	{
		signx=-1;
	}
	else
	{
		signx=1;
	}

	if (enemyLocation.Y<characterLocation.Y)
	{
		signy=-1;
	}
	else
	{
		signy=1;
	}

	//sometime maybe make 100 a variable based on collision boundaries, ie 100=>radiusCharacter+radiusFollower+1
	resultantx=signx*(100*tx)/(sqrt(ty*ty+tx*tx));
	resultanty=signy*(100*ty)/(sqrt(ty*ty+tx*tx));
	//target = the location between pawn and enemy, offset calculation from pawn
	target=characterLocation;

	target.X=target.X+resultantx;
	target.Y=target.Y+resultanty;
	`log(target);
	Follower.SetControllerTarget(target);
	Follower.SetControllerBattleStatus(true);
	
	targetRotation = rotator(enemyLocation - target);
	
	Follower.targetRotation = targetRotation;
}

function RotateFollowerPokemonToEnemy()
{
	local Vector followerLocation,enemyLocation;
	local Rotator targetRotation;
	
	followerLocation  = Follower.Location;
	enemyLocation     = EnemyPokemon.Location;
	
	targetRotation = rotator(enemyLocation - followerLocation);
	Follower.targetRotation = targetRotation;
}

function RotateEnemyPokemonToFollower()
{
	local Vector followerLocation,enemyLocation;
	local Rotator targetRotation;
	
	followerLocation  = Follower.Location;
	enemyLocation     = EnemyPokemon.Location;
	
	targetRotation = rotator(followerLocation - enemyLocation);
	EnemyPokemon.targetRotation = targetRotation;
}

function RotateEnemyPokemonToPlayer()
{
	local Vector enemyLocation,characterLocation;
	local Rotator targetRotation;
	
	characterLocation = Pawn.Location;
	enemyLocation     = EnemyPokemon.Location;
	
	targetRotation = rotator(characterLocation - enemyLocation);
	EnemyPokemon.targetRotation = targetRotation;
}

function RegainPlayerControl()
{
    //Default starting state for basic movement
	GoToState('PlayerWaiting');
	StartFire();
}

function array<float> GetCurrentSelectedPokemonHP()
{
    local array<float> hp;
	hp[0] = currentSelectedBattlePokemon.currentHitPoints;
	hp[1] = currentSelectedBattlePokemon.maxHitPoints;
	return hp;
}

function array<float> GetCurrentOpponentHP()
{
    local array<float> hp;
	hp[0] = EnemyPokemonDBInstance.currentHitPoints;
	hp[1] = EnemyPokemonDBInstance.maxHitPoints;
	return hp;
}

function THEPokemonInventory CreateWildEnemyPokemonFromDB(int level)
{
	local THEPokemonInventory inv;
	local THEPokemon pkmn;
	
	pkmn = gamestate.getPokemon(EnemyPokemon.speciesName);
	inv = gamestate.createPokemonInventory(pkmn);
	inv.Level=level;
	return inv;
}

function BattleStateExitCleanup()
{
	StopPokemonParticleComponent();
	pokemonBattleParticipatedInit();
	pokemonThatCanLearnNewMoveInit();
	bEnemyAttackAnimStarted = false;
	bPlayerAttackAnimStarted = false;
	bPlayBattleAnimations = false;
	bSelectBattlePokemon=false;
	bSelectBattleOption=false;
	bSelectBattleAttack=false;
	bSelectBattleItems=false;
	bInBattle=false;
	EnemyPokemon.bInBattle=false;
	Follower.SetControllerBattleStatus(false);
}

//return the weakness modifier for the attacking pokemon damage to the defending pokemon
function float CalculateTypeDifference(String attackType, String defendType)
{
	local int row,column,i;
	for(i=0;i<ArrayCount(typeNameList);++i)
	{
		if(typeNameList[i]==attackType)
		{
			row=i;
		}
		if(typeNameList[i]==defendType)
		{
			column=i;
		}
	}
	return typeDiffPerc[row*ArrayCount(typeNameList)+column];
}


//@return bool Hit=True, Miss=False
function bool CharacterPokemonAttackOpponentPokemon()
{
    local int damageToDo;
	local float stageMagnitude;
	local float percentageChanceToHit;
	local float stab,weaknessResistance,level,attackStat,attackPower,defenseStat,randomNumber;
	local float attackAccuracy, accuracy, evasion;
	
	attackAccuracy = currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].Accuracy;
	accuracy       = currentSelectedBattlePokemon.Accuracy;
	evasion        = currentSelectedBattlePokemon.Evasion;
    percentageChanceToHit=100*(attackAccuracy)*accuracy/evasion;
	
	if ( (percentageChanceToHit > Rand(100)) || (attackAccuracy > 1))
	{
	    if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].Power>0)
	    {
	        level=currentSelectedBattlePokemon.Level;
	        attackStat=currentSelectedBattlePokemon.AttackStat;
	        attackPower=currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].Power;
	        defenseStat=EnemyPokemonDBInstance.DefenseStat;
	        if (currentSelectedBattlePokemon.pokemonType == currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackType)
	        {
	            stab=1.5;
	        }
	    	else
	    	{
	    	    stab=1;
	    	}
	        weaknessResistance=CalculateTypeDifference(currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackType,EnemyPokemonDBInstance.pokemonType);
	        randomnumber=85+Rand(15);
			`log("damageToDo, level="$level$" attackStat="$attackStat$" attackPower="$attackPower$" defenseStat="$defenseStat$" stab="$stab$" weaknessResistance="$weaknessResistance$" randomNumber="$randomNumber);
	        damageToDo = FCeil(((((2*level/5+2)*attackStat*attackPower/defenseStat)/50)+2)*stab*weaknessResistance*(randomNumber/100));
			
			`log("damageToDo: "$damageToDo);
	    	//damageToDo = int(((((2*level/5+2)*attackStat*attackPower/defenseStat)/50)+2)*stab*(randomNumber/100));
	        EnemyPokemonDBInstance.currentHitPoints = EnemyPokemonDBInstance.currentHitPoints - damageToDo;
        }
		else
		{
			//check for enemy stage effects
		    stageMagnitude=currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].stageMag;
			//display effect
			if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].stageName != "none")
			{
			    if (stageMagnitude>0)
		        {
					THEHud(myHUD).SetPlayerStatus(currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].stageName$" increased!");
		        }
		        else
		        {
					THEHud(myHUD).SetEnemyStatus(currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].stageName$" decreased!");
		        }
			}
			
		    switch(currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].stageName)
		    {
		    case "none":
		        //do nothing
		        break;
		    case "accuracy":
		    	if (stageMagnitude>0)
		    	{
		    		currentSelectedBattlePokemon.Accuracy = currentSelectedBattlePokemon.Accuracy*((3+stageMagnitude)/3);
		    	}
		    	else
		    	{
		    		EnemyPokemonDBInstance.Accuracy = EnemyPokemonDBInstance.Accuracy*(3/(3-stageMagnitude));
		    	}
		    	break;
		    case "evasion":
		    	if (stageMagnitude>0)
		    	{
		    		currentSelectedBattlePokemon.Evasion = currentSelectedBattlePokemon.Evasion*((3+stageMagnitude)/3);
		    	}
		    	else
		    	{
		    		EnemyPokemonDBInstance.Evasion = EnemyPokemonDBInstance.Evasion*(3/(3-stageMagnitude));
		    	}
		    	break;
		    case "attack":
		    	if (stageMagnitude>0)
		    	{
		    		currentSelectedBattlePokemon.AttackStat = currentSelectedBattlePokemon.AttackStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		EnemyPokemonDBInstance.AttackStat = EnemyPokemonDBInstance.AttackStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "defense":
		    	if (stageMagnitude>0)
		    	{
		    		currentSelectedBattlePokemon.DefenseStat = currentSelectedBattlePokemon.DefenseStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		EnemyPokemonDBInstance.DefenseStat = EnemyPokemonDBInstance.DefenseStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "spAtk":
		    	if (stageMagnitude>0)
		    	{
		    		currentSelectedBattlePokemon.SpAtkStat = currentSelectedBattlePokemon.SpAtkStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		EnemyPokemonDBInstance.SpAtkStat = EnemyPokemonDBInstance.SpAtkStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "spDef":
		    	if (stageMagnitude>0)
		    	{
		    		currentSelectedBattlePokemon.SpDefStat = currentSelectedBattlePokemon.SpDefStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		EnemyPokemonDBInstance.SpDefStat = EnemyPokemonDBInstance.SpDefStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "speed":
		    	if (stageMagnitude>0)
		    	{
		    		currentSelectedBattlePokemon.SpeedStat = currentSelectedBattlePokemon.SpeedStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		EnemyPokemonDBInstance.SpeedStat = EnemyPokemonDBInstance.SpeedStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    }

		}
		return true;
	}
	return false;
}

//@return bool Hit=True, Miss=False
function bool OpponentPokemonAttackCharacterPokemon()
{
    local int damageToDo;
	local float stageMagnitude;
	local float percentageChanceToHit;
	local float stab,weaknessResistance,level,attackStat,attackPower,defenseStat,randomNumber;
	local float attackAccuracy, accuracy, evasion;
	
	attackAccuracy = EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].Accuracy;
	accuracy       = EnemyPokemonDBInstance.Accuracy;
	evasion        = currentSelectedBattlePokemon.Evasion;
    percentageChanceToHit=100*(attackAccuracy)*accuracy/evasion;
	
	if ( (percentageChanceToHit > Rand(100)) || (attackAccuracy > 1))
	{
		if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].Power>0)
		{
	        level=EnemyPokemonDBInstance.Level;
	        attackStat=EnemyPokemonDBInstance.AttackStat;
	        attackPower=EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].Power;
	        defenseStat=currentSelectedBattlePokemon.DefenseStat;
	        if (EnemyPokemonDBInstance.pokemonType == EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackType)
	        {
	            stab=1.5;
	        }
		    else
		    {
		        stab=1;
		    }
	        weaknessResistance=CalculateTypeDifference(EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackType,currentSelectedBattlePokemon.pokemonType);
	        randomnumber=85+Rand(15);
			damageToDo = FCeil(((((2*level/5+2)*attackStat*attackPower/defenseStat)/50)+2)*stab*weaknessResistance*(randomNumber/100));	        currentSelectedBattlePokemon.currentHitPoints = currentSelectedBattlePokemon.currentHitPoints - damageToDo;
		}
		else
		{
			//check for enemy stage effects
		    stageMagnitude=EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].stageMag;
			//display effect
			if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].stageName != "none")
			{
			    if (stageMagnitude>0)
		        {
					THEHud(myHUD).SetEnemyStatus(EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].stageName$" increased!");
		        }
		        else
		        {
					THEHud(myHUD).SetPlayerStatus(EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].stageName$" decreased!");
		        }
			}
			
		    switch(EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].stageName)
		    {
		    case "none":
		        //do nothing
		        break;
		    case "accuracy":
		    	if (stageMagnitude>0)
		    	{
		    		EnemyPokemonDBInstance.Accuracy = EnemyPokemonDBInstance.Accuracy*((3+stageMagnitude)/3);
		    	}
		    	else
		    	{
		    		currentSelectedBattlePokemon.Accuracy = currentSelectedBattlePokemon.Accuracy*(3/(3-stageMagnitude));
		    	}
		    	break;
		    case "evasion":
		    	if (stageMagnitude>0)
		    	{
		    		EnemyPokemonDBInstance.Evasion = EnemyPokemonDBInstance.Evasion*((3+stageMagnitude)/3);
		    	}
		    	else
		    	{
		    		currentSelectedBattlePokemon.Evasion = currentSelectedBattlePokemon.Evasion*(3/(3-stageMagnitude));
		    	}
		    	break;
		    case "attack":
		    	if (stageMagnitude>0)
		    	{
		    		EnemyPokemonDBInstance.AttackStat = EnemyPokemonDBInstance.AttackStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		currentSelectedBattlePokemon.AttackStat = currentSelectedBattlePokemon.AttackStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "defense":
		    	if (stageMagnitude>0)
		    	{
		    		EnemyPokemonDBInstance.DefenseStat = EnemyPokemonDBInstance.DefenseStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		currentSelectedBattlePokemon.DefenseStat = currentSelectedBattlePokemon.DefenseStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "spAtk":
		    	if (stageMagnitude>0)
		    	{
		    		EnemyPokemonDBInstance.SpAtkStat = EnemyPokemonDBInstance.SpAtkStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		currentSelectedBattlePokemon.SpAtkStat = currentSelectedBattlePokemon.SpAtkStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "spDef":
		    	if (stageMagnitude>0)
		    	{
		    		EnemyPokemonDBInstance.SpDefStat = EnemyPokemonDBInstance.SpDefStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		currentSelectedBattlePokemon.SpDefStat = currentSelectedBattlePokemon.SpDefStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    case "speed":
		    	if (stageMagnitude>0)
		    	{
		    		EnemyPokemonDBInstance.SpeedStat = EnemyPokemonDBInstance.SpeedStat*((2+stageMagnitude)/2);
		    	}
		    	else
		    	{
		    		currentSelectedBattlePokemon.SpeedStat = currentSelectedBattlePokemon.SpeedStat*(2/(2-stageMagnitude));
		    	}
		    	break;
		    }
		}
		return true;
	}
	return false;
	
}

//@return - 0 for failed, hopefully because the pokemon already has four moves.  otherwise something else is wrong..
//          1 for success or no new attacks need to be added for this level
function bool AddPokemonAttackForLevel(String pokemon,int level)
{
	local int i;
	local bool status;
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
	    if(char.pokemonInventory[i].pokemonSpecies == pokemon)
		{
		    if(char.pokemonInventory[i].FirstAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].FirstAttackName);
				if (status==false){return false;}
			}
		    if(char.pokemonInventory[i].SecondAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].SecondAttackName);
				if (status==false){return false;}
			}
		    if(char.pokemonInventory[i].ThirdAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].ThirdAttackName);
				if (status==false){return false;}
			}
		    if(char.pokemonInventory[i].FourthAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].FourthAttackName);
				if (status==false){return false;}
			}
		    if(char.pokemonInventory[i].FifthAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].FifthAttackName);
				if (status==false){return false;}
			}
		    if(char.pokemonInventory[i].SixthAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].SixthAttackName);
				if (status==false){return false;}
			}
		    if(char.pokemonInventory[i].SeventhAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].SeventhAttackName);
				if (status==false){return false;}
			}
		    if(char.pokemonInventory[i].EighthAttackLevel==level)
			{
			    status = addPokemonAttack(pokemon,char.pokemonInventory[i].EighthAttackName);
				if (status==false){return false;}
			}			
		}
	}
	return true;
}

//randomly give a leveled pokemon attacks it deserves for it's level
function AddOpponentAttackForLevel()
{
	local bool status;
	
	if(EnemyPokemonDBInstance.FirstAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.FirstAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.FirstAttackName);
		}
	}
	if(EnemyPokemonDBInstance.SecondAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.SecondAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.SecondAttackName);
		}
	}
	if(EnemyPokemonDBInstance.ThirdAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.ThirdAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.ThirdAttackName);
		}
	}
	if(EnemyPokemonDBInstance.FourthAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.FourthAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.FourthAttackName);
		}
	}
	if(EnemyPokemonDBInstance.FifthAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.FifthAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.FifthAttackName);
		}
	}
	if(EnemyPokemonDBInstance.SixthAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.SixthAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.SixthAttackName);
		}
	}
	if(EnemyPokemonDBInstance.SeventhAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.SeventhAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.SeventhAttackName);
		}
	}
	if(EnemyPokemonDBInstance.EighthAttackLevel<=EnemyPokemonDBInstance.level)
	{
	    status = addEnemyAttack(EnemyPokemonDBInstance.EighthAttackName);
		if (status==false)
		{
		    removeEnemyAttack();
			status = addEnemyAttack(EnemyPokemonDBInstance.EighthAttackName);
		}
	}
}

function int GetCharacterMaxLevelPokemon()
{
    local int i;
	local int maxLevel;
	maxLevel=1;
	for (i=0;i<char.pokemonInventory.Length;++i)
	{
	    if (char.pokemonInventory[i].Level > maxLevel)
		{
		    maxLevel = char.pokemonInventory[i].Level;
		}
	}
	return maxLevel;
}

function ResetCharacterTemporaryBattleStats()
{
    local int i;
	`log("calledpokemonstatreset");
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
	    if (char.pokemonInventory[i].inPlayerParty)
		{
		    `log("resetcharactertemporarybattlestats: "$char.pokemonInventory[i].pokemonSpecies);
	        char.pokemonInventory[i].Evasion = 1;
			char.pokemonInventory[i].Accuracy = 1;
			
			char.pokemonInventory[i].paralyzed = false;
			
			//These may have been changed by stage attacks during battle
			char.pokemonInventory[i].AttackStat=((char.pokemonInventory[i].IVAttack + char.pokemonInventory[i].BaseAttack + Sqrt(char.pokemonInventory[i].currentEVAttack)/8)*char.pokemonInventory[i].Level)/50+5;
			char.pokemonInventory[i].DefenseStat=((char.pokemonInventory[i].IVDefense + char.pokemonInventory[i].BaseDefense + Sqrt(char.pokemonInventory[i].currentEVDefense)/8)*char.pokemonInventory[i].Level)/50+5;
			char.pokemonInventory[i].SpAtkStat=((char.pokemonInventory[i].IVSpecial + char.pokemonInventory[i].BaseSpAtk + Sqrt(char.pokemonInventory[i].currentEVSpAttack)/8)*char.pokemonInventory[i].Level)/50+5;
			char.pokemonInventory[i].SpDefStat=((char.pokemonInventory[i].IVSpecial + char.pokemonInventory[i].BaseSpDef + Sqrt(char.pokemonInventory[i].currentEVSpDefense)/8)*char.pokemonInventory[i].Level)/50+5;
			char.pokemonInventory[i].SpeedStat=((char.pokemonInventory[i].IVSpeed + char.pokemonInventory[i].BaseSpeed + Sqrt(char.pokemonInventory[i].currentEVSpeed)/8)*char.pokemonInventory[i].Level)/50+5;
		}
	}
}

function ExchangeBattleAttacks()
{
    local bool hit;
	local String fainted;
	
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].powerPoints > 0)
	{
	    currentEnemySelectedBattleAttack=Rand(EnemyPokemonDBInstance.pokemonAttackInventory.Length);
		if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackPriority > currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackPriority)
		{
			bPlayerAttackFirst=false;
		    hit = OpponentPokemonAttackCharacterPokemon();
			if(hit==false) {THEHud(myHUD).SetEnemyStatus("Miss!");}
			else
			{
				fainted = CheckFainted();
				if (fainted != "none"){return;}
			    ApplyEnemyStatusAilments();
				
			}
			hit = CharacterPokemonAttackOpponentPokemon();
			if(hit==false) {THEHud(myHUD).SetPlayerStatus("Miss!");}
			else
			{
				fainted = CheckFainted();
				if (fainted != "none"){return;}
			    ApplyPlayerStatusAilments();
			}

		}
		if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackPriority < currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackPriority)
		{
			bPlayerAttackFirst=true;
			hit = CharacterPokemonAttackOpponentPokemon();
			if(hit==false) {THEHud(myHUD).SetPlayerStatus("Miss!");}
			else
			{
				fainted = CheckFainted();
				if (fainted != "none"){return;}
			    ApplyPlayerStatusAilments();
			}
		    hit = OpponentPokemonAttackCharacterPokemon();
			if(hit==false) {THEHud(myHUD).SetEnemyStatus("Miss!");}
			else
			{
				fainted = CheckFainted();
				if (fainted != "none"){return;}
			    ApplyEnemyStatusAilments();
			}
		}
		if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackPriority == currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackPriority)
		{
		    if (EnemyPokemonDBInstance.SpeedStat > currentSelectedBattlePokemon.SpeedStat)
			{
				bPlayerAttackFirst=false;
		        hit = OpponentPokemonAttackCharacterPokemon();
			    if(hit==false) {THEHud(myHUD).SetEnemyStatus("Miss!");}
				else
			    {
				    fainted = CheckFainted();
				    if (fainted != "none"){return;}
			        ApplyEnemyStatusAilments();
			    }
			    hit = CharacterPokemonAttackOpponentPokemon();
			    if(hit==false) {THEHud(myHUD).SetPlayerStatus("Miss!");}
				else
			    {
				    fainted = CheckFainted();
				    if (fainted != "none"){return;}
			        ApplyPlayerStatusAilments();
			    }
			}
			if (EnemyPokemonDBInstance.SpeedStat < currentSelectedBattlePokemon.SpeedStat)
			{
				bPlayerAttackFirst=true;
			    hit = CharacterPokemonAttackOpponentPokemon();
			    if(hit==false) {THEHud(myHUD).SetPlayerStatus("Miss!");}
				else
				{
				    fainted = CheckFainted();
				    if (fainted != "none"){return;}
			        ApplyPlayerStatusAilments();
			    }
		        hit = OpponentPokemonAttackCharacterPokemon();
			    if(hit==false) {THEHud(myHUD).SetEnemyStatus("Miss!");}
				else
			    {
				    fainted = CheckFainted();
				    if (fainted != "none"){return;}
			        ApplyEnemyStatusAilments();
			    }
			}
			if (EnemyPokemonDBInstance.SpeedStat == currentSelectedBattlePokemon.SpeedStat)
			{
			    //Take another look at this if you get the chance, fairness is weighted toward the opponent.
				bPlayerAttackFirst=false;
		        hit = OpponentPokemonAttackCharacterPokemon();
			    if(hit==false) {THEHud(myHUD).SetEnemyStatus("Miss!");}
				else
			    {
				    fainted = CheckFainted();
				    if (fainted != "none"){return;}
			        ApplyEnemyStatusAilments();
			    }
			    hit = CharacterPokemonAttackOpponentPokemon();
			    if(hit==false) 
				{THEHud(myHUD).SetPlayerStatus("Miss!");}
				else
				{
				    fainted = CheckFainted();
				    if (fainted != "none"){return;}
			        ApplyPlayerStatusAilments();
			    }
			}
		}
	    
		currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].powerPoints -= 1;
	}
}

//Calculate percentage chance to hit status ailments to place on the enemy, if any
function ApplyPlayerStatusAilments()
{
    local float temp;
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].extraEffect != "none")
	{
	    temp = Rand(100);
	    if ((currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].extraEffectMag*100)>temp)
		{
		
			switch(currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].extraEffect)
			{
			case ("paralyzed"):
				if (EnemyPokemonDBInstance.paralyzed == false)
				{
					EnemyPokemonDBInstance.paralyzed = true;
					EnemyPokemonDBInstance.SpeedStat = EnemyPokemonDBInstance.SpeedStat*0.25;
					EnemyPokemonDBInstance.Accuracy  = EnemyPokemonDBInstance.Accuracy*0.75;
					THEHud(myHUD).SetEnemyStatus("paralyzed!");
				}
				else
				{
					THEHud(myHUD).SetEnemyStatus("paralyzed!");
				}
				break;
			}
		}
	}
}

//Calculate percentage chance to hit status ailments to place on the character, if any
function ApplyEnemyStatusAilments()
{
    local float temp;
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].extraEffect != "none")
	{
	    temp = Rand(100);
	    if ((EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].extraEffectMag*100)>temp)
		{
			switch(EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].extraEffect)
			{
			case ("paralyzed"):
				if (currentSelectedBattlePokemon.paralyzed == false)
				{
					currentSelectedBattlePokemon.paralyzed = true;
					currentSelectedBattlePokemon.SpeedStat = currentSelectedBattlePokemon.SpeedStat*0.25;
					currentSelectedBattlePokemon.Accuracy  = currentSelectedBattlePokemon.Accuracy*0.25;
					THEHud(myHUD).SetPlayerStatus("paralyzed!");
				}
				else
				{
					THEHud(myHUD).SetEnemyStatus("paralyzed!");
				}
				break;
			}
		}
	}
}

//Roll to remove status ailments
function CheckStatusAilments()
{
    //none to roll for right now
}

function String CheckFainted()
{
	if (currentSelectedBattlePokemon.currentHitPoints <= 0)
	{
		`log("player fainted");
		currentSelectedBattlePokemon.isFainted = true;
		return "player";
	}

	//if fainted and wild, pause character, bring up stat screen, experience, level up, add attacks, evolve
	if (EnemyPokemonDBInstance.currentHitPoints <= 0)
	{
		`log("enemy fainted");
		EnemyPokemonDBInstance.isFainted = true;
		return "enemy";
	}
	return "none";
}

//Use an item in the character's inventory
function UseInventory(String itemName, String pokemonSpecies)
{
	local int i;
	
	switch(itemName)
	{
	case("berry"):
		if (char.characterBerries>0)
		{
	        for (i = 0; i < char.pokemonInventory.Length; ++i)
	        {
	            if (char.pokemonInventory[i].pokemonSpecies == pokemonSpecies)
	        	{
	        	    if (char.pokemonInventory[i].isFainted == false)
	        		{
						char.pokemonInventory[i].currentHitPoints+=10;
						if (char.pokemonInventory[i].currentHitPoints>char.pokemonInventory[i].maxHitPoints)
						{
							char.pokemonInventory[i].currentHitPoints=char.pokemonInventory[i].maxHitPoints;
						}
						char.characterBerries--;
	        		}
	        	}
	        }
		}
		break;
	}
}

function UpdatePlayerPartyExperience()
{
	local int i,j;
	local float a,t,b,e,L,s;
	
	if (true)//eventually this group will need to be finished and moved into the calculation loop
	{
	    //a is equal to 1 if the fainted Pokémon is wild, and 1.5 if the fainted Pokémon is owned by a Trainer.
	    a=1;
	    //t is equal to 1 if the winning Pokémon's OT is its current owner, 1.5 if the Pokémon was gained in a domestic trade
	    t=1;
	    //e is equal to 1.5 if the winning Pokémon is holding a Lucky Egg, and 1 otherwise.
	    e=1;
	}
	//b is the base experience yield of the fainted Pokémon's species
	b=EnemyPokemonDBInstance.experienceYield;
	//L is the level of the fainted Pokémon
	L=EnemyPokemonDBInstance.level;
	`log("Enemy Level: "$L);
	//s is the number of Pokémon that participated in the battle and have not fainted
	s=0;
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
		if (char.pokemonInventory[i].inPlayerParty)
		{
			for (j=0; j < ArrayCount(pokemonBattleParticipatedList); ++j)
			{
				if (char.pokemonInventory[i].pokemonSpecies == pokemonBattleParticipatedList[j])
				{
					if (char.pokemonInventory[i].isFainted == false)
					{
						s+=1;
					}
					break;
				}
			}
		}
	}
	if (s==0)
	{
		`log("warning! s==0, which should not be possible");
		s=1;
	}

	
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
		if (char.pokemonInventory[i].inPlayerParty)
		{
			for (j=0; j < ArrayCount(pokemonBattleParticipatedList); ++j)
			{
				if (char.pokemonInventory[i].pokemonSpecies == pokemonBattleParticipatedList[j])
				{
					char.pokemonInventory[i].currentExperience += (a*t*b*e*L)/(7*s);
				}
			}
		}
	}
}

function UpdatePlayerPartyLevelAndStats()
{
	local int i,nextLevel;
	local pokemonMove pM;
	
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
		if (char.pokemonInventory[i].inPlayerParty)
		{
			//Update EVs
			char.pokemonInventory[i].currentEVHP        += EnemyPokemonDBInstance.EVHP;
			char.pokemonInventory[i].currentEVAttack    += EnemyPokemonDBInstance.EVAttack;
			char.pokemonInventory[i].currentEVDefense   += EnemyPokemonDBInstance.EVDefense;
			char.pokemonInventory[i].currentEVSpAttack  += EnemyPokemonDBInstance.EVSpAttack;
			char.pokemonInventory[i].currentEVSpDefense += EnemyPokemonDBInstance.EVSpDefense;
			char.pokemonInventory[i].currentEVSpeed     += EnemyPokemonDBInstance.EVSpeed;
			
			nextLevel=char.pokemonInventory[i].Level+1;
			if (char.pokemonInventory[i].experienceType=="fast")
			{
				if (char.pokemonInventory[i].currentExperience >= (4*(nextLevel*nextLevel*nextLevel)/5))
				{
					if (char.pokemonInventory[i].Level != 100)
					{
					    //Update stats
					    char.pokemonInventory[i].Level++;
					    char.pokemonInventory[i].maxHitPoints=((char.pokemonInventory[i].IVHP + char.pokemonInventory[i].BaseHP + Sqrt(char.pokemonInventory[i].currentEVHP)/8 + 50)*char.pokemonInventory[i].Level)/50+10;
					    char.pokemonInventory[i].AttackStat=((char.pokemonInventory[i].IVAttack + char.pokemonInventory[i].BaseAttack + Sqrt(char.pokemonInventory[i].currentEVAttack)/8)*char.pokemonInventory[i].Level)/50+5;
					    char.pokemonInventory[i].DefenseStat=((char.pokemonInventory[i].IVDefense + char.pokemonInventory[i].BaseDefense + Sqrt(char.pokemonInventory[i].currentEVDefense)/8)*char.pokemonInventory[i].Level)/50+5;
					    char.pokemonInventory[i].SpAtkStat=((char.pokemonInventory[i].IVSpecial + char.pokemonInventory[i].BaseSpAtk + Sqrt(char.pokemonInventory[i].currentEVSpAttack)/8)*char.pokemonInventory[i].Level)/50+5;
					    char.pokemonInventory[i].SpDefStat=((char.pokemonInventory[i].IVSpecial + char.pokemonInventory[i].BaseSpDef + Sqrt(char.pokemonInventory[i].currentEVSpDefense)/8)*char.pokemonInventory[i].Level)/50+5;
					    char.pokemonInventory[i].SpeedStat=((char.pokemonInventory[i].IVSpeed + char.pokemonInventory[i].BaseSpeed + Sqrt(char.pokemonInventory[i].currentEVSpeed)/8)*char.pokemonInventory[i].Level)/50+5;
					    char.pokemonInventory[i].currentHitPoints=char.pokemonInventory[i].maxHitPoints;
						//I am aware this method is a pain, I don't mind though.  I could replace it with an instantiated array of structs and loop through them, but would it really make any real difference in the big scheme of things?
						if (char.pokemonInventory[i].Level == char.pokemonInventory[i].FirstAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].FirstAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}
						if(char.pokemonInventory[i].Level == char.pokemonInventory[i].SecondAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].SecondAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}
						if(char.pokemonInventory[i].Level == char.pokemonInventory[i].ThirdAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].ThirdAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}
						if(char.pokemonInventory[i].Level == char.pokemonInventory[i].FourthAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].FourthAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}
						if(char.pokemonInventory[i].Level == char.pokemonInventory[i].FifthAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].FifthAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}
						if(char.pokemonInventory[i].Level == char.pokemonInventory[i].SixthAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].SixthAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}
						if(char.pokemonInventory[i].Level == char.pokemonInventory[i].SeventhAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].SeventhAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}
						if(char.pokemonInventory[i].Level == char.pokemonInventory[i].EighthAttackLevel)
						{
							pM.species = char.pokemonInventory[i].pokemonSpecies;
							pM.attack = char.pokemonInventory[i].EighthAttackName;
							pokemonThatCanLearnNewMove.addItem(pM);
						}

						`log(pM.species$" can learn "$pM.attack);
					}
				}
			}
		}
	}
}

//Return lower bound experience number
function int GetSpeciesLowerExpBoundByLevel(String species, int level)
{
	local int i;

	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
		if (char.pokemonInventory[i].pokemonSpecies == species)
		{
			if (char.pokemonInventory[i].experienceType=="fast")
			{
				return (4*(level*level*level)/5);
			}
		}
	}
}

//Return upper bound experience number
function int GetSpeciesUpperExpBoundByLevel(String species, int level)
{
	local int i;
	level++;

	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
		if (char.pokemonInventory[i].pokemonSpecies == species)
		{
			if (char.pokemonInventory[i].experienceType=="fast")
			{
				return (4*(level*level*level)/5);
			}
		}
	}
}

//******************************************************************
//*  
//*  
//*  
//*                  Numeral Key Binding Overrides
//*  
//*  
//*  
//*
//******************************************************************
//A number has been presssed, reset all number presses.
function ResetNumeralPress()
{
   lastNumeral   = 10; //Invalid
   bNumeralPressed = false;
}

exec function Press1()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=1;
}

exec function Press2()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=2;
}

exec function Press3()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=3;
}

exec function Press4()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=4;
}

exec function Press5()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=5;
}

exec function Press6()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=6;
}

exec function Press7()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=7;
}

exec function Press8()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=8;
}

exec function Press9()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=9;
}

exec function Press0()
{
   ResetNumeralPress();
   bNumeralPressed=true;
   lastNumeral=0;
}

//******************************************************************
//*  
//*  
//*  
//*                  DATA INPUT OUTPUT FUNCTIONS
//*  
//*  
//*  
//*  
//******************************************************************

/**
 * Create a new character
 */
exec function createChar(string charName)
{
	if (len(charName) == 0)
	{
		TeamMessage(none, "The character must have a name", 'none');
		return;
	}
	if (char != none)
	{
		TeamMessage(none, "Discarding previous character: "$char.CharacterName$" (id:"$char.Name$")", 'none');
	}
	char = gamestate.createCharacter(charName);
	char.CharacterName = charName;
	TeamMessage(none, "New character created", 'none');
	showChar();
}

/**
 * Save the current character
 */
exec function saveChar()
{
	if (char != none)
	{
		char.save();
		TeamMessage(none, "Current character saved", 'none');
	}
}

/**
 * Load a given character
 */
exec function loadChar(String charId)
{
	if (len(charId) == 0)
	{
		TeamMessage(none, "No character id given", 'none');
		return;
	}
	if (char != none)
	{
		TeamMessage(none, "Discarding previous character: "$char.CharacterName$" (id:"$char.Name$")", 'none');
	}
	char = gamestate.loadCharacter(charId);
	if (char == none)
	{
		TeamMessage(none, "No character found with id: "$charId, 'none');
	}
	else {
		TeamMessage(none, "Character loaded", 'none');
		showChar();
	}
}

/**
 * Print a list of the current known characters
 */
exec function printChars()
{
	local array<string> chars;
	local int i;
	chars = gamestate.getCharacters();
	if (chars.length == 0)
	{
		TeamMessage(none, "There are no saved characters", 'none');
		return;
	}
	TeamMessage(none, "The following character ids exist:", 'none');
	for (i = 0; i < chars.length; ++i)
	{
		TeamMessage(none, "    "$chars[i], 'none');
	}
}

/**
 * Return a list of the current known characters
 */
function array<string> returnChars()
{
	local array<string> chars;
	chars = gamestate.getCharacters();
	return chars;
}

/**
 * Return a list of the current character's party pokemon
 */
function array<string> returnPokemonChars()
{
	local array<string> chars;
	local int i;
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
	    if (char.pokemonInventory[i].inPlayerParty)
		{
		    if (char.pokemonInventory[i].isFainted)
			{
			    chars.addItem("<Fainted>");
			}
			else
			{
				chars.addItem(char.pokemonInventory[i].pokemonDisplayName);
			}
		}
	}
	return chars;
}
/**
 * Return a list of the current upgrading Pokemon's attacks
 */

function array<string> GetPokemonToLearnAttackList()
{
	local array<string> chars;
	local int i,j;
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
		if( char.pokemonInventory[i].pokemonSpecies == pokemonThatCanLearnNewMove[pokemonThatCanLearnNewMove.Length-1].species)
		{
			for (j = 0; j < char.pokemonInventory[i].pokemonAttackInventory.Length; ++j)
			{
				chars.addItem(char.pokemonInventory[i].pokemonAttackInventory[j].attackDisplayName);
			}
			
		}
	}
	return chars;
}

/**
 * Return a list of the current battling Pokemon's attacks
 */
function array<string> returnAttackChars()
{
	local array<string> chars;
	local int i;
	for (i = 0; i < currentSelectedBattlePokemon.pokemonAttackInventory.Length; ++i)
	{
	    chars.addItem(currentSelectedBattlePokemon.pokemonAttackInventory[i].attackDisplayName$" ("$currentSelectedBattlePokemon.pokemonAttackInventory[i].powerPoints$")");
	}
	return chars;
}


/**
 * Return a list of the current battling pokemon
 */
function array<string> returnBattleChars()
{
	local array<string> chars;
	//The player's selection
	chars[0] = currentSelectedBattlePokemon.pokemonDisplayName;
	//The wild pokemon
	chars[1] = "Enemy "$EnemyPokemon.speciesName;
	return chars;
}

/**
 * Print the current character to the console
 */
exec function showChar()
{
    local int i,j;
	if (char == none)
	{
		TeamMessage(none, "There is no character", 'none');
	}
	TeamMessage(none, "ID:                "$char.name, 'none');
	TeamMessage(none, "Display Name:      "$char.CharacterName, 'none');
	TeamMessage(none, "Pokemon Inventory: "$char.pokemonInventory.length$" pokemon", 'none');
	for (i = 0; i < char.pokemonInventory.Length; ++i)
	{
		TeamMessage(none, "+   Pokemon:    "$char.pokemonInventory[i].pokemonSpecies, 'none');
		TeamMessage(none, "    ID:         "$char.pokemonInventory[i].name, 'none');
		TeamMessage(none, "    Name:       "$char.pokemonInventory[i].pokemonDisplayName, 'none');
		for (j = 0; j < char.pokemonInventory[i].pokemonAttackInventory.Length; ++j)
	    {
		    TeamMessage(none, "    +   Attack:     "$char.pokemonInventory[i].pokemonAttackInventory[j].attackDisplayName, 'none');
			TeamMessage(none, "        ID:         "$char.pokemonInventory[i].pokemonAttackInventory[j].name, 'none');
		}
	}
}

/**
 * Put a level 1 pokemon in the inventory of the character
 */
exec function addPokemon(String basePokemon)
{	
	local THEPokemonInventory inv;
	local THEPokemon pkmn;
	local bool status;
	
	if (char == none)
	{
		TeamMessage(none, "There is no character to add to", 'none');
		return;
	}
	
	if (char.checkPokemonInventorySpecies(basePokemon))
	{
		TeamMessage(none, "Character already has a "$basePokemon, 'none');
		return;
	}
	
	pkmn = gamestate.getPokemon(basePokemon);
	
	if (pkmn == none)
	{
		TeamMessage(none, "No pokemon type exists with id: "$basePokemon, 'none');
		return;
	}

	
	inv = gamestate.createPokemonInventory(pkmn);
	if (inv == none)
	{
		TeamMessage(none, "Error creating inventory pokemon from: "$basePokemon, 'none');
		return;
	}
	
	char.addPokemonInventory(inv);
	status = AddPokemonAttackForLevel(inv.pokemonSpecies,inv.level);
	if (status == false)
	{
	    TeamMessage(none, "Failed to add Level 1 attacks because you're a bad programmer", 'none');
    }
	
	TeamMessage(none, "Pokemon "$inv.pokemonSpecies$" added to char"$char.CharacterName$" (id:"$char.Name$")", 'none');
	return;
}

/**
 * Remove a pokemon species from the inventory of the character
 */
exec function removePokemon(String basePokemonSpecies)
{	
	local bool status;
	if (char == none)
	{
		TeamMessage(none, "There is no character to remove from", 'none');
		return;
	}
	
	status = char.removePokemonInventory(basePokemonSpecies);
	if (status == false)
	{
		TeamMessage(none, "Error removing inventory pokemon species from: "$basePokemonSpecies, 'none');
		return;
	}
	TeamMessage(none, "Pokemon type "$basePokemonSpecies$" removed from char "$char.CharacterName$" (id:"$char.Name$")", 'none');
	return;
}

/**
 * Put an attack in the inventory of a pokemon.  Only 4 allowed.
 */
exec function bool addPokemonAttack(String pokemon, String baseAttack)
{	
	local THEAttackInventory inv;
	local THEAttack atk;
	local bool status;
	
	if (char == none)
	{
		TeamMessage(none, "There is no character to add to", 'none');
		return false;
	}
	
	if (char.checkPokemonInventorySpecies(pokemon) == False)
	{
		TeamMessage(none, "Character does not have a "$pokemon$" to add an attack to.", 'none');
		return false;
	}
	
	if (char.checkPokemonInventoryAttack(pokemon,baseAttack) == True)
	{
		TeamMessage(none, "Attack type already exists with id: "$baseAttack, 'none');
		return false;
	}
	
	atk = gamestate.getPokemonAttack(baseAttack);
	
	if (atk == none)
	{
		TeamMessage(none, "No attack type exists with id: "$baseAttack, 'none');
		return false;
	}

	inv = gamestate.createPokemonAttackInventory(atk);
	if (inv == none)
	{
		TeamMessage(none, "Error creating inventory attack from: "$baseAttack, 'none');
		return false;
	}
	status = char.addPokemonAttackInventory(pokemon,inv);
	if (status == false)
	{
	    TeamMessage(none, "Attack "$inv.attackDisplayName$" not added to pokemon "$pokemon$" because it has 4 moves already.", 'none');
		return false;
	}
	//TeamMessage(none, "Attack "$inv.attackDisplayName$" added to pokemon "$pokemon, 'none');
	return true;
}

/**
 * Put an attack in the inventory of an Enemy pokemon.  Only 4 allowed.
 */
exec function bool addEnemyAttack(String baseAttack)
{	
	local THEAttackInventory inv;
	local THEAttack atk;
		
	atk = gamestate.getPokemonAttack(baseAttack);
	
	if (atk == none)
	{
		TeamMessage(none, "No attack type exists with id: "$baseAttack, 'none');
		return false;
	}

	inv = gamestate.createPokemonAttackInventory(atk);
	if (inv == none)
	{
		TeamMessage(none, "Error creating inventory attack from: "$baseAttack, 'none');
		return false;
	}

	if (EnemyPokemonDBInstance.pokemonAttackInventory.Length >= 4) return false;
	
	EnemyPokemonDBInstance.pokemonAttackInventory.addItem(inv);
	EnemyPokemonDBInstance.pokemonAttackRecords.addItem(string(inv.name));
	return true;
}

/**
 * Remove a random enemy attack
 */
exec function bool removeEnemyAttack()
{	
    local int i;
	local THEAttackInventory inv;
	i=Rand(4);
	
    inv=EnemyPokemonDBInstance.pokemonAttackInventory[i];
	EnemyPokemonDBInstance.pokemonAttackInventory.removeItem(inv);
	EnemyPokemonDBInstance.pokemonAttackRecords.removeItem(string(inv.name));

	return true;
}

/**
 * Remove an attack from the inventory of a pokemon
 */
exec function removePokemonAttack(String pokemon, String baseAttack)
{	

	if (char == none)
	{
		TeamMessage(none, "There is no character to add to", 'none');
		return;
	}
	
	if (char.checkPokemonInventorySpecies(pokemon) == False)
	{
		TeamMessage(none, "Character does not have a "$pokemon$" to remove an attack from.", 'none');
		return;
	}

	if (char.checkPokemonInventoryAttack(pokemon,baseAttack) == False)
	{
		TeamMessage(none, "No attack type exists with id: "$baseAttack, 'none');
		return;
	}

	char.removePokemonAttackInventory(pokemon,baseAttack);
	//TeamMessage(none, "Attack "$baseAttack$" removed from pokemon "$pokemon, 'none');
	return;
}

//Array used to calculate weakness/resistance
function TypeArrayInit()
{
	typeDiffPerc[0]=1;
    typeDiffPerc[1]=1;
    typeDiffPerc[2]=1;
    typeDiffPerc[3]=1;
    typeDiffPerc[4]=1;
    typeDiffPerc[5]=0.5;
    typeDiffPerc[6]=0;
    typeDiffPerc[7]=1;
    typeDiffPerc[8]=1;
    typeDiffPerc[9]=1;
    typeDiffPerc[10]=1;
    typeDiffPerc[11]=1;
    typeDiffPerc[12]=1;
    typeDiffPerc[13]=1;
    typeDiffPerc[14]=1;
    typeDiffPerc[15]=2;
    typeDiffPerc[16]=1;
    typeDiffPerc[17]=0.5;
    typeDiffPerc[18]=0.5;
    typeDiffPerc[19]=1;
    typeDiffPerc[20]=2;
    typeDiffPerc[21]=0.5;
    typeDiffPerc[22]=0;
    typeDiffPerc[23]=1;
    typeDiffPerc[24]=1;
    typeDiffPerc[25]=1;
    typeDiffPerc[26]=1;
    typeDiffPerc[27]=0.5;
    typeDiffPerc[28]=2;
    typeDiffPerc[29]=1;
    typeDiffPerc[30]=1;
    typeDiffPerc[31]=2;
    typeDiffPerc[32]=1;
    typeDiffPerc[33]=1;
    typeDiffPerc[34]=1;
    typeDiffPerc[35]=0.5;
    typeDiffPerc[36]=2;
    typeDiffPerc[37]=1;
    typeDiffPerc[38]=1;
    typeDiffPerc[39]=1;
    typeDiffPerc[40]=2;
    typeDiffPerc[41]=0.5;
    typeDiffPerc[42]=1;
    typeDiffPerc[43]=1;
    typeDiffPerc[44]=1;
    typeDiffPerc[45]=1;
    typeDiffPerc[46]=1;
    typeDiffPerc[47]=1;
    typeDiffPerc[48]=0.5;
    typeDiffPerc[49]=0.5;
    typeDiffPerc[50]=0.5;
    typeDiffPerc[51]=2;
    typeDiffPerc[52]=0.5;
    typeDiffPerc[53]=1;
    typeDiffPerc[54]=1;
    typeDiffPerc[55]=2;
    typeDiffPerc[56]=1;
    typeDiffPerc[57]=1;
    typeDiffPerc[58]=1;
    typeDiffPerc[59]=1;
    typeDiffPerc[60]=1;
    typeDiffPerc[61]=1;
    typeDiffPerc[62]=0;
    typeDiffPerc[63]=2;
    typeDiffPerc[64]=1;
    typeDiffPerc[65]=2;
    typeDiffPerc[66]=0.5;
    typeDiffPerc[67]=1;
    typeDiffPerc[68]=2;
    typeDiffPerc[69]=1;
    typeDiffPerc[70]=0.5;
    typeDiffPerc[71]=2;
    typeDiffPerc[72]=1;
    typeDiffPerc[73]=1;
    typeDiffPerc[74]=1;
    typeDiffPerc[75]=1;
    typeDiffPerc[76]=0.5;
    typeDiffPerc[77]=2;
    typeDiffPerc[78]=1;
    typeDiffPerc[79]=0.5;
    typeDiffPerc[80]=1;
    typeDiffPerc[81]=2;
    typeDiffPerc[82]=1;
    typeDiffPerc[83]=2;
    typeDiffPerc[84]=1;
    typeDiffPerc[85]=1;
    typeDiffPerc[86]=1;
    typeDiffPerc[87]=1;
    typeDiffPerc[88]=2;
    typeDiffPerc[89]=1;
    typeDiffPerc[90]=1;
    typeDiffPerc[91]=0.5;
    typeDiffPerc[92]=0.5;
    typeDiffPerc[93]=2;
    typeDiffPerc[94]=1;
    typeDiffPerc[95]=1;
    typeDiffPerc[96]=1;
    typeDiffPerc[97]=1;
    typeDiffPerc[98]=0.5;
    typeDiffPerc[99]=1;
    typeDiffPerc[100]=2;
    typeDiffPerc[101]=1;
    typeDiffPerc[102]=2;
    typeDiffPerc[103]=1;
    typeDiffPerc[104]=1;
    typeDiffPerc[105]=0;
    typeDiffPerc[106]=1;
    typeDiffPerc[107]=1;
    typeDiffPerc[108]=1;
    typeDiffPerc[109]=1;
    typeDiffPerc[110]=1;
    typeDiffPerc[111]=1;
    typeDiffPerc[112]=2;
    typeDiffPerc[113]=1;
    typeDiffPerc[114]=1;
    typeDiffPerc[115]=1;
    typeDiffPerc[116]=1;
    typeDiffPerc[117]=0;
    typeDiffPerc[118]=1;
    typeDiffPerc[119]=1;
    typeDiffPerc[120]=1;
    typeDiffPerc[121]=1;
    typeDiffPerc[122]=1;
    typeDiffPerc[123]=1;
    typeDiffPerc[124]=1;
    typeDiffPerc[125]=0.5;
    typeDiffPerc[126]=2;
    typeDiffPerc[127]=1;
    typeDiffPerc[128]=0.5;
    typeDiffPerc[129]=0.5;
    typeDiffPerc[130]=2;
    typeDiffPerc[131]=1;
    typeDiffPerc[132]=1;
    typeDiffPerc[133]=2;
    typeDiffPerc[134]=0.5;
    typeDiffPerc[135]=1;
    typeDiffPerc[136]=1;
    typeDiffPerc[137]=1;
    typeDiffPerc[138]=1;
    typeDiffPerc[139]=2;
    typeDiffPerc[140]=2;
    typeDiffPerc[141]=1;
    typeDiffPerc[142]=1;
    typeDiffPerc[143]=2;
    typeDiffPerc[144]=0.5;
    typeDiffPerc[145]=0.5;
    typeDiffPerc[146]=1;
    typeDiffPerc[147]=1;
    typeDiffPerc[148]=1;
    typeDiffPerc[149]=0.5;
    typeDiffPerc[150]=1;
    typeDiffPerc[151]=1;
    typeDiffPerc[152]=0.5;
    typeDiffPerc[153]=0.5;
    typeDiffPerc[154]=2;
    typeDiffPerc[155]=2;
    typeDiffPerc[156]=0.5;
    typeDiffPerc[157]=1;
    typeDiffPerc[158]=0.5;
    typeDiffPerc[159]=2;
    typeDiffPerc[160]=0.5;
    typeDiffPerc[161]=1;
    typeDiffPerc[162]=1;
    typeDiffPerc[163]=1;
    typeDiffPerc[164]=0.5;
    typeDiffPerc[165]=1;
    typeDiffPerc[166]=1;
    typeDiffPerc[167]=2;
    typeDiffPerc[168]=1;
    typeDiffPerc[169]=0;
    typeDiffPerc[170]=1;
    typeDiffPerc[171]=1;
    typeDiffPerc[172]=1;
    typeDiffPerc[173]=1;
    typeDiffPerc[174]=2;
    typeDiffPerc[175]=0.5;
    typeDiffPerc[176]=0.5;
    typeDiffPerc[177]=1;
    typeDiffPerc[178]=1;
    typeDiffPerc[179]=0.5;
    typeDiffPerc[180]=1;
    typeDiffPerc[181]=2;
    typeDiffPerc[182]=1;
    typeDiffPerc[183]=2;
    typeDiffPerc[184]=1;
    typeDiffPerc[185]=1;
    typeDiffPerc[186]=1;
    typeDiffPerc[187]=1;
    typeDiffPerc[188]=1;
    typeDiffPerc[189]=1;
    typeDiffPerc[190]=1;
    typeDiffPerc[191]=1;
    typeDiffPerc[192]=0.5;
    typeDiffPerc[193]=1;
    typeDiffPerc[194]=1;
    typeDiffPerc[195]=1;
    typeDiffPerc[196]=1;
    typeDiffPerc[197]=2;
    typeDiffPerc[198]=1;
    typeDiffPerc[199]=2;
    typeDiffPerc[200]=1;
    typeDiffPerc[201]=1;
    typeDiffPerc[202]=1;
    typeDiffPerc[203]=1;
    typeDiffPerc[204]=0.5;
    typeDiffPerc[205]=2;
    typeDiffPerc[206]=1;
    typeDiffPerc[207]=1;
    typeDiffPerc[208]=0.5;
    typeDiffPerc[209]=2;
    typeDiffPerc[210]=1;
    typeDiffPerc[211]=1;
    typeDiffPerc[212]=1;
    typeDiffPerc[213]=1;
    typeDiffPerc[214]=1;
    typeDiffPerc[215]=1;
    typeDiffPerc[216]=1;
    typeDiffPerc[217]=1;
    typeDiffPerc[218]=1;
    typeDiffPerc[219]=1;
    typeDiffPerc[220]=1;
    typeDiffPerc[221]=1;
    typeDiffPerc[222]=1;
    typeDiffPerc[223]=1;
    typeDiffPerc[224]=2;
	
	typeNameList[0] ="Normal";
	typeNameList[1] ="Fighting";
	typeNameList[2] ="Flying";
	typeNameList[3] ="Poison";
	typeNameList[4] ="Ground";
	typeNameList[5] ="Rock";
	typeNameList[6] ="Bug";
	typeNameList[7] ="Ghost";
	typeNameList[8] ="Fire";
	typeNameList[9] ="Water";
	typeNameList[10]="Grass";
	typeNameList[11]="Electric";
	typeNameList[12]="Psychic";
	typeNameList[13]="Ice";
	typeNameList[14]="Dragon";
}

function pokemonBattleParticipatedInit()
{
	pokemonBattleParticipatedList[0]="";
	pokemonBattleParticipatedList[1]="";
	pokemonBattleParticipatedList[2]="";
	pokemonBattleParticipatedList[3]="";
	pokemonBattleParticipatedList[4]="";
	pokemonBattleParticipatedList[5]="";
}

function pokemonThatCanLearnNewMoveInit()
{
	pokemonThatCanLearnNewMove.Length=0;
}
//******************************************************************
//*  
//*  
//*  
//*                     Animation Functions
//*  
//*  
//*  
//*  
//******************************************************************
function StartPlayerPokemonAnimation()
{
	local Vector followerLocation,enemyLocation;
	local Rotator playerParticleRotation;
	
	followerLocation  = Follower.Location;
	enemyLocation     = EnemyPokemon.Location;
	
	playerParticleRotation = rotator(enemyLocation - followerLocation);
	
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.FirstAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack1',1.f);
	}
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.SecondAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack2',1.f);
	}
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.ThirdAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack3',1.f);
	}
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.FourthAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack4',1.f);
	}
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.FifthAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack5',1.f);
	}
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.SixthAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack6',1.f);
	}
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.SeventhAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack7',1.f);
	}
	if (currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName == currentSelectedBattlePokemon.EighthAttackName)
	{
		Follower.TestSlot.PlayCustomAnim('Attack8',1.f);
	}

	StartPokemonParticleComponent(currentSelectedBattlePokemon.pokemonAttackInventory[currentSelectedBattleAttack].attackDisplayName, enemyLocation, followerLocation, playerParticleRotation);
}

function StartEnemyPokemonAnimation()
{
	local Vector followerLocation,enemyLocation;
	local Rotator enemyParticleRotation;
	
	followerLocation  = Follower.Location;
	enemyLocation     = EnemyPokemon.Location;
	
	enemyParticleRotation = rotator(followerLocation - enemyLocation);
	
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.FirstAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack1',1.f);
	}
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.SecondAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack2',1.f);
	}
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.ThirdAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack3',1.f);
	}
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.FourthAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack4',1.f);
	}
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.FifthAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack5',1.f);
	}
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.SixthAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack6',1.f);
	}
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.SeventhAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack7',1.f);
	}
	if (EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName == EnemyPokemonDBInstance.EighthAttackName)
	{
		EnemyPokemon.TestSlot.PlayCustomAnim('Attack8',1.f);
	}

	StartPokemonParticleComponent(EnemyPokemonDBInstance.pokemonAttackInventory[currentEnemySelectedBattleAttack].attackDisplayName, followerLocation, enemyLocation, enemyParticleRotation);
}


function StartPokemonParticleComponent(String attackName, Vector targetLocation, Vector sourceLocation, Rotator spawnParticleRotation)
{
	if (attackName == "ThunderShock")
	{
		spawnedParticleComponents = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'THEGamePackage.PS_Thundershock', targetLocation, spawnParticleRotation);
	}
	if (attackName == "Growl")
	{
		spawnParticleRotation.pitch = spawnParticleRotation.pitch-90*DegToUnrRot;
		spawnedParticleComponents = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'THEGamePackage.PS_Growl', sourceLocation, spawnParticleRotation);
	}
}

function StopPokemonParticleComponent()
{
	spawnedParticleComponents.SecondsBeforeInactive=0;
    spawnedParticleComponents.DeactivateSystem();
    spawnedParticleComponents.KillParticlesForced();
}


defaultproperties
{
   wildLevelMultiplier=1.5
   CameraClass=class'THEGame.THEPlayerCamera'
   FollowerPawnClass=class'THEGame.THEPawn_NPC_Pikachu'
}