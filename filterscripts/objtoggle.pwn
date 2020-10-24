/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <strlib>
#include <streamer>
#include <zcmd>

CMD:fly(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid, -1, "Admin only command");
		return 1;
	}

	if(strval(params))
	{
		Streamer_ToggleItemUpdate(playerid, STREAMER_TYPE_OBJECT, true);
		SendClientMessage(playerid, -1, "Object streaming toggled true");
	}
	else
	{
		Streamer_ToggleItemUpdate(playerid, STREAMER_TYPE_OBJECT, true);
		SendClientMessage(playerid, -1, "Object streaming toggled false");
	}

	return 1;
}

new badobjects[]=
{
	5422,
	5779,
	5856,
	6400,
	5340,
	13028,
	16500,
	7707,
	7891,
	5061,
	5056,
	5020,
	16773,
	17566,
	17951,
	10558,
	10150,
	18553,
	1508,
	1980,
	3294,
	16775,
	3352,
	3354,
	4084,
	5043,
	5302,
	7927,
	7930,
	7931,
	8378,
	8948,
	9093,
	9099,
	9625,
	9823,
	10149,
	10154,
	10182,
	10246,
	10575,
	10671,
	11102,
	11313,
	11319,
	11327,
	11416,
	13188,
	13187,
	13817,
	16501,
	16637
};

new idx;

CMD:os(playerid, params[])
{
	new
		upper = Streamer_GetUpperBound(STREAMER_TYPE_OBJECT),
		model;

	if(strval(params) != 0)
		idx = strval(params);

	SendClientMessage(playerid, -1, sprintf("Searching from IDX %d", idx));

	for(new i = idx; i <= upper; i++)
	{
		if(i == upper)
			idx = 0;

		if(!IsValidDynamicObject(i))
			continue;

		for(new k; k < sizeof(badobjects); k++)
		{
			model = Streamer_GetIntData(STREAMER_TYPE_OBJECT, i, E_STREAMER_MODEL_ID);

			if(model == badobjects[k])
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetDynamicObjectPos(i, x, y, z);
				SetPlayerPos(playerid, x, y, z);

				if(x > 0.0 && y > 0.0)
				{
					SendClientMessage(playerid, -1, sprintf("Object found: %d at %f, %f, %f", i, x, y, z));

					idx = i + 1;

					return 1;
				}
			}
		}
	}

	SendClientMessage(playerid, -1, "No object found");

	return 1;
}
