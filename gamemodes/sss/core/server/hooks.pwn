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


Hook_HackDetect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	HackDetect_SetPlayerPos(playerid, x, y, z);
	return SetPlayerPos(playerid, x, y, z);
}
#define SetPlayerPos Hook_HackDetect_SetPlayerPos

Hook_SetPlayerSkin(playerid, skinid, retry_on_fail = true)
{
	new specialaction = GetPlayerSpecialAction(playerid);

	if(specialaction == SPECIAL_ACTION_ENTER_VEHICLE || specialaction == SPECIAL_ACTION_EXIT_VEHICLE)
	{
		if(retry_on_fail)
			return _: defer Retry_SetPlayerSkin(playerid, skinid);
	}

	return SetPlayerSkin(playerid, skinid);
}
#define SetPlayerSkin Hook_SetPlayerSkin

timer Retry_SetPlayerSkin[100](playerid, skinid)
{
	Hook_SetPlayerSkin(playerid, skinid);
}
