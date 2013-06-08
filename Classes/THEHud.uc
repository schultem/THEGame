class THEHUD extends MobileHUD;

var THEPlayerController ThePlayerController;
var int R,G,B;

//Used to count the amount of hud clocks to display a status message, as well as fade them
var String enemyStatus;
var String playerStatus;
var int enemyStatusTimer;
var int playerStatusTimer;
var int statusDisplayTime;
var CanvasIcon titleIcon;

/******************************************************************
 * 
 * PostRender event
 * 
 * Use postRender function to define and call all hud drawing 
 * routine.
 * 
 * 
 ******************************************************************/
event PostRender()
{
    ThePlayerController = THEPlayerController(PlayerOwner);
	super.PostRender();
	DrawHUD();
}


function DrawHUD()
{
    local array<string> lowerchars;
	local array<string> upperchars;
	local array<string> optionList;
    super.DrawHUD();
	
	if(!ThePlayerController.bPressEscape)
	{
		//Draw status for items, etc
	    if (playerStatusTimer > 0 && !ThePlayerController.bInBattle)
	    {
	        playerStatusTimer--;
	    	DrawPlayerStatus(playerStatus);
	    }
		
	    if(ThePlayerController.bSelectCharacter)
	    {
	        lowerchars = ThePlayerController.returnChars();
			Canvas.DrawIcon(titleIcon, 0-(sizeX%1920)*1/4, 0-(sizeY%1080)*1/4);
			//DrawBlackScreen();
	    	DrawLowerBoxesWhite(3);
	    	DrawLowerStringNameList(lowerchars,3);
	    	//DrawTitle("Select Character");
	    	
	    }

	    if(ThePlayerController.bSelectBattlePokemon)
	    {
	        lowerchars = ThePlayerController.returnPokemonChars();
	        DrawWideScreen();
	    	DrawLowerBoxes(6);
	    	DrawLowerStringNameList(lowerchars,6);
	    	DrawTitle("Select Pokemon");
			if(ThePlayerController.bDisplayDistanceWarning)
		    {
		    	DrawTitle("Select Pokemon - You are too close, back up!");
		    }
			else
			{
			    DrawTitle("Select Pokemon");
			}
	    }
	    else
	    {
	        if(ThePlayerController.bInBattle) //and not selecting a different pokemon
	        { 
	    		//don't display or update any hud if animations are playing
	    		if (!ThePlayerController.bPlayBattleAnimations)
	    		{
	    	        upperchars = ThePlayerController.returnBattleChars();
	    		    DrawWideScreen();
	    		    DrawUpperStringNameList(upperchars);
	    		    DrawHitPoints();
	    		    
	    	        if (enemyStatusTimer > 0)
	                {
	                    enemyStatusTimer--;
	                	DrawEnemyStatus(enemyStatus);
	                }
	                if (playerStatusTimer > 0)
	                {
	                    playerStatusTimer--;
	                	DrawPlayerStatus(playerStatus);
	                }
	    		}
	    		else
	    		{
	    			DrawWideScreen();
	    		}
	        }
	    }
	    if(ThePlayerController.bPlayerPokemonVictory)
	    {
	    	DrawCenterBox();
	    	DrawCenterTitle("Battle Results:\n(Press any number to continue)");
	    	DrawCenterExp();
	    }
	    if(ThePlayerController.bPartyPokemonCanLearnNewMove)
	    {
	    	DrawSmallCenterBox();
	    	DrawCenterTitle("Battle Results:\n(Press any number to continue)");
	    	DrawPokemonWillLearnInfo();
	    }
	    if(ThePlayerController.bPartyPokemonReplaceMove)
	    {
	    	lowerchars = ThePlayerController.GetPokemonToLearnAttackList();
	    	lowerchars.addItem("Cancel");
	    	DrawLowerBoxes(5);
	    	DrawLowerStringNameList(lowerchars,5);
	    	DrawSmallCenterBox();
	    	DrawCenterTitle("Battle Results:\n(Press any number to continue)");
	    	DrawPokemonReplaceInfo();
	    }
	    if(ThePlayerController.bSelectBattleOption)
	    {
	    	optionList[0]="Fight!";
	    	optionList[1]="Select Pokemon";
	    	optionList[2]="Items";
	    	DrawLowerBoxes(3);
	    	DrawLowerStringNameList(optionList,3);
	    }
	    if(ThePlayerController.bSelectBattleAttack)
	    {
	        lowerchars = ThePlayerController.returnAttackChars();
	    	DrawLowerBoxes(4);
	    	DrawLowerStringNameList(lowerchars,4);
	    }
	    if(ThePlayerController.bSelectBattleItems)
	    {
	        lowerchars.Length=0;
	    	lowerchars.addItem("Berry ("$ThePlayerController.char.characterBerries$")");
	    	lowerchars.addItem("Pokeball ("$ThePlayerController.char.characterPokeballs$")");
	    	DrawLowerBoxes(4);
	    	DrawLowerStringNameList(lowerchars,4);
	    }
	    if(ThePlayerController.bAttemptToCatchWildPokemon)
	    {
	    	lowerchars.Length=0;
	    	lowerchars.addItem("Throw Pokeball");
	    	DrawLowerBoxes(1);
	    	DrawLowerStringNameList(lowerchars,1);
	    }
	    if(ThePlayerController.bCaughtWildPokemon)
	    {
	    	DrawSmallCenterBox();
	    	DrawCenterTitle("Battle Results:\n(Press any number to continue)");
	    	DrawPokemonCaughtInfo();
	    }
	    if(ThePlayerController.bPartyPokemonCanEvolve)
	    {
	    	lowerchars.Length=0;
	    	lowerchars.addItem("Allow");
	    	lowerchars.addItem("Deny");
	    	DrawSmallCenterBox();
	    	DrawPokemonEvolveInfo();
	    	DrawLowerBoxes(2);
	    	DrawLowerStringNameList(lowerchars,2);
	    }
	}
	else
	{
		if (!ThePlayerController.bGameOver)
		{
		    lowerchars.Length=0;
		    lowerchars.addItem("Keep playing");
		    lowerchars.addItem("Save Game");
	        lowerchars.addItem("Quit");
		    if(ThePlayerController.bSelectCharacter)
		    {
		    	Canvas.DrawIcon(titleIcon, 0-(sizeX%1920)*1/4, 0-(sizeY%1080)*1/4);
		    	DrawLowerBoxesWhite(3);
		    }
		    else
		    {
		    	DrawWideScreen();
		    	DrawLowerBoxes(3);
		    	DrawTitle("Pokemon Unreal");
		    }
	        DrawLowerStringNameList(lowerchars,3);
		}
		else
		{
			if(ThePlayerController.bGameOver)
	        {
		    	DrawBlackScreen();
	        	DrawTitle("All of your party has fainted - Press any number to quit");
	        }
		}
	}
}
 
