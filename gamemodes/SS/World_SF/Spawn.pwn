#define MAX_SPAWNS (11)


static
	Float:spawn_List[MAX_SPAWNS][4] =
	{
		{-223.27693,	-1708.64893,	-0.03820,	0.0},
		{10.04701,		-1102.97205,	-0.05019,	90.0},
		{-325.08279,	-468.19110,		0.98427,	90.0},
		{-1520.09302,	151.98511,		2.50820,	90.0},
		{-2077.33838,	1424.59875,		6.02601,	90.0},
		{-2975.57495,	504.43192,		1.38190,	270.0},
		{-2927.81030,	168.19971,		0.21538,	270.0},
		{-2920.55078,	-73.13767,		0.26866,	270.0},
		{-2935.97095,	-494.36163,		0.52946,	270.0},
		{-1650.31470,	-1702.93530,	0.11556,	90.0},
		{-2691.66675,	-2214.08301,	-0.07716,	180.0}
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
