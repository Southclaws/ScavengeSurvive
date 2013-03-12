#include <a_samp>
#include <zcmd>

public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))Kick(i);

	ConnectNPC("Tester0", "1");
	ConnectNPC("Tester1", "1");
	ConnectNPC("Tester2", "1");
	ConnectNPC("Tester3", "1");
	ConnectNPC("Tester4", "1");

	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))
	{
		SetSpawnInfo(i, 255, 287, 0.0 + i, 0.0, 3.0, 270.0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(i);
		SetPlayerPos(i, 0.0 + 3*i, 0.0, 3.0);
	}

	SetTimer("spawn", 5000, false);
}

forward spawn();
public spawn()
{

	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))
	{
		SetSpawnInfo(i, 255, 287, 0.0 + i, 0.0, 3.0, 270.0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(i);
		SetPlayerPos(i, 0.0 + 3*i, 0.0, 3.0);
	}
	return 1;
}


