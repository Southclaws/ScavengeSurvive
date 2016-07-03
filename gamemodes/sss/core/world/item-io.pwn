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
			SAVED_ITEM_INTERIOR
}

static big_data[8192];


static HANDLER = -1;


hook OnScriptInit()
{
	HANDLER = debug_register_handler("item-io", 4);
}

SaveWorldItem(itemid, subdir[], bool:active, savearray = true, data[] = "", data_size = 0)
{
	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(!IsValidItem(itemid))
	{
		printf("[SaveItem] ERROR: Can't save item %d (%s) Not valid item.", itemid, geid);
		return 1;
	}

	if(!IsItemInWorld(itemid))
	{
		d:1:HANDLER("[SaveItem] ERROR: Can't save item %d (%s) Item not in world.", itemid, geid);
		return 3;
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

	modio_push(filename, _T<I,N,F,O>, _:e_SAVED_ITEM_DATA, _:info);

	logf("[SAVE] Item %d (%s) info: %d %d %f %f %f",
		itemid, geid,
		_:info[SAVED_ITEM_TYPE], info[SAVED_ITEM_ACTIVE],
		info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z]);

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

	return 0;
}

RemoveSavedItem(itemid, subdir[])
{
	new
		geid[GEID_LEN],
		filename[256];

	GetItemGEID(itemid, geid);

	format(filename, sizeof(filename), "%s%s", subdir, geid);

	fremove(filename);
}

LoadItems(subdir[], callback[])
{
	new
		path[64],
		dir:direc,
		item[46],
		type,
		ret,
		count;

	format(path, sizeof(path), DIRECTORY_SCRIPTFILES"%s", subdir);

	direc = dir_open(path);

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			if(strlen(item) != 14)
			{
				printf("[LoadItems] WARN: Rogue file detected ('%s') in directory %s", item, subdir);
				continue;
			}

			ret = LoadItem(subdir, item, callback);

			if(ret != INVALID_ITEM_ID)
				count++;
		}
	}

	dir_close(direc);

	logf("Loaded %d items from %s", count, subdir);
}

LoadItem(subdir[], geid[], callback[])
{
	new
		filename[128],
		length,
		info[e_SAVED_ITEM_DATA];

	format(filename, sizeof(filename), "%s%s", subdir, geid);

	length = modio_read(filename, _T<I,N,F,O>, _:e_SAVED_ITEM_DATA, _:info, false, false);

	if(length < 0)
	{
		printf("[LoadItem] ERROR: modio error %d in '%s'.", length, filename);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	if(length == 0)
	{
		printf("[LoadItem] ERROR: Item %s data length is 0", filename);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	if(info[SAVED_ITEM_POS_X] == 0.0 && info[SAVED_ITEM_POS_Y] == 0.0 && info[SAVED_ITEM_POS_Z] == 0.0)
	{
		printf("[LoadItem] ERROR: Item %s position is %f %f %f", filename, info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z]);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	new itemid = CreateItem(
		info[SAVED_ITEM_TYPE],
		info[SAVED_ITEM_POS_X],
		info[SAVED_ITEM_POS_Y],
		info[SAVED_ITEM_POS_Z],
		.rx = info[SAVED_ITEM_ROT_X],
		.ry = info[SAVED_ITEM_ROT_Y],
		.rz = info[SAVED_ITEM_ROT_Z],
		.world = info[SAVED_ITEM_WORLD],
		.interior = info[SAVED_ITEM_INTERIOR],
		.zoffset = FLOOR_OFFSET,
		.geid = geid);

	logf("[LOAD] Item %d (%s) info: %d, %d, %f, %f, %f",
		itemid, geid,
		_:info[SAVED_ITEM_TYPE], info[SAVED_ITEM_ACTIVE],
		info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z]);
/*
	Todo: Figure out a way to block setting arraydata for certain items without
	a dumb function or lookup table of any sort
*/
	if(!IsItemTypeExtraDataDependent(GetItemType(itemid)))
		length = modio_read(filename, _T<A,R,R,Y>, sizeof(big_data), big_data, false, false);

	if(length > 0)
		SetItemArrayData(itemid, big_data, length);

	length = modio_read(filename, _T<D,A,T,A>, sizeof(big_data), big_data, true);

	CallLocalFunction(callback, "ddssd", itemid, info[SAVED_ITEM_ACTIVE], geid, big_data, length);

	return itemid;
}
