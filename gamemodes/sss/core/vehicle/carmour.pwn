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


#define DIRECTORY_CARMOUR	DIRECTORY_VEHICLESPAWNS"carmour/"
#define MAX_CARMOUR			(16)
#define MAX_CARMOUR_PARTS	(64)


enum E_ARMOUR_DATA
{
			arm_vehicleType,
			arm_objCount
}


enum E_ARMOUR_LIST_DATA
{
			arm_model,
Float:		arm_posX,
Float:		arm_posY,
Float:		arm_posZ,
Float:		arm_rotX,
Float:		arm_rotY,
Float:		arm_rotZ
}


new
			arm_Data[MAX_CARMOUR][E_ARMOUR_DATA],
			arm_Objects[MAX_CARMOUR][MAX_CARMOUR_PARTS][E_ARMOUR_LIST_DATA],
   Iterator:arm_Index<MAX_CARMOUR>,
			arm_VehicleTypeCarmour[MAX_VEHICLE_TYPE] = {-1, ...};


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Carmour'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_CARMOUR);
}


/*==============================================================================

	Core

==============================================================================*/


stock SetVehicleTypeCarmour(vehicletype, name[])
{
	new
		id,
		filename[64];

	format(filename, sizeof(filename), DIRECTORY_CARMOUR"%s.map", name);
	id = LoadOffsetsFromFile(filename);

	arm_Data[id][arm_vehicleType] = vehicletype;
	arm_VehicleTypeCarmour[vehicletype] = id;
}


/*==============================================================================

	Hooks and internal

==============================================================================*/


LoadOffsetsFromFile(filename[])
{
	new
		id = Iter_Free(arm_Index),
		File:file,
		line[128],
		model,
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		listindex;

	if(!fexist(filename))
	{
		printf("[LoadOffsetsFromFile] ERROR: File not found: '%s'", filename);
		return 0;
	}

	file = fopen(filename, io_read);

	while(fread(file, line))
	{
		if(!sscanf(line, "p<(>{s[20]}p<,>dfffffp<)>f{s[4]}", model, x, y, z, rx, ry, rz))
		{
			if(listindex >= MAX_CARMOUR_PARTS - 1)
			{
				printf("[LoadOffsetsFromFile] ERROR: Object limit reached while loading '%s'", filename);
				break;
			}

			arm_Objects[id][listindex][arm_model] = model;
			arm_Objects[id][listindex][arm_posX] = x;
			arm_Objects[id][listindex][arm_posY] = y;
			arm_Objects[id][listindex][arm_posZ] = z;
			arm_Objects[id][listindex][arm_rotX] = rx;
			arm_Objects[id][listindex][arm_rotY] = ry;
			arm_Objects[id][listindex][arm_rotZ] = rz;

			listindex++;
		}
	}

	fclose(file);

	arm_Data[id][arm_objCount] = listindex;

	Iter_Add(arm_Index, id);

	return id;
}

ApplyArmourToVehicle(vehicleid, armourid)
{
	if(!IsValidVehicle(vehicleid))
	{
		printf("[ApplyArmourToVehicle] ERROR: Invalid vehicle ID (%d) passed to function.", vehicleid);
		return 0;
	}

	new vehicletype = GetVehicleType(vehicleid);

	if(vehicletype != arm_Data[armourid][arm_vehicleType])
	{
		printf("[ApplyArmourToVehicle] ERROR: Vehicle type (%d) does not match carmour vehicle type (%d).", vehicletype, arm_Data[armourid][arm_vehicleType]);
		return 0;
	}

	new objectid;

	for(new i; i < arm_Data[armourid][arm_objCount]; i++)
	{
		objectid = CreateDynamicObject(arm_Objects[armourid][i][arm_model], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

		AttachDynamicObjectToVehicle(objectid, vehicleid,
			arm_Objects[armourid][i][arm_posX], arm_Objects[armourid][i][arm_posY], arm_Objects[armourid][i][arm_posZ],
			arm_Objects[armourid][i][arm_rotX], arm_Objects[armourid][i][arm_rotY], arm_Objects[armourid][i][arm_rotZ]);
	}

	return 1;
}

hook OnVehicleCreated(vehicleid)
{
	new vehicletype = GetVehicleType(vehicleid);

	if(arm_VehicleTypeCarmour[vehicletype] != -1)
		ApplyArmourToVehicle(vehicleid, arm_VehicleTypeCarmour[vehicletype]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}
