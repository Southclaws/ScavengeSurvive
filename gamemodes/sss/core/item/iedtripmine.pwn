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
	iedm_ContainerOption[MAX_PLAYERS],
	iedm_ArmingItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnGameModeInit()
{
	SetItemTypeMaxArrayData(item_IedTripMine, 1);
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/item/iedtripmine.pwn");

	iedm_ArmingItem[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/iedtripmine.pwn");


	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/item/iedtripmine.pwn");


	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/iedtripmine.pwn");

	if(RELEASED(16) && IsValidItem(iedm_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		iedm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

