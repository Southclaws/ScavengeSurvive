/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


stock isalphabetic(chr)
{
	if('a' <= chr <= 'z' || 'A' <= chr <= 'Z')
		return 1;

	return 0;
}

stock isalphanumeric(chr)
{
	if('a' <= chr <= 'z' || 'A' <= chr <= 'Z' || '0' <= chr <= '9')
		return 1;

	return 0;
}

FormatSpecifier<'T'>(output[], timestamp)
{
	strcat(output, TimestampToDateTime(timestamp, "%A %b %d %Y at %X"));
}

FormatSpecifier<'M'>(output[], millisecond)
{
	strcat(output, MsToString(millisecond, "%h:%m:%s.%d"));
}

stock atos(a[], size, s[], len = sizeof(s))
{
	s[0] = '[';

	for(new i; i < size; i++)
	{
		if(i != 0)
			strcat(s, ", ", len);

		format(s, len, "%s%d", s, a[i]);
	}

	s[strlen(s)] = ']';
}

stock atosr(a[], size = sizeof(a))
{
	new s[256];
	atos(a, size, s);
	return s;
}
