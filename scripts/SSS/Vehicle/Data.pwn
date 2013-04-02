#define loot_InvalidLoot -1

enum E_VEHICLE_DATA
{
Float:	veh_maxFuel,
Float:	veh_fuelCons,
		veh_lootIndex,
		veh_trunkSize
}


new const VehicleFuelData[212][E_VEHICLE_DATA] =
{
	{90.0,	13.0,	loot_CarCivilian,		12}, // 400		----	Landstalker
	{40.0,	11.0,	loot_CarCivilian,		12}, // 401		----	Bravura
	{60.0,	15.0,	loot_CarCivilian,		12}, // 402		----	Buffalo
	{120.0,	60.0,	loot_CarIndustrial,		12}, // 403		----	Linerunner
	{60.0,	13.0,	loot_CarCivilian,		12}, // 404		----	Pereniel
	{50.0,	14.0,	loot_CarCivilian,		12}, // 405		----	Sentinel
	{40.0,	13.0,	loot_CarCivilian,		12}, // 406		----	Dumper
	{70.0,	22.0,	loot_CarIndustrial,		16}, // 407		----	Firetruck
	{70.0,	4.0,	loot_CarCivilian,		24}, // 408		----	Trashmaster
	{50.0,	13.0,	loot_CarCivilian,		12}, // 409		----	Stretch

	{40.0,	9.0,	loot_CarCivilian,		12}, // 410		----	Manana
	{50.0,	18.0,	loot_CarCivilian,		12}, // 411		----	Infernus
	{50.0,	17.0,	loot_CarCivilian,		12}, // 412		----	Voodoo
	{50.0,	15.0,	loot_CarIndustrial,		16}, // 413		----	Pony
	{50.0,	24.0,	loot_CarIndustrial,		20}, // 414		----	Mule
	{60.0,	15.0,	loot_CarCivilian,		12}, // 415		----	Cheetah
	{80.0,	13.0,	loot_Medical,			16}, // 416		----	Ambulance
	{1600.0,143.0,	loot_CarCivilian,		12}, // 417		----	Leviathan
	{60.0,	18.0,	loot_CarCivilian,		12}, // 418		----	Moonbeam
	{55.0,	17.0,	loot_CarCivilian,		12}, // 419		----	Esperanto

	{55.0,	12.0,	loot_CarCivilian,		12}, // 420		----	Taxi
	{50.0,	13.0,	loot_CarCivilian,		12}, // 421		----	Washington
	{60.0,	16.0,	loot_CarIndustrial,		12}, // 422		----	Bobcat
	{60.0,	17.0,	loot_CarCivilian,		12}, // 423		----	Mr Whoopee
	{40.0,	8.0,	loot_CarCivilian,		12}, // 424		----	BF Injection
	{1421.0,441.0,	loot_InvalidLoot,		0},  // 425		----	Hunter
	{55.0,	12.0,	loot_CarCivilian,		12}, // 426		----	Premier
	{90.0,	36.0,	loot_CarPolice,			12}, // 427		----	Enforcer
	{90.0,	31.0,	loot_CarPolice,			12}, // 428		----	Securicar
	{40.0,	18.0,	loot_CarCivilian,		12}, // 429		----	Banshee

	{70.0,	31.0,	loot_CarPolice,			12}, // 430		----	Predator
	{70.0,	24.0,	loot_CarCivilian,		12}, // 431		----	Bus
	{1900.0,392.0,	loot_CarMilitary,		10}, // 432		----	Rhino
	{200.0,	77.0,	loot_CarMilitary,		22}, // 433		----	Barracks
	{50.0,	8.0,	loot_CarCivilian,		12}, // 434		----	Hotknife
	{0.0,	0.0,	loot_CarCivilian,		12}, // 435		----	Trailer
	{35.0,	8.0,	loot_CarCivilian,		12}, // 436		----	Previon
	{70.0,	24.0,	loot_CarCivilian,		12}, // 437		----	Coach
	{60.0,	17.0,	loot_CarCivilian,		12}, // 438		----	Cabbie
	{45.0,	14.0,	loot_CarCivilian,		12}, // 439		----	Stallion

	{55.0,	19.0,	loot_CarIndustrial,		16}, // 440		----	Rumpo
	{0.0,	0.0,	loot_CarCivilian,		12}, // 441		----	RC Bandit
	{35.0,	13.0,	loot_CarCivilian,		12}, // 442		----	Romero
	{60.0,	34.0,	loot_CarIndustrial,		14}, // 443		----	Packer
	{80.0,	48.0,	loot_CarCivilian,		12}, // 444		----	Monster
	{35.0,	10.0,	loot_CarCivilian,		12}, // 445		----	Admiral
	{50.0,	31.0,	loot_CarCivilian,		12}, // 446		----	Squalo
	{80.0,	46.0,	loot_CarCivilian,		12}, // 447		----	Seasparrow
	{8.0,	3.0,	loot_CarCivilian,		6},  // 448		----	Pizzaboy
	{0.0,	0.0,	loot_CarCivilian,		10}, // 449		----	Tram

	{0.0,	13.0,	loot_CarCivilian,		12}, // 450		----	Trailer
	{50.0,	25.0,	loot_CarCivilian,		12}, // 451		----	Turismo
	{60.0,	30.0,	loot_CarCivilian,		12}, // 452		----	Speeder
	{60.0,	34.0,	loot_CarCivilian,		12}, // 453		----	Reefer
	{60.0,	36.0,	loot_CarCivilian,		12}, // 454		----	Tropic
	{70.0,	69.0,	loot_CarIndustrial,		24}, // 455		----	Flatbed
	{60.0,	45.0,	loot_CarIndustrial,		20}, // 456		----	Yankee
	{10.0,	4.0,	loot_CarCivilian,		12}, // 457		----	Caddy
	{40.0,	14.0,	loot_CarCivilian,		12}, // 458		----	Solair
	{40.0,	16.0,	loot_CarIndustrial,		20}, // 459		----	Berkley's RC Van

	{102.0,	11.0,	loot_CarCivilian,		8},  // 460		----	Skimmer
	{18.0,	6.0,	loot_CarCivilian,		12}, // 461		----	PCJ-600
	{8.0,	3.0,	loot_CarCivilian,		6},  // 462		----	Faggio
	{19.0,	5.0,	loot_Survivor,			14}, // 463		----	Freeway
	{0.0,	0.0,	loot_CarCivilian,		12}, // 464		----	RC Baron
	{0.0,	0.0,	loot_CarCivilian,		12}, // 465		----	RC Raider
	{45.0,	11.0,	loot_CarCivilian,		12}, // 466		----	Glendale
	{45.0,	13.0,	loot_CarCivilian,		12}, // 467		----	Oceanic
	{10.0,	6.0,	loot_CarCivilian,		8},  // 468		----	Sanchez
	{190.0,	68.0,	loot_CarIndustrial,		16}, // 469		----	Sparrow

	{94.0,	26.0,	loot_CarMilitary,		12}, // 470		----	Patriot
	{9.0,	13.0,	loot_CarCivilian,		8},  // 471		----	Quad
	{60.0,	28.0,	loot_CarIndustrial,		16}, // 472		----	Coastguard
	{81.0,	27.0,	loot_CarCivilian,		12}, // 473		----	Dinghy
	{40.0,	16.0,	loot_CarCivilian,		12}, // 474		----	Hermes
	{60.0,	15.0,	loot_CarCivilian,		12}, // 475		----	Sabre
	{88.0,	19.0,	loot_CarCivilian,		6},  // 476		----	Rustler
	{50.0,	14.0,	loot_CarCivilian,		12}, // 477		----	ZR 350
	{60.0,	26.0,	loot_CarIndustrial,		16}, // 478		----	Walton
	{55.0,	13.0,	loot_CarCivilian,		12}, // 479		----	Regina

	{50.0,	12.0,	loot_CarCivilian,		12}, // 480		----	Comet
	{0.0,	0.0,	loot_InvalidLoot,		0},  // 481		----	BMX
	{70.0,	13.0,	loot_CarIndustrial,		20}, // 482		----	Burrito
	{80.0,	26.0,	loot_CarIndustrial,		16}, // 483		----	Camper
	{900.0,	67.0,	loot_CarCivilian,		12}, // 484		----	Marquis
	{24.0,	4.0,	loot_CarCivilian,		12}, // 485		----	Baggage
	{50.0,	47.0,	loot_CarCivilian,		12}, // 486		----	Dozer
	{240.0,	76.0,	loot_CarCivilian,		12}, // 487		----	Maverick
	{240.0,	76.0,	loot_CarCivilian,		12}, // 488		----	News Chopper
	{110.0,	16.0,	loot_CarCivilian,		12}, // 489		----	Rancher

	{110.0,	18.0,	loot_CarPolice,			12}, // 490		----	FBI Rancher
	{45.0,	11.0,	loot_CarCivilian,		12}, // 491		----	Virgo
	{55.0,	12.0,	loot_CarCivilian,		12}, // 492		----	Greenwood
	{90.0,	21.0,	loot_CarCivilian,		12}, // 493		----	Jetmax
	{80.0,	28.0,	loot_CarCivilian,		12}, // 494		----	Hotring
	{120.0,	31.0,	loot_CarCivilian,		12}, // 495		----	Sandking
	{40.0,	12.0,	loot_CarCivilian,		12}, // 496		----	Blista Compact
	{240.0,	76.0,	loot_CarCivilian,		12}, // 497		----	Police Maverick
	{75.0,	19.0,	loot_CarIndustrial,		24}, // 498		----	Boxville
	{70.0,	19.0,	loot_CarIndustrial,		24}, // 499		----	Benson

	{77.0,	13.0,	loot_CarCivilian,		12}, // 500		----	Mesa
	{0.0,	0.0,	loot_CarCivilian,		12}, // 501		----	RC Goblin
	{80.0,	13.0,	loot_CarCivilian,		12}, // 502		----	Hotring Racer A
	{80.0,	13.0,	loot_CarCivilian,		12}, // 503		----	Hotring Racer B
	{65.0,	13.0,	loot_CarCivilian,		12}, // 504		----	Bloodring Banger
	{70.0,	13.0,	loot_CarCivilian,		12}, // 505		----	Rancher
	{50.0,	13.0,	loot_CarCivilian,		12}, // 506		----	Super GT
	{35.0,	13.0,	loot_CarCivilian,		12}, // 507		----	Elegant
	{60.0,	13.0,	loot_CarCivilian,		12}, // 508		----	Journey
	{0.0,	13.0,	loot_InvalidLoot,		0},  // 509		----	Bike

	{0.0,	13.0,	loot_CarCivilian,		1},  // 510		----	Mountain Bike
	{250.0,	29.0,	loot_CarCivilian,		10}, // 511		----	Beagle
	{79.0,	16.0,	loot_CarCivilian,		6},  // 512		----	Cropdust
	{55.0,	14.0,	loot_CarCivilian,		6},  // 513		----	Stunt
	{190.0,	13.0,	loot_CarIndustrial,		16}, // 514		----	Tanker
	{210.0,	13.0,	loot_CarIndustrial,		14}, // 515		----	RoadTrain
	{35.0,	13.0,	loot_CarCivilian,		12}, // 516		----	Nebula
	{35.0,	13.0,	loot_CarCivilian,		12}, // 517		----	Majestic
	{40.0,	13.0,	loot_CarCivilian,		12}, // 518		----	Buccaneer
	{340.0,	43.0,	loot_CarCivilian,		16}, // 519		----	Shamal

	{7790.0,333.9,	loot_InvalidLoot,		0},  // 520		----	Hydra
	{45.0,	13.0,	loot_CarCivilian,		6},  // 521		----	FCR-900
	{45.0,	13.0,	loot_CarCivilian,		6},  // 522		----	NRG-500
	{60.0,	13.0,	loot_CarPolice,			8},  // 523		----	HPV1000
	{60.0,	13.0,	loot_CarIndustrial,		10}, // 524		----	Cement Truck
	{50.0,	13.0,	loot_CarIndustrial,		16}, // 525		----	Tow Truck
	{45.0,	13.0,	loot_CarCivilian,		12}, // 526		----	Fortune
	{30.0,	13.0,	loot_CarCivilian,		12}, // 527		----	Cadrona
	{80.0,	13.0,	loot_CarPolice,			12}, // 528		----	FBI Truck
	{50.0,	13.0,	loot_CarCivilian,		12}, // 529		----	Willard

	{25.0,	13.0,	loot_CarCivilian,		6},  // 530		----	Forklift
	{50.0,	13.0,	loot_CarCivilian,		14}, // 531		----	Tractor
	{60.0,	13.0,	loot_InvalidLoot,		0},  // 532		----	Combine
	{60.0,	13.0,	loot_CarCivilian,		12}, // 533		----	Feltzer
	{60.0,	13.0,	loot_CarCivilian,		12}, // 534		----	Remington
	{60.0,	13.0,	loot_CarCivilian,		12}, // 535		----	Slamvan
	{60.0,	13.0,	loot_CarCivilian,		12}, // 536		----	Blade
	{60.0,	13.0,	loot_CarCivilian,		12}, // 537		----	Freight
	{110.0,	18.0,	loot_CarCivilian,		12}, // 538		----	Streak
	{60.0,	13.0,	loot_CarCivilian,		6},  // 539		----	Vortex

	{60.0,	13.0,	loot_CarCivilian,		12}, // 540		----	Vincent
	{50.0,	13.0,	loot_CarCivilian,		12}, // 541		----	Bullet
	{60.0,	13.0,	loot_CarCivilian,		12}, // 542		----	Clover
	{60.0,	13.0,	loot_CarCivilian,		16}, // 543		----	Sadler
	{70.0,	13.0,	loot_CarIndustrial,		16}, // 544		----	Firetruck
	{60.0,	13.0,	loot_CarCivilian,		12}, // 545		----	Hustler
	{60.0,	13.0,	loot_CarCivilian,		12}, // 546		----	Intruder
	{60.0,	13.0,	loot_CarCivilian,		12}, // 547		----	Primo
	{2000.0,341.0,	loot_CarMilitary,		24}, // 548		----	Cargobob
	{60.0,	13.0,	loot_CarCivilian,		12}, // 549		----	Tampa

	{60.0,	13.0,	loot_CarCivilian,		12}, // 550		----	Sunrise
	{60.0,	13.0,	loot_CarCivilian,		12}, // 551		----	Merit
	{60.0,	13.0,	loot_CarIndustrial,		16}, // 552		----	Utility
	{3046.0,118.3,	loot_CarIndustrial,		24}, // 553		----	Nevada
	{60.0,	13.0,	loot_CarIndustrial,		16}, // 554		----	Yosemite
	{60.0,	13.0,	loot_CarCivilian,		12}, // 555		----	Windsor
	{40.0,	13.0,	loot_CarCivilian,		12}, // 556		----	Monster A
	{40.0,	13.0,	loot_CarCivilian,		12}, // 557		----	Monster B
	{50.0,	13.0,	loot_CarCivilian,		12}, // 558		----	Uranus
	{50.0,	13.0,	loot_CarCivilian,		12}, // 559		----	Jester

	{60.0,	13.0,	loot_CarCivilian,		12}, // 560		----	Sultan
	{60.0,	13.0,	loot_CarCivilian,		12}, // 561		----	Stratum
	{60.0,	13.0,	loot_CarCivilian,		12}, // 562		----	Elegy
	{200.0,	13.0,	loot_CarCivilian,		12}, // 563		----	Raindance
	{0.0,	13.0,	loot_CarCivilian,		12}, // 564		----	RC Tiger
	{60.0,	13.0,	loot_CarCivilian,		12}, // 565		----	Flash
	{60.0,	13.0,	loot_CarCivilian,		12}, // 566		----	Tahoma
	{60.0,	13.0,	loot_CarCivilian,		12}, // 567		----	Savanna
	{60.0,	13.0,	loot_CarCivilian,		12}, // 568		----	Bandito
	{200.0,	20.0,	loot_CarCivilian,		12}, // 569		----	Freight

	{0.0,	0.0,	loot_CarCivilian,		12}, // 570		----	Trailer
	{20.0,	13.0,	loot_CarCivilian,		12}, // 571		----	Kart
	{20.0,	13.0,	loot_CarCivilian,		12}, // 572		----	Mower
	{248.0,	35.0,	loot_CarCivilian,		16}, // 573		----	Duneride
	{60.0,	13.0,	loot_CarCivilian,		12}, // 574		----	Sweeper
	{60.0,	13.0,	loot_CarCivilian,		12}, // 575		----	Broadway
	{60.0,	13.0,	loot_CarCivilian,		12}, // 576		----	Tornado
	{17900.0,319.6,	loot_CarIndustrial,		12}, // 577		----	AT-400
	{60.0,	13.0,	loot_CarIndustrial,		24}, // 578		----	DFT-30
	{70.0,	13.0,	loot_CarCivilian,		14}, // 579		----	Huntley

	{67.0,	13.0,	loot_CarCivilian,		12}, // 580		----	Stafford
	{45.0,	12.0,	loot_CarCivilian,		6},  // 581		----	BF-400
	{60.0,	13.0,	loot_CarCivilian,		12}, // 582		----	Newsvan
	{10.0,	4.0,	loot_CarCivilian,		12}, // 583		----	Tug
	{0.0,	0.0,	loot_CarIndustrial,		12}, // 584		----	Trailer A
	{70.0,	12.0,	loot_CarCivilian,		12}, // 585		----	Emperor
	{47.0,	8.0,	loot_Survivor,			16}, // 586		----	Wayfarer
	{60.0,	13.0,	loot_CarCivilian,		12}, // 587		----	Euros
	{70.0,	13.0,	loot_CarCivilian,		12}, // 588		----	Hotdog
	{45.0,	13.0,	loot_CarCivilian,		12}, // 589		----	Club

	{0.0,	0.0,	loot_CarCivilian,		12}, // 590		----	Trailer B
	{0.0,	0.0,	loot_CarCivilian,		12}, // 591		----	Trailer C
	{193600.0,4360.4,loot_CarIndustrial,	24}, // 592		----	Andromada
	{110.0,	27.0,	loot_CarCivilian,		10}, // 593		----	Dodo
	{0.0,	0.0,	loot_InvalidLoot,		0},  // 594		----	RC Cam
	{213.0,	23.0,	loot_CarMilitary,		12}, // 595		----	Launch
	{78.0,	12.5,	loot_CarPolice,			12}, // 596		----	Police Car (LSPD)
	{70.0,	13.0,	loot_CarPolice,			12}, // 597		----	Police Car (SFPD)
	{75.0,	12.0,	loot_CarPolice,			12}, // 598		----	Police Car (LVPD)
	{110.0,	15.0,	loot_CarPolice,			12}, // 599		----	Police Ranger

	{86.0,	14.0,	loot_CarIndustrial,		16}, // 600		----	Picador
	{90.0,	16.0,	loot_CarMilitary,		12}, // 601		----	S.W.A.T. Van
	{73.0,	14.0,	loot_CarCivilian,		12}, // 602		----	Alpha
	{65.0,	14.5,	loot_CarCivilian,		12}, // 603		----	Phoenix
	{68.0,	15.0,	loot_CarCivilian,		12}, // 604		----	Glendale
	{78.0,	19.0,	loot_CarCivilian,		16}, // 605		----	Sadler
	{0.0,	0.0,	loot_CarCivilian,		12}, // 606		----	Luggage Trailer A
	{0.0,	0.0,	loot_CarCivilian,		12}, // 607		----	Luggage Trailer B
	{0.0,	0.0,	loot_CarCivilian,		12}, // 608		----	Stair Trailer
	{79.0,	20.0,	loot_CarIndustrial,		16}, // 609		----	Boxville

	{0.0,	0.0,	loot_CarCivilian,		12}, // 610		----	Farm Plow
	{0.0,	0.0,	loot_CarCivilian,		12}  // 611		----	Utility Trailer
};

