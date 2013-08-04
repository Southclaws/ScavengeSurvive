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

	if(stmt_execute(gStmt_WhitelistInsert))
		return 1;

	return -1;
}

stock RemoveNameFromWhitelist(name[])
{
	if(!IsNameInWhitelist(name))
		return 0;

	stmt_bind_value(gStmt_WhitelistDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_WhitelistDelete))
		return 1;

	return -1;
}

stock IsNameInWhitelist(name[])
{
	new count;

	stmt_bind_value(gStmt_WhitelistExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_WhitelistExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(gStmt_WhitelistExists);
	stmt_fetch_row(gStmt_WhitelistExists);

	if(count > 0)
		return 1;

	return 0;
}

public external_WhitelistAdd(name[])
{
	return AddNameToWhitelist(name);
}

public external_WhitelistRemove(name[])
{
	return RemoveNameFromWhitelist(name);
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
	return IsNameInWhitelist(name);
}
