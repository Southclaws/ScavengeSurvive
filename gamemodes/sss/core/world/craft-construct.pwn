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


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_CONSTRUCT_SET (48)
#define MAX_CONSTRUCT_SET_ITEMS (BTN_MAX_INRANGE)


enum E_CONSTRUCT_SET_DATA
{
			cons_buildtime,
ItemType:	cons_tool,
			cons_craftset,
ItemType:	cons_removalTool,
			cons_removalTime,
bool:		cons_tweak
}


static
		cons_Data[MAX_CONSTRUCT_SET][E_CONSTRUCT_SET_DATA],
		cons_Total,
		cons_CraftsetConstructSet[CFT_MAX_CRAFT_SET] = {-1, ...},
		cons_Constructing[MAX_PLAYERS] = {-1, ...},
		cons_Deconstructing[MAX_PLAYERS] = {-1, ...},
		cons_DeconstructingItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
		cons_SelectedItems[MAX_PLAYERS][MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
		cons_SelectedItemCount[MAX_PLAYERS];


forward OnPlayerConstruct(playerid, consset);
forward OnPlayerConstructed(playerid, consset, result);
forward OnPlayerDeconstructed(playerid, itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/world/craft-construct.pwn");

	for(new i; i < MAX_CONSTRUCT_SET_ITEMS; i++)
	{
		cons_SelectedItems[playerid][i][cft_selectedItemType] = INVALID_ITEM_TYPE;
		cons_SelectedItems[playerid][i][cft_selectedItemID] = INVALID_ITEM_ID;
	}

	cons_SelectedItemCount[playerid] = 0;
	cons_Constructing[playerid] = -1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock SetCraftSetConstructible(buildtime, ItemType:tool, craftset, ItemType:removal = INVALID_ITEM_TYPE, removaltime = 0, bool:tweak = true)
{
	cons_Data[cons_Total][cons_buildtime] = buildtime;
	cons_Data[cons_Total][cons_tool] = tool;
	cons_Data[cons_Total][cons_craftset] = craftset;
	cons_Data[cons_Total][cons_removalTool] = removal;
	cons_Data[cons_Total][cons_removalTime] = removaltime;
	cons_Data[cons_Total][cons_tweak] = tweak;

	cons_CraftsetConstructSet[craftset] = cons_Total;

	return cons_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/world/craft-construct.pwn");

	new
		list[BTN_MAX_INRANGE] = {INVALID_BUTTON_ID, ...},
		size;

	size = GetPlayerNearbyItems(playerid, list);

	if(size > 1)
	{
		dbg("gamemodes/sss/core/world/craft-construct.pwn", 1, "[OnPlayerUseItem] Button list size %d, comparing with craft lists", size);

		_ResetSelectedItems(playerid);

		for(new i; i < size; i++)
		{
			cons_SelectedItems[playerid][i][cft_selectedItemType] = GetItemType(list[i]);
			cons_SelectedItems[playerid][i][cft_selectedItemID] = list[i];
			cons_SelectedItemCount[playerid]++;
			dbg("gamemodes/sss/core/world/craft-construct.pwn", 3, "[OnPlayerUseItem] List item: %d (%d) valid: %d", _:cons_SelectedItems[playerid][i][cft_selectedItemType], cons_SelectedItems[playerid][i][cft_selectedItemID], IsValidItem(cons_SelectedItems[playerid][i][cft_selectedItemID]));
		}

		new craftset = _cft_FindCraftset(cons_SelectedItems[playerid], size);
		dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnPlayerUseItem] Craftset determined as %d", craftset);

		if(IsValidCraftSet(craftset))
		{
			dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnPlayerUseItem] Craftset determined as %d craftset constructionset %d", craftset, cons_CraftsetConstructSet[craftset]);

			if(cons_CraftsetConstructSet[craftset] != -1)
			{
				if(cons_Data[cons_CraftsetConstructSet[craftset]][cons_tool] == GetItemType(GetPlayerItem(playerid)))
				{
					dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnPlayerUseItem] Tool matches current item, begin holdaction");
					if(!CallLocalFunction("OnPlayerConstruct", "dd", playerid, cons_CraftsetConstructSet[craftset]))
					{
						new uniqueid[ITM_MAX_NAME];
						GetItemTypeName(GetCraftSetResult(craftset), uniqueid);
						StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, cons_Data[cons_CraftsetConstructSet[craftset]][cons_buildtime], uniqueid));
						ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
						ShowActionText(playerid, ls(playerid, "CONSTRUCTIN", true));

						cons_Constructing[playerid] = craftset;

						return Y_HOOKS_BREAK_RETURN_1;
					}
					else
					{
						dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnPlayerUseItem] OnPlayerConstruct returned nonzero");
					}
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	new craftset = ItemTypeResultForCraftingSet(GetItemType(withitemid));

	if(IsValidCraftSet(craftset))
	{
		dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnPlayerUseItemWithItem] withitem type is the result of a craftset");
		if(cons_CraftsetConstructSet[craftset] != -1)
		{
			dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnPlayerUseItemWithItem] craftset is a construction set");
			if(GetItemType(itemid) == cons_Data[cons_CraftsetConstructSet[craftset]][cons_removalTool])
			{
				dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnPlayerUseItemWithItem] held item is removal tool of craft set");
				StartRemovingConstructedItem(playerid, withitemid, craftset);
			}
		}
	}
}