function DrawPokemonEvolveInfo()
{
	Canvas.SetPos(SizeX/4+5,SizeY/5+5);
	Canvas.SetDrawColor(255,255,255,200);
	Canvas.Font = class'Engine'.static.GetLargeFont();
	Canvas.DrawText("Evolution");
	
	if (ThePlayerController.pokemonThatCanEvolve.Length>0)
	{
	    Canvas.SetPos(SizeX/4+5,SizeY/5+3*SizeY/(7*5)+15);
	    Canvas.SetDrawColor(255,255,255,200);
	    Canvas.Font = class'Engine'.static.GetLargeFont();
	    Canvas.DrawText(ThePlayerController.char.pokemonInventory[ThePlayerController.pokemonThatCanEvolve[ThePlayerController.pokemonThatCanEvolve.Length-1]].pokemonSpecies$" is trying to evolve!");
	}
}

function DrawCenterBox()
{
	Canvas.SetPos(SizeX/4,SizeY/5);
	Canvas.SetDrawColor(0,0,0,100);
	Canvas.DrawRect(SizeX/2,3*SizeY/5);
	
	Canvas.SetPos(SizeX/4,SizeY/5);
	Canvas.SetDrawColor(0,0,0,100);
	Canvas.DrawRect(SizeX/2,3*SizeY/(7*5));
}

function DrawSmallCenterBox()
{
	Canvas.SetPos(SizeX/4,SizeY/5);
	Canvas.SetDrawColor(0,0,0,100);
	Canvas.DrawRect(SizeX/2,2*3*SizeY/(7*5));
	
	Canvas.SetPos(SizeX/4,SizeY/5);
	Canvas.SetDrawColor(0,0,0,100);
	Canvas.DrawRect(SizeX/2,3*SizeY/(7*5));
}

