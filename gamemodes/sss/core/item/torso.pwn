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


#define MAX_DEATH_REASON (128)


enum
{
	torso_canHarvest,
	torso_spawnTime,
	torso_nameLen,
	torso_name[MAX_PLAYER_NAME],
	torso_reasonLen,
	torso_reason[MAX_DEATH_REASON],
	torso_end
}

static Item:gut_TargetItem[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Torso"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Torso"), MAX_PLAYER_NAME + 128 + 2);
}

hook OnPlayerConnect(playerid)
{
	gut_TargetItem[playerid] = INVALID_ITEM_ID;
}

stock Item:CreateGravestone(playerid, const reason[], Float:x, Float:y, Float:z, Float:rz)
{
	new
		name[MAX_PLAYER_NAME],
		Item:itemid;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	itemid = CreateItem(item_Torso, x, y, z, 0.0, 0.0, rz);

	SetItemArrayDataLength(itemid, 0);

	AppendItemArrayCell(itemid, 1); // canHarvest
	AppendItemArrayCell(itemid, gettime()); // spawnTime

	AppendItemArrayCell(itemid, strlen(name)); // nameLen
	AppendItemDataArray(itemid, name, strlen(name)); // name

	AppendItemArrayCell(itemid, strlen(reason)); // reasonLen
	AppendItemDataArray(itemid, reason, strlen(reason)); // reason

	return itemid;
}

ShowTorsoDetails(playerid, Item:itemid)
{
	new size;
	GetItemArrayDataSize(itemid, size);
	if(size < 3)
		return 0;

	new
		arraydata[torso_end],
		name[MAX_PLAYER_NAME],
		reason[MAX_DEATH_REASON];

	GetItemArrayData(itemid, arraydata);

	memcpy(name, arraydata[3], 0, arraydata[2] * 4);
	memcpy(reason, arraydata[3 + arraydata[2] + 1], 0, arraydata[3 + arraydata[2]] * 4);

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, name, reason, "Close", "");

	return 1;
}

hook OnItemCreateInWorld(Item:itemid)
{
	if(GetItemType(itemid) == item_Torso)
	{
		new value;
		GetItemExtraData(itemid, value);
		if(value != -1)
		{
			new Button:buttonid;
			GetItemButtonID(itemid, buttonid);
			SetButtonText(buttonid, "Hold "KEYTEXT_INTERACT" to pick up/harvest with knife~n~Press "KEYTEXT_INTERACT" to investigate");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(itemid) == item_Knife && GetItemType(withitemid) == item_Torso)
	{
		new value;
		GetItemArrayDataAtCell(withitemid, value, 0);
		if(value)
		{
			new decompose;
			GetItemArrayDataAtCell(withitemid, decompose, 1);
			if(gettime() - decompose < 86400)
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

hook OnPlayerUseItem(playerid, Item:itemid)
{
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
	if(IsValidItem(gut_TargetItem[playerid]))
	{
		new value;
		GetItemExtraData(gut_TargetItem[playerid], value);
		if(value == -1)
			return 1;

		new
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			Item:itemid;

		GetItemPos(gut_TargetItem[playerid], x, y, z);
		GetItemRot(gut_TargetItem[playerid], r, r, r);

		itemid = CreateItem(item_Meat, x, y, z + 0.3, .rz = r);
		SetItemArrayDataAtCell(itemid, 1, food_cooked);
		SetItemArrayDataAtCell(itemid, 5 + random(4), food_amount);

		SetItemArrayDataAtCell(gut_TargetItem[playerid], 0, 0);
		CancelPlayerMovement(playerid);

		gut_TargetItem[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
