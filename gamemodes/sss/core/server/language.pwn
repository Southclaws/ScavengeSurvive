/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define DIRECTORY_LANGUAGES			"languages/"
#define MAX_LANGUAGE				(12)
#define MAX_LANGUAGE_ENTRIES		(1024)
#define MAX_LANGUAGE_KEY_LEN		(12)
#define MAX_LANGUAGE_ENTRY_LENGTH	(768)
#define MAX_LANGUAGE_NAME			(32)
#define MAX_LANGUAGE_REPLACEMENTS	(48)
#define MAX_LANGUAGE_REPL_KEY_LEN	(32)
#define MAX_LANGUAGE_REPL_VAL_LEN	(32)

#define DELIMITER_CHAR				'='
#define ALPHABET_SIZE				(26)


enum e_LANGUAGE_ENTRY_DATA
{
	lang_key[MAX_LANGUAGE_KEY_LEN],
	lang_val[MAX_LANGUAGE_ENTRY_LENGTH]
}

enum e_LANGUAGE_TAG_REPLACEMENT_DATA
{
	lang_repl_key[MAX_LANGUAGE_REPL_KEY_LEN],
	lang_repl_val[MAX_LANGUAGE_REPL_VAL_LEN]
}


static
	lang_Entries[MAX_LANGUAGE][MAX_LANGUAGE_ENTRIES][e_LANGUAGE_ENTRY_DATA],
	lang_TotalEntries[MAX_LANGUAGE],
	lang_AlphabetMap[MAX_LANGUAGE][ALPHABET_SIZE],

	lang_Replacements[MAX_LANGUAGE_REPLACEMENTS][e_LANGUAGE_TAG_REPLACEMENT_DATA],
	lang_TotalReplacements,

	lang_Name[MAX_LANGUAGE][MAX_LANGUAGE_NAME],
	lang_Total;


hook OnGameModeInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_LANGUAGES);

	DefineLanguageReplacement("C_YELLOW",					"{FFFF00}");
	DefineLanguageReplacement("C_RED",						"{E85454}");
	DefineLanguageReplacement("C_GREEN",					"{33AA33}");
	DefineLanguageReplacement("C_BLUE",						"{33CCFF}");
	DefineLanguageReplacement("C_ORANGE",					"{FFAA00}");
	DefineLanguageReplacement("C_GREY",						"{AFAFAF}");
	DefineLanguageReplacement("C_PINK",						"{FFC0CB}");
	DefineLanguageReplacement("C_NAVY",						"{000080}");
	DefineLanguageReplacement("C_GOLD",						"{B8860B}");
	DefineLanguageReplacement("C_LGREEN",					"{00FD4D}");
	DefineLanguageReplacement("C_TEAL",						"{008080}");
	DefineLanguageReplacement("C_BROWN",					"{A52A2A}");
	DefineLanguageReplacement("C_AQUA",						"{F0F8FF}");
	DefineLanguageReplacement("C_BLACK",					"{000000}");
	DefineLanguageReplacement("C_WHITE",					"{FFFFFF}");
	DefineLanguageReplacement("C_SPECIAL",					"{0025AA}");
	DefineLanguageReplacement("KEYTEXT_INTERACT",			"~k~~VEHICLE_ENTER_EXIT~");
	DefineLanguageReplacement("KEYTEXT_RELOAD",				"~k~~PED_ANSWER_PHONE~");
	DefineLanguageReplacement("KEYTEXT_PUT_AWAY",			"~k~~CONVERSATION_YES~");
	DefineLanguageReplacement("KEYTEXT_DROP_ITEM",			"~k~~CONVERSATION_NO~");
	DefineLanguageReplacement("KEYTEXT_INVENTORY",			"~k~~GROUP_CONTROL_BWD~");
	DefineLanguageReplacement("KEYTEXT_ENGINE",				"~k~~CONVERSATION_YES~");
	DefineLanguageReplacement("KEYTEXT_LIGHTS",				"~k~~CONVERSATION_NO~");
	DefineLanguageReplacement("KEYTEXT_DOORS",				"~k~~TOGGLE_SUBMISSIONS~");
	DefineLanguageReplacement("KEYTEXT_RADIO",				"R");

	LoadAllLanguages();
}

