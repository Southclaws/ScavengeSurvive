#include <YSI\y_hooks>


#define MAX_DEFENCE_ITEM	(10)
#define MAX_DEFENCE			(1024)


enum
{
	DEFENCE_MODE_HORIZONTAL,
	DEFENCE_MODE_VERTICAL,
	DEFENCE_MODE_OPENABLE,
}

enum E_DEFENCE_ITEM_DATA
{
ItemType:	def_itemtype,
Float:		def_verticalRotX,
Float:		def_verticalRotY,
Float:		def_verticalRotZ,
Float:		def_horizontalRotX,
Float:		def_horizontalRotY,
Float:		def_horizontalRotZ,
Float:		def_placeOffsetZ,
			def_maxHitPoints,
			def_buildVertical,
			def_buildHorizont
}

enum E_DEFENCE_DATA
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
			def_TypeData[MAX_DEFENCE_ITEM][E_DEFENCE_ITEM_DATA],
			def_TypeIndex,
			def_ItemTypeBounds[2] = {65535, 0};

new
			def_Data[MAX_DEFENCE][E_DEFENCE_DATA],
Iterator:	def_Index<MAX_DEFENCE>,
			def_ButtonDefence[BTN_MAX];

static
			def_CurrentDefenceItem[MAX_PLAYERS],
			def_CurrentDefenceEdit[MAX_PLAYERS],
			def_CurrentDefenceMove[MAX_PLAYERS],
			def_CurrentDefenceOpen[MAX_PLAYERS];


hook OnGameModeInit()
{
	for(new i; i < BTN_MAX; i++)
		def_ButtonDefence[i] = -1;
}

hook OnPlayerConnect(playerid)
{
	def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceEdit[playerid] = -1;
	def_CurrentDefenceMove[playerid] = -1;
	def_CurrentDefenceOpen[playerid] = -1;
}


stock DefineDefenceItem(ItemType:itemtype, Float:v_rx, Float:v_ry, Float:v_rz, Float:h_rx, Float:h_ry, Float:h_rz, Float:zoffset, maxhitpoints, vert, horiz)
{
	new id = def_TypeIndex;

	def_TypeData[id][def_itemtype] = itemtype;
	def_TypeData[id][def_verticalRotX] = v_rx;
	def_TypeData[id][def_verticalRotY] = v_ry;
	def_TypeData[id][def_verticalRotZ] = v_rz;
	def_TypeData[id][def_horizontalRotX] = h_rx;
	def_TypeData[id][def_horizontalRotY] = h_ry;
	def_TypeData[id][def_horizontalRotZ] = h_rz;
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

stock IsValidDefenceType(type)
{
	if(0 <= type < def_TypeIndex)
		return 1;

	return 0;
}

stock IsItemTypeDefenceItem(ItemType:itemtype)
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

CreateDefence(type, Float:x, Float:y, Float:z, Float:rz, mode, hitpoints = -1, pass = 0)
{
	new id = Iter_Free(def_Index);

	if(id == -1)
		return -1;

	new	itemtypename[ITM_MAX_NAME];

	def_Data[id][def_type] = type;

	GetItemTypeName(def_TypeData[type][def_itemtype], itemtypename);

	if(hitpoints == -1)
		def_Data[id][def_hitPoints] = def_TypeData[type][def_maxHitPoints];

	else
		def_Data[id][def_hitPoints] = hitpoints;

	if(mode == DEFENCE_MODE_HORIZONTAL)
	{
		if(!def_TypeData[type][def_buildHorizont])
			return -2;

		def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z,
			def_TypeData[type][def_horizontalRotX],
			def_TypeData[type][def_horizontalRotY],
			def_TypeData[type][def_horizontalRotZ] + rz);

		if(mode == DEFENCE_MODE_OPENABLE)
			def_Data[id][def_buttonId] = CreateButton(x, y, z, sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename), 0, 0, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);

		else
			def_Data[id][def_buttonId] = CreateButton(x, y, z, sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename), 0, 0, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);
	}
	else
	{
		if(!def_TypeData[type][def_buildVertical])
			return -3;

		def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
			def_TypeData[type][def_verticalRotX],
			def_TypeData[type][def_verticalRotY],
			def_TypeData[type][def_verticalRotZ] + rz);

		if(mode == DEFENCE_MODE_OPENABLE)
			def_Data[id][def_buttonId] = CreateButton(x, y, z + def_TypeData[type][def_placeOffsetZ], sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename), 0, 0, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);

		else
			def_Data[id][def_buttonId] = CreateButton(x, y, z + def_TypeData[type][def_placeOffsetZ], sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename), 0, 0, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);
	}

	def_ButtonDefence[def_Data[id][def_buttonId]] = id;

	def_Data[id][def_mode] = mode;
	def_Data[id][def_pass] = pass;

	def_Data[id][def_posX] = x;
	def_Data[id][def_posY] = y;
	def_Data[id][def_posZ] = z;
	def_Data[id][def_rotZ] = rz;

	Iter_Add(def_Index, id);

	return id;
}

