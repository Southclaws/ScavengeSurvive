#include <YSI\y_hooks>
#include <YSI\y_va>


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
