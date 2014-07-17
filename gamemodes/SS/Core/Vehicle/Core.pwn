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
		veh_key,
		veh_engine,
		veh_panels,
		veh_doors,
		veh_lights,
		veh_tires,
		veh_armour,
		veh_colour1,
		veh_colour2,
Float:	veh_spawnX,
Float:	veh_spawnY,
Float:	veh_spawnZ,
Float:	veh_spawnR,

		veh_lastUsed
}


new
			veh_Data				[MAX_VEHICLES][E_VEHICLE_DATA],
			veh_BitData				[MAX_VEHICLES],
Iterator:	veh_Index<MAX_VEHICLES>,
			veh_ContainerVehicle	[CNT_MAX];

new
			veh_TrunkLock			[MAX_VEHICLES],
			veh_Area				[MAX_VEHICLES],
			veh_Container			[MAX_VEHICLES],
			veh_Owner				[MAX_VEHICLES][MAX_PLAYER_NAME];

new
			veh_CurrentTrunkVehicle	[MAX_PLAYERS],
Float:		veh_TempHealth			[MAX_PLAYERS],
Float:		veh_TempVelocity		[MAX_PLAYERS],
			veh_Entering			[MAX_PLAYERS],
			veh_EnterTick			[MAX_PLAYERS];


forward OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);


hook OnGameModeInit()
{
	for(new i; i < CNT_MAX; i++)
		veh_ContainerVehicle[i] = INVALID_VEHICLE_ID;
}


/*==============================================================================


	Core


==============================================================================*/


CreateNewVehicle(type, Float:x, Float:y, Float:z, Float:r)
{
	new
		vehicleid,
		model,
		colour1,
		colour2;

	model = GetVehicleTypeModel(type);

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

	vehicleid = CreateVehicleOfType(type, x, y, z, r, colour1, colour2);
	SetVehicleEngine(vehicleid, 0);

	if(vehicleid >= MAX_VEHICLES)
	{
		print("ERROR: Vehicle limit reached.");
		DestroyVehicle(vehicleid, 2);
		return 0;
	}

	Iter_Add(veh_Index, vehicleid);

	veh_Data[vehicleid][veh_colour1] = colour1;
	veh_Data[vehicleid][veh_colour2] = colour2;

	CreateVehicleArea(vehicleid);
	GenerateVehicleData(vehicleid);
	UpdateVehicleData(vehicleid);
	SetVehicleSpawnPoint(vehicleid, x, y, z, r);

	return vehicleid;
}

CreateVehicleArea(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
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
		type,
		category,
		Float:maxfuel,
		lootindex,
		trunksize,
		chance,
		panels,
		doors,
		lights,
		tires;

	type = GetVehicleType(vehicleid);
	category = GetVehicleTypeCategory(type);
	maxfuel = GetVehicleTypeMaxFuel(type);
	lootindex = GetVehicleTypeLootIndex(type);
	trunksize = GetVehicleTypeTrunkSize(type);

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
		veh_Data[vehicleid][veh_Fuel] = maxfuel / 2 + frandom(maxfuel / 2);

	else if(chance < 5)
		veh_Data[vehicleid][veh_Fuel] = maxfuel / 4 + frandom(maxfuel / 3);

	else if(chance < 10)
		veh_Data[vehicleid][veh_Fuel] = maxfuel / 8 + frandom(maxfuel / 4);

	else
		veh_Data[vehicleid][veh_Fuel] = frandom(1.0);

// Visual Damage

	if(category < VEHICLE_CATEGORY_MOTORBIKE)
	{
		veh_Data[vehicleid][veh_panels]	= encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4));
		veh_Data[vehicleid][veh_doors]	= encode_doors(random(5), random(5), random(5), random(5));
		veh_Data[vehicleid][veh_lights] = encode_lights(random(2), random(2), random(2), random(2));
		veh_Data[vehicleid][veh_tires] = encode_tires(random(2), random(2), random(2), random(2));

		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	}

// Locks

	if(maxfuel == 0.0)
	{
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
	}
	else
	{
		new locked;

		if(doors == 0)
			locked = random(2);

		if(panels)
			veh_TrunkLock[vehicleid] = random(2);

		SetVehicleParamsEx(vehicleid, 0, random(2), !random(100), locked, random(2), random(2), 0);
	}