stock DestroyDefence(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	new
		filename[64],
		next;

	format(filename, sizeof(filename), ""DIRECTORY_DEFENCES"%d_%d_%d_%d",
		def_Data[defenceid][def_posX],
		def_Data[defenceid][def_posY],
		def_Data[defenceid][def_posZ],
		def_Data[defenceid][def_rotZ]);

	fremove(filename);

	if(IsValidButton(def_Data[defenceid][def_buttonId]))
		def_ButtonDefence[def_Data[defenceid][def_buttonId]] = INVALID_ITEM_ID;

	DestroyDynamicObject(def_Data[defenceid][def_objectId]);
	DestroyButton(def_Data[defenceid][def_buttonId]);

	def_Data[defenceid][def_objectId] = INVALID_OBJECT_ID;
	def_Data[defenceid][def_buttonId] = INVALID_BUTTON_ID;

	def_Data[defenceid][def_mode]		= 0;
	def_Data[defenceid][def_hitPoints]	= 0;
	def_Data[defenceid][def_posX]		= 0.0;
	def_Data[defenceid][def_posY]		= 0.0;
	def_Data[defenceid][def_posZ]		= 0.0;
	def_Data[defenceid][def_rotZ]		= 0.0;

	Iter_SafeRemove(def_Index, defenceid, next);

	return next;
}

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Hammer || itemtype == item_Screwdriver)
	{
		new ItemType:withitemtype = GetItemType(withitemid);

		if(def_ItemTypeBounds[0] <= _:withitemtype <= def_ItemTypeBounds[1])
		{
			StartBuildingDefence(playerid, withitemid);
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
		StopBuildingDefence(playerid);
	}
}

StartBuildingDefence(playerid, itemid)
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

	new itemtypename[ITM_MAX_NAME];

	GetItemTypeName(def_TypeData[type][def_itemtype], itemtypename);

	def_CurrentDefenceItem[playerid] = itemid;
	StartHoldAction(playerid, 10000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, sprintf("Building %s...", itemtypename));

	return 1;
}

StopBuildingDefence(playerid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
		return;

	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);

		return;
	}
	if(def_CurrentDefenceEdit[playerid] != -1)
	{
		def_CurrentDefenceEdit[playerid] = -1;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);
		
		return;
	}

	return;
}

public OnButtonPress(playerid, buttonid)
{
	if(def_ButtonDefence[buttonid] != -1)
	{
		new id = def_ButtonDefence[buttonid];

		if(buttonid == def_Data[id][def_buttonId])
		{
			new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

			if(itemtype == item_Crowbar)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{
					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 10000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					ShowActionText(playerid, sprintf("Removing %s", itemtypename));

					return 1;
				}
			}

			if(itemtype == item_Keypad)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{	
					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 6000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

					ShowActionText(playerid, sprintf("Modifying %s", itemtypename));

					return 1;
				}
			}

			if(def_Data[id][def_mode] == DEFENCE_MODE_OPENABLE)
			{
				def_CurrentDefenceOpen[playerid] = id;

				ShowPlayerDialog(playerid, d_DefenceEnterPass, DIALOG_STYLE_INPUT, "Enter passcode", "Enter the 4 digit passcode to open.", "Enter", "Cancel");
				CancelPlayerMovement(playerid);

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

public OnHoldActionUpdate(playerid, progress)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			StopHoldAction(playerid);
	}
	return CallLocalFunction("def_OnHoldActionUpdate", "d", playerid, progress);
}
#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate def_OnHoldActionUpdate
forward def_OnHoldActionUpdate(playerid, progress);

