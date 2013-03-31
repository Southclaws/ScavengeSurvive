#include <YSI\y_hooks>


new
	gCurrentLightFixVehicle[MAX_PLAYERS],
	gLightData[MAX_PLAYERS][4];


ShowLightList(playerid, vehicleid)
{
	new
		panels,
		doors,
		lights,
		tires,
		str[22 * 4];

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	if(GetVehicleType(GetVehicleModel(vehicleid)) == VTYPE_BIKE)
	{
		gLightData[playerid][0] = lights & 0b0001;
		gLightData[playerid][1] = lights & 0b0010;

		if(gLightData[playerid][0]) // back
			strcat(str, "{FF0000}Back\n");

		else
			strcat(str, "{FFFFFF}Back\n");


		if(gLightData[playerid][1]) // front
			strcat(str, "{FF0000}Front\n");

		else
			strcat(str, "{FFFFFF}Front\n");
	}
	else
	{
		gLightData[playerid][0] = lights & 0b1000;
		gLightData[playerid][1] = lights & 0b0100;
		gLightData[playerid][2] = lights & 0b0010;
		gLightData[playerid][3] = lights & 0b0001;

		if(gLightData[playerid][0]) // backright
			strcat(str, "{FF0000}Back Right\n");

		else
			strcat(str, "{FFFFFF}Back Right\n");


		if(gLightData[playerid][1]) // frontright
			strcat(str, "{FF0000}Front Right\n");

		else
			strcat(str, "{FFFFFF}Front Right\n");


		if(gLightData[playerid][2]) // backleft
			strcat(str, "{FF0000}Back Left\n");

		else
			strcat(str, "{FFFFFF}Back Left\n");


		if(gLightData[playerid][3]) // frontleft
			strcat(str, "{FF0000}Front Left\n");

		else
			strcat(str, "{FFFFFF}Front Left\n");

	}
	gCurrentLightFixVehicle[playerid] = vehicleid;

	ShowPlayerDialog(playerid, d_Lights, DIALOG_STYLE_LIST, "Lights", str, "Fix", "Cancel");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Lights && response)
	{
		new
			panels,
			doors,
			lights,
			tires,
			itemid;

		GetVehicleDamageStatus(gCurrentLightFixVehicle[playerid], panels, doors, lights, tires);
		itemid = GetPlayerItem(playerid);

		if(listitem == 0)
		{
			if(gLightData[playerid][0] && GetItemType(itemid) == item_Headlight)
			{
				UpdateVehicleDamageStatus(gCurrentLightFixVehicle[playerid], panels, doors, lights & 0b0111, tires);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentLightFixVehicle[playerid]);
		}
		if(listitem == 1)
		{
			if(gLightData[playerid][1] && GetItemType(itemid) == item_Headlight)
			{
				UpdateVehicleDamageStatus(gCurrentLightFixVehicle[playerid], panels, doors, lights & 0b1011, tires);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentLightFixVehicle[playerid]);
		}
		if(listitem == 2)
		{
			if(gLightData[playerid][2] && GetItemType(itemid) == item_Headlight)
			{
				UpdateVehicleDamageStatus(gCurrentLightFixVehicle[playerid], panels, doors, lights & 0b1101, tires);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentLightFixVehicle[playerid]);
		}
		if(listitem == 3)
		{
			if(gLightData[playerid][3] && GetItemType(itemid) == item_Headlight)
			{
				UpdateVehicleDamageStatus(gCurrentLightFixVehicle[playerid], panels, doors, lights & 0b1110, tires);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentLightFixVehicle[playerid]);
		}
	}
}

