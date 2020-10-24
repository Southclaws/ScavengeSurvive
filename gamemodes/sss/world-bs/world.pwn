/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include "sss/world-bs/spawn.pwn"
#include "sss/world-bs/tr.pwn"

static
	MapName[32] = "Bayside DM";

stock GetMapName()
{
	return MapName;
}
