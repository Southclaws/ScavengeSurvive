/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


#define MAX_VEHICLES_IN_RANGE			(8)
#define VEH_STREAMER_AREA_IDENTIFIER	(500)


enum e_vehicle_range_data
{
			E_VEHICLE_AREA_VEHICLEID,
Float:		E_VEHICLE_AREA_DISTANCE
}

static
			varea_AreaID[MAX_VEHICLES],
			varea_NearList[MAX_PLAYERS][MAX_VEHICLES_IN_RANGE],
   Iterator:varea_NearIndex[MAX_PLAYERS]<MAX_VEHICLES_IN_RANGE>;


forward OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);
forward OnPlayerEnterVehArea(playerid, vehicleid);
forward OnPlayerLeaveVehArea(playerid, vehicleid);


static HANDLER = -1;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Vehicle/Interact'...");

	Iter_Init(varea_NearIndex);

	HANDLER = debug_register_handler("vehicle/interact");
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateVehicleArea(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z,
		data[2];

	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, x, y, z);

	// temp workaround for interaction zone of the marquis boat
	if(GetVehicleModel(vehicleid) == 484)
		y = 0.0;

	varea_AreaID[vehicleid] = CreateDynamicSphere(0.0, 0.0, 0.0, (y / 2.0) + 0.8, GetVehicleVirtualWorld(vehicleid));
	AttachDynamicAreaToVehicle(varea_AreaID[vehicleid], vehicleid);

	data[0] = VEH_STREAMER_AREA_IDENTIFIER;
	data[1] = vehicleid;

	Streamer_SetArrayData(STREAMER_TYPE_AREA, varea_AreaID[vehicleid], E_STREAMER_EXTRA_ID, data, 2);

	return 1;
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnVehicleCreated(vehicleid)
{
	d:3:GLOBAL_DEBUG("[OnVehicleCreated] in /gamemodes/sss/core/vehicle/interact.pwn");

	CreateVehicleArea(vehicleid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerEnterDynArea] in /gamemodes/sss/core/vehicle/interact.pwn");

	_vint_EnterArea(playerid, areaid);
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerLeaveDynArea] in /gamemodes/sss/core/vehicle/interact.pwn");

	_vint_LeaveArea(playerid, areaid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_vint_EnterArea(playerid, areaid)
{
	d:1:HANDLER("[_vint_EnterArea] %d %d", playerid, areaid);

	if(IsPlayerInAnyVehicle(playerid))
	{
		d:1:HANDLER("[_vint_EnterArea] Player in vehicle");
		return;
	}

	if(!IsValidDynamicArea(areaid))
	{
		d:1:HANDLER("[_vint_EnterArea] Invalid area ID (%d)", areaid);
		return;
	}

	if(Iter_Count(varea_NearIndex[playerid]) == MAX_VEHICLES_IN_RANGE)
	{
		d:1:HANDLER("[_vint_EnterArea] Player already in maximum amount of vehicle areas");
		return;
	}

	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != VEH_STREAMER_AREA_IDENTIFIER)
	{
		d:1:HANDLER("[_vint_EnterArea] Area not vehicle area type");
		return;
	}

	if(!IsValidVehicle(data[1]))
	{
		d:1:HANDLER("[_vint_EnterArea] Area contains invalid vehicle ID");
		return;
	}

	new bool:exists = false;

	foreach(new i : varea_NearIndex[playerid])
	{
		if(varea_NearList[playerid][i] == data[1])
		{
			exists = true;
			break;
		}
	}

	if(!exists)
	{
		new cell = Iter_Free(varea_NearIndex[playerid]);

		varea_NearList[playerid][cell] = data[1];
		Iter_Add(varea_NearIndex[playerid], cell);
	}
	else
	{
		printf("ERROR: Vehicle %d already in NearList for player %d", data[1], playerid);
	}

	CallLocalFunction("OnPlayerEnterVehArea", "dd", playerid, data[1]);

	return;
}

_vint_LeaveArea(playerid, areaid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		d:1:HANDLER("[_vint_LeaveArea] Player in vehicle");
		return;
	}

	if(!IsValidDynamicArea(areaid))
	{
		d:1:HANDLER("[_vint_LeaveArea] Invalid area ID (%d)", areaid);
		return;
	}

	if(Iter_Count(varea_NearIndex[playerid]) == 0)
	{
		d:1:HANDLER("[_vint_LeaveArea] Vehicle area list is empty");
		return;
	}

	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != VEH_STREAMER_AREA_IDENTIFIER)
	{
		d:1:HANDLER("[_vint_LeaveArea] Area not vehicle area type");
		return;
	}

	if(!IsValidVehicle(data[1]))
	{
		d:1:HANDLER("[_vint_LeaveArea] Vehicle in area data is invalid");
		return;
	}

	HideActionText(playerid);
	CallLocalFunction("OnPlayerLeaveVehArea", "dd", playerid, data[1]);

	foreach(new i : varea_NearIndex[playerid])
	{
		if(varea_NearList[playerid][i] == data[1])
		{
			d:2:HANDLER("[_vint_LeaveArea] Removed vehicle from list");
			Iter_Remove(varea_NearIndex[playerid], i);
			break;
		}
	}

	return;
}