// Putting loot in trunks

	if(lootindex != -1 && 0 < trunksize <= CNT_MAX_SLOTS)
	{
		new vehiclename[MAX_VEHICLE_TYPE_NAME];

		GetVehicleTypeName(type, vehiclename);

		veh_Container[vehicleid] = CreateContainer(sprintf("%s Trunk", vehiclename), trunksize, .virtual = 1);
		veh_ContainerVehicle[veh_Container[vehicleid]] = vehicleid;
		FillContainerWithLoot(veh_Container[vehicleid], random(trunksize / 3), lootindex);
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
	if(veh_Data[vehicleid][veh_health] > VEHICLE_HEALTH_MAX)
		veh_Data[vehicleid][veh_health] = VEHICLE_HEALTH_CHUNK_4;

	SetVehicleHealth(vehicleid, veh_Data[vehicleid][veh_health]);

	UpdateVehicleDamageStatus(vehicleid, veh_Data[vehicleid][veh_panels], veh_Data[vehicleid][veh_doors], veh_Data[vehicleid][veh_lights], veh_Data[vehicleid][veh_tires]);

	if(VEHICLE_CATEGORY_MOTORBIKE <= GetVehicleTypeCategory(GetVehicleType(vehicleid)) <= VEHICLE_CATEGORY_PUSHBIKE)
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);

	else
		SetVehicleParamsEx(vehicleid, 0, 0, 0, IsVehicleLocked(vehicleid), 0, 0, 0);

	return 1;
}

IsPlayerAtVehicleTrunk(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidVehicle(vehicleid))
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

	if(!IsValidVehicle(vehicleid))
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


RandomNumberPlateString()
{
	new str[9];
	for(new c; c < 8; c++)
	{
		if(c<4)str[c] = 'A' + random(26);
		else if(c>4)str[c] = '0' + random(10);
		str[4] = ' ';
	}
	return str;
}

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
				new
					Float:health,
					type = GetVehicleType(vehicleid);

				GetVehicleHealth(vehicleid, health);

				if(GetVehicleTypeMaxFuel(type) > 0.0)
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

		return 1;
	}

	if(newkeys == 16)
	{
		new vehicleid = GetPlayerVehicleArea(playerid);

		if(IsValidVehicle(vehicleid))
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
			GetVehiclePos(vehicleid, vx, vy, vz);
			GetVehicleZAngle(vehicleid, vr);

			angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

			if( (vz - 1.0) < pz < (vz + 2.0) )
			{
				if(CallLocalFunction("OnPlayerInteractVehicle", "ddf", playerid, vehicleid, angle))
					return 1;

				if(155.0 < angle < 205.0)
				{
					if(IsValidContainer(GetVehicleContainer(vehicleid)))
					{
						if(IsVehicleTrunkLocked(vehicleid))
						{
							ShowActionText(playerid, "Trunk locked", 3000);
							return 1;
						}

						if(IsVehicleLocked(vehicleid))
						{
							ShowActionText(playerid, "Trunk locked", 3000);
							return 1;
						}

						new
							engine,
							lights,
							alarm,
							doors,
							bonnet,
							boot,
							objective;

						GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
						SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 1, objective);

						CancelPlayerMovement(playerid);
						SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

						DisplayContainerInventory(playerid, GetVehicleContainer(vehicleid));
						veh_CurrentTrunkVehicle[playerid] = vehicleid;

						return 1;
					}
				}

				if(225.0 < angle < 315.0)
				{
					if(GetVehicleModel(vehicleid) == 449)
					{
						PutPlayerInVehicle(playerid, vehicleid, 0);
					}
				}
			}
		}
	}
/*
	if(HOLDING(KEY_SPRINT) || PRESSED(KEY_SPRINT) || RELEASED(KEY_SPRINT))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_ENTER_VEHICLE_DRIVER)
		{
			foreach(new i : Player)
			{
				if(i == playerid)
					continue;

				if(GetPlayerVehicleID(i) == veh_Entering[playerid])
					CancelPlayerMovement(playerid);
			}
		}
	}
*/
	return 1;
}

