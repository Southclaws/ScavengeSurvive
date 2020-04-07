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


static
			trunk_ContainerVehicle	[CNT_MAX] = {INVALID_VEHICLE_ID, ...},
			trunk_ContainerID		[MAX_VEHICLES] = {INVALID_CONTAINER_ID, ...},
			trunk_Locked			[MAX_VEHICLES],
			trunk_CurrentVehicle	[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};


/*==============================================================================

	Internal

==============================================================================*/


hook OnVehicleCreated(vehicleid)
{
	dbg("global", CORE, "[OnVehicleCreated] in /gamemodes/sss/core/vehicle/trunk.pwn");

	new
		vehicletype,
		trunksize;

	vehicletype = GetVehicleType(vehicleid);
	trunksize = GetVehicleTypeTrunkSize(vehicletype);

	if(trunksize > 0)
	{
		new vehicletypename[MAX_VEHICLE_TYPE_NAME];
		GetVehicleTypeName(vehicletype, vehicletypename);
		trunk_ContainerID[vehicleid] = CreateContainer(sprintf("%s trunk", vehicletypename), trunksize);
		trunk_ContainerVehicle[trunk_ContainerID[vehicleid]] = vehicleid;
		trunk_Locked[vehicleid] = false;
	}
}

hook OnVehicleReset(oldid, newid)
{
	dbg("global", CORE, "[OnVehicleReset] in /gamemodes/sss/core/vehicle/trunk.pwn");

	if(oldid != newid)
	{
		trunk_ContainerID[newid] = trunk_ContainerID[oldid];
		trunk_Locked[newid] = trunk_Locked[oldid];
		trunk_ContainerVehicle[trunk_ContainerID[oldid]] = INVALID_VEHICLE_ID;
		trunk_ContainerVehicle[trunk_ContainerID[newid]] = newid;
	}
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	dbg("global", CORE, "[OnPlayerInteractVehicle] in /gamemodes/sss/core/vehicle/trunk.pwn");

	if(155.0 < angle < 205.0)
	{
		if(IsValidContainer(GetVehicleContainer(vehicleid)))
		{
			if(IsVehicleTrunkLocked(vehicleid))
			{
				ShowActionText(playerid, ls(playerid, "TRUNKLOCKED", true), 3000);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			if(GetVehicleLockState(vehicleid) == E_LOCK_STATE_EXTERNAL)
			{
				ShowActionText(playerid, ls(playerid, "TRUNKLOCKED", true), 3000);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			new Float:vehicleangle;

			GetVehicleZAngle(vehicleid, vehicleangle);

			VehicleBootState(vehicleid, 1);
			CancelPlayerMovement(playerid);
			SetPlayerFacingAngle(playerid, (vehicleangle-angle)-180.0);

			DisplayContainerInventory(playerid, GetVehicleContainer(vehicleid));
			trunk_CurrentVehicle[playerid] = vehicleid;

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerCloseContainer] in /gamemodes/sss/core/vehicle/trunk.pwn");

	if(IsValidVehicle(trunk_CurrentVehicle[playerid]))
	{
		if(containerid == GetVehicleContainer(trunk_CurrentVehicle[playerid]))
		{
			VehicleBootState(trunk_CurrentVehicle[playerid], 0);

			trunk_CurrentVehicle[playerid] = INVALID_VEHICLE_ID;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/vehicle/trunk.pwn");

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(containerid, itemid, playerid)
{
	dbg("global", CORE, "[OnItemAddedToContainer] in /gamemodes/sss/core/vehicle/trunk.pwn");

	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(containerid, slotid, playerid)
{
	dbg("global", CORE, "[OnItemRemovedFromCnt] in /gamemodes/sss/core/vehicle/trunk.pwn");

	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

VehicleTrunkUpdateSave(playerid)
{
	if(IsValidVehicle(trunk_CurrentVehicle[playerid]))
	{
		new owner[MAX_PLAYER_NAME];

		GetVehicleOwner(trunk_CurrentVehicle[playerid], owner);

		if(!isnull(owner))
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			if(!strcmp(owner, name))
			{
				new
					Float:x,
					Float:y,
					Float:z,
					Float:r;

				SaveVehicle(trunk_CurrentVehicle[playerid]);
				GetVehiclePos(trunk_CurrentVehicle[playerid], x, y, z);
				GetVehicleZAngle(trunk_CurrentVehicle[playerid], r);
				SetVehicleSpawnPoint(trunk_CurrentVehicle[playerid], x, y, z, r);
			}
		}
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetVehicleContainer(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return INVALID_CONTAINER_ID;

	return trunk_ContainerID[vehicleid];
}

stock GetContainerTrunkVehicleID(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_VEHICLE_ID;

	return trunk_ContainerVehicle[containerid];
}

stock IsVehicleTrunkLocked(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return trunk_Locked[vehicleid];
}

stock SetVehicleTrunkLock(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	trunk_Locked[vehicleid] = toggle;
	return 1;
}

