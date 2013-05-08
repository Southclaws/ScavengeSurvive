#include <YSI\y_hooks>


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid) || bPlayerGameSettings[playerid] & KnockedOut)
		return 0;

	if(newkeys == 16)
	{
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
						if(250.0 <= vehiclehealth <= 450.0 || 750.0 <= vehiclehealth <= 990.0)
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
						if(450.0 <= vehiclehealth <= 600.0)
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
						if(600.0 <= vehiclehealth <= 750.0)
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
						SetPlayerPos(playerid, px, py, pz);
						ShowTireList(playerid, i);
					}
					else if(GetItemType(GetPlayerItem(playerid)) == item_GasCan)
					{
						SetPlayerPos(playerid, px, py, pz);
						StartRefuellingVehicle(playerid, i);
					}
					else if(GetItemType(GetPlayerItem(playerid)) == item_Headlight)
					{
						SetPlayerPos(playerid, px, py, pz);
						ShowLightList(playerid, i);
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

PlayerVehicleUpdate(playerid)
{
	new
		vehicleid = GetPlayerVehicleID(playerid),
		model = GetVehicleModel(vehicleid),
		Float:health;

	if(GetVehicleType(model) != VTYPE_BMX && model != 0)
	{
		GetVehicleHealth(vehicleid, health);

		if(health > 1000.0)
		{
			SetVehicleHealth(vehicleid, 1000.0);
			health = 1000.0;
		}

		if(0.0 < health <= 300.0)
			PlayerTextDrawColor(playerid, VehicleDamageText, 0xFF0000FF);

		if(300.0 < health <= 450.0)
			PlayerTextDrawColor(playerid, VehicleDamageText, 0xFF3F00FF);

		if(450.0 < health <= 650.0)
			PlayerTextDrawColor(playerid, VehicleDamageText, 0xFF7F00FF);

		if(650.0 < health <= 800.0)
			PlayerTextDrawColor(playerid, VehicleDamageText, 0xFFBF00FF);

		if(800.0 < health <= 1000.0)
			PlayerTextDrawColor(playerid, VehicleDamageText, 0xFFFF00FF);

		if(300.0 < health < 500.0)
		{
			if(VehicleEngineState(vehicleid) && gPlayerVelocity[playerid] > 30.0)
			{
				if(random(100) < (50 - ((health - 400.0) / 4)))
				{
					if(health < 400.0)
						VehicleEngineState(vehicleid, 0);
	
					SetVehicleHealth(vehicleid, health - (((200 - (health - 300.0)) / 100.0) / 2.0));
				}
			}
			else
			{
				if(random(100) < 100 - (50 - ((health - 400.0) / 4)))
				{
					if(health < 400.0)
						VehicleEngineState(vehicleid, 1);
				}
			}
		}

		if(VehicleEngineState(vehicleid) && VehicleFuelData[model - 400][veh_maxFuel] > 0.0)
		{
			if(health < 300.0 || gVehicleFuel[vehicleid] <= 0.0)
			{
				VehicleEngineState(vehicleid, 0);
				PlayerTextDrawColor(playerid, VehicleEngineText, RED);
			}
			else
			{
				if(gVehicleFuel[vehicleid] > 0.0)
				{
					gVehicleFuel[vehicleid] -= ((VehicleFuelData[model - 400][veh_fuelCons] / 100) * (((gPlayerVelocity[playerid]/60)/60)/10) + 0.0001);
				}

				switch(GetPlayerWeapon(playerid))
				{
					case 28, 29, 32:
					{
						if(tickcount() - tick_ExitVehicle[playerid] > 3000 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
							SetPlayerArmedWeapon(playerid, 0);
					}
				}

				PlayerTextDrawColor(playerid, VehicleEngineText, 0xFFFF00FF);
			}
		}
		else
		{
			PlayerTextDrawColor(playerid, VehicleEngineText, RED);
		}

		if(VehicleDoorsState(vehicleid))
		{
			PlayerTextDrawColor(playerid, VehicleDoorsText, 0xFFFF00FF);
		}
		else
		{
			PlayerTextDrawColor(playerid, VehicleDoorsText, RED);
		}

		new str[18];
		format(str, 18, "%.2fL/%.2f", gVehicleFuel[vehicleid], VehicleFuelData[model - 400][veh_maxFuel]);
		PlayerTextDrawSetString(playerid, VehicleFuelText, str);

		PlayerTextDrawShow(playerid, VehicleFuelText);
		PlayerTextDrawShow(playerid, VehicleDamageText);
		PlayerTextDrawShow(playerid, VehicleEngineText);
		PlayerTextDrawShow(playerid, VehicleDoorsText);

		if(floatabs(gCurrentVelocity[playerid] - gPlayerVelocity[playerid]) > ((GetVehicleType(model) == VTYPE_BMX) ? 55.0 : 45.0))
		{
			GivePlayerHP(playerid, -(floatabs(gCurrentVelocity[playerid] - gPlayerVelocity[playerid]) * 0.1));
		}

		gCurrentVelocity[playerid] = gPlayerVelocity[playerid];
	}
}

IsPlayerAtVehicleTrunk(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidVehicle(vehicleid))
		return 0;

	if(!IsPlayerInDynamicArea(playerid, gVehicleArea[vehicleid]))
		return 0;

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

	GetVehiclePos(vehicleid, vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);
	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

	GetVehicleZAngle(vehicleid, vr);

	angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

	if(155.0 < angle < 205.0)
	{
		return 1;
	}

	return 0;
}

IsPlayerAtVehicleBonnet(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidVehicle(vehicleid))
		return 0;

	if(!IsPlayerInDynamicArea(playerid, gVehicleArea[vehicleid]))
		return 0;

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

	GetVehiclePos(vehicleid, vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);
	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

	GetVehicleZAngle(vehicleid, vr);

	angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

	if(-25.0 < angle < 25.0 || 335.0 < angle < 385.0)
	{
		return 1;
	}

	return 0;
}

IsPlayerAtAnyVehicleTrunk(playerid)
{
	foreach(new i : gVehicleIndex)
	{
		if(IsPlayerAtVehicleTrunk(playerid, i))
			return 1;
	}

	return 0;
}

IsPlayerAtAnyVehicleBonnet(playerid)
{
	foreach(new i : gVehicleIndex)
	{
		if(IsPlayerAtVehicleBonnet(playerid, i))
			return 1;
	}

	return 0;
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

public OnPlayerUseItem(playerid, itemid)
{
	foreach(new i : gVehicleIndex)
	{
		if(IsPlayerInDynamicArea(playerid, gVehicleArea[i]))
		{
			return 1;
		}
	}

	return CallLocalFunction("veh_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem veh_OnPlayerUseItem
forward veh_OnPlayerUseItem(playerid, itemid);



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
