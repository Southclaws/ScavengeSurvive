/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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
