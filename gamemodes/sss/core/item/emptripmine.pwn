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


static
	empm_ContainerOption[MAX_PLAYERS],
	empm_ArmingItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnPlayerConnect(playerid)
{
	empm_ArmingItem[playerid] = INVALID_ITEM_ID;
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTripMine)
	{
		PlayerDropItem(playerid);
		empm_ArmingItem[playerid] = itemid;

		StartHoldAction(playerid, 500);
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, "Arming...");

		return 1;
	}

	#if defined empm_OnPlayerUseItem
		return empm_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem empm_OnPlayerUseItem
#if defined empm_OnPlayerUseItem
	forward empm_OnPlayerUseItem(playerid, itemid);
#endif

public OnHoldActionFinish(playerid)
{
	if(IsValidItem(empm_ArmingItem[playerid]))
	{
		SetItemExtraData(empm_ArmingItem[playerid], 1);
		ClearAnimations(playerid);
		ShowActionText(playerid, "Armed", 3000);

		empm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}

	#if defined empm_OnHoldActionFinish
		return empm_OnHoldActionFinish(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish empm_OnHoldActionFinish
#if defined empm_OnHoldActionFinish
	forward empm_OnHoldActionFinish(playerid);
#endif

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTripMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			SetItemToExplode(itemid, 0, 12.0, EXPLOSION_PRESET_EMP, 0);

			return 1;
		}
	}
	#if defined empm_OnPlayerPickUpItem
		return empm_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem empm_OnPlayerPickUpItem
#if defined empm_OnPlayerPickUpItem
	forward empm_OnPlayerPickUpItem(playerid, itemid);
#endif

public OnPlayerOpenContainer(playerid, containerid)
{
	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		new itemid = GetContainerSlotItem(containerid, i);

		if(GetItemType(itemid) == item_EmpTripMine)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				SetItemToExplode(itemid, 0, 12.0, EXPLOSION_PRESET_EMP, 0);
				RemoveItemFromContainer(containerid, i);
			}
		}
	}

	#if defined empm_OnPlayerOpenContainer
		return empm_OnPlayerOpenContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer empm_OnPlayerOpenContainer
#if defined empm_OnPlayerOpenContainer
	forward empm_OnPlayerOpenContainer(playerid, containerid);
#endif

public OnPlayerViewContainerOpt(playerid, containerid)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_EmpTripMine)
	{
		if(GetItemExtraData(itemid) == 0)
			empm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Trip Mine");

		else
			empm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Trip Mine");
	}

	#if defined empm_OnPlayerViewContainerOpt
		return empm_OnPlayerViewContainerOpt(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt empm_OnPlayerViewContainerOpt
#if defined empm_OnPlayerViewContainerOpt
	forward empm_OnPlayerViewContainerOpt(playerid, containerid);
#endif

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_EmpTripMine)
	{
		if(option == empm_ContainerOption[playerid])
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

	#if defined empm_OnPlayerSelectContainerOpt
		return empm_OnPlayerSelectContainerOpt(playerid, containerid, option);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt empm_OnPlayerSelectContainerOpt
#if defined empm_OnPlayerSelectContainerOpt
	forward empm_OnPlayerSelectContainerOpt(playerid, containerid, option);
#endif
