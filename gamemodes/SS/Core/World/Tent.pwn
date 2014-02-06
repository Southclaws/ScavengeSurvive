#include <YSI\y_hooks>


#define MAX_TENT			(1024)
#define MAX_TENT_ITEMS		(8)
#define INVALID_TENT_ID		(-1)


enum E_TENT_DATA
{
			tnt_buttonId,
			tnt_objSideR1,
			tnt_objSideR2,
			tnt_objSideL1,
			tnt_objSideL2,
			tnt_objEndF,
			tnt_objEndB,
			tnt_objPoleF,
			tnt_objPoleB,
Float:		tnt_posX,
Float:		tnt_posY,
Float:		tnt_posZ,
Float:		tnt_rotZ
}

enum
{
			TENT_CELL_ITEMTYPE,
			TENT_CELL_EXDATA,
			TENT_CELL_POSX,
			TENT_CELL_POSY,
			TENT_CELL_POSZ,
			TENT_CELL_ROTZ,
			TENT_CELL_END
}

new
			tnt_Data[MAX_TENT][E_TENT_DATA],
Iterator:	tnt_Index<MAX_TENT>;

static
			tnt_CurrentTentID[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
}


stock CreateTent(Float:x, Float:y, Float:z, Float:rz)
{
	new id = Iter_Free(tnt_Index);

	tnt_Data[id][tnt_buttonId] = CreateButton(x, y, z, "Hold "KEYTEXT_INTERACT" with crowbar to dismantle", .label = 0);

	tnt_Data[id][tnt_objSideR1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 270.0, degrees)),
		y + (0.49 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, .streamdistance = 100.0);

	tnt_Data[id][tnt_objSideR2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 270.0, degrees)),
		y + (0.48 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, .streamdistance = 20.0);

	tnt_Data[id][tnt_objSideL1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 90.0, degrees)),
		y + (0.49 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, .streamdistance = 100.0);

	tnt_Data[id][tnt_objSideL2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 90.0, degrees)),
		y + (0.48 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, .streamdistance = 20.0);

	tnt_Data[id][tnt_objEndF] = CreateDynamicObject(19475,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.17,
		45.0, 0.0, rz + 90, .streamdistance = 5.0);

	tnt_Data[id][tnt_objEndB] = CreateDynamicObject(19475,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.17,
		45.0, 0.0, rz + 90, .streamdistance = 5.0);

	tnt_Data[id][tnt_objPoleF] = CreateDynamicObject(19087,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, .streamdistance = 10.0);

	tnt_Data[id][tnt_objPoleB] = CreateDynamicObject(19087,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, .streamdistance = 10.0);

	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideR1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideR2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideL1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideL2], 0, 3095, "a51jdrx", "sam_camo", 0);

	SetDynamicObjectMaterial(tnt_Data[id][tnt_objEndF], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objEndB], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objPoleF], 0, 1270, "signs", "lamppost", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objPoleB], 0, 1270, "signs", "lamppost", 0);

	tnt_Data[id][tnt_posX] = x;
	tnt_Data[id][tnt_posY] = y;
	tnt_Data[id][tnt_posZ] = z;
	tnt_Data[id][tnt_rotZ] = rz;

	Iter_Add(tnt_Index, id);

	return id;
}

stock DestroyTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	new filename[64];

	format(filename, sizeof(filename), ""DIRECTORY_TENT"%d_%d_%d_%d",
		tnt_Data[tentid][tnt_posX], tnt_Data[tentid][tnt_posY], tnt_Data[tentid][tnt_posZ], tnt_Data[tentid][tnt_rotZ]);

	if(fexist(filename))
		fremove(filename);


	DestroyButton(tnt_Data[tentid][tnt_buttonId]);

	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideR1]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideR2]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideL1]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideL2]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objEndF]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objEndB]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objPoleF]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objPoleB]);

	tnt_Data[tentid][tnt_objSideR1] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideR2] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideL1] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideL2] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objEndF] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objEndB] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objPoleF] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objPoleB] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_posX] = 0.0;
	tnt_Data[tentid][tnt_posY] = 0.0;
	tnt_Data[tentid][tnt_posZ] = 0.0;
	tnt_Data[tentid][tnt_rotZ] = 0.0;

	Iter_SafeRemove(tnt_Index, tentid, tentid);

	return tentid;
}



// Interaction



public OnButtonPress(playerid, buttonid)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
	{
		foreach(new i : tnt_Index)
		{
			if(buttonid == tnt_Data[i][tnt_buttonId])
			{
				tnt_CurrentTentID[playerid] = i;
				StartHoldAction(playerid, 15000);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
				ShowActionText(playerid, "Removing Tent");

				return 1;
			}
		}
	}

	return CallLocalFunction("tnt_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress tnt_OnButtonPress
forward tnt_OnButtonPress(playerid, buttonid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(tnt_CurrentTentID[playerid] != INVALID_TENT_ID)
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);
			HideActionText(playerid);
			tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
		}
	}

	return 1;
}

