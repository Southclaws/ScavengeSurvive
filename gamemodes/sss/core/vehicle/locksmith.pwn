/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


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
			Item:itemid,
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
			new key;
			GetItemArrayDataAtCell(itemid, key, 0);
			if(key == 0)
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
				keyid,
				vehiclekey = GetVehicleKey(vehicleid);

			GetItemArrayDataAtCell(itemid, keyid, 0);

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
				log("[VLOCK] %p unlocked vehicle %s (%d)", playerid, GetVehicleUUID(vehicleid), vehicleid);
			}
			else
			{
				SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);
				ShowActionText(playerid, ls(playerid, "LOCKED", true), 3000);
				log("[VLOCK] %p locked vehicle %s (%d)", playerid, GetVehicleUUID(vehicleid), vehicleid);
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
	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		new
			Item:itemid,
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

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_Key)
	{
		new value;
		GetItemArrayDataAtCell(itemid, value, 0);
		if(value != 0)
		{
			new
				vehicletype,
				vehicletypename[MAX_VEHICLE_TYPE_NAME];

			GetItemArrayDataAtCell(itemid, vehicletype, 1);
			GetVehicleTypeName(vehicletype, vehicletypename);
			SetItemNameExtra(itemid, vehicletypename);
		}
	}
	else if(itemtype == item_WheelLock)
	{
		new value;
		GetItemArrayDataAtCell(itemid, value, 0);
		if(value == 0)
		{
			SetItemNameExtra(itemid, "Uncut");
		}
		else
		{
			SetItemNameExtra(itemid, "Cut");
		}
	}
}

hook OnPlayerCrafted(playerid, CraftSet:craftset, Item:result)
{
	new ItemType:resulttype;
	GetCraftSetResult(craftset, resulttype);
	if(resulttype == item_WheelLock)
	{
		SetItemArrayDataAtCell(result, 1, 0);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerConstructed(playerid, consset, Item:result)
{
	new CraftSet:craftset = GetConstructionSetCraftSet(consset);
	new ItemType:resulttype;
	GetCraftSetResult(craftset, resulttype);
	if(resulttype == item_Key)
	{
		new
			items[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
			count,
			Item:tmp,
			data,
			Item:itemid = INVALID_ITEM_ID;

		GetPlayerConstructionItems(playerid, items, count);

		for(new i; i < count; i++)
		{
			tmp = items[i][craft_selectedItemID];
			GetItemArrayDataAtCell(tmp, data, 0);

			if(GetItemType(tmp) == item_Key && data > 0)
			{
				itemid = tmp;
				break;
			}
		}

		if(IsValidItem(itemid))
		{
			SetItemArrayDataSize(result, 2);
			new v1, v2;
			GetItemArrayDataAtCell(itemid, v1, 0);
			GetItemArrayDataAtCell(itemid, v2, 1);
			SetItemArrayDataAtCell(result, v1, 0);
			SetItemArrayDataAtCell(result, v2, 1);
		}
		else
		{
			err("Key duplicated attempt failed %d %d %d %d", consset, _:craftset, _:result, _:tmp);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