PlayerVehicleUpdate(playerid)
{
	new
		vehicleid,
		vehicletype,
		Float:health,
		Float:velocitychange,
		Float:maxfuel,
		Float:fuelcons,
		playerstate;

	vehicleid = GetPlayerVehicleID(playerid);
	vehicletype = GetVehicleType(vehicleid);

	if(!IsValidVehicleType(vehicletype))
		return;

	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_PUSHBIKE)
		return;

	GetVehicleHealth(vehicleid, health);
	velocitychange = floatabs(veh_TempVelocity[playerid] - GetPlayerTotalVelocity(playerid));
	maxfuel = GetVehicleTypeMaxFuel(vehicletype);
	fuelcons = GetVehicleTypeFuelConsumption(vehicletype);
	playerstate = GetPlayerState(playerid);

	if(playerstate == PLAYER_STATE_DRIVER)
	{
		if(health > 300.0)
		{
			new Float:diff = veh_TempHealth[playerid] - health;

			if(diff > 10.0 && veh_TempHealth[playerid] < VEHICLE_HEALTH_MAX)
			{
				health += diff * 0.8;
				SetVehicleHealth(vehicleid, health);
			}
		}
		else
		{
			SetVehicleHealth(vehicleid, 299.0);
		}
	}

	if(velocitychange > 70.0)
	{
		switch(GetVehicleTypeCategory(vehicletype))
		{
			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE:
				SetVehicleAngularVelocity(vehicleid, 0.0, 0.0, 1.0);

			default:
				PlayerInflictWound(INVALID_PLAYER_ID, playerid, E_WND_TYPE:1, velocitychange * 0.000536, velocitychange * 0.16, -1, BODY_PART_HEAD);
		}
	}

	if(health <= VEHICLE_HEALTH_CHUNK_1)
		PlayerTextDrawColor(playerid, VehicleDamageText[playerid], VEHICLE_HEALTH_CHUNK_1_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_2)
		PlayerTextDrawColor(playerid, VehicleDamageText[playerid], VEHICLE_HEALTH_CHUNK_1_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_3)
		PlayerTextDrawColor(playerid, VehicleDamageText[playerid], VEHICLE_HEALTH_CHUNK_2_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_4)
		PlayerTextDrawColor(playerid, VehicleDamageText[playerid], VEHICLE_HEALTH_CHUNK_3_COLOUR);

	else if(health <= VEHICLE_HEALTH_MAX)
		PlayerTextDrawColor(playerid, VehicleDamageText[playerid], VEHICLE_HEALTH_CHUNK_4_COLOUR);

	if(maxfuel > 0.0) // If the vehicle is a fuel powered vehicle
	{
		new
			Float:fuel = GetVehicleFuel(vehicleid),
			str[18];

		if(fuel <= 0.0)
		{
			SetVehicleEngine(vehicleid, 0);
			PlayerTextDrawColor(playerid, VehicleEngineText[playerid], VEHICLE_UI_INACTIVE);
		}

		format(str, 18, "%.2fL/%.2f", GetVehicleFuel(vehicleid), maxfuel);
		PlayerTextDrawSetString(playerid, VehicleFuelText[playerid], str);
		PlayerTextDrawShow(playerid, VehicleFuelText[playerid]);

		if(GetVehicleEngine(vehicleid))
		{
			if(fuel > 0.0)
				fuel -= ((fuelcons / 100) * (((GetPlayerTotalVelocity(playerid)/60)/60)/10) + 0.0001);

			SetVehicleFuel(vehicleid, fuel);
			PlayerTextDrawColor(playerid, VehicleEngineText[playerid], VEHICLE_UI_ACTIVE);

			if(health <= VEHICLE_HEALTH_CHUNK_1)
			{
				SetVehicleEngine(vehicleid, 0);
				PlayerTextDrawColor(playerid, VehicleEngineText[playerid], VEHICLE_UI_INACTIVE);
			}
			else if(health <= VEHICLE_HEALTH_CHUNK_2 && GetPlayerTotalVelocity(playerid) > 1.0)
			{
				new Float:enginechance = (20 - ((health - VEHICLE_HEALTH_CHUNK_2) / 3));

				SetVehicleHealth(vehicleid, health - ((VEHICLE_HEALTH_CHUNK_1 - (health - VEHICLE_HEALTH_CHUNK_1)) / 1000.0));

				if(GetPlayerTotalVelocity(playerid) > 30.0)
				{
					if(random(100) < enginechance)
					{
						VehicleEngineState(vehicleid, 0);
						PlayerTextDrawColor(playerid, VehicleEngineText[playerid], VEHICLE_UI_INACTIVE);
					}
				}
				else
				{
					if(random(100) < 100 - enginechance)
					{
						VehicleEngineState(vehicleid, 1);
						PlayerTextDrawColor(playerid, VehicleEngineText[playerid], VEHICLE_UI_ACTIVE);
					}
				}
			}
		}
		else
		{
			PlayerTextDrawColor(playerid, VehicleEngineText[playerid], VEHICLE_UI_INACTIVE);
		}
	}
	else
	{
		PlayerTextDrawHide(playerid, VehicleFuelText[playerid]);
	}

	if(VehicleHasDoors(vehicleid))
	{
		if(VehicleDoorsState(vehicleid))
			PlayerTextDrawColor(playerid, VehicleDoorsText[playerid], VEHICLE_UI_ACTIVE);

		else
			PlayerTextDrawColor(playerid, VehicleDoorsText[playerid], VEHICLE_UI_INACTIVE);

		PlayerTextDrawShow(playerid, VehicleDoorsText[playerid]);
	}
	else
	{
		PlayerTextDrawHide(playerid, VehicleDoorsText[playerid]);
	}

	PlayerTextDrawShow(playerid, VehicleDamageText[playerid]);
	PlayerTextDrawShow(playerid, VehicleEngineText[playerid]);

	if(IsWeaponDriveby(GetPlayerWeapon(playerid)))
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) > 3000 && playerstate == PLAYER_STATE_DRIVER)
			SetPlayerArmedWeapon(playerid, 0);
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

	switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
	{
		case VEHICLE_CATEGORY_BOAT, VEHICLE_CATEGORY_TRAIN, VEHICLE_CATEGORY_TRAILER:
			return;
	}

	GetVehicleVelocity(vehicleid, vx, vy, vz);
	velocity = floatsqroot( (vx * vx) + (vy * vy) + (vz * vz) ) * 150.0;

	if(velocity > 40.0)
	{
		if(!IsPlayerKnockedOut(playerid))
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(playerid, x, y, z);
			SetPlayerPos(playerid, x - (vx * 2.0), y - (vy * 2.0), z - 0.5);

			SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
			GivePlayerHP(playerid, -frandom(5.0));

			KnockOutPlayer(playerid, 3000);
		}
	}

	return;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	veh_TempHealth[playerid] = 0.0;
	veh_TempVelocity[playerid] = 0.0;
	veh_Entering[playerid] = -1;

	if(newstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleid,
			vehicletype,
			vehiclename[32],
			Float:x,
			Float:y,
			Float:z;

		vehicleid = GetPlayerVehicleID(playerid);
		vehicletype = GetVehicleType(vehicleid);
		GetVehicleTypeName(vehicletype, vehiclename);
		GetVehiclePos(vehicleid, x, y, z);

		if(GetVehicleTypeCategory(GetVehicleType(vehicleid)) == VEHICLE_CATEGORY_PUSHBIKE)
			SetVehicleEngine(vehicleid, 1);

		else
			VehicleEngineState(vehicleid, veh_Data[vehicleid][veh_engine]);

		SetVehicleUsed(vehicleid, true);
		SetVehicleOccupied(vehicleid, true);

		ShowVehicleUI(playerid, vehicleid);

		veh_EnterTick[playerid] = GetTickCount();

		logf("[VEHICLE] %p entered vehicle as driver %d (%s) at %f, %f, %f", playerid, vehicleid, vehiclename, x, y, z);
	}

	if(oldstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleid,
			vehicletype,
			vehiclename[32];

		vehicleid = GetPlayerLastVehicle(playerid);
		vehicletype = GetVehicleType(vehicleid);
		GetVehicleTypeName(vehicletype, vehiclename);
		GetVehiclePos(vehicleid, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);

		if(!IsPlayerOnAdminDuty(playerid))
		{
			if(GetTickCountDifference(veh_EnterTick[playerid], GetTickCount()) > 1000)
			{
				new name[MAX_PLAYER_NAME];

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetVehicleZAngle(vehicleid, veh_Data[vehicleid][veh_spawnR]);

				SavePlayerVehicle(vehicleid, name);
			}
		}

		veh_Data[vehicleid][veh_lastUsed] = GetTickCount();

		SetVehicleExternalLock(vehicleid, 0);
		SetVehicleOccupied(vehicleid, false);
		SetCameraBehindPlayer(playerid);
		HideVehicleUI(playerid);

		logf("[VEHICLE] %p exited vehicle as driver %d (%s) at %f, %f, %f", playerid, vehicleid, vehiclename, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);
	}

	if(newstate == PLAYER_STATE_PASSENGER)
	{
		new
			vehicleid,
			vehicletype,
			vehiclename[32],
			Float:x,
			Float:y,
			Float:z;

		vehicleid = GetPlayerVehicleID(playerid);
		vehicletype = GetVehicleType(vehicleid);
		GetVehicleTypeName(vehicletype, vehiclename);
		GetVehiclePos(vehicleid, x, y, z);

		ShowVehicleUI(playerid, GetPlayerVehicleID(playerid));

		logf("[VEHICLE] %p entered vehicle as passenger %d (%s) at %f, %f, %f", playerid, vehicleid, vehiclename, x, y, z);
	}

	if(oldstate == PLAYER_STATE_PASSENGER)
	{
		new
			vehicleid,
			vehicletype,
			vehiclename[32],
			Float:x,
			Float:y,
			Float:z;

		vehicleid = GetPlayerVehicleID(playerid);
		vehicletype = GetVehicleType(vehicleid);
		GetVehicleTypeName(vehicletype, vehiclename);
		GetVehiclePos(vehicleid, x, y, z);

		SetVehicleExternalLock(GetPlayerLastVehicle(playerid), 0);
		HideVehicleUI(playerid);
		logf("[VEHICLE] %p exited vehicle as passenger %d (%s) at %f, %f, %f", playerid, vehicleid, vehiclename, x, y, z);
	}

	return 1;
}

