#include <YSI\y_hooks>


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(GetVehicleModel(vehicleid) != 525)
		return 1;

	if(newkeys == KEY_ACTION)
	{
		new
			Float:vx1,
			Float:vy1,
			Float:vz1,
			Float:vx2,
			Float:vy2,
			Float:vz2;

		GetVehiclePos(vehicleid, vx1, vy1, vz1);

		foreach(new i : veh_Index)
		{
			if(i == vehicleid)
				continue;

			GetVehiclePos(i, vx2, vy2, vz2);

			if(Distance(vx1, vy1, vz1, vx2, vy2, vz2) < 7.0)
			{
				if(IsTrailerAttachedToVehicle(vehicleid))
					DetachTrailerFromVehicle(vehicleid);

				AttachTrailerToVehicle(i, vehicleid);

				break;
			}
		}
	}

	return 1;
}
