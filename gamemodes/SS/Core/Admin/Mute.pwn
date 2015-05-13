#include <YSI\y_hooks>


static
		mute_Muted[MAX_PLAYERS],
		mute_StartTime[MAX_PLAYERS],
		mute_Duration[MAX_PLAYERS],
Timer:	mute_UnmuteTimer[MAX_PLAYERS];


TogglePlayerMute(playerid, bool:toggle, duration = -1)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(toggle && duration != 0)
	{
		mute_Muted[playerid] = true;
		mute_StartTime[playerid] = gettime();
		mute_Duration[playerid] = duration;

		if(duration > 0)
		{
			stop mute_UnmuteTimer[playerid];
			mute_UnmuteTimer[playerid] = defer UnMuteDelay(playerid, duration * 1000);
		}
	}
	else
	{
		mute_Muted[playerid] = false;
		mute_StartTime[playerid] = 0;
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

public OnPlayerDisconnected(playerid)
{
	if(gServerRestarting)
		return 1;

	if(mute_Muted[playerid])
	{
		TogglePlayerMute(playerid, false);
	}

	#if defined mute_OnPlayerDisconnected
		return mute_OnPlayerDisconnected(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnected
	#undef OnPlayerDisconnected
#else
	#define _ALS_OnPlayerDisconnected
#endif
#define OnPlayerDisconnected mute_OnPlayerDisconnected
#if defined mute_OnPlayerDisconnected
	forward mute_OnPlayerDisconnected(playerid);
#endif

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

	return mute_StartTime[playerid];
}

stock GetPlayerMuteDuration(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return mute_Duration[playerid];
}

stock GetPlayerMuteRemainder(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	if(!mute_Muted[playerid])
		return 0;

	if(mute_Duration[playerid] == -1)
		return -1;

	return mute_Duration[playerid] - (gettime() - mute_StartTime[playerid]);
}

CMD:testmute(playerid, params[])
{
	TogglePlayerMute(playerid, true, strval(params));
	return 1;
}
