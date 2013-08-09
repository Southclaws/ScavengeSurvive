ShowWatch(playerid)
{
	PlayerTextDrawShow(playerid, WatchBackground);
	PlayerTextDrawShow(playerid, WatchTime);
	PlayerTextDrawShow(playerid, WatchBear);
	PlayerTextDrawShow(playerid, WatchFreq);
}

HideWatch(playerid)
{
	PlayerTextDrawHide(playerid, WatchBackground);
	PlayerTextDrawHide(playerid, WatchTime);
	PlayerTextDrawHide(playerid, WatchBear);
	PlayerTextDrawHide(playerid, WatchFreq);
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
		GetVehicleZAngle(gPlayerData[playerid][ply_CurrentVehicle], angle);

	else
		GetPlayerFacingAngle(playerid, angle);

	format(str, 6, "%02d:%02d", hour, minute);
	PlayerTextDrawSetString(playerid, WatchTime, str);

	format(str, 12, "%.0f DEG", 360 - angle);
	PlayerTextDrawSetString(playerid, WatchBear, str);

	format(str, 7, "%.2f", gPlayerData[playerid][ply_RadioFrequency]);
	PlayerTextDrawSetString(playerid, WatchFreq, str);
}
