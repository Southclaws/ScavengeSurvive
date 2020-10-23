/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaws" Keene

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
