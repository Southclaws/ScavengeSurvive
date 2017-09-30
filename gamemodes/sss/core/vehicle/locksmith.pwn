/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/vehicle/locksmith.pwn");

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
				ShowActionText(playerid, ls(playerid, "LOCKNODOORS", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(GetVehicleKey(vehicleid) != 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKALREADY", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			CancelPlayerMovement(playerid);
			StartCraftingKey(playerid, vehicleid);
		}

		if(itemtype == item_WheelLock)
		{
			if(GetItemArrayDataAtCell(itemid, 0) == 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKCHNOKEY", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(GetVehicleKey(vehicleid) != 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKALREADY", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
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
				ShowActionText(playerid, ls(playerid, "LOCKKEYNCUT", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(vehiclekey == 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKVNOLOCK", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(keyid != vehiclekey)
			{
				ShowActionText(playerid, ls(playerid, "LOCKKEYNFIT", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			CancelPlayerMovement(playerid);

			// Update old keys to the correct vehicle type.
			SetItemArrayDataAtCell(itemid, vehicletype, 1);

			if(GetVehicleLockState(vehicleid) != E_LOCK_STATE_OPEN)
			{
				SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);
				ShowActionText(playerid, ls(playerid, "UNLOCKED", true), 3000);
				log("[VLOCK] %p unlocked vehicle %s (%d)", playerid, GetVehicleGEID(vehicleid), vehicleid);
			}
			else
			{
				SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);
				ShowActionText(playerid, ls(playerid, "LOCKED", true), 3000);
				log("[VLOCK] %p locked vehicle %s (%d)", playerid, GetVehicleGEID(vehicleid), vehicleid);
			}

			if(IsVehicleTypeTrailer(vehicletype))
				SaveVehicle(GetTrailerVehicleID(vehicleid));

			else
				SaveVehicle(vehicleid);
		}

		if(itemtype == item_LockBreaker)
		{
			if(GetVehicleKey(vehicleid) == 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKVNOLOCK", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			StartBreakingVehicleLock(playerid, vehicleid, 0);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/vehicle/locksmith.pwn");

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

hook OnHoldActionUpdate(playerid, progress)
{
	dbg("global", CORE, "[OnHoldActionUpdate] in /gamemodes/sss/core/vehicle/locksmith.pwn");

	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(
			!IsValidVehicle(lsk_TargetVehicle[playerid]) ||
			(GetItemType(GetPlayerItem(playerid)) != item_LocksmithKit && GetItemType(GetPlayerItem(playerid)) != item_WheelLock) ||
			!IsPlayerInVehicleArea(playerid, lsk_TargetVehicle[playerid]))
		{
			StopCraftingKey(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		SetPlayerToFaceVehicle(playerid, lsk_TargetVehicle[playerid]);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	dbg("global", CORE, "[OnHoldActionFinish] in /gamemodes/sss/core/vehicle/locksmith.pwn");

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

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	dbg("global", CORE, "[OnItemNameRender] in /gamemodes/sss/core/vehicle/locksmith.pwn");

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
}

hook OnPlayerCrafted(playerid, craftset, result)
{
	dbg("global", CORE, "[OnPlayerCrafted] in /gamemodes/sss/core/vehicle/locksmith.pwn");

	if(GetCraftSetResult(craftset) == item_WheelLock)
	{
		SetItemArrayDataAtCell(result, 1, 0);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerConstructed(playerid, consset, result)
{
	new craftset = GetConstructionSetCraftSet(consset);

	if(GetCraftSetResult(craftset) == item_Key)
	{
		new
			items[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
			count,
			tmp,
			itemid = INVALID_ITEM_ID;

		GetPlayerConstructionItems(playerid, items, count);

		for(new i; i < count; i++)
		{
			tmp = items[i][cft_selectedItemID];

			if(GetItemType(tmp) == item_Key && GetItemArrayDataAtCell(tmp, 0) > 0)
			{
				itemid = tmp;
				break;
			}
		}

		if(IsValidItem(itemid))
		{
			SetItemArrayDataSize(result, 2);
			SetItemArrayDataAtCell(result, GetItemArrayDataAtCell(itemid, 0), 0);
			SetItemArrayDataAtCell(result, GetItemArrayDataAtCell(itemid, 1), 1);
		}
		else
		{
			err("Key duplicated attempt failed %d %d %d %d", consset, craftset, result, tmp);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}