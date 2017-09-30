/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


hook OnPlayerGiveDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	dbg("global", CORE, "[OnPlayerGiveDamage] in /gamemodes/sss/core/char/headgear-pop.pwn");

	if(bodypart == BODY_PART_HEAD)
	{
		if(IsValidItem(GetPlayerHatItem(playerid)))
			PopHat(playerid);

		if(IsValidItem(GetPlayerMaskItem(playerid)))
			PopMask(playerid);
	}

	return 1;
}

PopHat(playerid)
{
	new
		itemid,
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemid = RemovePlayerHatItem(playerid);
	itemtype = GetItemType(itemid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropHat(objectid, itemid, x, y, z, r);
}

PopMask(playerid)
{
	new
		itemid,
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemid = RemovePlayerMaskItem(playerid);
	itemtype = GetItemType(itemid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropMask(objectid, itemid, x, y, z, r);
}


timer pop_DropHat[500](o, it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItemInWorld(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r);
}

timer pop_DropMask[500](o, it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItemInWorld(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r);
}

CMD:pophat(playerid, params[])
{
	PopHat(playerid);
	return 1;
}

CMD:popmask(playerid, params[])
{
	PopMask(playerid);
	return 1;
}