public OnHoldActionFinish(playerid)
{
	if(tnt_CurrentTentID[playerid] != INVALID_TENT_ID)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
		{
			CreateItem(item_TentPack,
				tnt_Data[tnt_CurrentTentID[playerid]][tnt_posX],
				tnt_Data[tnt_CurrentTentID[playerid]][tnt_posY],
				tnt_Data[tnt_CurrentTentID[playerid]][tnt_posZ] - 0.4,
				.rz = tnt_Data[tnt_CurrentTentID[playerid]][tnt_posX],
				.zoffset = FLOOR_OFFSET);

			DestroyTent(tnt_CurrentTentID[playerid]);
			ClearAnimations(playerid);
			HideActionText(playerid);

			tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
		}
	}

	return CallLocalFunction("tnt2_OnHoldActionFinish", "d", playerid);
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish tnt2_OnHoldActionFinish
forward tnt2_OnHoldActionFinish(playerid);



// Save and Load



SaveTents(printeach = false, printtotal = false)
{
	new count;

	foreach(new i : tnt_Index)
	{
		if(SaveTent(i, printeach))
			count++;
	}

	if(printtotal)
		printf("Saved %d Tents\n", count);
}

LoadTents(printeach = false, printtotal = false)
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_TENT),
		item[46],
		type,
		File:file,
		filedir[64],

		Float:x,
		Float:y,
		Float:z,
		Float:r,
		data[MAX_TENT_ITEMS * TENT_CELL_END],
		itemid,
		count;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filedir = DIRECTORY_TENT;
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				new idx;

				fblockread(file, data, MAX_TENT_ITEMS * TENT_CELL_END);
				fclose(file);

				sscanf(item, "p<_>dddd", _:x, _:y, _:z, _:r);

				if(printeach)
					printf("\t[LOAD] Tent at %f, %f, %f", x, y, z);

				CreateTent(Float:x, Float:y, Float:z, Float:r);

				while(idx < sizeof(data))
				{
					if(!IsValidItemType(ItemType:data[idx + TENT_CELL_ITEMTYPE]))
						break;

					itemid = CreateItem(ItemType:data[idx + TENT_CELL_ITEMTYPE],
						Float:data[idx + TENT_CELL_POSX],
						Float:data[idx + TENT_CELL_POSY],
						Float:data[idx + TENT_CELL_POSZ],
						.rz = Float:data[idx + TENT_CELL_ROTZ],
						.zoffset = FLOOR_OFFSET);

					if(!IsItemTypeExtraDataDependent(ItemType:data[idx + TENT_CELL_ITEMTYPE]))
						SetItemExtraData(itemid, data[idx + TENT_CELL_EXDATA]);

					idx += TENT_CELL_END;
				}

				count++;
			}
		}
	}

	dir_close(direc);

	if(printtotal)
		printf("Loaded %d Tents\n", count);
}

SaveTent(tentid, prints = false)
{
	if(!Iter_Contains(itm_Index, tentid))
		return 0;

	if(prints)
		printf("\t[SAVE] Tent at %f, %f, %f", tnt_Data[tentid][tnt_posX], tnt_Data[tentid][tnt_posY], tnt_Data[tentid][tnt_posZ]);

	new
		filename[64],
		File:file,
		data[MAX_TENT_ITEMS * TENT_CELL_END];

	format(filename, sizeof(filename), ""DIRECTORY_TENT"%d_%d_%d_%d",
		tnt_Data[tentid][tnt_posX], tnt_Data[tentid][tnt_posY], tnt_Data[tentid][tnt_posZ], tnt_Data[tentid][tnt_rotZ]);

	file = fopen(filename, io_write);

	if(file)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			ItemType:itemtype,
			exdata,
			idx;

		foreach(new j : itm_Index)
		{
			itemtype = GetItemType(j);
			exdata = GetItemExtraData(j);

			if(IsItemTypeSafebox(itemtype))
				continue;

			if(!IsItemInWorld(j))
				continue;

			GetItemPos(j, x, y, z);
			GetItemRot(j, r, r, r);

			if(x == 0.0 && y == 0.0 && z == 0.0)
				continue;

			if(Distance(tnt_Data[tentid][tnt_posX], tnt_Data[tentid][tnt_posY], tnt_Data[tentid][tnt_posZ], x, y, z) < 2.0)
			{
				data[idx + TENT_CELL_ITEMTYPE] = _:itemtype;
				data[idx + TENT_CELL_EXDATA] = exdata;
				data[idx + TENT_CELL_POSX] = _:x;
				data[idx + TENT_CELL_POSY] = _:y;
				data[idx + TENT_CELL_POSZ] = _:z;
				data[idx + TENT_CELL_ROTZ] = _:r;

				idx += TENT_CELL_END;

				j = DestroyItem(j);

				if(idx >= sizeof(data))
					break;
			}
		}
		fblockwrite(file, data);
		fclose(file);
	}
	else
	{
		printf("ERROR: Saving tent, filename: '%s'", filename);
		return 0;
	}

	return 1;
}



// Interface



stock GetTentPos(tentid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	x = tnt_Data[tentid][tnt_posX];
	y = tnt_Data[tentid][tnt_posY];
	z = tnt_Data[tentid][tnt_posZ];

	return 1;
}
