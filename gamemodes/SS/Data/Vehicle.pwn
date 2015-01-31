#include <YSI\y_hooks>



hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Data/Vehicle'...");
	// Todo: Move this to "Server/Init.pwn"
}




#endinput

#define loot_InvalidLoot -1
#define MAX_VEHICLE_GROUP (13)


enum
{
	VEHICLE_GROUP_CASUAL,			// 0
	VEHICLE_GROUP_TRUCK_L,			// 1
	VEHICLE_GROUP_TRUCK_S,			// 2
	VEHICLE_GROUP_SPORT,			// 3
	VEHICLE_GROUP_BIKE,				// 4
	VEHICLE_GROUP_MILITARY,			// 5
	VEHICLE_GROUP_POLICE,			// 6
	VEHICLE_GROUP_PLANE_L,			// 7
	VEHICLE_GROUP_PLANE_S,			// 8
	VEHICLE_GROUP_HELI_L,			// 9
	VEHICLE_GROUP_HELI_S,			// 10
	VEHICLE_GROUP_BOAT,				// 11
	VEHICLE_GROUP_UNIQUE			// 12
}

new VehicleGroupNames[MAX_VEHICLE_GROUP][24]=
{		
	"VEHICLE_GROUP_CASUAL",			// 0
	"VEHICLE_GROUP_TRUCK_L",		// 1
	"VEHICLE_GROUP_TRUCK_S",		// 2
	"VEHICLE_GROUP_SPORT",			// 3
	"VEHICLE_GROUP_BIKE",			// 4
	"VEHICLE_GROUP_MILITARY",		// 5
	"VEHICLE_GROUP_POLICE",			// 6
	"VEHICLE_GROUP_PLANE_L",		// 7
	"VEHICLE_GROUP_PLANE_S",		// 8
	"VEHICLE_GROUP_HELI_L",			// 9
	"VEHICLE_GROUP_HELI_S",			// 10
	"VEHICLE_GROUP_BOAT",			// 11
	"VEHICLE_GROUP_UNIQUE"			// 12
};


enum E_VEHICLE_TYPE_DATA
{
Float:	veh_maxFuel,
Float:	veh_fuelCons,
		veh_lootIndex,
		veh_trunkSize,
Float:	veh_spawnRate,
		veh_group
}