function DrawSmallerCenterBox()
{
	Canvas.SetPos(SizeX/4,SizeY/5);
	Canvas.SetDrawColor(0,0,0,150);
	Canvas.DrawRect(SizeX/2,3*SizeY/(7*5));
}

function DrawCenterTitle(String titleString)
{
	Canvas.SetPos(SizeX/4+5,SizeY/5+5);
	Canvas.SetDrawColor(255,255,255,200);
	Canvas.Font = class'Engine'.static.GetLargeFont();
	Canvas.DrawText(titleString);
}

function DrawCenterExp()
{
	local int i,j,k;
	local float ratio;
	local int battlersLevelList[6];
	local float battlersLowerExpBound[6];
	local float battlersUpperExpBound[6];
	local float battlersCurrentExp[6];
	
	k=0;
	//Get current level for each pokemon in pokemonBattleParticipatedList
	for (i=0;i<ThePlayerController.char.pokemonInventory.Length;++i)
	{
		for (j=0; j<ArrayCount(ThePlayerController.pokemonBattleParticipatedList); ++j)
		{
			if (ThePlayerController.pokemonBattleParticipatedList[j] == ThePlayerController.char.pokemonInventory[i].pokemonSpecies)
			{
				//`log("j:"$j);
				//`log("ThePlayerController.pokemonBattleParticipatedList[j]:"$ThePlayerController.pokemonBattleParticipatedList[j]);
				battlersLevelList[j]=ThePlayerController.char.pokemonInventory[i].level;
				//`log("battlersLevelList:"$battlersLevelList[j]);
				battlersCurrentExp[j]=ThePlayerController.char.pokemonInventory[i].currentExperience;
				//`log("battlersCurrentExp:"$battlersCurrentExp[j]);
				battlersLowerExpBound[j]=ThePlayerController.GetSpeciesLowerExpBoundByLevel(ThePlayerController.pokemonBattleParticipatedList[j],battlersLevelList[j]);
				//`log("battlersLowerExpBound:"$battlersLowerExpBound[j]);
				battlersUpperExpBound[j]=ThePlayerController.GetSpeciesUpperExpBoundByLevel(ThePlayerController.pokemonBattleParticipatedList[j],battlersLevelList[j]);
				//`log("battlersUpperExpBound:"$battlersUpperExpBound[j]);
				k++;
			}
			if (ThePlayerController.pokemonBattleParticipatedList[j] == "")
			{
				break;
			}
		}
		if (k >= ArrayCount(ThePlayerController.pokemonBattleParticipatedList))
		{
			break;
		}
	}
	//Display it in order of pokemonBattleParticipatedList
	for(k=0;k<ArrayCount(ThePlayerController.pokemonBattleParticipatedList);++k)
	{
		if (ThePlayerController.pokemonBattleParticipatedList[k] == "")
		{
			break;
		}
		ratio = (battlersCurrentExp[k]-battlersLowerExpBound[k])/((battlersUpperExpBound[k]-battlersLowerExpBound[k]));
		//`log("current: "$battlersCurrentExp[k]$" lower: "$battlersLowerExpBound[k]$" upper: "$battlersUpperExpBound[k]$"ratio: "$ratio);
	    Canvas.SetPos(SizeX/4+160,SizeY/5+(k+1)*3*SizeY/(7*5)+10);
	    Canvas.SetDrawColor(0,50,220,80);
	    Canvas.DrawRect(SizeX/3,3*SizeY/(7*5)-10);
	    
	    Canvas.SetPos(SizeX/4+160,SizeY/5+(k+1)*3*SizeY/(7*5)+10);
	    Canvas.SetDrawColor(0,50,220,120);
	    Canvas.DrawRect((ratio*SizeX/3+1),3*SizeY/(7*5)-10);
		
		Canvas.SetPos(SizeX/4+5,SizeY/5+(k+1)*3*SizeY/(7*5)+5);
	    Canvas.SetDrawColor(255,255,255,200);
	    Canvas.Font = class'Engine'.static.GetLargeFont();
	    Canvas.DrawText(ThePlayerController.pokemonBattleParticipatedList[k]$"\nLevel "$battlersLevelList[k]);
	}
}

