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
		gut_TargetItem[MAX_PLAYERS],
Timer:	gut_PickUpTimer[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	gut_TargetItem[playerid] = INVALID_ITEM_ID;
}

hook OnItemCreateInWorld(itemid)
{
	if(GetItemType(itemid) == item_Torso)
	{
		if(GetItemExtraData(itemid) != -1)
			SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up/harvest with knife~n~Press "KEYTEXT_INTERACT" to investigate");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_Knife && GetItemType(withitemid) == item_Torso)
	{
		if(GetItemArrayDataAtCell(withitemid, 0))
		{
			if(gettime() - GetItemArrayDataAtCell(withitemid, 1) < 86400)
			{
				StartHoldAction(playerid, 3000);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
				gut_TargetItem[playerid] = withitemid;
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "BODYDECOMPD"), 3000);
			}
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "BODYHARVEST"), 3000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Torso)
	{
		if(GetItemExtraData(itemid) != -1)
		{
			gut_PickUpTimer[playerid] = defer PickUpTorso(playerid);
			gut_TargetItem[playerid] = itemid;
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys == 16)
	{
		if(IsValidItem(gut_TargetItem[playerid]))
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);

			if(GetPlayerWeapon(playerid) != 4)
			{
				ShowTorsoDetails(playerid, gut_TargetItem[playerid]);

				stop gut_PickUpTimer[playerid];
				gut_TargetItem[playerid] = INVALID_ITEM_ID;
			}
		}
	}
}

timer PickUpTorso[250](playerid)
{
	if(GetPlayerWeapon(playerid) == 0)
	{
		PlayerPickUpItem(playerid, gut_TargetItem[playerid]);
		gut_TargetItem[playerid] = INVALID_ITEM_ID;
	}
}


hook OnHoldActionFinish(playerid)
{
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

		itemid = CreateItem(item_Meat, x, y, z + 0.3, .rz = r, .zoffset = FLOOR_OFFSET);
		SetItemArrayDataAtCell(itemid, 0, food_cooked, 1);
		SetItemArrayDataAtCell(itemid, 0, food_amount, 5 + random(4));

		SetItemArrayDataAtCell(gut_TargetItem[playerid], 0, 0);
		ClearAnimations(playerid);

		gut_TargetItem[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
