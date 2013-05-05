/**
 * Load and Save Game State Variables
 */

class THEGameState extends Object dependsOn(THEPokemon) dependsOn(THEAttack);

/**
 * struct used to cache the list of pokemon
 */
struct PokemonRecord
{
	var string pokemonName;
	var THEPokemon pokemon;
};

/**
 * Contains all known pokemon
 */
var array<PokemonRecord> pokemons;

/**
 * struct used to cache the list of attacks
 */
struct PokemonAttackRecord
{
	var string attackName;
	var THEAttack attack;
};

/**
 * Contains all known attacks
 */
var array<PokemonAttackRecord> attacks;

/**
 * Create a new character instance. None of it's fields have been initialized.
 * It is just created with a proper id, and not saved yet.
 *
 * @param charId
 *		Optionally character id to use. This must be unique.
 * @return The newly created character
 */
function THECharacter createCharacter(optional string charId = "Char_"$TimeStamp()$rand(100)$"_")
{
    // note: object names shouldn't end with a number
	local THECharacter char;
	charId -= " ";
	charId -= ":";
	charId -= "/";
	charId -= "-";
	char = new(none, charId) class'THECharacter';
	return char;
}

/**
 * Load a character using it's id
 *
 * @param charId
 *		The identifier for the character
 * @return The created character, or none if it could not be created/loaded
 */
function THECharacter loadCharacter(string charId)
{
	local THECharacter char;
	local THEPokemon pokemon;
	local THEPokemonInventory inv;
	local THEAttack attack;
	local THEAttackInventory atkinv;
	local int i,j;
	local array<string> chars;

	chars = getCharacters();
	if (chars.find(charId) == INDEX_NONE) return none;

	char = new(none, charId) class'THECharacter';
	if (char == none) return none;
    // load the pokemon inventory
	for (i = 0; i < char.pokemonInventoryRecords.length; ++i)
	{
		 inv = new(none, char.pokemonInventoryRecords[i]) class'THEPokemonInventory';
		 if (inv == none) continue;
		 pokemon = getPokemon(inv.pokemonDisplayName);
		 if (pokemon == none) continue;
		 inv.pokemon = pokemon;
		 char.pokemonInventory.addItem(inv);
	}
	for (i = 0; i < char.pokemonInventory.length; ++i)
	{
		for  (j = 0; j < char.pokemonInventory[i].pokemonAttackRecords.length; ++j)
		{
		    atkinv = new(none, char.pokemonInventory[i].pokemonAttackRecords[j]) class'THEAttackInventory';
			if (atkinv == none) continue;
			attack = getPokemonAttack(atkinv.attackDisplayName);
			if (attack == none) continue;
			atkinv.attack = attack;
			char.pokemonInventory[i].pokemonAttackInventory.addItem(atkinv);
		}
	}
	return char;
}

/**
 * Get a list of all existing character ids
 *
 * @return The list of character ids.
 */
function array<string> getCharacters()
{
	local array<string> res;
	local int i, idx;
	GetPerObjectConfigSections(class'THECharacter', res);
	// the result contains: "ObjectName ClassName" but we only need the ObjectNames
	for (i = 0; i < res.length; ++i)
	{
		idx = InStr(res[i], " ");
		if (idx != INDEX_NONE)
		{
			res[i] = left(res[i], idx);
		}
	}
	return res;
}

/**
 * Initialize the pokemon database
 */
function loadPokemonDB()
{
	local array<UDKUIResourceDataProvider> ProviderList;
	local int i;

	if (pokemons.length == 0)
	{
		// fill the list
		class'UDKUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'THEPokemon', ProviderList);
		pokemons.length = ProviderList.length;
		for (i = 0; i < ProviderList.length; ++i)
		{
			pokemons[i].pokemonName = string(ProviderList[i].name);
			pokemons[i].pokemon = THEPokemon(ProviderList[i]);
		}
	}
}

/**
 * Initialize the pokemon attack database
 */