function DrawPokemonWillLearnInfo()
{
	Canvas.SetPos(SizeX/4+5,SizeY/5+3*SizeY/(7*5)+15);
	Canvas.SetDrawColor(255,255,255,200);
	Canvas.Font = class'Engine'.static.GetLargeFont();
	if (ThePlayerController.pokemonThatCanLearnNewMove.Length > 0)
	{
		Canvas.DrawText(ThePlayerController.pokemonThatCanLearnNewMove[ThePlayerController.pokemonThatCanLearnNewMove.Length-1].species$" will learn "$ThePlayerController.pokemonThatCanLearnNewMove[ThePlayerController.pokemonThatCanLearnNewMove.Length-1].attack);
	}
}

function DrawPokemonCaughtInfo()
{
	Canvas.SetPos(SizeX/4+5,SizeY/5+3*SizeY/(7*5)+15);
	Canvas.SetDrawColor(255,255,255,200);
	Canvas.Font = class'Engine'.static.GetLargeFont();
	Canvas.DrawText(ThePlayerController.EnemyPokemonDBInstance.pokemonSpecies$" has been added to your party!");

}

function DrawPokemonReplaceInfo()
{
	Canvas.SetPos(SizeX/4+5,SizeY/5+3*SizeY/(7*5)+15);
	Canvas.SetDrawColor(255,255,255,200);
	Canvas.Font = class'Engine'.static.GetLargeFont();
	if (ThePlayerController.pokemonThatCanLearnNewMove.Length > 0)
	{
		Canvas.DrawText(ThePlayerController.pokemonThatCanLearnNewMove[ThePlayerController.pokemonThatCanLearnNewMove.Length-1].species$": Choose an attack to replace with "$ThePlayerController.pokemonThatCanLearnNewMove[ThePlayerController.pokemonThatCanLearnNewMove.Length-1].attack);
	}
}

function DrawHitPoints()
{
    local array<float> hp;
	local float hpratio;
	local int i;
		
	//hp[0]=current hit points, hp[1]= max hit points
	hp = ThePlayerController.GetCurrentSelectedPokemonHP();
	CalculateHealthRGB(hp);

	hpratio=hp[0]/hp[1];
		
	for(i=0; i<(SizeX*hpratio/2); i=i+5)
	{
		Canvas.SetPos(0,0);
	    Canvas.SetDrawColor(R,G,B,30);
	    Canvas.DrawRect(i,18);
	}
	
	//hp[0]=current hit points, hp[1]= max hit points
	hp = ThePlayerController.GetCurrentOpponentHP();
	CalculateHealthRGB(hp);
	hpratio=hp[0]/hp[1];
	
	//Canvas.SetPos(SizeX-(SizeX*hpratio/2),0);
	//Canvas.SetDrawColor(R,G,B,30);
	//Canvas.DrawRect(SizeX/2,18);

	for(i=0; i<(SizeX*hpratio/2); i=i+5)
	{
		Canvas.SetPos(SizeX-i,0);
	    Canvas.SetDrawColor(R,G,B,30);
	    Canvas.DrawRect(SizeX/2,18);
	}
}

function CalculateHealthRGB(array<float> hp)
{
    local float hpratio,hpration;
	
	hpratio=hp[0]/hp[1];
	//complement
	hpration=1-hpratio;
	
    if (hpratio >0.75)
	{
	    R=0;
		G=int(255*hpratio);
		B=int(255*hpration);
	}
	if (hpratio >0.50 && hpratio <=0.75)
	{
	    R=0;
		G=int(255*hpratio);
		B=int(255*hpration);
	}
	if (hpratio >0.25 && hpratio <=0.50)
	{
	    R=int(255*hpration);
		G=int(255*hpratio);
		B=0;
	}
	if (hpratio <=0.25)
	{
	    R=int(255*hpration);
		G=0;
		B=int(255*hpratio);
	}
}

function DrawWideScreen()
{
    local int i;
	for(i=0; i<SizeY/6; i=i+5)
	{
	    //Upper
        Canvas.SetPos(0,0);
	    Canvas.SetDrawColor(0,0,0,10);
	    Canvas.DrawRect(SizeX,i);
        
	    //Lower
	    Canvas.SetPos(0,SizeY-i);
	    Canvas.SetDrawColor(0,0,0,10);
	    Canvas.DrawRect(SizeX,SizeY);
	}

}

function DrawBlackScreen()
{
	Canvas.SetPos(0,0);
	Canvas.SetDrawColor(0,0,0,170);
	Canvas.DrawRect(SizeX,SizeY);
}