public OnHoldActionFinish(playerid)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			return 1;

		new
			Float:x,
			Float:y,
			Float:z,
			Float:angle,
			ItemType:itemtype = GetItemType(GetPlayerItem(playerid)),
			type,
			id;

		GetItemPos(def_CurrentDefenceItem[playerid], x, y, z);
		GetItemRot(def_CurrentDefenceItem[playerid], angle, angle, angle);

		for(new i; i < def_TypeIndex; i++)
		{
			if(GetItemType(def_CurrentDefenceItem[playerid]) == def_TypeData[i][def_itemtype])
			{
				type = i;
				break;
			}
		}

		DestroyItem(def_CurrentDefenceItem[playerid]);

		if(itemtype == item_Screwdriver)
			id = CreateDefence(type, x, y, z, angle, DEFENCE_MODE_VERTICAL);

		if(itemtype == item_Hammer)
			id = CreateDefence(type, x, y, z, angle, DEFENCE_MODE_HORIZONTAL);


		SaveDefenceItem(id);
		StopBuildingDefence(playerid);
		//EditDefence(playerid, id);

		return 1;
	}

	if(def_CurrentDefenceEdit[playerid] != -1)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_Keypad)
		{
			ShowPlayerDialog(playerid, d_DefenceSetPass, DIALOG_STYLE_INPUT, "Set passcode", "Set a 4 digit passcode:", "Enter", "");
			def_Data[def_CurrentDefenceEdit[playerid]][def_mode] = DEFENCE_MODE_OPENABLE;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(GetItemType(itemid) == item_Crowbar)
		{
			CreateItem(def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_itemtype],
				def_Data[def_CurrentDefenceEdit[playerid]][def_posX],
				def_Data[def_CurrentDefenceEdit[playerid]][def_posY],
				def_Data[def_CurrentDefenceEdit[playerid]][def_posZ],
				.rz = def_Data[def_CurrentDefenceEdit[playerid]][def_rotZ],
				.zoffset = ITEM_BUTTON_OFFSET);

			logf("[CROWBAR] %p BROKE DEFENCE TYPE %d at %f, %f, %f", playerid, _:def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_itemtype], def_Data[def_CurrentDefenceEdit[playerid]][def_posX], def_Data[def_CurrentDefenceEdit[playerid]][def_posY], def_Data[def_CurrentDefenceEdit[playerid]][def_posZ]);

			DestroyDefence(def_CurrentDefenceEdit[playerid]);
			ClearAnimations(playerid);
			def_CurrentDefenceEdit[playerid] = -1;
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
	if(dialogid == d_DefenceSetPass)
	{
		if(response)
		{
			new pass = strval(intputtext);

			if(1000 <= pass < 10000)
			{
				def_Data[def_CurrentDefenceEdit[playerid]][def_pass] = pass;
				SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
			}
			else
			{
				ShowPlayerDialog(playerid, d_DefenceSetPass, DIALOG_STYLE_INPUT, "Set passcode", "Passcode must be a 4 digit number", "Enter", "");
			}
		}
	}

	if(dialogid == d_DefenceEnterPass)
	{
		if(response)
		{
			new pass = strval(intputtext);

			if(def_Data[def_CurrentDefenceOpen[playerid]][def_pass] == pass)
			{
				defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
			}
			else
			{
				ShowPlayerDialog(playerid, d_DefenceEnterPass, DIALOG_STYLE_INPUT, "Enter passcode", "Incorrect passcode!", "Enter", "Cancel");
			}
		}
	}

	return 1;
}

timer MoveDefence[1500](defenceid, playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	foreach(new i : Player)
	{
		GetPlayerPos(i, x, y, z);

		if(Distance(x, y, z, def_Data[defenceid][def_posX], def_Data[defenceid][def_posY], def_Data[defenceid][def_posZ]) < 2.0)
		{
			defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);

			return;
		}
	}

	if(def_Data[def_CurrentDefenceOpen[playerid]][def_open])
	{
		MoveDynamicObject(def_Data[defenceid][def_objectId],
			def_Data[defenceid][def_posX],
			def_Data[defenceid][def_posY],
			def_Data[defenceid][def_posZ] + def_TypeData[def_Data[defenceid][def_type]][def_placeOffsetZ], 0.5,
			def_TypeData[def_Data[defenceid][def_type]][def_verticalRotX],
			def_TypeData[def_Data[defenceid][def_type]][def_verticalRotY],
			def_TypeData[def_Data[defenceid][def_type]][def_verticalRotZ] + def_Data[defenceid][def_rotZ]);

		def_Data[defenceid][def_open] = false;
	}
	else
	{
		MoveDynamicObject(def_Data[defenceid][def_objectId],
			def_Data[defenceid][def_posX],
			def_Data[defenceid][def_posY],
			def_Data[defenceid][def_posZ], 0.5,
			def_TypeData[def_Data[defenceid][def_type]][def_horizontalRotX],
			def_TypeData[def_Data[defenceid][def_type]][def_horizontalRotY],
			def_TypeData[def_Data[defenceid][def_type]][def_horizontalRotZ] + def_Data[defenceid][def_rotZ]);

		def_Data[defenceid][def_open] = true;
	}

	return;
}