hook OnVehicleDestroyed(vehicleid)
{
	d:3:GLOBAL_DEBUG("[OnVehicleDestroyed] in /gamemodes/sss/core/vehicle/interact.pwn");

	DestroyDynamicArea(varea_AreaID[vehicleid]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/vehicle/interact.pwn");

	if(newkeys == 16)
		_varea_Interact(playerid);

	return 1;
}

_varea_Interact(playerid)
{
	d:1:HANDLER("[_varea_Interact] %d", playerid);

	if(IsPlayerInAnyVehicle(playerid))
	{
		d:1:HANDLER("[_varea_Interact] Player in vehicle");
		return;
	}

	if(!IsPlayerInAnyDynamicArea(playerid))
	{
		printf("[WARNING] Player %d is not in areas but list isn't empty. Purging list.", playerid);
		Iter_Clear(varea_NearIndex[playerid]);
	}

	new
		vehicleid,
		Float:px,
		Float:py,
		Float:pz,
		Float:vx,
		Float:vy,
		Float:vz,
		Float:size_x,
		Float:size_y,
		Float:size_z,
		Float:distance,
		list[MAX_VEHICLES_IN_RANGE][e_vehicle_range_data],
		index;

	GetPlayerPos(playerid, px, py, pz);

	foreach(new i : varea_NearIndex[playerid])
	{
		d:2:HANDLER("[_varea_Interact] [%d] Looping vehicles in list", i);
		if(index >= MAX_VEHICLES_IN_RANGE - 1)
		{
			printf("ERROR: [_varea_Interact] varea_NearIndex tried to iterate %d times! Iterator size is %d", index, Iter_Count(varea_NearIndex));
			break;
		}

		vehicleid = varea_NearList[playerid][i];
		GetVehiclePos(vehicleid, vx, vy, vz);
		GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, size_x, size_y, size_z);
		distance = Distance(px, py, pz, vx, vy, vz);

		if(distance > (size_y / 2.0) + 0.8)
		{
			d:2:HANDLER("[_varea_Interact] ERROR: Vehicle is too far away");
			continue;
		}

		list[index][E_VEHICLE_AREA_VEHICLEID] = vehicleid;
		list[index][E_VEHICLE_AREA_DISTANCE] = distance;

		index++;
	}

	d:1:HANDLER("[_varea_Interact] Sorting compiled list");
	_varea_SortPlayerVehicleList(list, 0, index);

	for(new i = index - 1; i >= 0; i--)
	{
		d:2:HANDLER("[_varea_Interact] [%d/%d] Interacting with vehicle", i, index);
		if(!_varea_InteractSpecific(playerid, list[i][E_VEHICLE_AREA_VEHICLEID]))
			break;
	}

}

_varea_InteractSpecific(playerid, vehicleid)
{
	d:1:HANDLER("[_varea_InteractSpecific] %d %d", playerid, vehicleid);

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

	if(!( (vz - 1.0) < pz < (vz + 2.0) ))
	{
		d:1:HANDLER("[_varea_InteractSpecific] Vehicle out of Z bounds");
		return 0;
	}

	if(CallLocalFunction("OnPlayerInteractVehicle", "ddf", playerid, vehicleid, angle))
	{
		d:1:HANDLER("[_varea_InteractSpecific] OnPlayerInteractVehicle returned 1 to cancel call");
		return 0;
	}

	if(225.0 < angle < 315.0)
	{
		if(GetVehicleModel(vehicleid) == 449)
		{
			PutPlayerInVehicle(playerid, vehicleid, 0);
		}
	}

	return 1;
}

_varea_SortPlayerVehicleList(array[][e_vehicle_range_data], left, right)
{
	new
		tmp_left = left,
		tmp_right = right,
		Float:pivot = array[(left + right) / 2][E_VEHICLE_AREA_DISTANCE],
		tmp[e_vehicle_range_data];

	while(tmp_left <= tmp_right)
	{
		while(array[tmp_left][E_VEHICLE_AREA_DISTANCE] > pivot)
			tmp_left++;

		while(array[tmp_right][E_VEHICLE_AREA_DISTANCE] < pivot)
			tmp_right--;

		if(tmp_left <= tmp_right)
		{
			tmp = array[tmp_left];
			array[tmp_left] = array[tmp_right];
			array[tmp_right] = tmp;

			tmp_left++;
			tmp_right--;
		}
	}

	if(left < tmp_right)
		_varea_SortPlayerVehicleList(array, left, tmp_right);

	if(tmp_left < right)
		_varea_SortPlayerVehicleList(array, tmp_left, right);
}


/*==============================================================================

	Interface Functions

==============================================================================*/


stock IsPlayerInVehicleArea(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	if(!IsValidVehicle(vehicleid))
		return 0;

	return IsPlayerInDynamicArea(playerid, varea_AreaID[vehicleid]);
}

stock GetPlayerVehicleArea(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	foreach(new i : veh_Index)
	{
		if(IsPlayerInDynamicArea(playerid, varea_AreaID[i]))
			return i;
	}

	return INVALID_VEHICLE_ID;
}

stock GetVehicleArea(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return -1;

	return varea_AreaID[vehicleid];
}

stock IsPlayerAtVehicleTrunk(playerid, vehicleid)
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
		Float:vr,
		Float:angle;

	GetVehiclePos(vehicleid, vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);

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
		Float:vr,
		Float:angle;

	GetVehiclePos(vehicleid, vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);

	GetVehicleZAngle(vehicleid, vr);

	angle = absoluteangle(vr - GetAngleToPoint(vx, vy, px, py));

	if(-25.0 < angle < 25.0 || 335.0 < angle < 385.0)
	{
		return 1;
	}

	return 0;
}

stock GetPlayerVehicleTire(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	if(!IsValidVehicle(vehicleid))
		return -1;

	if(!IsPlayerInDynamicArea(playerid, GetVehicleArea(vehicleid)))
		return -1;

	new
		wheel,
		Float:x,
		Float:y,
		Float:z;

	for(wheel = WHEELSFRONT_LEFT; wheel <= WHEELSREAR_RIGHT; wheel++)
	{
		GetVehicleWheelPos(vehicleid, wheel, x, y, z);

		if(IsPlayerInRangeOfPoint(playerid, 1.0, x, y, z))
			break;
	}

	return wheel;
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
