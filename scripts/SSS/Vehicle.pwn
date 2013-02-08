#include <YSI\y_hooks>


new IsAtVehicleBonnet[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
		return 0;

	if(newkeys == 16)
	{
		new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

		if(itemtype == item_Satchel || itemtype == item_Backpack || itemtype == item_Briefcase)
			return 1;

		foreach(new i : gVehicleIndex)
		{
			if(IsPlayerInDynamicArea(playerid, gVehicleArea[i]))
			{
				new
					Float:px,
					Float:py,
					Float:pz,
					Float:vx,
					Float:vy,
					Float:vz,
					Float:vr,
					Float:angle;

				GetPlayerPos(playerid, px, py, pz);
				GetVehiclePos(i, vx, vy, vz);
				GetVehicleZAngle(i, vr);

				angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

				if(angle < 25.0 || angle > 335.0)
				{
					new Float:vehiclehealth;

					GetVehicleHealth(i, vehiclehealth);

					if(GetItemType(GetPlayerItem(playerid)) == item_Wrench)
					{
						if(250.0 <= vehiclehealth < 450.0 || 800.0 <= vehiclehealth < 1000.0)
						{
							SetPlayerPos(playerid, px, py, pz);
							StartRepairingVehicle(playerid, i);
							break;
						}
						else
						{
							ShowMsgBox(playerid, "You need another tool", 3000, 100);
						}
					}	
					else if(GetItemType(GetPlayerItem(playerid)) == item_Screwdriver)
					{
						if(450.0 <= vehiclehealth < 650.0)
						{
							SetPlayerPos(playerid, px, py, pz);
							StartRepairingVehicle(playerid, i);
							break;
						}
						else
						{
							ShowMsgBox(playerid, "You need another tool", 3000, 100);
						}
					}	
					else if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
					{
						if(650.0 <= vehiclehealth < 800.0)
						{
							SetPlayerPos(playerid, px, py, pz);
							StartRepairingVehicle(playerid, i);
							break;
						}
						else
						{
							ShowMsgBox(playerid, "You need another tool", 3000, 100);
						}
					}
					else if(GetItemType(GetPlayerItem(playerid)) == item_Wheel)
					{
						ShowTireList(playerid, i);
					}
					else if(GetItemType(GetPlayerItem(playerid)) == item_GasCan)
					{
						StartRefuellingVehicle(playerid, i);
					}
					else
					{
						ShowMsgBox(playerid, "You don't have the right tool", 3000, 100);
					}
				}
				if(155.0 < angle < 205.0)
				{
					if(IsValidContainer(gVehicleContainer[i]))
					{
						if(gVehicleTrunkLocked[i])
						{
							if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
							{
								StartBreakingVehicleLock(playerid, i, 1);
							}
						}
						else
						{
							new
								engine,
								lights,
								alarm,
								doors,
								bonnet,
								boot,
								objective;

							GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
							SetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, 1, objective);

							SetPlayerPos(playerid, px, py, pz);
							SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

							DisplayContainerInventory(playerid, gVehicleContainer[i]);
							gCurrentContainerVehicle[playerid] = i;

							break;
						}
					}
				}
				if(225.0 < angle < 315.0)
				{
					if(GetVehicleModel(i) == 449)
					{
						PutPlayerInVehicle(playerid, i, 0);
					}
					if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
					{
						StartBreakingVehicleLock(playerid, i, 0);
					}
				}
			}
		}
	}
	if(oldkeys == 16)
	{
		StopRepairingVehicle(playerid);
		StopRefuellingVehicle(playerid);
		StopBreakingVehicleLock(playerid);
	}

	return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : gVehicleIndex)
	{
		if(areaid == gVehicleArea[i])
		{
			new
				Float:vx,
				Float:vy,
				Float:vz,
				Float:px,
				Float:py,
				Float:pz,
				Float:sx,
				Float:sy,
				Float:sz,
				Float:vr,
				Float:angle;

			GetVehiclePos(i, vx, vy, vz);
			GetPlayerPos(playerid, px, py, pz);
			GetVehicleModelInfo(GetVehicleModel(i), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

			GetVehicleZAngle(i, vr);

			angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

			if(155.0 < angle < 205.0)
			{
				if(IsValidContainer(gVehicleContainer[i]))
					ShowMsgBox(playerid, "Press ~k~~VEHICLE_ENTER_EXIT~ to open trunk", 3000, 100);
			}
			if(-25.0 < angle < 25.0 || 335.0 < angle < 385.0)
			{
				IsAtVehicleBonnet[playerid] = 1;
			}
		}
	}

	return CallLocalFunction("veh_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea veh_OnPlayerEnterDynamicArea
forward veh_OnPlayerEnterDynamicArea(playerid, containerid);

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	foreach(new i : gVehicleIndex)
	{
		if(areaid == gVehicleArea[i])
		{
			IsAtVehicleBonnet[playerid] = 0;
		}
	}
	return CallLocalFunction("veh_OnPlayerLeaveDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea veh_OnPlayerLeaveDynamicArea
forward veh_OnPlayerLeaveDynamicArea(playerid, containerid);

IsPlayerAtAnyVehicleBonnet(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	return IsAtVehicleBonnet[playerid];
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
	{
		if(containerid == gVehicleContainer[gCurrentContainerVehicle[playerid]])
		{
			new
				engine,
				lights,
				alarm,
				doors,
				bonnet,
				boot,
				objective;

			GetVehicleParamsEx(gCurrentContainerVehicle[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(gCurrentContainerVehicle[playerid], engine, lights, alarm, doors, bonnet, 0, objective);

			gCurrentContainerVehicle[playerid] = INVALID_VEHICLE_ID;
		}
	}
	return CallLocalFunction("veh_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer veh_OnPlayerCloseContainer
forward veh_OnPlayerCloseContainer(playerid, containerid);

forward Float:GetVehicleFuelCapacity(vehicleid);
Float:GetVehicleFuelCapacity(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0.0;

	return VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];
}

forward Float:GetVehicleFuel(vehicleid);
Float:GetVehicleFuel(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0.0;

	return gVehicleFuel[vehicleid];
}
SetVehicleFuel(vehicleid, Float:fuel)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	gVehicleFuel[vehicleid] = fuel;

	if(gVehicleFuel[vehicleid] > VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel])
		gVehicleFuel[vehicleid] = VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];

	return 1;
}

IsVehicleTrunkLocked(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return gVehicleTrunkLocked[vehicleid];
}
SetVehicleTrunkLock(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	gVehicleTrunkLocked[vehicleid] = toggle;
	return 1;
}
