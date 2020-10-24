/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_CONSTRUCT_SET (48)
#define MAX_CONSTRUCT_SET_ITEMS (BTN_MAX_INRANGE)


enum E_CONSTRUCT_SET_DATA
{
			cons_buildtime,
ItemType:	cons_tool,
CraftSet:	cons_craftset,
ItemType:	cons_removalTool,
			cons_removalTime,
bool:		cons_tweak,
bool:		cons_defence
}


static
		cons_Data[MAX_CONSTRUCT_SET][E_CONSTRUCT_SET_DATA],
		cons_Total,
		cons_CraftsetConstructSet[CRAFT_MAX_CRAFT_SET] = {-1, ...},
CraftSet:cons_Constructing[MAX_PLAYERS] = {INVALID_CRAFTSET, ...},
CraftSet:cons_Deconstructing[MAX_PLAYERS] = {INVALID_CRAFTSET, ...},
Item:	cons_DeconstructingItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
		cons_SelectedItems[MAX_PLAYERS][MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
		cons_SelectedItemCount[MAX_PLAYERS];


forward OnPlayerConstruct(playerid, consset);
forward OnPlayerConstructed(playerid, consset, result);
forward OnPlayerDeconstructed(playerid, Item:itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS; i++)
	{
		cons_SelectedItems[playerid][i][craft_selectedItemType] = INVALID_ITEM_TYPE;
		cons_SelectedItems[playerid][i][craft_selectedItemID] = INVALID_ITEM_ID;
	}

	cons_SelectedItemCount[playerid] = 0;
	cons_Constructing[playerid] = INVALID_CRAFTSET;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock SetCraftSetConstructible(buildtime, ItemType:tool, CraftSet:craftset, ItemType:removal = INVALID_ITEM_TYPE, removaltime = 0, bool:tweak = true, bool:defence = false)
{
	cons_Data[cons_Total][cons_buildtime] = buildtime;
	cons_Data[cons_Total][cons_tool] = tool;
	cons_Data[cons_Total][cons_craftset] = craftset;
	cons_Data[cons_Total][cons_removalTool] = removal;
	cons_Data[cons_Total][cons_removalTime] = removaltime;
	cons_Data[cons_Total][cons_tweak] = tweak;
	cons_Data[cons_Total][cons_defence] = defence;

	cons_CraftsetConstructSet[craftset] = cons_Total;

	return cons_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseItem(playerid, Item:itemid)
{
	new
		Item:list[BTN_MAX_INRANGE] = {INVALID_ITEM_ID, ...},
		size;

	size = GetPlayerNearbyItems(playerid, list);

	if(size > 1)
	{
		dbg("craft-construct", 1, "[OnPlayerUseItem] Item list size %d, comparing with craft lists", size);

		_ResetSelectedItems(playerid);

		for(new i; i < size; i++)
		{
			cons_SelectedItems[playerid][i][craft_selectedItemType] = GetItemType(list[i]);
			cons_SelectedItems[playerid][i][craft_selectedItemID] = list[i];
			cons_SelectedItemCount[playerid]++;
			dbg("craft-construct", 3, "[OnPlayerUseItem] List item: %d (%d) valid: %d", _:cons_SelectedItems[playerid][i][craft_selectedItemType], _:cons_SelectedItems[playerid][i][craft_selectedItemID], IsValidItem(cons_SelectedItems[playerid][i][craft_selectedItemID]));
		}

		new CraftSet:craftset = _craft_FindCraftset(cons_SelectedItems[playerid], size);
		dbg("craft-construct", 2, "[OnPlayerUseItem] Craftset determined as %d", _:craftset);

		if(IsValidCraftSet(craftset))
		{
			dbg("craft-construct", 2, "[OnPlayerUseItem] Craftset determined as %d craftset constructionset %d", _:craftset, cons_CraftsetConstructSet[craftset]);

			if(cons_CraftsetConstructSet[craftset] != -1)
			{
				if(cons_Data[cons_CraftsetConstructSet[craftset]][cons_tool] == GetItemType(GetPlayerItem(playerid)))
				{
					dbg("craft-construct", 2, "[OnPlayerUseItem] Tool matches current item, begin holdaction");
					if(!CallLocalFunction("OnPlayerConstruct", "dd", playerid, cons_CraftsetConstructSet[craftset]))
					{
						new
							uniqueid[MAX_ITEM_NAME],
							ItemType:result;
						GetCraftSetResult(craftset, result);

						GetItemTypeName(result, uniqueid);
						StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, cons_Data[cons_CraftsetConstructSet[craftset]][cons_buildtime], uniqueid));
						ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
						ShowActionText(playerid, ls(playerid, "CONSTRUCTIN", true));

						cons_Constructing[playerid] = craftset;

						return Y_HOOKS_BREAK_RETURN_1;
					}
					else
					{
						dbg("craft-construct", 2, "[OnPlayerUseItem] OnPlayerConstruct returned nonzero");
					}
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	new CraftSet:craftset;
	ItemTypeResultForCraftingSet(GetItemType(withitemid), craftset);

	if(IsValidCraftSet(craftset))
	{
		dbg("craft-construct", 2, "[OnPlayerUseItemWithItem] withitem type is the result of a craftset");
		if(cons_CraftsetConstructSet[craftset] != -1)
		{
			dbg("craft-construct", 2, "[OnPlayerUseItemWithItem] craftset is a construction set");
			if(GetItemType(itemid) == cons_Data[cons_CraftsetConstructSet[craftset]][cons_removalTool])
			{
				dbg("craft-construct", 2, "[OnPlayerUseItemWithItem] held item is removal tool of craft set");
				StartRemovingConstructedItem(playerid, withitemid, craftset);
			}
		}
	}
}

StartRemovingConstructedItem(playerid, Item:itemid, CraftSet:craftset)
{
	new
		ItemType:result,
		uniqueid[MAX_ITEM_NAME];
	GetCraftSetResult(craftset, result);
	GetItemTypeName(result, uniqueid);
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
	cons_Deconstructing[playerid] = INVALID_CRAFTSET;
	cons_DeconstructingItem[playerid] = INVALID_ITEM_ID;
}

// TODO: Check if items are still there
// if a player picked one up during construction, it could be duplicated maybe.
hook OnHoldActionFinish(playerid)
{
	if(cons_Constructing[playerid] != INVALID_CRAFTSET)
	{
		dbg("craft-construct", 2, "[OnHoldActionFinish] creating result and destroying items marked to not keep");

		new
			ItemType:result,
			Float:x,
			Float:y,
			Float:z,
			Float:tx,
			Float:ty,
			Float:tz,
			count,
			Item:itemid,
			uniqueid[MAX_ITEM_NAME];

		GetCraftSetResult(cons_Constructing[playerid], result);
		GetItemTypeName(result, uniqueid);
		// DestroyItem(GetPlayerItem(playerid));

		// first make sure all items are in the world, if one isn't, exit early.
		for( ; count < cons_SelectedItemCount[playerid] && cons_SelectedItems[playerid][count][craft_selectedItemID] != INVALID_ITEM_ID; count++)
		{
			if(!IsItemInWorld(cons_SelectedItems[playerid][count][craft_selectedItemID]))
			{
				dbg("craft-construct", 2, "[OnHoldActionFinish] selected item %d is not in the world any more", _:cons_SelectedItems[playerid][count][craft_selectedItemID]);
				return;
			}
		}

		for(count = 0 ; count < cons_SelectedItemCount[playerid] && cons_SelectedItems[playerid][count][craft_selectedItemID] != INVALID_ITEM_ID; count++)
		{
			GetItemPos(cons_SelectedItems[playerid][count][craft_selectedItemID], x, y, z);

			if(x * y * z != 0.0)
			{
				tx += x;
				ty += y;
				tz += z;
			}

			new bool:keep;
			GetCraftSetItemKeep(cons_Constructing[playerid], count, keep);

			if(!keep)
			{
				DestroyItem(cons_SelectedItems[playerid][count][craft_selectedItemID]);
			}
		}

		tx /= float(count);
		ty /= float(count);
		tz /= float(count);

		itemid = CreateItem(result, tx, ty, tz, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
		PlayerGainSkillExperience(playerid, uniqueid);

		if(cons_Data[cons_CraftsetConstructSet[cons_Constructing[playerid]]][cons_defence])
			ConvertItemToDefenceItem(itemid, 0);

		if(cons_Data[cons_CraftsetConstructSet[cons_Constructing[playerid]]][cons_tweak])
			TweakItem(playerid, itemid);

		dbg("craft-construct", 2, "[OnHoldActionFinish] Calling OnPlayerConstructed %d %d %d", playerid, cons_CraftsetConstructSet[cons_Constructing[playerid]], _:itemid);
		CallLocalFunction("OnPlayerConstructed", "ddd", playerid, cons_CraftsetConstructSet[cons_Constructing[playerid]], _:itemid);

		ClearAnimations(playerid);
		HideActionText(playerid);

		_ResetSelectedItems(playerid);
		cons_Constructing[playerid] = INVALID_CRAFTSET;
	}
	else if(cons_DeconstructingItem[playerid] != INVALID_ITEM_ID)
	{
		dbg("craft-construct", 2, "[OnHoldActionFinish] Calling OnPlayerDeconstructed %d %d %d", playerid, _:cons_DeconstructingItem[playerid], _:cons_Deconstructing[playerid]);

		if(!CallLocalFunction("OnPlayerDeconstructed", "ddd", playerid, _:cons_DeconstructingItem[playerid], _:cons_Deconstructing[playerid]))
		{
			dbg("craft-construct", 2, "[OnHoldActionFinish] OnPlayerDeconstructed returned zero, destroying item and returning ingredients");

			new
				Float:x,
				Float:y,
				Float:z,
				recipedata[CRAFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data],
				recipeitems;

			GetItemPos(cons_DeconstructingItem[playerid], x, y, z);

			DestroyItem(cons_DeconstructingItem[playerid]);

			GetCraftSetIngredients(cons_Deconstructing[playerid], recipedata, recipeitems);

			for(new i; i < recipeitems; i++)
			{
				dbg("craft-construct", 3, "[OnHoldActionFinish] recipe items %d/%d: type: %d keep: %d", i, recipeitems, _:recipedata[i][craft_itemType], recipedata[i][craft_keepItem]);
				// items that were kept at the time of crafting are ignored
				// since they never originally left the player's posession.
				if(recipedata[i][craft_keepItem])
					continue;

				new world, interior;
				GetItemWorld(cons_DeconstructingItem[playerid], world);
				GetItemInterior(cons_DeconstructingItem[playerid], interior);
				CreateItem(recipedata[i][craft_itemType], x + frandom(0.6), y + frandom(0.6), z, 0.0, 0.0, frandom(360.0), world, interior);
			}

			StopRemovingConstructedItem(playerid);
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(RELEASED(16))
	{
		if(cons_Constructing[playerid] != INVALID_CRAFTSET)
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);
			HideActionText(playerid);
			_ResetSelectedItems(playerid);

			cons_Constructing[playerid] = INVALID_CRAFTSET;
		}
		else if(cons_Deconstructing[playerid] != INVALID_CRAFTSET)
		{
			StopRemovingConstructedItem(playerid);
		}
	}
}

hook OnPlayerCraft(playerid, CraftSet:craftset)
{
	if(cons_CraftsetConstructSet[craftset] != -1)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_ResetSelectedItems(playerid)
{
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS; i++)
	{
		cons_SelectedItems[playerid][i][craft_selectedItemType] = INVALID_ITEM_TYPE;
		cons_SelectedItems[playerid][i][craft_selectedItemID] = INVALID_ITEM_ID;
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
stock CraftSet:GetConstructionSetCraftSet(consset)
{
	if(!(0 <= consset < MAX_CONSTRUCT_SET))
		return INVALID_CRAFTSET;

	return cons_Data[consset][cons_craftset];
}

// cons_CraftsetConstructSet[craftset]
stock GetCraftSetConstructSet(CraftSet:craftset)
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
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS && cons_SelectedItems[playerid][i][craft_selectedItemID] != INVALID_ITEM_ID; i++)
		output[i] = cons_SelectedItems[playerid][i];

	count = cons_SelectedItemCount[playerid];

	return 1;
}
