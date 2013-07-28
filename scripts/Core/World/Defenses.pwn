#include <YSI\y_hooks>


#define MAX_DEFENSE_ITEM	(10)
#define MAX_DEFENSE			(1024)
#define DEFENSE_DATA_FOLDER	"SSS/Defenses/"
#define DEFENSE_DATA_DIR	"./scriptfiles/SSS/Defenses/"


enum
{
	DEFENSE_MODE_HORIZONTAL,
	DEFENSE_MODE_VERTICAL,
	DEFENSE_MODE_OPENABLE,
}

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
			def_buttonId,
			def_mode,
			def_pass,
			def_open,
			def_hitPoints,
Float:		def_posX,
Float:		def_posY,
Float:		def_posZ,
Float:		def_rotZ
}


static
			def_TypeData[MAX_DEFENSE_ITEM][E_DEFENSE_ITEM_DATA],
			def_TypeIndex,
			def_ItemTypeBounds[2] = {65535, 0};

new
			def_Data[MAX_DEFENSE][E_DEFENSE_DATA],
Iterator:	def_Index<MAX_DEFENSE>;

static
			def_CurrentDefenseItem[MAX_PLAYERS],
			def_CurrentDefenseEdit[MAX_PLAYERS],
			def_CurrentDefenseMove[MAX_PLAYERS],
			def_CurrentDefenseOpen[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	def_CurrentDefenseItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenseEdit[playerid] = -1;
	def_CurrentDefenseMove[playerid] = -1;
	def_CurrentDefenseOpen[playerid] = -1;
}


stock DefineDefenseItem(ItemType:itemtype, Float:rx, Float:ry, Float:rz, Float:zoffset, maxhitpoints, vert, horiz)
{
	new id = def_TypeIndex;

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

	return def_TypeIndex++;
}

stock IsValidDefenseType(type)
{
	if(0 <= type < def_TypeIndex)
		return 1;

	return 0;
}

stock IsItemTypeDefenseItem(ItemType:itemtype)
{
	for(new i; i < def_TypeIndex; i++)
	{
		if(itemtype == def_TypeData[i][def_itemtype])
		{
			return true;
		}
	}
	return false;
}

CreateDefense(type, Float:x, Float:y, Float:z, Float:rz, mode, hitpoints = -1, pass = 0)
{
	new id = Iter_Free(def_Index);

	if(id == -1)
		return -1;

	def_Data[id][def_type] = type;

	if(mode == DEFENSE_MODE_HORIZONTAL)
	{
		if(!def_TypeData[type][def_buildHorizont])
			return -1;

		def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z,
			def_TypeData[type][def_placeRotX] + 90.0,
			def_TypeData[type][def_placeRotY],
			def_TypeData[type][def_placeRotZ] + rz);
	}
	else
	{
		if(!def_TypeData[type][def_buildVertical])
			return -1;

		def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
			def_TypeData[type][def_placeRotX],
			def_TypeData[type][def_placeRotY],
			def_TypeData[type][def_placeRotZ] + rz);
	}

	if(mode == DEFENSE_MODE_OPENABLE)
		def_Data[id][def_buttonId] = CreateButton(x, y, z, ""KEYTEXT_INTERACT" to open", .areasize = 1.5);

	else
		def_Data[id][def_buttonId] = CreateButton(x, y, z, ""KEYTEXT_INTERACT" to modify", .areasize = 1.5);

	def_Data[id][def_mode] = mode;
	def_Data[id][def_pass] = pass;

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
	DestroyButton(def_Data[defenseid][def_buttonId]);

	def_Data[defenseid][def_mode]		= 0;
	def_Data[defenseid][def_hitPoints]	= 0;
	def_Data[defenseid][def_posX]		= 0.0;
	def_Data[defenseid][def_posY]		= 0.0;
	def_Data[defenseid][def_posZ]		= 0.0;
	def_Data[defenseid][def_rotZ]		= 0.0;

	Iter_SafeRemove(def_Index, defenseid, next);

	return next;
}

