/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


enum E_COLOUR_EMBED_DATA
{
	ce_char,
	ce_colour[9]
}


new EmbedColours[9][E_COLOUR_EMBED_DATA]=
{
	{'r', #C_RED},
	{'g', #C_GREEN},
	{'b', #C_BLUE},
	{'y', #C_YELLOW},
	{'p', #C_PINK},
	{'w', #C_WHITE},
	{'o', #C_ORANGE},
	{'n', #C_NAVY},
	{'a', #C_AQUA}
};


stock TagScan(const chat[], colour = WHITE)
{
	new
		text[256],
		length,
		a,
		tags;

	strcpy(text, chat, 256);
	length = strlen(chat);

	while(a < (length - 1) && tags < 3)
	{
		if(text[a]=='@')
		{
			if(IsCharNumeric(text[a+1]))
			{
				new
					id,
					tmp[3];

				strmid(tmp, text, a+1, a+3);
				id = strval(tmp);

				if(IsPlayerConnected(id))
				{
					new
						tmpName[MAX_PLAYER_NAME+17];

					format(tmpName, MAX_PLAYER_NAME+17, "%P%C", id, colour);

					if(id<10)
					{
						strdel(text[a], 0, 2);
					}
					else
					{
						strdel(text[a], 0, 3);
					}

					strins(text[a], tmpName, 0);

					length += strlen(tmpName);
					a += strlen(tmpName);
					tags++;
					continue;
				}
				else
				{
					a++;
				}
			}
			else
			{
				a++;
			}
		}
		else if(text[a]=='&')
		{
			if(IsCharAlphabetic(text[a+1]))
			{
				new replacements;
				for(new i;i<sizeof(EmbedColours);i++)
				{
					if(text[a+1] == EmbedColours[i][ce_char])
					{
						strdel(text[a], 0, 2);
						strins(text[a], EmbedColours[i][ce_colour], 0);
						length+=8;
						a+=8;
						replacements++;
						break;
					}
				}
				if(replacements==0)
				{
					a++;
				}
			}
			else
			{
				a++;
			}
		}
		else
		{
			a++;
		}
	}
	return text;
}
