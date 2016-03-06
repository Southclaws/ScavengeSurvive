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
	if(GetItemType(itemid) == item_Sign)
	{
		new
			tmpsign,
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		DestroyItem(itemid);
		tmpsign = CreateSign("I am a sign.", x + floatsin(-a, degrees), y + floatcos(-a, degrees), z - 1.0, a - 90.0);
		EditSign(playerid, tmpsign);

		return 1;
	}
	#if defined sgn_OnPlayerUseItem
		return sgn_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem sgn_OnPlayerUseItem
#if defined sgn_OnPlayerUseItem
	forward sgn_OnPlayerUseItem(playerid, itemid);
#endif