ShowVehicleUI(playerid, vehicleid)
{
	new vehiclename[MAX_VEHICLE_TYPE_NAME];

	GetVehicleTypeName(GetVehicleType(vehicleid), vehiclename);

	PlayerTextDrawSetString(playerid, VehicleNameText[playerid], vehiclename);
	PlayerTextDrawShow(playerid, VehicleNameText[playerid]);
	PlayerTextDrawShow(playerid, VehicleSpeedText[playerid]);

	if(GetVehicleTypeCategory(GetVehicleType(vehicleid)) != VEHICLE_CATEGORY_PUSHBIKE)
	{
		PlayerTextDrawShow(playerid, VehicleFuelText[playerid]);
		PlayerTextDrawShow(playerid, VehicleDamageText[playerid]);
		PlayerTextDrawShow(playerid, VehicleEngineText[playerid]);
		PlayerTextDrawShow(playerid, VehicleDoorsText[playerid]);
	}
}

HideVehicleUI(playerid)
{
	PlayerTextDrawHide(playerid, VehicleNameText[playerid]);
	PlayerTextDrawHide(playerid, VehicleSpeedText[playerid]);
	PlayerTextDrawHide(playerid, VehicleFuelText[playerid]);
	PlayerTextDrawHide(playerid, VehicleDamageText[playerid]);
	PlayerTextDrawHide(playerid, VehicleEngineText[playerid]);
	PlayerTextDrawHide(playerid, VehicleDoorsText[playerid]);
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(!ispassenger)
		veh_Entering[playerid] = vehicleid;

	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	veh_Data[vehicleid][veh_lastUsed] = GetTickCount();
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidVehicle(veh_CurrentTrunkVehicle[playerid]))
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
	#if defined veh_OnPlayerCloseContainer
		return veh_OnPlayerCloseContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer veh_OnPlayerCloseContainer
