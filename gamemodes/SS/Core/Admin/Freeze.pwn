#include <YSI\y_hooks>


static
bool:	frz_Frozen[MAX_PLAYERS],
Timer:	frz_DelayTimer[MAX_PLAYERS],
Timer:	frz_CheckTimer[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	frz_Frozen[playerid] = false;

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	stop frz_DelayTimer[playerid];

	return 1;
}

FreezePlayer(playerid, duration = 0, msg = 0)
{
	TogglePlayerControllable(playerid, false);
	frz_Frozen[playerid] = true;

	if(duration > 0)
	{
		stop frz_DelayTimer[playerid];
		frz_DelayTimer[playerid] = defer UnfreezePlayer_delay(playerid, duration, msg);
	}

	if(duration > 4000 || duration == 0)
	{
		stop frz_CheckTimer[playerid];
		frz_CheckTimer[playerid] = defer UnfreezePlayer_check(playerid);
	}
}

UnfreezePlayer(playerid, msg = 0)
{
	TogglePlayerControllable(playerid, true);
	frz_Frozen[playerid] = false;
	stop frz_DelayTimer[playerid];
	stop frz_CheckTimer[playerid];

	if(msg)
		Msg(playerid, YELLOW, " >  You are now unfrozen.");
}

timer UnfreezePlayer_delay[time](playerid, time, msg)
{
	#pragma unused time

	UnfreezePlayer(playerid, msg);
}

timer UnfreezePlayer_check[4000](playerid)
{
	new Float:z;

	GetPlayerCameraFrontVector(playerid, z, z, z);

	if(-0.994 >= z >= -0.997 || 0.9958 >= z >= 0.9946)
	{
		MsgAdminsF(2, YELLOW, " >  Possible mod user: "C_ORANGE"%p (%d)", playerid, playerid);
		SendIrcStaffMessage("Server", sprintf("Possible mod user %p", playerid));
	}
}


stock IsPlayerFrozen(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return frz_Frozen[playerid];
}
