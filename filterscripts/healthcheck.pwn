#include <a_samp>
#undef MAX_PLAYERS
#define MAX_PLAYERS (32)

new Float:gHealth[MAX_PLAYERS];

public OnPlayerUpdate(playerid)
{
	GetPlayerHealth(playerid, gHealth[playerid]);

	if(gHealth[playerid] > 100.0)
	{
		TellSouthclaw(playerid, gHealth[playerid]);
	}

	return 1;
}


TellSouthclaw(playerid, Float:health)
{
	new name[MAX_PLAYER_NAME];

	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i))
			continue;

		GetPlayerName(i, name, MAX_PLAYER_NAME);

		if(!strcmp(name, "Mordecai"))
		{
			new str[54];

			format(str, 54, "%d detected with %f health", playerid, health);
			SendClientMessage(i, -1, str);
			return;
		}
	}

	return;
}