// Save and Load


LoadDefences(printeach = false, printtotal = false)
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_DEFENCES),
		item[46],
		type,
		File:file,
		filedir[64],

		data[4],
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filedir = DIRECTORY_DEFENCES;
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				fblockread(file, data, sizeof(data));
				fclose(file);

				sscanf(item, "p<_>dddd", _:x, _:y, _:z, _:r);

				new ret = CreateDefence(data[0], Float:x, Float:y, Float:z, Float:r, data[1], data[2], data[3]);

				if(ret > -1)
				{
					if(printeach)
						printf("\t[LOAD] Defence at %f, %f, %f", x, y, z);
				}
				else
				{
					fremove(filedir);
					printf("ERROR: Loading defence type %d at %f, %f, %f, Code: %d", data[0], x, y, z, ret);
				}
			}
		}
	}

	dir_close(direc);

	if(printtotal)
		printf("Loaded %d Defences\n", Iter_Count(def_Index));
}

SaveDefences(printeach = false, printtotal = false)
{
	foreach(new i : def_Index)
	{
		SaveDefenceItem(i, printeach);
	}

	if(printtotal)
		printf("Saved %d Defences\n", Iter_Count(def_Index));
}

SaveDefenceItem(id, prints = false)
{
	if(!Iter_Contains(def_Index, id))
		return 0;

	new
		filename[64],
		File:file,
		data[4];

	format(filename, sizeof(filename), ""DIRECTORY_DEFENCES"%d_%d_%d_%d", def_Data[id][def_posX], def_Data[id][def_posY], def_Data[id][def_posZ], def_Data[id][def_rotZ]);
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
		printf("ERROR: Saving defence, filename: '%s'", filename);
		return 0;
	}

	if(prints)
		printf("\t[SAVE] Defence at %f, %f, %f", def_Data[id][def_posX], def_Data[id][def_posY], def_Data[id][def_posZ]);

	return 1;
}

CreateStructuralExplosion(Float:x, Float:y, Float:z, type, Float:size, hitpoints = 1)
{
	CreateExplosion(x, y, z, type, size);

	new
		Float:smallestdistance = 9999999.9,
		Float:tempdistance,
		closestid;

	foreach(new i : def_Index)
	{
		tempdistance = Distance(x, y, z, def_Data[i][def_posX], def_Data[i][def_posY], def_Data[i][def_posZ]);

		if(tempdistance < smallestdistance)
		{
			smallestdistance = tempdistance;
			closestid = i;
		}
	}

	if(smallestdistance < size)
	{
		def_Data[closestid][def_hitPoints] -= hitpoints;

		if(def_Data[closestid][def_hitPoints] <= 0)
		{
			logf("[DESTRUCTION] DEFENCE TYPE %d DESTROYED AT %f, %f, %f", _:def_TypeData[def_Data[closestid][def_type]][def_itemtype], def_Data[closestid][def_posX], def_Data[closestid][def_posY], def_Data[closestid][def_posZ]);

			DestroyDefence(closestid);
		}
		else
		{
			SetButtonLabel(def_Data[closestid][def_buttonId], sprintf("%d/%d", def_Data[closestid][def_hitPoints], def_TypeData[def_Data[closestid][def_type]][def_maxHitPoints]), .range = 1.5);
		}
	}
}



// Interface



stock GetDefencePos(defenceid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	x = def_Data[defenceid][def_posX];
	y = def_Data[defenceid][def_posY];
	z = def_Data[defenceid][def_posZ];

	return 1;
}
