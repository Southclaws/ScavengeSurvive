/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <ZCMD>


#define MAX_SHOT 1000


new
	shotTick[MAX_PLAYERS][MAX_SHOT],
	shotFirst[MAX_PLAYERS],
	shotInt[MAX_PLAYERS],
	shotWep[MAX_PLAYERS];


public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(shotFirst[playerid] == 0)
		shotFirst[playerid] = GetTickCount();

	shotTick[playerid][shotInt[playerid]] = GetTickCount();

    shotInt[playerid]++;
    
	shotWep[playerid] = weaponid;
}

CMD:results(playerid, params[])
{
	new
		tmpStr[128],
		str[2048],
		aveStr[64],
		intAve,
		Float:AverageRoFPerMS,
		tmpInt;

    for(new x = 1; x < shotInt[playerid]; x++)
    {
        tmpInt = shotTick[playerid][x] - shotTick[playerid][x-1];

        format(tmpStr, 128, "{FFFF00}INT: %02d\n", tmpInt);
        strcat(str, tmpStr);
        intAve+=tmpInt;
    }

    AverageRoFPerMS = floatdiv(intAve, shotInt[playerid]-1);
    format(aveStr, 64, "\n\nAverage: %f\nRate Of Fire: %f", AverageRoFPerMS, ((1000/AverageRoFPerMS)*60) );
    strcat(str, aveStr);

    ShowPlayerDialog(playerid, 1337, DIALOG_STYLE_MSGBOX, "Weapon Test Results", str, "close", "");


	new
		File:rFile = fopen("rofdata.txt", io_append),
		line[32];

	format(line, 32, ",\t%f},\t\t// %d\r\n", ((1000/AverageRoFPerMS)*60), shotWep[playerid]);
	fwrite(rFile, line);
	fclose(rFile);

	SendClientMessage(playerid, 0xFFFF00FF, "Saved to file!");
	SendClientMessage(playerid, -1, line);

	return 1;
}

CMD:resetdata(playerid, params[])
{
    shotInt[playerid] = 0;
    shotFirst[playerid] = 0;

	return 1;
}