function loadPokemonAttackDB()
{
	local array<UDKUIResourceDataProvider> ProviderList;
	local int i;

	if (attacks.length == 0)
	{
		// fill the list
		class'UDKUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'THEAttack', ProviderList);
		attacks.length = ProviderList.length;
		for (i = 0; i < ProviderList.length; ++i)
		{
			attacks[i].attackName = string(ProviderList[i].name);
			attacks[i].attack = THEAttack(ProviderList[i]);
		}
	}
}

/**
 * Get THEPokemon instance for a given name
 *
 * @param pokemonName
 *		The name of the pokemon
 * @return THEPokemon instance, or none
 */
function THEPokemon getPokemon(String pokemonName)
{
	local int i;
	loadPokemonDB();

	i = pokemons.find('pokemonName', pokemonName);
	if (i != INDEX_NONE)
	{
		return pokemons[i].pokemon;
	}
	return none;
}

/**
 * Create a new pokemoninventory pokemon, ie, starter or just caught a new one.
 *
 * @param fromPokemon
 *		The pokemon to create an inventory pokemon from
 * @return
 *		The inventory pokemon which can be added to the character
 */
function THEPokemonInventory createPokemonInventory(THEPokemon fromPokemon)
{
	local string invId;
	local THEPokemonInventory inv;

    // note: object names shouldn't end with a number
	invId = string(fromPokemon.name)$"_"$TimeStamp()$rand(100)$"_";
	invId -= " ";
	invId -= ":";
	invId -= "/";
	invId -= "-";
	inv = new(none, invId) class'THEPokemonInventory';
	inv.pokemonSpecies      = fromPokemon.species;
	inv.pokemonDisplayName  = fromPokemon.species;
	inv.pokemonDexNumber    = fromPokemon.pokemonDexNumber;
	inv.pokemonType         = fromPokemon.pokemonType;
	inv.evolutionSpecies    = fromPokemon.evolutionSpecies;
	inv.evolutionLevel      = fromPokemon.evolutionLevel;
	inv.inPlayerParty       = false;
	inv.isFainted           = false;
	inv.Level               = 1;
	
	inv.paralyzed           = false;
	inv.confused            = false;
	
	//experience type can be slow, mediumslow, mediumfast, fast
	inv.currentExperience   = 0;
	inv.experienceType      = fromPokemon.experienceType;
	inv.experienceYield     = fromPokemon.experienceYield;

	//used to determine EVs gained if this is an enemy
	inv.EVHP                = fromPokemon.EVHP;
	inv.EVAttack            = fromPokemon.EVAttack;
	inv.EVDefense           = fromPokemon.EVDefense;
	inv.EVSpAttack          = fromPokemon.EVSpAttack;
	inv.EVSpDefense         = fromPokemon.EVSpDefense;
	inv.EVSpeed             = fromPokemon.EVSpeed;
	
	//used to store EVs gained from enemies
	inv.currentEVHP                = 0;
	inv.currentEVAttack            = 0;
	inv.currentEVDefense           = 0;
	inv.currentEVSpAttack          = 0;
	inv.currentEVSpDefense         = 0;
	inv.currentEVSpeed             = 0;
    
	//Individual values
    inv.IVHP                = Rand(16);
	inv.IVAttack            = Rand(16);
	inv.IVDefense           = Rand(16);
	inv.IVSpeed             = Rand(16);
	inv.IVSpecial           = Rand(16);
	
	inv.catchRate           = fromPokemon.catchRate;
	
	//Should not change
	inv.BaseHP              = fromPokemon.BaseHP;
	inv.BaseAttack          = fromPokemon.BaseAttack;
	inv.BaseDefense         = fromPokemon.BaseDefense;
	inv.BaseSpAtk           = fromPokemon.BaseSpAtk;
	inv.BaseSpDef           = fromPokemon.BaseSPDef;
	inv.BaseSpeed           = fromPokemon.BaseSpeed;
	
	//Reset after each battle
	inv.Evasion             = 1;
	inv.Accuracy            = 1;
	inv.critStat            = 512;
	
	//Really shitty method..
	inv.FirstAttackLevel    = fromPokemon.FirstAttackLevel;
	inv.FirstAttackName     = fromPokemon.FirstAttackName;
	inv.SecondAttackLevel   = fromPokemon.SecondAttackLevel;
	inv.SecondAttackName    = fromPokemon.SecondAttackName;
	inv.ThirdAttackLevel    = fromPokemon.ThirdAttackLevel;
	inv.ThirdAttackName     = fromPokemon.ThirdAttackName;
	inv.FourthAttackLevel   = fromPokemon.FourthAttackLevel;
	inv.FourthAttackName    = fromPokemon.FourthAttackName;
	inv.FifthAttackLevel    = fromPokemon.FifthAttackLevel;
	inv.FifthAttackName     = fromPokemon.FifthAttackName;
	inv.SixthAttackLevel    = fromPokemon.SixthAttackLevel;
	inv.SixthAttackName     = fromPokemon.SixthAttackName;
	inv.SeventhAttackLevel  = fromPokemon.SeventhAttackLevel;
	inv.SeventhAttackName   = fromPokemon.SeventhAttackName;
	inv.EighthAttackLevel   = fromPokemon.EighthAttackLevel;
	inv.EighthAttackName    = fromPokemon.EighthAttackName;
	
	//Re-calculate these after leveling or evolution or battling
	inv.AttackStat          = (inv.IVAttack  + inv.BaseAttack  + 50)/50+5;
	inv.DefenseStat         = (inv.IVDefense + inv.BaseDefense + 50)/50+5;
	inv.SpAtkStat           = (inv.IVSpecial + inv.BaseSpAtk   + 50)/50+5;
	inv.SPDefStat           = (inv.IVSpecial + inv.BaseSpDef   + 50)/50+5;
	inv.SpeedStat           = (inv.IVSpeed   + inv.BaseSpeed   + 50)/50+5;
	inv.maxHitPoints        = (inv.IVHP + inv.BaseHP + 50)/50+10;
	
	inv.currentHitPoints    = inv.maxHitPoints;
	return inv;
}

