#include <YSI\y_hooks>


static
		mute_Muted[MAX_PLAYERS],
		mute_StartTick[MAX_PLAYERS],
		mute_Duration[MAX_PLAYERS],
Timer:	mute_UnmuteTimer[MAX_PLAYERS];


TogglePlayerMute(playerid, bool:toggle, duration = -1)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(toggle)
	{
		mute_Muted[playerid] = true;
		mute_StartTick[playerid] = GetTickCount();
		mute_Duration[playerid] = duration;

		if(duration > 0)
		{
			stop mute_UnmuteTimer[playerid];
			mute_UnmuteTimer[playerid] = defer UnMuteDelay(playerid, duration);
		}
	}
	else
	{
		mute_Muted[playerid] = false;
		mute_StartTick[playerid] = 0;
		mute_Duration[playerid] = 0;

		stop mute_UnmuteTimer[playerid];
	}

	return 1;
}

timer UnMuteDelay[time](playerid, time)
{
	#pragma unused time

	TogglePlayerMute(playerid, false);
	
	Msg(playerid, YELLOW, " >  You are now un-muted.");
}

hook OnPlayerDisconnect(playerid)
{
	if(gServerRestarting)
		return 1;

	if(mute_Muted[playerid])
	{
		TogglePlayerMute(playerid, false);
	}

	return 1;
}

stock IsPlayerMuted(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return mute_Muted[playerid];
}

stock GetPlayerMuteTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return mute_StartTick[playerid];
}

stock GetPlayerMuteDuration(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return mute_Duration[playerid];
}

stock GetPlayerMuteRemainder(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!mute_Muted[playerid])
		return 0;

	if(mute_Duration[playerid] == -1)
		return -1;

	return GetTickCountDifference((mute_StartTick[playerid] + mute_Duration[playerid]), GetTickCount());
}

CMD:testmute(playerid, params[])
{
	TogglePlayerMute(playerid, true, strval(params));
	return 1;
}
