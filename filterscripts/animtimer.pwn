#define FILTERSCRIPT
#include <a_samp>
#include <SIF/SIF>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

new
	curAnim,
	animTick;

public OnPlayerUpdate(playerid)
{
	new
		idx = GetPlayerAnimationIndex(playerid),
		animlib[32],
		animname[32],
		str[78];

	GetAnimationName(idx, animlib, 32, animname, 32);
	format(str, 78, "AnimIDX:%d~n~AnimName:%s~n~AnimLib:%s", idx, animname, animlib);
	ShowActionText(playerid, str, 0);

	if(idx != curAnim)
	{
		format(str, 128, "AnimTime: %d", GetTickCount() - animTick);
		SendClientMessage(playerid, -1, str);

		animTick = GetTickCount();

		curAnim = idx;
	}

	return 1;
}
