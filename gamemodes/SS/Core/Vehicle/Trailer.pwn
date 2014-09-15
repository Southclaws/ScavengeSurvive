#include <YSI\y_hooks>


static
	trl_VehicleTypeHitchSize[MAX_VEHICLE_TYPE] = {-1, ...};


stock SetVehicleTypeTrailerHitch(vehicletype, maxtrailersize)
{
	if(!IsValidVehicleType(vehicletype))
		return 0;

	trl_VehicleTypeHitchSize[vehicletype] = maxtrailersize;

	return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;

	if(newkeys == KEY_ACTION)
		_HandleTrailerTowKey(playerid);

	return 1;
}

_HandleTrailerTowKey(playerid)
{
	new
		vehicleid,
		vehicletype;

	vehicleid = GetPlayerVehicleID(playerid);
	vehicletype = GetVehicleType(vehicleid);

	if(!IsValidVehicleType(vehicletype))
		return 0;

	if(trl_VehicleTypeHitchSize[vehicletype] == -1)
		return 0;

	new
		tmptype,
		Float:vx1,
		Float:vy1,
		Float:vz1,
		Float:size_x1,
		Float:size_y1,
		Float:size_z1,
		Float:vx2,
		Float:vy2,
		Float:vz2,
		Float:size_x2,
		Float:size_y2,
		Float:size_z2;


	GetVehiclePos(vehicleid, vx1, vy1, vz1);
	GetVehicleModelInfo(GetVehicleTypeModel(vehicletype), VEHICLE_MODEL_INFO_SIZE, size_x1, size_y1, size_z1);

	if(IsTrailerAttachedToVehicle(vehicleid))
	{
		DetachTrailerFromVehicle(vehicleid);
		return 1;
	}

	foreach(new i : veh_Index)
	{
		if(i == vehicleid)
			continue;

		tmptype = GetVehicleType(i);

		printf("looping vehicle %d type: %d category %d size %d", i, tmptype, GetVehicleTypeCategory(tmptype), GetVehicleTypeSize(tmptype));

		if(GetVehicleTypeCategory(tmptype) != VEHICLE_CATEGORY_TRAILER)
			continue;

		if(GetVehicleTypeSize(tmptype) != trl_VehicleTypeHitchSize[vehicletype])
			continue;

		GetVehiclePos(i, vx2, vy2, vz2);
		GetVehicleModelInfo(GetVehicleTypeModel(tmptype), VEHICLE_MODEL_INFO_SIZE, size_x2, size_y2, size_z2);

		if(Distance(vx1, vy1, vz1, vx2, vy2, vz2) < size_y1 + size_y2 + 1.0)
		{
			AttachTrailerToVehicle(i, vehicleid);

			break;
		}
	}

	return 1;
}
