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


#if defined USE_DEFAULT_LOGGING
	#endinput
#endif


#include <YSI\y_hooks>
#include <YSI\y_va>


#define DIRECTORY_LOGS				"logs/"

static
File:	log_File,
		log_buffer[256];


_log_open()
{
	if(!!log_File)
		return;

	new
		year,
		month,
		day,
		filename[64];

	getdate(year, month, day);
	format(filename, 64, DIRECTORY_LOGS"%d-%02d-%02d.txt", year, month, day);

	if(fexist(filename))
		log_File = fopen(filename, io_append);

	else
		log_File = fopen(filename, io_write);

	return;
}

hook OnScriptExit()
{
	fclose(log_File);
}

stock _log(text[], printtext = true)
{
	if(printtext)
		print(text);

	if(!log_File)
		_log_open();

	new
		hour,
		minute,
		second,
		string[256];

	gettime(hour, minute, second);

	format(string, 256, "[%02d:%02d:%02d] %s\r\n", hour, minute, second, text);

	fwrite(log_File, string);

	return 1;
}

stock console(text[], va_args<>)
{
	va_formatex(log_buffer, sizeof(log_buffer), text, va_start<1>);
	print(log_buffer);
}

stock log(text[], va_args<>)
{
	va_formatex(log_buffer, sizeof(log_buffer), text, va_start<1>);
	_log(log_buffer);
}

stock err(text[], va_args<>)
{
	va_formatex(log_buffer, sizeof(log_buffer), text, va_start<1>);
	_log(log_buffer);
	PrintAmxBacktrace();
}

#define print						__use_log
#define printfex					__use_log
