new
ItemType:	item_Crowbar = INVALID_ITEM_TYPE,
Timer:		LockBreakTimer[MAX_PLAYERS],
			LockBreakCurrentVehicle[MAX_PLAYERS],
			LockBreakProgress[MAX_PLAYERS];


StartBreakingVehicleLock(playerid, vehicleid, type)
{
	new
		engine,
		lights,
		alarm,
		doors,
		bonnet,
		boot,
		objective;

	stop LockBreakTimer[playerid];

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	if(type == 0)
	{
		if(doors == 0)
			return 0;
	}
	if(type == 1)
	{
		if(IsVehicleTrunkLocked(vehicleid) == 0)
			return 0;
	}

	LockBreakTimer[playerid] = repeat BreakVehicleLockUpdate(playerid, vehicleid, type);

	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 20.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	LockBreakProgress[playerid] = 0;
	LockBreakCurrentVehicle[playerid] = vehicleid;
	ApplyAnimation(playerid, "POLICE", "DOOR_KICK", 3.0, 1, 1, 1, 0, 0);

	return 1;
}

StopBreakingVehicleLock(playerid)
{
	if(!IsValidVehicle(LockBreakCurrentVehicle[playerid]))
		return 0;

	stop LockBreakTimer[playerid];
	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);

	return 1;
}

timer BreakVehicleLockUpdate[100](playerid, vehicleid, type)
{
	if(LockBreakProgress[playerid] >= 20)
	{
		if(type == 0)
		{
			new
				engine,
				lights,
				alarm,
				doors,
				bonnet,
				boot,
				objective;

			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, engine, lights, 1, 0, bonnet, boot, objective);
		}
		if(type == 1)
		{
			SetVehicleTrunkLock(vehicleid, 0);
		}

		StopBreakingVehicleLock(playerid);			

		return;
	}

	if(!IsValidVehicle(vehicleid) || GetItemType(GetPlayerItem(playerid)) != item_Crowbar || !IsPlayerInVehicleArea(playerid, vehicleid))
	{
		StopBreakingVehicleLock(playerid);
		return;
	}

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:vx,
		Float:vy,
		Float:vz;

	SetPlayerProgressBarValue(playerid, ActionBar, LockBreakProgress[playerid]);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 20.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	GetVehiclePos(vehicleid, vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

	LockBreakProgress[playerid]++;

	return;
}
