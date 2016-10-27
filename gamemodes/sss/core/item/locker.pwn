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

hook OnPlayerOpenContainer(playerid, containerid)
{
	new itemid = GetContainerSafeboxItem(containerid);

	if(GetItemType(itemid) == item_Locker)
	{
		Streamer_SetIntData(STREAMER_TYPE_OBJECT, GetItemObjectID(itemid), E_STREAMER_MODEL_ID, 11730);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	new itemid = GetContainerSafeboxItem(containerid);

	if(GetItemType(itemid) == item_Locker)
	{
		Streamer_SetIntData(STREAMER_TYPE_OBJECT, GetItemObjectID(itemid), E_STREAMER_MODEL_ID, 11729);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Locker)
	{
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
