#include <YSI\y_hooks>


enum E_ALIAS_DATA
{
		alias_Name[MAX_PLAYER_NAME],
bool:	alias_Banned
}


static
DBStatement:	stmt_AliasesFromIp,
DBStatement:	stmt_AliasesFromPass,
DBStatement:	stmt_AliasesFromHash,
DBStatement:	stmt_AliasesFromAll;


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Aliases'...");

	stmt_AliasesFromIp = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_IPV4"=? AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
	stmt_AliasesFromPass = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_PASS"=? AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
	stmt_AliasesFromHash = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_GPCI"=? AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
	stmt_AliasesFromAll = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE ("FIELD_PLAYER_PASS"=? OR "FIELD_PLAYER_IPV4"=? OR "FIELD_PLAYER_GPCI" = ?) AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
}

stock GetAccountAliasesByIP(name[], list[][E_ALIAS_DATA], &count, max, &adminlevel)
{
	new
		ip,
		tempname[MAX_PLAYER_NAME],
		templevel;

	GetAccountIP(name, ip);

	if(ip == 0)
		return 0;

	stmt_bind_value(stmt_AliasesFromIp, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AliasesFromIp, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromIp, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromIp))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromIp))
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

	GetAccountPassword(name, pass);

	if(isnull(pass))
		return 0;

	stmt_bind_value(stmt_AliasesFromPass, 0, DB::TYPE_STRING, pass, 129);
	stmt_bind_value(stmt_AliasesFromPass, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromPass, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromPass))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromPass))
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

	GetAccountGPCI(name, serial);

	if(isnull(serial))
		return 0;

	if(serial[0] == '0')
		return 0;

	stmt_bind_value(stmt_AliasesFromHash, 0, DB::TYPE_STRING, serial, 41);
	stmt_bind_value(stmt_AliasesFromHash, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromHash, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromHash))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromHash))
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

stock GetAccountAliasesByAll(name[], list[][E_ALIAS_DATA], &count, max, &adminlevel)
{
	new
		pass[129],
		ip,
		serial[41],
		tempname[MAX_PLAYER_NAME],
		templevel;

	GetAccountAliasData(name, pass, ip, serial);

	if(isnull(serial))
		return 0;

	if(serial[0] == '0')
		return 0;

	stmt_bind_value(stmt_AliasesFromAll, 0, DB::TYPE_STRING, pass, sizeof(pass));
	stmt_bind_value(stmt_AliasesFromAll, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AliasesFromAll, 2, DB::TYPE_STRING, serial, sizeof(serial));
	stmt_bind_value(stmt_AliasesFromAll, 3, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromAll, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromAll))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromAll))
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

	GetAccountAliasesByAll(gPlayerName[playerid], list, count, 6, adminlevel);

	for(new i; i < count && i < sizeof(list); i++)
	{
		if(list[i][alias_Banned])
		{
			MsgAdminsF(1, RED, " >  Warning: One or more of those aliases is banned!");
			break;
		}
	}

	return 1;
}

