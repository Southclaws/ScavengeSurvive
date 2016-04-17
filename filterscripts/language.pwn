#include <a_samp>

#define L:%0[%1] GetLanguageString(GetPlayerLanguage(%0), %1)

// TEST CODE
public OnFilterScriptInit()
{
	print("\n\nLanguage test script");
	LoadLanguage("SSS/languages/English");

	print("\n\nTesting getter on valids\n");
	printf("valid:   '%s'", GetLanguageString(0, "LANGCHANGE"));
//	printf("valid:   '%s'", GetLanguageString(0, "AK47Rifle"));
//	printf("valid:   '%s'", GetLanguageString(0, "Ammo556Tracer"));
//
//	print("\n\nTesting getter on invalids\n");
//	printf("invalid: '%s'", L:0[".357"]);
//	printf("invalid: '%s'", L:0["NoneExistent"]);


//	new str1[32], str2[32];
//
//	str1 = "Horse";
//	str2 = "Cupcakes";
//
//	printf("'%s' : '%s'", str1, str2);
//
//	_swap(str1, str2);
//
//	printf("'%s' : '%s'", str1, str2);

}

stock GetPlayerLanguage(playerid)
{
	return playerid;
}

// LIB CODE

#define DIRECTORY_LANGUAGES			DIRECTORY_MAIN"languages/"
#define MAX_LANGUAGE				(6)
#define MAX_LANGUAGE_ENTRIES		(500)
#define MAX_LANGUAGE_KEY_LEN		(32)
#define MAX_LANGUAGE_ENTRY_LENGTH	(256)
#define MAX_LANGUAGE_NAME			(32)

#define DELIMITER_CHAR				'='
#define ALPHABET_SIZE				(26)


enum e_LANGUAGE_ENTRY_DATA
{
	lang_key[MAX_LANGUAGE_KEY_LEN],
	lang_val[MAX_LANGUAGE_ENTRY_LENGTH]
}

static
	lang_Entries[MAX_LANGUAGE][MAX_LANGUAGE_ENTRIES][e_LANGUAGE_ENTRY_DATA],
	lang_TotalEntries[MAX_LANGUAGE],
	lang_AlphabetMap[MAX_LANGUAGE][ALPHABET_SIZE],
	lang_Total;


stock LoadLanguage(filename[])
{
	printf("Loading language '%s'...", filename);
	new
		File:f = fopen(filename, io_read),
		line[256],
		length,
		delimiter,
		key[MAX_LANGUAGE_KEY_LEN],
		index;

	if(!f)
	{
		printf("[LoadLanguage] ERROR: Failed to load file '%s'", filename);
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
			key[delimiter] = line[delimiter];
			delimiter++;
		}

		if(delimiter >= length - 1 || delimiter < 4)
		{
			printf("[LoadLanguage] ERROR: Malformed line in '%s' delimiter character (%c) is absent or in first 4 cells.", filename, DELIMITER_CHAR);
			continue;
		}

		if(!(32 <= key[0] < 127))
		{
			printf("[LoadLanguage] ERROR: First character is abnormal character (%d/%c).", key[0], key[0]);
			continue;
		}

		key[delimiter] = EOS;
		index = lang_TotalEntries[lang_Total]++;
/*
		index = _hash(key, MAX_LANGUAGE_ENTRIES);

		if(lang_Entries[lang_Total][index][0] != EOS)
		{
			printf("[LoadLanguage] ERROR: Language index collision key '%s' == key for '%s' (%d)", key, lang_Entries[lang_Total][index], index);
			continue;
		}
*/
		strmid(lang_Entries[lang_Total][index][lang_key], line, 0, delimiter, MAX_LANGUAGE_ENTRY_LENGTH);
		strmid(lang_Entries[lang_Total][index][lang_val], line, delimiter + 1, length - 1, MAX_LANGUAGE_ENTRY_LENGTH);
	}

	// If this is the first language, set up some global rules
	if(lang_Total == 0)
	{
		//
	}

	fclose(f);

	// sort lang_Entries[lang_Total]
	print("\nUNSORTED:\n");

	for(new i; i < lang_TotalEntries[lang_Total]; i++)
		printf("%s=%s", lang_Entries[lang_Total][i][lang_key], lang_Entries[lang_Total][i][lang_val]);

	_qs(lang_Entries[lang_Total], 0, lang_TotalEntries[lang_Total] - 1);

	print("\nSORTED:\n");

	for(new i; i < lang_TotalEntries[lang_Total]; i++)
		printf("%s=%s", lang_Entries[lang_Total][i][lang_key], lang_Entries[lang_Total][i][lang_val]);

	print("\nDONE\n");

	// alphabetmap
	new
		this_letter,
		letter_idx;

	for(new i; i < lang_TotalEntries[lang_Total]; i++)
	{
		this_letter = toupper(lang_Entries[lang_Total][i][lang_key][0]) - 65;

		if(this_letter == letter_idx-1)
		{
			printf("Already set %c, skipping entry", this_letter+65);
			continue;
		}

		while(letter_idx < this_letter)
		{
			printf("Skipping %c", letter_idx+65);
			lang_AlphabetMap[lang_Total][letter_idx] = -1;
			letter_idx++;
		}

		printf("this letter: %c letter_idx: %c", this_letter+65, letter_idx+65);
		lang_AlphabetMap[lang_Total][letter_idx] = i;
		letter_idx++;
	}

	while(letter_idx < 26)
		lang_AlphabetMap[lang_Total][letter_idx++] = -1;

	for(new i; i < 26; i++)
		printf("Letter %c pos: %d", i + 65, lang_AlphabetMap[lang_Total][i]);

	return lang_Total++;
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

stock GetLanguageString(languageid, key[])
{
	new
		result[MAX_LANGUAGE_ENTRY_LENGTH],
		ret;

	ret = _GetLanguageString(languageid, key, result);

	switch(ret)
	{
		case 1:
			printf("[GetLanguageString] ERROR: Malformed key '%s' must be alphabetical.", key);

		case 2:
			printf("[GetLanguageString] ERROR: Key not found: '%s'", key);
	}

	return result;
}

_GetLanguageString(languageid, key[], result[])
{
	printf("\n\n_GetLanguageString: '%s'", key);

	if(!('A' <= key[0] <= 'Z'))
		return 1;

	new
		index,
		start,
		end,
		abindex;

	abindex = toupper(key[0] - 65);

	printf("abindex: %d char: '%c'", abindex, abindex+65);

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

	printf("search space: %d..%d", start, end);
	// start..end is now the search space

	// dumb search for now, will probably replace with bisect
	for(index = start; index < end; index++)
	{
		printf("Searching '%s'", lang_Entries[languageid][index][lang_key]);
		if(!strcmp(lang_Entries[languageid][index][lang_key], key))
			break;
	}

	if(index == end)
		return 2;

	strcat(result, lang_Entries[languageid][index][lang_val], MAX_LANGUAGE_ENTRY_LENGTH);

	return 0;
}
