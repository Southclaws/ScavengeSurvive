#include <YSI\y_hooks>


#define MAX_WORK_BENCH	(8)


enum E_WORKBENCH_DATA
{
			wb_objId,
			wb_buttonId,
Text3D:		wb_labelId,
Float:		wb_posX,
Float:		wb_posY,
Float:		wb_posZ,
Float:		wb_rotZ,
			wb_items[4],
}


new
			wb_Data[MAX_WORK_BENCH][E_WORKBENCH_DATA],
Iterator:	wb_Index<MAX_WORK_BENCH>;

new
			wb_CurrentWorkbench[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	wb_CurrentWorkbench[playerid] = -1;
}


stock CreateWorkBench(Float:x, Float:y, Float:z, Float:rz)
{
	new id = Iter_Free(wb_Index);

	if(id == -1)
	{
		print("ERROR: MAX_WORK_BENCH Limit reached.");
		return 0;
	}

	wb_Data[id][wb_objId] = CreateDynamicObject(936, x, y, z, 0.0, 0.0, rz);
	wb_Data[id][wb_buttonId] = CreateButton(x, y, z, "Press "#KEYTEXT_INTERACT" to use workbench", .areasize = 2.0);
	wb_Data[id][wb_labelId] = CreateDynamic3DTextLabel("Workbench", GREEN, x, y, z + 1.0, 10.0);
	wb_Data[id][wb_posX] = x;
	wb_Data[id][wb_posY] = y;
	wb_Data[id][wb_posZ] = z;
	wb_Data[id][wb_rotZ] = rz;
	wb_Data[id][wb_items][0] = INVALID_ITEM_ID;
	wb_Data[id][wb_items][1] = INVALID_ITEM_ID;
	wb_Data[id][wb_items][2] = INVALID_ITEM_ID;
	wb_Data[id][wb_items][3] = INVALID_ITEM_ID;

	Iter_Add(wb_Index, id);

	return id;
}

public OnButtonPress(playerid, buttonid)
{
	new itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
		foreach(new i : wb_Index)
		{
			if(buttonid == wb_Data[i][wb_buttonId])
			{
				Internal_OnPlayerUseWorkbench(playerid, i, itemid);
			}
		}
	}

	return CallLocalFunction("wb_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress wb_OnButtonPress
forward wb_OnButtonPress(playerid, buttonid);

Internal_OnPlayerUseWorkbench(playerid, workbenchid, itemid)
{
	if(GetItemType(itemid) == item_Hammer)
	{
		StartHoldAction(playerid, 5000);
		wb_CurrentWorkbench[playerid] = workbenchid;

		return 0;
	}

	new idx;

	for(new i; i < 4; i++)
	{
		if(IsValidItem(wb_Data[workbenchid][wb_items][i]))
			idx++;	
	}

	if(idx == 4)
	{
		return -1;
	}

	switch(idx)
	{
		case 0:
		{
			CreateItemInWorld(itemid,
				wb_Data[workbenchid][wb_posX] + (0.8 * floatsin(-wb_Data[workbenchid][wb_rotZ] + 105.0, degrees)),
				wb_Data[workbenchid][wb_posY] + (0.8 * floatcos(-wb_Data[workbenchid][wb_rotZ] + 105.0, degrees)),
				wb_Data[workbenchid][wb_posZ] + 0.49,
				0.0, 0.0, wb_Data[workbenchid][wb_rotZ] - 95.0 + frandom(10.0));
		}
		case 1:
		{
			CreateItemInWorld(itemid,
				wb_Data[workbenchid][wb_posX] + (0.32 * floatsin(-wb_Data[workbenchid][wb_rotZ] + 125.0, degrees)),
				wb_Data[workbenchid][wb_posY] + (0.32 * floatcos(-wb_Data[workbenchid][wb_rotZ] + 125.0, degrees)),
				wb_Data[workbenchid][wb_posZ] + 0.49,
				0.0, 0.0, wb_Data[workbenchid][wb_rotZ] - 95.0 + frandom(10.0));
		}
		case 2:
		{
			CreateItemInWorld(itemid,
				wb_Data[workbenchid][wb_posX] + (0.32 * floatsin(-wb_Data[workbenchid][wb_rotZ] - 125.0, degrees)),
				wb_Data[workbenchid][wb_posY] + (0.32 * floatcos(-wb_Data[workbenchid][wb_rotZ] - 125.0, degrees)),
				wb_Data[workbenchid][wb_posZ] + 0.49,
				0.0, 0.0, wb_Data[workbenchid][wb_rotZ] - 95.0 + frandom(10.0));
		}
		case 3:
		{
			CreateItemInWorld(itemid,
				wb_Data[workbenchid][wb_posX] + (0.8 * floatsin(-wb_Data[workbenchid][wb_rotZ] - 105.0, degrees)),
				wb_Data[workbenchid][wb_posY] + (0.8 * floatcos(-wb_Data[workbenchid][wb_rotZ] - 105.0, degrees)),
				wb_Data[workbenchid][wb_posZ] + 0.49,
				0.0, 0.0, wb_Data[workbenchid][wb_rotZ] - 95.0 + frandom(10.0));
		}
	}

	wb_Data[workbenchid][wb_items][idx] = itemid;

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(wb_CurrentWorkbench[playerid] != -1)
	{
		if(oldkeys & 16)
		{
			StopHoldAction(playerid);
			wb_CurrentWorkbench[playerid] = -1;
		}
	}

	return 1;
}

public OnHoldActionFinish(playerid)
{
	if(wb_CurrentWorkbench[playerid] != -1)
	{
		Msg(playerid, YELLOW, "Feature not finished yet");
		wb_CurrentWorkbench[playerid] = -1;
	}

	return CallLocalFunction("wb_OnHoldActionFinish", "d", playerid);
}

#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish wb_OnHoldActionFinish
forward wb_OnHoldActionFinish(playerid);

CMD:wbtest(playerid, params[])
{
	Internal_OnPlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	Internal_OnPlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	Internal_OnPlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	Internal_OnPlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));

	return 1;
}
