/**
* TheCharacter defines the specific game save character that the player created or will create.
*/

class THECharacter extends Object config(THEGameState) perobjectconfig;

 /**
 * The name of the character
 */
var config string CharacterName;

var config int characterBerries;

/**
 * The identifiers of the inventory pokemons.
 */
var config array<string> pokemonInventoryRecords;

/**
 * The instantiated pokemon inventory
 */
var array<THEPokemonInventory> pokemonInventory;

/**
 * Save this character. Do not use SaveConfig() to save
 * the character, because it won't save its inventory.
 */
function save()
{
	local int i,j;
	//
	for (i = 0; i < pokemonInventory.Length; i++)
	{
		for (j = 0; j < pokemonInventory[i].pokemonAttackInventory.Length; j++)
		{
		    pokemonInventory[i].pokemonAttackInventory[j].SaveConfig();
		}
		pokemonInventory[i].SaveConfig();
	}
	SaveConfig();
}

/**
 * Add a pokemon to the inventory
 *
 * @param pokemon
 *		The pokemon to add.
 * @return
 *		True if the pokemon was added
 */
function bool addPokemonInventory(THEPokemonInventory pokemon)
{
	local int i;
	i = pokemonInventory.find(pokemon);
	if (i != INDEX_NONE) return false;
	pokemonInventory.addItem(pokemon);
	pokemonInventoryRecords.addItem(string(pokemon.name));
	return true;
}

/**
 * Remove a pokemon from the inventory by species, which works because only one per species is allowed by owner.
 * @param pokemon
 *		The pokemon to remove
 * @return
 *		True if the pokemon was removed
 */
function bool removePokemonInventory(String species)
{
	local int i;
	local THEPokemonInventory inv;
	for (i = 0; i < pokemonInventory.Length; i++)
	{
		if (pokemonInventory[i].pokemonSpecies ~= species) 
		{
			inv=pokemonInventory[i];
			pokemonInventory.removeItem(inv);
			pokemonInventoryRecords.removeItem(string(inv.name));
			return true;
		}
	}
	return false;
}

/**
 * Check to see if character already has one of this species.
 * @param species
 *		The pokemon species to check
 * @return
 *		True if the character already has one of this species
 */
function bool checkPokemonInventorySpecies(String species)
{
    local int i;
	for (i = 0; i < pokemonInventory.Length; i++)
	{
		if (pokemonInventory[i].pokemonSpecies ~= species) return true;
	}
	return false;
}

/**
 * Check to see if pokemon alread has an attack.
 * @param species
 *		The pokemon species to check
 * @param attack
 *		The pokemon attack to check
 * @return
 *		True if the pokemon already has this attack.
 */
function bool checkPokemonInventoryAttack(String species, String attack)
{
    local int i,j;
	for (i = 0; i < pokemonInventory.Length; i++)
	{
		if (pokemonInventory[i].pokemonSpecies ~= species)
		{
			for (j = 0; j < pokemonInventory[i].pokemonAttackInventory.Length; j++)
			{
				if (pokemonInventory[i].pokemonAttackInventory[j].attackDisplayName ~= attack) return true;
			}
		}
	}
	return false;
}

/**
 * Add an attack to the specified pokemon species in the character's inventory.
 *
 * @param species
 *		The pokemon to add to.
 * @param attack
 *		The attack inventory object to add.
 * @return
 *		True if the attack was added, False most likely if the pokemon already has 4 attacks.  Remove one first.
 */
function bool addPokemonAttackInventory(String species, THEAttackInventory attack)
{
	local int i;
	for (i = 0; i < pokemonInventory.Length; i++)
	{
		if (pokemonInventory[i].pokemonSpecies ~= species) 
		{
		    if (pokemonInventory[i].pokemonAttackInventory.Length >= 4) return false;
			pokemonInventory[i].pokemonAttackInventory.addItem(attack);
			pokemonInventory[i].pokemonAttackRecords.addItem(string(attack.name));
			return true;
		}
	}
	return false;
}

/**
 * Remove an attack from the specified pokemon species in the character's inventory.
 *
 * @param species
 *		The pokemon to remove from.
 * @param attack
 *		The attack inventory object to remove.
 * @return
 *		True if the attack was added
 */
function bool removePokemonAttackInventory(String species, string attackName)
{
    local int i,j;
	local THEAttackInventory inv;
	for (i = 0; i < pokemonInventory.Length; i++)
	{
		if (pokemonInventory[i].pokemonSpecies ~= species) 
		{
			for (j = 0; j < pokemonInventory[i].pokemonAttackInventory.Length; j++)
			{
				if (pokemonInventory[i].pokemonAttackInventory[j].attackDisplayName ~= attackName) 
				{
			        inv=pokemonInventory[i].pokemonAttackInventory[j];
			        pokemonInventory[i].pokemonAttackInventory.removeItem(inv);
			        pokemonInventory[i].pokemonAttackRecords.removeItem(string(inv.name));
			        return true;
				}
			}
		}
	}
	return false;
}
