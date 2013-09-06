forward external_WhitelistAdd(name[]);
forward external_WhitelistRemove(name[]);
forward external_WhitelistOn();
forward external_WhitelistOff();
forward external_WhitelistCheck(name[]);


stock AddNameToWhitelist(name[])
{
	if(IsNameInWhitelist(name))
		return 0;

	stmt_bind_value(gStmt_WhitelistInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_WhitelistInsert, true, false))
	{
		stmt_free_result(gStmt_WhitelistInsert);
		return 1;
	}

	return -1;
}

stock RemoveNameFromWhitelist(name[])
{
	if(!IsNameInWhitelist(name))
		return 0;

	stmt_bind_value(gStmt_WhitelistDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_WhitelistDelete, true, false))
	{
		stmt_free_result(gStmt_WhitelistDelete);
		return 1;
	}

	return -1;
}

stock IsNameInWhitelist(name[])
{
	new count;

	stmt_bind_value(gStmt_WhitelistExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_WhitelistExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(gStmt_WhitelistExists, true, false);
	stmt_fetch_row(gStmt_WhitelistExists);
	stmt_free_result(gStmt_WhitelistExists);

	if(count > 0)
		return 1;

	return 0;
}

WhitelistKick(playerid)
{
	new str[512];

	format(str, 512,
		""#C_YELLOW"You are not on the whitelist for this server.\n\
		This is in force to provide the best gameplay experience for all players.\n\n\
		"#C_WHITE"Please apply on "#C_BLUE"%s"#C_WHITE".\n\
		Applications are always accepted as soon as possible\n\
		There are no requirements, just follow the rules.\n\
		Failure to do so will result in permanent removal from the whitelist.", gWebsiteURL);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Whitelist", str, "Close", "");

	defer KickPlayerDelay(playerid);
}

public external_WhitelistAdd(name[])
{
	new string[MAX_PLAYER_NAME];
	format(string, sizeof(string), name);
	return AddNameToWhitelist(string);
}

public external_WhitelistRemove(name[])
{
	new string[MAX_PLAYER_NAME];
	format(string, sizeof(string), name);
	return RemoveNameFromWhitelist(string);
}

public external_WhitelistOn()
{
	gWhitelist = true;
}

public external_WhitelistOff()
{
	gWhitelist = false;
}

public external_WhitelistCheck(name[])
{
	new string[MAX_PLAYER_NAME];
	format(string, sizeof(string), name);
	return IsNameInWhitelist(string);
}
