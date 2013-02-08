

new
	ItemType:item_Wheel = INVALID_ITEM_TYPE,
	gCurrentWheelFixVehicle[MAX_PLAYERS],
	gTireData[MAX_PLAYERS][4];


ShowTireList(playerid, vehicleid)
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
		gTireData[playerid][0] = tires & 0b0001;
		gTireData[playerid][1] = tires & 0b0010;

		if(gTireData[playerid][0]) // back
			strcat(str, "{FF0000}Back\n");

		else
			strcat(str, "{FFFFFF}Back\n");


		if(gTireData[playerid][1]) // front
			strcat(str, "{FF0000}Front\n");

		else
			strcat(str, "{FFFFFF}Front\n");
	}
	else
	{
		gTireData[playerid][0] = tires & 0b0001;
		gTireData[playerid][1] = tires & 0b0010;
		gTireData[playerid][2] = tires & 0b0100;
		gTireData[playerid][3] = tires & 0b1000;

		if(gTireData[playerid][0]) // backright
			strcat(str, "{FF0000}Back Right\n");

		else
			strcat(str, "{FFFFFF}Back Right\n");


		if(gTireData[playerid][1]) // frontright
			strcat(str, "{FF0000}Front Right\n");

		else
			strcat(str, "{FFFFFF}Front Right\n");


		if(gTireData[playerid][2]) // backleft
			strcat(str, "{FF0000}Back Left\n");

		else
			strcat(str, "{FFFFFF}Back Left\n");


		if(gTireData[playerid][3]) // frontleft
			strcat(str, "{FF0000}Front Left\n");

		else
			strcat(str, "{FFFFFF}Front Left\n");

	}
	gCurrentWheelFixVehicle[playerid] = vehicleid;

	ShowPlayerDialog(playerid, d_Tires, DIALOG_STYLE_LIST, "Tires", str, "Fix", "Cancel");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Tires && response)
	{
		new
			panels,
			doors,
			lights,
			tires,
			itemid;

		GetVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires);
		itemid = GetPlayerItem(playerid);

		if(listitem == 0)
		{
			if(gTireData[playerid][0] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b1110);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 1)
		{
			if(gTireData[playerid][1] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b1101);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 2)
		{
			if(gTireData[playerid][2] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b1011);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 3)
		{
			if(gTireData[playerid][3] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b0111);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
	}
}

