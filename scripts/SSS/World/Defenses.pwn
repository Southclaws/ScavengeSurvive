#include <YSI\y_hooks>


#define MAX_DEFENSE_ITEM	(10)
#define MAX_DEFENSE			(1024)
#define DEFENSE_DATA_FOLDER	"SSS/Defenses/"
#define DEFENSE_DATA_DIR	"./scriptfiles/SSS/Defenses/"


enum E_DEFENSE_ITEM_DATA
{
ItemType:	def_itemtype,
Float:		def_placeRotX,
Float:		def_placeRotY,
Float:		def_placeRotZ,
Float:		def_placeOffsetZ,
			def_maxHitPoints,
			def_buildVertical,
			def_buildHorizont
}

enum E_DEFENSE_DATA
{
			def_type,
			def_objectId,
			def_areaId,
			def_upright,
			def_hitPoints,
Float:		def_posX,
Float:		def_posY,
Float:		def_posZ,
Float:		def_rotZ
}


static
			def_TypeData[MAX_DEFENSE_ITEM][E_DEFENSE_ITEM_DATA],
Iterator:	def_TypeIndex<MAX_DEFENSE_ITEM>,
			def_ItemTypeBounds[2] = {65535, 0};

new
			def_Data[MAX_DEFENSE][E_DEFENSE_DATA],
Iterator:	def_Index<MAX_DEFENSE>;

new
Timer:		def_BuildTimer[MAX_PLAYERS],
			def_CurrentDefense[MAX_PLAYERS],
Float:		def_BuildProgress[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	def_CurrentDefense[playerid] = -1;
}


stock DefineDefenseItem(ItemType:itemtype, Float:rx, Float:ry, Float:rz, Float:zoffset, maxhitpoints, vert, horiz)
{
	new id = Iter_Free(def_TypeIndex);

	def_TypeData[id][def_itemtype] = itemtype;
	def_TypeData[id][def_placeRotX] = rx;
	def_TypeData[id][def_placeRotY] = ry;
	def_TypeData[id][def_placeRotZ] = rz;
	def_TypeData[id][def_placeOffsetZ] = zoffset;
	def_TypeData[id][def_maxHitPoints] = maxhitpoints;
	def_TypeData[id][def_buildVertical] = vert;
	def_TypeData[id][def_buildHorizont] = horiz;

	if(_:itemtype < def_ItemTypeBounds[0])
		def_ItemTypeBounds[0] = _:itemtype;

	if(_:itemtype > def_ItemTypeBounds[1])
		def_ItemTypeBounds[1] = _:itemtype;

	Iter_Add(def_TypeIndex, id);

	return id;
}

CreateDefense(type, Float:x, Float:y, Float:z, Float:rz, upright, hitpoints = -1)
{
	new id = Iter_Free(def_Index);

	if(id == -1)
		return -1;

	def_Data[id][def_type] = type;

	if(upright == 1)
	{
		if(!def_TypeData[type][def_buildVertical])
			return -1;

		def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
			def_TypeData[type][def_placeRotX],
			def_TypeData[type][def_placeRotY],
			def_TypeData[type][def_placeRotZ] + rz);
	}
	else
	{
		if(!def_TypeData[type][def_buildHorizont])
			return -1;

		def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z,
			def_TypeData[type][def_placeRotX] + 90.0,
			def_TypeData[type][def_placeRotY],
			def_TypeData[type][def_placeRotZ] + rz);
	}

	def_Data[id][def_areaId] = CreateDynamicSphere(x, y, z + def_TypeData[type][def_placeOffsetZ], 10.0);
	def_Data[id][def_upright] = upright;

	if(hitpoints == -1)
		def_Data[id][def_hitPoints] = def_TypeData[type][def_maxHitPoints];

	else
		def_Data[id][def_hitPoints] = hitpoints;

	def_Data[id][def_posX] = x;
	def_Data[id][def_posY] = y;
	def_Data[id][def_posZ] = z;
	def_Data[id][def_rotZ] = rz;

	Iter_Add(def_Index, id);

	return id;
}

stock DestroyDefense(defenseid)
{
	if(!Iter_Contains(def_Index, defenseid))
		return 0;

	new
		filename[64],
		next;

	format(filename, sizeof(filename), ""#DEFENSE_DATA_FOLDER"%d_%d_%d_%d", def_Data[defenseid][def_posX], def_Data[defenseid][def_posY], def_Data[defenseid][def_posZ], def_Data[defenseid][def_rotZ]);
	fremove(filename);

	DestroyDynamicObject(def_Data[defenseid][def_objectId]);
	DestroyDynamicArea(def_Data[defenseid][def_areaId]);

	def_Data[defenseid][def_upright]	= 0;
	def_Data[defenseid][def_hitPoints]	= 0;
	def_Data[defenseid][def_posX]		= 0.0;
	def_Data[defenseid][def_posY]		= 0.0;
	def_Data[defenseid][def_posZ]		= 0.0;
	def_Data[defenseid][def_rotZ]		= 0.0;

	Iter_SafeRemove(def_Index, defenseid, next);

	return next;
}

public OnPlayerPickedUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeBounds[0] <= _:itemtype <= def_ItemTypeBounds[1])
	{
		foreach(new i : def_TypeIndex)
		{
			if(itemtype == def_TypeData[i][def_itemtype])
			{
				ShowHelpTip(playerid, "Use a screwdriver with this while dropped to construct a permanent wall. Or use a hammer to construct a permanent floor.", 10000);
			}
		}
	}

	return CallLocalFunction("def_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
	#undef OnPlayerPickedUpItem
#else
	#define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem def_OnPlayerPickedUpItem
forward def_OnPlayerPickedUpItem(playerid, itemid);


public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Hammer || itemtype == item_Screwdriver)
	{
		new ItemType:withitemtype = GetItemType(withitemid);

		if(def_ItemTypeBounds[0] <= _:withitemtype <= def_ItemTypeBounds[1])
		{
			StartBuildingDefense(playerid, withitemid);
		}
	}

	return CallLocalFunction("def_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem def_OnPlayerUseItemWithItem
forward def_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopBuildingDefense(playerid);
	}
}

