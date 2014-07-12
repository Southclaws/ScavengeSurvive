#include <YSI\y_hooks>


static
	CollisionVehicle[MAX_PLAYERS],
	CollisionObject[MAX_PLAYERS];


hook OnPlayerDisconnect(playerid)
{
	CollisionVehicle[playerid] = INVALID_VEHICLE_ID;
	DestroyObject(CollisionObject[playerid]);
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleid,
			vehicletypecategory;

		vehicleid = GetPlayerVehicleID(playerid);
		vehicletypecategory = GetVehicleTypeCategory(GetVehicleType(vehicleid));

		if(vehicletypecategory == VEHICLE_CATEGORY_PUSHBIKE || vehicletypecategory == VEHICLE_CATEGORY_MOTORBIKE)
		{
			CollisionVehicle[playerid] = vehicleid;
			CollisionObject[playerid] = CreateObject(0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0);
			AttachObjectToVehicle(CollisionObject[playerid], CollisionVehicle[playerid], 0.0, 0.6, 1.2, 0.0, 0.0, 0.0);
		}

		return 1;
	}

	if(oldstate == PLAYER_STATE_DRIVER)
	{
		if(CollisionVehicle[playerid] != INVALID_VEHICLE_ID)
		{
			new vehicletypecategory = GetVehicleTypeCategory(GetVehicleType(CollisionVehicle[playerid]));

			if(vehicletypecategory == VEHICLE_CATEGORY_PUSHBIKE || vehicletypecategory == VEHICLE_CATEGORY_MOTORBIKE)
			{
				DestroyObject(CollisionObject[playerid]);
				CollisionVehicle[playerid] = INVALID_VEHICLE_ID;
				CollisionObject[playerid] = INVALID_OBJECT_ID;
			}
		}

		return 1;
	}

	return 1;
}
