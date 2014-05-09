#define MAX_SPAWNS (2)


static
	Float:spawn_List[MAX_SPAWNS][4] =
	{
		{-2431.0, 2254.0, 5.0,	0.0},
		{-2431.0, 2215.0, 5.0,	90.0}
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
