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
		gut_TargetItem[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Torso"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Torso"), MAX_PLAYER_NAME + 128 + 2);
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/item/torso.pwn");

	gut_TargetItem[playerid] = INVALID_ITEM_ID;
}

hook OnItemCreateInWorld(itemid)
{
	dbg("global", CORE, "[OnItemCreateInWorld] in /gamemodes/sss/core/item/torso.pwn");

	if(GetItemType(itemid) == item_Torso)
	{
		if(GetItemExtraData(itemid) != -1)
			SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up/harvest with knife~n~Press "KEYTEXT_INTERACT" to investigate");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	dbg("global", CORE, "[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/torso.pwn");

	if(GetItemType(itemid) == item_Knife && GetItemType(withitemid) == item_Torso)
	{
		if(GetItemArrayDataAtCell(withitemid, 0))
		{
			if(gettime() - GetItemArrayDataAtCell(withitemid, 1) < 86400)
			{
				StartHoldAction(playerid, 3000);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
				gut_TargetItem[playerid] = withitemid;
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "BODYDECOMPD", true), 3000);
			}
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "BODYHARVEST", true), 3000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/item/torso.pwn");

	if(GetItemType(itemid) == item_Torso)
	{
		gut_TargetItem[playerid] = itemid;
		ShowTorsoDetails(playerid, itemid);
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	if(gut_TargetItem[playerid] != INVALID_ITEM_ID)
	{
		gut_TargetItem[playerid] = INVALID_ITEM_ID;
		CancelPlayerMovement(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/torso.pwn");

	if(oldkeys == 16)
	{
		if(IsValidItem(gut_TargetItem[playerid]))
		{
			StopHoldAction(playerid);
			CancelPlayerMovement(playerid);
			gut_TargetItem[playerid] = INVALID_ITEM_ID;
		}
	}
}

hook OnHoldActionFinish(playerid)
{
	dbg("global", CORE, "[OnHoldActionFinish] in /gamemodes/sss/core/item/torso.pwn");

	if(IsValidItem(gut_TargetItem[playerid]))
	{
		if(GetItemExtraData(gut_TargetItem[playerid]) == -1)
			return 1;

		new
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			itemid;

		GetItemPos(gut_TargetItem[playerid], x, y, z);
		GetItemRot(gut_TargetItem[playerid], r, r, r);

		itemid = CreateItem(item_Meat, x, y, z + 0.3, .rz = r);
		SetItemArrayDataAtCell(itemid, 0, food_cooked, 1);
		SetItemArrayDataAtCell(itemid, 5 + random(3), food_amount, 1);

		SetItemArrayDataAtCell(gut_TargetItem[playerid], 0, 0);
		CancelPlayerMovement(playerid);

		gut_TargetItem[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
