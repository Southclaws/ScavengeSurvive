#include <YSI\y_hooks>


static
		fix_TargetVehicle[MAX_PLAYERS],
Float:	fix_Progress[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}


StartRepairingVehicle(playerid, vehicleid)
{
	GetVehicleHealth(vehicleid, fix_Progress[playerid]);

	if(fix_Progress[playerid] >= 990.0)
	{
		return 0;
	}

	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
	VehicleBonnetState(fix_TargetVehicle[playerid], 1);
	StartHoldAction(playerid, 50000, floatround(fix_Progress[playerid] * 50));

	fix_TargetVehicle[playerid] = vehicleid;

	return 1;
}

StopRepairingVehicle(playerid)
{
	if(fix_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	if(fix_Progress[playerid] > 990.0)
	{
		SetVehicleHealth(fix_TargetVehicle[playerid], 990.0);
	}

	VehicleBonnetState(fix_TargetVehicle[playerid], 0);
	StopHoldAction(playerid);
	ClearAnimations(playerid);

	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(fix_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(!IsPlayerInVehicleArea(playerid, fix_TargetVehicle[playerid]) || !IsValidVehicle(fix_TargetVehicle[playerid]))
		{
			StopRepairingVehicle(playerid);
			return 1;
		}

		if(GetItemType(GetPlayerItem(playerid)) == item_Wrench)
		{
			if(!(250.0 <= fix_Progress[playerid] <= 450.0) && !(750.0 <= fix_Progress[playerid] <= 990.0))
			{
				StopRepairingVehicle(playerid);
				return 1;
			}
		}
		if(GetItemType(GetPlayerItem(playerid)) == item_Screwdriver)
		{
			if(!(450.0 <= fix_Progress[playerid] <= 600.0))
			{
				StopRepairingVehicle(playerid);
				return 1;
			}
		}
		if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
		{
			if(!(600.0 <= fix_Progress[playerid] <= 750.0))
			{
				StopRepairingVehicle(playerid);
				return 1;
			}
		}

		fix_Progress[playerid] += 2.0;
		
		SetVehicleHealth(fix_TargetVehicle[playerid], fix_Progress[playerid]);
		SetPlayerToFaceVehicle(playerid, fix_TargetVehicle[playerid]);
	}

	return CallLocalFunction("rep_OnHoldActionUpdate", "dd", playerid, progress);
}

#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate rep_OnHoldActionUpdate
forward rep_OnHoldActionUpdate(playerid, progress);

