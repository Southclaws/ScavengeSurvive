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


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Campfire"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Campfire"), 1);
}

hook OnItemCreateInWorld(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreateInWorld] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);
		SetItemExtraData(itemid, CreateCampfire(x, y, z, rz, GetItemWorld(itemid), GetItemInterior(itemid)));
	}
}

hook OnPlayerPickedUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickedUpItem] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
	{
		DestroyCampfire(GetItemExtraData(itemid));
		defer AttachWoodLogs(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGivenItem(playerid, targetid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerGivenItem] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
	{
		defer AttachWoodLogs(targetid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer AttachWoodLogs[0](playerid)
{
	SetPlayerAttachedObject(playerid, ITM_ATTACH_INDEX, 1463, 6, 0.023999, 0.027236, -0.204656, 251.243942, 356.352508, 73.549652, 0.384758, 0.200000, 0.200000);		
}
