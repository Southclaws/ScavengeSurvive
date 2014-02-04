#include <YSI\y_hooks>


static
	aimshout_Tick[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if( (newkeys & 128) && (newkeys & 512) )
	{
		if(GetTickCountDifference(aimshout_Tick[playerid], GetTickCount()) > 750)
		{
			new string[128];

			GetPlayerAimShoutText(playerid, string);

			PlayerSendChat(playerid, string, 0.0);

			aimshout_Tick[playerid] = GetTickCount();
		}
	}

	return 1;
}

CMD:aimshout(playerid, params[])
{
	new string[128];

	if(sscanf(params, "s[128]", string))
	{
		Msg(playerid, YELLOW, " >  Usage: /aimshout [text] - Sets a custom string you can send by pressing the AIM and LOOK BEHIND keys at the same time.");
		return 1;
	}

	SetPlayerAimShoutText(playerid, string);

	stmt_bind_value(gStmt_AccountSetAimShout, 0, DB::TYPE_STRING, string, 128);
	stmt_bind_value(gStmt_AccountSetAimShout, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetAimShout);

	MsgF(playerid, YELLOW, " >  AimShout set to '%s'", string);

	return 1;
}
