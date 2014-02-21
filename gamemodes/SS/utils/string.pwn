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