#if defined veh_OnPlayerCloseContainer
	forward veh_OnPlayerCloseContainer(playerid, containerid);
#endif

public OnPlayerUseItem(playerid, itemid)
{
	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return 1;

	#if defined veh_OnPlayerUseItem
		return veh_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem veh_OnPlayerUseItem
#if defined veh_OnPlayerUseItem
	forward veh_OnPlayerUseItem(playerid, itemid);
#endif

public OnItemAddedToContainer(containerid, itemid, playerid)
{
	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	#if defined veh_OnItemAddedToContainer
		return veh_OnItemAddedToContainer(containerid, itemid, playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemAddedToContainer
	#undef OnItemAddedToContainer
#else
	#define _ALS_OnItemAddedToContainer
#endif
#define OnItemAddedToContainer veh_OnItemAddedToContainer
#if defined veh_OnItemAddedToContainer
	forward veh_OnItemAddedToContainer(containerid, itemid, playerid);
#endif

public OnItemRemovedFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	#if defined veh_OnItemRemovedFromContainer
		return veh_OnItemRemovedFromContainer(containerid, slotid, playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemRemovedFromContainer
	#undef OnItemRemovedFromContainer
#else
	#define _ALS_OnItemRemovedFromContainer
#endif
#define OnItemRemovedFromContainer veh_OnItemRemovedFromContainer
#if defined veh_OnItemRemovedFromContainer
	forward veh_OnItemRemovedFromContainer(containerid, slotid, playerid);
#endif

VehicleTrunkUpdateSave(playerid)
{
	if(IsValidVehicle(veh_CurrentTrunkVehicle[playerid]))
	{
		new owner[MAX_PLAYER_NAME];

		GetVehicleOwner(veh_CurrentTrunkVehicle[playerid], owner);

		if(!isnull(owner))
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			if(!strcmp(owner, name))
			{
				UpdateVehicleFile(veh_CurrentTrunkVehicle[playerid]);
				GetVehiclePos(veh_CurrentTrunkVehicle[playerid], veh_Data[veh_CurrentTrunkVehicle[playerid]][veh_spawnX], veh_Data[veh_CurrentTrunkVehicle[playerid]][veh_spawnY], veh_Data[veh_CurrentTrunkVehicle[playerid]][veh_spawnZ]);
				GetVehicleZAngle(veh_CurrentTrunkVehicle[playerid], veh_Data[veh_CurrentTrunkVehicle[playerid]][veh_spawnR]);
			}
		}
	}
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	GetVehicleDamageStatus(vehicleid,
		veh_Data[vehicleid][veh_panels],
		veh_Data[vehicleid][veh_doors],
		veh_Data[vehicleid][veh_lights],
		veh_Data[vehicleid][veh_tires]);
}

IsVehicleValidOutOfBounds(vehicleid)
{
	if(!IsPointInMapBounds(veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]))
	{
		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
		{
			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE:
				return 1;

			default:
				return 0;
		}
	}

	return 0;
}

ResetVehicle(vehicleid)
{
	new
		type = GetVehicleType(vehicleid),
		newid;

	DestroyVehicle(vehicleid, 4);
	DestroyDynamicArea(veh_Area[vehicleid]);

	newid = CreateVehicleOfType(type,
		veh_Data[vehicleid][veh_spawnX],
		veh_Data[vehicleid][veh_spawnY],
		veh_Data[vehicleid][veh_spawnZ],
		veh_Data[vehicleid][veh_spawnR],
		veh_Data[vehicleid][veh_colour1],
		veh_Data[vehicleid][veh_colour2]);

	if(newid != vehicleid)
	{
		veh_Data[newid] = veh_Data[vehicleid];
		veh_BitData[newid] = veh_BitData[vehicleid];
		veh_ContainerVehicle[veh_Container[vehicleid]] = newid;
		veh_TrunkLock[newid] = veh_TrunkLock[vehicleid];
		veh_Area[newid] = veh_Area[vehicleid];
		veh_Container[newid] = veh_Container[vehicleid];
		veh_Owner[newid] = veh_Owner[vehicleid];
	}

	CreateVehicleArea(newid);
	UpdateVehicleData(newid);
	SetVehicleSpawnPoint(newid, veh_Data[newid][veh_spawnX], veh_Data[newid][veh_spawnY], veh_Data[newid][veh_spawnZ], veh_Data[newid][veh_spawnR]);
}

public OnVehicleDeath(vehicleid, killerid)
{
	GetVehiclePos(vehicleid, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);
	t:veh_BitData[vehicleid]<veh_Dead>;
	printf("[DEBUG] Vehicle %d killed by %d", vehicleid, killerid);
}

public OnVehicleSpawn(vehicleid)
{
	if(veh_BitData[vehicleid] & veh_Dead)
	{
		if(IsVehicleValidOutOfBounds(vehicleid))
		{
			printf("Dead Vehicle %d Spawned, is valid out-of-bounds vehicle, resetting.", vehicleid);

			f:veh_BitData[vehicleid]<veh_Dead>;
			ResetVehicle(vehicleid);
		}
		else
		{
			printf("Dead Vehicle %d Spawned, destroying.", vehicleid);

			if(IsValidContainer(veh_Container[vehicleid]))
				DestroyContainer(veh_Container[vehicleid]);

			DestroyDynamicArea(veh_Area[vehicleid]);
			DestroyVehicle(vehicleid, 3);
			Iter_Remove(veh_Index, vehicleid);

			RemoveVehicleFileByID(vehicleid);
		}
	}

	return 1;
}

stock VehicleHasDoors(vehicleid)
{
	switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
	{
		case VEHICLE_CATEGORY_MOTORBIKE, VEHICLE_CATEGORY_PUSHBIKE, VEHICLE_CATEGORY_BOAT, VEHICLE_CATEGORY_TRAILER:
			return 0;
	}

	return 1;
}



/*==============================================================================


	Interface


==============================================================================*/


stock IsPlayerInVehicleArea(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	if(!IsValidVehicle(vehicleid))
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

forward Float:GetVehicleFuel(vehicleid);
stock Float:GetVehicleFuel(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0.0;

	if(veh_Data[vehicleid][veh_Fuel] < 0.0)
		veh_Data[vehicleid][veh_Fuel] = 0.0;

	return veh_Data[vehicleid][veh_Fuel];
}

stock SetVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	new Float:maxfuel = GetVehicleTypeMaxFuel(GetVehicleType(vehicleid));

	if(amount > maxfuel)
		amount = maxfuel;

	veh_Data[vehicleid][veh_Fuel] = amount;

	return 1;
}

stock GiveVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	new maxfuel = GetVehicleTypeMaxFuel(GetVehicleType(vehicleid));

	veh_Data[vehicleid][veh_Fuel] += amount;

	if(veh_Data[vehicleid][veh_Fuel] > maxfuel)
		veh_Data[vehicleid][veh_Fuel] = maxfuel;

	return 1;
}

stock GetVehicleKey(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return -1;

	return veh_Data[vehicleid][veh_key];
}

stock SetVehicleKey(vehicleid, key)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_key] = key;

	return 1;
}

