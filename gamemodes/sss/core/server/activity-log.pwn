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


#include <YSI_4\y_hooks>
#include <YSI_4\y_va>


#define DIRECTORY_LOGS				DIRECTORY_MAIN"Logs/"
#define USE_LOGS					false


static log_buffer[256];


hook OnGameModeInit()
{
#if USE_LOGS == true
	print("\n[OnGameModeInit] Initialising 'ActivityLog'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_LOGS);
#endif
}

stock log(text[], printtext = true)
{
	if(printtext)
		print(text);

#if USE_LOGS == true
	new
		year,
		month,
		day,
		hour,
		minute,
		second,
		string[256],
		File:file,
		filename[64];

	getdate(year, month, day);
	gettime(hour, minute, second);

	format(filename, 64, DIRECTORY_LOGS"%d-%02d-%02d.txt", year, month, day);

	if(fexist(filename))
		file = fopen(filename, io_append);

	else
		file = fopen(filename, io_write);

	if(!file)
	{
		printf("ERROR: Writing to log file '%s'.", filename);
		return 0;
	}

	format(string, 256, "[%02d:%02d:%02d] %s\r\n", hour, minute, second, text);

// Todo: replace this with an SQL buffer and time triggered/buffer triggered transaction
	fwrite(file, string);
	fclose(file);
#endif
	return 1;
}

stock logf(text[], va_args<>)
{
	va_formatex(log_buffer, sizeof(log_buffer), text, va_start<1>);

	return log(log_buffer);
}
