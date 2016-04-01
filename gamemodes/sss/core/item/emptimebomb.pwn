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
	emptbm_ArmingItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	emptbm_ArmingItem[playerid] = INVALID_ITEM_ID;
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTimebomb)
	{
		PlayerDropItem(playerid);
		emptbm_ArmingItem[playerid] = itemid;

		StartHoldAction(playerid, 1000);
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, "Arming...");
		return 1;
	}

    #if defined emptbm_OnPlayerUseItem
		return emptbm_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem emptbm_OnPlayerUseItem
#if defined emptbm_OnPlayerUseItem
	forward emptbm_OnPlayerUseItem(playerid, itemid);
#endif

hook OnHoldActionFinish(playerid)
{
	if(IsValidItem(emptbm_ArmingItem[playerid]))
	{
		defer EmpTimeBombExplode(emptbm_ArmingItem[playerid]);
		ClearAnimations(playerid);
		ShowActionText(playerid, "Armed for 5 seconds", 3000);

		emptbm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(RELEASED(16) && IsValidItem(emptbm_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		emptbm_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

timer EmpTimeBombExplode[5000](itemid)
{
	SetItemToExplode(itemid, 0, 12.0, EXPLOSION_PRESET_EMP, 0);
}
