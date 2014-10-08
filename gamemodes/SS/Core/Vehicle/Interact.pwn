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
Iterator:	varea_NearIndex[MAX_PLAYERS]<MAX_VEHICLES_IN_RANGE>;


forward OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);
forward OnPlayerEnterVehicleArea(playerid, vehicleid);
forward OnPlayerLeaveVehicleArea(playerid, vehicleid);


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Vehicle/Interact'...");

	Iter_Init(varea_NearIndex);
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

	varea_AreaID[vehicleid] = CreateDynamicSphere(0.0, 0.0, 0.0, (y / 2.0) + 3.0, 0);
	AttachDynamicAreaToVehicle(varea_AreaID[vehicleid], vehicleid);

	data[0] = VEH_STREAMER_AREA_IDENTIFIER;
	data[1] = vehicleid;

	Streamer_SetArrayData(STREAMER_TYPE_AREA, varea_AreaID[vehicleid], E_STREAMER_EXTRA_ID, data, 2);

	return 1;
}


/*==============================================================================

	Internal

==============================================================================*/


public OnVehicleCreated(vehicleid)
{
	CreateVehicleArea(vehicleid);

	#if defined vint_OnVehicleCreated
		return vint_OnVehicleCreated(vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleCreated
	#undef OnVehicleCreated
#else
	#define _ALS_OnVehicleCreated
#endif

#define OnVehicleCreated vint_OnVehicleCreated
#if defined vint_OnVehicleCreated
	forward vint_OnVehicleCreated(vehicleid);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	_vint_EnterArea(playerid, areaid);

	#if defined vint_OnPlayerEnterDynamicArea
		return vint_OnPlayerEnterDynamicArea(playerid, areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
 
#define OnPlayerEnterDynamicArea vint_OnPlayerEnterDynamicArea
#if defined vint_OnPlayerEnterDynamicArea
	forward vint_OnPlayerEnterDynamicArea(playerid, areaid);
#endif

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	_vint_LeaveArea(playerid, areaid);

	#if defined vint_OnPlayerLeaveDynamicArea
		return vint_OnPlayerLeaveDynamicArea(playerid, areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
 
#define OnPlayerLeaveDynamicArea vint_OnPlayerLeaveDynamicArea
#if defined vint_OnPlayerLeaveDynamicArea
	forward vint_OnPlayerLeaveDynamicArea(playerid, areaid);
#endif

_vint_EnterArea(playerid, areaid)
{
	if(IsPlayerInAnyVehicle(playerid))
		return;

	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != VEH_STREAMER_AREA_IDENTIFIER)
		return;

	if(!IsValidVehicle(data[1]))
		return;

	new cell = Iter_Free(varea_NearIndex[playerid]);

	varea_NearList[playerid][cell] = data[1];
	Iter_Add(varea_NearIndex[playerid], cell);

	CallLocalFunction("OnPlayerEnterVehicleArea", "dd", playerid, data[1]);

	return;
}

_vint_LeaveArea(playerid, areaid)
{
	if(IsPlayerInAnyVehicle(playerid))
		return;

	if(Iter_Count(varea_NearIndex[playerid]) == 0)
		return;

	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != VEH_STREAMER_AREA_IDENTIFIER)
		return;

	if(!IsValidVehicle(data[1]))
		return;

	HideActionText(playerid);
	CallLocalFunction("OnPlayerLeaveVehicleArea", "dd", playerid, data[1]);

	foreach(new i : varea_NearIndex[playerid])
	{
		if(varea_NearList[playerid][i] == data[1])
		{
			Iter_Remove(varea_NearIndex[playerid], i);
			break;
		}
	}

	return;
}

hook OnVehicleDeath(vehicleid, killerid)
{
	DestroyDynamicArea(varea_AreaID[vehicleid]);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == 16)
		_varea_Interact(playerid);

	return 1;
}

_varea_Interact(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
		return;

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
		Float:distance,
		list[MAX_VEHICLES_IN_RANGE][e_vehicle_range_data],
		index;

	GetPlayerPos(playerid, px, py, pz);

	foreach(new i : varea_NearIndex[playerid])
	{
		if(index >= MAX_VEHICLES_IN_RANGE)
			break;

		vehicleid = varea_NearList[playerid][i];
		GetVehiclePos(vehicleid, vx, vy, vz);
		distance = Distance(px, py, pz, vx, vy, vz);

		list[index][E_VEHICLE_AREA_VEHICLEID] = vehicleid;
		list[index][E_VEHICLE_AREA_DISTANCE] = distance;

		index++;
	}

	_varea_SortPlayerVehicleList(list, 0, index);

	for(new i = index - 1; i >= 0; i--)
	{
		if(_varea_InteractSpecific(playerid, list[i][E_VEHICLE_AREA_VEHICLEID]))
			break;
	}

}

_varea_InteractSpecific(playerid, vehicleid)
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

	if(!( (vz - 1.0) < pz < (vz + 2.0) ))
		return 1;

	if(CallLocalFunction("OnPlayerInteractVehicle", "ddf", playerid, vehicleid, angle))
		return 0;

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
		vehicleid,
		Float:distance;

	while(tmp_left <= tmp_right)
	{
		while(array[tmp_left][E_VEHICLE_AREA_DISTANCE] > pivot)
			tmp_left++;

		while(array[tmp_right][E_VEHICLE_AREA_DISTANCE] < pivot)
			tmp_right--;

		if(tmp_left <= tmp_right)
		{
			vehicleid = array[tmp_left][E_VEHICLE_AREA_VEHICLEID];
			array[tmp_left][E_VEHICLE_AREA_VEHICLEID] = array[tmp_right][E_VEHICLE_AREA_VEHICLEID];
			array[tmp_right][E_VEHICLE_AREA_VEHICLEID] = vehicleid;

			distance = array[tmp_left][E_VEHICLE_AREA_DISTANCE];
			array[tmp_left][E_VEHICLE_AREA_DISTANCE] = array[tmp_right][E_VEHICLE_AREA_DISTANCE];
			array[tmp_right][E_VEHICLE_AREA_DISTANCE] = distance;

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
