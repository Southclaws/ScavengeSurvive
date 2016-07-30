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


/*==============================================================================

	Setup

==============================================================================*/


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
			wb_count,
bool:		wb_inUse
}


static
			wb_Data[MAX_WORK_BENCH][E_WORKBENCH_DATA],
			wb_SelectedItems[MAX_WORK_BENCH][CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data], // has to be of CFT_MAX_CRAFT_SET_ITEMS size
			wb_Total,
			wb_ButtonWorkbench[BTN_MAX] = {-1, ...},
			wb_ItemWorkbench[ITM_MAX] = {-1, ...},

bool:		wb_ConstructionSetWorkbench[MAX_CONSTRUCT_SET],

			wb_CurrentConstructSet[MAX_PLAYERS],
			wb_CurrentWorkbench[MAX_PLAYERS];


static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	HANDLER = debug_register_handler("workbench");
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/world/workbench.pwn");

	wb_CurrentWorkbench[playerid] = -1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(wb_CurrentWorkbench[playerid] != -1)
		_wb_StopWorking(playerid);
}


/*==============================================================================

	Core Functions

==============================================================================*/


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
	wb_Data[wb_Total][wb_inUse] = false;

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


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnButtonPress(playerid, buttonid)
{
	d:3:GLOBAL_DEBUG("[OnButtonPress] in /gamemodes/sss/core/world/workbench.pwn");

	if(wb_ButtonWorkbench[buttonid] != -1)
	{
		d:1:HANDLER("[OnButtonPress] button %d workbench %d", buttonid, wb_ButtonWorkbench[buttonid]);
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

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wb_PlayerUseWorkbench(playerid, workbenchid, itemid)
{
	d:1:HANDLER("[_wb_PlayerUseWorkbench] playerid %d workbenchid %d itemid %d", playerid, workbenchid, itemid);
	if(wb_Data[workbenchid][wb_count] > 1)
	{
		d:2:HANDLER("[_wb_PlayerUseWorkbench] wb_count: %d", wb_Data[workbenchid][wb_count]);
		new
			craftset,
			consset;

		craftset = _cft_FindCraftset(wb_SelectedItems[workbenchid], wb_Data[workbenchid][wb_count]);
		consset = GetCraftSetConstructSet(craftset);

		d:2:HANDLER("[_wb_PlayerUseWorkbench] craftset: %d, consset: %d consset tool type: %d player item type: %d", craftset, consset, _:GetConstructionSetTool(consset), _:GetItemType(itemid));

		if(GetItemType(itemid) == GetConstructionSetTool(consset))
		{
			d:2:HANDLER("[_wb_PlayerUseWorkbench] craftset determined and tool matched, start building...");
	
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(playerid, x, y, z);
			SetPlayerFacingAngle(playerid, GetAngleToPoint(x, y, wb_Data[workbenchid][wb_posX],  wb_Data[workbenchid][wb_posY]));

			ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);

			wb_CurrentConstructSet[playerid] = consset;
			_wb_StartWorking(playerid, workbenchid, GetConstructionSetBuildTime(consset));
			return 1;
		}
	}

	_wb_AddItem(workbenchid, itemid);

	return 0;
}

_wb_StartWorking(playerid, workbenchid, buildtime)
{
	wb_Data[workbenchid][wb_inUse] = true;
	StartHoldAction(playerid, buildtime);
	wb_CurrentWorkbench[playerid] = workbenchid;
}

_wb_StopWorking(playerid)
{
	ClearAnimations(playerid);

	StopHoldAction(playerid);
	wb_Data[wb_CurrentWorkbench[playerid]][wb_inUse] = false;
	wb_CurrentWorkbench[playerid] = -1;
}

_wb_AddItem(workbenchid, itemid)
{
	d:1:HANDLER("[_wb_AddItem] workbenchid %d itemid %d, wb_count: %d", workbenchid, itemid, wb_Data[workbenchid][wb_count]);

	// workbench is full
	if(wb_Data[workbenchid][wb_count] == MAX_WORK_BENCH_ITEMS)
		return 0;

	new idx;

	// search for free slot to place item
	for(idx = 0; idx < MAX_WORK_BENCH_ITEMS; idx++)
	{
		if(!IsValidItem(wb_SelectedItems[workbenchid][idx][cft_selectedItemID]))
			break;
	}

	// is workbench full (again?)
	if(idx == MAX_WORK_BENCH_ITEMS)
	{
		printf("ERROR: Workbench full check failed after wb_count check passed (wb_count = %d)", wb_Data[workbenchid][wb_count]);
		return 0;
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

	wb_SelectedItems[workbenchid][idx][cft_selectedItemType] = GetItemType(itemid);
	wb_SelectedItems[workbenchid][idx][cft_selectedItemID] = itemid;
	wb_ItemWorkbench[itemid] = workbenchid;

	wb_Data[workbenchid][wb_count]++;

	return 1;
}

_wb_RemoveItem(workbenchid, itemid)
{
	d:1:HANDLER("[_wb_RemoveItem] workbenchid %d itemid %d, wb_count: %d", workbenchid, itemid, wb_Data[workbenchid][wb_count]);

	if(wb_Data[workbenchid][wb_inUse])
	{
		d:2:HANDLER("[_wb_RemoveItem] Workbench in-use, cancelling remove");
		return 0;
	}

	new idx;

	while(wb_SelectedItems[workbenchid][idx][cft_selectedItemID] != itemid)
	{
		if(idx++ == wb_Data[workbenchid][wb_count])
			return 1;
	}

	wb_SelectedItems[workbenchid][idx][cft_selectedItemType] = INVALID_ITEM_TYPE;
	wb_SelectedItems[workbenchid][idx][cft_selectedItemID] = INVALID_ITEM_ID;
	wb_ItemWorkbench[itemid] = -1;

	wb_Data[workbenchid][wb_count]--;

	return 1;
}

_wb_ClearWorkbench(workbenchid)
{
	d:1:HANDLER("[_wb_ClearWorkbench] workbenchid %d, count: %d", workbenchid, wb_Data[workbenchid][wb_count]);

	for(new i; i < wb_Data[workbenchid][wb_count]; i++)
	{
		DestroyItem(wb_SelectedItems[workbenchid][i][cft_selectedItemID]);
		wb_ItemWorkbench[wb_SelectedItems[workbenchid][i][cft_selectedItemID]] = -1;
		wb_SelectedItems[workbenchid][i][cft_selectedItemType] = INVALID_ITEM_TYPE;
		wb_SelectedItems[workbenchid][i][cft_selectedItemID] = INVALID_ITEM_ID;
	}

	wb_Data[workbenchid][wb_count] = 0;
}

_wb_CreateResult(workbenchid, craftset)
{
	d:1:HANDLER("[_wb_CreateResult] workbenchid %d craftset %d", workbenchid, craftset);

	CreateItem(GetCraftSetResult(craftset),
		wb_Data[workbenchid][wb_posX],
		wb_Data[workbenchid][wb_posY],
		wb_Data[workbenchid][wb_posZ] + 0.49,
		0.0, 0.0, wb_Data[workbenchid][wb_rotZ] - 95.0 + frandom(10.0));
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/world/workbench.pwn");

	if(RELEASED(16))
	{
		if(wb_CurrentWorkbench[playerid] != -1)
		{
			d:1:HANDLER("[OnPlayerKeyStateChange] stopping workbench build");
			_wb_StopWorking(playerid);
		}
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/world/workbench.pwn");

	if(wb_CurrentWorkbench[playerid] != -1)
	{
		d:1:HANDLER("[OnHoldActionFinish] workbench build complete, workbenchid: %d, construction set: %d", wb_CurrentWorkbench[playerid], wb_CurrentConstructSet[playerid]);

		_wb_ClearWorkbench(wb_CurrentWorkbench[playerid]);
		_wb_CreateResult(wb_CurrentWorkbench[playerid], GetConstructionSetCraftSet(wb_CurrentConstructSet[playerid]));
		_wb_StopWorking(playerid);
		wb_CurrentWorkbench[playerid] = -1;
		wb_CurrentConstructSet[playerid] = -1;
	}
}

hook OnPlayerPickedUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickedUpItem] in /gamemodes/sss/core/world/workbench.pwn");

	if(wb_ItemWorkbench[itemid] != -1)
	{
		if(_wb_RemoveItem(wb_ItemWorkbench[itemid], itemid) == 0)
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerConstruct(playerid, consset)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConstruct] in /gamemodes/sss/core/world/workbench.pwn");

	if(!IsValidConstructionSet(consset))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(wb_ConstructionSetWorkbench[consset] == true)
	{
		d:2:HANDLER("[OnPlayerConstruct] playerid %d consset %d attempted construction of workbench consset", playerid, consset);
		ShowActionText(playerid, ls(playerid, "NEEDWORKBE", true), 5000);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


ACMD:wbtest[3](playerid, params[])
{
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));
	_wb_PlayerUseWorkbench(playerid, 0, CreateItem(item_Battery));

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


//
