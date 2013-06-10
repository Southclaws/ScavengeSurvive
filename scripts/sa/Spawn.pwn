#define MAX_SPAWNS (4)


static Float:gSpawns[MAX_SPAWNS][4] =
{
	{-2994.2331, 470.8561, 4.9140, 269.0305},
	{-2923.4396, -70.4305, 0.7973, 269.0305},
	{-2914.9213, -902.9458, 0.5190, 339.3433},
	{-2804.5021, -2296.2153, 0.7071, 249.8544}
};


GenerateSpawnPoint(&Float:x, &Float:y, &Float:z, &Float:r)
{
	new index = random(sizeof(gSpawns));

	x = gSpawns[index][0];
	y = gSpawns[index][1];
	z = gSpawns[index][2];
	r = gSpawns[index][3];
}
