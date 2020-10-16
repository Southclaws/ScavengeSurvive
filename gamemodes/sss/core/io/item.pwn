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


#include <YSI_Coding\y_hooks>


#define DIRECTORY_WORLDITEM			DIRECTORY_MAIN"worlditem/"


enum e_SAVED_ITEM_DATA
{
ItemType:	SAVED_ITEM_TYPE,
			SAVED_ITEM_ACTIVE,
Float:		SAVED_ITEM_POS_X,
Float:		SAVED_ITEM_POS_Y,
Float:		SAVED_ITEM_POS_Z,
Float:		SAVED_ITEM_ROT_X,
Float:		SAVED_ITEM_ROT_Y,
Float:		SAVED_ITEM_ROT_Z,
			SAVED_ITEM_WORLD,
			SAVED_ITEM_INTERIOR,
			SAVED_ITEM_HITPOINTS
}

static big_data[8192];


SaveWorldItem(itemid, const subdir[], bool:active, savearray = true, const data[] = "", data_size = 0)
{
	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(gServerInitialising)
	{
		return 1;
	}

	if(!IsValidItem(itemid))
	{
		err("Can't save item %d (%s) Not valid item.", itemid, geid);
		return 2;
	}

	if(!IsItemInWorld(itemid))
	{
		return 3;
	}

	if(isnull(geid))
	{
		return 4;
	}

	new
		filename[256],
		info[e_SAVED_ITEM_DATA];

	format(filename, sizeof(filename), "%s%s", subdir, geid);

	info[SAVED_ITEM_TYPE] = GetItemType(itemid);
	info[SAVED_ITEM_ACTIVE] = active;
	GetItemPos(itemid, info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z]);
	GetItemRot(itemid, info[SAVED_ITEM_ROT_X], info[SAVED_ITEM_ROT_Y], info[SAVED_ITEM_ROT_Z]);
	info[SAVED_ITEM_WORLD] = GetItemWorld(itemid);
	info[SAVED_ITEM_INTERIOR] = GetItemInterior(itemid);
	info[SAVED_ITEM_HITPOINTS] = GetItemHitPoints(itemid);

	log("[SAVE] Item %d (%s) info: %d %d %d (%f, %f, %f, %f, %f, %f)",
		itemid, geid,
		_:info[SAVED_ITEM_TYPE], info[SAVED_ITEM_ACTIVE], info[SAVED_ITEM_HITPOINTS],
		info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z],
		info[SAVED_ITEM_ROT_X], info[SAVED_ITEM_ROT_Y], info[SAVED_ITEM_ROT_Z]);

	modio_push(filename, _T<I,N,F,O>, _:e_SAVED_ITEM_DATA, _:info);

	if(savearray)
	{
		new arraydatalen = GetItemArrayDataSize(itemid);

		if(arraydatalen > 0)
		{
			new arraydata[ITM_ARR_MAX_ARRAY_DATA];

			GetItemArrayData(itemid, arraydata);

			modio_push(filename, _T<A,R,R,Y>, arraydatalen, arraydata);
		}
	}

	if(data_size > 0)
	{
		modio_push(filename, _T<D,A,T,A>, data_size, data);
	}

	modio_finalise_write(modio_getsession_write(filename));

	return 0;
}

RemoveSavedItem(itemid, const subdir[])
{
	new
		geid[GEID_LEN],
		filename[256];

	GetItemGEID(itemid, geid);

	format(filename, sizeof(filename), "%s%s", subdir, geid);

	fremove(filename);

	log("[DELT] Item %d (%s) file %s", itemid, geid, filename);
}

LoadItems(const subdir[], const callback[])
{
	new
		path_with_root[64],
		Directory:direc,
		entry[256],
		geid[GEID_LEN],
		ENTRY_TYPE:type,
		ret,
		count,
		trimlength = strlen("./scriptfiles/");

	format(path_with_root, sizeof(path_with_root), DIRECTORY_SCRIPTFILES"%s", subdir);
	direc = OpenDir(path_with_root);

	while(DirNext(direc, type, entry))
	{
		if(type == E_REGULAR)
		{
			PathBase(entry, geid);
			ret = LoadItem(entry[trimlength], geid, callback);

			if(ret != INVALID_ITEM_ID)
				count++;
		}
	}

	CloseDir(direc);

	log("Loaded %d items from %s", count, subdir);
}

LoadItem(const filename[], const geid[], const callback[])
{
	new
		length,
		info[e_SAVED_ITEM_DATA];

	length = modio_read(filename, _T<I,N,F,O>, _:e_SAVED_ITEM_DATA, _:info, false, false);

	if(length < 0)
	{
		err("modio error %d in '%s'.", length, filename);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	if(length == 0)
	{
		err("Item %s data length is 0", filename);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	if(info[SAVED_ITEM_POS_X] == 0.0 && info[SAVED_ITEM_POS_Y] == 0.0 && info[SAVED_ITEM_POS_Z] == 0.0)
	{
		err("Item %s position is %f %f %f", filename, info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z]);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	new itemid = AllocNextItemID(info[SAVED_ITEM_TYPE], geid);
	SetItemNoResetArrayData(itemid, true);
	CreateItem_ExplicitID(
		itemid,
		info[SAVED_ITEM_POS_X],
		info[SAVED_ITEM_POS_Y],
		info[SAVED_ITEM_POS_Z],
		.rx = info[SAVED_ITEM_ROT_X],
		.ry = info[SAVED_ITEM_ROT_Y],
		.rz = info[SAVED_ITEM_ROT_Z],
		.world = info[SAVED_ITEM_WORLD],
		.interior = info[SAVED_ITEM_INTERIOR],
		.hitpoints = info[SAVED_ITEM_HITPOINTS],
		.applyrotoffsets = 0);

	log("[LOAD] Item %d (%s) info: %d %d %d (%f, %f, %f, %f, %f, %f)",
		itemid, geid,
		_:info[SAVED_ITEM_TYPE], info[SAVED_ITEM_ACTIVE], info[SAVED_ITEM_HITPOINTS],
		info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z],
		info[SAVED_ITEM_ROT_X], info[SAVED_ITEM_ROT_Y], info[SAVED_ITEM_ROT_Z]);
/*
	Todo: Figure out a way to block setting arraydata for certain items without
	a dumb function or lookup table of any sort
*/
	if(!IsItemTypeExtraDataDependent(GetItemType(itemid)))
	{
		length = modio_read(filename, _T<A,R,R,Y>, sizeof(big_data), big_data, false, false);

		if(length > 0)
		{
			SetItemArrayData(itemid, big_data, length);
		}
	}

	length = modio_read(filename, _T<D,A,T,A>, sizeof(big_data), big_data, true);

	if(length <= 0)
	{
		big_data[0] = 65;
		big_data[1] = 0;
		length = 0;
	}

	CallLocalFunction(callback, "ddsad", itemid, info[SAVED_ITEM_ACTIVE], geid, big_data, length);

	return itemid;
}

hook OnItemRemoveFromWorld(itemid)
{
	
	RemoveSavedItem(itemid, DIRECTORY_WORLDITEM);
}
