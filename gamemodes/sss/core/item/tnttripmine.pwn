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


#include <YSI_4\y_hooks>


static
	tntm_ContainerOption[MAX_PLAYERS],
	tntm_ArmingItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnPlayerConnect(playerid)
{
	tntm_ArmingItem[playerid] = INVALID_ITEM_ID;
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntTripMine)
	{
		PlayerDropItem(playerid);
		tntm_ArmingItem[playerid] = itemid;

		StartHoldAction(playerid, 1000);
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, "Arming...");
		return 1;
	}
	#if defined tntm_OnPlayerUseItem
		return tntm_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntm_OnPlayerUseItem
#if defined tntm_OnPlayerUseItem
	forward tntm_OnPlayerUseItem(playerid, itemid);
#endif

hook OnHoldActionFinish(playerid)
{
	if(IsValidItem(tntm_ArmingItem[playerid]))
	{
		SetItemExtraData(tntm_ArmingItem[playerid], 1);
		ClearAnimations(playerid);
		ShowActionText(playerid, "Armed", 3000);

		tntm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(RELEASED(16) && IsValidItem(tntm_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		tntm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnPlayerPickUpItem(playerid, itemid)
{
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

public OnPlayerOpenContainer(playerid, containerid)
{
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

	#if defined tntm_OnPlayerOpenContainer
		return tntm_OnPlayerOpenContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tntm_OnPlayerOpenContainer
#if defined tntm_OnPlayerOpenContainer
	forward tntm_OnPlayerOpenContainer(playerid, containerid);
#endif

public OnPlayerViewContainerOpt(playerid, containerid)
{
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

	#if defined tntm_OnPlayerViewContainerOpt
		return tntm_OnPlayerViewContainerOpt(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt tntm_OnPlayerViewContainerOpt
#if defined tntm_OnPlayerViewContainerOpt
	forward tntm_OnPlayerViewContainerOpt(playerid, containerid);
#endif

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
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

	#if defined tntm_OnPlayerSelectContainerOpt
		return tntm_OnPlayerSelectContainerOpt(playerid, containerid, option);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt tntm_OnPlayerSelectContainerOpt
#if defined tntm_OnPlayerSelectContainerOpt
	forward tntm_OnPlayerSelectContainerOpt(playerid, containerid, option);
#endif