enum
{
	VEHICLE_GROUP_NONE				= -1,
	VEHICLE_GROUP_CASUAL,			// 0
	VEHICLE_GROUP_CASUAL_DESERT,	// 1
	VEHICLE_GROUP_CASUAL_COUNTRY,	// 2
	VEHICLE_GROUP_SPORT,			// 3
	VEHICLE_GROUP_OFFROAD,			// 4
	VEHICLE_GROUP_BIKE,				// 5
	VEHICLE_GROUP_FASTBIKE,			// 6
	VEHICLE_GROUP_MILITARY,			// 7
	VEHICLE_GROUP_POLICE,			// 8
	VEHICLE_GROUP_BIGPLANE,			// 9
	VEHICLE_GROUP_SMALLPLANE,		// 10
	VEHICLE_GROUP_HELICOPTER,		// 11
	VEHICLE_GROUP_BOAT				// 12
}

new gModelGroup[13][78]=
{
	// VEHICLE_GROUP_CASUAL
	{
		404,442,479,549,600,496,496,401,
		410,419,436,439,517,518,401,410,
		419,436,439,474,491,496,517,518,
		526,527,533,545,549,580,589,600,
		602,400,404,442,458,479,489,505,
		579,405,421,426,445,466,467,492,
		507,516,529,540,546,547,550,551,
		566,585,587,412,534,535,536,567,
		575,576,509,481,510,462,448,463,
		586,468,471,0
	},
	// VEHICLE_GROUP_CASUAL_DESERT,
	{
	    404,479,445,542,466,467,549,540,
		424,400,500,505,489,499,422,600,
		515,543,554,443,508,525,509,481,
		510,462,448,463,586,468,471,0,...
	},
	// VEHICLE_GROUP_CASUAL_COUNTRY,
	{
	    499,422,498,609,455,403,414,514,
		600,413,515,440,543,531,478,456,
		554,445,518,401,527,542,546,410,
		549,508,525,509,481,510,462,448,
		463,586,468,471,0,...
	},
	// VEHICLE_GROUP_SPORT,
	{
		558,559,560,561,562,565,411,451,
		477,480,494,502,503,506,541,581,
		522,461,521,0,...
	},
	// VEHICLE_GROUP_OFFROAD,
	{
		400,505,579,422,478,543,554,468,
		586,0,...
	},
	// VEHICLE_GROUP_BIKE,
	{
	    509,481,510,462,448,463,586,468,
		471,0,...
	},
	// VEHICLE_GROUP_FASTBIKE,
	{
	    581,522,461,521,0,...
	},
	// VEHICLE_GROUP_MILITARY,
	{
	    433,432,601,470,0,...
	},
	// VEHICLE_GROUP_POLICE,
	{
	    523,596,598,597,599,490,528,427
	},
	// VEHICLE_GROUP_BIGPLANE,
	{
	    519,553,577,592,0,...
	},
	// VEHICLE_GROUP_SMALLPLANE,
	{
	    460,476,511,512,513,593,0,...
	},
	// VEHICLE_GROUP_HELICOPTER,
	{
	    548,487,417,487,488,487,497,487,
		563,477,469,487,0,...
	},
	// VEHICLE_GROUP_BOAT,
	{
	    472,473,493,595,484,430,453,452,
		446,454,460,447,0,...
	}
};

PickRandomVehicleFromGroup(group)
{
	new idx;
	while(gModelGroup[group][idx] != 0)idx++;
	return gModelGroup[group][random(idx)];
}