StartBuildingDefense(playerid, itemid)
{
	new type = -1;

	foreach(new i : def_TypeIndex)
	{
		if(GetItemType(itemid) == def_TypeData[i][def_itemtype])
		{
			type = i;
			break;
		}
	}

	if(type == -1)
		return 0;

	new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(itemtype == item_Screwdriver)
	{
		if(!def_TypeData[type][def_buildVertical])
		{
			ShowMsgBox(playerid, "You cannot build that part vertically.", 6000);
			return 0;
		}
	}

	if(itemtype == item_Hammer)
	{
		if(!def_TypeData[type][def_buildHorizont])
		{
			ShowMsgBox(playerid, "You cannot build that part horizontally.", 6000);
			return 0;
		}
	}

	def_BuildTimer[playerid] = repeat BuildDefenseUpdate(playerid, type);
	def_CurrentDefense[playerid] = itemid;
	def_BuildProgress[playerid] = 0.0;

	ShowPlayerProgressBar(playerid, ActionBar);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);

	return 1;
}

StopBuildingDefense(playerid)
{
	stop def_BuildTimer[playerid];
	if(def_CurrentDefense[playerid] != -1)
	{
		def_CurrentDefense[playerid] = -1;
		HidePlayerProgressBar(playerid, ActionBar);
		ClearAnimations(playerid);
	}
}

timer BuildDefenseUpdate[100](playerid, type)
{
	if(def_BuildProgress[playerid] == 100.0)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:angle,
			ItemType:playeritemtype = GetItemType(GetPlayerItem(playerid));

		GetItemPos(def_CurrentDefense[playerid], x, y, z);
		GetItemRot(def_CurrentDefense[playerid], angle, angle, angle);

		DestroyItem(def_CurrentDefense[playerid]);

		if(playeritemtype == item_Screwdriver)
			CreateDefense(type, x, y, z, angle, 1);

		if(playeritemtype == item_Hammer)
			CreateDefense(type, x, y, z, angle, 0);

		StopBuildingDefense(playerid);

		return;
	}

	SetPlayerProgressBarValue(playerid, ActionBar, def_BuildProgress[playerid]);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 100.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	def_BuildProgress[playerid] += 1.0;

	return;
}

LoadDefenses()
{
	new
		dir:direc = dir_open(DEFENSE_DATA_DIR),
		item[46],
		type,
		File:file,
		filedir[64],

		data[3],
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		count;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filedir = DEFENSE_DATA_FOLDER;
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				fblockread(file, data, sizeof(data));
				fclose(file);

				sscanf(item, "p<_>dddd", _:x, _:y, _:z, _:r);

				CreateDefense(data[0], Float:x, Float:y, Float:z, Float:r, data[1], data[2]);

				count++;
			}
		}
	}

	dir_close(direc);

	printf("Loaded %d Defense items", count);
}

SaveAllDefenses()
{
	foreach(new i : def_Index)
	{
		SaveDefenseItem(i);
	}
	return 1;
}

SaveDefenseItem(id)
{
	new
		filename[64],
		File:file,
		data[3];

	format(filename, sizeof(filename), ""#DEFENSE_DATA_FOLDER"%d_%d_%d_%d", def_Data[id][def_posX], def_Data[id][def_posY], def_Data[id][def_posZ], def_Data[id][def_rotZ]);
	file = fopen(filename, io_write);

	if(file)
	{
		data[0] = def_Data[id][def_type];
		data[1] = def_Data[id][def_upright];
		data[2] = def_Data[id][def_hitPoints];
		fblockwrite(file, data, sizeof(data));
		fclose(file);
	}
	else
	{
		printf("ERROR: Saving defense, filename: '%s'", filename);
	}
}

CreateStructuralExplosion(Float:x, Float:y, Float:z, type, Float:size)
{
	CreateExplosion(x, y, z, type, size);

	foreach(new i : def_Index)
	{
		if(Distance(x, y, z, def_Data[i][def_posX], def_Data[i][def_posY], def_Data[i][def_posZ]) < size)
		{
			def_Data[i][def_hitPoints] -= 1;

			if(def_Data[i][def_hitPoints] <= 0)
			{
				i = DestroyDefense(i);
			}
		}
	}
}

AutosaveDefenses()
{
	new idx;

	foreach(new i : def_Index)
	{
		autosave_Block[idx] = i;
		idx++;
	}
	autosave_Max = idx;

	defer Defense_BlockSave(0);
}

timer Defense_BlockSave[SAVE_BLOCK_INTERVAL](index)
{
	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK; i++)
	{
		if(i == autosave_Max)
			return;

		SaveDefenseItem(autosave_Block[i]);
	}

	defer Defense_BlockSave(i);

	return;
}
