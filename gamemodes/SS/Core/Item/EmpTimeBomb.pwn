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


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTimebomb)
	{
		PlayerDropItem(playerid);
		defer EmpTimeBombExplode(itemid);
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


timer EmpTimeBombExplode[5000](itemid)
{
	SetItemToExplode(itemid, 0, 12.0, EXPLOSION_PRESET_EMP, 0);
}
