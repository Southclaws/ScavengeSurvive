#define logf(%1,%2) log(sprintf(%1,%2))

stock log(text[], printtext = true)
{
	if(printtext)
		print(text);

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

	format(filename, 64, DIRECTORY_LOGS"%d-%d-%d.txt", year, month, day);

	if(fexist(filename))
		file = fopen(filename, io_append);

	else
		file = fopen(filename, io_write);

	if(!file)
	{
		printf("ERROR: Writing to log file '%s'.", filename);
		return 0;
	}

	format(string, 256, "[%d:%d:%d] %s\r\n", hour, minute, second, text);

	fwrite(file, string);
	fclose(file);

	return 1;
}
