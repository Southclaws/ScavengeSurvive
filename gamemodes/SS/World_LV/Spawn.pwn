#define MAX_SPAWNS (13)


static
	Float:spawn_List[MAX_SPAWNS][4] =
	{
		{2361.14844,	527.99731,	0.76357,	0.00},
		{2293.72754,	527.79791,	0.76734,	0.00},
		{258.25974,		2937.49365,	0.75733,	0.00},
		{-1845.25269,	2110.26245,	0.48460,	180.00},
		{-786.72101,	948.13007,	0.01286,	270.00},
		{-763.68823,	653.48480,	0.37847,	270.00},
		{-640.49799,	864.78693,	0.94158,	270.00},
		{-489.40747,	614.56006,	0.77154,	270.00},
		{-435.67020,	862.16876,	0.35344,	270.00},
		{-420.52075,	1163.55750,	0.85486,	90.00},
		{-649.15778,	1315.83948,	-0.06668,	90.00},
		{-1378.10144,	2111.37622,	41.11933,	90.00},
		{1628.41040,	583.12726,	0.67772,	0.00}
	},
	spawn_Last[MAX_PLAYERS];



GenerateSpawnPoint(playerid, &Float:x, &Float:y, &Float:z, &Float:r)
{
	new index = random(sizeof(spawn_List));

	while(index == spawn_Last[playerid])
		index = random(sizeof(spawn_List));

	x = spawn_List[index][0];
	y = spawn_List[index][1];
	z = spawn_List[index][2];
	r = spawn_List[index][3];

	spawn_Last[playerid] = index;
}
