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


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_MACHINE_TYPE (4)


static
			mach_Total,
			mach_ItemTypeMachine[ITM_MAX_TYPES] = {-1, ...},

			mach_ContainerSize[MAX_MACHINE_TYPE] = {0, ...},
			mach_ContainerMachineItem[CNT_MAX] = {INVALID_ITEM_ID, ...},
			mach_CurrentMachine[MAX_PLAYERS],
			mach_MachineInteractTick[MAX_PLAYERS],
Timer:		mach_HoldTimer[MAX_PLAYERS];


forward OnPlayerUseMachine(playerid, itemid, interactiontype);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/world/machine.pwn");

	mach_CurrentMachine[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock DefineMachineType(ItemType:itemtype, arraydata, containersize)
{
	SetItemTypeMaxArrayData(itemtype, arraydata);

	mach_ItemTypeMachine[itemtype] = mach_Total;
	mach_ContainerSize[mach_Total] = containersize;

	return mach_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnItemCreate(itemid)
{
	new machinetype = mach_ItemTypeMachine[GetItemType(itemid)];

	if(machinetype == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new name[ITM_MAX_NAME];

	GetItemName(itemid, name);

	new containerid = CreateContainer(name, mach_ContainerSize[machinetype]);

	SetItemArrayDataAtCell(itemid, containerid, 0);
	mach_ContainerMachineItem[containerid] = itemid;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreateInWorld(itemid)
{
	if(mach_ItemTypeMachine[GetItemType(itemid)] == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	SetButtonText(GetItemButtonID(itemid), "Press "KEYTEXT_INTERACT" to access machine~n~Hold "KEYTEXT_INTERACT" to open menu~n~Use Petrol Can to add fuel");

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(mach_ItemTypeMachine[GetItemType(itemid)] != -1)
	{
		_mach_PlayerUseMachine(playerid, itemid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(mach_ItemTypeMachine[GetItemType(withitemid)] != -1)
	{
		_mach_PlayerUseMachine(playerid, withitemid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_mach_PlayerUseMachine(playerid, itemid)
{
	dbg("gamemodes/sss/core/world/machine.pwn", 1, "[_mach_PlayerUseMachine] playerid %d itemid %d", playerid, itemid);

	mach_CurrentMachine[playerid] = itemid;
	mach_MachineInteractTick[playerid] = GetTickCount();

	mach_HoldTimer[playerid] = defer _mach_HoldInteract(playerid);

	return 0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/world/machine.pwn");

	if(RELEASED(16))
	{
		if(mach_CurrentMachine[playerid] != INVALID_ITEM_ID)
		{
			if(GetTickCountDifference(GetTickCount(), mach_MachineInteractTick[playerid]) < 250)
			{
				stop mach_HoldTimer[playerid];
				_mach_TapInteract(playerid);
			}
		}
	}

	return 1;
}

_mach_TapInteract(playerid)
{
	if(mach_CurrentMachine[playerid] == INVALID_ITEM_ID)
		return;

	CallLocalFunction("OnPlayerUseMachine", "ddd", playerid, mach_CurrentMachine[playerid], 0);

	mach_CurrentMachine[playerid] = INVALID_ITEM_ID;
}

timer _mach_HoldInteract[250](playerid)
{
	if(mach_CurrentMachine[playerid] == INVALID_ITEM_ID)
		return;

	CallLocalFunction("OnPlayerUseMachine", "ddd", playerid, mach_CurrentMachine[playerid], 1);

	mach_CurrentMachine[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Interface Functions

==============================================================================*/


// mach_ItemTypeMachine
stock GetItemTypeMachineType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return mach_ItemTypeMachine[itemtype];
}

// mach_ContainerSize
stock GetMachineTypeContainerSize(machinetype)
{
	if(!(0 <= machinetype < mach_Total))
		return 0;

	return mach_ContainerSize[machinetype];
}

// mach_ContainerMachineItem
stock GetContainerMachineItem(containerid)
{
	if(!IsValidContainer(containerid))
		return -1;

	return mach_ContainerMachineItem[containerid];
}

// mach_CurrentMachine
stock GetPlayerCurrentMachine(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return mach_CurrentMachine[playerid];
}