StartRemovingConstructedItem(playerid, itemid, craftset)
{
	new uniqueid[ITM_MAX_NAME];
	GetItemTypeName(GetCraftSetResult(craftset), uniqueid);
	StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, cons_Data[cons_CraftsetConstructSet[craftset]][cons_removalTime], uniqueid));
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "DECONSTRUCT", true));
	cons_Deconstructing[playerid] = craftset;
	cons_DeconstructingItem[playerid] = itemid;
}

StopRemovingConstructedItem(playerid)
{
	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);
	cons_Deconstructing[playerid] = -1;
	cons_DeconstructingItem[playerid] = INVALID_ITEM_ID;
}

hook OnHoldActionFinish(playerid)
{
	dbg("global", CORE, "[OnHoldActionFinish] in /gamemodes/sss/core/world/craft-construct.pwn");

	if(cons_Constructing[playerid] != -1)
	{
		dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnHoldActionFinish] creating result and destroying items marked to not keep");

		new
			Float:x,
			Float:y,
			Float:z,
			Float:tx,
			Float:ty,
			Float:tz,
			count,
			itemid,
			uniqueid[ITM_MAX_NAME];

		GetItemTypeName(GetCraftSetResult(cons_Constructing[playerid]), uniqueid);
		// DestroyItem(GetPlayerItem(playerid));

		for( ; count < cons_SelectedItemCount[playerid] && cons_SelectedItems[playerid][count][cft_selectedItemID] != INVALID_ITEM_ID; count++)
		{
			GetItemPos(cons_SelectedItems[playerid][count][cft_selectedItemID], x, y, z);

			if(x * y * z != 0.0)
			{
				tx += x;
				ty += y;
				tz += z;
			}

			if(!GetCraftSetItemKeep(cons_Constructing[playerid], count))
				DestroyItem(cons_SelectedItems[playerid][count][cft_selectedItemID]);
		}

		tx /= float(count);
		ty /= float(count);
		tz /= float(count);

		itemid = CreateItem(GetCraftSetResult(cons_Constructing[playerid]), tx, ty, tz, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
		PlayerGainSkillExperience(playerid, uniqueid);

		if(cons_Data[cons_CraftsetConstructSet[cons_Constructing[playerid]]][cons_tweak])
			TweakItem(playerid, itemid);

		dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnHoldActionFinish] Calling OnPlayerConstructed %d %d %d", playerid, cons_CraftsetConstructSet[cons_Constructing[playerid]], itemid);
		CallLocalFunction("OnPlayerConstructed", "ddd", playerid, cons_CraftsetConstructSet[cons_Constructing[playerid]], itemid);

		ClearAnimations(playerid);
		HideActionText(playerid);

		_ResetSelectedItems(playerid);
		cons_Constructing[playerid] = -1;
	}
	else if(cons_Deconstructing[playerid] != INVALID_ITEM_ID)
	{
		dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnHoldActionFinish] Calling OnPlayerDeconstructed %d %d %d", playerid, cons_DeconstructingItem[playerid], cons_Deconstructing[playerid]);

		if(!CallLocalFunction("OnPlayerDeconstructed", "ddd", playerid, cons_DeconstructingItem[playerid], cons_Deconstructing[playerid]))
		{
			dbg("gamemodes/sss/core/world/craft-construct.pwn", 2, "[OnHoldActionFinish] OnPlayerDeconstructed returned zero, destroying item and returning ingredients");

			new
				Float:x,
				Float:y,
				Float:z,
				recipedata[CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data],
				recipeitems;

			GetItemPos(cons_DeconstructingItem[playerid], x, y, z);

			DestroyItem(cons_DeconstructingItem[playerid]);

			recipeitems = GetCraftSetIngredients(cons_Deconstructing[playerid], recipedata);

			for(new i; i < recipeitems; i++)
			{
				dbg("gamemodes/sss/core/world/craft-construct.pwn", 3, "[OnHoldActionFinish] recipe items %d/%d: type: %d keep: %d", i, recipeitems, _:recipedata[i][cft_itemType], recipedata[i][cft_keepItem]);
				// items that were kept at the time of crafting are ignored
				// since they never originally left the player's posession.
				if(recipedata[i][cft_keepItem])
					continue;

				CreateItem(recipedata[i][cft_itemType], x + frandom(0.6), y + frandom(0.6), z, 0.0, 0.0, frandom(360.0), GetItemWorld(cons_DeconstructingItem[playerid]), GetItemInterior(cons_DeconstructingItem[playerid]));
			}

			StopRemovingConstructedItem(playerid);
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/world/craft-construct.pwn");

	if(RELEASED(16))
	{
		if(cons_Constructing[playerid] != -1)
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);
			HideActionText(playerid);
			_ResetSelectedItems(playerid);

			cons_Constructing[playerid] = -1;
		}
		else if(cons_Deconstructing[playerid] != -1)
		{
			StopRemovingConstructedItem(playerid);
		}
	}
}