stock DefineLanguageReplacement(const key[], const val[])
{
	strcat(lang_Replacements[lang_TotalReplacements][lang_repl_key], key, MAX_LANGUAGE_REPL_KEY_LEN);
	strcat(lang_Replacements[lang_TotalReplacements][lang_repl_val], val, MAX_LANGUAGE_REPL_VAL_LEN);

	lang_TotalReplacements++;
}

stock LoadAllLanguages()
{
	new
		Directory:direc,
		entry[64],
		ENTRY_TYPE:type,
		default_entries,
		entries,
		languages,
		filename[32],
		trimlength = strlen("./scriptfiles/");

	direc = OpenDir(DIRECTORY_SCRIPTFILES DIRECTORY_LANGUAGES);

	// Force load English first since that's the default language.
	default_entries = LoadLanguage(DIRECTORY_LANGUAGES"English", "English");
	Logger_Log("default language English loaded", Logger_I("entries", default_entries));

	if(direc == Directory:-1)
	{
		err("Reading directory '%s'.", DIRECTORY_SCRIPTFILES DIRECTORY_LANGUAGES);
		return 0;
	}

	if(default_entries == 0)
	{
		err("No default entries loaded! Please add the 'English' langfile to '%s'.", DIRECTORY_SCRIPTFILES DIRECTORY_LANGUAGES);
		for(;;) {}
	}

	while(DirNext(direc, type, entry))
	{
		if(type == E_REGULAR)
		{
			if(!strcmp(entry, "English"))
				continue;

			PathBase(entry, filename);
			entries = LoadLanguage(entry[trimlength], filename);

			if(entries > 0)
			{
				Logger_Log("additional language loaded",
					Logger_S("entry", entry),
					Logger_I("entries", entries),
					Logger_I("missing", default_entries - entries)
				);
				languages++;
			}
			else
			{
				printf("No entries loaded from language file '%s'", entry);
			}
		}
	}

	CloseDir(direc);

	return 1;
}

stock LoadLanguage(const filename[], const langname[])
{
	if(lang_Total == MAX_LANGUAGE)
	{
		printf("lang_Total reached MAX_LANGUAGE");
		return 0;
	}

	new
		File:f = fopen(filename, io_read),
		line[MAX_LANGUAGE_KEY_LEN + 1 + MAX_LANGUAGE_ENTRY_LENGTH],
		linenumber = 1,
		bool:skip,
		replace_me[MAX_LANGUAGE_ENTRY_LENGTH],
		length,
		delimiter,
		key[MAX_LANGUAGE_KEY_LEN],
		index;

	if(!f)
	{
		printf("Unable to open file '%s'.", filename);
		return 0;
	}

	while(fread(f, line))
	{
		length = strlen(line);

		if(length < 4)
			continue;

		delimiter = 0;

		while(line[delimiter] != DELIMITER_CHAR)
		{
			if(!(32 <= line[delimiter] < 127))
			{
				printf("Malformed line %d in '%s' key contains non-alphabetic character (%d:%c).", linenumber, filename, line[delimiter], line[delimiter]);
				skip = true;
				break;
			}

			if(delimiter >= MAX_LANGUAGE_KEY_LEN)
			{
				printf("Malformed line %d in '%s' key length over %d characters (%d).", linenumber, filename, MAX_LANGUAGE_KEY_LEN, delimiter);
				skip = true;
				break;
			}

			key[delimiter] = line[delimiter];
			delimiter++;
		}

		if(skip)
		{
			skip = false;
			continue;
		}

		if(delimiter >= length - 1 || delimiter < 4)
		{
			printf("Malformed line %d in '%s' delimiter character (%c) is absent or in first 4 cells.", linenumber, filename, DELIMITER_CHAR);
			continue;
		}

		if(!(32 <= key[0] < 127))
		{
			printf("First character on line %d is abnormal character (%d/%c).", linenumber, key[0], key[0]);
			continue;
		}

		key[delimiter] = EOS;
		index = lang_TotalEntries[lang_Total]++;

		if(lang_TotalEntries[lang_Total] >= MAX_LANGUAGE_ENTRIES)
		{
			printf("MAX_LANGUAGE_ENTRIES limit reached at line %d", linenumber);
			break;
		}

		strmid(lang_Entries[lang_Total][index][lang_key], line, 0, delimiter, MAX_LANGUAGE_ENTRY_LENGTH);
		strmid(replace_me, line, delimiter + 1, length - 1, MAX_LANGUAGE_ENTRY_LENGTH);

		_doReplace(replace_me, lang_Entries[lang_Total][index][lang_val]);

		linenumber++;
	}

	fclose(f);

	if(lang_TotalEntries[lang_Total] == 0)
	{
		return 0;
	}

	strcat(lang_Name[lang_Total], langname, MAX_LANGUAGE_NAME);

	_qs(lang_Entries[lang_Total], 0, lang_TotalEntries[lang_Total] - 1);

	// alphabetmap
	new
		this_letter,
		letter_idx;

	for(new i; i < lang_TotalEntries[lang_Total]; i++)
	{
		this_letter = toupper(lang_Entries[lang_Total][i][lang_key][0]) - 65;

		if(this_letter == letter_idx-1)
			continue;

		while(letter_idx < this_letter)
		{
			lang_AlphabetMap[lang_Total][letter_idx] = -1;
			letter_idx++;
		}

		if(letter_idx >= 26)
		{
			printf("letter_idx > 26 (%d) at i = %d entry: '%s'", letter_idx, i, lang_Entries[lang_Total][i][lang_key]);
		}

		lang_AlphabetMap[lang_Total][letter_idx] = i;
		letter_idx++;
	}

	// fill in the empty ones
	while(letter_idx < 26)
		lang_AlphabetMap[lang_Total][letter_idx++] = -1;

	lang_Total++;

	return index;
}

