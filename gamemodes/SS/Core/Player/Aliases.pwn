enum E_ALIAS_DATA
{
		alias_Name[MAX_PLAYER_NAME],
bool:	alias_Banned
}

GetAccountAliasesByIP(name[], list[][E_ALIAS_DATA], &count, max, &adminlevel)
{
	new
		ip,
		tempname[MAX_PLAYER_NAME],
		templevel;

	stmt_bind_value(gStmt_AccountGetIpv4, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetIpv4, 0, DB::TYPE_INTEGER, ip);

	if(!stmt_execute(gStmt_AccountGetIpv4))
		return 0;

	stmt_fetch_row(gStmt_AccountGetIpv4);

	stmt_bind_value(gStmt_AccountGetAliasesIp, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(gStmt_AccountGetAliasesIp, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesIp, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(gStmt_AccountGetAliasesIp))
		return 0;

	while(stmt_fetch_row(gStmt_AccountGetAliasesIp))
	{
		if(count < max)
			strcat(list[count][alias_Name], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		if(IsPlayerBanned(tempname))
			list[count][alias_Banned] = true;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByPass(name[], list[][E_ALIAS_DATA], &count, max, &adminlevel)
{
	new
		pass[129],
		tempname[MAX_PLAYER_NAME],
		templevel;

	stmt_bind_value(gStmt_AccountGetPass, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetPass, 0, DB::TYPE_STRING, pass, 129);

	if(!stmt_execute(gStmt_AccountGetPass))
		return 0;

	stmt_fetch_row(gStmt_AccountGetPass);

	stmt_bind_value(gStmt_AccountGetAliasesPass, 0, DB::TYPE_STRING, pass, 129);
	stmt_bind_value(gStmt_AccountGetAliasesPass, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesPass, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(gStmt_AccountGetAliasesPass))
		return 0;

	while(stmt_fetch_row(gStmt_AccountGetAliasesPass))
	{
		if(count < max)
			strcat(list[count][alias_Name], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		if(IsPlayerBanned(tempname))
			list[count][alias_Banned] = true;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByHash(name[], list[][E_ALIAS_DATA], &count, max, &adminlevel)
{
	new
		serial[41],
		tempname[MAX_PLAYER_NAME],
		templevel;

	stmt_bind_value(gStmt_AccountGetHash, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetHash, 0, DB::TYPE_STRING, serial, 41);

	if(!stmt_execute(gStmt_AccountGetHash))
		return 0;

	stmt_fetch_row(gStmt_AccountGetHash);

	if(isnull(serial))
		return 0;

	stmt_bind_value(gStmt_AccountGetAliasesHash, 0, DB::TYPE_STRING, serial, 41);
	stmt_bind_value(gStmt_AccountGetAliasesHash, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesHash, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(gStmt_AccountGetAliasesHash))
		return 0;

	while(stmt_fetch_row(gStmt_AccountGetAliasesHash))
	{
		if(serial[0] == '0')
			continue;

		if(count < max)
			strcat(list[count][alias_Name], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		if(IsPlayerBanned(tempname))
			list[count][alias_Banned] = true;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByAll(name[], list[][E_ALIAS_DATA], &count, max, &adminlevel)
{
	new
		ip,
		pass[129],
		serial[41],
		tempname[MAX_PLAYER_NAME],
		templevel;

	stmt_bind_value(gStmt_AccountGetAll, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAll, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_result_field(gStmt_AccountGetAll, 1, DB::TYPE_STRING, pass, sizeof(pass));
	stmt_bind_result_field(gStmt_AccountGetAll, 2, DB::TYPE_STRING, serial, sizeof(serial));

	if(!stmt_execute(gStmt_AccountGetAll))
		return 0;

	stmt_fetch_row(gStmt_AccountGetAll);

	stmt_bind_value(gStmt_AccountGetAliasesAll, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(gStmt_AccountGetAliasesAll, 1, DB::TYPE_STRING, pass, sizeof(pass));
	stmt_bind_value(gStmt_AccountGetAliasesAll, 2, DB::TYPE_STRING, serial, sizeof(serial));
	stmt_bind_value(gStmt_AccountGetAliasesAll, 3, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesAll, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(gStmt_AccountGetAliasesAll))
		return 0;

	while(stmt_fetch_row(gStmt_AccountGetAliasesAll))
	{
		if(count < max)
			strcat(list[count][alias_Name], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		if(IsPlayerBanned(tempname))
			list[count][alias_Banned] = true;

		count++;
	}

	return 1;
}

CheckForExtraAccounts(playerid)
{
	if(IsPlayerRegistered(playerid))
		return 0;

	new
		list[6][E_ALIAS_DATA],
		count,
		adminlevel,
		isbanned,
		string[(MAX_PLAYER_NAME + 2) * 6];

	adminlevel = GetPlayerAdminLevel(playerid);

	GetAccountAliasesByIP(gPlayerName[playerid], list, count, 6, adminlevel);

	if(count == 0)
		return 0;

	if(count == 1)
		strcat(string, list[0][alias_Name]);

	if(count > 1)
	{
		for(new i; i < count && i < sizeof(list); i++)
		{
			strcat(string, list[i][alias_Name]);
			strcat(string, ", ");
		}
	}

	if(adminlevel < 3)
		MsgAllF(YELLOW, " >  Aliases: "C_BLUE"(%d)"C_ORANGE" %s", count, string);

	if(isbanned)
		MsgAdminsF(1, RED, " >  Warning: One or more of those aliases is banned!");

	return 1;
}