Function DrawLowerBoxes(int numberOfBoxes)
{
    
    local int i,j;
    for(i=0;i<numberOfBoxes;i++)
	{
	    for(j=0; j<SizeX/numberOfBoxes; j=j+5)
	    {
	        Canvas.SetPos(i*sizeX/numberOfBoxes,6*sizeY/7);
	        Canvas.SetDrawColor(0,0,0,5);
	        Canvas.DrawRect(j,SizeY/8);
		}
	}
}

Function DrawLowerBoxesWhite(int numberOfBoxes)
{
    
    local int i,j;
    for(i=0;i<numberOfBoxes;i++)
	{
	    for(j=0; j<SizeX/numberOfBoxes; j=j+5)
	    {
	        Canvas.SetPos(i*sizeX/numberOfBoxes,6*sizeY/7);
	        Canvas.SetDrawColor(255,255,255,1);
	        Canvas.DrawRect(j,SizeY/8);
		}
	}
}

Function DrawUpperBoxes(int numberOfBoxes)
{
    
    local int i,j;
    for(i=0;i<numberOfBoxes;i++)
	{
	    for(j=0; j<SizeX/numberOfBoxes; j=j+5)
	    {
	        Canvas.SetPos(i*sizeX/numberOfBoxes+20,20);
	        Canvas.SetDrawColor(0,0,0,5);
	        Canvas.DrawRect(j,SizeY/7);
		}
	}
}

Function DrawLowerStringNameList(array<string> names, int numberOfBoxes)
{
    local int i;
    for(i=0;i<numberOfBoxes;i++)
	{
	    Canvas.SetPos(i*sizeX/numberOfBoxes+10,0.90*sizeY);
	    Canvas.SetDrawColor(255,255,255,200);
		Canvas.Font = class'Engine'.static.GetLargeFont();
		if (i < names.Length)
		{
	        Canvas.DrawText((i+1)$": "$names[i]);
		}
		else
		{
		    Canvas.DrawText((i+1)$": <Empty>");
		}
	}
}

Function DrawUpperStringNameList(array<string> names)
{
	Canvas.SetPos(20,30);
	Canvas.SetDrawColor(255,255,255,200);
	Canvas.Font = class'Engine'.static.GetLargeFont();
	Canvas.DrawText(names[0]);
	
	Canvas.SetPos(SizeX-250,30);
	Canvas.SetDrawColor(255,255,255,200);
	Canvas.Font = class'Engine'.static.GetLargeFont();
	Canvas.DrawText(names[1]);

	
}

Function DrawTitle(String title)
{
	//Displays a title
    Canvas.SetPos(20,50);
    Canvas.SetDrawColor(255,255,255,200);
    Canvas.Font = class'Engine'.static.GetLargeFont();
    Canvas.DrawText(title);
}

Function SetEnemyStatus(String status)
{
    if(enemyStatusTimer>0)
	{
	    enemyStatus=enemyStatus$"\n"$status;
	    enemyStatusTimer=statusDisplayTime;
	}
	else
	{
        enemyStatus=status;
	    enemyStatusTimer=statusDisplayTime;
	}
}

Function SetPlayerStatus(String status)
{
    if(playerStatusTimer>0)
	{
	    playerStatus=playerStatus$"\n"$status;
	    playerStatusTimer=statusDisplayTime;
	}
	else
	{
        playerStatus=status;
	    playerStatusTimer=statusDisplayTime;
	}
}

Function DrawEnemyStatus(String status)
{
    local float est,sdt;
	est=enemyStatusTimer;
	sdt=statusDisplayTime;
	
    Canvas.SetPos(SizeX-250,60);
    Canvas.SetDrawColor(255,255,255,int(200*(est/sdt)));
    Canvas.Font = class'Engine'.static.GetLargeFont();
    Canvas.DrawText(status);

}

Function DrawPlayerStatus(String status)
{
    local float pst,sdt;
	pst=playerStatusTimer;
	sdt=statusDisplayTime;

    Canvas.SetPos(80,60);
    Canvas.SetDrawColor(255,255,255,int(200*(pst/sdt)));
    Canvas.Font = class'Engine'.static.GetLargeFont();
    Canvas.DrawText(status);

}
 
defaultproperties
{
    statusDisplayTime=200
	playerStatusTimer=0
	titleIcon=(Texture=Texture2D'THEGamePackage.Textures.tmap_titlescreen') 
}