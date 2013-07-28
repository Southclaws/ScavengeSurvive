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


enum (<<=1)
{
		veh_Used = 1,
		veh_Occupied,
		veh_Player,
		veh_Dead
}

enum E_VEHICLE_DATA
{
Float:	veh_health,
Float:	veh_Fuel,
		veh_engine,
		veh_panels,
		veh_doors,
		veh_lights,
		veh_tires,
		veh_armour,
		veh_colour1,
		veh_colour2
}


new
			veh_Data				[MAX_SPAWNED_VEHICLES][E_VEHICLE_DATA],
			veh_BitData				[MAX_SPAWNED_VEHICLES],
Iterator:	veh_Index<MAX_SPAWNED_VEHICLES>;

new
			veh_TrunkLock			[MAX_SPAWNED_VEHICLES],
			veh_Area				[MAX_SPAWNED_VEHICLES],
			veh_Container			[MAX_SPAWNED_VEHICLES],
			veh_Owner				[MAX_SPAWNED_VEHICLES][MAX_PLAYER_NAME],
			veh_CurrentModelGroup;

new
			veh_CurrentTrunkVehicle	[MAX_PLAYERS],
Float:		veh_TempHealth			[MAX_PLAYERS],
Float:		veh_TempVelocity		[MAX_PLAYERS];


/*==============================================================================


	Core


==============================================================================*/


CreateNewVehicle(model, Float:x, Float:y, Float:z, Float:r)
{
	if(!(400 <= model < 612))
		return 0;

	new
		vehicleid,
		colour1,
		colour2;

	switch(model)
	{
		case 416, 433, 523, 427, 490, 528, 407, 544, 596, 597, 598, 599, 432, 601:
		{
			colour1 = -1;
			colour2 = -1;
		}
		default:
		{
			colour1 = 128 + random(128);
			colour2 = 128 + random(128);
		}
	}

	if(GetVehicleType(model) == VTYPE_TRAIN)
		vehicleid = AddStaticVehicle(model, x, y, z, r, colour1, colour2);

	else
		vehicleid = CreateVehicle(model, x, y, z, r, colour1, colour2, 86400);

	if(vehicleid >= MAX_SPAWNED_VEHICLES)
	{
		print("ERROR: Vehicle limit reached.");
		DestroyVehicle(vehicleid, 2);
		return 0;
	}

	veh_Data[vehicleid][veh_colour1] = colour1;
	veh_Data[vehicleid][veh_colour2] = colour2;

	CreateVehicleArea(vehicleid);
	GenerateVehicleData(vehicleid);
	UpdateVehicleData(vehicleid);

	return vehicleid;
}

CreateVehicleArea(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z;

	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, x, y, z);

	veh_Area[vehicleid] = CreateDynamicSphere(0.0, 0.0, 0.0, (y / 2.0) + 3.0, 0);
	AttachDynamicAreaToVehicle(veh_Area[vehicleid], vehicleid);

	return 1;
}

RespawnVehicle(vehicleid)
{
	SetVehicleToRespawn(vehicleid);
	UpdateVehicleData(vehicleid);
}

GenerateVehicleData(vehicleid)
{
	new
		model,
		type,
		chance,
		panels,
		doors,
		lights,
		tires;

	model = GetVehicleModel(vehicleid);
	type = GetVehicleType(model);

// Health

	chance = random(100);

	if(chance < 1)
		veh_Data[vehicleid][veh_health] = 500 + random(200);

	else if(chance < 5)
		veh_Data[vehicleid][veh_health] = 400 + random(200);

	else
		veh_Data[vehicleid][veh_health] = 300 + random(200);

	SetVehicleHealth(vehicleid, veh_Data[vehicleid][veh_health]);

// Fuel

	chance = random(100);

	if(chance < 1)
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[model-400][veh_maxFuel] / 2 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 2);

	else if(chance < 5)
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[model-400][veh_maxFuel] / 4 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 3);

	else if(chance < 10)
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[model-400][veh_maxFuel] / 8 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 4);

	else
		veh_Data[vehicleid][veh_Fuel] = frandom(1.0);

