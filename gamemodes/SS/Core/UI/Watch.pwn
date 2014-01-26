static
bool:	watch_Show[MAX_PLAYERS];


ShowWatch(playerid)
{
	PlayerTextDrawShow(playerid, WatchBackground[playerid]);
	PlayerTextDrawShow(playerid, WatchTime[playerid]);
	PlayerTextDrawShow(playerid, WatchBear[playerid]);
	PlayerTextDrawShow(playerid, WatchFreq[playerid]);

	watch_Show[playerid] = true;
}

HideWatch(playerid)
{
	PlayerTextDrawHide(playerid, WatchBackground[playerid]);
	PlayerTextDrawHide(playerid, WatchTime[playerid]);
	PlayerTextDrawHide(playerid, WatchBear[playerid]);
	PlayerTextDrawHide(playerid, WatchFreq[playerid]);

	watch_Show[playerid] = false;
}

ptask UpdateWatch[1000](playerid)
{
	if(!watch_Show[playerid])
		return;

	new
		str[12],
		hour,
		minute,
		Float:angle,
		lastattacker,
		lastweapon;

	gettime(hour, minute);

	if(IsPlayerInAnyVehicle(playerid))
		GetVehicleZAngle(GetPlayerLastVehicle(playerid), angle);

	else
		GetPlayerFacingAngle(playerid, angle);

	format(str, 6, "%02d:%02d", hour, minute);
	PlayerTextDrawSetString(playerid, WatchTime[playerid], str);

	format(str, 12, "%.0f DEG", 360 - angle);
	PlayerTextDrawSetString(playerid, WatchBear[playerid], str);

	format(str, 7, "%.2f", GetPlayerRadioFrequency(playerid));
	PlayerTextDrawSetString(playerid, WatchFreq[playerid], str);

	if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
	{
		if(IsPlayerConnected(lastattacker))
		{
			PlayerTextDrawColor(playerid, WatchTime[playerid], RED);
			PlayerTextDrawColor(playerid, WatchBear[playerid], RED);
			PlayerTextDrawColor(playerid, WatchFreq[playerid], RED);
		}
	}
	else
	{
		PlayerTextDrawColor(playerid, WatchTime[playerid], WHITE);
		PlayerTextDrawColor(playerid, WatchBear[playerid], WHITE);
		PlayerTextDrawColor(playerid, WatchFreq[playerid], WHITE);
	}

	PlayerTextDrawShow(playerid, WatchTime[playerid]);
	PlayerTextDrawShow(playerid, WatchBear[playerid]);
	PlayerTextDrawShow(playerid, WatchFreq[playerid]);

	return;
}