_doReplace(const input[], output[])
{
	new
		bool:in_tag = false,
		tag_start = -1,
		output_idx;

	for(new i = 0; input[i] != EOS; ++i)
	{
		if(in_tag)
		{
			if(input[i] == '}')
			{
				for(new j; j < lang_TotalReplacements; ++j)
				{
					if(!strcmp(input[tag_start], lang_Replacements[j][lang_repl_key], false, i - tag_start))
					{
						for(new k; lang_Replacements[j][lang_repl_val][k] != 0 && output_idx < MAX_LANGUAGE_ENTRY_LENGTH; ++k)
							output[output_idx++] = lang_Replacements[j][lang_repl_val][k];

						break;
					}
				}

				in_tag = false;
				continue;
			}
		}
		else
		{
			if(input[i] == '{')
			{
				tag_start = i + 1;
				in_tag = true;
				continue;
			}
			else if(input[i] == '\\')
			{
				if(input[i + 1] == 'n')
				{
					output[output_idx++] = '\n';
					i += 1;
				}
				else if(input[i + 1] == 't')
				{
					output[output_idx++] = '\t';
					i += 1;
				}
			}
			else
			{
				output[output_idx++] = input[i];
			}
		}
	}
}

_qs(array[][], left, right)
{
	new
		tempLeft = left,
		tempRight = right,
		pivot = array[(left + right) / 2][0];

	while(tempLeft <= tempRight)
	{
		while(array[tempLeft][0] < pivot)
			tempLeft++;

		while(array[tempRight][0] > pivot)
			tempRight--;
		
		if(tempLeft <= tempRight)
		{
			_swap(array[tempLeft][lang_key], array[tempRight][lang_key]);
			_swap(array[tempLeft][lang_val], array[tempRight][lang_val]);

			tempLeft++;
			tempRight--;
		}
	}

	if(left < tempRight)
		_qs(array, left, tempRight);

	if(tempLeft < right)
		_qs(array, tempLeft, right);
}

_swap(str1[], str2[])
{
	new tmp;

	for(new i; str1[i] != '\0' || str2[i] != '\0'; i++)
	{
		tmp = str1[i];
		str1[i] = str2[i];
		str2[i] = tmp;
	}
}

stock GetLanguageString(languageid, const key[], bool:encode = false)
{
	new
		result[MAX_LANGUAGE_ENTRY_LENGTH],
		ret;

	if(!(0 <= languageid < lang_Total))
	{
		printf("Invalid languageid %d.", languageid);
		return result;
	}

	ret = _GetLanguageString(languageid, key, result, encode);

	switch(ret)
	{
		case 1:
		{
			printf("Malformed key '%s' must be alphabetical.", key);
		}
		case 2:
		{
			printf("Key not found: '%s' in language '%s'", key, lang_Name[languageid]);

			// return english if key not found
			if(languageid != 0)
				strcat(result, GetLanguageString(0, key, encode), MAX_LANGUAGE_ENTRY_LENGTH);
		}
	}

	return result;
}

