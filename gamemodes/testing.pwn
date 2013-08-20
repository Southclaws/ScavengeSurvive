#include <a_samp>

main()
{
	SetTimer("tctest", 100, true);
}

forward tctest();
public tctest()
{
	print("Testing tickcount vs GetTickcount");
	new
		tc,
		gtc;

	tc = tickcount();
	gtc = GetTickCount();

	printf("tc:   %d", tc);
	printf("gtc:  %d", gtc);

	printf("tc:   %s", MsToString(tc, "%h:%m:%s.%d"));
	printf("gtc:  %s", MsToString(gtc, "%h:%m:%s.%d"));

	printf("diff: %d", gtc-tc);

	print("\n");
}

stock MsToString(millisecond, format[])
{
	new
		tmp[4],
		result[64],
		hour,
		minute,
		second,
		format_char,
		result_lenght,
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

			switch(format[format_char])
			{
				case 'h':
				{
					valstr(tmp, hour);
					strcat(result, tmp);
					result_lenght = strlen(result);
				}

				case 'm':
				{
					valstr(tmp, minute);
					strcat(result, tmp);
					result_lenght = strlen(result);
				}

				case 's':
				{
					valstr(tmp, second);
					strcat(result, tmp);
					result_lenght = strlen(result);
				}

				case 'd':
				{
					valstr(tmp, millisecond);
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



public OnPlayerSpawn(playerid)
{
	SetPlayerPos(playerid, 0.0, 0.0, 3.0);
}
