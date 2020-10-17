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


#include <YSI_Coding\y_hooks>


static CraftSet;
static ConsSet;
static bool:Constructing[MAX_PLAYERS];


hook OnGameModeInit()
{
	CraftSet = DefineItemCraftSet(item_LargeFrame, item_LargeFrame, false, item_RefinedMetal, false, item_RefinedMetal, false);
	ConsSet = SetCraftSetConstructible(30000, item_Wrench, CraftSet, item_Crowbar, 22000);
}

hook OnPlayerConnect(playerid)
{
	Constructing[playerid] = false;
	return 1;
}

hook OnPlayerConstruct(playerid, consset)
{
	if(!consset != ConsSet)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new craftset = GetConstructionSetCraftSet(consset);
	new uniqueid[ITM_MAX_NAME];
	GetItemTypeName(GetCraftSetResult(craftset), uniqueid);
	StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 10000, uniqueid));
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "CONSTRUCTIN", true));

	Constructing[playerid] = true;

	return Y_HOOKS_BREAK_RETURN_1;
}

hook OnHoldActionFinish(playerid)
{
	if(!Constructing[playerid])
		return Y_HOOKS_CONTINUE_RETURN_0;

	new list[BTN_MAX_INRANGE] = {INVALID_BUTTON_ID, ...};
	size = GetPlayerNearbyItems(playerid, list);
	if(size == 0)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new modification_item = INVALID_ITEM_ID;
	for(new i; i < size; i++)
	{
		if(GetItemType(i) == item_CorPanel)
		{
			modification_item = list[i];
			break;
		}
	}

	// find modification item, find target item
	// remove mod, adjust target

	return Y_HOOKS_CONTINUE_RETURN_0;
}