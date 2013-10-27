#define CTIME_DATE_TIME			"%A %b %d %Y at %X"
#define CTIME_DATE_FILENAME		"%Y-%m-%d (%a-%d-%b)"
#define CTIME_DATE_SHORT		"%x"
#define CTIME_TIME_SHORT		"%X"

stock TimestampToDateTime(datetime, format[] = CTIME_DATE_TIME)
{
	new
		str[64],
		tm<timestamp>;

	localtime(Time:datetime, timestamp);
	strftime(str, 64, format, timestamp);

	return str;
}

stock IsPointInMapBounds(Float:x, Float:y, Float:z)
{
	if(-3000.0 <= x <= 3000.0)
	{
		if(-3000.0 <= y <= 3000.0)
		{
			if(-100.0 <= z <= 1000.0)
			{
				return 1;
			}
		}
	}

	return 0;
}

stock returnOrdinal(number)
{
	new
		ordinal[4][3] = { "st", "nd", "rd", "th" };
	number = number < 0 ? -number : number;
	return (((10 < (number % 100) < 14)) ? ordinal[3] : (0 < (number % 10) < 4) ? ordinal[((number % 10) - 1)] : ordinal[3]);
}

stock IsNumeric(string[])
{
	for(new i,j=strlen(string);i<j;i++)if (string[i] > '9' || string[i] < '0') return 0;
	return 1;
}
stock IsCharNumeric(c)
{
	if(c>='0'&&c<='9')return 1;
	return 0;
}
stock IsCharAlphabetic(c)
{
	if((c>='a'&&c<='z')||(c>='A'&&c<='Z'))return 1;
	return 0;
}

stock strtolower(string[])
{
	new
		retStr[128],
		i,
		j;

	while ((j = string[i])) retStr[i++] = tolower(j);
	retStr[i] = '\0';

	return retStr;
}
stock UnderscoreToSpace(name[])
{
	new pos = strfind(name, "_", true);

	if(pos != -1)
	{
		name[pos] = ' ';
		return 1;
	}

	return 0;
}

stock db_escape(text[])
{
	new
		ret[256],
		ch,
		i,
		j;

	while ((ch = text[i++]) && j < sizeof (ret))
	{
		if (ch == '\'')
		{
			if (j < sizeof (ret) - 2)
			{
				ret[j++] = '\'';
				ret[j++] = '\'';
			}
		}
		else if (j < sizeof (ret))
		{
			ret[j++] = ch;
		}
		else
		{
			j++;
		}
	}
	ret[sizeof (ret) - 1] = '\0';
	return ret;
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

stock RGBAToHex(r, g, b, a)
{
	return (r<<24 | g<<16 | b<<8 | a);
}

stock HexToRGBA(colour, &r, &g, &b, &a)
{
	r = (colour >> 24) & 0xFF;
	g = (colour >> 16) & 0xFF;
	b = (colour >> 8) & 0xFF;
	a = colour & 0xFF;
}

stock IpIntToStr(ip)
{
	new str[17];
	format(str, 17, "%d.%d.%d.%d", ((ip>>24) & 0xFF), ((ip>>16) & 0xFF), ((ip>>8) & 0xFF), (ip & 0xFF) );
	return str;
}


//==============================================================================Player Functions


stock SetAllWeaponSkills(playerid, skill)
{
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED,	skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE,		skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN,			skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN,	skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE,		skill);
}


//==============================================================================Location / Geometrical


forward Float:GetPlayerDist3D(player1, player2);
stock Float:GetPlayerDist3D(player1, player2)
{
	new
		Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2;

	GetPlayerPos(player1, x1, y1, z1);
	GetPlayerPos(player2, x2, y2, z2);

	return floatsqroot( (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2));
}
forward Float:GetPlayerDist2D(player1, player2);
stock Float:GetPlayerDist2D(player1, player2)
{
	new
		Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2;

	GetPlayerPos(player1, x1, y1, z1);
	GetPlayerPos(player2, x2, y2, z2);

	return floatsqroot( (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}


//==============================================================================Skin Functions


static const SkinArray[] =
{
	3, 4, 5, 6, 7, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273,
	0,1,2,7,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,37,
	38,40,43,44,45,46,47,48,49,50,51,52,57,58,59,60,61,62,66,67,68,70,71,72,73,78,
	79,80,81,82,83,84,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,110,112,
	113,114,115,116,117,118,120,121,122,123,124,125,126,127,128,131,132,133,134,135,
	136,137,142,143,144,146,147,153,154,155,156,158,159,160,161,162,163,164,165,166,
	167,168,170,171,173,174,175,176,177,179,180,181,182,183,184,185,186,187,188,189,
	200,202,203,204,206,209,210,212,213,217,220,221,222,223,227,228,229,230,234,235,
	236,239,240,241,242,247,248,249,250,252,253,254,255,258,259,260,261,262,264,265,
	266,267,269,270,271,272,274,275,276,277,278,279,280,281,282,283,284,285,286,287,
	288,289,290,291,292,293,294,295,296,297,299,
	9,10,11,12,13,31,39,41,42,53,54,55,56,63,64,69,75,76,77,85,87,88,89,90,91,92,93,
	109,111,129,130,131,138,139,140,141,145,148,150,151,152,157,169,172,178,190,191,
	192,193,194,195,196,197,198,199,201,205,207,211,214,215,216,218,219,224,225,226,
	231,232,233,237,238,243,244,245,246,251,256,257,263,298
};

stock GetSkinGender(skinID)
{
	for(new i; i<sizeof(SkinArray); i++)
	{
		if(SkinArray[i] == skinID)
		{
			switch(i)
			{
				case 0..14: return 0;
				case 15..221: return 1;
				case 222..299: return 2;
			}
			break;
		}
	}
	return 0;
}

stock IsValidSkin(skinid)
{
	if(skinid == 74 || skinid > 299 || skinid < 0)
		return 0;
		
	return 1;
}

stock TruncateChatMessage(input[], output[])
{
	if(strlen(input) > 127)
	{
		new splitpos;

		for(new i = 128; i > 0; i--)
		{
			if(input[i] == ' ' || input[i] ==  ',' || input[i] ==  '.')
			{
				splitpos = i;
				break;
			}
		}

		strcat(output, input[splitpos], 128);
		input[splitpos] = 0;

		return 1;
	}

	return 0;
}
