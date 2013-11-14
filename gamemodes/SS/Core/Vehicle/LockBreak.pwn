#include <YSI\y_hooks>


static
	cro_TargetVehicle[MAX_PLAYERS],
	cro_OpenType[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	cro_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

public OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
	{
		if(IsVehicleLocked(vehicleid))
			return 1;

		if(225.0 < angle < 315.0)
		{
			return StartBreakingVehicleLock(playerid, vehicleid, 0);
		}

		if(155.0 < angle < 205.0)
		{
			return StartBreakingVehicleLock(playerid, vehicleid, 1);
		}
	}

	return CallLocalFunction("cro_OnPlayerInteractVehicle", "ddf", playerid, vehicleid, Float:angle);
}
#if defined _ALS_OnPlayerInteractVehicle
	#undef OnPlayerInteractVehicle
#else
	#define _ALS_OnPlayerInteractVehicle
#endif
#define OnPlayerInteractVehicle cro_OnPlayerInteractVehicle
forward cro_OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopBreakingVehicleLock(playerid);
	}
}

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

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	if(type == 0)
	{
		if(doors == 0)
			return 0;

		cro_OpenType[playerid] = 0;
	}
	if(type == 1)
	{
		if(!IsVehicleTrunkLocked(vehicleid))
			return 0;

		cro_OpenType[playerid] = 1;
	}

	cro_TargetVehicle[playerid] = vehicleid;
	ApplyAnimation(playerid, "POLICE", "DOOR_KICK", 3.0, 1, 1, 1, 0, 0);

	StartHoldAction(playerid, 3000);

	return 1;
}

StopBreakingVehicleLock(playerid)
{
	if(cro_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	ClearAnimations(playerid);
	StopHoldAction(playerid);

	cro_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(cro_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(!IsValidVehicleID(cro_TargetVehicle[playerid]) || GetItemType(GetPlayerItem(playerid)) != item_Crowbar || !IsPlayerInVehicleArea(playerid, cro_TargetVehicle[playerid]))
		{
			StopBreakingVehicleLock(playerid);
			return 1;
		}

		SetPlayerToFaceVehicle(playerid, cro_TargetVehicle[playerid]);

		return 1;
	}

	return CallLocalFunction("cro_OnHoldActionUpdate", "dd", playerid, progress);
}

public OnHoldActionFinish(playerid)
{
	if(cro_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(cro_OpenType[playerid] == 0)
		{
			VehicleDoorsState(cro_TargetVehicle[playerid], 0);
		}
		if(cro_OpenType[playerid] == 1)
		{
			SetVehicleTrunkLock(cro_TargetVehicle[playerid], 0);
		}

		StopBreakingVehicleLock(playerid);			

		return 1;
	}

	return CallLocalFunction("cro_OnHoldActionFinish", "d", playerid);
}


// Hooks


#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate cro_OnHoldActionUpdate
forward cro_OnHoldActionUpdate(playerid, progress);


#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish cro_OnHoldActionFinish
forward cro_OnHoldActionFinish(playerid);