/*
EditDefense(playerid, defenseid)
{
	if(!Iter_Contains(def_Index, defenseid))
		return 0;

	TogglePlayerControllable(playerid, false);
	Streamer_Update(playerid);
	EditDynamicObject(playerid, def_Data[defenseid][def_objectId]);
	def_CurrentDefenseMove[playerid] = defenseid;

	return 1;
}
*/

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(def_CurrentDefenseMove[playerid] != -1)
	{
		if(objectid == def_Data[def_CurrentDefenseMove[playerid]][def_objectId])
		{
			if(response == 1)
			{
				new filename[64];

				format(filename, sizeof(filename), ""#DEFENSE_DATA_FOLDER"%d_%d_%d_%d", def_Data[def_CurrentDefenseMove[playerid]][def_posX], def_Data[def_CurrentDefenseMove[playerid]][def_posY], def_Data[def_CurrentDefenseMove[playerid]][def_posZ], def_Data[def_CurrentDefenseMove[playerid]][def_rotZ]);
				fremove(filename);

				def_Data[def_CurrentDefenseMove[playerid]][def_posX] = x;
				def_Data[def_CurrentDefenseMove[playerid]][def_posY] = y;
				def_Data[def_CurrentDefenseMove[playerid]][def_posZ] = z;
				SaveDefenseItem(def_CurrentDefenseMove[playerid]);
				TogglePlayerControllable(playerid, true);
			}
			if(response == 2)
			{
				if(Distance(x, y, z, def_Data[def_CurrentDefenseMove[playerid]][def_posX], def_Data[def_CurrentDefenseMove[playerid]][def_posY], def_Data[def_CurrentDefenseMove[playerid]][def_posZ]) > 2.0)
				{
					CancelEdit(playerid);
					SetDynamicObjectPos(objectid, def_Data[def_CurrentDefenseMove[playerid]][def_posX], def_Data[def_CurrentDefenseMove[playerid]][def_posY], def_Data[def_CurrentDefenseMove[playerid]][def_posZ]);
					defer RetryEdit(playerid, objectid);
					return 1;
				}
			}
		}
	}

	return 1;
}

timer RetryEdit[100](playerid, objectid)
{
	EditDynamicObject(playerid, objectid);
}

timer OpenDefense[1500](defenseid)
{
	MoveDynamicObject(def_Data[defenseid][def_objectId],
		def_Data[defenseid][def_posX],
		def_Data[defenseid][def_posY],
		def_Data[defenseid][def_posZ], 0.5,
		def_TypeData[def_Data[defenseid][def_type]][def_placeRotX] + 90.0,
		def_TypeData[def_Data[defenseid][def_type]][def_placeRotY],
		def_TypeData[def_Data[defenseid][def_type]][def_placeRotZ] + def_Data[defenseid][def_rotZ]);

	def_Data[defenseid][def_open] = true;
}
timer CloseDefense[1500](defenseid)
{
	MoveDynamicObject(def_Data[defenseid][def_objectId],
		def_Data[defenseid][def_posX],
		def_Data[defenseid][def_posY],
		def_Data[defenseid][def_posZ] + def_TypeData[def_Data[defenseid][def_type]][def_placeOffsetZ], 0.5,
		def_TypeData[def_Data[defenseid][def_type]][def_placeRotX],
		def_TypeData[def_Data[defenseid][def_type]][def_placeRotY],
		def_TypeData[def_Data[defenseid][def_type]][def_placeRotZ] + def_Data[defenseid][def_rotZ]);

	def_Data[defenseid][def_open] = false;
}

public OnPlayerPickedUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeBounds[0] <= _:itemtype <= def_ItemTypeBounds[1])
	{
		for(new i; i < def_TypeIndex; i++)
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

	for(new i; i < def_TypeIndex; i++)
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
			ShowActionText(playerid, "You cannot build that part vertically.", 6000);
			return 0;
		}
	}

	if(itemtype == item_Hammer)
	{
		if(!def_TypeData[type][def_buildHorizont])
		{
			ShowActionText(playerid, "You cannot build that part horizontally.", 6000);
			return 0;
		}
	}

	def_CurrentDefenseItem[playerid] = itemid;
	StartHoldAction(playerid, 10000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);

	return 1;
}

StopBuildingDefense(playerid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
		return;

	if(def_CurrentDefenseItem[playerid] != INVALID_ITEM_ID)
	{
		def_CurrentDefenseItem[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		return;
	}
	if(def_CurrentDefenseEdit[playerid] != -1)
	{
		def_CurrentDefenseEdit[playerid] = -1;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		return;
	}
	return;
}

public OnButtonPress(playerid, buttonid)
{
	foreach(new i : def_Index)
	{
		if(buttonid == def_Data[i][def_buttonId])
		{
			new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

			if(itemtype == item_Crowbar)
			{
				new Float:angle = absoluteangle(def_Data[i][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{	
					def_CurrentDefenseEdit[playerid] = i;
					StartHoldAction(playerid, 10000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					return 1;
				}
			}

			if(itemtype == item_Keypad)
			{
				new Float:angle = absoluteangle(def_Data[i][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{	
					def_CurrentDefenseEdit[playerid] = i;
					StartHoldAction(playerid, 6000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					return 1;
				}
			}

			if(def_Data[i][def_mode] == DEFENSE_MODE_OPENABLE)
			{
				def_CurrentDefenseOpen[playerid] = i;
				ShowPlayerDialog(playerid, d_DefenseEnterPass, DIALOG_STYLE_INPUT, "Enter passcode", "Enter the 4 digit passcode to open.", "Enter", "Cancel");
				return 1;
			}
		}
	}

	return CallLocalFunction("def_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress def_OnButtonPress
forward def_OnButtonPress(playerid, buttonid);

public OnHoldActionFinish(playerid)
{
	if(def_CurrentDefenseItem[playerid] != INVALID_ITEM_ID)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:angle,
			ItemType:itemtype = GetItemType(GetPlayerItem(playerid)),
			type,
			id;

		GetItemPos(def_CurrentDefenseItem[playerid], x, y, z);
		GetItemRot(def_CurrentDefenseItem[playerid], angle, angle, angle);

		for(new i; i < def_TypeIndex; i++)
		{
			if(GetItemType(def_CurrentDefenseItem[playerid]) == def_TypeData[i][def_itemtype])
			{
				type = i;
				break;
			}
		}

		DestroyItem(def_CurrentDefenseItem[playerid]);


		if(itemtype == item_Screwdriver)
			id = CreateDefense(type, x, y, z, angle, DEFENSE_MODE_VERTICAL);

		if(itemtype == item_Hammer)
			id = CreateDefense(type, x, y, z, angle, DEFENSE_MODE_HORIZONTAL);


		SaveDefenseItem(id);
		StopBuildingDefense(playerid);
		//EditDefense(playerid, id);

		return 1;
	}

	if(def_CurrentDefenseEdit[playerid] != -1)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_Keypad)
		{
			ShowPlayerDialog(playerid, d_DefenseSetPass, DIALOG_STYLE_INPUT, "Set passcode", "Set a 4 digit passcode:", "Enter", "");
			def_Data[def_CurrentDefenseEdit[playerid]][def_mode] = DEFENSE_MODE_OPENABLE;
			SaveDefenseItem(def_CurrentDefenseEdit[playerid]);
			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(GetItemType(itemid) == item_Crowbar)
		{
			CreateItem(def_TypeData[def_Data[def_CurrentDefenseEdit[playerid]][def_type]][def_itemtype],
				def_Data[def_CurrentDefenseEdit[playerid]][def_posX],
				def_Data[def_CurrentDefenseEdit[playerid]][def_posY],
				def_Data[def_CurrentDefenseEdit[playerid]][def_posZ],
				.rz = def_Data[def_CurrentDefenseEdit[playerid]][def_rotZ],
				.zoffset = ITEM_BUTTON_OFFSET);

			DestroyDefense(def_CurrentDefenseEdit[playerid]);
			ClearAnimations(playerid);
			def_CurrentDefenseEdit[playerid] = -1;
		}

		return 1;
	}

	return CallLocalFunction("def_OnHoldActionFinish", "d", playerid);
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish def_OnHoldActionFinish
forward def_OnHoldActionFinish(playerid);

hook OnDialogResponse(playerid, dialogid, response, listitem, intputtext[])
{
	if(dialogid == d_DefenseSetPass)
	{
		if(response)
		{
			new pass = strval(intputtext);

			if(1000 <= pass < 10000)
			{
				def_Data[def_CurrentDefenseEdit[playerid]][def_pass] = pass;
				SaveDefenseItem(def_CurrentDefenseEdit[playerid]);
			}
			else
			{
				ShowPlayerDialog(playerid, d_DefenseSetPass, DIALOG_STYLE_INPUT, "Set passcode", "Passcode must be a 4 digit number", "Enter", "");
			}
		}
	}

	if(dialogid == d_DefenseEnterPass)
	{
		if(response)
		{
			new pass = strval(intputtext);

			if(def_Data[def_CurrentDefenseOpen[playerid]][def_pass] == pass)
			{
				if(def_Data[def_CurrentDefenseOpen[playerid]][def_open])
					defer CloseDefense(def_CurrentDefenseOpen[playerid]);

				else
					defer OpenDefense(def_CurrentDefenseOpen[playerid]);
			}
			else
			{
				ShowPlayerDialog(playerid, d_DefenseEnterPass, DIALOG_STYLE_INPUT, "Enter passcode", "Incorrect passcode!", "Enter", "Cancel");
			}
		}
	}

	return 1;
}


// Save and Load


LoadDefenses()
{
	new
		dir:direc = dir_open(DEFENSE_DATA_DIR),
		item[46],
		type,
		File:file,
		filedir[64],

		data[4],
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

				if(!IsValidDefenseType(data[0]))
				{
					fremove(filedir);
					continue;
				}

				CreateDefense(data[0], Float:x, Float:y, Float:z, Float:r, data[1], data[2], data[3]);

				count++;
			}
		}
	}

	dir_close(direc);

	printf("Loaded %d Defense items\n", count);
}

SaveDefenses()
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
		data[4];

	format(filename, sizeof(filename), ""#DEFENSE_DATA_FOLDER"%d_%d_%d_%d", def_Data[id][def_posX], def_Data[id][def_posY], def_Data[id][def_posZ], def_Data[id][def_rotZ]);
	file = fopen(filename, io_write);

	if(file)
	{
		data[0] = def_Data[id][def_type];
		data[1] = def_Data[id][def_mode];
		data[2] = def_Data[id][def_hitPoints];
		data[3] = def_Data[id][def_pass];
		fblockwrite(file, data, sizeof(data));
		fclose(file);
	}
	else
	{
		printf("ERROR: Saving defense, filename: '%s'", filename);
	}
}

CreateStructuralExplosion(Float:x, Float:y, Float:z, type, Float:size, hitpoints = 1)
{
	CreateExplosion(x, y, z, type, size);

	foreach(new i : def_Index)
	{
		if(Distance(x, y, z, def_Data[i][def_posX], def_Data[i][def_posY], def_Data[i][def_posZ]) < size)
		{
			def_Data[i][def_hitPoints] -= hitpoints;

			if(def_Data[i][def_hitPoints] <= 0)
				i = DestroyDefense(i);

			break;
		}
	}
}



// Interface



stock GetDefencePos(defenseid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(def_Index, defenseid))
		return 0;

	x = def_Data[defenseid][def_posX];
	y = def_Data[defenseid][def_posY];
	z = def_Data[defenseid][def_posZ];

	return 1;
}
