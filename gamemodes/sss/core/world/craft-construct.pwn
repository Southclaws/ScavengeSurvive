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


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_CONSTRUCT_SET (48)
#define MAX_CONSTRUCT_SET_ITEMS (BTN_MAX_INRANGE)


enum E_CONSTRUCT_SET_DATA
{
		cons_buildtime,
		cons_craftset
}


static
		cons_Data[MAX_CONSTRUCT_SET][E_CONSTRUCT_SET_DATA],
		cons_Total,
		cons_CraftsetConstructSet[CFT_MAX_CRAFT_SET],
		cons_Constructing[MAX_PLAYERS],
		cons_SelectedItems[MAX_PLAYERS][MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data];


forward OnPlayerConstruct(playerid, craftset);

static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	HANDLER = debug_register_handler("craft-construct");
}

hook OnPlayerConnect(playerid)
{
	cons_Constructing[playerid] = -1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock SetCraftSetConstructible(buildtime, craftset)
{
	if(GetCraftSetResult(craftset) == INVALID_ITEM_TYPE)
	{
		print("[SetCraftSetConstructible] ERROR: Invalid craftset.");
		return -1;
	}

	cons_Data[cons_Total][cons_buildtime] = buildtime;
	cons_Data[cons_Total][cons_craftset] = craftset;

	cons_CraftsetConstructSet[craftset] = cons_Total;

	return cons_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


public OnPlayerUseItem(playerid, itemid)
{
	new
		list[BTN_MAX_INRANGE] = {INVALID_ITEM_ID, ...},
		size;

	GetPlayerButtonList(playerid, list, size, true);

	if(size > 1)
	{
		d:1:HANDLER("[OnPlayerUseItem] Button list size %d, comparing with craft lists", size);

		for(new i; list[i] != INVALID_ITEM_ID && i < MAX_CONSTRUCT_SET_ITEMS; i++)
		{
			cons_SelectedItems[playerid][i][cft_selectedItemType] = GetItemType(list[i]);
			cons_SelectedItems[playerid][i][cft_selectedItemID] = list[i];
			d:3:HANDLER("[OnPlayerUseItem] List item: %d (%d)", _:cons_SelectedItems[playerid][i][cft_selectedItemType], cons_SelectedItems[playerid][i][cft_selectedItemID]);
		}

		new craftset = _cft_FindCraftset(cons_SelectedItems[playerid], size);
		d:2:HANDLER("[OnPlayerUseItem] Craftset determined as %d", craftset);

		if(GetCraftSetResult(craftset) == GetItemType(itemid))
		{
			d:2:HANDLER("[OnPlayerUseItem] Tool matches current item, begin holdaction");

			new consset = cons_CraftsetConstructSet[craftset];

			StartHoldAction(playerid, cons_Data[consset][cons_buildtime]);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			ShowActionText(playerid, "Constructing items...");

			cons_Constructing[playerid] = craftset;

			return 1;
		}
	}

	#if defined cons_OnPlayerUseItem
		return cons_OnPlayerUseItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem cons_OnPlayerUseItem
#if defined cons_OnPlayerUseItem
	forward cons_OnPlayerUseItem(playerid, itemid);
#endif


public OnHoldActionFinish(playerid)
{
	if(cons_Constructing[playerid] != -1)
	{
		d:2:HANDLER("[OnHoldActionFinish] Calling OnPlayerConstruct %d %d", playerid, cons_CraftsetConstructSet[cons_Constructing[playerid]]);

		CallLocalFunction("OnPlayerConstruct", "dd", playerid, cons_CraftsetConstructSet[cons_Constructing[playerid]]);
		ClearAnimations(playerid);
		HideActionText(playerid);

		cons_Constructing[playerid] = -1;
	}

	#if defined cons_OnHoldActionFinish
		return cons_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish cons_OnHoldActionFinish
forward cons_OnHoldActionFinish(playerid);


public OnPlayerCraft(playerid, craftset)
{
	if(cons_CraftsetConstructSet[craftset])
		return 1;

	#if defined cons_OnPlayerCraft
		return cons_OnPlayerCraft(playerid, craftset);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerCraft
	#undef OnPlayerCraft
#else
	#define _ALS_OnPlayerCraft
#endif
#define OnPlayerCraft cons_OnPlayerCraft
#if defined cons_OnPlayerCraft
	forward cons_OnPlayerCraft(playerid, craftset);
#endif


/*==============================================================================

	Interface

==============================================================================*/


stock GetCraftSetConstructSet(craftset)
{
	return cons_CraftsetConstructSet[craftset];
}

stock GetPlayerConstructing(playerid)
{
	return cons_Constructing[playerid];
}

stock GetPlayerConstructionItems(playerid, output[CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data])
{
	output = cons_SelectedItems[playerid];

	return 1;
}
