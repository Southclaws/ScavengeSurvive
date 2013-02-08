#include <YSI\y_hooks>

#define MAX_SPAWNS (5)

new Float:gSpawns[MAX_SPAWNS][4];

hook OnGameModeInit()
{
	new
		File:file,
		line[128],
		idx;

	file = fopen("SSS/Spawns.dat", io_read);

	while(fread(file, line))
	{
		sscanf(line, "p<,>ffff", gSpawns[idx][0], gSpawns[idx][1], gSpawns[idx][2], gSpawns[idx][3]);
		idx++;
	}
}