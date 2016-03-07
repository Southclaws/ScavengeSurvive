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


static lsk_TargetVehicle[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	lsk_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

public OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(225.0 < angle < 315.0)
	{
		new
			itemid,
			ItemType:itemtype,
			vehicletype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);
		vehicletype = GetVehicleType(vehicleid);
		
		if(itemtype == item_LocksmithKit)
		{
			if(!IsVehicleTypeLockable(vehicletype))
			{
				ShowActionText(playerid, "You cannot lock a vehicle with no doors", 3000);
				return 1;
			}

			if(GetVehicleKey(vehicleid) != 0)
			{
				ShowActionText(playerid, "That vehicle has already been locked", 3000);
				return 1;
			}

			CancelPlayerMovement(playerid);
			StartCraftingKey(playerid, vehicleid);
		}

		if(itemtype == item_WheelLock)
		{
			if(GetItemArrayDataAtCell(itemid, 0) == 0)
			{
				ShowActionText(playerid, "That lock and chain has no key. Combine it with a Locksmith Kit.", 3000);
				return 1;
			}

			if(GetVehicleKey(vehicleid) != 0)
			{
				ShowActionText(playerid, "That vehicle has already been locked", 3000);
				return 1;
			}

			CancelPlayerMovement(playerid);
			StartCraftingKey(playerid, vehicleid);
		}

		if(itemtype == item_Key)
		{
			new
				keyid = GetItemArrayDataAtCell(itemid, 0),
				vehiclekey = GetVehicleKey(vehicleid);

			if(keyid == 0)
			{
				ShowActionText(playerid, "That key hasn't been cut yet.", 3000);
				return 1;
			}

			if(vehiclekey == 0)
			{
				ShowActionText(playerid, "That vehicle lock hasn't been set up for a key yet. Use a Locksmith Kit to set it up.", 3000);
				return 1;
			}

			if(keyid != vehiclekey)
			{
				ShowActionText(playerid, "That key doesn't fit this vehicle", 3000);
				return 1;
			}

			CancelPlayerMovement(playerid);

			// Update old keys to the correct vehicle type.
			SetItemArrayDataAtCell(itemid, vehicletype, 1);

			if(IsVehicleLocked(vehicleid))
			{
				SetVehicleExternalLock(vehicleid, 0);
				ShowActionText(playerid, "Unlocked", 3000);
				logf("[VLOCK] %p unlocked vehicle %d", playerid, vehicleid);
			}
			else
			{
				SetVehicleExternalLock(vehicleid, 1);
				ShowActionText(playerid, "Locked", 3000);
				logf("[VLOCK] %p locked vehicle %d", playerid, vehicleid);
			}

			if(IsVehicleTypeTrailer(vehicletype))
				SaveVehicle(GetTrailerVehicleID(vehicleid));

			else
				SaveVehicle(vehicleid);
		}
	}

	return CallLocalFunction("lsk_OnPlayerInteractVehicle", "ddf", playerid, vehicleid, Float:angle);
}
#if defined _ALS_OnPlayerInteractVehicle
	#undef OnPlayerInteractVehicle
#else
	#define _ALS_OnPlayerInteractVehicle
#endif
#define OnPlayerInteractVehicle lsk_OnPlayerInteractVehicle
forward lsk_OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopCraftingKey(playerid);
	}
}

StartCraftingKey(playerid, vehicleid)
{
	lsk_TargetVehicle[playerid] = vehicleid;
	ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

	StartHoldAction(playerid, 3000);

	return 0;
}

StopCraftingKey(playerid)
{
	if(lsk_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	ClearAnimations(playerid);
	StopHoldAction(playerid);

	lsk_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(
			!IsValidVehicle(lsk_TargetVehicle[playerid]) ||
			(GetItemType(GetPlayerItem(playerid)) != item_LocksmithKit && GetItemType(GetPlayerItem(playerid)) != item_WheelLock) ||
			!IsPlayerInVehicleArea(playerid, lsk_TargetVehicle[playerid]))
		{
			StopCraftingKey(playerid);
			return 1;
		}

		SetPlayerToFaceVehicle(playerid, lsk_TargetVehicle[playerid]);

		return 1;
	}

	#if defined lsk_OnHoldActionUpdate
		return lsk_OnHoldActionUpdate(playerid, progress);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate lsk_OnHoldActionUpdate
#if defined lsk_OnHoldActionUpdate
	forward lsk_OnHoldActionUpdate(playerid, progress);
#endif

public OnHoldActionFinish(playerid)
{
	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_LocksmithKit || itemtype == item_WheelLock)
		{
			new key = 1 + random(2147483646);

			DestroyItem(itemid);
			itemid = CreateItem(item_Key);
			GiveWorldItemToPlayer(playerid, itemid);

			SetItemArrayDataAtCell(itemid, key, 0);
			SetItemArrayDataAtCell(itemid, GetVehicleType(lsk_TargetVehicle[playerid]), 1);
			SetVehicleKey(lsk_TargetVehicle[playerid], key);
		}

		StopCraftingKey(playerid);			

		return 1;
	}

	#if defined lsk_OnHoldActionFinish
		return lsk_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish lsk_OnHoldActionFinish
#if defined lsk_OnHoldActionFinish
	forward lsk_OnHoldActionFinish(playerid);
#endif

public OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_Key)
	{
		if(GetItemArrayDataAtCell(itemid, 0) != 0)
		{
			new
				vehicletype = GetItemArrayDataAtCell(itemid, 1),
				vehicletypename[MAX_VEHICLE_TYPE_NAME];

			GetVehicleTypeName(vehicletype, vehicletypename);
			SetItemNameExtra(itemid, vehicletypename);
		}
	}
	else if(itemtype == item_WheelLock)
	{
		if(GetItemArrayDataAtCell(itemid, 0) == 0)
		{
			SetItemNameExtra(itemid, "Uncut");
		}
		else
		{
			SetItemNameExtra(itemid, "Cut");
		}
	}

	#if defined lsk_OnItemNameRender
		return lsk_OnItemNameRender(itemid, itemtype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender lsk_OnItemNameRender
#if defined lsk_OnItemNameRender
	forward lsk_OnItemNameRender(itemid, ItemType:itemtype);
#endif

public OnPlayerCrafted(playerid, craftset, result)
{
	if(GetCraftSetResult(craftset) == item_WheelLock)
	{
		SetItemArrayDataAtCell(result, 1, 0);
	}

	#if defined lsk_OnPlayerCrafted
		return lsk_OnPlayerCrafted(playerid, craftset, result);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCrafted
	#undef OnPlayerCrafted
#else
	#define _ALS_OnPlayerCrafted
#endif
 
#define OnPlayerCrafted lsk_OnPlayerCrafted
#if defined lsk_OnPlayerCrafted
	forward lsk_OnPlayerCrafted(playerid, craftset, result);
#endif