hook OnPlayerCraft(playerid, craftset)
{
	dbg("global", CORE, "[OnPlayerCraft] in /gamemodes/sss/core/world/craft-construct.pwn");

	if(cons_CraftsetConstructSet[craftset] != -1)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_ResetSelectedItems(playerid)
{
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS; i++)
	{
		cons_SelectedItems[playerid][i][cft_selectedItemType] = INVALID_ITEM_TYPE;
		cons_SelectedItems[playerid][i][cft_selectedItemID] = INVALID_ITEM_ID;
	}
	cons_SelectedItemCount[playerid] = 0;
}


/*==============================================================================

	Interface

==============================================================================*/


// cons_Total
stock IsValidConstructionSet(consset)
{
	if(!(0 <= consset < MAX_CONSTRUCT_SET))
		return 0;

	return 1;
}

// cons_buildtime
stock GetConstructionSetBuildTime(consset)
{
	if(!(0 <= consset < MAX_CONSTRUCT_SET))
		return -1;

	return cons_Data[consset][cons_buildtime];
}

// cons_tool
forward ItemType:GetConstructionSetTool(consset);
stock ItemType:GetConstructionSetTool(consset)
{
	if(!(0 <= consset < MAX_CONSTRUCT_SET))
		return INVALID_ITEM_TYPE;

	return cons_Data[consset][cons_tool];
}

// cons_craftset
stock GetConstructionSetCraftSet(consset)
{
	if(!(0 <= consset < MAX_CONSTRUCT_SET))
		return -1;

	return cons_Data[consset][cons_craftset];
}

// cons_CraftsetConstructSet[craftset]
stock GetCraftSetConstructSet(craftset)
{
	if(!IsValidCraftSet(craftset))
		return -1;

	return cons_CraftsetConstructSet[craftset];
}

stock GetPlayerConstructing(playerid)
{
	return cons_Constructing[playerid];
}

stock GetPlayerConstructionItems(playerid, output[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data], &count)
{
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS && cons_SelectedItems[playerid][i][cft_selectedItemID] != -1; i++)
		output[i] = cons_SelectedItems[playerid][i];

	count = cons_SelectedItemCount[playerid];

	return 1;
}
