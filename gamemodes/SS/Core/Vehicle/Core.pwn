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



enum E_VEHICLE_DATA
{
		veh_type,
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

		veh_lastUsed,
		veh_used,
		veh_occupied,
		veh_dead
}


static
			veh_Data				[MAX_VEHICLES][E_VEHICLE_DATA],
			veh_TypeCount			[MAX_VEHICLE_TYPE];

new
Iterator:	veh_Index<MAX_VEHICLES>;

static
PlayerText:	veh_FuelUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_DamageUI			[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_EngineUI			[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_DoorsUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_NameUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_SpeedUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},

Float:		veh_TempHealth			[MAX_PLAYERS],
Float:		veh_TempVelocity		[MAX_PLAYERS],
			veh_Entering			[MAX_PLAYERS],
			veh_EnterTick			[MAX_PLAYERS];


forward OnVehicleCreated(vehicleid);
forward OnVehicleDestroyed(vehicleid);
forward OnVehicleReset(oldid, newid);


hook OnPlayerConnect(playerid)
{
	veh_NameUI[playerid]			=CreatePlayerTextDraw(playerid, 621.000000, 415.000000, "Infernus");
	PlayerTextDrawAlignment			(playerid, veh_NameUI[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, veh_NameUI[playerid], 255);
	PlayerTextDrawFont				(playerid, veh_NameUI[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, veh_NameUI[playerid], 0.349999, 1.799998);
	PlayerTextDrawColor				(playerid, veh_NameUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, veh_NameUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_NameUI[playerid], 1);

	veh_SpeedUI[playerid]			=CreatePlayerTextDraw(playerid, 620.000000, 401.000000, "220km/h");
	PlayerTextDrawAlignment			(playerid, veh_SpeedUI[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, veh_SpeedUI[playerid], 255);
	PlayerTextDrawFont				(playerid, veh_SpeedUI[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, veh_SpeedUI[playerid], 0.250000, 1.599998);
	PlayerTextDrawColor				(playerid, veh_SpeedUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, veh_SpeedUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_SpeedUI[playerid], 1);

	veh_FuelUI[playerid]			=CreatePlayerTextDraw(playerid, 620.000000, 386.000000, "0.0/0.0L");
	PlayerTextDrawAlignment			(playerid, veh_FuelUI[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, veh_FuelUI[playerid], 255);
	PlayerTextDrawFont				(playerid, veh_FuelUI[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, veh_FuelUI[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, veh_FuelUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, veh_FuelUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_FuelUI[playerid], 1);

	veh_DamageUI[playerid]			=CreatePlayerTextDraw(playerid, 620.000000, 371.000000, "DMG");
	PlayerTextDrawAlignment			(playerid, veh_DamageUI[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, veh_DamageUI[playerid], 255);
	PlayerTextDrawFont				(playerid, veh_DamageUI[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, veh_DamageUI[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, veh_DamageUI[playerid], RED);
	PlayerTextDrawSetOutline		(playerid, veh_DamageUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_DamageUI[playerid], 1);

	veh_EngineUI[playerid]			=CreatePlayerTextDraw(playerid, 620.000000, 356.000000, "ENG");
	PlayerTextDrawAlignment			(playerid, veh_EngineUI[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, veh_EngineUI[playerid], 255);
	PlayerTextDrawFont				(playerid, veh_EngineUI[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, veh_EngineUI[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, veh_EngineUI[playerid], RED);
	PlayerTextDrawSetOutline		(playerid, veh_EngineUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_EngineUI[playerid], 1);

	veh_DoorsUI[playerid]			=CreatePlayerTextDraw(playerid, 620.000000, 341.000000, "DOR");
	PlayerTextDrawAlignment			(playerid, veh_DoorsUI[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, veh_DoorsUI[playerid], 255);
	PlayerTextDrawFont				(playerid, veh_DoorsUI[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, veh_DoorsUI[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, veh_DoorsUI[playerid], RED);
	PlayerTextDrawSetOutline		(playerid, veh_DoorsUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_DoorsUI[playerid], 1);
}

SetPlayerVehicleSpeedUI(playerid, str[])
{
	PlayerTextDrawSetString(playerid, veh_SpeedUI[playerid], str);
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateWorldVehicle(type, Float:x, Float:y, Float:z, Float:r, colour1, colour2, world = 0)
{
	if(!(0 <= type < veh_TypeTotal))
	{
		printf("ERROR: Tried to create invalid vehicle type (%d).", type);
		return 0;
	}

	//printf("[CreateWorldVehicle] Creating vehicle of type %d model %d at %f, %f, %f", type, veh_TypeData[type][veh_modelId], x, y, z);

	new vehicleid = _veh_create(type, x, y, z, r, colour1, colour2, world);

	veh_TypeCount[type]++;

	CallLocalFunction("OnVehicleCreated", "d", vehicleid);
	_veh_SyncData(vehicleid);

	return vehicleid;
}

stock DestroyWorldVehicle(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	CallLocalFunction("OnVehicleDestroyed", "d", vehicleid);
	DestroyVehicle(vehicleid, 3);
	Iter_Remove(veh_Index, vehicleid);

	return 1;
}

stock ResetVehicle(vehicleid)
{
	new
		type = GetVehicleType(vehicleid),
		tmp[E_VEHICLE_DATA],
		newid;

	tmp = veh_Data[vehicleid];

	DestroyVehicle(vehicleid, 4);

	newid = _veh_create(type,
		veh_Data[vehicleid][veh_spawnX],
		veh_Data[vehicleid][veh_spawnY],
		veh_Data[vehicleid][veh_spawnZ],
		veh_Data[vehicleid][veh_spawnR],
		veh_Data[vehicleid][veh_colour1],
		veh_Data[vehicleid][veh_colour2]);

	CallLocalFunction("OnVehicleReset", "dd", vehicleid, newid);

	veh_Data[newid] = tmp;

	_veh_SyncData(newid);
	SetVehicleSpawnPoint(newid, veh_Data[newid][veh_spawnX], veh_Data[newid][veh_spawnY], veh_Data[newid][veh_spawnZ], veh_Data[newid][veh_spawnR]);
}

stock RespawnVehicle(vehicleid)
{
	SetVehicleToRespawn(vehicleid);
	_veh_SyncData(vehicleid);
}


/*==============================================================================

	Internal

==============================================================================*/


_veh_create(type, Float:x, Float:y, Float:z, Float:r, colour1, colour2, world = 0)
{
	new vehicleid = CreateVehicle(GetVehicleTypeModel(type), x, y, z, r, colour1, colour2, 864000);

	if(!IsValidVehicle(vehicleid))
		return 0;

	SetVehicleVirtualWorld(vehicleid, world);

	veh_Data[vehicleid][veh_type]		= type;
	veh_Data[vehicleid][veh_health]		= VEHICLE_HEALTH_MAX;
	veh_Data[vehicleid][veh_Fuel]		= 0.0;
	veh_Data[vehicleid][veh_key]		= 0;

	veh_Data[vehicleid][veh_engine]		= 0;
	veh_Data[vehicleid][veh_panels]		= 0;
	veh_Data[vehicleid][veh_doors]		= 0;
	veh_Data[vehicleid][veh_lights]		= 0;
	veh_Data[vehicleid][veh_tires]		= 0;

	veh_Data[vehicleid][veh_armour]		= 0;

	veh_Data[vehicleid][veh_colour1]	= colour1;
	veh_Data[vehicleid][veh_colour2]	= colour2;

	veh_Data[vehicleid][veh_spawnX]		= x;
	veh_Data[vehicleid][veh_spawnY]		= y;
	veh_Data[vehicleid][veh_spawnZ]		= z;
	veh_Data[vehicleid][veh_spawnR]		= r;

	veh_Data[vehicleid][veh_lastUsed]	= 0;
	veh_Data[vehicleid][veh_used]		= 0;
	veh_Data[vehicleid][veh_occupied]	= 0;
	veh_Data[vehicleid][veh_dead]		= 0;

	return vehicleid;
}

_veh_SyncData(vehicleid)
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
//		Float:velocitychange,
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
//	velocitychange = floatabs(veh_TempVelocity[playerid] - GetPlayerTotalVelocity(playerid));
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

//	if(velocitychange > 70.0)
//	{
//		switch(GetVehicleTypeCategory(vehicletype))
//		{
//			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE:
//				SetVehicleAngularVelocity(vehicleid, 0.0, 0.0, 1.0);
//
//			default:
//				PlayerInflictWound(INVALID_PLAYER_ID, playerid, E_WND_TYPE:1, velocitychange * 0.0001136, velocitychange * 0.00166, -1, BODY_PART_HEAD, "Collision");
//		}
//	}

	if(health <= VEHICLE_HEALTH_CHUNK_1)
		PlayerTextDrawColor(playerid, veh_DamageUI[playerid], VEHICLE_HEALTH_CHUNK_1_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_2)
		PlayerTextDrawColor(playerid, veh_DamageUI[playerid], VEHICLE_HEALTH_CHUNK_1_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_3)
		PlayerTextDrawColor(playerid, veh_DamageUI[playerid], VEHICLE_HEALTH_CHUNK_2_COLOUR);

	else if(health <= VEHICLE_HEALTH_CHUNK_4)
		PlayerTextDrawColor(playerid, veh_DamageUI[playerid], VEHICLE_HEALTH_CHUNK_3_COLOUR);

	else if(health <= VEHICLE_HEALTH_MAX)
		PlayerTextDrawColor(playerid, veh_DamageUI[playerid], VEHICLE_HEALTH_CHUNK_4_COLOUR);

	if(maxfuel > 0.0) // If the vehicle is a fuel powered vehicle
	{
		new
			Float:fuel = GetVehicleFuel(vehicleid),
			str[18];

		if(fuel <= 0.0)
		{
			SetVehicleEngine(vehicleid, 0);
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
		}

		format(str, 18, "%.2fL/%.2f", GetVehicleFuel(vehicleid), maxfuel);
		PlayerTextDrawSetString(playerid, veh_FuelUI[playerid], str);
		PlayerTextDrawShow(playerid, veh_FuelUI[playerid]);

		if(GetVehicleEngine(vehicleid))
		{
			if(fuel > 0.0)
				fuel -= ((fuelcons / 100) * (((GetPlayerTotalVelocity(playerid)/60)/60)/10) + 0.0001);

			SetVehicleFuel(vehicleid, fuel);
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_ACTIVE);

			if(health <= VEHICLE_HEALTH_CHUNK_1)
			{
				SetVehicleEngine(vehicleid, 0);
				PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
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
						PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
					}
				}
				else
				{
					if(random(100) < 100 - enginechance)
					{
						VehicleEngineState(vehicleid, 1);
						PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_ACTIVE);
					}
				}
			}
		}
		else
		{
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
		}
	}
	else
	{
		PlayerTextDrawHide(playerid, veh_FuelUI[playerid]);
	}

	if(IsVehicleTypeLockable(vehicletype))
	{
		if(VehicleDoorsState(vehicleid))
			PlayerTextDrawColor(playerid, veh_DoorsUI[playerid], VEHICLE_UI_ACTIVE);

		else
			PlayerTextDrawColor(playerid, veh_DoorsUI[playerid], VEHICLE_UI_INACTIVE);

		PlayerTextDrawShow(playerid, veh_DoorsUI[playerid]);
	}
	else
	{
		PlayerTextDrawHide(playerid, veh_DoorsUI[playerid]);
	}

	PlayerTextDrawShow(playerid, veh_DamageUI[playerid]);
	PlayerTextDrawShow(playerid, veh_EngineUI[playerid]);

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

	if(IsVehicleTypeSurfable(GetVehicleType(vehicleid)))
		return;

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

		veh_Data[vehicleid][veh_used] = true;
		veh_Data[vehicleid][veh_occupied] = true;

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
		GetVehicleZAngle(vehicleid, veh_Data[vehicleid][veh_spawnR]);

		veh_Data[vehicleid][veh_occupied] = false;
		veh_Data[vehicleid][veh_lastUsed] = GetTickCount();

		SetVehicleExternalLock(vehicleid, 0);
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

		vehicleid = GetPlayerLastVehicle(playerid);
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

	PlayerTextDrawSetString(playerid, veh_NameUI[playerid], vehiclename);
	PlayerTextDrawShow(playerid, veh_NameUI[playerid]);
	PlayerTextDrawShow(playerid, veh_SpeedUI[playerid]);

	if(GetVehicleTypeCategory(GetVehicleType(vehicleid)) != VEHICLE_CATEGORY_PUSHBIKE)
	{
		PlayerTextDrawShow(playerid, veh_FuelUI[playerid]);
		PlayerTextDrawShow(playerid, veh_DamageUI[playerid]);
		PlayerTextDrawShow(playerid, veh_EngineUI[playerid]);
		PlayerTextDrawShow(playerid, veh_DoorsUI[playerid]);
	}
}

HideVehicleUI(playerid)
{
	PlayerTextDrawHide(playerid, veh_NameUI[playerid]);
	PlayerTextDrawHide(playerid, veh_SpeedUI[playerid]);
	PlayerTextDrawHide(playerid, veh_FuelUI[playerid]);
	PlayerTextDrawHide(playerid, veh_DamageUI[playerid]);
	PlayerTextDrawHide(playerid, veh_EngineUI[playerid]);
	PlayerTextDrawHide(playerid, veh_DoorsUI[playerid]);
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

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	// TODO: Some anticheat magic before syncing.
	GetVehicleDamageStatus(vehicleid,
		veh_Data[vehicleid][veh_panels],
		veh_Data[vehicleid][veh_doors],
		veh_Data[vehicleid][veh_lights],
		veh_Data[vehicleid][veh_tires]);
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	if(IsValidVehicle(GetTrailerVehicleID(vehicleid)))
		return 1;

	new Float:distance = GetVehicleDistanceFromPoint(vehicleid, new_x, new_y, new_z);

	if(distance > 0.0)
	{
		if(GetTickCountDifference(GetTickCount(), veh_Data[vehicleid][veh_lastUsed]) < 10000)
			return 1;

		new Float:thresh;

		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
		{
			case VEHICLE_CATEGORY_TRUCK:
				thresh = 0.05;

			case VEHICLE_CATEGORY_MOTORBIKE, VEHICLE_CATEGORY_PUSHBIKE:
				thresh = 0.2;

			case VEHICLE_CATEGORY_BOAT:
				thresh = 2.6;

			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE:
				thresh = 0.01;

			default:
				thresh = 0.1;
		}

		if(distance > thresh)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetVehiclePos(vehicleid, x, y, z);
			SetVehiclePos(vehicleid, x, y, z);
		}

		return 0;
	}
	
	#if defined veh_OnUnoccupiedVehicleUpdate
		return veh_OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, new_x, new_y, new_z, vel_x, vel_y, vel_z);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnUnoccupiedVehicleUpdate
	#undef OnUnoccupiedVehicleUpdate
#else
	#define _ALS_OnUnoccupiedVehicleUpdate
#endif
 
#define OnUnoccupiedVehicleUpdate veh_OnUnoccupiedVehicleUpdate
#if defined veh_OnUnoccupiedVehicleUpdate
	forward veh_OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z);
#endif

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

/*
	Handling vehicle deaths:
	When a vehicle "dies" (reported by the client) it might be false. This hook
	aims to fix bugs with vehicle deaths and all code that's intended to run
	when a vehicle is destroyed should be put under OnVehicleDestroy(ed).
*/
public OnVehicleDeath(vehicleid, killerid)
{
	new name[MAX_PLAYER_NAME];

	GetPlayerName(killerid, name, MAX_PLAYER_NAME);
	GetVehiclePos(vehicleid, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);

	veh_Data[vehicleid][veh_dead] = true;

	printf("[OnVehicleDeath] Vehicle %d killed by %s at %f %f %f", vehicleid, name, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);
}

public OnVehicleSpawn(vehicleid)
{
	if(veh_Data[vehicleid][veh_dead])
	{
		if(IsVehicleValidOutOfBounds(vehicleid))
		{
			printf("Dead Vehicle %d Spawned, is valid out-of-bounds vehicle, resetting.", vehicleid);

			veh_Data[vehicleid][veh_dead] = false;
			ResetVehicle(vehicleid);
		}
		else
		{
			printf("Dead Vehicle %d Spawned, spawning as inactive.", vehicleid);

			veh_Data[vehicleid][veh_health] = 300.0;
			VehicleDoorsState(vehicleid, true);
			ResetVehicle(vehicleid);
		}
	}

	return 1;
}

/*
	Hook for CreateVehicle, if the first parameter isn't a valid model ID but is
	a valid vehicle-type from this index, use the index create function instead.
*/
stock vti_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay)
{
	#pragma unused vehicletype, x, y, z, rotation, color1, color2, respawn_delay
	printf("ERROR: Cannot create vehicle by model ID.");

	return 0;
}
#if defined _ALS_CreateVehicle
	#undef CreateVehicle
#else
	#define _ALS_CreateVehicle
#endif
#define CreateVehicle vti_CreateVehicle


/*==============================================================================

	Interface

==============================================================================*/


// veh_type
stock GetVehicleType(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return INVALID_VEHICLE_TYPE;

	return veh_Data[vehicleid][veh_type];
}

// veh_health
stock Float:GetVehicleHP(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0.0;

	return veh_Data[vehicleid][veh_health];
}

stock SetVehicleHP(vehicleid, Float:health)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_health] = health;
	_veh_SyncData(vehicleid); // hotfix

	return 1;
}

// veh_Fuel
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

// veh_key
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

// veh_engine
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

// veh_panels
// veh_doors
// veh_lights
// veh_tires
stock SetVehicleDamageData(vehicleid, panels, doors, lights, tires)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_panels] = panels;
	veh_Data[vehicleid][veh_doors] = doors;
	veh_Data[vehicleid][veh_lights] = lights;
	veh_Data[vehicleid][veh_tires] = tires;

	UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	return 1;
}

// veh_armour

// veh_colour1
// veh_colour2
stock GetVehicleColours(vehicleid, &colour1, &colour2)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	colour1 = veh_Data[vehicleid][veh_colour1];
	colour2 = veh_Data[vehicleid][veh_colour2];

	return 1;
}

stock SetVehicleColours(vehicleid, colour1, colour2)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_colour1] = colour1;
	veh_Data[vehicleid][veh_colour2] = colour2;

	return 1;
}

// veh_spawnX
// veh_spawnY
// veh_spawnZ
// veh_spawnR
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

// veh_lastUsed
stock GetVehicleLastUseTick(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_lastUsed];
}

// veh_used
stock IsVehicleUsed(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_used];
}

// veh_occupied
stock IsVehicleOccupied(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_occupied];
}


// veh_dead
stock IsVehicleDead(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_dead];
}

// veh_TypeCount
stock GetVehicleTypeCount(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeCount[vehicletype];
}

// veh_Entering
stock GetPlayerEnteringVehicle(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return veh_Entering[playerid];
}
// veh_EnterTick
stock GetPlayerVehicleEnterTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return veh_EnterTick[playerid];
}