static stock _GetLanguageString(languageid, const key[], result[], bool:encode = false)
{
	if(!('A' <= key[0] <= 'Z'))
		return 1;

	new
		index,
		start,
		end,
		abindex;

	abindex = toupper(key[0] - 65);

	start = lang_AlphabetMap[languageid][abindex];

	if(start == -1)
		return 2;

	do
	{
		abindex++;

		if(abindex == ALPHABET_SIZE)
			break;
	}
	while(lang_AlphabetMap[languageid][abindex] == -1);

	if(abindex < ALPHABET_SIZE)
		end = lang_AlphabetMap[languageid][abindex];

	else
		end = lang_TotalEntries[languageid];

	// start..end is now the search space

	// dumb search for now, will probably replace with bisect
	for(index = start; index < end; index++)
	{
		if(!strcmp(lang_Entries[languageid][index][lang_key], key, false, MAX_LANGUAGE_ENTRY_LENGTH))
			break;
	}

	if(index == end)
		return 2;

	strcat(result, lang_Entries[languageid][index][lang_val], MAX_LANGUAGE_ENTRY_LENGTH);

	if(encode)
		ConvertEncoding(result);

	return 0;
}

/*
	Credit for this function goes to Y_Less:
	http://forum.sa-mp.com/showpost.php?p=3015480&postcount=6
*/
stock ConvertEncoding(string[])
{
	static const
		real[256] =
		{
			  0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,
			 16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
			 32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
			 48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
			 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
			 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,
			 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
			112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
			128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
			144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
			160,  94, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
			124, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 175,
			128, 129, 130, 195, 131, 197, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141,
			208, 173, 142, 143, 144, 213, 145, 215, 216, 146, 147, 148, 149, 221, 222, 150,
			151, 152, 153, 227, 154, 229, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164,
			240, 174, 165, 166, 167, 245, 168, 247, 248, 169, 170, 171, 172, 253, 254, 255
		};

	for(new i = 0, len = strlen(string), ch; i != len; ++i)
	{
		// Check if this character is in our reduced range.
		if(0 <= (ch = string[i]) < 256)
		{
			string[i] = real[ch];
		}
	}
}

/*
	Not sure where this code came from... random pastebin link!

stock ConvertEncoding(string[])
{
	for(new i = 0, len = strlen(string); i != len; ++i)
	{
		switch(string[i])
		{
			case 0xC0 .. 0xC3: string[i] -= 0x40;
			case 0xC7 .. 0xC9: string[i] -= 0x42;
			case 0xD2 .. 0xD5: string[i] -= 0x44;
			case 0xD9 .. 0xDC: string[i] -= 0x47;
			case 0xE0 .. 0xE3: string[i] -= 0x49;
			case 0xE7 .. 0xEF: string[i] -= 0x4B;
			case 0xF2 .. 0xF5: string[i] -= 0x4D;
			case 0xF9 .. 0xFC: string[i] -= 0x50;
			case 0xC4, 0xE4: string[i] = 0x83;
			case 0xC6, 0xE6: string[i] = 0x84;
			case 0xD6, 0xF6: string[i] = 0x91;
			case 0xD1, 0xF1: string[i] = 0xEC;
			case 0xDF: string[i] = 0x96;
			case 0xBF: string[i] = 0xAF;
		}
	}
}
*/
stock GetLanguageList(list[][])
{
	for(new i; i < lang_Total; i++)
	{
		list[i][0] = EOS;
		strcat(list[i], lang_Name[i], MAX_LANGUAGE_NAME);
	}

	return lang_Total;
}

stock GetLanguageName(languageid, name[])
{
	if(!(0 <= languageid < lang_Total))
		return 0;

	name[0] = EOS;
	strcat(name, lang_Name[languageid], MAX_LANGUAGE_NAME);

	return 1;
}

stock GetLanguageID(name[])
{
	for(new i; i < lang_Total; i++)
	{
		if(!strcmp(name, lang_Name[i]))
			return i;
	}
	return -1;
}
