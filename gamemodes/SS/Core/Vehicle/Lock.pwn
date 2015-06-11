#include <YSI\y_hooks>


static
	lock_Status		[MAX_VEHICLES],
	lock_LastChange	[MAX_VEHICLES];


public OnVehicleCreated(vehicleid)
{
	lock_Status[vehicleid] = 0;
	lock_LastChange[vehicleid] = 0;

	#if defined lock_OnVehicleCreated
		return lock_OnVehicleCreated(vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleCreated
	#undef OnVehicleCreated
#else
	#define _ALS_OnVehicleCreated
#endif
 
#define OnVehicleCreated lock_OnVehicleCreated
#if defined lock_OnVehicleCreated
	forward lock_OnVehicleCreated(vehicleid);
#endif

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_SUBMISSION)
	{
		if(IsPlayerInAnyVehicle(playerid))
			_HandleLockKey(playerid);
	}

	return 1;
}

_HandleLockKey(playerid)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(VehicleDoorsState(vehicleid))
		SetVehicleExternalLock(vehicleid, false);

	else
		SetVehicleExternalLock(vehicleid, true);

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
	if(!IsValidVehicle(vehicleid))
		return -1;

	return lock_Status[vehicleid];
}

stock SetVehicleExternalLock(vehicleid, status)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(IsVehicleDead(vehicleid))
	{
		lock_Status[vehicleid] = true;
		VehicleDoorsState(vehicleid, true);
		return 1;
	}

	lock_LastChange[vehicleid] = GetTickCount();

	lock_Status[vehicleid] = status;
	VehicleDoorsState(vehicleid, status);

	return 1;
}

stock GetVehicleLockTick(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return lock_LastChange[vehicleid];
}
