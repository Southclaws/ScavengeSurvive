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


static scr_TargetItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/item/screwdriver.pwn");

	scr_TargetItem[playerid] = INVALID_ITEM_ID;
}


hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	dbg("global", CORE, "[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/screwdriver.pwn");

	if(GetItemType(itemid) == item_Screwdriver)
	{
		new
			ItemType:itemtype,
			explosiontype;

		itemtype = GetItemType(withitemid);
		explosiontype = GetItemTypeExplosiveType(itemtype);

		if(explosiontype != INVALID_EXPLOSIVE_TYPE)
		{
			new EXP_TRIGGER:trigger = GetExplosiveTypeTrigger(explosiontype);

			if(trigger == RADIO || trigger == MOTION)
			{
				if(GetItemExtraData(withitemid) == 1)
				{
					StartHoldAction(playerid, 2000);
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					scr_TargetItem[playerid] = withitemid;
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/screwdriver.pwn");

	if(oldkeys & 16)
	{
		if(IsValidItem(scr_TargetItem[playerid]))
			StopHoldAction(playerid);
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	dbg("global", CORE, "[OnHoldActionFinish] in /gamemodes/sss/core/item/screwdriver.pwn");

	if(IsValidItem(scr_TargetItem[playerid]))
	{
		ClearAnimations(playerid);
		SetItemExtraData(scr_TargetItem[playerid], 0);
		ShowActionText(playerid, ls(playerid, "DISARMEDBOM", true), 5000);
		scr_TargetItem[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
