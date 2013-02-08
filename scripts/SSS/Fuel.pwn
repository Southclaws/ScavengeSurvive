#include <YSI\y_hooks>

#define MAX_FUEL_LOCATIONS	(12)
#define FUEL_CAN_CAPACITY	(20)


enum E_FUEL_DATA
{
			fuel_state,
			fuel_areaId,
Float:		fuel_capacity,
Float:		fuel_amount,
Float:		fuel_posX,
Float:		fuel_posY,
Float:		fuel_posZ
}


new
			fuel_Data[MAX_FUEL_LOCATIONS][E_FUEL_DATA],
Iterator:	fuel_Index<MAX_FUEL_LOCATIONS>,
Timer:		fuel_RefuelTimer[MAX_PLAYERS],
			fuel_CurrentFuelOutlet[MAX_PLAYERS],
			fuel_CurrentlyRefuelling[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	fuel_CurrentlyRefuelling[playerid] = -1;
}


stock CreateFuelOutlet(Float:x, Float:y, Float:z, Float:areasize, Float:capacity, Float:startamount)
{
	new id = Iter_Free(fuel_Index);

	fuel_Data[id][fuel_areaId]		= CreateDynamicSphere(x, y, z, areasize);

	fuel_Data[id][fuel_state]		= 1;
	fuel_Data[id][fuel_capacity]	= capacity;
	fuel_Data[id][fuel_amount]		= startamount;

	fuel_Data[id][fuel_posX]		= x;
	fuel_Data[id][fuel_posY]		= y;
	fuel_Data[id][fuel_posZ]		= z;

	Iter_Add(fuel_Index, id);

	return id;
}

stock DestroyFuelOutlet(id)
{
	if(!Iter_Contains(fuel_Index, id))
		return 0;

	DestroyDynamicArea(fuel_Data[id][fuel_areaId]);

	fuel_Data[id][fuel_state]		= 0;
	fuel_Data[id][fuel_capacity]	= 0.0;
	fuel_Data[id][fuel_amount]		= 0.0;

	fuel_Data[id][fuel_posX]		= 0.0;
	fuel_Data[id][fuel_posY]		= 0.0;
	fuel_Data[id][fuel_posZ]		= 0.0;

	Iter_Remove(fuel_Index, id);

	return 1;
}

stock IsPlayerAtAnyFuelOutlet(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	foreach(new i : fuel_Index)
	{
		if(IsPlayerInDynamicArea(playerid, fuel_Data[i][fuel_areaId]))
			return 1;
	}
	return 0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		new itemid = GetPlayerItem(playerid);
		if(GetItemType(itemid) == item_GasCan)
		{
			foreach(new i : fuel_Index)
			{
				if(IsPlayerInDynamicArea(playerid, fuel_Data[i][fuel_areaId]))
				{
					if(GetItemExtraData(itemid) < FUEL_CAN_CAPACITY)
					{
						StartRefuellingFuelCan(playerid, i);
					}
				}
			}
		}
	}
	if(oldkeys & 16)
	{
		if(fuel_CurrentFuelOutlet[playerid] != -1)
		{
			StopRefuellingFuelCan(playerid);
		}
	}
}

StartRefuellingFuelCan(playerid, outletid)
{
	if(GetItemType(GetPlayerItem(playerid)) != item_GasCan)
	{
		ShowMsgBox(playerid, "You need a petrol can", 3000, 120);
		return 0;
	}

	if(fuel_Data[outletid][fuel_amount] <= 0.0)
	{
		ShowMsgBox(playerid, "Empty", 3000, 80);
		return 0;
	}

	CancelPlayerMovement(playerid);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, FUEL_CAN_CAPACITY);
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	stop fuel_RefuelTimer[playerid];
	fuel_RefuelTimer[playerid] = repeat RefuelCanUpdate(playerid);
	fuel_CurrentFuelOutlet[playerid] = outletid;

	ApplyAnimation(playerid, "HEIST9", "USE_SWIPECARD", 4.0, 0, 0, 0, 0, 500);

	return 1;
}
StopRefuellingFuelCan(playerid)
{
	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);

	stop fuel_RefuelTimer[playerid];
	fuel_CurrentFuelOutlet[playerid] = -1;
}

timer RefuelCanUpdate[500](playerid)
{
	if(fuel_CurrentFuelOutlet[playerid] == -1)
	{
		StopRefuellingFuelCan(playerid);
		return;
	}

	new
		itemid = GetPlayerItem(playerid),
		amount;

	amount = GetItemExtraData(itemid);

	if(amount >= FUEL_CAN_CAPACITY || fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] <= 0.0 || GetItemType(itemid) != item_GasCan)
	{
		StopRefuellingFuelCan(playerid);
		return;
	}

	SetPlayerProgressBarValue(playerid, ActionBar, float(amount));
	SetPlayerProgressBarMaxValue(playerid, ActionBar, FUEL_CAN_CAPACITY);
	ShowPlayerProgressBar(playerid, ActionBar);
	ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);

	SetItemExtraData(itemid, amount + 1);
	fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] -= 1.0;

	return;
}


StartRefuellingVehicle(playerid, vehicleid)
{
	if(GetItemType(GetPlayerItem(playerid)) != item_GasCan)
		return 0;

	CancelPlayerMovement(playerid);
	ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, GetVehicleFuelCapacity(vehicleid));
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	stop fuel_RefuelTimer[playerid];
	fuel_RefuelTimer[playerid] = repeat RefuelVehicleUpdate(playerid, vehicleid);
	fuel_CurrentlyRefuelling[playerid] = vehicleid;

	return 1;
}
StopRefuellingVehicle(playerid)
{
	stop fuel_RefuelTimer[playerid];

	if(!IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
		return 0;

	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);
	fuel_CurrentlyRefuelling[playerid] = -1;

	return 1;
}

timer RefuelVehicleUpdate[500](playerid, vehicleid)
{
	if(!IsValidVehicle(vehicleid))
	{
		StopRefuellingVehicle(playerid);
		return;
	}

	new
		itemid = GetPlayerItem(playerid),
		canfuel,
		Float:vehiclefuel,
		Float:px,
		Float:py,
		Float:pz,
		Float:vx,
		Float:vy,
		Float:vz;

	canfuel = GetItemExtraData(itemid);
	vehiclefuel = GetVehicleFuel(vehicleid);

	if(vehiclefuel >= GetVehicleFuelCapacity(vehicleid) || canfuel <= 0 || GetItemType(itemid) != item_GasCan || !IsPlayerInVehicleArea(playerid, vehicleid))
	{
		StopRefuellingVehicle(playerid);
		return;
	}


	SetPlayerProgressBarValue(playerid, ActionBar, vehiclefuel);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, GetVehicleFuelCapacity(vehicleid));
	ShowPlayerProgressBar(playerid, ActionBar);

	GetVehiclePos(vehicleid, vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

	SetItemExtraData(itemid, canfuel - 1);
	SetVehicleFuel(vehicleid, vehiclefuel + 1.0);

	return;
}