// Visual Damage

	if(type < VTYPE_BICYCLE)
	{
		veh_Data[vehicleid][veh_panels]	= encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4));
		veh_Data[vehicleid][veh_doors]	= encode_doors(random(5), random(5), random(5), random(5));
		veh_Data[vehicleid][veh_lights] = encode_lights(random(2), random(2), random(2), random(2));
		veh_Data[vehicleid][veh_tires] = encode_tires(random(2), random(2), random(2), random(2));

		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	}
	if(type == VTYPE_PLANE)
	{
		veh_Data[vehicleid][veh_panels]	= encode_panels(0, 0, random(4), 0, random(4), 0, 0);
	}


// Locks

	if(VehicleFuelData[model - 400][veh_maxFuel] == 0.0)
	{
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
	}
	else
	{
		new locked;

		if(doors == 0)
			locked = random(2);

		if(panels == 0)
			veh_TrunkLock[vehicleid] = random(2);

		SetVehicleParamsEx(vehicleid, 0, random(2), !random(100), locked, random(2), random(2), 0);
	}

// Putting loot in trunks

	if(VehicleFuelData[model - 400][veh_lootIndex] != -1 && 0 < VehicleFuelData[model - 400][veh_trunkSize] <= CNT_MAX_SLOTS)
	{
		veh_Container[vehicleid] = CreateContainer("Trunk", VehicleFuelData[model-400][veh_trunkSize], .virtual = 1);
		FillContainerWithLoot(veh_Container[vehicleid], random(4), VehicleFuelData[model-400][veh_lootIndex]);
	}
	else
	{
		veh_Container[vehicleid] = INVALID_CONTAINER_ID;
	}

// Number plate

	SetVehicleNumberPlate(vehicleid, RandomNumberPlateString());
}

UpdateVehicleData(vehicleid)
{
	SetVehicleHealth(vehicleid, veh_Data[vehicleid][veh_health]);

	UpdateVehicleDamageStatus(vehicleid, veh_Data[vehicleid][veh_panels], veh_Data[vehicleid][veh_doors], veh_Data[vehicleid][veh_lights], veh_Data[vehicleid][veh_tires]);

	if(GetVehicleType(GetVehicleModel(vehicleid)) == VTYPE_BICYCLE)
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);

	else
		SetVehicleParamsEx(vehicleid, 0, 0, 0, 0, 0, 0, 0);

	return 1;
}

IsPlayerAtVehicleTrunk(playerid, vehicleid)
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

IsPlayerAtVehicleBonnet(playerid, vehicleid)
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


/*==============================================================================


	Hooks and Internal


==============================================================================*/


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
							veh_CurrentTrunkVehicle[playerid] = i;

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

	if(oldstate == PLAYER_STATE_DRIVER && IsPlayerOnAdminDuty(playerid))
	{
		new name[MAX_PLAYER_NAME];

		GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		SavePlayerVehicle(GetPlayerLastVehicle(playerid), name);
		SetCameraBehindPlayer(playerid);
	}

	return 1;
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidVehicleID(veh_CurrentTrunkVehicle[playerid]))
	{
		if(containerid == GetVehicleContainer(veh_CurrentTrunkVehicle[playerid]))
		{
			new
				engine,
				lights,
				alarm,
				doors,
				bonnet,
				boot,
				objective;

			GetVehicleParamsEx(veh_CurrentTrunkVehicle[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(veh_CurrentTrunkVehicle[playerid], engine, lights, alarm, doors, bonnet, 0, objective);

			veh_CurrentTrunkVehicle[playerid] = INVALID_VEHICLE_ID;
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
	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return 1;

	return CallLocalFunction("veh_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem veh_OnPlayerUseItem
forward veh_OnPlayerUseItem(playerid, itemid);

public OnItemAddedToContainer(containerid, itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsValidVehicleID(veh_CurrentTrunkVehicle[playerid]))
		{
			new
				owner[MAX_PLAYER_NAME],
				name[MAX_PLAYER_NAME];

			GetVehicleOwner(veh_CurrentTrunkVehicle[playerid], owner);
			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			if(!isnull(owner) && !strcmp(owner, name))
			{
				SavePlayerVehicle(veh_CurrentTrunkVehicle[playerid], name);
			}
		}
	}

	return CallLocalFunction("veh_OnItemAddedToContainer", "ddd", containerid, itemid, playerid);
}
#if defined _ALS_OnItemAddedToContainer
	#undef OnItemAddedToContainer
#else
	#define _ALS_OnItemAddedToContainer
#endif
#define OnItemAddedToContainer veh_OnItemAddedToContainer
forward veh_OnItemAddedToContainer(containerid, itemid, playerid);

public OnItemRemovedFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsValidVehicleID(veh_CurrentTrunkVehicle[playerid]))
		{
			if(IsValidVehicleID(veh_CurrentTrunkVehicle[playerid]))
			{
				new
					owner[MAX_PLAYER_NAME],
					name[MAX_PLAYER_NAME];

				GetVehicleOwner(veh_CurrentTrunkVehicle[playerid], owner);
				GetPlayerName(playerid, name, MAX_PLAYER_NAME);

				if(!isnull(owner) && !strcmp(owner, name))
				{
					SavePlayerVehicle(veh_CurrentTrunkVehicle[playerid], name);
				}
			}
		}
	}

	return CallLocalFunction("veh_OnItemRemovedFromContainer", "ddd", containerid, slotid, playerid);
}
#if defined _ALS_OnItemRemovedFromContainer
	#undef OnItemRemovedFromContainer
