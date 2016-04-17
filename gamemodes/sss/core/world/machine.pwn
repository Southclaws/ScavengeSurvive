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


#define INVALID_MACHINE_ID	(-1)
#define MAX_MACHINE			(128)
#define MAX_MACHINE_NAME	(32)


enum E_MACHINE_DATA
{
			mach_objId,
			mach_buttonId,
			mach_containerId,
			mach_name[MAX_MACHINE_NAME],
			mach_size,
Float:		mach_posX,
Float:		mach_posY,
Float:		mach_posZ,
Float:		mach_rotZ
}


static
			mach_Data[MAX_MACHINE][E_MACHINE_DATA],
			mach_Total,
			mach_ButtonMachine[BTN_MAX] = {INVALID_MACHINE_ID, ...},
			mach_ContainerMachine[CNT_MAX] = {INVALID_MACHINE_ID, ...},
			mach_CurrentMachine[MAX_PLAYERS],
			mach_MachineInteractTick[MAX_PLAYERS],
Timer:		mach_HoldTimer[MAX_PLAYERS];


forward OnPlayerUseMachine(playerid, machineid, interactiontype);

static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	HANDLER = debug_register_handler("machine");
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/world/machine.pwn");

	mach_CurrentMachine[playerid] = INVALID_MACHINE_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateMachine(modelid, Float:x, Float:y, Float:z, Float:rz, name[], label[], size)
{
	if(mach_Total == MAX_MACHINE - 1)
	{
		print("ERROR: MAX_MACHINE Limit reached.");
		return 0;
	}

	mach_Data[mach_Total][mach_objId] = CreateDynamicObject(modelid, x, y, z, 0.0, 0.0, rz);
	mach_Data[mach_Total][mach_buttonId] = CreateButton(x, y, z + 0.5, label, .label = true, .areasize = 2.0);
	mach_Data[mach_Total][mach_containerId] = CreateContainer(name, size);
	strcat(mach_Data[mach_Total][mach_name], name, MAX_MACHINE_NAME);
	mach_Data[mach_Total][mach_size] = size;
	mach_Data[mach_Total][mach_posX] = x;
	mach_Data[mach_Total][mach_posY] = y;
	mach_Data[mach_Total][mach_posZ] = z;
	mach_Data[mach_Total][mach_rotZ] = rz;

	mach_ButtonMachine[mach_Data[mach_Total][mach_buttonId]] = mach_Total;
	mach_ContainerMachine[mach_Data[mach_Total][mach_containerId]] = mach_Total;

	return mach_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnButtonPress(playerid, buttonid)
{
	d:3:GLOBAL_DEBUG("[OnButtonPress] in /gamemodes/sss/core/world/machine.pwn");

	if(mach_ButtonMachine[buttonid] != INVALID_MACHINE_ID)
	{
		d:1:HANDLER("[OnButtonPress] button %d machine %d", buttonid, mach_ButtonMachine[buttonid]);
		if(mach_Data[mach_ButtonMachine[buttonid]][mach_buttonId] == buttonid)
		{
			_mach_PlayerUseMachine(playerid, mach_ButtonMachine[buttonid]);
		}
		else
		{
			printf("ERROR: Machine bi-directional link error. mach_ButtonMachine mach_buttonId = %d buttonid = %d");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_mach_PlayerUseMachine(playerid, machineid)
{
	d:1:HANDLER("[_mach_PlayerUseMachine] playerid %d machineid %d", playerid, machineid);

	mach_CurrentMachine[playerid] = machineid;
	mach_MachineInteractTick[playerid] = GetTickCount();

	mach_HoldTimer[playerid] = defer _mach_HoldInteract(playerid);

	return 0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/world/machine.pwn");

	if(RELEASED(16))
	{
		if(mach_CurrentMachine[playerid] != INVALID_MACHINE_ID)
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
	if(mach_CurrentMachine[playerid] == INVALID_MACHINE_ID)
		return;

	CallLocalFunction("OnPlayerUseMachine", "ddd", playerid, mach_CurrentMachine[playerid], 0);

	mach_CurrentMachine[playerid] = INVALID_MACHINE_ID;
}

timer _mach_HoldInteract[250](playerid)
{
	if(mach_CurrentMachine[playerid] == INVALID_MACHINE_ID)
		return;

	CallLocalFunction("OnPlayerUseMachine", "ddd", playerid, mach_CurrentMachine[playerid], 1);

	mach_CurrentMachine[playerid] = INVALID_MACHINE_ID;
}


/*==============================================================================

	Interface Functions

==============================================================================*/


// mach_Total
stock IsValidMachine(machineid)
{
	if(!(0 <= machineid < mach_Total))
		return 0;

	return 1;
}

// mach_ButtonMachine
stock GetButtonMachineID(buttonid)
{
	if(!IsValidButton(buttonid))
		return INVALID_MACHINE_ID;

	return mach_ButtonMachine[buttonid];
}

// mach_ContainerMachine
stock GetContainerMachineID(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_MACHINE_ID;

	return mach_ContainerMachine[containerid];
}

// mach_CurrentMachine
stock GetMachineCurrentMachine(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_MACHINE_ID;

	return mach_CurrentMachine[playerid];
}


// mach_objId
stock GetMachineObjectID(machineid)
{
	if(!(0 <= machineid < mach_Total))
		return 0;

	return mach_Data[machineid][mach_objId];
}

// mach_buttonId
stock GetMachineButtonID(machineid)
{
	if(!(0 <= machineid < mach_Total))
		return 0;

	return mach_Data[machineid][mach_buttonId];
}

// mach_containerId
stock GetMachineContainerID(machineid)
{
	if(!(0 <= machineid < mach_Total))
		return 0;

	return mach_Data[machineid][mach_containerId];
}

// mach_name
stock GetMachineName(machineid, name[])
{
	if(!(0 <= machineid < mach_Total))
		return 0;

	name[0] = EOS;
	strcat(name, mach_Data[machineid][mach_name], MAX_MACHINE_NAME);

	return 1;
}

// mach_size
stock GetMachineSize(machineid)
{
	if(!(0 <= machineid < mach_Total))
		return 0;

	return mach_Data[machineid][mach_size];
}

// mach_posX
// mach_posY
// mach_posZ
stock GetMachinePos(machineid, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= machineid < mach_Total))
		return 0;

	x = mach_Data[machineid][mach_posX];
	y = mach_Data[machineid][mach_posY];
	z = mach_Data[machineid][mach_posZ];

	return 1;
}

// mach_rotZ
stock Float:GetMachineRotZ(machineid)
{
	if(!(0 <= machineid < mach_Total))
		return FLOAT_INFINITY;

	return mach_Data[machineid][mach_rotZ];
}
