/**
 * A pokemon in the inventory of THECharacter.  An instance of THEPokemon.
 */
 
 class THEPokemonInventory extends Object config(THEGameState) perobjectconfig;

var config string pokemonSpecies;
var config string pokemonDisplayName;
var config string pokemonDexNumber;
var config string pokemonType;   
var config string evolutionSpecies;
var config int    evolutionLevel;
var config bool   inPlayerParty;
var config bool   isFainted;
var config int    Level;

var config bool paralyzed;
var config bool confused;

//experience type can be
var config int currentExperience;
var config string experienceType;
var config int experienceYield;

//used to determine EVs 
var config int EVHP;
var config int EVAttack;
var config int EVDefense;
var config int EVSpAttack;
var config int EVSpDefense;
var config int EVSpeed;

//used to store EVs gain
var config int currentEVHP;
var config int currentEVAttack;
var config int currentEVDefense;
var config int currentEVSpAttack;
var config int currentEVSpDefense;
var config int currentEVSpeed;

//Individual values
var config int IVHP;
var config int IVAttack;
var config int IVDefense;
var config int IVSpeed;
var config int IVSpecial;

var config int catchRate;

//Should not change
var config int BaseHP;
var config int BaseAttack;
var config int BaseDefense;
var config int BaseSpAtk;
var config int BaseSpDef;
var config int BaseSpeed;

//Reset after each battle
var config float evasion;
var config float accuracy;
var config float critStat;

//Really shitty method..
var config int FirstAttackLevel;  
var config string FirstAttackName;  
var config int SecondAttackLevel;  
var config string SecondAttackName;  
var config int ThirdAttackLevel;  
var config string ThirdAttackName;  
var config int FourthAttackLevel;  
var config string FourthAttackName;  
var config int FifthAttackLevel;  
var config string FifthAttackName;  
var config int SixthAttackLevel;  
var config string SixthAttackName;  
var config int SeventhAttackLevel;  
var config string SeventhAttackName;  
var config int EighthAttackLevel;  
var config string EighthAttackName;  

//Re-calculate these after evolving or leveling or battling
var config float AttackStat;
var config float DefenseStat;
var config float SpAtkStat;
var config float SpDefStat;
var config float SpeedStat;
var config int maxHitPoints;

var config int currentHitPoints;

var THEPokemon pokemon;

/**
 * The identifiers of the pokemon's attacks.
 */
var config array<string> pokemonAttackRecords;

/**
 * The instantiated pokemon attack inventory
 */
var array<THEAttackInventory> pokemonAttackInventory;