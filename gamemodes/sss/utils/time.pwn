/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define CTIME_DATE_TIME			"%A %b %d %Y at %X"
#define CTIME_DATE_FILENAME		"%Y-%m-%d (%a-%d-%b)"
#define CTIME_DATE_SHORT		"%x"
#define CTIME_TIME_SHORT		"%X"

#define ROUND_TYPE_MINUTE		(60)
#define ROUND_TYPE_HOUR			(3600)
#define ROUND_TYPE_DAY			(86400)

stock RoundTimestamp(timestamp, roundamount)
{
	return timestamp - (timestamp % roundamount);
}

stock TimestampToDateTime(datetime, const format[] = CTIME_DATE_TIME)
{
	new str[64];
	TimeFormat(Timestamp:datetime, format, str);
	return str;
}

stock MsToString(millisecond, const format[])
{
	new
		tmp[4],
		result[64],
		hour,
		minute,
		second,
		format_char,
		result_lenght,
		bool:padding,
		len = strlen(format);

	hour			= (millisecond / (1000 * 60 * 60));
	minute			= (millisecond % (1000 * 60 * 60)) / (1000 * 60);
	second			= ((millisecond % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
	millisecond		= millisecond - (hour * 60 * 60 * 1000) - (minute * 60 * 1000) - (second * 1000);

	while(format_char < len)
	{
		if(format[format_char] == '%')
		{
			format_char++;

			if(format[format_char] == '1')
			{
				padding = true;
				format_char++;
			}
			else
			{
				padding = false;
			}

			switch(format[format_char])
			{
				case 'h':
				{
					valstr(tmp, hour);

					if(padding)
					{
						if(hour < 10)
							strcat(result, "0");
					}

					strcat(result, tmp);
					result_lenght = strlen(result);
				}

				case 'm':
				{
					valstr(tmp, minute);

					if(padding)
					{
						if(minute < 10)
							strcat(result, "0");
					}

					strcat(result, tmp);
					result_lenght = strlen(result);
				}

				case 's':
				{
					valstr(tmp, second);

					if(padding)
					{
						if(second < 10)
							strcat(result, "0");
					}

					strcat(result, tmp);
					result_lenght = strlen(result);
				}

				case 'd':
				{
					valstr(tmp, millisecond);

					if(padding)
					{
						if(millisecond < 10)
							strcat(result, "00");

						else if(millisecond < 100)
							strcat(result, "0");
					}

					strcat(result, tmp);
					result_lenght = strlen(result);
				}
			}
		}
		else
		{
			result[result_lenght] = format[format_char];
			result_lenght++;
		}

		format_char++;
	}

	return result;
}

GetDurationFromString(const string[])
{
	new
		value,
		type[16];

	if(sscanf(string, "ds[16]", value, type))
		return -1;

	if(value <= 0)
		return -1;

	if(!strcmp(type, "day", true, 3))
		return value * 86400;

	if(!strcmp(type, "week", true, 4))
		return value * 604800;

	if(!strcmp(type, "month", true, 5))
		return value * 2628000;

	return -1;
}
