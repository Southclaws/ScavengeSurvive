#include <YSI\y_hooks>


#define VEHICLE_HEALTH_MIN					(250.0)
#define VEHICLE_HEALTH_CHUNK_1				(300.0)
#define VEHICLE_HEALTH_CHUNK_2				(450.0)
#define VEHICLE_HEALTH_CHUNK_3				(650.0)
#define VEHICLE_HEALTH_CHUNK_4				(800.0)
#define VEHICLE_HEALTH_MAX					(990.0)

#define VEHICLE_HEALTH_CHUNK_1_COLOUR		0xFF0000FF
#define VEHICLE_HEALTH_CHUNK_2_COLOUR		0xFF7700FF
#define VEHICLE_HEALTH_CHUNK_3_COLOUR		0xFFFF00FF
#define VEHICLE_HEALTH_CHUNK_4_COLOUR		0x808000FF

#define VEHICLE_UI_INACTIVE					0xFF0000FF
#define VEHICLE_UI_ACTIVE					0x808000FF


new
Float:	veh_TempHealth[MAX_PLAYERS],
Float:	veh_TempVelocity[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(newkeys & KEY_YES)
		{
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
				new Float:health;
				GetVehicleHealth(vehicleid, health);

				if(VehicleFuelData[GetVehicleModel(vehicleid)-400][veh_maxFuel] > 0.0)
				{
					if(health >= 300.0)
					{
						if(GetVehicleFuel(vehicleid) > 0.0)
							SetVehicleEngine(vehicleid, !GetVehicleEngine(vehicleid));
					}
				}
			}
		}
		if(newkeys & KEY_NO)
		{
			VehicleLightsState(vehicleid, !VehicleLightsState(vehicleid));
		}
		if(newkeys & KEY_CTRL_BACK)//262144)
		{
			ShowRadioUI(playerid);
		}
		if(newkeys & KEY_SUBMISSION)
		{
			VehicleDoorsState(vehicleid, !VehicleDoorsState(vehicleid));
		}

		return 1;
	}

	if(newkeys == 16)
	{
		foreach(new i : veh_Index)
		{
			if(IsPlayerInDynamicArea(playerid, GetVehicleArea(i)))
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
						if(vehiclehealth <= VEHICLE_HEALTH_CHUNK_2 || VEHICLE_HEALTH_CHUNK_4 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_MAX)
						{
							SetPlayerPos(playerid, px, py, pz);
							StartRepairingVehicle(playerid, i);
							break;
						}
						else
						{
							ShowActionText(playerid, "You need another tool", 3000, 100);
						}
					}	
					else if(GetItemType(GetPlayerItem(playerid)) == item_Screwdriver)
					{
						if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_3)
						{
							SetPlayerPos(playerid, px, py, pz);
							StartRepairingVehicle(playerid, i);
							break;
						}
						else
						{
							ShowActionText(playerid, "You need another tool", 3000, 100);
						}
					}	
					else if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
					{
						if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_4)
						{
							SetPlayerPos(playerid, px, py, pz);
							StartRepairingVehicle(playerid, i);
							break;
						}
						else
						{
							ShowActionText(playerid, "You need another tool", 3000, 100);
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
						ShowActionText(playerid, "You don't have the right tool", 3000, 100);
					}
				}
				if(155.0 < angle < 205.0)
				{
					if(IsValidContainer(GetVehicleContainer(i)))
					{
						if(IsVehicleTrunkLocked(i))
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

							DisplayContainerInventory(playerid, GetVehicleContainer(i));
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

	if(GetVehicleType(model) == VTYPE_BICYCLE || model == 0)
		return;

	GetVehicleHealth(vehicleid, health);

	if(veh_TempHealth[playerid] > 300.0)
	{
		new Float:diff = veh_TempHealth[playerid] - health;

		if(diff > 10.0 && veh_TempHealth[playerid] < VEHICLE_HEALTH_MAX)
		{
			health += diff * 0.8;
			SetVehicleHealth(vehicleid, health);
		}
	}

	if(floatabs(veh_TempVelocity[playerid] - GetPlayerTotalVelocity(playerid)) > ((GetVehicleType(model) == VTYPE_BICYCLE) ? 55.0 : 45.0))
	{
		GivePlayerHP(playerid, -(floatabs(veh_TempVelocity[playerid] - GetPlayerTotalVelocity(playerid)) * 0.1));
	}

	if(health <= VEHICLE_HEALTH_CHUNK_1)
		PlayerTextDrawColor(playerid, VehicleDamageText, VEHICLE_HEALTH_CHUNK_1_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_2)
		PlayerTextDrawColor(playerid, VehicleDamageText, VEHICLE_HEALTH_CHUNK_1_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_3)
		PlayerTextDrawColor(playerid, VehicleDamageText, VEHICLE_HEALTH_CHUNK_2_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_4)
		PlayerTextDrawColor(playerid, VehicleDamageText, VEHICLE_HEALTH_CHUNK_3_COLOUR);

	else if(health <= VEHICLE_HEALTH_MAX)
		PlayerTextDrawColor(playerid, VehicleDamageText, VEHICLE_HEALTH_CHUNK_4_COLOUR);

	if(VehicleFuelData[model - 400][veh_maxFuel] > 0.0) // If the vehicle is a fuel powered vehicle
	{
		new
			Float:fuel = GetVehicleFuel(vehicleid),
			str[18];

		if(fuel <= 0.0)
		{
			SetVehicleEngine(vehicleid, 0);
			PlayerTextDrawColor(playerid, VehicleEngineText, VEHICLE_UI_INACTIVE);
		}

		format(str, 18, "%.2fL/%.2f", GetVehicleFuel(vehicleid), VehicleFuelData[model - 400][veh_maxFuel]);
		PlayerTextDrawSetString(playerid, VehicleFuelText, str);
		PlayerTextDrawShow(playerid, VehicleFuelText);

		if(GetVehicleEngine(vehicleid))
		{
			if(fuel > 0.0)
				fuel -= ((VehicleFuelData[model - 400][veh_fuelCons] / 100) * (((GetPlayerTotalVelocity(playerid)/60)/60)/10) + 0.0001);

			SetVehicleFuel(vehicleid, fuel);
			PlayerTextDrawColor(playerid, VehicleEngineText, VEHICLE_UI_ACTIVE);

			if(health <= VEHICLE_HEALTH_CHUNK_1)
			{
				SetVehicleEngine(vehicleid, 0);
				PlayerTextDrawColor(playerid, VehicleEngineText, VEHICLE_UI_INACTIVE);
			}
			else if(health <= VEHICLE_HEALTH_CHUNK_2 && GetPlayerTotalVelocity(playerid) > 1.0)
			{
				new Float:enginechance = (20 - ((health - VEHICLE_HEALTH_CHUNK_2) / 3));

				SetVehicleHealth(vehicleid, health - ((VEHICLE_HEALTH_CHUNK_1 - (health - VEHICLE_HEALTH_CHUNK_1)) / 1000.0));

				if(VehicleEngineState(vehicleid) && GetPlayerTotalVelocity(playerid) > 30.0)
				{
					if(random(100) < enginechance)
					{
						VehicleEngineState(vehicleid, 0);
						PlayerTextDrawColor(playerid, VehicleEngineText, VEHICLE_UI_INACTIVE);
					}
				}
				else
				{
					if(random(100) < 100 - enginechance)
					{
						VehicleEngineState(vehicleid, 1);
						PlayerTextDrawColor(playerid, VehicleEngineText, VEHICLE_UI_ACTIVE);
					}
				}
			}
		}
		else
		{
			PlayerTextDrawColor(playerid, VehicleEngineText, VEHICLE_UI_INACTIVE);
		}
	}
	else
	{
		PlayerTextDrawHide(playerid, VehicleFuelText);
	}

	if(VehicleHasDoors(model))
	{
		if(VehicleDoorsState(vehicleid))
			PlayerTextDrawColor(playerid, VehicleDoorsText, VEHICLE_UI_ACTIVE);

		else
			PlayerTextDrawColor(playerid, VehicleDoorsText, VEHICLE_UI_INACTIVE);

		PlayerTextDrawShow(playerid, VehicleDoorsText);
	}
	else
	{
		PlayerTextDrawHide(playerid, VehicleDoorsText);
	}

	PlayerTextDrawShow(playerid, VehicleDamageText);
	PlayerTextDrawShow(playerid, VehicleEngineText);

	switch(GetPlayerWeapon(playerid))
	{
		case 28, 29, 32:
		{
			if(tickcount() - GetPlayerVehicleExitTick(playerid) > 3000 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				SetPlayerArmedWeapon(playerid, 0);
		}
	}

	veh_TempVelocity[playerid] = GetPlayerTotalVelocity(playerid);
	veh_TempHealth[playerid] = health;

	return;
}

VehicleSurfingCheck(playerid)
{
	new
		vehicleid = GetPlayerSurfingVehicleID(playerid),
		Float:vx,
		Float:vy,
		Float:vz,
		Float:velocity;

	GetVehicleVelocity(vehicleid, vx, vy, vz);
	velocity = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;

	if(velocity > 40.0)
	{
		if(!IsPlayerKnockedOut(playerid))
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(playerid, x, y, z);
			SetPlayerPos(playerid, x, y, z + 1.0);

			SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
			GivePlayerHP(playerid, -frandom(5.0));

			KnockOutPlayer(playerid, 3000);
		}
	}
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	veh_TempHealth[playerid] = 0.0;
	veh_TempVelocity[playerid] = 0.0;

	if(newstate == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(GetVehicleType(GetVehicleModel(vehicleid)) == VTYPE_BICYCLE)
			VehicleEngineState(vehicleid, 1);
	}

	return 1;
}

stock IsPlayerAtVehicleTrunk(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(!IsPlayerInDynamicArea(playerid, GetVehicleArea(vehicleid)))
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

stock IsPlayerAtVehicleBonnet(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(!IsPlayerInDynamicArea(playerid, GetVehicleArea(vehicleid)))
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

stock IsPlayerAtAnyVehicleTrunk(playerid)
{
	foreach(new i : veh_Index)
	{
		if(IsPlayerAtVehicleTrunk(playerid, i))
			return 1;
	}

	return 0;
}

stock IsPlayerAtAnyVehicleBonnet(playerid)
{
	foreach(new i : veh_Index)
	{
		if(IsPlayerAtVehicleBonnet(playerid, i))
			return 1;
	}

	return 0;
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidVehicleID(gCurrentContainerVehicle[playerid]))
	{
		if(containerid == GetVehicleContainer(gCurrentContainerVehicle[playerid]))
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
	foreach(new i : veh_Index)
	{
		if(IsPlayerInDynamicArea(playerid, GetVehicleArea(i)))
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

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	GetVehicleDamageStatus(vehicleid,
		veh_Data[vehicleid][veh_panels],
		veh_Data[vehicleid][veh_doors],
		veh_Data[vehicleid][veh_lights],
		veh_Data[vehicleid][veh_tires]);
}
