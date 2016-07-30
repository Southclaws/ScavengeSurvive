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


#define MAX_HACKTRAP	(64)


new
			hak_ItemID[MAX_HACKTRAP],
   Iterator:hak_Index<MAX_HACKTRAP>;


stock CreateHackerTrap(Float:x, Float:y, Float:z, lootindex)
{
	new id = Iter_Free(hak_Index);

	if(id == ITER_NONE)
		return INVALID_ITEM_ID;

	hak_ItemID[id] = CreateLootItem(lootindex, x, y, z);

	Iter_Add(hak_Index, id);

	return id;
}


hook OnPlayerPickUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickUpItem] in /gamemodes/sss/core/admin/hack-trap.pwn");

	foreach(new i : hak_Index)
	{
		if(itemid == hak_ItemID[i])
		{
			TheTrapHasSprung(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


TheTrapHasSprung(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		Float:x,
		Float:y,
		Float:z;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetPlayerPos(playerid, x, y, z);

	ReportPlayer(name, "Picked up a hack-trap", -1, REPORT_TYPE_HACKTRAP, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
	BanPlayer(playerid, "Sprung the hacker trap by picking up an unreachable item!", -1, 0);
}