stock GetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME])
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	name = veh_Owner[vehicleid];

	return 1;
}

stock GetVehicleContainer(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return INVALID_CONTAINER_ID;

	return veh_Container[vehicleid];
}

stock SetVehicleContainer(vehicleid, containerid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(IsValidContainer(containerid))
	{
		veh_Container[vehicleid] = containerid;
		veh_ContainerVehicle[veh_Container[vehicleid]] = vehicleid;
	}
	else
	{
		veh_Container[vehicleid] = -1;
	}

	return 1;
}

stock IsVehicleTrunkLocked(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_TrunkLock[vehicleid];
}

stock SetVehicleTrunkLock(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	veh_TrunkLock[vehicleid] = toggle;
	return 1;
}

stock SetVehicleUsed(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(toggle)
		t:veh_BitData[vehicleid]<veh_Used>;

	else
		f:veh_BitData[vehicleid]<veh_Used>;

	return 1;
}

stock SetVehicleOccupied(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(toggle)
		t:veh_BitData[vehicleid]<veh_Occupied>;

	else
		f:veh_BitData[vehicleid]<veh_Occupied>;

	return 1;
}

stock GetVehicleArea(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return -1;

	return veh_Area[vehicleid];
}

stock IsVehicleOccupied(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_BitData[vehicleid] & veh_Occupied;
}

stock GetVehicleEngine(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_engine];
}

stock SetVehicleEngine(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
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

stock GetContainerTrunkVehicleID(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_VEHICLE_ID;

	return veh_ContainerVehicle[containerid];
}

stock SetVehicleSpawnPoint(vehicleid, Float:x, Float:y, Float:z, Float:r)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_spawnX] = x;
	veh_Data[vehicleid][veh_spawnY] = y;
	veh_Data[vehicleid][veh_spawnZ] = z;
	veh_Data[vehicleid][veh_spawnR] = r;

	return 1;
}

stock GetVehicleSpawnPoint(vehicleid, &Float:x, &Float:y, &Float:z, &Float:r)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	x = veh_Data[vehicleid][veh_spawnX];
	y = veh_Data[vehicleid][veh_spawnY];
	z = veh_Data[vehicleid][veh_spawnZ];
	r = veh_Data[vehicleid][veh_spawnR];

	return 1;
}

stock GetVehicleLastUseTick(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_lastUsed];
}
