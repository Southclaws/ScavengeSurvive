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
	iedt_ArmingItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/item/iedtimebomb.pwn");

	iedt_ArmingItem[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/iedtimebomb.pwn");

	if(GetItemType(itemid) == item_IedTimebomb)
	{
		PlayerDropItem(playerid);
		iedt_ArmingItem[playerid] = itemid;

		StartHoldAction(playerid, 1000);
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, ls(playerid, "ARMINGBOMB"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/item/iedtimebomb.pwn");

	if(IsValidItem(iedt_ArmingItem[playerid]))
	{
		defer IedTimeBombExplode(iedt_ArmingItem[playerid]);
		logf("[EXPLOSIVE] IED TIMEBOMB placed by %p", playerid);
		ClearAnimations(playerid);
		ShowActionText(playerid, ls(playerid, "ARMEDBOMB5S"), 3000);

		iedt_ArmingItem[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/iedtimebomb.pwn");

	if(RELEASED(16) && IsValidItem(iedt_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		iedt_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

timer IedTimeBombExplode[5000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);

	logf("[EXPLOSIVE] IED TIMEBOMB detonated at %f, %f, %f", x, y, z);

	SetItemToExplode(itemid, 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);
}
