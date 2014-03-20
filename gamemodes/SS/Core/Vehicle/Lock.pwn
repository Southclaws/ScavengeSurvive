#include <YSI\y_hooks>


static
	lock_Status		[MAX_SPAWNED_VEHICLES],
	lock_LastChange	[MAX_SPAWNED_VEHICLES];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(newkeys & KEY_SUBMISSION)
		{
			if(VehicleDoorsState(vehicleid))
			{
				SetVehicleExternalLock(vehicleid, false);
			}
			else
			{
				SetVehicleExternalLock(vehicleid, true);
			}
		}
	}

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(lock_Status[vehicleid])
	{
		CancelPlayerMovement(playerid);
		ShowActionText(playerid, "Door Locked", 3000);
	}

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsVehicleLocked(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return -1;

	return lock_Status[vehicleid];
}

stock SetVehicleExternalLock(vehicleid, status)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(!VehicleHasDoors(GetVehicleModel(vehicleid)))
	{
		lock_Status[vehicleid] = false;
		VehicleDoorsState(vehicleid, false);
		return 1;
	}

	lock_LastChange[vehicleid] = GetTickCount();

	lock_Status[vehicleid] = status;
	VehicleDoorsState(vehicleid, status);

	return 1;
}

stock GetVehicleLockTick(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	return lock_LastChange[vehicleid];
}
