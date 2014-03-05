#define logf(%1,%2) log(sprintf(%1,%2))

stock log(text[], printtext = true)
{
	if(printtext)
		print(text);

	new
		string[256],
		File:file,
		filename[64];

	format(filename, 64, DIRECTORY_LOGS"%s.txt", TimestampToDateTime(gettime(), CTIME_DATE_FILENAME));

	if(fexist(filename))
		file = fopen(filename, io_append);

	else
		file = fopen(filename, io_write);

	if(!file)
	{
		printf("ERROR: Writing to log file '%s'.", filename);
		return 0;
	}

	format(string, 256, "[%s] %s\r\n", TimestampToDateTime(gettime(), CTIME_TIME_SHORT), text);

	fwrite(file, string);
	fclose(file);

	return 1;
}