#else
	#define _ALS_OnItemRemovedFromContainer
#endif
#define OnItemRemovedFromContainer veh_OnItemRemovedFromContainer
forward veh_OnItemRemovedFromContainer(containerid, slotid, playerid);

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	GetVehicleDamageStatus(vehicleid,
		veh_Data[vehicleid][veh_panels],
		veh_Data[vehicleid][veh_doors],
		veh_Data[vehicleid][veh_lights],
		veh_Data[vehicleid][veh_tires]);
}


/*==============================================================================


	Interface


==============================================================================*/


stock IsPlayerInVehicleArea(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	if(!IsValidVehicleID(vehicleid))
		return 0;

	return IsPlayerInDynamicArea(playerid, veh_Area[vehicleid]);
}

stock GetPlayerVehicleArea(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	foreach(new i : veh_Index)
	{
		if(IsPlayerInDynamicArea(playerid, veh_Area[i]))
			return i;
	}

	return INVALID_VEHICLE_ID;
}

forward Float:GetVehicleFuelCapacity(vehicleid);
stock Float:GetVehicleFuelCapacity(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0.0;

	return VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];
}

forward Float:GetVehicleFuel(vehicleid);
stock Float:GetVehicleFuel(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0.0;

	if(veh_Data[vehicleid][veh_Fuel] < 0.0)
		veh_Data[vehicleid][veh_Fuel] = 0.0;

	return veh_Data[vehicleid][veh_Fuel];
}

stock SetVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(amount > VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel])
		amount = VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];

	veh_Data[vehicleid][veh_Fuel] = amount;

	return 1;
}

stock GiveVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_Fuel] += amount;

	if(veh_Data[vehicleid][veh_Fuel] > VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel])
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];

	return 1;
}

stock GetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME])
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	name = veh_Owner[vehicleid];

	return 1;
}

stock GetVehicleContainer(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return INVALID_CONTAINER_ID;

	return veh_Container[vehicleid];
}

stock SetVehicleContainer(vehicleid, containerid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_Container[vehicleid] = containerid;

	return 1;
}

stock IsVehicleTrunkLocked(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	return veh_TrunkLock[vehicleid];
}

stock SetVehicleTrunkLock(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_TrunkLock[vehicleid] = toggle;
	return 1;
}

stock SetVehicleUsed(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(toggle)
		t:veh_BitData[vehicleid]<veh_Used>;

	else
		f:veh_BitData[vehicleid]<veh_Used>;

	return 1;
}

stock SetVehicleOccupied(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(toggle)
		t:veh_BitData[vehicleid]<veh_Occupied>;

	else
		f:veh_BitData[vehicleid]<veh_Occupied>;

	return 1;
}

stock GetVehicleArea(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return -1;

	return veh_Area[vehicleid];
}

stock IsVehicleOccupied(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	return veh_BitData[vehicleid] & veh_Occupied;
}

stock IsValidVehicleID(vehicleid)
{
	if(IsValidVehicle(vehicleid) && vehicleid < MAX_SPAWNED_VEHICLES)
		return 1;

	return 0;
}

stock GetVehicleEngine(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_engine];
}

stock SetVehicleEngine(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_engine] = toggle;
	VehicleEngineState(vehicleid, toggle);

	return 1;
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

