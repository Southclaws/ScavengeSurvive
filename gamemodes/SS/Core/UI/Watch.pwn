ShowWatch(playerid)
{
	PlayerTextDrawShow(playerid, WatchBackground[playerid]);
	PlayerTextDrawShow(playerid, WatchTime[playerid]);
	PlayerTextDrawShow(playerid, WatchBear[playerid]);
	PlayerTextDrawShow(playerid, WatchFreq[playerid]);
}

HideWatch(playerid)
{
	PlayerTextDrawHide(playerid, WatchBackground[playerid]);
	PlayerTextDrawHide(playerid, WatchTime[playerid]);
	PlayerTextDrawHide(playerid, WatchBear[playerid]);
	PlayerTextDrawHide(playerid, WatchFreq[playerid]);
}

ptask UpdateWatch[1000](playerid)
{
	new
		str[12],
		hour,
		minute,
		Float:angle;

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
}
