/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>


static
Text:	TickCheck,
bool:	UpdateState;


forward Update();


public OnFilterScriptInit()
{
	TickCheck = TextDrawCreate(320.0, 340.0, "200");
	TextDrawAlignment		(TickCheck, 2);
	TextDrawBackgroundColor	(TickCheck, 0);
	TextDrawFont			(TickCheck, 1);
	TextDrawLetterSize		(TickCheck, 0.210000, 1.000000);
	TextDrawColor			(TickCheck, -1);
	TextDrawSetProportional	(TickCheck, 1);
	TextDrawUseBox			(TickCheck, 1);
	TextDrawBoxColor		(TickCheck, 255);
	TextDrawTextSize		(TickCheck, 340.000000, 20.000000);

	TextDrawDestroy(TickCheck-1);

	SetTimer("Update", 1000, true);
}

public OnFilterScriptExit()
{
	TextDrawDestroy(TickCheck);
}

public Update()
{
	new
		str[12],
		tick;

	tick = GetServerTickRate();

	format(str, sizeof(str), "%d", tick);
	TextDrawSetString(TickCheck, str);

	TextDrawColor(TickCheck, UpdateState ? (tick < 150 ? 0xFF0000FF : 0x000000FF) : (0xFFFFFFFF));
	TextDrawBoxColor(TickCheck, UpdateState ? (0xFFFFFFFF) : (tick < 150 ? 0xFF0000FF : 0x000000FF));
	TextDrawShowForAll(TickCheck);

	UpdateState = !UpdateState;
}
