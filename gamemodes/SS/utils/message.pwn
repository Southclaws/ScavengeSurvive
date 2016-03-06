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


#include <YSI\y_va>

static stock gs_Buffer[256];

stock va_formatex(output[], size = sizeof(output), const fmat[], va_:STATIC_ARGS)
{
	new
		num_args,
		arg_start,
		arg_end;
	
	// Get the pointer to the number of arguments to the last function.
	#emit LOAD.S.pri 0
	#emit ADD.C 8
	#emit MOVE.alt
	// Get the number of arguments.
	#emit LOAD.I
	#emit STOR.S.pri num_args
	// Get the variable arguments (end).
	#emit ADD
	#emit STOR.S.pri arg_end
	// Get the variable arguments (start).
	#emit LOAD.S.pri STATIC_ARGS
	#emit SMUL.C 4
	#emit ADD
	#emit STOR.S.pri arg_start
	// Using an assembly loop here screwed the code up as the labels added some
	// odd stack/frame manipulation code...
	while (arg_end != arg_start)
	{
		#emit MOVE.pri
		#emit LOAD.I
		#emit PUSH.pri
		#emit CONST.pri 4
		#emit SUB.alt
		#emit STOR.S.pri arg_end
	}
	// Push the additional parameters.
	#emit PUSH.S fmat
	#emit PUSH.S size
	#emit PUSH.S output
	// Push the argument count.
	#emit LOAD.S.pri num_args
	#emit ADD.C 12
	#emit LOAD.S.alt STATIC_ARGS
	#emit XCHG
	#emit SMUL.C 4
	#emit SUB.alt
	#emit PUSH.pri
	#emit MOVE.alt
	// Push the return address.
	#emit LCTRL 6
	#emit ADD.C 28
	#emit PUSH.pri
	// Call formatex
	#emit CONST.pri formatex
	#emit SCTRL 6
}

stock Msg(playerid, colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;
		
		SendClientMessage(playerid, colour, string);
		SendClientMessage(playerid, colour, string2);
	}
	else SendClientMessage(playerid, colour, string);
	
	return 1;
}
stock MsgAll(colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		SendClientMessageToAll(colour, string);
		SendClientMessageToAll(colour, string2);
	}
	else SendClientMessageToAll(colour, string);

	return 1;
}


stock MsgF(playerid, colour, fmat[], va_args<>)
{
	va_formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	Msg(playerid, colour, gs_Buffer);

	return 1;
}

stock MsgAllF(colour, fmat[], va_args<>)
{
	va_formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<2>);
	MsgAll(colour, gs_Buffer);

	return 1;
}

stock MsgAdminsF(level, colour, fmat[], va_args<>)
{
	va_formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	MsgAdmins(level, colour, gs_Buffer);

	return 1;
}
