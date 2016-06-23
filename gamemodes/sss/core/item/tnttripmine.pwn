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


static
	tntm_ContainerOption[MAX_PLAYERS],
	tntm_ArmingItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnGameModeInit()
{
	SetItemTypeMaxArrayData(item_TntTripMine, 1);
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/item/tnttripmine.pwn");

	tntm_ArmingItem[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/tnttripmine.pwn");

	if(GetItemType(itemid) == item_TntTripMine)
	{
		PlayerDropItem(playerid);
		tntm_ArmingItem[playerid] = itemid;

		StartHoldAction(playerid, 1000);
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, ls(playerid, "ARMINGBOMB"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/item/tnttripmine.pwn");

	if(IsValidItem(tntm_ArmingItem[playerid]))
	{
		SetItemExtraData(tntm_ArmingItem[playerid], 1);
		ClearAnimations(playerid);
		ShowActionText(playerid, ls(playerid, "ARMEDBOMB"), 3000);

		tntm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/tnttripmine.pwn");

	if(RELEASED(16) && IsValidItem(tntm_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		tntm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickUpItem] in /gamemodes/sss/core/item/tnttripmine.pwn");

	if(GetItemType(itemid) == item_TntTripMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			SetItemToExplode(itemid, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerOpenContainer] in /gamemodes/sss/core/item/tnttripmine.pwn");

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		new itemid = GetContainerSlotItem(containerid, i);

		if(GetItemType(itemid) == item_TntTripMine)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				SetItemToExplode(itemid, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
				break;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerViewCntOpt] in /gamemodes/sss/core/item/tnttripmine.pwn");

	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_TntTripMine)
	{
		if(GetItemExtraData(itemid) == 0)
			tntm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Trip Mine");

		else
			tntm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Trip Mine");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, containerid, option)
{
	d:3:GLOBAL_DEBUG("[OnPlayerSelectCntOpt] in /gamemodes/sss/core/item/tnttripmine.pwn");

	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_TntTripMine)
	{
		if(option == tntm_ContainerOption[playerid])
		{
			if(GetItemExtraData(itemid) == 0)
			{
				DisplayContainerInventory(playerid, containerid);
				SetItemExtraData(itemid, 1);
			}
			else
			{
				SetItemExtraData(itemid, 0);
				DisplayContainerInventory(playerid, containerid);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
