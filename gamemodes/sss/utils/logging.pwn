/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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


#include <YSI_Coding\y_hooks>
#include <YSI\y_va>


enum
{
	NONE,
	CORE,
	DEEP,
	LOOP
}


stock log(const text[], va_args<>)
{
	new log_Buffer[256];
	formatex(log_Buffer, sizeof(log_Buffer), text, va_start<1>);
	print(log_Buffer);
}

stock dbg(const handler[], level, const text[], va_args<>)
{
	new log_Buffer[256];
	if(level <= GetSVarInt(handler))
	{
		formatex(log_Buffer, sizeof(log_Buffer), text, va_start<3>);
		print(log_Buffer);
	}
}

stock err(const text[], va_args<>)
{
	new log_Buffer[256];
	formatex(log_Buffer, sizeof(log_Buffer), text, va_start<1>);
	print(log_Buffer);
	PrintAmxBacktrace();
}


/*==============================================================================

	Internal/utility

==============================================================================*/


stock debug_set_level(const handler[], level)
{
	SetSVarInt(handler, level);
	return 1;
}

stock debug_conditional(const handler[], level)
{
	return GetSVarInt(handler) >= level;
}