new const VehicleFuelData[212][E_VEHICLE_TYPE_DATA] =
{
	{90.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 400		----	Landstalker
	{40.0,	11.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 401		----	Bravura
	{60.0,	15.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 402		----	Buffalo
	{120.0,	60.0,	loot_CarIndustrial,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 403		----	Linerunner
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 404		----	Pereniel
	{50.0,	14.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 405		----	Sentinel
	{40.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 406		----	Dumper
	{70.0,	22.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_UNIQUE},		// 407		----	Firetruck
	{70.0,	4.0,	loot_CarCivilian,		24,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 408		----	Trashmaster
	{50.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 409		----	Stretch

	{40.0,	9.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 410		----	Manana
	{50.0,	18.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 411		----	Infernus
	{50.0,	17.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 412		----	Voodoo
	{50.0,	15.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 413		----	Pony
	{50.0,	24.0,	loot_CarIndustrial,		20,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 414		----	Mule
	{60.0,	15.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 415		----	Cheetah
	{80.0,	13.0,	loot_Medical,			16,		1.0,	VEHICLE_GROUP_UNIQUE},		// 416		----	Ambulance
	{1600.0,143.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_HELI_L},		// 417		----	Leviathan
	{60.0,	18.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 418		----	Moonbeam
	{55.0,	17.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 419		----	Esperanto

	{55.0,	12.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 420		----	Taxi
	{50.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 421		----	Washington
	{60.0,	16.0,	loot_CarIndustrial,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 422		----	Bobcat
	{60.0,	17.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 423		----	Mr Whoopee
	{40.0,	8.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 424		----	BF Injection
	{1421.0,441.0,	loot_InvalidLoot,		0,		0.01,	VEHICLE_GROUP_HELI_L},		// 425		----	Hunter
	{55.0,	12.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 426		----	Premier
	{90.0,	36.0,	loot_CarPolice,			12,		0.5,	VEHICLE_GROUP_POLICE},		// 427		----	Enforcer
	{90.0,	31.0,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 428		----	Securicar
	{40.0,	18.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 429		----	Banshee

	{70.0,	31.0,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_BOAT},		// 430		----	Predator
	{70.0,	24.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 431		----	Bus
	{1900.0,392.0,	loot_CarMilitary,		10,		0.01,	VEHICLE_GROUP_MILITARY},	// 432		----	Rhino
	{200.0,	77.0,	loot_CarMilitary,		22,		0.4,	VEHICLE_GROUP_MILITARY},	// 433		----	Barracks
	{50.0,	8.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 434		----	Hotknife
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 435		----	Trailer
	{35.0,	8.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 436		----	Previon
	{70.0,	24.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 437		----	Coach
	{60.0,	17.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 438		----	Cabbie
	{45.0,	14.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 439		----	Stallion

	{55.0,	19.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 440		----	Rumpo
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 441		----	RC Bandit
	{35.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 442		----	Romero
	{60.0,	34.0,	loot_CarIndustrial,		14,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 443		----	Packer
	{80.0,	48.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 444		----	Monster
	{35.0,	10.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 445		----	Admiral
	{50.0,	31.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 446		----	Squalo
	{80.0,	46.0,	loot_CarCivilian,		6,		0.1,	VEHICLE_GROUP_HELI_S},		// 447		----	Seasparrow
	{8.0,	3.0,	loot_CarCivilian,		6,		1.0,	VEHICLE_GROUP_BIKE},		// 448		----	Pizzaboy
	{0.0,	0.0,	loot_CarCivilian,		10,		1.0,	VEHICLE_GROUP_UNIQUE},		// 449		----	Tram

	{0.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 450		----	Trailer
	{50.0,	25.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 451		----	Turismo
	{60.0,	30.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 452		----	Speeder
	{60.0,	34.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 453		----	Reefer
	{60.0,	36.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 454		----	Tropic
	{70.0,	69.0,	loot_CarIndustrial,		24,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 455		----	Flatbed
	{60.0,	45.0,	loot_CarIndustrial,		20,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 456		----	Yankee
	{10.0,	4.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 457		----	Caddy
	{40.0,	14.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 458		----	Solair
	{40.0,	16.0,	loot_CarIndustrial,		20,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 459		----	Berkley's RC Van

	{102.0,	11.0,	loot_CarCivilian,		8,		0.1,	VEHICLE_GROUP_PLANE_S},		// 460		----	Skimmer
	{18.0,	6.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BIKE},		// 461		----	PCJ-600
	{8.0,	3.0,	loot_CarCivilian,		6,		1.0,	VEHICLE_GROUP_BIKE},		// 462		----	Faggio
	{19.0,	5.0,	loot_Survivor,			14,		1.0,	VEHICLE_GROUP_BIKE},		// 463		----	Freeway
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 464		----	RC Baron
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 465		----	RC Raider
	{45.0,	11.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 466		----	Glendale
	{45.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 467		----	Oceanic
	{10.0,	6.0,	loot_CarCivilian,		8,		1.0,	VEHICLE_GROUP_BIKE},		// 468		----	Sanchez
	{190.0,	68.0,	loot_CarIndustrial,		6,		0.3,	VEHICLE_GROUP_HELI_S},		// 469		----	Sparrow

	{94.0,	26.0,	loot_CarMilitary,		12,		1.0,	VEHICLE_GROUP_MILITARY},	// 470		----	Patriot
	{9.0,	13.0,	loot_CarCivilian,		8,		1.0,	VEHICLE_GROUP_BIKE},		// 471		----	Quad
	{60.0,	28.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_BOAT},		// 472		----	Coastguard
	{81.0,	27.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 473		----	Dinghy
	{40.0,	16.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 474		----	Hermes
	{60.0,	15.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 475		----	Sabre
	{88.0,	19.0,	loot_CarCivilian,		6,		0.2,	VEHICLE_GROUP_PLANE_S},		// 476		----	Rustler
	{50.0,	14.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 477		----	ZR 350
	{60.0,	26.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 478		----	Walton
	{55.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 479		----	Regina

	{50.0,	12.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 480		----	Comet
	{0.0,	0.0,	loot_InvalidLoot,		0,		1.0,	VEHICLE_GROUP_BIKE},		// 481		----	BMX
	{70.0,	13.0,	loot_CarIndustrial,		20,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 482		----	Burrito
	{80.0,	26.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 483		----	Camper
	{900.0,	67.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 484		----	Marquis
	{24.0,	4.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 485		----	Baggage
	{50.0,	47.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 486		----	Dozer
	{240.0,	76.0,	loot_CarCivilian,		12,		0.2,	VEHICLE_GROUP_HELI_S},		// 487		----	Maverick
	{240.0,	76.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_HELI_S},		// 488		----	News Chopper
	{110.0,	16.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 489		----	Rancher

	{110.0,	18.0,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_POLICE},		// 490		----	FBI Rancher
	{45.0,	11.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 491		----	Virgo
	{55.0,	12.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 492		----	Greenwood
	{90.0,	21.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 493		----	Jetmax
	{80.0,	28.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 494		----	Hotring
	{120.0,	31.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 495		----	Sandking
	{40.0,	12.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 496		----	Blista Compact
	{240.0,	76.0,	loot_CarCivilian,		12,		0.05,	VEHICLE_GROUP_HELI_S},		// 497		----	Police Maverick
	{75.0,	19.0,	loot_CarIndustrial,		24,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 498		----	Boxville
	{70.0,	19.0,	loot_CarIndustrial,		24,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 499		----	Benson

	{77.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 500		----	Mesa
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 501		----	RC Goblin
	{80.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 502		----	Hotring Racer A
	{80.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 503		----	Hotring Racer B
	{65.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 504		----	Bloodring Banger
	{70.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 505		----	Rancher
	{50.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 506		----	Super GT
	{35.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 507		----	Elegant
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 508		----	Journey
	{0.0,	13.0,	loot_InvalidLoot,		0,		1.0,	VEHICLE_GROUP_BIKE},		// 509		----	Bike

	{0.0,	13.0,	loot_CarCivilian,		1,		1.0,	VEHICLE_GROUP_BIKE},		// 510		----	Mountain Bike
	{250.0,	29.0,	loot_CarCivilian,		10,		0.2,	VEHICLE_GROUP_PLANE_L},		// 511		----	Beagle
	{79.0,	16.0,	loot_CarCivilian,		6,		0.1,	VEHICLE_GROUP_PLANE_S},		// 512		----	Cropdust
	{55.0,	14.0,	loot_CarCivilian,		6,		0.3,	VEHICLE_GROUP_PLANE_S},		// 513		----	Stunt
	{190.0,	13.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 514		----	Tanker
	{210.0,	13.0,	loot_CarIndustrial,		14,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 515		----	RoadTrain
	{35.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 516		----	Nebula
	{35.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 517		----	Majestic
	{40.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 518		----	Buccaneer
	{340.0,	43.0,	loot_CarCivilian,		16,		0.1,	VEHICLE_GROUP_PLANE_L},		// 519		----	Shamal

	{7790.0,333.9,	loot_InvalidLoot,		0,		0.01,	VEHICLE_GROUP_PLANE_L},		// 520		----	Hydra
	{45.0,	13.0,	loot_CarCivilian,		6,		0.9,	VEHICLE_GROUP_BIKE},		// 521		----	FCR-900
	{45.0,	13.0,	loot_CarCivilian,		6,		0.5,	VEHICLE_GROUP_BIKE},		// 522		----	NRG-500
	{60.0,	13.0,	loot_CarPolice,			8,		0.8,	VEHICLE_GROUP_BIKE},		// 523		----	HPV1000
	{60.0,	13.0,	loot_CarIndustrial,		10,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 524		----	Cement Truck
	{50.0,	13.0,	loot_CarIndustrial,		16,		0.0,	VEHICLE_GROUP_TRUCK_S},		// 525		----	Tow Truck
	{45.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 526		----	Fortune
	{30.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 527		----	Cadrona
	{80.0,	13.0,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_POLICE},		// 528		----	FBI Truck
	{50.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 529		----	Willard

	{25.0,	13.0,	loot_CarCivilian,		6,		0.0,	VEHICLE_GROUP_TRUCK_S},		// 530		----	Forklift
	{50.0,	13.0,	loot_CarCivilian,		14,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 531		----	Tractor
	{60.0,	13.0,	loot_InvalidLoot,		0,		1.0,	VEHICLE_GROUP_UNIQUE},		// 532		----	Combine
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 533		----	Feltzer
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 534		----	Remington
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 535		----	Slamvan
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 536		----	Blade
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 537		----	Freight
	{110.0,	18.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 538		----	Streak
	{60.0,	13.0,	loot_CarCivilian,		6,		1.0,	VEHICLE_GROUP_BOAT},		// 539		----	Vortex

	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 540		----	Vincent
	{50.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 541		----	Bullet
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 542		----	Clover
	{60.0,	13.0,	loot_CarCivilian,		16,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 543		----	Sadler
	{70.0,	13.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_UNIQUE},		// 544		----	Firetruck
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 545		----	Hustler
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 546		----	Intruder
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 547		----	Primo
	{2000.0,341.0,	loot_CarMilitary,		24,		0.1,	VEHICLE_GROUP_HELI_L},		// 548		----	Cargobob
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 549		----	Tampa

	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 550		----	Sunrise
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 551		----	Merit
	{60.0,	13.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 552		----	Utility
	{3046.0,118.3,	loot_CarIndustrial,		24,		0.2,	VEHICLE_GROUP_PLANE_L},		// 553		----	Nevada
	{60.0,	13.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 554		----	Yosemite
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 555		----	Windsor
	{40.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 556		----	Monster A
	{40.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 557		----	Monster B
	{50.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 558		----	Uranus
	{50.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 559		----	Jester

	{60.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 560		----	Sultan
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 561		----	Stratum
	{60.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 562		----	Elegy
	{200.0,	13.0,	loot_CarCivilian,		12,		0.08,	VEHICLE_GROUP_HELI_L},		// 563		----	Raindance
	{0.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 564		----	RC Tiger
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 565		----	Flash
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 566		----	Tahoma
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 567		----	Savanna
	{60.0,	13.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_TRUCK_S},		// 568		----	Bandito
	{200.0,	20.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 569		----	Freight

	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 570		----	Trailer
	{20.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 571		----	Kart
	{20.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 572		----	Mower
	{248.0,	35.0,	loot_CarCivilian,		16,		1.0,	VEHICLE_GROUP_UNIQUE},		// 573		----	Duneride
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 574		----	Sweeper
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 575		----	Broadway
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 576		----	Tornado
	{17900.0,319.6,	loot_CarIndustrial,		12,		0.1,	VEHICLE_GROUP_PLANE_L},		// 577		----	AT-400
	{60.0,	13.0,	loot_CarIndustrial,		24,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 578		----	DFT-30
	{70.0,	13.0,	loot_CarCivilian,		14,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 579		----	Huntley

	{67.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 580		----	Stafford
	{45.0,	12.0,	loot_CarCivilian,		6,		1.0,	VEHICLE_GROUP_BIKE},		// 581		----	BF-400
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 582		----	Newsvan
	{10.0,	4.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 583		----	Tug
	{0.0,	0.0,	loot_CarIndustrial,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 584		----	Trailer A
	{70.0,	12.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 585		----	Emperor
	{47.0,	8.0,	loot_Survivor,			16,		1.0,	VEHICLE_GROUP_BIKE},		// 586		----	Wayfarer
	{60.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 587		----	Euros
	{70.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 588		----	Hotdog
	{45.0,	13.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 589		----	Club

	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 590		----	Trailer B
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 591		----	Trailer C
	{193600.0,4360.4,loot_CarIndustrial,	24,		0.1,	VEHICLE_GROUP_PLANE_L},		// 592		----	Andromada
	{110.0,	27.0,	loot_CarCivilian,		10,		0.3,	VEHICLE_GROUP_PLANE_S},		// 593		----	Dodo
	{0.0,	0.0,	loot_InvalidLoot,		0,		1.0,	VEHICLE_GROUP_UNIQUE},		// 594		----	RC Cam
	{213.0,	23.0,	loot_CarMilitary,		12,		1.0,	VEHICLE_GROUP_BOAT},		// 595		----	Launch
	{78.0,	12.5,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_POLICE},		// 596		----	Police Car (LSPD)
	{70.0,	13.0,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_POLICE},		// 597		----	Police Car (SFPD)
	{75.0,	12.0,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_POLICE},		// 598		----	Police Car (LVPD)
	{110.0,	15.0,	loot_CarPolice,			12,		1.0,	VEHICLE_GROUP_POLICE},		// 599		----	Police Ranger

	{86.0,	14.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 600		----	Picador
	{90.0,	16.0,	loot_CarMilitary,		12,		0.4,	VEHICLE_GROUP_POLICE},		// 601		----	S.W.A.T. Van
	{73.0,	14.0,	loot_CarCivilian,		12,		0.1,	VEHICLE_GROUP_SPORT},		// 602		----	Alpha
	{65.0,	14.5,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 603		----	Phoenix
	{68.0,	15.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_CASUAL},		// 604		----	Glendale
	{78.0,	19.0,	loot_CarCivilian,		16,		1.0,	VEHICLE_GROUP_TRUCK_S},		// 605		----	Sadler
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 606		----	Luggage Trailer A
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 607		----	Luggage Trailer B
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 608		----	Stair Trailer
	{79.0,	20.0,	loot_CarIndustrial,		16,		1.0,	VEHICLE_GROUP_TRUCK_L},		// 609		----	Boxville

	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE},		// 610		----	Farm Plow
	{0.0,	0.0,	loot_CarCivilian,		12,		1.0,	VEHICLE_GROUP_UNIQUE}		// 611		----	Utility Trailer
};

GetVehicleGroupFromName(name[])
{
	for(new i; i < MAX_VEHICLE_GROUP; i++)
	{
		if(!strcmp(name, VehicleGroupNames[i]))
			return i;
	}

	printf("ERROR: Returning vehicle group from '%s", name);

	return -1;
}
