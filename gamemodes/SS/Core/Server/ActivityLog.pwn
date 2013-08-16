#define LOG_FILE "SSS/Logs/%s.txt"
#define logf(%1,%2) log(sprintf(%1,%2))

stock log(text[])
{
	new
		string[256],
		File:file,
		filename[64];

	format(filename, 64, LOG_FILE, TimestampToDate(gettime()));

	if(fexist(filename))
		file = fopen(filename, io_append);

	else
		file = fopen(filename, io_write);

	if(!file)
	{
		printf("ERROR: Writing to log file '%s'.", filename);
		return 0;
	}

	strcat(string, text);
	strcat(string, "\r\n");

	fwrite(file, string);
	fclose(file);

	return 1;
}
