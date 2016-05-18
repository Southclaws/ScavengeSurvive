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


enum
{
	EXPLOSION_PRESET_NORMAL,
	EXPLOSION_PRESET_STRUCTURAL,
	EXPLOSION_PRESET_EMP
}


stock SetItemToExplode(itemid, type, Float:size, preset, hitpoints)
{
	if(!IsValidItem(itemid))
		return 0;

	if(IsItemInWorld(itemid))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetItemPos(itemid, x, y, z);
		CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);
		DestroyItem(itemid);

		return 1;
	}

	new containerid = GetItemContainer(itemid);

	if(IsValidContainer(containerid))
	{
		new buttonid = GetContainerButton(containerid);

		if(IsValidButton(buttonid))
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetButtonPos(buttonid, x, y, z);
			CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);
			DestroyItem(itemid);

			return 1;
		}

		new vehicleid = GetContainerTrunkVehicleID(containerid);

		if(IsValidVehicle(vehicleid))
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetVehiclePos(vehicleid, x, y, z);
			CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);
			DestroyItem(itemid);
			SetVehicleHealth(vehicleid, 0.0);

			return 1;
		}

		new safeboxitemid = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitemid))
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(safeboxitemid, x, y, z);
			CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);
			DestroyItem(itemid);

			if(type != EXPLOSION_PRESET_EMP)
				DestroyItem(safeboxitemid);

			return 1;
		}

		new playerid = GetContainerPlayerBag(containerid);

		if(IsPlayerConnected(playerid))
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(playerid, x, y, z);
			CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);
			DestroyItem(itemid);

			if(type != EXPLOSION_PRESET_EMP)
				DestroyPlayerBag(playerid);

			return 1;
		}

		new bagitemid = GetContainerBagItem(containerid);

		if(IsValidItem(bagitemid))
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(bagitemid, x, y, z);
			CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);
			DestroyItem(itemid);

			if(type != EXPLOSION_PRESET_EMP)
				DestroyItem(bagitemid);

			return 1;
		}
	}

	new playerid = GetItemPlayerInventory(itemid);

	if(IsPlayerConnected(playerid))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);
		CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);
		DestroyItem(itemid);

		return 1;
	}

	return 0;
}

stock CreateExplosionOfPreset(Float:x, Float:y, Float:z, type, Float:size, preset, hitpoints)
{
	switch(preset)
	{
		case EXPLOSION_PRESET_NORMAL:
			CreateExplosion(x, y, z, type, size);

		case EXPLOSION_PRESET_STRUCTURAL:
			CreateStructuralExplosion(x, y, z, type, size, hitpoints);

		case EXPLOSION_PRESET_EMP:
			CreateEmpExplosion(x, y, z, size);
	}
}

stock CreateStructuralExplosion(Float:x, Float:y, Float:z, type, Float:size, hitpoints = 1)
{
	CreateExplosion(x, y, z, type, size);

	new
		Float:defposx,
		Float:defposy,
		Float:defposz,
		Float:smallestdistance = 9999999.9,
		Float:tempdistance,
		closestid;

	foreach(new i : def_Index)
	{
		GetDefencePos(i, defposx, defposy, defposz);

		tempdistance = Distance(x, y, z, defposx, defposy, defposz);

		if(tempdistance < smallestdistance)
		{
			smallestdistance = tempdistance;
			closestid = i;
		}
	}

	if(smallestdistance < size)
	{
		new newhitpoints = GetDefenceHitPoints(closestid) - hitpoints;

		if(newhitpoints <= 0)
		{
			new
				defencetype = GetDefenceType(closestid),
				ItemType:itemtype = GetDefenceTypeItemType(defencetype),
				Float:vrotx,
				Float:vroty,
				Float:vrotz,
				Float:rotz;

			GetDefenceTypeVerticalRot(defencetype, vrotx, vroty, vrotz);
			rotz = GetDefenceRot(closestid);

			logf("[DESTRUCTION] Defence %d From %.1f, %.1f, %.1f (GEID: %d) type %d (%d, %f, %f, %f, %f, %f, %f)",
				closestid, x, y, z,
				GetDefenceGEID(closestid),
				_:itemtype,
				GetItemTypeModel(itemtype),
				x, y, z + GetDefenceTypeOffsetZ(defencetype),
				vrotx, vroty, vrotz + rotz);

			DestroyDefence(closestid);
		}
		else
		{
			SetDefenceHitPoints(closestid, newhitpoints);
		}
	}
}
