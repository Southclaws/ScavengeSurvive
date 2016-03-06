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


hook OnPlayerGiveDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(bodypart == BODY_PART_HEAD)
	{
		if(GetPlayerHat(playerid) != -1)
			PopHat(playerid);

		if(GetPlayerMask(playerid) != -1)
			PopMask(playerid);
	}

	return 1;
}

PopHat(playerid)
{
	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemtype = GetItemTypeFromHat(GetPlayerHat(playerid));
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropHat(objectid, itemtype, _:x, _:y, _:z, _:r);
}

PopMask(playerid)
{
	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemtype = GetItemTypeFromMask(GetPlayerMask(playerid));
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropMask(objectid, itemtype, _:x, _:y, _:z, _:r);
}


timer pop_DropHat[500](o, ItemType:it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItem(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r, .zoffset = FLOOR_OFFSET);
}

timer pop_DropMask[500](o, ItemType:it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItem(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r, .zoffset = FLOOR_OFFSET);
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