/**
 * Create a new pokemonAttackInventory attack.
 *
 * @param fromAttack
 *		The attack to create an inventory attack from
 * @return
 *		The inventory attack which can be added to the character
 */
function THEAttackInventory createPokemonAttackInventory(THEAttack fromAttack)
{
	local string invId;
	local THEAttackInventory inv;

    // note: object names shouldn't end with a number
	invId = string(fromAttack.name)$"_"$TimeStamp()$rand(100)$"_";
	invId -= " ";
	invId -= ":";
	invId -= "/";
	invId -= "-";
	inv = new(none, invId) class'THEAttackInventory';
	inv.attackDisplayName = fromAttack.DisplayName;
	inv.powerPoints       = fromAttack.powerPoints;
	inv.maxPowerPoints    = fromAttack.powerPoints;
	inv.power             = fromAttack.power;
	inv.accuracy          = fromAttack.accuracy;
	inv.attackType        = fromAttack.attackType;
	//stat effects
    inv.stageName         = fromAttack.stageName;
    inv.stageMag          = fromAttack.stageMag;
	inv.stageAffectPlayer = fromAttack.stageAffectPlayer;
	//status ailments
    inv.extraEffect       = fromAttack.extraEffect;
    inv.extraEffectMag    = fromAttack.extraEffectMag;
	//battle turn priority
	inv.attackPriority    = fromAttack.attackPriority;
	return inv;
}

/**
 * Get THEAttack instance for a given name
 *
 * @param attackName
 *		The name of the attack
 * @return THEPokemon instance, or none
 */
function THEAttack getPokemonAttack(String attackName)
{
	local int i;
	loadPokemonAttackDB();

	i = attacks.find('attackName', attackName);
	if (i != INDEX_NONE)
	{
		return attacks[i].attack;
	}
	return none;
}
