#include <a_samp>
#include <formatex>
#include <zcmd>
#include <streamer>
#include <colours>

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
	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 150);

	if(idx != curAnim)
	{
	    curAnim = idx;
	    OnAnimChange(playerid);
	}

}

OnAnimChange(playerid)
{
	new str[128];
	format(str, 128, "AnimTime: %d", GetTickCount() - animTick);
	SendClientMessage(playerid, YELLOW, str);

	animTick = GetTickCount();
}
