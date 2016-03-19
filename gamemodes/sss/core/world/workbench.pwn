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


#define MAX_WORK_BENCH			(32)
#define MAX_WORK_BENCH_ITEMS	(4)


enum E_WORKBENCH_DATA
{
			wb_objId,
			wb_buttonId,
Text3D:		wb_labelId,
Float:		wb_posX,
Float:		wb_posY,
Float:		wb_posZ,
Float:		wb_rotZ,
			wb_count
}


static
			wb_Data[MAX_WORK_BENCH][E_WORKBENCH_DATA],
			wb_SelectedItems[MAX_WORK_BENCH][CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data], // has to be of CFT_MAX_CRAFT_SET_ITEMS size
			wb_Total,
			wb_ButtonWorkbench[BTN_MAX] = {-1, ...},

bool:		wb_ConstructionSetWorkbench[MAX_CONSTRUCT_SET],

			wb_CurrentConstructSet[MAX_PLAYERS],
			wb_CurrentWorkbench[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	wb_CurrentWorkbench[playerid] = -1;
}


stock CreateWorkBench(Float:x, Float:y, Float:z, Float:rz)
{
	if(wb_Total == MAX_WORK_BENCH - 1)
	{
		print("ERROR: MAX_WORK_BENCH Limit reached.");
		return 0;
	}

	wb_Data[wb_Total][wb_objId] = CreateDynamicObject(936, x, y, z, 0.0, 0.0, rz);
	wb_Data[wb_Total][wb_buttonId] = CreateButton(x, y, z, "Press "KEYTEXT_INTERACT" to use workbench", .areasize = 2.0);
	wb_Data[wb_Total][wb_labelId] = CreateDynamic3DTextLabel("Workbench", GREEN, x, y, z + 1.0, 10.0);
	wb_Data[wb_Total][wb_posX] = x;
	wb_Data[wb_Total][wb_posY] = y;
	wb_Data[wb_Total][wb_posZ] = z;
	wb_Data[wb_Total][wb_rotZ] = rz;

	for(new i; i < MAX_WORK_BENCH_ITEMS; i++)
	{
		wb_SelectedItems[wb_Total][i][cft_selectedItemType] = INVALID_ITEM_TYPE;
		wb_SelectedItems[wb_Total][i][cft_selectedItemID] = INVALID_ITEM_ID;
	}

	wb_Data[wb_Total][wb_count] = 0;

	wb_ButtonWorkbench[wb_Data[wb_Total][wb_buttonId]] = wb_Total;

	return wb_Total++;
}

stock SetConstructionSetWorkbench(consset)
{
	if(!IsValidConstructionSet(consset))
	{
		printf("ERROR: Tried to assign workbench properties to invalid construction set ID.");
		return 0;
	}

	wb_ConstructionSetWorkbench[consset] = true;

	return consset;
}

public OnButtonPress(playerid, buttonid)
{
	if(wb_ButtonWorkbench[buttonid] != -1)
	{
		if(wb_Data[wb_ButtonWorkbench[buttonid]][wb_buttonId] == buttonid)
		{
			new itemid = GetPlayerItem(playerid);

			if(IsValidItem(itemid))
			{
				_wb_PlayerUseWorkbench(playerid, wb_ButtonWorkbench[buttonid], itemid);
			}
		}
		else
		{
			printf("ERROR: Workbench bi-directional link error. wb_ButtonWorkbench wb_buttonId = %d buttonid = %d");
		}
	}

	#if defined wb_OnButtonPress
		return wb_OnButtonPress(playerid, buttonid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress wb_OnButtonPress
#if defined wb_OnButtonPress
	forward wb_OnButtonPress(playerid, buttonid);
#endif

_wb_PlayerUseWorkbench(playerid, workbenchid, itemid)
{
	if(wb_Data[workbenchid][wb_count] > 1)
	{
		new
			craftset,
			consset;

		craftset = _cft_FindCraftset(wb_SelectedItems[workbenchid], wb_Data[workbenchid][wb_count]);
		consset = GetCraftSetConstructSet(craftset);

		if(GetCraftSetResult(craftset) == GetConstructionSetTool(consset))
		{
			StartHoldAction(playerid, GetConstructionSetBuildTime(consset));
			wb_CurrentWorkbench[playerid] = workbenchid;
			wb_CurrentConstructSet[playerid] = consset;
			return 1;
		}
	}

	_wb_AddItem(workbenchid, itemid);

	return 0;
}

_wb_AddItem(workbenchid, itemid)
{
	// todo: validate items and wb_Data[workbenchid][wb_count]

	if(wb_Data[workbenchid][wb_count] == MAX_WORK_BENCH_ITEMS)
	{
		return 0;
	}

	switch(wb_Data[workbenchid][wb_count])
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

	wb_SelectedItems[workbenchid][wb_Data[workbenchid][wb_count]][cft_selectedItemType] = GetItemType(itemid);
	wb_SelectedItems[workbenchid][wb_Data[workbenchid][wb_count]][cft_selectedItemID] = itemid;

	wb_Data[workbenchid][wb_count]++;

	return 1;
}

_wb_ClearWorkbench(workbenchid)
{
	for(new i; i < wb_Data[workbenchid][wb_count]; i++)
	{
		DestroyItem(wb_SelectedItems[workbenchid][i][cft_selectedItemID]);
	}
}

_wb_CreateResult(workbenchid, craftset)
{
	CreateItem(GetCraftSetResult(craftset),
		wb_Data[workbenchid][wb_posX],
		wb_Data[workbenchid][wb_posY],
		wb_Data[workbenchid][wb_posZ] + 0.49,
		0.0, 0.0, wb_Data[workbenchid][wb_rotZ] - 95.0 + frandom(10.0));
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(RELEASED(16))
	{
		if(wb_CurrentWorkbench[playerid] != -1)
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
		_wb_ClearWorkbench(wb_CurrentWorkbench[playerid]);
		_wb_CreateResult(wb_CurrentWorkbench[playerid], wb_CurrentConstructSet[playerid]);
		wb_CurrentWorkbench[playerid] = -1;
	}

	#if defined wb_OnHoldActionFinish
		return wb_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish wb_OnHoldActionFinish
#if defined wb_OnHoldActionFinish
	forward wb_OnHoldActionFinish(playerid);
#endif


// Todo: hook OnPlayerPickedUpItem and remove from wb item index


ACMD:wbtest[3](playerid, params[])
{
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));

	return 1;
}
