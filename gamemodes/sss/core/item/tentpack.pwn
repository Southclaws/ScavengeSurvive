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
	tnt_CurrentTentItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
}


hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_Hammer && GetItemType(withitemid) == item_TentPack)
	{
		StartBuildingTent(playerid, withitemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopBuildingTent(playerid);
	}
}

StartBuildingTent(playerid, itemid)
{
	tnt_CurrentTentItem[playerid] = itemid;
	StartHoldAction(playerid, 10000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, "Building Tent...");
}

StopBuildingTent(playerid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
		return;

	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		return;
	}
	return;
}

hook OnHoldActionFinish(playerid)
{
	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:rz;

			GetItemPos(tnt_CurrentTentItem[playerid], x, y, z);
			GetItemRot(tnt_CurrentTentItem[playerid], rz, rz, rz);

			CreateTent(x, y, z + 0.4, rz, GetItemWorld(tnt_CurrentTentItem[playerid]), GetItemInterior(tnt_CurrentTentItem[playerid]));
			DestroyItem(tnt_CurrentTentItem[playerid]);
			ClearAnimations(playerid);

			tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
