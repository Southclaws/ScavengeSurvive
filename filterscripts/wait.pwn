/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define FILTERSCRIPT



#include <a_samp>
#include <ZCMD>


CMD:wait(playerid, params[])
{
	new seconds = strval(params);

	wait(seconds * 1000);
}


stock wait(time)
{
	new stamp = tickcount();
	while (tickcount() - stamp < time)
	{
	}
	return 1;
}

