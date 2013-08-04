#include <YSI\y_hooks>


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;

	if(GetVehicleModel(gPlayerData[playerid][ply_CurrentVehicle]) != 525)
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

		GetVehiclePos(gPlayerData[playerid][ply_CurrentVehicle], vx1, vy1, vz1);

		foreach(new i : veh_Index)
		{
			if(i == gPlayerData[playerid][ply_CurrentVehicle])
				continue;

			GetVehiclePos(i, vx2, vy2, vz2);

			if(Distance(vx1, vy1, vz1, vx2, vy2, vz2) < 7.0)
			{
				if(IsTrailerAttachedToVehicle(gPlayerData[playerid][ply_CurrentVehicle]))
					DetachTrailerFromVehicle(gPlayerData[playerid][ply_CurrentVehicle]);

				AttachTrailerToVehicle(i, gPlayerData[playerid][ply_CurrentVehicle]);

				break;
			}
		}
	}

	return 1;
}
