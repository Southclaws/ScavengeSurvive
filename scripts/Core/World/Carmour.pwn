#include <YSI\y_hooks>


#define ARMOUR_DATA_FOLDER	"vehicles/Mods/"
#define ARMOUR_DATA_DIR		"./scriptfiles/vehicles/Mods/"
#define MAX_ARMOUR			(16)
#define MAX_ARMOUR_PARTS	(32)
#define MAX_ARMOUR_VEHICLES	(8)


enum E_ARMOUR_DATA
{
			arm_vehicle,
			arm_name[32],
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
			arm_Data[MAX_ARMOUR][E_ARMOUR_DATA],
			arm_List[MAX_ARMOUR][MAX_ARMOUR_PARTS][E_ARMOUR_LIST_DATA],
Iterator:	arm_Index<MAX_ARMOUR>;

new
			arm_ArmourID[MAX_SPAWNED_VEHICLES];

hook OnGameModeInit()
{
	new
		dir:direc = dir_open(ARMOUR_DATA_DIR),
		item[46],
		type;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			LoadOffsetsFromFile(item);
		}
	}

	dir_close(direc);
}

LoadOffsetsFromFile(name[])
{
	new
		id = Iter_Free(arm_Index),
		File:file,
		filedir[64],
		line[128],
		model,
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		listindex;

	filedir = ARMOUR_DATA_FOLDER;
	strcat(filedir, name);

	if(!fexist(filedir))
		return 0;

	file = fopen(filedir, io_read);
	fread(file, line);
	arm_Data[id][arm_vehicle] = strval(line);

	if(!(400 <= arm_Data[id][arm_vehicle] <= 612))
		return 0;

	while(fread(file, line))
	{
		if(!sscanf(line, "p<(>{s[20]}p<,>dfffffp<)>f{s[4]}", model, x, y, z, rx, ry, rz))
		{
			arm_List[id][listindex][arm_model] = model;
			arm_List[id][listindex][arm_posX] = x;
			arm_List[id][listindex][arm_posY] = y;
			arm_List[id][listindex][arm_posZ] = z;
			arm_List[id][listindex][arm_rotX] = rx;
			arm_List[id][listindex][arm_rotY] = ry;
			arm_List[id][listindex][arm_rotZ] = rz;
		}
		listindex++;
	}
	fclose(file);

	arm_Data[id][arm_objCount] = listindex;

	Iter_Add(arm_Index, id);

	return 1;
}

ApplyArmourToVehicle(vehicleid, armourid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	new
		objectid,
		modelid = GetVehicleModel(vehicleid);

	if(modelid != arm_Data[armourid][arm_vehicle])
		return 0;

	for(new i; i < arm_Data[armourid][arm_objCount]; i++)
	{
		objectid = CreateDynamicObject(arm_List[armourid][i][arm_model], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

		AttachDynamicObjectToVehicle(objectid, vehicleid,
			arm_List[armourid][i][arm_posX], arm_List[armourid][i][arm_posY], arm_List[armourid][i][arm_posZ],
			arm_List[armourid][i][arm_rotX], arm_List[armourid][i][arm_rotY], arm_List[armourid][i][arm_rotZ]);
	}

	arm_ArmourID[vehicleid] = armourid;

	return 1;
}

ACMD:armour[4](playerid, params[])
{
	new
		vehicleid = GetPlayerVehicleID(playerid),
		id = strval(params),
		ret;

	ret = ApplyArmourToVehicle(vehicleid, id);

	MsgF(playerid, -1, "Ret: %d", ret);

	return 1;
}

ACMD:allcarmour[4](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		vehicleid;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	foreach(new i : arm_Index)
	{
		vehicleid = CreateVehicle(arm_Data[i][arm_vehicle],
			x + ((10 * i) * floatsin(-r, degrees)),
			y + ((10 * i) * floatcos(-r, degrees)),
			z, r + 90.0, -1, -1, -1);

		SetVehicleFuel(vehicleid, 10000.0);

		ApplyArmourToVehicle(vehicleid, i);
	}

	return 1;
}
