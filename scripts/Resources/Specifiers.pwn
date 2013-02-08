SSCANF:player_name(string[])
{
    new
		foundplayer = INVALID_PLAYER_ID,
		bool:numeric = true;

    for (new i = 0, c; (c = string[i]); i++)
	{
        if (c < '0' || c > '9')
		{
            numeric = false;

            break;
        }
    }

    if (numeric)
	{
        foundplayer = strval(string);

        if (IsPlayerConnected(foundplayer))
            return foundplayer;

        else
            foundplayer = INVALID_PLAYER_ID;
    }

    foreach(new playerid : Player)
	{
        if (strfind(gPlayerName[playerid], string, true) != -1)
		{
            if (foundplayer != INVALID_PLAYER_ID)
                return INVALID_PLAYER_ID; // Multiple matches

            else
                foundplayer = playerid;
        }
    }

    return foundplayer;
}
